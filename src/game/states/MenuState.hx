package game.states;

import luxe.Text;
import luxe.States.State;
import luxe.Vector;
import luxe.Color;
import luxe.tween.Actuate;

import game.ui.Button;

using game.misc.GameMode.GameModeTools;

class MenuState extends State {
    static public var StateId :String = 'MenuState';
    var title :Text;
    var counting_total_score :Float;
    var tutorial_box :game.entities.TutorialBox;

    public function new() {
        super({ name: StateId });
    }

    override function init() {

    }

    override function onenter(data :Dynamic) {
        var icon = new luxe.Sprite({
            pos: new Vector(Settings.WIDTH / 2 - 20, 80),
            texture: Luxe.resources.texture('assets/ui/pyramids.png'),
            scale: new Vector(0.5, 0.5)
        });

        title = new Text({
            text: 'Stoneset',
            pos: new Vector(Settings.WIDTH / 2, 80),
            point_size: 42,
            align: luxe.Text.TextAlign.center,
            align_vertical: luxe.Text.TextAlign.center,
            color: new luxe.Color(1.0, 1.0, 1.0),

            letter_spacing: 0,
            sdf: true,
            shader: Luxe.renderer.shaders.bitmapfont.shader.clone('title-shader'),
            outline: 0.75,
            outline_color: new Color().rgb(0xa55004),
        });
        luxe.tween.Actuate.tween(title, 3.0, { outline: 0.65, letter_spacing: -1.5 }).reflect().repeat();

        var config_button = new game.ui.Icon({
            pos: new Vector(35, 35),
            texture_path: 'assets/ui/circular.png',
            on_click: Main.SetState.bind(SettingsState.StateId)
        });
        config_button.scale.set_xy(1/5, 1/5);
        config_button.color.a = 0.75;
        new luxe.Sprite({
            texture: Luxe.resources.texture('assets/ui/cog.png'),
            parent: config_button,
            pos: new Vector(128, 128),
            scale: new Vector(0.5, 0.5),
            color: new Color().rgb(0x8C7D56),
            depth: 110
        });

        var about_button = new game.ui.Icon({
            pos: new Vector(Settings.WIDTH - 35, 35),
            texture_path: 'assets/ui/circular.png',
            on_click: Main.SetState.bind(CreditsState.StateId)
        });
        about_button.scale.set_xy(1/5, 1/5);
        about_button.color.a = 0.75;
        new luxe.Sprite({
            texture: Luxe.resources.texture('assets/ui/book.png'),
            parent: about_button,
            pos: new Vector(128, 128),
            scale: new Vector(0.5, 0.5),
            color: new Color().rgb(0x8C7D56),
            depth: 110
        });

        /*
        var star = new luxe.Sprite({
            pos: new Vector(55, 190),
            texture: Luxe.resources.texture('assets/images/symbols/star.png'),
            scale: new Vector(0.15, 0.15),
            color: new Color().rgb(0xFFFFFF),
            depth: 10
        });
        luxe.tween.Actuate
            .tween(star, 10.0, { rotation_z: 360 })
            .ease(luxe.tween.easing.Linear.easeNone)
            .repeat(); // spin faster when gaining points?

        new Text({
            pos: new Vector(90, 190),
            text: 'Rank 3/853',
            align: TextAlign.left,
            align_vertical: TextAlign.center,
            color: new Color().rgb(0x956416),
            point_size: 26
        });
        */

        var normal_save = Luxe.io.string_load('save_normal');

        var button_height = 60;
        var button_count = 0;
        function get_button_y() {
            return 250 + (button_count++) * button_height;
        }
        var tutorial_completed = (Luxe.io.string_load('tutorial_complete') == 'true');
        var normal_game_mode = (tutorial_completed ? game.misc.GameMode.Normal : game.misc.GameMode.Tutorial(game.misc.GameMode.Normal));
        var play_button = new Button({
            pos: new Vector(Settings.WIDTH / 2, get_button_y()),
            text: (normal_save == null ? 'Normal' : '~ Normal ~'),
            on_click: Main.SetState.bind(PlayState.StateId, normal_game_mode)
        });

        // var play_stats = new game.ui.Icon({
        //     pos: new Vector(play_button.pos.x + play_button.width - 30, play_button.pos.y + 22),
        //     texture_path: 'assets/ui/stars.png',
        //     on_click: function() { trace('stats button'); }
        // });
        // play_stats.scale.set_xy(1/7, 1/7);
        // play_stats.depth = 200;

        var old_total_score = Settings.load_int('menu_last_total_score', 0);
        var total_score = Settings.load_int('total_score', 0);
        Luxe.io.string_save('menu_last_total_score', '$total_score');

        var strive_save = Luxe.io.string_load('save_strive');
        var strive_level = Luxe.io.string_load('strive_level');
        var strive_tutorial_completed = (Luxe.io.string_load('tutorial_complete_strive') == 'true');
        var strive_mode = game.misc.GameMode.Strive(strive_level != null ? Std.parseInt(strive_level) : 1);
        var strive_game_mode = (strive_tutorial_completed ? strive_mode : game.misc.GameMode.Tutorial(strive_mode));
        var strive_text = (strive_save == null ? '' : '~ ') + (strive_level != null ? 'Strive for ${strive_mode.get_strive_score()}' : 'Strive') +(strive_save == null ? '' : ' ~');
        var strive_unlock = 1000;
        var strive_button = new Button({
            pos: new Vector(Settings.WIDTH / 2, get_button_y()),
            text: (total_score < strive_unlock ? 'Unlock: ${strive_unlock - total_score}' : strive_text),
            on_click: Main.SetState.bind(PlayState.StateId, strive_game_mode),
            disabled: (total_score < strive_unlock)
        });

        var timed_unlock = 2000;
        var timed_tutorial_completed = false; //(Luxe.io.string_load('tutorial_complete_timed') == 'true');
        var timed_game_mode = (timed_tutorial_completed ? game.misc.GameMode.Timed : game.misc.GameMode.Tutorial(game.misc.GameMode.Timed));
        var timed_button = new Button({
            pos: new Vector(Settings.WIDTH / 2, get_button_y()),
            text: (total_score < timed_unlock ? 'Unlock: ${timed_unlock - total_score}' : 'Survival'),
            on_click: Main.SetState.bind(PlayState.StateId, timed_game_mode),
            disabled: (total_score < timed_unlock)
        });

        // trace('Old total score: $old_total_score, new total score: $total_score');
        
        counting_total_score = old_total_score;
        var count_down_duration = luxe.utils.Maths.clamp((total_score - old_total_score) / 50, 1.0, 3.0);
        if (total_score > old_total_score) {
            if (!strive_button.enabled) strive_button.color_burst(count_down_duration);
            if (!timed_button.enabled) timed_button.color_burst(count_down_duration);
        }
        Actuate.tween(this, count_down_duration, { counting_total_score: total_score }, true).onUpdate(function () {
            // if (counting_total_score - old_total_score % 10 == 0) {
            //     Luxe.audio.play(Luxe.resources.audio(Settings.get_sound_file_path('points_big').source);
            // }
            strive_button.text = (counting_total_score < strive_unlock ? 'Unlock: ${Std.int(strive_unlock - counting_total_score)}' : strive_text);
            var was_enabled = strive_button.enabled;
            strive_button.enabled = tutorial_completed && (counting_total_score >= strive_unlock);
            if (!was_enabled && strive_button.enabled) {
                Luxe.audio.play(Luxe.resources.audio(Settings.get_sound_file_path('points_devine')).source);
                Luxe.audio.play(Luxe.resources.audio(Settings.get_sound_file_path('ui_click')).source);
            }

            timed_button.text = (counting_total_score < timed_unlock ? 'Unlock: ${Std.int(timed_unlock - counting_total_score)}' : 'Survival');
            was_enabled = timed_button.enabled;
            timed_button.enabled = tutorial_completed && (counting_total_score >= timed_unlock);
            if (!was_enabled && timed_button.enabled) {
                Luxe.audio.play(Luxe.resources.audio(Settings.get_sound_file_path('points_devine')).source);
                Luxe.audio.play(Luxe.resources.audio(Settings.get_sound_file_path('ui_click')).source);
            }
        }).delay(0.1);
        
        

        // var puzzle_unlock = 3000;
        // var puzzle_button = new Button({
        //     pos: new Vector(Settings.WIDTH / 2, get_button_y()),
        //     text: (total_score < puzzle_unlock ? 'Unlock: ${puzzle_unlock - total_score}' : 'Puzzle'),
        //     on_click: Main.SetState.bind(PlayState.StateId, game.misc.GameMode.Puzzle),
        //     disabled: (total_score < puzzle_unlock)
        // });

        var showTutorial = (Luxe.io.string_load('tutorial_menu_complete') == null);
        if (showTutorial) {
            tutorial_box = new game.entities.TutorialBox({ depth: 200 });
            play_button.enabled = false;
            strive_button.enabled = false;
            timed_button.enabled = false;

            function complete_tutorial() {
                Luxe.io.string_save('tutorial_menu_complete', 'true');
                Luxe.timer.schedule(2.5, function() { // to avoid accidentally clicking on "Play"
                    play_button.enabled = true;
                    strive_button.enabled = true;
                    timed_button.enabled = true;
                });
            }

            tutorial_box
            .tutorial({ texts: ['This is the normal\n{brown}Play{default} mode.', 'Here you compete for\nthe highscore.'], pos_y: play_button.get_top_pos().y - 85, points: [play_button.get_top_pos()] })
            .then(tutorial_box.tutorial({ texts: ['Secret unlockable\ngame modes.', 'Earn points to unlock.'], pos_y: strive_button.get_center_pos().y - 80, points: [Vector.Add(strive_button.get_center_pos(), new Vector(-35, 0)), Vector.Add(timed_button.get_top_pos(), new Vector(35, 0))] }))
            // .then(tutorial_box.tutorial({ texts: ['Secret unlockable\ngame mode #1.'], pos_y: strive_button.get_top_pos().y - 85, points: [strive_button.get_top_pos()] }))
            // .then(tutorial_box.tutorial({ texts: ['Secret unlockable\ngame mode #2.', 'Earn points to unlock.'], pos_y: timed_button.get_top_pos().y - 85, points: [timed_button.get_top_pos()] }))
            .then(tutorial_box.tutorial({ texts: ['Settings menu is here.'], pos_y: config_button.pos.y + 85 + 15, points: [Vector.Add(config_button.pos, new Vector(0, 15))] }))
            .then(tutorial_box.tutorial({ texts: ['About {brown}Stoneset{default}.', 'Go here to {brown}donate{default}\ntowards the game.'], pos_y: about_button.pos.y + 85 + 15, points: [Vector.Add(about_button.pos, new Vector(0, 15))], do_func: complete_tutorial }));
        }
    }

    override function onleave(_) {
        Luxe.scene.empty();
    }

    #if sys
    override function onkeyup(event :luxe.Input.KeyEvent) {
        if (event.keycode == luxe.Input.Key.escape) {
            Luxe.shutdown();
        }
    }
    // #else
    // override function onkeyup(event :luxe.Input.KeyEvent) {
    //     if (event.keycode == luxe.Input.Key.key_p) {
    //         trace('plus');
    //         title.outline += 0.1;
    //     } else if (event.keycode == luxe.Input.Key.key_m) {
    //         trace('minus');
    //         title.outline -= 0.1;
    //     }
    //     trace('outline: ${title.outline}');
    // }
    #end
}
