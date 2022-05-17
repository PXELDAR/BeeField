-----------------------------------------------------------------------------------

_enemies = {}

-----------------------------------------------------------------------------------

function spawnEnemy(x, y)
    local enemy = _world:newRectangleCollider(x, y, 70, 90, { collision_class = _colliderKeys.danger })
    enemy.direction = 1
    enemy.speed = 200
    enemy.animation = _animations.enemy
    table.insert(_enemies, enemy)
end

-----------------------------------------------------------------------------------

function updateEnemies(dt)
    for i, enemy in ipairs(_enemies) do
        enemy.animation:update(dt)

        local enemyX, enemyY = enemy:getPosition()

        local colliders = _world:queryRectangleArea(enemyX + (40 * enemy.direction), enemyY + 40, 10, 10, { _colliderKeys.platform })
        if (#colliders == 0) then
            enemy.direction = enemy.direction * -1
        end

        enemy:setX(enemyX + enemy.speed * dt * enemy.direction)
    end
end

-----------------------------------------------------------------------------------

function drawEnemies()
    for i, enemy in ipairs(_enemies) do
        local enemyX, enemyY = enemy:getPosition()
        enemy.animation:draw(_sprites.enemySheet, enemyX, enemyY, nil, enemy.direction, 1, 50, 65)
    end
end

-----------------------------------------------------------------------------------
