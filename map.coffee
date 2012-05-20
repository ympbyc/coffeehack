  class Map
    @EMPTY = 0
    @PATH = 1
    @ROOM = 2
    @WALL_VERT = 3.1
    @WALL_HORIZ = 3.2
    @STAIR_UP = 4.1
    @STAIR_DOWN = 4.2
    @TRAP = 5
    @TRAP_ACTIVE = 5.1
    @ITEM = 6

    initMap = (width, height) ->
      map = for i in [0 ... height]
        arr = for i in [0 ... width]
          Map.EMPTY

    splitMap = (map, splitMode) ->
      map = map.concat([])
      height = map.length
      width = map[0].length
      SPLIT_VERTICAL = 1
      SPLIT_HORIZONTAL = 2
      MINIMUM_LENGTH = 12

      return createRoom(map) if width < MINIMUM_LENGTH or height < MINIMUM_LENGTH

      splitMode = splitMode or Math.round(Math.random())

      if splitMode is SPLIT_VERTICAL
        xPosition = Math.round(Math.random()*(width-10)+5)

        for i in [2 ... map.length-2]
          map[i][xPosition] = Map.PATH

        leftHalf = []; rightHalf = []; splitColumn = []
        for row in map
          leftHalf.push(row[...xPosition])
          rightHalf.push(row[xPosition+1..])
          splitColumn.push([row[xPosition]])

        leftResult = splitMap(leftHalf, SPLIT_HORIZONTAL)
        rightResult = splitMap(rightHalf, SPLIT_HORIZONTAL)
        finalResult = for i in [0 ... map.length]
          leftResult[i].concat splitColumn[i].concat rightResult[i]
        return finalResult

      else if splitMode is SPLIT_HORIZONTAL
        yPosition = Math.round(Math.random()*(height-10)+5)

        for i in [2 ... map[yPosition].length-2]
          map[yPosition][i] = Map.PATH

        upperHalf = map[0 ... yPosition]
        lowerHalf = map[yPosition+1 ..]
        splitRow = [map[yPosition]]

        return splitMap(upperHalf, SPLIT_VERTICAL).concat splitRow.concat splitMap(lowerHalf, SPLIT_VERTICAL)

    createRoom = (section) ->
      section = section.concat([])
      for i in [1 .. section.length-2]
        for j in [1 .. section[i].length-2]
          if i is 1 or i is section.length-2 then section[i][j] = Map.WALL_HORIZ
          else if j is 1 or j is section[i].length-2 then section[i][j] = Map.WALL_VERT
          else section[i][j] = Map.ROOM

      vert_center = Math.floor(section.length / 2)
      horiz_center = Math.floor(section[0].length / 2)

      section[vert_center][0] = Map.PATH; section[vert_center][1] = Map.ROOM
      section[vert_center][section[vert_center].length-1] = Map.PATH; section[vert_center][section[vert_center].length-2] = Map.ROOM
      section[0][horiz_center] = Map.PATH; section[1][horiz_center] = Map.ROOM
      section[section.length-1][horiz_center] = Map.PATH; section[section.length-2][horiz_center] = Map.ROOM;
      section

    createSpecialCells = (map) ->
      map = map.concat([])
      f = (type, occurance = 1) ->
        if occurance
          x = Math.floor(Math.random()*map[0].length); y = Math.floor(Math.random()*map.length)
          if map[y][x] and map[y][x] is Map.ROOM
            map[y][x] =  type
            f(type, occurance -= 1)
          else f(type, occurance)
      f(Map.STAIR_UP)
      f(Map.STAIR_DOWN)
      f(Map.TRAP, Math.floor(Math.random()*10))
      f(Map.ITEM, Math.floor(Math.random()*10+3))
      map

    constructor : (@width, @height) ->
      @_map = createSpecialCells(splitMap(initMap(@width, @height), 1))
      @reserved = []

    show : () ->
      str =  (for row in @_map
        (for cell in row
          switch cell
            when Map.EMPTY then ' '
            when Map.WALL_VERT then '|'
            when Map.WALL_HORIZ then '-'
            when Map.ROOM then '.'
            when Map.TRAP then '.'
            when Map.TRAP_ACTIVE then '^'
            when Map.PATH then '#'
            when Map.STAIR_UP then '<'
            when Map.STAIR_DOWN then '>'
            when Map.ITEM then '*'
            else cell
        ).join('')
      ).join('\n')
      str

    walkable = [Map.ROOM, Map.PATH, Map.STAIR_UP, Map.STAIR_DOWN, Map.TRAP, Map.TRAP_ACTIVE, Map.ITEM]

    isWalkable : (x, y) ->
      @_map[y] and @_map[y][x] and walkable.indexOf(@_map[y][x]) > -1 and not @getReservation(x, y)

    isAttackable : (x, y) ->
      @_map[y] and @_map[y][x] and walkable.indexOf(@_map[y][x]) > -1

    setCell : (x, y, char) ->
      @_map[y][x] = char

    getCell : (x, y) ->
      @_map[y][x]

    reserveCell : (x, y, obj) ->
      if not @reserved[y] then @reserved[y] = {}
      if not @reserved[y][x] then @reserved[y][x] = obj
      else throw 'cell already reserved'

    getReservation : (x, y) ->
      if @reserved[y] and @reserved[y][x] then @reserved[y][x]
      else false

    clearReservation : (x, y) ->
      @reserved[y][x] = null

    getNearByCells : (x, y) ->
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