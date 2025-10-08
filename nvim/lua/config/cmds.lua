-- DiagOpenFloat
vim.api.nvim_create_user_command("DiagOpenFloat", function()
  vim.diagnostic.open_float(nil, { focusable = false, border = 'rounded' })
end, { desc = "Open diagnostic float" })

-- OpenTerminal
vim.api.nvim_create_user_command("OpenTerminal", function()
  local cur_tab = vim.api.nvim_get_current_tabpage()
  local terminal_win = nil

  -- Look for a terminal window in the current tab
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(cur_tab)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" then
      terminal_win = win
      break
    end
  end

  if terminal_win then
    -- Focus the terminal window
    vim.api.nvim_set_current_win(terminal_win)
    return
  end

  -- Look for existing terminal buf
  local terminal_buf = nil
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == "terminal" then
      terminal_buf = buf
      break
    end
  end

  if terminal_buf then
    -- Open the existing terminal buf in new split
    vim.cmd("botright split")
    vim.api.nvim_win_set_buf(0, terminal_buf)
    vim.cmd("resize 15")
  else
    -- No terminal buf exists, open a new one
    vim.cmd("botright split | terminal pwsh -NoLogo")
    vim.cmd("resize 15")
    vim.cmd("startinsert")
  end
end, { desc = "Open or switch to terminal window" })

