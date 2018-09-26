package game.states;

import luxe.Text;
import luxe.States.State;
import luxe.Vector;
import luxe.Color;
import luxe.Scene;
import luxe.Sprite;
import luxe.tween.Actuate;
import game.misc.GameMode.GameMode;
import core.utils.AsyncHttpUtils;
import core.utils.AsyncHttpUtils.HttpCallback;

using game.misc.GameMode.GameModeTools;

class HighscoreLine extends luxe.Entity {
    var rankText :Text;
    var scoreText :Text;
    var nameText :Text;
    public var icon :Sprite = null;
    public var alpha(get, set) :Float;
    public var color(get, set) :Color;

    public function new(rank :String, score :Int, name :String) {
        super({ name: '$rank.$score.$name', name_unique: true });
        rankText = new luxe.Text({
            parent: this,
            pos: new Vector(60, 0),
            text: rank,
            point_size: 24,
            align: right,
            align_vertical: center,
            color: new Color(0.7, 0.7, 0.7, 0.0),
            depth: 10
        });
        scoreText = new luxe.Text({
            parent: this,
            pos: new Vector(115, 0),
            text: '$score',
            point_size: 24,
            align: right,
            align_vertical: center,
            color: new Color(0.6, 0.6, 0.6, 0.0),
            depth: 10
        });
        nameText = new luxe.Text({
            parent: this,
            pos: new Vector(125, 0),
            text: name,
            point_size: 24,
            align: left,
            align_vertical: center,
            color: new Color(0.6, 0.6, 0.6, 0.0),
            depth: 10
        });
    }

    function set_alpha(alpha :Float) {
        rankText.color.a = alpha;
        scoreText.color.a = alpha;
        nameText.color.a = alpha;
        if (icon != null) icon.color.a = alpha / 2;
        return alpha;
    }

    function get_alpha() {
        return rankText.color.a;
    }

    function set_color(color :Color) {
        rankText.color = color.clone();
        scoreText.color = color.clone();
        nameText.color = color.clone();
        return color;
    }

    function get_color() {
        return rankText.color;
    }
}

typedef DataType = { 
    user_id :String,
    seed :Int,
    score :Int,
    name :String,
    game_mode :GameMode,
    next_game_mode :GameMode,
    actions_data :String,
    ?highscore_mode :HighscoreMode
};

typedef LocalHighscore = { 
    score :Int,
    name :String,
    current :Bool
};

typedef GlobalHighscore = { 
    score :Int,
    name :String,
    user_id :String,
    user_name :String
};

enum HighscoreMode {
    Global;
    Local;
    Rank;
}

class GameOverState extends State {
    static public var StateId :String = 'GameOverState';
    var highscore_mode :HighscoreMode;
    var game_mode :GameMode;
    var score :Int;
    var local_highscores :Array<LocalHighscore>;
    var global_highscores :Array<GlobalHighscore>;
    var highscore_lines_scene :Scene;
    var title :Text;
    var score_container :luxe.Visual;
    var play_button :game.ui.Button;
    // var retry_button :game.ui.Button;
    var error_text :String;
    var loading_icon :Sprite;
    var loading_global_data :Bool;

    public function new() {
        super({ name: StateId });
    }

    override function init() {
        
    }

