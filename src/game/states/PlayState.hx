
package game.states;

import luxe.Input.MouseEvent;
import luxe.States.State;
import luxe.Vector;
import luxe.Sprite;
import luxe.tween.Actuate;
import luxe.Color;
import luxe.Text;

import game.entities.Tile;
import game.components.Clickable;

import snow.api.Promise;
import core.models.Deck.Card;

using Lambda;

class PlayState extends State {
    static public var StateId :String = 'PlayState';
    var selected_tile :Tile = null;
    var game :core.models.Game; // TODO: Don't aggregate Game here! Reference it from a static context

    var tiles_x = 4;
    var tiles_y = 3;
    var tile_size = 64;
    var margin = 8;

    var quests :Array<Tile>;
    var tiles :Array<Tile>;

    var selection :Array<{ x :Int, y :Int }>;

    public function new() {
        super({ name: StateId });
        game = new core.models.Game();
        game.listen(handle_event);
        selection = [];
        tiles = [];
        quests = [];
    }

    override function init() {

    }

    override function onenter(_) {
        for (x in 0 ... tiles_x) {
            for (y in 0 ... tiles_y) {
                var tile = new Tile({
                    pos: get_pos(x, y + 4),
                    size: tile_size,
                    color: new Color(0.3, 0.3, 0.3)
                });
                tile.grid_pos = { x: x, y: y };
                tile.add(new Clickable(grid_clicked));
                // tile.add(new Clickable(tile_selected));
            }
        }

        game.new_game();
    }

    function get_pos(tile_x :Int, tile_y :Int) {
        return new Vector(
            16 + tile_size / 2 + tile_x * (tile_size + margin),
            16 + tile_size / 2 + tile_y * (tile_size + margin)
        );
    }

    function handle_event(event :core.models.Game.Event) :Promise {
        return switch (event) {
            case Draw(cards): handle_draw(cards);
            case NewQuest(quest): handle_new_quest(quest);
            case ChangedTile(x, y, card): handle_changed_tile(x, y, card); Promise.resolve();
            case Selected(x, y): trace('Selected! $x $y'); Promise.resolve();
            case Collected(cards): handle_collected(cards); Promise.resolve();
            case Stacked(cards): handle_stacked(cards); Promise.resolve();
        }
    }

    function handle_draw(cards :Array<Card>) {
        trace('handle_draw: $cards');
        var x = 0;
        for (card in cards) {
            var tile = new Tile({
                pos: get_pos(x, tiles_y + 4 + 1),
                size: tile_size,
                color: switch (card.suit) {
                    case 0: new Color(1.0, 0.0, 0.0);
                    case 1: new Color(0.0, 1.0, 0.0);
                    case 2: new Color(0.0, 0.0, 1.0);
                    case 3: new Color(0.0, 1.0, 1.0);
                    case _: new Color();
                },
                card: card,
                depth: 2
            });
            tile.add(new Clickable(tile_clicked));
            tiles.push(tile);
            x++;
        }
        return Promise.resolve();
    }

    function handle_new_quest(quest :Array<Card>) {
        var x = 0;
        for (card in quest) {
            var y = Math.floor(quests.length / 3);
            var tile = new Tile({
                pos: get_pos(x, y),
                size: tile_size,
                color: switch (card.suit) {
                    case 0: new Color(1.0, 0.0, 0.0);
                    case 1: new Color(0.0, 1.0, 0.0);
                    case 2: new Color(0.0, 0.0, 1.0);
                    case 3: new Color(0.0, 1.0, 1.0);
                    case _: new Color();
                },
                card: card
            });
            quests.push(tile);
            x++;
        }
        return Promise.resolve();
    }

    function handle_collected(cards :Array<Card>) {
        trace('Collected! $cards');
        // maybe use selection variable
        // for (tile in tiles) {
        //     if (cards.indexOf(tile.card) != -1) {
        //         tiles.remove(tile);
        //         tile.destroy();
        //     }
        // }
    }

    function handle_stacked(cards :Array<Card>) {
        trace('Stacked! $cards');

        var stacked_card = cards.pop();
        stacked_card.stacked = true;

        // maybe use selection variable
        // for (tile in tiles) {
        //     if (cards.indexOf(tile.card) != -1) {
        //         tiles.remove(tile);
        //         tile.destroy();
        //     }
        // }
    }

    function handle_changed_tile(x :Int, y :Int, card :Card) {
        trace('handle_changed_tile: $x $y $card');
        for (tile in tiles) {
            if (tile.grid_pos == null) continue;
            if (tile.grid_pos.x == x && tile.grid_pos.y == y) {
                trace('found tile: $tile');
                if (card == null) {
                    tiles.remove(tile);
                    tile.destroy();
                } else {
                    tile.card = card;
                }
            }
        }
    }

    function grid_clicked(sprite :Sprite) {
        if (selected_tile != null) {
            var tile :Tile = cast sprite;
            selected_tile.pos = tile.pos.clone();
            selected_tile.grid_pos = tile.grid_pos;
            selected_tile.remove('Clickable');
            // selected_tile.add(new Clickable(tile_selected));
            var card = selected_tile.card;
            selected_tile = null;

            game.do_action(Place(card, tile.grid_pos.x, tile.grid_pos.y));
        } else {
            var tile :Tile = cast sprite;
            selection.push(tile.grid_pos);
            if (selection.length == 3) {
                game.do_action(Select(selection));
                selection = [];
            }
        }
    }

    function tile_clicked(sprite :Sprite) {
        selected_tile = cast sprite;
    }

    override function onleave(_) {

    }

    override function onmousemove(event :luxe.Input.MouseEvent) {
        if (selected_tile != null) {
            selected_tile.pos = event.pos.clone();
        }
    }

    override function onrender() {
        if (selected_tile != null) {
            Luxe.draw.box({
                x: -5 + selected_tile.pos.x - 32,
                y: -5 + selected_tile.pos.y - 32,
                h: 64 + 10,
                w: 64 + 10,
                color: new Color(1, 1, 1, 1),
                depth: selected_tile.depth - 1,
                immediate: true
            });
        }
        for (tile in selection) {
            var pos = get_pos(tile.x, tile.y + 4);
            Luxe.draw.box({
                x: pos.x - 32 - 5,
                y: pos.y - 32 - 5,
                h: 64 + 10,
                w: 64 + 10,
                color: new Color(1, 0, 1, 1),
                depth: 1,
                immediate: true
            });
        }
        for (quest in quests) {
            if (!quest.card.stacked) continue;
            Luxe.draw.circle({
                x: quest.pos.x,
                y: quest.pos.y,
                r: 20,
                color: new Color(0.2, 0.7, 0.2, 0.8),
                depth: 3,
                immediate: true
            });
        }
        for (tile in tiles) {
            if (!tile.card.stacked) continue;
            Luxe.draw.circle({
                x: tile.pos.x,
                y: tile.pos.y,
                r: 20,
                color: new Color(0.2, 0.7, 0.2, 0.8),
                depth: 3,
                immediate: true
            });
        }
    }

    override function update(dt :Float) {

    }
}
