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
      null

  'x' : (game, dir = {d:'u', x:0, y:-1, hd:'r', hx:1, hy:0}) ->
    alert ('You died.') if game.player.isDead()
    map = game.currentMap()
    pp = game.player.getPosition()
    nextd = {
      u: {d:'l', x:-1, y:0,  hd:'u', hx:0,  hy:-1}
      l: {d:'d', x:0,  y:1,  hd:'l', hx:-1, hy:0}
      d: {d:'r', x:1,  y:0,  hd:'d', hx:0,  hy:1}
      r: {d:'u', x:0,  y:-1, hd:'r', hx:1,  hy:0}
    }
    prevd = {
      u: {d:'r', x:1,  y:0,  hd:'d', hx:0,  hy:1}
      l: {d:'u', x:0,  y:-1, hd:'r', hx:1,  hy:0}
      d: {d:'l', x:-1, y:0,  hd:'u', hx:0,  hy:-1}
      r: {d:'d', x:0,  y:1,  hd:'l', hx:-1, hy:0}
    }
    isOkToGo = (x, y) ->
      if map.isWalkable(x, y) or map.isAttackable(x, y) then true
      else false

    if map.getCell(pp.x, pp.y) is Map.STAIR_DOWN then commands['>'](game)
    else if isOkToGo(pp.x+dir.x, pp.y+dir.y)
      if not isOkToGo(pp.x+dir.hx, pp.y+dir.hy)
        game.player.walk(map, dir.d)
      else
        game.player.walk(map, dir.hd)
        #dir = prevd[dir.d]
      game.fire('turn')
    else if isOkToGo(pp.x+dir.hx, pp.y+dir.hy)
      game.player.walk(map, dir.hd)
      dir = prevd[dir.d]
      game.fire('turn')
    else
      dir = nextd[dir.d]

    setTimeout((->commands['x'](game, dir)),100)
}
