package game.misc;

import luxe.Color;
import luxe.Ev;
import luxe.Parcel;
import luxe.ParcelProgress;
import luxe.Sprite;
import luxe.Text;
import luxe.tween.Actuate;

/**
 * ...
 * @author https://github.com/wimcake
 */
class ArcProgress extends ParcelProgress {
	var s :Sprite;
	var t :Text;
	var value :Float = 0.01;
	var cb :Void->Void;

	public function new(parcel :Parcel, ?color :Color, cb :Void->Void) {
		super({
			parcel: parcel,
			no_visuals: true,
			oncomplete: null
		});

		this.cb = cb;

		s = new Sprite({
			pos: Luxe.camera.center,
			centered: true,
			color: color,
			no_scene: true,
			geometry: Luxe.draw.arc( {
				immediate: true,
				x: 0.0,
				y: 0.0,
				r: 60.0,
				start_angle: 0.0,
				end_angle: 1.0
			})
		});

		t = new Text({
			pos: Luxe.camera.center,
			color: color,
			text: '',
			align: center,
			align_vertical: center,
			point_size: 18
		});

		parcel.load();
	}

	function upd(dt :Float) {
		t.text = '${Math.floor(value * 100)} %';
		s.rotation_z += 360 * dt;
		s.geometry = Luxe.draw.arc( {
			immediate: true,
			x: 0.0,
			y: 0.0,
			r: 60.0,
			start_angle: 0.0,
			end_angle: value * 360
		} );
	}

	function complete() {
		Luxe.off(Ev.update, upd);
		s.destroy(true);
		t.destroy(true);
		cb();
		cb = null;
	}

	override public function onbegin(_parcel :Parcel) {
		super.onbegin(_parcel);
		Luxe.on(Ev.update, upd);
	}

	override public function onprogress(_state :ParcelChange) {
		super.onprogress(_state);
        value = _state.index / _state.total;
		// Actuate.tween(this, 0.1, { value: _state.index / _state.total } );
	}

	override public function oncomplete(_parcel :Parcel) {
		// Actuate.tween(this, 0.1, { value: 1.0 } ).onComplete(complete);
		//super.oncomplete(_parcel);
        complete();
	}
}
