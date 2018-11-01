package;

import luxe.GameConfig;
import luxe.States;
import game.misc.Settings;
import core.utils.Analytics;
import snow.types.Types;
import game.states.*;

using game.misc.GameMode;

#if android
@:build(snow.api.JNI.declare('org.snowkit.snow.SnowActivity'))
class SnowActivity {
    public static function url_open(url:String) :Void;
    // public static function share(text:String): Void;
}
#end

class Main extends luxe.Game {
    static var states :States;
    static var current_state_id :String = "";
    static var fade :game.components.Fader;
    // static var music_handles :Array<luxe.Audio.AudioHandle> = [];
    static var music_handle :luxe.Audio.AudioHandle;
    var start_time :Float;
    var nineslice :luxe.NineSlice;

    override function config(config:GameConfig) {
        start_time = haxe.Timer.stamp();

        config.window.title = 'Stoneset';
        config.window.width = 360; //Settings.WIDTH;
        config.window.height = 640; //Settings.HEIGHT;
        config.window.fullscreen = false;
        config.render.antialiasing = 4;

        config.preload.textures.push({ id: 'assets/ui/panel_beigeLight.png' });

        com.akifox.asynchttp.AsyncHttp.logEnabled = false;
        com.akifox.asynchttp.AsyncHttp.logErrorEnabled = true;

        #if ios
        sys.ssl.Socket.DEFAULT_VERIFY_CERT = false;
        #end

        return config;
    }

    override function ready() {
        var clientId = Luxe.io.string_load('clientId');
        if (clientId == null) {
            clientId = '${haxe.Timer.stamp()}'.split('.').join('');
            Luxe.io.string_save('clientId', clientId);
        }

        #if debug
        Analytics.tracking_id = 'UA-117762148-1';
        #else
        Analytics.tracking_id = 'UA-117779824-1';
        #end
        Analytics.client_id = clientId;
        Analytics.screen('Main');
        #if web
        Analytics.event('platform', 'Web');
        #elseif android
        Analytics.event('platform', 'Android');
        #elseif ios
        Analytics.event('platform', 'iOS');
        #else
        Analytics.event('platform', Sys.systemName());
        #end
        Analytics.event('startup', 'ready');

        Luxe.camera.size = new luxe.Vector(Settings.WIDTH, Settings.HEIGHT);
        Luxe.renderer.clear_color = Settings.BACKGROUND_COLOR;
        sparkler.ParticleSystem.renderer = new sparkler.render.luxe.LuxeRenderer();
        
        fade = new game.components.Fader({ name: 'fade' });
        Luxe.camera.add(fade);
        Luxe.on(luxe.Ev.init, function(_){ fade.fade_in(); });

        nineslice = new luxe.NineSlice({
            name_unique: true,
            texture: Luxe.resources.texture('assets/ui/panel_beigeLight.png'),
            top: 20,
            left: 20,
            right: 20,
            bottom: 20,
            color: new luxe.Color(1, 1, 1, 0),
            depth: -1000,
            scene: new luxe.Scene()
        });
        var size = 170;
        nineslice.create(new luxe.Vector(Settings.WIDTH / 2 - size / 2, Settings.HEIGHT / 2 - size / 2), size, size);
        nineslice.size = new luxe.Vector(size, size);
        luxe.tween.Actuate.tween(nineslice.color, 0.3, { a: 1.0 });

        var icons = ['square.png', 'circle.png', 'triangle.png', 'diamond.png', 'hex.png', 'star.png', 'tile.png', 'tile_bg.png', 'tile_stacked.png', 'ring.png'].map(function(i) return 'images/symbols/$i');
        var ui = ['ui/buttonLong_brown_pressed.png', 'ui/buttonLong_teal_pressed.png', 'ui/arrowBeige_left.png', 'ui/panelInset_beige.png', 'ui/pyramids.png', 'ui/circular.png', 'ui/circular_light.png', 'ui/cog.png', 'ui/book.png', 'ui/holy-grail.png', 'ui/egyptian-walk.png', 'ui/round-star.png', 'ui/diamond.png'];
        var tutorial = ['images/tutorial/box_shadow.png', 'images/tutorial/arrow.png', 'images/tutorial/collect_order.png', 'images/tutorial/collect_adjacent.png', 'images/tutorial/stack.png'];
        var journey = ['images/journey/egyptian-temple.png', 'images/journey/great-pyramid.png', 'images/journey/flying-flag.png', 'images/journey/path1.png', 'images/journey/path2.png'];
        var sounds = ['invalid', 'lost', 'place', 'points_big', 'points_huge', 'points_small', 'points_devine', 'quest', 'slide', 'stack', 'tile_click', 'ui_click', 'won', 'collect', 'tutorial'];
        var music = ['Temple_of_the_Mystics' /*, 'desert-ambience-cropped.ogg' */];

        var parcel = new luxe.Parcel({
            load_time_spacing: 0,
            load_start_delay: 0,
            textures: [ for (icon in icons.concat(ui).concat(tutorial).concat(journey)) { id: 'assets/' + icon } ],
            sounds: [ for (sound in sounds) { id: Settings.get_sound_file_path(sound), is_stream: false } ]
                    .concat([for (m in music) { id: Settings.get_music_file_path(m), is_stream: true }]),
            fonts: [{ id: 'assets/fonts/clemente/clemente.fnt' } ]
        });

        new game.misc.ArcProgress(parcel, new luxe.Color().rgb(0x914D50), start);
    }

