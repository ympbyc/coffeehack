  class Monster extends Player
    constructor : (@role, @hp, @char, @power, @gainExp, @action) ->
      super(null, @role, @hp)

    move : (map, x, y) ->
      fallback = (->
        table = ['u', 'd', 'r', 'l']
        @walk(map, table[Math.floor(Math.random()*4)])).bind(@)
      if not x? or not y?
        fallback()
      else
        if Math.floor(Math.random()*10) < 3 then fallback()
        else
          mp = @getPosition()
          direction = (
            if mp.x < x then 'r'
            else if mp.x > x then 'l'
            else if mp.y < y then 'd'
            else if mp.y > y then 'u')
          @walk(map, direction)