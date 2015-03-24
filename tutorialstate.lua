local gamestate = require("gamestate")
local player = require("player")
local mook = require("mook")
local settings = require("settings")
local Control = require("control")
local gradient = require("gradient")
local fonts = require("fonts")

local tutorialstate = {}

tutorialstate.new = function(self,name)
	local _tutorialstate = gamestate:new(name or "level1")
	setmetatable(_tutorialstate,{__index = self})
	return _tutorialstate
end

tutorialstate.initialize = function(self)
	self.pause = false
	self.tutorial = false
	self.ended = false
	
	self.totalTime = 0
	self.nearTime = {}
	self.nearTime[1] = 0
	self.nearTime[2] = 0
	self.winTime = 30
	self.win = false

	self.backgroundTimer = 0

	self.distClosestSame = {}
	self.distClosestSame[1] = 0
	self.distClosestSame[2] = 0
	self.distClosestOther = {}
	self.distClosestOther[1] = 0
	self.distClosestOther[2] = 0

	self.colors = {}
	self.colors.red = {255,0,0}
	self.colors.green = {0,255,0}
	self.colors.blue = {0,0,255}
	
	--self.stateChangeTimer = 0
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

	self.scorefile = love.filesystem.newFile(scorefilename)
	self.highscores = {}
	local bool, err = self.scorefile:open("r")
	if not bool then
		print("Unable to open high score file: "..err)
		print("Score will not be saved.")
	else
		for line in self.scorefile:lines() do
			if line ~= "Avoidant High Scores\n" then
				table.insert(self.highscores,tonumber(line))
			end
		end
	end
	self.scorefile:close()

	self.width, self.height = settings.width,settings.height
	self.R,self.G,self.B,self.A = love.graphics.getColor()
	self.bloom = love.graphics.newShader("bloom.shader")
	self.canvas = love.graphics.newCanvas(self.width,self.height)
	self.bloomcanvas = love.graphics.newCanvas(self.width/2,self.height/2)

	self.shader = true

	local rb = 32
	local gb = 32
	local bb = 32
	love.graphics.setBackgroundColor(rb,gb,bb)
	--love.graphics.setBackgroundColor(255,255,255)

	self.homes = {}

	for i,c in pairs(player.states) do
		local home = {}
		home.x = self.width/2 + 0.33*self.height*math.cos((i-1)*2*math.pi/3 - math.pi/2)
		home.y = self.height/2 - 0.33*self.height*math.sin((i-1)*2*math.pi/3 - math.pi/2)
		home.color = self.colors[c]
		self.homes[c] = home
	end

	self.homeSpin = 0

	self.tutorialText = ""
	self.tutorialStep = 1
	self.tutorialSteps[self.tutorialStep](self)
	self.playerMovement = true
	self.enemyMovement = true
	self.effects = false
	self.checkForWin = false


	--[[
	self.graphics.background = love.graphics.newImage("background.png")

	self.graphics.player = {}
	self.graphics.player.red = love.graphics.newImage("player-red.png")
	self.graphics.player.green = love.graphics.newImage("player-green.png")
	self.graphics.player.blue = love.graphics.newImage("player-blue.png")
	self.graphics.mook = {}
	self.graphics.mook.red = love.graphics.newImage("mook-red.png")
	self.graphics.mook.green = love.graphics.newImage("mook-green.png")
	self.graphics.mook.blue = love.graphics.newImage("mook-blue.png")

	]]--

	love.mouse.setVisible(false)

	self.players = {}
	self.mooks = {}

	mook:refreshTypeQueue()

	table.insert(self.players,player:new(self.width/2+20,self.height/2,"red",Control:new("right",self.joystick),self,1))

	--for _,c in pairs(mook.types) do
	--	table.insert(self.mooks,mook:new(self.homes[c].x,self.homes[c].y,c,self))
	--end

end

tutorialstate.terminate = function(self)
	self.scorefile:close()
end

tutorialstate.keypressed = function(self, key, isrepeat )
	if key == "f" then
		self.shader = not self.shader
	elseif key == "return" then
		if self.ended then
			self.manager:switchToState(self.manager.states["mainmenu"])
		else
			if self.tutorialStep < 7 then
				self.tutorialStep = self.tutorialStep + 1
				self.tutorialSteps[self.tutorialStep](self)
			end
		end
	elseif key == "escape" then
		self.manager:switchToState(self.manager.states["mainmenu"])
		--print("Bye!")
		--love.event.quit()
	end
