return {
  "duane9/nvim-rg",
  config = function ()
    vim.keymap.set("n", "<leader>gg", ":Rg ", { noremap = true })
    vim.keymap.set("v", "<leader>gg", '"zy:Rg <C-R>z', { noremap = true })
  end
}
