--[[
note: poles are drawn upside down due to the way the images are drawn (starting from top left of the image)

this is a prototype game, I am just seeing how this goes and if it could be developed into a full game because it's rather fun to make
]]--

io.stdout:setvbuf("no") -- this disables the io buffer for printing on windows (ZeroBrane Studio)

windowHeight = 720
windowWidth = 1280

polex = windowWidth / 2

poleWidth = 3 --(pixels)
poleScale = 3


--these are the variables for the bobber
bobberSize = 6 --(width)
bobberScale = 4
bobberX = 0
bobberY = 0



-- this is used for casting out the pole, it is basically the "power level" of your cast
drawback = 0 
castedOut = false
letterTable = {"P", "O", "W", "E", "R"}
castingCoolDown = 0

--these are used for the level variables
--the level "boundaries" (y limited due to prototyping)
levelMin = 600 --(close) - using direct pixel spacing of the display window, needs to be changed to fit multiple window sizes
levelMax = 420 --(far)

--whether casting or fighting
underWater = false

--fish variables
fishScale = 3
fishSizeX = 118
fishSizeY = 29
fishX = 0
fishY = 0


levelPanel1X = 0
levelPanel2X = 1280


function love.load()
    love.window.setMode(windowWidth, windowHeight)
    love.graphics.setDefaultFilter( "nearest", "nearest", 0 )
    
    level = love.graphics.newImage("Ocean.png")
    pole = love.graphics.newImage("Pole.png")
    bobber = love.graphics.newImage("Bobber.png")
    pike = love.graphics.newImage("pike.png")
    
    underWaterLevel = love.graphics.newImage("underwater.png")
    
    castSound = love.audio.newSource("cast.mp3", "static")
    music = love.audio.newSource("music.mp3", "stream")
    
    reelSound = love.audio.newSource("reel.wav", "static")
    collectLure = love.audio.newSource("collectLure.wav", "static")
    biteSound = love.audio.newSource("bite.wav", "static")
    
    fishFightSound = love.audio.newSource("fishFight.wav", "static")
    fishLanded = love.audio.newSource("fishLanded.wav", "static")
    
    underWaterSounds = love.audio.newSource("underwater.wav", "stream")
    
    music:setVolume(0.5)
    music:play()
end

function love.draw()
    if not underWater then
      love.graphics.draw(level,0,0,0,3.333,3.333) --draw level
      
      if castedOut and drawback <= 0 then
        love.graphics.draw(bobber, bobberX,  bobberY, 0, 4,4)
        
        love.graphics.setColor( 0, 0, 0, 255 )
        
        love.graphics.line( polex - ((poleWidth * poleScale)/5) , windowHeight-380, bobberX+((bobberScale * bobberSize)/2), bobberY)
        
        love.graphics.setColor( 255, 255, 255, 255 )
      end
      
      -- this is flipped 180 because it is easier to work with that way (math.pi)
      if drawback <= 1 then
        love.graphics.draw(pole, polex + ((poleWidth * poleScale)/2), windowHeight + (drawback * 50), (((drawback - 1) * math.pi) / 4) + (math.pi * 1.25) ,poleScale * (1 + (drawback*2)),poleScale *  (1 + (drawback*2))) 
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
      
      
    else
    
      love.graphics.draw(underWaterLevel,levelPanel1X,0,0,1,1) --draw level
      love.graphics.draw(underWaterLevel,levelPanel2X,0,0,1,1) --draw level
      
      love.graphics.draw(pike,fishX,fishY - ((fishScale * fishSizeY) / 2),0,fishScale,fishScale)
      
      
      love.graphics.setColor( 0, 0, 0, 255 )
      love.graphics.line( fishX, fishY, windowWidth / 2, 0)
      love.graphics.setColor( 255, 255, 255, 255 )
      
    love.graphics.setColor( 0, 0, 0, 255 )
    love.graphics.print("Line: " .. line, 0, 50)
    love.graphics.setColor( 255, 255, 255, 255 )
    
    end
    love.graphics.setColor( 0, 0, 0, 255 )
    love.graphics.print("Fishing 0.0", 0, 0)
    love.graphics.setColor( 255, 255, 255, 255 )
    
