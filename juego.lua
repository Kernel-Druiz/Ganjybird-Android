local juego = {}

function juego.load()
    love.filesystem.setIdentity("Ganjybird")

    birdX = 50
    birdY = 200
    birdRot = 0 
    birdVelocity = 10
    gravity = 20           
    jumpHeight = -5     
    pajarodemierda = love.graphics.newImage("weedybird.png")
    pajarodemierdamuerto = love.graphics.newImage("weedybirdkill.png")

    flashrojo = 0

    imgTubo = love.graphics.newImage("thuglife.png")
    tubos = {} 
    timerTubo = 0 
    anchoTubo = 20
    espacioEntreTubos = 150 

    pasado = love.graphics.newImage("thug.png")
    mostrarpasado = false
    timerpas = 0
    duracionthug = 0.5
    posX_pasado = 0
    posY_pasado = 0

    thugometer = 0
    if love.filesystem.getInfo("record.txt") then
        local contenido = love.filesystem.read("record.txt")
        thugomax = tonumber(contenido) or 0
    else
        thugomax = 0
    end

    fondo = love.graphics.newImage("mlg.jpg")
    fondoX = 0
    fondoSpeed = 60 

    estaVivo = true

    musicacabrona = love.audio.newSource("fondo.mp3", "stream")
    musicacabrona:setLooping(true)
    musicacabrona:play()
    musicamuerte = love.audio.newSource("muerte.mp3", "static")
    salto = love.audio.newSource("salto.mp3", "static")

    thugfont = love.graphics.newFont("Iglesia.ttf", 24)
    deathfont = love.graphics.newFont("Iglesia.ttf", 40)
end

local function drawTextWithOutline(text, x, y, font, mainColor, outlineColor, scale, align, width)
    love.graphics.setFont(font)
    love.graphics.setColor(outlineColor)
    local s = scale or 1
    local offset = 2 * s 

    if align then
        love.graphics.printf(text, x - offset, y, width, align, 0, s, s)
        love.graphics.printf(text, x + offset, y, width, align, 0, s, s)
        love.graphics.printf(text, x, y - offset, width, align, 0, s, s)
        love.graphics.printf(text, x, y + offset, width, align, 0, s, s)
        
        love.graphics.setColor(mainColor)
        love.graphics.printf(text, x, y, width, align, 0, s, s)
    else
        love.graphics.print(text, x - offset, y, 0, s, s)
        love.graphics.print(text, x + offset, y, 0, s, s)
        love.graphics.print(text, x, y - offset, 0, s, s)
        love.graphics.print(text, x, y + offset, 0, s, s)

        love.graphics.setColor(mainColor)
        love.graphics.print(text, x, y, 0, s, s)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function juego.update(dt)
    if flashrojo > 0  then
        flashrojo = math.max(0, flashrojo - 4 * dt)
    end

    if not estaVivo then 
        if musicacabrona:isPlaying() then
            musicacabrona:stop()
            musicamuerte:play()
            flashrojo = 1 
        end
        birdRot = math.min(birdRot + 10 * dt, math.pi/2)
        return 
    end

    local escalaX_fondo = love.graphics.getWidth() / fondo:getWidth()
    local anchoRealFondo = fondo:getWidth() * escalaX_fondo
    fondoX = fondoX - fondoSpeed * dt
    if fondoX <= -anchoRealFondo then fondoX = 0 end

    birdVelocity = birdVelocity + (gravity * dt)
    birdY = birdY + birdVelocity
    birdRot = birdVelocity * 0.15
    if birdRot > 1.2 then birdRot = 1.2 end
    if birdRot < -0.6 then birdRot = -0.6 end

    timerTubo = timerTubo + dt
    if timerTubo > 1.5 then
        table.insert(tubos, {
            x = love.graphics.getWidth(),
            y = love.math.random(50, 400),
            pasado = false
        })
        timerTubo = 0
    end

    for i = #tubos, 1, -1 do
        local t = tubos[i]
        t.x = t.x - (200 * dt) 
        if not t.pasado and birdX > t.x + anchoTubo then
            t.pasado = true
            thugometer = thugometer + 100
            mostrarpasado = true
            timerpas = duracionthug
            posX_pasado = love.math.random(100, love.graphics.getWidth() - 200)
            posY_pasado = love.math.random(50, love.graphics.getHeight() - 200)
        end
        if t.x < -anchoTubo then table.remove(tubos, i) end
        if checkCollision(birdX, birdY, 15, 15, t.x, 0, anchoTubo, t.y) or
           checkCollision(birdX, birdY, 15, 15, t.x, t.y + espacioEntreTubos, anchoTubo, 800) then
            estaVivo = false
        end
    end

    if thugometer > thugomax then 
        thugomax = thugometer 
        love.filesystem.write("record.txt", tostring(thugomax))
    end

    if mostrarpasado then
        timerpas = timerpas - dt
        if timerpas <= 0 then mostrarpasado = false end
    end

    if birdY > love.graphics.getHeight() or birdY < 0 then estaVivo = false end
