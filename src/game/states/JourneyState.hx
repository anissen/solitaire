package game.states;

import luxe.Text;
import luxe.States.State;
import luxe.Vector;
import luxe.Color;
import luxe.Sprite;
import game.components.Clickable;
import game.misc.GameMode.GameMode;
import core.utils.Analytics;

class JourneyState extends State {
    static public var StateId :String = 'JourneyState';
    var title :Text;

    public function new() {
        super({ name: StateId });
    }

    override function init() {

    }

    override function onenter(data :Dynamic) {
        title = new Text({
            text: 'Journey',
            pos: new Vector(Settings.WIDTH / 2, 50),
            point_size: 30,
            align: luxe.Text.TextAlign.center,
            align_vertical: luxe.Text.TextAlign.center,
            color: new luxe.Color(1.0, 1.0, 1.0),

            letter_spacing: 0,
            sdf: true,
            shader: Luxe.renderer.shaders.bitmapfont.shader.clone('title-shader'),
            outline: 0.75,
            outline_color: new Color().rgb(0xa55004),
        });

        var back_button = new game.ui.Icon({
            pos: new Vector(30, 30),
            texture_path: 'assets/ui/arrowBeige_left.png',
            on_click: Main.SetState.bind(MenuState.StateId)
        });
        back_button.scale.set_xy(1/4, 1/4);

        // var temple = new Sprite({
        //     texture: Luxe.resources.texture('assets/images/journey/egyptian-temple.png'),
        //     pos: new Vector(Settings.WIDTH / 2, Settings.HEIGHT / 2),
        //     scale: new Vector(0.3, 0.3)
        // });
        // temple.add(new Clickable(function(_) {
        //     Main.SetState(PlayState.StateId, Strive(2));
        // }));

        var rank_button = new game.ui.Icon({
            pos: new Vector(Settings.WIDTH / 2, Settings.HEIGHT / 2),
            texture_path: 'assets/ui/circular_light.png',
            on_click: function() { Main.SetState(PlayState.StateId, Strive(2)); }
        });
        rank_button.scale.set_xy(1/3, 1/3);
        rank_button.color.a = 0.75;

        var rankIcon = new Sprite({
            parent: rank_button,
            pos: Vector.Multiply(rank_button.size, 0.5),
            texture: Luxe.resources.texture('assets/images/journey/egyptian-temple.png'),
            scale: new Vector(0.05 * 5, 0.05 * 5),
            color: new Color(0.75, 0.0, 0.5),
            depth: 10
        });
        luxe.tween.Actuate
            .tween(rankIcon.scale, 4.0, { x: 0.06 * 5, y: 0.06 * 5 })
            .ease(luxe.tween.easing.Linear.easeNone)
            .reflect()
            .repeat();
        
        var rankText = new Text({
            pos: new Vector(115, 190),
            text: 'Rank ' + Luxe.io.string_load('rank'),
            align: TextAlign.left,
            align_vertical: TextAlign.center,
            color: new Color(0.75, 0.0, 0.5),
            point_size: 26
        });
        rankText.color.a = 0.5;

        var journey_level = Luxe.io.string_load('journey_level');
        var journey_tutorial_completed = (Luxe.io.string_load('tutorial_complete_journey') == 'true');
        var journey_mode = Strive(journey_level != null ? Std.parseInt(journey_level) : 1);
        var journey_game_mode = (journey_tutorial_completed ? journey_mode : Tutorial(journey_mode));

        new game.ui.Button({
            pos: new Vector(Settings.WIDTH / 2, Settings.HEIGHT - 40),
            text: journey_game_mode.getName(),
            on_click: function() {
                Main.SetState(PlayState.StateId, journey_game_mode);
            }
        });
    }

    override function onkeyup(event :luxe.Input.KeyEvent) {
        if (event.keycode == luxe.Input.Key.ac_back) {
            Main.SetState(MenuState.StateId);
        }
    }

    override function onleave(_) {
        Luxe.scene.empty();
    }
}
