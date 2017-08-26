package game.tools;

import luxe.Vector;

class VectorTools {
	static public function distance(pos1:Vector, pos2:Vector) : Float {
		return Vector.Subtract(pos1, pos2).length;
	}

	static public function cross2D(v1:Vector, v2:Vector) : Float {
		return (v1.x * v2.y) - (v1.y * v2.x);
	}

	static public function absolute(v:Vector) : Vector {
		return new Vector(Math.abs(v.x), Math.abs(v.y));
	}

	static public function setFromAngle(v:Vector, radians:Float) : Vector {
		v = new Vector(Math.cos(radians), Math.sin(radians));
		return v;
	}

	static public function tangent2D(v:Vector) : Vector {
		return new Vector(-v.y, v.x);
	}
}