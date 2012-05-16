  class Monster extends Player
    constructor : (@name, @hp, @char) ->
      super(@name, @name, @hp)
    move : (map) ->
      table = ['u', 'd', 'r', 'l']
      @walk(map, table[Math.floor(Math.random()*4)])