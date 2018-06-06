package game.states;

import luxe.Text;
import luxe.States.State;
import luxe.Vector;
import luxe.Color;
import luxe.Scene;
import luxe.tween.Actuate;
import game.misc.GameMode.GameMode;

using game.misc.GameMode.GameModeTools;

class HighscoreLine extends luxe.Entity {
    var rankText :Text;
    var scoreText :Text;
    var nameText :Text;
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
            color: new Color(0.8, 0.8, 0.8, 0.0),
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

typedef DataType = { user_id :Int, score :Int, name :String, game_mode :GameMode, next_game_mode :GameMode };
typedef LocalHighscore = { score :Int, name :String, current :Bool };
typedef GlobalHighscore = { score :Int, name :String, user_id :Int, user_name :String };

enum HighscoreMode {
    Global;
    Local;
}

class GameOverState extends State {
    static public var StateId :String = 'GameOverState';
    var highscore_mode :HighscoreMode = Global;
    var game_mode :GameMode;
    var score :Int;
    var local_highscores :Array<LocalHighscore>;
    var global_highscores :Array<GlobalHighscore>;
    var highscore_lines_scene :Scene;
    var title :Text;
    var score_container :luxe.Visual;
    var play_button :game.ui.Button;

    public function new() {
        super({ name: StateId });
    }

    override function init() {
        highscore_lines_scene = new Scene();
    }

    override function onenter(d :Dynamic) {
        // var http = new haxe.Http("http://localhost:1337/highscore");
        // http.addParameter('user_id', data.user_id);
        // http.addParameter('name', data.name);
        // http.addParameter('score', '${data.score}');
        // http.onError = function(http_data) {
        //     trace('error: $http_data');
        //     var local_scores_str = Luxe.io.string_load('scores_${data.game_mode.get_game_mode_id()}');
        //     var local_scores = [];
        //     if (local_scores_str != null) local_scores = haxe.Json.parse(local_scores_str);

        //     var highscores = [ for (s in local_scores) { score: s, name: 'You' } ];

        //     show_highscores(highscores);
        // }
        // http.onStatus = function(http_data) {
        //     trace('status: $http_data');
        // }
        // http.onData = function(http_data) {
        //     trace('data: $http_data');
        //     var scores :Array<Highscore> = [];
        //     try {
        //         scores = haxe.Json.parse(http_data);
        //     } catch (e :Dynamic) {
        //         trace('Error parsing data: $e');
        //     }

        //     show_highscores(scores);
        // }
        // http.request();

        var back_button = new game.ui.Icon({
            pos: new Vector(25, 25),
            texture_path: 'assets/ui/arrowBeige_left.png',
            on_click: Main.SetState.bind(MenuState.StateId)
        });
        back_button.scale.set_xy(1/5, 1/5);
        back_button.depth = 100;

        // var toggle_highscores_button = new game.ui.Icon({
        //     pos: new Vector(Settings.WIDTH - 25, 25),
        //     texture_path: 'assets/ui/arrowBeige_left.png',
        //     on_click: function() {
        //         switch (highscore_mode) {
        //             case Global: show_local_highscores();
        //             case Local: show_global_highscores();
        //         }
        //     }
        // });
        // toggle_highscores_button.scale.set_xy(1/5, 1/5);
        // toggle_highscores_button.flipx = true;
        // toggle_highscores_button.depth = 100;

        var highscores_button = new game.ui.Icon({
            pos: new Vector(Settings.WIDTH - 35, 35),
            texture_path: 'assets/ui/circular.png',
            on_click: function() {
                switch (highscore_mode) {
                    case Global: show_local_highscores();
                    case Local:  show_global_highscores();
                }
            }
        });
        highscores_button.scale.set_xy(1/5, 1/5);
        highscores_button.color.a = 0.75;
        new luxe.Sprite({
            texture: Luxe.resources.texture('assets/ui/holy-grail.png'),
            parent: highscores_button,
            pos: new Vector(128, 128),
            scale: new Vector(0.3, 0.3),
            color: new Color().rgb(0x8C7D56),
            depth: 110
        });

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

        // var toggle_highscores_button = new game.ui.Button({
        //     pos: new Vector(Settings.WIDTH / 2, 100),
        //     width: Settings.WIDTH - 20,
        //     text: 'Global Highscores',
        //     on_click: function() {
        //         switch (highscore_mode) {
        //             case Global: show_local_highscores();
        //             case Local: show_global_highscores();
        //         }
        //     }
        // });

        var data :DataType = cast d;
        score = data.score;
        game_mode = data.game_mode;
        var next_game_mode = data.next_game_mode;

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

        var total_score = Std.parseInt(Luxe.io.string_load('total_score'));
        if (total_score == null) total_score = 0;
        total_score += score;
        Luxe.io.string_save('total_score', '$total_score');

        var local_scores_str = Luxe.io.string_load('scores_${game_mode.get_game_mode_id()}');
        var local_scores = [];
        if (local_scores_str != null) local_scores = haxe.Json.parse(local_scores_str);

        local_highscores = [ for (s in local_scores) { score: s, name: 'You', current: false } ];
        local_highscores.push({ score: score, name: 'You', current: true });

        local_scores.push(score); // code is HERE to prevent duplicate own scores

        Luxe.io.string_save('scores_${game_mode.get_game_mode_id()}', haxe.Json.stringify(local_scores));
        
        // show_local_highscores(game_mode, score, highscores);
        update_global_highscores(data);
    }

