
Tasks:
* More tweeting!
* Landing page (stoneset.info?/stoneset.dk?)
    * https://startbootstrap.com/template-overviews/new-age/
    * https://startbootstrap.com/template-overviews/freelancer/
    * https://startbootstrap.com/template-overviews/grayscale/
* Update andersnissen.com
* Android release:
    * [ ] Notify spiludvikling.dk (facebook)
    * [ ] Notify indie game dev (facebook)
    * [ ] Notify Interactive Denmark
    * [x] Notify haxe.io
    * [x] Notify dkgame (twitter)
    * [x] Notify reddit (indiegame)
    * [ ] Notify touch arcade
    * [ ] Notify pocket tactics
* Screenshots on Google Play: Use the images to explain how the game works and what's special about it

HOOK: Build your own match-3

===== Beta launch line =====

BETA FEEDBACK
Doom:
[ ] Disable Settings and Abort state while main menu tutorial is active
[ ] Strive regler ikke helt forstået (Sean)

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

* "Invalid sound" should play when making a valid but non-matching selecting
* Make a "retry"-button if the server cannot be contacted
* Highscore button in Normal play mode
* Indicate low time in Survival somehow
* Make highlight tweets of
   * Images in tutorial
   * Pop text in play mode
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
* Crash when having poor/unstable internet connectivity
* Clicking the About button while the tutorial is *active* causes a crash (reported by Christoffer)
* Scores ending in '1' are slightly offset to the left
* Wrong scores are sometimes awarded when collecting stacked tiles in incorrect order
* The second level in journey mode was blank (reported by Caribou)
* Gaining 10 stars in Journey seems to award 11 stars on the menu screen
* Journey mode: Closing the app when the level is lost (before journey screen) then the progress is not updated (reported by Rasmus)
* Strive mode: Collecting tiles just after the timer runs out, can cause the score to be invalid and the game to hang (reported by Rasmus)
* MORE BUGS IN "BETA FEEDBACK"-SECTION!


* Make a top-100 list of all time highest scores
* Better explaination of "adjacent tiles" (versus straight lines)
* Better explaination of how the global scoring system works (ie. a score per game played)
* "Fix" my Journey score
* Backup the directory


iOS specific:
* If sound is disabled, and the app is resumed, the sound (not music) is re-enabled. 
* Links do not work on iOS and macOS

Nice:
* NICE-TO-HAVE: Make a simple checksum test on the server to validate the scores, etc.
* NICE-TO-HAVE: Move external libs into the repository (e.g. as git submodules)
* NICE-TO-HAVE: Change menu screen to only make one call to server instead of three
* NICE-TO-HAVE: Fade out the top and bottom in journey
* NICE-TO-HAVE: Screen showing where the stars come from (wins, journey, score)
* NICE-TO-HAVE: Being able to see all-time-highscores for Strive & Normal
