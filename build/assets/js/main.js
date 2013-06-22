
/*
# main.js
# Handles all the user interaction, and bridges between classes.
# Other files should not depend on this file to work.
#
# The only file you have to modify when you port this project to a new environment is this.
# This version targets html5 web browsers.
#
# dependencies - command.coffee, game.coffee, (index.html),
#                (lib/jquery), map.coffee, messagelist.coffee, monster.coffee,
#                monsterlist.coffee, (nhtiles/*.gif), ninjitsulist.coffee, player.coffee,
#                (tile.coffee), traplist.coffee, itemlist.coffee, item.coffee
*/


(function() {
  var Item, MAP_HEIGHT, MAP_WIDTH, MAX_MONSTER, MESSAGE_SIZE, Map, Monster, Player, Tile, Weapon, commands, getKeyChar, items, main, messagelist, monsterlist, ninjitsulist, traplist, utils;

  messagelist = hack.messagelist, monsterlist = hack.monsterlist, commands = hack.commands, items = hack.items, ninjitsulist = hack.ninjitsulist, traplist = hack.traplist, Player = hack.Player, Monster = hack.Monster, Item = hack.Item, Weapon = hack.Weapon, Map = hack.Map, Tile = hack.Tile, utils = hack.utils;

  MAP_WIDTH = 40;

  MAP_HEIGHT = 30;

  MAX_MONSTER = 10;

  MESSAGE_SIZE = 4;

  main = function() {
    var $document, currentmonsterlist, game, i, m, mainlistener, message, prevmapstr, tile, updateCanvasMap, updateObjects;
    game = new hack.Game();
    game.setPlayer(new Player('coffeedrinker', 'Ninja', 12));
    game.addMap(new Map(MAP_WIDTH, MAP_HEIGHT));
    game.nextMap();
    game.player.born(game.currentMap());
    tile = new Tile('ch-canvas');
    currentmonsterlist = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = monsterlist.length; _i < _len; _i++) {
        m = monsterlist[_i];
        if (m[1] <= 1) {
          _results.push(m);
        }
      }
      return _results;
    })();
    message = ['', '', '', '', 'Welcome to coffeehack. You are a neutral male ninja. Slay the dragons!'];
    $document = $(document);
    /*
      # This is the main game loop of coffeehack.
      # This gets called every time the user hits a key.
      # Execution of the user's action take place before anything else happens.
      # After that, the turn emits.
    */

    $document.bind('keypress', mainlistener = function(e) {
      var direction, f, keyChar;
      keyChar = getKeyChar(e.which);
      direction = {
        'k': 'u',
        'j': 'd',
        'l': 'r',
        'h': 'l',
        'y': 'ul',
        'u': 'ur',
        'b': 'll',
        'n': 'lr'
      };
      if (direction[keyChar]) {
        game.player.walk(game.currentMap(), direction[keyChar]);
      }
      if (commands[keyChar] != null) {
        f = commands[keyChar](game);
        if (f != null) {
          game.fire('argumentrequest', {
            command: f
          });
        }
      }
      return game.fire('turn');
    });
    /*
      # Manipulation of monsters occur after the player has done his action.
    */

    game.on('turn', function() {
      var monster;
      if (Math.random() * 10 < 0.5 && game.countMonster() < MAX_MONSTER) {
        monster = (function(func, args, ctor) {
          ctor.prototype = func.prototype;
          var child = new ctor, result = func.apply(child, args), t = typeof result;
          return t == "object" || t == "function" ? result || child : child;
        })(Monster, currentmonsterlist[utils.randomInt(currentmonsterlist.length)], function(){});
        monster.on('attack', function(e) {
          var action, tgt;
          tgt = e.enemy.name ? 'You' : 'the ' + e.enemy.role;
          action = Math.round(Math.random()) ? e.me.action : 'hits';
          return game.fire('message', {
            message: messagelist.format(messagelist.monster.attack, e.me.role, action, tgt)
          });
        });
        monster.on('die', function(e) {
          var pos, weapon;
          pos = e.beef.getPosition();
          weapon = (function(func, args, ctor) {
            ctor.prototype = func.prototype;
            var child = new ctor, result = func.apply(child, args), t = typeof result;
            return t == "object" || t == "function" ? result || child : child;
          })(Weapon, items.weapons[utils.randomInt(items.weapons.length)], function(){});
          if (weapon.rareness > utils.randomInt(100)) {
            return game.addItem(pos.x, pos.y, weapon);
          } else {
            return weapon = null;
          }
        });
        game.addMonster(monster);
      }
      game.moveAllMonsters();
      return game.fire('turnend');
    });
    /*
      # Update the screen when the turn ends.
    */

    game.on('turnend', function() {
      var status;
      updateObjects(game.drawObjects());
      status = "" + game.player.name + " @ floor - " + game.level + " \n hp: " + (Math.floor(game.player.hp)) + " / " + (game.player.getMaxHP()) + " exp: " + (Math.floor(game.player.experience * 10) * 1 / 10) + " time: " + game.time + " score: " + game.score;
      return game.fire('status', {
        status: status
      });
    });
    /*
      # Update the message area if anything interesting happened on this turn
    */

    game.on('turnend', function() {
      if (message[MESSAGE_SIZE].length) {
        message.shift();
        $('#message').html(message.join('\n'));
        return message.push('');
      }
    });
    /*
      # This event fires when the player hit '>' key on downward staircases.
      # This listener gives birth to the player on the next level.
      # A new floor has to be generated if the player hasn't been to that level.
    */

    game.on('godown', function() {
      var map;
      if (!game.nextMap()) {
        game.addMap(new Map(MAP_WIDTH, MAP_HEIGHT));
        game.nextMap();
      }
      map = game.currentMap();
      game.player.born(map, map.stair_pos_up);
      return game.fire('mapchange');
    });
    /*
      # The variation of monsters that appear in a level increases as the player goes deeper.
    */

    game.on('godown', function() {
      currentmonsterlist = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = monsterlist.length; _i < _len; _i++) {
          m = monsterlist[_i];
          if (m[1] <= (((game.player.explevel || 1) + game.level) / 2)) {
            _results.push(m);
          }
        }
        return _results;
      })();
      return console.log(currentmonsterlist);
    });
    /*
      # reversed 'godown'
    */

    game.on('goup', function() {
      var map;
      game.prevMap();
      map = game.currentMap();
      game.player.born(map, map.stair_pos_down);
      return game.fire('mapchange');
    });
    game.on('goup', function() {
      return currentmonsterlist = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = monsterlist.length; _i < _len; _i++) {
          m = monsterlist[_i];
          if (m[1] <= ((game.player.explevel + game.level) / 2 || 1)) {
            _results.push(m);
          }
        }
        return _results;
      })();
    });
    /*
      # Messages that are generated as a result of specific events
      # are acumurated here till the end of the turn
    */

    game.on('message', function(e) {
      return message[MESSAGE_SIZE] += ' ' + e.message;
    });
    game.on('status', function(e) {
      return $('#status').html(e.status);
    });
    /*
      # commands such as 'w'(wield) take an argument.
      # These commands are difined as higher order functions
      # and returns an anonymous function that take a charactor as its argument.
      # This listener is responsible for feeding the user input to this anonymous function
    */

    game.on('argumentrequest', function(e) {
      var listener;
      $document.unbind('keypress', mainlistener);
      listener = function(ev) {
        $document.unbind('keypress', listener);
        $document.bind('keypress', mainlistener);
        return e.command(getKeyChar(ev.keyCode));
      };
      return $document.bind('keypress', listener);
    });
    /*
      # Fires a message on an attack
    */

    game.player.on('attack', function(e) {
      var mode;
      mode = e.enemy.isDead() ? 'killed' : 'hit';
      return game.fire('message', {
        message: messagelist.format(messagelist.player.attack, mode, e.enemy.role)
      });
    });
    /*
      # Traps are functions that take the instence of the game.
      # Which type of trap to be activated is decided on the fly each time the player come across it
    */

    game.player.on('move', function(e) {
      var pp;
      if ([Map.TRAP, Map.TRAP_ACTIVE].indexOf(game.currentMap().getCell(e.position.x, e.position.y)) > -1) {
        pp = game.player.getPosition();
        game.currentMap().setCell(pp.x, pp.y, Map.TRAP_ACTIVE);
        game.fire('mapchange');
        return traplist[utils.randomInt(traplist.length)](game);
      }
    });
    /*
      # Same applies to ninjitsu fields
    */

    game.player.on('move', function(ev) {
      var listener, ninjitsu;
      if (game.currentMap().getCell(ev.position.x, ev.position.y) === Map.NINJITSU) {
        ninjitsu = ninjitsulist[utils.randomInt(ninjitsulist.length)];
        game.fire('message', {
          message: "" + ninjitsu.name + " : " + ninjitsu.description + ". spell? (y or anything else)"
        });
        listener = function(e) {
          $document.unbind('keypress', listener);
          $document.bind('keypress', mainlistener);
          if (getKeyChar(e.keyCode) === 'y') {
            ninjitsu.jitsu(game);
            game.fire('message', {
              message: ninjitsu.message
            });
            game.currentMap().setCell(ev.position.x, ev.position.y, Map.FLOOR);
            game.fire('mapchange');
            return game.fire('turn');
          }
        };
        $document.unbind('keypress', mainlistener);
        return $document.bind('keypress', listener);
      }
    });
    /*
      # Fire a message on experience-level-ups
    */

    game.player.on('explevelup', function(e) {
      game.score += 100;
      return game.fire('message', {
        message: "Welcome to experience level " + e.explevel + "."
      });
    });
    /*
      # Give a score on each kill
    */

    game.player.on('killedanenemy', function() {
      return game.score += 100;
    });
    prevmapstr = ((function() {
      var _i, _ref, _results;
      _results = [];
      for (i = _i = 0, _ref = MAP_WIDTH * MAP_HEIGHT; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        _results.push('0');
      }
      return _results;
    })()).join('');
    /*
      # Update the map only when some changes happen
    */

    game.on('mapchange', function() {
      return updateCanvasMap(game.currentMap().show());
    });
    /*
      # Translate the map represented in rogue characters to graphical tiles
    */

    updateCanvasMap = function(mapstr) {
      var cell, j, ptr, _i, _j;
      mapstr = mapstr.replace(/\n/g, '');
      ptr = -1;
      for (i = _i = 0; 0 <= MAP_HEIGHT ? _i < MAP_HEIGHT : _i > MAP_HEIGHT; i = 0 <= MAP_HEIGHT ? ++_i : --_i) {
        for (j = _j = 0; 0 <= MAP_WIDTH ? _j < MAP_WIDTH : _j > MAP_WIDTH; j = 0 <= MAP_WIDTH ? ++_j : --_j) {
          ptr++;
          if (prevmapstr[ptr] === mapstr[ptr]) {
            continue;
          }
          cell = (function() {
            switch (mapstr[ptr]) {
              case ' ':
                return ['map', 'blank'];
              case '~':
                return ['map', 'water'];
              case '.':
                return ['map', 'room'];
              case '#':
                return ['map', 'path'];
              case '|':
                return ['map', 'wall_vert'];
              case '-':
                return ['map', 'wall_horiz'];
              case '^':
                return ['map', 'trap_active'];
              case '<':
                return ['map', 'stair_up'];
              case '>':
                return ['map', 'stair_down'];
              case '*':
                return ['map', 'ninjitsu'];
            }
          })();
          tile.update(j, i, cell[0], cell[1]);
        }
      }
      return tile.toDataUrl();
    };
    updateObjects = function(objectLayer) {
      var cell, j, row, _results;
      tile.resetWithMap();
      _results = [];
      for (i in objectLayer) {
        row = objectLayer[i];
        _results.push((function() {
          var _results1;
          _results1 = [];
          for (j in row) {
            cell = row[j];
            if (cell instanceof Player) {
              _results1.push(tile.update(j, i, 'monster', cell.role));
            } else if (cell instanceof Weapon) {
              _results1.push(tile.update(j, i, 'weapon', cell.name));
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        })());
      }
      return _results;
    };
    updateCanvasMap(game.currentMap().show());
    return game.fire('turn');
  };

  /*
  # Get character from keycode
  */


  getKeyChar = function(keyCode) {
    return String.fromCharCode(keyCode);
  };

  $(window).bind('load', main);

}).call(this);
