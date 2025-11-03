local function term_toggle()
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
end

vim.api.nvim_create_user_command("TermToggle", term_toggle, { desc = "Toggle floating terminal window" })
vim.keymap.set("n", "<C-t>", term_toggle, { noremap = true })
vim.keymap.set("t", "<C-t>", "<C-\\><C-n><Cmd>TermToggle<CR>", { noremap = true })
