local function range_contains_pos(range, line, char)
    local start = range.start
    local stop = range["end"]

    if line < start.line or line > stop.line then
        return false
    end

    if line == start.line and char < start.character then
        return false
    end

    if line == stop.line and char > stop.character then
        return false
    end

    return true
end

local function find_symbol_path(symbol_list, line, char, path)
    if not symbol_list or #symbol_list == 0 then
        return false
    end

    for _, symbol in ipairs(symbol_list) do
        if range_contains_pos(symbol.range, line, char) then
            table.insert(path, symbol.name)
            find_symbol_path(symbol.children, line, char, path)
            return true
        end
    end
    return false
end

local function lsp_callback(err, symbols, ctx, config, winid)
    if err or not symbols then
        if vim.api.nvim_win_is_valid(winid) then
            vim.wo[winid].winbar = ""
        end
        return
    end

    if not vim.api.nvim_win_is_valid(winid) then
        return
    end

    local pos = vim.api.nvim_win_get_cursor(winid)
    local cursor_line = pos[1] - 1
    local cursor_char = pos[2]

    local file_path = vim.fn.bufname(ctx.bufnr)
    if not file_path or file_path == "" then
        vim.wo[winid].winbar = "[No Name]"
        return
    end

    local relative_path

    local clients = vim.lsp.get_clients({ bufnr = ctx.bufnr })

    if #clients > 0 and clients[1].root_dir then
        local root_dir = clients[1].root_dir
        if root_dir == nil then
            relative_path = ""
        else
            relative_path = vim.fs.relpath(root_dir, file_path)
            relative_path = relative_path and string.gsub(relative_path, "/", " > ")
        end
    end


    local breadcrumbs = { relative_path }

    find_symbol_path(symbols, cursor_line, cursor_char, breadcrumbs)

    local breadcrumb_string = table.concat(breadcrumbs, " > ")

    if breadcrumb_string ~= "" then
        vim.wo[winid].winbar = breadcrumb_string
    else
        vim.wo[winid].winbar = " "
    end
end

local function breadcrumbs_set()
    local bufnr = vim.api.nvim_get_current_buf()
    local winid = vim.api.nvim_get_current_win()

    -- Check for LSP clients attached to this buffer
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    if #clients == 0 then
        vim.wo[winid].winbar = ""
        return
    end

    -- Check if any client supports documentSymbol
    local supports_document_symbol = false
    for _, client in ipairs(clients) do
        if client.supports_method and client:supports_method("textDocument/documentSymbol") then
            supports_document_symbol = true
            break
        end
    end
    if not supports_document_symbol then
        vim.wo[winid].winbar = ""
        return
    end

    local uri = vim.lsp.util.make_text_document_params(bufnr)["uri"]
    if not uri then
        vim.print("Error: Could not get URI for buffer. Is it saved?")
        vim.wo[winid].winbar = ""
        return
    end

    local params = {
        textDocument = {
            uri = uri
        }
    }
    vim.lsp.buf_request(
        bufnr,
        "textDocument/documentSymbol",
        params,
        function(err, symbols, ctx, config)
            -- Pass the window ID to the callback
            if vim.api.nvim_win_is_valid(winid) then
                lsp_callback(err, symbols, ctx, config, winid)
            end
        end
    )
end

local breadcrumbs_augroup = vim.api.nvim_create_augroup("Breadcrumbs", { clear = true })

vim.api.nvim_create_autocmd({ "LspAttach", "CursorMoved" }, {
    group = breadcrumbs_augroup,
    callback = breadcrumbs_set,
    desc = "Set breadcrumbs.",
})
