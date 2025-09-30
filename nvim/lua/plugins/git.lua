return {
  { "lewis6991/gitsigns.nvim" },
  {
    "tpope/vim-fugitive",
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
