  class Player extends EventEmitter
    constructor : (@name, @role, @hp) ->
      super()
      @_position = {}
      @experience = 0
      @on('godown', ((e) ->
        e.prevMap.clearReservation(@getPosition().x, @getPosition().y) if e.prevMap #evaluates to false on initialization
      ).bind(@))
      @on('goup', ((e) ->
        e.prevMap.clearReservation(@getPosition().x, @getPosition().y) if e.prevMap #evaluates to false on initialization
      ).bind(@))

    born : (map) ->
      nextPos = {
        x : Math.floor(Math.random()*map.width)
        y : Math.floor(Math.random()*map.height)
      }
      if map.isWalkable(nextPos.x, nextPos.y)
        @_position = nextPos
        map.reserveCell(@_position.x, @_position.y, @)
      else @born(map)

    getMaxHP : ->
      maxHP = [12, 18, 26, 36, 48, 62, 80, 100]
      maxHP[Math.floor(@experience)] || maxHP[maxHP.length-1]

    getPower : ->
      power = (i for i in [4..20] by 2)
      power[Math.floor(@experience)] || power[power.length-1]

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
      return if @isDead()
      enemy.hp -= @getPower()
      if enemy.isDead()
        @experience += enemy.gainExp/(@experience || 1) #gain Exp decreases according to the players exp
        enemy.fire('die')
      @fire('attack', {me : @, enemy : enemy})

    isDead : ->
      if @hp < 1 then true else false

    getPosition : ->
      @_position

    setPosition : (x, y) ->
      @_position = {x : x, y : y}
