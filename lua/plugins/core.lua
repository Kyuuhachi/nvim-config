local lazy = require"98.util".lazy

return {
	-- picker
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		version = false, -- telescope did only one release, so use HEAD for now
		keys = (function()
			local tlb = lazy "telescope.builtin"
			return {
				{",F", tlb.git_files(), desc = "List files in repo"},
				{",F", tlb.git_files(), desc = "List files in repo"},
				{",f", tlb.find_files(), desc = "List files in dir"},
				{",g", tlb.live_grep(), desc = "Live grep"},
				{",b", tlb.buffers { sort_lastused = true, sort_mru = true, ignore_current_buffer = true }, desc = "List buffers"},
				{",h", tlb.highlights(), desc = "List highlights"},
				{",m", tlb.marks(), desc = "List marks"},
				{",M", tlb.keymaps { show_plug = false }, desc = "List mappings"},
				{",d", tlb.diagnostics(), desc = "List diagnostics"},
				{",.", tlb.resume(), desc = "Resume previous telescope"},
				{",s", tlb.lsp_document_symbols(), desc = "List document symbols"},
				{",S", tlb.lsp_dynamic_workspace_symbols(), desc = "List workspace symbols"},
			}
		end)(),
		opts = {
			defaults = {
				mappings = {
					i = {
						["<Esc>"] = function(...) require "telescope.actions".close(...) end,
					},
				},
			},
		},
		dependencies = { "nvim-lua/plenary.nvim" },
	},
}
