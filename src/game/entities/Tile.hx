
package game.entities;

import luxe.Vector;
import luxe.Sprite;
import luxe.Color;
import luxe.Text;

typedef TileOptions = {
    pos :Vector,
    size :Float,
    ?card :core.models.Deck.Card,
    ?depth :Int,
    ?color :Color
}

class Tile extends Sprite {
    public var grid_pos :{ x :Int, y :Int } = null;
    public var card :core.models.Deck.Card;

    public function new(options :TileOptions) {
        super({
            pos: options.pos,
            size: new Vector(options.size, options.size),
            color: ((options.color == null) ? Color.random() : options.color),
            depth: ((options.depth == null) ? 0 : options.depth)
        });
        card = options.card;
    }
}
