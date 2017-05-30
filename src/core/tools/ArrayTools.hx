package core.tools;

@:forward(length, concat, join, toString, indexOf, lastIndexOf, copy, iterator, map, filter)
abstract ImmutableArray<T>(Array<T>) from Array<T> to Iterable<T> {
	@:arrayAccess @:extern inline public function arrayAccess(key:Int):T return this[key];
}

class ArrayTools {
    static inline function random_value(value :Int, ?random :Int->Int) {
        return (random != null ? random(value) : Std.random(value));
    }

    static public function random<T>(array :Array<T>, ?random :Int->Int) :T {
        return array[random_value(array.length, random)];
    }

    static public function empty<T>(array :Array<T>) :Bool {
        return (array == null || array.length == 0);
    }

    static public function has<T>(array :Array<T>, value :T) :Bool {
        return (array.indexOf(value) > -1);
    }

    static public function shuffle<T>(array :Array<T>, ?random :Int->Int) :Array<T> {
        var indexes = [ for (i in 0 ... array.length) i ];
        var result = [];
        while (indexes.length > 0) {
            var pos = random_value(indexes.length, random);
            var index = indexes[pos];
            indexes.splice(pos, 1);
            result.push(array[index]);
        }
        return result;
    }

    static public function append<T>(array :Array<T>, other :Array<T>) :Array<T> {
        for (e in other) array.push(e);
        return array;
    }

    static public function first<T>(array :Array<T>) :Null<T> {
        return array[0];
    }

    static public function rest<T>(array :Array<T>, fromIndex :Int = 1) :Array<T> {
        return array.splice(fromIndex, array.length - fromIndex);
    }

    static public function last<T>(array :Array<T>) :Null<T> {
        return array[array.length - 1];
    }

    static public function clear<T>(array :Array<T>) :Array<T> {
        array.splice(0, array.length);
        return array;
    }

    static public function to_immutable<T>(array :Array<T>) :ImmutableArray<T> {
        return cast array;
    }
}
