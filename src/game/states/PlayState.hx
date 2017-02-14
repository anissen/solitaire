
package game.states;

import luxe.States.State;
import luxe.Vector;
import luxe.Sprite;
import luxe.Color;

import game.entities.Tile;
import game.components.Clickable;

import snow.api.Promise;
import core.models.Deck.Card;
import core.models.Game;

/*
TODO:
- maybe: make it possible to pass Tile into game as an generic argument to be used as a core model, e.g. SetCardOnGrid(x, y, tile) where tile has suit, stacked
*/

class PlayState extends State {
    static public var StateId :String = 'PlayState';
    var selected_tile :Tile = null;
    var game :Game; // TODO: Don't aggregate Game here! Reference it from a static context

    var tiles_x = 4;
    var tiles_y = 3;
    var tile_size = 64;
    var margin = 8;

    var quests :Map<Int, Tile>;

    var selection :Array<{ x :Int, y :Int }>;

    public function new() {
        super({ name: StateId });
        game = new Game();
        game.listen(handle_event);
        selection = [];
        quests = new Map();
    }

    override function init() {
        
    }

    override function onenter(_) {
        var tiles :Array<core.models.Deck.ICard> = [];
        for (x in 0 ... tiles_x) {
            for (y in 0 ... tiles_y) {
                var tile = new Tile({
                    pos: get_pos(x, y + 4),
                    size: tile_size,
                    color: new Color(0.3, 0.3, 0.3),
                    suit: tiles_x,
                    stacked: false
                });
                tile.grid_pos = { x: x, y: y };
                tile.add(new Clickable(grid_clicked));
                // tile.add(new Clickable(tile_selected));
                tiles.push(tile);
            }
        }

        game.new_game(tiles, []); // TODO: Add quest cards
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
            case TileRemoved(card): handle_tile_removed(card); Promise.resolve();
            case Collected(cards, quest): handle_collected(cards, quest); Promise.resolve();
            case Stacked(card): handle_stacked(card); Promise.resolve();
        }
    }

    function handle_draw(cards :Array<Card>) {
        trace('handle_draw: $cards');
        var x = 0;
        // for (card in cards) {
        //     var tile = new Tile({
        //         pos: get_pos(x, tiles_y + 4 + 1),
        //         size: tile_size,
        //         color: switch (card.suit) {
        //             case 0: new Color(1.0, 0.0, 0.0);
        //             case 1: new Color(0.0, 1.0, 0.0);
        //             case 2: new Color(0.0, 0.0, 1.0);
        //             case 3: new Color(0.0, 1.0, 1.0);
        //             case _: new Color();
        //         },
        //         card: card,
        //         depth: 2
        //     });
        //     tile.add(new Clickable(tile_clicked));
        //     card.tile = tile;
        //     x++;
        // }
        return Promise.resolve();
    }

    function handle_new_quest(quest :Array<Card>) {
        var count = 0;
        for (tile in quests) {
            tile.pos = get_pos(count % 3, Math.floor(count / 3));
            count++;
        }
        var x = 0;
        // for (card in quest) {
        //     var y = Math.floor(count / 3);
        //     var tile = new Tile({
        //         pos: get_pos(x, y),
        //         size: tile_size,
        //         color: switch (card.suit) {
        //             case 0: new Color(1.0, 0.0, 0.0);
        //             case 1: new Color(0.0, 1.0, 0.0);
        //             case 2: new Color(0.0, 0.0, 1.0);
        //             case 3: new Color(0.0, 1.0, 1.0);
        //             case _: new Color();
        //         },
        //         card: card
        //     });
        //     // trace('storing quest tile with id ${card.id}');
        //     quests[card.id] = tile;
        //     x++;
        // }
        return Promise.resolve();
    }

    function handle_collected(cards :Array<Card>, quest :Array<Card>) {
        // trace('Collected! $cards');

        // for (quest_card in quest) {
        //     var tile = quests.get(quest_card.id);
        //     if (tile == null) {
        //         trace('Cannot locate quest tile for $quest_card');
        //         continue;
        //     }
        //     tile.destroy();
        //     quests.remove(quest_card.id);
        // }
        // for (card in cards) {
        //     card.tile.destroy();
        // }
    }

    function handle_stacked(card :Card) {
        // trace('Stacked! $cards');

        var stacked_card = card;
        // stacked_card.stacked = true;
    }

    function handle_tile_removed(card :Card) {
        //trace('handle_changed_tile: $x $y $card');
        // card.tile.destroy();
    }

    function grid_clicked(sprite :Sprite) {
        if (selected_tile != null) {
            var tile :Tile = cast sprite;
            selected_tile.pos = tile.pos.clone();
            selected_tile.grid_pos = tile.grid_pos;
            selected_tile.remove('Clickable');
            // selected_tile.add(new Clickable(tile_selected));
            // var card = selected_tile.card;
            selected_tile = null;

            game.do_action(Place(tile, tile.grid_pos.x, tile.grid_pos.y));
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
            if (!quest.stacked) continue;
            Luxe.draw.circle({
                x: quest.pos.x,
                y: quest.pos.y,
                r: 20,
                color: new Color(0.2, 0.7, 0.2, 0.8),
                depth: 3,
                immediate: true
            });
        }
        // for (tile in tiles) {
        //     if (!tile.card.stacked) continue;
        //     Luxe.draw.circle({
        //         x: tile.pos.x,
        //         y: tile.pos.y,
        //         r: 20,
        //         color: new Color(0.2, 0.7, 0.2, 0.8),
        //         depth: 3,
        //         immediate: true
        //     });
        // }
    }

    override function update(dt :Float) {

    }
}
