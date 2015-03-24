local gamestate = require("gamestate")
local player = require("player")
local mook = require("mook")
local settings = require("settings")
local Control = require("control")

local playstate = {}

playstate.new = function(self,name)
	local _playstate = gamestate:new(name or "level1")
	setmetatable(_playstate,{__index = self})
	return _playstate
end

playstate.initialize = function(self)
	self.pause = false
	self.ended = false
	self.tutorial = false
	
	self.totalTime = 0
	
	self.stateChangeTimer = 0
	self.mookSpawnTimer = 0
	self.score = 0
	self.scoreOptimal = 0
	self.performance = 0
	self.performanceSum = 0
	self.performancePoints = 0
	self.scoreTimer = 0
	self.slow = 1
	self.multiplier = 1

	self.music = {}
	self.graphics = {}

	self.joystick = love.joystick.getJoysticks()[1]

	self.width, self.height = love.graphics.getDimensions()
	self.R,self.G,self.B,self.A = love.graphics.getColor()

	local rb = 205
	local gb = 201
	local bb = 201
	love.graphics.setBackgroundColor(rb,gb,bb)

	self.graphics.background = love.graphics.newImage("background.png")

	self.graphics.player = {}
	self.graphics.player.red = love.graphics.newImage("player-red.png")
	self.graphics.player.green = love.graphics.newImage("player-green.png")
	self.graphics.player.blue = love.graphics.newImage("player-blue.png")
	self.graphics.mook = {}
	self.graphics.mook.red = love.graphics.newImage("mook-red.png")
	self.graphics.mook.green = love.graphics.newImage("mook-green.png")
	self.graphics.mook.blue = love.graphics.newImage("mook-blue.png")

	self.music = love.audio.newSource("biisi.mp3")
	self.music:play()
	self.music:setLooping(true)

	love.mouse.setVisible(false)

	self.players = {}
	self.mooks = {}

	mook:refreshTypeQueue()

	table.insert(self.players,player:new(self.width/2,self.height/2,"red",Control:new("right",self.joystick),self))
	--table.insert(self.players,player:new(self.width/2+50,self.height/2+50,"green",Control:new("left",self.joystick),self))

	for _,t in pairs(player.states) do
		table.insert(self.mooks,self:randomNewMook(t))
	end

end

playstate.terminate = function(self)
	self.music:stop()
end

playstate.keypressed = function(self, key, isrepeat )
	if key == "r" and self.ended then
		self:restart()
	elseif key == "escape" then
		self.manager:switchToState(self.manager.states["mainmenu"])
		--print("Bye!")
		--love.event.quit()
	elseif key == " " then
		if self.slow == 1 then
			self.slow = 0.5
		else
			self.slow = 1
		end
	elseif key == "p" and not self.ended and not self.tutorial then
		self.pause = not self.pause
	elseif key == "t" and not self.ended then
		if not self.tutorial then
			self.tutorial = true
			self.pause = true
		else
			self.tutorial = false
			self.pause = false
		end
	elseif key == "m" then
		if self.music:isPlaying() then
			self.music:pause()
		else
			self.music:play()
		end
	end
end

playstate.gamepadpressed = function(self,joystick,button)
	if button == "a" and self.ended then
		self:restart()
	elseif button == "b" then
		self.manager:switchToState(self.manager.states["mainmenu"])
	end
end

playstate.update = function(self,dt)
	if not self.pause then
		self.totalTime = self.totalTime + dt
		--self.slow = 1-0.45*(self.joystick:getGamepadAxis( "triggerright" )+self.joystick:getGamepadAxis( "triggerleft" ))
		dt = self.slow * dt
		self:updateMultiplier(dt)
		self:updateScore(dt)
		self.mookSpawnTimer = self.mookSpawnTimer + dt
		if self.mookSpawnTimer > settings.mookSpawnMaxTime then
			table.insert(self.mooks,self:randomNewMook())
			self.mookSpawnTimer = 0
		end
		for i=1,#self.players do
			self.players[i]:update(dt)
		end
		for k,m in pairs(self.mooks) do
			for i=1,#self.players do
				if self.collide(self.players[i],m) then
					self:endgame()
					break
				end
			end
			m:update(dt)
		end
	end
end

playstate.draw = function(self)
	self:drawBackground()
	self:drawEntities()
	self:drawUI()
end

playstate.drawBackground = function(self)
end

playstate.drawEntities = function(self)
	for i=1,#self.mooks do
		self.mooks[i]:draw()
	end
	for i=1,#self.players do
		self.players[i]:draw()
	end
end

playstate.drawUI = function(self)
	self:displayScore()
	self:displayPerformance()
	self:drawMultiplier()
	if self.ended then
		self:drawDeathScreen()
	end
	self:drawTutorial()
	love.graphics.setColor(self.R,self.G,self.B,self.A)
end

