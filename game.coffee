  class Game extends EventEmitter
    constructor : ->
      super()
      @monsterStack = []
      @mapStack = []
      @level = -1
      @time = 0
      @on('turn', (->
        @turnInit()
      ).bind(this))
      @on('turnend', (->
        @turnEnd()
      ).bind(this))

    setPlayer : (@player) ->
      @player.on('move', ((e) ->
#        pos = @player.getPosition()
#        nearby = @currentMap().getNearByCells(pos.x, pos.y)
#        for cell in nearby
#          cell.attack(@player) if cell
      ).bind(this))

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

    killMonsters : ->
      for i in [0...@monsterStack.length]
        if @monsterStack[i] and @monsterStack[i].isDead()
          @monsterStack[i].fire('die')
          pos = @monsterStack[i].getPosition()
          @currentMap().clearReservation(pos.x, pos.y)
          delete @monsterStack[i]

    countMonster : ->
      ctr = 0
      for m in @monsterStack
        if m then ctr++
      ctr

    moveAllMonsters : ->
      for m in @monsterStack
        if m
          m.move(@currentMap())
          m.fire('move')

    turnInit : ->
      @time++

    turnEnd : ->
      @killMonsters()
      alert 'you died' if @player.isDead()

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
