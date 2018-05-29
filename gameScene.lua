-----------------------------------------------------------------------------------------
-- Created by: Aayman Shameem
-- Created on: May 29, 2018
-- 
-- This code will allow the user to make the robot walk, jump and shoot at things
-----------------------------------------------------------------------------------------

-- game scene

-- place all the require statements here
local composer = require( "composer" )
local physics = require("physics")
local json = require( "json" )
local tiled = require( "com.ponywolf.ponytiled" )
 
local scene = composer.newScene()

-- you need these to exist the entire scene
-- this is called the forward reference
local map = nil
local robot = nil
local anEnemy = nil
local rightArrow = nil
local jumpButton = nil
local shootButton = nil
local playerBullets = {}

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function onRightArrowTouch( event )
    if ( event.phase == "began" ) then
        if robot.sequence ~= "walk" then
            robot.sequence = "walk"
            robot:setSequence( "walk" )
            robot:play()
        end

    elseif ( event.phase == "ended" ) then
        if robot.sequence ~= "idle" then
            robot.sequence = "idle"
            robot:setSequence( "idle" )
            robot:play()
        end
    end
    return true
end

local function onJumpButtonTouch( event )
    if ( event.phase == "ended" ) then
            robot:setLinearVelocity( 0, -750 )
            robot:setSequence( "jump" )
            robot.sequence = "jump"
            
            robot:play()

    elseif ( event.phase == "ended" ) then
        if robot.sequence ~= "idle" then
            robot.sequence = "idle"
            robot:setSequence( "idle" )
            robot:play()
        end
    end
    return true
end

local robotShoot = function( event )
    -- after 1 second go back to idle
    robot.sequence = "idle"
    robot:setSequence( "idle" )
    robot:play()
end

local checkPlayerBulletisOutOfBounds = function ( event )
        -- check if any tomatoes are out of bounds
    local bulletCounter

    if #playerBullets > 0 then
        for bulletCounter = #playerBullets, 1, -1 do
            if playerBullets[ bulletCounter ].x > display.contentWidth * 2 then
                playerBullets[ bulletCounter ]:removeSelf()
                playerBullets[ bulletCounter ] = nil
                table.remove( playerBullets, bulletCounter )
                print( "remove bullet" )
            end
        end
    end
end

