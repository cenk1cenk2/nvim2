--
local M = {}

M.name = "ui"

function M.config()
  require("setup").define_extension(M.name, true, {
    opts = {
      multiple_packages = true,
    },
    plugin = function()
      return {
        {
          "nvim-lua/plenary.nvim",
          init = false,
          config = false,
          deactivate = function() end,
        },
        {
          "Tastyep/structlog.nvim",
          lazy = false,
          config = function()
            require("core.log"):get()
          end,
        },
        -- {
        --   "nvim-tree/nvim-web-devicons",
        --   event = "UIEnter",
        --   init = false,
        --   config = false,
        -- },
        {
          "MunifTanjim/nui.nvim",
          event = "VeryLazy",
          init = false,
          config = false,
        },
      }
    end,
  })
end

return M