    function update_global_highscores(data :DataType) {
        var plays_today = Std.parseInt(Luxe.io.string_load(data.game_mode.get_game_mode_id() + '_plays_today'));
        var now = Date.now();
        var seed_string = '' + (data.game_mode.getIndex() + 1 /* to avoid zero */) + plays_today + now.getDate() + now.getMonth() + (now.getFullYear() - 2000);

        var url = #if debug 'http://localhost:3000/scores/' #else 'https://anissen-solitaire.herokuapp.com/scores/' #end ;

        // TODO: Make a map for holding the data and use it in both js and other platforms

        #if js
            var http = new haxe.Http(url);
            http.onData = function(data :String) {
                trace('data: $data');
                global_highscores = haxe.Json.parse(data);
                Luxe.next(show_global_highscores);
            }
            http.onError = function(error :String) {
                trace('error: $error');
                Luxe.next(show_error.bind(error));
            }
            http.onStatus = function(status :Int) {
                trace('status: $status');
            }
            http.addParameter('user_id', '' + data.user_id);
            http.addParameter('user_name', '' + 'Test Name'); // TODO: Implement!
            http.addParameter('score', '' + data.score);
            http.addParameter('seed', seed_string);
            http.addParameter('year', '' + now.getFullYear());
            http.addParameter('month', '' + now.getMonth());
            http.addParameter('day', '' + now.getDate());
            http.addParameter('game_mode', '' + data.game_mode.getIndex());
            http.addParameter('game_count', '' + plays_today);
            http.addParameter('actions', '');
            http.request(true);
        #else
            var content = {
                user_id: data.user_id,
                user_name: 'Test Name', // TODO: Implement!
                score: data.score,
                seed: Std.parseInt(seed_string),
                year: now.getFullYear(),
                month: now.getMonth(),
                day: now.getDate(),
                game_mode: data.game_mode.getIndex(),
                game_count: plays_today,
                actions: ''
            };
            function callback(response :com.akifox.asynchttp.HttpResponse) {
                if (response.isOK) {
                    trace('DONE ${response.status}');
                    trace(response.content);
                    global_highscores = response.toJson();
                    if (global_highscores == null) {
                        Luxe.next(show_error.bind('Error.'));
                    } else {
                        Luxe.next(show_global_highscores);
                    }
                } else {
                    trace('ERROR ${response.status} ${response.error}');
                    Luxe.next(show_error.bind(response.error));
                }
            }
            var request = new com.akifox.asynchttp.HttpRequest({ url: url, content: haxe.Json.stringify(content), callback: callback });
            request.method = com.akifox.asynchttp.HttpMethod.POST;
            request.contentType = 'application/json';
            request.send();
            #end
    }

    function show_error(text :String) {
        new luxe.Text({
            pos: new Vector(Settings.WIDTH / 2, Settings.HEIGHT / 2),
            text: text,
            point_size: 24,
            align: center,
            align_vertical: center,
            color: new Color(0.75, 0.0, 0.0, 0.0),
            depth: 10
        });
    }
    
