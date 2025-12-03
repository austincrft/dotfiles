return {
  {
    "tpope/vim-fugitive",
    config = function()
      -- Always enable auto-orientation for diffs (side-by-side when space allows)
      vim.g.fugitive_diffsplit_directional_fit = 1

      vim.api.nvim_create_user_command("GdiffsplitRevision", function(opts)
        local args = vim.split(opts.args, "%s+")
        local branch1, branch2
        if #args == 0 then
          vim.notify("Must provide at least one branch", vim.log.levels.ERROR)
        elseif #args == 1 then
          branch1 = "HEAD"
          branch2 = args[1]
        elseif #args == 2 then
          branch1 = args[1]
          branch2 = args[2]
        end

        -- Get changed files between branches
        local cmd = string.format("git diff --name-only %s..%s", branch1, branch2)
        local files = vim.fn.systemlist(cmd)

        if vim.v.shell_error ~= 0 or #files == 0 then
          vim.notify("No differences found between " .. branch1 .. " and " .. branch2, vim.log.levels.WARN)
          return
        end

        -- Build qf list
        local qf_list = {}
        for _, file in ipairs(files) do
          table.insert(qf_list, {
            filename = file,
            lnum = 1,
            text = "Changed in " .. branch1 .. ".." .. branch2
          })
        end

        -- Set qf with title
        local title = string.format("Branch diff: %s..%s", branch1, branch2)
        vim.fn.setqflist({}, 'r', {
          items = qf_list,
          title = title
        })

        -- Store target branch for diffing
        vim.g.gdiff_target_branch = branch2

        -- Open first diff, then qf
        vim.cmd("cfirst")
        vim.cmd("Gdiffsplit! " .. branch2)
        vim.cmd("botright copen")
      end, { nargs = "*", desc = "Diff files between branches" })

      local function open_qf_branch_diff()
        local qf_title = vim.fn.getqflist({ title = 1 }).title
        if qf_title:match("^Branch diff:") and vim.g.gdiff_target_branch then
          -- Close diff mode if active
          if vim.wo.diff then
            vim.cmd("diffoff!")
          end

          -- Close all windows except current one and qf to get clean layout
          local current_win = vim.api.nvim_get_current_win()
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local bufnr = vim.api.nvim_win_get_buf(win)
            local is_qf = vim.bo[bufnr].buftype == "quickfix"
            if win ~= current_win and not is_qf and vim.api.nvim_win_get_config(win).relative == "" then
              pcall(vim.api.nvim_win_close, win, false)
            end
          end

          -- Open diff split
          vim.cmd("Gdiffsplit! " .. vim.g.gdiff_target_branch)
        end
      end

      vim.keymap.set("n", "]q", function()
        pcall(vim.cmd("cnext"))
        vim.schedule(open_qf_branch_diff)
      end, { desc = "Next quickfix entry" })

      vim.keymap.set("n", "[q", function()
        pcall(vim.cmd("cprev"))
        vim.schedule(open_qf_branch_diff)
      end, { desc = "Previous quickfix entry" })

      -- Add <CR> mapping in qf window for branch diffs
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "qf",
        callback = function(ev)
          vim.keymap.set("n", "<CR>", function()
            local qf_title = vim.fn.getqflist({ title = 1 }).title
            if qf_title:match("^Branch diff:") then
              vim.cmd(".cc")
              open_qf_branch_diff()
            else
              -- Normal quickfix behavior
              vim.cmd("normal! \r")
            end
          end, { buffer = ev.buf })
        end,
      })
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, {expr=true, desc="Next Git hunk"})

          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, {expr=true, desc="Previous Git hunk"})
        end,
      })
    end,
  },
    {
      "esmuellert/vscode-diff.nvim",
      dependencies = { "MunifTanjim/nui.nvim" },
    config = function()
      require("vscode-diff").setup({
        -- Diff view behavior
        diff = {
          disable_inlay_hints = true,         -- Disable inlay hints in diff windows for cleaner view
          max_computation_time_ms = 5000,     -- Maximum time for diff computation (VSCode default)
        },

        -- Keymaps in diff view
        keymaps = {
          view = {
            quit = "q",                    -- Close diff tab
            toggle_explorer = "<leader>b",  -- Toggle explorer visibility (explorer mode only)
            next_hunk = "]c",   -- Jump to next change
            prev_hunk = "[c",   -- Jump to previous change
            next_file = "]f",   -- Next file in explorer mode
            prev_file = "[f",   -- Previous file in explorer mode
          },
          explorer = {
            select = "<CR>",    -- Open diff for selected file
            hover = "K",        -- Show file diff preview
            refresh = "R",      -- Refresh git status
          },
        },
      })
    end,
  },
}
