
# Tasks:

Need:
* Make better graphics for quest background
* Make better graphics for stacked tiles
* Better background graphics
* Add sounds
* Automatic save and resume games
* Add game over screen
* Add main screen (or make an overlay menu)
* Tutorial
* App icon
* Remove debug hooks, debug view
* Add some analytics

Bugs:
* Releasing a card on the board (not on a tile) causes the card to hang (instead of tweening back to its origin)
* If quest has [a, b, b] and [a, b] is collected the first [a, b, _] should be highlighted in quests matched

Nice:
* Share score via twitter
* Move the general-purpose parts out of core and into turnabout (and reference it)
* Disable clicking (only dragging supported)