playstate.randomNewMook = function(self,color)
	local found = false
	local x = 0
	local y = 0
	while not found do
		found = true
		x = math.random(0,self.width)
		for i=1,#self.players do
			if math.abs(x-self.players[i].x) < 150 then
				found = false
				break
			end
		end
	end
	found = false
	while not found do
		found = true
		y = math.random(0,self.height)
		for i=1,#self.players do
			if math.abs(y-self.players[i].y) < 150 then
				found = false
				break
			end
		end
	end
	local _color = color
	if not _color then
		local index = math.random(1,#mook.typeQueue)
		_color = mook.typeQueue[index]
		table.remove(mook.typeQueue,index)
		if #mook.typeQueue == 0 then
			mook:refreshTypeQueue()
		end
	end
	return mook:new(x,y,_color,self)
end

playstate.collide = function(entity1,entity2)
	local radius = 20
	local dx = entity1.x - entity2.x
	local dy = entity1.y - entity2.y
	if dx*dx+dy*dy <= radius*radius then
		return true
	end
	return false
end

playstate.updateScore = function(self,dt)
	self.scoreTimer = self.scoreTimer + dt
	if self.scoreTimer > 0.1 then
		self.score = self.score + #self.mooks*self.multiplier
		self.scoreOptimal = self.scoreOptimal + #self.mooks*settings.multiplierMax
		self.performance = self.score/self.scoreOptimal
		if self.totalTime > settings.performanceGraceTime then
			self.performanceSum = self.performanceSum + self.performance
			self.performancePoints = self.performancePoints + 1
		end
		self.scoreTimer = 0
	end
end

playstate.displayScore = function(self)
	love.graphics.setColor(255,0,0)
	love.graphics.print(string.format("SCORE: %d",self.score),5,self.height-15)
end

playstate.displayPerformance = function(self)
	love.graphics.setColor(255,0,0)
	love.graphics.print(string.format("Performance: %.2f",self.performance),5,self.height-30)
end

playstate.endgame = function(self)
	self.pause = true
	self.ended = true
	self.music:setVolume(0.5)
end

playstate.restart = function(self)
	self.pause = false
	self.ended = false
	self.players[1].x = self.width/2
	self.players[1].y = self.height/2
	self.players[1].state = "red"
	self.players[1].stateChangeTimer = 0
	if #self.players > 1 then
		self.players[2].x = self.width/2+50
		self.players[2].y = self.height/2+50
		self.players[2].state = "green"
		self.players[2].stateChangeTimer = 0
	end
	self.mooks = {}
	for _,t in pairs(player.states) do
		table.insert(self.mooks,self:randomNewMook(t))
	end
	mook:refreshTypeQueue()
	self.mookSpawnTimer = 0
	self.stateChangeTimer = 0
	self.score = 0
	self.scoreOptimal = 0
	self.performance = 0
	self.performanceSum = 0
	self.performancePoints = 0
	self.slow = 1
	self.multiplier = 1
	self.music:setVolume(1)
	self.totalTime = 0
end

playstate.updateMultiplier = function(self,dt)
	local minSame = self.width*self.height
	local minOther = self.width*self.height
	--[[
	for _, M in pairs(mooks) do
		local dx = player.x-M.x
		local dy = player.y-M.y
		local dist = math.sqrt(dx * dx + dy * dy)
		if M.type ~= player.state then
			minOther = math.min(dist,minOther)
		else
			minSame = math.min(dist,minSame)
		end
	end
	]]--
	minSame = math.max(minSame,settings.multiplierMinDistance)
	minOther = math.max(minOther,settings.multiplierMinDistance)
	--multiplier = multiplier + multiplierChangeRate * (multiplierGrowthAdvantage*(1/minSame) - (1/minOther)) * dt
	self.multiplier = self.multiplier + ((settings.multiplierChangeRate/minSame)-settings.multiplierDecreaseSpeed) * dt
	self.multiplier = math.max(self.multiplier,settings.multiplierMin)
	self.multiplier = math.min(self.multiplier,settings.multiplierMax)
end

playstate.drawMultiplier = function(self)
	local w = 30
	local h = 10+100*(self.multiplier-settings.multiplierMin)/(settings.multiplierMax-1)

	local x = self.width-40
	local y = 60+(110-h)

	love.graphics.setColor(255,0,0)
	local ratio = (self.multiplier-settings.multiplierMin)/(settings.multiplierMax-settings.multiplierMin)
	if ratio > 0.3 then
		love.graphics.setColor(255,255,0)
	end
	if ratio > 0.5 then
		love.graphics.setColor(0,255,0)
	end
	if ratio > 0.8 then
		love.graphics.setColor(255,0,255)
	end
	love.graphics.rectangle("fill",x,y,w,h)
	love.graphics.print(string.format("x%.1f",self.multiplier),self.width-50,180)
	love.graphics.setColor(self.R,self.G,self.B,self.A)	
end


playstate.drawDeathScreen = function(self)
	love.graphics.setColor(0,0,0,127)
	love.graphics.rectangle("fill",0,0,self.width,self.height)
	love.graphics.setColor(255,0,0)
	love.graphics.printf("Game ended!",self.width/3,self.height/2,self.width/3,"center")
	love.graphics.printf("Press [r] to restart.",self.width/3,self.height/2+20,self.width/3,"center")
	love.graphics.printf(string.format("Final score: %d",self.score),self.width/3,self.height/2+40,self.width/3,"center")
	local performanceAverage = 0
	local grade = "D"
	if self.performancePoints > 0 then
		performanceAverage = self.performanceSum/self.performancePoints
	else
		grade = "-"
	end
	if performanceAverage > 0.95 then
		grade = "AAA"
	elseif performanceAverage > 0.93 then
		grade = "AA"
	elseif performanceAverage > 0.9 then
		grade = "A"
	elseif performanceAverage > 0.8 then
		grade = "B"
	elseif performanceAverage > 0.7 then
		grade = "C"
	end
	love.graphics.printf(string.format("Grade: %s",grade),self.width/3,self.height/2+60,self.width/3,"center")
end

playstate.drawTutorial = function(self)
	if self.tutorial then
		love.graphics.setColor(0,0,0,64)
	love.graphics.rectangle("fill",50,30,self.width-100,self.height-200)
		love.graphics.setColor(255,255,255)
		love.graphics.printf(settings.tutorialText,0,40,self.width,"center")
	else
		love.graphics.setColor(255,255,255)
		love.graphics.printf("Press [t] for tutorial.",0,10,self.width,"center")
	end
end




return playstate