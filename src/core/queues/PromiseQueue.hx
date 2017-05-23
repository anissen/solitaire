
package core.queues;

import snow.api.Promise;

class PromiseQueue<T> {
    var queue :List<T>;
    var temp_queue :List<T>;
    var handler :T->Promise;

    public function new() {
        queue = new List();
        temp_queue = new List();
    }

    public function handle(element :T) :Promise {
        if (queue.isEmpty()) {
            queue.add(element);
            return handle_next_element();
        } else {
            temp_queue.add(element);
            return Promise.resolve();
        }
    }

    public function set_handler(handler :T->Promise) {
        this.handler = handler;
    }

    function handle_next_element() :Promise {
        queue = queue.concat(temp_queue);
        temp_queue.clear();
        if (queue.isEmpty()) return Promise.resolve();
        return handle_element(queue.pop());
    }

    function handle_element(element :T) :Promise {
        if (handler == null) throw 'Handler not set!';
        return handler(element)
            .then(handle_next_element)
            .error(function(e) { trace('Error: $e'); });
    }
}
