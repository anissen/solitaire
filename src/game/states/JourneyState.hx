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
    var scroll_container :luxe.Visual;
    var rank_button :game.ui.Icon;

    public function new() {
        super({ name: StateId });
    }

    override function init() {
        
    }

    override function onenter(data :Dynamic) {
        var back_button = new game.ui.Icon({
            pos: new Vector(30, 30),
            texture_path: 'assets/ui/arrowBeige_left.png',
            on_click: Main.SetState.bind(MenuState.StateId)
        });
        back_button.scale.set_xy(1/4, 1/4);

        scroll_container = new luxe.Visual({ name: 'scroll_container' });
        scroll_container.color.a = 0;

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

        var journey_level = Settings.load_int('journey_level', 1);
        var journey_tutorial_completed = (Luxe.io.string_load('tutorial_complete_journey') == 'true');
        var journey_mode = Strive(journey_level);
        var journey_game_mode = (journey_tutorial_completed ? journey_mode : Tutorial(journey_mode));

        new game.ui.Button({
            pos: new Vector(Settings.WIDTH / 2, Settings.HEIGHT - 40),
            text: journey_game_mode.getName(),
            on_click: function() {
                Main.SetState(PlayState.StateId, journey_game_mode);
            }
        });

        var points = [0, 1, 1, 1, 1, 5, 2, 2, 2, 2, 10, 5, 5, 5, 5, 20, 10, 10, 10, 10, 40, 20, 20, 20, 20, 50, 40, 40, 40, 40, 100];
        var major  = [0, 0, 0, 0, 0, 1, 0, 0, 0, 0,  1, 0, 0, 0, 0,  1,  0,  0,  0,  0,  1,  0,  0,  0,  0,  1,  0,  0,  0,  0, 1];

        var max_levels = 30; // 200 points
        var container_height = 0.0;
        var scroll_to = 0.0;
        for (i in 0 ... max_levels) {
            var level = i + 1;
            var level_points = (level < 10) ? level * 10 : 10 * 10 + (level - 10) * 5; // 10 interval to 100, then 5
            var icon = create_icon(level_points, points[level], (level == journey_level), major[level] > 0);
            var level_pos = max_levels - level;
            icon.pos.y = 100 + level_pos * 125;
            container_height = (icon.pos.y > container_height ? icon.pos.y : container_height);
            if (level == journey_level) scroll_to = -icon.pos.y + Settings.HEIGHT / 2;
            icon.parent = scroll_container;

            var rand = 1 + Std.random(2); // between 1 and 2
            new Sprite({
                parent: scroll_container,
                texture: Luxe.resources.texture('assets/images/journey/path${rand}.png'),
                pos: new Vector(Settings.WIDTH / 2, 100 + (level_pos - 0.5) * 125),
                scale: new Vector((Std.random(2) < 1 ? 0.3 : -0.3), (Std.random(2) < 1 ? 0.3 : -0.3)),
                color: new Color().rgb(0x956416)
            });
        }

        var pan = new game.components.DragPan({ name: 'DragPan' });
        var correct_drag_top = #if web 100 #else 40 #end;
        pan.y_top = Settings.HEIGHT - container_height - correct_drag_top;
        pan.y_bottom = 0;
        scroll_container.add(pan);

        scroll_container.pos.y = scroll_to; //pan.y_top;
    }

    function create_icon(goal :Int, stars :Int, active_level :Bool, major_level :Bool) :luxe.Visual {
        var container = new luxe.Visual({});
        container.color.a = 0;

        var rank_button = new game.ui.Icon({
            pos: new Vector(Settings.WIDTH / 2, 0),
            texture_path: 'assets/ui/circular_light.png',
            on_click: function() { Main.SetState(PlayState.StateId, Strive(2)); }
        });
        rank_button.parent = container;
        rank_button.scale.set_xy(1/4, 1/4);
        rank_button.color.a = 0.75;
        rank_button.disabled = !active_level;

        var color = (active_level ? new Color(0.75, 0.0, 0.5) : new Color().rgb(0x956416));

        var levelIcon = new Sprite({
            parent: rank_button,
            pos: Vector.Multiply(rank_button.size, 0.5),
            texture: Luxe.resources.texture('assets/images/journey/${major_level ? 'egyptian-temple' : 'great-pyramid'}.png'),
            scale: new Vector(0.05 * 5, 0.05 * 5),
            color: color,
            depth: 10
        });
        luxe.tween.Actuate
            .tween(levelIcon.scale, 4.0, { x: 0.06 * 5, y: 0.06 * 5 })
            .ease(luxe.tween.easing.Linear.easeNone)
            .reflect()
            .repeat();
        
        var goalText = new Text({
            parent: container,
            pos: new Vector(60, 2),
            text: '$goal',
            align: TextAlign.right,
            align_vertical: TextAlign.center,
            color: color,
            point_size: 22
        });
        goalText.color.a = 0.5;

        var scoreIcon = new Sprite({
            parent: container,
            pos: new Vector(80, 0),
            texture: Luxe.resources.texture('assets/ui/diamond.png'),
            scale: new Vector(0.055, 0.055),
            color: color
        });
        luxe.tween.Actuate
            .tween(scoreIcon.scale, 4.0, { x: 0.065, y: 0.065 })
            .ease(luxe.tween.easing.Linear.easeNone)
            .reflect()
            .repeat();

        var starsText = new Text({
            parent: container,
            pos: new Vector(Settings.WIDTH - 80, 2),
            text: '$stars',
            align: TextAlign.right,
            align_vertical: TextAlign.center,
            color: color,
            point_size: 22
        });
        starsText.color.a = 0.5;

        var starIcon = new Sprite({
            parent: container,
            pos: new Vector(Settings.WIDTH - 60, 0),
            texture: Luxe.resources.texture('assets/ui/round-star.png'),
            scale: new Vector(0.06, 0.06),
            color: color, //new Color().rgb(0x956416),
            depth: 10
        });
        luxe.tween.Actuate
            .tween(starIcon, 10.0, { rotation_z: 360 })
            .ease(luxe.tween.easing.Linear.easeNone)
            .repeat();

        return container;
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
