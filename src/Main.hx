package;

import luxe.GameConfig;
import luxe.Input;
import luxe.States;

import game.states.PlayState;
import game.states.GameOverState;

class Main extends luxe.Game {
    static public var states :States;

    override function config(config:GameConfig) {
        config.window.title = 'Solitaire';
        config.window.width = 360;
        config.window.height = 640;
        config.window.fullscreen = false;
        config.render.antialiasing = 4;

        var icons = ['square.png', 'circle.png', 'triangle.png', 'diamond.png', 'hex.png', 'tile.png', 'tile_bg.png'];
        for (icon in icons) config.preload.textures.push({ id: 'assets/images/symbols/' + icon });

        return config;
    }

    override function ready() {
        Luxe.camera.size = new luxe.Vector(270, 480);
        Luxe.renderer.clear_color.rgb(0xD5D5D5);

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
