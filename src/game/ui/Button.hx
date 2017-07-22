package game.ui;

import luxe.Input;
import luxe.Vector;
import luxe.Visual;
import luxe.Text;
import luxe.Color;
import luxe.tween.Actuate;

class Button extends luxe.NineSlice {
    // static var SIZE = 150;
    // public var x :Int;
    // public var y :Int;
    var text :Text;
    var hovered :Bool = false;

    // TODO: Take an options object instead
    public function new(pos :Vector, width :Float = 200, height :Float = 40) {
        super({
            name_unique: true,
            texture: Luxe.resources.texture('assets/ui/buttonLong_brown_pressed.png'),
            top: 20,
            left: 50,
            right: 50,
            bottom: 20,
            color: new Color(1, 1, 1, 1)
        });
        this.create(Vector.Subtract(pos, new Vector(width / 2, height / 2)), width, height);

        // new Visual({
        //     pos: new Vector(SIZE * 0.05, SIZE * 0.05),
        //     size: new Vector(SIZE * 0.9, SIZE * 0.9),
        //     color: new Color(0.75, 0.75, 0.75, 0.5),
        //     parent: this
        // });

        text = new Text({
            parent: this,
            text: 'PLAY',
            pos: new Vector(width / 2, height / 2),
            point_size: 24,
            align: luxe.Text.TextAlign.center,
            align_vertical: luxe.Text.TextAlign.center,
            color: new luxe.Color(1.0, 1.0, 1.0)
        });

        this.scale.set_xy(0, 0);
        Actuate
            .tween(this.scale, 0.5, { x: 1, y: 1 })
            // .delay(x * 0.2 + y * 0.5)
            .ease(luxe.tween.easing.Cubic.easeInOut);
    }

    override function onmousemove(event :MouseEvent) {
        var world_pos = Luxe.camera.screen_point_to_world(event.pos);
        if (point_inside_AABB(world_pos)) {
            if (!hovered) {
                hovered = true;
                color.tween(0.1, { a: 0.6 });
            }
        } else {
            if (hovered) {
                hovered = false;
                color.tween(0.1, { a: 1.0 });
            }
        }
    }

    override public function onmouseup(event :MouseEvent) {
        var world_pos = Luxe.camera.screen_point_to_world(event.pos);
        if (point_inside_AABB(world_pos)) {
            events.fire('click');
        }
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

    public function assign(symbol :String) {
        text.text = symbol;
        Actuate
            .tween(text, 0.3, { rotation_z: 90 })
            .reflect()
            .repeat(1)
            .ease(luxe.tween.easing.Cubic.easeInOut);
    }
}
