  class Monster extends Player
    constructor : (@name, @hp, @char) ->
    move : (map) ->
      table = ['u', 'd', 'r', 'l']
      @walk(map, table[Math.floor(Math.rondom()*4)])