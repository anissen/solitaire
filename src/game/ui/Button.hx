package game.ui;

import luxe.Input;
import luxe.Vector;
import luxe.Text;
import luxe.Color;
import luxe.tween.Actuate;

typedef ButtonOptions = {
    pos :Vector,
    ?width :Int,
    ?height :Int,
    ?font_size :Int,
    ?text :String,
    on_click :Void->Void
}

class Button extends luxe.NineSlice {
    var label :Text;
    var hovered :Bool = false;
    var on_click :Void->Void;

    public function new(options :ButtonOptions) {
        super({
            name_unique: true,
            texture: Luxe.resources.texture('assets/ui/buttonLong_brown_pressed.png'),
            top: 20,
            left: 50,
            right: 50,
            bottom: 20,
            color: new Color(1, 1, 1, 1),
            depth: 100
        });
        var width = (options.width != null ? options.width : 200);
        var height = (options.height != null ? options.height : 40);
        var font_size = (options.font_size != null ? options.font_size : 24);
        var text = (options.text != null ? options.text : '');
        on_click = options.on_click;
        this.create(Vector.Subtract(options.pos, new Vector(width / 2, height / 2)), width, height);

        label = new Text({
            parent: this,
            text: text,
            pos: new Vector(width / 2, height / 2),
            point_size: font_size,
            align: luxe.Text.TextAlign.center,
            align_vertical: luxe.Text.TextAlign.center,
            color: new luxe.Color(1.0, 1.0, 1.0),
            depth: this.depth + 0.1
        });

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
            play_sound('ui_click.ogg');
            on_click();
        }
    }

    function play_sound(id :String) {
        var sound = Luxe.resources.audio('assets/sounds/$id');
        Luxe.audio.play(sound.source);
    }

    /** Returns true if a point is inside the AABB unrotated */
    public function point_inside_AABB(_p :Vector) :Bool {
        if (pos == null) return false;
        if (size == null) return false;

        // scaled size
        var _s_x = size.x * scale.x;
        var _s_y = size.y * scale.y;

        if (_p.x < pos.x) return false;
        if (_p.y < pos.y) return false;
        if (_p.x > pos.x+_s_x) return false;
        if (_p.y > pos.y+_s_y) return false;

        return true;
    }
}