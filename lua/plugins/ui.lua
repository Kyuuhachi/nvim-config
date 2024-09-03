local plug = require "plugins"

-- icons (mostly a dependency)
plug["kyazdani42/nvim-web-devicons"] = {
	lazy = true,
	init = function()
		local devicons = require "nvim-web-devicons"
		devicons.set_icon { xml = { icon = "" } } -- The usual 謹 is in cjk compatibility and is wide
	end,
}

-- top line
plug["akinsho/bufferline.nvim"] = {
	event = "VeryLazy",
	opts = {
		options = {
			show_buffer_close_icons = false,
			show_close_icon = false,
			diagnostics = "nvim_lsp",
		},
	},
}

-- git signcolumn
plug["lewis6991/gitsigns.nvim"] = {
	opts = {},
	event = { "BufReadPre", "BufNewFile" },
	keys = {
		{"]c", [[&diff ? ']c' : '<Cmd>Gitsigns next_hunk<CR>']], expr=true, mode={"n","v"}},
		{"[c", [[&diff ? '[c' : '<Cmd>Gitsigns prev_hunk<CR>']], expr=true, mode={"n","v"}},
	},
}

-- window separator
plug["nvim-zh/colorful-winsep.nvim"] = {
	config = true,
	event = { "WinNew" },
}

-- bottom line
plug["SmiteshP/nvim-navic"] = {}
local navic_section = {
	cond = function() return require "nvim-navic".is_available() end,
	function()
		local data = require "nvim-navic".get_data() or {}
		local parts = {}
		for _, v in ipairs(data) do
			local name = v.name:gsub("%%", "%%%%"):gsub("\n", " ")
			local component = v.icon .. name
			table.insert(parts, component)
		end
		return table.concat(parts, "  ")
	end,
}

local search_section = {
	cond = function() return vim.v.hlsearch end,
	function()
		local max = 999
		local res = vim.fn.searchcount({ maxcount = max, timeout = 500 })
		local function f(n) if n > max then return ">"..max else return n end end

		if res.total > 0 then
			return string.format("%s/%s", f(res.current), f(res.total))
		end
		return ""
	end
}

plug["nvim-lualine/lualine.nvim"] = {
	event = "VeryLazy",
	opts = {
		theme = "auto",
		globalstatus = true,
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch", "diff", "diagnostics" },
			lualine_c = { { "filename", path = 1 }, navic_section },
			lualine_x = { "encoding", "fileformat", "filetype" },
			lualine_y = { "progress", search_section },
			lualine_z = { "location" },
		},
	},
	init = function()
		vim.opt.shortmess:append "sS"
		vim.opt.laststatus = 3
	end,
}

-- top right in window
local function render_incline(props)
	local ll = require "lualine.components.diagnostics.config"

	local path = vim.api.nvim_buf_get_name(props.buf)
	local filename = vim.fn.fnamemodify(path, ":t")
	if filename == "" then
		filename = "[No Name]"
	end
	local icon, icon_color = require "nvim-web-devicons".get_icon_color(path)

	local diag = {}
	local name_color = nil
	for _, category in ipairs(ll.options.sections) do
		local n = #vim.diagnostic.get(props.buf, {
			severity = vim.diagnostic.severity[string.upper(category)],
		})
		if n > 0 then
			local group = category:gsub("^%l", string.upper)
			table.insert(diag, {
				ll.symbols.icons[category] .. n .. ' ',
				group = 'DiagnosticSign' .. group
			})
			name_color = name_color or ("Diagnostic" .. group)
		end
	end

	local out = {}
	if #diag > 0 then
		table.insert(out, diag)
		table.insert(out, { "▏", group = "NonText" })
	end
	if icon then
		table.insert(out, { icon, group = name_color, guifg = icon_color })
		table.insert(out, " ")
	end
	table.insert(out, { filename, group = name_color })
	if vim.bo[props.buf].modified then
		table.insert(out, { " [+]", group = name_color })
	end

	return out
end

plug["b0o/incline.nvim"] = {
	opts = {
		window = { padding = 0 },
		hide = {
			focused_win = true,
		},
		highlight = {
			groups = {
				InclineNormal = { guibg = "none" },
				InclineNormalNC = { guibg = "none" },
			}
		},
		render = function(params)
			local content = render_incline(params)
			local hl = vim.api.nvim_get_hl(0, { name = "NormalFloat", link = false })
			local bg = string.format("#%06x", hl.bg)
			return {
				{ "", guifg = bg },
				{
					{ " ", content, " " },
					guibg = bg,
				},
				{ "", guifg = bg },
			}
		end,
	}
}

-- replace vim.ui.select and vim.ui.input
plug["stevearc/dressing.nvim"] = {
	lazy = true,
	init = function()
		vim.ui.select = function(...)
			require "lazy".load({ plugins = { "dressing.nvim" } })
			return vim.ui.select(...)
		end
		vim.ui.input = function(...)
			require "lazy".load({ plugins = { "dressing.nvim" } })
			return vim.ui.input(...)
		end
	end,
}

-- replace vim.notify
plug["rcarriga/nvim-notify"] = {
	opts = {
		animate = false,
		level = 0,
		minimum_width = 50,
		render = "compact",
		stages = "static",
		timeout = 5000,
		top_down = false
	},
	init = function()
		vim.notify = require "notify"
	end,
}

-- ui lib
plug["MunifTanjim/nui.nvim"] = { lazy = true }

-- lsp progress
plug["j-hui/fidget.nvim"] = { opts = {} }

return {}
