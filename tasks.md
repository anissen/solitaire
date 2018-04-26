
Tasks:
* App icon -- done?
* Put on Google Play beta program
* More tweeting!
* Settings: "Music off" does not work
* Screenshots on Google Play: Use the images to explain how the game works and what's special about it
* Email list
* Landing page (stoneset.info?/stoneset.dk?)

===== Beta launch line =====

* [No default font]
* iOS app icon
* iOS launch icon
* Clean up bundled resources
* "Invalid sound" should play when making a valid but non-matching selecting
* Music:
    * desert ambience always looping
    * temple of the mystics starting on main menu and playing in normal and strive
    * theme-3 plays on survival
    * theme-5 plays on puzzle
* Make a better highscore list for Strive
* Move external libs into the repository (e.g. as git submodules)

Bugs:
* If quest has [a, b, b] and [a, b] is collected the first [a, b, _] should be highlighted in quests matched
* Clicking on grid selects multiple tiles
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
* Share picture of completion (see https://developer.android.com/training/sharing/send.html, https://github.com/Shin-NiL/Godot-Share/blob/master/share/android/GodotShare.java)
