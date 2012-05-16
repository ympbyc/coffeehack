commands =  if require? then require('commands') else window.commands

window.addEventListener('load', ->
  game = new Game()
  game.setPlayer(new Player('ympbyc', 'Samurai', 20))
  game.addMap(new Map(80, 30))
  game.nextMap()
  game.player.born(game.currentMap())

  document.addEventListener('keypress', (e) ->
    direction = {107 : 'u', 106 : 'd', 108 : 'r',  104 : 'l'} #kjlh
    if direction[e.keyCode]
      game.player.walk(game.currentMap(),  direction[e.keyCode])

    if commands[e.keyCode]
      commands[e.keyCode](game)

    game.fire('turn')
  )

  game.on('turn', ->
    game.addMonster(new Monster('grid bug', 5, 'x')) if (Math.random()*10 < 0.5)
    game.moveAllMonsters()
    game.fire('turnend')
  )

  game.on('turnend', ->
    document.getElementById('jshack').innerHTML = game.drawStage()
  )

  game.on('godown', ->
    game.addMap(new Map(80, 30))
    game.nextMap()
    game.player.born(game.currentMap())
  )
  game.on('goup', ->
    game.prevMap()
    game.player.born(game.currentMap())
  )

  game.on('message', (e) ->
    document.getElementById('message').innerHTML = e.message
  )

  game.on('status', (e) ->
    document.getElementById('status').innerHTML = e.status
  )

)