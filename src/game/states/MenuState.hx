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
        var play_button = new Button(new Vector(Settings.WIDTH / 2, Settings.HEIGHT / 2));
        play_button.assign('Play');
        play_button.events.listen('click', function(_) {
            trace('new game');
            Main.NewGame();
        });

        var strive_button = new Button(new Vector(Settings.WIDTH / 2, Settings.HEIGHT / 2 + 60));
        strive_button.assign('Strive');
        strive_button.events.listen('click', function(_) {
            trace('new game -- strive');
            Main.NewGame();
        });
    }

    override function onleave(_) {
        Luxe.scene.empty();
    }
}
