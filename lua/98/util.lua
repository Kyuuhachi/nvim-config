local M = {}

local path_meta = {
	__index = function(self, key)
		local path = {}
		for i, v in ipairs(self._path) do
			path[i] = v
		end
		path[#path+1] = key
		return setmetatable({
			_func = self._func,
			_path = path,
		}, getmetatable(self))
	end,
	__call = function(self, ...)
		return self._func(self._path, ...)
	end,
}

function M.path(func)
	return setmetatable({
		_func = func,
		_path = {},
	}, path_meta)
end

function M.lazy(module)
	return M.path(function(path, ...)
		local args = {...}
		return function()
			local obj
			if type(module) == "string" then
				obj = require(module)
			else
				obj = module()
			end
			for _, p in ipairs(path) do
				obj = obj[p]
			end
			obj(unpack(args))
		end
	end)
end

function M.conf_add_to(name)
	return M.path(function(path, arg)
		return {
			name,
			optional = true,
			opts = function(_, obj)
				for _, p in ipairs(path) do
					obj[p] = obj[p] or {}
					obj = obj[p]
				end
				vim.list_extend(obj, arg)
			end
		}
	end)
end

function M.conf_put(name)
	return M.path(function(path, arg)
		return {
			name,
			optional = true,
			opts = function(plug, opts)
				opts = opts or {}
				local obj = opts
				local prev = obj
				local last
				for _, p in ipairs(path) do
					obj[p] = obj[p] or {}
					prev = obj
					obj = obj[p]
					last = p
				end
				if type(arg) == "function" then
					arg = arg(plug, obj)
				end
				if arg then
					prev[last] = vim.tbl_deep_extend("force", prev[last], arg)
				else
					return opts
				end
			end
		}
	end)
end

function M.nested(input)
	local result = {}

	local keys = {}
	for k, v in pairs(input) do
		if type(k) == "string" then
			table.insert(keys, k)
		else
			result.insert(k, v)
		end
	end

	-- this sort makes it so that keys ["a"] and ["a.b"] are both allowed
	table.sort(keys)

	for _, k in ipairs(keys) do
		local segs = {}
		for seg in string.gmatch(k..".", "([^.]*).") do table.insert(segs, seg) end

		local last = table.remove(segs)
		local ptr = result
		for _, seg in ipairs(segs) do
			if not ptr[seg] then ptr[seg] = {} end
			ptr = ptr[seg]
		end
		ptr[last] = input[k]
	end
	return result
end

M.canvas = setmetatable({
	put = function(self, hl, s, ...)
		s = s:format(...)
		table.insert(self.line, s)
		table.insert(self.highlight, {hl, #self.lines, self.pos, self.pos+#s})
		self.pos = self.pos + #s
		return self
	end,

	nl = function(self)
		table.insert(self.lines, table.concat(self.line))
		self.line = {}
		self.pos = 0
		return self
	end,

	show_floating = function(self, opts)
		if #self.lines == 0 then return end
		local bufid, win = vim.lsp.util.open_floating_preview(self.lines, "", opts)

		local ns = vim.api.nvim_create_namespace""
		for _, hl in ipairs(self.highlight) do
			vim.api.nvim_buf_add_highlight(bufid, ns, unpack(hl))
		end

		return bufid, win, ns
	end,

	write_to_buf = function(self, bufid)
		if #self.lines == 0 then return end
		vim.api.nvim_buf_set_lines(bufid, 0, -1, false, self.lines)

		local ns = vim.api.nvim_create_namespace""
		for _, hl in ipairs(self.highlight) do
			vim.api.nvim_buf_add_highlight(bufid, ns, unpack(hl))
		end

		return ns
	end,
}, {
	__call = function(cls)
		return setmetatable({
			lines = {},
			line = {},
			pos = 0,
			highlight = {},
		}, {
			__name = getmetatable(cls).__name,
			__index = cls,
		})
	end,

	__name = "util.canvas",
})

return M
