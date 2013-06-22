(function() {
  var utils;

  hack.utils = utils = {};

  utils.randomInt = function(max) {
    return ~~(Math.random() * max);
  };

  utils.dice = function(n, x) {
    var i, nums;
    if (n == null) {
      n = 1;
    }
    if (x == null) {
      x = 4;
    }
    nums = (function() {
      var _i, _results;
      _results = [];
      for (i = _i = 1; 1 <= n ? _i <= n : _i >= n; i = 1 <= n ? ++_i : --_i) {
        _results.push(utils.randomInt(x));
      }
      return _results;
    })();
    return _.foldl(nums, (function(m, n) {
      return m + n;
    }), 0);
  };

}).call(this);
