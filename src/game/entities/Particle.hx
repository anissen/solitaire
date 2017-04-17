package game.entities;

import luxe.Vector;
import luxe.Sprite;

typedef ParticleOptions = {
    > luxe.options.SpriteOptions,
    target :Vector,
    duration :Float,
    delay :Float
}

class Particle extends Sprite {
    static public var Count :Int = 0;
    var start :Vector;
    var target :Vector;
    var duration :Float;
    var t :Float;

    public function new(options :ParticleOptions) {
        super(options);

        start = options.pos.clone();
        target = options.target.clone();
        duration = options.duration;
        t = -options.delay;
        Particle.Count++;
    }

    public override function update(dt :Float) {
        t += dt;
        pos = start.clone().lerp(target, t / duration); // TODO: Use static version when merged
        // pos = Vector.Lerp(start, target, t / duration);
        
    }

    override public function ondestroy() {
        Particle.Count--;
        super.ondestroy();
    }
}
