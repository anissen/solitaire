package;

import luxe.GameConfig;
import luxe.States;

import game.states.PlayState;
import game.states.GameOverState;

class Main extends luxe.Game {
    static public var states :States;
    var start_time :Float;

    override function config(config:GameConfig) {
        start_time = haxe.Timer.stamp();

        config.window.title = 'Solitaire';
        config.window.width = 360;
        config.window.height = 640;
        config.window.fullscreen = false;
        config.render.antialiasing = 4;

        // var icons = ['square.png', 'circle.png', 'triangle.png', 'diamond.png', 'hex.png', 'tile.png', 'tile_bg.png', 'tile_stacked.png'];
        // for (icon in icons) config.preload.textures.push({ id: 'assets/images/symbols/' + icon });

        return config;
    }

    override function ready() {
        Luxe.renderer.clear_color = game.misc.Settings.BACKGROUND_COLOR;

        var icons = ['square.png', 'circle.png', 'triangle.png', 'diamond.png', 'hex.png', 'tile.png', 'tile_bg.png', 'tile_stacked.png'];

        // var icons = ['animals/elephant.png', 'animals/giraffe.png', 'animals/hippo.png', 'animals/monkey.png','animals/panda.png', 'animals/parrot.png', 'animals/penguin.png', 'animals/pig.png', 'animals/rabbit.png', 'animals/snake.png', 'symbols/tile.png', 'symbols/tile_bg.png', 'symbols/tile_stacked.png'];
        var parcel = new luxe.Parcel({
			// load_time_spacing: .5,
			// load_start_delay: .5,
			textures: [ for (icon in icons) { id: 'assets/images/symbols/' + icon } ]
		});

		new game.misc.ArcProgress(parcel, new luxe.Color().rgb(0x914D50), start);
    }

    function start() {
        var end = haxe.Timer.stamp();
        trace('startup took ${end - start_time} seconds'); 

        Luxe.camera.size = new luxe.Vector(270, 480);

        luxe.tween.Actuate.defaultEase = luxe.tween.easing.Quad.easeIn;

        states = new States({ name: 'state_machine' });
        states.add(new PlayState());
        states.add(new GameOverState());
        NewGame();
    }

    static public function NewGame() {
        if (states.enabled(GameOverState.StateId)) states.disable(GameOverState.StateId);
        states.unset();
        states.set(PlayState.StateId);
    }

    #if sys
    override function onkeyup(event:KeyEvent) {
        if (event.keycode == Key.escape) {
            Luxe.shutdown();
        }
    }
    #end
}
