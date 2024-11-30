-- https://github.com/uga-rosa/ccc.nvim
local M = {}

M.name = "uga-rosa/ccc.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "uga-rosa/ccc.nvim",
        cmd = { "CccPick", "CccHighlighterToggle" },
      }
    end,
    setup = function()
      ---@type ccc.Options.P
      return {}
    end,
    on_setup = function(c)
      require("ccc").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.RUN, "c" }),
          function()
            vim.cmd([[CccPick]])
          end,
          desc = "color picker",
        },
      }
    end,
    toggles = function(_, categories, fn)
      ---@type WKToggleMappings
      return {
        {
          fn.wk_keystroke({ categories.RUN, "C" }),
          function()
            return require("snacks.toggle").new({
              name = "higlight colors",
              get = function()
                local bufnr = vim.api.nvim_get_current_buf()

                return require("ccc.highlighter").attached_buffer[bufnr] ~= nil
              end,
              set = function(state)
                require("ccc.highlighter"):toggle()
              end,
            })
          end,
          desc = "highlight colors",
        },
      }
    end,
  })
end

return M
