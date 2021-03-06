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
    var start_pos :Vector;
    // @:isVar public var disabled (default, set) :Bool;
    public var disabled :Bool;

    public function new(options :IconOptions) {
        super({
            name_unique: true,
            texture: Luxe.resources.texture(options.texture_path),
            pos: options.pos
        });
        on_click = options.on_click;
        start_pos = options.pos.clone();
        disabled = false;
    }

    override function init() {
        var old_scale = scale.clone();
        this.scale.y = 0;
        Actuate
            .tween(this.scale, 0.3, { y: old_scale.y })
            .delay(Math.random() * 0.2)
            .ease(luxe.tween.easing.Cubic.easeInOut);
    }

    override function onmousemove(event :MouseEvent) {
        if (!visible || disabled) return;
        
        var world_pos = Luxe.camera.screen_point_to_world(event.pos);
        if (point_inside(world_pos)) {
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
                Actuate.tween(this.pos, 0.3, { y: start_pos.y });
                color.tween(0.1, { a: 1.0 });
            }
        }
    }

    override public function onmouseup(event :MouseEvent) {
        if (!visible || disabled) return;

        var world_pos = Luxe.camera.screen_point_to_world(event.pos);
        if (point_inside(world_pos)) {
            Luxe.audio.play(Luxe.resources.audio(Settings.get_sound_file_path('tile_click')).source);
            on_click();
        }
    }

    // function set_disabled(value :Bool) :Bool {
    //     disabled = value;

    //     return disabled;
    // }
}
