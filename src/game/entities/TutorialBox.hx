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

typedef TutorialData = { texts :Array<String>, ?entities :Array<luxe.Visual> };

class TutorialBox extends Sprite {
    var label :game.entities.RichText;
    var tutorial_texts :Array<String> = [];
    var promise :Promise;
    var promise_resolve :Void->Void = null;
    var tutorial_scene :luxe.Scene = new luxe.Scene();
    var tutorial_temp_scene :luxe.Scene = new luxe.Scene();
    var tutorial_dismissable :Bool;
    var tutorial_active :Bool;
    var tutorial_promise_queue :core.queues.SimplePromiseQueue<TutorialData>;
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
        label = new game.entities.RichText({
            parent: this,
            pos: Vector.Divide(this.size, 2),
            align: center,
            align_vertical: center,
            color: new Color(0, 0, 0, 1),
            point_size: 22,
            text: '',
            depth: 1010,
            scene: tutorial_scene,
            tags : [
				{ 
                    name: "brown", 
                    color: new Color().rgb(0x964B00)
                }
			],
        });

        this.visible = false;
        shadow.visible = false;
        label.visible = false;

        tutorial_dismissable = true;
        tutorial_active = false;

        tutorial_promise_queue = new core.queues.SimplePromiseQueue();
        tutorial_promise_queue.set_handler(show);
    }

    public function point_to(entity :luxe.Visual) {
        // trace('point_to ');
        var arrow_height = 86 * 0.9 /* scale */;
        var pointing_up = (entity.pos.y < this.pos.y);
        var y = entity.pos.y + (entity.size.y / 3 + arrow_height / 2) * (pointing_up ? 1 : -1);

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
            scene: tutorial_temp_scene
        });
    
        return Actuate.tween(arrow.color, 0.3, { a: 1 }).onComplete(function(_) {
            Actuate.tween(arrow.pos, 1.0, { y: y }).onComplete(function(_) {
               new Sprite({
                    pos: entity.pos,
                    texture: Luxe.resources.texture('assets/images/symbols/circle.png'),
                    size: Vector.Multiply(entity.size, 1.8),
                    color: new Color(1, 1, 1, 0.2),
                    depth: this.depth - 0.2,
                    scene: tutorial_temp_scene
                }); 
            });
        });
    }

    public function show(data :TutorialData) {
        var entities = data.entities;
        if (entities == null) entities = [];
        promise = new Promise(function(resolve, reject) {
            tutorial_active = true;
            tutorial_dismissable = false;
            promise_resolve = resolve;

            var center_y = 0.0;
            for (entity in entities) {
                center_y += (entity.pos.y - Settings.HEIGHT / 2);
            }
            var pos_y = Settings.HEIGHT / 2 + (entities.empty() ? 0.0 : (center_y / entities.length) * 0.4 /* how much to move towards pointing locations */);
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
            label.text = '';
            Actuate.tween(this.pos, 0.5, { y: pos_y }).ease(luxe.tween.easing.Sine.easeInOut).onComplete(function(_) {
                Actuate.tween(this.pos, 0.5, { y: this.pos.y + 2 }).reflect().repeat().ease(luxe.tween.easing.Sine.easeInOut);

                var delay = 0.3;
                for (entity in entities) {
                    // trace('tutorial card pos: ${entity.pos}');
                    point_to(entity).delay(delay);
                    delay += 0.5;
                }

                tutorial_texts = data.texts;
                proceed();
                Actuate.timer(delay + 0.5).onComplete(function(_) {
                    tutorial_dismissable = true;
                });
            });
        });

        return promise;
    }

    public function proceed() :Promise {
        var nextText = tutorial_texts.shift();
        if (nextText == null) {
            // if (promise_resolve != null) promise_resolve();
            hide();
            trace('promise_resolve');
            promise_resolve();
            return Promise.resolve();
        }
        label.text = nextText;
        label.play();
        return get_promise();
        // return Promise.resolve();
    }

    public function tutorial(data :TutorialData) :Promise {
        // if (Luxe.io.string_load(id) != null) return Promise.resolve();
        // Luxe.io.string_save(id, 'done');

        return tutorial_promise_queue.handle(data);
    }

    function hide() {
        // tutorial_scene.empty();
        this.visible = false;
        shadow.visible = false;
        label.visible = false;
        tutorial_temp_scene.empty();
        tutorial_dismissable = false;
        tutorial_active = false;
    }

    public function is_active() {
        return tutorial_active;
    }

    override public function onmouseup(event :luxe.Input.MouseEvent) {
        if (!tutorial_dismissable) return;
        proceed();
    }

    public function get_promise() :Promise {
        return promise;
    }
}
