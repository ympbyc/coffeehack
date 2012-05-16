commands =  if require? then require('commands') else window.commands
monsterlist =  if require? then require('monsterlist') else window.monsterlist

window.addEventListener('load', ->
  game = new Game()
  game.setPlayer(new Player('ympbyc', 'Samurai', 12))
  game.addMap(new Map(80, 30))
  game.nextMap()
  game.player.born(game.currentMap())

  message = ' '

  document.addEventListener('keypress', (e) ->
    direction = {107 : 'u', 106 : 'd', 108 : 'r',  104 : 'l'} #kjlh
    if direction[e.keyCode]
      game.player.walk(game.currentMap(),  direction[e.keyCode])

    if commands[e.keyCode]
      commands[e.keyCode](game)

    game.fire('turn')
  )

  game.on('turn', ->
    if (Math.random()*10 < 0.5)
      monster = new Monster(monsterlist[Math.floor(Math.random()*monsterlist.length)]...)
      monster.on('attack', ((e) ->
        tgt = if e.enemy.name then 'You' else 'the ' + e.enemy.role
        action = if Math.round(Math.random()) then e.me.action else 'hits'
        @fire('message', {message : ['the', e.me.role, action, tgt+'.'].join(' ')})
      ).bind(@))
      game.addMonster(monster)
    game.moveAllMonsters()
    game.fire('turnend')
  )

  game.on('turnend', ->
    document.getElementById('jshack').innerHTML = game.drawStage()
    status = [game.player.name, '@ level', game.level, '\n',
      'hp:', game.player.hp, '/', game.player.getMaxHP(), 'exp:', game.player.experience, 'time:', game.time
    ].join(' ')
    game.fire('status', {status : status})
  )

  game.on('turnend', ->
    document.getElementById('message').innerHTML = message
    message = ' '
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
    message += ' ' + e.message
  )

  game.on('status', (e) ->
    document.getElementById('status').innerHTML = e.status
  )

  game.player.on('attack', ((e) ->
    mode = if e.enemy.isDead() then 'You killed the ' else 'You hit the '
      @fire('message', {message : mode + e.enemy.role + '.'})
  ).bind(@))
)