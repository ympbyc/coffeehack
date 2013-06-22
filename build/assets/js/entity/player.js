
/*
# player.coffee
# Defines the properties and behaviour of a character
# Monsters extend this class therefore if the word 'player' appears
# in this file, it also represents monsters
*/


(function() {
  var EventEmitter, randomInt, utils,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  utils = hack.utils, EventEmitter = hack.EventEmitter;

  randomInt = utils.randomInt;

  hack.Player = (function(_super) {

    __extends(Player, _super);

    Player.EXP_REQUIRED = [0, 20, 40, 80, 160, 320, 640, 1280, 2560, 5120, 10000, 20000, 40000, 80000, 160000, 320000, 640000, 1280000, 2560000, 5120000, 100000, 200000, 300000, 400000, 500000, 600000, 700000, 800000, 900000, 1000000];

    /*
      # experience is an floating point number, incremented each time the player defeats a monster
      # explevel is an integer number, incremente when the player reachs the required experience
      # gainExp is the experience given to the enemy when
    */


    function Player(name, role, hp, explevel, gainExp, dice) {
      var _this = this;
      this.name = name;
      this.role = role;
      this.hp = hp;
      this.explevel = explevel != null ? explevel : 0;
      this.gainExp = gainExp != null ? gainExp : 0;
      this.dice = dice != null ? dice : [1, 4];
      Player.__super__.constructor.call(this);
      this._position = {};
      this.experience = 0;
      this.inventory = new hack.Inventory();
      this.on('godown', function(e) {
        if (e.prevMap) {
          return e.prevMap.clearReservation(_this.getPosition().x, _this.getPosition().y);
        }
      });
      this.on('goup', function(e) {
        if (e.prevMap) {
          return e.prevMap.clearReservation(_this.getPosition().x, _this.getPosition().y);
        }
      });
    }

    Player.prototype.born = function(map, pos) {
      var nextPos;
      if (pos == null) {
        pos = null;
      }
      nextPos = pos != null ? pos : {
        x: randomInt(map.width),
        y: randomInt(map.height)
      };
      if (map.isWalkable(nextPos.x, nextPos.y)) {
        this._position = nextPos;
        return map.reserveCell(this._position.x, this._position.y, this);
      } else {
        return this.born(map);
      }
    };

    Player.prototype.getMaxHP = function() {
      var maxHP;
      maxHP = [12, 18, 26, 36, 48, 62, 80, 100];
      return maxHP[this.explevel] || maxHP[maxHP.length - 1];
    };

    Player.prototype.walk = function(map, direction) {
      var DOWN, LEFT, LWRLFT, LWRRGT, RIGHT, UP, UPRLFT, UPRRGT, m, nextPos;
      UP = 'u';
      DOWN = 'd';
      RIGHT = 'r';
      LEFT = 'l';
      UPRLFT = 'ul';
      UPRRGT = 'ur';
      LWRLFT = 'll';
      LWRRGT = 'lr';
      nextPos = {
        x: this._position.x,
        y: this._position.y
      };
      switch (direction) {
        case UP:
          nextPos.y -= 1;
          break;
        case DOWN:
          nextPos.y += 1;
          break;
        case RIGHT:
          nextPos.x += 1;
          break;
        case LEFT:
          nextPos.x -= 1;
          break;
        case UPRLFT:
          nextPos.x -= 1;
          nextPos.y -= 1;
          break;
        case UPRRGT:
          nextPos.x += 1;
          nextPos.y -= 1;
          break;
        case LWRLFT:
          nextPos.x -= 1;
          nextPos.y += 1;
          break;
        case LWRRGT:
          nextPos.x += 1;
          nextPos.y += 1;
      }
      if (map.isWalkable(nextPos.x, nextPos.y)) {
        map.clearReservation(this._position.x, this._position.y);
        this._position = nextPos;
        map.reserveCell(this._position.x, this._position.y, this);
      } else if (m = map.getReservation(nextPos.x, nextPos.y)) {
        this.attack(m);
      }
      return this.fire('move', {
        position: this._position
      });
    };

    Player.prototype.attack = function(enemy) {
      if (this.isDead()) {
        return;
      }
      enemy.hp -= utils.dice(this.dice[0], this.dice[1]);
      if (enemy.isDead()) {
        this.killedAnEnemy(enemy);
        enemy.fire('die', {
          beef: enemy
        });
      }
      return this.fire('attack', {
        me: this,
        enemy: enemy
      });
    };

    Player.prototype.killedAnEnemy = function(enemy) {
      this.experience += enemy.gainExp;
      this.fire('killedanenemy');
      if (this.experience >= Player.EXP_REQUIRED[this.explevel + 1]) {
        this.explevel += 1;
        this.dice[1] += 1;
        return this.fire('explevelup', {
          explevel: this.explevel
        });
      }
    };

    Player.prototype.isDead = function() {
      if (this.hp < 1) {
        return true;
      } else {
        return false;
      }
    };

    Player.prototype.getPosition = function() {
      return this._position;
    };

    Player.prototype.setPosition = function(x, y) {
      return this._position = {
        x: x,
        y: y
      };
    };

    Player.prototype.wield = function(ch) {
      var weapon;
      weapon = this.inventory.getItem(ch) || null;
      if (weapon != null) {
        this.dice = weapon.dice;
      }
      return weapon;
    };

    return Player;

  })(EventEmitter);

}).call(this);