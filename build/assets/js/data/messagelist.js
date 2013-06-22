(function() {
  var __slice = [].slice;

  hack.messagelist = {};

  hack.messagelist.format = function() {
    var args, str, variable, _i, _len;
    str = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    for (_i = 0, _len = args.length; _i < _len; _i++) {
      variable = args[_i];
      str = str.replace('?', variable);
    }
    return str;
  };

  hack.messagelist.trap = {
    stone: "A stone fell from above. The stone hits you.",
    hole: "A trap door opened under you.",
    teleport: "You felt an urge to core dump."
  };

  hack.messagelist.player = {
    attack: "You ? the ?."
  };

  hack.messagelist.monster = {
    attack: "the ? ? ?."
  };

}).call(this);
