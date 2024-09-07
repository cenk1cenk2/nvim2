-- https://github.com/MunifTanjim/nui.nvim
local M = {}

M.name = "MunifTanjim/nui.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "MunifTanjim/nui.nvim",
        event = "VeryLazy",
        init = false,
        config = false,
        dependencies = {
          -- https://github.com/grapp-dev/nui-components.nvim
          -- "grapp-dev/nui-components.nvim",
          -- "cenk1cenk2/nui-components.nvim",
          {
            dir = "~/development/nui-components.nvim",
          },
        },
      }
    end,
  })
end

return M
