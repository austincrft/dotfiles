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

    require("codecompanion").setup({
      -- opts = {
      --   log_level = "TRACE",
      -- },
      strategies = {
        chat = { adapter = "copilot" },
        inline = { adapter = "copilot" },
        agent = { adapter = "copilot" },
      },
    })

    vim.keymap.set("n", "<leader>ai", ":CodeCompanionChat<CR>", { noremap = true })
  end
}
