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

local GRAVITY_PULSE_INITIAL_SPAWN_TIME = 1
local GRAVITY_PULSE_SPAWN_RATE_INCREMENT = 5

local LEFT_WALL = { x = 40, y = 150, w = 10, h = love.graphics.getHeight() - 200, isWall = true }
local RIGHT_WALL = { x = love.graphics.getWidth() - 50, y = 150, w = 10, h = love.graphics.getHeight() - 200, isWall = true }
local TOP_WALL = { x = 50, y = 140, w = love.graphics.getWidth() - 100, h = 10, isWall = true }
local BOTTOM_WALL = { x = 50, y = love.graphics.getHeight() - 50, w = love.graphics.getWidth() - 100, h = 10, isWall = true }

function Play:spawnGravityPulse(time)
    self.nextGravityPulseSpawnCountdown = time

    self.spawnGravityPulseTimerHandle = Timer.during(time,
        function (dt)
            self.nextGravityPulseSpawnCountdown = self.nextGravityPulseSpawnCountdown - dt
            self.gravityPulseText = ('%.02f'):format(self.nextGravityPulseSpawnCountdown)
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

function Play:enter(prev, pfl, pft, pfr, pfb)
    if pfl then self.pfl = pfl end
    if pft then self.pft = pft end
    if pfr then self.pfr = pfr end
    if pfb then self.pfb = pfb end

    self.uiText = love.graphics.newText(ASSETS['font-timers'])
    self.gravityUiText = love.graphics.newText(ASSETS['font-gravity'])

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
    self.nextGravityPulseSpawnTime = self:spawnGravityPulse(GRAVITY_PULSE_INITIAL_SPAWN_TIME)

    Signal.register('explode', function ()
        self.nextGravityPulseSpawnTime = self:spawnGravityPulse(self.nextGravityPulseSpawnTime)
    end)

    Signal.register('explodeEnd', function () self.gravitypulse = nil end)

    -- Player
    self.playership = PlayerShip(Vector(300, 200), self.BUMP_WORLD)

    -- Enemies
    self.enemies = {}
    self.spawnRates = {
        lazy = 0.3,
        chase = 0.0,
        ramming = 0.0
    }

    self.enemySpawnTimerHandle = Timer.every(1, function ()
        local rand = love.math.random()
        local x, y, dist = 0, 0

        self.spawnRates.lazy = self.spawnRates.lazy + 0.03
        self.spawnRates.chase = self.spawnRates.chase + 0.005
        self.spawnRates.ramming = self.spawnRates.ramming

        repeat
            x = love.math.random(100, love.graphics.getWidth() - 100)
            y = love.math.random(150, love.graphics.getHeight() - 100)
            dist = Vector(x, y):dist(self.playership.position)
        until dist > 200

        if rand > self.spawnRates.lazy then
            table.insert(self.enemies, LazyShip(
                Vector(x, y),
                self.BUMP_WORLD))
        elseif rand > self.spawnRates.chase then
            table.insert(self.enemies, ChaseShip(
                Vector(x, y),
                self.BUMP_WORLD,
                self.playership))
        else
            table.insert(self.enemies, RammingShip(
                Vector(x, y),
                self.BUMP_WORLD,
                self.playership))
        end
    end)

    -- Game over
    Signal.register('death', function ()
        Gamestate.switch(STATES.RETRY, self.scoreTimer)
    end)
end

function Play:leave()
    Timer.clear()
    Signal.clearPattern('.*')
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
    love.graphics.setScissor(self.pfl, self.pft, self.pfr - self.pfl, self.pfb - self.pft)
    ASSETS['glow-effect'](function ()
        if self.gravitypulse then self.gravitypulse:draw() end

        self.playership:draw()

        Utils.map(self.enemies, 'draw')
    end)
    love.graphics.setScissor()

    local min = math.floor(self.scoreTimer / 60)
    local sec = math.floor(self.scoreTimer % 60)
    self.uiText:set(('%02d:%02d'):format(min, sec))
    love.graphics.draw(self.uiText, 175, 137 - self.uiText:getHeight())

    if not self.gravitypulse then
        self.uiText:setf(self.gravityPulseText, 200, 'left')
        love.graphics.draw(self.uiText, 1020, 134 - self.uiText:getHeight())
    else
        self.gravityUiText:setf(self.gravityPulseText, 200, 'left')
        love.graphics.draw(self.gravityUiText, 1020, 129 - self.gravityUiText:getHeight())
    end
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