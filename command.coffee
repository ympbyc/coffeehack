commands = {
  '>' : (game) ->
    pp = game.player.getPosition()
    if game.currentMap().getCell(pp.x, pp.y) is Map.STAIR_DOWN
      game.fire('godown')
  '<' : (game) ->
    pp = game.player.getPosition()
    if game.level > 0 and game.currentMap().getCell(pp.x, pp.y) is Map.STAIR_UP
      game.fire('goup')
}
