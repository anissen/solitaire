
import luxe.GameConfig;
import luxe.Input;
import luxe.States;

import game.states.PlayState;

class Main extends luxe.Game {
    var states :States;

    override function config(config:GameConfig) {
        config.window.title = 'luxe game';
        // config.window.width = 316;
        // config.window.height = 476;
        // config.window.width = 240;
        // config.window.height = 576;
        config.window.fullscreen = false;
        return config;
    }

    override function ready() {
        Luxe.camera.size = new luxe.Vector(316, 476);
        Luxe.renderer.clear_color.set(0.7, 0.8, 0.8);

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
