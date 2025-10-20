-- Strip trailing whitespace on save
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  callback = function()
    local curpos = vim.api.nvim_win_get_cursor(0) -- Save cursor position
    vim.cmd([[keeppatterns %s/\s\+$//e]])         -- Perform substitution
    vim.api.nvim_win_set_cursor(0, curpos)        -- Restore cursor position
  end,
})

-- Enable treesitter folding
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWinEnter" }, {
  callback = function()
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
