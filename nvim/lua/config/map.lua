local keymap = vim.keymap.set

keymap("i", "jj", "<Esc>", { noremap = true, silent = true })
keymap("t", "jj", "<C-\\><C-n>", { noremap = true })
keymap("n", "<leader><leader>", ":DiagOpenFloat<CR>", { noremap = true, silent = true })
keymap("n", "-", function()
  local filename = vim.fn.expand("%:t")
  vim.cmd("Ex")
  vim.fn.search(filename, "w")
end, { noremap = true, silent = true })

-- Disable command-line mode
vim.keymap.set("n", "q:", "<nop>", { silent = true, desc = "Disable command-line window q:" })
vim.keymap.set("n", "Q", "<nop>", { silent = true, desc = "Disable Ex mode Q" })

-- System Clipboard
keymap("v", "<leader>c", '"+y', { noremap = true, silent = true })
keymap("n", "<leader>v", '"+p', { noremap = true, silent = true })
keymap("v", "<leader>v", '"+p', { noremap = true, silent = true })

-- Formatting
keymap("n", "<leader>fw", function()
  vim.opt.wrap = not vim.o.wrap
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

-- Diagnostic navigation
keymap("n", "]e", function()
  vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
end, { noremap = true, silent = true, desc = "Next error diagnostic" })

keymap("n", "[e", function()
  vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
end, { noremap = true, silent = true, desc = "Previous error diagnostic" })

keymap("n", "]w", function()
  vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.WARN })
end, { noremap = true, silent = true, desc = "Next warning diagnostic" })

keymap("n", "[w", function()
  vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.WARN })
end, { noremap = true, silent = true, desc = "Previous warning diagnostic" })
