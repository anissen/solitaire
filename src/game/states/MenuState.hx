package game.states;

import luxe.Text;
import luxe.States.State;
import luxe.Vector;
import luxe.Color;

import game.ui.Button;

using game.misc.GameMode.GameModeTools;

class MenuState extends State {
    static public var StateId :String = 'MenuState';
    var title :Text;

    public function new() {
        super({ name: StateId });
    }

    override function init() {

    }

    override function onenter(data :Dynamic) {
        var icon = new luxe.Sprite({
            pos: new Vector(Settings.WIDTH / 2 - 20, 80),
            texture: Luxe.resources.texture('assets/ui/pyramids.png'),
            scale: new Vector(0.5, 0.5)
        });

        title = new Text({
            text: 'Solitaire',
            pos: new Vector(Settings.WIDTH / 2, 80),
            point_size: 42,
            align: luxe.Text.TextAlign.center,
            align_vertical: luxe.Text.TextAlign.center,
            color: new luxe.Color(1.0, 1.0, 1.0),

            letter_spacing: 0,
            sdf: true,
            shader: Luxe.renderer.shaders.bitmapfont.shader.clone('title-shader'),
            outline: 0.75,
            outline_color: new Color().rgb(0xa55004),
        });
        luxe.tween.Actuate.tween(title, 3.0, { outline: 0.65, letter_spacing: -1.5 }).reflect().repeat();

        var config_button = new game.ui.Icon({
            pos: new Vector(35, 35),
            texture_path: 'assets/ui/circular.png',
            on_click: function() { trace('config button'); }
        });
        config_button.scale.set_xy(1/5, 1/5);
        config_button.color.a = 0.75;
        new luxe.Sprite({
            texture: Luxe.resources.texture('assets/ui/cog.png'),
            parent: config_button,
            pos: new Vector(128, 128),
            scale: new Vector(0.5, 0.5),
            color: new Color().rgb(0x8C7D56),
            depth: 110
        });

        var about_button = new game.ui.Icon({
            pos: new Vector(Settings.WIDTH - 35, 35),
            texture_path: 'assets/ui/circular.png',
            on_click: function() { trace('about button'); }
        });
        about_button.scale.set_xy(1/5, 1/5);
        about_button.color.a = 0.75;
        new luxe.Sprite({
            texture: Luxe.resources.texture('assets/ui/book.png'),
            parent: about_button,
            pos: new Vector(128, 128),
            scale: new Vector(0.5, 0.5),
            color: new Color().rgb(0x8C7D56),
            depth: 110
        });

        var star = new luxe.Sprite({
            pos: new Vector(55, 190),
            texture: Luxe.resources.texture('assets/images/symbols/star.png'),
            scale: new Vector(0.15, 0.15),
            color: new Color().rgb(0xFFFFFF),
            depth: 10
            // color: new Color().rgb(0xFFD48F)
        });
        luxe.tween.Actuate
            .tween(star, 10.0, { rotation_z: 360 })
            .ease(luxe.tween.easing.Linear.easeNone)
            .repeat(); // spin faster when gaining points?

        new Text({
            pos: new Vector(90, 190),
            text: 'Rank 3/853',
            align: TextAlign.left,
            align_vertical: TextAlign.center,
            color: new Color().rgb(0x956416),
            point_size: 26
        });

        var normal_save = Luxe.io.string_load('save_normal');

        var button_height = 60;
        var button_count = 0;
        function get_button_y() {
            return 250 + (button_count++) * button_height;
        }
        var play_button = new Button({
            pos: new Vector(Settings.WIDTH / 2, get_button_y()),
            text: (normal_save == null ? 'Normal' : '~ Normal ~'),
            on_click: Main.SetState.bind(PlayState.StateId)
        });

        // var play_stats = new game.ui.Icon({
        //     pos: new Vector(play_button.pos.x + play_button.width - 30, play_button.pos.y + 22),
        //     texture_path: 'assets/ui/stars.png',
        //     on_click: function() { trace('stats button'); }
        // });
        // play_stats.scale.set_xy(1/7, 1/7);
        // play_stats.depth = 200;

        var strive_save = Luxe.io.string_load('save_strive');
        var strive_level = Luxe.io.string_load('strive_level');
        var strive_mode = game.misc.GameMode.GameMode.Strive(strive_level != null ? Std.parseInt(strive_level) : 1);
        var strive_button = new Button({
            pos: new Vector(Settings.WIDTH / 2, get_button_y()),
            text: (strive_save == null ? '' : '~ ') + (strive_level != null ? 'Strive for ${strive_mode.get_strive_score()}' : 'Strive') +(strive_save == null ? '' : ' ~'),
            on_click: Main.SetState.bind(PlayState.StateId, strive_mode)
        });

        var timed_button = new Button({
            pos: new Vector(Settings.WIDTH / 2, get_button_y()),
            text: 'Unlock: 1000', //'Timed',
            on_click: function() { trace('timed button'); },
            disabled: true
        });
        timed_button.color.a = 0.2;

        var puzzle_button = new Button({
            pos: new Vector(Settings.WIDTH / 2, get_button_y()),
            text: 'Unlock: 2000', //'Puzzle',
            on_click: function() { trace('puzzle button'); },
            disabled: true
        });
        puzzle_button.color.a = 0.2;
    }

    override function onleave(_) {
        Luxe.scene.empty();
    }

    #if sys
    override function onkeyup(event :luxe.Input.KeyEvent) {
        if (event.keycode == luxe.Input.Key.escape) {
            Luxe.shutdown();
        }
    }
    // #else
    // override function onkeyup(event :luxe.Input.KeyEvent) {
    //     if (event.keycode == luxe.Input.Key.key_p) {
    //         trace('plus');
    //         title.outline += 0.1;
    //     } else if (event.keycode == luxe.Input.Key.key_m) {
    //         trace('minus');
    //         title.outline -= 0.1;
    //     }
    //     trace('outline: ${title.outline}');
    // }
    #end
}
