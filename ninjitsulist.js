// Generated by CoffeeScript 1.3.2
var ninjitsulist;

ninjitsulist = [
  {
    name: 'jistu of healing',
    jitsu: (function(game) {
      return game.player.hp = game.player.getMaxHP();
    }),
    description: 'heals your hp to the maximum',
    message: 'You spelled the jitsu of healing. You are fully recovered.'
  }, {
    name: 'jistu of superattack',
    jitsu: (function(game) {
      var cells, m, pp, _i, _len, _results;
      pp = game.player.getPosition();
      cells = game.currentMap().getNearByCells(pp.x, pp.y);
      _results = [];
      for (_i = 0, _len = cells.length; _i < _len; _i++) {
        m = cells[_i];
        if ((m != null) && m) {
          _results.push(m.hp = 0);
        }
      }
      return _results;
    }),
    description: 'kills all the enemies on your nearby cells',
    message: 'Your nearby cells are cleared out! Yahoo!'
  }, {
    name: 'jitsu of hiding',
    jitsu: (function(game) {
      var ctr, f, i, map, pp, _i;
      pp = game.player.getPosition();
      map = game.currentMap();
      map.clearReservation(pp.x, pp.y);
      ctr = 0;
      game.on('turn', function() {
        return ctr++;
      });
      for (i = _i = 0; _i < 20; i = ++_i) {
        game.fire('turn');
      }
      return (f = function() {
        if (ctr >= 20) {
          return game.player.born(map);
        } else {
          return setTimeout(f, 10);
        }
      })();
    }),
    description: 'hides for 20 turns and teleports',
    message: 'You hid for 20 turns.'
  }, {
    name: 'jitsu of level teleport',
    jitsu: (function(game) {
      var i, tolevel, _i, _ref, _results;
      tolevel = Math.floor(Math.random() * game.level);
      if (tolevel !== game.level) {
        _results = [];
        for (i = _i = _ref = game.level; _ref <= tolevel ? _i < tolevel : _i > tolevel; i = _ref <= tolevel ? ++_i : --_i) {
          _results.push(game.fire('goup'));
        }
        return _results;
      }
    }),
    description: 'Go back up to a random floor level',
    message: 'Some magical power pulled your pants up.'
  }
];
