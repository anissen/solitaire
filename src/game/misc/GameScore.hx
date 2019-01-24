package game.misc;

import core.utils.AsyncHttpUtils;

using game.misc.GameMode.GameModeTools;

typedef HighscoreOptions = {
    score :Int,
    seed :Int,
    game_mode :GameMode.GameMode,
    global_highscores_callback :Dynamic -> Void,
    global_highscores_error_callback :String -> Void
}

typedef LocalHighscores = Array<{ 
    score :Int,
    name :String,
    current :Bool
}>;

class GameScore {
    static public function add_highscore(options :HighscoreOptions) :LocalHighscores {
        update_settings(options);
        add_global_highscore(options);
        return add_local_highscore(options);
    }

    static function update_settings(options :HighscoreOptions) {
        var game_mode = options.game_mode;
        var score = options.score;
        var total_score = Settings.load_int('total_score', 0);
        total_score += options.score;
        Luxe.io.string_save('total_score', '$total_score');

        var now = Date.now();
        var date_string = '' + now.getDate() + now.getMonth() + now.getFullYear();
        if (Luxe.io.string_load(game_mode.get_non_tutorial_game_mode_id() + '_play_date') == date_string) { // only update plays today if it is still "today"
            // Update the plays today value
            var plays_today = Luxe.io.string_load(game_mode.get_non_tutorial_game_mode_id() + '_plays_today');
            if (plays_today == null) plays_today = '0';
            var number_of_plays_today = Std.parseInt(plays_today) + 1;
            Luxe.io.string_save(game_mode.get_non_tutorial_game_mode_id() + '_plays_today', '$number_of_plays_today');
        }

        switch (game_mode) {
            case Strive(level) | Tutorial(Strive(level)):
                Luxe.io.string_save('old_journey_level', '$level');

                var won = (score >= game_mode.get_strive_score());
                var new_level = (won ? level + 1 : level - 1);
                if (new_level < 1) new_level = 1;
                Luxe.io.string_save('journey_level', '$new_level');

                var highest_level_played = Settings.load_int('journey_highest_level_played', 0);
                if (level > highest_level_played)  Luxe.io.string_save('journey_highest_level_played', '$level');

                var strive_highscore = Settings.load_int('journey_highscore', 0);
                var highest_level_won = Settings.load_int('journey_highest_level_won', -1);
                if (won) {
                    if (level > highest_level_won) {
                        highest_level_won = level;
                        Luxe.io.string_save('journey_highest_level_won', '$highest_level_won');
                    }
                    if (score > strive_highscore) {
                        strive_highscore = score;
                        Luxe.io.string_save('journey_highscore', '$score');
                    }
                }
            default:
        }
    }

    static function add_global_highscore(options :HighscoreOptions) {
        var game_mode = options.game_mode;
        var plays_today = Settings.load_int(game_mode.get_non_tutorial_game_mode_id() + '_plays_today', 0);
        var now = Date.now(); // TODO: Should be the date the the game is *STARTED*!
        var url = Settings.SERVER_URL + 'scores/';

        var data_map = [
            'user_id' => '' + Luxe.io.string_load('clientId'),
            'user_name' => Luxe.io.string_load('user_name'),
            'score' => '' + options.score,
            'strive_goal' => '' + game_mode.get_strive_score(),
            'seed' => '' + options.seed,
            'year' => '' + now.getFullYear(),
            'month' => '' + now.getMonth(),
            'day' => '' + now.getDate(),
            'game_mode' => '' + game_mode.get_non_tutorial_game_mode_index(),
            'game_count' => '' + plays_today,
            'actions' => '', // + options.actions_data
            'total_score' => '' + Settings.load_int('total_score', 0),
            'highest_journey_level_won' => '' + Settings.load_int('journey_highest_level_won', -1)
        ];

        AsyncHttpUtils.post(url, data_map, function(data :HttpCallback) {
            if (data.error == null) {
                if (data.json == null) {
                    options.global_highscores_error_callback('Error');
                } else {
                    options.global_highscores_callback(data.json);
                }
            } else {
                options.global_highscores_error_callback(data.error);
            }
        }); 
    }

    static function add_local_highscore(options :HighscoreOptions) :LocalHighscores {
        var game_mode = options.game_mode;
        var score = options.score;
        var user_name = Settings.load_string('user_name', 'You');

        var local_scores_str = Luxe.io.string_load('scores_${game_mode.get_game_mode_id()}');
        var local_scores = [];
        if (local_scores_str != null) local_scores = haxe.Json.parse(local_scores_str);

        var local_highscores = [ for (s in local_scores) { score: s, name: user_name, current: false } ];
        local_highscores.push({ score: score, name: user_name, current: true });

        local_scores.push(score); // code is HERE to prevent duplicate own scores
        Luxe.io.string_save('scores_${game_mode.get_game_mode_id()}', haxe.Json.stringify(local_scores));

        return local_highscores;
    }
}
