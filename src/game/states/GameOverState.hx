package game.states;

import luxe.Text;
import luxe.States.State;
import luxe.Vector;
import luxe.Sprite;
import luxe.Color;
import luxe.tween.Actuate;

import mint.types.Types;
import mint.render.luxe.LuxeMintRender;
import mint.layout.margins.Margins;
import mint.focus.Focus;

// class HighscoreLine {
//     var rankText :Text;
//     var scoreText :Text;
//     var nameText :Text;
//     public var y(get, set) :Float;
//     public var alpha(get, set) :Float;
//     public var color(get, set) :Color;

//     public function new(rank :String, score :Int, name :String, y :Float) {
//         rankText = new luxe.Text({
//             pos: new Vector(60, y),
//             text: '$rank.',
//             point_size: 24,
//             align: right,
//             align_vertical: center,
//             color: new Color(0.6, 0.6, 0.6, 0.0),
//             depth: 101
//         });
//         scoreText = new luxe.Text({
//             pos: new Vector(115, y),
//             text: '$score',
//             point_size: 24,
//             align: right,
//             align_vertical: center,
//             color: new Color(0.6, 0.6, 0.6, 0.0),
//             depth: 101
//         });
//         nameText = new luxe.Text({
//             pos: new Vector(120, y),
//             text: name,
//             point_size: 24,
//             align: left,
//             align_vertical: center,
//             color: new Color(0.6, 0.6, 0.6, 0.0),
//             depth: 101
//         });
//     }

//     function set_y(y :Float) {
//         rankText.pos.y = y;
//         scoreText.pos.y = y;
//         nameText.pos.y = y;
//         return y;
//     }
    
//     function get_y() {
//         return rankText.pos.y;
//     }

//     function set_alpha(alpha :Float) {
//         rankText.color.a = alpha;
//         scoreText.color.a = alpha;
//         nameText.color.a = alpha;
//         return alpha;
//     }

//     function get_alpha() {
//         return rankText.color.a;
//     }

//     function set_color(color :Color) {
//         rankText.color = color;
//         scoreText.color = color;
//         nameText.color = color;
//         return color;
//     }

//     function get_color() {
//         return rankText.color;
//     }
// }

class HighscoreLine extends luxe.Entity {
    var rankText :Text;
    var scoreText :Text;
    var nameText :Text;
    public var alpha(get, set) :Float;
    // public var color(get, set) :Color;

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

    // function set_color(color :Color) {
    //     rankText.color = color;
    //     scoreText.color = color;
    //     nameText.color = color;
    //     return color;
    // }

    // function get_color() {
    //     return rankText.color;
    // }
}

typedef Highscore = { client :String, score :Int, name :String };

class GameOverState extends State {
    static public var StateId :String = 'GameOverState';

    var canvas: mint.Canvas;
    var rendering: LuxeMintRender;
    var layout: Margins;
    var focus :Focus;

    public function new() {
        super({ name: StateId });
    }

    override function init() {

    }

