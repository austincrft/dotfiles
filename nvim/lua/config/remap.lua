vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true })
vim.keymap.set("n", "-", ":Ex<CR>", { noremap = true, silent = true })

-- System Clipboard
vim.keymap.set("v", "<leader>c", '"+y', { noremap = true, silent = true })
vim.keymap.set("n", "<leader>v", '"+p', { noremap = true, silent = true })
vim.keymap.set("v", "<leader>v", '"+p', { noremap = true, silent = true })

-- Buffer
vim.keymap.set("n", "<leader><Tab>", ":b#<CR>", { noremap = true, silent = true })

-- Formatting
vim.keymap.set("n", "<leader>fw", function()
  vim.opt.wrap = not vim.opt.wrap:get()
end, { desc = "Toggle line wrap" })

-- Meta
vim.keymap.set("n", "<leader>_d", ":e $MYVIMRC<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>_r", ":source $MYVIMRC<CR>", { noremap = true, silent = true })

-- Quickfix
vim.keymap.set("n", "<leader>qo", ":botright copen<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>qc", ":cclose<CR>", { noremap = true, silent = true })

-- Location List
vim.keymap.set("n", "<leader>lo", ":botright lopen<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>lc", ":lclose<CR>", { noremap = true, silent = true })

-- Substitute & Global
vim.keymap.set("n", "<leader>ss", ":%s/", { noremap = true, silent = true })
vim.keymap.set("v", "<leader>ss", '"zy:%s/<C-R>z/', { noremap = true, silent = true })
