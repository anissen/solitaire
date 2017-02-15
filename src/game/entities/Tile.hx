
package game.entities;

import luxe.Vector;
import luxe.Sprite;
import luxe.Color;

typedef TileOptions = {
    pos :Vector,
    size :Float,
    suit :Int,
    stacked :Bool,
    ?grid_pos :{ x :Int, y :Int },
    ?depth :Int,
    ?color :Color
}

class Tile extends Sprite implements core.models.Deck.ICard {
    @:isVar public var suit(default, null) :Int;
    @:isVar public var stacked(default, default) :Bool;
    
    public var grid_pos :{ x :Int, y :Int } = null;

    public function new(options :TileOptions) {
        super({
            pos: options.pos,
            size: new Vector(options.size, options.size),
            color: ((options.color == null) ? Color.random() : options.color),
            depth: ((options.depth == null) ? 0 : options.depth)
        });
        suit = options.suit;
        stacked = options.stacked;
        grid_pos = options.grid_pos;
    }
}
