
package;

import core.models.Deck;
import core.models.Deck.Card;
import core.models.Grid;
import core.models.Game;
import core.models.Game.Action;

class CmdTest {
    static public function main() {
        #if (neko || cpp)
        play_game();
        #else
        trace('This only works in C++/Neko');
        #end
    }

    static public function play_game() {
        trace('Welcome to the game!');
        var game = new Game();
        while (!game.game_over()) {
            game.print_game();

            trace('>');
            var action = parse_input(Sys.stdin().readLine());
            try {
                switch (action) {
                    case Place(index, x, y): game.put(index, x, y);
                    case Select(x, y): game.collect(x, y);
                    case Noop: trace('Invalid action. Use one of the follwing:\n"put index x y"\n"pick x y"\n');
                }
            } catch (e :Dynamic) {
                trace('Something went wrong: $e. Try again.');
            }
        }
    }

    static function parse_input(input :String) {
        return switch (StringTools.trim(input).toLowerCase().split(' ')) {
            case ['put', index, x, y]: Place(Std.parseInt(index), Std.parseInt(x), Std.parseInt(y));
            case ['pick', x, y]: Select(Std.parseInt(x), Std.parseInt(y));
            case ['exit']: trace('Bye!'); Sys.exit(0); Noop;
            case _: Noop;
        }
    }
}
