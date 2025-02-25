local M = {}

---@class WKCategories
---@field ACTIONS string
---@field BOOKMARKS string
---@field BUFFER string
---@field COPILOT string
---@field DEBUG string
---@field FIND string
---@field GIT string
---@field ISSUES string
---@field LSP string
---@field NEOVIM string
---@field NOTES string
---@field RUN string
---@field SEARCH string
---@field SESSION string
---@field TERMINAL string
---@field TESTS string
---@field PLUGINS string Subcategory > neovim
---@field TREESITTER string Subcategory > neovim
---@field LOGS string Subcategory.

---@type WKCategories
M.CATEGORIES = {
  ACTIONS = "a",
  BOOKMARKS = "m",
  BUFFER = "b",
  COPILOT = "c",
  DEBUG = "d",
  FIND = "f",
  GIT = "g",
  ISSUES = "i",
  LSP = "l",
  NEOVIM = "N",
  NOTES = "n",
  PLUGINS = "Np",
  RUN = "r",
  SEARCH = "s",
  SESSION = "w",
  TERMINAL = "t",
  TESTS = "j",
  TREESITTER = "Nt",
  --- subcategories
  LOGS = "?",
}

function M.setup()
  require("ck.setup").init({
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          {
            fn.wk_keystroke({ "x" }),
            "<C-W>s",
            desc = "split below",
            mode = { "n", "v" },
          },
          {
            fn.wk_keystroke({ "v" }),
            "<C-W>v",
            desc = "split right",
            mode = { "n", "v" },
          },
          {
            fn.wk_keystroke({ "'" }),
            function()
              vim.o.hlsearch = false
            end,
            desc = "no highlight",
            mode = { "n", "v" },
          },

          -- localleader

          {
            fn.wk_keystroke({ nvim.localleader }),
            group = "local",
          },

          -- actions

          {
            fn.wk_keystroke({ categories.ACTIONS }),
            group = "actions",
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "a" }),
            "ggVG",
            desc = "select all",
            mode = { "n", "v" },
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "c" }),
            ":set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20<CR>",
            desc = "bring back cursor",
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "e" }),
            ":set ff=unix<CR>",
            desc = "set lf",
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "E" }),
            ":set ff=dos<CR>",
            desc = "set crlf",
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "i" }),
            function()
              vim.ui.select({ "tabs", "spaces" }, {
                prompt = "Indentation Type",
              }, function(value)
                if not value then
                  return
                end

                vim.api.nvim_set_option_value("expandtab", value == "spaces", { buf = 0 })
              end)
            end,
            desc = "indentation type",
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "I" }),
            function()
              vim.ui.input({
                prompt = "Indentation Amount",
                default = tostring(vim.bo.tabstop),
              }, function(value)
                if not value then
                  return
                end

                vim.api.nvim_set_option_value("shiftwidth", tonumber(value), { buf = 0 })
                vim.api.nvim_set_option_value("tabstop", tonumber(value), { buf = 0 })
              end)
            end,
            desc = "indentation amount",
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "w" }),
            "<C-W>=<CR>",
            desc = "balance open windows",
            mode = { "n", "v" },
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "R" }),
            "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
            desc = "redraw",
            mode = { "n", "v" },
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "p" }),
            ":wincmd p<CR>",
            desc = "previous window",
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "s" }),
            ":sort<CR>",
            desc = "sort",
            mode = { "n", "v" },
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "S" }),
            ":set signcolumn=yes<CR>",
            desc = "fix sign columns",
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "T" }),
            ":setlocal bufhidden=delete<CR>",
            desc = "set as temporary buffer",
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "q" }),
            ":colder<CR>",
            desc = "quickfix older",
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "Q" }),
            ":cnewer<CR>",
            desc = "quickfix newer",
          },

          -- buffer

          {
            fn.wk_keystroke({ categories.BUFFER }),
            group = "buffer",
            mode = { "n", "v" },
          },

          {
            fn.wk_keystroke({ categories.BUFFER, "c" }),
            function()
              vim.fn.setreg(vim.v.register or nvim.system_register, require("ck.utils.fs").get_buffer_name())
            end,
            desc = "copy filename to clipboard",
          },
          {
            fn.wk_keystroke({ categories.BUFFER, "C" }),
            function()
              vim.fn.setreg(vim.v.register or nvim.system_register, require("ck.utils.fs").get_project_buffer_filepath())
            end,
            desc = "copy buffer project path to clipboard",
          },
          {
            fn.wk_keystroke({ categories.BUFFER, "e" }),
            ":e<CR>",
            desc = "reopen current buffer",
            mode = { "n", "v" },
          },
          {
            fn.wk_keystroke({ categories.BUFFER, "E" }),
            ":e!<CR>",
            desc = "force reopen current buffer",
            mode = { "n", "v" },
          },
          {
            fn.wk_keystroke({ categories.BUFFER, "s" }),
            ":edit #<CR>",
            desc = "switch to last buffer",
            mode = { "n", "v" },
          },
          {
            fn.wk_keystroke({ categories.BUFFER, "S" }),
            function()
              vim.cmd("w!")
              require("ck.log"):warn("File overwritten.")
            end,
            desc = "overwrite - force save",
            mode = { "n", "v" },
          },
          {
            fn.wk_keystroke({ categories.BUFFER, "R" }),
            function()
              vim.ui.input({
                prompt = "rename buffer",
                default = vim.api.nvim_buf_get_name(0),
              }, function(value)
                if not value then
                  return
                end

                vim.api.nvim_buf_set_name(0, value)
              end)
            end,
            desc = "change buffer current name",
            mode = { "n", "v" },
          },
          {
            fn.wk_keystroke({ categories.BUFFER, "N" }),
            function()
              local bufnr = vim.api.nvim_create_buf(true, false)
              vim.api.nvim_set_current_buf(bufnr)
            end,
            desc = "create empty buffer",
            mode = { "n", "v" },
          },
          {
            fn.wk_keystroke({ categories.BUFFER, "w" }),
            function()
              vim.cmd("w")
            end,
            desc = "write",
            mode = { "n", "v" },
          },
          {
            fn.wk_keystroke({ categories.BUFFER, "W" }),
            function()
              vim.cmd("wa")
              require("ck.log"):warn("Wrote all files.")
            end,
            desc = "write all",
            mode = { "n", "v" },
          },

          -- copilot

          {
            fn.wk_keystroke({ categories.COPILOT }),
            group = "copilot",
            mode = { "n", "v" },
          },

          -- debug

          {
            fn.wk_keystroke({ categories.DEBUG }),
            group = "debug",
            mode = { "n", "v" },
          },

          -- find

          {
            fn.wk_keystroke({ categories.FIND }),
            group = "find",
            mode = { "n", "v" },
          },

          -- search

          {
            fn.wk_keystroke({ categories.SEARCH }),
            group = "search",
            mode = { "n", "v" },
          },

          -- issues

          {
            fn.wk_keystroke({ categories.ISSUES }),
            group = "issues",
            mode = { "n", "v" },
          },

          -- notes

          {
            fn.wk_keystroke({ categories.NOTES }),
            group = "notes",
            mode = { "n", "v" },
          },

          -- git

          {
            fn.wk_keystroke({ categories.GIT }),
            group = "git",
            mode = { "n", "v" },
          },

          {
            fn.wk_keystroke({ categories.GIT, "g" }),
            group = "github",
            mode = { "n", "v" },
          },

          {
            fn.wk_keystroke({ categories.GIT, "l" }),
            group = "gitlab",
            mode = { "n", "v" },
          },

          -- lsp

          {
            fn.wk_keystroke({ categories.LSP }),
            group = "lsp",
            mode = { "n", "v" },
          },

          -- bookmarks

          {
            fn.wk_keystroke({ categories.BOOKMARKS }),
            group = "bookmarks",
            mode = { "n", "v" },
          },

          -- terminal

          {
            fn.wk_keystroke({ categories.TERMINAL }),
            group = "terminal",
            mode = { "n", "v" },
          },

          -- sessions

          {
            fn.wk_keystroke({ categories.SESSION }),
            group = "session",
            mode = { "n", "v" },
          },

          {
            fn.wk_keystroke({ categories.GIT, "r" }),
            function()
              local root = vim.fs.root(0, { ".git" })

              if not root then
                require("ck.log"):warn("Can not find git root.")
                return
              end

              require("ck.log"):info("Changing cwd to git root: %s", root)

              vim.api.nvim_set_current_dir(root)
            end,
            desc = "cwd as git root",
            mode = { "n", "v" },
          },

          -- neovim

          {
            fn.wk_keystroke({ categories.PLUGINS }),
            group = "plugins",
          },

          -- tests

          {
            fn.wk_keystroke({ categories.TESTS }),
            group = "tests",
          },

          -- tasks

          {
            fn.wk_keystroke({ categories.RUN }),
            group = "run",
          },

          -- neovim

          {
            fn.wk_keystroke({ categories.NEOVIM }),
            group = "neovim",
          },

          -- treesitter

          {
            fn.wk_keystroke({ categories.TREESITTER }),
            group = "treesitter",
          },
        },
      }
    end,
    toggles = function(_, categories, fn)
      ---@type WKToggleMappings
      return {
        {
          fn.wk_keystroke({ categories.ACTIONS, "b" }),
          function()
            return require("snacks").toggle.new({
              name = "editor block",
              get = function()
                return vim.env["EDITOR_BLOCK"] == "1"
              end,
              set = function(state)
                if state then
                  local editor = "nvim -b"

                  vim.env.VISUAL = editor
                  vim.env.EDITOR = editor
                  vim.env.GIT_EDITOR = editor
                  vim.env.EDITOR_BLOCK = "1"

                  require("ck.log"):info("Editor set to blocking mode.")
                else
                  local editor = "nvim"

                  vim.env.VISUAL = editor
                  vim.env.EDITOR = editor
                  vim.env.GIT_EDITOR = editor
                  vim.env.EDITOR_BLOCK = ""

                  require("ck.log"):info("Editor set to async mode.")
                end
              end,
            })
          end,
          desc = "editor block",
        },
        {
          fn.wk_keystroke({ categories.ACTIONS, "L" }),
          function()
            return require("ck.plugins.snacks-nvim").toggle_global_option("relativenumber")
          end,
          desc = "relative line numbers",
        },
        {
          fn.wk_keystroke({ categories.ACTIONS, "l" }),
          function()
            return require("ck.plugins.snacks-nvim").toggle_global_option("number")
          end,
          desc = "line numbers",
        },
        {
          fn.wk_keystroke({ categories.ACTIONS, "t" }),
          function()
            return require("ck.plugins.snacks-nvim").toggle_local_option("wrap")
          end,
          desc = "wrap",
        },
      }
    end,
  })
end

return M
