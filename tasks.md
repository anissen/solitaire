
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
* Change donation to use paypal.me/andersnissen
* Notify spiludvikling.dk (facebook)
* Notify dkgame (twitter)
* Create facebook page

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

* Global highscores
    [x] On-screen keyboard for entering name for highscores
    [x] Button(s) to toggle between local/global highscores
    [?] Handle Strive and Survival game modes
    [ ] Highscore button in play mode
    [ ] Handle Strive global highscore mode
    [ ] LATER: View all high scores
    [ ] LATER: Ranking
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
* Update Sparkle library
* Area particle effect when won/lost
* Make a "retry"-button if the server cannot be contacted

Bugs:
* Crash when starting a normal game, then finishing another game mode and resuming the normal game
* In some cases, two tiles can be collected and simply disappears
* If quest has [a, b, b] and [a, b] is collected the first [a, b, \_] should be highlighted in quests matched
* Clicking on grid selects multiple tiles
* Links do not work on iOS and macOS

iOS specific:
* iOS app icon
* iOS launch icon

Nice:
* Add scoring information to home screen (or e.g. sub-screens)
* Achievements? { Intent: Gotta catch'em all }
* Share score via twitter
* Share picture of completion (see https://developer.android.com/training/sharing/send.html, https://github.com/Shin-NiL/Godot-Share/blob/master/share/android/GodotShare.java)
