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
    dependencies = "skywind3000/asyncrun.vim",
    ft = { "cs" }, -- Enable only for C# files
    config = function()
      local dotnet_test = require("dotnet-test")
      dotnet_test.setup({
        -- log_level = vim.log.levels.DEBUG,
        build = {
          args = { "--verbosity", "quiet" },
        },
      })

      vim.keymap.set("n", "<Leader>tt", function()
        dotnet_test.run_test()
      end, { noremap = true, silent = true })

      vim.keymap.set("n", "<Leader>td", function()
        dotnet_test.run_test({ debug = true })
      end, { noremap = true, silent = true })

      vim.keymap.set("n", "<Leader>tf", function()
        dotnet_test.run_current_file()
      end, { noremap = true, silent = true })

      vim.keymap.set("n", "<Leader>ts", function()
        dotnet_test.run_target()
      end, { noremap = true, silent = true })
    end,
  }
}
