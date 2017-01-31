package ;

class RunTests {

  static function main() {
    trace('it works');
    #if flash
      flash.system.System.exit(0); //Don't forget to exit on flash!
    #end
  }

  /*
  class MyTests extends haxe.unit.TestCase {
    var deck = new Deck();

    override public function setup() {

    }

    // Every test function name has to start with 'test'

    public function testShuffle() {
        var cardsBefore = deck.get_cards();
        var countBefore = deck.count();
        deck.shuffle();
        assertTrue(deck.count() == countBefore);

        var changed = false;
        var cards = deck.get_cards();
        for (i in 0 ... cards.length) {
        	if (cardsBefore[i] != cards[i]) {
            	changed = true;
            	break;
        	}
        }

        assertTrue(changed);
        //print_cards(cards);
        //trace('3 top cards');
        //print_cards(take(3));
    }

    public function testMath1() {
        assertTrue(true);
    }

    public function testMath2() {
        assertFalse(false);
    }
}
    */
}
