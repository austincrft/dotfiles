vim.api.nvim_create_user_command("DiagOpenFloat", function()
  vim.diagnostic.open_float(nil, { focusable = true, border = 'rounded' })
end, { desc = "Open diagnostic float" })

vim.api.nvim_create_user_command("DiagSetQuickFix", function()
  vim.diagnostic.setqflist({ open = false, severity = { min = vim.diagnostic.severity.WARN } })
  vim.cmd("botright copen")
end, {})

vim.api.nvim_create_user_command("G", function(opts)
  local cmd = "git " .. opts.args
  local output = {}

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(output, line)
          end
        end
      end
    end,
    on_stderr = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(output, line)
          end
        end
      end
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        if #output > 0 then
          local level = code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
          vim.notify(table.concat(output, "\n"), level)
        elseif code ~= 0 then
          vim.notify("git command failed with exit code " .. code, vim.log.levels.ERROR)
        end
      end)
    end,
  })
end, {
  nargs = "*",
  desc = "Async git command pass-through",
})

vim.api.nvim_create_user_command("DeleteInactiveBuffers", function()
  -- Collect all visible buffers in all windows of all tabpages
  local visible = {}
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      visible[vim.api.nvim_win_get_buf(win)] = true
    end
  end

  -- Delete all listed buffers that are not visible, except terminals
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf)
      and vim.api.nvim_buf_get_option(buf, "buflisted")
      and not visible[buf]
      and vim.bo[buf].buftype ~= "terminal"
    then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
end, {})
