local M = {}

-- Track center mode state
M.is_centered = false
M.left_buf = nil
M.right_buf = nil
M.left_win = nil
M.right_win = nil
M.center_win = nil
M.augroup = nil

-- Auto-center configuration
M.auto_width_col_threshold = 160

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

-- Exit center mode
function M.exit()
  if not M.is_centered then
    return
  end

  -- Delete autocommand group
  if M.augroup then
    vim.api.nvim_del_augroup_by_id(M.augroup)
    M.augroup = nil
  end

  -- Close side windows
  if M.left_win and vim.api.nvim_win_is_valid(M.left_win) then
    vim.api.nvim_win_close(M.left_win, true)
  end
  if M.right_win and vim.api.nvim_win_is_valid(M.right_win) then
    vim.api.nvim_win_close(M.right_win, true)
  end

  -- Focus the center window if it's still valid
  if M.center_win and vim.api.nvim_win_is_valid(M.center_win) then
    vim.api.nvim_set_current_win(M.center_win)
  end

  -- Reset state
  M.is_centered = false
  M.left_buf = nil
  M.right_buf = nil
  M.left_win = nil
  M.right_win = nil
  M.center_win = nil
end

-- Enter center mode
function M.enter()
  if M.is_centered then
    return
  end

  -- Get the current window (this will be the center)
  M.center_win = vim.api.nvim_get_current_win()

  -- Calculate side buffer width (20% of screen on each side)
  local side_width = math.floor(vim.o.columns * 0.2)

  -- Create left side buffer
  M.left_buf = create_side_buffer()
  vim.cmd('topleft vsplit')
  M.left_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(M.left_win, M.left_buf)
  vim.api.nvim_win_set_width(M.left_win, side_width)

  -- Disable various UI elements for side buffers
  vim.wo[M.left_win].number = false
  vim.wo[M.left_win].relativenumber = false
  vim.wo[M.left_win].signcolumn = 'no'
  vim.wo[M.left_win].foldcolumn = '0'
  vim.wo[M.left_win].cursorline = false
  vim.wo[M.left_win].statusline = '%#Normal#'  -- Empty statusline (no lualine)
  vim.wo[M.left_win].fillchars = 'eob: '  -- Hide ~ characters
  -- Blend into background by hiding visual elements
  vim.wo[M.left_win].winhl = 'Normal:Normal,EndOfBuffer:Normal'

  -- Create right side buffer
  M.right_buf = create_side_buffer()
  vim.api.nvim_set_current_win(M.center_win)
  vim.cmd('botright vsplit')
  M.right_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(M.right_win, M.right_buf)
  vim.api.nvim_win_set_width(M.right_win, side_width)

  -- Disable various UI elements for side buffers
  vim.wo[M.right_win].number = false
  vim.wo[M.right_win].relativenumber = false
  vim.wo[M.right_win].signcolumn = 'no'
  vim.wo[M.right_win].foldcolumn = '0'
  vim.wo[M.right_win].cursorline = false
  vim.wo[M.right_win].statusline = '%#Normal#'  -- Empty statusline (no lualine)
  vim.wo[M.right_win].fillchars = 'eob: '  -- Hide ~ characters
  -- Blend into background by hiding visual elements
  vim.wo[M.right_win].winhl = 'Normal:Normal,EndOfBuffer:Normal'

  -- Return focus to center window
  vim.api.nvim_set_current_win(M.center_win)

  M.is_centered = true

  -- Create autocommand to detect splits
  M.augroup = vim.api.nvim_create_augroup('CenterMode', { clear = true })

  vim.api.nvim_create_autocmd({ 'WinNew', 'WinEnter' }, {
    group = M.augroup,
    callback = function()
      local current_win = vim.api.nvim_get_current_win()

      -- Redirect if user tries to enter a side buffer
      if current_win == M.left_win or current_win == M.right_win then
        vim.schedule(function()
          if M.center_win and vim.api.nvim_win_is_valid(M.center_win) then
            vim.api.nvim_set_current_win(M.center_win)
          end
        end)
        return
      end

      -- Check if a new window was created that isn't one of our side buffers
      -- Ignore floating windows (like terminal toggle, telescope, etc.)
      local wins = vim.api.nvim_tabpage_list_wins(0)
      for _, win in ipairs(wins) do
        if win ~= M.left_win and win ~= M.right_win and win ~= M.center_win then
          -- Check if this is a floating window
          local win_config = vim.api.nvim_win_get_config(win)
          if win_config.relative == '' then
            -- Not a floating window, so it's a real split - exit center mode
            vim.schedule(function()
              M.exit()
            end)
            return
          end
        end
      end
    end
  })

  -- Also exit if the center window is closed
  vim.api.nvim_create_autocmd('WinClosed', {
    group = M.augroup,
    callback = function(args)
      local closed_win = tonumber(args.match)
      if closed_win == M.center_win then
        vim.schedule(function()
          M.exit()
        end)
      end
    end
  })
end

-- Toggle center mode
function M.toggle()
  if M.is_centered then
    M.exit()
  else
    M.enter()
  end
end

-- Auto-center check for ultrawide monitors
local function auto_center_check()
  -- Count non-floating windows
  local non_floating_wins = 0
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local win_config = vim.api.nvim_win_get_config(win)
    if win_config.relative == '' then
      non_floating_wins = non_floating_wins + 1
    end
  end

  -- Only auto-center if:
  -- 1. Not already centered
  -- 2. Screen is wide enough
  -- 3. Only one non-floating window exists (no splits)
  if not M.is_centered
    and vim.o.columns >= M.auto_width_col_threshold
    and non_floating_wins == 1
  then
    M.enter()
  end
end

-- Set up auto-centering on file open
vim.api.nvim_create_augroup('CenterModeAutoEnable', { clear = true })
vim.api.nvim_create_autocmd('BufWinEnter', {
  group = 'CenterModeAutoEnable',
  callback = function()
    vim.schedule(auto_center_check)
  end
})

-- Create cmd
vim.api.nvim_create_user_command('Center', function()
  M.toggle()
end, { desc = 'Toggle centered buffer mode' })

-- Create keymap
vim.keymap.set("n", "<leader>c", M.toggle, { noremap = true })

return M
