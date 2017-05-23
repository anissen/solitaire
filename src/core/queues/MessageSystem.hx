
package core.queues;

import snow.api.Promise;

enum MessageType<TAction, TEvent> {
    Action(action :TAction);
    Event(event :TEvent);
}

class MessageSystem<TAction, TEvent> {
    var queue :PromiseQueue<MessageType<TAction, TEvent>>;

    // var actions :PromiseQueue<TAction>;
    // var action_list :Array<TAction>;
    // var events :PromiseQueue<TEvent>;
    var listeners :List<TEvent->Promise>;
    var processed_actions :Array<TAction>;
    var action_handler :TAction->Promise;
    // var event_promise :Promise;

    public function new() {
        listeners = new List(); // make into an array?
        processed_actions = [];
        // event_promise = Promise.resolve();

        /*
        actions = new PromiseQueue();
        actions.on = handle_action;
        // action_list = [];
        // action_handler = null;

        events = new PromiseQueue();
        events.set_handler(function(event :TEvent) {
            var promises :Array<Promise> = [];
            for (l in listeners) promises.push(l(event));
            return Promise.all(promises);
        });
        */
        
        queue = new PromiseQueue();
        queue.set_handler(function(element :MessageType<TAction, TEvent>) {
            switch (element) {
                case Action(action):
                    trace('ACTION: ${action}');
                    action_handler(action);
                    return Promise.resolve();
                case Event(event):
                    trace('EVENT: ${event}');
                    var promises :Array<Promise> = [];
                    for (l in listeners) promises.push(l(event));
                    return Promise.all(promises);
            }
        });
    }

    public function emit(event :TEvent) {
        // trace('EVENT: $event');
        return queue.handle(Event(event));
    }

    public function on_action(func :TAction->Promise) {
        action_handler = func;
    }

    // ACTION -> (handle + events, continue when )

    // function do_next_action() {
    //     var action = action_list.shift();
    //     trace('ACTION: $action');
    //     if (action == null) return;
        
    //     processed_actions.push(action);
    //     action_handler(action);
    // }

    public function do_action(action :TAction) {
        processed_actions.push(action);
        return queue.handle(Action(action));
        //var action = events.finished().then(do_next_action)
        //action_list.push(action);

        // if (processing) {
        //     queue = queue.concat(actions);
        //     return;
        // }
        // processing = true;
        // queue = actions.concat(queue);
        // while (queue.length > 0) {
        //     var a = queue.shift();
        //     if (serializable) processed.push(a);
        //     if (on != null) on(a);
        // }
        // processing = false;
        // if (finished != null) finished();
    }

    public function listen(func :TEvent->Promise) {
        listeners.add(func);
    }

    public function serialize() :String {
        var serializer = new haxe.Serializer();
        serializer.serialize(processed_actions);
        return serializer.toString();
    }

    public function deserialize(s :String) {
        processed_actions = [];
        var unserializer = new haxe.Unserializer(s);
        var action_list :Array<TAction> = unserializer.unserialize();
        // trace('replaying action: ${processed_actions[0]}');
        // do_action(processed_actions[0]);

        // var next = Promise.resolve();
        // for (action in action_list) {
        //     // trace('********* Replaying action: $action');
        //     next = next.then(do_action.bind(action));
        // }

        for (action in action_list) {
            do_action(action);
        }
        // Promise.all(action_list.map(do_action));

        // emit([]); // HACK
        // Some way of stepping through actions only when the corresponding events are done
    }
}
