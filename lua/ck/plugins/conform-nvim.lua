-- https://github.com/stevearc/conform.nvim
local M = {}
local tools = require("ck.lsp.tools")

M.name = "stevearc/conform.nvim"

local METHOD = tools.METHODS.FORMATTER

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "stevearc/conform.nvim",
        event = { "BufReadPost", "BufNewFile", "BufNew" },
      }
    end,
    setup = function()
      M.extend_tools()
      M.register()

      ---@type conform.setupOpts
      return {
        default_format_opts = {
          lsp_format = nvim.lsp.tools.format.lsp_format,
        },

        -- Map of filetype to formatters
        formatters_by_ft = tools.read(METHOD),
        -- If this is set, Conform will run the formatter on save.
        -- It will pass the table to conform.format().
        -- This can also be a function that returns the table.
        format_on_save = function(bufnr)
          if not require("ck.lsp.format").should_format_on_save() then
            return {
              formatters = {},
            }
          end

          return {
            timeout_ms = nvim.lsp.tools.format.timeout,
          }
        end,
        -- If this is set, Conform will run the formatter asynchronously after save.
        -- It will pass the table to conform.format().
        -- This can also be a function that returns the table.
        -- format_after_save = function(bufnr)
        --   return {
        --   }
        -- end,
        -- Set the log level. Use `:ConformInfo` to see the location of the log file.
        log_level = vim.log.levels.ERROR,
        -- Conform will notify you when a formatter errors
        notify_on_error = true,
      }
    end,
    on_setup = function(c)
      require("conform").setup(c)
    end,
    on_done = function()
      table.insert(nvim.lsp.buffer_options, function(_, bufnr)
        vim.api.nvim_set_option_value("formatexpr", "v:lua.require'conform'.formatexpr()", { buf = bufnr })
      end)

      ---@type ToolListFn
      nvim.lsp.tools.list_registered.formatters = function(bufnr)
        local registered = vim.tbl_extend("force", {
          lsp_format = nvim.lsp.tools.format.lsp_format,
        }, require("ck.lsp.tools").list_registered(require("ck.lsp.tools").METHODS.FORMATTER, bufnr))

        local formatters = {}

        if registered.lsp_format ~= "prefer" then
          for key, value in ipairs(registered) do
            if type(key) == "number" then
              table.insert(formatters, value)
            end
          end
        end

        if registered.lsp_format ~= "never" and not (registered.lsp_format == "fallback" and #formatters > 0) then
          local lsp = vim.tbl_filter(function(client)
            if client.server_capabilities.documentFormattingProvider == true then
              return true
            end

            return false
          end, vim.lsp.get_clients({ bufnr = bufnr }))

          if registered.lsp_format == "first" then
            formatters = vim.list_extend(
              vim.tbl_map(function(client)
                return ("%s [lsp]"):format(client.name)
              end, lsp),
              formatters
            )
          else
            formatters = vim.list_extend(
              formatters,
              vim.tbl_map(function(client)
                return ("%s [lsp]"):format(client.name)
              end, lsp)
            )
          end
        end

        formatters = vim.tbl_filter(function(formatter)
          if type(formatter) == "string" and vim.list_contains(M.default_formatters, formatter) then
            return false
          elseif type(formatter) == "table" and formatter.name and vim.list_contains(M.default_formatters, formatter.name) then
            return false
          end

          return true
        end, formatters)

        return formatters
      end

      ---@param opts? conform.FormatOpts
      ---@diagnostic disable-next-line: duplicate-set-field
      nvim.lsp.fn.format = function(opts)
        opts = vim.tbl_extend(
          "force",
          ---@type conform.FormatOpts
          {
            bufnr = vim.api.nvim_get_current_buf(),
            timeout_ms = nvim.lsp.tools.format.timeout_ms,
            filter = nvim.lsp.tools.format.filter,
            undojoin = true,
          },
          opts or {}
        )
        return require("conform").format(opts)
      end
    end,
    autocmds = function()
      return {
        require("ck.modules.autocmds").on_lspattach(function(bufnr)
          return {
            wk = function(_, categories, fn)
              ---@type WKMappings
              return {
                {
                  fn.wk_keystroke({ categories.LSP, categories.LOGS, "f" }),
                  function()
                    vim.cmd([[ConformInfo]])
                  end,
                  desc = "formatter logs",
                  buffer = bufnr,
                },
              }
            end,
          }
        end),
      }
    end,
  })
end

M.default_formatters = {
  "trim_whitespace",
  "trim_newlines",
  "trim_multiple_newlines",
}

function M.register()
  tools.register(METHOD, { "trim_whitespace", "trim_newlines", "trim_multiple_newlines" }, {
    "*",
  })

  tools.register(METHOD, "injected", {
    "hurl",
    "markdown",
    "gotmpl",
  })

  tools.register(
    METHOD,
    ---@type conform.FormatOpts
    {
      lsp_format = "last",
    },
    {
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
      "vue",
      "svelte",
    }
  )

  tools.register(METHOD, "prettierd", {
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
    "vue",
    "svelte",
    "yaml",
    "yaml.ansible",
    "yaml.docker-compose",
    "json",
    "jsonc",
    "html",
    "scss",
    "css",
    "markdown",
    "graphql",
    -- "xml",
  })

  -- lsp_utils.register(METHOD, "eslint_d", {
  --   "javascript",
  --   "typescript",
  --   "javascriptreact",
  --   "typescriptreact",
  --   "vue",
  --   "svelte",
  -- })

  tools.register(METHOD, "stylua", {
    "lua",
  })

  tools.register(METHOD, { "golines", "goimports" }, {
    "go",
  })

  tools.register(METHOD, "shfmt", {
    "sh",
    "bash",
    "zsh",
  })
  -- lsp_utils.register(METHOD, "beautysh", {
  --   "sh",
  --   "bash",
  --   "zsh",
  -- })

  -- lsp_utils.register(METHOD, "terraform_fmt", {
  --   "terraform",
  --   "tfvars",
  -- })
end

function M.extend_tools()
  local conform = require("conform")

  conform.formatters["prettierd"] = vim.tbl_deep_extend("force", require("conform.formatters.prettierd"), {
    env = {
      ["PRETTIERD_DEFAULT_CONFIG"] = vim.fn.expand("~/.config/nvim/utils/linter-config/.prettierrc.json"),
    },
  })

  conform.formatters["markdown-toc"] = vim.tbl_deep_extend("force", require("conform.formatters.markdown-toc"), {
    prepend_args = { "--bullets='-'" },
  })

  conform.formatters["golines"] = vim.tbl_deep_extend("force", require("conform.formatters.golines"), {
    prepend_args = { "-m", "180" },
  })

  conform.formatters["trim_multiple_newlines"] = {
    meta = {
      url = "https://www.gnu.org/software/gawk/manual/gawk.html",
      description = "Trim multiple new lines with awk.",
    },
    command = "awk",
    args = { "!NF {if (++n <= 1) print; next}; {n=0;print}" },
  }
end

return M
