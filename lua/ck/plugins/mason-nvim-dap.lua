-- https://github.com/jay-babu/mason-nvim-dap.nvim
local M = {}

M.name = "jay-babu/mason-nvim-dap.nvim"

local log = require("ck.log")

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "jay-babu/mason-nvim-dap.nvim",
        keys = { { "<Space>d" } },
      }
    end,
    setup = function()
      ---@type MasonNvimDapSettings
      return {
        -- A list of adapters to install if they're not already installed.
        -- This setting has no relation with the `automatic_installation` setting.
        ensure_installed = {},

        -- NOTE: this is left here for future porting in case needed
        -- Whether adapters that are set up (via dap) should be automatically installed if they're not already installed.
        -- This setting has no relation with the `ensure_installed` setting.
        -- Can either be:
        --   - false: Daps are not automatically installed.
        --   - true: All adapters set up via dap are automatically installed.
        --   - { exclude: string[] }: All adapters set up via mason-nvim-dap, except the ones provided in the list, are automatically installed.
        --       Example: automatic_installation = { exclude = { "python", "delve" } }
        automatic_installation = false,

        -- Whether adapters that are installed in mason should be automatically set up in dap.
        -- Removes the need to set up dap manually.
        -- See mappings.adapters and mappings.configurations for settings.
        -- Must invoke when set to true: `require 'mason-nvim-dap'.setup_handlers()`
        -- Can either be:
        -- 	- false: Dap is not automatically configured.
        -- 	- true: Dap is automatically configured.
        -- 	- {adapters: {ADAPTER: {}, }, configurations: {ADAPTER: {}, }}. Allows overriding default configuration.
        automatic_setup = false,
        handlers = {
          function(config)
            require("mason-nvim-dap").default_setup(config)
          end,
        },
      }
    end,
    on_setup = function(c)
      require("mason-nvim-dap").setup(c)
    end,
  })
end

return M
