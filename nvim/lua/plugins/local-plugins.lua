return {
  {
    dir = vim.fn.stdpath("config") .. "/lua/dotnet-secrets",
    name = "dotnet-secrets",
    config = function()
      local secrets = require("dotnet-secrets")

      vim.api.nvim_create_user_command("OpenSecrets", function(opts)
        secrets.open(opts.args)
      end, { nargs = "?", desc = "Open .NET user secrets" })

      vim.keymap.set("n", "grs", ":OpenSecrets<CR>", { noremap = true, silent = true })
    end,
  },
  {
    dir = vim.fn.stdpath("config") .. "/lua/dotnet-test",
    name = "dotnet-test",
    ft = { "cs" }, -- Enable only for C# files
    config = function()
      local dotnet_test = require("dotnet-test")
      dotnet_test.setup({ log_level = vim.log.levels.DEBUG })

      vim.api.nvim_create_user_command("RunTest", function(opts)
        dotnet_test.run_test(opts.args)
      end, { nargs = "?", desc = "Run .NET test" })

      vim.keymap.set("n", "<Leader>rt", ":RunTest<CR>", { noremap = true, silent = true })
    end,
  }
}