local function onShootButtonTouch( event )
    if ( event.phase == "began" ) then
        if robot.sequence ~= "shoot" then
            robot.sequence = "shoot" 
            robot:setSequence( "shoot" )

            --[[elseif robotVelocityY > 0 then
                robot.sequence = "jump and shoot"
                robot:setSequence( "jump and shoot" )]]

            robot:play()
            timer.performWithDelay( 800, robotShoot )

            -- make a tomato appear
            local powerBullet = display.newImage( "./assets/sprites/items/blueShot.png" )
            powerBullet.x = robot.x
            powerBullet.y = robot.y 
            physics.addBody( powerBullet, "dynamic" )
            -- Make the object a "bullet" type object
            powerBullet.isBullet = true
            powerBullet.isFixedRotation = true
            powerBullet.gravityScale = 0
            powerBullet.id = "a blue shot"
            powerBullet:setLinearVelocity( 1500, 0 )

            table.insert( playerBullets, powerBullet )
            print( "# of bullet: " .. tostring( #playerBullets ) )
        end

    elseif ( event.phase == "ended" ) then

    end
    return true
end

local moveRobot = function( event )

    if robot.sequence == "walk" then
        transition.moveBy( robot, {
            x = 10,
            y = 0,
            time = 0
            } )
    end

    if robot.sequence == "jump" then

        -- can also check if the robot has landed from a jump
        local robotVelocityX, robotVelocityY = robot:getLinearVelocity()

        if robotVelocityY == 0 then
            -- the robot is currently not jumping
            -- it was jumping so set to idle
            robot.sequence = "idle"
            robot:setSequence( "idle" )
            robot:play()
        end

    end
end

local function enemyShot( event )

    if ( event.phase == "began" ) then
        local obj1 = event.object1
        local obj2 = event.object2
        local whereCollisionOccurredX = obj1.x
        local whereCollisionOccurredY = obj1.y

        if ( ( obj1.id == "zombie" and obj2.id == "a blue shot" ) or 
             ( obj1.id == "a blue shot" and obj2.id == "zombie" ) ) then

        -- remove the bullet
        local bulletCounter = nil

        for bulletCounter = #playerBullets, 1, -1 do
            if ( playerBullets[bulletCounter] == obj1 or playerBullets[bulletCounter] == obj2 ) then
                playerBullets[bulletCounter]:removeSelf()
                playerBullets[bulletCounter] = nil
                table.remove( playerBullets, bulletCounter )
                break
            end
        end

        -- set animation to dead
        anEnemy.sequence = "dead"
        anEnemy:setSequence( "dead" )
        anEnemy:play()

        -- fad character out before removing it
        transition.to( anEnemy, { time = 2000, x = x, y = y, alpha = 0 } )

        -- remove character after 1 second
        timer.performWithDelay( 3000, removeanEnemy )

        -- make an explosion sound effect
            local expolsionSound = audio.loadStream( "./assets/sounds/8bit_bomb_explosion.wav" )
            local explosionChannel = audio.play( expolsionSound )

            -- make an explosion happen
            -- Table of emitter parameters
            local emitterParams = {
                startColorAlpha = 1,
                startParticleSizeVariance = 250,
                startColorGreen = 0,
                yCoordFlipped = -1,
                blendFuncSource = 770,
                rotatePerSecondVariance = 153.95,
                particleLifespan = 0.7237,
                tangentialAcceleration = -1440.74,
                finishColorBlue = 1,
                finishColorGreen = 0,
                blendFuncDestination = 1,
                startParticleSize = 400.95,
                startColorRed = 0,
                textureFileName = "./assets/sprites/fire.png",
                startColorVarianceAlpha = 1,
                maxParticles = 256,
                finishParticleSize = 540,
                duration = 1.77,
                finishColorRed = 0,
                maxRadiusVariance = 77.25,
                finishParticleSizeVariance = 250,
                gravityy = -671.05,
                speedVariance = 90.79,
                tangentialAccelVariance = -420.11,
                angleVariance = -142.62,
                angle = -244.11
            }
            local emitter = display.newEmitter( emitterParams )
            emitter.x = whereCollisonOccurredX
            emitter.y = whereCollisonOccurredY

        end
    end
end
 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- start physics
    physics.start()
    physics.setGravity(0, 32)
    physics.setDrawMode( "normal" )


    local filename = "assets/maps/level13.json"
    local mapData = json.decodeFile( system.pathForFile( filename, system.ResourceDirectory ) ) 
    map = tiled.new( mapData, "assets/maps" )


    --our character
    local sheetOptionsIdle = require( "assets.spritesheets.robot.robotIdle" )
    local sheetIdleRobot = graphics.newImageSheet( "./assets/spritesheets/robot/robotIdle.png", sheetOptionsIdle:getSheet() )

    local sheetOptionsWalk = require( "assets.spritesheets.robot.robotRun" )
    local sheetWalkingRobot = graphics.newImageSheet( "./assets/spritesheets/robot/robotRun.png", sheetOptionsWalk:getSheet() )

    local sheetOptionsShoot = require( "assets.spritesheets.robot.robotShoot" )
    local sheetShootRobot = graphics.newImageSheet( "./assets/spritesheets/robot/robotShoot.png", sheetOptionsShoot:getSheet() )

    local sheetOptionsJump = require( "assets.spritesheets.robot.robotJump" )
    local sheetJumpRobot = graphics.newImageSheet( "./assets/spritesheets/robot/robotJump.png", sheetOptionsJump:getSheet() )

    local sheetOptionsJumpShoot = require( "assets.spritesheets.robot.robotJumpShoot" )
    local sheetJumpShootRobot = graphics.newImageSheet( "./assets/spritesheets/robot/robotJumpShoot.png", sheetOptionsJump:getSheet() )

    -- the enemy
    local sheetOptionsIdleZombie = require( "assets.spritesheets.zombieMale.zombieMaleIdle" )
    local sheetIdleZombie = graphics.newImageSheet( "./assets/spritesheets/zombieMale/zombieMaleIdle.png", sheetOptionsIdleZombie:getSheet() )

    local sheetOptionsDeadZombie = require( "assets.spritesheets.zombieMale.zombieMaleDead" )
    local sheetDeadZombie = graphics.newImageSheet( "./assets/spritesheets/zombieMale/zombieMaleDead.png", sheetOptionsDeadZombie:getSheet() )

    --sequences table
    local sequence_data = {
    -- consecutive frames sequence
        {

            name = "idle",
            start = 1,
            count = 10,
            time = 800,
            loopCount = 0,
            sheet = sheetIdleRobot
        },
        {

            name = "walk",
            start = 1,
            count = 10,
            time = 1000,
            loopCount = 1,
            sheet = sheetWalkingRobot
        },
        {

            name = "shoot",
            start = 1,
            count = 10,
            time = 800,
            loopCount = 0,
            sheet = sheetShootRobot
        },
        {

            name = "jump and shoot",
            start = 1,
            count = 10,
            time = 800,
            loopCount = 0,
            sheet = sheetJumpShootRobot
        },
        {

            name = "jump",
            start = 1,
            count = 10,
            time = 1000,
            loopCount = 1,
            sheet = sheetJumpRobot
        }
    }

    --sequences table
    local sequence_data2 = {
    -- consecutive frames sequence
        {

            name = "idle",
            start = 1,
            count = 10,
            time = 800,
            loopCount = 0,
            sheet = sheetIdleZombie
        },
        {

            name = "dead",
            start = 1,
            count = 10,
            time = 1000,
            loopCount = 1,
            sheet = sheetDeadZombie
        }
    }

    robot = display.newSprite( sheetIdleRobot, sequence_data )
    -- Add physics
    physics.addBody( robot, "dynamic", { density = 3, bounce = 0, friction = 1.0 } )
    robot.isFixedRotation = true
    robot.x = display.contentWidth * .5
    robot.y = 0
    robot:setSequence( "idle" )
    robot.sequence = "idle"
    robot:play()

    anEnemy = display.newSprite( sheetIdleZombie, sequence_data2 )
    -- Add physics
    physics.addBody( anEnemy, "dynamic", { density = 3, bounce = 0, friction = 1.0 } )
    anEnemy.isFixedRotation = true
    anEnemy.id = "zombie"
    anEnemy.sequence = "idle"
    anEnemy.x = display.contentWidth - 250
    anEnemy.y = display.contentCenterY
    anEnemy:setSequence( "idle" )
    anEnemy:play()

    rightArrow = display.newImage( "./assets/sprites/rightButton.png" )
    rightArrow.x = 260
    rightArrow.y = display.contentHeight - 177
    rightArrow.id = "right arrow"
    rightArrow.alpha = 0.5

    jumpButton = display.newImage( "./assets/sprites/jumpButton.png" )
    jumpButton.x = display.contentWidth - 80
    jumpButton.y = display.contentHeight - 80
    jumpButton.id = "jump button"
    jumpButton.alpha = 0.5

    shootButton = display.newImage( "./assets/sprites/jumpButton.png" )
    shootButton.x = display.contentWidth - 277
    shootButton.y = display.contentHeight - 80
    shootButton.id = "shoot button"
    shootButton.alpha = 0.5

    sceneGroup:insert( map )
    sceneGroup:insert( robot )
    sceneGroup:insert( anEnemy )
    sceneGroup:insert( rightArrow )
    sceneGroup:insert( jumpButton )
    sceneGroup:insert( shootButton )
    
 
    end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- add in code to check character movement
        sceneGroup:insert( rightArrow )

        rightArrow:addEventListener( "touch", onRightArrowTouch )
        jumpButton:addEventListener( "touch", onJumpButtonTouch )
        shootButton:addEventListener( "touch", onShootButtonTouch )  
        
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        Runtime:addEventListener( "enterFrame", moveRobot )
        Runtime:addEventListener( "enterFrame", checkPlayerBulletisOutOfBounds )
        Runtime:addEventListener( "collision", enemyShot )
    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen

        -- good practise to remove every event listener you create
        rightArrow:removeEventListener( "touch", onRightArrowTouch )
        jumpButton:removeEventListener( "touch", onJumpButtonTouch )
        shootButton:removeEventListener( "touch", onShootButtonTouch )

        Runtime:removeEventListener( "enterFrame", moveRobot )
        Runtime:removeEventListener( "enterFrame", checkPlayerBulletisOutOfBounds )
        Runtime:removeEventListener( "collision", enemyShot )
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
