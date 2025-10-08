local M = {}

local config = {
  log_level = vim.log.levels.INFO,
}

function M.setup(opts)
  config = vim.tbl_extend("force", config, opts or {})
end

local function notify(msg, level)
  if level >= config.log_level then
    vim.notify(msg, level)
  end
end

local function get_csharp_method()
  local ts = vim.treesitter
  local bufnr = vim.api.nvim_get_current_buf()
  local parser = ts.get_parser(bufnr, "c_sharp")
  if not parser then
    notify("No C# parser installed", vim.log.levels.ERROR)
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

  if not found then
    notify("Cursor is not inside a method.", vim.log.levels.WARN)
    return
  end

  -- Use a query to get the method name identifier
  local query = ts.query.parse("c_sharp", [[
    (method_declaration
      name: (identifier) @method_name)
  ]])
  for id, node in query:iter_captures(found, bufnr, 0, -1) do
    if query.captures[id] == "method_name" then
      local name = ts.get_node_text(node, bufnr)
      return name
    end
  end
  notify("Method found, but could not get name.", vim.log.levels.ERROR)
end

function M.run_test(test_name)
  local test = test_name and test_name ~= "" or get_csharp_method()

  if not test or test == "" then
    notify("No test name provided.", vim.log.levels.ERROR)
    return
  end

  local build_cmd = "dotnet build --verbosity quiet"
  local test_cmd = "dotnet test --no-build --verbosity minimal --filter FullyQualifiedName~" .. test
  vim.cmd("AsyncRun  " .. build_cmd .. " && " .. test_cmd)
  vim.cmd("botright copen")
end

return M
