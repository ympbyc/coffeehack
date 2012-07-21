class Inventory extends EventEmitter
  @validchars = ['a','b','c','d','e','f','g','h','i','j','k'] # ...

  constructor : ->
    super()
    @_inventory = {}
    @_charIndex = 0

  charIndexIncrement : (i=0, memoi=0) ->
    if i >= Inventory.validchars.length
      return @charIndexIncrement(0, memoi+1)
    else if not @getItem(Inventory.validchars[i])?
      return i
    else if memoi >= MAX_RECURSION = Inventory.validchars.length*2
      throw "inventory overflow"
      return i
    else return@charIndexIncrement(i+1, memoi+1)

  addItem : (item) ->
    try
      @_charIndex = @charIndexIncrement(@_charIndex)
    catch err
      @fire('inventoryfull') #does nothing
      return null
    cch = Inventory.validchars[@_charIndex]
    @_inventory[cch] = item
    cch

  getItem : (ch) ->
    @_inventory[ch]

  removeItem : (ch) ->
    tmp = @_inventory[ch]
    @_inventory[ch] = null
    tmp

  listItems : ->
    @_inventory