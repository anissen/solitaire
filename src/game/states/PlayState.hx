
package game.states;

import core.models.Deck.InfiniteDeck;
import luxe.States.State;
import luxe.Vector;
import luxe.Sprite;
import luxe.Color;
import luxe.tween.Actuate;

import game.entities.Tile;
import game.components.Clickable;
import game.components.MouseUp;
import game.components.DragOver;

import snow.api.Promise;
import core.models.Game;

using game.tools.TweenTools;

typedef Card = Tile;

class PlayState extends State {
    static public var StateId :String = 'PlayState';
    var grabbed_card :Tile = null;
    var game :Game; // TODO: Don't aggregate Game here! Reference it from a static context

    var tiles_x = 3;
    var tiles_y = 3;
    var tile_size = 60;
    var margin = 10;

    var suits = 3;
    var quest_values = 12; // 13
    var card_values  = 8;  // 10
    var reshuffle_count :Int;

    var quests :Array<Card>;
    var tiles :Array<Card>;
    var collection :Array<Card>;

    var scoreText :luxe.Text;
    var score :Int;

    var quest_matches :Array<Card>;

    public function new() {
        super({ name: StateId });
        game = new Game();
        game.listen(handle_event);
        collection = [];
        quests = [];
        tiles = [];
        quest_matches = [];
        reshuffle_count = 0;
    }

    override function init() {

    }

    override function onenter(_) {
        // quest backgrounds
        for (x in 0 ... 3) {
            new Sprite({
                pos: get_pos(x, 0.5),
                texture: Luxe.resources.texture('assets/images/symbols/tile_bg.png'),
                size: new Vector(tile_size, tile_size * 2.6),
                color: new Color().rgb(0xBBBBBB)
            });
        }
        
        // board grid
        for (x in 0 ... tiles_x) {
            for (y in 0 ... tiles_y) {
                var sprite = new Sprite({
                    pos: get_pos(x, y + 2),
                    texture: Luxe.resources.texture('assets/images/symbols/tile_bg.png'),
                    size: new Vector(tile_size * 1.15, tile_size * 1.15),
                    color: new Color().rgb(0xDDDDDD)
                });
                sprite.add(new MouseUp(grid_clicked.bind(x, y)));
            }
        }

        // card grid
        for (x in 0 ... 3) {
            var sprite = new Sprite({
                pos: get_pos(x, tiles_y + 2 + 0.1),
                texture: Luxe.resources.texture('assets/images/symbols/tile_bg.png'),
                size: new Vector(tile_size * 1.4, tile_size * 1.4),
                color: new Color().rgb(0xCCCCCC)
            });
            sprite.add(new MouseUp(card_grid_clicked));
        }

        var deck_cards = [];
        for (suit in 0 ... suits) {
            for (value in 0 ... card_values) {
                deck_cards.push({ suit: suit, stacked: (value >= 10) });
            }
        }

        var quest_cards = [];
        for (suit in 0 ... suits) {
            for (value in 0 ... quest_values) {
                quest_cards.push({ suit: suit, stacked: (value >= 10) });
            }
        }

        scoreText = new luxe.Text({
            pos: get_pos(1, -1),
            align: center,
            text: '0'
        });
        score = 0;

        var deck = new InfiniteDeck(deck_cards, function(data) {
            var tile = create_tile(data.suit, data.stacked, tile_size);
            tile.pos = get_pos(1, tiles_y + 3);
            return tile;
        });
        var quest_deck = new InfiniteDeck(quest_cards, function(data) {
            var tile = create_tile(data.suit, data.stacked, tile_size * 0.5);
            tile.pos = get_pos(1, -2);
            return tile;
        });
        deck.on_reshuffling = function() {
            reshuffle_count++;
            if (reshuffle_count == 1) {
                deck.add_cards([ for (value in 0 ... card_values) { suit: 3, stacked: (value >= 10) } ]);
                quest_deck.add_cards([ for (value in 0 ... quest_values) { suit: 3, stacked: (value >= 10) } ]);
                quest_deck.reshuffle();
            } else if (reshuffle_count == 2) {
                deck.add_cards([ for (value in 0 ... card_values) { suit: 4, stacked: (value >= 10) } ]);
                quest_deck.add_cards([ for (value in 0 ... quest_values) { suit: 4, stacked: (value >= 10) } ]);
                quest_deck.reshuffle();
            }
        };
        game.new_game(tiles_x, tiles_y, deck, quest_deck);
    }

    function create_tile(suit :Int, stacked :Bool, size :Float) {
        var tile = new Tile({
            pos: get_pos(0, tiles_y + 3),
            size: size * 1.25, // HACK
            color: new Color().rgb(switch (suit) { 
                // http://www.colourlovers.com/palette/434904/espresso_rainbow
                case 0: 0x0db8b5; // blue
                case 1: 0xffe433; // yellow
                case 2: 0xd92727; // red
                case 3: 0x6fcc43; // green
                // case 4: 0xfc8f12; // orange
                case 4: 0xd00fc3; // purple
                case _: throw 'invalid enum';
            }),
            texture: Luxe.resources.texture('assets/images/symbols/' + switch (suit) {
                case 0: 'square.png';
                case 1: 'circle.png';
                case 2: 'triangle.png';
                case 3: 'diamond.png';
                case 4: 'star.png';
                case _: throw 'invalid enum';
            }),
            suit: suit,
            stacked: stacked,
            depth: 2
        });
        return tile;
    }

