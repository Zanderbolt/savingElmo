-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here




local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

-- Seed the random number generator
math.randomseed( os.time() )

-- Configure image sheet
local sheetOptions =
{
    frames =
    {
        {   -- 1) BurbujaMoneda
            x = 0,
            y = 0,
            width = 102,
            height = 91
        },

        {   -- 2) BurbujaPiedra
            x = 0,
            y = 91,
            width = 90,
            height = 83
        },


        {   -- 2) Elmo
            x = 0,
            y = 275,
            width = 98,
            height = 79
        },

        {   -- 4) PelotaFut
        x = 0,
        y = 180,
        width = 100,
        height = 90
    },
    },
}
local objectSheet = graphics.newImageSheet( "gameobjects.png", sheetOptions )

-- Initialize variables
local coins = 0
local score = 0
local win = false
 
local asteroidsTable = {}
 
local ship
local gameLoopTimer
local coinsText
local scoreText

-- Set up display groups
local backGroup = display.newGroup()  -- Display group for the background image
local mainGroup = display.newGroup()  -- Display group for elmo, bubbles.
local uiGroup = display.newGroup()    -- Display group for UI coins catched

-- Load the background
local background = display.newImageRect(backGroup, "background.png", 800, 1400 )
background.x = display.contentCenterX
background.y = display.contentCenterY

ship = display.newImageRect( mainGroup, objectSheet, 3, 600, 600 )

ship.x = display.contentCenterX
ship.y = display.contentHeight + 250
physics.addBody( ship, { radius=30, isSensor=true } )

ship.myName = "ship"

-- Display coins and score
coinsText = display.newText( uiGroup, "Monedas: " .. coins, 120, 80, native.systemFont, 36)
coinsText:setFillColor( 0, 204, 255 )
-- scoreText = display.newText( uiGroup, "Score: " .. score, 400, 80, native.systemFont, 36 )

-- Hide the status bar
display.setStatusBar( display.HiddenStatusBar )

local function updateText()
    coinsText.text = "Monedas: " .. coins
    -- scoreText.text = "Score: " .. score
end

local idAsteroid = 0;

local function createAsteroid()
    local bubbleImage = math.random(2)
    local newAsteroid = display.newImageRect( mainGroup, objectSheet, bubbleImage, 125, 125 )
    
    if(bubbleImage == 1) then
        newAsteroid.hasCoin = true
    end

    physics.addBody( newAsteroid, "dynamic", { radius=50, bounce=0.8 } )
    newAsteroid.myName = "asteroid"
    newAsteroid.id = idAsteroid
    idAsteroid = idAsteroid + 1;
    

    local whereFrom = math.random( 3 )

    if ( whereFrom == 1 ) then
        -- From the left
        newAsteroid.x = -60
        newAsteroid.y = math.random( 500 )
        newAsteroid:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
    elseif ( whereFrom == 2 ) then
        -- From the top
        newAsteroid.x = math.random( display.contentWidth )
        newAsteroid.y = -60
        newAsteroid:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
    elseif ( whereFrom == 3 ) then
        -- From the right
        newAsteroid.x = display.contentWidth + 60
        newAsteroid.y = math.random( 500 )
        newAsteroid:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
    end

     newAsteroid:applyTorque( math.random( -6,6 ) )

     function newAsteroid:touch( event )
        if event.phase == "began" then
            event.target:removeSelf()
            table.remove( asteroidsTable, event.target.id )
            if (event.target.hasCoin) then        
             -- Increase score
                coins = coins + 1
                coinsText.text = "Monedas: " .. coins                
            end
        end
    end

    newAsteroid:addEventListener( "touch", object )


       
    
    table.insert( asteroidsTable, newAsteroid )
    -- newAsteroid:addEventListener( "tap", fireLaser )

end

-- sdsd

local function createSoccerBall()
    local newSoccerBall = display.newImageRect( mainGroup, objectSheet, 4, 125, 125 )
    
   

    newSoccerBall.x = 60
    newSoccerBall.y = math.random( 500 )
       
end



local function fireLaser()
 
    local newLaser = display.newImageRect( mainGroup, objectSheet, 1, 14, 40 )
    physics.addBody( newLaser, "dynamic" )
    newLaser.isBullet = true
    newLaser.myName = "laser"

    newLaser.x = ship.x
    newLaser.y = ship.y

    newLaser:toBack()

     transition.to( newLaser, { y=-40, time=500,
        onComplete = function() display.remove( newLaser ) end
    } )

 end 

 ship:addEventListener( "tap", fireLaser )

--[[  local function dragShip( event )
 
    local ship = event.target
    local phase = event.phase

    if ( "began" == phase ) then
        -- Set touch focus on the ship
        display.currentStage:setFocus( ship )
        -- Store initial offset position
        ship.touchOffsetX = event.x - ship.x
        ship.touchOffsetY = event.y - ship.y


    elseif ( "moved" == phase ) then
    -- Move the ship to the new touch position
        ship.x = event.x - ship.touchOffsetX
        ship.y = event.y - ship.touchOffsetY

    elseif ( "ended" == phase or "cancelled" == phase ) then
    -- Release touch focus on the ship
        display.currentStage:setFocus( nil )

    end

    return true  -- Prevents touch propagation to underlying object

end
 ]]



--[[ ship:addEventListener( "touch", dragShip ) ]]


local function gameLoop()

   
        -- Create new asteroid
        if(win ~= true) then
            if (coins <5) then
                createAsteroid()        
            else
                local newSoccerBall = display.newImageRect( mainGroup, objectSheet, 4, 250, 250 )   
                physics.addBody( newSoccerBall, "dynamic", { isSensor=true } )


                newSoccerBall:setLinearVelocity( 0, 200 )
                coinsText = display.newText( uiGroup, "Felicidades! Ganaste: ", display.contentCenterX , display.contentCenterY - 150, native.systemFont, 50)    
                newSoccerBall.x = display.contentCenterX;
                newSoccerBall.y = display.contentCenterY;

                win = true;
            end 
         end
     

   --[[  -- Remove asteroids which have drifted off screen
    for i = #asteroidsTable, 1, -1 do

        local thisAsteroid = asteroidsTable[i]
    
        if ( thisAsteroid.x < -100 or
            thisAsteroid.x > display.contentWidth + 100 or
            thisAsteroid.y < -100 or
            thisAsteroid.y > display.contentHeight + 100 )
        then
            display.remove( thisAsteroid )
            table.remove( asteroidsTable, i )
        end

    end ]]

end

gameLoopTimer = timer.performWithDelay( 2000, gameLoop, 0 )  

local function onCollision( event )
 
    if ( event.phase == "began" ) then
 
        local obj1 = event.object1 --Primer Objecto colisiona
        local obj2 = event.object2 --Segundo objeto que colisiona

        if ( ( obj1.myName == "laser" and obj2.myName == "asteroid" ) or
            ( obj1.myName == "asteroid" and obj2.myName == "laser" ) )
        then
            -- Remove both the laser and asteroid
            display.remove( obj1 )
            display.remove( obj2 )

            for i = #asteroidsTable, 1, -1 do
                if ( asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2 ) then
                    table.remove( asteroidsTable, i )
                    break
                end
            end

        end

    end
end

Runtime:addEventListener( "collision", onCollision )

