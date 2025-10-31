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
        preview = {
          hide_on_startup = true
        },
        mappings = {
          i = {
            ["<C-p>"] = require('telescope.actions.layout').toggle_preview,
            ["<C-v>"] = function()
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-r>+", true, false, true), "n", true)
            end,
          }
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
    vim.keymap.set("n", "<leader>fb", ":Telescope buffers<cr>", { desc = "Find buffers" })
    vim.keymap.set("n", "<leader>fh", ":Telescope help_tags<cr>", { desc = "Help tags" })
    vim.keymap.set("n", "<leader>fd", function()
      local width = vim.o.columns
      local picker_width = math.floor(width * 0.8)
      -- Calculate dynamic widths based on screen size
      local symbol_type_width = math.max(12, math.min(20, math.floor(picker_width * 0.15)))
      local symbol_width = picker_width - symbol_type_width

      require("telescope.builtin").lsp_document_symbols({
        symbol_width = symbol_width,
        symbol_type_width = symbol_type_width
      })
    end, { desc = "LSP document symbols" })
  end
}

