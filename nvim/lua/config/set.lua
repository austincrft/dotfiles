vim.opt.nu = true

vim.opt.termguicolors = true

vim.opt.wrap = false
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.breakindent = true
vim.opt.foldmethod = "indent"
vim.opt.foldlevelstart = 99
vim.opt.nrformats:append("alpha")
vim.opt.diffopt:append("vertical")

vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.list = true
vim.opt.listchars = {
    tab = "-→",
    trail = "·",
}

vim.g.netrw_banner = 0

vim.g.mapleader = " "

vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"

vim.filetype.add({
  pattern = {
    ['.*%.json'] = "jsonc",
    ['.*%.xaml'] = "xml",
  },
})
