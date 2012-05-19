class Tile
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
        blank : loadImage(861),
        room : loadImage(849),
        path : loadImage(850),
        wall_vert : loadImage(830),
        wall_horiz : loadImage(831),
        trap : loadImage(849),
        trap_active : loadImage(874),
        stair_up : loadImage(851),
        stair_down : loadImage(852),
        item : loadImage(903)
      },
      monster : {
        player : loadImage(388),
        lichen : loadImage(159),
        'grid bug' : loadImage(117),
        newt : loadImage(326),
        jackal : loadImage(12),
        dragon : loadImage(147)
      },
    }
  )()

  constructor : (cvid) ->
    @surface = document.getElementById(cvid).getContext('2d')

  update : (x, y, type, name) ->
    try
      @surface.drawImage(Tile.images[type][name], x*CELL_SIZE, y*CELL_SIZE)
    catch e
      alert(type + ' ' + name)