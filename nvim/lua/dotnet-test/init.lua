local M = {}

local config = {
  log_level = vim.log.levels.WARN,
  use_roslyn_sln = false,
  find_target_max_iter = 10,
  build = {
    cmd_runner = nil,
    cmd_finished_autocmd = nil
  }
}

function M.setup(opts)
  config = vim.tbl_extend("force", config, opts or {})
end

local function notify(msg, level)
  if level >= config.log_level then
    vim.schedule(function()
      vim.notify("[dotnet-test] " .. msg, level)
    end)
  end
end

local function get_curr_csharp_method()
  local ts = vim.treesitter
  local bufnr = vim.api.nvim_get_current_buf()
  local parser = ts.get_parser(bufnr, "c_sharp")
  if not parser then
    notify("No treesitter parser for C# installed", vim.log.levels.ERROR)
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

  -- Get method name
  local query = ts.query.parse("c_sharp", [[
    (method_declaration
      name: (identifier) @method_name)
  ]])
  local method_name = nil
  for id, node in query:iter_captures(found, bufnr, 0, -1) do
    if query.captures[id] == "method_name" then
      method_name = ts.get_node_text(node, bufnr)
      break
    end
  end
  if not method_name then
    notify("Method found, but could not get name.", vim.log.levels.ERROR)
    return
  end

  -- Walk up to collect class/struct/record and namespace names
  local names = { method_name }
  local parent = found:parent()
  local namespace_found = false
  while parent do
    local t = parent:type()
    if t == "class_declaration" or t == "struct_declaration" or t == "record_declaration" then
      -- Get class/struct/record name
      for child in parent:iter_children() do
        if child:type() == "identifier" then
          table.insert(names, 1, ts.get_node_text(child, bufnr))
          break
        end
      end
    elseif t == "namespace_declaration" then
      -- Get namespace name (could be a qualified_name or identifier)
      for child in parent:iter_children() do
        if child:type() == "qualified_name" or child:type() == "identifier" then
          table.insert(names, 1, ts.get_node_text(child, bufnr))
          namespace_found = true
          break
        end
      end
    end
    parent = parent:parent()
  end

  if not namespace_found then
    local file_scoped_ns = nil
    for child in root:iter_children() do
      if child:type() == "file_scoped_namespace_declaration" then
        for ns_child in child:iter_children() do
          if ns_child:type() == "qualified_name" or ns_child:type() == "identifier" then
            file_scoped_ns = ts.get_node_text(ns_child, bufnr)
            break
          end
        end
        break
      end
    end

    if file_scoped_ns then
      table.insert(names, 1, file_scoped_ns)
    end
  end

  return table.concat(names, ".")
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
  local buf_dir = vim.fn.expand('%:p:h')

  -- Walk up from buf_dir
  local iter = 1
  local dir = buf_dir
  local cwd = vim.fn.getcwd()

  while iter ~= config.find_target_max_iter + 1 and dir and dir ~= "" and dir ~= "/" and dir ~= cwd do
    notify("Iter " .. tostring(iter) .. ": " .. dir, vim.log.levels.DEBUG)
    local targets = glob_any(dir, patterns)
    if not targets or #targets == 0 then
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

local function run_term_cmd(cmd)
  if config.build and config.build.cmd_runner then
    config.build.cmd_runner(cmd)
    return
  end

  vim.cmd("AsyncRun " .. cmd)
  vim.cmd("botright copen")
end

local function build_finished_autocmd(callback)
  if config.build and config.build.cmd_finished_autocmd then
    config.build.cmd_finished_autocmd(callback)
    return
  end

  vim.api.nvim_create_autocmd("User", {
    pattern = "AsyncRunStop",
    once = true,
    callback = function()
      if vim.g.asyncrun_status ~= "success" then
        notify("Build failed, not running test.", vim.log.levels.ERROR)
      else
        -- Close quickfix
        vim.cmd("cclose")

        callback()
      end
    end,
  })
end

