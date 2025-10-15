return {
  { "tpope/vim-fugitive" },
  { "lewis6991/gitsigns.nvim" },
  {
    "sindrets/diffview.nvim",
    config = function ()
      vim.keymap.set("n", "<leader>GG", ":DiffviewOpen<CR>", { noremap = true })
      vim.keymap.set("n", "<leader>GD", ":DiffviewOpen ", { noremap = true })
      vim.keymap.set("n", "<leader>GC", ":DiffviewClose<CR>", { noremap = true })
    end
  },
}
