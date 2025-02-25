-- https://github.com/nvim-lualine/lualine.nvim
local M = {}

M.name = "nvim-lualine/lualine.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "nvim-lualine/lualine.nvim",
        event = "UIEnter",
      }
    end,
    setup = function()
      local components = M.components()

      return {
        globalstatus = true,
        options = {
          theme = "auto",
          icons_enabled = true,
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = nvim.disabled_filetypes,
        },
        sections = {
          lualine_a = { components.mode },
          lualine_b = {
            components.branch,
            components.filetype,
            -- components.filename,
            components.diff,
            components.python_env,
            components.viedit,
            components.iedit,
          },
          lualine_c = {
            components.noice_message,
          },
          lualine_x = {
            components.searchcount,
            components.ai,
            components.snippet,
            components.noice_mode,
            components.noice_command,
          },
          lualine_y = {
            components.yazi,
            components.lazy_updates,
            components.location,
            components.ff,
            components.spaces,
            -- components.encoding,
            components.session,
            components.dap,
            components.diagnostics,
            components.treesitter,
            components.schema_companion,
            components.lsp,
          },
          lualine_z = { components.scrollbar },
        },
        inactive_sections = {
          lualine_a = { components.mode },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
        -- winbar = {
        --   lualine_a = {},
        --   lualine_b = {},
        --   lualine_c = {},
        --   lualine_x = {},
        --   lualine_y = {},
        --   lualine_z = {},
        -- },
        -- inactive_winbar = {
        --   lualine_a = {},
        --   lualine_b = {},
        --   lualine_c = {},
        --   lualine_x = {},
        --   lualine_y = {},
        --   lualine_z = {},
        -- },
        tabline = nil,
        extensions = { "nvim-tree", "aerial", "quickfix", "nvim-dap-ui", "toggleterm" },
      }
    end,
    on_setup = function(c)
      require("lualine").setup(c)
    end,
  })
end

