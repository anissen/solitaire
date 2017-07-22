
package game.components;

import luxe.Component;
import luxe.Input.MouseButton;
import luxe.Input.MouseEvent;
import luxe.Vector;

class DragPan extends Component {
    public var y_top :Float;
    public var y_bottom :Float;
    public var button : MouseButton;

    var dragging : Bool = false;
    var drag_start : Vector;
    var drag_start_pos : Vector;
    var visual : luxe.Visual;

    override function init() {
        drag_start = new Vector();
        drag_start_pos = new Vector();

        button = MouseButton.left;

        visual = cast entity;
        if(visual == null) throw 'Invalid entity type';
    }

    override function onmousedown(e :MouseEvent) {
        if (!dragging && e.button == button) {
            dragging = true;
            drag_start.set_xy(e.pos.x, e.pos.y);
            drag_start_pos.set_xy(pos.x, pos.y);
        }
    }

    override function onmouseup(e :MouseEvent) {
        if (e.button == button && dragging) {
            dragging = false;
        }
    }

    override function onmousemove(e :MouseEvent) {
        if (dragging) {
            var diffy = (drag_start.y - e.pos.y); // / camera.zoom;
            pos.y = luxe.utils.Maths.clamp(drag_start_pos.y - diffy, y_top, y_bottom);
            // pos.y = drag_start_pos.y - diffy;
        }
    }
}