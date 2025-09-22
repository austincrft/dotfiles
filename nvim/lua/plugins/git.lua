return {
  { "lewis6991/gitsigns.nvim" },
  {
    "tpope/vim-fugitive",
    config = function ()
      vim.keymap.set("n", "<leader>gC", ":Git commit -m \"", { noremap = true, silent = true })
    end
  },
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function ()
      vim.keymap.set("n", "<leader>gd", ":DiffviewOpen<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>gD", ":DiffviewClose<CR>", { noremap = true, silent = true })
    end
  },
}
