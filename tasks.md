
# Tasks:

Need:
* Better tile graphics (to indicate depth)
* Add game over screen
* Tutorial
* App icon
* Remove debug hooks, debug view
* Add some analytics
* [No default font]
* Convert sounds to MP3 for better browser compability
* Strive: Change the title to e.g. "Strive for 120 points" and complete the game when the points have been reached 

Bugs:
* If quest has [a, b, b] and [a, b] is collected the first [a, b, _] should be highlighted in quests matched
* Cards can still get stuck on the background
* A tile can be selected while dragging a grabbed card
* Choosing "Play" on the game over screen always plays a normal game (e.g not the next strive game)

Nice:
* Better background graphics
* Share score via twitter
* Outlines on text
* State transitions (fade)
* Trails on symbol particles (https://gist.github.com/le-doux/d9ac94af66c2b9a86238)
* Move the general-purpose parts out of core and into turnabout (and reference it)