local plug = require "plugins"

plug["nvim-treesitter"] = {
	version = false,
	build = ":TSUpdate",
	main = "nvim-treesitter.configs",
	opts = {
		highlight = {
			enable = true,
			disable = function(lang, bufnr)
				return vim.api.nvim_buf_line_count(bufnr) > 5000
			end,
		},
		indent = { enable = false },
		ensure_installed = {
			"query",
			"lua", "luadoc", "luap",
			"python",
			"rust",
			"c", "cpp",
			"javascript", "jsdoc", "html", "css",
			"markdown", "markdown_inline",
			"bash",
			"toml",
			"regex",
			"vim", "vimdoc",
		},
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "<C-space>",
				node_incremental = "<C-space>",
				scope_incremental = false,
				node_decremental = "<bs>",
			},
		},
	},
}

plug["echasnovski/mini.hipatterns"] = {
	event = "VeryLazy",
	opts = function()
		return {
			highlighters = {
				fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
				xxx   = { pattern = "%f[%w]()XXX()%f[%W]",   group = "MiniHipatternsFixme" },
				hack  = { pattern = "%f[%w]()HACK()%f[%W]",  group = "MiniHipatternsHack"  },
				todo  = { pattern = "%f[%w]()TODO()%f[%W]",  group = "MiniHipatternsTodo"  },
				note  = { pattern = "%f[%w]()NOTE()%f[%W]",  group = "MiniHipatternsNote"  },
				hex_color = require "mini.hipatterns".gen_highlighter.hex_color(),
				hl = {
					pattern = function(bufid)
						if vim.bo[bufid].define:match("colorscheme") then
							return "%f[%w]%w+%f[%W]"
						end
					end,
					group = function(_, match)
						if vim.fn.synIDattr(vim.fn.hlID(match), "name") == match then
							return match
						end
					end,
				},
			},
			delay = {
				text_change = 0,
				scroll = 0,
			},
		}
	end,
}

plug["HiPhish/rainbow-delimiters.nvim"] = {
	config = function()
		vim.g.rainbow_delimiters = {
			highlight = { "RainbowDelimiterRed", "RainbowDelimiterOrange", "RainbowDelimiterYellow", "RainbowDelimiterGreen", "RainbowDelimiterCyan", "RainbowDelimiterBlue", "RainbowDelimiterViolet" },
			strategy = {
				[""] = require "rainbow-delimiters".strategy["global"],
			},
			query = {
				[""] = "rainbow-delimiters",
				lua = "rainbow-blocks",
			},
		}
	end,
}

plug["rrethy/vim-illuminate"] = {
	config = function(_, opts)
		require "illuminate".configure(opts)
	end
}

return {}
