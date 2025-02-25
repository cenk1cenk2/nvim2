-- https://github.com/nvim-treesitter/nvim-treesitter-context
local M = {}

M.name = "nvim-treesitter/nvim-treesitter-context"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "nvim-treesitter/nvim-treesitter-context",
        event = { "BufReadPost", "BufNewFile", "BufNew" },
      }
    end,
    setup = function()
      ---@type TSContext.UserConfig
      return {
        enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
        max_lines = 20, -- How many lines the window should span. Values <= 0 mean no limit.
        min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
        line_numbers = true,
        multiline_threshold = 5, -- Maximum number of lines to collapse for a single context line
        trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
        mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
        -- Separator between context and content. Should be a single character string, like '-'.
        -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
        separator = nvim.ui.icons.borderchars[3],
        zindex = 20, -- The Z-index of the context window
        on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
      }
    end,
    on_setup = function(c)
      require("treesitter-context").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.TREESITTER, "T" }),
          function()
            require("treesitter-context").toggle()
          end,
          desc = "toggle treesitter context",
        },
      }
    end,
  })
end

return M
