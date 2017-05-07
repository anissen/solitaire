package game.states;

import luxe.Text;
import luxe.States.State;
import luxe.Vector;
import luxe.Sprite;
import luxe.Color;
import luxe.tween.Actuate;

class HighscoreLine {
    var rankText :Text;
    var scoreText :Text;
    var nameText :Text;
    public var y(get, set) :Float;
    public var alpha(get, set) :Float;
    public var color(get, set) :Color;

    public function new(rank :String, score :Int, name :String, y :Float) {
        rankText = new luxe.Text({
            pos: new Vector(60, y),
            text: '$rank.',
            point_size: 28,
            align: right,
            align_vertical: center,
            color: new Color(0.6, 0.6, 0.6, 0.0),
            depth: 101
        });
        scoreText = new luxe.Text({
            pos: new Vector(115, y),
            text: '$score',
            point_size: 28,
            align: right,
            align_vertical: center,
            color: new Color(0.6, 0.6, 0.6, 0.0),
            depth: 101
        });
        nameText = new luxe.Text({
            pos: new Vector(120, y),
            text: name,
            point_size: 28,
            align: left,
            align_vertical: center,
            color: new Color(0.6, 0.6, 0.6, 0.0),
            depth: 101
        });
    }

    function set_y(y :Float) {
        rankText.pos.y = y;
        scoreText.pos.y = y;
        nameText.pos.y = y;
        return y;
    }
    
    function get_y() {
        return rankText.pos.y;
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
        rankText.color = color;
        scoreText.color = color;
        nameText.color = color;
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

    override function onenabled(data :Dynamic) {
        var highscore :Highscore = cast data;

        var http = new haxe.Http("http://localhost:1337/highscore");
        http.addParameter('client', highscore.client);
        http.addParameter('name', highscore.name);
        http.addParameter('score', '${highscore.score}');
        http.onError = function(data) {
            trace('error: $data');

            new HighscoreLine('?', highscore.score, highscore.name, 320 /* TODO: Don't hardcode */);
            // TODO: Show not-connected icon
        }
        http.onStatus = function(data) {
            trace('status: $data');
        }
        http.onData = function(data) {
            trace('data: $data');
            var scores :Array<Highscore> = [];
            try {
                scores = haxe.Json.parse(data);
            } catch (e :Dynamic) {
                trace('Error parsing data: $e');
            }

            scores.sort(function(a, b) { return b.score - a.score; });
            
            var count = 0;
            for (score in scores) {
                count++;
                var highscore_line = new HighscoreLine('$count', score.score, score.name, count * 50);
                Actuate.tween(highscore_line, 0.3, { y: count * 50 - 20, alpha: 1.0 }).delay(1.0);
                if (score.client == highscore.client) {
                    highscore_line.color = new Color(0.4, 0.4, 0.4, 0.0);
                    Actuate.tween(Luxe.camera.view.center, 5.0, { y: count * 50 }, true).onUpdate( function() {
                        Luxe.camera.transform.pos.set_xy(Luxe.camera.view.pos.x, Luxe.camera.view.pos.y);
                    });
                }
            }
            Luxe.camera.transform.pos.y = count * 50;
        }
        http.request();

        var bg = new luxe.Sprite({
            pos: Luxe.screen.mid.clone(),
            size: Luxe.screen.size.clone(),
            color: new Color(1.0, 1.0, 1.0, 0.0),
            depth: 100
        });

        Actuate.tween(bg.color, 1.0, { a: 0.95 }).onComplete(function() {
        //     var my_highscore_line = new HighscoreLine('$my_highscore_rank', highscore.score, highscore.name, highscores_count * 50 + 620);
        //     Actuate.tween(my_highscore_line, 0.3, { alpha: 1 }).onComplete(function() {
        //         Actuate.tween(my_highscore_line, 5.0, { y: my_highscore_rank * 50 - 20 }).onUpdate(function() {
        //             Luxe.camera.transform.pos.y = my_highscore_line.y;
        //         });
        //     });
        });
    }

    override function ondisabled(_) {
        Luxe.scene.empty();
    }

    override function onmouseup(event :luxe.Input.MouseEvent) {
        if (event.button == luxe.Input.MouseButton.left) {
            Main.NewGame();
        }
    }
}
