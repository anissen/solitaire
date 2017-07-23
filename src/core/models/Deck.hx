
package core.models;

using core.tools.ArrayTools;

class GenericDeck<T> {
    var cards :Array<T>;

    public inline function new(cards :Array<T>) {
        this.cards = cards;
    }

    public inline function shuffle(?random_func :Int->Int) {
        cards = cards.shuffle(random_func);
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
    var random_func :Int->Int;
    public var on_reshuffling :Void->Void = null;

	public function new(cards :Array<CardData>, instantiate_func :CardData->Card, random_func :Int->Int) {
        all_cards = cards.copy();
        this.instatiate_func = instantiate_func;
        this.random_func = random_func;
        super(cards);
        shuffle(random_func);
    }

    public function add_cards(cards :Array<CardData>) {
        all_cards.append(cards);
    }

    public inline function reshuffle() {
        if (on_reshuffling != null) on_reshuffling();
        cards.clear();
        cards.append(all_cards.shuffle(random_func));
        return this;
    }

    public function take(count :Int = 1) {
        var taken_cards = cards.splice(0, count);
        var cards_missing = (count - taken_cards.length);
        // trace('taken_cards: ${taken_cards.length}, cards_missing: $cards_missing, cards left: ${cards.length}');
        while (cards_missing > 0) {
            reshuffle();
            var new_cards = cards.splice(0, cards_missing);
            cards_missing -= new_cards.length;
            // trace('RESHUFFLED:');
            taken_cards.append(new_cards);
            // taken_cards = taken_cards.concat(new_cards);
            // trace('new_cards: ${new_cards.length}, taken_cards: ${taken_cards.length}, cards left: ${cards.length}');
            // for (c in new_cards) trace('::::: $c');
        }
        return [ for (card in taken_cards) instatiate_func(card) ];
    }
}
