
Tasks:
* Put on Google Play beta program
* More tweeting!
* Screenshots on Google Play: Use the images to explain how the game works and what's special about it
* Email list
    * https://tinyletter.com
* Landing page (stoneset.info?/stoneset.dk?)
    * https://startbootstrap.com/template-overviews/new-age/
    * https://startbootstrap.com/template-overviews/freelancer/
    * https://startbootstrap.com/template-overviews/grayscale/
* Update andersnissen.com
* Notify spiludvikling.dk (facebook)
* Notify dkgame (twitter)
* Create facebook page
* Update Google Play screenshots (they are outdated)

===== Beta launch line =====

BETA FEEDBACK
Doom:
[ ] Man kan ikke tage felter på skrå?
[-] Flawless gems kan ikke bruges som alm. gems
[ ] Game mode unlock: Jeg troede at man skulle have det i ét spil
[ ] Det er ikke tydeligt at man kan samle i ikke-lige linjer
[ ] Disable Settings and Abort state while main menu tutorial is active
[ ] Strive regler ikke helt forstået (Sean)
[ ] Audio var disabled men blev pludseligt enabled (Sean)

GOLD Niels & Daniel:
[ ] Vis back button efter Strive tutorial (glæder måske også for Survival?)

GOLD Rene:
[ ] Bedre forklaring af flawless gems

Kim:
[ ] Flyt + klik på symbol sætter åbenbart en ny origin for symbolet
[ ] "Audio off" bliver deaktiveret ved at minimere/restore app'en
[ ] Knapper kan flyttes ved at holde en finger på knappen og tappe andetsteds
[ ] Knapper på "change name" skærmen kan trykkes før de er tween'et ind
[ ] Crash ved klik på "Play" på game over skærm, efter skift til local highscore
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
* Images in tutorial to explain "collecting", "correct set order", "make a flawless gem"
* Clean up bundled resources
* "Invalid sound" should play when making a valid but non-matching selecting
* Music:
    * desert ambience always looping
    * temple of the mystics starting on main menu and playing in normal and strive
    * theme-3 plays on survival
    * theme-5 plays on puzzle
* Move external libs into the repository (e.g. as git submodules)
* Area particle effect when won/lost
* Make a "retry"-button if the server cannot be contacted
* Use limits on { games-played-star, highscores, ranking, ... } to account for MANY users
* Make a version file that Analytics reads from
* Speed up text and arrows in tutorial
* Make the background take up the entire screen (?)

Bugs:
* Crash when starting a normal game, then finishing another game mode and resuming the normal game
* In some cases, two tiles can be collected and simply disappears (reported by Niels and Daniel)
* If quest has [a, b, b] and [a, b] is collected the first [a, b, \_] should be highlighted in quests matched
* Clicking on grid selects multiple tiles
* Random crash when play
* Tutorial game mode are sent to server as game_mode 4 (how??)
* Gems can be placed behind other gems in the hand (probably due to grabbed_card) (reported by Niels)
* Text in plays-stars on menu screen are on top of tutorial

iOS specific:
* iOS app icon
* iOS launch icon
* Links do not work on iOS and macOS
* Donations must (probably) be removed
    * Donation link
    * Donation tutorial text

Nice:
* Add scoring information to home screen (or e.g. sub-screens)
* Make the wins icon to a button that shows the changes since last time (#wins, #loses, MAYBE who you won over/lost to)
* Make Strive into a "Journey" mode with a (linear) map
* Achievements? { Intent: Gotta catch'em all }
* Share score via twitter
* Share picture of completion (see https://developer.android.com/training/sharing/send.html, https://github.com/Shin-NiL/Godot-Share/blob/master/share/android/GodotShare.java)
