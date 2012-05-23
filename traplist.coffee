# dependencie - messagelist.coffee, instance of the Game class

message = messagelist
traplist = [
    #hole
  (game) ->
    game.fire('message', {message : message.trap.hole})
    game.fire('godown')
  , #stone
  (game) ->
    game.fire('message', {message : message.trap.stone})
    game.player.hp -= 4
  , #teleport
  (game) ->
    game.fire('message', {message : message.trap.teleport})
    pp = game.player.getPosition()
    map = game.currentMap()
    map.clearReservation(pp.x, pp.y)
    game.player.born(map)
]