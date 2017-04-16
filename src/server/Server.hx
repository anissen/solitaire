package server;

import js.node.Http;
import js.node.http.ServerResponse;
import js.node.http.IncomingMessage;
import js.node.Url;

using Lambda;

typedef Highscore = { name :String, score :Int /*, seed :String, time :Date */ };

class Server {
    static public function main() {
        var highscore_file = 'highscores.json';
        var highscores :Array<Highscore> = (sys.FileSystem.exists(highscore_file) ? haxe.Json.parse(sys.io.File.getContent(highscore_file)) : []);
        
        function get_highscores() {
            return highscores;
        }

        function set_highscore(highscore :Highscore) {
            var highscores = get_highscores();
            highscores.push(highscore);
            sys.io.File.saveContent(highscore_file, haxe.Json.stringify(highscores));
        }

        var server = Http.createServer(function(request :IncomingMessage, response :ServerResponse) {
            function send(data :Dynamic, status :Int) {
                response.setHeader("Content-Type","text/json");
                response.writeHead(status);
                response.end(haxe.Json.stringify(data));
            }
            function ok(data :Dynamic) send(data, 200);
            function error(data :Dynamic) send(data, 500);

            var params = Url.parse(request.url, true);
            var query :haxe.DynamicAccess<String> = params.query;
            
            switch (params.pathname) {
                case '/get_highscore': ok(get_highscores());
                case '/set_highscore' if (query.exists('score') && query.exists('name')):
                    trace('setting highscore: ${query.get('score')} for ${query.get('name')}');
                    set_highscore({ name: query.get('name'), score: Std.parseInt(query.get('score')) /*, seed: query.get('seed'), time:  Date.fromString(query.get('time')) */ });
                    ok(get_highscores().filter(function(h) { return h.score > 50; }));
                case _: error({ error: 'Unknown endpoint "${params.pathname}"'});
            }
            trace('You got served!');
        });
        server.listen(1337, "localhost");
        trace('Server running at http://127.0.0.1:1337/');
    }
}