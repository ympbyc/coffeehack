(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  hack.Item = (function() {

    function Item(name, rareness, dice, message) {
      this.name = name;
      this.rareness = rareness;
      this.dice = dice;
      this.message = message;
    }

    return Item;

  })();

  hack.Weapon = (function(_super) {

    __extends(Weapon, _super);

    function Weapon(name, rareness, dice, message) {
      Weapon.__super__.constructor.call(this, name, rareness, dice, message);
    }

    return Weapon;

  })(hack.Item);

}).call(this);
