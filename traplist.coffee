message = if require? then require('messagelist').messagelist else messagelist

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
    (f = ->
      x = Math.floor(Math.random()*map.width); y = Math.floor(Math.random()*map.height)
      if map.isWalkable(x, y)
        map.clearReservation(pp.x, pp.y)
        map.reserve(x, y)
        game.player.setPosition(x, y)
      else f()
    )()
]