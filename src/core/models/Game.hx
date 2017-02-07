package core.models;

import core.models.Deck.Card;
import core.queues.MessageSystem;

enum Action {
    Noop;
    Place(card :Card, x :Int, y :Int);
    Select(tiles :Array<{x :Int, y :Int}>);
}

enum Event {
    Draw(card :Array<Card>);
    NewQuest(card :Array<Card>);
    TileRemoved(card :Card);
    Selected(x :Int, y :Int);
    Collected(cards :Array<Card>, quest :Array<Card>); // or maybe Array<{ x: Int, y :Int }> ?
    Stacked(cards :Array<Card>); // or maybe Array<{ x: Int, y :Int }> ?
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

    public function new_game() {
        deck = new Deck([
            for (suit in 0...3)
            	for (value in 0...13) { suit: suit, stacked: false }
        ]);
        quest_deck = new Deck([
            for (suit in 0...3)
            	for (value in 0...13) { suit: suit, stacked: value >= 10 }
        ]);
        grid = new Grid(4, 3);

        quests = [];
        hand = [];

        score = 0;

        new_turn();

        // for testing purposes:
        // var i = 0;
        // for (card in deck.take(4)) {
        //     grid.set_tile(i++, 1, card);
        // }
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
            case Select(tiles): handle_selection(tiles); //handle_select(x, y);
        }
    }

    function new_turn() {
        if (quests.length < 3) {
            var newQuest = quest_deck.take(3);
            quests.push(newQuest);
            messageSystem.emit(NewQuest(newQuest));
        }
        hand = deck.take(3); // TODO: Hand should be a Set
        messageSystem.emit(Draw(hand));
    }

    function handle_place(card :Card, x :Int, y :Int) {
        // if (hand.length < index) return;
        // var card = hand.splice(index, 1)[0];
        hand.remove(card);

        change_tile({ x: x, y: y }, card);
        //grid.set_tile(x, y, { suit: card.suit, stacked: false });

        if (hand.length == 0) {
            new_turn();
        }
    }

    function is_collection_valid(tiles :Array<{ x :Int, y :Int }>) {
        if (tiles.length != 3) {
            trace('Only ${tiles.length} tiles selected');
            return false;
        }

        for (tile in tiles) {
            if (grid.get_tile(tile.x, tile.y) == null) {
                trace('Empty tile selected');
                return false;
            }
        }

        for (i in 1 ... tiles.length) {
            var previous = tiles[i - 1];
            var current = tiles[i];

            if (Math.abs(current.x - previous.x) + Math.abs(current.y - previous.y) != 1) {
                trace('Collected cards must be adjacent');
                return false;
            }
        }

        return true;
    }

    function complete_quest(tiles :Array<{ x :Int, y :Int }>) {
        var cards = [ for (t in tiles) grid.get_tile(t.x, t.y) ];
        for (quest in quests) {
            if (!cards_matching(cards, quest)) continue;

            trace('Matched quest: $quest');
            quests.remove(quest);
            for (tile in tiles) remove_tile(tile);
            update_score(cards, quest);
            messageSystem.emit(Collected(cards, quest));
            return true;
        }
        return false;
    }

    function make_stack(tiles :Array<{ x :Int, y :Int }>) {
        // test if collection is a merge
        var cards = [ for (t in tiles) grid.get_tile(t.x, t.y) ];
        var first_card = cards[0];
        if (first_card.stacked) return false;

        for (i in 1 ... cards.length) {
            var card = cards[i];
            if (card.stacked || card.suit != first_card.suit) {
                trace('No match for collected cards');
                return false;
            }
        }

        trace('Made a stack');
        for (i in 0 ... tiles.length - 1) remove_tile(tiles[i]);
        var last = tiles[tiles.length - 1];
        var last_card = cards[cards.length - 1];
        change_tile(last, { suit: last_card.suit, stacked: true });

        messageSystem.emit(Stacked(cards));
        return true;
    }

    function remove_tile(pos :{ x :Int, y :Int }) {
        messageSystem.emit(TileRemoved(grid.get_tile(pos.x, pos.y)));
        change_tile(pos, null);
    }

    function change_tile(pos :{ x :Int, y :Int }, card :Card) {
        grid.set_tile(pos.x, pos.y, card);
        // messageSystem.emit(ChangedTile(pos.x, pos.y, card));
    }

    public function handle_selection(tiles :Array<{ x :Int, y :Int }>) {
        if (!is_collection_valid(tiles)) return;
        if (complete_quest(tiles)) return;
        if (make_stack(tiles)) return;
    }

    function update_score(cards :Array<Card>, quest :Array<Card>) {
        for (i in 0 ... cards.length) {
            score += (cards[i].stacked ? 5 : 1);
            score += (cards[i].suit == quest[i].suit ? 1 : 0);
        }
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

    public function print_game() {
        var str = '\n';
        // str += '\033[1;40;30m===  GRID ===\033[0m\n';
        str += print_grid();

        str += '\033[1;40;30m=== QUESTS ===\033[0m\n';
        for (quest in quests) str += print_cards(quest);

        str += '\033[1;40;30m===  HAND  ===\033[0m\n';
        str += print_cards(hand);

        str += 'Score: $score';

        trace(str);
    }

    function print_cards(cards :Array<Card>) {
        var str = '';
        for (card in cards) {
            var card_str = deck.get_card_string(card);
            if (card.stacked) {
                str += '($card_str)';
            } else {
                str += ' $card_str ';
            }
        }
        return str + '\n';
    }

    function print_grid() {
        var str = '';
        var y = 0;
        for (row in grid.get_tiles()) {
            if (y == 0) {
                str += '  ';
                for (x in 0 ... row.length) str += ' \033[1;40;30m$x\033[0m ';
                str += '\n';
            }
            var x = 0;
            for (tile in row) {
                if (x == 0) str += '\033[1;40;30m$y\033[0m ';
                var tile_str = deck.get_card_string(tile);
                if /* (tile != null && is_collecting(x, y)) {
                    str += '[$tile_str]';
                } else if */ (tile != null && tile.stacked) {
                    str += '($tile_str)';
                } else {
                    str += ' $tile_str ';
                }
                x++;
            }
            y++;
            str += '\n';
        }
        return str;
    }
}
