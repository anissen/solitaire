
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
import core.utils.Analytics;
import game.misc.GameMode.GameMode;

import particles.ParticleSystem;
import particles.ParticleEmitter;
import particles.modules.*;

using game.tools.TweenTools;
using game.misc.GameMode.GameModeTools;

typedef Card = Tile;

enum TutorialStep {
    Welcome;
    WhatIsTheGoal;
    Inventory;
    DrawingCards;
    DrawingSets;
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
    var quest_values = 12; // 13
    var card_values  = 8;  // 10
    var reshuffle_count :Int;

    var quests :Array<Card>;
    var tiles :Array<Card>;
    var collection :Array<Card>;

    var scoreText :luxe.Text;
    var counting_score :Float;
    var time_penalty :Float;
    var score :Int;

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
    var tutorial_steps :Array<TutorialStep> = [Welcome, Inventory, PlacingCards, PlacingCards2, PlacingCards3, PlacingCards4, CollectingSets, CollectingSets2, DragToCollectSets, Scoring, DrawingSets, DrawingCards, StackingTiles, GoodLuck];
    var tutorial_step_index :Int;
    var tutorial_can_drop :{ x :Int, y :Int };
    var tutorial_can_collect :Bool;
    
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

        Analytics.screen('PlayState/' + game_mode.get_game_mode_id());

