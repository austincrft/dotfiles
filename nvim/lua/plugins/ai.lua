return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "github/copilot.vim",
  },
  config = function ()
    -- Disable copilot inline suggestions
    vim.g.copilot_enabled = 0

    local adapter = "copilot"

    require("codecompanion").setup({
      strategies = {
        chat = { adapter = adapter },
        inline = { adapter = adapter },
        agent = { adapter = adapter },
      },
    })

    vim.keymap.set("n", "<leader>ai", ":CodeCompanionChat<CR>", { noremap = true })
    vim.keymap.set("v", "<leader>ai", ":CodeCompanion<CR>", { noremap = true })
  end
}
