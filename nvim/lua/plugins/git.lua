return {
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
  {
    "esmuellert/codediff.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    config = function()
      require("codediff").setup({
        explorer = {
          view_mode = "tree",
        },
        keymaps = {
          conflict = {
            accept_incoming = "<leader>xt",  -- Accept incoming (theirs/left) change
            accept_current = "<leader>xo",   -- Accept current (ours/right) change
            accept_both = "<leader>xb",      -- Accept both changes (incoming first)
            discard = "<leader>xx",          -- Discard both, keep base
          },
        },
      })
      vim.keymap.set("n", "<leader>gd", "<Cmd>CodeDiff<CR>", { desc = "Toggle code diff" })
      vim.keymap.set("n", "<leader>gD", ":CodeDiff " , { desc = "Open code diff window for revision" })
      vim.keymap.set("n", "<leader>gl", "<Cmd>CodeDiff history<CR>" , { desc = "Open code diff log" })
      vim.keymap.set("n", "<leader>gf", "<Cmd>CodeDiff history %<CR>" , { desc = "Open code diff file history" })
    end,
  }
}
