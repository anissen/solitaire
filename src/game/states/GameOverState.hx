package game.states;

import luxe.Text;
import luxe.States.State;
import luxe.Vector;
import luxe.Color;
import luxe.Scene;
import luxe.Sprite;
import luxe.tween.Actuate;
import game.misc.GameMode.GameMode;
import game.misc.GameScore;
import core.utils.AsyncHttpUtils;
import core.utils.AsyncHttpUtils.HttpCallback;

using game.misc.GameMode.GameModeTools;

class HighscoreLine extends luxe.Entity {
    var rankText :Text;
    var scoreText :Text;
    var nameText :Text;
    public var icon :Sprite = null;
    public var point_icon :Sprite = null;
    public var alpha(get, set) :Float;
    public var color(get, set) :Color;

    public function new(rank :String, score :Int, name :String) {
        super({ name: '$rank.$score.$name', name_unique: true });
        rankText = new luxe.Text({
            parent: this,
            pos: new Vector(80, 0),
            text: rank,
            point_size: 20,
            align: right,
            align_vertical: center,
            color: new Color(0.6, 0.6, 0.6, 0.0),
            depth: 10
        });
        scoreText = new luxe.Text({
            parent: this,
            pos: new Vector(120, 0),
            text: '$score',
            point_size: 20,
            align: right,
            align_vertical: center,
            color: new Color(0.5, 0.5, 0.5, 0.0),
            depth: 10
        });
        nameText = new luxe.Text({
            parent: this,
            pos: new Vector(145, 0),
            text: name,
            point_size: 20,
            align: left,
            align_vertical: center,
            color: new Color(0.5, 0.5, 0.5, 0.0),
            depth: 10
        });
    }

    function set_alpha(alpha :Float) {
        rankText.color.a = alpha;
        scoreText.color.a = alpha;
        nameText.color.a = alpha;
        if (icon != null) icon.color.a = alpha / 2;
        if (point_icon != null) point_icon.color.a = alpha;
        return alpha;
    }

    function get_alpha() {
        return rankText.color.a;
    }

    function set_color(color :Color) {
        rankText.color = color.clone();
        scoreText.color = color.clone();
        nameText.color = color.clone();
        if (point_icon != null) point_icon.color = color.clone();
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
    total_score :Int,
    highest_journey_level_won :Int,
    ?back_to_state :String,
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
    var loading_icon :Sprite;
    var loading_global_data :Bool;
    var back_to_state :String;

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
        loading_global_data = false;

        var data :DataType = cast d;
        score = data.score;
        game_mode = data.game_mode;
        back_to_state = (data.back_to_state != null ? data.back_to_state : MenuState.StateId);
        var next_game_mode = data.next_game_mode;

        var back_button = new game.ui.Icon({
            pos: new Vector(30, 30),
            texture_path: 'assets/ui/arrowBeige_left.png',
            on_click: Main.SetState.bind(back_to_state)
        });
        back_button.scale.set_xy(1/4, 1/4);
        back_button.depth = 100;

        highscore_mode = Global;
        if (data.highscore_mode == Rank) highscore_mode = Rank;
        var is_rank_mode = switch (highscore_mode) {
            case Rank: true;
            default: false;
        };

        var is_journey_mode = switch (game_mode) {
            case Strive(_) | Tutorial(Strive(_)): true;
            default: false;
        };

        if (!is_rank_mode && !is_journey_mode) {
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
            text: 'Global Highscores',
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
            case Strive(level): 'Journey: ${next_game_mode.get_strive_score()}';
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
        } else if (is_journey_mode) {
            play_button.visible = false;
            show_journey_highscores();
        } else {
            // retry_button = new game.ui.Button({
            //     pos: new Vector(Settings.WIDTH / 2, Settings.HEIGHT / 2 + 60),
            //     text: 'Try again',
            //     on_click: function() {
            //         update_global_highscores(data);
            //     }
            // });
            // retry_button.visible = false;

            loading_global_data = true;
            loading_icon.visible = true;
            Actuate.tween(loading_icon.scale, 1.0, { x: -0.3 }).ease(luxe.tween.easing.Elastic.easeInOut).reflect().repeat();

            // if (is_journey_mode) {
            //     GameScore.get_journey_highscores({
            //         global_highscores_callback: function(highscores :Array<GlobalHighscore>) {
            //             loading_global_data = false;
            //             global_highscores = highscores;
            //             show_global_highscores();
            //         },
            //         global_highscores_error_callback: show_error
            //     });
            // } else {
                local_highscores = GameScore.add_highscore({
                    score: score,
                    seed: data.seed,
                    game_mode: game_mode,
                    global_highscores_callback: function(highscores :Array<GlobalHighscore>) {
                        loading_global_data = false;
                        global_highscores = highscores;
                        show_global_highscores();
                    },
                    global_highscores_error_callback: show_error
                });
            // }
        }
    }

    function show_error(text :String) {
        loading_icon.visible = false;
        new luxe.Text({
            pos: new Vector(Settings.WIDTH / 2, Settings.HEIGHT / 2),
            text: text,
            point_size: 22,
            align: center,
            align_vertical: center,
            color: new Color(0.75, 0.0, 0.0),
            depth: 10,
            scene: highscore_lines_scene,
            bounds: new luxe.Rectangle(-Settings.WIDTH / 2 + 20, -Settings.HEIGHT / 2, Settings.WIDTH - 40, Settings.HEIGHT),
            bounds_wrap: true
        });
    }
    
