(function() {
  var d;

  hack.items = {};

  d = function(n, x) {
    return [n, x];
  };

  hack.items.weapons = [['stone', 20, d(2, 3), 'hit'], ['longsword', 5, d(2, 6), 'slew'], ['mace', 10, d(2, 4), 'hit'], ['katana', 2, d(3, 6), 'slew']];

}).call(this);
