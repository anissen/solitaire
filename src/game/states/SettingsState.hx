package game.states;

import luxe.Text;
import luxe.States.State;
import luxe.Vector;
import luxe.Color;

import game.ui.Button;

class SettingsState extends State {
    static public var StateId :String = 'SettingsState';
    var title :Text;

    public function new() {
        super({ name: StateId });
    }

    override function init() {

    }

    override function onenter(data :Dynamic) {
        title = new Text({
            text: 'Settings',
            pos: new Vector(Settings.WIDTH / 2, 50),
            point_size: 30,
            align: luxe.Text.TextAlign.center,
            align_vertical: luxe.Text.TextAlign.center,
            color: new luxe.Color(1.0, 1.0, 1.0),

            letter_spacing: 0,
            sdf: true,
            shader: Luxe.renderer.shaders.bitmapfont.shader.clone('title-shader'),
            outline: 0.75,
            outline_color: new Color().rgb(0xa55004),
        });
        // luxe.tween.Actuate.tween(title, 3.0, { outline: 0.65, letter_spacing: -1.5 }).reflect().repeat();

        var back_button = new game.ui.Icon({
            pos: new Vector(30, 30),
            texture_path: 'assets/ui/arrowBeige_left.png',
            on_click: Main.SetState.bind(MenuState.StateId)
        });
        back_button.scale.set_xy(1/4, 1/4);

        // new Text({
        //     // pos: new Vector(90, 190),
        //     pos: Luxe.camera.center.clone(),
        //     text: 'Settings goes here',
        //     align: TextAlign.center,
        //     align_vertical: TextAlign.center,
        //     color: new Color().rgb(0x956416),
        //     point_size: 26
        // });

        var button_height = 60;
        var button_count = 0;
        function get_button_y() {
            return 150 + (button_count++) * button_height;
        }

        var audio_enabled = true;
        if (Luxe.io.string_load('audio_enabled') == 'false') audio_enabled = false;
        var music_enabled = true;
        if (Luxe.io.string_load('music_enabled') == 'false') music_enabled = false;
        
        var audio_button :Button;
        var music_button :Button;
        
        audio_button = new Button({
            pos: new Vector(Settings.WIDTH / 2, get_button_y()),
            text: (audio_enabled ? 'Audio On' : 'Audio Off'),
            on_click: function() {
                audio_enabled = (!audio_enabled);
                audio_button.text = (audio_enabled ? 'Audio On' : 'Audio Off');
                if (!audio_enabled) {
                    Luxe.audio.suspend();
                    music_enabled = false;
                    music_button.enabled = false;
                    music_button.text = 'Music Off';
                } else {
                    Luxe.audio.resume();
                    music_enabled = true;
                    if (Luxe.io.string_load('music_enabled') == 'false') {
                        music_enabled = false;
                    } else {
                        Main.start_music();
                    }
                    music_button.enabled = true;
                    music_button.text = (music_enabled ? 'Music On' : 'Music Off');
                }
                Luxe.io.string_save('audio_enabled', (audio_enabled ? 'true' : 'false'));
            }
        });

        music_button = new Button({
            pos: new Vector(Settings.WIDTH / 2, get_button_y()),
            text: (music_enabled ? 'Music On' : 'Music Off'),
            on_click: function() {
                music_enabled = (!music_enabled);
                music_button.text = (music_enabled ? 'Music On' : 'Music Off');
                Luxe.io.string_save('music_enabled', (music_enabled ? 'true' : 'false'));
                if (music_enabled) {
                    Main.start_music();
                } else {
                    Main.stop_music();
                }
            },
            disabled: (!audio_enabled)
        });

        new Button({
            pos: new Vector(Settings.WIDTH / 2, get_button_y() + button_height),
            text: 'Change Name',
            on_click: function() {
                Main.SetState(TextInputState.StateId, { 
                    done_func: function(user_name :String) {
                        core.utils.AsyncHttpUtils.post(Settings.SERVER_URL + 'change_name/', [
                            "user_id" => Luxe.io.string_load('clientId'),
                            "user_name" => user_name
                        ]);
                        Main.SetState(SettingsState.StateId);
                    }
                });
            }
        });

        var reset_tutorial_enabled = false;
        var tutorial_completed = (Luxe.io.string_load('tutorial_complete') == 'true');
        if (tutorial_completed) reset_tutorial_enabled = true;
        var reset_tutorial_button :Button;
        reset_tutorial_button = new Button({
            pos: new Vector(Settings.WIDTH / 2, get_button_y() + button_height),
            text: 'Reset Tutorial',
            on_click: function() {
                reset_tutorial_button.enabled = false;
                Luxe.io.string_save('tutorial_menu_complete', null);
                Luxe.io.string_save('tutorial_complete', null);
                Luxe.io.string_save('tutorial_complete_journey', null);
                Luxe.io.string_save('tutorial_complete_timed', null);
            },
            disabled: (!reset_tutorial_enabled)
        });
    }

    override function onkeyup(event :luxe.Input.KeyEvent) {
        if (event.keycode == luxe.Input.Key.ac_back) {
            Main.SetState(MenuState.StateId);
        }
    }

    override function onleave(_) {
        Luxe.scene.empty();
    }
}
