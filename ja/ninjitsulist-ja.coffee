#dependencie - instance of the Game class

ninjitsulist_ja = [
  {
    name : '回復の術',
    jitsu : ((game) ->
      game.player.hp = game.player.getMaxHP()),
    description : 'HPを最大値まで回復する.',
    message : 'あなたは回復の術を使った。ピロリロリン♪ あなたのHPは回復した.'
  },{
    name : '超攻撃の術',
    jitsu : ((game) ->
      pp = game.player.getPosition()
      cells =  game.currentMap().getNearByCells(pp.x, pp.y)
      m.hp = 0 for m in cells when m? and m),
    description : '近接するマスにいる敵を全て倒す(経験値は入らない)',
    message : 'ボシュッ！あなたは軽い爆発を起こした。近接する敵はいなくなった.'
  },{
    name : '隠れ身の術',
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
    description : '20ターンの間、残像を残して身を隠し、ランダムな位置にテレポートする',
    message : 'あなたは20ターン身を隠した。馬鹿めそっちは残像だ！.'
  },{
    name : '階層跳躍の術',
    jitsu : ((game) ->
      tolevel = Math.floor(Math.random() * game.level)
      if tolevel isnt game.level then game.fire('goup') for i in [game.level ... tolevel]
    ),
    description : '予測不能な階まで戻る',
    message : '頭がくらくらする。あなたは階層跳躍を終えた..'
  }
]