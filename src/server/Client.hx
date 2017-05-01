package server;

class Client {
    static function get_highscores() {
        var http = new haxe.Http("http://localhost:1337/highscore");
        http.addParameter('name', 'Anders');
        http.addParameter('score', '37');
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
}