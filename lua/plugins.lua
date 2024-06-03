return setmetatable({}, {
	__newindex = function(self, key, value)
		assert(type(key) == "string", "key must be a string")
		if rawget(self, key) ~= nil then
			return error("plugin "..key.." already exists", 2)
		end
		value[1] = key
		rawset(self, key, value)
		table.insert(self, value)
	end,
	__index = function(self, key)
		if rawget(self, key) == nil then
			return error("plugin "..key.." does not exist", 2)
		end
		return rawget(self, key)
	end,
})
