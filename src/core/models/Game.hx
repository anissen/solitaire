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
    ChangedTile(x :Int, y :Int, card :Card);
    Selected(x :Int, y :Int);
    Collected(cards :Array<Card>); // or maybe Array<{ x: Int, y :Int }> ?
    Stacked(cards :Array<Card>); // or maybe Array<{ x: Int, y :Int }> ?
}

class Game {
    var quest_deck :Deck;
    var deck :Deck;
    var grid :Grid<Card>;

    var quests :Array<Array<Card>>;
    var hand :Array<Card>;

    // var collecting :Array<{ x: Int, y :Int }>;

    var score :Int;

    // var actions :MessageQueue<Action>;
    // var events :PromiseQueue<Event>;
    // var listeners :List<EventListenerFunction>;

    var messageSystem :MessageSystem<Action, Event>;

    public function new() {
        messageSystem = new MessageSystem();
        messageSystem.on_action(handle_action);
    }

    public function new_game() {
        deck = new Deck();
        quest_deck = new Deck();
        grid = new Grid(4, 3);

        quests = [];
        hand = [];
        // collecting = [];

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
        hand = deck.take(3).map(function(card) { return { suit: card.suit, stacked: false }; });
        messageSystem.emit(Draw(hand));
    }

    function handle_place(card, x :Int, y :Int) {
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
            messageSystem.emit(Collected(cards));
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
        change_tile(pos, null);
    }

    function change_tile(pos :{ x :Int, y :Int }, card :Card) {
        grid.set_tile(pos.x, pos.y, card);
        messageSystem.emit(ChangedTile(pos.x, pos.y, card));
    }

    public function handle_selection(tiles :Array<{ x :Int, y :Int }>) {
        if (!is_collection_valid(tiles)) return;
        if (complete_quest(tiles)) return;
        if (make_stack(tiles)) return;
    }

    /*
    function handle_select(x :Int, y :Int) {
        // TODO: test that collected tiles are adjacent
        if (collecting.length > 0) {
            var last_col = collecting[collecting.length - 1];
            if (Math.abs(last_col.x - x) + Math.abs(last_col.y - y) != 1) {
                trace('Collected cards must be adjacent');
                return;
            }
        }

        if (grid.get_tile(x, y) == null) {
            trace('No card to be collected here');
            return;
        }

        collecting.push({ x: x, y: y });
        if (collecting.length == 3) {
            // test if collection is a quest
            var cards_collected = [ for (c in collecting) grid.get_tile(c.x, c.y) ];
            for (quest in quests) {
                if (cards_matching(cards_collected, quest)) {
                    trace('Matched quest: $quest');
                    quests.remove(quest);
                    for (c in collecting) grid.set_tile(c.x, c.y, null);
                    update_score(cards_collected, quest);
                    collecting = [];
                    messageSystem.emit(Collected(cards_collected));
                    return;
                }
            }

            // test if collection is a merge
            for (i in 0 ... collecting.length - 1) {
                var this_col = collecting[i];
                var next_col = collecting[i + 1];
                var this_card = grid.get_tile(this_col.x, this_col.y);
                var next_card = grid.get_tile(next_col.x, next_col.y);
                if (this_card == null || next_card == null || this_card.suit != next_card.suit || this_card.stacked || next_card.stacked) {
                    trace('No match for collected cards');
                    collecting = [];
                    return;
                }
            }
            trace('Made a stack');
            for (i in 0 ... collecting.length - 1) grid.set_tile(collecting[i].x, collecting[i].y, null);
            var last_col = collecting[collecting.length - 1];
            var last_card = grid.get_tile(last_col.x, last_col.y);
            grid.set_tile(last_col.x, last_col.y, { suit: last_card.suit, stacked: true });
            collecting = [];
            messageSystem.emit(Stacked(cards_collected));
            return;
        }
    }
    */

    function update_score(cards :Array<Card>, quest :Array<Card>) {
        for (i in 0 ... cards.length) {
            score += (cards[i].stacked ? 5 : 1);
            score += (cards[i].suit == quest[i].suit ? 1 : 0);
        }
    }

    function cards_matching(cards1 :Array<Card>, cards2 :Array<Card>) {
        var test = cards2.copy();
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

    /*
    function is_collecting(x :Int, y :Int) {
        return (Lambda.find(collecting, function(c) {
            return c.x == x && c.y == y;
        }) != null);
        //return (collecting.indexOf({ x: x, y: y }) > -1);
        // for (col in collecting) {
        //     if (col.x == x && col.y == y) return true;
        // }
        // return false;
    }
    */

    public function game_over() {
        return false;
    }
}
