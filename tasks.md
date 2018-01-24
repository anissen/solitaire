
# Tasks:

Need: [what is the INTENT]
* Tutorial
    * Tutorial should start immediately (ie. bypass menu) if "tutorial completed" flag is not set in settings
* App icon -- done?
* Remove debug hooks, debug view
* Add some analytics
* [No default font]
* Settings screen:
    * Reset tutorial
    * Music on/off
    * Sounds on/off
* About screen:
    * Credits
    * Donation link
* Clean up bundled resources (especially music)
* "Invalid sound" should play when making a valid but non-matching selecting
* Music:
    * desert ambience always looping
    * temple of the mystics starting on main menu and playing in normal and strive
    * theme-3 plays on survival
    * theme-5 plays on puzzle
* Check that Survival has remaining seconds added to score on game over
* Put on Google Play beta program
* Set proper analytics ID
* Set a deterministic random seed per game

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
