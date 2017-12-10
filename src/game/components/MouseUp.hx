package game.components;

import luxe.Sprite;
import luxe.Component;
import luxe.Input.MouseEvent;

class MouseUp extends Component {
    var sprite :Sprite;
    var callback :Sprite->Void;

    public function new(callback :Sprite->Void) {
        super({ name: 'MouseUp' });
        this.callback = callback;
    }

    override function onadded() {
        sprite = cast entity;
    }

    override function onmouseup(event :MouseEvent) {
        if (sprite == null) return; // can happen if the sprite is destroyed on mouse-down
        var world_pos = Luxe.camera.screen_point_to_world(event.pos);
        if (sprite.point_inside(world_pos)) {
            callback(sprite);
        }
    }
}
