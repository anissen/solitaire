
package core.queues;

import snow.api.Promise;

class PromiseQueue<T> {
    var queue :List<T>;
    var idle :Bool;
    var handler :T->Promise;

    public function new() {
        queue = new List();
        idle = true;
    }

    public function handle(element :T) :Promise {
        queue.add(element);
        if (idle) return handle_next_element();
        return Promise.resolve();
    }

    public function set_handler(handler :T->Promise) {
        this.handler = handler;
    }

    function handle_next_element() :Promise {
        if (queue.isEmpty()) {
            idle = true;
            return Promise.resolve();
        }
        return handle_element(queue.pop());
    }

    function handle_element(element :T) :Promise {
        if (handler == null) throw 'Handler not set!';
        idle = false;
        return handler(element)
            .then(handle_next_element)
            .error(function(e) { trace('Error: $e'); });
    }
}
