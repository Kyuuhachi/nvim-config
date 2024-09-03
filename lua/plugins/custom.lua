local plug = require "plugins"

plug["Kyuuhachi/ga.nvim"] = { cmd = "GaMakeCache", keys = "ga", opts = {} }
plug["Kyuuhachi/hitree.nvim"] = { cmd = "Hitree", opts = {} }
plug["Kyuuhachi/mkdir.nvim"] = { autocmd = "BufWritePre", opts = {} }
plug["Kyuuhachi/bonsai.nvim"] = { opts = {} }

plug["Kyuuhachi/nvdim"] = {
	priority = -100,
	opts = function() return {
		-- color = require "nvdim.color".axis("#2E3440", "#4C566A", 0.7), -- nord0, nord3
		color = require "nvdim.color".point("#2E3440", 0.5), -- nord0
		override = {
			CursorLine = {},
			Search = { bg = "#4C566A" }, -- nord3
		}
	} end,
	init = function()
		local hi = require "mini.hipatterns"
		local compute_hex_color_group = hi.compute_hex_color_group
		hi.compute_hex_color_group = function(...)
			local v = compute_hex_color_group(...)
			require "nvdim".sync_highlights(0, {v})
			return v
		end
	end
}

plug["Kyuuhachi/knob.nvim"] = {
	opts = {
		winblend = 0, -- until #10685 is fixed
	},
}

plug["Kyuuhachi/worzel.nvim"] = {
	(function()
		table.insert(require "lazy.core.config".defaults.install.colorscheme, 1, "worzel")
	end)(),
	priority = 1000,
	lazy = false,
	dependencies = "rktjmp/lush.nvim",
	init = function()
		vim.cmd.colorscheme("worzel")
		require"worzel".enable_background()
	end,
}

return {}
