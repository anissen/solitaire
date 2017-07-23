package game.ui;

import luxe.Input;
import luxe.Vector;
import luxe.Sprite;
import luxe.tween.Actuate;

typedef IconOptions = {
    pos :Vector,
    texture_path :String,
    on_click :Void->Void
}

class Icon extends Sprite {
    var hovered :Bool = false;
    var on_click :Void->Void;

    public function new(options :IconOptions) {
        super({
            name_unique: true,
            texture: Luxe.resources.texture(options.texture_path),
            pos: options.pos
        });
        on_click = options.on_click;

        this.scale.y = 0;
        Actuate
            .tween(this.scale, 0.3, { y: 1 })
            .delay(Math.random() * 0.2)
            .ease(luxe.tween.easing.Cubic.easeInOut);
    }

    override function onmousemove(event :MouseEvent) {
        var world_pos = Luxe.camera.screen_point_to_world(event.pos);
        if (point_inside_AABB(world_pos)) {
            if (!hovered) {
                hovered = true;
                color.tween(0.1, { a: 0.7 });
                Actuate
                    .tween(this.pos, 0.3, { y: this.pos.y + 2 })
                    .reflect()
                    .repeat()
                    .ease(luxe.tween.easing.Sine.easeInOut);
            }
        } else {
            if (hovered) {
                hovered = false;
                Actuate.stop(this.pos);
                color.tween(0.1, { a: 1.0 });
            }
        }
    }

    override public function onmouseup(event :MouseEvent) {
        var world_pos = Luxe.camera.screen_point_to_world(event.pos);
        if (point_inside_AABB(world_pos)) {
            Luxe.audio.play(Luxe.resources.audio('assets/sounds/ui_click.wav').source);
            on_click();
        }
    }
}
