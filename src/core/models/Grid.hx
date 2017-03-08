package core.models;

class Grid<T> {
    var tiles :Array<Array<T>>;
    var width :Int;
    var height :Int;

    public function new(width :Int, height :Int, ?default_value :T) {
        this.width = width;
        this.height = height;
        tiles = [
            for (y in 0 ... height) [
                for (x in 0 ... width)
                    default_value
            ]
        ];
    }

    public function get_width() {
        return width;
    }

    public function get_height() {
        return height;
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
