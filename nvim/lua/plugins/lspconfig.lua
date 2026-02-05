local function suppress_diagnostics()
  local suppressed_diagnostics = {
    -- Roslyn
    ["IDE0001"] = true, -- Name can be simplified
    ["IDE0003"] = true, -- Remove this or Me qualification
    ["IDE0028"] = true, -- Collection initialization can be simplified
    ["IDE0290"] = true, -- Use primary constructor
    ["IDE0300"] = true, -- Collection initialization can be simplified
    ["IDE0305"] = true, -- Collection initialization can be simplified
  }

  local original_set = vim.diagnostic.set

  ---@diagnostic disable-next-line: duplicate-set-field
  vim.diagnostic.set = function(ns, bufnr, diagnostics, opts)
    diagnostics = vim.tbl_filter(function(d)
      return not suppressed_diagnostics[tostring(d.code)]
    end, diagnostics)
    original_set(ns, bufnr, diagnostics, opts)
  end
end

return {
  "neovim/nvim-lspconfig",
  config = function()

    suppress_diagnostics()

    vim.lsp.config('lua_ls', {
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = {
              vim.env.VIMRUNTIME .. "/lua",
              vim.fn.expand("$VIMRUNTIME/lua"),
              vim.fn.stdpath("config") .. "/lua",
            },
            checkThirdParty = false,
          },
          telemetry = {
            enable = false,
          },
        },
      },
    })
  end,
}
