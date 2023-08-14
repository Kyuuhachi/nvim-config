local util = require "98.util"

return {
	{
		"Saecki/crates.nvim",
		event = "BufRead Cargo.toml",
		opts = {}
	},

	util.conf_add_to "hrsh7th/nvim-cmp".sources { { name = "crates" } },

	util.conf_add_to "WhoIsSethDaniel/mason-tool-installer.nvim".ensure_installed { "taplo" },
	util.conf_add_to "neovim/nvim-lspconfig".servers.taplo.keys {
		{
			"K",
			function()
				if vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
					require("crates").show_popup()
				else
					vim.lsp.buf.hover()
				end
			end,
			desc = "show crate documentation",
		},
	},

	util.conf_add_to "nvim-treesitter/nvim-treesitter".ensure_installed { "ron", "rust", "toml" },

	util.conf_put "neovim/nvim-lspconfig".servers.rust_analyzer {
		keys = {
			{ "K", "<cmd>RustHoverActions<cr>", desc = "Hover Actions (Rust)" },
			{ "F1", "<cmd>RustCodeAction<cr>", desc = "Code Action (Rust)" },
			{ "F3", "<cmd>RustDebuggables<cr>", desc = "Run Debuggables (Rust)" },
		},
		settings = util.nested {
			["rust-analyzer.cargo.features"] = "all",
			["rust-analyzer.cargo.buildScripts.enable"] = true,
			["rust-analyzer.procMacro.enabled"] = true,
			["rust-analyzer.check.features"] = "all",
			["rust-analyzer.check.command"] = "clippy",
			["rust-analyzer.check.extraArgs"] = { "--no-deps" },
			-- ["completion.callable.snippets"] = none,
			-- ["completion.postfix.enable"] = false,
		},
	},

	{
		"simrat39/rust-tools.nvim",
		opts = {
			tools = {
				inlay_hints = {
					only_current_line = true,
				},
			}
		}
	},

	-- integrate rust-tools into lspconfig
	{
		"simrat39/rust-tools.nvim",
		optional = true,
		config = function() end, -- called from lspconfig setup
		dependencies = {
			util.conf_put "neovim/nvim-lspconfig".servers.rust_analyzer {
				setup = function(server)
					local rt = require "lazy.core.config".plugins["rust-tools.nvim"]
					local opts = require "lazy.core.plugin".values(rt, "opts", false)
					opts.server = vim.tbl_deep_extend("force", server, opts.server or {})
					require "rust-tools".setup(opts)
				end
			}
		}
	},

	-- integrate rust-tools with dap+mason
	util.conf_add_to "WhoIsSethDaniel/mason-tool-installer.nvim".ensure_installed { "codelldb" },
	util.conf_put "simrat39/rust-tools.nvim".dap(function(_, dap)
		local ok, mason_registry = pcall(require, "mason-registry")
		if ok then
			local codelldb = mason_registry.get_package("codelldb")
			local extension_path = codelldb:get_install_path() .. "/extension/"
			local codelldb_path = extension_path .. "adapter/codelldb"
			local liblldb_path
			if vim.fn.has("mac") == 1 then
				liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"
			else
				liblldb_path = extension_path .. "lldb/lib/liblldb.so"
			end
			dap.adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path)
		end
	end),

	-- add rust to neotest
	{
		"nvim-neotest/neotest",
		optional = true,
		dependencies = {
			"rouge8/neotest-rust",
		},
		opts = {
			adapters = {
				["neotest-rust"] = {},
			},
		},
	},
}
