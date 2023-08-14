return {
	-- icons
	{
		"kyazdani42/nvim-web-devicons",
		lazy = true,
		init = function()
			local devicons = require "nvim-web-devicons"
			devicons.set_icon {
				xml = { icon = "" }, -- The usual 謹 is in cjk compatibility and is wide
				jsm = devicons.get_icons().js,
			}
		end,
	},

	-- top line
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		opts = {
			options = {
				show_buffer_close_icons = false,
				show_close_icon = false,
				diagnostics = "nvim_lsp",
			}
		},
	},

	-- bottom line
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		opts = {
			theme = "auto",
			globalstatus = true,
			sections = {
				lualine_a = {
					"mode"
				},
				lualine_b = {
					"branch",
					"diff",
					"diagnostics"
				},
				lualine_c = {
					{ "filename", path = 1 },
					{
						cond = function()
							return package.loaded["nvim-navic"] and require("nvim-navic").is_available()
						end,
						function() return require("nvim-navic").get_location() end,
					},
				},
				lualine_x = {
					"encoding",
					"fileformat",
					"filetype"
				},
				lualine_y = {
					"progress",
					{ function()
						if vim.api.nvim_get_vvar("hlsearch") == 1 then
							local max = 999
							local res = vim.fn.searchcount({ maxcount = max, timeout = 500 })
							local function f(n) if n > max then return ">"..max else return n end end

							if res.total > 0 then
								return string.format("%s/%s", f(res.current), f(res.total))
							end
						end
						return ""
					end }
				},
				lualine_z = {
					"location"
				},
			},
		},
		init = function()
			vim.opt.shortmess:append "sS"
		end,
	},

	-- lsp symbol navigation for lualine
	{
		"SmiteshP/nvim-navic",
		lazy = true,
		opts = {
			highlight = true,
			separator = "»",
			lsp = {
				auto_attach = true,
			},
		},
	},

	-- replace vim.ui.select and vim.ui.input
	{
		"stevearc/dressing.nvim",
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
	},

	-- replace vim.notify
	{
		"rcarriga/nvim-notify",
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
	},

	-- ui lib
	{ "MunifTanjim/nui.nvim", lazy = true },

	-- show lsp progress
	{ "j-hui/fidget.nvim", opts = {} },
}
