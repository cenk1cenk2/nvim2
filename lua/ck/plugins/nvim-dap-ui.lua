-- https://github.com/rcarriga/nvim-dap-ui
local M = {}

M.name = "rcarriga/nvim-dap-ui"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "rcarriga/nvim-dap-ui",
        dependencies = {
          "mfussenegger/nvim-dap",
          "nvim-neotest/nvim-nio",
        },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "dapui_breakpoints",
        "dapui_stacks",
        "dapui_watches",
        "dapui_scopes",
        "dapui_repl",
      })

      fn.setup_callback(require("ck.plugins.edgy-nvim").name, function(c)
        vim.list_extend(c.right, {
          {
            title = "Dap Watches",
            ft = "dapui_watches",
            size = {
              width = function()
                if vim.o.columns < 180 then
                  return 0.25
                end

                return 75
              end,
            },
          },
          {
            title = "Dap Stacks",
            ft = "dapui_stacks",
            size = {
              width = function()
                if vim.o.columns < 180 then
                  return 0.25
                end

                return 75
              end,
            },
          },
          {
            title = "Dap Breakpoints",
            ft = "dapui_breakpoints",
            size = {
              width = function()
                if vim.o.columns < 180 then
                  return 0.25
                end

                return 75
              end,
            },
          },
        })

        vim.list_extend(c.bottom, {
          {
            ft = "dapui_scopes",
            title = "Dap Scopes",
            size = {
              height = function()
                if vim.o.lines < 60 then
                  return 0.25
                end

                return 20
              end,
            },
          },
        })

        return c
      end)
    end,
    setup = function()
      ---@type dapui.Config
      return {
        icons = { expanded = nvim.ui.icons.ui.ChevronShortDown, collapsed = nvim.ui.icons.ui.ChevronShortRight },
        mappings = {
          -- Use a table to apply multiple mappings
          expand = { "<CR>", "<2-LeftMouse>", "O" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        -- Expand lines larger than the window
        -- Requires >= 0.7
        expand_lines = true,
        -- Layouts define sections of the screen to place windows.
        -- The position can be "left", "right", "top" or "bottom".
        -- The size specifies the height/width depending on position.
        -- Elements are the elements shown in the layout (in order).
        -- Layouts are opened in order so that earlier layouts take priority in window sizing.
        layouts = {
          {
            elements = {
              -- Provide as ID strings or tables with "id" and "size" keys
              {
                id = "watches",
                size = 0.2,
              },
              {
                id = "stacks",
                size = 0.5,
              },
              {
                id = "breakpoints",
                size = 0.3,
              },
            },
            size = 60,
            position = "right",
          },
          {
            elements = {
              {
                id = "repl",
                size = 0.5,
              },
              {
                id = "scopes",
                size = 0.5, -- Can be float or integer > 1
              },
            },
            size = 20,
            position = "bottom",
          },
        },
        floating = {
          max_height = nil, -- These can be integers or a float between 0 and 1.
          max_width = nil, -- Floats will be treated as percentage of your screen.
          border = nvim.ui.border, -- Border style. Can be nvim.ui.border, "double" or "rounded"
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        windows = { indent = 1 },
        render = {
          max_type_length = nil, -- Can be integer or nil.
        },
      }
    end,
    on_setup = function(c)
      require("dapui").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.DEBUG, "u" }),
          function()
            require("dapui").toggle()
          end,
          desc = "toggle ui",
        },
        {
          fn.wk_keystroke({ categories.DEBUG, "U" }),
          function()
            require("dapui").float_element()
          end,
          desc = "floating element",
        },
      }
    end,
  })
end

return M
