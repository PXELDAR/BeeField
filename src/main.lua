-----------------------------------------------------------------------------------

function love.load()
    _anim8 = require "libraries/anim8/anim8"

    _sprites = {}
    _sprites.playerSheet = love.graphics.newImage("assets/playerSheet.png")

    --Original width/height divided by columns & rows
    --(9210 / 15, 1692 / 3)
    local grid = _anim8.newGrid(614, 564, _sprites.playerSheet:getWidth(), _sprites.playerSheet:getHeight())

    _animations = {}
    _animations.idle = _anim8.newAnimation(grid("1-15", 1), 0.05) --column, row
    _animations.jump = _anim8.newAnimation(grid("1-7", 2), 0.05) --column, row
    _animations.run = _anim8.newAnimation(grid("1-15", 3), 0.05) --column, row

    _windField = require "libraries/windfield"
    _world = _windField.newWorld(0, 800, false)
    _world:setQueryDebugDrawing(true)

    _colliderKeys = {}
    _colliderKeys.platform = "Platform"
    _colliderKeys.player = "Player"
    _colliderKeys.danger = "Danger"

    _world:addCollisionClass(_colliderKeys.platform)
    _world:addCollisionClass(_colliderKeys.player --[[, {ignores = {"Platform"}}]])
    _world:addCollisionClass(_colliderKeys.danger)

    require("player")

    _platform = _world:newRectangleCollider(250, 400, 300, 100, { collision_class = _colliderKeys.platform })
    _platform:setType("static")

    _dangerZone = _world:newRectangleCollider(0, 550, 800, 50, { collision_class = _colliderKeys.danger })
    _dangerZone:setType("static")

    _controls = {}
    _controls.up = "w"
    _controls.down = "s"
    _controls.left = "a"
    _controls.right = "d"
end

-----------------------------------------------------------------------------------

function love.update(dt)
    _world:update(dt)
    playerUpdate(dt)
end

-----------------------------------------------------------------------------------

function love.draw()
    _world:draw()
    drawPlayer()
end

-----------------------------------------------------------------------------------

