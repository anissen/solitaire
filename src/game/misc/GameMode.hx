package game.misc;

enum GameMode {
    Normal;
    Strive(level :Int);
}

class GameModeTools {
    static public function get_strive_score(game_mode :GameMode) :Int {
        return switch (game_mode) {
            case Normal: 0;
            case Strive(level): (level < 10) ? level * 10 : 10 * 10 + (level % 10) * 5; // 10 interval to 100, then 5
        }
    }

    static public function get_game_mode_id(game_mode :GameMode) :String {
        return game_mode.getName().toLowerCase();
    }
}