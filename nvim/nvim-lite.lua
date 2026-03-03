vim.opt.nu = true

vim.g.mapleader = " "

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true })

vim.keymap.set("v", "<leader>c", '"+y', { noremap = true, silent = true })
vim.keymap.set("n", "<leader>v", '"+p', { noremap = true, silent = true })
vim.keymap.set("v", "<leader>v", '"+p', { noremap = true, silent = true })

vim.keymap.set("n", "<leader>fw", function()
  vim.opt.wrap = not vim.o.wrap
end, { desc = "Toggle line wrap" })
