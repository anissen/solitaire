package game.states;

import luxe.Text;
import luxe.States.State;
import luxe.Vector;
import luxe.Sprite;
import luxe.Color;
import luxe.tween.Actuate;

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

        var play_button = new Button(new Vector(Settings.WIDTH / 2, Settings.HEIGHT / 2));
        play_button.assign('Play');
        play_button.events.listen('click', function(_) {
            trace('new game');
            Main.SetState(PlayState.StateId);
        });

        var strive_level = Luxe.io.string_load('strive_level');
        var strive_button = new Button(new Vector(Settings.WIDTH / 2, Settings.HEIGHT / 2 + 60));
        strive_button.assign(strive_level != null ? 'Strive (Level $strive_level)' : 'Strive');
        strive_button.events.listen('click', function(_) {
            trace('new game -- strive');
            Main.SetState(PlayState.StateId, PlayState.GameMode.Strive(strive_level != null ? Std.parseInt(strive_level) : 1));
        });
    }

    override function onleave(_) {
        Luxe.scene.empty();
    }
}
