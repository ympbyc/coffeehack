messagelist_ja = {}

messagelist_ja.format = (str, args...) ->
  for variable in args
    str = str.replace('?', variable)
  str


messagelist_ja.trap = {
  stone : "頭上から石が落ちてきてあなたに当たった."
  hole : "足下で隠し扉が開いた."
  teleport : "おえっぷ、はきそう…"
}

messagelist_ja.player = {
  attack : "あなたの攻撃は?に当たった.",
}

messagelist_ja.monster = {
  attack : "?は?に?.",
}