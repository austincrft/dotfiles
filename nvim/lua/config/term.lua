-- Multi-tab floating terminal
local M = {
  terminals = {},    -- List of terminal buffer IDs
  active_idx = 1,    -- Currently active terminal index
  float_win = nil,   -- Current floating window ID
}

-- Clean up invalid terminal buffers
local function cleanup_terminals()
  local valid = {}
  for _, buf in ipairs(M.terminals) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
      table.insert(valid, buf)
    end
  end
  M.terminals = valid
  if M.active_idx > #M.terminals then
    M.active_idx = math.max(1, #M.terminals)
  end
end

-- Build the title string for tabs
local function build_title()
  local tabs = {}
  for i, _ in ipairs(M.terminals) do
    if i == M.active_idx then
      table.insert(tabs, "[" .. i .. "]")
    else
      table.insert(tabs, " " .. i .. " ")
    end
  end
  return table.concat(tabs, "")
end

-- Update the floating window title
local function update_title()
  if not M.float_win or not vim.api.nvim_win_is_valid(M.float_win) then
    return
  end
  local title = build_title()
  vim.api.nvim_win_set_config(M.float_win, { title = title, title_pos = "center" })
end

-- Get floating window config
local function get_float_config()
  local max_width = 180
  local width = math.min(math.floor(vim.o.columns * 0.8), max_width)
  local height = math.floor((vim.o.lines - 2) * 0.8)
  local row = math.floor((vim.o.lines - height - 2) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  return {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    border = 'rounded',
    title = build_title(),
    title_pos = "center",
  }
end

-- Forward declaration for setup_keymaps
local setup_keymaps

-- Create a new terminal buffer
local function create_terminal()
  local buf = vim.api.nvim_create_buf(false, true)
  table.insert(M.terminals, buf)
  M.active_idx = #M.terminals

  if M.float_win and vim.api.nvim_win_is_valid(M.float_win) then
    vim.wo[M.float_win].winfixbuf = false
    vim.api.nvim_win_set_buf(M.float_win, buf)
    vim.wo[M.float_win].winfixbuf = true
    update_title()
  end

  vim.fn.termopen("pwsh -NoLogo")
  setup_keymaps(buf)
  vim.cmd("startinsert")
end

-- Switch to terminal at index
local function switch_terminal(idx)
  cleanup_terminals()
  if idx < 1 or idx > #M.terminals then
    return
  end

  M.active_idx = idx
  local buf = M.terminals[idx]

  if M.float_win and vim.api.nvim_win_is_valid(M.float_win) then
    vim.wo[M.float_win].winfixbuf = false
    vim.api.nvim_win_set_buf(M.float_win, buf)
    vim.wo[M.float_win].winfixbuf = true
    setup_keymaps(buf)
    update_title()
    vim.cmd("startinsert")
  end
end

-- Next terminal
local function next_terminal()
  cleanup_terminals()
  if #M.terminals == 0 then return end
  local next_idx = M.active_idx % #M.terminals + 1
  switch_terminal(next_idx)
end

-- Previous terminal
local function prev_terminal()
  cleanup_terminals()
  if #M.terminals == 0 then return end
  local prev_idx = (M.active_idx - 2) % #M.terminals + 1
  switch_terminal(prev_idx)
end

-- Close current terminal
local function close_terminal()
  cleanup_terminals()
  if #M.terminals == 0 then return end

  local buf = M.terminals[M.active_idx]
  table.remove(M.terminals, M.active_idx)

  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
  end

  if #M.terminals == 0 then
    if M.float_win and vim.api.nvim_win_is_valid(M.float_win) then
      vim.api.nvim_win_close(M.float_win, false)
      M.float_win = nil
    end
    return
  end

  M.active_idx = math.min(M.active_idx, #M.terminals)
  switch_terminal(M.active_idx)
end

-- Set up keymaps for the terminal buffer
setup_keymaps = function(buf)
  local opts = { buffer = buf, noremap = true, silent = true }

  vim.keymap.set({ "t", "n" }, "<C-n>", function()
    vim.cmd("stopinsert")
    create_terminal()
  end, opts)

  vim.keymap.set({ "t", "n" }, "<C-l>", function()
    vim.cmd("stopinsert")
    next_terminal()
  end, opts)

  vim.keymap.set({ "t", "n" }, "<C-h>", function()
    vim.cmd("stopinsert")
    prev_terminal()
  end, opts)
end

-- Main toggle function
local function term_toggle()
  if M.float_win and vim.api.nvim_win_is_valid(M.float_win) then
    vim.api.nvim_win_close(M.float_win, false)
    M.float_win = nil
    return
  end

  cleanup_terminals()

  local opts = get_float_config()

  if #M.terminals == 0 then
    local buf = vim.api.nvim_create_buf(false, true)
    table.insert(M.terminals, buf)
    M.active_idx = 1

    opts.title = build_title()
    M.float_win = vim.api.nvim_open_win(buf, true, opts)
    vim.wo[M.float_win].winfixbuf = true
    setup_keymaps(buf)

    vim.fn.termopen("pwsh -NoLogo")
    vim.cmd("startinsert")
    return
  end

  local buf = M.terminals[M.active_idx]
  M.float_win = vim.api.nvim_open_win(buf, true, opts)
  vim.wo[M.float_win].winfixbuf = true
  setup_keymaps(buf)
  vim.cmd("startinsert")
end

-- Expose functions
M.toggle = term_toggle
M.create = create_terminal
M.next = next_terminal
M.prev = prev_terminal
M.close = close_terminal
M.switch = switch_terminal

-- Commands
vim.api.nvim_create_user_command("TermToggle", term_toggle, { desc = "Toggle floating terminal window" })
vim.api.nvim_create_user_command("TermNew", create_terminal, { desc = "Create new terminal tab" })
vim.api.nvim_create_user_command("TermNext", next_terminal, { desc = "Switch to next terminal" })
vim.api.nvim_create_user_command("TermPrev", prev_terminal, { desc = "Switch to previous terminal" })
vim.api.nvim_create_user_command("TermClose", close_terminal, { desc = "Close current terminal" })

-- Global keymaps
vim.keymap.set("n", "<C-t>", term_toggle, { noremap = true, desc = "Toggle floating terminal" })
vim.keymap.set("t", "<C-t>", "<C-\\><C-n><Cmd>TermToggle<CR>", { noremap = true, desc = "Toggle floating terminal" })

return M
