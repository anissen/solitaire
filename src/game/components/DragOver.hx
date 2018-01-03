package game.components;

import luxe.Sprite;
import luxe.Component;
import luxe.Input.MouseEvent;

class DragOver extends Component {
    var sprite :Sprite;
    var callback :Sprite->Void;
    var left_callback :Sprite->Void;
    var was_inside :Bool;

    public function new(callback :Sprite->Void, ?left_callback :Sprite->Void) {
        super({ name: 'DragOver' });
        this.callback = callback;
        this.left_callback = left_callback;
        was_inside = false;
    }

    override function onadded() {
        sprite = cast entity;
    }

    /*
    override function onmousedown(event :MouseEvent) {
        mouse_down = ;
    }

    override function onmouseup(event :MouseEvent) {
        mouse_down = false;
    }
    */

    override function onmousemove(event :MouseEvent) {
        if (!Luxe.input.mousedown(luxe.Input.MouseButton.left)) return;
        var world_pos = Luxe.camera.screen_point_to_world(event.pos);
        if (sprite.point_inside(world_pos)) {
        //     Luxe.events.fire('dragging', sprite);
            was_inside = true;
            callback(sprite);
        } else if (was_inside && left_callback != null) {
            was_inside = false;
            left_callback(sprite);
        }
    }
}
