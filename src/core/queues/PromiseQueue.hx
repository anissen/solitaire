
package core.queues;

import snow.api.Promise;

class PromiseQueue<T> {
    var queue :List<T>;
    var temp_queue :List<T>;
    var idle :Bool;
    var handler :T->Promise;
    var finished_promise :Promise;
    var finished_func :Void->Void;
    public var is_finished (get, null) :Bool;

    public function new() {
        queue = new List();
        temp_queue = new List();
        idle = true;
        finished_promise = new Promise(function(resolve, reject) {
            finished_func = resolve;
        });
    }

    public function handle(element :T) :Promise {
        if (queue.isEmpty()) {
            queue.add(element);
            return handle_next_element();
        } else {
            temp_queue.add(element);
            return finished();
        }
    }

    public function set_handler(handler :T->Promise) {
        this.handler = handler;
    }

    public function finished() :Promise {
        return finished_promise;
    }

    function handle_next_element() :Promise {
        queue = queue.concat(temp_queue);
        temp_queue.clear();
        if (queue.isEmpty()) {
            idle = true;
            finished_func();
            return Promise.resolve();
        }
        return handle_element(queue.pop());
    }

    function handle_element(element :T) :Promise {
        if (handler == null) throw 'Handler not set!';
        idle = false;
        // trace('handling element: $element');
        return handler(element)
            .then(handle_next_element)
            .error(function(e) { trace('Error: $e'); });
    }

    function get_is_finished() {
        return idle && queue.isEmpty();
    }
}
