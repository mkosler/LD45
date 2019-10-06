Gamestate = require 'lib.hump.gamestate'
Class = require 'lib.hump.class'
Vector = require 'lib.hump.vector'
Timer = require 'lib.hump.timer'
Signal = require 'lib.hump.signal'
bump = require 'lib.bump.bump'
moonshine = require 'lib.moonshine'

Utils = require 'src.utils'
PlayerShip = require 'src.objects.playership'
LazyShip = require 'src.objects.lazyship'
ChaseShip = require 'src.objects.chaseship'
RammingShip = require 'src.objects.rammingship'
GravityPulse = require 'src.objects.gravitypulse'

local PLAYFIELD_LEFT = 50
local PLAYFIELD_TOP = 150
local PLAYFIELD_RIGHT = 50 + love.graphics.getWidth() - 100
local PLAYFIELD_BOTTOM = 150 + love.graphics.getHeight() - 200

local PLAYFIELD_CELL_WIDTH = (PLAYFIELD_RIGHT - PLAYFIELD_LEFT) / 16
local PLAYFIELD_CELL_HEIGHT = (PLAYFIELD_BOTTOM - PLAYFIELD_TOP) / 16

function love.load()
    local glowEffect = moonshine(moonshine.effects.glow)
    glowEffect.parameters = {
        glow = { min_luma = 0 },
    }

    local crtEffect = moonshine(moonshine.effects.crt)

    STATES = {
        PLAY = require 'src.states.play',
        RETRY = require 'src.states.retry'
    }

    ASSETS = {
        ['font-title'] = love.graphics.newFont('assets/Born2bSportyV2.ttf', 108),
        ['font-timers'] = love.graphics.newFont('assets/Born2bSportyV2.ttf', 48),
        ['font-gravity'] = love.graphics.newFont('assets/Born2bSportyV2.ttf', 24),
        ['font-retry'] = love.graphics.newFont('assets/Born2bSportyV2.ttf', 36),
        ['glow-effect'] = glowEffect,
        ['crt-effect'] = crtEffect,
        ['explosion-sfx'] = love.audio.newSource('assets/explosion.wav', 'static'),
        ['bomb-sfx'] = love.audio.newSource('assets/bomb.wav', 'static'),
        ['player-death-sfx'] = love.audio.newSource('assets/player-death.wav', 'static'),
        ['spawn-sfx'] = love.audio.newSource('assets/spawn.wav', 'static'),
        ['music'] = love.audio.newSource('assets/music.wav'),
    }

    local callbacks = {
        'update'
    }

    for k in pairs(love.handlers) do
        callbacks[#callbacks + 1] = k
    end

    Gamestate.registerEvents(callbacks)
    Gamestate.switch(STATES.PLAY, PLAYFIELD_LEFT, PLAYFIELD_TOP, PLAYFIELD_RIGHT, PLAYFIELD_BOTTOM)
end

function love.update(dt)
    Timer.update(dt)
end

function love.draw()
    ASSETS['crt-effect'](function()
    love.graphics.setLineWidth(5)

    love.graphics.push('all')
    love.graphics.setColor(255, 255, 255)

    local titleText = love.graphics.newText(ASSETS['font-title'], 'DEFENSELESS')
    love.graphics.draw(titleText, love.graphics.getWidth() / 2 - titleText:getWidth() / 2, 150 - titleText:getHeight())

    love.graphics.push('all')
    love.graphics.setLineWidth(1)
    love.graphics.setColor(100, 100, 100)
    for i = 0, 15 do
        love.graphics.line(
            PLAYFIELD_LEFT,
            PLAYFIELD_TOP + PLAYFIELD_CELL_HEIGHT * i,
            PLAYFIELD_RIGHT,
            PLAYFIELD_TOP + PLAYFIELD_CELL_HEIGHT * i)
    end
    for i = 0, 15 do
        love.graphics.line(
            PLAYFIELD_LEFT + PLAYFIELD_CELL_WIDTH * i,
            PLAYFIELD_TOP,
            PLAYFIELD_LEFT + PLAYFIELD_CELL_WIDTH * i,
            PLAYFIELD_BOTTOM)
    end
    love.graphics.pop()

    Gamestate.draw()

    love.graphics.rectangle(
        'line',
        PLAYFIELD_LEFT,
        PLAYFIELD_TOP,
        PLAYFIELD_RIGHT - PLAYFIELD_LEFT,
        PLAYFIELD_BOTTOM - PLAYFIELD_TOP)
    love.graphics.pop()
    end)
end