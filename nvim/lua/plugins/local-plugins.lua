return {
  {
    dir = vim.fn.stdpath("config") .. "/lua/dotnet-secrets",
    name = "dotnet-secrets",
    config = function()
      local secrets = require("dotnet-secrets")

      vim.api.nvim_create_user_command("DotnetSecrets", function(opts)
        secrets.open(opts.args)
      end, { nargs = "?", desc = "Open .NET user secrets" })

      vim.keymap.set("n", "grs", ":DotnetSecrets<CR>", { noremap = true, silent = true })
    end,
  },
  {
    dir = vim.fn.stdpath("config") .. "/lua/dotnet-test",
    name = "dotnet-test",
    ft = { "cs" }, -- Enable only for C# files
    config = function()
      local dotnet_test = require("dotnet-test")
      dotnet_test.setup({ log_level = vim.log.levels.DEBUG })

      vim.keymap.set("n", "<Leader>rt", ":DotnetTestRun<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<Leader>dt", ":DotnetTestDebug<CR>", { noremap = true, silent = true })
    end,
  }
}
