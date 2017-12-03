package game.states;

import luxe.Text;
import luxe.States.State;
import luxe.Vector;
import luxe.Color;

// import game.ui.Button;

class CreditsState extends State {
    static public var StateId :String = 'CreditsState';
    var title :Text;

    public function new() {
        super({ name: StateId });
    }

    override function init() {

    }

    override function onenter(data :Dynamic) {
        title = new Text({
            text: 'About',
            pos: new Vector(Settings.WIDTH / 2, 80),
            point_size: 36,
            align: luxe.Text.TextAlign.center,
            align_vertical: luxe.Text.TextAlign.center,
            color: new luxe.Color(1.0, 1.0, 1.0),

            letter_spacing: 0,
            sdf: true,
            shader: Luxe.renderer.shaders.bitmapfont.shader.clone('title-shader'),
            outline: 0.75,
            outline_color: new Color().rgb(0xa55004),
        });
        // luxe.tween.Actuate.tween(title, 3.0, { outline: 0.65, letter_spacing: -1.5 }).reflect().repeat();

        var back_button = new game.ui.Icon({
            pos: new Vector(25, 25),
            texture_path: 'assets/ui/arrowBeige_left.png',
            on_click: Main.SetState.bind(MenuState.StateId)
        });
        back_button.scale.set_xy(1/5, 1/5);

        var madeby = new Text({
            //pos: new Vector(90, 190),
            pos: Luxe.camera.center.clone(),
            text: 'Made by',
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            color: new Color().rgb(0x956416),
            point_size: 26
        });
        var link = new Text({
            //pos: new Vector(90, 190),
            pos: Vector.Add(madeby.pos, new Vector(0, 50)),
            text: 'Anders Nissen',
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            color: new Color(0.6, 0.0, 0.6),
            point_size: 26
        });
        link.add(new game.components.MouseUp(function(s) {
            // Luxe.io.url_open('http://www.andersnissen.com'); // TODO: Does not work on Android :(
        }));
    }

    override function onleave(_) {
        Luxe.scene.empty();
    }
}