    override function onenter(d :Dynamic) {
        local_highscores = null;
        global_highscores = null;
        highscore_lines_scene = new Scene();
        score_container = null;
        error_text = '';
        loading_global_data = false;

        var data :DataType = cast d;
        score = data.score;
        game_mode = data.game_mode;
        var next_game_mode = data.next_game_mode;

        var back_button = new game.ui.Icon({
            pos: new Vector(30, 30),
            texture_path: 'assets/ui/arrowBeige_left.png',
            on_click: Main.SetState.bind(MenuState.StateId)
        });
        back_button.scale.set_xy(1/4, 1/4);
        back_button.depth = 100;

        var is_strive_mode = switch (game_mode) {
            case Strive(_): true;
            default: false;
        };
        highscore_mode = (is_strive_mode ? Local : Global);
        if (data.highscore_mode == Rank) highscore_mode = Rank;
        var is_rank_mode = switch (highscore_mode) {
            case Rank: true;
            default: false;
        };

        if (!is_strive_mode && !is_rank_mode) { // TODO: Handle Strive global highscore mode
            var highscores_button = new game.ui.Icon({
                pos: new Vector(Settings.WIDTH - 35, 35),
                texture_path: 'assets/ui/circular.png',
                on_click: function() {
                    switch (highscore_mode) {
                        case Global: show_local_highscores();
                        case Local:  show_global_highscores();
                        case Rank:
                    }
                }
            });
            highscores_button.scale.set_xy(1/5, 1/5);
            highscores_button.color.a = 0.75;
            new Sprite({
                texture: Luxe.resources.texture('assets/ui/holy-grail.png'),
                parent: highscores_button,
                pos: new Vector(128, 128),
                scale: new Vector(0.3, 0.3),
                color: new Color().rgb(0x8C7D56),
                depth: 110
            });
        }

        /*
        Normal: Top 100 (/All time high)
        Normal: Today
        Normal: Local
        Strive: All time high
        Strive: Local
        Timed: All time high
        Timed: Today
        Timed: Local
        */

        title = new Text({
            text: (is_strive_mode ? 'Local Highscores' : 'Global Highscores'),
            pos: new Vector(Settings.WIDTH / 2, 70),
            point_size: 26,
            align: luxe.Text.TextAlign.center,
            align_vertical: luxe.Text.TextAlign.center,
            color: new luxe.Color(1.0, 1.0, 1.0),

            letter_spacing: 0,
            sdf: true,
            shader: Luxe.renderer.shaders.bitmapfont.shader.clone('title-shader'),
            outline: 0.75,
            outline_color: new Color().rgb(0xa55004),
        });

        loading_icon = new Sprite({
            texture: Luxe.resources.texture('assets/ui/egyptian-walk.png'),
            pos: new Vector(Settings.WIDTH / 2, Settings.HEIGHT / 2),
            scale: new Vector(0.3, 0.3),
            color: new Color().rgb(0xa55004),
            depth: 110
        });
        loading_icon.color.a = 0.2;
        loading_icon.visible = false;

        var play_text = switch (next_game_mode) {
            case Normal: 'Play';
            case Strive(level): 'Strive: ${next_game_mode.get_strive_score()}';
            case Timed: 'Survival';
            case Puzzle: 'Puzzle';
            case Tutorial(_): 'Tutorial'; // never shown
        };

        play_button = new game.ui.Button({
            pos: new Vector(Settings.WIDTH / 2, Settings.HEIGHT - 40),
            text: play_text,
            on_click: function() {
                Main.SetState(PlayState.StateId, next_game_mode);
            }
        });
        if (is_rank_mode) {
            play_button.visible = false;
            show_rank();
        } else {
            // retry_button = new game.ui.Button({
            //     pos: new Vector(Settings.WIDTH / 2, Settings.HEIGHT / 2 + 60),
            //     text: 'Try again',
            //     on_click: function() {
            //         update_global_highscores(data);
            //     }
            // });
            // retry_button.visible = false;

            var user_name = Luxe.io.string_load('user_name');
            if (user_name == null || user_name.length == 0) user_name = 'You';

            var total_score = Std.parseInt(Luxe.io.string_load('total_score'));
            if (total_score == null) total_score = 0;
            total_score += score;
            Luxe.io.string_save('total_score', '$total_score');

            var local_scores_str = Luxe.io.string_load('scores_${game_mode.get_game_mode_id()}');
            var local_scores = [];
            if (local_scores_str != null) local_scores = haxe.Json.parse(local_scores_str);

            local_highscores = [ for (s in local_scores) { score: s, name: user_name, current: false } ];
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

            if (is_strive_mode) {
                show_local_highscores();
                update_global_highscores(data); // just update, don't show the global scores yet
            } else {
                update_global_highscores(data);
            }
        }
    }

