package game.components;

import luxe.Sprite;
import luxe.Component;
import luxe.Input.MouseEvent;

class DragOver extends Component {
    var sprite :Sprite;
    var callback :Sprite->Void;

    public function new(callback :Sprite->Void) {
        super({ name: 'DragOver' });
        this.callback = callback;
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
            callback(sprite);
        }
    }
}
