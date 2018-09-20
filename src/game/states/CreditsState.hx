package game.states;

import luxe.Text;
import luxe.States.State;
import luxe.Vector;
import luxe.Sprite;
import luxe.Color;
import core.utils.Analytics;

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
            pos: new Vector(Settings.WIDTH / 2, 50),
            point_size: 30,
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
            pos: new Vector(30, 30),
            texture_path: 'assets/ui/arrowBeige_left.png',
            on_click: Main.SetState.bind(MenuState.StateId)
        });
        back_button.scale.set_xy(1/4, 1/4);

        var url_open_func = #if android Main.SnowActivity.url_open #else Luxe.io.url_open #end ;

        var madeby = new Text({
            //pos: new Vector(90, 190),
            pos: new Vector(Settings.WIDTH / 2, 120),
            text: 'Made by',
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            color: new Color().rgb(0x956416),
            point_size: 26
        });
        var name = new Text({
            //pos: new Vector(90, 190),
            pos: new Vector(Settings.WIDTH / 2, 150),
            text: 'Anders Nissen',
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            color: new Color().rgb(0x68460e),
            point_size: 26,

            letter_spacing: 0,
            sdf: true,
            shader: Luxe.renderer.shaders.bitmapfont.shader.clone('title-shader'),
            outline: 0.75,
            outline_color: new Color()
        });
        new Sprite({
            parent: name,
            pos: new Vector(0, -5), // to avoid the two link-sprites overlapping
            size: new Vector(name.text_bounds.w, name.text_bounds.h),
            color: new Color(1.0, 0.0, 0.0, 0.0)
        }).add(new game.components.MouseUp(function(s) {
            Analytics.event('about', 'clicked', 'name');
            url_open_func('http://www.andersnissen.com');
        }));

        var link = new Text({
            //pos: new Vector(90, 190),
            pos: new Vector(Settings.WIDTH / 2, 180),
            text: 'andersnissen.com',
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            color: new Color(0.75, 0.0, 0.5),
            point_size: 26
        });
        new Sprite({
            parent: link,
            size: new Vector(link.text_bounds.w, link.text_bounds.h),
            color: new Color(1.0, 0.0, 0.0, 0.0)
        }).add(new game.components.MouseUp(function(s) {
            Analytics.event('about', 'clicked', 'link');
            url_open_func('http://www.andersnissen.com');
        }));

        var icons_by = new Text({
            //pos: new Vector(90, 190),
            pos: new Vector(Settings.WIDTH / 2, 245),
            text: 'Icons by',
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            color: new Color().rgb(0x956416),
            point_size: 26
        });
        var icons_link = new Text({
            //pos: new Vector(90, 190),
            pos: new Vector(Settings.WIDTH / 2, 275),
            text: 'game-icons.net',
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            color: new Color(0.75, 0.0, 0.5),
            point_size: 26
        });
        new Sprite({
            parent: icons_link,
            size: new Vector(icons_link.text_bounds.w, icons_link.text_bounds.h),
            color: new Color(1.0, 0.0, 0.0, 0.0)
        }).add(new game.components.MouseUp(function(s) {
            url_open_func('https://game-icons.net/');
        }));

        // var donation = new Text({
        //     //pos: new Vector(90, 190),
        //     pos: Vector.Add(madeby.pos, new Vector(0, 120)),
        //     text: 'Make a donation',
        //     align: TextAlign.center,
        //     align_vertical: TextAlign.center,
        //     color: new Color(0.6, 0.0, 0.0),
        //     point_size: 26
        // });
        // donation.add(new game.components.MouseUp(function(s) {
        //     url_open_func('https://anissen.itch.io/stoneset/donate');
        // }));

        var donation_button = new game.ui.Button({
            pos: new Vector(Settings.WIDTH / 2, 350),
            width: 230,
            text: 'Make a donation',
            on_click: function() {
                Analytics.event('about', 'clicked', 'donate');
                url_open_func('https://anissen.itch.io/stoneset/donate');
                // #if android
                // Main.SnowActivity.share('Stoneset shared text!');
                // #end
            },
            disabled: false
        });
        donation_button.color_burst();
        var donation_text = new Text({
            pos: new Vector(Settings.WIDTH / 2, 420),
            text: 'Thank you for considering donating!\nDonations help keep Stoneset ad-free\nand speeds up improvements.',
            align: TextAlign.center,
            align_vertical: TextAlign.center,
            color: new Color().rgb(0x956416),
            point_size: 14
        });
    }

    override function onkeyup(event :luxe.Input.KeyEvent) {
        if (event.keycode == luxe.Input.Key.ac_back) {
            Main.SetState(MenuState.StateId);
        }
    }

    override function onleave(_) {
        Luxe.scene.empty();
    }
}
