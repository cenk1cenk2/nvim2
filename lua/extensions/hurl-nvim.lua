-- https://github.com/jellydn/hurl.nvim
local M = {}

local extension_name = "jellydn/hurl.nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "jellydn/hurl.nvim",
        dependencies = { "MunifTanjim/nui.nvim" },
        cmd = { "HurlRunner", "HurlRunnerAt", "HurlRunnerToEntry", "HurlToggleMode" },
      }
    end,
    setup = function()
      return {
        -- Show debugging info
        debug = false,
        -- Show response in popup or split
        mode = "split",
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
          -- json = { "prettierd", "result.json" },
          json = { "jq" },
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
            ":HurlRunnerToEntry<CR>",
            "run hurl to entry",
          },
          R = {
            ":HurlRunnerAt<CR>",
            "run hurl under cursor",
          },
          h = {
            ":HurlRunner<CR>",
            "run hurl for all requests",
          },
          H = {
            ":HurlToggleMode<CR>",
            "toggle hurl.nvim mode",
          },
          c = {
            function()
              local Log = require("lvim.core.log")
              local job = require("utils.job")

              job.spawn({
                command = join_paths(get_config_dir(), "utils", "scripts", "curl-to-hurl.sh"),
                on_success = function(j)
                  local generated = table.concat(j:result(), "\n")

                  Log:info("Copied generated hurl to clipboard.")
                  vim.fn.setreg(vim.v.register or lvim.system_register, generated)
                end,
              })
            end,
            "curl to hurl",
          },
        },
      }
    end,
    wk_v = function(_, categories)
      return {
        [categories.TASKS] = {
          r = {
            ":HurlRunner<CR>",
            "run hurl for selected requests",
          },
        },
      }
    end,
  })
end

return M
