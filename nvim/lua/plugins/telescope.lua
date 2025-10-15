return {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    "nvim-telescope/telescope-ui-select.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local builtin = require("telescope.builtin")

    telescope.setup({
      defaults = {
        file_ignore_patterns = {
          "%.git[/\\]",
          "node_modules[/\\]",
        },
      }
    })

    telescope.load_extension("ui-select")

    -- Key mappings
    local keymap = vim.keymap.set
    keymap("n", "<leader>ff", ":Telescope find_files<cr>", { desc = "Find files" })
    keymap("n", "<leader>fg", ":Telescope live_grep<cr>", { desc = "Live grep" })
    keymap("n", "<leader>fG", function ()
      local filetype = vim.fn.input("File filter: ")
      vim.schedule(function()
        require('telescope.builtin').live_grep({
          glob_pattern = filetype,
        })
            end)
    end, { desc = "Live grep with file filter" })
    keymap("n", "<leader>fb", ":Telescope buffers<cr>", { desc = "Find buffers" })
    keymap("n", "<leader>fh", ":Telescope help_tags<cr>", { desc = "Help tags" })
    keymap("n", "<leader>fd", function() builtin.lsp_document_symbols() end, { desc = "LSP document symbols" })
  end
}

