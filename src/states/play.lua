local Play = {}

local KEYS = {
    w = 'UP',
    s = 'DOWN',
    a = 'LEFT',
    d = 'RIGHT'
}

local CONTROLS = {
    UP = false,
    DOWN = false,
    LEFT = false,
    RIGHT = false
}

local testEntity = { x = 500, y = 500, w = 20, h = 20 }

function Play:enter(prev)
    self.BUMP_WORLD = bump.newWorld()
    self.entities = {}

    self.playership = PlayerShip(Vector(300, 200))
    self.BUMP_WORLD:add(self.playership, self.playership.position.x, self.playership.position.y,
        self.playership.width, self.playership.height)
    table.insert(self.entities, self.playership)

    self.BUMP_WORLD:add(testEntity, testEntity.x, testEntity.y, testEntity.w, testEntity.h)
    table.insert(self.entities, testEntity)
end

function Play:update(dt)
    local xAxis, yAxis = 0, 0

    if CONTROLS.UP and CONTROLS.DOWN then yAxis = 0
    elseif CONTROLS.UP then yAxis = -1
    elseif CONTROLS.DOWN then yAxis = 1
    end

    if CONTROLS.LEFT and CONTROLS.RIGHT then xAxis = 0
    elseif CONTROLS.LEFT then xAxis = -1
    elseif CONTROLS.RIGHT then xAxis = 1
    end

    local goalX, goalY = self.playership:move(dt, xAxis, yAxis)
    local actualX, actualY, cols, len = self.BUMP_WORLD:move(self.playership, goalX, goalY, self.playership.collide)
    if len > 0 then print('hit!') end
    self.playership:setPosition(actualX, actualY)
end

function Play:draw()
    self.playership:draw()

    love.graphics.push('all')
    love.graphics.setColor(0, 255, 0)
    love.graphics.translate(testEntity.x, testEntity.y)
    love.graphics.rectangle('line', 0, 0, testEntity.w, testEntity.h)
    love.graphics.pop()
end

function Play:keypressed(key)
    for k,v in pairs(KEYS) do
        if key == k then CONTROLS[v] = true end
    end
end

function Play:keyreleased(key)
    for k,v in pairs(KEYS) do
        if key == k then CONTROLS[v] = false end
    end
end

function Play:mousepressed(x, y, b)
end

function Play:mousereleased(x, y, b)
end

return Play