function M.components()
  local window_width_limit = 70

  local conditions = {
    buffer_not_empty = function()
      return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
    end,
    hide_in_width = function()
      return vim.fn.winwidth(0) > window_width_limit
    end,
  }

  local components = {
    mode = {
      function()
        local mode_name = {
          c = "COMMAND",
          i = "INSERT",
          ic = "INSERT COMP",
          ix = "INSERT COMP",
          multi = "MULTI",
          n = "NORMAL",
          ni = "(INSERT)",
          no = "OP PENDING",
          R = "REPLACE",
          Rv = "V REPLACE",
          s = "SELECT",
          S = "S-LINE",
          [""] = "S-BLOCK",
          t = "TERMINAL",
          v = "VISUAL",
          V = "V-LINE",
          [""] = "V-BLOCK",
        }

        return mode_name[vim.fn.mode()]
      end,
      padding = { left = 1, right = 1 },
      color = { fg = nvim.ui.colors.black },
    },
    branch = {
      "b:gitsigns_head",
      icon = nvim.ui.icons.git.Branch,
      color = { fg = nvim.ui.colors.black, bg = nvim.ui.colors.yellow[300] },
      cond = conditions.hide_in_width,
    },
    ai = {
      function()
        return ("%s %s | %s"):format(nvim.ui.icons.misc.Robot, nvim.lsp.ai.provider.completion, nvim.lsp.ai.provider.chat)
      end,
      cond = function()
        return conditions.hide_in_width()
      end,
      color = {
        fg = nvim.ui.colors.white,
        bg = nvim.ui.colors.blue[300],
      },
    },
    filetype = {
      "filetype",
      cond = conditions.hide_in_width,
      color = {
        fg = nvim.ui.colors.fg,
        bg = nvim.ui.colors.bg[300],
      },
    },
    filename = {
      "filename",
      color = {
        fg = nvim.ui.colors.fg,
        bg = nvim.ui.colors.bg[300],
      },
    },
    diff = {
      "diff",
      source = function()
        local gitsigns = vim.b.gitsigns_status_dict

        if gitsigns then
          return { added = gitsigns.added, modified = gitsigns.changed, removed = gitsigns.removed }
        end
      end,
      symbols = { added = nvim.ui.icons.git.LineAdded .. " ", modified = nvim.ui.icons.git.LineModified .. " ", removed = nvim.ui.icons.git.LineModified .. " " },
      diff_color = {
        added = { fg = nvim.ui.colors.green[600] },
        modified = { fg = nvim.ui.colors.blue[600] },
        removed = { fg = nvim.ui.colors.red[600] },
      },
      color = {
        bg = nvim.ui.colors.bg[300],
      },
      cond = conditions.hide_in_width,
    },
    python_env = {
      function()
        local utils = require("ck.core.lualine.utils")
        if vim.bo.filetype == "python" then
          local venv = os.getenv("CONDA_DEFAULT_ENV") or os.getenv("VIRTUAL_ENV")
          if venv then
            return string.format("  (%s)", utils.env_cleanup(venv))
          end
        end
        return ""
      end,
      color = {
        fg = nvim.ui.colors.green[300],
        bg = nvim.ui.colors.bg[300],
      },
      cond = conditions.hide_in_width,
    },
    schema_companion = {
      function()
        return ("%s %s"):format(nvim.ui.icons.ui.Table, require("schema-companion.context").get_buffer_schema(0).name):sub(0, 128)
      end,
      color = {
        fg = nvim.ui.colors.purple[600],
        bg = nvim.ui.colors.bg[300],
      },
      cond = function()
        return conditions.hide_in_width() and vim.tbl_contains({ "yaml", "helm" }, vim.api.nvim_get_option_value("ft", { buf = 0 })) and is_loaded("schema-companion")
      end,
    },
    diagnostics = {
      "diagnostics",
      sources = { "nvim_diagnostic" },
      symbols = {
        error = nvim.ui.icons.diagnostics.Error .. " ",
        warn = nvim.ui.icons.diagnostics.Warning .. " ",
        info = nvim.ui.icons.diagnostics.Information .. " ",
        hint = nvim.ui.icons.diagnostics.Hint .. " ",
      },
      cond = conditions.hide_in_width,
    },
    session = {
      function()
        return ("%s"):format(nvim.ui.icons.ui.History)
      end,
      color = function()
        return {
          fg = nvim.ui.colors.green[300],
          bg = nvim.ui.colors.bg[300],
        }
      end,
      cond = function()
        if not is_loaded("possession") or require("possession").session_name == "" then
          return false
        end

        return conditions.hide_in_width()
      end,
    },
    dap = {
      function()
        return ("%s - %s"):format(nvim.ui.icons.ui.Bug, require("dap").status())
      end,
      color = function()
        return {
          fg = nvim.ui.colors.yellow[300],
          bg = nvim.ui.colors.bg[300],
        }
      end,
      cond = function()
        if not is_loaded("dap") or require("dap").status() == "" then
          return false
        end

        return conditions.hide_in_width()
      end,
    },
    treesitter = {
      function()
        return nvim.ui.icons.ui.Tree
      end,
      color = function()
        local buf = vim.api.nvim_get_current_buf()
        local ts = vim.treesitter.highlighter.active[buf]

        return {
          fg = ts and not vim.tbl_isempty(ts) and nvim.ui.colors.green[300] or nvim.ui.colors.red[300],
          bg = nvim.ui.colors.bg[300],
        }
      end,
      cond = conditions.hide_in_width,
    },
    lsp = {
      function(msg)
        local bufnr = vim.api.nvim_get_current_buf()

        local buf_clients = vim.tbl_map(function(client)
          return client.name
        end, vim.lsp.get_clients({ bufnr = bufnr }))

        -- add formatter
        local message = { table.concat(buf_clients or { nvim.ui.icons.ui.Close }, ", ") }

        local supported_linters = nvim.lsp.tools.list_registered.linters(bufnr)

        if supported_linters and not vim.tbl_isempty(supported_linters) then
          vim.list_extend(message, { ("%s %s"):format(nvim.ui.icons.ui.DoubleChevronRight, table.concat(supported_linters, ", ")) })
        end

        local supported_formatters = nvim.lsp.tools.list_registered.formatters(bufnr)

        if supported_formatters and not vim.tbl_isempty(supported_formatters) then
          vim.list_extend(message, { ("%s %s"):format(nvim.ui.icons.ui.DoubleChevronRight, table.concat(supported_formatters, ", ")) })
        end

        return table.concat(message, " ")
      end,
      color = { fg = nvim.ui.colors.fg, bg = nvim.ui.colors.bg[300] },
    },
    snippet = {
      function()
        return ("%s%s%s"):format(
          require("luasnip").locally_jumpable(1) and nvim.ui.icons.ui.BoxLeft or "",
          nvim.ui.icons.kind.Snippet,
          require("luasnip").locally_jumpable(-1) and nvim.ui.icons.ui.BoxRight or ""
        )
      end,
      color = { fg = nvim.ui.colors.white, bg = nvim.ui.colors.orange[300] },
      cond = function()
        if not is_loaded("luasnip") then
          return false
        end

        return conditions.hide_in_width() and (require("luasnip").locally_jumpable(1) or require("luasnip").locally_jumpable(-1))
      end,
    },
    progress = {
      "progress",
      cond = conditions.hide_in_width,
      color = {},
    },
    location = {
      "location",
      color = { fg = nvim.ui.colors.blue[300], bg = nvim.ui.colors.bg[300] },
    },
    ff = {
      "fileformat",
      cond = conditions.hide_in_width,
      color = { fg = nvim.ui.colors.bg[600], bg = nvim.ui.colors.bg[300] },
    },
    spaces = {
      function()
        if not vim.bo.expandtab then
          return ("%s %s"):format(nvim.ui.icons.ui.Tab, vim.bo.tabstop)
        end
        local size = vim.bo.shiftwidth
        if size == 0 then
          size = vim.bo.tabstop
        end

        return ("%s %s"):format(nvim.ui.icons.ui.Space, size)
      end,
      cond = conditions.hide_in_width,
      fmt = string.upper,
      color = { fg = nvim.ui.colors.bg[600], bg = nvim.ui.colors.bg[300] },
    },
    encoding = {
      "encoding",
      fmt = string.upper,
      color = { fg = nvim.ui.colors.bg[600], bg = nvim.ui.colors.bg[300] },
      cond = conditions.hide_in_width,
    },
    scrollbar = {
      function()
        local current_line = vim.fn.line(".")
        local total_lines = vim.fn.line("$")
        local chars = { "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
        local line_ratio = current_line / total_lines
        local index = math.ceil(line_ratio * #chars)
        return chars[index]
      end,
      padding = { left = 0, right = 0 },
      color = { fg = nvim.ui.colors.yellow[300], bg = nvim.ui.colors.gray[300] },
      cond = nil,
    },
    iedit = {
      function()
        return nvim.ui.icons.ui.Pencil
      end,
      color = { fg = nvim.ui.colors.black, bg = nvim.ui.colors.orange[600] },
      cond = function()
        return is_loaded("iedit") and require("ck.plugins.iedit-nvim").is_active()
      end,
    },
    viedit = {
      function()
        return nvim.ui.icons.ui.Pencil
      end,
      color = { fg = nvim.ui.colors.black, bg = nvim.ui.colors.orange[600] },
      cond = function()
        if not is_loaded("viedit") then
          return false
        end

        local session = require("viedit.session").get(vim.api.nvim_get_current_buf())

        return type(session) == "table" and session.is_active
      end,
    },
    lazy_updates = {
      function()
        return require("lazy.status").updates()
      end,
      cond = function()
        return is_loaded("lazy") and require("lazy.status").has_updates()
      end,
      color = { fg = nvim.ui.colors.yellow[900] },
    },
    searchcount = {
      function()
        -- local searchcount = vim.fn.searchcount({ recompute = 1 })
        --
        -- if searchcount.total == 0 then
        --   return ""
        -- end

        -- return ("%s %s/%s"):format(nvim.ui.icons.ui.Search, searchcount.current, searchcount.total == 100 and "99+" or searchcount.total)
        return nvim.ui.icons.ui.Search .. " "
      end,
      cond = function()
        return conditions.hide_in_width() and vim.o.hlsearch
      end,
      color = { fg = nvim.ui.colors.white, bg = nvim.ui.colors.magenta[300] },
    },
    noice_message = {
      function()
        return require("noice").api.status.message.get_hl()
      end,
      cond = function()
        return is_loaded("noice") and require("noice").api.status.message.has()
      end,
    },
    noice_search = {
      function()
        return require("noice").api.status.search.get()
      end,
      color = { fg = nvim.ui.colors.cyan[600] },
      cond = function()
        return is_loaded("noice") and require("noice").api.status.search.has()
      end,
    },
    noice_mode = {
      function()
        return require("noice").api.status.mode.get()
      end,
      color = { fg = nvim.ui.colors.yellow[600] },
      cond = function()
        return is_loaded("noice") and require("noice").api.status.mode.has()
      end,
    },
    noice_command = {
      function()
        return require("noice").api.statusline.command.get()
      end,
      color = { fg = nvim.ui.colors.blue[600] },
      cond = function()
        return is_loaded("noice") and require("noice").api.statusline.command.has()
      end,
    },
    yazi = {
      function()
        return nvim.ui.icons.ui.FolderOpen
      end,
      color = { bg = nvim.ui.colors.yellow[600], fg = nvim.ui.colors.black },
      cond = function()
        local env = vim.env["YAZI_LEVEL"]
        return conditions.hide_in_width() and env and env ~= ""
      end,
    },
  }

  return components
end

return M