    static public function start_music() {
        var state = Luxe.audio.state_of(music_handle);
        if (state == luxe.Audio.AudioState.as_playing) return;

        var music_source = Luxe.resources.audio(Settings.get_music_file_path('Temple_of_the_Mystics')).source;
        music_handle = Luxe.audio.loop(music_source);
        Luxe.audio.volume(music_handle, 0.2);
    }

    static public function stop_music() {
        var state = Luxe.audio.state_of(music_handle);
        if (state != luxe.Audio.AudioState.as_playing) return;

        Luxe.audio.stop(music_handle);
    }

    function start() {
        Luxe.renderer.font = Luxe.resources.font('assets/fonts/clemente/clemente.fnt');

        var end = haxe.Timer.stamp();
        trace('startup took ${end - start_time} seconds');
        Analytics.event('startup', 'finished', 'duration', Std.int((end - start_time) * 1000));

        luxe.tween.Actuate.defaultEase = luxe.tween.easing.Quad.easeIn;

        states = new States({ name: 'state_machine' });
        states.add(new MenuState());
        states.add(new SettingsState());
        states.add(new CreditsState());
        states.add(new PlayState());
        states.add(new GameOverState());
        states.add(new TextInputState());
        states.add(new JourneyState());

        if (Luxe.io.string_load('audio_enabled') == 'false') {
            Luxe.audio.suspend();
        }

        var now = Date.now();
        var date_string = '' + now.getDate() + now.getMonth() + now.getFullYear();
        //trace('date_string: $date_string');
        if (Luxe.io.string_load('today') != date_string) {
            //trace('setting new date string: $date_string');
            Luxe.io.string_save('today', date_string);
            Luxe.io.string_save(GameMode.Normal.get_game_mode_id() + '_plays_today', '0');
            Luxe.io.string_save(GameMode.Strive(0).get_game_mode_id() + '_plays_today', '0');
            Luxe.io.string_save(GameMode.Timed.get_game_mode_id() + '_plays_today', '0');
        }

        // Luxe.audio.loop(Luxe.resources.audio('assets/music/ogg/desert-ambience-cropped.ogg').source);
        // var handle = Luxe.audio.loop(Luxe.resources.audio('assets/music/ogg/Temple_of_the_Mystics.ogg').source);
        // handle.

        // music_handles.push(Luxe.resources.audio('assets/music/ogg/desert-ambience-cropped.ogg').source));
        // music_handles.push(Luxe.audio.loop(Luxe.resources.audio('assets/music/ogg/Temple_of_the_Mystics.ogg').source));

        // var music_handle = Luxe.audio.loop(Luxe.resources.audio('assets/music/ogg/Temple_of_the_Mystics.ogg').source);
        // for (handle in music_handles) {
        //     Luxe.audio.volume(handle, 0.2);
        // }

        var music_enabled = Luxe.io.string_load('music_enabled');
        if (music_enabled == null || music_enabled == 'true') {
            start_music();
        }

        luxe.tween.Actuate.tween(nineslice.pos, 0.2, { x: 0, y: 0 });
        luxe.tween.Actuate.tween(nineslice.size, 0.2, { x: Settings.WIDTH, y: Settings.HEIGHT }).onComplete(function() {
            var showTutorial = (Luxe.io.string_load('tutorial_complete') == null);
            if (showTutorial) {
                SetState(PlayState.StateId, GameMode.Tutorial(GameMode.Normal));
            } else {
                SetState(JourneyState.StateId);
            }
        });
    }

    static public function SetState(id :String, ?data :Dynamic) {
        current_state_id = id;
        Analytics.screen(id);
        luxe.tween.Actuate.reset();
        fade.fade_out().onComplete(function() {
            Luxe.audio.play(Luxe.resources.audio(Settings.get_sound_file_path('slide')).source);
            states.set(id, data);
            fade.fade_in();
        });
    }

    static public function GetStateId() :String {
        return current_state_id;
    }

    override public function onevent(event :SystemEvent) {
        if (event.type == se_window) {
            switch (event.window.type) {
                case WindowEventType.we_restored:
                    // crazy hack to ensure that audio is disabled when resuming
                    if (Luxe.io.string_load('audio_enabled') == 'false') {
                        Luxe.audio.suspend();
                    }
                default:
            }
        }
    }

    #if debug
    override function onkeyup(event :luxe.Input.KeyEvent) {
        if (event.keycode == luxe.Input.Key.key_d) {
            Luxe.io.string_save('save_normal', null);
            Luxe.io.string_save('save_journey', null);
        }
    }
    #end
}
