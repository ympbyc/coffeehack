# dependencie - index.html

class hack.Tile
  CELL_SIZE = 16
  WIDTH = CELL_SIZE*25
  HEIGHT = CELL_SIZE*18

  loadImage = (n) ->
    img = new Image()
    img.src = './nhtiles/'+n+'.png'
    img

  @images = (->
    {
      map : {
        blank : loadImage(829),
        water : loadImage(860),
        room : loadImage(849),
        path : loadImage(850),
        wall_vert : loadImage(830),
        wall_horiz : loadImage(831),
        trap : loadImage(849),
        trap_active : loadImage(874),
        stair_up : loadImage(851),
        stair_down : loadImage(852),
        ninjitsu : loadImage(903)
      },
      weapon : {
        longsword : loadImage(431),
        katana : loadImage(433),
        stone : loadImage(822),
        mace : loadImage(450)
      },
      monster : {
        Ninja : loadImage(388),
        'grid bug' : loadImage(117),
        jackal : loadImage(12),
        newt : loadImage(326),
        goblin : loadImage(71),
        lichen : loadImage(159),
        kitten : loadImage(34),
        gnome : loadImage(166),
        dwarf : loadImage(45),
        rothe : loadImage(82),
        'fire ant' : loadImage(3),
        centaur : loadImage(131),
        unicorn : loadImage(102),
        'spotted jelly' : loadImage(58),
        'vampire bat' : loadImage(130),
        'barrow wight' : loadImage(231),
        'owl bear' : loadImage(237),
        gargoyle : loadImage(42),
        python : loadImage(219),
        'red naga' : loadImage(201),
        giant : loadImage(170),
        'green slime' : loadImage(211),
        troll : loadImage(221),
        'glass piercer' : loadImage(81),
        vampire : loadImage(227),
        'stone golem' : loadImage(259),
        jabberwock : loadImage(179),
        angel : loadImage(124),
        'red dragon' : loadImage(147),
        'Demogorgon' : loadImage(313)
      },
    }
  )()

  constructor : (cvid) ->
    @canvas = document.getElementById(cvid)
    @surface = @canvas.getContext('2d')
    @currentMapImage

  update : (x, y, type, name) ->
    #try
      @surface.drawImage(Tile.images[type][name], x*CELL_SIZE, y*CELL_SIZE)
    #catch e
     # alert(type + ' ' + name)

  toDataUrl : ->
    @currentMapImage = new Image()
    @currentMapImage.src = @canvas.toDataURL('image/png')

  resetWithMap : ->
    @surface.drawImage(@currentMapImage, 0, 0)
