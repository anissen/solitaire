package core.models;

import core.models.Deck.Card;
import core.queues.MessageSystem;

using Lambda;

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
    GameOver();
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

    public function new_game(grid_width :Int, grid_height :Int, deck_cards :Array<Card>, quest_cards :Array<Card>) {
        deck = new Deck(deck_cards);
        quest_deck = new Deck(quest_cards);
        grid = new Grid(grid_width, grid_height);

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
            if (newQuest.length == 3) {
                quests.push(newQuest);
                messageSystem.emit(NewQuest(newQuest));
            }
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

        if (is_game_over()) {
            messageSystem.emit(GameOver);
        }
    }

    public function is_game_over() {
        var last_turn = deck.empty();
        var empty_hand = hand.empty();
        if (last_turn && empty_hand) {
            trace('game over: last turn + hand empty');
            return true;
        }

        var quest_completable = is_quest_completable();
        if (quest_completable) {
            trace('one or more quests can be completed');
            return false;
        }
        
        var board_full = is_board_full();
        if (!board_full) {
            trace('board is not full');
            return false;
        }

        var board_stackable = is_board_stackable();
        if (board_stackable) {
            trace('board is stackable');
            return false;
        }

        trace('game over: board is full and not stackable');
        return true;
    }

    function is_board_full() {
        for (x in 0 ... grid.get_width()) {
            for (y in 0 ... grid.get_height()) {
                if (grid.get_tile(x, y) == null) return false;
            }
        }
        return true;
    }

    function is_collectable(cards :Array<Card>) {
        if (cards.empty()) throw 'Nonsense!';

        // var candidates = [];
        // for (x in 0 ... grid.get_width()) {
        //     for (y in 0 ... grid.get_height()) {
        //         var tile = grid.get_tile(x, y);
        //         if (tile != null && cards.exists(function(c) { return c.suit == tile.suit && c.stacked == tile.stacked; })) {
        //             candidates.push(tile);
        //         }
        //     }
        // }

        // var firsts = candidates.filter(function(c) { return c.suit == cards[0].suit && c.stacked == cards[0].stacked; });
        // if (firsts.empty()) return false;
        
        function find_subset(x :Int, y :Int, subset :Array<Card>) {
            if (subset.empty()) return true;
            
            var tile = grid.get_tile(x, y);
            if (tile == null) return false;
            var match = (subset[0].suit == tile.suit && subset[0].stacked == tile.stacked);
            if (!match) return false;
            
            var new_subset = subset.copy();
            new_subset.shift();

            if (x > 0 && find_subset(x - 1, y, new_subset)) return true;
            if (x < grid.get_width() - 1 && find_subset(x + 1, y, new_subset)) return true;
            if (y > 0 && find_subset(x, y - 1, new_subset)) return true;
            if (y < grid.get_height() - 1 && find_subset(x, y + 1, new_subset)) return true;
            return false;
        }

        for (x in 0 ... grid.get_width()) {
            for (y in 0 ... grid.get_height()) {
                if (find_subset(x, y, cards)) return true;
            }
        }

        return false;
    }

    function is_board_stackable() {
        var suit_map = new Map<Int, Card>();
        for (x in 0 ... grid.get_width()) {
            for (y in 0 ... grid.get_height()) {
                var tile = grid.get_tile(x, y);
                if (tile != null && !tile.stacked) {
                    suit_map[tile.suit] = tile;
                }
            }
        }
        for (s in suit_map) {
            if (is_collectable([s, s, s])) return true;
        }
        return false;
    }

    function is_quest_completable() {
        for (quest in quests) {
            if (quest.empty()) continue;
            // if (is_collectable(quest)) return true;
            if (is_collectable([ quest[0], quest[1], quest[2] ])) return true;
            if (is_collectable([ quest[0], quest[2], quest[1] ])) return true;
            if (is_collectable([ quest[1], quest[0], quest[2] ])) return true;
            if (is_collectable([ quest[1], quest[2], quest[0] ])) return true;
            if (is_collectable([ quest[2], quest[0], quest[1] ])) return true;
            if (is_collectable([ quest[2], quest[1], quest[0] ])) return true;
        }
        return false;
    }

    public function is_placement_valid(x :Int, y :Int) {
        return (grid.get_tile(x, y) == null);
    }

    public function is_collection_valid(tiles :Array<Card>) {
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

        for (i in 0 ... tiles.length) {
            for (j in 0 ... tiles.length) {
                if (i == j) continue;
                if (tiles[i] == tiles[j]) {
                    trace('Two of the same card selected');
                    return false;
                }
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

        // TODO: This is a test!
        // score += 1;
        // messageSystem.emit(Score(score));

        return true;
    }

    function remove_tile(card :Card) {
        messageSystem.emit(TileRemoved(grid.get_tile(card.grid_pos.x, card.grid_pos.y)));
        grid.set_tile(card.grid_pos.x, card.grid_pos.y, null);
    }
    
    public function get_matching_quest_parts(tiles :Array<Card>) {
        if (!is_collection_valid(tiles)) return [];

        // var matchingQuestParts = [];
        var matches = [];

        // Only look at the quests in normal order (not reversed)
        //var cards = [ for (t in tiles) grid.get_tile(t.grid_pos.x, t.grid_pos.y) ];
        for (quest in quests) {
            // var tiles_copy = [ for (tile in tiles) { suit: tile.suit, stacked: tile.stacked } ];
            var quest_copy = [ for (tile in quest) { suit: tile.suit, stacked: tile.stacked, tile: tile } ];
            var quest_matches = [];

            for (tile in tiles) {
                var match = false;
                for (quest_card in quest_copy) {
                    if (tile.suit == quest_card.suit && tile.stacked == quest_card.stacked) {
                        quest_matches.push(quest_card.tile);
                        quest_copy.remove(quest_card);
                        match = true;
                        break;
                    }
                }
                if (!match) {
                    quest_matches = [];
                    break;
                }
            }

            // for (quest_card in quest) {
            //     for (tile in tiles_copy) {
            //         if (tile.suit == quest_card.suit && tile.stacked == quest_card.stacked) {
            //             tiles_copy.remove(tile);
            //             quest_matches.push(quest_card);
            //             break;
            //         }
            //         quest_matches = [];
            //         break;
            //     }
            // }
            if (quest_matches.length > 0) matches = matches.concat(quest_matches); // TODO: Replace with tool function
        }
        // return matchingQuestParts;
        return matches;
    }

    public function handle_collecting(tiles :Array<Card>) {
        if (!is_collection_valid(tiles)) return;
        if (tiles.length != 3) {
            trace('Only ${tiles.length} tiles selected');
            return;
        }
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
