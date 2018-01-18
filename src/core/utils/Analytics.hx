package core.utils;

class Analytics { 
    public static var tracking_id :String;
    public static var client_id :String;

    // https://developers.google.com/analytics/devguides/collection/protocol/v1/devguide
    public static function event(category :String, action :String, ?label :String, ?value :Int) {
        var maybe_label = (label != null ? '&el=$label' : '');
        var maybe_value = (value != null ? '&ev=$value' : '');
        analytics_request('t=event&ec=$category&ea=$action$maybe_label$maybe_value');
    }

    public static function screen(screen :String) {
        analytics_request('t=pageview&dh=stoneset&dp=$screen&dt=$screen');
    }

    static function analytics_request(url_part :String) {
        var rand :Int = Std.int(Math.random() * 100000000);
        var url = 'https://www.google-analytics.com/collect?v=1&tid=$tracking_id&cid=$client_id&$url_part&z=$rand';
        com.akifox.asynchttp.AsyncHttp.logEnabled = #if debug true #else false #end ;
        var request = new com.akifox.asynchttp.HttpRequest({ url: url });
        // callback : function(response:HttpResponse):Void {
        //     if (response.isOK) {
        //         trace(response.content);
        //         trace('DONE ${response.status}');
        //     } else {
        //         trace('ERROR ${response.status} ${response.error}');
        //     }
        // }  
        request.send();

        // #if web
        // var http = new haxe.Http(url);
        // // http.onData = function(data) {
        // //     trace('Result: $data');
        // // };
        // // http.onError = function(err) {
        // //     trace('Error: $err');
        // // };
        // // http.onStatus = function(status) {
        // //     trace('Status: $status');
        // // };
        // http.async = true;
        // http.request();
        // #end
    }
}
