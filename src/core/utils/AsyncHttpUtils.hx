package core.utils;

typedef HttpCallback = {
    ?error :String,
    ?json :Dynamic
}

class AsyncHttpUtils {
    public static function get(url :String, ?callback :HttpCallback -> Void) {
        try {
            function callbackWrapper(response :com.akifox.asynchttp.HttpResponse) {
                if (callback == null) return;

                if (response.isOK) {
                    Luxe.next(callback.bind({ json: response.toJson() }));
                } else {
                    Luxe.next(callback.bind({ error: response.error }));
                }
            }

            var request = new com.akifox.asynchttp.HttpRequest({ url: url, callback: callbackWrapper });
            request.send();
        } catch (e :Dynamic) {
            trace('AsyncHttp:get error: ' + e);
        }
    }

    public static function post(url :String, data :Map<String,String>, ?callback :HttpCallback -> Void) {
        try {
            #if js

            var http = new haxe.Http(url);
            http.onData = function(data :String) {
                if (callback == null) return;

                Luxe.next(callback.bind({ json: haxe.Json.parse(data) }));
            }
            http.onError = function(error :String) {
                if (callback == null) return;

                Luxe.next(callback.bind({ error: error }));
            }
            
            for (key in data.keys()) {
                http.addParameter(key, data[key]);
            }

            http.request(true);

            #else

            function callbackWrapper(response :com.akifox.asynchttp.HttpResponse) {
                if (callback == null) return;

                if (response.isOK) {
                    Luxe.next(callback.bind({ json: response.toJson() }));
                } else {
                    Luxe.next(callback.bind({ error: response.error }));
                }
            }
            var request = new com.akifox.asynchttp.HttpRequest({ url: url, content: haxe.Json.stringify(data), callback: callbackWrapper });
            request.method = com.akifox.asynchttp.HttpMethod.POST;
            request.contentType = 'application/json';
            request.send();

            #end
        } catch (e :Dynamic) {
            trace('AsyncHttp:post error: ' + e);
        }
    }
}
