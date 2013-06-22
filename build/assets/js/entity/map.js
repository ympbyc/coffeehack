(function() {
  var Map, utils;

  utils = hack.utils;

  Map = (function() {
    var walkable, _createEarth;

    Map.EARTH = 0;

    Map.WATER = 1;

    Map.FLOOR = 2;

    Map.WALL = 3;

    Map.STAIR_UP = 4.1;

    Map.STAIR_DOWN = 4.2;

    Map.TRAP = 5;

    Map.TRAP_ACTIVE = 5.1;

    Map.NINJITSU = 6;

    _createEarth = function(width, height) {
      var i, j, _i, _results;
      _results = [];
      for (i = _i = 0; 0 <= height ? _i < height : _i > height; i = 0 <= height ? ++_i : --_i) {
        _results.push((function() {
          var _j, _results1;
          _results1 = [];
          for (j = _j = 0; 0 <= width ? _j < width : _j > width; j = 0 <= width ? ++_j : --_j) {
            _results1.push(Map.EARTH);
          }
          return _results1;
        })());
      }
      return _results;
    };

    Map.prototype._singleRoomAtTheCentre = function() {
      var centre, room;
      centre = {
        x: this.width / 2,
        y: this.height / 2
      };
      room = [[Map.WALL, Map.WALL, Map.WALL, Map.WALL, Map.WALL], [Map.WALL, Map.FLOOR, Map.FLOOR, Map.FLOOR, Map.WALL], [Map.WALL, Map.FLOOR, Map.FLOOR, Map.FLOOR, Map.WALL], [Map.WALL, Map.FLOOR, Map.FLOOR, Map.FLOOR, Map.WALL], [Map.WALL, Map.WALL, Map.WALL, Map.WALL, Map.WALL]];
      return this._addFeatureIfSpaceIsAvailable(centre, room, 'down');
    };

    Map.prototype._pickRandomStartingPoint = function() {
      var it, nbc, p;
      p = {
        x: utils.randomInt(this.width),
        y: utils.randomInt(this.height)
      };
      nbc = this.getNearbyCells(p.x, p.y);
      if (this.getCell(p.x, p.y) === Map.EARTH && ((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = nbc.length; _i < _len; _i++) {
          it = nbc[_i];
          if (it === Map.WALL) {
            _results.push(it);
          }
        }
        return _results;
      })()).length === 3) {
        if (nbc[0] === Map.WALL) {
          return {
            coord: p,
            direction: 'left'
          };
        } else if (nbc[1] === Map.WALL) {
          return {
            coord: p,
            direction: 'right'
          };
        } else if (nbc[2] === Map.WALL) {
          return {
            coord: p,
            direction: 'up'
          };
        } else if (nbc[3] === Map.WALL) {
          return {
            coord: p,
            direction: 'down'
          };
        } else {
          return this._pickRandomStartingPoint();
        }
      } else {
        return this._pickRandomStartingPoint();
      }
    };

    Map.prototype._addFeatureIfSpaceIsAvailable = function(p, feature, direction) {
      var cell, fheight, fwidth, map, mf, row, topleft, x, y, _i, _j;
      map = (function() {
        var _i, _len, _ref, _results;
        _ref = this._map;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          row = _ref[_i];
          _results.push((function() {
            var _j, _len1, _results1;
            _results1 = [];
            for (_j = 0, _len1 = row.length; _j < _len1; _j++) {
              cell = row[_j];
              _results1.push(cell);
            }
            return _results1;
          })());
        }
        return _results;
      }).call(this);
      fwidth = feature[0].length;
      fheight = feature.length;
      mf = Math.floor;
      topleft = (function() {
        switch (direction) {
          case 'up':
            return {
              x: p.x - mf(fwidth / 2),
              y: p.y - (fheight - 1),
              tof: {
                x: p.x,
                y: p.y + 1
              }
            };
          case 'down':
            return {
              x: p.x - mf(fwidth / 2),
              y: p.y,
              tof: {
                x: p.x,
                y: p.y - 1
              }
            };
          case 'left':
            return {
              x: p.x - (fwidth - 1),
              y: p.y - mf(fheight / 2),
              tof: {
                x: p.x + 1,
                y: p.y
              }
            };
          case 'right':
            return {
              x: p.x,
              y: p.y - mf(fheight / 2),
              tof: {
                x: p.x - 1,
                y: p.y
              }
            };
        }
      })();
      for (y = _i = 0; 0 <= fheight ? _i < fheight : _i > fheight; y = 0 <= fheight ? ++_i : --_i) {
        for (x = _j = 0; 0 <= fwidth ? _j < fwidth : _j > fwidth; x = 0 <= fwidth ? ++_j : --_j) {
          if (this.getCell(x + topleft.x, y + topleft.y) !== Map.EARTH) {
            return null;
          }
          map[y + topleft.y][x + topleft.x] = feature[y][x];
        }
      }
      map[p.y][p.x] = Map.FLOOR;
      map[topleft.tof.y][topleft.tof.x] = Map.FLOOR;
      return this._map = map;
    };

    Map.prototype._createSpecialCells = function() {
      var f,
        _this = this;
      f = function(type, occurance, memo, bywall) {
        var x, y;
        if (occurance == null) {
          occurance = 1;
        }
        if (memo == null) {
          memo = null;
        }
        if (bywall == null) {
          bywall = false;
        }
        if (occurance) {
          x = utils.randomInt(_this.width - 1);
          y = utils.randomInt(_this.height - 1);
          if (_this._map[y][x] && _this._map[y][x] === Map.FLOOR) {
            if ((bywall && _this.getNearbyCells(x, y).indexOf(Map.WALL) > -1) || !bywall) {
              _this._map[y][x] = type;
              return f(type, occurance -= 1, {
                x: x,
                y: y
              });
            } else {
              return f(type, occurance, null, bywall);
            }
          } else {
            return f(type, occurance, null, bywall);
          }
        } else {
          return memo;
        }
      };
      this.stair_pos_up = f(Map.STAIR_UP, 1, null, true);
      this.stair_pos_down = f(Map.STAIR_DOWN, 1, null, true);
      f(Map.TRAP, utils.randomInt(5));
      f(Map.NINJITSU, 3);
      return this._map;
    };

    function Map(width, height) {
      var lmt, sttpt;
      this.width = width;
      this.height = height;
      this._map = _createEarth(this.width, this.height);
      this._singleRoomAtTheCentre();
      lmt = 50;
      while (--lmt) {
        sttpt = this._pickRandomStartingPoint();
        this._addFeatureIfSpaceIsAvailable(sttpt.coord, hack.features[utils.randomInt(hack.features.length)], sttpt.direction);
      }
      this.stair_pos_up = null;
      this.stair_pos_down = null;
      this._createSpecialCells();
      this.reserved = [];
    }

    Map.prototype.show = function() {
      var cell, row, str;
      str = ((function() {
        var _i, _len, _ref, _results;
        _ref = this._map;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          row = _ref[_i];
          _results.push(((function() {
            var _j, _len1, _results1;
            _results1 = [];
            for (_j = 0, _len1 = row.length; _j < _len1; _j++) {
              cell = row[_j];
              switch (cell) {
                case Map.EARTH:
                  _results1.push(' ');
                  break;
                case Map.WATER:
                  _results1.push('~');
                  break;
                case Map.WALL:
                  _results1.push('-');
                  break;
                case Map.FLOOR:
                  _results1.push('.');
                  break;
                case Map.TRAP:
                  _results1.push('.');
                  break;
                case Map.TRAP_ACTIVE:
                  _results1.push('^');
                  break;
                case Map.PATH:
                  _results1.push('#');
                  break;
                case Map.STAIR_UP:
                  _results1.push('<');
                  break;
                case Map.STAIR_DOWN:
                  _results1.push('>');
                  break;
                case Map.NINJITSU:
                  _results1.push('*');
                  break;
                default:
                  _results1.push(void 0);
              }
            }
            return _results1;
          })()).join(''));
        }
        return _results;
      }).call(this)).join('\n');
      return str;
    };

    walkable = [Map.FLOOR, Map.PATH, Map.STAIR_UP, Map.STAIR_DOWN, Map.TRAP, Map.TRAP_ACTIVE, Map.NINJITSU];

    Map.prototype.isWalkable = function(x, y) {
      return this._map[y] && this._map[y][x] && walkable.indexOf(this._map[y][x]) > -1 && !this.getReservation(x, y);
    };

    Map.prototype.isAttackable = function(x, y) {
      return this._map[y] && this._map[y][x] && walkable.indexOf(this._map[y][x]) > -1;
    };

    Map.prototype.setCell = function(x, y, char) {
      return this._map[y][x] = char;
    };

    Map.prototype.getCell = function(x, y) {
      var _ref;
      if (((_ref = this._map[y]) != null ? _ref[x] : void 0) != null) {
        return this._map[y][x];
      } else {
        return null;
      }
    };

    Map.prototype.getNearbyCells = function(x, y) {
      return [this.getCell(x + 1, y), this.getCell(x - 1, y), this.getCell(x, y + 1), this.getCell(x, y - 1), this.getCell(x + 1, y + 1), this.getCell(x + 1, y - 1), this.getCell(x - 1, y + 1), this.getCell(x - 1, y - 1)];
    };

    Map.prototype.reserveCell = function(x, y, obj) {
      if (!this.reserved[y]) {
        this.reserved[y] = {};
      }
      if (!this.reserved[y][x]) {
        return this.reserved[y][x] = obj;
      } else {
        throw 'cell already reserved';
      }
    };

    Map.prototype.getReservation = function(x, y) {
      if (this.reserved[y] && this.reserved[y][x]) {
        return this.reserved[y][x];
      } else {
        return false;
      }
    };

    Map.prototype.clearReservation = function(x, y) {
      var _ref;
      if (((_ref = this.reserved[y]) != null ? _ref[x] : void 0) != null) {
        return this.reserved[y][x] = null;
      }
    };

    Map.prototype.getNearbyReservations = function(x, y) {
      return [this.getReservation(x + 1, y), this.getReservation(x - 1, y), this.getReservation(x, y + 1), this.getReservation(x, y - 1), this.getReservation(x + 1, y + 1), this.getReservation(x - 1, y + 1), this.getReservation(x + 1, y - 1), this.getReservation(x - 1, y - 1)];
    };

    return Map;

  })();

  hack.Map = Map;

}).call(this);
