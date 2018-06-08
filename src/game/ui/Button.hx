package game.ui;

import luxe.Input;
import luxe.Vector;
import luxe.Text;
import luxe.Color;
import luxe.tween.Actuate;

import particles.ParticleSystem;
import particles.ParticleEmitter;
import particles.modules.*;

typedef ButtonOptions = {
    pos :Vector,
    ?width :Int,
    ?height :Int,
    ?font_size :Int,
    ?text :String,
    ?disabled :Bool,
    ?no_shake :Bool,
    on_click :Void->Void
}

class Button extends luxe.NineSlice {
    var label :Text;
    var hovered :Bool = false;
    var on_click :Void->Void;
    var is_enabled :Bool = true;
    var ps :ParticleSystem;
    var pe :ParticleEmitter;
    var particle_color :Color;
    var start_pos :Vector;
    public var text (get, set) :String;
    public var enabled (get, set) :Bool;

    public function new(options :ButtonOptions) {
        super({
            name_unique: true,
            texture: Luxe.resources.texture('assets/ui/buttonLong_brown_pressed.png'),
            top: 15,
            left: 20,
            right: 20,
            bottom: 15,
            color: new Color(1, 1, 1, 1),
            depth: 100
        });
        var width = (options.width != null ? options.width : 200);
        var height = (options.height != null ? options.height : 45);
        var font_size = (options.font_size != null ? options.font_size : 26);
        var text = (options.text != null ? options.text : '');
        var disabled = (options.disabled != null ? options.disabled : false);
        on_click = options.on_click;
        this.create(Vector.Subtract(options.pos, new Vector(width / 2, height / 2)), width, height);
        start_pos = this.pos.clone();

        label = new Text({
            parent: this,
            text: text,
            pos: new Vector(width / 2, height / 2 + 2),
            point_size: font_size,
            align: luxe.Text.TextAlign.center,
            align_vertical: luxe.Text.TextAlign.center,
            color: new luxe.Color(1.0, 1.0, 1.0),
            depth: this.depth + 0.1,

            letter_spacing: -1.4,
            sdf: true,
            shader: Luxe.renderer.shaders.bitmapfont.shader.clone('title-shader'),
            outline: 0.7,
            outline_color: new Color().rgb(0xa55004)
        });

        Actuate.tween(label, 3.0, { letter_spacing: -0.5 }).reflect().repeat();

        enabled = !disabled;

        particle_color = new Color(1, 1, 1, 0.5);
        ps = new ParticleSystem();
        pe = new ParticleEmitter({
			name: 'tile_particle_emitter', 
			rate: 8,
			cache_size: 32,
			cache_wrap: true,
			modules: [
				new AreaSpawnModule({
                    size: new Vector(width, height),
                    inside: false
                }),
				new LifeTimeModule({
					lifetime: 0.5,
					lifetime_max: 1
				}),
                new ColorLifeModule({
                    initial_color: particle_color
                }),
				new SizeLifeModule({
					initial_size: new Vector(5,5),
					end_size: new Vector(2,2)
				}),
				new DirectionModule({
					direction: 0,
					direction_variance: 360,
                    speed: 10
				})
                // new particles.modules.RadialAccelModule({
                //     accel: 500
                // })
			]
		});
        pe.stop();
		ps.add(pe);
        pe.position.copy_from(options.pos);

        this.scale.y = 0;
        Actuate
            .tween(this.scale, 0.3, { y: 1 })
            .delay(Math.random() * 0.2)
            .ease(luxe.tween.easing.Cubic.easeInOut)
            .onComplete((options.no_shake == true) ? function() {} : Luxe.camera.shake.bind(0.5));
    }

    public function get_top_pos() {
        return new Vector(pos.x + width / 2, pos.y);
    }

    public function get_center_pos() {
        return new Vector(pos.x + width / 2, pos.y + height / 2);
    }

    override function onmousemove(event :MouseEvent) {
        var world_pos = Luxe.camera.screen_point_to_world(event.pos);
        if (point_inside_AABB(world_pos)) {
            if (!hovered) {
                hovered = true;
                color.tween(0.1, { r: 1.0, g: 0.9, b: 0.9 });
                pe.start();
                Actuate
                    .tween(this.pos, 0.3, { y: this.pos.y + 2 })
                    .reflect()
                    .repeat()
                    .ease(luxe.tween.easing.Sine.easeInOut);
            }
        } else {
            if (hovered) {
                hovered = false;
                pe.stop();
                Actuate.stop(this.pos);
                Actuate.tween(this.pos, 0.3, { y: start_pos.y });
                color.tween(0.1, { r: 1.0, g: 1.0, b: 1.0 });
            }
        }
    }

    override public function onmouseup(event :MouseEvent) {
        var world_pos = Luxe.camera.screen_point_to_world(event.pos);
        if (point_inside_AABB(world_pos)) {
            play_sound('ui_click');
            on_click();
        }
    }

    override public function update(dt :Float) {
        super.update(dt);
        ps.update(dt);
    }

    override public function ondestroy() {
        super.ondestroy();
        ps.destroy();
    }

    public function color_burst(?duration :Float) {
        var old_color = particle_color.clone();
        particle_color.set(1, 1, 0, 1);
        pe.rate = 32;
        pe.start();
        if (duration != null) {
            particle_color
                .tween(0.3, { r: old_color.r, g: old_color.g, b: old_color.b, a: old_color.a })
                .onComplete(function(_) {
                    pe.rate = 8;
                    pe.stop();
                })
                .delay(duration);
        }
    }

    function get_text() {
        return label.text;
    }

    function set_text(t :String) {
        return (label.text = t);
    }

    function get_enabled() :Bool {
        return is_enabled;
    }

    function set_enabled(value :Bool) {
        if (is_enabled == value) return value;
        is_enabled = value;
        if (value) {
            color.tween(0.3, { a: 1.0 });
            label.outline_color.tween(0.3, { r: 0.65, g: 0.31, b: 0.02 });
        } else {
            if (pe != null) pe.stop();
            Actuate.stop(this.pos);
            Actuate.tween(this.pos, 0.3, { y: start_pos.y });
            color.tween(0.3, { a: 0.2 });
            label.outline_color.tween(0.3, { r: 0.5, g: 0.5, b: 0.5 });
        }
        return is_enabled;
    }

    function play_sound(id :String) {
        var sound = Luxe.resources.audio(Settings.get_sound_file_path(id));
        Luxe.audio.play(sound.source);
    }

    /** Returns true if a point is inside the AABB unrotated */
    public function point_inside_AABB(_p :Vector) :Bool {
        if (!enabled) return false;
        if (pos == null) return false;
        if (size == null) return false;

        // scaled size
        // var _s_x = size.x * scale.x * 0.5  /* hack */;
        // var _s_y = size.y * scale.y * 0.5 /* hack */;

        if (_p.x < pos.x) return false;
        if (_p.y < pos.y) return false;
        if (_p.x > pos.x + width) return false;
        if (_p.y > pos.y + height) return false;

        return true;
    }
}
