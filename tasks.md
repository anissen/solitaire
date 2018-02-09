
# Tasks:

Need, in order of importance: [what is the INTENT]
* Tutorial
    * Tutorial should start immediately (ie. bypass menu) if "tutorial completed" flag is not set in settings
    * Key items for tutorial
        * [Play state]
            * Drag GEMSTONES into sockets
            * Complete SETS
            * Collect GEMSTONES
            * Collect VERTICALLY or HORISONTALLY (or both)
            * (New cards and sets after each hand -- required info?)
            * Combine GEMSTONES into "super gemstones" (find better word)
            * Collect in the right ORDER to gain double points
            * Compete for the highscore
        * [Main menu]
            * Gain points to unlock new play modes
* App icon -- done?
* Analytics on 
    * Donation button
    * Website link
    * More game play related things
* Remove debug hooks, debug view
* Set proper analytics ID
* Setup itch to use google analytics
* Set a deterministic random seed per game
* Put on Google Play beta program

===== Beta launch line =====

* [No default font]
* Settings screen:
    * Reset tutorial
* About screen:
    * Change text highlight colors
    * Donation link fix
* Clean up bundled resources
* "Invalid sound" should play when making a valid but non-matching selecting
* Music:
    * desert ambience always looping
    * temple of the mystics starting on main menu and playing in normal and strive
    * theme-3 plays on survival
    * theme-5 plays on puzzle
* Check that Survival has remaining seconds added to score on game over
* Make a better highscore list for Strive
* Move external libs into the repository

Bugs:
* If quest has [a, b, b] and [a, b] is collected the first [a, b, _] should be highlighted in quests matched
* Clicking on grid selects multiple tiles
* Survival can give invalid score (probably due to last score occuring _after_ game over)
* If game starts with audio disabled, enabling audio does not start the music

Nice:
* Global highscores
* On-screen keyboard for entering name for highscores
* Share score via twitter
* Score indicator on the main menu
* Puzzle mode
* Achievements? { Intent: Gotta catch'em all }
* Multi-touch for dragging tiles?
* Add scoring information to home screen (or e.g. sub-screens)
* Move the general-purpose parts out of core and into turnabout (and reference it)
