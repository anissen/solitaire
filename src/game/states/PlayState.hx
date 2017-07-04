
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

/*
    Stuff to be saved:
    * Deck list
    * Hand list
    * Board
    * Score
    * Game seed (for this instant in the game!)
*/

class PlayState extends State {
    static public var StateId :String = 'PlayState';
    var grabbed_card :Tile = null;
    var grabbed_card_origin :Vector;
    var grabbed_card_offset :Vector;

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
    var counting_score :Float;
    var score :Int;

    var game_over :Bool;

    var quest_matches :Array<Card>;

    public function new() {
        super({ name: StateId });
        // game = new Game();
        Game.Instance.listen(handle_event);
    }

    override function init() {

    }

    override function onenter(_) {
        Actuate.reset();
        Luxe.camera.center = Vector.Multiply(Luxe.camera.size, 0.5);

        // Luxe.io.string_save('save', null);
        var could_load_game = load_game();
        if (!could_load_game) handle_new_game();
    }

    function handle_new_game() {
        Luxe.scene.empty();

        collection = [];
        quests = [];
        tiles = [];
        quest_matches = [];
        reshuffle_count = 0;
        score = 0;
        counting_score = 0;
        game_over = false;
        Tile.CardId = 0; // reset card Ids
        Luxe.utils.random.initial = 42;


        // var bg_texture = Luxe.resources.texture('assets/images/symbols/wool.png');
        // bg_texture.clamp_s = phoenix.Texture.ClampType.repeat;
        // bg_texture.clamp_t = phoenix.Texture.ClampType.repeat;
        // bg_texture.width = Luxe.screen.w * 2;
        // bg_texture.height = Luxe.screen.h * 2;

        // new Sprite({
        //     centered: true,
        //     pos: Luxe.screen.mid.clone(),
        //     texture: bg_texture,
        //     depth: -1
        // });
        
        // quest backgrounds
        for (x in 0 ... 3) {
            new Sprite({
                pos: get_pos(x, 0.5),
                texture: Luxe.resources.texture('assets/images/symbols/tile_bg.png'),
                size: new Vector(tile_size, tile_size * 2.6),
                color: Settings.QUEST_BG_COLOR
            });
        }
        
        // board grid
        for (x in 0 ... tiles_x) {
            for (y in 0 ... tiles_y) {
                var sprite = new Sprite({
                    pos: get_pos(x, y + 2),
                    texture: Luxe.resources.texture('assets/images/symbols/tile_bg.png'),
                    size: new Vector(tile_size * 1.15, tile_size * 1.15),
                    color: Settings.BOARD_BG_COLOR
                });
                sprite.add(new MouseUp(grid_clicked.bind(x, y)));
                // tween_pos(sprite, get_pos(x+3, y + 2), 10);
            }
        }

        // card grid
        for (x in 0 ... 3) {
            var sprite = new Sprite({
                pos: get_pos(x, tiles_y + 2 + 0.1),
                texture: Luxe.resources.texture('assets/images/symbols/tile_bg.png'),
                size: new Vector(tile_size * 1.4, tile_size * 1.4),
                color: Settings.CARD_BG_COLOR
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
            pos: get_pos(1, -0.75),
            align: center,
            align_vertical: center,
            text: '0'
        });

        var deck = new InfiniteDeck(deck_cards, function(data) {
            var tile = create_tile(data.suit, data.stacked, tile_size);
            tile.pos = get_pos(1, tiles_y + 3.5);
            return tile;
        }, random_func);
        var quest_deck = new InfiniteDeck(quest_cards, function(data) {
            var tile = create_tile(data.suit, data.stacked, tile_size * 0.5);
            tile.pos = get_pos(1, -2);
            return tile;
        }, random_func);
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
        Game.Instance.new_game(tiles_x, tiles_y, deck, quest_deck);

        return Promise.resolve();
    }

    function random_func(v :Int) {
        return Luxe.utils.random.int(v);
    }

    function create_tile(suit :Int, stacked :Bool, size :Float) {
        var tile = new Tile({
            pos: get_pos(0, tiles_y + 3),
            size: size * 1.25, // HACK
            color: Settings.SYMBOL_COLORS[suit],
            texture: Luxe.resources.texture('assets/images/symbols/' + switch (suit) {
                case 0: 'square.png';
                case 1: 'circle.png';
                case 2: 'triangle.png';
                case 3: 'diamond.png';
                case 4: 'hex.png';
                case _: throw 'invalid enum';
            }),
            suit: suit,
            stacked: stacked,
            depth: 2
        });
        Game.CardManager[tile.cardId] = tile;
        return tile;
    }

    function get_pos(tile_x :Float, tile_y :Float) {
        return new Vector(
            35 + tile_size / 2 + tile_x * (tile_size + margin),
            50 + tile_size / 2 + tile_y * (tile_size + margin)
        );
    }

    function handle_event(event :core.models.Game.Event) :Promise {
        // trace(event);
        return switch (event) {
            case NewGame: handle_new_game();
            case Draw(cards): handle_draw(cards);
            case NewQuest(quest): handle_new_quest(quest);
            case TilePlaced(card, x, y): handle_tile_placed(card, x, y);
            case TileRemoved(card): handle_tile_removed(card);
            case Collected(cards, quest): handle_collected(cards, quest);
            case Stacked(card): handle_stacked(card);
            case Score(score, card): handle_score(score, card);
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
        // trace('tween_pos', sprite);
        // return Actuate.tween(this, duration, { score: score + 1 });
        // var temp_pos = sprite.pos.clone();
        return Actuate.tween(sprite.pos, duration, { x: pos.x, y: pos.y }); /* .onUpdate(function() {
            if (sprite != null && sprite.transform != null && !sprite.destroyed) {
                sprite.pos.set_xy(temp_pos.x, temp_pos.y);
                // sprite.transform.dirty = true;
            }
        }); */
    }

    function handle_collected(cards :Array<Card>, quest :Array<Card>) {
        quest_matches = [];

        for (card in quest) {
            quests.remove(card);
            // Actuate.stop(card);
            card.destroy();
        }
        return Promise.resolve();
    }

    function handle_stacked(card :Card) {
        card.stacked = true;

        return Promise.resolve();
    }

    function handle_tile_placed(card :Card, x :Int, y :Int) {
        // card.pos = get_pos(x, y + 2);
        var tween = tween_pos(card, get_pos(x, y + 2), 0.1);
        card.grid_pos = { x: x, y: y };
        card.depth = 2;
        if (card.has('Clickable')) card.remove('Clickable');
        // card.add(new Clickable(tile_clicked));
        // card.add(new DragOver(tile_dragover));

        Luxe.next(function() { // Hack to prevent tile_clicked to be triggered immediately
            if (card == null || card.destroyed) return; // might happen when replaying (that card is removed in the same frame)
            card.add(new Clickable(tile_clicked));
            card.add(new DragOver(tile_dragover));
        });
        return tween.toPromise();
    }

    function handle_tile_removed(card :Card) {
        tiles.remove(card);
        // Actuate.stop(card);
        card.destroy();

        return Promise.resolve();
    }

    function handle_score(card_score :Int, card :Card) {
        var duration = 0.3;
        var delay = game.entities.Particle.Count * 0.1;
        var p = new game.entities.Particle({
            pos: card.pos.clone(),
            texture: card.texture,
            size: new Vector(tile_size, tile_size),
            color: card.color.clone(),
            depth: 100,

            target: scoreText.pos,
            duration: duration,
            delay: delay
        });
        Actuate.tween(p.size, duration, { x: tile_size * 0.25, y: tile_size * 0.25 }).delay(delay).onComplete(function() {
            p.destroy(true);
            score += card_score;
            // scoreText.text = '${Std.int(this.score)}';
            var textScale = scoreText.scale.x;
            if (textScale < 1.5) {
                textScale += 0.1 * card_score;
                scoreText.scale.set_xy(textScale, textScale);
            }
            Actuate.tween(this, (score - counting_score) * 0.02, { counting_score: score }, true).onUpdate(function() { scoreText.text = '${Std.int(counting_score)}'; });
        });

        return Promise.resolve();
    }

    function handle_game_over() {
        game_over = true;

        Luxe.io.string_save('save', null); // clear the save

        //var tween = Luxe.renderer.clear_color.tween(1.0, { r: 1.0, g: 0.2, b: 0.2 });
        //return tween.toPromise();
        Main.states.enable(GameOverState.StateId, {
            client: 'my-client-id-'  + Math.floor(1000 * Math.random()), // TODO: Get client ID from server initially, store it locally
            name: 'Name' + Math.floor(1000 * Math.random()), // TODO: Use correct name
            score: Math.floor(1000 * Math.random()) // TODO: Use correct score
        });

        return Promise.resolve();
    }

    function grid_clicked(x :Int, y :Int, sprite :Sprite) {
        if (game_over) return;
        if (grabbed_card == null) return;
        if (!Game.Instance.is_placement_valid(x, y)) {
            tween_pos(grabbed_card, grabbed_card_origin);
            grabbed_card = null;
            return;
        }

        // grabbed_card.pos = sprite.pos.clone();
        // grabbed_card.grid_pos = { x: x, y: y };
        // grabbed_card.remove('Clickable');
        do_action(Place(grabbed_card.cardId, x, y));
        // var grabbed_card_copy = grabbed_card;
        // Luxe.next(function() { // Hack to prevent tile_clicked to be triggered immediately
        //     grabbed_card_copy.add(new Clickable(tile_clicked));
        //     grabbed_card_copy.add(new DragOver(tile_dragover));
        // });
        // grabbed_card.depth = 2;
        grabbed_card = null;
    }

    function card_grid_clicked(sprite :Sprite) {
        if (game_over) return;
        if (grabbed_card == null) return;
        tween_pos(grabbed_card, grabbed_card_origin);
        grabbed_card = null;
    }

    function tile_dragover(sprite :Sprite) {
        var tile :Tile = cast sprite;
        if (grabbed_card == null && collection.length > 0 && !collection.has(tile)) {
            add_to_collection(tile);
        }
    }

    function tile_clicked(sprite :Sprite) {
        if (game_over) return;
        var tile :Tile = cast sprite;
        add_to_collection(tile);
    }

    function add_to_collection(tile :Tile) {
        tile.set_highlight(true);
        collection.push(tile);
        if (!Game.Instance.is_collection_valid(collection)) {
            clear_collection();
            return;
        }

        if (collection.length == 3) {
            var cardIds = [ for (c in collection) c.cardId ];
            clear_collection();
            do_action(Collect(cardIds));
        } else {
            for (tile in quest_matches) {
                tile.set_highlight(false);
            }
            quest_matches = Game.Instance.get_matching_quest_parts(collection);
            for (tile in quest_matches) {
                tile.set_highlight(true);
            }
        }
    }

    function clear_collection() {
        for (tile in collection) {
            tile.set_highlight(false);
        }
        for (tile in quest_matches) {
            tile.set_highlight(false);
        }
        collection = [];
        quest_matches = [];
    }

    function card_clicked(sprite :Sprite) {
        if (game_over) return;
        grabbed_card = cast sprite;
        grabbed_card_origin = sprite.pos.clone();
        grabbed_card_offset = Vector.Subtract(Luxe.screen.cursor.pos, Luxe.camera.world_point_to_screen(sprite.pos));
        grabbed_card.depth = 3;
        clear_collection();
    }

    override function onleave(_) {
        Luxe.scene.empty();
    }

    override function onmousemove(event :luxe.Input.MouseEvent) {
        if (game_over) return;
        if (grabbed_card != null) {
            var world_pos = Luxe.camera.screen_point_to_world(Vector.Subtract(event.pos, grabbed_card_offset));
            grabbed_card.pos = world_pos;
        }
    }

    override function onrender() {

    }

    override function update(dt :Float) {
        var textScale = scoreText.scale.x; 
        if (textScale > 1) scoreText.scale.set_xy(textScale - dt, textScale - dt);
    }

    function do_action(action :Action) {
        Game.Instance.do_action(action);
        save_game();
    }

    function save_game() {
        // deck list
        // quest list
        // active quests
        // hand
        // board
        // (what to do about card ids?)

        var save_data = {
            seed: Luxe.utils.random.seed,
            score: score,
            events: Game.Instance.save()
        };

        trace('save_data: $save_data');

        var succeeded = Luxe.io.string_save('save', haxe.Json.stringify(save_data));
        if (!succeeded) trace('Save failed!');
    }

    function load_game() {
        var data_string = Luxe.io.string_load('save');
        if (data_string == null) {
            trace('Save not found or failed to load!');
            return false;
        }
        try {
            trace('load_data: $data_string');
            var data = haxe.Json.parse(data_string);
            Luxe.utils.random.initial = data.seed;
            score = data.score;
            Game.Instance.load(data.events);
            return true;
        } catch (e :Dynamic) {
            trace('Failed to parse or load saved data. Error: $e');
            return false;
        }
    }

    #if debug // TODO: Remove before release
    override function onkeyup(event :luxe.Input.KeyEvent) {
        switch (event.keycode) {
            case luxe.Input.Key.key_k: handle_game_over();
            case luxe.Input.Key.key_n: handle_new_game(); // Main.NewGame();
            case luxe.Input.Key.key_s: save_game();
            case luxe.Input.Key.key_l: load_game();
            case luxe.Input.Key.key_t: Luxe.io.url_open('https://twitter.com/intent/tweet?original_referer=http://andersnissen.com&text=Solitaire tweet #Solitaire&url=http://andersnissen.com/');
        }
    }
    #end
}
