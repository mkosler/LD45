Gamestate = require 'hump.gamestate'
Class = require 'hump.class'
Vector = require 'hump.vector'
Timer = require 'hump.timer'
Signal = require 'hump.signal'
bump = require 'bump.bump'
PlayerShip = require 'src.objects.playership'

STATES = {
    PLAY = require 'src.states.play'
}

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(STATES.PLAY)
end

function love.update(dt)
    Timer.update(dt)
end