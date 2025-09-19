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

      vim.keymap.set("n", "<F5>", dap.continue, { desc = "Start/continue debugging" })
      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Step over" })
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Step into" })
      vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Step out" })
      vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
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
    config = function()
      require("dap-helper").setup()
    end
  },
}

