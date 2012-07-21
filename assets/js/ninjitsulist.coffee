#dependencie - instance of the Game class

ninjitsulist = [
  {
    name : 'jistu of healing',
    jitsu : ((game) ->
      game.player.hp = game.player.getMaxHP()),
    description : 'heals your hp to the maximum',
    message : 'You spelled the jitsu of healing. You are fully recovered.'
  },{
    name : 'jistu of superattack',
    jitsu : ((game) ->
      pp = game.player.getPosition()
      cells =  game.currentMap().getNearbyReservations(pp.x, pp.y)
      m.hp = 0 for m in cells when m? and m),
    description : 'kills all the enemies on your nearby cells',
    message : 'Your nearby cells are cleared out! Yahoo!'
  },{
    name : 'jitsu of hiding',
    jitsu : ((game) ->
      pp = game.player.getPosition()
      map = game.currentMap()
      map.clearReservation(pp.x, pp.y)
      ctr = 0
      game.on('turn', -> ctr++)
      game.fire('turn') for i in [0...20]
      (f = ->
        if ctr >= 20
          game.player.born(map)
        else
          setTimeout(f, 10)
      )()),
    description : 'hides for 20 turns and teleports',
    message : 'You hid for 20 turns.'
  },{
    name : 'jitsu of level teleport',
    jitsu : ((game) ->
      tolevel = Math.floor(Math.random() * game.level)
      if tolevel isnt game.level then game.fire('goup') for i in [game.level ... tolevel]
    ),
    description : 'Go back up to a random floor level',
    message : 'Some magical power pulled your pants up.'
  }
]