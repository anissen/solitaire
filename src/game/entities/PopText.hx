package game.entities;

import luxe.Text;
import luxe.Sprite;
import luxe.tween.Actuate;

typedef PopTextOptions = {
    > luxe.options.TextOptions,
    ?duration :Float,
    ?icon :Sprite
}

class PopText extends Text {
    var fadeDuration :Float = 0.5;
    var fadeDelay :Float = 1.0;
    var icon :Sprite;

    public function new(options :PopTextOptions) {
        super(options);

        icon = options.icon;
        if (options.duration != null) fadeDuration = options.duration;

        this.color.a = 0.8;
    }

    override public function init() {
        super.init();

        if (icon != null) {
            icon.color.a = 0.8;
            icon.pos = this.pos.clone();
            var text_width = this.geom.text_width;
            if (this.text == "1") text_width = text_width / 2;
            icon.pos.x += text_width / 2 + icon.size.w / 2 + 12;
            icon.pos.y -= 3;
            Actuate.tween(icon.color, fadeDuration, { a: 0 }).delay(fadeDelay);
        }

        Actuate.tween(this, fadeDuration, { outline: 0 }).delay(fadeDelay);
        Actuate
            .tween(this.color, fadeDuration, { a: 0 })
            .ease(luxe.tween.easing.Linear.easeNone)
            .onComplete(function (_) {
                trace('destroying poptext!');
                if (icon != null) icon.destroy();
                destroy();
            })
            .delay(fadeDelay);
    }
}
