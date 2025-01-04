-- https://github.com/Saghen/blink.cmp
local M = {}

M.name = "Saghen/blink.cmp"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "Saghen/blink.cmp",
        event = { "InsertEnter", "CmdlineEnter" },
        dependencies = {
          { "mikavilpas/blink-ripgrep.nvim" },
          { "rafamadriz/friendly-snippets" },
          { "L3MON4D3/LuaSnip" },
          { "saghen/blink.compat" },
          -- https://github.com/tzachar/cmp-fuzzy-buffer
          { "tzachar/cmp-fuzzy-buffer" },
          {
            "cenk1cenk2/cmp-zsh",
            config = function()
              require("cmp_zsh").setup({
                zshrc = true,
                filetypes = { "zsh", "bash", "sh" },
                env = {
                  ZNAP_HEADLESS = "1",
                },
              })
            end,
          },
        },
      }
    end,
    setup = function(config)
      return {
        sources = M.sources,
        completion = {
          menu = {
            border = nvim.ui.border,
            min_width = 80,
            max_height = 10,
            draw = {
              treesitter = { "lsp", "buffer" },
            },
          },
          documentation = {
            window = { border = nvim.ui.border },
            auto_show = true,
          },
        },
        signature = {
          enabled = true,
          window = { border = nvim.ui.border },
        },
        snippets = {
          expand = function(snippet)
            require("luasnip").lsp_expand(snippet)
          end,
          active = function(filter)
            if filter and filter.direction then
              return require("luasnip").jumpable(filter.direction)
            end

            return require("luasnip").in_snippet()
          end,
          jump = function(direction)
            require("luasnip").jump(direction)
          end,
        },
        appearance = {
          kind_icons = nvim.ui.icons.kind,
        },
        keymap = {
          ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
          ["<CR>"] = { "accept", "fallback" },
          ["<C-e>"] = { "hide", "fallback" },

          ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
          ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },

          ["<Up>"] = { "select_prev", "fallback" },
          ["<Down>"] = { "select_next", "fallback" },
          ["<C-p>"] = { "select_prev", "fallback" },
          ["<C-n>"] = { "select_next", "fallback" },

          ["<C-b>"] = { "scroll_documentation_up", "fallback" },
          ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        },
      }
    end,
    on_setup = function(c, config)
      require("blink-cmp").setup(c)
    end,
    on_done = function(c, config)
      -- setup lua snip
      local paths = {}

      table.insert(paths, join_paths(require("ck.loader").plugins_dir, "friendly-snippets"))

      local user_snippets = join_paths(get_config_dir(), "snippets")
      if is_directory(user_snippets) then
        table.insert(paths, user_snippets)
      end

      require("luasnip.loaders.from_lua").lazy_load({ paths = paths })
      require("luasnip.loaders.from_vscode").lazy_load({ paths = paths })
      require("luasnip.loaders.from_snipmate").lazy_load()
    end,
  })
end

--- @type blink.cmp.SourceConfig
M.sources = {
  default = function(ctx)
    return {
      "lsp",
      "lazydev",
      "luasnip",
      "snippets",
      "path",
      "buffer",
      "ripgrep",
    }
  end,
  per_filetype = {},
  cmdline = function()
    local type = vim.fn.getcmdtype()

    if type == "/" or type == "?" then
      return {
        "fuzzy_buffer",
      }
    elseif type == ":" or type == "@" then
      return {
        "zsh",
        "cmdline",
      }
    end

    return {}
  end,
  providers = {
    lazydev = {
      name = "LazyDev",
      module = "lazydev.integrations.blink",
      score_offset = 100,
    },
    ripgrep = {
      module = "blink-ripgrep",
      name = "Ripgrep",
    },
    zsh = {
      module = "blink.compat.source",
      name = "zsh",
    },
    fuzzy_buffer = {
      module = "blink.compat.source",
      name = "fuzzy_buffer",
    },
  },
}

return M
