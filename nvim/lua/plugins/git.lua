return {
  { "lewis6991/gitsigns.nvim" },
  {
    "tpope/vim-fugitive",
    config = function ()
      vim.keymap.set("n", "<leader>gC", ":Git commit -m \"", { noremap = true, silent = true })
    end
  },
  {
    "jecaro/fugitive-difftool.nvim",
    dependencies = { "tpope/vim-fugitive" },
    config = function()
      vim.api.nvim_create_user_command("GitDiffBranch", function()
        vim.cmd("Git! difftool ")
      end, {})
    end
  },
}
