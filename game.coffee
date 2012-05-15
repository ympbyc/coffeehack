  class Game extends EventEmitter
    constructor : ->
      super()
      @monsterStack = []
      @mapStack = []
      @level = -1
      @time = 0

    setPlayer : (@player) ->

    addMap : (map) ->
      @mapStack.push(map)

    currentMap : ->
      @mapStack[@level]

    nextMap : ->
      @level++
      @mapStack[@level]

    prevMap : ->
      @level--
      @mapStack[@level]

    addMonster : (monster) ->
      monster.born(@currentMap())
      @monsterStack.push(monster)

    killMonster : (monster) ->
      for i in [0...@monsterStack.length]
        if @monsterStack[i] is monster then delete @monsterStack[i]

    countMonster : ->
      ctr = 0
      for m in @monsterStack
        if m then ctr++
      ctr

    moveAllMonsters : ->
      m.move(@currentMap()) for m in @monsterStack

    turnInit : ->
      @time++

    drawStage : ->
      map = @currentMap()
      playerPos = @player.getPosition()
      savePlayerCell = map.getCell(playerPos.x, playerPos.y)
      map.setCell(playerPos.x, playerPos.y, '@')

      saveMonsterCell = []
      for m in @monsterStack
        if m
          monsterPos = m.getPosition()
          saveMonsterCell.push({x : monsterPos.x, y : monsterPos.y, save : map.getCell(monsterPos.x, monsterPos.y)})
          map.setCell(monsterPos.x, monsterPos.y, m.char)

      ret = map.show()

      map.setCell(playerPos.x, playerPos.y, savePlayerCell)
      for s in saveMonsterCell
        map.setCell(s.x, s.y, s.save)

      ret