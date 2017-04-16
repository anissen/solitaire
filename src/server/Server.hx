package server;

import js.node.Http;
import js.node.http.ServerResponse;
import js.node.http.IncomingMessage;
import js.node.Url;

class Server {
    static public function main() {
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
            // var query :Dynamic = params.query;
            
            var queryString = haxe.Json.stringify(query);
            switch (params.pathname) {
                case '/get_highscore': ok([{ score: 100, name: 'Aaa' }, { score: 90, name: 'Bbb' }]);
                case '/set_highscore' if (query.exists('score') && query.exists('name')): trace('setting highscore: ${query.get('score')} for ${query.get('name')}'); ok({ status: 'success' });
                // case '/set_highscore': trace('setting highscore: ${query.scores} for ${query.name}'); ok({ status: 'success' });
                case _: error({ error: 'Unknown endpoint "${params.pathname}"'});
            }
            // trace('query: $queryString');
            // trace('pathname: ${params.pathname}');

            // response.setHeader("Content-Type","text/json");
            // response.writeHead(200);
            // response.end(haxe.Json.stringify(data));
            trace('You got served!');
        });
        server.listen(1337, "localhost");
        trace('Server running at http://127.0.0.1:1337/');
    }
}