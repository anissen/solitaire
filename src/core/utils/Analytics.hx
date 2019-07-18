package core.utils;

import core.utils.AsyncHttpUtils;

#if android
@:build(snow.api.JNI.declare('com.anissen.stoneset.AppActivity'))
class AppActivity {
    public static function analytics(category :String, action :String, label :String, value :Int) :Void;
}
#end

class Analytics { 
    public static var tracking_id :String;
    public static var client_id :String;

    // https://developers.google.com/analytics/devguides/collection/protocol/v1/devguide
    public static function event(category :String, action :String, ?label :String, ?value :Int) {
        var maybe_label = (label != null ? '&el=$label' : '');
        var maybe_value = (value != null ? '&ev=$value' : '');
        analytics_request('t=event&ec=$category&ea=$action$maybe_label$maybe_value');

        #if android
            AppActivity.analytics(category, action, (label != null ? label : ''), (value != null ? value : -1));
        #end
    }

    public static function screen(screen :String) {
        var version = '1.0.2';
        analytics_request('t=screenview&an=Stoneset&av=$version&aid=com.anissen.stoneset&aiid=com.android.vending&cd=$screen');
    }

    static function analytics_request(url_part :String) {
        var rand :Int = Std.int(Math.random() * 100000000);
        var url = 'https://www.google-analytics.com/collect?v=1&tid=$tracking_id&cid=$client_id&$url_part&z=$rand';
        AsyncHttpUtils.get(url);
    }
}
