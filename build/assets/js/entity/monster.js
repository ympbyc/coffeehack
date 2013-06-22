
/*
# monster.coffeee
# Monsters are players, with an extended method move.
# They are designed to chase "the player" and attack them
*/


(function() {
  var Player, utils,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  utils = hack.utils, Player = hack.Player;

  hack.Monster = (function(_super) {

    __extends(Monster, _super);

    function Monster(role, difficulty, char, explevel, gainExp, action, dice) {
      var hp;
      this.role = role;
      this.difficulty = difficulty;
      this.char = char;
      this.explevel = explevel;
      this.gainExp = gainExp;
      this.action = action;
      this.dice = dice;
      hp = utils.dice(this.explevel, 8);
      Monster.__super__.constructor.call(this, null, this.role, hp, this.explevel, this.gainExp, this.dice);
    }

    Monster.prototype.move = function(map, x, y) {
      var direction, fallback, mp;
      fallback = (function() {
        var table;
        table = ['u', 'd', 'r', 'l'];
        return this.walk(map, table[utils.randomInt(4)]);
      }).bind(this);
      if (!(x != null) || !(y != null)) {
        return fallback();
      } else {
        if (utils.randomInt(10) < 2) {
          return fallback();
        } else {
          mp = this.getPosition();
          direction = (mp.x < x && map.isAttackable(mp.x + 1, mp.y) ? 'r' : mp.x > x && map.isAttackable(mp.x - 1, mp.y) ? 'l' : mp.y < y && map.isAttackable(mp.x, mp.y + 1) ? 'd' : mp.y > y && map.isAttackable(mp.x, mp.y - 1) ? 'u' : false);
          if (direction) {
            return this.walk(map, direction);
          } else {
            return fallback();
          }
        }
      }
    };

    return Monster;

  })(Player);

}).call(this);
