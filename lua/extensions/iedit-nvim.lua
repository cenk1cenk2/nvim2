-- https://github.com/altermo/iedit.nvim
local M = {}

local Log = require("lvim.core.log")

local extension_name = "altermo/iedit.nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "altermo/iedit.nvim",
      }
    end,
    setup = function()
      return {
        select = {
          map = {
            q = { "done" },
            ["<Esc>"] = { "select", "done" },
            ["<CR>"] = { "toggle" },
            n = { "toggle", "next" },
            p = { "toggle", "prev" },
            N = { "next" },
            P = { "prev" },
            a = { "all" },
            --Mapping to use while in selection-mode
            --Possible values are:
            -- • `done` Done with selection
            -- • `next` Go to next occurrence
            -- • `prev` Go to previous occurrence
            -- • `select` Select current
            -- • `unselect` Unselect current
            -- • `toggle` Toggle current
            -- • `all` Select all
          },
          highlight = {
            current = "CurSearch",
            selected = "Search",
          },
        },
        highlight = "IncSearch",
      }
    end,
    on_setup = function(config)
      -- require("iedit").setup(config.setup)
    end,
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.TASKS, "i" }),
          function()
            if M.is_active() then
              Log:info("Editing stopped.")

              return require("iedit").stop()
            end

            Log:info("Editing started.")
            require("iedit").select()
          end,
          desc = "start iedit",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.TASKS, "I" }),
          function()
            Log:info("Editing started with selection.")

            require("iedit").select_all()
          end,
          desc = "iedit select all",
          mode = { "n", "v" },
        },
      }
    end,
  })
end

function M.is_active(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local data = vim.b[bufnr].iedit_data

  return data ~= nil and (type(data) == "table" and vim.tbl_count(data) > 0)
end

return M
