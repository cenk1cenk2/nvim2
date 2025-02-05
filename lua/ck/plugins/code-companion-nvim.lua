-- https://github.com/olimorris/codecompanion.nvim
local M = {}

M.name = "olimorris/codecompanion.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, false, {
    plugin = function()
      ---@type Plugin
      return {
        "olimorris/codecompanion.nvim",
        cmd = { "CodeCompanion", "CodeCompanionCmd", "CodeCompanionActions", "CodeCompanionChat" },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "codecompanion",
      })

      fn.setup_callback(require("ck.plugins.edgy-nvim").name, function(c)
        vim.list_extend(c.right, {
          {
            title = "CodeCompanion",
            ft = "codecompanion",
            size = {
              width = function()
                if vim.o.columns < 180 then
                  return 0.5
                end

                return 120
              end,
            },
          },
        })

        return c
      end)
    end,
    setup = function(_, fn)
      return {
        opts = {
          log_level = "DEBUG",
        },
        strategies = {
          chat = {
            adapter = "copilot",
            keymaps = {
              send = {
                modes = { n = "<C-s>", i = "<C-s>" },
              },
              close = {
                modes = { n = "<C-c>", i = "<C-c>" },
              },
            },
            window = {
              border = nvim.ui.border,
            },
            start_in_insert_mode = true,
            show_settings = true,
          },
          inline = {
            adapter = "copilot",
            keymaps = {
              accept_change = {
                modes = { n = fn.local_keystroke({ "ca" }) },
                description = "Accept the suggested change",
              },
              reject_change = {
                modes = { n = fn.local_keystroke({ "cr" }) },
                description = "Reject the suggested change",
              },
            },
          },
        },
      }
    end,
    on_setup = function(c)
      require("codecompanion").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.COPILOT, "c" }),
          function()
            vim.cmd([[CodeCompanionChat toggle]])
          end,
          desc = "toggle chat [codecompanion]",
          mode = { "n", "v" },
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
  })
end

return M