end

tutorialstate.gamepadpressed = function(self,joystick,button)
	if button == "a" then
		if self.ended then
			self.manager:switchToState(self.manager.states["mainmenu"])
		else
			if self.tutorialStep < 7 then
				self.tutorialStep = self.tutorialStep + 1
				self.tutorialSteps[self.tutorialStep](self)
			end
		end
	elseif button == "b" then
		self.manager:switchToState(self.manager.states["mainmenu"])
	end
end

tutorialstate.update = function(self,dt)
	if not self.pause then
		self.totalTime = self.totalTime + dt
		--self.slow = 1-0.45*(self.joystick:getGamepadAxis( "triggerright" )+self.joystick:getGamepadAxis( "triggerleft" ))
		dt = self.slow * dt
		---self:updateMultiplier(dt)
		--self:updateScore(dt)
		self:updateHomes(dt)
		self.backgroundTimer = self.backgroundTimer + dt
		--self.mookSpawnTimer = self.mookSpawnTimer + dt
		for i=1,#self.players do
			if self.nearTime[i] >= self.winTime and self.checkForWin then
				self.win = true
				self:endgame()
				return
			end
			if self.playerMovement then
				self.players[i]:update(dt,true)
			end
		end
		if self.enemyMovement then
			for k,m in pairs(self.mooks) do
				for i=1,#self.players do
					if not self.players[i].dead then
						if self.collide(self.players[i],m) then
							--self:endgame()
							self.players[i].dead = true
							self.players[i].stateChangeTimer = math.max(self.players[i].stateChangeTimer - 1,0)
							self.nearTime[i] = math.max(self.nearTime[i]-settings.timePenalty,0)
						end
					end
				end
				m:update(dt)
			end
		end
		for i=1,#self.players do
			self.distClosestSame[i], self.distClosestOther[i] = self:distToClosest(self.players[i])
		end
		self:decreaseNearTime(dt)
	end
end

tutorialstate.draw = function(self)
	
	if self.shader then
		self.canvas:clear()
		self.bloomcanvas:clear()
		
		love.graphics.setCanvas(self.canvas)
		love.graphics.push()
		love.graphics.origin()
		self:drawBackground()
		self:drawEntities()
		self:drawEffects()
		

		love.graphics.setCanvas(self.bloomcanvas)
		love.graphics.scale(0.5,0.5)
		love.graphics.draw(self.canvas,0,0)

		love.graphics.setBlendMode("screen")
		self.bloom:send("size",{self.width/2,self.height/2})
		--self.bloom:sendInt("samples",10)
		self.bloom:send("quality",0.6)
		love.graphics.setCanvas(self.canvas)
		love.graphics.setShader(self.bloom)
		love.graphics.origin()
		love.graphics.scale(2,2)
		love.graphics.draw(self.bloomcanvas,0,0)
		
		--love.graphics.setBlendMode("alpha")
		love.graphics.pop()
		love.graphics.setCanvas()
		love.graphics.draw(self.canvas,0,0)
		
		love.graphics.setShader()
		love.graphics.setBlendMode("alpha")
	else
		self:drawBackground()
		self:drawEntities()
		self:drawEffects()
	end
	self:drawUI()
end

tutorialstate.randomNewMook = function(self,color)
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
	local v_x = math.random(-50,50)
	local v_y = math.random(-50,50)
	return mook:new(x,y,_color,self,v_x,v_y)
end

tutorialstate.collide = function(entity1,entity2)
	local radius = 16
	local dx = entity1.x - entity2.x
	local dy = entity1.y - entity2.y
	if dx*dx+dy*dy <= radius*radius then
		return true
	end
	return false
end



tutorialstate.endgame = function(self)
	self.pause = true
	self.ended = true
end

