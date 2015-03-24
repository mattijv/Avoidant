local gamestate = require("gamestate")
local fonts = require("fonts")
local settings = require("settings")

local highscorescreen = {}

highscorescreen.new = function(self,name)
	local _playstate = gamestate:new(name or "mainmenu")
	setmetatable(_playstate,{__index = self})
	return _playstate
end

highscorescreen.initialize = function(self)
	self.width, self.height = settings.width,settings.height
	self.R,self.G,self.B,self.A = love.graphics.getColor()
	--self.background = love.graphics.newImage("background.png")
	self.pointTimer = 0
	local rb = 32
	local gb = 32
	local bb = 32
	love.graphics.setBackgroundColor(rb,gb,bb)
	
	self.scorefilename = "highscores.txt"
	self.scores = {}


	if love.filesystem.exists(self.scorefilename) then
		self.scorefile = love.filesystem.newFile(self.scorefilename)
		self.scorefile:open("r")
		for line in self.scorefile:lines() do
			table.insert(self.scores,line)
		end
		self.scorefile:close()
	else
		self.errorstring = "High score file not found :("
	end
end

highscorescreen.terminate = function(self)
end

highscorescreen.update = function(self,dt)
	self.pointTimer = self.pointTimer + dt
end

highscorescreen.draw = function(self)
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

	self:drawHighscores()
	

	love.graphics.setColor(self.R,self.G,self.B,self.A)
end

highscorescreen.keypressed = function(self, key, isrepeat )
	if key == "return" or key == "escape"then
		self.manager:switchToState(self.manager.states["mainmenu"])
	end
end

highscorescreen.gamepadpressed = function(self,joystick,button)
	if button == "a" or button == "b" then
		self.manager:switchToState(self.manager.states["mainmenu"])
	end
end

highscorescreen.drawHighscores = function(self)

	love.graphics.setFont(fonts.mainmenu)
	love.graphics.setColor(255,255,0)
	love.graphics.printf("High Scores",self.width/4,100,self.width/2,"center")
	if self.errorstring then
		love.graphics.printf(self.errorstring,self.width/4,200,self.width/2,"center")
	else
		love.graphics.setFont(fonts.tutorial)
		local scoreString = ""
		for i=1,settings.maxHighScores do
			if self.scores[i+1] ~= nil then
				scoreString = scoreString..tonumber(i)..". --- "..self.scores[i+1].."\n"
			else
				scoreString = scoreString..tonumber(i)..". --- ".."______\n"
			end
		end
		love.graphics.printf(scoreString,self.width/4,200,self.width/2,"center")
	end
	love.graphics.setColor(0,255,255)
	love.graphics.setFont(fonts.mainmenu)
	love.graphics.printf("Back",self.width/4,self.height-100,self.width/2,"center")

end

return highscorescreen