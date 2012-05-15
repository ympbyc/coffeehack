  class Player extends EventEmitter
    constructor : (@name, @role) ->
      @position = {}
      super()

    born : (map) ->
      nextPos = {
        x : Math.floor(Math.random()*map.width)
        y : Math.floor(Math.random()*map.height)
      }
      if map.isWalkable(nextPos.x, nextPos.y)
        @position = nextPos
        map.reservePosition(@position.x, @position.y)
      else @born(map)

    walk : (map, direction) ->
      UP = 'u'; DOWN = 'd'; RIGHT = 'r'; LEFT = 'l'
      nextPos = {x : @position.x, y : @position.y}
      switch direction
        when UP then nextPos.y -= 1
        when DOWN then nextPos.y += 1
        when RIGHT then nextPos.x += 1
        when LEFT then nextPos.x -= 1
      if map.isWalkable(nextPos.x, nextPos.y)
        map.clearReservation(@position.x, @position.y)
        @position = nextPos
        map.reservePosition(@position.x, @position.y)

    getPosition : ->
      @position