package server;

class Client {
    static function get_highscores() {
        // return haxe.Http.requestUrl("http://localhost:1337");
        var http = new haxe.Http("http://localhost:1337/set_highscore");
        http.addParameter('name', 'Anders');
        http.addParameter('score', '42');
        http.addParameter('blah', '66');
        http.onError = function(data) {
            trace('error: $data');
        }
        http.onStatus = function(data) {
            trace('status: $data');
        }
        http.onData = function(data) {
            trace('data: $data');
        }
        http.request();
    }

    static function main() {
        get_highscores();
        trace('done');    
    }

    // static function main() {
    // var http = new haxe.Http("http://localhost:5000");
    // http.onError = function(data) {
	// 	trace('error: $data');
    // }
    // http.onStatus = function(data) {
	// 	trace('status: $data');
    // }
    // http.onData = function(data) {
	// 	trace('data: $data');
    // }
    // http.request();
    // trace('done');

        // var s = new sys.net.Socket();
        // s.connect(new sys.net.Host("localhost"), 5000);
        // while( true ) {
        //     var l = s.input.readLine();
        //     trace(l);
        //     if( l == "exit" ) {
        //         s.close();
        //         break;
        //     }
        // }
    // }
}