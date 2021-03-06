
package game.states;

import game.entities.PopText;
import game.misc.GameScore;
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
import core.utils.Analytics;
import game.misc.GameMode.GameMode;

import sparkler.ParticleSystem;
import sparkler.ParticleEmitter;
import sparkler.modules.*;

using game.tools.TweenTools;
using game.misc.GameMode.GameModeTools;

typedef Card = Tile;

enum TutorialStep {
    Welcome;
    WhatIsTheGoal;
    Inventory;
    PlacingCards;
    PlacingCards2;
    StackingTiles;
    PlacingCards3;
    PlacingCards4;
    CollectingSets;
    CollectingSets2;
    DragToCollectSets;
    Scoring;
    GoodLuck;
}

typedef TutorialData = { step: TutorialStep, texts :Array<String>, entities :Array<luxe.Visual> };

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
    var quest_values = 12;
    var card_values  = 6;
    var reshuffle_count :Int;

    var quests :Array<Card>;
    var tiles :Array<Card>;
    var collection :Array<Card>;

    var scoreText :luxe.Text;
    var scoreIcon :Sprite;
    var counting_score :Float;
    var time_penalty :Float;
    var score :Float;

    var game_over :Bool;
    var game_mode :GameMode;

    var quest_matches :Array<Card>;

    var ps :ParticleSystem;
    var pe_burst :ParticleEmitter;
    var pe_continous :ParticleEmitter;
    var pe_burst_color_life_module :ColorLifeModule;
    var pe_continous_color_life_module :ColorLifeModule;

    var highlighted_tile :Sprite;
    
    var tutorial_box :game.entities.TutorialBox;
    var tutorial_steps :Array<TutorialStep> = [Welcome, Inventory, PlacingCards, PlacingCards2, PlacingCards3, PlacingCards4, CollectingSets, CollectingSets2, DragToCollectSets, Scoring, StackingTiles, GoodLuck];
    var tutorial_step_index :Int;
    var tutorial_can_drop :{ x :Int, y :Int };
    var tutorial_can_collect :Bool;

    var sounds_playing :Int;

    var flash_overlay :Sprite;
    var flash_timer :Float;
    
    public function new() {
        super({ name: StateId });
        Game.Instance.listen(handle_event);
    }

    override function init() {

    }

    override function onenter(data :Dynamic) {
        Luxe.camera.center = Vector.Multiply(Luxe.camera.size, 0.5);

        game_mode = cast data;
        if (game_mode == null) game_mode = Normal;

        Luxe.audio.on(luxe.Audio.AudioEvent.ae_end, sound_stopped);

        switch (game_mode) {
            case Tutorial(mode): Analytics.screen('PlayState/' + mode.get_game_mode_id() + '/' + game_mode.get_game_mode_id());
            default: Analytics.screen('PlayState/' + game_mode.get_game_mode_id());
        }

        var could_load_game = load_game();
        if (!could_load_game) start_new_game();
    }

    function start_new_game() {
        var plays_today = Luxe.io.string_load(game_mode.get_non_tutorial_game_mode_id() + '_plays_today');
        if (plays_today == null) plays_today = '0';
        //trace('${game_mode.get_game_mode_id()} games today: $plays_today');
        //trace('... now ${game_mode.get_game_mode_id()} games today: ${Std.parseInt(plays_today) + 1}');
        var number_of_plays_today = Std.parseInt(plays_today) + 1;
        // trace('... now ${game_mode.get_game_mode_id()} games today: $number_of_plays_today');
        Analytics.event('game', 'plays_daily', game_mode.get_non_tutorial_game_mode_id(), number_of_plays_today);

        var now = Date.now();
        Luxe.io.string_save(game_mode.get_non_tutorial_game_mode_id() + '_play_date', '' + now.getDate() + now.getMonth() + now.getFullYear());

        Luxe.utils.random.initial = switch (game_mode) {
            case Tutorial(Normal): 12;
            default:
                // e.g 1-2-0-26-8-18
                var seed_string = '' + (game_mode.get_non_tutorial_game_mode_index() + 1 /* to avoid zero */) + plays_today + 0 + now.getDate() + now.getMonth() + (now.getFullYear() - 2000);
                Std.parseInt(seed_string);
        }

        handle_new_game();
    }

    function handle_new_game() {
        Luxe.scene.empty();

        grabbed_card = null;
        collection = [];
        quests = [];
        tiles = [];
        quest_matches = [];
        reshuffle_count = 0;
        // score = 0;
        // counting_score = 0;
        game_over = false;
        sounds_playing = 0;
        Tile.CardId = 0; // reset card Ids
        tutorial_step_index = 0;
        tutorial_can_drop = { x: -1, y: -1 };
        tutorial_can_collect = true;

        highlighted_tile = new Sprite({
            texture: Luxe.resources.texture('assets/images/symbols/tile.png'),
            // size: new Vector(tile_size * 1.25, tile_size * 1.25),
            size: new Vector(tile_size * 1.08, tile_size * 1.08),
            depth: 1,
            color: Settings.CARD_COLOR.clone()
        });
        highlighted_tile.color.a = 0.3;
        highlighted_tile.visible = false;

        ps = new ParticleSystem();

        pe_burst_color_life_module = new ColorLifeModule({
            initial_color : new sparkler.data.Color(1,0,1,1),
            end_color : new sparkler.data.Color(0,0,1,1),
            end_color_max : new sparkler.data.Color(1,0,0,1)
        });
        pe_burst = new ParticleEmitter({
			name: 'tile_particle_emitter', 
			rate: 128,
			cache_size: 64,
			cache_wrap: true,
			duration: 0.1,
            lifetime: 0.15,
            lifetime_max: 0.3,
			modules: [
				new RadialSpawnModule({
                    radius: 5
                }),
                pe_burst_color_life_module,
				new SizeLifeModule({
					initial_size: new sparkler.data.Vector(10,10),
					end_size: new sparkler.data.Vector(5,5)
				}),
				new DirectionModule({
					direction: 0,
					direction_variance: 360,
                    speed: 100
				}),
                new RotationModule({
                    initial_rotation: Math.random() * 2 * Math.PI
                })
			]
		});
        pe_burst.stop();
		ps.add(pe_burst);

        pe_continous_color_life_module = new ColorLifeModule({
            initial_color : new sparkler.data.Color(1,0,1,0.5),
            end_color : new sparkler.data.Color(0,0,1,0),
            end_color_max : new sparkler.data.Color(1,0,0,0.5)
        });
        pe_continous = new ParticleEmitter({
			name: 'card_particle_emitter', 
			rate: 50,
			cache_size: 64,
			cache_wrap: true,
            depth: 9,
            lifetime: 0.4,
            lifetime_max: 0.8,
			modules: [
                new RadialSpawnModule({
                    radius: 10
                }),
                pe_continous_color_life_module,
				new SizeLifeModule({
					initial_size: new sparkler.data.Vector(10,10),
					end_size: new sparkler.data.Vector(5,5)
				}),
                new RotationModule({
                    initial_rotation: Math.random() * 2 * Math.PI
                })
			]
		});
        pe_continous.stop();
		ps.add(pe_continous);

        flash_overlay = new Sprite({
            texture: Luxe.resources.texture('assets/ui/inner-border.png'),
            size: Vector.Multiply(Luxe.screen.size, 0.75),
            color: new Color(1.0, 1.0, 1.0, 0.0),
            centered: false,
            //no_scene: true,
            depth: 999
        });
        flash_overlay.blend_src = phoenix.Batcher.BlendMode.src_alpha;
        flash_overlay.blend_dest = phoenix.Batcher.BlendMode.one;
        flash_timer = 0;

        var show_back_button = switch (game_mode) {
            case Tutorial(_): false;
            case _: true;
        };

        if (show_back_button) {
            var back_button = new game.ui.Icon({
                pos: new Vector(30, 30),
                texture_path: 'assets/ui/arrowBeige_left.png',
                on_click: go_back
            });
            back_button.scale.set_xy(1/4, 1/4);
        }

        // quest backgrounds
        for (x in 0 ... 3) {
            // new Sprite({
            //     pos: get_pos(x, 0.5),
            //     texture: Luxe.resources.texture('assets/images/symbols/tile_bg.png'),
            //     size: new Vector(tile_size, tile_size * 2.6),
            //     color: Settings.QUEST_BG_COLOR
            // });
            var nineslice = new luxe.NineSlice({
                name_unique: true,
                texture: Luxe.resources.texture('assets/ui/panelInset_beige.png'),
                top: 20,
                left: 20,
                right: 20,
                bottom: 20
            });

            nineslice.create(get_pos(-0.35 + x, -0.35), tile_size * 0.8, tile_size);
            nineslice.size = new luxe.Vector(tile_size * 0.8, tile_size);
            Actuate.tween(nineslice.size, 0.3, { y: tile_size * 2 }).delay(x * 0.2);
        }

        function drag_left(s) {
            highlighted_tile.visible = false;
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
                sprite.add(new DragOver(function(s) {
                    if (grabbed_card == null) return;
                    highlighted_tile.pos = sprite.pos;
                    highlighted_tile.visible = true;
                }, drag_left));
            }
        }

        // card grid
        for (x in 0 ... 3) {
            var sprite = new Sprite({
                pos: get_pos(x, tiles_y + 2 + 0.1),
                texture: Luxe.resources.texture('assets/images/symbols/tile_bg.png'),
                size: new Vector(tile_size * 1.15, tile_size * 1.15),
                color: Settings.CARD_BG_COLOR
            });
            sprite.color.a = 0.5;
            sprite.add(new MouseUp(card_grid_clicked));
            sprite.add(new DragOver(function(s) {
                if (grabbed_card == null) return;
                if (!grabbed_card_origin.equals(sprite.pos)) return;
                highlighted_tile.pos = sprite.pos;
                highlighted_tile.visible = true;
            }, drag_left));
        }

        var max_suits = switch (game_mode) {
            case Strive(_) | Tutorial(Strive(_)): suits - 1;
            default: suits;
        };

        switch (game_mode) {
            case Tutorial(Normal): card_values = 8;
            default:
        }

        var deck_cards = [];
        for (suit in 0 ... max_suits) {
            for (value in 0 ... card_values) {
                deck_cards.push({ suit: suit, stacked: (value >= 10) });
            }
        }

        var quest_cards = [];
        for (suit in 0 ... max_suits) {
            for (value in 0 ... quest_values) {
                quest_cards.push({ suit: suit, stacked: (value >= 10) });
            }
        }

        var play_mode = switch (game_mode) {
            case Tutorial(mode): mode;
            default: game_mode;
        }
        score = switch (play_mode) {
            case Normal: 0;
            case Strive(_): -game_mode.get_strive_score();
            case Timed: 30;
            case Puzzle: 0;
            case Tutorial(_): throw 'will never happen';
        };
        counting_score = score;
        time_penalty = 0;
        scoreText = new luxe.Text({
            pos: get_pos(1, -0.6),
            align: center,
            align_vertical: center,
            text: '$score', // Seed test: '' + Luxe.utils.random.initial
            letter_spacing: -1.4,
            sdf: true,
            shader: Luxe.renderer.shaders.bitmapfont.shader.clone('title-shader'),
            outline: 0.7,
            outline_color: new Color().rgb(0xa55004)
        });

        scoreIcon = new Sprite({
            pos: get_pos(1.75, -0.68),
            texture: Luxe.resources.texture('assets/ui/diamond.png'),
            scale: new Vector(0.06, 0.06),
            color: new Color().rgb(0x956416),
            depth: 10
        });

        // TODO: Make a different deck/quest_deck/game for puzzle mode
        /*
        XYZ
        ZZY
        XYX

        Hand: XXZ

        Quest: XXX
        Quest: XYZ
        Quest: ZYZ
        */

        switch (game_mode) {
            case Tutorial(_):
                tutorial_box = new game.entities.TutorialBox({});
                tutorial_can_collect = false;
                Analytics.event('game', 'tutorial', 'started');
            case Puzzle:
                deck_cards = [];
                var stackedIndex = Luxe.utils.random.int(0, 9);
                for (value in 0 ... 9) { // tile cards
                    deck_cards.push({ suit: Luxe.utils.random.int(0, 4), stacked: (value == stackedIndex) });
                }
                for (value in 0 ... 3) { // hand cards
                    deck_cards.push({ suit: Luxe.utils.random.int(0, 4), stacked: false });
                }

                quest_cards = [];
                for (suit in 0 ... 2) {
                    for (value in 0 ... 2) {
                        quest_cards.push({ suit: suit, stacked: false });
                    }
                }
            default:
        }

        function instantiate_tile(data) {
            var tile = create_tile(data.suit, data.stacked, tile_size);
            tile.pos = get_pos(1, tiles_y + 3.5);
            return tile;
        }

        var deck = new InfiniteDeck(deck_cards, instantiate_tile, random_func);
        var quest_deck = new InfiniteDeck(quest_cards, function(data) {
            var tile = create_tile(data.suit, data.stacked, tile_size * 0.5);
            tile.pos = get_pos(1, -2);
            return tile;
        }, random_func);
        deck.on_reshuffling = function() {
            reshuffle_count++;
            function add_cards(suit :Int) {
                deck.add_cards([ for (value in 0 ... card_values) { suit: suit, stacked: (value >= 10) } ]);
                quest_deck.add_cards([ for (value in 0 ... quest_values) { suit: suit, stacked: (value >= 10) } ]);
                quest_deck.reshuffle();
            }
            switch (game_mode) {
                case Strive(_) | Tutorial(Strive(_)):
                    if (reshuffle_count == 1) {
                        add_cards(2);
                    } else if (reshuffle_count == 2) {
                        add_cards(3);
                    } else if (reshuffle_count == 3) {
                        add_cards(4);
                    }
                default:
                    if (reshuffle_count == 1) {
                        add_cards(3);
                    } else if (reshuffle_count == 2) {
                        add_cards(4);
                    }
            }
        };

        Analytics.event('game', 'start', game_mode.get_game_mode_id());

        return switch (game_mode) {
            case Tutorial(Normal): tutorial(TutorialStep.Welcome, { texts: ['Welcome to {brown}Stoneset{default}.', 'In {brown}Stoneset{default} you\nforge {brown}gemstones.', 'And complete {brown}sets{default}\nto collect riches!'] }).then(function() {
                    Game.Instance.new_game(tiles_x, tiles_y, deck, quest_deck);
                });
            case Tutorial(Strive(_)): tutorial(TutorialStep.Welcome, { texts: ['Welcome to the\n{brown}Journey{default} game mode.', 'In {brown}Journey{default} you need\nto fulfill a {brown}goal{default}.', 'If you succeed, the {brown}goal{default}\nwill be increased.', 'If you fail, the {brown}goal{default}\nwill be decreased.', 'Journey to complete\nthe highest {brown}goal{default}.', 'Good luck.'] }).then(function() {
                    finish_tutorial();
                    Game.Instance.new_game(tiles_x, tiles_y, deck, quest_deck);
                });
            case Tutorial(Timed): tutorial(TutorialStep.Welcome, { texts: ['Welcome to the\n{brown}Survival{default} game mode.', 'In {brown}Survival{default} you need\nto act quickly.', 'Instead of {brown}points{default}\nyou have {brown}seconds{default}.', 'You must survive as\nlong as possible.', 'Good luck.'] }).then(function() {
                    finish_tutorial();
                    Game.Instance.new_game(tiles_x, tiles_y, deck, quest_deck);
                });
            default: 
                Game.Instance.new_game(tiles_x, tiles_y, deck, quest_deck);
                Promise.resolve();
        }
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

    public function tutorial(step :TutorialStep, data :game.entities.TutorialBox.TutorialData) :Promise {
        switch (game_mode) {
            case Tutorial(_):
            case _: return Promise.resolve();
        }
        if (/* tutorial_box.is_active() || */ step != tutorial_steps[tutorial_step_index]) return Promise.resolve();
        tutorial_step_index++;
        return tutorial_box.tutorial(data);
    }

    function handle_event(event :core.models.Game.Event) :Promise {
        if (game_over) return Promise.resolve();
        return switch (event) {
            case NewGame: handle_new_game();
            case Draw(cards): handle_draw(cards);
            case NewQuest(quest): handle_new_quest(quest);
            case TilePlaced(card, x, y): handle_tile_placed(card, x, y);
            case TileRemoved(card): handle_tile_removed(card);
            case Collected(cards, quest, total_score): handle_collected(cards, quest, total_score);
            case Stacked(card): handle_stacked(card);
            case Score(score, card, correct_order): handle_score(score, card, correct_order);
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
            // var trail = new game.components.TrailRenderer();
            // trail.depth = card.depth - 0.1;
            // card.add(trail);
            tiles.push(card);
            x++;
        }

        tutorial(TutorialStep.Inventory, { texts: ['These are your\n{brown}gemstones{default}.'], points: [ get_pos(0, tiles_y + 1.8), get_pos(1, tiles_y + 1.8), get_pos(2, tiles_y + 1.8) ], do_func: function() {
            for (card in cards) {
                card.remove('Clickable');
            }
        } });
        tutorial(TutorialStep.PlacingCards, { texts: ['{brown}Gemstones{default} are placed\ninto {brown}sockets{default}.', 'Once placed, {brown}gemstones{default}\ncannot be moved.'], pos_y: (Settings.HEIGHT * (2/3)) });

        tutorial(TutorialStep.PlacingCards2, { texts: ['Drag this {sapphire}sapphire{default}\ninto this {brown}socket{default}.'], points: [ get_pos(0, tiles_y + 1.8), get_pos(0, tiles_y - 0.8) ], pos_y: (Settings.HEIGHT * (2/3)), must_be_dismissed: true, do_func: function() { 
            tutorial_can_drop = { x: 0, y: 0 };
            cards[0].add(new Clickable(card_clicked));
        }});

        tutorial(TutorialStep.PlacingCards3, { texts: ['Drag this {topaz}topaz{default}\ninto this {brown}socket{default}.'], points: [ get_pos(1, tiles_y + 1.8), get_pos(1, tiles_y - 0.8) ], pos_y: (Settings.HEIGHT * (2/3)), must_be_dismissed: true, do_func: function() { 
            tutorial_can_drop = { x: 1, y: 0 };
            cards[0].add(new Clickable(card_clicked)); // why does this work?
        }});

        tutorial(TutorialStep.PlacingCards4, { texts: ['Drag this {sapphire}sapphire{default}\ninto this {brown}socket{default}.'], points: [ get_pos(2, tiles_y + 1.8), get_pos(2, tiles_y - 0.8) ], pos_y: (Settings.HEIGHT * (2/3)), must_be_dismissed: true, do_func: function() { 
            tutorial_can_drop = { x: 2, y: 0 };
            cards[0].add(new Clickable(card_clicked)); // why does this work?
        }});

        // hack to save initial normal and strive games
        if (Luxe.io.string_load('save_${game_mode.get_game_mode_id()}') == null) {
            save_game();
        }

        // tutorial: once a gemstone has been placed in a socket, it cannot be moved
        // tutorial: collect adjacent gemstones to complete sets
        // tutorial: collect adjacent gemstones of the same type to create flawless gemstones

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
        play_sound('quest', get_pos(Math.floor(count / 3), (count % 3) * 0.5));
        for (card in quest) {
            var new_pos = get_pos(Math.floor(count / 3), (count % 3) * 0.5);
            tween = tween_pos(card, new_pos).delay(delay_count * 0.1);
            quests.push(card);
            card.show_tile_graphics().delay(delay_count * 0.1 + 0.2);
            delay_count++;
            count++;
        }
        
        //tutorial(TutorialStep.WhatIsTheGoal, ['Your goal is to\ncomplete {brown}sets{default}.']);

        return (tween != null ? tween.toPromise() : Promise.resolve());
    }

    function tween_pos(sprite :Sprite, pos :Vector, duration :Float = 0.2) {
        return Actuate.tween(sprite.pos, duration, { x: pos.x, y: pos.y });
    }

    function handle_collected(cards :Array<Card>, quest :Array<Card>, total_score :Int) {
        quest_matches = [];

        Analytics.event('game', 'collect', 'score', total_score);

        var sound_pos = quest.last().pos;
        play_sound('collect', sound_pos);

        if (total_score > 10) {
            play_sound('points_devine', sound_pos);
        }

        for (card in quest) {
            quests.remove(card);
            card.destroy();
        }
        return Promise.resolve();
    }

    function handle_stacked(card :Card) {
        play_sound('stack', card.pos);
        card.stacked = true;
        Luxe.camera.shake(2.0);

        var ring_symbol = new Sprite({
            texture: Luxe.resources.texture('assets/images/symbols/ring.png'),
            size: new Vector(tile_size, tile_size),
            pos: card.pos,
            color: card.get_original_color(),
            depth: card.depth + 0.1
        });
        Actuate.tween(ring_symbol.color, 0.3, { a: 0.0 });
        Actuate.tween(ring_symbol.size, 0.3, { x: tile_size * 4, y: tile_size * 4 }).onComplete(function() {
            if (!ring_symbol.destroyed) ring_symbol.destroy();
        });

        pe_burst.position.x = card.pos.x;
        pe_burst.position.y = card.pos.y;
        var color = card.get_original_color();
        color.a = 0.5;
        pe_burst_color_life_module.initial_color.from_json(color);
        pe_burst_color_life_module.end_color.from_json(color);
        pe_burst_color_life_module.end_color_max = new sparkler.data.Color(1, 1, 1, 0);
        pe_burst.start();

        return Promise.resolve();
    }

    function handle_tile_placed(card :Card, x :Int, y :Int) {
        play_sound('place', get_pos(x, y + 2));
        if (card == null) {
            trace('handle_tile_placed: Card was null -- how?!');
            return Promise.resolve();
        }
        var tween = tween_pos(card, get_pos(x, y + 2), 0.1);
        card.grid_pos = { x: x, y: y };
        card.depth = 2;
        card.show_tile_graphics();
        if (card.has('Clickable')) card.remove('Clickable');

        Luxe.next(function() { // Hack to prevent tile_clicked to be triggered immediately
            if (card == null || card.destroyed) {
                // trace('No component is added to card -- card is null or destroyed');
                return; // might happen when replaying (that card is removed in the same frame)
            }
            card.add(new Clickable(tile_clicked));
            card.add(new DragOver(tile_dragover));
        });

        // Analytics.event('game', 'place', '$x,$y'); // disabled to prevent sending many messages

        Luxe.camera.shake(0.5);

        pe_burst.position.x = card.pos.x;
        pe_burst.position.y = card.pos.y;
        pe_burst_color_life_module.initial_color.from_json(card.get_original_color());
        pe_burst_color_life_module.end_color.from_json(card.get_original_color());
        pe_burst_color_life_module.end_color_max = new sparkler.data.Color(1, 1, 1, 0);
        pe_burst.start();

        tutorial(TutorialStep.CollectingSets, { texts: ['You collect adjacent\n{brown}gemstones{default} to form {brown}sets{default}.', 'You don\'t have to\ncollect in straight lines.', 'collect_adjacent.png'], pos_y: (Settings.HEIGHT * (3/4) - 40) });

        tutorial(TutorialStep.CollectingSets2, { texts: ['You can now\ncollect this {brown}set{default}.'], points: [ get_pos(0, tiles_y - 1.7) ], pos_y: (Settings.HEIGHT / 2) + 30 });

        tutorial(TutorialStep.DragToCollectSets, { texts: ['Connect the {brown}gemstones{default}\nby dragging.'], points: [ get_pos(0, tiles_y - 0.5), get_pos(1, tiles_y - 0.5), get_pos(2, tiles_y - 0.5) ], pos_y: (Settings.HEIGHT * (3/4) - 20), must_be_dismissed: true, do_func: function() { 
            tutorial_can_collect = true;
        }});

        return tween.toPromise();
    }

    function handle_tile_removed(card :Card) {
        tiles.remove(card);
        card.destroy();

        return Promise.resolve();
    }

    function play_sound(id :String, ?pos :Vector) {
        #if sys // does not work on web
        if (sounds_playing >= 4) {
            // trace('skipping sound! ($sounds_playing playing)');
            return; // don't play too many simultainous sounds (is not being triggered on web)
        }
        #end
        var sound = Luxe.resources.audio(Settings.get_sound_file_path(id));
        var handle = Luxe.audio.play(sound.source);
        if (pos != null) {
            Luxe.audio.pan(handle, pos.x / Settings.WIDTH);
        }
        sounds_playing++;
    }

    function sound_stopped(h) {
        sounds_playing--;
        if (sounds_playing < 0) sounds_playing = 0;
    }

    function handle_score(card_score :Int, card :Card, correct_order :Bool) {
        if (game_over) return Promise.resolve();

        var duration = 0.3;
        var card_pos = card.pos.clone();
        var delay = game.entities.Particle.Count * 0.15;
        var particle_pos = card.pos.clone();
        var is_loading = (particle_pos.y > Settings.HEIGHT); // hack to avoid particle rain when game loads
        if (is_loading) { // hack to avoid particle rain when game loads
            particle_pos.y = scoreText.pos.y + 20;
            duration *= 0.1;
            delay *= 0.1;
        }
        var p = new game.entities.Particle({
            pos: particle_pos,
            texture: card.texture,
            size: new Vector(tile_size, tile_size),
            color: card.color.clone(),
            depth: 100,

            target: scoreText.pos,
            duration: duration,
            delay: delay
        });
        if (is_loading) {
            p.visible = false;
        }
        if (correct_order) {
            var trail = new game.components.TrailRenderer();
            trail.trailColor.fromColor(card.color);
            trail.startSize = 8;
            trail.maxLength = 75;
            trail.depth = p.depth - 0.1;
            p.add(trail);
        }

        if (!is_loading) {
            new PopText({
                pos: Vector.Add(card_pos, new Vector(-11, 0)),
                fadeDelay: 0.75,
                align: center,
                align_vertical: center,
                text: '$card_score',
                letter_spacing: -1.4,
                sdf: true,
                shader: Luxe.renderer.shaders.bitmapfont.shader.clone('title-shader'),
                outline: 0.6,
                outline_color: new Color().rgb(0xa55004),
                icon: new Sprite({
                    texture: Luxe.resources.texture('assets/ui/diamond.png'),
                    scale: new Vector(0.05, 0.05),
                    color: new Color().rgb(0x956416)
                })
            });
        }

        score += card_score;
        // score += switch (game_mode) {
        //     case Timed | Tutorial(Timed): card_score; // Hack to reduce survival time in timed mode
        //     default: card_score;
        // };
        var temp_score = score;

        Actuate.tween(p.size, duration, { x: tile_size * 0.25, y: tile_size * 0.25 }).delay(delay).onComplete(function() {
            if (p != null && !p.destroyed) p.destroy();
            
            var textScale = scoreText.scale.x;
            if (textScale < 1.5) {
                textScale += 0.1 * card_score;
                scoreText.scale.set_xy(textScale, textScale);
                scoreIcon.scale.set_xy(textScale * 0.06, textScale * 0.06);
            }
            var ring_symbol = new Sprite({
                texture: Luxe.resources.texture('assets/images/symbols/ring.png'),
                size: new Vector(tile_size / 2, tile_size / 2),
                pos: scoreText.pos,
                color: card.get_original_color()
            });
            Actuate.tween(ring_symbol.color, 0.1, { a: 1.0 });
            Actuate.tween(ring_symbol.color, 0.1, { a: 0.0 }).delay(0.1);
            Actuate.tween(ring_symbol.size, 0.2, { x: tile_size * 2, y: tile_size * 2 }).onComplete(function() {
                if (!ring_symbol.destroyed) ring_symbol.destroy();
            });

            var originalColor = new Color().rgb(0x956416);
            var new_color = card.get_original_color();
            //Actuate.stop(scoreIcon.color);
            Actuate.tween(scoreIcon.color, 0.1, { r: (originalColor.r + new_color.r) / 2, g: (originalColor.g + new_color.g) / 2, b: (originalColor.b + new_color.b) / 2 }, true).onComplete(function(_) {
                Actuate.tween(scoreIcon.color, 0.3, { r: originalColor.r, g: originalColor.g, b: originalColor.b });
            });

            Luxe.camera.shake(card_score * (1 / 2));

            pe_burst.position.x = scoreText.pos.x;
            pe_burst.position.y = scoreText.pos.y;
            var color = card.get_original_color();
            color.a = 0.5;
            pe_burst_color_life_module.initial_color.from_json(color);
            pe_burst_color_life_module.end_color.from_json(color);
            pe_burst_color_life_module.end_color_max = new sparkler.data.Color(1, 1, 1, 0);
            pe_burst.start();

            if (card_score <= 1) {
                play_sound('points_small', card_pos);
            } else if (card_score <= 3) {
                play_sound('points_big', card_pos);
            } else { // score: 6
                play_sound('points_huge', card_pos);
            }

            var timed_mode = false;
            switch (game_mode) {
                case Strive(_) | Tutorial(Strive(_)):
                    if (score >= 0) {
                        scoreText.color.tween(0.3, { r: 0.2, g: 0.8, b: 0.2 });
                        handle_game_over();
                    }
                case Timed | Tutorial(Timed): timed_mode = true;
                default: 
            }

            if (!game_over || !timed_mode) {
                Actuate.tween(this, (temp_score - counting_score) * 0.02, { counting_score: temp_score }, true).onUpdate(function() {
                    scoreText.text = '${Std.int(counting_score - time_penalty)}';
                });
            }
        });

        tutorial(TutorialStep.Scoring, { texts: ['Complete {brown}sets{default} to\nincrease your score.', 'Collect in the correct\norder to double the {brown}points{default}.', 'collect_order.png'], entities: [scoreText] });

        tutorial(TutorialStep.StackingTiles, { texts: ['This {brown}set{default} has a\n{brown}flawless{default} {ruby}ruby{default}.', '{brown}Flawless gemstones{default}\nmust be forged.', 'stack.png'], points: [ get_pos(1, tiles_y - 1.7) ], pos_y: (Settings.HEIGHT / 2) + 30 });

        tutorial(TutorialStep.GoodLuck, { texts: ['Now go make your\nfortune in {brown}Stoneset{default}.', 'Good luck!'], do_func: function() {
            finish_tutorial();
        } });

        return Promise.resolve();
    }

    function handle_game_over() {
        if (game_over) return Promise.resolve();
        game_over = true;

        Luxe.io.string_save('save_${game_mode.get_game_mode_id()}', null); // clear the save

        var new_game_mode :GameMode = game_mode;
        switch (game_mode) {
            case Strive(level) | Tutorial(Strive(level)):
                var win = (score >= 0); // strive score starts negative
                var new_level = (win ? level + 1 : level - 1);
                if (new_level < 1) new_level = 1;
                new_game_mode = Strive(new_level);
                play_sound(win ? 'won' : 'lost');

                var icon_path = (win ? 'assets/ui/holy-grail.png' : 'assets/images/journey/camel.png');
                if (win && new_level > Settings.load_int('journey_highest_level_won', 0)) {
                    icon_path = 'assets/images/journey/flying-flag.png';
                }
                var game_over_icon = new Sprite({
                    texture: Luxe.resources.texture(icon_path),
                    pos: new Vector(Settings.WIDTH / 2, Settings.HEIGHT / 2),
                    scale: new Vector(0.0, 0.0),
                    color: new Color().rgb(0xa55004),
                    depth: 100
                });
                Actuate.tween(game_over_icon.scale, 0.3, { x: 0.4, y: 0.4 }).delay(0.1);
                Actuate.tween(game_over_icon.color, 0.3, { a: 1.0 }).delay(0.1);
            case Normal:
                play_sound('won');
            case Timed | Tutorial(Timed):
                new_game_mode = Timed;
                score = Std.int(time_penalty); // set the score to be the time survived
                play_sound('won');
            case Puzzle:
                play_sound('won');
            case Tutorial(mode):
                new_game_mode = mode;
                play_sound('won');
        }

        var delay = 0.1;
        for (tile in tiles) {
            tile.show_tile_graphics(false).delay(delay);
            delay += 0.05;
        }

        switch (game_mode) {
            case Timed | Tutorial(Timed):
                scoreText.color.tween(0.3, { r: 0.2, g: 0.2, b: 0.2 });
                var remaining_time = (counting_score - time_penalty);
                counting_score = remaining_time;
                var tween = Actuate.tween(this, time_penalty * 0.05, { counting_score: remaining_time + time_penalty }, true).onUpdate(function() {
                    scoreText.text = '${Std.int(counting_score)} sec';
                });
                return tween.toPromise().then(switch_to_game_over_state.bind(new_game_mode));
            default:
                return switch_to_game_over_state(new_game_mode);
        }
    }

    function switch_to_game_over_state(next_game_mode :GameMode) {
        Luxe.timer.schedule(2.0, function() {
            var the_score :Int = Std.int(switch (game_mode) {
                case Timed | Tutorial(Timed): counting_score;
                case Strive(level) | Tutorial(Strive(level)): game_mode.get_strive_score() + score;
                default: score;
            });
            Analytics.event('game', 'over', game_mode.get_game_mode_id());
            Analytics.event('game', 'score', game_mode.get_game_mode_id(), the_score);

            if (Luxe.io.string_load('tutorial_has_been_reset') == 'true') { // to prevent tutorial-replay exploit
                Luxe.io.string_save('tutorial_has_been_reset', null);
                Main.SetState(MenuState.StateId);
                return;
            }

            switch (game_mode) { // TODO: Hack! Should be handled in one place for all game modes
                case Strive(level) | Tutorial(Strive(level)):
                    GameScore.add_highscore({
                        score: the_score,
                        seed: Std.int(Luxe.utils.random.initial),
                        game_mode: game_mode,
                        global_highscores_callback: function(highscores) {},
                        global_highscores_error_callback: function(error) {}
                    });
                default:
            };

            var data = {
                user_id: Luxe.io.string_load('clientId'),
                seed: Std.int(Luxe.utils.random.initial),
                score: the_score,
                game_mode: game_mode,
                next_game_mode: next_game_mode,
                actions_data: Game.Instance.get_actions_data(),
                total_score: Settings.load_int('total_score', 0),
                highest_journey_level_won: Settings.load_int('journey_highest_level_won', -1)
            };

            var gameOverStateId = switch (game_mode) {
                case Strive(level) | Tutorial(Strive(level)): JourneyState.StateId;
                default: GameOverState.StateId;
            };

            var name = Luxe.io.string_load('user_name');
            if (name == null || name.length == 0) {
                Main.SetState(TextInputState.StateId, { done_func: Main.SetState.bind(gameOverStateId, data) });
            } else {
                Main.SetState(gameOverStateId, data);
            }
        });
        return Promise.resolve();
    }

    function grid_clicked(x :Int, y :Int, sprite :Sprite) {
        if (game_over) return;
        if (grabbed_card == null) return;
        if ((tutorial_box != null && tutorial_box.is_active() && (tutorial_can_drop.x != x || tutorial_can_drop.y != y)) || !Game.Instance.is_placement_valid(x, y)) {
            tween_pos(grabbed_card, grabbed_card_origin);
            release_grabbed_card();
            return;
        }

        on_tutorial_card_dropped();
        do_action(Place(grabbed_card.cardId, x, y));
        release_grabbed_card();
    }

    function card_grid_clicked(sprite :Sprite) {
        if (game_over) return;
        if (grabbed_card == null) return;
        tween_pos(grabbed_card, grabbed_card_origin);
        release_grabbed_card();
    }

    function tile_dragover(sprite :Sprite) {
        if (!tutorial_can_collect) return;
        var tile :Tile = cast sprite;
        if (grabbed_card == null && collection.length > 0 && !collection.has(tile)) {
            add_to_collection(tile);
        }
    }

    function tile_clicked(sprite :Sprite) {
        if (game_over) return;
        if (grabbed_card != null) return;
        if (!tutorial_can_collect) return;
        var tile :Tile = cast sprite;
        add_to_collection(tile);
    }

    function on_tutorial_card_dropped() {
        if (tutorial_box == null || !tutorial_box.is_active()) return;
        tutorial_box.proceed();
    }

    function add_to_collection(tile :Tile) {
        tile.set_highlight(true);
        collection.push(tile);
        if (!Game.Instance.is_collection_valid(collection)) {
            Analytics.event('game', 'collect', 'invalid');
            play_sound('invalid', tile.pos);
            clear_collection();
            return;
        }

        play_sound('tile_click', tile.pos);

        if (collection.length == 3) {
            var cardIds = [ for (c in collection) c.cardId ];
            clear_collection();
            do_action(Collect(cardIds));

            if (tutorial_box != null && tutorial_box.is_active()) {
                if (tutorial_can_collect) {
                    tutorial_box.proceed(); // TODO: can this cause problems?
                }
            }
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
        grabbed_card.depth = 10;
        grabbed_card.show_shadow(true);
        
        pe_continous.position.x = grabbed_card.pos.x;
        pe_continous.position.y = grabbed_card.pos.y;
        var color = grabbed_card.get_original_color();
        color.a = 0.5;
        pe_continous_color_life_module.initial_color.from_json(color);
        pe_continous_color_life_module.end_color.from_json(color);
        pe_continous_color_life_module.end_color_max = new sparkler.data.Color(1, 1, 1, 0);
        pe_continous.start();

        clear_collection();
    }

    function release_grabbed_card() {
        if (grabbed_card == null) return;
        grabbed_card.depth = 3;
        grabbed_card.show_shadow(false);
        grabbed_card = null;
        pe_continous.stop();
        highlighted_tile.visible = false;
    }

    override function onleave(_) {
        if (tutorial_box != null) tutorial_box.dismiss();
        ps.destroy();
        Luxe.scene.empty();

        Luxe.audio.off(luxe.Audio.AudioEvent.ae_end, sound_stopped);
    }

    override function onmousemove(event :luxe.Input.MouseEvent) {
        if (game_over) return;
        if (grabbed_card != null) {
            var world_pos = Luxe.camera.screen_point_to_world(Vector.Subtract(event.pos, grabbed_card_offset));
            grabbed_card.pos = world_pos;
            pe_continous.position.x = world_pos.x;
            pe_continous.position.y = world_pos.y;
        }
    }

    override function onmouseup(event :luxe.Input.MouseEvent) {
        if (game_over) return;
        if (grabbed_card == null) return;
        tween_pos(grabbed_card, grabbed_card_origin);
        release_grabbed_card();
    }

    override function onrender() {
        
    }

    override function update(dt :Float) {
        ps.update(dt);
        var textScale = scoreText.scale.x; 
        if (textScale > 1) {
            scoreText.scale.set_xy(textScale - dt, textScale - dt);
            scoreIcon.scale.set_xy((textScale - dt) * 0.06, (textScale - dt) * 0.06);
        }
        scoreIcon.pos.x = scoreText.pos.x + scoreText.geom.text_width / 2 + 10 + 15 * textScale;
        if (game_over) return;
        switch (game_mode) {
            case Timed | Tutorial(Timed) if (!game_over && (tutorial_box == null || !tutorial_box.is_active())):
                time_penalty += dt;
                var time_left = counting_score - time_penalty;
                scoreText.text = '${Std.int(time_left)}';
                if ((time_left) < 0) {
                    scoreText.color.tween(0.3, { r: 1, g: 0.2, b: 0.2 });
                    handle_game_over();
                } else {
                    flash_timer -= dt;
                    if (flash_timer <= 0) {
                        if (time_left <= 3) {
                            flash_overlay.color.r = 1.0;
                            flash_overlay.color.g = 0.5;
                            flash_overlay.color.b = 0.5;
                            flash_overlay.color.tween(0.2, { a: 0.3 }).ease(luxe.tween.easing.Linear.easeNone).onComplete(function(_) {
                                flash_overlay.color.tween(0.2, { a: 0 }).ease(luxe.tween.easing.Linear.easeNone).delay(0.1);
                            });
                            flash_timer += 0.75;
                        } else if (time_left <= 10) {
                            flash_overlay.color.r = 1.0;
                            flash_overlay.color.g = 1.0;
                            flash_overlay.color.b = 1.0;
                            flash_overlay.color.tween(0.3, { a: 0.2 }).ease(luxe.tween.easing.Linear.easeNone).onComplete(function(_) {
                                flash_overlay.color.tween(0.3, { a: 0 }).ease(luxe.tween.easing.Linear.easeNone).delay(0.2);
                            });
                            flash_timer += 1.5;
                        }
                    }
                }
            default:
        }
    }

    function do_action(action :Action) {
        Game.Instance.do_action(action);
        save_game();
    }

    function save_game() {
        // trace('save_game');
        if (game_over) return; // do not try to save game when game is over!
        if (!game_mode.persistable_game_mode()) return; // game mode should not be saved

        var save_data = {
            seed: Std.int(Luxe.utils.random.initial),
            score: score,
            events: Game.Instance.save()
        };
        // trace('save_data:');
        // trace(save_data);

        var succeeded = Luxe.io.string_save('save_${game_mode.get_game_mode_id()}', haxe.Json.stringify(save_data));
        if (!succeeded) trace('Save failed!');
    }

    function load_game() {
        // trace('load_game');
        var data_string = Luxe.io.string_load('save_${game_mode.get_game_mode_id()}');
        if (data_string == null) {
            trace('Save not found or failed to load!');
            return false;
        }
        try {
            var data = haxe.Json.parse(data_string);
            Luxe.utils.random.initial = Std.int(data.seed);
            score = data.score;
            // trace('data:');
            // trace(data);
            Game.Instance.load(data.events);
            return true;
        } catch (e :Dynamic) {
            trace('Failed to parse or load saved data. Error: $e');
            return false;
        }
    }

    function finish_tutorial() {
        tutorial_step_index = tutorial_steps.length;
        tutorial_can_drop = { x: -1, y: -1 };
        tutorial_can_collect = true;
        switch (game_mode) {
            case Tutorial(Normal): Luxe.io.string_save('tutorial_complete', 'true');
            case Tutorial(Strive(_)): Luxe.io.string_save('tutorial_complete_journey', 'true');
            case Tutorial(Timed): Luxe.io.string_save('tutorial_complete_timed', 'true');
            default: 
        }
        if (tutorial_box != null && tutorial_box.is_active()) tutorial_box.dismiss();
        Analytics.event('game', 'tutorial', 'finished');
    }

    function go_back() {
        if (tutorial_box != null && tutorial_box.is_active()) return;
        
        switch (game_mode) {
            case Strive(_) | Tutorial(Strive(_)): Main.SetState(JourneyState.StateId);
            default: Main.SetState(MenuState.StateId);
        };
    }

    var seed_number = 0;
    override function onkeyup(event :luxe.Input.KeyEvent) {
        switch (event.keycode) {
            #if debug
            case luxe.Input.Key.key_k: handle_game_over();
            case luxe.Input.Key.key_n: {
                @SuppressWarning("checkstyle:Trace")
                trace('debug: starting a new game');
                Luxe.io.string_save('save_${game_mode.get_game_mode_id()}', null); // clear the save
                start_new_game();
            }
            case luxe.Input.Key.key_r: {
                @SuppressWarning("checkstyle:Trace")
                trace('debug: resetting games played today');
                Luxe.io.string_save(game_mode.get_game_mode_id() + '_plays_today', '0');
            }
            case luxe.Input.Key.key_m:
                Luxe.audio.active = !Luxe.audio.active;
                if (!Luxe.audio.active) {
                    Luxe.audio.suspend();
                } else {
                    Luxe.audio.resume();
                }
            case luxe.Input.Key.key_s: save_game();
            case luxe.Input.Key.key_l: load_game();
            case luxe.Input.Key.key_q: // skip tutorial
                finish_tutorial();
                @SuppressWarning("checkstyle:Trace")
                trace('Tutorial skipped');
            // case luxe.Input.Key.key_p: tutorial.point_to(scoreText).then(tutorial.point_to(tiles.last()));
            // case luxe.Input.Key.key_q: tutorial.show(['This is tutorial', 'More text'], [tiles.first(), tiles[1], tiles.last()]);
            case luxe.Input.Key.key_t: Luxe.io.url_open('https://twitter.com/intent/tweet?original_referer=http://andersnissen.com&text=Stoneset tweet #Stoneset&url=http://andersnissen.com/');
            #end
            case luxe.Input.Key.ac_back: go_back();
            case luxe.Input.Key.escape: go_back();
        }
    }
}
