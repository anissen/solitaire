package game.states;

import luxe.Text;
import luxe.States.State;
import luxe.Vector;
import luxe.Color;
import luxe.Sprite;
import game.misc.GameMode.GameMode;
import core.utils.Analytics;

using game.misc.GameMode.GameModeTools;

typedef CreateIconOptions = {
    goal :Int,
    stars :Int,
    active_level :Bool,
    level_category :Int,
    grayed_out :Bool,
    stars_taken :Bool,
    flag :Bool,
    game_mode :GameMode
};

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
        
        var journey_highest_level_played = Settings.load_int('journey_highest_level_played', 0);
        var journey_highest_level_won = Settings.load_int('journey_highest_level_won', 0);

        // new game.ui.Button({
        //     pos: new Vector(Settings.WIDTH / 2, Settings.HEIGHT - 40),
        //     text: journey_game_mode.getName(),
        //     on_click: function() {
        //         Main.SetState(PlayState.StateId, journey_game_mode);
        //     }
        // });

        var points = [0, 1, 1, 1, 1, 5, 2, 2, 2, 2, 10, 5, 5, 5, 5, 20, 10, 10, 10, 10, 40, 20, 20, 20, 20, 50, 40, 40, 40, 40, 100];
        var major  = [0, 0, 0, 0, 0, 1, 0, 0, 0, 0,  1, 0, 0, 0, 0,  1,  0,  0,  0,  0,  1,  0,  0,  0,  0,  1,  0,  0,  0,  0, 2];

        var max_levels = 30; // 200 points
        var container_height = 0.0;
        var scroll_to = 0.0;
        for (i in 0 ... max_levels) {
            var level = i + 1;
            var level_points = (level < 10) ? level * 10 : 10 * 10 + (level - 10) * 5; // 10 interval to 100, then 5
            var icon = create_icon({
                goal: level_points,
                stars: points[level],
                active_level: (level == journey_level),
                level_category: major[level],
                grayed_out: (level != journey_level && level > journey_highest_level_played),
                stars_taken: (level <= journey_highest_level_won),
                flag: (level == journey_highest_level_played),
                game_mode: journey_game_mode
            });
            var level_pos = max_levels - level;
            icon.pos.y = 100 + level_pos * 125;
            container_height = (icon.pos.y > container_height ? icon.pos.y + 100 : container_height);
            if (level == journey_level) scroll_to = -icon.pos.y + Settings.HEIGHT / 2;
            icon.parent = scroll_container;

            if (i == max_levels - 1) break; // don't show the last path
            var rand = 1 + Std.random(2); // between 1 and 2
            var path = new Sprite({
                parent: scroll_container,
                texture: Luxe.resources.texture('assets/images/journey/path${rand}.png'),
                pos: new Vector(Settings.WIDTH / 2, 100 + (level_pos - 0.5) * 125),
                scale: new Vector((Std.random(2) < 1 ? 0.3 : -0.3), (Std.random(2) < 1 ? 0.3 : -0.3)),
                color: new Color().rgb(0x956416)
            });
            if (level >= journey_level) path.color.a = 0.25;
        }

        var pan = new game.components.DragPan({ name: 'DragPan' });
        var correct_drag_top = #if web 100 #else 40 #end;
        pan.y_top = Settings.HEIGHT - container_height - correct_drag_top;
        pan.y_bottom = 0;
        scroll_container.pos.y = scroll_to; //pan.y_top;
        scroll_container.add(pan);
    }

    function create_icon(options :CreateIconOptions) :luxe.Visual {
        var container = new luxe.Visual({});
        container.color.a = 0;

        var rank_button = new game.ui.Icon({
            pos: new Vector(Settings.WIDTH / 2, 0),
            texture_path: (options.active_level ? 'assets/ui/circular_highlight.png' : 'assets/ui/circular_light.png'),
            on_click: function() {
                Main.SetState(PlayState.StateId, options.game_mode);
            }
        });
        rank_button.parent = container;
        rank_button.scale.set_xy(1/4, 1/4);
        rank_button.disabled = !options.active_level;

        var color = (options.active_level ? new Color(0.75, 0.0, 0.5) : new Color().rgb(0x956416));
        if (options.grayed_out) color.a = 0.2;

        var level_icon = switch (options.level_category) {
            case 1: 'assets/images/journey/egyptian-temple.png';
            case 2: 'assets/ui/holy-grail.png';
            case _: 'assets/images/journey/great-pyramid.png';
        };

        var levelIcon = new Sprite({
            parent: rank_button,
            pos: Vector.Multiply(rank_button.size, 0.5),
            texture: Luxe.resources.texture(level_icon),
            scale: new Vector(0.05 * 5, 0.05 * 5),
            color: color,
            depth: 10
        });
        luxe.tween.Actuate
            .tween(levelIcon.scale, 4.0, { x: 0.06 * 5, y: 0.06 * 5 })
            .ease(luxe.tween.easing.Linear.easeNone)
            .reflect()
            .repeat();

        if (options.flag) {
            var flagIcon = new Sprite({
                parent: container,
                pos: new Vector(Settings.WIDTH / 2 + 5, -30),
                texture: Luxe.resources.texture('assets/images/journey/flying-flag.png'),
                scale: new Vector(0.1, 0.1),
                color: new Color(0.75, 0.0, 0.5),
                depth: 50
            });
            luxe.tween.Actuate
                .tween(flagIcon.scale, 4.0, { x: 0.09, y: 0.09 })
                .ease(luxe.tween.easing.Linear.easeNone)
                .reflect()
                .repeat();
            flagIcon.rotation_z = 7.5;
            luxe.tween.Actuate
                .tween(flagIcon, 2.0, { rotation_z: 12.5 })
                .ease(luxe.tween.easing.Linear.easeNone)
                .reflect()
                .repeat();
        }
        
        var goalText = new Text({
            parent: container,
            pos: new Vector(65, 2),
            text: '${options.goal}',
            align: TextAlign.right,
            align_vertical: TextAlign.center,
            color: color,
            point_size: 22
        });

        var scoreIcon = new Sprite({
            parent: container,
            pos: new Vector(85, 0),
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
            pos: new Vector(Settings.WIDTH - 65, 2),
            text: '${options.stars}',
            align: TextAlign.left,
            align_vertical: TextAlign.center,
            color: color,
            point_size: 22
        });
        if (options.stars_taken) {
            // starsText.color = new Color().rgb(0x956416);
            starsText.color = color.clone();
            starsText.color.a = 0.25;
        }

        var starIcon = new Sprite({
            parent: container,
            pos: new Vector(Settings.WIDTH - 85, 0),
            texture: Luxe.resources.texture('assets/ui/round-star.png'),
            scale: new Vector(0.06, 0.06),
            color: color,
            depth: 10
        });
        if (options.stars_taken) {
            // starIcon.color = new Color().rgb(0x956416);
            starIcon.color = color.clone();
            starIcon.color.a = 0.25;
        }
        if (!options.stars_taken) {
            luxe.tween.Actuate
                .tween(starIcon, 10.0, { rotation_z: 360 })
                .ease(luxe.tween.easing.Linear.easeNone)
                .repeat();
        }

        return container;
    }

    override function onkeyup(event :luxe.Input.KeyEvent) {
        if (event.keycode == luxe.Input.Key.ac_back) {
            Main.SetState(MenuState.StateId);
        } 
        #if debug
        if (event.keycode == luxe.Input.Key.key_r) {
            Luxe.io.string_save('journey_level', null);
            Luxe.io.string_save('journey_highest_level_played', null);
            Luxe.io.string_save('journey_highest_level_won', null);
            Luxe.io.string_save('journey_highscore', null);

            Luxe.io.string_save('save_${Strive(1).get_game_mode_id()}', null); // clear the save
        }
        #end
    }

    override function onleave(_) {
        Luxe.scene.empty();
    }
}
