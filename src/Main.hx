package;

import luxe.GameConfig;
import luxe.States;

import game.misc.Settings;

import game.states.MenuState;
import game.states.PlayState;
import game.states.GameOverState;

class Main extends luxe.Game {
    static var states :States;
    static var fade :game.components.Fader;
    var start_time :Float;
    var nineslice :luxe.NineSlice;

    override function config(config:GameConfig) {
        start_time = haxe.Timer.stamp();

        config.window.title = 'Solitaire';
        config.window.width = 360; //Settings.WIDTH;
        config.window.height = 640; //Settings.HEIGHT;
        config.window.fullscreen = false;
        config.render.antialiasing = 4;

        config.preload.textures.push({ id: 'assets/ui/panel_beigeLight.png' });

        return config;
    }

    override function ready() {
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
        var ui = ['ui/buttonLong_brown_pressed.png', 'ui/arrowBeige_left.png', 'ui/panelInset_beige.png', 'ui/pyramids.png', 'ui/circular.png', 'ui/cog.png', 'ui/book.png', 'ui/histogram.png'];
        var sounds = ['invalid.ogg', 'lost.ogg', 'place.ogg', 'points_big.ogg', 'points_huge.ogg', 'points_small.ogg', 'quest.ogg', 'slide.ogg', 'stack.ogg', 'tile_click.ogg', 'ui_click.ogg', 'won.ogg'];
        var music = ['Temple_of_the_Mystics.ogg']; // TODO: Convert to mp3 to work in more browsers?]

        var parcel = new luxe.Parcel({
			load_time_spacing: 0,
			load_start_delay: 0,
			textures: [ for (icon in icons.concat(ui)) { id: 'assets/' + icon } ],
			sounds: [ for (sound in sounds) { id: 'assets/sounds/' + sound, is_stream: false } ]
                    .concat([for (m in music) { id: 'assets/music/' + m, is_stream: true }]),
            fonts: [{ id: 'assets/fonts/clemente/clemente.fnt' } ]
		});

		new game.misc.ArcProgress(parcel, new luxe.Color().rgb(0x914D50), start);
    }

    function start() {
        Luxe.renderer.font = Luxe.resources.font('assets/fonts/clemente/clemente.fnt');

        var end = haxe.Timer.stamp();
        trace('startup took ${end - start_time} seconds'); 

        luxe.tween.Actuate.defaultEase = luxe.tween.easing.Quad.easeIn;

        states = new States({ name: 'state_machine' });
        states.add(new MenuState());
        states.add(new PlayState());
        states.add(new GameOverState());

        // Luxe.audio.loop(Luxe.resources.audio('assets/music/Temple_of_the_Mystics.ogg').source);

        luxe.tween.Actuate.tween(nineslice.pos, 0.3, { x: 0, y: 0 });
        luxe.tween.Actuate.tween(nineslice.size, 0.3, { x: Settings.WIDTH, y: Settings.HEIGHT }).onComplete(function() {
            states.set(MenuState.StateId);  
        });
    }

    static public function SetState(id :String, ?data :Dynamic) {
        luxe.tween.Actuate.reset();
        fade.fade_out().onComplete(function() {
            Luxe.audio.play(Luxe.resources.audio('assets/sounds/slide.ogg').source);
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
