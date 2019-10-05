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

local GRAVITY_PULSE_SPAWN_RATE_INCREMENT = 5

local LEFT_WALL = { x = 40, y = 150, w = 10, h = love.graphics.getHeight() - 200, isWall = true }
local RIGHT_WALL = { x = love.graphics.getWidth() - 50, y = 150, w = 10, h = love.graphics.getHeight() - 200, isWall = true }
local TOP_WALL = { x = 50, y = 140, w = love.graphics.getWidth() - 100, h = 10, isWall = true }
local BOTTOM_WALL = { x = 50, y = love.graphics.getHeight() - 50, w = love.graphics.getWidth() - 100, h = 10, isWall = true }

function Play:spawnGravityPulse(time)
    self.nextGravityPulseSpawnCountdown = time

    Timer.during(time,
        function (dt)
            self.nextGravityPulseSpawnCountdown = self.nextGravityPulseSpawnCountdown - dt
            self.gravityPulseText = ('Next gravity pulse: %.02f'):format(self.nextGravityPulseSpawnCountdown)
        end, function ()
            self.gravityPulseText = 'Gravity pulse spawned'
            local x = love.math.random(100, love.graphics.getWidth() - 200)
            local y = love.math.random(150, love.graphics.getHeight() - 200)
            self.gravitypulse = GravityPulse(
                Vector(x, y),
                self.BUMP_WORLD)
        end)

    return time + GRAVITY_PULSE_SPAWN_RATE_INCREMENT
end

function Play:enter(prev)
    -- Score timer
    self.scoreTimer = 0

    self.BUMP_WORLD = bump.newWorld()

    -- Playing field walls
    self.BUMP_WORLD:add(LEFT_WALL, LEFT_WALL.x, LEFT_WALL.y, LEFT_WALL.w, LEFT_WALL.h)
    self.BUMP_WORLD:add(RIGHT_WALL, RIGHT_WALL.x, RIGHT_WALL.y, RIGHT_WALL.w, RIGHT_WALL.h)
    self.BUMP_WORLD:add(TOP_WALL, TOP_WALL.x, TOP_WALL.y, TOP_WALL.w, TOP_WALL.h)
    self.BUMP_WORLD:add(BOTTOM_WALL, BOTTOM_WALL.x, BOTTOM_WALL.y, BOTTOM_WALL.w, BOTTOM_WALL.h)

    -- Gravity pulse logic
    self.gravitypulse = nil
    self.nextGravityPulseSpawnCountdown = nil
    self.nextGravityPulseSpawnTime = self:spawnGravityPulse(10)
    Signal.register('explode', function ()
        self.gravitypulse = nil
        self.nextGravityPulseSpawnTime = self:spawnGravityPulse(self.nextGravityPulseSpawnTime)
    end)

    -- Player
    self.playership = PlayerShip(Vector(300, 200), self.BUMP_WORLD)

    -- Enemies
    self.enemies = {}
    Timer.every(1, function ()
        local rand = love.math.random()
        local x = love.math.random(100, love.graphics.getWidth() - 100)
        local y = love.math.random(150, love.graphics.getHeight() - 100)

        if rand > 0.7 then
            table.insert(self.enemies, ChaseShip(
                Vector(x, y),
                self.BUMP_WORLD,
                self.playership))
        elseif rand > 0.2 then
            table.insert(self.enemies, LazyShip(
                Vector(x, y),
                self.BUMP_WORLD))
        else
            table.insert(self.enemies, RammingShip(
                Vector(x, y),
                self.BUMP_WORLD,
                self.playership))
        end
    end)
end

function Play:update(dt)
    self.scoreTimer = self.scoreTimer + dt

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
    if self.gravitypulse then self.gravitypulse:draw() end

    self.playership:draw()

    Utils.map(self.enemies, 'draw')

    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle('line', 50, 150, love.graphics.getWidth() - 100, love.graphics.getHeight() - 200)

    local min = math.floor(self.scoreTimer / 60)
    local sec = math.floor(self.scoreTimer % 60)
    love.graphics.print(('%02d:%02d'):format(min, sec), 0, 0)
    love.graphics.print(self.gravityPulseText, 0, 20)
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