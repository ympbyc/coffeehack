  class Player extends EventEmitter
    @EXP_REQUIRED = [
      0, 20, 40, 80, 160, 320, 640, 1280, 2560, 5120,
      10000, 20000, 40000, 80000, 160000, 320000, 640000, 1280000, 2560000, 5120000,
      100000, 200000, 300000, 400000, 500000, 600000, 700000, 800000, 900000, 1000000
    ]


    constructor : (@name, @role, @hp, @explevel=0, @gainExp=0, @dice=[1,4]) ->
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
      maxHP[@explevel] || maxHP[maxHP.length-1]

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
      enemy.hp -= utils.dice(@dice[0], @dice[1])
      if enemy.isDead()
        @killedAnEnemy(enemy)
        enemy.fire('die')
      @fire('attack', {me : @, enemy : enemy})

    killedAnEnemy : (enemy) ->
      @experience += enemy.gainExp
      if @experience >= Player.EXP_REQUIRED[@explevel+1]
        @explevel += 1
        @dice[1] += 1
        @fire('explevelup', {explevel : @explevel})

    isDead : ->
      if @hp < 1 then true else false

    getPosition : ->
      @_position

    setPosition : (x, y) ->
      @_position = {x : x, y : y}