    override function onenter(data :Dynamic) {
        var bg = new luxe.Sprite({
            pos: Luxe.screen.mid.clone(),
            size: Luxe.screen.size.clone(),
            color: new Color(1.0, 1.0, 1.0, 0.0),
            depth: 100
        });
        Actuate.tween(bg.color, 1.0, { a: 0.95 });

        // Actuate.tween(bg.color, 1.0, { a: 0.95 }).onComplete(function(_) {
        //     var highscores = [ for (i in 0 ... 100) { score: i * 10, name: 'Test $i' } ];
        //     setup_ui(highscores, Std.int(1000 * Math.random())); 
        // });

        // return;

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
            
        var count = 0;
        for (score in highscores) {
            count++;
            var highscore_line = new HighscoreLine('$count', score.score, score.name);
            highscore_line.pos.y = count * 25 + 20;
            highscore_line.alpha = 0;
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
        var pan = new game.components.CameraPan({ name: 'CameraPan' });
        pan.y_top = -50; // ???
        pan.y_bottom = count * 25 - Settings.HEIGHT + 50;
        Luxe.camera.add(pan);
    }

    function setup_ui(highscores :Array<{ score :Int, name :String }>, my_score :Int) {
        var ui_batcher = Luxe.renderer.create_batcher({ name: 'gui', layer: 5 });
        rendering = new LuxeMintRender({
            depth: 1000,
            batcher: ui_batcher
        });
        layout = new Margins();

        var _scale = Luxe.screen.device_pixel_ratio;
        // ui_batcher.view.zoom = _scale;
        var auto_canvas = new game.ui.AutoCanvas({
            name: 'canvas',
            rendering: rendering,
            // options: { color: new Color(1,1,1,0.5) },
            scale: _scale,
            // x: 0,
            // y: 0,
            w: Luxe.screen.w / _scale,
            h: Luxe.screen.h / _scale
        });

        auto_canvas.auto_listen();
        canvas = auto_canvas;
        focus = new Focus(canvas);

        // var panel = new mint.Panel({
        //     parent: canvas,
        //     // x: (Settings.WIDTH / _scale) / 2 - 150,
        //     // y: (Settings.HEIGHT / _scale) / 2 - 200,
        //     // w: 300,
        //     // h: 400,
        //     x: 20,
        //     y: 20,
        //     w: Settings.WIDTH - 40,
        //     h: Settings.HEIGHT - 40
        //     // options: { color: new Color(0.5,0.5,0,0.8) },
        // });

        var _list = new mint.List({
            parent: canvas,
            name: 'list',
            options: { 
                // color: new Color(0.5,0.0,5,0.8), // no effect?
                view: {  // scroll view
                    color: new Color(1.0, 1.0, 1.0, 0.0),
                    color_handles:new Color().rgb(0x000000)
                } 
            },
            x: 20,
            y: 20 + 90,
            w: Settings.WIDTH - 40,
            h: Settings.HEIGHT - 40 - 90 - 90
        });

        var rank_count = 0;
        for (s in highscores) {
            rank_count++;
            var row_panel = new mint.Panel({
                parent: _list,
                name: 'panel$rank_count',
                x: 0,
                y: 0,
                w: Settings.WIDTH - 40,
                h: 30,
                options: { color: new Color(1.0,1.0,1.0,0.0) }
            });

            var rank = new mint.Label({
                parent: row_panel,
                x: 0,
                y: 0,
                w: 60,
                h: 30,
                align: TextAlign.right,
                align_vertical: TextAlign.top,
                name: 'rank$rank_count',
                text: '$rank_count.',
                text_size: 24,
                options: {
                    color: new Color().rgb(0x333333),
                }
            });
            // rank.mouse_input = false;
            // _list.add_item(rank, 0, 0);

            var score = new mint.Label({
                parent: row_panel,
                x: 75,
                y: 0,
                w: 50,
                h: 30,
                align: TextAlign.right,
                align_vertical: TextAlign.top,
                name: 'score$rank_count',
                text: '${s.score}',
                text_size: 24,
                options: {
                    color: new Color().rgb(0x333333)
                }
            });
            // score.mouse_input = false;
            // _list.add_item(score, 50, -30);

            var name = new mint.Label({
                parent: row_panel,
                x: 140,
                y: 0,
                w: 100,
                h: 30,
                align: TextAlign.left,
                align_vertical: TextAlign.top,
                name: 'name$rank_count',
                text: s.name,
                text_size: 24,
                options: {
                    color: new Color().rgb(0x333333),
                    // color_hover: new Color().rgb(0xf6007b)
                },
                // onclick: function(_,_) { trace('hello label$i'); }
            });
            // name.mouse_input = false;

            _list.add_item(row_panel);
        }
        _list.view.set_scroll_percent(0 /* horizontal */, 0.5 /* vertical */);

        var header = new mint.Label({
            parent: canvas,
            x: 0,
            y: 25,
            w: Settings.WIDTH,
            h: 40,
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            name: 'header',
            text: 'Highscores',
            text_size: 32,
            options: {
                color: new Color().rgb(0x333333),
                // color_hover: new Color().rgb(0xf6007b)
            },
            // onclick: function(_,_) { trace('hello label$i'); }
        });

        var buttonWidth = 120;
        var buttonHeight = 40;
        new mint.Button({
            parent: canvas,
            x: Settings.WIDTH / 2 - buttonWidth / 2,
            y: Settings.HEIGHT - 40 - (100 - buttonHeight) / 2,
            w: buttonWidth,
            h: buttonHeight,
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            name: 'button',
            text: 'Back',
            text_size: 24,
            options: {
                color: new Color().rgb(0x333333),
                color_hover: new Color().rgb(0xf6007b)
            },
            onclick: function(_,_) { Main.NewGame(); }
        });
    }

    override function onleave(_) {
        canvas.destroy();
        Luxe.camera.remove('CameraPan');
        Luxe.scene.empty();
    }

    override function onmouseup(event :luxe.Input.MouseEvent) {
        if (event.button == luxe.Input.MouseButton.right) {
            Main.NewGame();
        }
    }
}
