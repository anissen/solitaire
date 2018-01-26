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
            pos: new Vector(Settings.WIDTH / 2, 170),
            text: 'Made by',
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            color: new Color().rgb(0x956416),
            point_size: 26
        });
        var name = new Text({
            //pos: new Vector(90, 190),
            pos: new Vector(Settings.WIDTH / 2, 230),
            text: 'Anders Nissen',
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            color: new Color().rgb(0x68460e),
            point_size: 26
        });
        var link = new Text({
            //pos: new Vector(90, 190),
            pos: new Vector(Settings.WIDTH / 2, 265),
            text: 'andersnissen.com',
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            color: new Color(0.75, 0.0, 0.5),
            point_size: 26
        });
        #if web
        name.add(new game.components.MouseUp(function(s) {
            Luxe.io.url_open('http://www.andersnissen.com');
        }));
        link.add(new game.components.MouseUp(function(s) {
            Luxe.io.url_open('http://www.andersnissen.com');
        }));
        #end

        // var donation = new Text({
        //     //pos: new Vector(90, 190),
        //     pos: Vector.Add(madeby.pos, new Vector(0, 120)),
        //     text: 'Make a donation',
        //     align: TextAlign.center,
        //     align_vertical: TextAlign.center,
        //     color: new Color(0.6, 0.0, 0.0),
        //     point_size: 26
        // });
        // #if web
        // donation.add(new game.components.MouseUp(function(s) {
        //     Luxe.io.url_open('https://anissen.itch.io/stoneset/donate');
        // }));
        // #end

        var donation_button = new game.ui.Button({
            pos: new Vector(Settings.WIDTH / 2, 360),
            width: 230,
            text: 'Make a donation',
            on_click: function() {
                Luxe.io.url_open('https://anissen.itch.io/stoneset/donate');
            },
            disabled: #if web false #else true #end
        });
        #if web
        donation_button.color_burst();
        #end
        var donation_text = new Text({
            pos: new Vector(Settings.WIDTH / 2, 425),
            text: 'Thank you for considering donating!\nDonations help keep Stoneset ad-free\nand speeds up improvements.',
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            color: new Color().rgb(0x956416),
            point_size: 14
        });
    }

    override function onleave(_) {
        Luxe.scene.empty();
    }
}
