hack.messagelist = {}

hack.messagelist.format = (str, args...) ->
  for variable in args
    str = str.replace('?', variable)
  str


hack.messagelist.trap = {
  stone : "A stone fell from above. The stone hits you."
  hole : "A trap door opened under you."
  teleport : "You felt an urge to core dump."
}

hack.messagelist.player = {
  attack : "You ? the ?.",
}

hack.messagelist.monster = {
  attack : "the ? ? ?.",
}
