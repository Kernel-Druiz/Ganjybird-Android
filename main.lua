local menu = require("menu")
local juego = require("juego")
local estado = "menu"

function love.load()
    menu.load()
    juego.load()
end

function love.update(dt)
    if estado == "menu" then
        menu.update(dt)
    elseif estado == "jugando" then
        juego.update(dt)
    end
end

function love.draw()
    if estado == "menu" then
        menu.draw()
    elseif estado == "jugando" then
        juego.draw()
    end
end

function cambiarEstado(nuevoEstado)
    estado = nuevoEstado
end

function love.keypressed(key)
    if estado == "menu" then menu.keypressed(key)
    else juego.keypressed(key) end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    if estado == "menu" then
        menu.touchpressed(id, x, y, dx, dy, pressure)
    elseif estado == "jugando" then
        juego.touchpressed(id, x, y, dx, dy, pressure)
    end
end