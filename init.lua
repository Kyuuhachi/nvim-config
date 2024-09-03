-- kodoku integration: make ~ behave nicely
if vim.env.KODOKU_HOME and vim.env.USER_HOME then
	local _stdpath = {}
	for _, k in pairs{"cache", "config", "config_dirs", "data", "data_dirs", "log", "run", "state"} do
		_stdpath[k] = vim.fn.stdpath(k)
	end
	vim.opt.shadafile = _stdpath["data"].."/shada/main.shada"
	vim.env.NVIM_RPLUGIN_MANIFEST = _stdpath["data"].."/rplugin.vim"
	vim.fn.stdpath = function(a) return _stdpath[a] or error(("invalid stdpath(%q)"):format(a)) end
	vim.cmd [[ let $HOME = $USER_HOME ]] -- Assigning to vim.env.HOME doesn't work, #17501
end

-- plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system {
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	}
end
vim.opt.rtp:prepend(lazypath)

local o = vim.opt

o.mouse = ""

o.number = true
o.splitright = true
o.splitbelow = true
o.showmode = false
o.cmdheight = 2
o.wildmode = {"longest", "list"}
o.signcolumn = "yes"

o.scrolloff = 7
o.sidescrolloff = 30
o.wrap = false
o.linebreak = true

o.list = true
o.listchars = {
	tab = "⟩ ",
	trail = "+",
	precedes = "<",
	extends = ">",
	space = "·",
	nbsp = "␣",
}

local function gcd(a, b)
	return b==0 and a or gcd(b,a%b)
end

local function update_lead()
	local lcs = vim.opt_local.listchars:get()
	local tab = vim.fn.str2list(lcs.tab)
	local space = vim.fn.str2list(vim.opt.listchars:get().leadmultispace or lcs.lead or lcs.multispace or lcs.space)
	local ts = vim.bo.tabstop
	local lcm = (ts * #space)/gcd(ts, #space)
	local lead = {}
	for i = 0, lcm-1 do
		if i % ts == 0 then
			lead[#lead+1] = tab[1]
		else
			lead[#lead+1] = space[i % #space + 1]
		end
	end
	vim.opt_local.listchars:append({
		leadmultispace = vim.fn.list2str(lead),
	})
end
vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = update_lead })
vim.api.nvim_create_autocmd("OptionSet", { pattern = { "listchars", "tabstop", "filetype" }, callback = update_lead })

o.cursorline = true
o.virtualedit = "block"

o.foldmethod = "marker"
o.foldlevelstart = 99

o.ignorecase = true
o.smartcase = true
o.gdefault = true
o.diffopt = { "filler", "vertical", "internal", "indent-heuristic", "closeoff", "iwhite" }

o.undofile = true
o.swapfile = false
o.paragraphs = ""
o.sections = ""
o.fileencodings = "utf8,cp932,latin1"

o.updatetime = 250
o.timeout = false

o.commentstring = "# %s"
o.formatoptions = "j"
o.expandtab = false
o.tabstop = 4
o.softtabstop = 0
o.shiftwidth = 0

vim.cmd[[
au FileType *       setlocal et< ts< sw< sts< fo< noshowmatch syntax=ON
au FileType haskell setlocal et ts=2
au FileType yaml    setlocal et ts=2

au StdinReadPost * set nomodified
]]

vim.keymap.set({"","l"}, "<F1>", "<Nop>")
vim.keymap.set("n", ",,", "<C-^>")

vim.keymap.set("", "H", "['^', 'g^'][&wrap]", {expr = true, remap = true})
vim.keymap.set("", "L", "['$', 'g$'][&wrap]", {expr = true, remap = true})
vim.keymap.set("", "n", "'Nn'[v:searchforward]", {expr = true})
vim.keymap.set("", "N", "'nN'[v:searchforward]", {expr = true})

-- https://vi.stackexchange.com/questions/4054/case-sensitive-with-ignorecase-on
vim.cmd[[
nnoremap <silent>  * :let @/='\C\<' . expand('<cword>') . '\>'<CR>:let v:searchforward=1<CR>n
nnoremap <silent>  # :let @/='\C\<' . expand('<cword>') . '\>'<CR>:let v:searchforward=0<CR>n
nnoremap <silent> g* :let @/='\C'   . expand('<cword>')       <CR>:let v:searchforward=1<CR>n
nnoremap <silent> g# :let @/='\C'   . expand('<cword>')       <CR>:let v:searchforward=0<CR>n
]]

vim.keymap.set("n", "<C-k>", vim.diagnostic.goto_prev)
vim.keymap.set("n", "<C-j>", vim.diagnostic.goto_next)

vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gi", vim.lsp.buf.implementation)
vim.keymap.set("n", "gr", vim.lsp.buf.references)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "gK", vim.lsp.buf.signature_help)
vim.keymap.set({"n","v"}, "<F1>", vim.lsp.buf.code_action)
vim.keymap.set("n", "<F2>", vim.lsp.buf.rename)

vim.api.nvim_create_autocmd("LspAttach", { callback = function(args)
	local client = vim.lsp.get_client_by_id(args.data.client_id)
	if client and client.server_capabilities.code_lens then
		vim.api.nvim_create_autocmd({"BufEnter","CursorHold","InsertLeave"}, {
			callback = function() vim.lsp.codelens.refresh() end,
			buffer = args.bufnr,
		})
	end
end })

vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0

-- putting plugins last makes the above settings apply even if it fails to load
require "lazy".setup("plugins", {
	dev = {
		patterns = { "Kyuuhachi" },
		path = vim.fn.fnamemodify(vim.env.MYVIMRC, ":p:h:h") .. "/local",
	},
	install = {
		colorscheme = { "worzel" },
	},
})