end


biteTimer = 100
fishFighting = true
fishFightTimer = 100
line = 3000

function love.update()
  
    if not underWater then
      --allow the player to move the pole around
      if drawback == 0 then
        if love.keyboard.isDown("left") and polex > 20 then
          polex = polex - 2
        elseif love.keyboard.isDown("right") and polex < windowWidth - 20 then
          polex = polex + 2
        end
      end
      
      --calculate biting chance if casted out
      if drawback == 0 and castedOut then
        biteTimer = biteTimer - 0.5
        if biteTimer <= 0 then
          biteTimer = 100
          if math.random() > 0.9 then
            underWater = true
            biteSound:play()
            music:stop()
            underWaterSounds:play()
            
            fishX = (windowWidth / 2) - ((fishScale * fishSizeX) / 2)
            fishY = (windowHeight / 2) - ((fishScale * fishSizeY) / 2)
            
            line = 3000
          end
        end
      end
    
      --this is the animation and power logic of drawing back the pole
      if love.keyboard.isDown("space") and not castedOut and castingCoolDown <= 0 then
        
        if drawback < 2 then
          drawback = drawback + 0.005
        end
        if drawback >= 2 then
          up = false
          drawback = 2
        end
        
      elseif drawback > 0 and not love.keyboard.isDown("space") and castedOut == false then
          castedOut = true
          bobberX = ((polex + (windowWidth/2)) / 2) - ((bobberSize * bobberScale)/2) 
          bobberY = ((drawback/2) * (levelMax - levelMin)) + levelMin
          castSound:play()
          
      elseif drawback > 0 and castedOut then
        
          if drawback > 0 then
            drawback = drawback - 0.025
          end
          if drawback <= 0 then
            up = true
            drawback = 0 
          end
          
      elseif love.keyboard.isDown("space") and castedOut then
        if bobberX + (bobberSize * bobberScale) < polex + (poleWidth * poleScale) then
          bobberX = bobberX + 1
        elseif bobberX + (bobberSize * bobberScale) > polex + (poleWidth * poleScale) then
          bobberX = bobberX -  1
        end
        bobberY = bobberY + 1
        
        if bobberY > windowHeight - 50 then
          castedOut = false
          castingCoolDown = 15
          collectLure:play()
        end
          reelSound:play()
      else
        reelSound:stop()
      end
      
      if castingCoolDown > 0 then
        castingCoolDown = castingCoolDown - 0.1
      end
    else
      
      fishFightTimer = fishFightTimer - 1
      if fishFightTimer <= 0 then
        if math.random() > 0.79 then
          fishFighting = true
        else
          fishFighting = false
        end
        fishFightTimer = 100
      end
      
      if fishFighting then
        
        reelSound:stop()
        
        levelPanel1X = levelPanel1X + 1
        levelPanel2X = levelPanel2X + 1
        
        if levelPanel1X > 1280 then
          levelPanel1X = -1279
        end
        if levelPanel2X > 1280 then
          levelPanel2X = -1279
        end
        
        fishFightSound:play() 
        
        line = line + 1
        
      elseif love.keyboard.isDown("space") then
        reelSound:play()
        
        levelPanel1X = levelPanel1X - 1
        levelPanel2X = levelPanel2X - 1
        
        if levelPanel1X < -1280 then
          levelPanel1X = 1279
        end
        if levelPanel2X < -1280 then
          levelPanel2X = 1279
        end
        
        line = line - 1
        
        if line <= 0 then
          underWater = false
          castingCoolDown = 50
          castedOut = false
          music:play()
          fishLanded:play()
        end
      else
        reelSound:stop()
      end
    end
end