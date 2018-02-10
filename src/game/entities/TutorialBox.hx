package game.entities;

import luxe.Text;
import luxe.Color;
import luxe.Vector;
import luxe.Sprite;
import luxe.tween.Actuate;
import snow.api.Promise;
import game.misc.Settings;

typedef TutorialBoxOptions = {

}

class TutorialBox extends Sprite {
    var label :Text;
    var tutorial_texts :Array<String> = [];
    var promise :Promise;
    var promise_resolve :Void->Void = null;
    var tutorial_scene :luxe.Scene = new luxe.Scene();
    var shadow :Sprite;

    public function new(_options :TutorialBoxOptions) {
        super({
            name: 'TutorialBox' + Luxe.utils.uniqueid(),
            pos: new Vector(Settings.WIDTH / 2, Settings.HEIGHT / 2),
            size: new Vector(Settings.WIDTH, 90),
            depth: 1000,
            scene: tutorial_scene
        });

        shadow = new Sprite({
            parent: this,
            pos: Vector.Divide(this.size, 2),
            texture: Luxe.resources.texture('assets/images/tutorial/box_shadow.png'),
            size: Vector.Multiply(this.size, 2),
            depth: this.depth - 1,
            color: new Color(1, 1, 1),
            scene: tutorial_scene
        });
        label = new luxe.Text({
            parent: this,
            pos: Vector.Divide(this.size, 2),
            align: center,
            align_vertical: center,
            color: new Color(0, 0, 0, 1),
            point_size: 22,
            text: 'Some tutorial text\ngoes here!',
            depth: 1010,
            scene: tutorial_scene
        });

        this.visible = false;
        shadow.visible = false;
        label.visible = false;

        // promise = new Promise(function(resolve, reject) {
        //     promise_resolve = resolve;
        //     trace('setting promise_resolve to ' + resolve);
        // });
    }

    override function init() {
        trace('tutorialbox init');
    }

    public function point_to(entity :luxe.Visual) {
        // trace('point_to ');
        var arrow_height = 86 * 0.9 /* scale */;
        var pointing_up = (entity.pos.y < this.pos.y);
        var y = entity.pos.y + (entity.size.y / 3 + arrow_height / 2) * (pointing_up ? 1 : -1);

        new Sprite({
            pos: entity.pos,
            texture: Luxe.resources.texture('assets/images/symbols/circle.png'),
            size: Vector.Multiply(entity.size, 1.8),
            color: new Color(1, 1, 1, 0.2),
            depth: this.depth - 0.2,
            scene: tutorial_scene
        });

        // new Sprite({
        //     pos: entity.pos,
        //     texture: Luxe.resources.texture('assets/images/symbols/square.png'),
        //     size: Vector.Multiply(entity.size, 1.5),
        //     color: new Color(1, 1, 1, 0.2),
        //     depth: this.depth - 0.2
        // });

        var arrow = new Sprite({
            pos: new Vector(entity.pos.x, this.pos.y),
            texture: Luxe.resources.texture('assets/images/tutorial/arrow.png'),
            scale: new Vector(0.9, 0.9 * (pointing_up ? 1 : -1)),
            depth: this.depth - 0.1,
            color: new Color(1, 1, 1, 0),
            scene: tutorial_scene
        });
    
        return Actuate.tween(arrow.color, 0.3, { a: 1 }).onComplete(function(_) {
            Actuate.tween(arrow.pos, 1.0, { y: y });
        });
    }

    public function show(texts :Array<String>, entities :Array<luxe.Visual>) {
        promise = new Promise(function(resolve, reject) {
            promise_resolve = resolve;

            var center_y = 0.0;
            for (entity in entities) {
                center_y += (entity.pos.y - Settings.HEIGHT / 2);
            }
            this.pos.y = Settings.HEIGHT / 2 + (center_y / entities.length) * 0.4 /* how much to move towards pointing locations */;
            /*
            var old_size_y = this.size.y;
            this.size.y = 0;
            shadow.size.y = 0;
            var fold_out_duration = 1.5;
            Actuate.tween(this.size, fold_out_duration, { y: old_size_y });
            Actuate.tween(shadow.size, fold_out_duration, { y: old_size_y * 2 });
            Actuate.tween(shadow.pos, fold_out_duration, { y: old_size_y / 2 });
            // shadow.color.a = 0;
            // Actuate.tween(shadow.color, fold_out_duration, { a: 1 });
            */

            this.visible = true;
            shadow.visible = true;
            label.visible = true;
            Actuate.tween(this.pos, 0.5, { y: this.pos.y + 2 }).reflect().repeat();

            var delay = 0.3;
            for (entity in entities) {
                // trace('tutorial card pos: ${entity.pos}');
                point_to(entity).delay(delay);
                delay += 0.5;
            }

            tutorial_texts = texts;
            proceed();
        });

        return promise;
    }

    public function proceed() :Promise {
        var nextText = tutorial_texts.shift();
        if (nextText == null) {
            // if (promise_resolve != null) promise_resolve();
            hide();
            promise_resolve();
            return Promise.resolve();
        }
        label.text = nextText;
        return get_promise();
        // return Promise.resolve();
    }

    function hide() {
        tutorial_scene.empty();
    }

    override public function onmouseup(event :luxe.Input.MouseEvent) {
        proceed();
    }

    public function get_promise() :Promise {
        return promise;
    }
}
