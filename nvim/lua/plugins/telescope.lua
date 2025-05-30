return {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        file_ignore_patterns = {
          "node_modules[/\\]",
          "%.git[/\\]",
        },
      }
    })

    -- Key mappings
    local keymap = vim.keymap.set
    keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
    keymap("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live Grep" })
    keymap("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find Buffers" })
    keymap("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help Tags" })
  end
}

