-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
local lives = 3
local score = 0
local died = false


local ship
local gameLoopTimer
local livesText
local scoreText
-- Display groups

local physics = require("physics")
physics.start()
physics.setGravity ( 0, 0 )

local background = display.newImageRect("background/backgroundnova.png", 1080, 1920)
background.x = display.contentCenterX
background.y = display.contentCenterY
ship = display.newImageRect( "1.png", 80, 80)
ship.x=display.contentCenterX
ship.y=display.contentHeight - 100
physics.addBody( ship, { radius=30, isSensor=true } )
ship.myName = "ship"

-- Criando naves inimigas
local function createalien()
 newalienship = display.newImageRect("Alien Ships/Alien-Bomber.png", 80, 80)
 table.insert( alienshipTable, newalienship)
 physics.addBody(newalienship, "dynamic", { radius=40, bounce=0.8 } )
 newalienship.myName = "valkards"
end

--local whereFrom = math.random(1)
--	if (whereFrom == 1) then
--		newalienship.x = -60
--		newalienship.y = math.random(500)
--	newalienship:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
--  elseif ( whereFrom == 2 ) then
--        -- From the top
--       newalienship.x = math.random( display.contentWidth )
--        newalienship.y = -60
--        newalienship:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
--    elseif ( whereFrom == 3 ) then
--       -- From the right
--        newalienship.x = display.contentWidth + 60
--        newalienship.y = math.random( 500 )
--       newalienship:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
--	end	
--end



--Até aqui.

-- Seed the random number generator
math.randomseed( os.time() )

--local sheetOptions =

--local objectSheet = graphics.newImageSheet( "1.png", sheetOptions)
--livesText = display.newText( uiGroup, "Lives:" .. lives, 200, 80, native.systemFont, 36)
--scoreText = display.newText( uiGroup, "Score: " .. score, 400, 80, native.systemFonte, 36)
local function  updateText()
	livesText.text = "Lives: " .. lives
	scoreText.text = "Score: " .. score
end
local function fireLaser()
	local newlaser = display.newImageRect("laser3.png", 1000, 1000)
	physics.addBody( newlaser,"dynamic", { isSensor=true } )
	newlaser.isBullet = true
	newlaser.myName = "laser"

	
	newlaser.x = ship.x
	newlaser.y = ship.y
	newlaser:toBack()

	transition.to( newlaser, { y=-40, time=500, } )
end

ship:addEventListener( "tap", fireLaser )

local function dragShip( event )
	local ship = event.target
	local phase = event.phase
	if ("began" == phase) then
		display.currentStage:setFocus( ship )
		ship.touchOffsetX = event.x - ship.x
		ship.touchOffsetY = event.y - ship.y
	elseif ( "moved" == phase ) then
		ship.x = event.x - ship.touchOffsetX
		ship.y = event.y - ship.touchOffsetY
	elseif ( "moved" == phase ) then
		ship.x = event.x - ship.touchOffsetX
	elseif ( "ended" == phase or "cancelled" == phase )then
		display.currentStage:setFocus( nil )

	end
	return true
end

ship:addEventListener( "touch", dragShip )