end

function juego.draw()
    local escalaX = love.graphics.getWidth() / fondo:getWidth()
    local escalaY = love.graphics.getHeight() / fondo:getHeight()
    local anchoReal = fondo:getWidth() * escalaX

    if not estaVivo then
        love.graphics.setColor(1, 0.2, 0.2)
    else
        love.graphics.setColor(1, 1, 1)
    end

    love.graphics.draw(fondo, fondoX, 0, 0, escalaX, escalaY)
    love.graphics.draw(fondo, fondoX + anchoReal, 0, 0, escalaX, escalaY)
    love.graphics.draw(fondo, fondoX + (anchoReal * 2), 0, 0, escalaX, escalaY)

    for i, t in ipairs(tubos) do
        love.graphics.draw(imgTubo, t.x, t.y, 0, 1, -1)
        love.graphics.draw(imgTubo, t.x, t.y + espacioEntreTubos, 0, 1, 1)
    end

    local img = estaVivo and pajarodemierda or pajarodemierdamuerto
    local w, h = img:getDimensions()
    love.graphics.draw(img, birdX, birdY, birdRot, 0.2, 0.2, w/2, h/2)

    love.graphics.setColor(1, 1, 1, 1)

    if flashrojo > 0 then
        love.graphics.setColor(1, 0, 0, flashrojo)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end

    if not estaVivo then
        drawTextWithOutline("¡YOU DIED MOTHAFUCKA!\nPresiona 'R' para reiniciar", 0, 250, deathfont, {1, 0, 0}, {0, 0, 0}, 1, "center", love.graphics.getWidth())
    end

    drawTextWithOutline("THUGOMETER: " .. thugometer, 20, 20, thugfont, {1, 1, 1}, {0, 0, 0}, 1.2)
    drawTextWithOutline("THUGOMAXIMUM: " .. thugomax, 20, 80, thugfont, {1, 1, 0}, {0, 0, 0}, 1.2)

    if mostrarpasado and estaVivo then
        love.graphics.draw(pasado, posX_pasado, posY_pasado, 0, 0.5, 0.5)
    end
end

function juego.keypressed(key)
    if key == "space" and estaVivo then
        birdVelocity = jumpHeight
        salto:stop()    
        salto:setPitch(love.math.random(80, 120) / 100)
        salto:play()
    end
    if key == "r" and not estaVivo then love.event.quit("restart") end
end

function juego.touchpressed(id, x, y, dx, dy, pressure)
    if estaVivo then
        birdVelocity = jumpHeight
        salto:stop()    
        salto:setPitch(love.math.random(80, 120) / 100)
        salto:play()
    else 
        love.event.quit("restart") 
    end
end

function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 - 10 < x2 + w2 and x2 < x1 + 10 and y1 - 10 < y2 + h2 and y2 < y1 + 10
end

return juego