    function show_global_highscores() {
        if (Main.GetStateId() != GameOverState.StateId) return;

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

        var clientId = Luxe.io.string_load('clientId');

        var highscore_lines = [];
        var count = 0;
        for (highscore in global_highscores) {
            count++;
            var highscore_line = new HighscoreLine('$count.', highscore.score, '' + highscore.user_name);
            highscore_line.point_icon = new Sprite({
                parent: highscore_line,
                pos: new Vector(132, -3),
                texture: Luxe.resources.texture('assets/ui/diamond.png'),
                scale: new Vector(0.037, 0.037),
                color: new Color().rgb(0x956416)
            });
            if (highscore.user_id == clientId) highscore_line.color = new Color(0.75, 0.0, 0.5);
            if (score > highscore.score) {
                highscore_line.icon = new Sprite({
                    parent: highscore_line,
                    pos: new Vector(23, -4),
                    texture: Luxe.resources.texture('assets/ui/round-star.png'),
                    scale: new Vector(0.045, 0.045),
                    color: new Color().rgb(0x8C7D56),
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

        local_highscores.sort(function(a, b) {
            if (a.score == b.score) {
                if (a.current) return -1;
                if (b.current) return 1;
            }
            return b.score - a.score;
        });
        
        var count = 0;
        var highscore_lines = [];
        for (highscore in local_highscores) {
            count++;
            var highscore_line = new HighscoreLine('$count.', highscore.score, highscore.name);
            highscore_line.point_icon = new Sprite({
                parent: highscore_line,
                pos: new Vector(132, -3),
                texture: Luxe.resources.texture('assets/ui/diamond.png'),
                scale: new Vector(0.037, 0.037),
                color: new Color().rgb(0x956416)
            });
            if (highscore.current) highscore_line.color = new Color(0.75, 0.0, 0.5);
            highscore_lines.push(highscore_line);
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
                    show_error('Error');
                } else {
                    var clientId = Luxe.io.string_load('clientId');
                    var json :Array<{ user_id :String, user_name :String, total_stars :Null<Int>, total_wins :Int }> = data.json;
                    var highscore_lines = [];
                    var rank = 0;
                    var last_stars = -1;
                    for (rankJson in json) {
                        var stars = (rankJson.total_stars != null ? rankJson.total_stars : rankJson.total_wins);
                        if (stars != last_stars) rank++;
                        if (rank > 100) break; // only show the first 100 ranked players (+ ties)

                        var highscore_line = new HighscoreLine('$rank.', stars, rankJson.user_name);
                        highscore_line.point_icon = new Sprite({
                            parent: highscore_line,
                            pos: new Vector(132, -3),
                            texture: Luxe.resources.texture('assets/ui/round-star.png'),
                            scale: new Vector(0.037, 0.037),
                            color: new Color().rgb(0x8C7D56)
                        });
                        if (rankJson.user_id == clientId) highscore_line.color = new Color(0.75, 0.0, 0.5);
                        highscore_line.color.a = 0;
                        highscore_lines.push(highscore_line);
                        last_stars = stars;
                    }
                    show_highscores(highscore_lines);
                }
            } else {
                show_error(data.error);
            }
        });
    }

    function show_journey_highscores() {
        loading_icon.visible = true;
        Actuate.tween(loading_icon.scale, 1.0, { x: -0.3 }).ease(luxe.tween.easing.Elastic.easeInOut).reflect().repeat();

        title.text = 'Journey Highscores';
        highscore_mode = Global;

        var url = Settings.SERVER_URL + 'strive_highscores';
        AsyncHttpUtils.get(url, function(data :HttpCallback) {
            if (Main.GetStateId() != GameOverState.StateId) return;

            loading_icon.visible = false;
            if (data.error == null) {
                if (data.json == null) {
                    show_error('Error');
                } else {
                    var clientId = Luxe.io.string_load('clientId');
                    var json :Array<{ user_id :String, user_name :String, highest_journey_level_won :Int, highest_journey_score_won :Null<Int> }> = data.json;
                    var highscore_lines = [];
                    var rank = 0;
                    var last_level_won = -1;
                    for (highscoreJson in json) {
                        var level_won = highscoreJson.highest_journey_level_won;
                        if (level_won != last_level_won) rank++;
                        if (rank > 100) break; // only show the first 100 ranked players (+ ties)

                        var strive_score = GameModeTools.get_strive_score(Strive(highscoreJson.highest_journey_level_won));
                        var highscore_line = new HighscoreLine('$rank.', strive_score, highscoreJson.user_name);
                        highscore_line.point_icon = new Sprite({
                            parent: highscore_line,
                            pos: new Vector(132, -3),
                            texture: Luxe.resources.texture('assets/ui/diamond.png'),
                            scale: new Vector(0.037, 0.037),
                            color: new Color().rgb(0x8C7D56)
                        });
                        if (highscoreJson.user_id == clientId) highscore_line.color = new Color(0.75, 0.0, 0.5);
                        highscore_line.color.a = 0;
                        highscore_lines.push(highscore_line);
                        last_level_won = level_won;
                    }
                    show_highscores(highscore_lines);
                }
            } else {
                show_error(data.error);
            }
        });
    }

    function show_highscores(highscore_lines :Array<HighscoreLine>) {
        score_container = new luxe.Visual({ name: 'score_container', scene: highscore_lines_scene });
        score_container.color.a = 0;

        var count = 0;
        for (highscore_line in highscore_lines) {
            count++;
            highscore_line.pos.y = count * 25 + 100;
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
            Main.SetState(back_to_state);
        }
    }

    override function onleave(_) {
        Actuate.reset();
        highscore_lines_scene.empty();
        Luxe.scene.empty();
    }
}
