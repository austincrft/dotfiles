local M = {}

local config = {
  log_level = vim.log.levels.INFO,
  use_roslyn_sln = false,
}

function M.setup(opts)
  config = vim.tbl_extend("force", config, opts or {})
end

local function notify(msg, level)
  if level >= config.log_level then
    vim.notify("[dotnet-test] " .. msg, level)
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

local function glob_any(dir, patterns)
  for _, pat in ipairs(patterns) do
    local files = vim.fn.globpath(dir, pat, false, true)
    if #files > 0 then return files end
  end
  return {}
end

local function find_dotnet_target()
  if config.use_roslyn_sln and vim.g.roslyn_nvim_selected_solution then
    notify('Using roslyn selected sln: ' .. vim.g.roslyn_nvim_selected_solution, vim.log.levels.DEBUG)
    return vim.g.roslyn_nvim_selected_solution
  end

  local patterns = { "*.sln", "*.csproj" }
  local start_dir = vim.fn.expand('%:p:h')

  -- Walk up from buf_dir
  local iter, max_iter = 1, 10
  local dir, cwd = start_dir, vim.fn.getcwd()

  while iter ~= max_iter + 1 and dir and dir ~= "" and dir ~= "/" and dir ~= cwd do
    notify("Iteration " .. tostring(iter) .. ": " .. dir, vim.log.levels.DEBUG)
    local targets = glob_any(dir, patterns)
    if not #targets then
      notify("No targets found" .. dir, vim.log.levels.DEBUG)
    else
      if #targets == 1 then
        return targets[1]
      else
        -- TODO: Show picker
        local msg = "Multiple targets found at " .. dir .. ": " .. table.concat(targets, ", ")
        notify(msg, vim.log.levels.DEBUG)
        return
      end
    end
    local parent = vim.fn.fnamemodify(dir, ":h")
    if not parent or parent == dir then break end
    dir = parent
    iter = iter + 1
  end

  return nil
end

function M.run_test(test_name)
  local test = test_name and test_name ~= "" or get_csharp_method()

  if not test or test == "" then
    return
  end

  local target = find_dotnet_target()
  if not target then
    notify("No .sln or .csproj found.", vim.log.levels.ERROR)
    return
  end

  local cmds = {
    "dotnet build \"" .. target .. "\" --verbosity quiet",
    "dotnet test \"" .. target .. "\" --no-build --verbosity minimal --filter FullyQualifiedName~" .. test,
  }
  vim.cmd("AsyncRun " .. table.concat(cmds, "&& "))
  vim.cmd("botright copen")
end

return M
