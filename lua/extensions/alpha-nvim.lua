-- https://github.com/goolord/alpha-nvim
local M = {}

local extension_name = "alpha"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "goolord/alpha-nvim",
        lazy = false,
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "alpha",
      })
    end,
    on_setup = function(config)
      local lvim_version = require("lvim.utils.git").get_lvim_current_sha()
      local nvim_version = require("lvim.utils.git").get_nvim_version()
      local num_plugins_loaded = require("lazy").stats().count
      local button = require("alpha.themes.dashboard").button

      local buttons = {}
      for _, value in ipairs(config.layout.buttons) do
        table.insert(buttons, button(value[1], value[2]))
      end

      require("alpha").setup({
        layout = {
          { type = "padding", val = 1 },
          {
            type = "text",
            val = config.layout.header,
            opts = {
              position = "center",
              hl = "DashboardHeader",
              -- wrap = "overflow";
            },
          },
          { type = "padding", val = 1 },
          {
            type = "group",
            val = buttons,
            opts = {
              spacing = 1,
              hl = "DashboardCenter",
            },
          },
          { type = "padding", val = 1 },

          {
            type = "text",
            val = { "Neovim loaded: " .. num_plugins_loaded .. " plugins " },
            opts = {
              position = "center",
              hl = "DashboardFooter",
            },
          },
          { type = "padding", val = 0 },
          {
            type = "text",
            val = { lvim_version },
            opts = {
              position = "center",
              hl = "DashboardFooter",
            },
          },
          { type = "padding", val = 0 },
          {
            type = "text",
            val = { nvim_version },
            opts = {
              position = "center",
              hl = "DashboardFooter",
            },
          },
        },
        opts = {
          margin = 5,
        },
      })
    end,
    wk = function(_, categories)
      return {
        [categories.SESSION] = {
          c = { ":Alpha<CR>", "dashboard" },
        },
      }
    end,
    autocmds = {
      {
        "FileType",
        {
          group = "__alpha",
          pattern = "alpha",
          command = "setlocal nocursorline noswapfile synmaxcol& signcolumn=no norelativenumber nocursorcolumn nospell nolist nonumber bufhidden=wipe colorcolumn= foldcolumn=0 matchpairs=",
        },
      },

      {
        "FileType",
        {
          group = "__alpha",
          pattern = "alpha",
          command = "nnoremap <silent> <buffer> q :q<CR>",
        },
      },
    },
    layout = {
      header = {
        [[                                                                                        ]],
        [[                                      ████▒▒▒▒██████                                    ]],
        [[                                    ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                                  ]],
        [[                                  ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                                ]],
        [[                                  ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                              ]],
        [[                                ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                              ]],
        [[                                ██▒▒▒▒▒▒    ▒▒    ▒▒▒▒▒▒██                              ]],
        [[                                ██▒▒▒▒▒▒  ██▒▒██  ▒▒▒▒▒▒██                              ]],
        [[                                ██▒▒▒▒▒▒  ██▒▒██  ▒▒▒▒▒▒██                              ]],
        [[                                  ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                                ]],
        [[                          ██████  ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██    ██                            ]],
        [[                          ██▒▒▒▒██  ██▒▒██▒▒▒▒▒▒██▒▒██████▒▒██  ██                      ]],
        [[                        ██████▒▒▒▒██▒▒▒▒▒▒██████▒▒▒▒██▒▒▒▒██  ██▒▒██                    ]],
        [[                      ██▒▒▒▒▒▒████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██████  ██▒▒██                      ]],
        [[                        ██████▒▒▒▒▒▒▒▒██▒▒▒▒▒▒▒▒▒▒██▒▒▒▒████▒▒██                        ]],
        [[                              ██████████▒▒▒▒▒▒██▒▒▒▒██▒▒▒▒▒▒██                          ]],
        [[                                    ██▒▒▒▒▒▒▒▒▒▒██▒▒▒▒██████████                        ]],
        [[                              ██████▒▒▒▒▒▒██▒▒██  ██▒▒▒▒▒▒▒▒▒▒▒▒██                      ]],
        [[                            ██▒▒▒▒▒▒▒▒▒▒██▒▒▒▒▒▒██  ████████████                        ]],
        [[                          ██▒▒██████████  ██▒▒▒▒▒▒██                                    ]],
        [[                          ████              ██████▒▒██                                  ]],
        [[                                                  ████                                  ]],
        [[                                                      ██                                ]],
        [[                                                                                        ]],
      },
      buttons = {
        { "SPC w l", lvim.icons.ui.History .. "  Load Last Session" },
        { "SPC w f", lvim.icons.ui.Stacks .. "  Sessions" },
        { "SPC p", lvim.icons.ui.File .. "  Find File" },
        { "SPC w p", lvim.icons.ui.Project .. "  Recent Projects" },
        { "SPC f f", lvim.icons.ui.Files .. "  Recently Used Files" },
        { "SPC P S", lvim.icons.ui.Gear .. "  Plugins" },
        { "q", lvim.icons.ui.TriangleShortArrowLeft .. "  Quit" },
      },
    },
  })
end

return M
