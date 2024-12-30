-- https://github.com/LintaoAmons/bookmarks.nvim
local M = {}

M.name = "LintaoAmons/bookmarks.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "LintaoAmons/bookmarks.nvim",
        dependencies = {
          { "kkharji/sqlite.lua" },
        },
        event = { "BufReadPost", "BufNewFile", "BufNew" },
      }
    end,
    setup = function()
      return {
        signs = {
          -- Sign mark icon and color in the gutter
          mark = {
            icon = nvim.ui.icons.ui.BookMark,
            color = "",
            line_bg = "",
          },
          desc_format = function()
            return ""
          end,
        },
      }
    end,
    on_setup = function(c)
      require("bookmarks").setup(c)
    end,
    keymaps = function(_, fn)
      ---@type WKMappings
      return {
        {
          fn.keystroke({ "m", "m" }),
          function()
            local Service = require("bookmarks.domain.service")
            local Sign = require("bookmarks.sign")
            local Tree = require("bookmarks.tree.operate")
            Service.toggle_mark("")
            Sign.safe_refresh_signs()
            pcall(Tree.refresh)
          end,
          desc = "toggle bookmark",
        },

        {
          fn.keystroke({ "m", "n" }),
          function()
            require("bookmarks").goto_next_list_bookmark()
          end,
          desc = "next bookmark",
        },

        {
          fn.keystroke({ "m", "p" }),
          function()
            require("bookmarks").goto_prev_list_bookmark()
          end,
          desc = "previous bookmark",
        },

        {
          fn.keystroke({ "m", "f" }),
          function()
            require("bookmarks").goto_bookmark()
          end,
          desc = "show bookmarks",
        },
      }
    end,
  })
end

return M
