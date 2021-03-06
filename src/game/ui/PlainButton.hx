package game.ui;

import luxe.Input;
import luxe.Vector;
import luxe.Text;
import luxe.Color;
import luxe.tween.Actuate;

typedef PlainButtonOptions = {
    pos :Vector,
    ?width :Int,
    ?height :Int,
    ?font_size :Int,
    ?text :String,
    ?disabled :Bool,
    on_click :Void->Void
}

class PlainButton extends luxe.NineSlice {
    var label :Text;
    var hovered :Bool = false;
    var on_click :Void->Void;
    var is_enabled :Bool = true;
    var start_pos :Vector;
    public var text (get, set) :String;
    public var enabled (get, set) :Bool;

    public function new(options :PlainButtonOptions) {
        super({
            name_unique: true,
            texture: Luxe.resources.texture('assets/ui/buttonLong_teal_pressed.png'),
            top: 20,
            left: 20,
            right: 20,
            bottom: 20,
            color: new Color(1, 1, 1, 1),
            depth: 100
        });
        var width = (options.width != null ? options.width : 200);
        var height = (options.height != null ? options.height : 45);
        var font_size = (options.font_size != null ? options.font_size : 26);
        var text = (options.text != null ? options.text : '');
        var disabled = (options.disabled != null ? options.disabled : false);
        on_click = options.on_click;
        this.create(Vector.Subtract(options.pos, new Vector(width / 2, height / 2)), width, height);
        start_pos = this.pos.clone();

        label = new Text({
            parent: this,
            text: text,
            pos: new Vector(width / 2, height / 2 + 2),
            point_size: font_size,
            align: luxe.Text.TextAlign.center,
            align_vertical: luxe.Text.TextAlign.center,
            color: new luxe.Color(1.0, 1.0, 1.0),
            depth: this.depth + 0.1,

            letter_spacing: -1.0,
            sdf: true,
            shader: Luxe.renderer.shaders.bitmapfont.shader.clone('title-shader'),
            outline: 0.7,
            outline_color: new Color().rgb(0xa55004)
        });

        enabled = !disabled;
    }

    public function get_top_pos() {
        return new Vector(pos.x + width / 2, pos.y);
    }

    public function get_center_pos() {
        return new Vector(pos.x + width / 2, pos.y + height / 2);
    }

    override function onmousemove(event :MouseEvent) {
        var world_pos = Luxe.camera.screen_point_to_world(event.pos);
        if (point_inside_AABB(world_pos)) {
            if (!hovered) {
                hovered = true;
                color.tween(0.1, { r: 1.0, g: 0.9, b: 0.9 });
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
                Actuate.tween(this.pos, 0.3, { y: start_pos.y });
                color.tween(0.1, { r: 1.0, g: 1.0, b: 1.0 });
            }
        }
    }

    override public function onmouseup(event :MouseEvent) {
        var world_pos = Luxe.camera.screen_point_to_world(event.pos);
        if (point_inside_AABB(world_pos)) {
            play_sound('ui_click');
            on_click();
        }
    }

    function get_text() {
        return label.text;
    }

    function set_text(t :String) {
        return (label.text = t);
    }

    function get_enabled() :Bool {
        return is_enabled;
    }

    function set_enabled(value :Bool) {
        if (is_enabled == value) return value;
        is_enabled = value;
        if (value) {
            color.tween(0.3, { a: 1.0 });
            label.outline_color.tween(0.3, { r: 0.65, g: 0.31, b: 0.02 });
        } else {
            Actuate.stop(this.pos);
            Actuate.tween(this.pos, 0.3, { y: start_pos.y });
            color.tween(0.3, { a: 0.2 });
            label.outline_color.tween(0.3, { r: 0.5, g: 0.5, b: 0.5 });
        }
        return is_enabled;
    }

    function play_sound(id :String) {
        var sound = Luxe.resources.audio(Settings.get_sound_file_path(id));
        Luxe.audio.play(sound.source);
    }

    /** Returns true if a point is inside the AABB unrotated */
    public function point_inside_AABB(_p :Vector) :Bool {
        if (!enabled) return false;
        if (pos == null) return false;
        if (size == null) return false;

        // scaled size
        // var _s_x = size.x * scale.x * 0.5  /* hack */;
        // var _s_y = size.y * scale.y * 0.5 /* hack */;

        if (_p.x < pos.x) return false;
        if (_p.y < pos.y) return false;
        if (_p.x > pos.x + width) return false;
        if (_p.y > pos.y + height) return false;

        return true;
    }
}
