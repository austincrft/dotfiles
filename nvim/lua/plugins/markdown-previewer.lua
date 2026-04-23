return {
  "OXY2DEV/markview.nvim",
  lazy = false,
  config = function()
    require("markview").setup({
      preview = {
        enable = false -- Disables automatic previews on buffer attachment
      }
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function(args)
        vim.keymap.set('n', '<leader>mp', function()
          vim.cmd([[Markview toggle]])
        end, { buffer = args.buf, desc = "Toggle markdown preview" })
      end,
    })
  end,
};
