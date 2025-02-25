-- https://github.com/andythigpen/nvim-coverage
local M = {}

local log = require("ck.log")

M.name = "andythigpen/nvim-coverage"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "andythigpen/nvim-coverage",
        dependencies = {
          { "nvim-lua/plenary.nvim" },
        },
      }
    end,
    setup = function()
      return {
        auto_reload = true,
        commands = true, -- create commands
        load_coverage_cb = function(ftype)
          require("ck.log"):info(("Loaded test coverage: %s"):format(ftype))
        end,
        highlights = {
          -- customize highlight groups created by the plugin
          covered = { fg = nvim.ui.colors.green[300] }, -- supports style, fg, bg, sp (see :h highlight-gui)
          partial = { fg = nvim.ui.colors.yellow[300] },
          uncovered = { fg = nvim.ui.colors.red[300] },
        },
        signs = {
          -- use your own highlight groups or text markers
          covered = { hl = "CoverageCovered", text = nvim.ui.icons.ui.TriangleShortArrowRight },
          partial = { hl = "CoveragePartial", text = nvim.ui.icons.ui.TriangleShortArrowRight },
          uncovered = { hl = "CoverageUncovered", text = nvim.ui.icons.ui.TriangleShortArrowRight },
        },
        summary = {
          -- customize the summary pop-up
          min_coverage = 50.0, -- minimum coverage threshold (used for highlighting)
        },
        lang = {
          -- customize language specific settings
        },
      }
    end,
    on_setup = function(c)
      require("coverage").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.TESTS, "c" }),
          function()
            require("coverage").clear()
          end,
          desc = "clear coverage",
        },
        {
          fn.wk_keystroke({ categories.TESTS, "l" }),
          function()
            require("coverage").load(true)
          end,
          desc = "load coverage file",
        },
        {
          fn.wk_keystroke({ categories.TESTS, "L" }),
          function()
            local shada = require("ck.modules.shada")
            local store_key = "NVIM_COVERAGE_REPORT"
            local stored_value = shada.get(store_key)

            vim.ui.input({
              prompt = "Load coverage",
              default = stored_value,
              completion = "file",
            }, function(arguments)
              shada.set(store_key, arguments)

              if not arguments or arguments == "" then
                log:warn("No coverage file provided.")

                return
              end

              require("coverage").load_lcov(arguments, true)
            end)
          end,
          desc = "load coverage file with input",
        },
        {
          fn.wk_keystroke({ categories.TESTS, "t" }),
          function()
            require("coverage").toggle()
          end,
          desc = "toggle coverage",
        },
        {
          fn.wk_keystroke({ categories.TESTS, "S" }),

          function()
            require("coverage").summary()
          end,
          desc = "coverage summary",
        },
      }
    end,
  })
end

return M
