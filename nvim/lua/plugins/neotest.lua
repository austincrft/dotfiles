return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nsidorenco/neotest-vstest",
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-vstest"),
      },
      icons = {
        failed = "X",
        passed = "✓",
        not_run = "…",
        skipped = "–",
        unknown = "?",
        notify = "A",
        watching = "W",
        warning = "w",
        running = "⟳",

      },
      summary = {
        mappings = {
          watch = "<Nop>"
        },
      },
    })
  end,
  keys = {
  },
}

