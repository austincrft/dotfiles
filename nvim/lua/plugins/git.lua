return {
  { "tpope/vim-fugitive" },
  { "lewis6991/gitsigns.nvim" },
  {
    "sindrets/diffview.nvim",
    config = function ()
      vim.keymap.set("n", "<leader>dv", ":DiffviewOpen ", { noremap = true })
    end
  },
}
