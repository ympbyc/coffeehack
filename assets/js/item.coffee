class Item
  constructor : (@name, @rareness, @dice, @message) ->

class Weapon extends Item
  constructor : (name, rareness, dice, message) ->
    super(name, rareness, dice, message)