tutorialstate.restart = function(self)
	self.pause = false
	self.ended = false
	for i=1,#self.players do
		self.players[i].x = self.width/2-40*i+20
		self.players[i].y = self.height/2
		self.players[i].state = "red"
		self.players[i].stateChangeTimer = 0
		self.players[i].dead = false
		self.players[i].deadTimer = 0
	end
	for i,c in pairs(player.states) do
		local home = {}
		home.x = self.width/2 + 0.33*self.height*math.cos((i-1)*2*math.pi/3 - math.pi/2)
		home.y = self.height/2 - 0.33*self.height*math.sin((i-1)*2*math.pi/3 - math.pi/2)
		home.color = self.colors[c]
		self.homes[c] = home
	end
	self.mooks = {}
	for _,c in pairs(mook.types) do
		table.insert(self.mooks,mook:new(self.homes[c].x,self.homes[c].y,c,self))
	end
	mook:refreshTypeQueue()
	for i=1,#self.players do
		self.nearTime[i] = 0
	end
	self.win = false
	self.mookSpawnTimer = 0
	self.stateChangeTimer = 0
	self.score = 0
	self.scoreOptimal = 0
	self.performance = 0
	self.performanceSum = 0
	self.performancePoints = 0
	self.slow = 1
	self.totalTime = 0
	self.backgroundTimer = 0
end

tutorialstate.updateHomes = function(self,dt)
	self.homeSpin = self.homeSpin+dt
	local angle = math.pi/10*self.homeSpin
	for i,c in pairs(player.states) do
		local home = {}
		home.x = self.width/2+0.25*self.height*math.cos((i-1)*2*math.pi/3 - math.pi/2+angle)
		home.y = self.height/2-0.25*self.height*math.sin((i-1)*2*math.pi/3 - math.pi/2+angle)
		home.color = self.colors[c]
		self.homes[c] = home
	end
end

tutorialstate.decreaseNearTime = function(self,dt)
	local minDist = settings.scoreMinDistance
	local maxDist = settings.scoreMaxDistance

	for i=1,#self.players do
		if not self.players[i].dead then
			local minSame = self.distClosestSame[i]
			if minSame <= maxDist then
				minSame = math.max(minSame,minDist)
				local k = -1/(maxDist-minDist)
				local delta = dt*k*(minSame-maxDist)
				self.nearTime[i] = math.min(self.nearTime[i] + delta,self.winTime)
				self.mookSpawnTimer = self.mookSpawnTimer + delta
			end
		end
	end
end

tutorialstate.distToClosest = function(self,origin)
	local minSame = self.width*self.height
	local minOther = self.width*self.height
	for _, M in pairs(self.mooks) do
		local dx = origin.x-M.x
		local dy = origin.y-M.y
		local dist = math.sqrt(dx * dx + dy * dy)
		if M.type == origin.state then
			minSame = math.min(dist,minSame)
		else
			minOther = math.min(dist,minOther)
		end
	end
	return minSame, minOther
end

tutorialstate.positionOfClosestSame = function(self,origin)
	local minSame = self.width*self.height
	local pos = {}
	pos.x = 0
	pos.y = 0
	for _, M in pairs(self.mooks) do
		local dx = origin.x-M.x
		local dy = origin.y-M.y
		local dist = math.sqrt(dx * dx + dy * dy)
		if M.type == origin.state then
			minSame = math.min(dist,minSame)
			if dist == minSame then
				pos.x = M.x
				pos.y = M.y
			end
		end
	end
	return pos
end



tutorialstate.drawTutorial = function(self)
	love.graphics.setFont(fonts.tutorial)
	love.graphics.setColor(255,255,255)
	love.graphics.printf(self.tutorialText,0,self.height-100,self.width,"center")
	love.graphics.printf("Press A on the gamepad or return on the keyboard to advance the tutorial.\nPress B or escape to quit the tutorial.",0,50,self.width,"center")
end


tutorialstate.drawWinScreen = function(self)
	love.graphics.setColor(0,0,0,127)
	love.graphics.rectangle("fill",0,0,self.width,self.height)
	love.graphics.setColor(0,255,0)
	love.graphics.setFont(fonts.mainmenu)
	if #self.players > 1 then
		for i=1,#self.nearTime do
			if self.nearTime[i] == self.winTime then
				love.graphics.printf(string.format("Player %d wins!",i),self.width/3,self.height/2,self.width/3,"center")
			end
		end
	else
		love.graphics.printf("You win!",self.width/3,self.height/2,self.width/3,"center")
	end
	--love.graphics.printf(string.format("Total time: %.2f seconds",self.totalTime),self.width/4,self.height/2+20,self.width/2,"center")
	love.graphics.printf("Press A or return to quit the tutorial.",self.width/3,self.height/2+40,self.width/3,"center")
