message = if require? then require('messagelist').messagelist else messagelist

traplist = [
    #hole
  (game) ->
    game.fire('message', message.trap.hole)
    game.fire('godown')
  , #stone
  (game) ->
    game.fire('message', message.trap.stone)
    game.player.hp -= 4
  , #teleport
  (game) ->
    game.fire('message', message.trap.teleport)
    map = game.currentMap()
    (f = ->
      x = Math.floor(Math.random()*map.width); y = Math.floor(Math.random()*map.height)
      if map.isWalkable(x, y) then game.player.setPosition(x, y)
      else f()
    )()
]