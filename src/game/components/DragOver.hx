package game.components;

import luxe.Sprite;
import luxe.Component;
import luxe.Input.MouseEvent;

class DragOver extends Component {
    var sprite :Sprite;
    var mouse_down :Bool = false;

    public function new() {
        super({ name: 'DragOver' });
    }

    override function onadded() {
        sprite = cast entity;
    }

    override function onmousedown(event :MouseEvent) {
        mouse_down = sprite.point_inside(event.pos);
    }

    override function onmouseup(event :MouseEvent) {
        mouse_down = false;
    }

    override function onmousemove(event :MouseEvent) {
        if (mouse_down) {
            Luxe.events.fire('dragging', sprite);
        }
    }
}
