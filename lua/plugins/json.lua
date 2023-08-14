local util = require "98.util"

return {
	util.conf_add_to "nvim-treesitter/nvim-treesitter".ensure_installed { "json", "json5", "jsonc" },

	{
		"neovim/nvim-lspconfig",
		optional = true,
		dependencies = {
			"b0o/SchemaStore.nvim",
			version = false, -- last release is way too old
		},
		opts = {
			servers = {
				jsonls = {
					on_new_config = function(new_config)
						new_config.settings.json.schemas = new_config.settings.json.schemas or {}
						vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
					end,
					settings = {
						json = {
							format = {
								enable = true,
							},
							validate = { enable = true },
						},
					},
				},
			},
		},
	},
}
