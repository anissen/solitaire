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
        config.window.width = 360;
        config.window.height = 640;
        config.window.fullscreen = false;
        config.render.antialiasing = 4;

        config.preload.textures.push({ id: 'assets/ui/panel_beigeLight.png' });

        // var icons = ['square.png', 'circle.png', 'triangle.png', 'diamond.png', 'hex.png', 'tile.png', 'tile_bg.png', 'tile_stacked.png'];
        // for (icon in icons) config.preload.textures.push({ id: 'assets/images/symbols/' + icon });

        return config;
    }

    override function ready() {
        Luxe.camera.size = new luxe.Vector(270, 480);
        Luxe.renderer.clear_color = game.misc.Settings.BACKGROUND_COLOR;
        
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
        nineslice.create(new luxe.Vector(20, Settings.HEIGHT / 4), Settings.WIDTH - 40, Settings.HEIGHT / 2);
        nineslice.size = new luxe.Vector(Settings.WIDTH - 40, Settings.HEIGHT / 2);
        luxe.tween.Actuate.tween(nineslice.color, 0.3, { a: 1.0 });

        var icons = ['square.png', 'circle.png', 'triangle.png', 'diamond.png', 'hex.png', 'tile.png', 'tile_bg.png', 'tile_stacked.png'].map(function(i) return 'images/symbols/$i');
        var ui = ['ui/buttonLong_brown_pressed.png'];

        var parcel = new luxe.Parcel({
			load_time_spacing: 0, //.5,
			load_start_delay: 0, //.5,
			textures: [ for (icon in icons.concat(ui)) { id: 'assets/' + icon } ]
		});

		new game.misc.ArcProgress(parcel, new luxe.Color().rgb(0x914D50), start);
    }

    function start() {
        var end = haxe.Timer.stamp();
        trace('startup took ${end - start_time} seconds'); 

        luxe.tween.Actuate.defaultEase = luxe.tween.easing.Quad.easeIn;

        states = new States({ name: 'state_machine' });
        states.add(new MenuState());
        states.add(new PlayState());
        states.add(new GameOverState());
        states.set(MenuState.StateId);        

        luxe.tween.Actuate.tween(nineslice.pos, 0.3, { x: 0, y: 0 });
        luxe.tween.Actuate.tween(nineslice.size, 0.3, { x: Settings.WIDTH, y: Settings.HEIGHT });
    }

    static public function SetState(id :String, ?data :Dynamic) {
        luxe.tween.Actuate.reset();
        fade.fade_out().onComplete(function() {
            states.set(id, data);
            fade.fade_in();
        });
    }

    #if sys
    override function onkeyup(event :luxe.Input.KeyEvent) {
        if (event.keycode == luxe.Input.Key.escape) {
            Luxe.shutdown();
        }
    }
    #end
}
