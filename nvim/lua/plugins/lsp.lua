return {
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v3.x",
    dependencies = {
      { "neovim/nvim-lspconfig" },
      { "mason-org/mason.nvim" },
      { "mason-org/mason-lspconfig.nvim" },
      { "hrsh7th/nvim-cmp" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "L3MON4D3/LuaSnip" },
    },
    config = function()
      local lsp = require("lsp-zero").preset("recommended")

      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup({
        mapping = {
          ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
          }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),

          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
      })

      lsp.configure("lua_ls", {
        settings = {
          Lua = {
            workspace = {
              library = { vim.env.VIMRUNTIME },
            },
          },
        },
      })

      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls" },
        handlers = {
          lsp.default_setup,
        },
      })

      lsp.on_attach(function(_, bufnr)
        local opts = { buffer = bufnr, remap = false }
        local keymap = vim.keymap.set

        keymap("n", "gd", vim.lsp.buf.definition, opts)
        keymap("n", "K", vim.lsp.buf.hover, opts)
        keymap("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
        keymap("n", "<leader>vd", vim.diagnostic.open_float, opts)
        keymap("n", "]d", function() vim.diagnostic.jump({ count=1, float=true}) end, opts)
        keymap("n", "[d", function() vim.diagnostic.jump({ count=-1, float=true}) end, opts)
        keymap("n", "<leader>vca", vim.lsp.buf.code_action, opts)
        keymap("n", "<leader>vrr", vim.lsp.buf.references, opts)
        keymap("n", "<leader>vrn", vim.lsp.buf.rename, opts)
        keymap("i", "<C-h>", vim.lsp.buf.signature_help, opts)
      end)

      lsp.setup()
    end,
  },
}
