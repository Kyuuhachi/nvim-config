local util = require "98.util"
local lazy = util.lazy
local plug = require "plugins"

plug["kylechui/nvim-surround"] = {
	event = "VeryLazy",
	opts = {
		surrounds = {
			["s"] = {
				add = { " ", "" },
			},
		}
	},
}

plug["echasnovski/mini.comment"] = {
	keys = {{"gc", mode = {"n", "v"}}},
	opts = {},
}

plug["echasnovski/mini.ai"] = {
	keys = {
		{ "a", mode = { "x", "o" } },
		{ "i", mode = { "x", "o" } },
	},
	event = "VeryLazy",
	dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
	opts = function()
		local ai = require "mini.ai"
		return {
			n_lines = 1500,
			custom_textobjects = {
				o = ai.gen_spec.treesitter({
					a = { "@block.outer", "@conditional.outer", "@loop.outer" },
					i = { "@block.inner", "@conditional.inner", "@loop.inner" },
				}, {}),
				f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
				c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
			},
		}
	end,
}

plug["Wansmer/treesj"] = {
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	opts = {
		use_default_keymaps = false,
		check_syntax_error = false,
		max_join_length = 0xFFFFFFFF,
	},
	keys = {
		{ "gs", lazy "treesj".split() },
		{ "gS", lazy "treesj".join() },
	},
}

plug["junegunn/vim-easy-align"] = {
	command = "EasyAlign",
}

plug["Vimjas/vim-python-pep8-indent"] = {
	ft = "python",
}

return {}
