local gamestate = require("gamestate")
local fonts = require("fonts")
local settings = require("settings")

local optionsmenu = {}

optionsmenu.new = function(self,name)
	local _playstate = gamestate:new(name or "mainmenu")
	setmetatable(_playstate,{__index = self})
	return _playstate
end

optionsmenu.initialize = function(self)
	self.width, self.height = settings.width,settings.height
	self.R,self.G,self.B,self.A = love.graphics.getColor()
	--self.background = love.graphics.newImage("background.png")
	self.pointTimer = 0
	local rb = 32
	local gb = 32
	local bb = 32
	love.graphics.setBackgroundColor(rb,gb,bb)
	self.flags = {}
	self.flags.fullscreen = true
	self.flags.vsync = true
	self.flags.fsaa = 4


	self.options = {}
	self.options[1] = {["name"]="Resolution",["values"]={
															{2560,1600},
															{2560,1440},
															{1920,1200},
															{1920,1080},
															{1680,1050},
															{1536,864},
															{1440,900},
															{1366,768},
															{1360,768},
															{1280,1024},
															{1280,800},
															{1280,720},
															{1024,768}
														},
						["selected"]=4
					  }
	self.options[2] = {["name"]="Fullscreen",["values"]={
															"fullscreen",
															"windowed"
														},
						["selected"]=1
					  }
	self.options[3] = {["name"]="Vsync",["values"]={
															"on",
															"off"
														},
						["selected"]=1
					  }
	self.options[4] = {["name"]="FSAA",["values"]={
															0,
															2,
															4,
															8,
															16
														},
						["selected"]=1
					  }


	local w,h,flags = love.window.getMode()
	for i=1,#self.options[1].values do
		if self.options[1].values[i][1] == w and self.options[1].values[i][2] == h then
			self.options[1].selected = i
			break
		end
	end
	if not flags.fullscreen then self.options[2].selected = 2 end
	if not flags.vsync then self.options[3].selected = 2 end
	for i=1,#self.options[4].values do
		if self.options[4].values[i] == flags.fsaa then
			self.options[4].selected = i
			break
		end
	end
	self.actions = {}
	self.actions[1] = function()
		if self.options[1].selected + 1 <= #self.options[1].values then
			self.options[1].selected = self.options[1].selected+1
		else
			self.options[1].selected = 1
		end
	end
	self.actions[2] = function()
		if self.options[2].selected + 1 <= #self.options[2].values then
			self.options[2].selected = self.options[2].selected+1
		else
			self.options[2].selected = 1
		end
	end
	self.actions[3] = function()
		if self.options[3].selected + 1 <= #self.options[3].values then
			self.options[3].selected = self.options[3].selected+1
		else
			self.options[3].selected = 1
		end
	end
	self.actions[4] = function()
		if self.options[4].selected + 1 <= #self.options[4].values then
			self.options[4].selected = self.options[4].selected+1
		else
			self.options[4].selected = 1
		end
	end
	self.actions[5] = function()
		self:setGraphics()
		self.manager:switchToState(self.manager.states["mainmenu"])
	end
	self.selected = 1
end

optionsmenu.terminate = function(self)
end

optionsmenu.update = function(self,dt)
	self.pointTimer = self.pointTimer + dt
end

optionsmenu.draw = function(self)
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
		love.graphics.setColor(255,255,0)
		love.graphics.printf(self.options[i].name,0,self.height/2+i*30-60,self.width/3,"right")
		if i == self.selected then
			love.graphics.setColor(0,255,255)
		else
			love.graphics.setColor(255,255,0)
		end
		if i > 1 then
			love.graphics.printf(self.options[i].values[self.options[i].selected],self.width/3,self.height/2+i*30-60,self.width/3,"center")
		else
			local w = self.options[i].values[self.options[i].selected][1]
			local h = self.options[i].values[self.options[i].selected][2]
			love.graphics.printf(tostring(w).."x"..tostring(h),self.width/3,self.height/2+i*30-60,self.width/3,"center")
		end
	end
	if self.selected == #self.options+1 then
		love.graphics.setColor(0,255,255)
	else
		love.graphics.setColor(255,255,0)
	end
		love.graphics.printf("Save and exit",self.width/3,self.height/2+(#self.options+1)*30-60,self.width/3,"center")
	love.graphics.setColor(self.R,self.G,self.B,self.A)
end

optionsmenu.selectionUp = function(self)
	self.selected = self.selected-1
	if self.selected < 1 then self.selected = #self.options+1 end
end

optionsmenu.selectionDown = function(self)
	self.selected = self.selected+1
	if self.selected > #self.options+1 then self.selected = 1 end
end

optionsmenu.selectionRight = function(self)
	if self.selected == #self.options+1 then return end
	if self.options[self.selected].selected + 1 <= #self.options[self.selected].values then
			self.options[self.selected].selected = self.options[self.selected].selected + 1
		else
			self.options[self.selected].selected = 1
	end
end

optionsmenu.selectionLeft = function(self)
	if self.selected == #self.options+1 then return end
	if self.options[self.selected].selected - 1 > 0 then
			self.options[self.selected].selected = self.options[self.selected].selected - 1
		else
			self.options[self.selected].selected = #self.options[self.selected].values
	end
end


optionsmenu.keypressed = function(self, key, isrepeat )
	if key == "up" then
		self:selectionUp()
	elseif key == "down" then
		self:selectionDown()
	elseif key == "left" then
		self:selectionLeft()
	elseif key == "right" then
		self:selectionRight()
	elseif key == "return" then
		self.actions[self.selected]()
	elseif key == "escape" then
		self.manager:switchToState(self.manager.states["mainmenu"])
	end
end

optionsmenu.gamepadpressed = function(self,joystick,button)
	if button == "a" then
		self.actions[self.selected]()
	elseif button == "dpup" then
		self:selectionUp()
	elseif button == "dpdown" then
		self:selectionDown()
	elseif button == "dpleft" then
		self:selectionLeft()
	elseif button == "dpright" then
		self:selectionRight()
	elseif button == "b" then
		self.manager:switchToState(self.manager.states["mainmenu"])
	end
end

optionsmenu.setGraphics = function(self)
	local w = self.options[1].values[self.options[1].selected][1]
	local h = self.options[1].values[self.options[1].selected][2]
	if self.options[2].values[self.options[2].selected] == "fullscreen" then
		self.flags.fullscreen = true
	else
		self.flags.fullscreen = false
	end
	if self.options[3].values[self.options[3].selected] == "on" then
		self.flags.vsync = true
	else
		self.flags.vsync = false
	end
	self.flags.fsaa = self.options[4].values[self.options[4].selected]
	love.window.setMode(w,h,self.flags)
end


return optionsmenu