function M.run_dotnet_test_cli(filter, debug)
  local target = find_dotnet_target()
  if not target then
    notify("No .sln or .csproj found.", vim.log.levels.ERROR)
    return
  end

  local build_cmd = "dotnet build \"" .. target .. "\" --verbosity quiet"

  if debug then
    -- Run build
    run_term_cmd(build_cmd)

    local function build_finished_callback()
      local dap = require('dap')
      local handle
      local stdout = vim.uv.new_pipe(false)
      notify("Starting dotnet test", vim.log.levels.DEBUG)
      handle = vim.uv.spawn('dotnet', {
        args = {
          "test", target,
          "--no-build",
          "--filter", '"' .. filter .. '"'
        },
        env = { 'VSTEST_HOST_DEBUG=1' },
        stdio = {nil, stdout, nil}
      }, function(code, signal)
        notify("Closing stdout and handle", vim.log.levels.DEBUG)
        stdout:close()
        handle:close()
      end)

      stdout:read_start(function(err, data)
        notify("Starting read. Error=" .. vim.inspect(err) .. ";Data=" .. vim.inspect(data), vim.log.levels.DEBUG)
        if data then
          local test_pid = data:match('Process Id: (%d+)')
          if test_pid then
            notify("Attaching to test host: " .. test_pid, vim.log.levels.DEBUG)
            vim.schedule(function()
              dap.run({
                type = 'coreclr',
                name = 'Attach to Test Host',
                request = 'attach',
                processId = tonumber(test_pid)
              })
            end)
          end
        end
      end)
    end

    -- Wait for build to finish
    build_finished_autocmd(build_finished_callback)

    return
  end

  local test_cmd = 'dotnet test "' .. target .. '" --no-build --verbosity minimal --filter "' .. filter .. '"'
  run_term_cmd(table.concat({ build_cmd, test_cmd }, " && "))
end

function M.run_test(opts)
  opts = opts or { test_name = nil, debug = false }
  local test = opts.test_name and opts.test_name ~= "" or get_curr_csharp_method()
  if not test or test == "" then
    return
  end

  local filter = "FullyQualifiedName~" .. test
  M.run_dotnet_test_cli(filter, opts.debug)
end

local function get_curr_file_toplevel_types()
  local ts = vim.treesitter
  local bufnr = vim.api.nvim_get_current_buf()
  local parser = ts.get_parser(bufnr, "c_sharp")
  if not parser then
    notify("No treesitter parser for C# installed", vim.log.levels.ERROR)
    return {}
  end

  local tree = parser:parse()[1]
  local root = tree:root()
  local types = {}

  -- Helper to get namespace name
  local function get_namespace()
    for child in root:iter_children() do
      if child:type() == "namespace_declaration" then
        for ns_child in child:iter_children() do
          if ns_child:type() == "qualified_name" or ns_child:type() == "identifier" then
            return ts.get_node_text(ns_child, bufnr)
          end
        end
      elseif child:type() == "file_scoped_namespace_declaration" then
        for ns_child in child:iter_children() do
          if ns_child:type() == "qualified_name" or ns_child:type() == "identifier" then
            return ts.get_node_text(ns_child, bufnr)
          end
        end
      end
    end
    return nil
  end

  local namespace = get_namespace()

  for child in root:iter_children() do
    local t = child:type()
    if t == "class_declaration" or t == "struct_declaration" or t == "record_declaration" then
      local type_name = nil
      for type_child in child:iter_children() do
        if type_child:type() == "identifier" then
          type_name = ts.get_node_text(type_child, bufnr)
          break
        end
      end
      if type_name then
        if namespace then
          table.insert(types, namespace .. "." .. type_name)
        else
          table.insert(types, type_name)
        end
      end
    end
  end

  return types
end

function M.run_current_file(opts)
  opts = opts or { debug = false }
  local type_names = get_curr_file_toplevel_types()
  if not type_names or #type_names == 0 then
    notify("No top-level types found in the current file", vim.log.levels.ERROR)
    return
  end

  notify("top-level types: " .. table.concat(type_names, ", "), vim.log.levels.DEBUG)

  local filters = {}
  for i, v in ipairs(type_names) do
    filters[i] = "FullyQualifiedName~" .. v
  end

  local filter = table.concat(filters, " | ")
  notify("filter: " .. filter, vim.log.levels.DEBUG)

  M.run_dotnet_test_cli(filter, opts.debug)
end

return M
