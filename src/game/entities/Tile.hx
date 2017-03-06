
package game.entities;

import luxe.Vector;
import luxe.Sprite;
import luxe.Color;

typedef TileOptions = {
    pos :Vector,
    size :Float,
    suit :Int,
    stacked :Bool,
    texture :phoenix.Texture,
    ?grid_pos :{ x :Int, y :Int },
    ?depth :Int,
    ?color :Color
}

class Tile extends Sprite implements core.models.Deck.ICard {
    @:isVar public var suit(default, null) :Int;
    @:isVar public var stacked(default, set) :Bool;
    
    public var grid_pos :{ x :Int, y :Int } = null;

    var original_color :Color;
    // var original_size :Float;
    // var size_tween :luxe.tween.actuators.GenericActuator.IGenericActuator;

    var bg :Sprite;

    public function new(options :TileOptions) {
        super({
            pos: options.pos,
            size: new Vector(options.size, options.size),
            // color: ((options.color == null) ? Color.random() : options.color),
            // color: (options.stacked ? new Color(1, 1, 1, 1) : options.color),
            depth: ((options.depth == null) ? 0 : options.depth),
            texture: options.texture
        });

        bg = new Sprite({
            pos: Vector.Multiply(size, 0.5),
            // origin: Vector.Multiply(size, 0.5),
            size: size,
            texture: Luxe.resources.texture('assets/images/symbols/tile.png'),
            // color: (options.stacked ? options.color : new Color(1, 1, 1, 1)),
            depth: depth - 0.1,
            parent: this
        });

        original_color = options.color;
        // original_size = options.size;
        suit = options.suit;
        stacked = options.stacked;
        grid_pos = options.grid_pos;

        // var new_size = new Vector(original_size * 0.9, original_size * 0.9);
        // size_tween = luxe.tween.Actuate.tween(new_size, 1.0, { /*rotation_z: 5 */ x: original_size * 1.1, y: original_size * 1.1 }).reflect().repeat().onUpdate(function() { 
        //     this.size = new_size;
        //     this.bg.size = new_size;
        //     this.bg.pos = Vector.Multiply(new_size, 0.5);
        // });
    }

    function set_stacked(value :Bool) {
        stacked = value;
        if (bg != null) {
            color = (value ? new Color(0, 0, 0, 1) : original_color);
            bg.color = (value ? original_color : new Color(1, 1, 1, 1));
        }
        return value;
    }

    override public function set_visible(value :Bool) {
        bg.visible = value;
        return (super.visible = value);
    }

    override public function set_depth(value :Float) {
        if (bg != null) bg.depth = value - 0.1;
        return (super.depth = value);
    }
}
