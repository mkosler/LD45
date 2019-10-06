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

local GRAVITY_PULSE_INITIAL_SPAWN_TIME = 10
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
            local x, y, dist = 0, 0, 0

            repeat
                x = love.math.random(150, love.graphics.getWidth() - 250)
                y = love.math.random(200, love.graphics.getHeight() - 250)
                dist = Vector(x, y):dist(self.playership.position)
            until not Utils.hover(x, y,
                self.gravityPulseNoSpawnZoneX, self.gravityPulseNoSpawnZoneY,
                self.gravityPulseNoSpawnZoneX + self.gravityPulseNoSpawnZoneW,
                self.gravityPulseNoSpawnZoneY + self.gravityPulseNoSpawnZoneH) and dist > 300

            self.smallerText = true
            self.gravitypulse = GravityPulse(
                Vector(x, y),
                self.BUMP_WORLD)
        end)

    return time + GRAVITY_PULSE_SPAWN_RATE_INCREMENT
end

function Play:enter(prev, pfl, pft, pfr, pfb)
    ASSETS['music']:play()

    if pfl then
        self.pfl = pfl
        self.gravityPulseNoSpawnZoneX = pfl + (pfr - pfl) / 2 - 225
    end
    if pft then
        self.pft = pft
        self.gravityPulseNoSpawnZoneY = pft + (pfb - pft) / 2 - 175
    end
    if pfr then
        self.pfr = pfr
        self.gravityPulseNoSpawnZoneW = 450
    end
    if pfb then
        self.pfb = pfb
        self.gravityPulseNoSpawnZoneH = 350
    end

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

    Signal.register('pulseExplode', function ()
        self.spawnerPause = true
        self.smallerText = false
        self.gravityPulseText = ''
        self.nextGravityPulseSpawnTime = self:spawnGravityPulse(self.nextGravityPulseSpawnTime)
    end)

    Signal.register('pulseExplodeEnd', function ()
        self.gravitypulse = nil
        self.spawnerPause = false
    end)

    -- Player
    self.playership = PlayerShip(Vector(300, 200), self.BUMP_WORLD)

    -- Enemies
    self.enemies = {
        -- LazyShip(Vector(400, 300), self.BUMP_WORLD),
        -- ChaseShip(Vector(475, 300), self.BUMP_WORLD, self.playership),
        -- RammingShip(Vector(550, 300), self.BUMP_WORLD, self.playership)
    }
    self.spawnRates = {
        lazy = 0.3,
        chase = 0.0,
        ramming = 0.0
    }

    self.enemySpawnTimerHandle = Timer.every(1, function ()
        if self.spawnerPause then return end

        ASSETS['spawn-sfx']:play()

        local rand = love.math.random()
        local x, y, dist = 0, 0

        self.spawnRates.lazy = self.spawnRates.lazy + 0.03
        self.spawnRates.chase = self.spawnRates.chase + 0.005
        self.spawnRates.ramming = self.spawnRates.ramming

        repeat
            x = love.math.random(100, love.graphics.getWidth() - 100)
            y = love.math.random(150, love.graphics.getHeight() - 100)
            dist = Vector(x, y):dist(self.playership.position)
        until dist > 300

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
    ASSETS['music']:stop()
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

    if not self.smallerText then
        self.uiText:setf(self.gravityPulseText, 200, 'left')
        love.graphics.draw(self.uiText, 1010, 134 - self.uiText:getHeight())
    else
        self.gravityUiText:setf(self.gravityPulseText, 200, 'left')
        love.graphics.draw(self.gravityUiText, 1010, 129 - self.gravityUiText:getHeight())
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

return Play