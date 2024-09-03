local util = require "98.util"
local plug = require "plugins"

plug["WhoIsSethDaniel/mason-tool-installer.nvim"] = {
	dependencies = { "williamboman/mason.nvim", opts = {} },
	opts = { ensure_installed = {} },
}

local function ensure_installed(name)
	table.insert(plug["WhoIsSethDaniel/mason-tool-installer.nvim"].opts.ensure_installed, name)
end

-- snippets (required for cmp)
plug["L3MON4D3/LuaSnip"] = {
	opts = {
		history = true,
		delete_check_events = "TextChanged",
	},
}

-- completion
local cmp_sources = {
	{ name = "nvim_lsp" },
	{ name = "luasnip" },
	{ name = "path" },
	{ name = "buffer" },
}
plug["hrsh7th/nvim-cmp"] = {
	version = false,
	event = "InsertEnter",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"saadparwaiz1/cmp_luasnip",
	},
	opts = function() return {
		completion = {
			completeopt = "menu,menuone,noselect,noinsert",
		},
		snippet = {
			expand = function(args) require("luasnip").lsp_expand(args.body) end,
		},
		mapping = {
			["<C-p>"] = require "cmp".mapping.select_prev_item(),
			["<C-n>"] = require "cmp".mapping.select_next_item(),
			["<C-k>"] = require "cmp".mapping.select_prev_item(),
			["<C-j>"] = require "cmp".mapping.select_next_item(),
			["<A-k>"] = require "cmp".mapping.scroll_docs(4),
			["<A-j>"] = require "cmp".mapping.scroll_docs(-4),
			["<CR>"] = require "cmp".mapping.confirm {select = false},
		},
		sources = cmp_sources,
	} end,
	init = function()
		vim.o.completeopt = "menu,menuone,noselect,noinsert"
	end,
}

vim.diagnostic.config {
	virtual_text = false,
	signs = true,
	update_in_insert = true,
	underline = true,
	severity_sort = true,
	float = {
		source = "always",
		header = "",
	},
}

local lsp_servers = {}
plug["neovim/nvim-lspconfig"] = {
	config = function()
		local caps = vim.tbl_deep_extend(
			"force",
			{},
			vim.lsp.protocol.make_client_capabilities(),
			require("cmp_nvim_lsp").default_capabilities()
		)
		for k, settings in pairs(lsp_servers) do
			settings.on_attach = function(client, bufnr)
				if client.server_capabilities.documentSymbolProvider then
					require "nvim-navic".attach(client, bufnr)
				end
			end
			settings.capabilities = caps

			require("lspconfig")[k].setup(settings)
		end
	end,
}

ensure_installed("lua-language-server")
lsp_servers.lua_ls = {
	settings = util.nested {
		["Lua.diagnostics.disable"] = { "trailing-space", "redefined-local" },
		["Lua.workspace.checkThirdParty"] = false,
		["Lua.telemetry.enable"] = false,
	},
}
plug["folke/lazydev.nvim"] = { ft = "lua", opts = { library = {} } }
plug["Bilal2453/luvit-meta"] = { lazy = true }
table.insert(cmp_sources, { name = "lazydev", group_index = 0 })

-- ccls isn't in mason?
-- ensure_installed("ccls")
lsp_servers.ccls = {
	settings = util.nested {
		["init_options.cache.directory"] = vim.fn.stdpath("cache").."/ccls-cache",
	},
}

ensure_installed("pyright")
lsp_servers.pyright = {
	settings = util.nested {
		["python.analysis.diagnosticSeverityOverrides"] = {
			reportMissingModuleSource = "none",
			reportUnusedVariable = "none",
			reportUnnecessaryIsInstance = "none",
			reportMissingParameterType = "information",
			reportMissingTypeArgument = "information",
			reportPropertyTypeMismatch = "warning",
			reportImplicitStringConcatenation = "information",
			reportUnnecessaryCast = "information",
			reportMatchNotExhaustive = "information",
			reportUnnecessaryTypeIgnoreComment = "information",
		},
	},
}

plug["Saecki/crates.nvim"] = {
	event = "BufRead Cargo.toml",
	opts = {},
}
table.insert(cmp_sources, { name = "crates" })

local function cargo_hover()
	if vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
		require("crates").show_popup()
	else
		vim.lsp.buf.hover()
	end
end
ensure_installed("taplo")
lsp_servers.taplo = {
	keys = { { "K", cargo_hover, desc = "show crate documentation" } },
}

plug["mrcjkb/rustaceanvim"] = {
	version = "^4",
	lazy = false,
}
vim.g.rustaceanvim = {
	server = {
		on_attach = function(_, bufnr)
			vim.keymap.set({"n","v"}, "<F1>", function() vim.cmd.RustLsp("codeAction") end, { buffer = bufnr })
			vim.keymap.set({"n","v"}, "J", function() vim.cmd.RustLsp("joinLines") end, { buffer = bufnr })
		end,
		default_settings = util.nested {
			["rust-analyzer.cargo.features"] = "all",
			["rust-analyzer.check.features"] = "all",
			["rust-analyzer.check.command"] = "clippy",
			["rust-analyzer.check.extraArgs"] = { "--no-deps" },
		}
	}
}

return {}
