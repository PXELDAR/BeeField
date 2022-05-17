-----------------------------------------------------------------------------------

function love.load()
    love.window.setMode(1000, 768)

    _anim8 = require "libraries/anim8/anim8"
    _sti = require "libraries/SimpleTiledImplementation/sti"  
    _cameraFile = require "libraries/hump/camera"

    _camera = _cameraFile()
    
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

    -- _dangerZone = _world:newRectangleCollider(0, 550, 800, 50, { collision_class = _colliderKeys.danger })
    -- _dangerZone:setType("static")

    _platforms = { }

    loadMap()
end

-----------------------------------------------------------------------------------

function love.update(dt)
    _world:update(dt)
    _gameMap:update(dt)
    playerUpdate(dt)
end

-----------------------------------------------------------------------------------

function love.draw()
    _gameMap:drawLayer(_gameMap.layers["platformTile"])
    _world:draw()
    drawPlayer()
end

-----------------------------------------------------------------------------------

function spawnPlatform(x, y, width, height)
    local _platform = _world:newRectangleCollider(x, y, width, height, { collision_class = _colliderKeys.platform })
    _platform:setType("static")
    table.insert(_platforms, _platform)
end

-----------------------------------------------------------------------------------

function loadMap()
    _gameMap = _sti("maps/levelOne.lua")

    for i, platform in pairs(_gameMap.layers["platformCollider"].objects) do
        spawnPlatform(platform.x, platform.y, platform.width, platform.height)
    end
end

-----------------------------------------------------------------------------------
