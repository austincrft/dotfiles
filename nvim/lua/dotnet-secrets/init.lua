local M = {}

function M.open(secrets_id)
  if secrets_id == "" and vim.api.nvim_buf_get_name(0):match("%.csproj$") then
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local content = table.concat(lines, "\n")

    secrets_id = content:match("<UserSecretsId>([%w%-%.]+)</UserSecretsId>")
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
end

return M
