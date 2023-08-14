local util = require "98.util"

return {
	{ "williamboman/mason.nvim", opts = {}, },

	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = "williamboman/mason.nvim",
		opts = {}
	},

	{
		"neovim/nvim-lspconfig",
		opts = {
			capabilities = vim.lsp.protocol.make_client_capabilities(),
			on_attach = function() end,
			diagnostic = {},
			servers = {},
		},
		config = function(_, opts)
			vim.diagnostic.config(opts.diagnostic)
			for k, settings in pairs(opts.servers) do
				local setup = settings.setup or require("lspconfig")[k].setup
				settings.setup = nil
				setup {
					on_attach = opts.on_attach,
					capabilities = opts.capabilities,
					settings = settings,
				}
			end
		end,
	},

	util.conf_add_to "WhoIsSethDaniel/mason-tool-installer.nvim".ensure_installed { "lua-language-server" },

	{
		"folke/neodev.nvim",
		opts = {},
		init = function()
			-- weirdo hack that's needed for some reason
			local lsputil = require "lspconfig.util"
			lsputil.on_setup = lsputil.add_hook_after(lsputil.on_setup, function() end)
		end,
	},

	{ "neovim/nvim-lspconfig", optional = true, dependencies = {
		{ "folke/neodev.nvim", optional = true },
	} },

	util.conf_put "neovim/nvim-lspconfig".servers.lua_ls(util.nested {
		Lua = util.nested {
			["diagnostics.disable"] = { "trailing-space", "redefined-local" },
			["workspace.checkThirdParty"] = false,
			["telemetry.enable"] = false,
		},
	}),

	-- ccls isn't in mason?
	-- util.conf_add_to "WhoIsSethDaniel/mason-tool-installer.nvim".ensure_installed { "ccls" },

	util.conf_put "neovim/nvim-lspconfig".servers.ccls(util.nested {
		["init_options.cache.directory"] = vim.fn.stdpath("cache").."/ccls-cache",
	}),

	util.conf_put "neovim/nvim-lspconfig".diagnostic {
		virtual_text = false,
		signs = true,
		update_in_insert = true,
		underline = true,
		severity_sort = true,
		float = {
			source = "always",
			header = "",
		},
	},
}
