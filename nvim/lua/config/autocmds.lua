-- Strip trailing whitespace on save
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  callback = function()
    local curpos = vim.api.nvim_win_get_cursor(0) -- Save cursor position
    vim.cmd([[keeppatterns %s/\s\+$//e]])         -- Perform substitution
    vim.api.nvim_win_set_cursor(0, curpos)        -- Restore cursor position
  end,
})

-- Expand quickfix
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  pattern = { "[^l]*" },
  command = "botright copen"
})


-- Enable treesitter folding
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    local parsers = require("nvim-treesitter.parsers")
    local parser = parsers.has_parser() and parsers.get_parser()
    if parser then
      parser:parse()
      vim.o.foldmethod = "expr"
      vim.o.foldexpr = "nvim_treesitter#foldexpr()"
    end
  end,
})
