package core.models;

import core.models.Deck.Card;
import core.models.Deck.CardData;
import core.models.Deck.InfiniteDeck;
import core.queues.MessageSystem;

typedef CardId = Int;

enum Action {
    Noop;
    Place(card :CardId, x :Int, y :Int);
    Collect(tiles :Array<CardId>);
}

enum Event {
    NewGame();
    Draw(card :Array<Card>);
    NewQuest(card :Array<Card>);
    TilePlaced(card :Card, x :Int, y :Int);
    TileRemoved(card :Card);
    Collected(cards :Array<Card>, quest :Array<Card>, total_score :Int);
    Stacked(card :Card);
    Score(score :Int, card :Card, correct_order :Bool);
    GameOver();
}

class Game {
    public static var Instance(default, null) = new Game();
    public static var CardManager(default, null) = new Map<CardId, Card>();

    var quest_deck :InfiniteDeck;
    var deck :InfiniteDeck;
    var grid :Grid<Card>;

    var quests :Array<Array<Card>>;
    var hand :Array<Card>;

    var messageSystem :MessageSystem<Action, Event>;

    function new() {
        messageSystem = new MessageSystem();
        messageSystem.on_action(handle_action);
    }

    public function new_game(grid_width :Int, grid_height :Int, deck :InfiniteDeck, quest_deck :InfiniteDeck) {
        this.deck = deck;
        this.quest_deck = quest_deck;
        grid = new Grid(grid_width, grid_height);

        messageSystem.reset();
        quests = [];
        hand = [];
        Card.CardId = 0;
        CardManager = new Map();

        new_turn();
    }

    public function get_actions_data() {
        return messageSystem.serialize();
    }

