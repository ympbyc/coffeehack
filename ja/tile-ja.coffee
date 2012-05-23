# dependencie - index.html

class TileJa
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
        'グリッドバグ' : loadImage(117),
        'ジャッカル' : loadImage(12),
        'ヤモリ' : loadImage(326),
        'ゴブリン' : loadImage(71),
        '苔の怪物' : loadImage(159),
        '仔猫' : loadImage(34),
        'ノーム' : loadImage(166),
        'ドワーフ' : loadImage(45),
        'ロゼ' : loadImage(82),
        '火蟻' : loadImage(3),
        'セントール' : loadImage(131),
        '灰色ユニコーン' : loadImage(102),
        'まだらゼリー' : loadImage(58),
        '吸血コウモリ' : loadImage(130),
        'バロウワイト' : loadImage(231),
        'オウルベア' : loadImage(237),
        'ガーゴイル' : loadImage(42),
        'ニシキヘビ' : loadImage(219),
        '赤ナーガ' : loadImage(201),
        '巨人' : loadImage(170),
        '緑スライム' : loadImage(211),
        'トロル' : loadImage(221),
        'ガラス喰い' : loadImage(81),
        '吸血鬼' : loadImage(227),
        '石のゴーレム' : loadImage(259),
        'ジャバウォック' : loadImage(179),
        '天使' : loadImage(124),
        '赤ドラゴン' : loadImage(147),
        'デモゴルゴン' : loadImage(313)
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