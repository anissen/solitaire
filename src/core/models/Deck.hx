
package core.models;

using core.tools.ArrayTools;

//typedef Card = { suit :Int, stacked :Bool /* value :Int */ };

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

    /*
    public inline function get_cards() {
        return cards.copy();
    }
    */

    public inline function count() {
        return cards.length;
    }
}

// TODO: Maybe simply have the data structure be an Array and have a class of static extensions

@:structInit
class Card {
    static var Id :Int = 0;
    @:isVar public var id(default, null) :Int;
    @:isVar public var suit(default, null) :Int;
    @:isVar public var stacked(default, default) :Bool;

    public function new(suit :Int, stacked :Bool) {
        this.id = Card.Id++;
        this.suit = suit;
        this.stacked = stacked;
    }
}

/*
@:structInit
class Set {
    static var Id :Int = 0;
    var id :Int;
    @:isVar public var cards(default, null) :Array<Card>;

    public function new(cards :Array<Card>) {
        this.id = Set.Id++;
        this.cards = cards;
    }

    public function equals(other :Set) {
        return (id == other.id);
    }
}
*/

class Deck extends GenericDeck<Card> {
	public function new(cards :Array<Card>) {
        super();
        this.cards = cards;
        shuffle();
        //print_cards(cards);
        // print_cards(take(3));
    }

    function print_cards(cards :Array<Card>) {
        for (c in cards) {
            trace(get_card_string(c));
        }
    }

    /*
    public function take_set(count :Int) :Set {
        return { cards: take(count) };
    }
    */

    public function get_card_string(card :Card) {
        if (card == null) {
            return '\033[0;37m·\033[0m';
        }

        var color = switch (card.suit) {
            case 0: 34;
            case 1: 32;
            case 2: 31;
            case 3: 35;
            case _: 37;
        }
        var symbol = switch (card.suit) {
            case 0: '♠';
            case 1: '♣';
            case 2: '♥';
            case 3: '♦';
            case _: '·';
        }
        return '\033[0;${color}m$symbol\033[0m';
    }
}
