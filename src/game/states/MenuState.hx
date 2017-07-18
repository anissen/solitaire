package game.states;

import luxe.Text;
import luxe.States.State;
import luxe.Vector;
import luxe.Sprite;
import luxe.Color;
import luxe.tween.Actuate;


class MenuState extends State {
    static public var StateId :String = 'MenuState';

    public function new() {
        super({ name: StateId });
    }

    override function init() {

    }

    override function onenter(data :Dynamic) {
        var button = new game.ui.Button(new Vector(Settings.WIDTH / 2, Settings.HEIGHT / 2));
        // button.pos.set_xy(Settings.WIDTH / 2, Settings.HEIGHT / 2);
        button.assign('Play');
        button.events.listen('click', function(_) {
            trace('new game');
            Main.NewGame();
        });
    }

    override function onleave(_) {
        Luxe.scene.empty();
    }
}
