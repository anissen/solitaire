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

class GameOverState extends State {
    static public var StateId :String = 'GameOverState';

    public function new() {
        super({ name: StateId });
    }

    override function init() {

    }

    override function onenabled(d :Dynamic) {
        var data :{ score :Int, name :String } = cast d;

        var http = new haxe.Http("http://localhost:1337/highscore");
        http.addParameter('name', data.name);
        http.addParameter('score', '${data.score}');
        http.onError = function(data) {
            trace('error: $data');
            var text = new luxe.Text({
                pos: new Vector(20, Luxe.screen.mid.y - 100),
                text: 'Error: $data',
                point_size: 32,
                align: left,
                align_vertical: center,
                color: new Color(0.6, 0.6, 0.6, 0.0),
                depth: 101
            });
        }
        http.onStatus = function(data) {
            trace('status: $data');
        }
        http.onData = function(data) {
            trace('data: $data');
            var scores :Array<{ score :Int, name :String }> = [];
            try {
                scores = haxe.Json.parse(data);
            } catch (e :Dynamic) {
                trace('Error parsing data: $e');
            }

            scores.sort(function(a, b) { return b.score - a.score; });

            var count = 0;
            for (score in scores) {
                count++;
                var highscore = new HighscoreLine(count, score.score, score.name, count * 50);
                Actuate.tween(highscore, 0.3, { y: count * 50 - 20, alpha: 1.0 }).delay(count / 2);
            }
        }
        http.request();

        var bg = new luxe.Sprite({
            pos: Luxe.screen.mid.clone(),
            size: Luxe.screen.size.clone(),
            color: new Color(1.0, 1.0, 1.0, 0.0),
            depth: 100
        });

        /*
        var scores = [
            { rank: 999, score: 999, name: 'Blah' },
            { rank: 4, score: 234, name: 'Blah' },
            { rank: 5, score: 199, name: 'X' },
            { rank: 6, score: 184, name: 'Anders' },
            { rank: 7, score: 123, name: 'Xblasdlfasf' },
            { rank: 8, score: 32, name: 'Xyz' },
            { rank: 9, score: 8, name: 'asdf' },
            { rank: 10, score: 0, name: 'xx' }
        ];
        var y = 50;
        for (score in scores) {
            var highscore = new HighscoreLine(score.rank, score.score, score.name, y += 50);
            Actuate.tween(highscore, 0.3, { y: y - 20, alpha: 1.0 }).delay(y / 100);
        }
        */

        // var text = new luxe.Text({
        //     pos: new Vector(20, Luxe.screen.mid.y - 100),
        //     text: '4.\t234\tBlaahh\n5.\t199\tXyz\n6.\t${data.score}\tNAME\n7.\t102\tPsfd\n10.\t0\tAsdf',
        //     point_size: 32,
        //     align: left,
        //     align_vertical: center,
        //     color: new Color(0.6, 0.6, 0.6, 0.0),
        //     depth: 101
        // });

        Actuate.tween(bg.color, 1.0, { a: 0.95 }).onComplete(function() {
            // Actuate.tween(text.color, 1.0, { a: 1.0 });
            // Actuate.tween(text.pos, 1.0, { y: Luxe.screen.mid.y });
        });
    }

    override function ondisabled(_) {
        Luxe.scene.empty();
    }

    override function update(dt :Float) {

    }
}
