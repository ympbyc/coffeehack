// Generated by CoffeeScript 1.3.3
var Map;

Map = (function() {
  var createRoom, createSpecialCells, initMap, splitMap, walkable;

  Map.EMPTY = 0;

  Map.PATH = 1;

  Map.ROOM = 2;

  Map.WALL_VERT = 3.1;

  Map.WALL_HORIZ = 3.2;

  Map.STAIR_UP = 4.1;

  Map.STAIR_DOWN = 4.2;

  Map.TRAP = 5;

  Map.TRAP_ACTIVE = 5.1;

  Map.ITEM = 6;

  initMap = function(width, height) {
    var arr, i, map;
    return map = (function() {
      var _i, _results;
      _results = [];
      for (i = _i = 0; 0 <= height ? _i < height : _i > height; i = 0 <= height ? ++_i : --_i) {
        _results.push(arr = (function() {
          var _j, _results1;
          _results1 = [];
          for (i = _j = 0; 0 <= width ? _j < width : _j > width; i = 0 <= width ? ++_j : --_j) {
            _results1.push(Map.EMPTY);
          }
          return _results1;
        })());
      }
      return _results;
    })();
  };

  splitMap = function(map, splitMode) {
    var MINIMUM_LENGTH, SPLIT_HORIZONTAL, SPLIT_VERTICAL, finalResult, height, i, leftHalf, leftResult, lowerHalf, rightHalf, rightResult, row, splitColumn, splitRow, upperHalf, width, xPosition, yPosition, _i, _j, _k, _len, _ref, _ref1;
    map = map.concat([]);
    height = map.length;
    width = map[0].length;
    SPLIT_VERTICAL = 1;
    SPLIT_HORIZONTAL = 2;
    MINIMUM_LENGTH = 12;
    if (width < MINIMUM_LENGTH || height < MINIMUM_LENGTH) {
      return createRoom(map);
    }
    splitMode = splitMode || Math.round(Math.random());
    if (splitMode === SPLIT_VERTICAL) {
      xPosition = Math.round(Math.random() * (width - 10) + 5);
      for (i = _i = 2, _ref = map.length - 2; 2 <= _ref ? _i < _ref : _i > _ref; i = 2 <= _ref ? ++_i : --_i) {
        map[i][xPosition] = Map.PATH;
      }
      leftHalf = [];
      rightHalf = [];
      splitColumn = [];
      for (_j = 0, _len = map.length; _j < _len; _j++) {
        row = map[_j];
        leftHalf.push(row.slice(0, xPosition));
        rightHalf.push(row.slice(xPosition + 1));
        splitColumn.push([row[xPosition]]);
      }
      leftResult = splitMap(leftHalf, SPLIT_HORIZONTAL);
      rightResult = splitMap(rightHalf, SPLIT_HORIZONTAL);
      finalResult = (function() {
        var _k, _ref1, _results;
        _results = [];
        for (i = _k = 0, _ref1 = map.length; 0 <= _ref1 ? _k < _ref1 : _k > _ref1; i = 0 <= _ref1 ? ++_k : --_k) {
          _results.push(leftResult[i].concat(splitColumn[i].concat(rightResult[i])));
        }
        return _results;
      })();
      return finalResult;
    } else if (splitMode === SPLIT_HORIZONTAL) {
      yPosition = Math.round(Math.random() * (height - 10) + 5);
      for (i = _k = 2, _ref1 = map[yPosition].length - 2; 2 <= _ref1 ? _k < _ref1 : _k > _ref1; i = 2 <= _ref1 ? ++_k : --_k) {
        map[yPosition][i] = Map.PATH;
      }
      upperHalf = map.slice(0, yPosition);
      lowerHalf = map.slice(yPosition + 1);
      splitRow = [map[yPosition]];
      return splitMap(upperHalf, SPLIT_VERTICAL).concat(splitRow.concat(splitMap(lowerHalf, SPLIT_VERTICAL)));
    }
  };

  createRoom = function(section) {
    var horiz_center, i, j, vert_center, _i, _j, _ref, _ref1;
    if (section.length < 5 || section[0].length < 5) {
      return section;
    }
    section = section.concat([]);
    for (i = _i = 1, _ref = section.length - 2; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
      for (j = _j = 1, _ref1 = section[i].length - 2; 1 <= _ref1 ? _j <= _ref1 : _j >= _ref1; j = 1 <= _ref1 ? ++_j : --_j) {
        if (i === 1 || i === section.length - 2) {
          section[i][j] = Map.WALL_HORIZ;
        } else if (j === 1 || j === section[i].length - 2) {
          section[i][j] = Map.WALL_VERT;
        } else {
          section[i][j] = Map.ROOM;
        }
      }
    }
    vert_center = Math.floor(section.length / 2);
    horiz_center = Math.floor(section[0].length / 2);
    section[vert_center][0] = Map.PATH;
    section[vert_center][1] = Map.ROOM;
    section[vert_center][section[vert_center].length - 1] = Map.PATH;
    section[vert_center][section[vert_center].length - 2] = Map.ROOM;
    section[0][horiz_center] = Map.PATH;
    section[1][horiz_center] = Map.ROOM;
    section[section.length - 1][horiz_center] = Map.PATH;
    section[section.length - 2][horiz_center] = Map.ROOM;
    return section;
  };

  createSpecialCells = function(map) {
    var f;
    map = map.concat([]);
    f = function(type, occurance) {
      var x, y;
      if (occurance == null) {
        occurance = 1;
      }
      if (occurance) {
        x = Math.floor(Math.random() * map[0].length);
        y = Math.floor(Math.random() * map.length);
        if (map[y][x] && map[y][x] === Map.ROOM) {
          map[y][x] = type;
          return f(type, occurance -= 1);
        } else {
          return f(type, occurance);
        }
      }
    };
    f(Map.STAIR_UP);
    f(Map.STAIR_DOWN);
    f(Map.TRAP, Math.floor(Math.random() * 10));
    f(Map.ITEM, Math.floor(Math.random() * 10 + 3));
    return map;
  };

  function Map(width, height) {
    this.width = width;
    this.height = height;
    this._map = createSpecialCells(splitMap(initMap(this.width, this.height), 1));
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
              case Map.EMPTY:
                _results1.push(' ');
                break;
              case Map.WALL_VERT:
                _results1.push('|');
                break;
              case Map.WALL_HORIZ:
                _results1.push('-');
                break;
              case Map.ROOM:
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
              case Map.ITEM:
                _results1.push('*');
                break;
              default:
                _results1.push(cell);
            }
          }
          return _results1;
        })()).join(''));
      }
      return _results;
    }).call(this)).join('\n');
    return str;
  };

  walkable = [Map.ROOM, Map.PATH, Map.STAIR_UP, Map.STAIR_DOWN, Map.TRAP, Map.TRAP_ACTIVE, Map.ITEM];

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
    return this._map[y][x];
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
    return this.reserved[y][x] = null;
  };

  Map.prototype.getNearByCells = function(x, y) {
    return [this.getReservation(x + 1, y), this.getReservation(x - 1, y), this.getReservation(x, y + 1), this.getReservation(x, y - 1), this.getReservation(x + 1, y + 1), this.getReservation(x - 1, y + 1), this.getReservation(x + 1, y - 1), this.getReservation(x - 1, y - 1)];
  };

  return Map;

})();
