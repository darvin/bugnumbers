class GameObject
  constructor: (@node, @world, @x, @y) ->
    @world.addObject(this)


class Command extends GameObject
  constructor: (@node, @world, @x, @y, @cmd) ->
    @endurance = 100
    super @node @world, @x, @y

class Player extends GameObject
  constructor: (@node, @world, @x, @y, @name, @image) ->
    @dir = new Direction "n"
    console.log @world
    super @node, @world, @x, @y

  move: (dir, num) ->
    @dir = new Direction dir
    [x, y] = @dir.getCoordOffset(@x, @y, num)
    @goto x, y


  goto: (x, y) ->
    console.log "old coords #{@x}, #{@y} new coords #{x}, #{y}"
    [@x, @y] = [x, y]


class Robot extends GameObject
  constructor: (@node, @world, @x, @y, @direction) ->
    @memory = []
    @pointer = 0
    super @node, @world, @x, @y

  step: () ->
    [x, y] = @direction.getForward @x, @y
    @goto x, y
    for command in @world.getObjects x, y when command is Command
      @executeCommand command

  goto: (x, y) ->
    [@x, @y] = [x, y]


  turnLeft: () ->
    @direction.turnLeft()

  turnRight: () ->
    @direction.turnRight()

  pointerDec: () ->
    @pointer--
  
  pointerInc: () ->
    @pointer++


  regDec: () ->
    @memory[@pointer]--
  
  regInc: () ->
    @memory[@pointer]++

  putchar: () ->
    #fixme
    console.log @memory[@pointer]

  cycle: (start, command) ->
    stack = []
    cycle_closure: (start, command) ->
      if start
        stack.push command
      else
        start_command = stack.pop
        @goto(command.x, command.y)
    return cycle_closure start, command

  executeCommand: (command) ->
    switch command.cmd
      when '<' then @pointerDec()
      when '>' then @pointerInc()
      when '+' then @regInc()
      when '-' then @regDec()
      when '.' then @putchar()
      when ',' then @getchar(command.x, command.y)
      when 'R' then @turnRight()
      when 'L' then @turnLeft()
      when '[' then @cycle(true, command)
      when ']' then @cycle(false, command)

  interactObject: (obj) ->
    if obj is Command
      @executeCommand(obj)

class Direction
  constructor: (@dir) ->

  dirOrder: ['n', 'e', 's', 'w']

  turnLeft: () ->
    return @turn(-1)

  turnRight: () ->
    return @turn(1)


  turn: (num) ->
    for d in [0..this.dirOrder.length-1]
      if @dir==this.dirOrder[d]
        if (0<=d+num<this.dirOrder.length)
          newnum = d+num
        else
          if d+num < 0
            newnum = this.dirOrder.length-1
          if d+num >= this.dirOrder.length
            newnum = 0
        @dir = this.dirOrder[newnum]
        return this

  getCoordOffset: (x, y, num) ->
    switch @dir
      when 'n' then [x, y+num]
      when 'e' then [x-num, y]
      when 's' then [x, y-num]
      when 'w' then [x+num, y]
      else print "coord offset error"

  getForward: (x, y) ->
    return @getCoordOffset(x,y, 1)



class World
  constructor: (@name) ->
    @objects = []

  addObject: (object) ->
    @objects.push(object)

  getObjects: (x, y) ->
    [obj if obj.x==x and obj.y==y for obj in @objects]






PLAYGROUND_HEIGHT = 250
PLAYGROUND_WIDTH = 700


my_world = new World "some world"

jQuery($ ->

  $("#playground").playground({height: PLAYGROUND_HEIGHT, width: PLAYGROUND_WIDTH, keyTracker: true})


  $.playground().addGroup("background", {width: PLAYGROUND_WIDTH, height: PLAYGROUND_HEIGHT})
  $.playground().addGroup("fields", {width: PLAYGROUND_WIDTH, height: PLAYGROUND_HEIGHT})
  $.playground().addGroup("commands", {width: PLAYGROUND_WIDTH, height: PLAYGROUND_HEIGHT})
  $.playground().addGroup("letters", {width: PLAYGROUND_WIDTH, height: PLAYGROUND_HEIGHT})

  player_animation = {}
  player_animation["idle"] = new $.gameQuery.Animation {imageURL: "img/baddie.svg"}


  $.playground().addGroup("actors", {width: PLAYGROUND_WIDTH, height: PLAYGROUND_HEIGHT}).addGroup("player", {posx: PLAYGROUND_WIDTH/2, posy: PLAYGROUND_HEIGHT/2, width: 100, height: 26}).addSprite("playerBody",{animation: player_animation["idle"], posx: 0, posy: 0, width: 100, height: 26})

        
  $("#player")[0].player = new Player($("#player"), my_world, 0,0, 'darvi', 'buddy.svg')
  $.playground().registerCallback(->
    if(jQuery.gameQuery.keyTracker[65]) #this is left! (a)
      $("#player")[0].player.move('e',1)
    if(jQuery.gameQuery.keyTracker[68]) #this is right! (d)
      $("#player")[0].player.move('w',1)
    if(jQuery.gameQuery.keyTracker[87]) #this is up! (w)
      $("#player")[0].player.move('n',1)
    if(jQuery.gameQuery.keyTracker[83]) #this is down! (s)
      $("#player")[0].player.move('s',1)
  , 30)
  $.playground().startGame()
)



