###
# main.js
# Handles all the user interaction, and bridges between classes.
# Other files should not depend on this file to work.
#
# The only file you have to modify when you port this project to a new environment is this.
# This version targets html5 web browsers.
#
# Newing classes should only happen in this file.
#
# dependencies - command.coffee, game.coffee, (index.html),
#                (lib/jquery), map.coffee, messagelist.coffee, monster.coffee,
#                monsterlist.coffee, (nhtiles/*.gif), ninjitsulist.coffee, player.coffee,
#                (tile.coffee), traplist.coffee, itemlist.coffee, item.coffee
###

MAP_WIDTH = 40
MAP_HEIGHT = 30
MAX_MONSTER = 10 #maximum number of monsters that can exist on the map
MESSAGE_SIZE = 4 #number of massages to save

main  = ->
  game = new Game()
  game.setPlayer(new Player('coffeedrinker', 'Ninja', 12))
  game.addMap(new Map(MAP_WIDTH, MAP_HEIGHT))
  game.nextMap()
  game.player.born(game.currentMap())
  tile = new Tile('ch-canvas') #set up the canvas element
  currentmonsterlist = (m for m in monsterlist when m[1] <= 1)
  message = [
    '',
    ' The following is written in a secret scroll you inherited from your ancestor.',
    '  "There once were mean dragons crawling all around us on the ground',
    '    In 1997 we have succeeded to lock them in the ancient underground dungeon at the centre of our town."',
    'Welcome to coffeehack. You are a neutral male ninja. Slay the dragons!']

  ## Use jQuery for cross-browser keyboard event handling.
  ## This should be replaced with a lighter function specialized for this occasion.
  $(document).on('keypress', (e) ->
#    console.log(e.which)
    keyChar = getKeyChar(e.which) #middleware wraps the keycode difference in each browser

    direction = {
      'k':'u', 'j':'d', 'l':'r',  'h':'l',
      'y':'ul', 'u':'ur', 'b':'ll', 'n':'lr'
    } #kjlh
    if direction[keyChar]
      game.player.walk(game.currentMap(),  direction[keyChar])

    if commands[keyChar]?
      f = commands[keyChar](game)
      game.fire('argumentrequest', {command : f}) if f? #for commands that take an argument

    game.fire('turn')
  )

  game.on('turn', ->
    ## 0.5 may well be too much, nedd more conideration
    if (Math.random()*10 < 0.5 and game.countMonster() < MAX_MONSTER)
      monster = new Monster(currentmonsterlist[utils.randomInt(currentmonsterlist.length)]...) # NETHACK LOGIC
      monster.on('attack', (e) ->
        tgt = if e.enemy.name then 'You' else 'the ' + e.enemy.role
        action = if Math.round(Math.random()) then e.me.action else 'hits'
        game.fire('message', {message : messagelist.format(messagelist.monster.attack, e.me.role, action, tgt)})
      )
      monster.on('die', (e) ->
        pos = e.beef.getPosition()
        weapon = new Weapon(items.weapons[utils.randomInt(items.weapons.length)]...)
        if weapon.rareness > utils.randomInt(100)
          game.addItem(pos.x, pos.y, weapon)
        else
          weapon = null
      )
      game.addMonster(monster)

    game.moveAllMonsters()
    game.fire('turnend')
  )

  game.on('turnend', ->
    #document.getElementById('jshack').innerHTML = game.drawStage() #activate when you want the text-mode
    updateObjects(game.drawObjects())
    status = [game.player.name, '@ floor -', game.level, '\n',
      'hp:', Math.floor(game.player.hp), '/', game.player.getMaxHP(), 'exp:', Math.floor(game.player.experience*10)*1/10, 'time:', game.time, 'score:', game.score
    ].join(' ')
    game.fire('status', {status : status}) #writes out the status line at the botttom
  )

  game.on('turnend', ->
    if message[MESSAGE_SIZE].length
      message.shift()
      document.getElementById('message').innerHTML = message.join('\n')
      message.push('')
  )

  game.on('godown', ->
    if not game.nextMap() #false when there is no map deeper than the current
      game.addMap(new Map(MAP_WIDTH, MAP_HEIGHT))
      game.nextMap()
    game.player.born(game.currentMap())
    game.fire('mapchange')
  )
  game.on('godown', ->
    currentmonsterlist = (m for m in monsterlist when m[1] <= (((game.player.explevel or 1) + game.level)/2)) #NETHACK LOGIC
    console.log(currentmonsterlist)
  )
  game.on('goup', ->
    game.prevMap()
    game.player.born(game.currentMap())
    game.fire('mapchange')
  )
  game.on('goup', ->
    currentmonsterlist = (m for m in monsterlist when m[1] <= ((game.player.explevel + game.level)/2 or 1)) #NETHACK LOGIC
  )
  game.on('message', (e) ->
    message[MESSAGE_SIZE] += ' ' + e.message
  )

  game.on('status', (e) ->
    document.getElementById('status').innerHTML = e.status
  )

  game.on('argumentrequest', (e) ->
    listener = (ev) ->
      document.removeEventListener('keypress', listener)
      e.command(getKeyChar(ev.keyCode))
    document.addEventListener('keypress', listener)
  )

  game.player.on('attack', (e) ->
    mode = if e.enemy.isDead() then 'killed' else 'hit'
    game.fire('message', {message : messagelist.format(messagelist.player.attack, mode, e.enemy.role)})
  )

  game.player.on('move', (e) ->
    if [Map.TRAP, Map.TRAP_ACTIVE].indexOf(game.currentMap().getCell(e.position.x, e.position.y)) > -1
      pp = game.player.getPosition()
      game.currentMap().setCell(pp.x, pp.y, Map.TRAP_ACTIVE)
      game.fire('mapchange')
      traplist[utils.randomInt(traplist.length)](game) #trap type is decided randomly on the fly
  )

  game.player.on('move', (ev) ->
    if game.currentMap().getCell(ev.position.x, ev.position.y) is Map.NINJITSU
      ninjitsu = ninjitsulist[utils.randomInt(ninjitsulist.length)] #ninjutsus, too decided randomly
      game.fire('message', {message :"#{ ninjitsu.name} : #{ninjitsu.description}. spell? (y or anything else)"})
      listener = (e) ->
        document.removeEventListener('keypress', listener)
        if getKeyChar(e.keyCode) is 'y'
          ninjitsu.jitsu(game)
          game.fire('message', {message : ninjitsu.message})
          game.currentMap().setCell(ev.position.x, ev.position.y, Map.FLOOR)
          game.fire('mapchange')
          game.fire('turn')

      document.addEventListener('keypress', listener)
  )
  game.player.on('explevelup', (e) ->
    game.score += 100
    game.fire('message', {message : "Welcome to experience level #{e.explevel}."})
  )
  game.player.on('killedanenemy', ->
    game.score += 100
  )

  prevmapstr = (for i in [0...MAP_WIDTH*MAP_HEIGHT]
    '0').join('')

  game.on('mapchange', ->
    updateCanvasMap(game.currentMap().show())
  )

  updateCanvasMap = (mapstr) ->
    mapstr = mapstr.replace(/\n/g, '')
    ptr = -1
    for i in [0...MAP_HEIGHT]
      for j in [0...MAP_WIDTH]
        ptr++;
        if prevmapstr[ptr] is mapstr[ptr] then continue
        cell = switch mapstr[ptr]
          when ' ' then ['map', 'blank']
          when '~' then ['map', 'water']
          when '.' then ['map', 'room']
          when '#' then ['map', 'path']
          when '|' then ['map', 'wall_vert']
          when '-' then ['map', 'wall_horiz']
          when '^' then ['map', 'trap_active']
          when '<' then ['map', 'stair_up']
          when '>' then ['map', 'stair_down']
          when '*' then ['map', 'ninjitsu']
        tile.update(j, i, cell[0], cell[1])
    tile.toDataUrl()

   updateObjects = (objectLayer) ->
      tile.resetWithMap()
      for i,row of objectLayer
        for j, cell of row
          if cell instanceof Player
            tile.update(j, i, 'monster', cell.role)
          else if cell instanceof Weapon
            tile.update(j, i, 'weapon', cell.name)

  updateCanvasMap(game.currentMap().show())
  game.fire('turn')

getKeyChar = (keyCode) ->
  String.fromCharCode(keyCode)

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


#window.addEventListener('load', main)