    public function make_puzzle(instantiate_func :CardData->Card) {
        // var random_cards = [
        //     { suit: 0, stacked: false },
        //     { suit: 0, stacked: false },
        //     { suit: 1, stacked: false },
        //     { suit: 1, stacked: false },
        //     { suit: 2, stacked: false },
        //     { suit: 2, stacked: false }
        // ];
        // // deck.add_cards(random_cards);

        // var positions = [
        //     { x: 0, y: 0 },
        //     { x: 1, y: 0 },
        //     { x: 2, y: 0 },
        //     { x: 0, y: 1 },
        //     { x: 1, y: 1 },
        //     { x: 2, y: 1 },
        //     { x: 0, y: 2 },
        //     { x: 1, y: 2 },
        //     { x: 2, y: 2 }
        // ];//.shuffle();

        // deck.add_cards([ // hand
        //     { suit: 0, stacked: false },
        //     { suit: 1, stacked: false },
        //     { suit: 2, stacked: false }
        // ]);

        // var card_pos_pairs = [];
        // // var the_quests = [];
        // var newQuest = [];
        // for (card_data in random_cards) {
        //     var card = instantiate_func(card_data);
        //     var position = positions.shift();
        //     // card_pos_pairs.push({ card: card, pos: position });
        //     newQuest.push(card);
        //     if (newQuest.length == 3) {
        //         // the_quests.push(newQuest);

        //         quests.push(newQuest);
        //         messageSystem.emit(NewQuest(newQuest));
        //         newQuest.clear();
        //     }
        //     handle_place(card.cardId, position.x, position.y);
        // }

        // // for (card_pos_pair in card_pos_pairs) {
        // //     handle_place(card_pos_pair.card.cardId, card_pos_pair.pos.x, card_pos_pair.pos.y);
        // // }
        
        // return;


        // 3+3+3 = 9
        // 3+3+3+3 = 12
        // 3+2+3+3 = 11

        /* 
         (New) idea:
         Place 9 random tiles on the grid. Make a "worm" find and remove a connected subset of the tiles. Randomly place between 0 and 3 of cards on hand onto grid. Repeat. The collected tiles form the quests.
         Consider using stacked tiles?

         To use all tiles:
         Make a grid like this:
         XXX
         X X
         XXX

         Hand: XXX
         There must be exactly one stacked tile (3+2+3 tiles + 3 cards - 2 tiles for stack == 3+3+3 quest cards)
        */

        
        // for (y in 0 ... 3) {
        //     for (x in 0 ... 3) {
        //         if (x == 1 && y == 1) continue; // skip center tile
        //         var card = deck.take(1).first();
        //         //grid.set_tile(x, y, card);
        //         handle_place(card.cardId, x, y);
        //     }
        // }

        var positions = [
            { x: 0, y: 0 },
            { x: 1, y: 0 },
            { x: 2, y: 0 },
            // { x: 0, y: 1 },
            // { x: 1, y: 1 },
            // { x: 2, y: 1 },
            { x: 0, y: 2 },
            { x: 1, y: 2 },
            { x: 2, y: 2 }
        ];//.shuffle();
        
        for (pos in positions) {
            var card = deck.take(1).first();
            handle_place(card.cardId, pos.x, pos.y);
        }

        //var hand = deck.take(3);

        // var test_grid = grid.clone();

        // function get_random_tile(empty :Bool = false) {
        //     var x = 0;
        //     var y = 0;
        //     var tile = null;
        //     while (tile == null) {
        //         x = Luxe.utils.random.int(0, 3);
        //         y = Luxe.utils.random.int(0, 3);
        //         tile = test_grid.get_tile(x, y);
        //         if (empty && tile == null) break; // return first empty tile if empty argument is passed
        //     }
        //     return { tile: tile, x: x, y: y };
        // }

        // function get_adjacent_tiles(startX :Int, startY :Int) {
        //     var adjacent = [];
        //     if (startX > 0) adjacent.push({ x: startX - 1, y: startY });
        //     if (startX < 3) adjacent.push({ x: startX + 1, y: startY });
        //     if (startY > 0) adjacent.push({ x: startX, y: startY - 1 });
        //     if (startY < 3) adjacent.push({ x: startX, y: startY + 1 });

        //     var nonempty = [];
        //     for (a in adjacent) {
        //         var tile = test_grid.get_tile(a.x, a.y);
        //         if (tile != null) nonempty.push({ tile: tile, x: a.x, y: a.y });
        //     }
        //     return nonempty.shuffle();
        // }

        function collect_quest(x :Int, y :Int, quest :Array<Card>, visited :Array<Card>) {
            // trace('collect_quest x: $x, y: $y');
            // trace('quest length: ${quest.length}');
            var tile = grid.get_tile(x, y);
            if (tile == null) return [];
            if (visited.has(tile)) return [];
            quest.push(tile);
            // trace('quest tile added!');
            if (quest.length == 3) return quest;

            var new_visited = visited.copy();
            new_visited.push(tile);
            
            var new_quest = quest.copy();
            // new_quest.shift();

            var adjacent_tiles = [];
            if (x > 0)                      adjacent_tiles.push({ x: x - 1, y: y });
            if (x < grid.get_width() - 1)   adjacent_tiles.push({ x: x + 1, y: y });
            if (y > 0)                      adjacent_tiles.push({ x: x, y: y - 1 });
            if (y < grid.get_height() - 1)  adjacent_tiles.push({ x: x, y: y + 1 });

            for (adjacent in adjacent_tiles.shuffle()) {
                var result = collect_quest(adjacent.x, adjacent.y, new_quest, new_visited);
                if (result.length == 3) return result;
            }
            return [];
        }

        var visited_quest_tiles = [];
        function get_quest() {

            for (pos in positions.shuffle()) {
                var quest = collect_quest(pos.x, pos.y, [], visited_quest_tiles);
                // trace('get_quest quest length: ${quest.length}');
                // trace(quest);
                if (quest.length == 3) {
                    // for (q in quest) test_grid.set_tile(q.grid_pos.x, q.grid_pos.y, null);
                    visited_quest_tiles = visited_quest_tiles.concat(quest);
                    return quest;
                }
            }
            
            // var tiles = get_adjacent_tiles(start.x, start.y);
            // if (tiles.empty()) return [];

            throw 'No quests found on board!';

            return [];
        }

        var quest_cards :Array<CardData> = [];
        while (quest_cards.length < 6) {
            for (q in get_quest()) {
                // trace('got quest!');
                quest_cards.push({ suit: q.suit, stacked: q.stacked });
            }
            // trace('count_all: ${quest_cards.length}');
        }

        // quest_deck.clear(); // hack
        quest_deck.add_cards(quest_cards);

        while (quests.length < 2) {
            // trace('creating a new quest');
            var newQuest = quest_deck.take(3);
            quests.push(newQuest);
            messageSystem.emit(NewQuest(newQuest));
        }
    }

