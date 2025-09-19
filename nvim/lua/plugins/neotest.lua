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
    local neotest = require("neotest")
    neotest.setup({
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
        open = "topleft vsplit | vertical resize 50"
      },
    })

    local keymap = vim.keymap.set
    keymap("n", "<leader>ts", function() neotest.summary.toggle() end, { desc = "Test summary" })
    keymap("n", "<leader>tt", function() neotest.run.run() end, { desc = "Run nearest test" })
    keymap("n", "<leader>tf", function() neotest.run.run(vim.fn.expand("%")) end, { desc = "Run tests in file" })
  end,
}

