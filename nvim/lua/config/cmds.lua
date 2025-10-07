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

vim.api.nvim_create_user_command("CSharpCurrentMethod", function()
  local ts = vim.treesitter
  local bufnr = vim.api.nvim_get_current_buf()
  local parser = ts.get_parser(bufnr, "c_sharp")
  if not parser then
    print("No C# parser installed")
    return
  end

  local tree = parser:parse()[1]
  local root = tree:root()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]

  local found = nil
  local function node_contains_cursor(node)
    local start_row, start_col, end_row, end_col = node:range()
    if row < start_row or row > end_row then return false end
    if row == start_row and col < start_col then return false end
    if row == end_row and col > end_col then return false end
    return true
  end

  -- Find the innermost method_declaration node containing the cursor
  local function find_method(node)
    if node:type() == "method_declaration" and node_contains_cursor(node) then
      found = node
      for child in node:iter_children() do
        find_method(child)
      end
    else
      for child in node:iter_children() do
        find_method(child)
      end
    end
  end

  find_method(root)

  if found then
    -- Use a query to get the method name identifier
    local query = ts.query.parse("c_sharp", [[
      (method_declaration
        name: (identifier) @method_name)
    ]])
    for id, node in query:iter_captures(found, bufnr, 0, -1) do
      if query.captures[id] == "method_name" then
        local name = ts.get_node_text(node, bufnr)
        print("Current method: " .. name)
        return
      end
    end
    print("Method found, but could not get name.")
  else
    print("Cursor is not inside a method.")
  end
end, { desc = "Show the C# method at the cursor" })
