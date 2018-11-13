package game.misc;

import game.misc.GameMode.GameMode;

using game.misc.GameMode.GameModeTools;

class GameScore {

    static public function update_local_score(game_mode :GameMode, score :Int) :Array<{ score :Int, name :String, current :Bool }> {
        var user_name = Luxe.io.string_load('user_name');
        if (user_name == null || user_name.length == 0) user_name = 'You';

        var total_score = Std.parseInt(Luxe.io.string_load('total_score'));
        if (total_score == null) total_score = 0;
        total_score += score;
        Luxe.io.string_save('total_score', '$total_score');

        var local_scores_str = Luxe.io.string_load('scores_${game_mode.get_game_mode_id()}');
        var local_scores = [];
        if (local_scores_str != null) local_scores = haxe.Json.parse(local_scores_str);

        var local_highscores = [ for (s in local_scores) { score: s, name: user_name, current: false } ];
        local_highscores.push({ score: score, name: user_name, current: true });

        local_scores.push(score); // code is HERE to prevent duplicate own scores

        var now = Date.now();
        var date_string = '' + now.getDate() + now.getMonth() + now.getFullYear();
        if (Luxe.io.string_load(game_mode.get_non_tutorial_game_mode_id() + '_play_date') == date_string) { // only update plays today if it is still "today"
            // Update the plays today value
            var plays_today = Luxe.io.string_load(game_mode.get_non_tutorial_game_mode_id() + '_plays_today');
            if (plays_today == null) plays_today = '0';
            var number_of_plays_today = Std.parseInt(plays_today) + 1;
            Luxe.io.string_save(game_mode.get_non_tutorial_game_mode_id() + '_plays_today', '$number_of_plays_today');
        }
        Luxe.io.string_save('scores_${game_mode.get_game_mode_id()}', haxe.Json.stringify(local_scores));

        switch (game_mode) {
            case Strive(level) | Tutorial(Strive(level)):
                var won = (score >= game_mode.get_strive_score());
                var new_level = (won ? level + 1 : level - 1);
                if (new_level < 1) new_level = 1;
                Luxe.io.string_save('journey_level', '$new_level');

                var highest_level_played = Std.parseInt(Luxe.io.string_load('journey_highest_level_played'));
                if (highest_level_played == null) highest_level_played = 0;
                if (level > highest_level_played)  Luxe.io.string_save('journey_highest_level_played', '$level');

                var strive_highscore = Std.parseInt(Luxe.io.string_load('journey_highscore'));
                if (strive_highscore == null) strive_highscore = 0;
                var highest_level_won = Std.parseInt(Luxe.io.string_load('journey_highest_level_won'));
                if (highest_level_won == null) highest_level_won = 0;
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

        return local_highscores;
    }
    
}
