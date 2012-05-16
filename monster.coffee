  class Monster extends Player
    constructor : (@role, @hp, @char, @power, @gainExp, @action) ->
      super(null, @role, @hp)
    move : (map) ->
      table = ['u', 'd', 'r', 'l']
      @walk(map, table[Math.floor(Math.random()*4)])