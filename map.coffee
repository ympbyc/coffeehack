  #dep utils

  class Map
    @EARTH = 0
    @WATER = 1
    @FLOOR = 2
    @WALL = 3
    @STAIR_UP = 4.1
    @STAIR_DOWN = 4.2
    @TRAP = 5
    @TRAP_ACTIVE = 5.1
    @NINJITSU = 6

    ## create a two dimentional array representing the map.
    ## prefill each cell with earth
    #
    _createEarth = (width, height) ->
      (for i in [0 ... height]
        (for j in [0 ... width]
          Map.EARTH))

    ## we need some walls in order to build features.
    ## creating a small room at the center would do the job.
    #
    _singleRoomAtTheCentre : ->
      centre = {x:@width/2, y:@height/2}
      room = [[Map.WALL, Map.WALL, Map.WALL, Map.WALL, Map.WALL]
              [Map.WALL, Map.FLOOR, Map.FLOOR, Map.FLOOR, Map.WALL]
              [Map.WALL, Map.FLOOR, Map.FLOOR, Map.FLOOR, Map.WALL]
              [Map.WALL, Map.FLOOR, Map.FLOOR, Map.FLOOR, Map.WALL]
              [Map.WALL, Map.WALL, Map.WALL, Map.WALL, Map.WALL]]
      @_addFeatureIfSpaceIsAvailable(centre, room, 'down')

    ## pick a random coordinate
    ## check if it is empty and is next to a wall cell
    ## if so return that coordinate and the direction which the feature should be added
    #
    _pickRandomStartingPoint : () ->
      p = {x: utils.randomInt(@width), y: utils.randomInt(@height)}
      nbc = @getNearbyCells(p.x, p.y)
      if (@getCell(p.x,p.y) is Map.EARTH \
         and (it for it in nbc when it is Map.WALL).length is 3)
        if nbc[0] is Map.WALL then {coord:p, direction:'left'}
        else if nbc[1] is Map.WALL then {coord:p, direction:'right'}
        else if nbc[2] is Map.WALL then {coord:p, direction:'up'}
        else if nbc[3] is Map.WALL then {coord:p, direction:'down'}
        else
          @_pickRandomStartingPoint()
      else
          @_pickRandomStartingPoint()

    ## add the given feature to the map
    ## we accomplish this by actually filling the deep copyied array of the map
    ## just return if we encounter a non-empty cell on the way
    ## otherwise replace the map with this new map with the feature added
    #
    _addFeatureIfSpaceIsAvailable : (p, feature, direction) ->
      map = (cell for cell in row for row in @_map)
      fwidth = feature[0].length; fheight = feature.length
      mf = Math.floor
      topleft = switch direction
        when 'up' then {x: p.x-mf(fwidth/2), y: p.y-(fheight-1), tof:{x:p.x,y:p.y+1}}
        when 'down' then {x: p.x-mf(fwidth/2), y: p.y, tof:{x:p.x,y:p.y-1}}
        when 'left' then {x: p.x-(fwidth-1), y: p.y-mf(fheight/2), tof:{x:p.x+1,y:p.y}}
        when 'right' then {x:p.x, y: p.y-mf(fheight/2), tof:{x:p.x-1,y:p.y}}
      for y in [0...fheight]
        for x in [0...fwidth]
          return null if @getCell(x+topleft.x, y+topleft.y) isnt Map.EARTH
          map[y+topleft.y][x+topleft.x] = feature[y][x]
      map[p.y][p.x] = Map.FLOOR
      map[topleft.tof.y][topleft.tof.x] = Map.FLOOR
      @_map = map

    ## create special cells such as staircases, traps and ninjitsu fields
    #
    _createSpecialCells : ->
      f = (type, occurance = 1, memo) =>
        if occurance
          x = utils.randomInt(@width-1); y = utils.randomInt(@height-1)
          if @_map[y][x] and @_map[y][x] is Map.FLOOR
            @_map[y][x] =  type
            f(type, occurance -= 1, {x:x,y:y})
          else f(type, occurance)
        else
          memo
      @stair_pos_up = f(Map.STAIR_UP)
      @stair_pos_down = f(Map.STAIR_DOWN)
      f(Map.TRAP, utils.randomInt(5))
      f(Map.NINJITSU, 3)
      @_map

    constructor : (@width, @height) ->
      @_map = _createEarth(@width, @height)
      @_singleRoomAtTheCentre()

      lmt = 50
      while --lmt
        sttpt = @_pickRandomStartingPoint()
        @_addFeatureIfSpaceIsAvailable(sttpt.coord, features[utils.randomInt(features.length)], sttpt.direction)
      @stair_pos_up = null; @stair_pos_down = null
      @_createSpecialCells()
      @reserved = []

    ## build a string visualising the map.
    #
    show : () ->
      str =  (for row in @_map
        (for cell in row
          switch cell
            when Map.EARTH then ' '
            when Map.WATER then '~'
            when Map.WALL then '-'
            when Map.FLOOR then '.'
            when Map.TRAP then '.'
            when Map.TRAP_ACTIVE then '^'
            when Map.PATH then '#'
            when Map.STAIR_UP then '<'
            when Map.STAIR_DOWN then '>'
            when Map.NINJITSU then '*'
        ).join('')
      ).join('\n')
      str

    walkable = [Map.FLOOR, Map.PATH, Map.STAIR_UP, Map.STAIR_DOWN, Map.TRAP, Map.TRAP_ACTIVE, Map.NINJITSU]

    ## Checks for the cell type and reservation
    #
    isWalkable : (x, y) ->
      @_map[y] and @_map[y][x] and walkable.indexOf(@_map[y][x]) > -1 and not @getReservation(x, y)

    ## Only checks for the map type
    #
    isAttackable : (x, y) ->
      @_map[y] and @_map[y][x] and walkable.indexOf(@_map[y][x]) > -1

    ## Give it a map type and it'll set the cell to be it
    #
    setCell : (x, y, char) ->
      @_map[y][x] = char

    ## Returns whatever is the cell set to
    #
    getCell : (x, y) ->
      if @_map[y]?[x]?
        @_map[y][x]
      else null

    ##
    #
    getNearbyCells : (x, y) ->
      [
        @getCell(x+1, y),
        @getCell(x-1, y),
        @getCell(x, y+1),
        @getCell(x, y-1),
        @getCell(x+1, y+1),
        @getCell(x+1, y-1),
        @getCell(x-1, y+1),
        @getCell(x-1, y-1)
      ]

    ## Makes the cell exclusive to the object given.
    ## player and monsters should reserve a cell each time they move.
    #
    reserveCell : (x, y, obj) ->
      if not @reserved[y] then @reserved[y] = {}
      if not @reserved[y][x] then @reserved[y][x] = obj
      else throw 'cell already reserved'

    ## Get whats in the reservation array
    #
    getReservation : (x, y) ->
      if @reserved[y] and @reserved[y][x] then @reserved[y][x]
      else false

    ## Make the cell available for others
    #
    clearReservation : (x, y) ->
      @reserved[y][x] = null if @reserved[y]?[x]?

    ## Returns an array containing the reservation of surrounding 8 cells
    #
    getNearbyReservations : (x, y) ->
      [
        @getReservation(x+1, y),
        @getReservation(x-1, y),
        @getReservation(x, y+1),
        @getReservation(x, y-1),
        @getReservation(x+1, y+1),
        @getReservation(x-1, y+1),
        @getReservation(x+1, y-1),
        @getReservation(x-1, y-1)
      ]