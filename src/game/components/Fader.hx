package game.components;

import luxe.Component;
import luxe.Sprite;
import luxe.Color;

class Fader extends Component {
    var overlay: Sprite;

    override function init() {
        overlay = new Sprite({
            size: Luxe.screen.size,
            color: new Color(1, 1, 1, 1),
            centered: false,
            no_scene: true,
            depth: 999
        });
    }

    public function fade_out(?t :Float = 0.3) {
        return overlay.color.tween(t, { a: 1 });
    }

    public function fade_in(?t :Float = 0.3) {
        return overlay.color.tween(t, { a: 0 });
    }

    override function ondestroy() {
        overlay.destroy( );
    }
}