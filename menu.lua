local menu = {}

function menu.load()
    menu.font = love.graphics.newFont("Iglesia.ttf", 40)
    wall = love.graphics.newImage("menuwall.png")
end

function menu.update(dt)
end

function menu.draw()
    local sx = love.graphics.getWidth() / wall:getWidth()
    local sy = love.graphics.getHeight() / wall:getHeight()
    love.graphics.draw(wall, 0, 0, 0, sx, sy)

    love.graphics.setFont(menu.font)
    love.graphics.printf("GANJYBIRD\n\nPresiona ESPACIO\nO toca la pantalla", 0, love.graphics.getHeight()/3, love.graphics.getWidth(), "center")
end

function menu.keypressed(key)
    if key == "space" then
        cambiarEstado("jugando")
    end
end

function menu.touchpressed(id, x, y, dx, dy, pressure)
    cambiarEstado("jugando")
end

return menu