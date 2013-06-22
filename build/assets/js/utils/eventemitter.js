(function() {

  hack.EventEmitter = (function() {

    function EventEmitter() {
      this.listenerStack = [];
    }

    EventEmitter.prototype.on = function(type, listener) {
      return this.listenerStack.push({
        type: type,
        listener: listener
      });
    };

    EventEmitter.prototype.off = function(type, listener) {
      var _this = this;
      return this.listenerStack = _.reject(this.listenerStack, function(stack) {
        return (stack.type === type) && (stack.listener === listener);
      });
    };

    EventEmitter.prototype.fire = function(type, obj) {
      var item, _i, _len, _ref, _results;
      _ref = this.listenerStack;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        if (item.type === type) {
          _results.push(item.listener(obj));
        }
      }
      return _results;
    };

    return EventEmitter;

  })();

}).call(this);
