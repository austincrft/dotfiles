local parsers = {
  "bicep",
  "c_sharp",
  "dockerfile",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "powershell",
  "sql",
  "typescript",
  "xml",
  "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install(parsers)

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local ft = vim.bo[args.buf].filetype
          local lang = vim.treesitter.language.get_lang(ft)
          if lang and vim.treesitter.language.add(lang) then
            vim.treesitter.start(args.buf, lang)
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      vim.api.nvim_create_autocmd({ "BufReadPost", "BufWinEnter" }, {
        callback = function(args)
          if vim.wo.diff then return end
          local ft = vim.bo[args.buf].filetype
          local lang = vim.treesitter.language.get_lang(ft)
          if lang and vim.treesitter.language.add(lang) then
            vim.opt_local.foldmethod = "expr"
            vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          end
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true,
        },
        move = {
          set_jumps = true,
        },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")

      local function sel(q, g) return function() select.select_textobject(q, g) end end
      vim.keymap.set({ "x", "o" }, "af", sel("@function.outer", "textobjects"))
      vim.keymap.set({ "x", "o" }, "if", sel("@function.inner", "textobjects"))
      vim.keymap.set({ "x", "o" }, "aa", sel("@parameter.outer", "textobjects"))
      vim.keymap.set({ "x", "o" }, "ia", sel("@parameter.inner", "textobjects"))
      vim.keymap.set({ "x", "o" }, "ac", sel("@class.outer", "textobjects"))
      vim.keymap.set({ "x", "o" }, "ic", sel("@class.inner", "textobjects"))
      vim.keymap.set({ "x", "o" }, "as", sel("@local.scope", "locals"))
      vim.keymap.set({ "x", "o" }, "is", sel("@local.scope", "locals"))

      vim.keymap.set({ "n", "x", "o" }, "]m", function() move.goto_next_start("@function.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "]]", function() move.goto_next_start("@class.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "]s", function() move.goto_next_start("@local.scope", "locals") end)
      vim.keymap.set({ "n", "x", "o" }, "]z", function() move.goto_next_start("@fold", "folds") end)
      vim.keymap.set({ "n", "x", "o" }, "[m", function() move.goto_previous_start("@function.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[[", function() move.goto_previous_start("@class.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[s", function() move.goto_previous_start("@local.scope", "locals") end)
      vim.keymap.set({ "n", "x", "o" }, "[z", function() move.goto_previous_start("@fold", "folds") end)
    end,
  },
}
