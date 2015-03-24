local settings = require("settings")
local mook = {}
mook.types = {"red","green","blue"}
mook.defaultTypeQueue = {"red", "red", "red", "red", "green", "green", "green", "green", "blue", "blue", "blue", "blue"}
mook.typeQueue = {}

mook.refreshTypeQueue = function(self)
	self.typeQueue = {}
	for i=1,#self.defaultTypeQueue do
		table.insert(self.typeQueue,self.defaultTypeQueue[i])
	end
end

mook.new = function(self,x,y,color,manager,v_x,v_y)
	local _mook = {}
	_mook.x = x
	_mook.y = y
	_mook.v_x = v_x or 0
	_mook.v_y = v_y or 0
	_mook.type = color
	_mook.manager = manager
	_mook.animationTimer = 0
	_mook.frame = math.random(1,3)
	_mook.scared = false

	setmetatable(_mook,{__index = self})
	return _mook
end

mook.update = function(self,dt)
	self.scared = false
	local players = self.manager.players
	for i=1,#players do
			--if not players[i].dead then
				dx = players[i].x - self.x
				dy = players[i].y - self.y
				local dist = math.sqrt(dx * dx + dy * dy)
				local norm = 1.0/dist
				local sign = 1
				local playerForce = settings.playerAttractionForce
				local cutOff = settings.attractionCutOff
				if players[i].dead then
					sign = -1
					playerForce = settings.deadRepulsionForce
					cutoff = settings.repulsionCutOff
				elseif players[i].state == self.type then
					sign = -1
					playerForce = settings.playerRepulsionForce
					cutoff = settings.repulsionCutOff
					self.scared = true
				end
				if dist < cutOff then
					dx = sign * playerForce * norm * dx
					dy = sign * playerForce * norm * dy
					self.v_x = self.v_x+dx*dt
					self.v_y = self.v_y+dy*dt
				end
			--end
	end
	local mooks = self.manager.mooks
	for i=1,#mooks do
		if mooks[i] ~= self then
			--if not self.scared or (self.scared and mooks[i].type == self.type) then
				dx = self.x - mooks[i].x
				dy = self.y - mooks[i].y
				local dist = math.sqrt(dx * dx + dy * dy)
				local norm = 1.0/dist
				if dist < settings.mookForceCutOff then
					dx = settings.mookForce * norm * dx
					dy = settings.mookForce * norm * dy
					self.v_x = self.v_x+dx*dt
					self.v_y = self.v_y+dy*dt
				end
			--end
		end
	end
	--if self.scared then
		dx = self.manager.homes[self.type].x - self.x
		dy = self.manager.homes[self.type].y - self.y
		local norm = 1.0/math.sqrt(dx * dx + dy * dy)
		dx = settings.centripetalForce * norm * dx
		dy = settings.centripetalForce * norm * dy
		self.v_x = self.v_x+dx*dt
		self.v_y = self.v_y+dy*dt
	--end
	local speed = math.sqrt(self.v_x*self.v_x+self.v_y*self.v_y)
	local norm = 1
	if speed > settings.speedMax then
		norm = settings.speedMax/speed
	end
	self.v_x = norm * self.v_x
	self.v_y = norm * self.v_y
	self.x = self.x + self.v_x * dt
	self.y = self.y + self.v_y * dt
	if self.x >= self.manager.width-10 then
		self.v_x = -self.v_x
		self.x = self.manager.width-10
	elseif self.x <= 10 then
		self.x = 10
		self.v_x = -self.v_x
	end
	if self.y >= self.manager.height-10 then
		self.v_y = -self.v_y
		self.y = self.manager.height-10
	elseif self.y <= 10 then
		self.v_y = -self.v_y
		self.y = 10
	end
end



--mook.draw = function(self)
--	local offset = 12
--	if not self.scared then
--		love.graphics.draw(self.graphics[self.type],self.frames[self.frameSequence[self.frame]],self.x-offset,self.y-offset)
--	else
--		love.graphics.draw(self.graphics[self.type],self.frames["scared"],self.x-offset,self.y-offset)
--	end
--end

mook.draw = function(self)
	local points = {}
	points.red = 3
	points.green = 4
	points.blue = 5
	local colors = {}
	colors.red = {255,0,0}
	colors.green = {0,255,0}
	colors.blue = {153,50,204}
	--[[
	local shadowOffset = {}
	shadowOffset.x = 5
	shadowOffset.y = 5
	love.graphics.setColor(10,10,10)
	if self.scared then
		love.graphics.circle("fill",self.x+shadowOffset.x,self.y+shadowOffset.y,12,points[self.type])
	else
		love.graphics.circle("line",self.x+shadowOffset.x,self.y+shadowOffset.y,12,points[self.type])
	end
	]]--


	love.graphics.setColor(colors[self.type])
	if self.scared then
		love.graphics.circle("fill",self.x,self.y,12,points[self.type])
	else
		love.graphics.circle("line",self.x,self.y,12,points[self.type])
	end
end


return mook