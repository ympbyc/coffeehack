messagelist = {}

messagelist.format = (str, args...) ->
  for variable in args
    str = str.replace('?', variable)
  str


messagelist.trap = {
  stone : "A stone fell from above. The stone hits you."
  hole : "A trap door opened under you."
  teleport : "You felt an urge to core dump."
}

messagelist.player = {
  attack : "You ? the ?.",
}

messagelist.monster = {
  attack : "the ? ? ?.",
}

CH.messagelist = messagelist