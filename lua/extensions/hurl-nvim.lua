-- https://github.com/jellydn/hurl.nvim
local M = {}

local extension_name = "jellydn/hurl.nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "jellydn/hurl.nvim",
        dependencies = { "MunifTanjim/nui.nvim" },
        cmd = { "HurlRunner", "HurlRunnerAt", "HurlRunner" },
      }
    end,
    setup = function()
      return {
        -- Show debugging info
        debug = false,
        -- Show response in popup or split
        mode = "popup",
        -- Split settings
        split_position = "right",
        split_size = "50%",

        -- Popup settings
        popup_position = "50%",
        popup_size = {
          width = 180,
          height = 60,
        },
        -- Default environment file name
        env_file = "vars.env",
        -- Specify formatters for different response types
        formatters = {
          json = { "prettierd", "result.json" }, -- Uses jq to format JSON responses
          html = { "prettierd", "result.html" },
        },
      }
    end,
    on_setup = function(config)
      require("hurl").setup(config.setup)
    end,
    wk = function(_, categories)
      return {
        [categories.TASKS] = {
          r = {
            ":HurlRunnerAt<CR>",
            "run hurl under cursor",
          },
          R = {
            ":HurlRunner<CR>",
            "run hurl under cursor",
          },
        },
      }
    end,
  })
end

return M
