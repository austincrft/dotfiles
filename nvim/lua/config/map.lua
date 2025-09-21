local keymap = vim.keymap.set

keymap("i", "jj", "<Esc>", { noremap = true, silent = true })
keymap("n", "-", ":Ex<CR>", { noremap = true, silent = true })
keymap("n", "<leader><leader>", ":DiagOpenFloat<CR>", { noremap = true, silent = true })

-- System Clipboard
keymap("v", "<leader>c", '"+y', { noremap = true, silent = true })
keymap("n", "<leader>v", '"+p', { noremap = true, silent = true })
keymap("v", "<leader>v", '"+p', { noremap = true, silent = true })

-- Buffer
keymap("n", "<leader><Tab>", ":b#<CR>", { noremap = true, silent = true })

-- Formatting
keymap("n", "<leader>fw", function()
  vim.opt.wrap = not vim.opt.wrap:get()
end, { desc = "Toggle line wrap" })

-- Quickfix
keymap("n", "<leader>qo", ":botright copen<CR>", { noremap = true, silent = true })
keymap("n", "<leader>qc", ":cclose<CR>", { noremap = true, silent = true })
keymap("n", "<leader>qC", ":cexpr []<CR>", { noremap = true, silent = true })

-- Location List
keymap("n", "<leader>lo", ":botright lopen<CR>", { noremap = true, silent = true })
keymap("n", "<leader>lc", ":lclose<CR>", { noremap = true, silent = true })

-- Substitute & Global
keymap("n", "<leader>ss", ":%s/", { noremap = true })
keymap("v", "<leader>ss", '"zy:%s/<C-R>z/', { noremap = true })

-- Meta
keymap("n", "<leader>_d", ":e $MYVIMRC<CR>", { noremap = true, silent = true })
keymap("n", "<leader>_r", ":source $MYVIMRC<CR>", { noremap = true, silent = true })
