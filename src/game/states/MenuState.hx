package game.states;

import luxe.Text;
import luxe.States.State;
import luxe.Vector;
import luxe.Color;

import game.ui.Button;

class MenuState extends State {
    static public var StateId :String = 'MenuState';
    var title :Text;

    public function new() {
        super({ name: StateId });
    }

    override function init() {

    }

    override function onenter(data :Dynamic) {
        title = new Text({
            text: 'Solitaire',
            pos: new Vector(Settings.WIDTH / 2, 100),
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

        var normal_save = Luxe.io.string_load('save_normal');

        var play_button = new Button({
            pos: new Vector(Settings.WIDTH / 2, Settings.HEIGHT / 2),
            text: (normal_save == null ? 'Play' : '~ Play ~'),
            on_click: Main.SetState.bind(PlayState.StateId)
        });

        var strive_save = Luxe.io.string_load('save_strive');
        var strive_level = Luxe.io.string_load('strive_level');
        var strive_button = new Button({
            pos: new Vector(Settings.WIDTH / 2, Settings.HEIGHT / 2 + 60),
            text: (strive_save == null ? '' : '~ ') + (strive_level != null ? 'Strive $strive_level' : 'Strive') +(strive_save == null ? '' : ' ~'),
            on_click: Main.SetState.bind(PlayState.StateId, PlayState.GameMode.Strive(strive_level != null ? Std.parseInt(strive_level) : 1))
        });
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
