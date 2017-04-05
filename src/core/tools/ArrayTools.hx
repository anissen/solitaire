package core.tools;

class ArrayTools {
    static inline function random_value(value :Int, ?random :Int->Int) {
        return (random != null ? random(value) : Std.random(value));
    }

    static public function random<T>(array :Array<T>, ?random :Int->Int) :T {
        return array[random_value(array.length, random)];
    }

    static public function empty<T>(array :Array<T>) :Bool {
        return (array.length == 0);
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

    static public function clear<T>(array :Array<T>) {
        array.splice(0, array.length);
        return array;
    }
}
