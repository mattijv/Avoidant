local Control = {}
Control.new = function(self,side,joystick)
	local _rsc = {}
	setmetatable(_rsc,{__index = self})
	_rsc.side = side
	_rsc.joystick = joystick
	return _rsc
end


Control.getControl = function(self)
	local deadzone = 0.15
	local _control = {}
	_control.x = 0
	_control.y = 0
	if self.joystick ~= nil then
		_control.x = self.joystick:getGamepadAxis(self.side.."x")
		_control.y = self.joystick:getGamepadAxis(self.side.."y")
		local magnitude = math.sqrt(_control.x*_control.x + _control.y*_control.y)
		--_control.x = _control.x*math.abs(_control.x)
		--_control.y = _control.y*math.abs(_control.y)
		if magnitude < deadzone then
			_control.x = 0
			_control.y = 0
		else
			_control.x = (_control.x/magnitude)*((magnitude-deadzone)/(1-deadzone))
			_control.y = (_control.y/magnitude)*((magnitude-deadzone)/(1-deadzone))
		end
	end
	if self.side == "right" then
		if love.keyboard.isDown("left") then
			_control.x = -1
		elseif love.keyboard.isDown("right") then
			_control.x = 1
		end
		if love.keyboard.isDown("up") then
			_control.y = -1
		elseif love.keyboard.isDown("down") then
			_control.y = 1
		end
	elseif self.side == "left" then
		if love.keyboard.isDown("a") then
			_control.x = -1
		elseif love.keyboard.isDown("d") then
			_control.x = 1
		end
		if love.keyboard.isDown("w") then
			_control.y = -1
		elseif love.keyboard.isDown("s") then
			_control.y = 1
		end
	end
	return _control
end

Control.getTrigger = function(self)
	if self.joystick ~= nil then
		return self.joystick:getGamepadAxis( "trigger"..self.side )
	else
		if self.side == "right" then
			if love.keyboard.isDown(" ") then
				return 1
			else
				return 0
			end
		else
			if love.keyboard.isDown("tab") then
				return 1
			else
				return 0
			end
		end
	end
end

return Control