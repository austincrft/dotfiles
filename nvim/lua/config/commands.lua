vim.api.nvim_create_user_command("DiagSetQuickFix", function()
  vim.diagnostic.setqflist({ open = false, severity = { min = vim.diagnostic.severity.HINT } })
end, {})

vim.api.nvim_create_user_command("DiagOpenFloat", function()
  vim.diagnostic.open_float(nil, { focusable = false, border = 'rounded' })
end, {})

