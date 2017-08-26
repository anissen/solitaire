package core.models;

import core.models.Deck.Card;
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
    Collected(cards :Array<Card>, quest :Array<Card>);
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

        return true;
    }

    function complete_quest(tiles :Array<Card>) {
        var cards = [ for (t in tiles) grid.get_tile(t.grid_pos.x, t.grid_pos.y) ];
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

        if (best_quest == null) return false;

        quests.remove(best_quest);
        update_score(cards, best_quest);
        for (tile in tiles) remove_tile(tile);
        messageSystem.emit(Collected(cards, best_quest));
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
