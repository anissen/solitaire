package core.utils;

class Analytics { 
    public static var tracking_id :String;
    public static var client_id :String;

    public static function event(category :String, action :String, ?label :String, ?value :Int) {
        var rand :Int = Std.int(Math.random() * 100000000);
        var maybe_label = (label != null ? '&el=$label' : '');
        var maybe_value = (value != null ? '&ev=$value' : '');
        var url = 'https://www.google-analytics.com/collect?v=1&tid=$tracking_id&cid=$client_id&t=event&ec=$category&ea=$action$maybe_label$maybe_value&z=$rand';
        var http = new haxe.Http(url);
        // http.onData = function(data) {
        //     trace('Result: $data');
        // };
        // http.onError = function(err) {
        //     trace('Error: $err');
        // };
        // http.onStatus = function(status) {
        //     trace('Status: $status');
        // };
        #if web
        http.async = true;
        #end
        http.request();
    }

    // public static function screen(screen :String) {
    //     var rand :Int = Std.int(Math.random() * 100000000);
    //     var url = 'https://www.google-analytics.com/collect?v=1&tid=$tracking_id&cid=$client_id&t=screenview&an=solitaire&av=0.4.0&aid=anissen.solitaire&cd=$screen&z=$rand';
    //     var http = new haxe.Http(url);
    //     // http.onData = function(data) {
    //     //     trace('Result: $data');
    //     // };
    //     // http.onError = function(err) {
    //     //     trace('Error: $err');
    //     // };
    //     // http.onStatus = function(status) {
    //     //     trace('Status: $status');
    //     // };
    //     #if web
    //     http.async = true;
    //     #end
    //     http.request();
    // }
    public static function screen(screen :String) {
        var rand :Int = Std.int(Math.random() * 100000000);
        var url = 'https://www.google-analytics.com/collect?v=1&tid=$tracking_id&cid=$client_id&t=pageview&dh=solitaire&dp=$screen&dt=$screen&z=$rand';
        var http = new haxe.Http(url);
        // http.onData = function(data) {
        //     trace('Result: $data');
        // };
        // http.onError = function(err) {
        //     trace('Error: $err');
        // };
        // http.onStatus = function(status) {
        //     trace('Status: $status');
        // };
        #if web
        http.async = true;
        #end
        http.request();
    }
}
