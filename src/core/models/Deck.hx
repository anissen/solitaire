
package core.models;

using core.tools.ArrayTools;

// TODO: Handle random seed

class GenericDeck<T> {
    var cards :Array<T>;

    public inline function new() {
        cards = [];
    }

    public inline function shuffle() {
        cards = cards.shuffle();
        return this;
    }

    public inline function take(count :Int = 1) {
        return cards.splice(0, count);
    }

    public inline function count() {
        return cards.length;
    }

    public inline function empty() {
        return count() == 0;
    }
}

interface ICard {
    var suit(default, null) :Int;
    var stacked(default, set) :Bool;
    var grid_pos(default, null) :{ x :Int, y :Int };
}

//typedef Card = ICard; //game.entities.Tile;
typedef Card = game.entities.Tile; // TODO: Hack!

class Deck extends GenericDeck<Card> {
	public function new(cards :Array<Card>) {
        super();
        this.cards = cards;
        shuffle();
    }
}
