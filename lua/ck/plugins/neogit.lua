-- https://github.com/NeogitOrg/neogit
local M = {}

M.name = "NeogitOrg/neogit"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "NeogitOrg/neogit",
        dependencies = {
          "nvim-lua/plenary.nvim",
          "sindrets/diffview.nvim",

          "nvim-telescope/telescope.nvim",
        },
      }
    end,
    setup = function()
      return {
        graph_style = "kitty",
      }
    end,
    on_setup = function(c)
      require("neogit").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.GIT, "f" }),
          function()
            require("neogit").open()
          end,
          desc = "neogit",
        },
      }
    end,
  })
end

return M
