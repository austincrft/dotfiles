return {
  {
    "seblyng/roslyn.nvim",
    ft = "cs",
    dependencies = { "neovim/nvim-lspconfig", "mason-org/mason.nvim" },
    config = function ()
      local roslyn = require("roslyn")
      roslyn.setup({
        filewatching = "roslyn",
        lock_target = true,
        broad_search = true,
      })

      vim.api.nvim_create_user_command("BuildSln", function(opts)
        local sln = vim.g.roslyn_nvim_selected_solution
        if not sln then
          vim.notify("No roslyn sln selected", vim.log.levels.ERROR)
          return
        end

        local args = opts.args or "--verbosity quiet"
        vim.cmd("AsyncRun dotnet build " .. args .. " \"" .. sln .. "\"")
        vim.cmd("botright copen")
      end, { nargs = "*" })

      vim.keymap.set("n", "<leader>bb", ":BuildSln<CR>", { noremap = true })
    end
  },
  {
    "austincrft/dotnet-secrets.nvim",
    config = function()
      vim.keymap.set("n", "grs", function()
        require("dotnet-secrets").open_secrets()
      end, { noremap = true, silent = true, desc = "Open .NET user secrets" })
    end,
  },
  {
    "austincrft/dotnet-test.nvim",
    dependencies = {
      "skywind3000/asyncrun.vim",
      "mfussenegger/nvim-dap",
      "seblyng/roslyn.nvim",
    },
    config = function()
      local dotnet_test = require("dotnet-test")

      -- This plugin does not require calling setup if you're using defaults.
      -- I find the `dotnet build` cmd verbose, so I set it to quiet
      dotnet_test.setup({
        build = {
          args = { "--verbosity", "quiet" },
        },
      })

      -- Creates buffer-scoped mappings for tests
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "cs",
        callback = function()
          vim.keymap.set("n", "<Leader>tt", function()
            dotnet_test.run_test()
          end, {
            noremap = true,
            silent = true,
            buffer = true,
            desc = "Run .NET test"
          })

          vim.keymap.set("n", "<Leader>td", function()
            dotnet_test.run_test({ debug = true })
          end, {
            noremap = true,
            silent = true,
            buffer = true,
            desc = "Debug .NET test"
          })

          vim.keymap.set("n", "<Leader>tf", function()
            dotnet_test.run_current_file()
          end, {
            noremap = true,
            silent = true,
            buffer = true,
            desc = "Debug .NET tests in file"
          })

          vim.keymap.set("n", "<Leader>ts", function()
            dotnet_test.run_target()
          end, {
            noremap = true,
            silent = true,
            buffer = true,
            desc = "Run .NET tests in sln or proj"
          })
        end,
      })
    end,
  },
}
