-- https://github.com/j-hui/fidget.nvim
local M = {}

local extension_name = "fidget_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, false, {
    packer = function(config)
      return {
        "j-hui/fidget.nvim",
        config = function()
          require("utils.setup").packer_config "fidget_nvim"
        end,
        disable = not config.active,
      }
    end,
    setup = {
      text = {
        spinner = "pipe", -- animation shown when tasks are ongoing
        done = "✔", -- character shown when all tasks are complete
        commenced = "Started", -- message shown when task starts
        completed = "Completed", -- message shown when task completes
      },
      align = {
        bottom = true, -- align fidgets along bottom edge of buffer
        right = true, -- align fidgets along right edge of buffer
      },
      timer = {
        spinner_rate = 125, -- frame rate of spinner animation, in ms
        fidget_decay = 2000, -- how long to keep around empty fidget, in ms
        task_decay = 1000, -- how long to keep around completed task, in ms
      },
      fmt = {
        leftpad = true, -- right-justify text in fidget box
        stack_upwards = true, -- list of tasks grows upwards
        -- function to format fidget title
        fidget = function(fidget_name, spinner)
          return string.format("%s %s", spinner, fidget_name)
        end,
        -- function to format each task line
        task = function(task_name, message, percentage)
          return string.format(
            "%s%s [%s]",
            message,
            percentage and string.format(" (%s%%)", percentage) or "",
            task_name
          )
        end,
      },
      debug = {
        logging = false, -- whether to enable logging, for debugging
      },
    },
    on_setup = function(config)
      require("fidget").setup(config.setup)
    end,
  })
end

return M
