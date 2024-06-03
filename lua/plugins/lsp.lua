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

				settings.on_attach = function(client, bufnr)
					if client.server_capabilities.documentSymbolProvider then
						require "nvim-navic".attach(client, bufnr)
					end
					if opts.on_attach then
						opts.on_attach(client, bufnr)
					end
				end

				if not settings.capabilities then
					settings.capabilities = opts.capabilities
				end

				setup(settings)
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

	util.conf_put "neovim/nvim-lspconfig".servers.lua_ls {
		settings = util.nested {
			["Lua.diagnostics.disable"] = { "trailing-space", "redefined-local" },
			["Lua.workspace.checkThirdParty"] = false,
			["Lua.telemetry.enable"] = false,
		}
	},

	-- ccls isn't in mason?
	-- util.conf_add_to "WhoIsSethDaniel/mason-tool-installer.nvim".ensure_installed { "ccls" },

	util.conf_put "neovim/nvim-lspconfig".servers.ccls {
		settings = util.nested {
			["init_options.cache.directory"] = vim.fn.stdpath("cache").."/ccls-cache",
		},
	},

	util.conf_add_to "WhoIsSethDaniel/mason-tool-installer.nvim".ensure_installed { "pyright" },
	util.conf_put "neovim/nvim-lspconfig".servers.pyright {
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
	},

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

	{ "rrethy/vim-illuminate" }
}
