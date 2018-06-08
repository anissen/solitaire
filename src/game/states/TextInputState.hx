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

    public function new() {
        super({ name: StateId });
    }

    override function init() {

    }

    override function onenter(data :Dynamic) {
        new Text({
            text: 'Enter your name:',
            pos: new Vector(Settings.WIDTH / 2, 35),
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

        var nineslice = new luxe.NineSlice({
            name_unique: true,
            texture: Luxe.resources.texture('assets/ui/panelInset_beige.png'),
            top: 20,
            left: 20,
            right: 20,
            bottom: 20
        });

        nineslice.create(new Vector(20, 60), 32, 50);
        nineslice.size = new luxe.Vector(32, 50);
        Actuate.tween(nineslice.size, 1.0, { x: Settings.WIDTH - 40 }).delay(0.3);

        var nameText = new Text({
            text: '',
            pos: new Vector(Settings.WIDTH / 2, 90),
            point_size: 26,
            align: luxe.Text.TextAlign.center,
            align_vertical: luxe.Text.TextAlign.center,
            color: new luxe.Color().rgb(0x964B00),

            letter_spacing: 0,
            sdf: true,
            // shader: Luxe.renderer.shaders.bitmapfont.shader.clone('title-shader'),
            outline: 0.75,
            outline_color: new Color()
        });

        var button_height = 45;
        var button_width = 45;
        var margin = 5;
        var name_max_length = 10;
        
        var caps = true;
        var letter_buttons :Array<PlainButton> = [];
        var space_button :Button = null;
        var erase_button :Button = null;
        var caps_button  :Button = null;
        var done_button  :Button = null;

        var name = Luxe.io.string_load('user_name');
        if (name == null) name = '';

        function update_name(n :String) {
            name = n;

            var maxed = (name.length >= name_max_length);
            for (b in letter_buttons) b.enabled = !maxed;
            space_button.enabled = (!maxed && name.length > 0 && name.charAt(name.length - 1) != ' ');
            erase_button.enabled = (name.length > 0);
            caps_button.enabled = !maxed;
            done_button.enabled = (name.length > 1);

            if (name.length > name_max_length) {
                name = name.substr(0, name_max_length);
            }
            nameText.text = name;

            caps = (name.length == 0 || (name.charAt(name.length - 1) == ' '));
            for (b in letter_buttons) b.text = (caps ? b.text.toUpperCase() : b.text.toLowerCase());
        }

        var count = 0;
        var letters = 'A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 1 2 3 4 5'.split(' ');
        for (letter in letters) {
            var text = letter;
            if (letter == '3') {
                count += 0;
            } else if (letter == '1' || letter == '2' || letter == '4' || letter == '5') {
                var size = 2;
                if (letter == '1') text = 'Space';
                if (letter == '2') text = 'Erase';
                if (letter == '4') { text = 'Aa'; size = 1; }
                if (letter == '5') { text = 'Done'; size = 4; }
                var button = new Button({
                    pos: new Vector(10 + (size * (button_width / 2 + margin / 2)) + (button_width + margin) * (count % 5), (Settings.HEIGHT - 300 - 10 - (button_height / 2)) + (button_height + margin) * Std.int(count / 5)),
                    width: (button_width + margin) * size - margin,
                    height: button_height,
                    text: text,
                    on_click: function() {
                        if (letter == '1') update_name(name + ' ');
                        if (letter == '2' && name.length > 0) update_name(name.substr(0, name.length - 1));
                        if (letter == '4') { 
                            caps = !caps;
                            for (b in letter_buttons) b.text = (caps ? b.text.toUpperCase() : b.text.toLowerCase());
                        }
                        if (letter == '5') {
                            if (name.charAt(name.length - 1) == ' ') name = name.substr(0, name.length - 1);
                            Luxe.io.string_save('user_name', name);
                            data.done_func();
                        }
                    }
                });
                if (letter == '1') space_button = button;
                if (letter == '2') erase_button = button;
                if (letter == '4') caps_button = button;
                if (letter == '5') done_button = button;
                button.scale.set_xy(1.0, 0);
                Actuate.tween(button.scale, 0.2, { y: 1.0}).delay(1.5 + count * 0.02);
                count += size;
            } else {
                var button = new PlainButton({
                    pos: new Vector(10 + (button_width / 2) + (button_width + margin) * (count % 5), (Settings.HEIGHT - 300 - 10 - (button_height / 2)) + (button_height + margin) * Std.int(count / 5)),
                    width: button_width,
                    height: button_height,
                    text: text,
                    on_click: function() {
                        update_name(name + (caps ? text.toUpperCase() : text.toLowerCase()));
                    }
                });
                letter_buttons.push(button);
                button.scale.set_xy(1.0, 0);
                Actuate.tween(button.scale, 0.2, { y: 1.0}).delay(1.0 + count * 0.02);
                count++;
            }
        }

        update_name(name);
    }

    override function onleave(_) {
        Luxe.scene.empty();
    }
}
