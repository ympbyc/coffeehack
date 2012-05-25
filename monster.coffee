###
# monster.coffeee
# Monsters are players, with an extended method walk.
# They are designed to chase "the player" and attack them
#
# dependencie - player.coffee, utils.coffee
###

  class Monster extends Player
    constructor : (@role, @difficulty, @char, @explevel, @gainExp, @action, @dice) ->
      hp = utils.dice(@explevel, 8) # NETHACK LOGIC
      super(null, @role, hp, @explevel, @gainExp, @dice)

    ## Chase "the player" when it can. Otherwise walk a random direction.
    #
    move : (map, x, y) ->
      fallback = (->
        table = ['u', 'd', 'r', 'l']
        @walk(map, table[Math.floor(Math.random()*4)])).bind(@)
      if not x? or not y?
        fallback()
      else
        if Math.floor(Math.random()*10) < 2 then fallback()
        else
          mp = @getPosition()
          direction = (
            if mp.x < x and map.isAttackable(mp.x+1, mp.y) then 'r'
            else if mp.x > x and map.isAttackable(mp.x-1, mp.y) then 'l'
            else if mp.y < y and map.isAttackable(mp.x, mp.y+1) then 'd'
            else if mp.y > y and map.isAttackable(mp.x, mp.y-1) then 'u'
            else false)
          if direction then @walk(map, direction)
          else fallback()
