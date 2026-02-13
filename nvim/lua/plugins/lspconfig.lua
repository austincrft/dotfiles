local function set_lsp_autocmds()
  -- Detach LSP from codediff:// virtual buffers without sending didClose.
  -- Some LSPs (like roslyn) fail for codediff:// documents (rejects didOpen for unknown URI
  -- schemes), so a didClose notification crashes the server.
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local bufname = vim.api.nvim_buf_get_name(args.buf)
      if not bufname:match("^codediff://") then
        return
      end

      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then
        return
      end

      -- Temporarily suppress didClose so LSPs don't crash on the
      -- untracked codediff:// URI, then detach the client from the buffer.
      local orig_notify = client.notify
      client.notify = function(method, params)
        ---@diagnostic disable: undefined-field
        if method == "textDocument/didClose"
          and params and params.textDocument
          and params.textDocument.uri
          and params.textDocument.uri:match("^codediff://") then
          return true
        end
        ---@diagnostic enable: undefined-field

        return orig_notify(method, params)
      end

      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(args.buf) then
          pcall(vim.lsp.buf_detach_client, args.buf, args.data.client_id)
        end
        client.notify = orig_notify
      end)
    end,
    desc = "Detach LSP from codediff virtual buffers",
  })
end

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
    set_lsp_autocmds()
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
