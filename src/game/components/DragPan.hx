
package game.components;

import luxe.Component;
import luxe.Input.MouseButton;
import luxe.Input.MouseEvent;
import luxe.Vector;

class DragPan extends Component {
    public var y_top :Float;
    public var y_bottom :Float;
    public var button : MouseButton;

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

    override function onmousedown(e :MouseEvent) {
        if (!dragging && e.button == button) {
            dragging = true;
            inertia_time = 0;
            drag_start.set_xy(e.pos.x, e.pos.y);
            drag_start_pos.set_xy(pos.x, pos.y);
        }
    }

    override function onmouseup(e :MouseEvent) {
        if (e.button == button && dragging) {
            dragging = false;
            inertia_time = inertia_duration;
        }
    }

    override function onmousemove(e :MouseEvent) {
        if (dragging) {
            var drag_diff_y = (drag_start.y - e.pos.y);
            var previous_pos = pos.y;
            pos.y = luxe.utils.Maths.clamp(drag_start_pos.y - drag_diff_y, y_top, y_bottom);
            drag_velocity = pos.y - previous_pos;
        }
    }

    override function update(dt :Float) {
        if (inertia_time > 0) {
            pos.y += drag_velocity;
            var progress = (inertia_duration - inertia_time) / inertia_duration;
            drag_velocity = luxe.utils.Maths.lerp(drag_velocity, 0, progress);
            inertia_time -= dt;
        }
    }
}