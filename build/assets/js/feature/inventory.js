(function() {
  var EventEmitter,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  EventEmitter = hack.EventEmitter;

  hack.Inventory = (function(_super) {

    __extends(Inventory, _super);

    Inventory.validchars = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k'];

    function Inventory() {
      Inventory.__super__.constructor.call(this);
      this._inventory = {};
      this._charIndex = 0;
    }

    Inventory.prototype.charIndexIncrement = function(i, memoi) {
      var MAX_RECURSION;
      if (i == null) {
        i = 0;
      }
      if (memoi == null) {
        memoi = 0;
      }
      if (i >= Inventory.validchars.length) {
        return this.charIndexIncrement(0, memoi + 1);
      } else if (!(this.getItem(Inventory.validchars[i]) != null)) {
        return i;
      } else if (memoi >= (MAX_RECURSION = Inventory.validchars.length * 2)) {
        throw "inventory overflow";
        return i;
      } else {
        return this.charIndexIncrement(i + 1, memoi + 1);
      }
    };

    Inventory.prototype.addItem = function(item) {
      var cch;
      try {
        this._charIndex = this.charIndexIncrement(this._charIndex);
      } catch (err) {
        this.fire('inventoryfull');
        return null;
      }
      cch = Inventory.validchars[this._charIndex];
      this._inventory[cch] = item;
      return cch;
    };

    Inventory.prototype.getItem = function(ch) {
      return this._inventory[ch];
    };

    Inventory.prototype.removeItem = function(ch) {
      var tmp;
      tmp = this._inventory[ch];
      this._inventory[ch] = null;
      return tmp;
    };

    Inventory.prototype.listItems = function() {
      return this._inventory;
    };

    return Inventory;

  })(EventEmitter);

}).call(this);
