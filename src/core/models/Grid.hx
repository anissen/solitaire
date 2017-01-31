package core.models;

class Grid<T> {
    var tiles :Array<Array<T>>;

    public function new(width :Int, height :Int, ?default_value :T) {
        tiles = [
            for (y in 0 ... height) [
                for (x in 0 ... width)
                    default_value
            ]
        ];
    }

    public function get_tiles() {
        return tiles;
    }

    public function get_tile(x :Int, y :Int) {
        return tiles[y][x];
    }

    public function set_tile(x :Int, y :Int, value :T) {
        tiles[y][x] = value;
    }
}
