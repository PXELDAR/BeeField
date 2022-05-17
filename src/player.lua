-----------------------------------------------------------------------------------

_player = _world:newRectangleCollider(360, 100, 40, 100, { collision_class = _colliderKeys.player })
_player:setFixedRotation(true)
_player.speed = 240
_player.animation = _animations.idle
_player.isMoving = false
_player.grounded = true
_player.direction = 1

_controls = {}
_controls.up = "w"
_controls.down = "s"
_controls.left = "a"
_controls.right = "d"

-----------------------------------------------------------------------------------

function playerUpdate(dt)
    if (_player.body) then
        checkIfGrounded()
        movePlayer(dt)
        checkAnimationState()
        animatePlayer(dt)
        checkPlayerCollision()
    end
end

-----------------------------------------------------------------------------------

function drawPlayer()
    if(_player.body) then
        local playerX, playerY = _player:getPosition()
        _player.animation:draw(_sprites.playerSheet, playerX, playerY, nil, 0.25 * _player.direction , 0.25, 130, 300)
    end
end

-----------------------------------------------------------------------------------

function checkIfGrounded()
    local colliders = _world:queryRectangleArea(_player:getX() - 20, _player:getY() + 50, 40, 5, { _colliderKeys.platform })
    _player.grounded = #colliders > 0
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

function checkAnimationState()
    if (_player.grounded) then
        if(_player.isMoving) then
            _player.animation = _animations.run
        else
            _player.animation = _animations.idle
        end
    else
        _player.animation = _animations.jump
    end
end

-----------------------------------------------------------------------------------

function animatePlayer(dt)
    _player.animation:update(dt)
end

-----------------------------------------------------------------------------------

function checkPlayerCollision()
    if _player:enter((_colliderKeys.danger)) then
        _player:destroy()
    end
end

-----------------------------------------------------------------------------------

function love.keypressed(key)
    if (key ==_controls.up) then
        if (_player.grounded) then
            _player:applyLinearImpulse(0, -4000)
        end
    end
end

-----------------------------------------------------------------------------------


-----------------------------------------------------------------------------------
