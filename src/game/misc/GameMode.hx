package game.misc;

enum GameMode {
    Normal;
    Strive(level :Int);
    Timed;
    Puzzle;
    Tutorial(game_mode :GameMode);
}

class GameModeTools {
    static public function get_strive_score(game_mode :GameMode) :Int {
        return switch (game_mode) {
            case Strive(level) | Tutorial(Strive(level)): (level < 10) ? level * 10 : 10 * 10 + (level % 10) * 5; // 10 interval to 100, then 5
            case _: 0;
        }
    }

    static public function get_game_mode_id(game_mode :GameMode) :String {
        return game_mode.getName().toLowerCase();
    }

    static public function persistable_game_mode(game_mode :GameMode) :Bool {
        return switch (game_mode) {
            case Normal: true;
            case Strive(_): true;
            case Puzzle: true;
            case Timed: false;
            case Tutorial(_): false;
        }
    }
}