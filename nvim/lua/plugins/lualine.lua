return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function ()
      vim.api.nvim_create_autocmd("DiagnosticChanged", {
        callback = function(ev)
          if not vim.b[ev.buf].lsp_ready and next(vim.lsp.get_clients({ bufnr = ev.buf })) then
            vim.b[ev.buf].lsp_ready = true
          end
        end,
      })

      require('lualine').setup({
        options = {
          disabled_filetypes = {
            statusline = { 'center-padding' },
          },
        },
        sections = {
          lualine_z = {},
          lualine_x = {
            {
              function() return "󱐋" end,
              cond = function()
                local lsp_clients = vim.lsp.get_clients({ bufnr = 0 })
                return #lsp_clients ~= 0 and vim.b.lsp_ready == true
              end,
            },
            {
              function()
                local val = "󰘐"
                if vim.fn.winwidth(0) >= 145 then
                  val = val .. " " .. vim.fn.fnamemodify(vim.g.roslyn_nvim_selected_solution, ":t")
                end
                return val
              end,
              cond = function()
                return vim.g.roslyn_nvim_selected_solution ~= nil
              end,
            },
            "filetype",
          },
        },
      })
    end
}
