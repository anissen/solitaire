package game.misc;

import luxe.Color;

class Settings {
    // egypt theme:
    // static public var BACKGROUND_COLOR = new Color().rgb(0x914D50);
    // static public var CARD_COLOR = new Color().rgb(0xFFFFFF);
    // static public var CARD_HIGHLIGHT_COLOR = new Color().rgb(0x7FDBFF);
    // static public var CARD_STACKED_COLOR = new Color().rgb(0xF6CE8C);
    // static public var BOARD_BG_COLOR = new Color().rgb(0xF6CE8C);
    // static public var QUEST_BG_COLOR = new Color().rgb(0xF6CE8C);
    // static public var CARD_BG_COLOR = new Color().rgb(0xE8B89A);

    static public var BACKGROUND_COLOR = new Color().rgb(0xD5D5D5);
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
}