    public function do_action(action :Action) {
        messageSystem.do_action(action);
    }

    public function listen(func :Event->snow.api.Promise) {
        messageSystem.listen(func);
    }

    function handle_action(action :Action) {
        // trace(action);
        switch (action) {
            case Noop:
            case Place(cardId, x, y): handle_place(cardId, x, y);
            case Collect(cardIds): handle_collecting(cardIds);
        }
        return snow.api.Promise.resolve();
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

    function handle_place(cardId :CardId, x :Int, y :Int) {
        var card = CardManager[cardId];
        messageSystem.emit(TilePlaced(card, x, y));
        grid.set_tile(x, y, card);

        hand.remove(card);
        if (hand.length == 0) {
            new_turn();
        }

        if (is_game_over()) {
            messageSystem.emit(GameOver);
        }
    }

    public function save() {
        return messageSystem.serialize();
    }

    public function load(s :String) {
        messageSystem.reset();
        messageSystem.emit(NewGame);
        messageSystem.deserialize(s);
    }

    public function is_game_over() {
        var board_full = is_board_full();
        if (!board_full) {
            // trace('board is not full');
            return false;
        }

        var quest_completable = is_quest_completable();
        if (quest_completable) {
            // trace('one or more quests can be completed');
            return false;
        }

        var board_stackable = is_board_stackable();
        if (board_stackable) {
            // trace('board is stackable');
            return false;
        }

        // trace('game over: board is full and not stackable');
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
        
        function find_subset(x :Int, y :Int, subset :Array<Card>, visited :Array<Card>) {
            if (subset.empty()) return true;
            
            var tile = grid.get_tile(x, y);
            if (tile == null) return false;
            if (visited.has(tile)) return false;
            var match = (subset[0].suit == tile.suit && subset[0].stacked == tile.stacked);
            if (!match) return false;

            var new_visited = visited.copy();
            new_visited.push(tile);
            
            var new_subset = subset.copy();
            new_subset.shift();

            if (x > 0 && find_subset(x - 1, y, new_subset, new_visited)) return true;
            if (x < grid.get_width() - 1 && find_subset(x + 1, y, new_subset, new_visited)) return true;
            if (y > 0 && find_subset(x, y - 1, new_subset, new_visited)) return true;
            if (y < grid.get_height() - 1 && find_subset(x, y + 1, new_subset, new_visited)) return true;
            return false;
        }

        for (x in 0 ... grid.get_width()) {
            for (y in 0 ... grid.get_height()) {
                if (find_subset(x, y, cards, [])) return true;
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
                // trace('Tile has no grid_pos -- how?');
                return false;
            }

            if (grid.get_tile(tile.grid_pos.x, tile.grid_pos.y) == null) {
                // trace('Empty tile selected');
                return false;
            }
        }

        for (i in 0 ... tiles.length) {
            for (j in 0 ... tiles.length) {
                if (i == j) continue;
                if (tiles[i] == tiles[j]) {
                    // trace('Two of the same card selected');
                    return false;
                }
            }
        }

        for (i in 1 ... tiles.length) {
            var previous = tiles[i - 1];
            var current = tiles[i];

            if (Math.abs(current.grid_pos.x - previous.grid_pos.x) + Math.abs(current.grid_pos.y - previous.grid_pos.y) != 1) {
                // trace('Collected cards must be adjacent');
                return false;
            }
        }

        // var cards = [ for (t in tiles) grid.get_tile(t.grid_pos.x, t.grid_pos.y) ];
        // var best_quest = get_best_quest(cards);
        // return (best_quest != null);
        return true;
    }

    function get_best_quest(cards :Array<Card>) {
        var best_quest_score = 0;
        var best_quest = null;
        for (quest in quests) {
            if (!cards_matching(cards, quest)) continue;
            
            var quest_score = calculate_score(cards, quest);
            if (quest_score > best_quest_score) {
                best_quest = quest;
                best_quest_score = quest_score;
            } 
        }
        return best_quest;
    }

    function complete_quest(tiles :Array<Card>) {
        var cards = [ for (t in tiles) grid.get_tile(t.grid_pos.x, t.grid_pos.y) ];
        // var best_quest_score = 0;
        // var best_quest = null;
        // for (quest in quests) {
        //     if (!cards_matching(cards, quest)) continue;
            
        //     var quest_score = calculate_score(cards, quest);
        //     if (quest_score > best_quest_score) {
        //         best_quest = quest;
        //         best_quest_score = quest_score;
        //     } 
        // }

        var best_quest = get_best_quest(cards);        
        if (best_quest == null) return false;

        quests.remove(best_quest);
        update_score(cards, best_quest);
        for (tile in tiles) remove_tile(tile);
        messageSystem.emit(Collected(cards, best_quest, calculate_score(cards, best_quest)));
        return true;
    }

    function make_stack(tiles :Array<Card>) {
        // test if collection is a merge
        var cards = [ for (t in tiles) grid.get_tile(t.grid_pos.x, t.grid_pos.y) ];
        var first_card = cards[0];
        if (first_card.stacked) return false;

        for (i in 1 ... cards.length) {
            var card = cards[i];
            if (card.stacked || card.suit != first_card.suit) {
                // trace('No match for collected cards');
                return false;
            }
        }

        for (i in 0 ... cards.length - 1) {
            messageSystem.emit(Score(1, cards[i], false));
        }

        for (i in 0 ... tiles.length - 1) remove_tile(tiles[i]);

        messageSystem.emit(Stacked(cards.last()));

        return true;
    }

    function remove_tile(card :Card) {
        messageSystem.emit(TileRemoved(grid.get_tile(card.grid_pos.x, card.grid_pos.y)));
        grid.set_tile(card.grid_pos.x, card.grid_pos.y, null);
    }
    
    public function get_matching_quest_parts(tiles :Array<Card>) {
        if (!is_collection_valid(tiles)) return [];

        var matches = [];

        // Only look at the quests in normal order (not reversed)
        for (quest in quests) {
            var quest_copy = [ for (tile in quest) { suit: tile.suit, stacked: tile.stacked, tile: tile } ];
            // trace(quest_copy);
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

            if (quest_matches.length > 0) matches.append(quest_matches);
        }
        return matches;
    }

    public function handle_collecting(cardIds :Array<CardId>) {
        var tiles = [ for (id in cardIds) CardManager[id] ];
        if (!is_collection_valid(tiles)) return;
        if (tiles.length != 3) {
            // trace('Only ${tiles.length} tiles selected');
            return;
        }
        if (complete_quest(tiles)) return;
        if (make_stack(tiles)) return;
    }

    function card_score(card :Card, isCorrectOrder :Bool) {
        return (card.stacked ? 3 : 1) * (isCorrectOrder ? 2 : 1);
    }

    function is_correct_order(cards :Array<Card>, quest :Array<Card>) {
        var matchingSuits = true;
        var matchingSuitsReverse = true;
        for (i in 0 ... cards.length) {
            if (cards[i].suit != quest[i].suit) matchingSuits = false;
            if (cards[i].suit != quest[cards.length - i - 1].suit) matchingSuitsReverse = false;
        }
        return (cards.length > 0 && (matchingSuits || matchingSuitsReverse));
    }

    function calculate_score(cards :Array<Card>, quest :Array<Card>) {
        var score_sum = 0;
        for (card in cards) {
            score_sum += card_score(card, is_correct_order(cards, quest));
        }
        return score_sum;
    }

    function update_score(cards :Array<Card>, quest :Array<Card>) {
        var correct_order = is_correct_order(cards, quest);
        for (card in cards) {
            var card_score = card_score(card, correct_order);
            messageSystem.emit(Score(card_score, card, correct_order));
        }
    }

    function cards_matching(cards1 :Array<Card>, cards2 :Array<Card>) {
        var cards2_copy = [ for (card in cards2) { suit: card.suit, stacked: card.stacked } ];
        for (a in cards1) {
            var match = false;
            for (b in cards2_copy) {
                if (a.suit == b.suit && a.stacked == b.stacked) {
                    cards2_copy.remove(b);
                    match = true;
                    break;
                }
            }
            if (!match) return false;
        }
        return true;
    }
}
