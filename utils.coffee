utils = {}
utils.dice = (n, x) ->
  n = n or 1
  x = x or 4
  p = 0
  p +=  Math.floor(Math.random()*(x-1)+1) for i in [1..n]
  p