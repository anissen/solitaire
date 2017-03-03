
import luxe.GameConfig;
import luxe.Input;
import luxe.States;

import game.states.PlayState;

class Main extends luxe.Game {
    var states :States;

    override function config(config:GameConfig) {
        config.window.title = 'luxe game';
        // config.window.width = 270;
        // config.window.height = 480;
        config.window.width = 360;
        config.window.height = 640;
        config.window.fullscreen = false;
        config.render.antialiasing = 4;

        // var icons = ['bread.png', 'cheese-wedge.png', 'dripping-honey.png', 'grain.png', 'grapes.png', 'honeypot.png', 'milk-carton.png', 'wine-glass.png'];
        // for (icon in icons) config.preload.textures.push({ id: 'assets/images/' + icon });
        // var icons = ['clubs.png', 'diamonds.png', 'hearts.png', 'spades.png'];
        // var icons = ['candlebright.png', 'curled-leaf.png', 'drop.png', 'fluffy-cloud.png'];
        var icons = ['square.png', 'circle.png', 'triangle.png', 'diamond.png', 'tile.png'];
        for (icon in icons) config.preload.textures.push({ id: 'assets/images/symbols/' + icon });

        return config;
    }

    override function ready() {
        Luxe.camera.size = new luxe.Vector(270, 480);
        Luxe.renderer.clear_color.set(0.7, 0.8, 0.8);

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

    override function update(delta:Float) {

    }
}
