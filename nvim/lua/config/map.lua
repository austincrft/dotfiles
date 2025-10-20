local keymap = vim.keymap.set

keymap("i", "jj", "<Esc>", { noremap = true, silent = true })
keymap("t", "jj", "<C-\\><C-n>", { noremap = true })
keymap("n", "<leader><leader>", ":DiagOpenFloat<CR>", { noremap = true, silent = true })
keymap("n", "-", function()
  local filename = vim.fn.expand("%:t")
  vim.cmd("Ex")
  vim.fn.search(filename, "w")
end, { noremap = true, silent = true })

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

-- Substitute
keymap("n", "<leader>ss", ":%s/", { noremap = true })
keymap("v", "<leader>ss", '"zy:%s/<C-R>z/', { noremap = true })

-- Terminal
keymap("n", "<leader>TT", ":OpenTerminal<CR>", { noremap = true })

-- Meta
keymap("n", "<leader>_d", function ()
  vim.cmd("edit " .. vim.fn.stdpath("config"))
end, { noremap = true, silent = true })

keymap("n", "<leader>_p", function ()
  vim.cmd("edit " .. vim.fn.stdpath("data") .. "/lazy")
end, { noremap = true, silent = true })

keymap("n", "<leader>_w", function ()
  vim.cmd("edit ~/work/nvim")
end, { noremap = true, silent = true })
