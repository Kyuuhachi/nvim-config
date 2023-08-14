local util = require "98.util"

return {
	{
		"nvim-treesitter/nvim-treesitter",
		version = false, -- last release is way too old and doesn't work on Windows
		build = ":TSUpdate",
		-- event = { "BufReadPost", "BufNewFile" },
		-- cmd = { "TSUpdateSync" },
		main = "nvim-treesitter.configs",
		opts = {
			highlight = { enable = true },
			indent = { enable = true },
			ensure_installed = {
				"query",
				"lua", "luadoc", "luap",
				"python",
				"rust",
				"c", "cpp",
				"javascript", "jsdoc", "html", "css",
				"markdown", "markdown_inline",
				"bash",
				"json", "yaml", "toml",
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
	},

	-- playground
	{
		"nvim-treesitter/playground",
		lazy = true,
		cmd = "TSPlaygroundToggle",
		opts = {},
		config = function(_, opts)
			require "nvim-treesitter.configs".setup { playground = opts }
		end,
	},
	util.conf_add_to "nvim-treesitter/nvim-treesitter".ensure_installed { "query" },

	-- show TODO comments
	{
		"echasnovski/mini.hipatterns",
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
				},
				delay = {
					text_change = 0,
					scroll = 0,
				},
			}
		end
	},

	-- color scheme
	{
		"rktjmp/lush.nvim",
		priority = 1000,
		lazy = false,
		init = function()
			vim.cmd [[colorscheme worzel]]
		end
	},

	-- rainbow delimiters
	{
		"HiPhish/rainbow-delimiters.nvim",
		-- event = "VeryLazy",
		opts = function() return {
			highlight = { "Rainbow1", "Rainbow2", "Rainbow3", "Rainbow4", "Rainbow5", "Rainbow6" },
			strategy = {
				[""] = require "rainbow-delimiters".strategy["global"],
			},
			query = {
				[""] = "rainbow-delimiters",
				lua = "rainbow-blocks",
			},
		} end,
		config = function(_, opts)
			vim.g.rainbow_delimiters = opts
		end,
	},
}
