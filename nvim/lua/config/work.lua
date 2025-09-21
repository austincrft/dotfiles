local M = {}

function M.setup()
  local work_dir = vim.loop.os_homedir() .. "/work/nvim"

  pcall(dofile, work_dir .. "/config.lua")

  local ok, overrides = pcall(dofile, work_dir .. "/plugin_overrides.lua")
  if ok then
    M.plugin_overrides = overrides
  else
    M.plugin_overrides = {}
  end

  function M.apply_plugin_override(plugin_name, opts)
    local override = M.plugin_overrides[plugin_name]
    if override then
      return vim.tbl_deep_extend("force", opts, override)
    end
    return opts
  end
end


return M
