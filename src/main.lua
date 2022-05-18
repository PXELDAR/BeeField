-----------------------------------------------------------------------------------

function love.load()
    love.window.setMode(1000, 768)

    _anim8 = require "libraries/anim8/anim8"
    _sti = require "libraries/SimpleTiledImplementation/sti"  
    _cameraFile = require "libraries/hump/camera"

    _camera = _cameraFile()
    
    _sounds = { }
    _sounds.jump = love.audio.newSource("audio/jump.wav", "static")
    _sounds.music = love.audio.newSource("audio/music.mp3", "stream")
    _sounds.music:setLooping(true)
    _sounds.music:setVolume(0.5)

    _sounds.music:play()

    _sprites = {}
    _sprites.playerSheet = love.graphics.newImage("assets/playerSheet.png")
    _sprites.enemySheet = love.graphics.newImage("assets/enemySheet.png")
    _sprites.backGround = love.graphics.newImage("assets/background.png")

    --Original width/height divided by columns & rows
    --(9210 / 15, 1692 / 3)
    local grid = _anim8.newGrid(614, 564, _sprites.playerSheet:getWidth(), _sprites.playerSheet:getHeight())
    
    --Original width/height divided by columns & rows
    --(200 / 2, 79 / 1) 
    local enemyGrid = _anim8.newGrid(100, 79, _sprites.enemySheet:getWidth(), _sprites.enemySheet:getHeight())

    _animations = {}
    _animations.idle = _anim8.newAnimation(grid("1-15", 1), 0.05) --column, row
    _animations.jump = _anim8.newAnimation(grid("1-7", 2), 0.05) --column, row
    _animations.run = _anim8.newAnimation(grid("1-15", 3), 0.05) --column, row
    _animations.enemy = _anim8.newAnimation(enemyGrid("1-2", 1), 0.03)

    _windField = require "libraries/windfield"
    _world = _windField.newWorld(0, 800, false)
    _world:setQueryDebugDrawing(true)

    _colliderKeys = {}
    _colliderKeys.platform = "Platform"
    _colliderKeys.player = "Player"
    _colliderKeys.danger = "Danger"
    _colliderKeys.flag = "Flag"

    _world:addCollisionClass(_colliderKeys.platform)
    _world:addCollisionClass(_colliderKeys.player --[[, {ignores = {"Platform"}}]])
    _world:addCollisionClass(_colliderKeys.danger)

    require("player")
    require("enemy")
    require("libraries/show")

    _dangerZone = _world:newRectangleCollider(-550, 800, 5000, 50, { collision_class = _colliderKeys.danger })
    _dangerZone:setType("static")

    _platforms = { }

    _flagX = 0
    _flagY = 0
    
    saveData = {}
    saveData.currentLevel = "levelOne"
    
    if (love.filesystem.getInfo("data.lua")) then
        local data = love.filesystem.load("data.lua")
        data()
    end

    loadMap(saveData.currentLevel)
end

-----------------------------------------------------------------------------------

function love.update(dt)
    _world:update(dt)
    _gameMap:update(dt)
    updatePlayer(dt)
    updateEnemies(dt)

    local playerX, playerY = _player:getPosition()
    _camera:lookAt(playerX, love.graphics.getHeight() / 2)

    local collders = _world:queryCircleArea(_flagX, _flagY, 10, {_colliderKeys.player})
    if (#collders > 0) then
        if (saveData.currentLevel == "levelOne") then
            loadMap("levelTwo")
        elseif (saveData.currentLevel == "levelTwo") then
            loadMap("levelOne")
        end
    end
end

-----------------------------------------------------------------------------------

function love.draw()
    love.graphics.draw(_sprites.backGround, 0, 0)

    _camera:attach()
        _gameMap:drawLayer(_gameMap.layers["platformTile"])
        _world:draw()
        drawPlayer()
        drawEnemies()
    _camera:detach()
end

-----------------------------------------------------------------------------------

function spawnPlatform(x, y, width, height)
    local _platform = _world:newRectangleCollider(x, y, width, height, { collision_class = _colliderKeys.platform })
    _platform:setType("static")
    table.insert(_platforms, _platform)
end

-----------------------------------------------------------------------------------

function destroyAll()
    local i = #_platforms
    while (i > -1) do
        if(_platforms[i] ~= nil) then
            _platforms[i]:destroy()
        end
        table.remove(_platforms, i)
        i = i - 1
    end

    local i = #_enemies
    while (i > -1) do
        if(_enemies[i] ~= nil) then
            _enemies[i]:destroy()
        end
        table.remove(_enemies, i)
        i = i - 1
    end
end

-----------------------------------------------------------------------------------

function loadMap(mapName)
    saveData.currentLevel = mapName
    love.filesystem.write("data.lua", table.show(saveData, "saveData"))    
    destroyAll()
    _gameMap = _sti("maps/"..mapName..".lua")

    for i, player in pairs(_gameMap.layers["player"].objects) do
        _playerStartX = player.x
        _playerStartY = player.y
    end

    _player:setPosition(_playerStartX, _playerStartY)

    for i, platform in pairs(_gameMap.layers["platform"].objects) do
        spawnPlatform(platform.x, platform.y, platform.width, platform.height)
    end

    for i, enemy in pairs(_gameMap.layers["enemy"].objects) do
        spawnEnemy(enemy.x, enemy.y, enemy.width, enemy.height)
    end

    for i, flag in pairs(_gameMap.layers["flag"].objects) do
        _flagX = flag.x
        _flagY = flag.y
    end
end

-----------------------------------------------------------------------------------
