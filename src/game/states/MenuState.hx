package game.states;

import luxe.Text;
import luxe.States.State;
import luxe.Vector;
import luxe.Color;

import game.ui.Button;

class MenuState extends State {
    static public var StateId :String = 'MenuState';

    public function new() {
        super({ name: StateId });
    }

    override function init() {

    }

    override function onenter(data :Dynamic) {
        var title = new Text({
            text: 'Solitaire',
            pos: new Vector(Settings.WIDTH / 2, 100),
            point_size: 42,
            align: luxe.Text.TextAlign.center,
            align_vertical: luxe.Text.TextAlign.center,
            color: new luxe.Color(1.0, 1.0, 1.0)
        });

        var normal_save = Luxe.io.string_load('save_normal');

        var play_button = new Button({
            pos: new Vector(Settings.WIDTH / 2, Settings.HEIGHT / 2),
            text: (normal_save == null ? 'Play' : 'Continue Play'),
            on_click: Main.SetState.bind(PlayState.StateId)
        });

        var strive_save = Luxe.io.string_load('save_strive');
        var strive_level = Luxe.io.string_load('strive_level');
        var strive_button = new Button({
            pos: new Vector(Settings.WIDTH / 2, Settings.HEIGHT / 2 + 60),
            text: (strive_save == null ? '' : 'Continue ') + (strive_level != null ? 'Strive (Level $strive_level)' : 'Strive'),
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
    #end
}
