package game.entities;

import luxe.Scene;
import luxe.Text;
import luxe.Entity;
import luxe.Color;
import luxe.Vector;
import luxe.Sprite;
import luxe.tween.Actuate;
import snow.api.Promise;
import game.misc.Settings;

typedef TutorialBoxOptions = {

}

class TutorialBox extends Entity {
    var promise :Promise;
    var promise_resolve :Void->Void;

    public function new(_options :TutorialBoxOptions) {
        super({ name: 'TutorialBox' + Luxe.utils.uniqueid() });

        promise = new Promise(function(resolve, reject) {
            promise_resolve = resolve;
        });
    }

    override function init() {
        var tutorial_box = new Sprite({
            pos: new Vector(Settings.WIDTH / 2, Settings.HEIGHT / 2),
            size: new Vector(Settings.WIDTH, 80),
            depth: 1000
        });
        var tutorial_shadow = new Sprite({
            parent: tutorial_box,
            pos: Vector.Divide(tutorial_box.size, 2),
            texture: Luxe.resources.texture('assets/images/tutorial/box_shadow.png'),
            size: Vector.Multiply(tutorial_box.size, 2),
            // scale: new Vector(2, 2),
            depth: tutorial_box.depth - 1,
            color: new Color(1, 0, 0)
        });
        new luxe.Text({
            parent: tutorial_box,
            pos: Vector.Divide(tutorial_box.size, 2),
            align: center,
            align_vertical: center,
            color: new Color(0, 0, 0, 1),
            point_size: 22,
            text: 'Some tutorial text\ngoes here!',
            depth: 1010
        });
        Actuate.tween(tutorial_box.pos, 0.5, { y: tutorial_box.pos.y + 2 }).reflect().repeat();
    }

    public function point_to(pos :Vector) {
        
    }

    public function get_promise() :Promise {
        return promise;
    }
}
