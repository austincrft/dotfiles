return {
  { "lewis6991/gitsigns.nvim" },
  {
    "tpope/vim-fugitive",
  },
  {
    "jecaro/fugitive-difftool.nvim",
    dependencies = { "tpope/vim-fugitive" },
    config = function()
      vim.api.nvim_create_user_command("GitDiffBranch", function(opts)
        vim.cmd("Git! difftool " .. opts.args)
      end, { nargs = 1 })
    end
  },
}
