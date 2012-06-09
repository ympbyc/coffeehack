commands = {
  '>' : (game) ->
    pp = game.player.getPosition()
    if game.currentMap().getCell(pp.x, pp.y) is Map.STAIR_DOWN
      game.fire('godown')
    null

  '<' : (game) ->
    pp = game.player.getPosition()
    if game.level > 0 and game.currentMap().getCell(pp.x, pp.y) is Map.STAIR_UP
      game.fire('goup')
    null

  ';' : (game) ->
    pp = game.player.getPosition()
    possibleItems = game.getItems(pp.x, pp.y)
    if possibleItems?.length? then for it in possibleItems
      game.fire('message', {message : it.name}) if it?
    null

  ',' : (game) ->
    pp = game.player.getPosition()
    possibleItems = game.getItems(pp.x, pp.y)
    if possibleItems?
      cch = game.player.inventory.addItem(possibleItems[0])
      game.fire('message', {message : "You picked up a #{possibleItems[0].name} - #{cch}."}) if cch?
      game.shiftItem(pp.x, pp.y) if cch?
    null

  'i' : (game) ->
    disparr = ("#{ch} - #{item.name}(#{item.dice.join('d')})" for ch, item of game.player.inventory.listItems() when item?)
    game.fire('message', {message : disparr.join('\n')})
    console.log(game.player.inventory.listItems())
    null

  'w' : (game) ->
    (ch) ->
      weapon = game.player.wield(ch)
      game.fire('message', {message : "You wielded the #{weapon.name} #{weapon.dice[0]}d#{weapon.dice[1]}."}) if weapon?
      game.fire('turn')
      null

  'd' : (game) ->
    pp = game.player.getPosition()
    (ch) ->
      item = game.player.inventory.removeItem(ch)
      console.log(item)
      game.addItem(pp.x, pp.y, item)
}
