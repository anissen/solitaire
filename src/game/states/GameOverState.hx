package game.states;

import luxe.Text;
import luxe.States.State;
import luxe.Vector;
import luxe.Color;
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
        super({ name: '$rank.$score.$name' });
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

typedef Highscore = { client :String, score :Int, name :String };

class GameOverState extends State {
    static public var StateId :String = 'GameOverState';

    public function new() {
        super({ name: StateId });
    }

    override function init() {

    }

    override function onenter(d :Dynamic) {
        // var http = new haxe.Http("http://localhost:1337/highscore");
        // http.addParameter('client', data.client);
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

        var data :{ client :String, score :Int, name :String, game_mode :GameMode, next_game_mode :GameMode } = cast d;
        var score = data.score;
        var game_mode = data.game_mode;
        var next_game_mode = data.next_game_mode;

        var play_text = switch (next_game_mode) {
            case Normal: 'Play';
            case Strive(level): 'Strive: ${next_game_mode.get_strive_score()}';
            case Timed: 'Survival';
            case Puzzle: 'Puzzle';
            case Tutorial(_): 'Tutorial'; // never shown
        };

        var play_button = new game.ui.Button({
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
        local_scores.push(score);
        Luxe.io.string_save('scores_${game_mode.get_game_mode_id()}', haxe.Json.stringify(local_scores));

        var highscores = [ for (s in local_scores) { score: s, name: 'You', current: false } ];
        highscores.push({ score: score, name: 'You', current: true });
        
        var highscore_lines = [];
        switch (game_mode) {
            case Strive(level):
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
                highscores.sort(function(a, b) {
                    if (a.score == b.score) {
                        if (a.current) return -1;
                        if (b.current) return 1;
                    }
                    return b.score - a.score;
                });
                var count = 0;
                for (highscore in highscores) {
                    count++;
                    var highscore_line = new HighscoreLine('$count.', highscore.score, highscore.name);
                    if (highscore.current) highscore_line.color = new Color(0.75, 0.0, 0.5);
                    highscore_lines.push(highscore_line);
                }
        }

        show_highscores(highscore_lines);

        // Actuate.tween(bg.color, 1.0, { a: 0.95 }).onComplete(function() {
        //     var my_highscore_line = new HighscoreLine('$my_highscore_rank', highscore.score, highscore.name, highscores_count * 50 + 620);
        //     Actuate.tween(my_highscore_line, 0.3, { alpha: 1 }).onComplete(function() {
        //         Actuate.tween(my_highscore_line, 5.0, { y: my_highscore_rank * 50 - 20 }).onUpdate(function() {
        //             Luxe.camera.transform.pos.y = my_highscore_line.y;
        //         });
        //     });
        // });
    }

    function show_highscores(highscore_lines :Array<HighscoreLine>) {
        //highscores.sort(function(a, b) { return b.score - a.score; });

        var score_container = new luxe.Visual({});
        score_container.color.a = 0;
        // score_container.clip_rect = new luxe.Rectangle(0, 50, Settings.WIDTH / 2, Settings.HEIGHT / 2 - 50);
        
        // TODO: Try adding a batcher with clipping rectangle
        // TODO: Fade in/out at the top/bottom
        var count = 0;
        for (highscore_line in highscore_lines) {
            count++;
            highscore_line.pos.y = count * 25 + 20;
            highscore_line.alpha = 0;
            highscore_line.parent = score_container;

            Actuate.tween(highscore_line, 0.3, { alpha: 1.0 }).delay(0.3 + count * 0.1);
            // Actuate.tween(highscore_line.color, 0.3, { y: count * 25 }).delay(1.0);
            // if (score.client == highscore.client) {
            //     highscore_line.color = new Color(0.4, 0.4, 0.4, 0.0);
            //     Actuate.tween(Luxe.camera.view.center, 2.0, { y: count * 50 }, true).onUpdate( function() {
            //         Luxe.camera.transform.pos.set_xy(Luxe.camera.view.pos.x, Luxe.camera.view.pos.y); // TODO: Clamp to pan viewport
            //     });
            // }
        }
        // Luxe.camera.transform.pos.y = count * 50;
        var highscore_list_height = (count * 25 + 100);
        if (highscore_list_height > Settings.HEIGHT) {
            var pan = new game.components.DragPan({ name: 'DragPan' });
            pan.y_top = Settings.HEIGHT - highscore_list_height;
            pan.y_bottom = 0;
            score_container.add(pan);
        }
    }

    override function onleave(_) {
        Luxe.camera.remove('CameraPan');
        Luxe.scene.empty();
    }

    // override function onmouseup(event :luxe.Input.MouseEvent) {
    //     if (event.button == luxe.Input.MouseButton.right) {
    //         Main.SetState(PlayState.StateId);
    //     }
    // }
}
