
package game.components;

import luxe.Component;
import luxe.Vector;
import phoenix.geometry.Vertex;
import phoenix.geometry.*;
import phoenix.Batcher;
import luxe.Color.ColorHSL;
import luxe.utils.Maths;

using game.tools.VectorTools;

class TrailRenderer extends Component {

	var points : Array<Vector>;
	var trailGeometry : Geometry;

	public var maxLength : Float = 150.0;
	public var startSize : Float = 8.0;
	var endSize : Float = 0.0;

	public var trailColor : ColorHSL = new ColorHSL(200, 1, 0.5); //(0.1, 0.5, 0.8);

	public var depth :Float = 0; // hack
	// var time_dt :Float = 0;

	override function init() {
		points = [pos.clone()];

		trailGeometry = new Geometry({batcher: Luxe.renderer.batcher, primitive_type: PrimitiveType.triangles});
		trailGeometry.depth = depth;
	}

	override function update(dt : Float) {
		// time_dt += dt;
		if (points[0].distance(pos) > 10 /* || time_dt > 0.1 */) {
			// time_dt = 0;
			points.insert(0, pos.clone());
			cullPoints();
			updateGeometry();
		}
	}

	override function onremoved() {
		Luxe.renderer.batcher.remove(trailGeometry);
	}

	function cullPoints() {
		var totalLength : Float = 0;
		var prevPoint = null;
		var count = 0;
		for (p in points) {

			if (prevPoint != null) {
				totalLength += Vector.Subtract(p, prevPoint).length;
			}

			if (totalLength > maxLength) {
				break;
			}

			prevPoint = p;
			count++;
		}
		points = points.slice(0,count);
	}

	function updateGeometry() {
		trailGeometry.vertices = []; //clear vertices

		var prevPoint = null;
		var count : Float = 0;

		var mustFillGap = false;
		var prevQ2 = new Vector(0,0);
		var prevQ3 = new Vector(0,0);

		for (p in points) {

			if (prevPoint != null) {
				//tangent
				var tangent = Vector.Subtract(p, prevPoint).normalized.tangent2D();

				//changing size of trail
				var size0 = Maths.lerp(startSize, endSize, (count-1) / points.length);
				var size1 = Maths.lerp(startSize, endSize, count / points.length);

				//quad points
				var q0 = Vector.Add(prevPoint, Vector.Multiply(tangent, size0));
				var q1 = Vector.Add(prevPoint, Vector.Multiply(tangent, -1 * size0));
				var q2 = Vector.Add(p, Vector.Multiply(tangent, size1));
				var q3 = Vector.Add(p, Vector.Multiply(tangent, -1 * size1));

				//tri 1
				trailGeometry.add(new Vertex(q0));
				trailGeometry.add(new Vertex(q1));
				trailGeometry.add(new Vertex(q2));

				//tri 2
				trailGeometry.add(new Vertex(q3));
				trailGeometry.add(new Vertex(q2));
				trailGeometry.add(new Vertex(q1));

				//fill gaps w/ tris
				if (mustFillGap) {
					trailGeometry.add(new Vertex(prevPoint.clone()));
					trailGeometry.add(new Vertex(prevQ2.clone()));
					trailGeometry.add(new Vertex(q0));

					trailGeometry.add(new Vertex(prevPoint.clone()));
					trailGeometry.add(new Vertex(prevQ3.clone()));
					trailGeometry.add(new Vertex(q1));
				}

				//save values
				prevQ2 = q2;
				prevQ3 = q3;
				mustFillGap = true;
			}

			prevPoint = p;
			count++;
		}

		//re-apply color
		trailGeometry.color = trailColor;
	}
}
