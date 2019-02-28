package;

using core.tools.ArrayTools;

typedef CardData = {
    suit :Int,
    stacked :Bool
}

class GenericTestDeck<T> {
    var cards :Array<T>;

    public inline function new(cards :Array<T>) {
        this.cards = cards;
    }

    public inline function shuffle(?random_func :Int->Int) {
        cards = cards.shuffle(random_func);
        return this;
    }

    public inline function count() {
        return cards.length;
    }

    public inline function empty() {
        return count() == 0;
    }
}

class InfiniteTestDeck extends GenericTestDeck<CardData> {
    var all_cards :Array<CardData>;
    var random_func :Int->Int;
    public var on_reshuffling :Void->Void = null;

	public function new(cards :Array<CardData>, random_func :Int->Int) {
        all_cards = cards.copy();
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
        while (cards_missing > 0) {
            reshuffle();
            var new_cards = cards.splice(0, cards_missing);
            cards_missing -= new_cards.length;
            taken_cards.append(new_cards);
        }
        return taken_cards;
    }
}


class CompletionTest {
    static var rounds_survived :Int = 0;
    static var min_rounds_survived :Int = 10000;
    static var max_rounds_survived :Int = 0;
    static var quest_values = 12; // 13
    static var card_values = 6;  // 10

    static function main() {
        for (i in 0 ... 1000) {
            run_test();
        }

        trace('--------------');
        trace('CARD VALUES: $card_values');
        trace('min rounds: $min_rounds_survived');
        trace('max rounds: $max_rounds_survived');
        trace('average survival: ${rounds_survived / 1000} rounds');
    }

    static function run_test() {
        var max_suits = 2;

        var questCards = [];
        for (suit in 0 ... max_suits) {
            for (value in 0 ... quest_values) {
                questCards.push({ suit: suit, stacked: (value >= 10) });
            }
        }
        var questDeck = new InfiniteTestDeck(questCards, Std.random);
        
        var handCards = [];
        for (suit in 0 ... max_suits) {
            for (value in 0 ... card_values) {
                handCards.push({ suit: suit, stacked: false });
            }
        }
        var handDeck = new InfiniteTestDeck(handCards, Std.random);
        var reshuffle_count = 0;
        handDeck.on_reshuffling = function() {
            reshuffle_count++;
            function add_cards(suit :Int) {
                handDeck.add_cards([ for (value in 0 ... card_values) { suit: suit, stacked: false } ]);
                questDeck.add_cards([ for (value in 0 ... quest_values) { suit: suit, stacked: (value >= 10) } ]);
                questDeck.reshuffle();
            }
            if (reshuffle_count == 1) {
                add_cards(2);
            } else if (reshuffle_count == 2) {
                add_cards(3);
            } else if (reshuffle_count == 3) {
                add_cards(4);
            }
        };

        var hasLost = false;
        var quests = [];
        var cards = [];
        var rounds = 0;
        while (!hasLost) {
            // trace('round ${rounds + 1} begins');

            if (quests.length < 3) quests.push(questDeck.take(3));
            var new_cards = handDeck.take(2); // TODO: test: only take two cards
            cards = cards.concat(new_cards);

            var total_suits = [0,0,0,0,0];
            for (quest in quests) {
                for (quest_card in quest) {
                    total_suits[quest_card.suit] += (quest_card.stacked ? 3 : 1);
                }
            }
            for (card in new_cards) {
                total_suits[card.suit] -= 1;
            }

            var most_cards_in_suit = 0;
            var most_cards_in_suit_index = 0;
            for (suit_index in 0 ... total_suits.length) {
                if (total_suits[suit_index] > most_cards_in_suit) {
                    most_cards_in_suit = total_suits[suit_index];
                    most_cards_in_suit_index = suit_index;
                }
            }
            // trace(total_suits + ' => ' + most_cards_in_suit_index + '($most_cards_in_suit)');
            cards.push({ suit: most_cards_in_suit_index, stacked: false });

            var quest_requirements = [];
            for (quest in quests) {
                var suits = [0,0,0,0,0];
                for (quest_card in quest) {
                    suits[quest_card.suit] += (quest_card.stacked ? 3 : 1);
                }
                // trace(suits);
                var cards_to_remove = [];
                for (card in cards) {
                    if (suits[card.suit] > 0) {
                        suits[card.suit] -= 1;
                        cards_to_remove.push(card);
                    }
                }
                // trace(suits);
                var success = true;
                for (suit in suits) {
                    if (suit > 0) success = false;
                }
                if (success) {
                    // trace('completed quest, quests: ${quests.length}, cards: ${cards.length}');
                    quests.remove(quest);
                    for (card in cards_to_remove) cards.remove(card);
                    // trace('AFTER quests: ${quests.length}, cards: ${cards.length}');
                }
            }

            if (cards.length > 9) hasLost = true;
            rounds++;
        }

        rounds_survived += rounds;
        if (rounds < min_rounds_survived) min_rounds_survived = rounds;
        if (rounds > max_rounds_survived) max_rounds_survived = rounds;
        // trace('survived for $rounds rounds');
    }
}
