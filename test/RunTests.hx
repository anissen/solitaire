package;

import core.models.Game;

@:structInit
class TestCard implements core.models.Deck.ICard {
    @:isVar public var suit(default, null) :Int;
    @:isVar public var stacked(default, set) :Bool;
    
    public var grid_pos :{ x :Int, y :Int } = null;

    function set_stacked(value :Bool) {
        return (stacked = value);
    }

	public function new(suit :Int, stacked :Bool) {
        this.suit = suit;
        this.stacked = stacked;
    }
}

class MyTests extends haxe.unit.TestCase {
    // var deck = new Deck();
    var game = new Game();

    override public function setup() {
        
    }

    public function testStackableGameBoard() {
        var card :TestCard = { suit: 0, stacked: false };
        game.new_game(3, 3, [ card ], []);

        assertFalse(game.is_game_over());
        for (x in 0 ... 3) {
            for (y in 0 ... 3) {
                assertTrue(game.is_placement_valid(x, y));
                var card :TestCard = { suit: 0, stacked: false };
                game.do_action(core.models.Action.Place(card, x, y));
                assertFalse(game.is_placement_valid(x, y));
                assertFalse(game.is_game_over());
            }
        }
    }

    public function testUnstackableGameBoard() {
        var card :TestCard = { suit: 0, stacked: false };
        game.new_game(3, 3, [ card ], []);

        for (x in 0 ... 3) {
            for (y in 0 ... 3) {
                var card :TestCard = { suit: (x + y), stacked: false };
                game.do_action(core.models.Action.Place(card, x, y));
            }
        }
        assertTrue(game.is_game_over());
    }
}

class QuestCompletionTests extends haxe.unit.TestCase {
    var game = new Game();
    var card0 :TestCard = { suit: 0, stacked: false };
    var card1 :TestCard = { suit: 1, stacked: false };
    var card2 :TestCard = { suit: 2, stacked: false };
    var card3 :TestCard = { suit: 3, stacked: false };
    var card4 :TestCard = { suit: 4, stacked: false };

    function setup_board() {
        /*
        Board:
        0·1·2
        1·2·3
        2·3·4
        */

        for (x in 0 ... 3) {
            for (y in 0 ... 3) {
                var card :TestCard = { suit: (x + y), stacked: false };
                game.do_action(core.models.Action.Place(card, x, y));
            }
        }
    }

    public function testCompleteableQuests() {
        game.new_game(3, 3, [ card0 ], [ card0, card1, card2 ]);
        setup_board();
        assertFalse(game.is_game_over());

        game.new_game(3, 3, [ card0 ], [ card2, card1, card0 ]);
        setup_board();
        assertFalse(game.is_game_over());

        game.new_game(3, 3, [ card0 ], [ card3, card2, card3 ]);
        setup_board();
        assertFalse(game.is_game_over());

        game.new_game(3, 3, [ card0 ], [ card3, card2, card4 ]);
        setup_board();
        assertFalse(game.is_game_over());
    }

    public function testNonCompleteableQuest() {
        game.new_game(3, 3, [ card0 ], [ card1, card2, card4 ]);
        setup_board();        
        assertTrue(game.is_game_over());

        game.new_game(3, 3, [ card0 ], [ card0, card2, card4 ]);
        setup_board();        
        assertTrue(game.is_game_over());
    }
}

class RunTests extends haxe.unit.TestRunner {
    static function main() {
        new RunTests();
    }

    public function new() {
        super();
        add(new MyTests());
        add(new QuestCompletionTests());
        run();
    }
}
