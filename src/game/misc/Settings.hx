package game.misc;

import luxe.Color;

class Settings {

    static public function get_sound_file_path(id :String) {
        var audio_type = #if web 'mp3' #else 'ogg' #end;
        return 'assets/sounds/$id.$audio_type';
    }

    static public function get_music_file_path(id :String) {
        var audio_type = #if web 'mp3' #else 'ogg' #end;
        return 'assets/music/$id.$audio_type';
    }

    static public function load_string(key :String, default_value :String) :String {
        var data = Luxe.io.string_load(key);
        if (data == null) return default_value;
        
        return data;
    }

    static public function load_int(key :String, default_value :Int) :Int {
        var data = Luxe.io.string_load(key);
        if (data == null) return default_value;
        
        var value = Std.parseInt(data);
        if (value == null) return default_value;

        return value;
    }

    static public function save_int(key :String, value :Int) {
        Luxe.io.string_save(key, '$value');
    }
 
    static public function get_journey_stars_for_level(level :Int) :Int {
        if (level < 0) return 0;
        var stars = [0, 1, 1, 1, 1, 3, 1, 1, 1, 1, 5, 2, 2, 2, 2, 10, 5, 5, 5, 5, 20, 10, 10, 10, 10, 30, 20, 20, 20, 20, 50, 40, 40, 40, 40, 70, 60, 60, 60, 60, 100];
        if (level > stars.length) return 0;
        return stars[level];
    }

    // egypt theme:
    // static public var BACKGROUND_COLOR = new Color().rgb(0x914D50);
    // static public var CARD_COLOR = new Color().rgb(0xFFFFFF);
    // static public var CARD_HIGHLIGHT_COLOR = new Color().rgb(0x7FDBFF);
    // static public var CARD_STACKED_COLOR = new Color().rgb(0xF6CE8C);
    // static public var BOARD_BG_COLOR = new Color().rgb(0xF6CE8C);
    // static public var QUEST_BG_COLOR = new Color().rgb(0xF6CE8C);
    // static public var CARD_BG_COLOR = new Color().rgb(0xE8B89A);

    static public var BACKGROUND_COLOR = new Color().rgb(0xFBF3E0);
    static public var QUEST_BG_COLOR = new Color().rgb(0xDDDDDD);
    static public var BOARD_BG_COLOR = new Color().rgb(0xD3BF8F);
    static public var CARD_BG_COLOR = new Color().rgb(0xCCCCCC);

    static public var CARD_COLOR = new Color().rgb(0xFFFFFF);
    static public var CARD_STACKED_COLOR = new Color().rgb(0x000000);
    static public var CARD_HIGHLIGHT_COLOR = new Color().rgb(0x7FDBFF);

    static public var SYMBOL_COLORS = [
        new Color().rgb(0x0db8b5), // blue
        new Color().rgb(0xffe433), // yellow
        new Color().rgb(0xd92727), // red
        new Color().rgb(0x6fcc43), // green
        new Color().rgb(0xfc8f12)  // orange
    ];

    static public var WIDTH  = 270;
    static public var HEIGHT = 480;

    static public var SERVER_URL = #if (debug && !android && !ios) 'http://localhost:3000/' #else 'https://stoneset.herokuapp.com/' #end ;
}
