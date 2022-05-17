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

    _player = _world:newRectangleCollider(360, 100, 40, 100, { collision_class = _colliderKeys.player })
    _player:setFixedRotation(true)
    _player.speed = 240
    _player.animation = _animations.idle
    _player.isMoving = false
    _player.direction = 1

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

    if (_player.body) then
        movePlayer(dt)
        checkAnimationState()
        animatePlayer(dt)
        checkPlayerCollision()
    end
end

-----------------------------------------------------------------------------------

function love.draw()
    _world:draw()

    local playerX, playerY = _player:getPosition()
    _player.animation:draw(_sprites.playerSheet, playerX, playerY, nil, 0.25 * _player.direction , 0.25, 130, 300)
end

-----------------------------------------------------------------------------------

function movePlayer(dt)
    _player.isMoving = false

    local playerX, playerY = _player:getPosition()
        
    if (love.keyboard.isDown(_controls.right)) then
        _player:setX(playerX + _player.speed * dt)
        _player.isMoving = true
        _player.direction = 1
    end
    if (love.keyboard.isDown(_controls.left)) then
        _player:setX(playerX - _player.speed * dt)
        _player.isMoving = true
        _player.direction = -1
    end
end

-----------------------------------------------------------------------------------

function checkPlayerCollision()
    if _player:enter((_colliderKeys.danger)) then
        _player:destroy()
    end
end

-----------------------------------------------------------------------------------

function checkAnimationState()
    if(_player.isMoving) then
        _player.animation = _animations.run
    else
        _player.animation = _animations.idle
    end
end

-----------------------------------------------------------------------------------

function animatePlayer(dt)
    _player.animation:update(dt)
end

-----------------------------------------------------------------------------------

function love.keypressed(key)
    if (key ==_controls.up) then
        local colliders = _world:queryRectangleArea(_player:getX() - 20, _player:getY() + 50, 40, 5, { _colliderKeys.platform })
        
        if (#colliders > 0) then
            _player:applyLinearImpulse(0, -4000)
        end
    end
end

-----------------------------------------------------------------------------------
