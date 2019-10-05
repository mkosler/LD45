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

    self.playership = PlayerShip(Vector(300, 200), self.BUMP_WORLD)

    self.enemies = {}

    Timer.every(1, function ()
        local rand = love.math.random()

        if rand > 0.5 then
            table.insert(self.enemies, ChaseShip(
                Vector(
                    love.math.random(10, love.graphics.getWidth() - 10),
                    love.math.random(10, love.graphics.getHeight() - 10)),
                self.BUMP_WORLD,
                self.playership))
        else
            table.insert(self.enemies, LazyShip(
                    Vector(
                        love.math.random(10, love.graphics.getWidth() - 10),
                        love.math.random(10, love.graphics.getHeight() - 10)),
                    self.BUMP_WORLD))
        end
    end)
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

    self.playership:move(dt, xAxis, yAxis)

    Utils.map(self.enemies, 'move', dt)
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