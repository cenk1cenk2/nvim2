-- https://github.com/sindrets/diffview.nvim
local setup = require "utils.setup"

local M = {}

local extension_name = "diffview"

function M.config()
  setup.define_extension(extension_name, true, {
    packer = function(config)
      return {
        "sindrets/diffview.nvim",
        config = function()
          require("utils.setup").packer_config "diffview"
        end,
        disable = not config.active,
      }
    end,
    to_inject = function()
      return {
        cb = require("diffview.config").diffview_callback,
      }
    end,
    setup = function(config)
      local cb = config.inject.cb

      return {
        on_config_done = nil,
        diff_binaries = false, -- Show diffs for binaries
        use_icons = true, -- Requires nvim-web-devicons
        file_panel = { win_config = { width = 35 } },
        key_bindings = {
          -- The `view` bindings are active in the diff buffers, only when the current
          -- tabpage is a Diffview.
          view = {
            ["<tab>"] = cb "select_next_entry", -- Open the diff for the next file
            ["<s-tab>"] = cb "select_prev_entry", -- Open the diff for the previous file
            ["f"] = cb "focus_files", -- Bring focus to the files panel
            ["F"] = cb "toggle_files", -- Toggle the files panel.
          },
          file_panel = {
            ["j"] = cb "next_entry", -- Bring the cursor to the next file entry
            ["<down>"] = cb "next_entry",
            ["k"] = cb "prev_entry", -- Bring the cursor to the previous file entry.
            ["<up>"] = cb "prev_entry",
            ["<cr>"] = cb "select_entry", -- Open the diff for the selected entry.
            ["o"] = cb "select_entry",
            ["R"] = cb "refresh_files", -- Update stats and entries in the file list.
            ["<tab>"] = cb "select_next_entry",
            ["<s-tab>"] = cb "select_prev_entry",
            ["f"] = cb "focus_files",
            ["F"] = cb "toggle_files",
          },
        },
      }
    end,
    on_setup = function(config)
      require("diffview").setup(config.setup)
    end,
    wk = {
      ["g"] = {
        ["a"] = { ":DiffviewFileHistory %<CR>", "buffer commits" },
        ["d"] = { ":DiffviewOpen<CR>", "diff view open" },
        ["D"] = { ":DiffviewClose<CR>", "diff view close" },
        ["v"] = { ":DiffviewFileHistory<CR>", "workspace commits" },
      },
    },
  })
end

return M
