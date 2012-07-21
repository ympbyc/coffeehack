#= require game

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

{
  messagelist, monsterlist, commands, items, ninjitsulist, traplist
  Player, Monster
  Item, Weapon
  Map
  utils
} = hack

MAP_WIDTH = 40
MAP_HEIGHT = 30
MAX_MONSTER = 10 #maximum number of monsters that can exist on the map
MESSAGE_SIZE = 4 #number of massages to save

main  = ->
  game = new hack.Game()
  game.setPlayer(new hack.Player('coffeedrinker', 'Ninja', 12))
  game.addMap(new hack.Map(MAP_WIDTH, MAP_HEIGHT))
  game.nextMap()
  game.player.born(game.currentMap())
  tile = new hack.Tile('ch-canvas') #set up the canvas element
  currentmonsterlist = (m for m in monsterlist when m[1] <= 1)

  message = [
    '',
    '',
    '',
    '',
    'Welcome to coffeehack. You are a neutral male ninja. Slay the dragons!']

  ## Use jQuery for cross-browser keyboard event handling.

  $document = $(document)

  ###
  # This is the main game loop of coffeehack.
  # This gets called every time the user hits a key.
  # Execution of the user's action take place before anything else happens.
  # After that, the turn emits.
  ###
  $document.bind('keypress', mainlistener = (e) ->
    keyChar = getKeyChar(e.which) #middleware wraps the keycode difference in each browser

    #map directional key to direction string for player.walk
    direction = {
      'k':'u', 'j':'d', 'l':'r',  'h':'l',
      'y':'ul', 'u':'ur', 'b':'ll', 'n':'lr'
    }
    if direction[keyChar]
      game.player.walk(game.currentMap(),  direction[keyChar])

    if commands[keyChar]?
      f = commands[keyChar](game)
      game.fire('argumentrequest', {command : f}) if f? #for commands that take an argument

    game.fire('turn')
  )

  ###
  # Manipulation of monsters occur after the player has done his action.
  ###
  game.on('turn', ->
    # add a monster
    if (Math.random()*10 < 0.5 and game.countMonster() < MAX_MONSTER)
      monster = new Monster(currentmonsterlist[utils.randomInt(currentmonsterlist.length)]...) # NETHACK LOGIC
      monster.on('attack', (e) ->
        tgt = if e.enemy.name then 'You' else 'the ' + e.enemy.role
        action = if Math.round(Math.random()) then e.me.action else 'hits'
        game.fire('message', {message : messagelist.format(messagelist.monster.attack, e.me.role, action, tgt)})
      )
      # monsters occasionaly drop weapons
      monster.on('die', (e) ->
        pos = e.beef.getPosition()
        weapon = new Weapon(items.weapons[utils.randomInt(items.weapons.length)]...)
        if weapon.rareness > utils.randomInt(100)
          game.addItem(pos.x, pos.y, weapon)
        else
          weapon = null
      )
      game.addMonster(monster)

    game.moveAllMonsters() #call move method on each monster
    game.fire('turnend')
  )

  ###
  # Update the screen when the turn ends.
  ###
  game.on('turnend', ->
    #document.getElementById('jshack').innerHTML = game.drawStage() #activate when you want the text-mode
    updateObjects(game.drawObjects()) # update the object layer to reflect current state
    status = "#{game.player.name} @ floor - #{game.level} \n
 hp: #{Math.floor(game.player.hp)} / #{game.player.getMaxHP()} exp: #{Math.floor(game.player.experience*10)*1/10} time: #{game.time} score: #{game.score}"
    game.fire('status', {status : status}) #writes out the status line at the botttom of the screen
  )

  ###
  # Update the message area if anything interesting happened on this turn
  ###
  game.on('turnend', ->
    if message[MESSAGE_SIZE].length
      message.shift()
      $('#message').html(message.join('\n'))
      message.push('')
  )

  ###
  # This event fires when the player hit '>' key on downward staircases.
  # This listener gives birth to the player on the next level.
  # A new floor has to be generated if the player hasn't been to that level.
  ###
  game.on('godown', ->
    if not game.nextMap() #false when there is no map deeper than the current
      game.addMap(new Map(MAP_WIDTH, MAP_HEIGHT))
      game.nextMap()
    map = game.currentMap()
    game.player.born(map, map.stair_pos_up)
    game.fire('mapchange')
  )

  ###
  # The variation of monsters that appear in a level increases as the player goes deeper.
  ###
  game.on('godown', ->
    currentmonsterlist = (m for m in monsterlist when m[1] <= (((game.player.explevel or 1) + game.level)/2)) #NETHACK LOGIC
    console.log(currentmonsterlist)
  )

  ###
  # reversed 'godown'
  ###
  game.on('goup', ->
    game.prevMap()
    map = game.currentMap()
    game.player.born(map, map.stair_pos_down)
    game.fire('mapchange')
  )
  game.on('goup', ->
    currentmonsterlist = (m for m in monsterlist when m[1] <= ((game.player.explevel + game.level)/2 or 1)) #NETHACK LOGIC
  )

  ###
  # Messages that are generated as a result of specific events
  # are acumurated here till the end of the turn
  ###
  game.on('message', (e) ->
    message[MESSAGE_SIZE] += ' ' + e.message
  )


  game.on('status', (e) ->
    $('#status').html(e.status)
  )

  ###
  # commands such as 'w'(wield) take an argument.
  # These commands are difined as higher order functions
  # and returns an anonymous function that take a charactor as its argument.
  # This listener is responsible for feeding the user input to this anonymous function
  ###
  game.on('argumentrequest', (e) ->
    $document.unbind('keypress', mainlistener)
    listener = (ev) ->
      $document.unbind('keypress', listener)
      $document.bind('keypress', mainlistener)
      e.command(getKeyChar(ev.keyCode))
    $document.bind('keypress', listener)
  )

  ###
  # Fires a message on an attack
  ###
  game.player.on('attack', (e) ->
    mode = if e.enemy.isDead() then 'killed' else 'hit'
    game.fire('message', {message : messagelist.format(messagelist.player.attack, mode, e.enemy.role)})
  )

  ###
  # Traps are functions that take the instence of the game.
  # Which type of trap to be activated is decided on the fly each time the player come across it
  ###
  game.player.on('move', (e) ->
    if [Map.TRAP, Map.TRAP_ACTIVE].indexOf(game.currentMap().getCell(e.position.x, e.position.y)) > -1
      pp = game.player.getPosition()
      game.currentMap().setCell(pp.x, pp.y, Map.TRAP_ACTIVE)
      game.fire('mapchange')
      traplist[utils.randomInt(traplist.length)](game) #trap type is decided randomly on the fly
  )

  ###
  # Same applies to ninjitsu fields
  ###
  game.player.on('move', (ev) ->
    if game.currentMap().getCell(ev.position.x, ev.position.y) is Map.NINJITSU
      ninjitsu = ninjitsulist[utils.randomInt(ninjitsulist.length)] #ninjutsus, too decided randomly
      game.fire('message', {message :"#{ ninjitsu.name} : #{ninjitsu.description}. spell? (y or anything else)"})

      listener = (e) ->
        $document.unbind('keypress', listener)
        $document.bind('keypress', mainlistener) #enable main eventlistener
        if getKeyChar(e.keyCode) is 'y'
          ninjitsu.jitsu(game)
          game.fire('message', {message : ninjitsu.message})
          game.currentMap().setCell(ev.position.x, ev.position.y, Map.FLOOR)
          game.fire('mapchange')
          game.fire('turn')

      $document.unbind('keypress', mainlistener) #disable main eventlistener
      $document.bind('keypress', listener)
  )

  ###
  # Fire a message on experience-level-ups
  ###
  game.player.on('explevelup', (e) ->
    game.score += 100
    game.fire('message', {message : "Welcome to experience level #{e.explevel}."})
  )
  ###
  # Give a score on each kill
  ###
  game.player.on('killedanenemy', ->
    game.score += 100
  )

  # constant
  prevmapstr = (for i in [0...MAP_WIDTH*MAP_HEIGHT]
    '0').join('')

  ###
  # Update the map only when some changes happen
  ###
  game.on('mapchange', ->
    updateCanvasMap(game.currentMap().show())
  )

  ###
  # Translate the map represented in rogue characters to graphical tiles
  ###
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

###
# Get character from keycode
###
getKeyChar = (keyCode) ->
  String.fromCharCode(keyCode)

$(window).bind('load', main)
