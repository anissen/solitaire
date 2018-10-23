
Tasks:
* More tweeting!
* Email list
    * https://tinyletter.com
* Landing page (stoneset.info?/stoneset.dk?)
    * https://startbootstrap.com/template-overviews/new-age/
    * https://startbootstrap.com/template-overviews/freelancer/
    * https://startbootstrap.com/template-overviews/grayscale/
* Update andersnissen.com
* Notify spiludvikling.dk (facebook)
* Notify Interactive Denmark
* Notify haxe.io
* Notify dkgame (twitter)
* Create facebook page
* Update Google Play screenshots (they are outdated)
* Screenshots on Google Play: Use the images to explain how the game works and what's special about it

===== Beta launch line =====

BETA FEEDBACK
Doom:
[ ] Game mode unlock: Jeg troede at man skulle have det i ét spil
[ ] Disable Settings and Abort state while main menu tutorial is active
[ ] Strive regler ikke helt forstået (Sean)
[ ] Audio var disabled men blev pludseligt enabled (Sean)

GOLD Niels & Daniel:
[ ] Vis back button efter Strive tutorial (glæder måske også for Survival?)

Kim:
[ ] Flyt + klik på symbol sætter åbenbart en ny origin for symbolet
[ ] "Audio off" bliver deaktiveret ved at minimere/restore app'en
[ ] Knapper kan flyttes ved at holde en finger på knappen og tappe andetsteds
[ ] Knapper på "change name" skærmen kan trykkes før de er tween'et ind [FIXED?]
[ ] Crash ved klik på "Play" på game over skærm, efter skift til local highscore [FIXED?]
END BETA FEEDBACK

* Use a logging package for heroku to be able to see logs
* Implement ability to view all highscores for a game mode, sorted by day (and maybe also by game count)
* SERVER: Implement crash handler (pm2/forever)
* SERVER: Make a dedicated 'today' page grouped by game mode and game #
* SERVER: Make a dedicated 'rankpage' page that can show scores and ties

* Global highscores
    [?] Handle Strive and Survival game modes
    [ ] Highscore button in play mode
    [ ] Handle Strive global highscore mode
    [ ] LATER: View all high scores
* Being able to view highscore list without having to finish a game
* [No default font]
* Clean up bundled resources
* "Invalid sound" should play when making a valid but non-matching selecting
* Music:
    * desert ambience always looping
    * temple of the mystics starting on main menu and playing in normal and strive
    * theme-3 plays on survival
    * theme-5 plays on puzzle
* Make a "retry"-button if the server cannot be contacted
* Make the background take up the entire screen (?)
* Rename "Normal" mode?
* Add some tutorial for wins/rank on the menu screen
* Make highlight tweets of
   * Wins/ranking juicy effects (e.g. plus show ranking screen)
   * Images in tutorial
   * Stars in highscore list?

Bugs:
* Crash when starting a normal game, then finishing another game mode and resuming the normal game
* In some cases, two tiles can be collected and simply disappears (reported by Niels and Daniel)
* If quest has [a, b, b] and [a, b] is collected the first [a, b, \_] should be highlighted in quests matched
* Clicking on grid selects multiple tiles
* Random crash when play
* Gems can be placed behind other gems in the hand (probably due to grabbed_card) (reported by Niels)
* Crash when resuming app (on android) after being inactive for a long time. Resuming on the menu screen in poor network conditions.
* [FIXED?] Starting a game on day 1 and finishing on day 2+ causes gameoverstate to increment plays for current day when it shouldn't
* Sometimes when going into Strive mode it only shows a blank screen and have to kill & reload the game (reported by Caribou)
* Possible bug: Resetting tutorial would cause a player to get multiple scores on that game seed
* Disabled audio is re-enabled when app is resumed (Sean, Kim, Anne)
* MORE BUGS IN "BETA FEEDBACK"-SECTION!

iOS specific:
* iOS app icon
* iOS launch icon
* If sound is disabled, and the app is resumed, the sound (not music) is re-enabled. 
* Links do not work on iOS and macOS
* Donations must (probably) be removed
    * Donation link
    * Donation tutorial text

Nice:
* Move external libs into the repository (e.g. as git submodules)
* Add scoring information to home screen (or e.g. sub-screens)
* Make the wins icon to a button that shows the changes since last time (#wins, #loses, MAYBE who you won over/lost to)
* Make Strive into a "Journey" mode with a (linear) map
    10 points   =>  1  star
    20 points   =>  1  star
    30 points   =>  1  star
    40 points   =>  1  star
    50 points   =>  5  star
    60 points   =>  2  star
    70 points   =>  2  star
    80 points   =>  2  star
    90 points   =>  2  star
    100 points  =>  10 star
    105 points  =>  5  star
    110 points  =>  5  star
    115 points  =>  5  star
    120 points  =>  5  star
    125 points  =>  20 star
    130 points  =>  10 star
    135 points  =>  10 star
    140 points  =>  10 star
    145 points  =>  10 star
    150 points  =>  40 star
    155 points  =>  20 star
    160 points  =>  20 star
    165 points  =>  20 star
    170 points  =>  20 star
    175 points  =>  50 star
* Achievements? { Intent: Gotta catch'em all }
* Share score via twitter
* Share picture of completion (see https://developer.android.com/training/sharing/send.html, https://github.com/Shin-NiL/Godot-Share/blob/master/share/android/GodotShare.java)