    function update_global_highscores(data :DataType) {
        switch (highscore_mode) {
            case Local: // don't show loading icon in local mode
            case Global | Rank: {
                loading_icon.visible = true;
                Actuate.tween(loading_icon.scale, 1.0, { x: -0.3 }).ease(luxe.tween.easing.Elastic.easeInOut).reflect().repeat();
            }
        }
        loading_global_data = true;
        // retry_button.visible = false;

        var plays_today = Std.parseInt(Luxe.io.string_load(game_mode.get_non_tutorial_game_mode_id() + '_plays_today'));
        var now = Date.now();
        var user_name = Luxe.io.string_load('user_name');
        var strive_goal = data.game_mode.get_strive_score();

        var url = Settings.SERVER_URL + 'scores/';

        var data_map = [
            'user_id' => '' + data.user_id,
            'user_name' => user_name,
            'score' => '' + data.score,
            'strive_goal' => '' + strive_goal,
            'seed' => '' + data.seed,
            'year' => '' + now.getFullYear(),
            'month' => '' + now.getMonth(),
            'day' => '' + now.getDate(),
            'game_mode' => '' + get_non_tutorial_game_mode().getIndex(),
            'game_count' => '' + plays_today,
            'actions' => '' // + data.actions_data
        ];

        AsyncHttpUtils.post(url, data_map, function(data :HttpCallback) {
            if (Main.GetStateId() != GameOverState.StateId) return;

            loading_global_data = false;
            if (data.error == null) {
                global_highscores = data.json;
                if (global_highscores == null) {
                    error_text = 'Error';
                    show_error();
                } else {
                    switch (highscore_mode) {
                        case Local | Rank: // don't do anything
                        case Global: show_global_highscores();
                    }
                }
            } else {
                error_text = data.error;
                // retry_button.visible = true;
                show_error();
            }
        });
    }

    function show_error() {
        loading_icon.visible = false;
        new luxe.Text({
            pos: new Vector(Settings.WIDTH / 2, Settings.HEIGHT / 2),
            text: error_text,
            point_size: 24,
            align: center,
            align_vertical: center,
            color: new Color(0.75, 0.0, 0.0),
            depth: 10,
            scene: highscore_lines_scene
        });
    }
    
    function show_global_highscores() {
        if (score_container != null && !score_container.destroyed) {
            for (child in score_container.children) {
                Actuate.stop(child);
                var highscore_line = cast (child, HighscoreLine);
                if (highscore_line != null && highscore_line.icon != null) Actuate.stop(highscore_line.icon);
            }
        }
        highscore_lines_scene.empty();
        loading_icon.visible = false;

        title.text = 'Global Highscores';
        highscore_mode = Global;

        if (loading_global_data) {
            loading_icon.visible = true;
            Actuate.tween(loading_icon.scale, 1.0, { x: -0.3 }).ease(luxe.tween.easing.Elastic.easeInOut).reflect().repeat();
            return;
        }

        if (global_highscores == null) {
            show_error();
            return;
        }

        var clientId = Luxe.io.string_load('clientId');

        var highscore_lines = [];
        var count = 0;
        for (highscore in global_highscores) {
            count++;
            var highscore_line = new HighscoreLine('$count.', highscore.score, '' + highscore.user_name);
            if (highscore.user_id == clientId) highscore_line.color = new Color(0.75, 0.0, 0.5);
            if (score > highscore.score) {
                highscore_line.icon = new Sprite({
                    parent: highscore_line,
                    pos: new Vector(Settings.WIDTH - 30, 0),
                    texture: Luxe.resources.texture('assets/ui/round-star.png'),
                    scale: new Vector(0.045, 0.045),
                    color: new Color().rgb(0x956416),
                    depth: 5
                });
                luxe.tween.Actuate
                    .tween(highscore_line.icon, 10.0, { rotation_z: 360 })
                    .ease(luxe.tween.easing.Linear.easeNone)
                    .repeat();
            }
            highscore_lines.push(highscore_line);
        }
        show_highscores(highscore_lines);
    }