    function show_global_highscores() {
        if (score_container != null) {
            for (child in score_container.children) Actuate.stop(child);
        }
        highscore_lines_scene.empty();

        title.text = 'Global Highscores';
        highscore_mode = Global;

        var clientId = Std.parseInt(Luxe.io.string_load('clientId'));

        var highscore_lines = [];
        var count = 0;
        for (highscore in global_highscores) {
            count++;
            var highscore_line = new HighscoreLine('$count.', highscore.score, '' + highscore.user_name);
            if (highscore.user_id == clientId) highscore_line.color = new Color(0.75, 0.0, 0.5);
            highscore_lines.push(highscore_line);
        }
        show_highscores(highscore_lines);
    }

    function show_local_highscores() {
        if (score_container != null) {
            for (child in score_container.children) Actuate.stop(child);
        }
        highscore_lines_scene.empty();

        title.text = 'Local Highscores';
        highscore_mode = Local;

        var highscore_lines = [];
        switch (game_mode) {
            case Strive(level) | Tutorial(Strive(level)):
                var strive_level = Std.parseInt(Luxe.io.string_load('strive_highlevel'));
                if (strive_level == null) strive_level = 0;
                var strive_highscore = Std.parseInt(Luxe.io.string_load('strive_highscore'));
                if (strive_highscore == null) strive_highscore = 0;
                if (score >= game_mode.get_strive_score()) {
                    if (level > strive_level)     Luxe.io.string_save('strive_highlevel', '$level');
                    if (score > strive_highscore) Luxe.io.string_save('strive_highscore', '$score');
                }

                var max_level = (level > strive_level ? level : strive_level);
                for (i in 0 ... max_level) {
                    var strive_mode = Strive(max_level - i);
                    var highscore_line = new HighscoreLine('#${max_level - i}', strive_mode.get_strive_score(), 'You');
                    if (game_mode.equals(strive_mode)) {
                        highscore_line.color = ((score >= game_mode.get_strive_score()) ? new Color(0.0, 0.75, 0.0) : new Color(0.75, 0.0, 0.0));
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

    function show_highscores(highscore_lines :Array<HighscoreLine>) {
        //highscores.sort(function(a, b) { return b.score - a.score; });

        score_container = new luxe.Visual({});
        score_container.color.a = 0;
        highscore_lines_scene.add(score_container);
        // score_container.clip_rect = new luxe.Rectangle(0, 50, Settings.WIDTH / 2, Settings.HEIGHT / 2 - 50);
        
        // TODO: Try adding a batcher with clipping rectangle
        // TODO: Fade in/out at the top/bottom
        var count = 0;
        for (highscore_line in highscore_lines) {
            count++;
            highscore_line.pos.y = count * 25 + 90;
            highscore_line.alpha = 0;
            highscore_line.parent = score_container;

            Actuate.tween(highscore_line, 0.3, { alpha: get_fade_value(highscore_line.pos.y) }).delay(0.1 + count * 0.05);
            // Actuate.tween(highscore_line.color, 0.3, { y: count * 25 }).delay(1.0);
            // if (score.user_id == highscore.user_id) {
            //     highscore_line.color = new Color(0.4, 0.4, 0.4, 0.0);
            //     Actuate.tween(Luxe.camera.view.center, 2.0, { y: count * 50 }, true).onUpdate( function() {
            //         Luxe.camera.transform.pos.set_xy(Luxe.camera.view.pos.x, Luxe.camera.view.pos.y); // TODO: Clamp to pan viewport
            //     });
            // }
        }
        // Luxe.camera.transform.pos.y = count * 50;
        // if (score_container.has('DragPan')) score_container.remove('DragPan');
        var highscore_list_height = (count * 25 + 100);
        if (highscore_list_height > Settings.HEIGHT) {
            var pan = new game.components.DragPan({ name: 'DragPan' });
            pan.y_top = Settings.HEIGHT - highscore_list_height;
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
        var top_fade_y = (title.pos.y + 60);
        var top_hide_y = (title.pos.y + 20);
        var bottom_fade_y = (play_button.pos.y - 50);
        var bottom_hide_y = (play_button.pos.y - 10);
        if (y < top_hide_y) {
            return 0.0;
        } else if (y < top_fade_y) {
            return (y - top_hide_y) / (top_fade_y - top_hide_y);
        } else if (y > bottom_hide_y) {
            return 0.0;
        } else if (y > bottom_fade_y) {
            trace(1.0 - (y - bottom_fade_y) / (bottom_hide_y - bottom_fade_y));
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
        Luxe.camera.remove('CameraPan');
        Luxe.scene.empty();
    }
}
