local gamestate = {}
gamestate.new = function(self,name)
	local _state = {}
	_state.name = name or "defaultState"
	_state.manager = nil
	return _state
end

return gamestate