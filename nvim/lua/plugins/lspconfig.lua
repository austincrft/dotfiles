local function suppress_diagnostics()
  local suppressed_diagnostics = {
    -- Roslyn
    ["IDE0001"] = true, -- Name can be simplified
    ["IDE0003"] = true, -- Remove this or Me qualification
    ["IDE0028"] = true, -- Collection initialization can be simplified
    ["IDE0270"] = true, -- Null check can be simplified
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

local function set_lsp_autocmds()
  -- Roslyn crashes on unpaired didOpen/didClose for codediff:// URIs.
  -- codediff.nvim sends these through the real file's LSP client for semantic
  -- tokens, but doesn't always pair them correctly. We track open state and
  -- ensure every didOpen has a matching didClose and vice versa.
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client or client.name ~= "roslyn" or client._codediff_wrapped then
        return
      end
      ---@diagnostic disable-next-line: inject-field
      client._codediff_wrapped = true

      local orig_notify = client.notify
      local open_docs = {} ---@type table<string, boolean>

      client.notify = function(first, ...)
        -- method_wrapper means notify can be called as client.notify(method, params)
        -- or client:notify(method, params). Peek at args to find the method.
        local method = type(first) == "string" and first or select(1, ...)
        local params = type(first) == "string" and select(1, ...) or select(2, ...)

        local uri = type(params) == "table" and params.textDocument
          and type(params.textDocument.uri) == "string"
          and params.textDocument.uri or nil

        if uri and uri:match("^codediff://") then
          if method == "textDocument/didOpen" then
            if open_docs[uri] then
              -- Already open in Roslyn — close first to avoid duplicate didOpen crash
              ---@diagnostic disable-next-line: param-type-mismatch
              orig_notify("textDocument/didClose", { textDocument = { uri = uri } })
            end
            open_docs[uri] = true
          elseif method == "textDocument/didClose" then
            if not open_docs[uri] then
              -- Never opened — suppress to avoid orphaned didClose crash
              return true
            end
            open_docs[uri] = nil
          end
        end

        return orig_notify(first, ...)
      end
    end,
    desc = "Track codediff:// didOpen/didClose pairing for roslyn",
  })
end

return {
  "neovim/nvim-lspconfig",
  config = function()
    suppress_diagnostics()
    set_lsp_autocmds()

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
