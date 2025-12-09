return {
  {
    "sindrets/diffview.nvim",
    config = function()
      vim.keymap.set("n", "<leader>gd", function()
        if next(require("diffview.lib").views) == nil then
          vim.cmd("DiffviewOpen")
        else
          vim.cmd("DiffviewClose")
        end
      end, { desc = "Toggle Diffview window" })

      vim.keymap.set("n", "<leader>gD", ":DiffviewOpen " , { desc = "Open Diffview window for revision" })
      vim.keymap.set("n", "<leader>gl", "<Cmd>DiffviewFileHistory<CR>" , { desc = "Open Diffview log" })
      vim.keymap.set("n", "<leader>gf", "<Cmd>DiffviewFileHistory %<CR>" , { desc = "Open Diffview file history" })
    end
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, {expr=true, desc="Next Git hunk"})

          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, {expr=true, desc="Previous Git hunk"})
        end,
      })
    end,
  },
  -- {
  --   "esmuellert/vscode-diff.nvim",
  --   dependencies = { "MunifTanjim/nui.nvim" },
  -- },
}
