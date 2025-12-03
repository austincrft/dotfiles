local M = {}

-- Track center mode state per-tab
M.tabs = {}  -- { [tab_id] = { left_win, right_win, center_win, left_buf, right_buf } }

-- Auto-center configuration
M.auto_width_col_threshold = 200

-- Create uneditable side buffer
local function create_side_buffer()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = 'center-padding'
  return buf
end

-- Get state for current tab
local function get_tab_state()
  local tab = vim.api.nvim_get_current_tabpage()
  return M.tabs[tab]
end

-- Set state for current tab
local function set_tab_state(state)
  local tab = vim.api.nvim_get_current_tabpage()
  M.tabs[tab] = state
end

-- Check if current tab is centered
local function is_centered()
  local state = get_tab_state()
  return state ~= nil
end

-- Exit center mode
function M.exit()
  local state = get_tab_state()
  if not state then
    return
  end

  -- Delete side buffers (this will automatically close their windows)
  if state.left_buf and vim.api.nvim_buf_is_valid(state.left_buf) then
    vim.api.nvim_buf_delete(state.left_buf, { force = true })
  end
  if state.right_buf and vim.api.nvim_buf_is_valid(state.right_buf) then
    vim.api.nvim_buf_delete(state.right_buf, { force = true })
  end

  -- Focus the center window if it's still valid
  if state.center_win and vim.api.nvim_win_is_valid(state.center_win) then
    pcall(vim.api.nvim_set_current_win, state.center_win)
  end

  -- Clear state for this tab
  set_tab_state(nil)
end

-- Enter center mode
function M.enter()
  if is_centered() then
    return
  end

  local state = {}

  -- Get the current window (this will be the center)
  state.center_win = vim.api.nvim_get_current_win()

  -- Calculate side buffer width (20% of screen on each side)
  local side_width = math.floor(vim.o.columns * 0.2)

  -- Create left side buffer
  state.left_buf = create_side_buffer()
  vim.cmd('topleft vsplit')
  state.left_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.left_win, state.left_buf)
  vim.api.nvim_win_set_width(state.left_win, side_width)

  -- Disable various UI elements for side buffers
  vim.wo[state.left_win].number = false
  vim.wo[state.left_win].relativenumber = false
  vim.wo[state.left_win].signcolumn = 'no'
  vim.wo[state.left_win].foldcolumn = '0'
  vim.wo[state.left_win].cursorline = false
  vim.wo[state.left_win].statusline = '%#Normal#'  -- Empty statusline (no lualine)
  vim.wo[state.left_win].fillchars = 'eob: '  -- Hide ~ characters
  -- Blend into background by hiding visual elements
  vim.wo[state.left_win].winhl = 'Normal:Normal,EndOfBuffer:Normal'

  -- Create right side buffer
  state.right_buf = create_side_buffer()
  vim.api.nvim_set_current_win(state.center_win)
  vim.cmd('botright vsplit')
  state.right_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.right_win, state.right_buf)
  vim.api.nvim_win_set_width(state.right_win, side_width)

  -- Disable various UI elements for side buffers
  vim.wo[state.right_win].number = false
  vim.wo[state.right_win].relativenumber = false
  vim.wo[state.right_win].signcolumn = 'no'
  vim.wo[state.right_win].foldcolumn = '0'
  vim.wo[state.right_win].cursorline = false
  vim.wo[state.right_win].statusline = '%#Normal#'  -- Empty statusline (no lualine)
  vim.wo[state.right_win].fillchars = 'eob: '  -- Hide ~ characters
  -- Blend into background by hiding visual elements
  vim.wo[state.right_win].winhl = 'Normal:Normal,EndOfBuffer:Normal'

  -- Return focus to center window
  vim.api.nvim_set_current_win(state.center_win)

  -- Save state for this tab
  set_tab_state(state)
end

-- Toggle center mode
function M.toggle()
  if is_centered() then
    M.exit()
  else
    M.enter()
  end
end

-- Create global autocommands for center mode management
vim.api.nvim_create_augroup('CenterMode', { clear = true })

-- Handle window enter/new events
vim.api.nvim_create_autocmd({ 'WinNew', 'WinEnter' }, {
  group = 'CenterMode',
  callback = function()
    local state = get_tab_state()
    if not state then
      return
    end

    local current_win = vim.api.nvim_get_current_win()

    -- Redirect if user tries to enter a side buffer
    if current_win == state.left_win or current_win == state.right_win then
      vim.schedule(function()
        if state.center_win and vim.api.nvim_win_is_valid(state.center_win) then
          vim.api.nvim_set_current_win(state.center_win)
        end
      end)
      return
    end

    -- Check if a new window was created that isn't one of our side buffers
    -- Ignore floating windows and quickfix
    -- Only check windows in the current tab
    local wins = vim.api.nvim_tabpage_list_wins(0)
    for _, win in ipairs(wins) do
      if win ~= state.left_win and win ~= state.right_win and win ~= state.center_win then
        -- Check if this is a floating window or quickfix
        local win_config = vim.api.nvim_win_get_config(win)
        local buf = vim.api.nvim_win_get_buf(win)
        local buftype = vim.bo[buf].buftype

        if win_config.relative == '' and buftype ~= 'quickfix' then
          -- Not a floating window or quickfix, so it's a real split - exit center mode
          vim.schedule(function()
            M.exit()
          end)
          return
        end
      end
    end
  end
})

-- Handle window closed events
vim.api.nvim_create_autocmd('WinClosed', {
  group = 'CenterMode',
  callback = function(args)
    local state = get_tab_state()
    if not state then
      return
    end

    local closed_win = tonumber(args.match)
    if closed_win == state.center_win then
      vim.schedule(function()
        M.exit()
      end)
    end
  end
})

-- Handle window resizing to maintain proper centering
vim.api.nvim_create_autocmd('WinResized', {
  group = 'CenterMode',
  callback = function()
    local state = get_tab_state()
    if not state then
      return
    end

    -- Recalculate side buffer widths to maintain centering
    local side_width = math.floor(vim.o.columns * 0.2)

    if state.left_win and vim.api.nvim_win_is_valid(state.left_win) then
      vim.api.nvim_win_set_width(state.left_win, side_width)
    end

    if state.right_win and vim.api.nvim_win_is_valid(state.right_win) then
      vim.api.nvim_win_set_width(state.right_win, side_width)
    end
  end
})

-- Create cmd
vim.api.nvim_create_user_command('Center', function()
  M.toggle()
end, { desc = 'Toggle centered buffer mode' })

-- Create keymap
vim.keymap.set("n", "<leader>c", M.toggle, { noremap = true })

return M
