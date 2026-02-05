-- Strip trailing whitespace on save
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = "*",
  callback = function()
    local curpos = vim.api.nvim_win_get_cursor(0) -- Save cursor position
    vim.cmd([[keeppatterns %s/\s\+$//e]])         -- Perform substitution
    vim.api.nvim_win_set_cursor(0, curpos)        -- Restore cursor position
  end,
})

-- Disable auto comment on newline
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- Enable treesitter folding (skip for diff buffers)
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWinEnter" }, {
  callback = function()
    if vim.wo.diff then
      return
    end
    local parsers = require("nvim-treesitter.parsers")
    local bufnr = vim.api.nvim_get_current_buf()
    local parser = parsers.has_parser() and parsers.get_parser(bufnr)
    if parser then
      parser:parse()
      vim.opt_local.foldmethod = "expr"
      vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
    end
  end,
})

-- Expand quickfix
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  pattern = { "[^l]*" },
  command = "botright copen"
})

-- Remove items from quickfix
-- dd to delete in normal
-- d to delete visual
local function delete_qf_items()
    local mode = vim.api.nvim_get_mode()['mode']

    local start_idx
    local count

    if mode == 'n' then
        -- Normal mode
        start_idx = vim.fn.line('.')
        count = vim.v.count > 0 and vim.v.count or 1
    else
        -- Visual mode
        local v_start_idx = vim.fn.line('v')
        local v_end_idx = vim.fn.line('.')

        start_idx = math.min(v_start_idx, v_end_idx)
        count = math.abs(v_end_idx - v_start_idx) + 1

        -- Go back to normal
        vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes(
                '<esc>', -- what to escape
                true, -- Vim leftovers
                false, -- Also replace `<lt>`?
                true -- Replace keycodes (like `<esc>`)?
            ),
            'x', -- Mode flag
            false -- Should be false, since we already `nvim_replace_termcodes()`
        )
    end

    local qflist = vim.fn.getqflist()

    for _ = 1, count, 1 do
        table.remove(qflist, start_idx)
    end

    vim.fn.setqflist(qflist, 'r')
    vim.fn.cursor(start_idx, 1)
end

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'qf',
    callback = function()
      -- `dd` deletes an item from the list.
      vim.keymap.set('n', 'dd', delete_qf_items, { buffer = true })
      vim.keymap.set('x', 'd', delete_qf_items, { buffer = true })
    end,
    desc = 'Quickfix tweaks',
  })

-- Helper to disable LSP/diagnostics/folding for a diff buffer
local function disable_lsp_for_diff(bufnr)
  vim.diagnostic.enable(false, { bufnr = bufnr })
  vim.wo.foldenable = false
  for _, client in pairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if vim.lsp.buf_is_attached(bufnr, client.id) then
      vim.lsp.buf_detach_client(bufnr, client.id)
    end
  end
end

-- Check if buffer is displayed in any diff window
local function is_buf_in_diff_window(bufnr)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == bufnr and vim.wo[win].diff then
      return true
    end
  end
  return false
end

-- Detach LSP from diff buffers (check after LSP has time to fully attach)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    vim.schedule(function()
      if is_buf_in_diff_window(args.buf) and vim.lsp.buf_is_attached(args.buf, args.data.client_id) then
        vim.lsp.buf_detach_client(args.buf, args.data.client_id)
      end
    end)
  end,
  desc = "Detach LSP from diff buffers",
})

-- Apply diff settings when entering a diff window
vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
  callback = function()
    if vim.wo.diff then
      local bufnr = vim.api.nvim_get_current_buf()
      disable_lsp_for_diff(bufnr)
    end
  end,
  desc = "Disable LSP/diagnostics in diff windows",
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local shada_dir = vim.fn.stdpath("data") .. "/shada"
    for _, f in ipairs(vim.fn.glob(shada_dir .. "/main.shada.tmp.*", false, true)) do
      vim.fn.delete(f)
    end
  end
})
