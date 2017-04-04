
package core.models;

using core.tools.ArrayTools;

// TODO: Handle random seed

class GenericDeck<T> {
    var cards :Array<T>;

    public inline function new(cards :Array<T>) {
        this.cards = cards;
    }

    public inline function shuffle() {
        cards = cards.shuffle();
        return this;
    }

    // public function take(count :Int = 1) {
    //     return cards.splice(0, count);
    // }

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

typedef CardData = {
    suit :Int,
    stacked :Bool
}

#if testing
typedef Card = ICard;
#else
typedef Card = game.entities.Tile; // TODO: Hack!
#end

// typedef Deck = GenericDeck<CardData>;

// class Deck extends GenericDeck<Card> {
// 	public function new(cards :Array<Card>) {
//         super(cards);
//         this.cards = cards;
//         shuffle();
//     }
// }

class InfiniteDeck extends GenericDeck<CardData> {
    var all_cards :Array<CardData>;
    var instatiate_func :CardData->Card;

	public function new(cards :Array<CardData>, instantiate_func :CardData->Card) {
        all_cards = cards.copy();
        this.instatiate_func = instantiate_func;
        super(cards);
        shuffle();
    }

    public inline function reshuffle() {
        cards = all_cards.copy().shuffle();
        return this;
    }

    public function take(count :Int = 1) {
        // TODO: Ask the game (or playstate) to provide a Card instead
        // Alternatively, make the deck only have raw data and make the game (or playstate) create the corresponding Entity

        var taken_cards = cards.splice(0, count);
        var cards_missing = (count - taken_cards.length);
        trace('taken_cards: ${taken_cards.length}, cards_missing: $cards_missing, cards left: ${cards.length}');
        if (cards_missing > 0) {
            reshuffle();
            taken_cards.append(cards.splice(0, cards_missing));
            trace('RESHUFFLED: taken_cards: ${taken_cards.length}, cards left: ${cards.length}');
        }
        return [ for (card in taken_cards) instatiate_func(card) ];
    }
}
