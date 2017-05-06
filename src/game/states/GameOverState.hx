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

    public function new(rank :Int, score :Int, name :String, y :Float) {
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
}

typedef Highscore = { score :Int, name :String };

class GameOverState extends State {
    static public var StateId :String = 'GameOverState';
    // var my_highscore_line :HighscoreLine;
    // var highscore_lines :Array<HighscoreLine>;
    // var scrolling :Bool;

    public function new() {
        super({ name: StateId });
    }

    override function init() {

    }

    override function onenabled(data :Dynamic) {
        var highscore :Highscore = cast data;
        var highscores_count = 0;
        // scrolling = false;
        // highscore_lines = [];
        var my_highscore_rank = 1;

        var http = new haxe.Http("http://localhost:1337/highscore");
        http.addParameter('name', highscore.name);
        http.addParameter('score', '${highscore.score}');
        http.onError = function(data) {
            trace('error: $data');

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
            
            for (score in scores) {
                if (score.score <= highscore.score && my_highscore_rank == 1) {
                    my_highscore_rank = highscores_count;
                    highscores_count++;
                }
                highscores_count++;
                var highscore_line = new HighscoreLine(highscores_count, score.score, score.name, highscores_count * 50);
                Actuate.tween(highscore_line, 0.3, { y: highscores_count * 50 - 20, alpha: 1.0 }); //.delay(count / 2);
                // highscore_lines.push(highscore_line);
            }
        }
        http.request();

        var bg = new luxe.Sprite({
            pos: Luxe.screen.mid.clone(),
            size: Luxe.screen.size.clone(),
            color: new Color(1.0, 1.0, 1.0, 0.0),
            depth: 100
        });

        Actuate.tween(bg.color, 1.0, { a: 0.95 }).onComplete(function() {
            var my_highscore_line = new HighscoreLine(my_highscore_rank, highscore.score, highscore.name, highscores_count * 50 + 620);
            Actuate.tween(my_highscore_line, 0.3, { alpha: 1 }).onComplete(function() {
                Actuate.tween(my_highscore_line, 5.0, { y: my_highscore_rank * 50 - 20 }).onUpdate(function() {
                    Luxe.camera.transform.pos.y = my_highscore_line.y;
                });
            });
        });
    }

    /*
    function show_highscores(scores :Array<Highscore>) {
        var count = 0;
        for (score in scores) {
            count++;
            var highscore = new HighscoreLine(count, score.score, score.name, count * 50);
            Actuate.tween(highscore, 0.3, { y: count * 50 - 20, alpha: 1.0 }).delay(count / 2);
        }
    }
    */

    override function ondisabled(_) {
        Luxe.scene.empty();
    }

    // override function update(dt :Float) {
    //     if (!scrolling) return;
    //     if (my_highscore_line.y <= )
    //     my_highscore_line.y -= dt;
    // }

    override function onmouseup(event :luxe.Input.MouseEvent) {
        if (event.button == luxe.Input.MouseButton.left) {
            Main.NewGame();
        }
    }
}