end

tutorialstate.displayScore = function(self)
	love.graphics.setColor(255,0,0)
	love.graphics.print(string.format("SCORE: %d",self.score),5,self.height-15)
end

tutorialstate.displayPerformance = function(self)
	love.graphics.setColor(255,0,0)
	love.graphics.print(string.format("Performance: %.2f",self.performance),5,self.height-30)
end

tutorialstate.drawBackground = function(self)
	
	--for _,h in pairs(self.homes) do
	--	love.graphics.setColor(h.color)
	--	love.graphics.circle("fill",h.x,h.y,5,20)
	--end
	local npoints = 60
	local sin = math.sin(2*math.pi*self.backgroundTimer/30+math.pi)
	local spread = (1+0.5*sin)*self.width
	--local timeratio = (self.winTime-self.nearTime[#self.players])/self.winTime
	--local spread = self.width
	--top left
	local xpoints = {}
	local ypoints = {}
	local originx = 0
	local originy = 0
	for i=1,npoints do
		table.insert(xpoints,originx+i*spread/npoints)
		table.insert(ypoints,originy+i*spread/npoints)
	end
	love.graphics.setColor(0,255,255,15)
	for i=1,#xpoints do
		love.graphics.line(xpoints[i],originy,originx,ypoints[#ypoints-i+1])
	end

	--bottom right
	sin = math.sin(2*math.pi*self.backgroundTimer/30+math.pi)
	spread = (1+0.5*sin)*self.width
	xpoints = {}
	ypoints = {}
	originx = self.width
	originy = self.height
	for i=1,npoints do
		table.insert(xpoints,originx-i*spread/npoints)
		table.insert(ypoints,originy-i*spread/npoints)
	end
	love.graphics.setColor(255,255,0,15)
	for i=1,#xpoints do
		love.graphics.line(xpoints[i],originy,originx,ypoints[#ypoints-i+1])
	end

end

tutorialstate.drawEntities = function(self)
	for i=1,#self.mooks do
		self.mooks[i]:draw()
	end
	for i=1,#self.players do
		self.players[i]:draw()
	end
	love.graphics.setColor(self.R,self.G,self.B,self.A)
end

tutorialstate.drawEffects = function(self)
	if self.effects then
		for i=1,#self.players do
			if not self.players[i].dead then
				if self.distClosestSame[i] <= settings.scoreMaxDistance then
					local pos = self:positionOfClosestSame(self.players[i])
					local x = self.players[i].x
					local y = self.players[i].y
					local N = 1
					local jitter = 7
					love.graphics.setColor(255,255,255)
					if self.distClosestSame[i] <= settings.scoreMinDistance+0.5*(settings.scoreMaxDistance-settings.scoreMinDistance) then
						love.graphics.setColor(255, 255, 127)
						N = 2
						jitter = 6
					end
					if self.distClosestSame[i] <= settings.scoreMinDistance then
						love.graphics.setColor(0,255,255)
						N = 3
						jitter = 5
					end
					local spread = 10-jitter
					for j=1,N do
						love.graphics.line(lightningPoints(x,y,pos.x+math.random(-spread,spread),pos.y+math.random(-spread,spread),6,jitter))
					end
					love.graphics.setColor(self.R,self.G,self.B,self.A)
				end
			end
		end
	end
	love.graphics.setColor(self.R,self.G,self.B,self.A)
end

tutorialstate.drawUI = function(self)
	--self:displayScore()
	--self:displayPerformance()
	--self:drawTimeLeft()
	if self.ended then
		if not self.win then
			self:drawDeathScreen()
		else
			self:drawWinScreen()
		end
	end
	self:drawTutorial()
	love.graphics.setColor(self.R,self.G,self.B,self.A)
end

tutorialstate.tutorialSteps = {}

tutorialstate.tutorialSteps[1] = function(self)
	self.mooks = {}
	self.players = {}
	table.insert(self.players,player:new(self.width/2+20,self.height/2,"red",Control:new("right",self.joystick),self,1))
	self.tutorialText = "Use the gamepad stick or keyboard arrows to move."
end

tutorialstate.tutorialSteps[2] = function(self)
	self.mooks = {}
	self.players = {}
	table.insert(self.players,player:new(self.width/2+20,self.height/2,"red",Control:new("right",self.joystick),self,1))
	self.tutorialText = "You can also use space or gamepad trigger to get extra speed."
end

tutorialstate.tutorialSteps[3] = function(self)
	self.mooks = {}
	for _,c in pairs(mook.types) do
		table.insert(self.mooks,mook:new(self.homes[c].x,self.homes[c].y,"green",self))
	end
	self.players = {}
	settings.scoreMaxDistance = -1
	self.changeState = false
	table.insert(self.players,player:new(self.width/2+20,self.height/2,"red",Control:new("right",self.joystick),self,1))
	self.tutorialText = "Avoid touching the enemies.\nYou can't die, but hitting an enemy will disable you for a second."
end

tutorialstate.tutorialSteps[4] = function(self)
	self.mooks = {}
	for _,c in pairs(mook.types) do
		table.insert(self.mooks,mook:new(self.homes[c].x,self.homes[c].y,c,self))
	end
	self.players = {}
	settings.scoreMaxDistance = -1
	self.effects = false
	table.insert(self.players,player:new(self.width/2+20,self.height/2,"red",Control:new("right",self.joystick),self,1))
	self.tutorialText = "Enemies that are different shape will try to get you.\nEnemies of same shape will try to avoid you."
end

tutorialstate.tutorialSteps[5] = function(self)
	self.mooks = {}
	table.insert(self.mooks,mook:new(self.width/2-50,self.height/2,"red",self))
	self.mooks[1].scared = true
	self.players = {}
	settings.scoreMaxDistance = 200
	table.insert(self.players,player:new(self.width/2+50,self.height/2,"red",Control:new("right",self.joystick),self,1))
	self.playerMovement = false
	self.enemyMovement = false
	self.effects = true
	self.tutorialText = "You collect energy while near enemies of the same shape."
end

tutorialstate.tutorialSteps[6] = function(self)
	self.mooks = {}
	self.nearTime[1] = 0
	table.insert(self.mooks,mook:new(self.width/2-20,self.height/2,"red",self))
	self.mooks[1].scared = true
	self.players = {}
	settings.scoreMaxDistance = 200
	self.winTime = 20
	table.insert(self.players,player:new(self.width/2+20,self.height/2,"red",Control:new("right",self.joystick),self,1))
	self.playerMovement = false
	self.enemyMovement = false
	self.effects = true
	self.tutorialText = "The closer you are to the enemies, the faster you collect the energy."
end


tutorialstate.tutorialSteps[7] = function(self)
	self.mooks = {}
	self.nearTime[1] = 0
	table.insert(self.mooks,mook:new(self.width/2-20,self.height/2,"red",self))
	self.mooks[1].scared = true
	self.players = {}
	settings.scoreMaxDistance = 100
	self.winTime = 5
	table.insert(self.players,player:new(self.width/2+20,self.height/2,"red",Control:new("right",self.joystick),self,1))
	self.playerMovement = false
	self.enemyMovement = false
	self.effects = true
	self.checkForWin = true
	self.tutorialText = "Fill the meter around you to win.\nYour aim is to be as fast as possible and highscores are the quickest times."
end



function lightningPoints(x1,y1,x2,y2,N,jitter)
	local points = {x1,y1}
	local dx = (x2-x1)/(N+1)
	local dy = (y2-y1)/(N+1)
	local perpx = dy
	local perpy = -dx
	local perpnorm = math.sqrt(perpx*perpx+perpy*perpy)
	perpx = perpx/perpnorm
	perpy = perpy/perpnorm

	for i=1,N do
		local px = points[#points-1]
		local py = points[#points]
		table.insert(points,px+dx)
		table.insert(points,py+dy)
	end
	for i=3,#points-1,2 do
		local px = points[i]
		local py = points[i+1]
		local disp = jitter*(1-2*math.random())
		px = px+perpx*disp
		py = py+perpy*disp
		points[i] = px
		points[i+1] = py
	end
	table.insert(points,x2)
	table.insert(points,y2)
	return points
end


return tutorialstate