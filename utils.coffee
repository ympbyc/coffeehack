utils = {}
utils.randomInt = (max) ->
  Math.floor(Math.random()*max)

utils.dice = (n, x) ->
  n = n or 1
  x = x or 4
  p = 0
  p +=  utils.randomInt((x-1)+1) for i in [1..n]
  p

CH.utils = utils