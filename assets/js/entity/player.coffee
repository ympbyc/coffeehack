###
# player.coffee
# Defines the properties and behaviour of a character
# Monsters extend this class therefore if the word 'player' appears
# in this file, it also represents monsters
###

{utils, EventEmitter} = hack
{randomInt} = utils

class hack.Player extends EventEmitter

  ## explevel vs experience
  #
  @EXP_REQUIRED = [
    0, 20, 40, 80, 160, 320, 640, 1280, 2560, 5120,
    10000, 20000, 40000, 80000, 160000, 320000, 640000, 1280000, 2560000, 5120000,
    100000, 200000, 300000, 400000, 500000, 600000, 700000, 800000, 900000, 1000000
  ]

  ###
  # experience is an floating point number, incremented each time the player defeats a monster
  # explevel is an integer number, incremente when the player reachs the required experience
  # gainExp is the experience given to the enemy when
  ###
  constructor : (@name, @role, @hp, @explevel=0, @gainExp=0, @dice=[1,4]) ->
    super()
    @_position = {}
    @experience = 0
    @inventory = new hack.Inventory()
    @on('godown', (e) =>
      e.prevMap.clearReservation(@getPosition().x, @getPosition().y) if e.prevMap #evaluates to false on initialization
    )
    @on('goup', (e) =>
      e.prevMap.clearReservation(@getPosition().x, @getPosition().y) if e.prevMap #evaluates to false on initialization
    )

  ## Generate a random coordinate, test it for its availability on the current map,
  ## if succeeds, reserve that cell
  ## if not, try again
  #
  born : (map, pos=null) ->
    nextPos = if pos? then pos else
      {
        x : randomInt(map.width)
        y : randomInt(map.height)
      }
    if map.isWalkable(nextPos.x, nextPos.y)
      @_position = nextPos
      map.reserveCell(@_position.x, @_position.y, @)
    else @born(map)

  ## HP is defined in terms of the player's explevel
  #
  getMaxHP : ->
    maxHP = [12, 18, 26, 36, 48, 62, 80, 100]
    maxHP[@explevel] || maxHP[maxHP.length-1]

  ## Generate a random coordinate, test for its availability
  ## if there is nothing in the way, move to it, clear the reservation of the current cell, and reserve the new cell.
  #
  walk : (map, direction) ->
    UP = 'u'; DOWN = 'd'; RIGHT = 'r'; LEFT = 'l';
    UPRLFT = 'ul'; UPRRGT = 'ur'; LWRLFT = 'll'; LWRRGT = 'lr';
    nextPos = {x : @_position.x, y : @_position.y}
    switch direction
      when UP then nextPos.y -= 1
      when DOWN then nextPos.y += 1
      when RIGHT then nextPos.x += 1
      when LEFT then nextPos.x -= 1
      when UPRLFT
        nextPos.x -= 1
        nextPos.y -= 1
      when UPRRGT
        nextPos.x += 1
        nextPos.y -= 1
      when LWRLFT
        nextPos.x -= 1
        nextPos.y += 1
      when LWRRGT
        nextPos.x += 1
        nextPos.y += 1
    if map.isWalkable(nextPos.x, nextPos.y)
      map.clearReservation(@_position.x, @_position.y)
      @_position = nextPos
      map.reserveCell(@_position.x, @_position.y, @)
    else if m = map.getReservation(nextPos.x, nextPos.y)
      @attack(m)

    @fire('move', {position : @_position})

  ## Suck the HP of the enemy the player is attacking
  #
  attack : (enemy) ->
    return if @isDead()
    enemy.hp -= utils.dice(@dice[0], @dice[1])
    if enemy.isDead()
      @killedAnEnemy(enemy)
      enemy.fire('die', {beef : enemy})
    @fire('attack', {me : @, enemy : enemy})

  ## Get the experience point the enemy defeated has.
  #
  killedAnEnemy : (enemy) ->
    @experience += enemy.gainExp
    @fire('killedanenemy')
    if @experience >= Player.EXP_REQUIRED[@explevel+1]
      @explevel += 1
      @dice[1] += 1
      @fire('explevelup', {explevel : @explevel})

  ## "U dead?"
  ## "Yeah."
  #
  isDead : ->
    if @hp < 1 then true else false

  ## getter
  #
  getPosition : ->
    @_position

  ## setter
  #
  setPosition : (x, y) ->
    @_position = {x : x, y : y}

  wield : (ch) ->
    weapon = @inventory.getItem(ch) or null
    console.log weapon
    @dice = weapon.dice if weapon?
    weapon
