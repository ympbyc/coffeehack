(function() {
  var EventEmitter,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  EventEmitter = hack.EventEmitter;

  hack.Game = (function(_super) {

    __extends(Game, _super);

    function Game() {
      var _this = this;
      Game.__super__.constructor.call(this);
      this.monsterStack = [[]];
      this.itemStack = [[]];
      this.mapStack = [];
      this.level = -1;
      this.time = 0;
      this.score = 0;
      this.on('turn', function() {
        return _this.turnInit();
      });
      this.on('turnend', function() {
        return _this.turnEnd();
      });
    }

    Game.prototype.setPlayer = function(player) {
      this.player = player;
    };

    Game.prototype.addMap = function(map) {
      return this.mapStack.push(map);
    };

    Game.prototype.currentMap = function() {
      return this.mapStack[this.level];
    };

    Game.prototype.nextMap = function() {
      if (!(this.mapStack[this.level + 1] != null)) {
        return false;
      }
      this.player.fire('godown', {
        prevMap: this.currentMap()
      });
      this.level++;
      this.levelInit();
      return this.mapStack[this.level];
    };

    Game.prototype.prevMap = function() {
      this.player.fire('goup', {
        prevMap: this.currentMap()
      });
      this.level--;
      return this.mapStack[this.level];
    };

    Game.prototype.levelInit = function() {
      if (!this.monsterStack[this.level]) {
        this.monsterStack.push([]);
      }
      if (!this.itemStack[this.level]) {
        return this.itemStack.push([]);
      }
    };

    Game.prototype.addMonster = function(monster) {
      monster.born(this.currentMap());
      return this.monsterStack[this.level].push(monster);
    };

    Game.prototype.killMonsters = function() {
      var i, ms, pos, _i, _ref, _results;
      ms = this.monsterStack[this.level];
      _results = [];
      for (i = _i = 0, _ref = ms.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        if (ms[i] && ms[i].isDead()) {
          pos = ms[i].getPosition();
          this.currentMap().clearReservation(pos.x, pos.y);
          _results.push(delete ms[i]);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Game.prototype.countMonster = function() {
      var ctr, m, _i, _len, _ref;
      ctr = 0;
      _ref = this.monsterStack[this.level];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        m = _ref[_i];
        if (m != null) {
          ctr++;
        }
      }
      return ctr;
    };

    Game.prototype.moveAllMonsters = function() {
      var m, pp, _i, _len, _ref, _results;
      pp = this.player.getPosition();
      _ref = this.monsterStack[this.level];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        m = _ref[_i];
        if (m) {
          m.move(this.currentMap(), pp.x, pp.y);
          _results.push(m.fire('move'));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Game.prototype.addItem = function(x, y, item) {
      var items;
      items = this.itemStack[this.level];
      if (!(items[y] != null)) {
        items[y] = {};
      }
      if (!(items[y][x] != null)) {
        return items[y][x] = [item];
      } else {
        return items[y][x].push(item);
      }
    };

    Game.prototype.getItems = function(x, y) {
      var items;
      items = this.itemStack[this.level];
      if (!(items[y] && items[y][x])) {
        return null;
      }
      return items[y][x];
    };

    Game.prototype.shiftItem = function(x, y) {
      var items, _ref;
      items = this.itemStack[this.level];
      if (((_ref = items[y]) != null ? _ref[x] : void 0) != null) {
        return items[y][x].shift();
      }
    };

    Game.prototype.turnInit = function() {
      this.time++;
      if (this.player.hp < this.player.getMaxHP()) {
        return this.player.hp += 1 / ((42 / (this.player.explevel + 2)) + 1);
      }
    };

    Game.prototype.turnEnd = function() {
      this.killMonsters();
      if (this.player.isDead()) {
        return alert('you died');
      }
    };

    Game.prototype.drawObjects = function() {
      var column, i, items, j, m, map, monsterPos, objectLayer, pp, row, x, _i, _j, _len, _ref, _ref1, _ref2, _ref3, _ref4;
      map = this.currentMap();
      objectLayer = (function() {
        var _i, _ref, _results;
        _results = [];
        for (row = _i = 0, _ref = map.height; 0 <= _ref ? _i < _ref : _i > _ref; row = 0 <= _ref ? ++_i : --_i) {
          _results.push((function() {
            var _j, _ref1, _results1;
            _results1 = [];
            for (column = _j = 0, _ref1 = map.width; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; column = 0 <= _ref1 ? ++_j : --_j) {
              _results1.push(0);
            }
            return _results1;
          })());
        }
        return _results;
      })();
      items = this.itemStack[this.level];
      for (i = _i = 0, _ref = map.height; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        _ref1 = (items[i] != null ? items[i] : []);
        for (j in _ref1) {
          x = _ref1[j];
          if ((_ref2 = items[i]) != null ? (_ref3 = _ref2[j]) != null ? _ref3.length : void 0 : void 0) {
            objectLayer[i][j] = items[i][j][0];
          }
        }
      }
      pp = this.player.getPosition();
      objectLayer[pp.y][pp.x] = this.player;
      _ref4 = this.monsterStack[this.level];
      for (_j = 0, _len = _ref4.length; _j < _len; _j++) {
        m = _ref4[_j];
        if (m) {
          monsterPos = m.getPosition();
          objectLayer[monsterPos.y][monsterPos.x] = m;
        }
      }
      return objectLayer;
    };

    return Game;

  })(EventEmitter);

}).call(this);
