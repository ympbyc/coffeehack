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

    ## set the player of the game.
    ## coffeehack is a single player game so this method
    ## is called just once
    #
    setPlayer : (@player) ->

    ## coffeehack saves every level the player explored
    ## this method adds a map to this saved list of maps
    #
    addMap : (map) ->
      @mapStack.push(map)

    ## Returns the map where the player is on. (if set correctly)
    #
    currentMap : ->
      @mapStack[@level]

    ## Increment the floor level and return the registered map of this level
    ## This method WILL NOT create a new map.
    ## Instead it returns false in that case.
    #
    nextMap : ->
      if not @mapStack[@level+1]? then return false
      @player.fire('godown', {prevMap : @currentMap()})
      @level++
      @levelInit()
      @mapStack[@level]

    ## Decrements the floor level and return the registered map for this level
    #
    prevMap : ->
      @player.fire('goup', {prevMap : @currentMap()})
      @level--
      @mapStack[@level]

    ## Call this each time the floor level increments or decrements
    #
    levelInit : ->
      @monsterStack.push([]) if not @monsterStack[@level]

    ## Add a monster to the stack
    ## Stacks are associated with floor levels
    #
    addMonster : (monster) ->
      monster.born(@currentMap())
      @monsterStack[@level].push(monster)

    ## Remove dead monsters from the stack
    #
    killMonsters : ->
      ms = @monsterStack[@level]
      for i in [0...ms.length]
        if ms[i] and ms[i].isDead()
          pos = ms[i].getPosition()
          @currentMap().clearReservation(pos.x, pos.y)
          delete ms[i]

    ## Count the number of live monsters
    #
    countMonster : ->
      ctr = 0
      for m in @monsterStack[@level]
        if m? then ctr++
      ctr

    ## Call the move method for each monster in the stack
    #
    moveAllMonsters : ->
      pp = @player.getPosition()
      for m in @monsterStack[@level]
        if m
          m.move(@currentMap(), pp.x, pp.y)
          m.fire('move')

    ## Call this on each passing turn
    #
    turnInit : ->
      @time++
      @player.hp += 1 / ((42 / (@player.explevel + 2)) + 1) if @player.hp < @player.getMaxHP() # NETHACK LOGIC

    ## Call this each time the turn ends
    #
    turnEnd : ->
      @killMonsters()
      alert 'you died' if @player.isDead()

    ## Call the show method of the current map
    ## with monsters and the player set to it.
    #
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