        Luxe.utils.random.initial = switch (game_mode) {
            case Tutorial(_): 12;
            default: Std.int(10000 * Math.random()); // TODO: Should be incremented for each play
        }
        var could_load_game = load_game();
        if (!could_load_game) handle_new_game();
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
            initial_color : new Color(1,0,1,1),
            end_color : new Color(0,0,1,1),
            end_color_max : new Color(1,0,0,1)
        });
        pe_burst = new ParticleEmitter({
			name: 'tile_particle_emitter', 
			rate: 128,
			cache_size: 64,
			cache_wrap: true,
			duration: 0.1,
			modules: [
				new RadialSpawnModule({
                    radius: 5
                }),
				new LifeTimeModule({
					lifetime: 0.15,
					lifetime_max: 0.3
				}),
                pe_burst_color_life_module,
				new SizeLifeModule({
					initial_size: new Vector(10,10),
					end_size: new Vector(5,5)
				}),
				new DirectionModule({
					direction: 0,
					direction_variance: 360,
                    speed: 100
				})
			]
		});
        pe_burst.stop();
		ps.add(pe_burst);

        pe_continous_color_life_module = new ColorLifeModule({
            initial_color : new Color(1,0,1,0.5),
            end_color : new Color(0,0,1,0),
            end_color_max : new Color(1,0,0,0.5)
        });
        pe_continous = new ParticleEmitter({
			name: 'card_particle_emitter', 
			rate: 48,
			cache_size: 64,
			cache_wrap: true,
            depth: 9,
			modules: [
                new RadialSpawnModule({
                    radius: 10
                }),
				new LifeTimeModule({
					lifetime: 0.3,
					lifetime_max: 0.6
				}),
                pe_continous_color_life_module,
				new SizeLifeModule({
					initial_size: new Vector(10,10),
					end_size: new Vector(5,5)
				})
			]
		});
        pe_continous.stop();
		ps.add(pe_continous);

        var show_back_button = switch (game_mode) {
            case Tutorial(_): false;
            case _: true;
        };

        if (show_back_button) {
            var back_button = new game.ui.Icon({
                pos: new Vector(25, 25),
                texture_path: 'assets/ui/arrowBeige_left.png',
                on_click: Main.SetState.bind(MenuState.StateId)
            });
            back_button.scale.set_xy(1/5, 1/5);
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

        score = switch (game_mode) {
            case Normal: 0;
            case Strive(_): -game_mode.get_strive_score();
            case Timed: 30;
            case Puzzle: 0;
            case Tutorial(_): 0;
        };
        counting_score = score;
        time_penalty = 0;
        scoreText = new luxe.Text({
            pos: get_pos(1, -0.6),
            align: center,
            align_vertical: center,
            text: '$score',
            
            letter_spacing: -1.4,
            sdf: true,
            shader: Luxe.renderer.shaders.bitmapfont.shader.clone('title-shader'),
            outline: 0.7,
            outline_color: new Color().rgb(0xa55004)
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

        Analytics.event('game', 'start', game_mode.get_game_mode_id());

        return switch (game_mode) {
            case Tutorial(_): tutorial(TutorialStep.Welcome, { texts: ['Welcome to {brown}Stoneset{default}.', 'In {brown}Stoneset{default} you\nforge {brown}gemstones.', 'And complete {brown}sets{default}\nto collect riches!'] }).then(function() {
                    Game.Instance.new_game(tiles_x, tiles_y, deck, quest_deck);
                });
            default: Game.Instance.new_game(tiles_x, tiles_y, deck, quest_deck); Promise.resolve();
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
        // trace(event);
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

        // tutorial: once a gemstone has been placed in a socket, it cannot be moved
        // tutorial: collect adjacent gemstones to complete sets
        // tutorial: collect adjacent gemstones of the same type to create flawless gemstones

        return (tween != null ? tween.toPromise() : Promise.resolve());
    }

    function handle_new_quest(quest :Array<Card>) {
        play_sound('quest');
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

        play_sound('collect');

        if (total_score > 10) {
            play_sound('points_devine');
        }

        for (card in quest) {
            quests.remove(card);
            card.destroy();
        }
        return Promise.resolve();
    }

    function handle_stacked(card :Card) {
        play_sound('stack');
        card.stacked = true;
        Luxe.camera.shake(0.5);

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

        pe_burst.position.copy_from(card.pos);
        var color = card.get_original_color();
        color.a = 0.5;
        pe_burst_color_life_module.initial_color = color;
        pe_burst_color_life_module.end_color = color;
        pe_burst_color_life_module.end_color_max = new Color(1, 1, 1, 0);
        pe_burst.start();

        return Promise.resolve();
    }

    function handle_tile_placed(card :Card, x :Int, y :Int) {
        play_sound('place');
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
                trace('No component is added to card -- card is null or destroyed');
                return; // might happen when replaying (that card is removed in the same frame)
            }
            card.add(new Clickable(tile_clicked));
            card.add(new DragOver(tile_dragover));
        });

        pe_burst.position.copy_from(card.pos);
        pe_burst_color_life_module.initial_color = card.get_original_color();
        pe_burst_color_life_module.end_color = card.get_original_color();
        pe_burst_color_life_module.end_color_max = new Color(1, 1, 1, 0);
        pe_burst.start();

        tutorial(TutorialStep.CollectingSets, { texts: ['You collect adjacent\n{brown}gemstones{default} to form {brown}sets{default}.'], pos_y: (Settings.HEIGHT * (3/4) - 40) });

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

    function play_sound(id :String) {
        var sound = Luxe.resources.audio(Settings.get_sound_file_path(id));
        Luxe.audio.play(sound.source);
    }

    function handle_score(card_score :Int, card :Card, correct_order :Bool) {
        if (game_over) return Promise.resolve();

        var duration = 0.3;
        var delay = game.entities.Particle.Count * 0.15;
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
        if (correct_order) {
            var trail = new game.components.TrailRenderer();
            trail.trailColor.fromColor(card.color);
            trail.startSize = 8;
            trail.maxLength = 75;
            trail.depth = p.depth - 0.1;
            p.add(trail);
        }

        Actuate.tween(p.size, duration, { x: tile_size * 0.25, y: tile_size * 0.25 }).delay(delay).onComplete(function() {
            if (p != null && !p.destroyed) p.destroy();
            score += card_score;
            var textScale = scoreText.scale.x;
            if (textScale < 1.5) {
                textScale += 0.1 * card_score;
                scoreText.scale.set_xy(textScale, textScale);
            }
            var ring_symbol = new Sprite({
                texture: Luxe.resources.texture('assets/images/symbols/ring.png'),
                size: new Vector(tile_size / 2, tile_size / 2),
                pos: scoreText.pos,
                color: card.color
            });
            Actuate.tween(ring_symbol.color, 0.1, { a: 1.0 });
            Actuate.tween(ring_symbol.color, 0.1, { a: 0.0 }).delay(0.1);
            Actuate.tween(ring_symbol.size, 0.2, { x: tile_size * 2, y: tile_size * 2 }).onComplete(function() {
                if (!ring_symbol.destroyed) ring_symbol.destroy();
            });

            Luxe.camera.shake(card_score * (1 / 3));

            pe_burst.position.copy_from(scoreText.pos);
            var color = card.get_original_color();
            color.a = 0.5;
            pe_burst_color_life_module.initial_color = color;
            pe_burst_color_life_module.end_color = color;
            pe_burst_color_life_module.end_color_max = new Color(1, 1, 1, 0);
            pe_burst.start();

            if (card_score <= 1) {
                play_sound('points_small');
            } else if (card_score <= 3) {
                play_sound('points_big');
            } else { // score: 6
                play_sound('points_huge');
            }
            switch (game_mode) {
                case Strive(_): 
                    if (score >= 0) {
                        scoreText.color.tween(0.3, { r: 0.2, g: 0.8, b: 0.2 });
                        handle_game_over();
                    }
                default: 
            }
            // var strive_score = get_strive_score();
            // if (strive_score > 0 && score >= strive_score) {
            //     scoreText.color.tween(0.3, { r: 0.2, g: 1, b: 0.2 });
            //     handle_game_over();
            // }
            Actuate.tween(this, (score - counting_score) * 0.02, { counting_score: score }, true).onUpdate(function() {
                // var temp_score = Std.int(counting_score) - strive_score;
                scoreText.text = '${Std.int(counting_score - time_penalty)}';
            });
        });

        tutorial(TutorialStep.Scoring, { texts: ['Completing {brown}sets{default}\nincreases your score.', '{brown}Gemstones{default} can be\ncollected in any order.', 'Collecting in the correct\norder doubles the points.'], entities: [scoreText] });

        tutorial(TutorialStep.DrawingSets, { texts: ['Each turn you\nget a new {brown}set{default}.'], points: [ get_pos(0, tiles_y - 1.7), get_pos(1, tiles_y - 1.7), get_pos(2, tiles_y - 1.7) ], pos_y: (Settings.HEIGHT / 2) + 30 });
        tutorial(TutorialStep.DrawingCards, { texts: ['And three new\n{brown}gemstones{default}.'], points: [ get_pos(0, tiles_y + 1.8), get_pos(1, tiles_y + 1.8), get_pos(2, tiles_y + 1.8) ] });

        tutorial(TutorialStep.StackingTiles, { texts: ['This {brown}set{default} has a\n{brown}flawless{default} {ruby}ruby{default}.', '{brown}Flawless gemstones{default}\nmust be forged.', 'Combine three {brown}gemstones{default}\n of the same type...', 'And a {brown}flawless{default} version\nwill be forged.'], points: [ get_pos(1, tiles_y - 1.7) ], pos_y: (Settings.HEIGHT / 2) + 30 });

        tutorial(TutorialStep.GoodLuck, { texts: ['Now go make your\nfortune in {brown}Stoneset{default}.', 'Good luck!'] });

        return Promise.resolve();
    }

    function handle_game_over() {
        if (game_over) return Promise.resolve();
        game_over = true;

        Luxe.io.string_save('save_${game_mode.get_game_mode_id()}', null); // clear the save

        var new_game_mode :GameMode = game_mode;
        switch (game_mode) {
            case Strive(level):
                var win = (score >= 0); // strive score starts negative
                var new_level = (win ? level + 1 : level - 1);
                if (new_level < 1) new_level = 1;
                Luxe.io.string_save('strive_level', '$new_level');
                new_game_mode = Strive(new_level);
                play_sound(win ? 'won' : 'lost');
            case Normal:
                play_sound('won');
            case Timed:
                score = Std.int(time_penalty); // set the score to be the time survived
                play_sound((counting_score - time_penalty > 0) ? 'won' : 'lost');
            case Puzzle:
                play_sound('won');
            case Tutorial(mode):
                new_game_mode = mode;
                play_sound('won');
        }

        var delay = 0.0;
        for (tile in tiles) {
            tile.show_tile_graphics(false).delay(delay);
            delay += 0.05;
        }

        switch (game_mode) {
            case Timed:
                scoreText.color.tween(0.3, { r: 0.0, g: 0.0, b: 0.0 });
                // trace('time_penalty: $time_penalty');
                counting_score = 0.0;
                var tween = Actuate.tween(this, time_penalty * 0.05, { counting_score: time_penalty }, true).onUpdate(function() {
                    // trace('counting_score: $counting_score');
                    scoreText.text = '${Std.int(counting_score)} sec';
                });
                return tween.toPromise().then(switch_to_game_over_state.bind(new_game_mode));
            default:
                return switch_to_game_over_state(new_game_mode);
        }
    }

    function switch_to_game_over_state(next_game_mode :GameMode) {
        var the_score :Int = switch (game_mode) {
            case Timed: Std.int(time_penalty);
            case Strive(level): game_mode.get_strive_score() + score;
            default: score;
        };
        Analytics.event('game', 'over', 'score', the_score);
        Luxe.timer.schedule(1.5, function() {
            Main.SetState(GameOverState.StateId, {
                // client: 'my-client-id-'  + Math.floor(1000 * Math.random()), // TODO: Get client ID from server initially, store it locally
                // name: 'Name' + Math.floor(1000 * Math.random()), // TODO: Use correct name
                score: the_score,
                game_mode: next_game_mode
            });
        });
        return Promise.resolve();
    }

    function grid_clicked(x :Int, y :Int, sprite :Sprite) {
        if (game_over) return;
        if (grabbed_card == null) return;
        if ((tutorial_box.is_active() && (tutorial_can_drop.x != x || tutorial_can_drop.y != y)) || !Game.Instance.is_placement_valid(x, y)) {
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
            trace('!is_collection_valid');
            play_sound('invalid');
            clear_collection();
            return;
        }

        play_sound('tile_click');

        if (collection.length == 3) {
            trace('collection.length == 3');
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
        
        pe_continous.position.copy_from(grabbed_card.pos);
        var color = grabbed_card.get_original_color();
        color.a = 0.5;
        pe_continous_color_life_module.initial_color = color;
        pe_continous_color_life_module.end_color = color;
        pe_continous_color_life_module.end_color_max = new Color(1, 1, 1, 0);
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
    }

    override function onmousemove(event :luxe.Input.MouseEvent) {
        if (game_over) return;
        if (grabbed_card != null) {
            var world_pos = Luxe.camera.screen_point_to_world(Vector.Subtract(event.pos, grabbed_card_offset));
            grabbed_card.pos = world_pos;
            pe_continous.position.copy_from(world_pos);
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
        if (game_over) return;
        ps.update(dt);
        var textScale = scoreText.scale.x; 
        if (textScale > 1) scoreText.scale.set_xy(textScale - dt, textScale - dt);
        switch (game_mode) {
            case Timed if (!game_over):
                time_penalty += dt;
                scoreText.text = '${Std.int(counting_score - time_penalty)}';
                if ((counting_score - time_penalty) < 0) {
                    scoreText.color.tween(0.3, { r: 1, g: 0.2, b: 0.2 });
                    handle_game_over();
                }
            default:
        }
    }

    function do_action(action :Action) {
        Game.Instance.do_action(action);
        save_game();
    }

    function save_game() {
        if (game_over) return; // do not try to save game when game is over!
        if (!game_mode.persistable_game_mode()) return; // game mode should not be saved

        var save_data = {
            seed: Std.int(Luxe.utils.random.initial),
            score: score,
            events: Game.Instance.save()
        };

        // trace('save_data: $save_data');

        var succeeded = Luxe.io.string_save('save_${game_mode.get_game_mode_id()}', haxe.Json.stringify(save_data));
        if (!succeeded) trace('Save failed!');
    }

    function load_game() {
        var data_string = Luxe.io.string_load('save_${game_mode.get_game_mode_id()}');
        if (data_string == null) {
            trace('Save not found or failed to load!');
            return false;
        }
        try {
            // trace('load_data: $data_string');
            var data = haxe.Json.parse(data_string);
            Luxe.utils.random.initial = Std.int(data.seed);
            score = data.score;
            Game.Instance.load(data.events);
            return true;
        } catch (e :Dynamic) {
            trace('Failed to parse or load saved data. Error: $e');
            return false;
        }
    }

    var seed_number = 0;
    override function onkeyup(event :luxe.Input.KeyEvent) {
        switch (event.keycode) {
            #if debug
            case luxe.Input.Key.key_k: handle_game_over();
            case luxe.Input.Key.key_n: {
                Luxe.io.string_save('save_${game_mode.get_game_mode_id()}', null); // clear the save
                Luxe.utils.random.initial = seed_number++;
                handle_new_game();
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
            // case luxe.Input.Key.key_p: tutorial.point_to(scoreText).then(tutorial.point_to(tiles.last()));
            // case luxe.Input.Key.key_q: tutorial.show(['This is tutorial', 'More text'], [tiles.first(), tiles[1], tiles.last()]);
            case luxe.Input.Key.key_t: Luxe.io.url_open('https://twitter.com/intent/tweet?original_referer=http://andersnissen.com&text=Stoneset tweet #Stoneset&url=http://andersnissen.com/');
            #end
            case luxe.Input.Key.escape: Main.SetState(MenuState.StateId);
        }
    }
}
