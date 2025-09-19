vim.api.nvim_create_user_command("DiagSetQuickFix", function()
  vim.diagnostic.setqflist({ open = false, severity = { min = vim.diagnostic.severity.HINT } })
end, {})

vim.api.nvim_create_user_command("DiagOpenFloat", function()
  vim.diagnostic.open_float(nil, { focusable = false, border = 'rounded' })
end, {})

-- Strip trailing whitespace on save
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  callback = function()
    local curpos = vim.api.nvim_win_get_cursor(0) -- Save cursor position
    vim.cmd([[keeppatterns %s/\s\+$//e]])         -- Perform substitution
    vim.api.nvim_win_set_cursor(0, curpos)        -- Restore cursor position
  end,
})

