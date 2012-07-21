hack.utils = utils = {}

utils.randomInt = (max) ->
  Math.floor(Math.random()*max)

utils.dice = (n = 1, x = 4) ->
  nums = (utils.randomInt(x) for i in [1..n])
  _.foldl nums, ((m, n) -> m + n), 0
