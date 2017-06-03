
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

    static public var CardId :Int = 0;
    public var cardId(default, never) :Int = CardId++;

    var original_color :Color;

    var bg :Sprite;
    var highlighted :Bool;

    public function new(options :TileOptions) {
        super({
            pos: options.pos,
            size: new Vector(options.size, options.size),
            depth: ((options.depth == null) ? 0 : options.depth),
            texture: options.texture
        });

        bg = new Sprite({
            pos: Vector.Multiply(size, 0.5),
            size: size,
            texture: Luxe.resources.texture('assets/images/symbols/tile.png'),
            depth: depth - 0.1,
            parent: this
        });

        original_color = options.color;
        suit = options.suit;
        stacked = options.stacked;
        grid_pos = options.grid_pos;
        highlighted = false;
    }

    function set_stacked(value :Bool) {
        stacked = value;
        if (bg != null) {
            bg.texture = Luxe.resources.texture('assets/images/symbols/' + (value ? 'tile_stacked' : 'tile') + '.png');
            // bg.pos = (value ? Vector.Subtract(Vector.Multiply(size, 0.5), new Vector(0, 10)) : Vector.Multiply(size, 0.5));

            color = (value ? new Color(0, 0, 0, 1) : original_color);
            bg.color = (highlighted ? Settings.CARD_HIGHLIGHT_COLOR : (value ? original_color : new Color().rgb(0xF6CE8C)));
        }
        return value;
    }

    public function set_highlight(value :Bool) {
        highlighted = value;
        bg.color = (highlighted ? Settings.CARD_HIGHLIGHT_COLOR : (stacked ? original_color : new Color().rgb(0xF6CE8C)));
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
