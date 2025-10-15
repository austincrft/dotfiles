return {
  { "tpope/vim-fugitive" },
  { "lewis6991/gitsigns.nvim" },
  {
    "sindrets/diffview.nvim",
    config = function ()
      vim.keymap.set("n", "<leader>gg", ":DiffviewOpen<CR>", { noremap = true })
      vim.keymap.set("n", "<leader>gd", ":DiffviewOpen ", { noremap = true })
      vim.keymap.set("n", "<leader>gC", ":DiffviewClose<CR>", { noremap = true })
    end
  },
}
