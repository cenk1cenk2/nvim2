-- https://github.com/OXY2DEV/markview.nvim
local M = {}

M.name = "OXY2DEV/markview.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "OXY2DEV/markview.nvim",
        ft = { "markdown", "rmd", "norg", "org", "vimwiki", "Avante" },
      }
    end,
    setup = function()
      local defaults = require("markview.spec").default
      return {
        preview = {
          modes = { "n", "no", "c" }, -- Change these modes
          hybrid_modes = { "n", "v", "x" },
          filetypes = { "markdown", "rmd", "norg", "org", "vimwiki", "Avante" },
          callbacks = {
            -- on_enable = function(_, win)
            --   vim.wo[win].conceallevel = 2
            --   vim.wo[win].concealcursor = "c"
            -- end,
          },
          ignore_buftypes = {},
        },
        markdown = {
          headings = vim.tbl_deep_extend("force", vim.deepcopy(defaults.markdown.headings), {
            enable = true,
            shift_width = 0,
            shift_char = "",
            heading_1 = {
              hl = "@markup.heading.1.markdown",
            },
            heading_2 = {
              hl = "@markup.heading.2.markdown",
            },
            heading_3 = {
              hl = "@markup.heading.3.markdown",
            },
            heading_4 = {
              hl = "@markup.heading.4.markdown",
            },
            heading_5 = {
              hl = "@markup.heading.5.markdown",
            },
            heading_6 = {
              hl = "@markup.heading.6.markdown",
            },
          }),
          list_items = vim.tbl_deep_extend("force", vim.deepcopy(defaults.markdown.list_items), {
            enable = true,
            shift_width = 2,
          }),
        },
      }
    end,
    on_setup = function(c)
      require("markview").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.RUN, "m" }),
          function()
            require("markview").commands.toggle()
          end,
          desc = "toggle markdown preview",
        },
      }
    end,
  })
end

return M
