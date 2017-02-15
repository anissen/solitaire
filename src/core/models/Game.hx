package core.models;

import core.models.Deck.Card;
import core.queues.MessageSystem;

enum Action {
    Noop;
    Place(card :Card, x :Int, y :Int);
    Collect(tiles :Array<Card>);
}

enum Event {
    Draw(card :Array<Card>);
    NewQuest(card :Array<Card>);
    TileRemoved(card :Card);
    Collected(cards :Array<Card>, quest :Array<Card>);
    Stacked(card :Card);
    Score(score :Int);
}

class Game {
    var quest_deck :Deck;
    var deck :Deck;
    var grid :Grid<Card>;

    var quests :Array<Array<Card>>;
    var hand :Array<Card>;

    var score :Int;

    var messageSystem :MessageSystem<Action, Event>;

    public function new() {
        messageSystem = new MessageSystem();
        messageSystem.on_action(handle_action);
    }

    public function new_game(deck_cards :Array<Card>, quest_cards :Array<Card>) {
        deck = new Deck(deck_cards);
        quest_deck = new Deck(quest_cards);
        grid = new Grid(4, 3);

        quests = [];
        hand = [];

        score = 0;

        new_turn();
    }

    public function do_action(action :Action) {
        messageSystem.do_action(action);
    }

    public function listen(func :Event->snow.api.Promise) {
        messageSystem.listen(func);
    }

    function handle_action(action :Action) {
        switch (action) {
            case Noop:
            case Place(card, x, y): handle_place(card, x, y);
            case Collect(tiles): handle_collecting(tiles);
        }
    }

    function new_turn() {
        if (quests.length < 3) {
            var newQuest = quest_deck.take(3);
            quests.push(newQuest);
            messageSystem.emit(NewQuest(newQuest));
        }
        hand = deck.take(3);
        messageSystem.emit(Draw(hand));
    }

    function handle_place(card :Card, x :Int, y :Int) {
        grid.set_tile(x, y, card);

        hand.remove(card);
        if (hand.length == 0) {
            new_turn();
        }
    }

    function is_collection_valid(tiles :Array<Card>) {
        if (tiles.length != 3) {
            trace('Only ${tiles.length} tiles selected');
            return false;
        }

        for (tile in tiles) {
            if (tile.grid_pos == null) {
                trace('Tile has no grid_pos -- how?');
                return false;
            }

            if (grid.get_tile(tile.grid_pos.x, tile.grid_pos.y) == null) {
                trace('Empty tile selected');
                return false;
            }
        }

        for (i in 1 ... tiles.length) {
            var previous = tiles[i - 1];
            var current = tiles[i];

            if (Math.abs(current.grid_pos.x - previous.grid_pos.x) + Math.abs(current.grid_pos.y - previous.grid_pos.y) != 1) {
                trace('Collected cards must be adjacent');
                return false;
            }
        }

        return true;
    }

    function complete_quest(tiles :Array<Card>) {
        var cards = [ for (t in tiles) grid.get_tile(t.grid_pos.x, t.grid_pos.y) ];
        for (quest in quests) {
            if (!cards_matching(cards, quest)) continue;

            // trace('Matched quest: $quest');
            quests.remove(quest);
            for (tile in tiles) remove_tile(tile);
            update_score(cards, quest);
            messageSystem.emit(Collected(cards, quest));
            return true;
        }
        return false;
    }

    function make_stack(tiles :Array<Card>) {
        // test if collection is a merge
        var cards = [ for (t in tiles) grid.get_tile(t.grid_pos.x, t.grid_pos.y) ];
        var first_card = cards[0];
        if (first_card.stacked) return false;

        for (i in 1 ... cards.length) {
            var card = cards[i];
            if (card.stacked || card.suit != first_card.suit) {
                trace('No match for collected cards');
                return false;
            }
        }

        // trace('Made a stack');
        for (i in 0 ... tiles.length - 1) remove_tile(tiles[i]);
        var last_card = cards[cards.length - 1];

        messageSystem.emit(Stacked(last_card));
        return true;
    }

    function remove_tile(card :Card) {
        messageSystem.emit(TileRemoved(grid.get_tile(card.grid_pos.x, card.grid_pos.y)));
        grid.set_tile(card.grid_pos.x, card.grid_pos.y, null);
    }

    public function handle_collecting(tiles :Array<Card>) {
        if (!is_collection_valid(tiles)) return;
        if (complete_quest(tiles)) return;
        if (make_stack(tiles)) return;
    }

    function update_score(cards :Array<Card>, quest :Array<Card>) {
        for (card in cards) {
            score += (card.stacked ? 5 : 1);
        }
        var matchingSuits = true;
        var matchingSuitsReverse = true;
        for (i in 0 ... cards.length) {
            if (cards[i].suit != quest[i].suit) matchingSuits = false;
            if (cards[i].suit != quest[cards.length - i - 1].suit) matchingSuitsReverse = false;
        }
        if (cards.length > 0 && (matchingSuits || matchingSuitsReverse)) score += 3;
        messageSystem.emit(Score(score));
    }

    function cards_matching(cards1 :Array<Card>, cards2 :Array<Card>) {
        var test = cards2.copy(); // TODO: This is not good!
        for (a in cards1) {
            var match = false;
            for (b in test) {
                if (a.suit == b.suit && a.stacked == b.stacked) {
                    test.remove(b);
                    match = true;
                    break;
                }
            }
            if (!match) return false;
        }
        return true;
    }
}
