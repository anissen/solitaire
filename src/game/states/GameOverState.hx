package game.states;

import luxe.Text;
import luxe.States.State;
import luxe.Vector;
import luxe.Color;
import luxe.tween.Actuate;

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
            text: '$rank.',
            point_size: 24,
            align: right,
            align_vertical: center,
            color: new Color(0.8, 0.8, 0.8, 0.0),
            depth: 101
        });
        scoreText = new luxe.Text({
            parent: this,
            pos: new Vector(115, 0),
            text: '$score',
            point_size: 24,
            align: right,
            align_vertical: center,
            color: new Color(0.6, 0.6, 0.6, 0.0),
            depth: 101
        });
        nameText = new luxe.Text({
            parent: this,
            pos: new Vector(120, 0),
            text: name,
            point_size: 24,
            align: left,
            align_vertical: center,
            color: new Color(0.6, 0.6, 0.6, 0.0),
            depth: 101
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

    override function onenter(data :Dynamic) {
        // var bg = new luxe.Sprite({
        //     pos: Luxe.screen.mid.clone(),
        //     size: Luxe.screen.size.clone(),
        //     color: new Color(1.0, 1.0, 1.0, 0.0),
        //     depth: 100
        // });
        // Actuate.tween(bg.color, 1.0, { a: 0.95 });

        var highscore :Highscore = cast data;

        var http = new haxe.Http("http://localhost:1337/highscore");
        http.addParameter('client', highscore.client);
        http.addParameter('name', highscore.name);
        http.addParameter('score', '${highscore.score}');
        http.onError = function(data) {
            trace('error: $data');

            // new HighscoreLine('?', highscore.score, highscore.name, 320 /* TODO: Don't hardcode */);
            // TODO: Show not-connected icon

            var highscores = [ for (i in 0 ... 50) { score: i * 10, name: 'Test $i' } ];
            show_highscores(highscores);
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

            show_highscores(scores);
        }
        http.request();

        var back_button = new game.ui.Button({
            pos: new Vector(Settings.WIDTH * (1/4), Settings.HEIGHT - 50),
            width: 100,
            text: 'Back',
            on_click: Main.SetState.bind(MenuState.StateId)
        });

        var play_button = new game.ui.Button({
            pos: new Vector(Settings.WIDTH * (3/4), Settings.HEIGHT - 50),
            width: 100,
            text: 'Play',
            on_click: Main.SetState.bind(PlayState.StateId)
        });

        // Actuate.tween(bg.color, 1.0, { a: 0.95 }).onComplete(function() {
        //     var my_highscore_line = new HighscoreLine('$my_highscore_rank', highscore.score, highscore.name, highscores_count * 50 + 620);
        //     Actuate.tween(my_highscore_line, 0.3, { alpha: 1 }).onComplete(function() {
        //         Actuate.tween(my_highscore_line, 5.0, { y: my_highscore_rank * 50 - 20 }).onUpdate(function() {
        //             Luxe.camera.transform.pos.y = my_highscore_line.y;
        //         });
        //     });
        // });
    }

    function show_highscores(highscores :Array<{ score :Int, name :String }>) {
        highscores.sort(function(a, b) { return b.score - a.score; });

        var score_container = new luxe.Visual({});
        score_container.color.a = 0;
        // score_container.clip_rect = new luxe.Rectangle(0, 50, Settings.WIDTH / 2, Settings.HEIGHT / 2 - 50);
        
        var count = 0;
        for (score in highscores) {
            count++;
            var highscore_line = new HighscoreLine('$count', score.score, score.name);
            highscore_line.pos.y = count * 25 + 20;
            highscore_line.alpha = 0;
            highscore_line.parent = score_container;

            Actuate.tween(highscore_line, 0.3, { alpha: 1.0 }).delay(1.0 + count * 0.1);
            // Actuate.tween(highscore_line.color, 0.3, { y: count * 25 }).delay(1.0);
            // if (score.client == highscore.client) {
            //     highscore_line.color = new Color(0.4, 0.4, 0.4, 0.0);
            //     Actuate.tween(Luxe.camera.view.center, 2.0, { y: count * 50 }, true).onUpdate( function() {
            //         Luxe.camera.transform.pos.set_xy(Luxe.camera.view.pos.x, Luxe.camera.view.pos.y); // TODO: Clamp to pan viewport
            //     });
            // }
        }
        // Luxe.camera.transform.pos.y = count * 50;
        var pan = new game.components.DragPan({ name: 'DragPan' });
        pan.y_top = Settings.HEIGHT - (count * 25 + 50);
        pan.y_bottom = 0;
        score_container.add(pan);
        // Luxe.camera.add(pan);
    }

    override function onleave(_) {
        Luxe.camera.remove('CameraPan');
        Luxe.scene.empty();
    }

    override function onmouseup(event :luxe.Input.MouseEvent) {
        if (event.button == luxe.Input.MouseButton.right) {
            Main.SetState(PlayState.StateId);
        }
    }
}
