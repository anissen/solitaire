
# Tasks:

Need:
* Make better graphics for quest background
* Better background graphics
* Add sounds
* Add game over screen
* Add main screen (or make an overlay menu)
* Tutorial
* App icon
* Remove debug hooks, debug view
* Add some analytics

Bugs:
* If quest has [a, b, b] and [a, b] is collected the first [a, b, _] should be highlighted in quests matched
* If multiple quests match the collected tiles, the highest-scoring quest should be completed

Nice:
* Share score via twitter (e.g Luxe.io.url_open('https://twitter.com/intent/tweet?original_referer=http://andersnissen.com&text=Solitaire tweet&url=http://andersnissen.com/');)
* Move the general-purpose parts out of core and into turnabout (and reference it)
* Disable clicking (only dragging supported)