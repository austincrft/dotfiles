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

    local function live_grep_filetype(starting_text)
      local filetype = vim.fn.input("File filter: ")
      if not filetype or filetype == "" then
        return
      end

      vim.schedule(function()
        builtin.live_grep({
          glob_pattern = filetype,
          default_text = starting_text
        })
      end)
    end

    vim.keymap.set("n", "<leader>ff", ":Telescope find_files<cr>", { desc = "Find files" })
    vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<cr>", { desc = "Live grep" })
    vim.keymap.set("v", "<leader>fg", '"zy:Telescope live_grep<cr><C-R>z', { desc = "Live grep" })
    vim.keymap.set("n", "<leader>fG", live_grep_filetype, { desc = "Live grep with file filter" })
    vim.keymap.set("v", "<leader>fG", function()
      vim.cmd('normal! "zy')
      local selection = vim.fn.getreg('z')
      live_grep_filetype(selection)
    end, { desc = "Live grep with file filter" })
   -- keymap("v", "<leader>ss", '"zy:%s/<C-R>z/', { noremap = true })
    vim.keymap.set("n", "<leader>fb", ":Telescope buffers<cr>", { desc = "Find buffers" })
    vim.keymap.set("n", "<leader>fh", ":Telescope help_tags<cr>", { desc = "Help tags" })
    vim.keymap.set("n", "<leader>fd", function() builtin.lsp_document_symbols() end, { desc = "LSP document symbols" })
  end
}

