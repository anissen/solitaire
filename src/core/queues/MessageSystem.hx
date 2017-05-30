
package core.queues;

import snow.api.Promise;

enum MessageType<TAction, TEvent> {
    Action(action :TAction);
    Event(event :TEvent);
}

class MessageSystem<TAction, TEvent> {
    var queue :PromiseQueue<MessageType<TAction, TEvent>>;

    var listeners :List<TEvent->Promise>;
    var processed_actions :Array<TAction>;
    var action_handler :TAction->Promise;

    public function new() {
        listeners = new List(); // make into an array?
        processed_actions = [];
        
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
        return queue.handle(Event(event));
    }

    public function on_action(func :TAction->Promise) {
        action_handler = func;
    }

    public function do_action(action :TAction) {
        processed_actions.push(action);
        return queue.handle(Action(action));
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

        // Events are played correctly, but does not seem to complete in the correct order
        // processed_actions = action_list;
        // queue.handle_many([ for (action in action_list) Action(action) ]);

        // Events are seemingly played all at once but it doesn't break, somehow
        for (action in action_list) {
            do_action(action);
        }
    }
}
