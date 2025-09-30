-- DiagOpenFloat
vim.api.nvim_create_user_command("DiagOpenFloat", function()
  vim.diagnostic.open_float(nil, { focusable = false, border = 'rounded' })
end, { desc = "Open diagnostic float" })

-- TerminalTab
vim.api.nvim_create_user_command("TerminalTab", function()
  -- Check if the first tab already has a terminal buffer
  local tab = vim.api.nvim_list_tabpages()[1]
  local has_terminal = false
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" then
      has_terminal = true
      break
    end
  end

  if has_terminal then
    vim.api.nvim_set_current_tabpage(tab)
    vim.cmd("startinsert")
  else
    vim.cmd("tabnew")
    vim.cmd("tabmove 0")
    vim.cmd("terminal pwsh")
    vim.cmd("startinsert")
  end
end, { desc = "Open or switch to terminal tab" })

-- OpenSecrets
vim.api.nvim_create_user_command("OpenSecrets", function(opts)
  -- Get the secrets id from args or open csproj
  local secrets_id = opts.args
  if secrets_id == "" and vim.api.nvim_buf_get_name(0):match("%.csproj$") then
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local content = table.concat(lines, "\n")

    secrets_id = content:match("<UserSecretsId>([%w%-]+)</UserSecretsId>")
    if not secrets_id then
      vim.notify("Could not find <UserSecretsId> in csproj", vim.log.levels.ERROR)
      return
    end
  end

  if not secrets_id or secrets_id == "" then
    vim.notify("Provide secrets ID directly or run from a csproj", vim.log.levels.ERROR)
    return
  end

  local secrets_path = vim.fn.has("win32") == 1
    and vim.env.APPDATA .. "/Microsoft/UserSecrets/" .. secrets_id .. "/secrets.json"
    or "~/.microsoft/usersecrets/" .. secrets_id .. "/secrets.json"

  vim.cmd("edit " .. secrets_path)
end, { nargs = "?", desc = "Open .NET user secrets" })

