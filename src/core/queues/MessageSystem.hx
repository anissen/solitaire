
package core.queues;

import snow.api.Promise;

typedef EventListenerFunction = core.models.Game.Event -> Promise;

class MessageSystem<TAction, TEvent> {
    var actions :MessageQueue<TAction>;
    var events :PromiseQueue<TEvent>;
    var listeners :List<TEvent->snow.api.Promise>;

    public function new() {
        listeners = new List();

        actions = new MessageQueue({ serializable: true });
        // actions.on = handle_action;

        events = new PromiseQueue();
        events.set_handler(function(event :TEvent) {
            var promises :Array<Promise> = [];
            for (l in listeners) promises.push(l(event));
            return Promise.all(promises);
        });
    }

    public function emit(event :TEvent) :Void {
        events.handle(event);
    }

    public function on_action(func :TAction->Void) {
        actions.on = func;
    }

    public function do_action(action :TAction) {
        actions.emit([action]);
    }

    public function listen(func :TEvent->snow.api.Promise) {
        listeners.add(func);
    }
}
