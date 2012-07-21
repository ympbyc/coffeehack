class hack.EventEmitter
  constructor : ->
    @listenerStack = []

  on : (type, listener) ->
    @listenerStack.push
      type    : type
      listener: listener

  off : (type, listener) ->
    for stack, i in @listenerStack when (stack?.type is type) and (stack?.listener is listener)
      @listenerStack[i] = undefined

  fire : (type, obj) ->
    for item in @listenerStack when item?.type is type
      item.listener(obj)
