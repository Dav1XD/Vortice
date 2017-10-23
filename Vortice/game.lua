
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

local lives = 3
local score = 0
local died = false
local backGroup 
local mainGroup 
local uiGroup 
local alienshipTable = {}
local ship
local gameLoopTimer
local livesText
local scoreText
local fireSound

local function  updateText()
	livesText.text = "Lives: " .. lives
	scoreText.text = "Score: " .. score
end


local function createalien()
 	local newalienship = display.newImageRect( mainGroup,"Alien1.png", 50,50 )
 	table.insert(alienshipTable, newalienship)
 	physics.addBody( newalienship, "dynamic", {radius=30, bounce=0.8 } )
 	newalienship.myName = "valkarians"
 	contador = 0
 	posicao = math.random(200)

 	local whereFrom = math.random( 20 )
 		if ( whereFrom == 1 ) then
 			newalienship.x = math.random (display.contentWidth)
 		newalienship:setLinearVelocity( 0,30)
 		elseif ( whereFrom == 2) then
 			newalienship.x = math.random (display.contentWidth)
 		newalienship:setLinearVelocity (0, 30)
 		elseif (whereFrom == 3 ) then
 			newalienship.x = math.random (display.contentWidth)
 			newalienship:setLinearVelocity (0, 30)
 	end
 
end

local function fireLaser()
	local newlaser = display.newImageRect(mainGroup,"laser3.png", 50, 50)
	physics.addBody( newlaser,"dynamic", { isSensor=true } )
	newlaser.isBullet = true
	newlaser.myName = "laser"
	audio.play( fireSound )

	
	newlaser.x = ship.x
	newlaser.y = ship.y
	newlaser:toBack()

	transition.to( newlaser, { y=-40, time=500, } )
		onComplete = function() display.remove(newlaser) end	
end



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



local function gameLoop()
	createalien()

	for i = #alienshipTable, 1, -1 do
	local thisalien = alienshipTable[i]

		if (thisalien.y < -100 or
			thisalien.y > display.contentHeight + 100)
		then
		display.remove( thisalien )
		table.remove( alienshipTable, i)
		end
	end
end


local function restoreShip()
	
	ship.isBodyActive = false
	ship.x = display.contentCenterX
	ship.y = display.contentHeight - 100

	-- Fade in the ship
	transition.to( ship, { alpha=1, time=4000,	
		onComplete = function()
			ship.isBodyActive = true
			died = false
		end

		} )

end
local function endGame()
	composer.gotoScene( "menu", { time=800, effect="crossFade" } )
end	


local function onCollision (event)

	if (event.phase == "began" ) then

		local obj1 = event.object1
		local obj2 = event.object2

		if (( obj1.myName == "laser" and obj2.myName == "valkarians") or
			(obj1.myName == "valkarians" and obj2.myName == "laser") )
		then

			display.remove( obj1 )
			display.remove( obj2 )
			for i = #alienshipTable, 1, -1 do
				if ( alienshipTable[i] == obj1 or alienshipTable[i] == obj2 ) then
					table.remove ( alienshipTable, i)
					break
				end
			end
			
			--Score
			score = score + 100
			scoreText.text= "Score: " .. score

			elseif (( obj1.myName == "ship" and obj2.myName == "valkarians" ) or
				(obj1.myName =="valkarians" and obj2.myName == "ship" ) )
			then
			if ( died == false ) then
				died = true

				--update lives
				lives = lives - 1
				livesText.text = "Lives: " .. lives

				if 	( lives == 0 ) then
					display.remove(ship)
					timer.performWithDelay( 2000, endGame )
				else
					ship.alpha = 0
					timer.performWithDelay ( 1000, restoreShip)
				end
			end
		end
	end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	physics.pause()

	backGroup = display.newGroup()
	sceneGroup:insert( backGroup )

	mainGroup = display.newGroup()
	sceneGroup:insert( mainGroup )

	uiGroup = display.newGroup()
	sceneGroup:insert( uiGroup )

	local background = display.newImageRect( backGroup, "background/backgroundnova.png", 800, 1400)
	background.x = display.contentCenterX
	background.y = display.contentCenterY



	ship = display.newImageRect( mainGroup,"1.png", 60, 60)
	ship.x=display.contentCenterX
	ship.y=display.contentHeight - 100
	physics.addBody( ship, { radius=30, isSensor=true } )
	ship.myName = "ship"

	livesText = display.newText( uiGroup, "Lives:" .. lives, 260, 40, native.systemFont, 20)
	scoreText = display.newText( uiGroup, "Score:" .. score, 80, 40, native.systemFont, 20)

	 ship:addEventListener( "tap", fireLaser )
    ship:addEventListener( "touch", dragShip )
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physics.start()
        Runtime:addEventListener( "collision", onCollision )
        gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		timer.cancel( gameLoopTimer)

	elseif ( phase == "did" ) then
		Runtime:removeEventListener( "collision", onCollision)
		physics.pause()
		composer.removeScene( "game")
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
