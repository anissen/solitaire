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
            pos: new Vector(Settings.WIDTH / 2, 80),
            point_size: 36,
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
            pos: new Vector(25, 25),
            texture_path: 'assets/ui/arrowBeige_left.png',
            on_click: Main.SetState.bind(MenuState.StateId)
        });
        back_button.scale.set_xy(1/5, 1/5);

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
                Luxe.audio.active = (!audio_enabled);
                if (!audio_enabled) {
                    Luxe.audio.suspend();
                    music_enabled = false;
                    music_button.enabled = false;
                    music_button.text = 'Music Off';
                } else {
                    Luxe.audio.resume();
                    music_enabled = true;
                    if (Luxe.io.string_load('music_enabled') == 'false') music_enabled = false;
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
                // Luxe.audio.stop();
                Luxe.io.string_save('music_enabled', (music_enabled ? 'true' : 'false'));
            },
            disabled: (!audio_enabled)
        });

        var reset_tutorial_enabled = false;
        if (Luxe.io.string_load('tutorial_enabled') == 'false') reset_tutorial_enabled = true;
        var reset_tutorial_button :Button;
        reset_tutorial_button = new Button({
            pos: new Vector(Settings.WIDTH / 2, get_button_y() + button_height),
            text: 'Reset Tutorial',
            on_click: function() {
                reset_tutorial_button.enabled = false;
                Luxe.io.string_save('tutorial_enabled', 'true');
            },
            disabled: (!reset_tutorial_enabled)
        });
    }

    override function onleave(_) {
        Luxe.scene.empty();
    }
}
