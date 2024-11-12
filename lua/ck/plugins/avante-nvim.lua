-- https://github.com/yetone/avante.nvim
local M = {}

M.name = "yetone/avante.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "yetone/avante.nvim",
        build = "make",
        dependencies = {
          { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
          { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
        },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "AvanteInput",
        "Avante",
      })

      -- fn.setup_callback(require("ck.plugins.edgy-nvim").name, function(c)
      --   vim.list_extend(c.right, {
      --     {
      --       title = "Avante",
      --       ft = "Avante",
      --       size = {
      --         width = function()
      --           if vim.o.columns < 180 then
      --             return 0.5
      --           end
      --
      --           return 120
      --         end,
      --       },
      --     },
      --   })
      --
      --   return c
      -- end)
    end,
    setup = function(_, fn)
      local categories = fn.get_wk_categories()

      ---@type avante.Config
      return {
        provider = "copilot",
        windows = {
          wrap = true, -- similar to vim.o.wrap
          width = 50, -- default % based on available width
          sidebar_header = {
            rounded = false,
          },
          input = {
            prefix = nvim.ui.icons.misc.Robot .. " ",
            height = 20, -- Height of the input window in vertical layout
          },
        },
        behaviour = {
          auto_set_highlight_group = false,
          auto_set_keymaps = false,
        },
        mappings = {
          --- @class AvanteConflictMappings
          diff = {
            ours = fn.local_keystroke({ "c", "o" }),
            theirs = fn.local_keystroke({ "c", "t" }),
            all_theirs = fn.local_keystroke({ "a", "t" }),
            both = fn.local_keystroke({ "c", "b" }),
            cursor = fn.local_keystroke({ "c", "c" }),
            next = "]x",
            prev = "[x",
          },
          suggestion = {
            accept = "<M-l>",
            next = "<M-k>",
            prev = "<M-j>",
            dismiss = "<C-h>",
          },
          jump = {
            next = "]]",
            prev = "[[",
          },
          submit = {
            normal = "<CR>",
            insert = "<C-s>",
          },
          sidebar = {
            apply_all = fn.local_keystroke({ "A" }),
            apply_cursor = fn.local_keystroke({ "a" }),
            switch_windows = "<Tab>",
            reverse_switch_windows = "<S-Tab>",
          },
          ask = fn.wk_keystroke({ categories.COPILOT, "c" }),
          edit = fn.wk_keystroke({ categories.COPILOT, "e" }),
          refresh = fn.wk_keystroke({ categories.COPILOT, "r" }),
          focus = fn.wk_keystroke({ categories.COPILOT, "f" }),
          toggle = {
            debug = fn.wk_keystroke({ categories.COPILOT, "A" }),
            hint = fn.wk_keystroke({ categories.COPILOT, "a" }),
          },
        },
      }
    end,
    on_setup = function(c)
      require("avante").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.COPILOT, "c" }),
          function()
            require("avante.api").ask()
          end,
          desc = "toggle chat [avante]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "e" }),
          function()
            require("avante.api").edit()
          end,
          desc = "edit [avante]",
          mode = { "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "r" }),
          function()
            require("avante.api").refresh()
          end,
          desc = "refresh [avante]",
          mode = { "n" },
        },
      }
    end,
    autocmds = function()
      return {
        require("ck.modules.autocmds").q_close_autocmd({
          "Avante",
          "AvanteInput",
        }),
      }
    end,
  })
end

return M
