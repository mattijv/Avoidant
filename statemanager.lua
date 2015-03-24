local stateManager = {}
stateManager.new = function(self)
	local _manager = {}
	_manager.states = {}
	_manager.currentState = nil
	setmetatable(_manager,{__index=self})
	return _manager
end

stateManager.addState = function(self,state)
	state.manager = self
	self.states[state.name] = state
end

stateManager.setCurrentState = function(self,state)
	self.currentState = state
end

stateManager.switchToState = function(self,newState,args)
	if self.currentState ~= nil then
		self.currentState:terminate()
	end
	self:setCurrentState(newState)
	self.currentState:initialize(args)
end

return stateManager