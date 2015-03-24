local gamestate = require("gamestate")
local fonts = require("fonts")
local settings = require("settings")

local playersselection = {}

playersselection.new = function(self,name)
	local _playstate = gamestate:new(name or "mainmenu")
	setmetatable(_playstate,{__index = self})
	return _playstate
end

playersselection.initialize = function(self)
	self.width, self.height = settings.width,settings.height
	self.R,self.G,self.B,self.A = love.graphics.getColor()
	--self.background = love.graphics.newImage("background.png")
	self.pointTimer = 0
	local rb = 32
	local gb = 32
	local bb = 32
	love.graphics.setBackgroundColor(rb,gb,bb)
	self.options = {}
	self.options[1] = "Singleplayer"
	self.options[2] = "Multiplayer"
	self.options[3] = "Back"
	self.actions = {}
	self.actions[1] = function()
		self.manager:switchToState(self.manager.states["level1"],1)
	end
	self.actions[2] = function()
		self.manager:switchToState(self.manager.states["level1"],2)
	end
	self.actions[3] = function()
		self.manager:switchToState(self.manager.states["mainmenu"])
	end
	self.selected = 1
end

playersselection.terminate = function(self)
end

playersselection.update = function(self,dt)
	self.pointTimer = self.pointTimer + dt
end

playersselection.draw = function(self)
	--love.graphics.draw(self.background,0,0)

	local npoints = math.min(math.floor(self.pointTimer*30),38)+2
	local spread = self.width/2

	--bottom left
	xpoints = {}
	ypoints = {}
	originx = 0
	originy = self.height
	for i=1,npoints do
		table.insert(xpoints,originx+i*spread/npoints+10*math.sin(2*math.pi*self.pointTimer/20))
		table.insert(ypoints,originy-i*spread/npoints+10*math.sin(2*math.pi*self.pointTimer/20))
	end
	love.graphics.setColor(0,255,255,31)
	for i=1,#xpoints do
		love.graphics.line(xpoints[i],originy,originx,ypoints[#ypoints-i+1])
	end


	--top right
	local xpoints = {}
	local ypoints = {}
	local originx = self.width
	local originy = 0
	for i=1,npoints do
		table.insert(xpoints,originx-i*spread/npoints+10*math.sin(2*math.pi*self.pointTimer/20))
		table.insert(ypoints,originy+i*spread/npoints+10*math.sin(2*math.pi*self.pointTimer/20))
	end
	love.graphics.setColor(255,255,0,31)
	for i=1,#xpoints do
		love.graphics.line(xpoints[i],originy,originx,ypoints[#ypoints-i+1])
	end

	love.graphics.setFont(fonts.mainmenu)
	for i=1,#self.options do
		if i == self.selected then
			love.graphics.setColor(0,255,255)
		else
			love.graphics.setColor(255,255,0)
		end
		love.graphics.printf(self.options[i],self.width/3,self.height/2+i*30-60,self.width/3,"center")
	end
	love.graphics.setColor(self.R,self.G,self.B,self.A)
end

playersselection.selectionUp = function(self)
	self.selected = self.selected-1
	if self.selected < 1 then self.selected = #self.options end
end

playersselection.selectionDown = function(self)
	self.selected = self.selected+1
	if self.selected > #self.options then self.selected = 1 end
end

playersselection.keypressed = function(self, key, isrepeat )
	if key == "up" then
		self:selectionUp()
	elseif key == "down" then
		self:selectionDown()
	elseif key == "return" then
		self.actions[self.selected]()
	elseif key == "escape" then
		self.actions[3]()
	end
end

playersselection.gamepadpressed = function(self,joystick,button)
	if button == "a" then
		self.actions[self.selected]()
	elseif button == "dpup" then
		self:selectionUp()
	elseif button == "dpdown" then
		self:selectionDown()
	elseif button == "b" then
		self.actions[3]()
	end
end


return playersselection