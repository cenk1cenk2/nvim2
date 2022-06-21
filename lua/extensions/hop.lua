local M = {}

local extension_name = "hop"

function M.config()
  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
    keymaps = {
      normal_mode = {
        ["s"] = ":HopChar2<cr>",
        ["ss"] = ":HopChar1<cr>",
        ["sw"] = ":HopPattern<cr>",
        ["S"] = ":HopWord<cr>",
        ["SS"] = ":HopLine<cr>",
      },
    },
    setup = {},
  }
end

function M.setup()
  local extension = require "hop"

  extension.setup(lvim.extensions[extension_name].setup)

  require("lvim.keymappings").load(lvim.extensions[extension_name].keymaps)

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done()
  end
end

return M