    function get_pos(tile_x :Float, tile_y :Float) {
        return new Vector(
            35 + tile_size / 2 + tile_x * (tile_size + margin),
            50 + tile_size / 2 + tile_y * (tile_size + margin)
        );
    }

    function handle_event(event :core.models.Game.Event) :Promise {
        return switch (event) {
            case Draw(cards): handle_draw(cards);
            case NewQuest(quest): handle_new_quest(quest);
            case TileRemoved(card): handle_tile_removed(card); Promise.resolve();
            case Collected(cards, quest): handle_collected(cards, quest);
            case Stacked(card): handle_stacked(card); Promise.resolve();
            case Score(score): handle_score(score);
            case GameOver: handle_game_over();
        }
    }

    function handle_draw(cards :Array<Card>) {
        var x = 0;
        var tween = null;
        for (card in cards) {
            var new_pos = get_pos(x, tiles_y + 2 + 0.1);
            tween = tween_pos(card, new_pos).delay(x * 0.1);
            card.add(new Clickable(card_clicked));
            tiles.push(card);
            x++;
        }
        return (tween != null ? tween.toPromise() : Promise.resolve());
    }

    function handle_new_quest(quest :Array<Card>) {
        var count = 0;
        var delay_count = 0;
        var tween = null;
        for (tile in quests) {
            var new_pos = get_pos(Math.floor(count / 3), (count % 3) * 0.5);
            if (Math.abs(tile.pos.x - new_pos.x) > 0.1 || Math.abs(tile.pos.y - new_pos.y) > 0.1) { // hack to skip already positioned tiles
                tween = tween_pos(tile, new_pos).delay(delay_count * 0.1);
                delay_count++;
            }
            count++;
        }
        for (card in quest) {
            var new_pos = get_pos(Math.floor(count / 3), (count % 3) * 0.5);
            tween = tween_pos(card, new_pos).delay(delay_count * 0.1);
            quests.push(card);
            delay_count++;
            count++;
        }
        return (tween != null ? tween.toPromise() : Promise.resolve());
    }

    function tween_pos(sprite :Sprite, pos :Vector, duration :Float = 0.2) {
        return Actuate.tween(sprite.pos, duration, { x: pos.x, y: pos.y }).onUpdate(function() {
            if (sprite != null && sprite.transform != null) {
                sprite.transform.dirty = true;
            }
        });
    }

    function handle_collected(cards :Array<Card>, quest :Array<Card>) {
        quest_matches = [];

        for (card in quest) {
            quests.remove(card);
            card.destroy();
        }
        return Promise.resolve();
    }

    function handle_stacked(card :Card) {
        card.stacked = true;
    }

    function handle_tile_removed(card :Card) {
        tiles.remove(card);
        card.destroy();
    }

    function handle_score(score :Int) {
        var scoreDiff = score - this.score;
        var tween = Actuate.tween(this, scoreDiff * 0.05, { score: score }).onUpdate(function() { scoreText.text = '${Std.int(this.score)}'; });
        return tween.toPromise();
    }

    function handle_game_over() {
        var tween = Luxe.renderer.clear_color.tween(1.0, { r: 1.0, g: 0.2, b: 0.2 });
        return tween.toPromise();
    }

    function grid_clicked(x :Int, y :Int, sprite :Sprite) {
        if (grabbed_card == null) return;
        if (!game.is_placement_valid(x, y)) return; // TODO: Some indication hereof!

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

    function card_grid_clicked(sprite :Sprite) {
        if (grabbed_card == null) return;
        grabbed_card.pos = sprite.pos.clone();
        grabbed_card = null;
    }

    function tile_dragover(sprite :Sprite) {
        var tile :Tile = cast sprite;
        if (grabbed_card == null && collection.length > 0 && collection.indexOf(tile) == -1) {
            add_to_collection(tile);
        }
    }

    function tile_clicked(sprite :Sprite) {
        var tile :Tile = cast sprite;
        add_to_collection(tile);
    }

    function add_to_collection(tile :Tile) {
        collection.push(tile);
        if (!game.is_collection_valid(collection)) {
            collection = [];
            quest_matches = [];
            return;
        }

        if (collection.length == 3) {
            game.do_action(Collect(collection));
            collection = [];
            quest_matches = [];
        } else {
            quest_matches = game.get_matching_quest_parts(collection);
        }
    }

    function card_clicked(sprite :Sprite) {
        grabbed_card = cast sprite;
        grabbed_card.depth = 3;
        collection = [];
        quest_matches = [];
    }

    override function onleave(_) {

    }

    override function onmousemove(event :luxe.Input.MouseEvent) {
        if (grabbed_card != null) {
            var world_pos = Luxe.camera.screen_point_to_world(event.pos);
            grabbed_card.pos = world_pos;
        }
    }

    override function onrender() {
        for (tile in collection) {
            Luxe.draw.box({
                x: tile.pos.x - (tile_size / 2) - 4,
                y: tile.pos.y - (tile_size / 2) - 4,
                h: tile_size + 8 + 4,
                w: tile_size + 8,
                color: new Color(1, 0, 1, 0.4),
                depth: 1,
                immediate: true
            });
        }
        for (tile in quest_matches) {
            Luxe.draw.box({
                x: tile.pos.x - (tile_size / 4) - 2,
                y: tile.pos.y - (tile_size / 4) - 2,
                h: tile_size / 2 + 4 + 2,
                w: tile_size / 2 + 4,
                color: new Color(1, 0, 1, 0.4),
                depth: 1,
                immediate: true
            });
        }
    }

    override function update(dt :Float) {

    }
}
