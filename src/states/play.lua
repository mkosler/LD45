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

local LEFT_WALL = { x = -10, y = 0, w = 10, h = love.graphics.getHeight(), isWall = true }
local RIGHT_WALL = { x = love.graphics.getWidth(), y = 0, w = 10, h = love.graphics.getHeight(), isWall = true }
local TOP_WALL = { x = 0, y = -10, w = love.graphics.getWidth(), h = 10, isWall = true }
local BOTTOM_WALL = { x = 0, y = love.graphics.getHeight(), w = love.graphics.getWidth(), h = 10, isWall = true }

function Play:enter(prev)
    self.BUMP_WORLD = bump.newWorld()

    self.BUMP_WORLD:add(LEFT_WALL, LEFT_WALL.x, LEFT_WALL.y, LEFT_WALL.w, LEFT_WALL.h)
    self.BUMP_WORLD:add(RIGHT_WALL, RIGHT_WALL.x, RIGHT_WALL.y, RIGHT_WALL.w, RIGHT_WALL.h)
    self.BUMP_WORLD:add(TOP_WALL, TOP_WALL.x, TOP_WALL.y, TOP_WALL.w, TOP_WALL.h)
    self.BUMP_WORLD:add(BOTTOM_WALL, BOTTOM_WALL.x, BOTTOM_WALL.y, BOTTOM_WALL.w, BOTTOM_WALL.h)

    self.enemies = {}

    for i = 1, 10 do
        self.enemies[i] = LazyShip(
                Vector(
                    love.math.random(10, love.graphics.getWidth() - 10),
                    love.math.random(10, love.graphics.getHeight() - 10)))
        self.BUMP_WORLD:add(
            self.enemies[i],
            self.enemies[i].position.x,
            self.enemies[i].position.y,
            self.enemies[i].width,
            self.enemies[i].height)
    end

    self.playership = PlayerShip(Vector(300, 200))
    self.BUMP_WORLD:add(self.playership, self.playership.position.x, self.playership.position.y,
        self.playership.width, self.playership.height)
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
    -- if len > 0 then print('hit!') end
    self.playership:setPosition(actualX, actualY)

    for _,v in pairs(self.enemies) do
        local egx, egy = v:move(dt)
        local eax, eay, ecols, elen = self.BUMP_WORLD:move(v, egx, egy, v.collide)
        for i = 1, elen do
            if ecols[i].bounce then
                if ecols[i].normal.x ~= 0 then 
                    v.velocity.x = v.velocity.x * -1
                end
                if ecols[i].normal.y ~= 0 then 
                    v.velocity.y = v.velocity.y * -1
                end
            end
        end
        v:setPosition(eax, eay)
    end
end

function Play:draw()
    self.playership:draw()

    Utils.map(self.enemies, 'draw')
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