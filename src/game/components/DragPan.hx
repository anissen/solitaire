
package game.components;

import luxe.Component;
import luxe.Input.MouseButton;
import luxe.Input.MouseEvent;
import luxe.Vector;

class DragPan extends Component {
    public var y_top :Float;
    public var y_bottom :Float;
    public var button : MouseButton;

    var mouse_down :Bool = false;
    var dragging :Bool = false;
    var drag_start :Vector;
    var drag_start_pos :Vector;
    var visual :luxe.Visual;

    var drag_velocity :Float;
    var inertia_duration :Float = 0.5;
    var inertia_time :Float;

    override function init() {
        drag_start = new Vector();
        drag_start_pos = new Vector();
        
        drag_velocity = 0;
        inertia_time = 0;

        button = MouseButton.left;

        visual = cast entity;
        if(visual == null) throw 'Invalid entity type';
    }

    override function onmousedown(event :MouseEvent) {
        if (!dragging && event.button == button) {
            mouse_down = true;
            inertia_time = 0;
            var world_pos = Luxe.camera.screen_point_to_world(event.pos);
            drag_start.set_xy(world_pos.x, world_pos.y);
            drag_start_pos.set_xy(pos.x, pos.y);
        }
    }

    override function onmouseup(event :MouseEvent) {
        if (event.button == button) {
            mouse_down = false;
            if (dragging) {
                dragging = false;
                inertia_time = inertia_duration;
            }
        }
    }

    override function onmousemove(event :MouseEvent) {
        if (mouse_down) {
            dragging = true;
            var world_pos = Luxe.camera.screen_point_to_world(event.pos);
            var drag_diff_y = (drag_start.y - world_pos.y);
            var previous_pos = pos.y;
            pos.y = luxe.utils.Maths.clamp(drag_start_pos.y - drag_diff_y, y_top, y_bottom);
            drag_velocity = pos.y - previous_pos;
        }
    }

    override function update(dt :Float) {
        if (inertia_time > 0) {
            pos.y = luxe.utils.Maths.clamp(pos.y + drag_velocity, y_top, y_bottom);
            var progress = (inertia_duration - inertia_time) / inertia_duration;
            drag_velocity = luxe.utils.Maths.lerp(drag_velocity, 0, progress);
            inertia_time -= dt;
        }
    }
}