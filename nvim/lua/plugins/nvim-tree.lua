return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function ()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    require("nvim-tree").setup()

    local keymap = vim.keymap.set
    keymap("n", "<leader>;", ":NvimTreeToggle<CR>", { noremap = true, silent = true } )
    keymap("n", "-", ":NvimTreeFindFile<CR>", { noremap = true, silent = true } )
  end
}
