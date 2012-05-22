commands =  if require? then require('commands') else window.commands
monsterlist =  if require? then require('monsterlist') else window.monsterlist
traplist = if require? then require('traplist') else window.traplist
ninjitsulist = if require? then require('ninjitsulist') else window.ninjitsulist

MAP_WIDTH = 40 #25
MAP_HEIGHT = 30 #18
MESSAGE_SIZE = 4

window.addEventListener('load', ->
  game = new Game()
  game.setPlayer(new Player('ympbyc', 'Samurai', 12))
  game.addMap(new Map(MAP_WIDTH, MAP_HEIGHT))
  game.nextMap()
  game.player.born(game.currentMap())
  tile = new Tile('ch-canvas')
  currentmonsterlist = (m for m in monsterlist when m[1] <= 1)
  message = [
    '',
    ' The following is written in a secret scroll you inherited from your ancestor.',
    '  "There once were mean dragons crawling all around us on the ground',
    '    In 1997 we have succeeded to lock them in the ancient underground dungeon at the centre of our town."',
    'Welcome to coffeehack. You are a neutral male ninja. Slay the dragons!']

  $(document).on('keypress', (e) ->
    keyChar = getKeyChar(e.which)
    direction = {'k' : 'u', 'j' : 'd', 'l' : 'r',  'h' : 'l'} #kjlh
    if direction[keyChar]
      game.player.walk(game.currentMap(),  direction[keyChar])

    if commands[keyChar]
      commands[keyChar](game)

    game.fire('turn')
  )

  game.on('turn', ->
    if (Math.random()*10 < 0.5 and game.countMonster() < 10)
      monster = new Monster(currentmonsterlist[a = Math.floor(Math.random()*currentmonsterlist.length)]...)
      console.log(a)
      monster.on('attack', (e) ->
        tgt = if e.enemy.name then 'You' else 'the ' + e.enemy.role
        action = if Math.round(Math.random()) then e.me.action else 'hits'
        game.fire('message', {message : messagelist.format(messagelist.monster.attack, e.me.role, action, tgt)})
      )
      game.addMonster(monster)
    game.moveAllMonsters()
    game.fire('turnend')
  )

  game.on('turnend', ->
    #document.getElementById('jshack').innerHTML = game.drawStage()
    updateCanvas(game.drawStage())
    status = [game.player.name, '@ floor -', game.level, '\n',
      'hp:', Math.floor(game.player.hp), '/', game.player.getMaxHP(), 'exp:', Math.floor(game.player.experience*10)*1/10, 'time:', game.time
    ].join(' ')
    game.fire('status', {status : status})
  )

  game.on('turnend', ->
    if message[MESSAGE_SIZE].length
      message.shift()
      document.getElementById('message').innerHTML = message.join('\n')
      message.push('')
  )

  game.on('godown', ->
    if not game.nextMap()
      game.addMap(new Map(MAP_WIDTH, MAP_HEIGHT))
      game.nextMap()
    game.player.born(game.currentMap())
  )
  game.on('godown', ->
    currentmonsterlist = (m for m in monsterlist when m[1] <= (((game.player.explevel or 1) + game.level)/2))
    console.log(currentmonsterlist)
  )
  game.on('goup', ->
    game.prevMap()
    game.player.born(game.currentMap())
  )
  game.on('goup', ->
    currentmonsterlist = (m for m in monsterlist when m[1] <= ((game.player.explevel + game.level)/2 or 1))
  )
  game.on('message', (e) ->
    message[MESSAGE_SIZE] += ' ' + e.message
  )

  game.on('status', (e) ->
    document.getElementById('status').innerHTML = e.status
  )

  game.player.on('attack', (e) ->
    mode = if e.enemy.isDead() then 'killed' else 'hit'
    game.fire('message', {message : messagelist.format(messagelist.player.attack, mode, e.enemy.role)})
  )

  game.player.on('move', (e) ->
    if [Map.TRAP, Map.TRAP_ACTIVE].indexOf(game.currentMap().getCell(e.position.x, e.position.y)) > -1
      pp = game.player.getPosition()
      game.currentMap().setCell(pp.x, pp.y, Map.TRAP_ACTIVE)
      traplist[Math.floor(Math.random()*traplist.length)](game)
  )

  game.player.on('move', (ev) ->
    if game.currentMap().getCell(ev.position.x, ev.position.y) is Map.ITEM
      ninjitsu = ninjitsulist[Math.floor(Math.random()*ninjitsulist.length)]
      game.fire('message', {message :"#{ ninjitsu.name} : #{ninjitsu.description}. spell? (y or anything else)"})
      listener = (e) ->
        document.removeEventListener('keypress', listener)
        if getKeyChar(e.keyCode) is 'y'
          ninjitsu.jitsu(game)
          game.fire('message', {message : ninjitsu.message})
          game.fire('turn')
          game.currentMap().setCell(ev.position.x, ev.position.y, Map.ROOM)
      document.addEventListener('keypress', listener)
  )
  game.player.on('explevelup', (e) ->
    game.fire('message', {message : "Welcome to experience level #{e.explevel}."})
  )

  prevmapstr = (for i in [0...MAP_WIDTH*MAP_HEIGHT]
    '0').join('')
  monstermap = {}
  for m in monsterlist
    monstermap[m[2]] = m[0]

  updateCanvas = (mapstr) ->
    mapstr = mapstr.replace(/\n/g, '')
    ptr = -1
    for i in [0...MAP_HEIGHT]
      for j in [0...MAP_WIDTH]
        ptr++;
        if prevmapstr[ptr] is mapstr[ptr] then continue
        cell = switch mapstr[ptr]
          when ' ' then ['map', 'blank']
          when '.' then ['map', 'room']
          when '#' then ['map', 'path']
          when '|' then ['map', 'wall_vert']
          when '-' then ['map', 'wall_horiz']
          when '^' then ['map', 'trap_active']
          when '<' then ['map', 'stair_up']
          when '>' then ['map', 'stair_down']
          when '*' then ['map', 'item']
          when '@' then ['monster', 'player']
          else
            ['monster', monstermap[mapstr[ptr]]]

        tile.update(j, i, cell[0], cell[1])

  game.fire('turn')
)

getKeyChar = (keyCode) ->
  keyChar = {
    62 : '>',
    60 : '<',
    107 : 'k',
    106 : 'j',
    108 : 'l',
    104 : 'h',
    38 : 'k',
    40 : 'j',
    39 : 'l',
    37 : 'h',
    46 : '.',
    121 : 'y',
    110 : 'n'
  }
  keyChar[keyCode]


unless Function::bind
  Function::bind = (oThis) ->
    throw new TypeError("Function.prototype.bind - what is trying to be bound is not callable")  if typeof this isnt "function"
    aArgs = Array::slice.call(arguments, 1)
    fToBind = this
    fNOP = ->

    fBound = ->
      fToBind.apply (if this instanceof fNOP then this else oThis or window), aArgs.concat(Array::slice.call(arguments))

    fNOP:: = @::
    fBound:: = new fNOP()
    fBound