    function show_local_highscores() {
        if (score_container != null && !score_container.destroyed) {
            for (child in score_container.children) {
                Actuate.stop(child);
                var highscore_line = cast (child, HighscoreLine);
                if (highscore_line != null && highscore_line.icon != null) Actuate.stop(highscore_line.icon);
            }
        }
        highscore_lines_scene.empty();
        loading_icon.visible = false;

        title.text = 'Local Highscores';
        highscore_mode = Local;

        var highscore_lines = [];
        switch (game_mode) {
            case Strive(level) | Tutorial(Strive(level)):
                var highest_level_played = Std.parseInt(Luxe.io.string_load('strive_highest_level_played'));
                if (highest_level_played == null) highest_level_played = 0;
                if (level > highest_level_played)  Luxe.io.string_save('strive_highest_level_played', '$level');

                var strive_highscore = Std.parseInt(Luxe.io.string_load('strive_highscore'));
                if (strive_highscore == null) strive_highscore = 0;
                var highest_level_won = Std.parseInt(Luxe.io.string_load('strive_highest_level_won'));
                if (highest_level_won == null) highest_level_won = 0;
                if (score >= game_mode.get_strive_score()) {
                    if (level > highest_level_won) {
                        highest_level_won = level;
                        Luxe.io.string_save('strive_highest_level_won', '$highest_level_won');
                    }
                    if (score > strive_highscore) {
                        strive_highscore = score;
                        Luxe.io.string_save('strive_highscore', '$score');
                    }
                }

                var max_level = (level > highest_level_played ? level : highest_level_played);
                for (i in 0 ... max_level) {
                    var level_counter = (max_level - i);
                    var strive_mode = Strive(level_counter);
                    var description = 'Lost';
                    var color = new Color(0.5, 0.0, 0.0);
                    if (level_counter == highest_level_won) {
                        description = 'Highscore';
                        color = new Color(0.5, 0.0, 0.5);
                    }
                    if (level_counter < level) {
                        description = 'Won';
                        color = new Color(0.0, 0.5, 0.0);
                    }
                    if (game_mode.equals(strive_mode)) {
                        var won_game = (score >= game_mode.get_strive_score());
                        description = (won_game ? 'Won!' : 'Lost!');
                    }
                    var highscore_line = new HighscoreLine('', strive_mode.get_strive_score(), description);
                    highscore_line.color = color;
                    if (game_mode.equals(strive_mode)) {
                        var won_game = (score >= game_mode.get_strive_score());
                        highscore_line.color = new Color(0.75, 0.1, 0.1);
                        if (won_game) highscore_line.color = ((level_counter == highest_level_won) ? new Color(0.5, 0.0, 0.5) : new Color(0.1, 0.75, 0.1));
                    }
                    
                    highscore_lines.push(highscore_line);
                } 
            default:
                local_highscores.sort(function(a, b) {
                    if (a.score == b.score) {
                        if (a.current) return -1;
                        if (b.current) return 1;
                    }
                    return b.score - a.score;
                });
                var count = 0;
                for (highscore in local_highscores) {
                    count++;
                    var highscore_line = new HighscoreLine('$count.', highscore.score, highscore.name);
                    if (highscore.current) highscore_line.color = new Color(0.75, 0.0, 0.5);
                    highscore_lines.push(highscore_line);
                }
        }

        show_highscores(highscore_lines);
    }

