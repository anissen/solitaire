package;

import core.models.Game;

@:structInit
class TestCard implements core.models.Deck.Card {
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
        var card :TestCard = { suit: 0, stacked: false };
        game.new_game(4, 4, [ card ], []);
    }

    public function testGameBoard() {
        assertFalse(game.is_game_over());
        for (x in 0 ... 4) {
            for (y in 0 ... 4) {
                assertTrue(game.is_placement_valid(x, y));
                var card :TestCard = { suit: 0, stacked: false };
                game.do_action(core.models.Action.Place(card, x, y));
                assertFalse(game.is_placement_valid(x, y));
                assertFalse(game.is_game_over());
            }
        }
    }
}

class RunTests extends haxe.unit.TestRunner {
    static function main() {
        new RunTests();
    }

    public function new() {
        super();
        add(new MyTests());
        run();
    }
}
