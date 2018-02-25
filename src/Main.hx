package;

import luxe.GameConfig;
import luxe.States;

import game.misc.Settings;
import core.utils.Analytics;

import game.states.*;

#if android
@:build(snow.api.JNI.declare('org.snowkit.snow.SnowActivity'))
class SnowActivity {
    public static function url_open(url:String): Void;
}
#end

class Main extends luxe.Game {
    static var states :States;
    static var fade :game.components.Fader;
    // static var music_handles :Array<luxe.Audio.AudioHandle> = [];
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

        return config;
    }

    override function ready() {
        var clientId = Luxe.io.string_load('clientId');
        if (clientId == null) {
            clientId = '${haxe.Timer.stamp()}'.split('.').join('');
            Luxe.io.string_save('clientId', clientId);
        }
        trace('clientId: $clientId');

        Analytics.tracking_id = 'UA-64844180-1';
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
        var size = 160;
        nineslice.create(new luxe.Vector(Settings.WIDTH / 2 - size / 2, Settings.HEIGHT / 2 - size / 2), size, size);
        nineslice.size = new luxe.Vector(size, size);
        luxe.tween.Actuate.tween(nineslice.color, 0.3, { a: 1.0 });

        var icons = ['square.png', 'circle.png', 'triangle.png', 'diamond.png', 'hex.png', 'star.png', 'tile.png', 'tile_bg.png', 'tile_stacked.png', 'ring.png'].map(function(i) return 'images/symbols/$i');
        var ui = ['ui/buttonLong_brown_pressed.png', 'ui/arrowBeige_left.png', 'ui/panelInset_beige.png', 'ui/pyramids.png', 'ui/circular.png', 'ui/cog.png', 'ui/book.png', 'ui/stars.png'];
        var tutorial = ['images/tutorial/box_shadow.png', 'images/tutorial/arrow.png'];
        var sounds = ['invalid', 'lost', 'place', 'points_big', 'points_huge', 'points_small', 'points_devine', 'quest', 'slide', 'stack', 'tile_click', 'ui_click', 'won', 'collect'];
        var music = ['Temple_of_the_Mystics' /*, 'desert-ambience-cropped.ogg' */];

        var parcel = new luxe.Parcel({
			load_time_spacing: 0,
			load_start_delay: 0,
			textures: [ for (icon in icons.concat(ui).concat(tutorial)) { id: 'assets/' + icon } ],
			sounds: [ for (sound in sounds) { id: Settings.get_sound_file_path(sound), is_stream: false } ]
                    .concat([for (m in music) { id: Settings.get_music_file_path(m), is_stream: true }]),
            fonts: [{ id: 'assets/fonts/clemente/clemente.fnt' } ]
		});

		new game.misc.ArcProgress(parcel, new luxe.Color().rgb(0x914D50), start);
    }

    function start() {
        Luxe.renderer.font = Luxe.resources.font('assets/fonts/clemente/clemente.fnt');

        var end = haxe.Timer.stamp();
        trace('startup took ${end - start_time} seconds'); 
        Analytics.event('startup', 'finished', 'duration', Std.int(end - start_time));

        luxe.tween.Actuate.defaultEase = luxe.tween.easing.Quad.easeIn;

        states = new States({ name: 'state_machine' });
        states.add(new MenuState());
        states.add(new SettingsState());
        states.add(new CreditsState());
        states.add(new PlayState());
        states.add(new GameOverState());

        if (Luxe.io.string_load('audio_enabled') == 'false') {
            Luxe.audio.active = false;
            Luxe.audio.suspend();
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

        var music_handle = Luxe.audio.loop(Luxe.resources.audio(Settings.get_music_file_path('Temple_of_the_Mystics')).source);
        Luxe.audio.volume(music_handle, 0.2);

        luxe.tween.Actuate.tween(nineslice.pos, 0.3, { x: 0, y: 0 });
        luxe.tween.Actuate.tween(nineslice.size, 0.3, { x: Settings.WIDTH, y: Settings.HEIGHT }).onComplete(function() {
            states.set(MenuState.StateId);  
        });

        // #if android 
        // Main.SnowActivity.url_open('https://twitter.com/intent/tweet?original_referer=http://andersnissen.com&text=Stoneset tweet #Stoneset&url=http://andersnissen.com/');
        // #end
    }

    static public function SetState(id :String, ?data :Dynamic) {
        Analytics.screen(id);
        luxe.tween.Actuate.reset();
        fade.fade_out().onComplete(function() {
            Luxe.audio.play(Luxe.resources.audio(Settings.get_sound_file_path('slide')).source);
            states.set(id, data);
            fade.fade_in();
        });
    }

    #if debug
    override function onkeyup(event :luxe.Input.KeyEvent) {
        if (event.keycode == luxe.Input.Key.key_d) {
            Luxe.io.string_save('save_normal', null);
            Luxe.io.string_save('save_strive', null);
        }
    }
    #end
}
