  class Player extends EventEmitter
    constructor : (@name, @role, @hp) ->
      @_position = {}
      super()

    born : (map) ->
      nextPos = {
        x : Math.floor(Math.random()*map.width)
        y : Math.floor(Math.random()*map.height)
      }
      if map.isWalkable(nextPos.x, nextPos.y)
        @_position = nextPos
        map.reserveCell(@_position.x, @_position.y, @)
      else @born(map)

    walk : (map, direction) ->
      UP = 'u'; DOWN = 'd'; RIGHT = 'r'; LEFT = 'l'
      nextPos = {x : @_position.x, y : @_position.y}
      switch direction
        when UP then nextPos.y -= 1
        when DOWN then nextPos.y += 1
        when RIGHT then nextPos.x += 1
        when LEFT then nextPos.x -= 1
      if map.isWalkable(nextPos.x, nextPos.y)
        map.clearReservation(@_position.x, @_position.y)
        @_position = nextPos
        map.reserveCell(@_position.x, @_position.y, @)
      else if m = map.getReservation(nextPos.x, nextPos.y)
        @attack(m)

      @fire('move', {position : @_position})

    attack : (enemy) ->
      TEMPORARY_MAGIC_NUMBER = 2
      alert(enemy.hp)
      enemy.hp -= TEMPORARY_MAGIC_NUMBER

    isDead : ->
      if @hp < 1 then true else false

    getPosition : ->
      @_position