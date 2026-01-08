local function format_json()
  vim.cmd("%!jq .")
end

local filetype_formatters = {
  json = format_json,
  jsonc = format_json,
}

-- TODO: if text is selected, apply only to selection
vim.api.nvim_create_user_command("Format", function()
  local filetype = vim.bo.filetype
  local formatter = filetype_formatters[filetype]
  if formatter then
    formatter()
  else
    vim.notify("No formatter for filetype: " .. filetype, vim.log.levels.WARN)
  end
end, { desc = "Format current buffer by filetype" })
