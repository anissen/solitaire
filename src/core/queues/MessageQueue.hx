
package core.queues;

typedef MessageQueueOptions = { serializable :Bool };

class MessageQueue<T> {
    public var on :T->Void;
    public var finished :Void->Void;
    var queue :Array<T>;
    var processing :Bool;
    var processed :Array<T>;
    var serializable :Bool;

    public function new(?options :MessageQueueOptions) {
        queue = [];
        processed = [];
        processing = false;
        on = null;
        finished = null;

        var has_serializable_property = options != null;
        serializable = has_serializable_property ? options.serializable : false;
    }

    public function emit(actions :Array<T>) {
        if (processing) {
            queue = queue.concat(actions);
            return;
        }
        processing = true;
        queue = actions.concat(queue);
        while (queue.length > 0) {
            var a = queue.shift();
            if (serializable) processed.push(a);
            if (on != null) on(a);
        }
        processing = false;
        if (finished != null) finished();
    }

    public function serialize() :String {
        if (!serializable) throw 'Cannot be serialized!';
        var serializer = new haxe.Serializer();
        serializer.serialize(processed);
        return serializer.toString();
    }

    public function deserialize(s :String) {
        var unserializer = new haxe.Unserializer(s);
        queue = unserializer.unserialize();
        emit([]); // HACK
    }
}
