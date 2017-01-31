package game.components;

import luxe.Sprite;
import luxe.Component;
import luxe.Input.MouseEvent;

class Selected extends Component {
    var sprite :Sprite;
    var scene :luxe.Scene;
    var highlight :Sprite;

    public function new() {
        super({ name: 'Selected' });
        scene = new luxe.Scene();
    }

    override function onadded() {
        sprite = cast entity;
        highlight = new Sprite({
            pos: new luxe.Vector(32, 32),
            color: new luxe.Color(1, 1, 1, 1),
            size: luxe.Vector.Multiply(sprite.size, 1.2),
            depth: sprite.depth - 1,
            parent: sprite,
            scene: scene
        });
    }

    override function onremoved() {
        trace('removed!');
        //highlight.destroy(true);
        scene.empty();
    }
}
