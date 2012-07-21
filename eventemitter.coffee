class EventEmitter
  constructor : ->
    @listenerStack = []

  on : (type, listener) ->
    @listenerStack.push({type:type, listener:listener})

  off : (type, listener) ->
    for i in [0 ... @listenerStack.length]
      @listenerStack[i] = undefined if @listenerStack[i] and @listenerStack[i].type is type and @listenerStack[i].listener is listener

  fire : (type, obj) ->
    for item in @listenerStack
      item.listener(obj) if item and item.type is type

CH.EventEmitter = EventEmitter