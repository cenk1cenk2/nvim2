-- https://github.com/lalitmee/browse.nvim
local M = {}

M.name = "lalitmee/browse.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "lalitmee/browse.nvim",
      }
    end,
    setup = function()
      return {
        -- search provider you want to use
        provider = "google", -- default
      }
    end,
    on_setup = function(c)
      require("browse").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.FIND, "s" }),
          function()
            require("browse").input_search()
          end,
          desc = "search on google",
        },
      }
    end,
  })
end

return M