    function show_rank() {
        loading_icon.visible = true;
        Actuate.tween(loading_icon.scale, 1.0, { x: -0.3 }).ease(luxe.tween.easing.Elastic.easeInOut).reflect().repeat();

        title.text = 'Rankings';
        highscore_mode = Rank;

        var url = Settings.SERVER_URL + 'rank';
        AsyncHttpUtils.get(url, function(data :HttpCallback) {
            if (Main.GetStateId() != GameOverState.StateId) return;

            loading_icon.visible = false;
            if (data.error == null) {
                if (data.json == null) {
                    error_text = 'Error';
                    show_error();
                } else {
                    var clientId = Luxe.io.string_load('clientId');
                    var json :Array<{ user_id :String, user_name :String, total_wins :Int }> = data.json;
                    var highscore_lines = [];
                    var rank = 0;
                    var last_wins = -1;
                    for (rankJson in json) {
                        if (rankJson.total_wins != last_wins) rank++;
                        if (rank > 100) break; // only show the first 100 ranked players (+ ties)

                        var highscore_line = new HighscoreLine('$rank.', rankJson.total_wins, rankJson.user_name);
                        if (rankJson.user_id == clientId) highscore_line.color = new Color(0.75, 0.0, 0.5);
                        highscore_line.color.a = 0;
                        highscore_lines.push(highscore_line);
                        last_wins = rankJson.total_wins;
                    }
                    show_highscores(highscore_lines);
                }
            } else {
                error_text = data.error;
                show_error();
            }
        });
    }

    function show_highscores(highscore_lines :Array<HighscoreLine>) {
        score_container = new luxe.Visual({ name: 'score_container', scene: highscore_lines_scene });
        score_container.color.a = 0;

        var count = 0;
        for (highscore_line in highscore_lines) {
            count++;
            highscore_line.pos.y = count * 25 + 90;
            highscore_line.alpha = 0;
            highscore_line.parent = score_container;

            Actuate.tween(highscore_line, 0.3, { alpha: get_fade_value(highscore_line.pos.y) }).delay(0.1 + count * 0.05);
        }
        var highscore_list_height = (count * 25 + 100);
        if (highscore_list_height > Settings.HEIGHT) {
            var pan = new game.components.DragPan({ name: 'DragPan' });
            var correct_drag_top = #if web 100 #else 40 #end;
            pan.y_top = Settings.HEIGHT - highscore_list_height - correct_drag_top;
            pan.y_bottom = 0;
            pan.ondrag = update_fading.bind(highscore_lines);
            score_container.add(pan);
        }
    }

    function update_fading(highscore_lines :Array<HighscoreLine>) {
        for (highscore_line in highscore_lines) {
            highscore_line.alpha = get_fade_value(highscore_line.pos.y);
        }
    }

    function get_fade_value(line_y :Float) {
        var y = score_container.pos.y + line_y;
        var top_fade_y = (title.pos.y + 65);
        var top_hide_y = (title.pos.y + 25);
        var bottom_fade_y = (play_button.visible ? play_button.pos.y - 55 : Settings.HEIGHT - 55);
        var bottom_hide_y = (play_button.visible ? play_button.pos.y - 15 : Settings.HEIGHT - 15);
        if (y < top_hide_y) {
            return 0.0;
        } else if (y < top_fade_y) {
            return (y - top_hide_y) / (top_fade_y - top_hide_y);
        } else if (y > bottom_hide_y) {
            return 0.0;
        } else if (y > bottom_fade_y) {
            return 1.0 - (y - bottom_fade_y) / (bottom_hide_y - bottom_fade_y);
        } else {
            return 1.0;
        }
    }

    override function onkeyup(event :luxe.Input.KeyEvent) {
        if (event.keycode == luxe.Input.Key.ac_back) {
            Main.SetState(MenuState.StateId);
        }
    }

    override function onleave(_) {
        Actuate.reset();
        highscore_lines_scene.empty();
        Luxe.scene.empty();
    }
}
