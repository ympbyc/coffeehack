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

  'x' : (game, tothisdir=null) ->
    if game.player.isDead() then game.player.hp = 100
    console.log tothisdir
    map = game.currentMap()
    dstcs = (->
      for i in [0...map._map.length]
        for j in [0...map._map[i].length]
          return {x:j, y:i} if map.getCell(j, i) is Map.STAIR_DOWN
    )()

    isOkToGo = (x, y) ->
      if map.isWalkable(x, y) or map.isAttackable(x, y) then true
      else false

    pp = game.player.getPosition()
    rnd = !(utils.randomInt(10) < 3)
    nbc = map.getNearbyCells()
    if map.getCell(pp.x, pp.y) is Map.STAIR_DOWN then commands['>'](game)
    else if (tothisdir and (
          (tothisdir is 'u' and isOkToGo(pp.x, pp.y-1)) or
          (tothisdir is 'd' and isOkToGo(pp.x, pp.y+1)) or
          (tothisdir is 'l' and isOkToGo(pp.x-1, pp.y)) or
          (tothisdir is 'r' and isOkToGo(pp.x+1, pp.y))
       )) and utils.randomInt(10) > 3
         ttd = tothisdir
         game.player.walk(map, tothisdir)
    else if pp.x < dstcs.x && isOkToGo(pp.x+1, pp.y) and utils.randomInt(10) > 4
      game.player.walk(map, 'r')
    else if pp.y < dstcs.y &&  isOkToGo(pp.x, pp.y+1) and utils.randomInt(10) > 4
      game.player.walk(map, 'd')
    else if pp.x > dstcs.x && isOkToGo(pp.x-1, pp.y) and utils.randomInt(10) > 4
      game.player.walk(map, 'l')
    else if pp.y > dstcs.y &&  isOkToGo(pp.x, pp.y-1)  and utils.randomInt(10) > 4
      game.player.walk(map, 'u')
    else
        ttd = null
        f = ->
          d= [{d:'r', x:pp.x+1, y:pp.y},
           {d:'l', x:pp.x-1, y:pp.y},
           {d:'d', x:pp.x, y:pp.y+1},
           {d:'u', x:pp.x, y:pp.y-1}
          ][utils.randomInt(4)]
          if isOkToGo(d.x, d.y)
            game.player.walk(map, d.d)
            ttd = d.d
          else f()
        f()
    game.fire('turn')
    setTimeout((->commands['x'](game, ttd)), 80)
}
