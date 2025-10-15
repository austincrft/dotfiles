local M = {}

local config = {
  log_level = vim.log.levels.INFO,
  create_cmds = true,
  use_roslyn_sln = false,
  find_target_max_iter = 10,
}

function M.setup(opts)
  config = vim.tbl_extend("force", config, opts or {})

  if config.create_cmds then
      vim.api.nvim_create_user_command("DotnetTestRun", function(opts)
        M.run_test(opts.args)
      end, { nargs = "?", desc = "Run a .NET test" })

      vim.api.nvim_create_user_command("DotnetTestDebug", function(opts)
        M.run_test(opts.args, true)
      end, { nargs = "?", desc = "Debug a .NET test" })
  end
end

local function notify(msg, level)
  if level >= config.log_level then
    vim.schedule(function()
      vim.notify("[dotnet-test] " .. msg, level)
    end)
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

local run_term_cmd = function (cmd)
  vim.cmd("AsyncRun " .. cmd)
  vim.cmd("botright copen")
end

function M.run_test(test_name, debug)
  local test = test_name and test_name ~= "" or get_csharp_method()

  if not test or test == "" then
    return
  end

  local target = find_dotnet_target()
  if not target then
    notify("No .sln or .csproj found.", vim.log.levels.ERROR)
    return
  end

  local build_cmd = "dotnet build \"" .. target .. "\" --verbosity quiet"

  if debug then

    run_term_cmd(build_cmd)

    vim.api.nvim_create_autocmd("User", {
      pattern = "AsyncRunStop",
      once = true,
      callback = function()
        if vim.g.asyncrun_status ~= "success" then
          notify("Build failed, not running test.", vim.log.levels.ERROR)
        else
          -- Close quickfix
          vim.cmd("cclose")

          -- Proceed with debug logic
          local dap = require('dap')
          local handle
          local stdout = vim.uv.new_pipe(false)
          notify("Starting dotnet test", vim.log.levels.DEBUG)
          handle = vim.uv.spawn('dotnet', {
            args = {
              "test", target,
              "--no-build",
              "--filter", "FullyQualifiedName~" .. test,
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
      end,
    })

    return
  end

  local test_cmd = "dotnet test \"" .. target .. "\" --no-build --verbosity minimal --filter FullyQualifiedName~" .. test
  run_term_cmd(table.concat({ build_cmd, test_cmd }, " && "))
end

return M
