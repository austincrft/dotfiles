return {
  {
    "seblyng/roslyn.nvim",
    ft = "cs", -- load when opening C# files
    dependencies = { "neovim/nvim-lspconfig", "mason-org/mason.nvim" },
    config = function ()
      local roslyn = require("roslyn")
      local work = require("config.work")
      roslyn.setup(work.apply_plugin_override("roslyn", { filewatching = "roslyn" }))

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
}
