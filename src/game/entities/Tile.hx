
package game.entities;

import luxe.Vector;
import luxe.Sprite;
import luxe.Color;

typedef TileOptions = {
    pos :Vector,
    size :Float,
    //?card :core.models.Deck.Card,
    suit :Int,
    stacked :Bool,
    ?grid_pos :{ x :Int, y :Int },
    ?depth :Int,
    ?color :Color
}

class Tile extends Sprite implements core.models.Deck.ICard {
    //static var Id :Int = 0;
    //@:isVar public var id(default, null) :Int;
    @:isVar public var suit(default, null) :Int;
    @:isVar public var stacked(default, default) :Bool;
    
    public var grid_pos :{ x :Int, y :Int } = null;
    // public var card :core.models.Deck.Card;

    public function new(options :TileOptions) {
        super({
            pos: options.pos,
            size: new Vector(options.size, options.size),
            color: ((options.color == null) ? Color.random() : options.color),
            depth: ((options.depth == null) ? 0 : options.depth)
        });
        //card = options.card;
        suit = options.suit;
        stacked = options.stacked;
        grid_pos = options.grid_pos;
    }
}
