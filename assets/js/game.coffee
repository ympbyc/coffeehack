class hack.Game extends hack.EventEmitter
  constructor : ->
    super()
    @monsterStack = [[]] #y-axis holds floor levels
    @itemStack = [[]] #y-axis holds floor levels
    @mapStack = []
    @level = -1
    @time = 0
    @score = 0
    @on('turn', =>
      @turnInit()
    )
    @on('turnend', =>
      @turnEnd()
    )

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
    @itemStack.push([]) if not @itemStack[@level]

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

  ## add given item to the itemstack
  #
  addItem : (x, y, item) ->
    items = @itemStack[@level]
    if not items[y]? then items[y] = {}
    if not items[y][x]? then items[y][x] = [item]
    else items[y][x].push(item)

  getItems : (x, y) ->
    items = @itemStack[@level]
    return null if not (items[y] and items[y][x])
    return items[y][x]

  shiftItem : (x, y) ->
    items = @itemStack[@level]
    if items[y]?[x]?
      items[y][x].shift()


  ## Call this on each passing turn
  #
  turnInit : ->
    @time++
    @player.hp += 1 / ((42 / (@player.explevel + 2)) + 1) if @player.hp < @player.getMaxHP() # NETHACK LOGIC

  ## Call this each time the turn ends
  #
  turnEnd : ->
    @killMonsters()
    #alert 'you died' if @player.isDead()

  ## Call the show method of the current map
  ## with monsters and the player set to it.
  #
  drawObjects : ->
    map = @currentMap()
    objectLayer = (0 for column in [0...map.width] for row in [0...map.height])

    items = @itemStack[@level]
    for i in [0...map.height]
      for j, x of (if items[i]? then items[i] else [])
        if items[i]?[j]?.length
          objectLayer[i][j] = items[i][j][0]

    pp = @player.getPosition()
    objectLayer[pp.y][pp.x] = @player

    for m in @monsterStack[@level]
      if m
        monsterPos = m.getPosition()
        objectLayer[monsterPos.y][monsterPos.x] = m

    objectLayer
