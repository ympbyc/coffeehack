# dependencie - eventemitter.coffee

  class Game extends EventEmitter
    constructor : ->
      super()
      @monsterStack = [[]]
      @mapStack = []
      @level = -1
      @time = 0
      @on('turn', (->
        @turnInit()
      ).bind(@))
      @on('turnend', (->
        @turnEnd()
      ).bind(@))

    setPlayer : (@player) ->

    addMap : (map) ->
      @mapStack.push(map)

    currentMap : ->
      @mapStack[@level]

    nextMap : ->
      if not @mapStack[@level+1]? then return false
      @player.fire('godown', {prevMap : @currentMap()})
      @level++
      @levelInit()
      @mapStack[@level]

    prevMap : ->
      @player.fire('goup', {prevMap : @currentMap()})
      @level--
      @mapStack[@level]

    levelInit : ->
      @monsterStack.push([]) if not @monsterStack[@level]

    addMonster : (monster) ->
      monster.born(@currentMap())
      @monsterStack[@level].push(monster)

    killMonsters : ->
      ms = @monsterStack[@level]
      for i in [0...ms.length]
        if ms[i] and ms[i].isDead()
          pos = ms[i].getPosition()
          @currentMap().clearReservation(pos.x, pos.y)
          delete ms[i]

    countMonster : ->
      ctr = 0
      for m in @monsterStack[@level]
        if m? then ctr++
      ctr

    moveAllMonsters : ->
      pp = @player.getPosition()
      for m in @monsterStack[@level]
        if m
          m.move(@currentMap(), pp.x, pp.y)
          m.fire('move')

    turnInit : ->
      @time++
      @player.hp += 1 / ((42 / (@player.explevel + 2)) + 1) if @player.hp < @player.getMaxHP()

    turnEnd : ->
      @killMonsters()
      alert 'you died' if @player.isDead()

    drawStage : ->
      map = @currentMap()
      playerPos = @player.getPosition()
      savePlayerCell = map.getCell(playerPos.x, playerPos.y)
      map.setCell(playerPos.x, playerPos.y, '@')

      saveMonsterCell = []
      for m in @monsterStack[@level]
        if m
          monsterPos = m.getPosition()
          saveMonsterCell.push({x : monsterPos.x, y : monsterPos.y, save : map.getCell(monsterPos.x, monsterPos.y)})
          map.setCell(monsterPos.x, monsterPos.y, m.char)

      ret = map.show()

      map.setCell(playerPos.x, playerPos.y, savePlayerCell)
      for s in saveMonsterCell
        map.setCell(s.x, s.y, s.save)

      ret
