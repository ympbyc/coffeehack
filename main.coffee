window.addEventListener('load', ->
  game = new Game()
  game.setPlayer(new Player('ympbyc', 'Samurai'))
  game.addMap(new Map(80, 30))
  map = game.nextMap()
  game.player.born(map)

  document.addEventListener('keydown', (e) ->
    direction = {75 : 'u', 74 : 'd', 76 : 'r',  72 : 'l'}
    if direction[e.keyCode]
      game.player.walk(map, direction[e.keyCode])
      game.fire('turn')
  )

  game.on('turn', ->
    game.addMonster(new Monster('grid bug', 5, 'x')) if (Math.random()*10 < 2)
    game.moveAllMonsters()
    game.fire('turnend')
  )

  game.on('turnend', ->
    document.getElementById('jshack').innerHTML = game.drawStage()
  )
)