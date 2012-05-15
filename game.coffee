  class Game extends EventEmitter
    mapStack = []
    monsterStack = []

    constructor : ->
      @level = -1

    setPlayer : (@player) ->

    addMap : (map) ->
      mapStack.push(map)

    currentMap : ->
      mapStack[@level]

    nextMap : ->
      @level++
      mapStack[@level]

    prevMap : ->
      @level--
      mapStack[@level]

    addMonster : (monster) ->
      monsterStack.push(monster)

    killMonster : (monster) ->
      for i in [0...monsterStack.length]
        if monsterStack[i] is monster then delete monsterStack[i]

    countMonster : ->
      ctr = 0
      for m in mansterStack
        if m then ctr++
      ctr

    moveAllMonsters : ->
      m.move() for m in monsterStack

    drawStage : ->
      map = @currentMap()
      playerPos = @player.getPosition()
      savePlayerCell = map.getCell(playerPos.x, playerPos.y)
      map.setCell(playerPos.x, playerPos.y, '@')


      saveMonsterCell = []
      for m in monsterStack
        if m
          monsterPos = m.getPosition()
          saveMonsterCell.push({x : monsterPos.x, y : monsterPos.y, save : map.getCell(monsterPos.x, monsterPos.y)})
          map.setCell(monsterPos.x, monsterPos.y, m.char)

      ret = map.show()

      map.setCell(playerPos.x, playerPos.y, savePlayerCell)
      for s in saveMonsterCell
        map.setCell(s.x, s.y, s.save)

      ret
