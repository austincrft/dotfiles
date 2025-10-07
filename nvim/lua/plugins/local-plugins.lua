return {
  dir = vim.fn.stdpath("config") .. "/lua/dotnet-secrets",
  name = "dotnet-secrets",
  config = function()
    local secrets = require("dotnet-secrets")

    vim.api.nvim_create_user_command("OpenSecrets", function(opts)
      secrets.open(opts.args)
    end, { nargs = "?", desc = "Open .NET user secrets" })

    vim.keymap.set("n", "grs", ":OpenSecrets<CR>", { noremap = true, silent = true })
  end,
}
