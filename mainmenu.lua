local gamestate = require("gamestate")
local fonts = require("fonts")
local settings = require("settings")

local mainmenustate = {}

mainmenustate.new = function(self,name)
	local _playstate = gamestate:new(name or "mainmenu")
	setmetatable(_playstate,{__index = self})
	return _playstate
end

mainmenustate.initialize = function(self)
	self.width, self.height = settings.width,settings.height
	self.R,self.G,self.B,self.A = love.graphics.getColor()

	self.pointTimer = 0
	self.tutorial = false
	local rb = 32
	local gb = 32
	local bb = 32
	love.graphics.setBackgroundColor(rb,gb,bb)
	self.options = {}
	self.options[1] = "New game"
	self.options[2] = "Tutorial"
	self.options[3] = "Options"
	self.options[4] = "High scores"
	self.options[5] = "Quit"
	self.actions = {}
	self.actions[1] = function()
		self.manager:switchToState(self.manager.states["nplayers"])
	end
	self.actions[2] = function()
		self.manager:switchToState(self.manager.states["tutorial"])
	end
	self.actions[3] = function()
		self.manager:switchToState(self.manager.states["options"])
	end
	self.actions[4] = function()
		self.manager:switchToState(self.manager.states["highscores"])
	end
	self.actions[5] = function()
		print("Bye!")
		love.event.quit()
	end
	self.selected = 1
end

mainmenustate.terminate = function(self)
end

mainmenustate.update = function(self,dt)
	self.pointTimer = self.pointTimer + dt
end

mainmenustate.draw = function(self)
	--love.graphics.draw(self.background,0,0)
	local npoints = math.min(math.floor(self.pointTimer*30),38)+2
	local spread = self.width/2
	--top left
	local xpoints = {}
	local ypoints = {}
	local originx = 0
	local originy = 0
	for i=1,npoints do
		table.insert(xpoints,originx+i*spread/npoints+10*math.sin(2*math.pi*self.pointTimer/20))
		table.insert(ypoints,originy+i*spread/npoints+10*math.sin(2*math.pi*self.pointTimer/20))
	end
	love.graphics.setColor(255,255,0,31)
	for i=1,#xpoints do
		love.graphics.line(xpoints[i],originy,originx,ypoints[#ypoints-i+1])
	end

	--bottom right
	xpoints = {}
	ypoints = {}
	originx = self.width
	originy = self.height
	for i=1,npoints do
		table.insert(xpoints,originx-i*spread/npoints+10*math.sin(2*math.pi*self.pointTimer/20))
		table.insert(ypoints,originy-i*spread/npoints+10*math.sin(2*math.pi*self.pointTimer/20))
	end
	love.graphics.setColor(0,255,255,31)
	for i=1,#xpoints do
		love.graphics.line(xpoints[i],originy,originx,ypoints[#ypoints-i+1])
	end

	if self.tutorial then
		self:drawTutorial()
	else
		
		for i=1,3 do
			love.graphics.setColor(255,255,255)
			local points = lightningPoints(self.width/3+110,245,self.width*2/3-110,245,15,7)
			love.graphics.line(points)
			--points = lightningPoints(self.width*2/3-120,235,self.width/3+120,235,15,5)
			--love.graphics.line(points)
		end
		
		love.graphics.setFont(fonts.title)
		love.graphics.setColor(0,0,0)
		love.graphics.printf(settings.title,self.width/3+2,200+2,self.width/3,"center")
		love.graphics.setColor(0,255,255)
		love.graphics.printf(settings.title,self.width/3,200,self.width/3,"center")
		love.graphics.setFont(fonts.mainmenu)
		for i=1,#self.options do
			if i == self.selected then
				love.graphics.setColor(0,255,255)
			else
				love.graphics.setColor(255,255,0)
			end
			--if i == 3 then
			--	local r,g,b = love.graphics.getColor()
			--	love.graphics.setColor(r,g,b,63)
			--end
			love.graphics.printf(self.options[i],self.width/3,self.height/2+i*30-60,self.width/3,"center")
		end
	end
	self:drawMusicControls()
	love.graphics.setColor(self.R,self.G,self.B,self.A)
end

mainmenustate.selectionUp = function(self)
	self.selected = self.selected-1
	if self.selected < 1 then self.selected = #self.options end
end

mainmenustate.selectionDown = function(self)
	self.selected = self.selected+1
	if self.selected > #self.options then self.selected = 1 end
end

mainmenustate.keypressed = function(self, key, isrepeat )
	if key == "up" then
		self:selectionUp()
	elseif key == "down" then
		self:selectionDown()
	elseif key == "return" then
		if not self.tutorial then
			self.actions[self.selected]()
		else
			self.tutorial = false
		end
	elseif key == "escape" then
		if not self.tutorial then
			print("Bye!")
			love.event.quit()
		else
			self.tutorial = false
		end
	end
end

mainmenustate.gamepadpressed = function(self,joystick,button)
	if button == "a" then
		if self.tutorial then
			self.tutorial = false
		else
			self.actions[self.selected]()
		end
	elseif button == "dpup" then
		self:selectionUp()
	elseif button == "dpdown" then
		self:selectionDown()
	elseif button == "b" then
		if self.tutorial then
			self.tutorial = false
		else
			print("Bye!")
			love.event.quit()
		end
	end
end

mainmenustate.drawTutorial = function(self)
	love.graphics.setFont(fonts.tutorial)
	--love.graphics.setColor(127,127,127)
	--love.graphics.rectangle("fill",200,50,self.width-400,self.height-100)
	love.graphics.setColor(0,0,0)
	love.graphics.printf(settings.tutorialText,self.width/4+2,102,self.width/2,"center")
	love.graphics.setColor(255,255,255)
	love.graphics.printf(settings.tutorialText,self.width/4,100,self.width/2,"center")
	love.graphics.setColor(0,255,255)
	love.graphics.setFont(fonts.mainmenu)
	love.graphics.printf("Back",self.width/4,self.height-100,self.width/2,"center")
end

mainmenustate.drawMusicControls = function(self)
	love.graphics.setFont(fonts.tutorial)
	love.graphics.setColor(255,255,255,127)
	love.graphics.printf("Press m to mute/resume the music.",3*self.width/4,self.height-50,self.width/4,"left")
	love.graphics.setFont(fonts.credits)
	love.graphics.setColor(255,255,255,127)
	love.graphics.printf("Connor O.R.T. Linning - DN38416",3*self.width/4,self.height-30,self.width/4,"left")
end

mainmenustate.drawCredits = function(self)
	love.graphics.setFont(fonts.tutorial)
	love.graphics.setColor(255,255,255,127)
	love.graphics.printf("Press m to mute/resume the music.",3*self.width/4,self.height-50,self.width/4,"left")
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


return mainmenustate