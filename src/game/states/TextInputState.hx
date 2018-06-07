package game.states;

import luxe.Text;
import luxe.States.State;
import luxe.Vector;
import luxe.Color;
import luxe.tween.Actuate;
import game.ui.Button;
import game.ui.PlainButton;

class TextInputState extends State {
    static public var StateId :String = 'TextInputState';
    var title :Text;
    var counting_total_score :Float;
    var tutorial_box :game.entities.TutorialBox;

    public function new() {
        super({ name: StateId });
    }

    override function init() {

    }

    override function onenter(data :Dynamic) {
        title = new Text({
            text: 'Enter your name:',
            pos: new Vector(Settings.WIDTH / 2, 30),
            point_size: 26,
            align: luxe.Text.TextAlign.center,
            align_vertical: luxe.Text.TextAlign.center,
            color: new luxe.Color(1.0, 1.0, 1.0),

            letter_spacing: 0,
            sdf: true,
            shader: Luxe.renderer.shaders.bitmapfont.shader.clone('title-shader'),
            outline: 0.75,
            outline_color: new Color().rgb(0xa55004),
        });

        // var config_button = new game.ui.Icon({
        //     pos: new Vector(35, 35),
        //     texture_path: 'assets/ui/circular.png',
        //     on_click: Main.SetState.bind(SettingsState.StateId)
        // });
        // config_button.scale.set_xy(1/5, 1/5);
        // config_button.color.a = 0.75;
        // new luxe.Sprite({
        //     texture: Luxe.resources.texture('assets/ui/cog.png'),
        //     parent: config_button,
        //     pos: new Vector(128, 128),
        //     scale: new Vector(0.5, 0.5),
        //     color: new Color().rgb(0x8C7D56),
        //     depth: 110
        // });

        // var about_button = new game.ui.Icon({
        //     pos: new Vector(Settings.WIDTH - 35, 35),
        //     texture_path: 'assets/ui/circular.png',
        //     on_click: Main.SetState.bind(CreditsState.StateId)
        // });
        // about_button.scale.set_xy(1/5, 1/5);
        // about_button.color.a = 0.75;
        // new luxe.Sprite({
        //     texture: Luxe.resources.texture('assets/ui/book.png'),
        //     parent: about_button,
        //     pos: new Vector(128, 128),
        //     scale: new Vector(0.5, 0.5),
        //     color: new Color().rgb(0x8C7D56),
        //     depth: 110
        // });

        // var normal_save = Luxe.io.string_load('save_normal');

        var button_height = 45;
        var button_width = 45;
        var margin = 5;
        // function get_button_y() {
        //     return 275 + (button_count++) * button_height;
        // }
        var count = 0;
        var letters = 'A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 2 3 4 5'.split(' ');
        for (letter in letters) {
            if (letter == '2') {
                count += 4;
                continue;
            }
            if (letter != '2') {
                var text = letter;
                if (letter == '3' || letter == '4' || letter == '5') {
                    if (letter == '3') text = 'Aa';
                    if (letter == '4') text = 'Erase';
                    if (letter == '5') text = 'Done';
                    var button = new Button({
                        // pos: new Vector(10 + (button_width / 2) + (button_width + margin) * (count % 5), (Settings.HEIGHT - 250 - 10 - (button_height / 2)) + (button_height + margin) * Std.int(count / 5)),
                        pos: new Vector(10 + (letter == '3' ? button_width / 2 : button_width) + (button_width + margin) * (count % 5), (Settings.HEIGHT - 300 - 10 - (button_height / 2)) + (button_height + margin) * Std.int(count / 5)),
                        width: (letter == '3' ? button_width : button_width * 2 + margin),
                        height: button_height,
                        text: text,
                        on_click: function() {}
                    });
                    button.scale.set_xy(1.0, 0);
                    Actuate.tween(button.scale, 0.2, { y: 1.0}).delay(1.0 + count * 0.02);
                    count += (letter == '3' ? 1 : 2);
                    continue;
                } else {
                    var button = new PlainButton({
                        // pos: new Vector(10 + (button_width / 2) + (button_width + margin) * (count % 5), (Settings.HEIGHT - 250 - 10 - (button_height / 2)) + (button_height + margin) * Std.int(count / 5)),
                        pos: new Vector(10 + (button_width / 2) + (button_width + margin) * (count % 5), (Settings.HEIGHT - 300 - 10 - (button_height / 2)) + (button_height + margin) * Std.int(count / 5)),
                        width: button_width,
                        height: button_height,
                        text: text,
                        on_click: function() {}
                    });
                    button.scale.set_xy(1.0, 0);
                    Actuate.tween(button.scale, 0.2, { y: 1.0}).delay(0.5 + count * 0.02);
                    count++;
                }
            }
        }
    }

    override function onleave(_) {
        Luxe.scene.empty();
    }
}
