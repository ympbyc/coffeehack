class hack.EventEmitter
  constructor : ->
    @listenerStack = []

  on : (type, listener) ->
    @listenerStack.push
      type    : type
      listener: listener

  off : (type, listener) ->
    @listenerStack = _.reject @listenerStack, (stack) => 
      (stack.type is type) and (stack.listener is listener)

  fire : (type, obj) ->
    for item in @listenerStack when item.type is type
      item.listener(obj)
