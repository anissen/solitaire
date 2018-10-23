package game.states;

import luxe.Text;
import luxe.States.State;
import luxe.Sprite;
import luxe.Vector;
import luxe.Color;
import luxe.tween.Actuate;
import game.misc.GameMode;
import game.ui.Button;
import core.utils.AsyncHttpUtils;
import core.utils.AsyncHttpUtils.HttpCallback;

import sparkler.ParticleSystem;
import sparkler.ParticleEmitter;
import sparkler.modules.*;

using game.misc.GameMode.GameModeTools;

class MenuState extends State {
    static public var StateId :String = 'MenuState';
    var title :Text;
    var rankText :Text;
    var winsIcon :Sprite;
    var winsText :Text;
    var counting_total_score :Float;
    var tutorial_box :game.entities.TutorialBox;

    var ps :ParticleSystem; 
    var pe_burst :ParticleEmitter;
    var pe_burst_color_life_module :ColorLifeModule;

    public function new() {
        super({ name: StateId });
    }

    override function init() {
        
    }

    override function onenter(data :Dynamic) {
        ps = new ParticleSystem();
        pe_burst_color_life_module = new ColorLifeModule({
            initial_color : new sparkler.data.Color(1,0,1,1),
            end_color : new sparkler.data.Color(0,0,1,1),
            end_color_max : new sparkler.data.Color(1,0,0,1)
        });
        pe_burst = new ParticleEmitter({
			name: 'tile_particle_emitter', 
			rate: 128,
			cache_size: 64,
			cache_wrap: true,
			duration: 0.15,
            lifetime: 0.15,
            lifetime_max: 0.3,
			modules: [
				new AreaSpawnModule({
                    size: new sparkler.data.Vector(120, 25),
                    // inside: false
                }),
                pe_burst_color_life_module,
				new SizeLifeModule({
					initial_size: new sparkler.data.Vector(10,10),
					end_size: new sparkler.data.Vector(5,5)
				}),
				new DirectionModule({
					direction: 0,
					direction_variance: 360,
                    speed: 100
				}),
                new RotationModule({
                    initial_rotation: Math.random() * 2 * Math.PI
                })
			]
		});
        pe_burst.stop();
		ps.add(pe_burst);

        var icon = new Sprite({
            pos: new Vector(Settings.WIDTH / 2 - 20, 80),
            texture: Luxe.resources.texture('assets/ui/pyramids.png'),
            scale: new Vector(0.5, 0.5)
        });

        title = new Text({
            text: 'Stoneset',
            pos: new Vector(Settings.WIDTH / 2, 100),
            point_size: 42,
            align: luxe.Text.TextAlign.center,
            align_vertical: luxe.Text.TextAlign.center,
            color: new luxe.Color(1.0, 1.0, 1.0),

            letter_spacing: 0,
            sdf: true,
            shader: Luxe.renderer.shaders.bitmapfont.shader.clone('title-shader'),
            outline: 0.75,
            outline_color: new Color().rgb(0xa55004)
        });
        luxe.tween.Actuate.tween(title, 3.0, { outline: 0.65, letter_spacing: -1.25 }).reflect().repeat();

        var config_button = new game.ui.Icon({
            pos: new Vector(35, 35),
            texture_path: 'assets/ui/circular.png',
            on_click: Main.SetState.bind(SettingsState.StateId)
        });
        config_button.scale.set_xy(1/5, 1/5);
        config_button.color.a = 0.75;
        new Sprite({
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
        new Sprite({
            texture: Luxe.resources.texture('assets/ui/book.png'),
            parent: about_button,
            pos: new Vector(128, 128),
            scale: new Vector(0.5, 0.5),
            color: new Color().rgb(0x8C7D56),
            depth: 110
        });

        var rank_button = new game.ui.Icon({
            pos: new Vector(87, 185),
            texture_path: 'assets/ui/circular_light.png',
            on_click: Main.SetState.bind(GameOverState.StateId, { 
                user_id: Luxe.io.string_load('clientId'),
                seed: 0,
                score: 0,
                game_mode: Normal,
                next_game_mode: Normal,
                actions_data: [],
                highscore_mode: GameOverState.HighscoreMode.Rank
            })
        });
        rank_button.scale.set_xy(1/5, 1/5);
        rank_button.color.a = 0.75;

        var rankIcon = new Sprite({
            parent: rank_button,
            pos: Vector.Multiply(rank_button.size, 0.5),
            texture: Luxe.resources.texture('assets/ui/holy-grail.png'),
            scale: new Vector(0.05 * 5, 0.05 * 5),
            color: new Color(0.75, 0.0, 0.5),
            depth: 10
        });
        luxe.tween.Actuate
            .tween(rankIcon.scale, 4.0, { x: 0.06 * 5, y: 0.06 * 5 })
            .ease(luxe.tween.easing.Linear.easeNone)
            .reflect()
            .repeat();
        
        rankText = new Text({
            pos: new Vector(115, 190),
            text: 'Rank ' + Luxe.io.string_load('rank'),
            align: TextAlign.left,
            align_vertical: TextAlign.center,
            color: new Color(0.75, 0.0, 0.5),
            point_size: 26
        });
        rankText.color.a = 0.5;

        winsIcon = new Sprite({
            pos: new Vector(87, 227),
            texture: Luxe.resources.texture('assets/ui/round-star.png'),
            scale: new Vector(0.06, 0.06),
            color: new Color().rgb(0x956416),
            depth: 10
        });
        luxe.tween.Actuate
            .tween(winsIcon, 10.0, { rotation_z: 360 })
            .ease(luxe.tween.easing.Linear.easeNone)
            .repeat();

        winsText = new Text({
            pos: new Vector(115, 230),
            text: Luxe.io.string_load('wins'),
            align: TextAlign.left,
            align_vertical: TextAlign.center,
            color: new Color().rgb(0x956416),
            point_size: 26
        });
        winsText.color.a = 0.5;

        get_rank();

        var normal_save = Luxe.io.string_load('save_normal');

        var button_height = 60;
        var button_count = 0;
        function get_button_y() {
            return 285 + (button_count++) * button_height;
        }
        var tutorial_completed = (Luxe.io.string_load('tutorial_complete') == 'true');
        var normal_game_mode = (tutorial_completed ? Normal : Tutorial(Normal));
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
        var strive_mode = Strive(strive_level != null ? Std.parseInt(strive_level) : 1);
        var strive_game_mode = (strive_tutorial_completed ? strive_mode : Tutorial(strive_mode));
        var strive_text = (strive_save == null ? '' : '~ ') + (strive_level != null ? 'Strive for ${strive_mode.get_strive_score()}' : 'Strive') +(strive_save == null ? '' : ' ~');
        var strive_unlock = 1000;
        var strive_button = new Button({
            pos: new Vector(Settings.WIDTH / 2, get_button_y()),
            text: (total_score < strive_unlock ? 'Unlock: ${strive_unlock - total_score}' : strive_text),
            on_click: Main.SetState.bind(PlayState.StateId, strive_game_mode),
            disabled: (total_score < strive_unlock)
        });

        var timed_unlock = 2000;
        var timed_tutorial_completed = (Luxe.io.string_load('tutorial_complete_timed') == 'true');
        var timed_game_mode = (timed_tutorial_completed ? Timed : Tutorial(Timed));
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
        //     on_click: Main.SetState.bind(PlayState.StateId, Puzzle),
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
                    strive_button.enabled = tutorial_completed && (counting_total_score >= strive_unlock);
                    timed_button.enabled = tutorial_completed && (counting_total_score >= timed_unlock);
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

        var link = new Text({
            pos: new Vector(Settings.WIDTH / 2, get_button_y() - 10),
            text: 'Beta Feedback',
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            color: new Color(0.75, 0.0, 0.5),
            point_size: 26
        });
        new Sprite({
            parent: link,
            size: new Vector(link.text_bounds.w, link.text_bounds.h),
            color: new Color(1.0, 0.0, 0.0, 0.0)
        }).add(new game.components.MouseUp(function(s) {
            var url_open_func = #if android Main.SnowActivity.url_open #else Luxe.io.url_open #end ;
            url_open_func('mailto:andnis+stoneset@gmail.com');
        }));

        plays_for_game_mode(Normal, play_button);
        if (tutorial_completed && (total_score >= timed_unlock)) plays_for_game_mode(Timed, timed_button);

        #if debug
        new Text({
            pos: new Vector(Settings.WIDTH / 2, 20),
            text: 'Debug',
            align: luxe.Text.TextAlign.center,
            color: new Color(0.0, 0.0, 1.0)
        });
        #end
    }

    function plays_for_game_mode(game_mode :GameMode, button :Button) {
        var url = Settings.SERVER_URL + 'plays/${next_game_seed(game_mode)}';
        AsyncHttpUtils.get(url, function(data :HttpCallback) {
            if (Main.GetStateId() != MenuState.StateId) return;

            if (data.error != null) return;

            var json = data.json;
            var plays :Int = json.plays;
            if (plays <= 0) return;
            
            var starIcon = new Sprite({
                parent: button,
                pos: new Vector(176, 22),
                texture: Luxe.resources.texture('assets/ui/round-star.png'),
                scale: new Vector(0.06, 0.06),
                color: new Color().rgb(0xFFFFFF), // .rgb(0x956416)
                depth: 150
            });

            var playsText = new Text({
                parent: button,
                pos: new Vector(176, 26),
                text: (plays <= 99 ? '$plays' : '+'),
                align: TextAlign.center,
                align_vertical: TextAlign.center,
                color: new Color().rgb(0x956416),
                point_size: 18,
                depth: 151
            });

            starIcon.scale.set_xy(0.0, 0.0);
            playsText.scale.set_xy(0.0, 0.0);
            Actuate.tween(starIcon.scale, 0.3, { x: 0.06, y: 0.06 });
            Actuate.tween(playsText.scale, 0.3, { x: 1, y: 1 }).delay(0.1);
        });
    }

    function next_game_seed(game_mode :GameMode) {
        var plays_today = Luxe.io.string_load(game_mode.get_non_tutorial_game_mode_id() + '_plays_today');
        if (plays_today == null) plays_today = '0';

        var now = Date.now();
        var seed_string = '' + (game_mode.get_non_tutorial_game_mode_index() + 1 /* to avoid zero */) + plays_today + 0 + now.getDate() + now.getMonth() + (now.getFullYear() - 2000);
        return Std.parseInt(seed_string);
    }

    function get_rank() {
        var clientId = Luxe.io.string_load('clientId');
        if (clientId == null) {
            rankText.text = 'Rank ???';
            winsText.text = '???';
            return;
        }

        var old_rank_str = Luxe.io.string_load('rank');
        var old_wins_str = Luxe.io.string_load('wins');

        var url = Settings.SERVER_URL + 'rank/$clientId';
        AsyncHttpUtils.get(url, function(data :HttpCallback) {
            if (Main.GetStateId() != MenuState.StateId) return;

            if (data.error == null) {
                var json = data.json;
                var rank :Int = json.rank + 1;
                var wins :Int = json.wins;
                var players :Int = json.players;

                Luxe.io.string_save('rank', '$rank');
                Luxe.io.string_save('wins', '$wins');

                var old_rank = (old_rank_str != null ? Std.parseInt(old_rank_str) : players);
                var old_wins = (old_wins_str != null ? Std.parseInt(old_wins_str) : 0);

                update_global_stats(old_wins, wins, old_rank, rank);
            } else {
                rankText.text = 'Rank N/A';
                winsText.text = 'N/A';
            }
        });
    }
    
    function update_global_stats(old_wins :Int, wins :Int, old_rank :Int, rank :Int) {
        // trace('update_global_stats:: old_wins: $old_wins, wins: $wins, old_rank: $old_rank, rank: $rank');
        // if (wins != old_wins) {
        //     trace('wins_changed! old_wins: $old_wins, wins: $wins');
        // }
        // if (rank != old_rank) {
        //     trace('rank_changed! old_rank: $old_rank, rank: $rank');
        // }

        var max_particles = ((wins - old_wins) <= 10 ? (wins - old_wins) : 10);

        for (w in 0 ... max_particles) {
            create_particle(w * 0.35, w, Math.ceil(old_wins + (w + 1) * (wins - old_wins) / max_particles));
        }

        if (rank != old_rank) {
            var delay = (wins > old_wins ? (max_particles * 0.35 + 0.5) : 0.0);
            Actuate.timer(delay).onComplete(function() {
                pe_burst.position.x = Settings.WIDTH / 2;
                pe_burst.position.y = rankText.pos.y;

                pe_burst_color_life_module.initial_color.from_json(rank < old_rank ? new sparkler.data.Color(1, 0, 1) : new sparkler.data.Color(0, 0, 0));
                pe_burst_color_life_module.end_color.from_json(new sparkler.data.Color(1, 1, 1, 1));
                pe_burst.duration = 0.5;

                pe_burst.start();

                if (rank <= 0) { // player has no data yet
                    rankText.text = 'Rank';
                } else {
                    rankText.text = 'Rank $rank';
                }
            });
        }

        winsText.color.a = 1.0;
        rankText.color.a = 1.0;
    }

    function create_particle(delay :Float, particleCount :Int, wins :Int) {
        var duration = 0.5;
        var size = 48;

        var random_positions = [
            new Vector(-size / 2, Std.random(Settings.HEIGHT)), // left side
            new Vector(Std.random(Settings.WIDTH), -size / 2), // top side
            new Vector(Settings.WIDTH + size / 2, Std.random(Settings.HEIGHT)), // right side
            new Vector(Std.random(Settings.WIDTH), Settings.HEIGHT + size / 2), // bottom side
        ];

        var p = new game.entities.Particle({
            pos: random_positions.random(),
            texture: Luxe.resources.texture('assets/ui/round-star.png'),
            size: new Vector(size, size),
            color: new Color().rgb(0x956416),
            depth: 100,
            rotation_z: Math.random() * 2 * Math.PI,

            target: winsIcon.pos,
            duration: duration,
            delay: delay
        });

        var trail = new game.components.TrailRenderer();
        trail.trailColor.fromColor(p.color);
        trail.trailColor.a = 0.7;
        trail.startSize = 6;
        trail.maxLength = 75;
        trail.depth = p.depth - 0.1;
        p.add(trail);

        Actuate.tween(p.size, duration, { x: size * 0.5, y: size * 0.5 }).delay(delay).onComplete(function() {
            if (p != null && !p.destroyed) p.destroy();
            
            var textScale = winsText.scale.x;
            if (textScale < 1.5) {
                textScale += 0.3;
                winsText.scale.set_xy(textScale, textScale);
                winsIcon.scale.set_xy(textScale * 0.06, textScale * 0.06);
            }
            var ring_symbol = new Sprite({
                texture: Luxe.resources.texture('assets/images/symbols/ring.png'),
                size: new Vector(32, 32),
                pos: winsIcon.pos,
                color: new Color().rgb(0x956416)
            });
            Actuate.tween(ring_symbol.color, 0.1, { a: 1.0 });
            Actuate.tween(ring_symbol.color, 0.1, { a: 0.0 }).delay(0.3);
            Actuate.tween(ring_symbol.size, 0.5, { x: 128, y: 128 }).onComplete(function() {
                if (!ring_symbol.destroyed) ring_symbol.destroy();
            });

            Luxe.camera.shake(2);

            pe_burst.position.x = Settings.WIDTH / 2;
            pe_burst.position.y = winsText.pos.y;

            pe_burst_color_life_module.initial_color.from_json(new sparkler.data.Color(0.584313, 0.392156, 0.086274));
            pe_burst_color_life_module.end_color.from_json(new sparkler.data.Color(1, 1, 1, 1));

            pe_burst.duration = 0.15;

            pe_burst.start();

            winsText.text = '$wins';

            var sound = switch (particleCount) {
                case 0 | 1: 'points_small';
                case 2 | 3: 'points_big';
                case 4 | 5: 'points_huge';
                default: 'points_devine';
            }
            Luxe.audio.play(Luxe.resources.audio(Settings.get_sound_file_path(sound)).source);
        });
    }

    override function update(dt :Float) {
        var textScale = winsText.scale.x; 
        if (textScale > 1) {
            winsText.scale.set_xy(textScale - dt, textScale - dt);
            winsIcon.scale.set_xy((textScale - dt) * 0.06, (textScale - dt) * 0.06);
        }
        ps.update(dt);
    }

    override function onleave(_) {
        Luxe.scene.empty();
        ps.destroy();
    }

    override function onkeyup(event :luxe.Input.KeyEvent) {
        #if sys
        if (event.keycode == luxe.Input.Key.escape) {
            Luxe.shutdown();
        }
        #end
        #if debug
        switch (event.keycode) {
            case luxe.Input.Key.key_1: Main.SetState(PlayState.StateId, Normal);
            case luxe.Input.Key.key_2:
                var strive_level = Luxe.io.string_load('strive_level');
                var strive_mode = Strive(strive_level != null ? Std.parseInt(strive_level) : 1);
                Main.SetState(PlayState.StateId, strive_mode);
            case luxe.Input.Key.key_3: Main.SetState(PlayState.StateId, Timed);
            case luxe.Input.Key.key_t: update_global_stats(5, 8, 7, 6);
            case luxe.Input.Key.key_c: {
                @SuppressWarning("checkstyle:Trace")
                trace('debug: clears all saves');
                for (game_mode in [GameMode.Normal, GameMode.Strive(0), GameMode.Timed]) {
                    Luxe.io.string_save('save_${game_mode.get_game_mode_id()}', null); // clear the save
                }
            }
        }
        #end
        if (event.keycode == luxe.Input.Key.ac_back) {
            Luxe.shutdown();
        }
    }
}
