(function() {
  var Map;

  Map = hack.Map;

  hack.commands = {
    '>': function(game) {
      var pp;
      pp = game.player.getPosition();
      if (game.currentMap().getCell(pp.x, pp.y) === Map.STAIR_DOWN) {
        game.fire('godown');
      }
      return null;
    },
    '<': function(game) {
      var pp;
      pp = game.player.getPosition();
      if (game.level > 0 && game.currentMap().getCell(pp.x, pp.y) === Map.STAIR_UP) {
        game.fire('goup');
      }
      return null;
    },
    ';': function(game) {
      var it, possibleItems, pp, _i, _len;
      pp = game.player.getPosition();
      possibleItems = game.getItems(pp.x, pp.y);
      if ((possibleItems != null ? possibleItems.length : void 0) != null) {
        for (_i = 0, _len = possibleItems.length; _i < _len; _i++) {
          it = possibleItems[_i];
          if (it != null) {
            game.fire('message', {
              message: it.name
            });
          }
        }
      }
      return null;
    },
    ',': function(game) {
      var cch, possibleItems, pp;
      pp = game.player.getPosition();
      possibleItems = game.getItems(pp.x, pp.y);
      if (possibleItems != null) {
        cch = game.player.inventory.addItem(possibleItems[0]);
        if (cch != null) {
          game.fire('message', {
            message: "You picked up a " + possibleItems[0].name + " - " + cch + "."
          });
        }
        if (cch != null) {
          game.shiftItem(pp.x, pp.y);
        }
      }
      return null;
    },
    'i': function(game) {
      var ch, disparr, item;
      disparr = (function() {
        var _ref, _results;
        _ref = game.player.inventory.listItems();
        _results = [];
        for (ch in _ref) {
          item = _ref[ch];
          if (item != null) {
            _results.push("" + ch + " - " + item.name + "(" + (item.dice.join('d')) + ")");
          }
        }
        return _results;
      })();
      game.fire('message', {
        message: disparr.join('\n')
      });
      console.log(game.player.inventory.listItems());
      return null;
    },
    'w': function(game) {
      return function(ch) {
        var weapon;
        weapon = game.player.wield(ch);
        if (weapon != null) {
          game.fire('message', {
            message: "You wielded the " + weapon.name + " " + weapon.dice[0] + "d" + weapon.dice[1] + "."
          });
        }
        game.fire('turn');
        return null;
      };
    },
    'd': function(game) {
      var pp;
      pp = game.player.getPosition();
      return function(ch) {
        var item;
        item = game.player.inventory.removeItem(ch);
        console.log(item);
        game.addItem(pp.x, pp.y, item);
        return null;
      };
    },
    'x': function(game, dir) {
      var isOkToGo, map, nextd, pp, prevd;
      if (dir == null) {
        dir = {
          d: 'u',
          x: 0,
          y: -1,
          hd: 'r',
          hx: 1,
          hy: 0
        };
      }
      if (game.player.isDead()) {
        alert('You died.');
      }
      map = game.currentMap();
      pp = game.player.getPosition();
      nextd = {
        u: {
          d: 'l',
          x: -1,
          y: 0,
          hd: 'u',
          hx: 0,
          hy: -1
        },
        l: {
          d: 'd',
          x: 0,
          y: 1,
          hd: 'l',
          hx: -1,
          hy: 0
        },
        d: {
          d: 'r',
          x: 1,
          y: 0,
          hd: 'd',
          hx: 0,
          hy: 1
        },
        r: {
          d: 'u',
          x: 0,
          y: -1,
          hd: 'r',
          hx: 1,
          hy: 0
        }
      };
      prevd = {
        u: {
          d: 'r',
          x: 1,
          y: 0,
          hd: 'd',
          hx: 0,
          hy: 1
        },
        l: {
          d: 'u',
          x: 0,
          y: -1,
          hd: 'r',
          hx: 1,
          hy: 0
        },
        d: {
          d: 'l',
          x: -1,
          y: 0,
          hd: 'u',
          hx: 0,
          hy: -1
        },
        r: {
          d: 'd',
          x: 0,
          y: 1,
          hd: 'l',
          hx: -1,
          hy: 0
        }
      };
      isOkToGo = function(x, y) {
        if (map.isWalkable(x, y) || map.isAttackable(x, y)) {
          return true;
        } else {
          return false;
        }
      };
      if (map.getCell(pp.x, pp.y) === Map.STAIR_DOWN) {
        hack.commands['>'](game);
      } else if (isOkToGo(pp.x + dir.x, pp.y + dir.y)) {
        if (!isOkToGo(pp.x + dir.hx, pp.y + dir.hy)) {
          game.player.walk(map, dir.d);
        } else {
          game.player.walk(map, dir.hd);
        }
        game.fire('turn');
      } else if (isOkToGo(pp.x + dir.hx, pp.y + dir.hy)) {
        game.player.walk(map, dir.hd);
        dir = prevd[dir.d];
        game.fire('turn');
      } else {
        dir = nextd[dir.d];
      }
      return setTimeout((function() {
        return hack.commands['x'](game, dir);
      }), 100);
    }
  };

}).call(this);
