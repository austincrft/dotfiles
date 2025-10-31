vim.api.nvim_create_user_command("DiagOpenFloat", function()
  vim.diagnostic.open_float(nil, { focusable = true, border = 'rounded' })
end, { desc = "Open diagnostic float" })

vim.api.nvim_create_user_command("DiagSetQuickFix", function()
  vim.diagnostic.setqflist({ open = false, severity = { min = vim.diagnostic.severity.WARN } })
  vim.cmd("botright copen")
end, {})

vim.api.nvim_create_user_command("TermToggle", function()
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
    -- Close the terminal window
    vim.api.nvim_win_close(terminal_win, false)
    return
  end

  -- Look for existing terminal buf
  local terminal_buf = nil
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == "terminal" and vim.api.nvim_buf_is_valid(buf) then
      terminal_buf = buf
      break
    end
  end

  -- Calculate floating window size (80% width, 80% height)
  local max_width = 180  -- Max width for ultrawide monitors
  local width = math.min(math.floor(vim.o.columns * 0.8), max_width)
  local height = math.floor((vim.o.lines - 2) * 0.8)  -- Account for cmdline
  local row = math.floor((vim.o.lines - height - 2) / 2)  -- Centered vertically
  local col = math.floor((vim.o.columns - width) / 2)  -- Centered horizontally

  -- Create floating window config
  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
  }

  if terminal_buf then
    -- Open the existing terminal buf in floating window
    local win = vim.api.nvim_open_win(terminal_buf, true, opts)
  else
    -- Create new terminal buf and open in floating window
    terminal_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_open_win(terminal_buf, true, opts)
    vim.fn.termopen("pwsh -NoLogo")
    vim.cmd("startinsert")
  end
end, { desc = "Toggle floating terminal window" })

vim.api.nvim_create_user_command("DeleteInactiveBuffers", function()
  -- Collect all visible buffers in all windows of all tabpages
  local visible = {}
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      visible[vim.api.nvim_win_get_buf(win)] = true
    end
  end

  -- Delete all listed buffers that are not visible, except terminals
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf)
      and vim.api.nvim_buf_get_option(buf, "buflisted")
      and not visible[buf]
      and vim.bo[buf].buftype ~= "terminal"
    then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
end, {})
