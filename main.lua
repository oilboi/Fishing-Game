--[[
note: poles are drawn upside down due to the way the images are drawn (starting from top left of the image)

]]--

io.stdout:setvbuf("no") -- this disables the io buffer for printing on windows (ZeroBrane Studio)

windowHeight = 720
windowWidth = 1280

polex = windowWidth / 2

poleWidth = 3 --(pixels)
poleScale = 3


-- this is used for casting out the pole, it is basically the "power level" of your cast
drawback = 0 
castedOut = false
letterTable = {"P", "O", "W", "E", "R"}


function love.load()
    love.window.setMode(windowWidth, windowHeight)
    love.graphics.setDefaultFilter( "nearest", "nearest", 0 )
    level = love.graphics.newImage("Ocean.png")
    pole = love.graphics.newImage("Pole.png")
    bobber = love.graphics.newImage("Bobber.png")
end

function love.draw()
    love.graphics.draw(level,0,0,0,3.333,3.333) --draw level
    
    -- this is flipped 180 because it is easier to work with that way (math.pi)
    if drawback <= 1 then
      love.graphics.draw(pole, polex + poleScale, windowHeight + (drawback * 50), (((drawback - 1) * math.pi) / 4) + (math.pi * 1.25) ,poleScale * (1 + (drawback*2)),poleScale *  (1 + (drawback*2))) 
    end
    
    --shows the power meter of casting
    if drawback > 0 then
      --max height is 200 pixels
      love.graphics.setColor( 255, 0, 0, 255 )
      love.graphics.rectangle( "line", windowWidth - 30, windowHeight - 480 , 20, 220)
      love.graphics.rectangle( "fill", windowWidth - 30, windowHeight - 260 - (drawback * 110), 20, drawback * 110 )
      
      for number,letter in pairs(letterTable) do
          love.graphics.print(letter, windowWidth - 45, windowHeight - 430 + (number*20))
      end
      love.graphics.setColor( 255, 255, 255, 255 )
    end
    
    love.graphics.draw(bobber, 0,0, 0, 4,4)
    
    love.graphics.setColor( 0, 0, 0, 255 )
    love.graphics.print("Fishing 0.0", 0, 0)
    love.graphics.setColor( 255, 255, 255, 255 )
    
end


function love.update()
  
    --allow the player to move the pole around
    if drawback == 0 and not castedOut then
      if love.keyboard.isDown("left") and polex > 20 then
        polex = polex - 2
      elseif love.keyboard.isDown("right") and polex < windowWidth - 20 then
        polex = polex + 2
      end
    end
  
    --this is the animation and power logic of drawing back the pole
    if love.keyboard.isDown("space") and not castedOut then
      
      if drawback < 2 then
        drawback = drawback + 0.005
      end
      if drawback >= 2 then
        up = false
        drawback = 2
      end
      
    elseif drawback > 0 and not love.keyboard.isDown("space") and castedOut == false then
        castedOut = true
        
    elseif drawback > 0 and castedOut then
      
        if drawback > 0 then
          drawback = drawback - 0.025
        end
        if drawback <= 0 then
          up = true
          drawback = 0 
        end
        
    end
    
end