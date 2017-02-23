
package game.states;

import luxe.States.State;
import luxe.Vector;
import luxe.Sprite;
import luxe.Color;

import game.entities.Tile;
import game.components.Clickable;
import game.components.MouseUp;
import game.components.DragOver;

import snow.api.Promise;
import core.models.Deck.Card;
import core.models.Game;

class PlayState extends State {
    static public var StateId :String = 'PlayState';
    var grabbed_card :Tile = null;
    var game :Game; // TODO: Don't aggregate Game here! Reference it from a static context

    var tiles_x = 3;
    var tiles_y = 3;
    var tile_size = 64;
    var margin = 8;

    var quests :Array<Card>;
    var tiles :Array<Card>;
    var collection :Array<Card>;

    var scoreText :luxe.Text;

    public function new() {
        super({ name: StateId });
        game = new Game();
        game.listen(handle_event);
        collection = [];
        quests = [];
        tiles = [];
    }

    override function init() {
        
    }

    override function onenter(_) {
        for (x in 0 ... tiles_x) {
            for (y in 0 ... tiles_y) {
                var sprite = new Sprite({
                    pos: get_pos(x, y + 2),
                    size: new Vector(tile_size, tile_size),
                    color: new Color(0.3, 0.3, 0.3)
                });
                sprite.add(new MouseUp(grid_clicked.bind(x, y)));
            }
        }

        var tile_deck = [];
        for (suit in 0 ... 4) {
            for (value in 0 ... 13) {
                var tile = new Tile({
                    pos: get_pos(0, tiles_y + 3),
                    size: tile_size,
                    color: switch (suit) {
                        case 0: new Color(1.0, 0.0, 0.0);
                        case 1: new Color(0.0, 1.0, 0.0);
                        case 2: new Color(0.0, 0.0, 1.0);
                        case 3: new Color(0.0, 1.0, 1.0);
                        case _: new Color();
                    },
                    suit: suit,
                    stacked: false,
                    depth: 2
                });
                tile.visible = false;
                tile_deck.push(tile);
            }
        }

        for (x in 0 ... 3) {
            new Sprite({
                pos: get_pos(x, 0.5),
                size: new Vector(tile_size, tile_size * 2),
                color: new Color(0.5, 0.5, 0.5)
            });
        }

        var quest_deck = [];
        for (suit in 0 ... 4) {
            for (value in 0 ... 13) {
                var tile = new Tile({
                    pos: get_pos(0, tiles_y + 3),
                    size: tile_size / 2,
                    color: switch (suit) {
                        case 0: new Color(1.0, 0.0, 0.0);
                        case 1: new Color(0.0, 1.0, 0.0);
                        case 2: new Color(0.0, 0.0, 1.0);
                        case 3: new Color(0.0, 1.0, 1.0);
                        case _: new Color();
                    },
                    suit: suit,
                    stacked: (value >= 10),
                    depth: 2
                });
                tile.visible = false;
                quest_deck.push(tile);
            }
        }

        scoreText = new luxe.Text({
            // pos: new Vector(Luxe.screen.mid.x, Luxe.screen.height - 64),
            pos: new Vector(Luxe.screen.width - 48, 64),
            align: center,
            text: '0'
        });

        game.new_game(tiles_x, tiles_y, tile_deck, quest_deck);
    }

    function get_pos(tile_x :Float, tile_y :Float) {
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
            case Score(score): handle_score(score); Promise.resolve();
        }
    }

    function handle_draw(cards :Array<Card>) {
        // trace('handle_draw: $cards');
        var x = 0;
        for (card in cards) {
            card.visible = true;
            card.pos = get_pos(x++, tiles_y + 2);
            card.add(new Clickable(card_clicked));
            tiles.push(card);
        }
        return Promise.resolve();
    }

    function handle_new_quest(quest :Array<Card>) {
        var count = 0;
        for (tile in quests) {
            // trace('handle_new_quest ${count % 3}, ${Math.floor(count / 3)}');
            tile.pos = get_pos(Math.floor(count / 3), (count % 3) * 0.5);
            count++;
        }
        for (card in quest) {
            card.visible = true;
            card.pos = get_pos(Math.floor(count / 3), (count % 3) * 0.5);
            quests.push(card);
            count++;
        }
        return Promise.resolve();
    }

    function handle_collected(cards :Array<Card>, quest :Array<Card>) {
        // trace('Collected!');
        for (card in quest) {
            quests.remove(card);
            card.destroy();
        }
        // for (card in cards) {
        //     tiles.remove(card);
        //     card.destroy();
        // }
    }

    function handle_stacked(card :Card) {
        // trace('Stacked!');
        card.stacked = true;
    }

    function handle_tile_removed(card :Card) {
        // trace('handle_changed_tile:');
        tiles.remove(card);
        card.destroy();
    }

    function handle_score(score :Int) {
        scoreText.text = '$score';
    }

    function grid_clicked(x :Int, y :Int, sprite :Sprite) {
        if (grabbed_card != null) {
            grabbed_card.pos = sprite.pos.clone();
            grabbed_card.grid_pos = { x: x, y: y };
            grabbed_card.remove('Clickable');
            game.do_action(Place(grabbed_card, x, y));
            var grabbed_card_copy = grabbed_card;
            Luxe.next(function() { // Hack to prevent tile_clicked to be triggered immediately
                grabbed_card_copy.add(new Clickable(tile_clicked));
                grabbed_card_copy.add(new DragOver(tile_dragover));
            });
            grabbed_card.depth = 2;
            grabbed_card = null;
        }
    }

    function tile_dragover(sprite :Sprite) {
        var tile :Tile = cast sprite;
        if (grabbed_card == null && collection.length > 0 && collection.indexOf(tile) == -1) {
            collection.push(tile);
            if (collection.length == 3) {
                game.do_action(Collect(collection));
                collection = [];
            }
        }
    }

    function tile_clicked(sprite :Sprite) {
        var tile :Tile = cast sprite;
        // trace('select tile $tile');
        collection.push(tile);
        if (collection.length == 3) {
            game.do_action(Collect(collection));
            collection = [];
        }
    }

    function card_clicked(sprite :Sprite) {
        grabbed_card = cast sprite;
        grabbed_card.depth = 3;
    }

    override function onleave(_) {

    }

    override function onmousemove(event :luxe.Input.MouseEvent) {
        if (grabbed_card != null) {
            grabbed_card.pos = event.pos.clone();
        }
    }

    override function onrender() {
        for (tile in tiles) {
            if (tile.grid_pos != null) continue; // hack to find cards, not tiles
            Luxe.draw.box({
                x: tile.pos.x - 32 - 2,
                y: tile.pos.y - 32 - 2,
                h: 64 + 4,
                w: 64 + 4,
                color: new Color(1, 1, 1, 1),
                depth: 1,
                immediate: true
            });
        }
        if (grabbed_card != null) {
            Luxe.draw.box({
                x: -5 + grabbed_card.pos.x - 32,
                y: -5 + grabbed_card.pos.y - 32,
                h: 64 + 10,
                w: 64 + 10,
                color: new Color(1, 1, 1, 1),
                depth: grabbed_card.depth - 1,
                immediate: true
            });
        }
        for (tile in collection) {
            Luxe.draw.box({
                x: tile.pos.x - 32 - 5,
                y: tile.pos.y - 32 - 5,
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
                r: 10,
                color: new Color(0.2, 0.7, 0.2, 0.8),
                depth: 3,
                immediate: true
            });
        }
        for (tile in tiles) {
            if (!tile.stacked) continue;
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
