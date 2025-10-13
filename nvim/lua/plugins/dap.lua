return {
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")

      dap.adapters.coreclr = {
        type = 'executable',
        command = 'netcoredbg',
        args = {'--interpreter=vscode'}
      }

      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "attach - netcoredbg",
          request = "attach",
          processId = function()
            return require('dap.utils').pick_process()
          end,
        },
        {
          type = "coreclr",
          name = "launch - netcoredbg",
          request = "launch",
          program = function()
            local actions = require('telescope.actions')
            local action_state = require('telescope.actions.state')

            return coroutine.create(function(coro)
              require('telescope.builtin').find_files({
                prompt_title = "Select DLL to Debug",
                find_command = { "rg", "--files", "--iglob", "*.dll", "--no-ignore" },
                attach_mappings = function(prompt_bufnr, map)
                  actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    coroutine.resume(coro, selection.path)
                  end)
                  return true
                end,
              })
              local dll_path = coroutine.yield()
              return dll_path
            end)
          end,
        },
      }

      vim.cmd("highlight DapStoppedColor guifg=#ffc777")
      vim.fn.sign_define('DapStopped', {text='🡆', texthl='DapStoppedColor', linehl='DapStoppedColor', numhl=''})
      vim.fn.sign_define('DapBreakpoint', {text='🔴', texthl='', linehl='', numhl=''})

      vim.api.nvim_create_user_command("DapExceptions", function(opts)
        require('dap').set_exception_breakpoints({opts.args})
      end, {
        nargs = 1,
        complete = function(arg_lead, _, _)
          local options = { "all", "user-unhandled", "never" }
          return vim.tbl_filter(function(option)
            return option:find("^" .. vim.pesc(arg_lead))
          end, options)
        end,
      })

      vim.keymap.set("n", "<F5>", dap.continue, { desc = "Start/continue debugging" })
      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Step over" })
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Step into" })
      vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Step out" })
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
      vim.keymap.set("n", "<leader>dB", dap.clear_breakpoints, { desc = "Toggle breakpoint" })
      vim.keymap.set("n", "<leader>de", ":DapExceptions ", { desc = "Exception settings" })
      vim.keymap.set("n", "<leader>dc", dap.run_to_cursor, { desc = "Run to cursor" })
      vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "Toggle DAP REPL" })
      vim.keymap.set("n", "<leader>dj", dap.down, { desc = "Go down stack frame" })
      vim.keymap.set("n", "<leader>dk", dap.up, { desc = "Go up stack frame" })
    end
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio"
    },
    config = function ()
      local dapui = require("dapui")
      local dap = require("dap")

      dapui.setup()

      -- Automatically open/close dap ui
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      -- Overwrite <leader><leader> during a debug session
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("DapKeymaps", { clear = true }),
        callback = function()
          vim.keymap.set("n", "<leader><leader>", function()
            if dap.session() then
              dapui.eval()
            else
              vim.cmd(":DiagOpenFloat")
            end
          end, {
            buffer = true, -- Make it a buffer-local mapping
            noremap = true,
            silent = true,
            desc = "Debug eval",
          })
        end,
      })
    end
  },
  {
    'daic0r/dap-helper.nvim',
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui"
    },
    opts = {}
  },
}

