  class Map
    EMPTY = 0
    PATH = 1
    ROOM = 2
    WALL_VERT = 3.1
    WALL_HORIZ = 3.2

    initMap = (width, height) ->
      map = for i in [0 ... height]
        arr = for i in [0 ... width]
          EMPTY

    splitMap = (map, splitMode) ->
      map = map.concat([])
      height = map.length
      width = map[0].length
      SPLIT_VERTICAL = 0
      SPLIT_HORIZONTAL = 1
      MINIMUM_LENGTH = 12

      return createRoom(map) if width < MINIMUM_LENGTH or height < MINIMUM_LENGTH

      splitMode = splitMode or Math.round(Math.random())

      if splitMode is SPLIT_VERTICAL
        xPosition = Math.round(Math.random()*(width-10)+5)

        for i in [2 ... map.length-2]
          map[i][xPosition] = PATH

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
          map[yPosition][i] = PATH

        upperHalf = map[0 ... yPosition]
        lowerHalf = map[yPosition+1 ..]
        splitRow = [map[yPosition]]

        return splitMap(upperHalf, SPLIT_VERTICAL).concat splitRow.concat splitMap(lowerHalf, SPLIT_VERTICAL)

    createRoom = (section) ->
      section = section.concat([])
      for i in [1 .. section.length-2]
        for j in [1 .. section[i].length-2]
          if i is 1 or i is section.length-2 then section[i][j] = WALL_HORIZ
          else if j is 1 or j is section[i].length-2 then section[i][j] = WALL_VERT
          else section[i][j] = ROOM

      vert_center = Math.floor(section.length / 2)
      horiz_center = Math.floor(section[0].length / 2)

      section[vert_center][0] = PATH; section[vert_center][1] = ROOM
      section[vert_center][section[vert_center].length-1] = PATH; section[vert_center][section[vert_center].length-2] = ROOM
      section[0][horiz_center] = PATH; section[1][horiz_center] = ROOM
      section[section.length-1][horiz_center] = PATH; section[section.length-2][horiz_center] = ROOM;

      section

    constructor : (@width, @height) ->
      @_map = splitMap(initMap(@width, @height))

    show : () ->
      str =  (for row in @_map
        (for cell in row
          switch cell
            when EMPTY then ' '
            when WALL_VERT then '|'
            when WALL_HORIZ then '-'
            when ROOM then '.'
            when PATH then '#'
            else cell
        ).join('')
      ).join('\n')
      console.log(str)
      str


    isWalkable : (x, y) ->
      if (@_map[y] && @_map[y][x] && [ROOM, PATH].indexOf(@_map[y][x]) > -1) then true
      else false

    setCell : (x, y, char) ->
      @_map[y][x] = char

    getCell : (x, y) ->
      @_map[y][x]
