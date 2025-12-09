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
