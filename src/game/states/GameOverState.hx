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

    public function set_y(y :Float) {
        rankText.pos.y = y;
        scoreText.pos.y = y;
        nameText.pos.y = y;
    }

    public function set_alpha(alpha :Float) {
        rankText.color.a = alpha;
        scoreText.color.a = alpha;
        nameText.color.a = alpha;
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

        var bg = new luxe.Sprite({
            pos: Luxe.screen.mid.clone(),
            size: Luxe.screen.size.clone(),
            color: new Color(1.0, 1.0, 1.0, 0.0),
            depth: 100
        });

        var data :{ score :Int /*, bg :phoenix.Texture */ } = cast d;
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
            // Actuate.tween(highscore, 1.0, { y: Luxe.screen.mid.y });
        }

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
