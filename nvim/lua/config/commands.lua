vim.api.nvim_create_user_command("DiagOpenFloat", function()
  vim.diagnostic.open_float(nil, { focusable = false, border = 'rounded' })
end, {})

vim.api.nvim_create_user_command("TerminalTab", function()
  -- Check if the first tab already has a terminal buffer
  local tab = vim.api.nvim_list_tabpages()[1]
  local has_terminal = false
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" then
      has_terminal = true
      break
    end
  end


  if has_terminal then
    vim.api.nvim_set_current_tabpage(tab)
    vim.cmd("startinsert")
  else
    vim.cmd("tabnew")
    vim.cmd("tabmove 0")
    vim.cmd("terminal pwsh")
    vim.cmd("startinsert")
  end
end, { desc = "Open or switch to terminal tab" })

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
