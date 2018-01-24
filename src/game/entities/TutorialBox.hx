package game.entities;

import luxe.Text;
import luxe.Color;
import luxe.Vector;
import luxe.Sprite;
import luxe.tween.Actuate;
import game.misc.Settings;

typedef TutorialBoxOptions = {

}

class TutorialBox extends Sprite {
    var text :Text;
    // var promise :Promise;
    // var promise_resolve :Void->Void;

    public function new(_options :TutorialBoxOptions) {
        super({
            name: 'TutorialBox' + Luxe.utils.uniqueid(),
            pos: new Vector(Settings.WIDTH / 2, Settings.HEIGHT / 2),
            size: new Vector(Settings.WIDTH, 90),
            depth: 1000    
        });

        // promise = new Promise(function(resolve, reject) {
        //     promise_resolve = resolve;
        // });
    }

    override function init() {
        var tutorial_shadow = new Sprite({
            parent: this,
            pos: Vector.Divide(this.size, 2),
            texture: Luxe.resources.texture('assets/images/tutorial/box_shadow.png'),
            size: Vector.Multiply(this.size, 2),
            depth: this.depth - 1,
            color: new Color(1, 0, 0)
        });
        text = new luxe.Text({
            parent: this,
            pos: Vector.Divide(this.size, 2),
            align: center,
            align_vertical: center,
            color: new Color(0, 0, 0, 1),
            point_size: 22,
            text: 'Some tutorial text\ngoes here!',
            depth: 1010
        });
    }

    public function point_to(entity :luxe.Visual) {
        trace('point_to ');
        var arrow_height = 86 * 0.9 /* scale */;
        var pointing_up = (entity.pos.y < this.pos.y);
        var y = entity.pos.y + (entity.size.y / 3 + arrow_height / 2) * (pointing_up ? 1 : -1);

        new Sprite({
            pos: entity.pos,
            texture: Luxe.resources.texture('assets/images/symbols/circle.png'),
            size: Vector.Multiply(entity.size, 1.8),
            color: new Color(1, 1, 1, 0.1),
            depth: this.depth - 0.2
        });

        var arrow = new Sprite({
            pos: new Vector(entity.pos.x, this.pos.y),
            texture: Luxe.resources.texture('assets/images/tutorial/arrow.png'),
            scale: new Vector(0.9, 0.9 * (pointing_up ? 1 : -1)),
            depth: this.depth - 0.1,
            color: new Color(1, 1, 1)
        });
        return Actuate.tween(arrow.pos, 1.0, { y: y });
    }

    public function show(texts :Array<String>, entities :Array<luxe.Visual>) {
        var center_y = 0.0;
        for (entity in entities) {
            center_y += (entity.pos.y - Settings.HEIGHT / 2);
        }
        this.pos.y = Settings.HEIGHT / 2 + (center_y / entities.length) * 0.4 /* how much to move towards pointing locations */;
        Actuate.tween(this.pos, 0.5, { y: this.pos.y + 2 }).reflect().repeat();

        var delay = 0.3;
        for (entity in entities) {
            point_to(entity).delay(delay);
            delay += 0.5;
        }

        text.text = texts.first();
    }

    public function proceed() {

    }

    // public function get_promise() :Promise {
    //     return promise;
    // }
}
