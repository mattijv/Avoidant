local playstate = require("playstate")
local survival = require("survivelevel")
local mainmenu = require("mainmenu")
local playersselection = require("playersselection")
local options = require("optionsmenu")
local highscorescreen = require("highscores")
local tutorial = require("tutorialstate")
local statemanager = require("statemanager")
local fonts = require("fonts")
local settings = require("settings")


function love.load()
	math.randomseed(os.time())
	love.mouse.setVisible(false)
	width, height = settings.width,settings.height
	_,__,flags = love.window.getMode()
	--nativewidth,nativeheight = love.window.getDesktopDimensions()
	nativewidth = 1920
	nativeheight = 1080
	love.window.setMode(nativewidth,nativeheight,flags)
	R,G,B,A = love.graphics.getColor()
	fps = 0
	screenw,screenh = love.graphics.getDimensions()
	scalex = screenw/width
	scaley = screenh/height

	scorefilename = "highscores.txt"
	if not love.filesystem.exists(scorefilename) then
		scorefile = love.filesystem.newFile(scorefilename)
		scorefile:open("w")
		scorefile:write("Avoidant High Scores\n")
		scorefile:close()
	end
	music = love.audio.newSource("DN38416.mp3")
	music:play()
	music:setVolume(0.5)
	music:setLooping(true)
	
	manager = statemanager:new()

	manager:addState(mainmenu:new("mainmenu"))
	manager:addState(survival:new("level1"))
	manager:addState(playersselection:new("nplayers"))
	manager:addState(options:new("options"))
	manager:addState(highscorescreen:new("highscores"))
	manager:addState(tutorial:new("tutorial"))
	manager:switchToState(manager.states["mainmenu"])
	
end



function drawFPSMeter()
	love.graphics.setColor(255,0,0)
	love.graphics.setFont(fonts.fpsmeter)
	love.graphics.print(string.format("FPS: %.0f",fps),5,5)
	love.graphics.setColor(R,G,B,A)
end


function love.update(dt)
	fps = 1.0/dt
	manager.currentState:update(dt)
end

function love.draw()
	local screenw,screenh = love.graphics.getDimensions()
	local scalex = screenw/width
	local scaley = screenh/height
	love.graphics.push()
	love.graphics.scale(scalex,scaley)
	manager.currentState:draw()
	--drawFPSMeter()
	love.graphics.pop()
	love.graphics.setColor(R,G,B,A)
end

function love.keypressed(key,isrepeat)
	if key == "m" then
		if music:isPlaying() then
			music:pause()
		else
			music:play()
		end
	else
		manager.currentState:keypressed(key,isrepeat)
	end
end

function love.gamepadpressed(joystick, button)
	manager.currentState:gamepadpressed(joystick,button)
end