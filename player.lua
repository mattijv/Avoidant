local settings = require("settings")
local player = {}
player.states = {"red","green","blue"}
player.new = function(self,x,y,state,controller,manager,id)
	local _player = {}
	_player.x = x
	_player.y = y
	_player.state = state
	_player.controller = controller
	_player.manager = manager
	_player.id = id or "player1"
	_player.dead = false
	_player.deadTimer = 0
	_player.stateChangeTimer = 0
	setmetatable(_player,{__index = self})
	return _player
end
player.update = function(self,dt,static)
	local controls = self.controller:getControl()
	local throttle = self.controller:getTrigger()
	local speed = settings.playerMinSpeed
	if throttle ~= nil then
		speed = speed + (settings.playerMaxSpeed-settings.playerMinSpeed)*throttle*throttle
	end
	if controls ~= nil then
		local magnitude = math.sqrt(controls.x*controls.x+controls.y*controls.y)
		local norm = 1
		if magnitude > 1 then
			norm = 1/magnitude
		end
		local mult = 1
		if self.dead then mult = 0.5 end
		self.x = self.x + controls.x*speed*dt*mult*norm
		self.y = self.y + controls.y*speed*dt*mult*norm
		self.x = math.min(self.x,width-10)
		self.x = math.max(self.x,10)
		self.y = math.min(self.y,height-10)
		self.y = math.max(self.y,10)
	end
	if not self.dead then
		if not static then
			self.stateChangeTimer = self.stateChangeTimer + dt
		end
		if self.stateChangeTimer > settings.stateChangeMaxTime then
			local newState = self.states[math.random(1,3)]
			while newState == self.state do
				newState = self.states[math.random(1,3)]
			end
			self.state = newState
			self.stateChangeTimer = 0
		end
	else
		self.deadTimer = self.deadTimer + dt
		if self.deadTimer > settings.deadTime then
			if self.manager.distClosestSame[self.id] > 40 and self.manager.distClosestOther[self.id] > 40 then
				self.dead = false
				self.deadTimer = 0
			end
		end
	end
end


player.draw = function(self)
	local colors = {}
	colors[1] = {255,255,0}
	colors[2] = {0,255,255}
	local timer = {}
	timer[1] = {0,255,255}
	timer[2] = {255,255,0}
	local points = {}
	points.red = 3
	points.green = 4
	points.blue = 5
	--local pts = points[self.state]
	local radius = 15
	if not self.dead then
		if (self.stateChangeTimer > 6.4 and self.stateChangeTimer < 6.5) or (self.stateChangeTimer > 6.2 and self.stateChangeTimer < 6.3) or (self.stateChangeTimer > 6.6 and self.stateChangeTimer < 6.7) then
					love.graphics.setColor(255,255,255)
					radius = 26
		else
			love.graphics.setColor(colors[self.id])
		end
	else
		love.graphics.setColor(colors[self.id][1],colors[self.id][2],colors[self.id][3],63)
	end
	love.graphics.circle("fill",self.x,self.y,radius,points[self.state])
	love.graphics.setColor(timer[self.id][1],timer[self.id][2],timer[self.id][3],63)
	love.graphics.circle("line",self.x,self.y,30,30)
	love.graphics.setColor(timer[self.id])
	local portion = 2*math.pi*(self.manager.nearTime[self.id]/self.manager.winTime)
	drawArc(self.x, self.y, 30, -math.pi/2, portion-math.pi/2,30)

end


function drawArc(x0,y0,radius,angle1,angle2,segments)
	local segments = segments or 10
	local angle = angle2-angle1
	local da = angle/segments
	local points = {}
	for i=0,segments do
		local x = x0 + radius*math.cos(angle1+i*da)
		local y = y0 + radius*math.sin(angle1+i*da)
		table.insert(points,x)
		table.insert(points,y)
	end
	love.graphics.line(points)
end

return player