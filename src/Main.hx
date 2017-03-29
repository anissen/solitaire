package;

import luxe.GameConfig;
import luxe.Input;
import luxe.States;

import game.states.PlayState;

class Main extends luxe.Game {
    var states :States;

    override function config(config:GameConfig) {
        config.window.title = 'luxe game';
        config.window.width = 360;
        config.window.height = 640;
        config.window.fullscreen = false;
        config.render.antialiasing = 4;

        var icons = ['square.png', 'circle.png', 'triangle.png', 'diamond.png', 'tile.png', 'tile_bg.png'];
        for (icon in icons) config.preload.textures.push({ id: 'assets/images/symbols/' + icon });

        return config;
    }

    override function ready() {
        Luxe.camera.size = new luxe.Vector(270, 480);
        Luxe.renderer.clear_color.rgb(0xD5D5D5);

        luxe.tween.Actuate.defaultEase = luxe.tween.easing.Quad.easeIn;

        states = new States({ name: 'state_machine' });
        states.add(new PlayState());
        states.set(PlayState.StateId);
    }

    override function onkeyup(event:KeyEvent) {
        if (event.keycode == Key.escape) {
            Luxe.shutdown();
        }
    }
}
