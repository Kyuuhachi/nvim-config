local util = require "98.util"
local lazy = util.lazy

return {
	{
		"lewis6991/gitsigns.nvim",
		opts = {},
		event = { "BufReadPre", "BufNewFile" },
		keys = {
			{"]c", [[&diff ? ']c' : '<Cmd>Gitsigns next_hunk<CR>']], expr=true, mode={"n","v"}, desc="Go to previous hunk"},
			{"[c", [[&diff ? '[c' : '<Cmd>Gitsigns prev_hunk<CR>']], expr=true, mode={"n","v"}, desc="Go to next hunk"},
			{"\\h", "<Cmd>Gitsigns select_hunk", mode={"o", "x"}, desc="Select hunk"},

			{"\\s", "<Cmd>Gitsigns stage_hunk<CR>", mode={"n","v"}, desc="Stage hunk"},
			{"\\r", "<Cmd>Gitsigns reset_hunk<CR>", mode={"n","v"}, desc="Reset hunk"},
			{"\\r", "<Cmd>Gitsigns undo_stage_hunk<CR>", desc="Unstage hunk"},

			{"\\p", "<Cmd>Gitsigns preview_hunk<CR>", desc="Preview hunk"},
			{"\\b", "<Cmd>Gitsigns blame_line<CR>", desc="Blame line"},
			{"\\B", "<Cmd>Gitsigns blame_line full", desc="Blame line (full)"},
			{"\\d", "<Cmd>Gitsigns diffthis<CR>", desc="Git diff"},
			{"\\D", "<Cmd>Gitsigns diffthis ~1", desc="Git diff ~1"},
			{"\\t", "<Cmd>Gitsigns toggle_deleted<CR>", desc="Diff toggle deleted"},
		},
	},

	-- snippets
	{
		"L3MON4D3/LuaSnip",
		build = "make install_jsregexp",
		opts = {
			history = true,
			delete_check_events = "TextChanged",
		},
		init = function()
			require "luasnip.loaders.from_lua".lazy_load()
			vim.api.nvim_create_user_command("Snip", require("luasnip.loaders").edit_snippet_files, {})
		end,
		keys = {
			{
				"<tab>",
				function()
					return require "luasnip".jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
				end,
				expr = true,
				silent = true,
				mode = "i",
			},
			{ "<tab>", lazy "luasnip".jump(1), mode = "s" },
			{ "<s-tab>", lazy "luasnip".jump(-1), mode = { "i", "s" } },
		},
	},

	-- completion
	{
		"hrsh7th/nvim-cmp",
		version = false, -- last release is way too old
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
		},
		opts = function()
			local cmp = require "cmp"
			return {
				completion = {
					completeopt = "menu,menuone,noselect,noinsert",
				},
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = {
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-k>"] = cmp.mapping.select_prev_item(),
					["<C-j>"] = cmp.mapping.select_next_item(),
					["<A-k>"] = cmp.mapping.scroll_docs(4),
					["<A-j>"] = cmp.mapping.scroll_docs(-4),
					["<CR>"] = cmp.mapping.confirm {select = false},
				},
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
					{ name = "buffer" },
				},
			}
		end,
	},

	{
		"hrsh7th/cmp-nvim-lsp",
		optional = true,
		dependencies = {
			util.conf_put "neovim/nvim-lspconfig"(function(_, conf)
				conf.capabilities = require("cmp_nvim_lsp").default_capabilities(conf.capabilities)
			end),
		},
	},

	-- delimiter stuff
	{
		"kylechui/nvim-surround",
		event = "VeryLazy",
		opts = {
			surrounds = {
				["s"] = {
					add = { " ", "" },
				},
			}
		},
	},

	-- comments
	{
		"echasnovski/mini.comment",
		keys = {{"gc", mode = {"n", "v"}}},
		opts = {},
	},

	-- better text objects
	{
		"echasnovski/mini.ai",
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
	},

	-- block↔inline
	{
		"Wansmer/treesj",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			use_default_keymaps = false,
			max_join_length = 120,
		},
		keys = {
			{ "gs", lazy "treesj".split() },
			{ "gS", lazy "treesj".join() },
		},
	},

	-- 
	{
		"Wansmer/treesj",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			use_default_keymaps = false,
			max_join_length = 120,
		},
		keys = {
			{ "gs", lazy "treesj".split() },
			{ "gS", lazy "treesj".join() },
		},
	},

	-- peek lines in commandline
	{"nacro90/numb.nvim", event = "VeryLazy", opts = {}},

	-- fold
	{
		"kevinhwang91/nvim-ufo",
		dependencies = "kevinhwang91/promise-async",
		event = "BufReadPost",
		opts = {
			open_fold_hl_timeout = 0,
			fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
				local newVirtText = {}
				local suffix = (' + %d '):format(endLnum - lnum)
				local sufWidth = vim.fn.strdisplaywidth(suffix)
				local targetWidth = width - sufWidth
				local curWidth = 0
				for _, chunk in ipairs(virtText) do
					local chunkText = chunk[1]
					local chunkWidth = vim.fn.strdisplaywidth(chunkText)
					if curWidth + chunkWidth < targetWidth then
						table.insert(newVirtText, chunk)
					else
						chunkText = truncate(chunkText, targetWidth - curWidth)
						local hlGroup = chunk[2]
						table.insert(newVirtText, {chunkText, hlGroup})
						chunkWidth = vim.fn.strdisplaywidth(chunkText)
						if curWidth + chunkWidth < targetWidth then
							suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
						end
						break
					end
					curWidth = curWidth + chunkWidth
				end
				table.insert(newVirtText, {suffix, 'MoreMsg'})
				return newVirtText
			end
		},
		init = function()
			vim.keymap.set("n", "zR", function()
				require("ufo").openAllFolds()
			end)
			vim.keymap.set("n", "zM", function()
				require("ufo").closeAllFolds()
			end)

			vim.o.foldcolumn = '1' -- '0' is not bad
			vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true
		end,
	},

	{
		"hrsh7th/cmp-nvim-lsp",
		optional = true,
		dependencies = {
			util.conf_put "neovim/nvim-lspconfig"(function(_, conf)
				conf.capabilities.textDocument.foldingRange = {
					dynamicRegistration = false,
					lineFoldingOnly = true
				}
			end),
		},
	},
}
