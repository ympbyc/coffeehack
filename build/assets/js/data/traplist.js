(function() {
  var message;

  message = hack.messagelist;

  hack.traplist = [
    function(game) {
      game.fire('message', {
        message: message.trap.hole
      });
      return game.fire('godown');
    }, function(game) {
      game.fire('message', {
        message: message.trap.stone
      });
      return game.player.hp -= 4;
    }, function(game) {
      var map, pp;
      game.fire('message', {
        message: message.trap.teleport
      });
      pp = game.player.getPosition();
      map = game.currentMap();
      map.clearReservation(pp.x, pp.y);
      return game.player.born(map);
    }
  ];

}).call(this);
