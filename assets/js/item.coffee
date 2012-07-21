class hack.Item
  constructor : (@name, @rareness, @dice, @message) ->

class hack.Weapon extends hack.Item
  constructor : (name, rareness, dice, message) ->
    super(name, rareness, dice, message)
