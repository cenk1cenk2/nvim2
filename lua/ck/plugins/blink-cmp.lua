-- https://github.com/Saghen/blink.cmp
local M = {}

M.name = "Saghen/blink.cmp"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "Saghen/blink.cmp",
        version = "*",
        event = { "InsertEnter", "CmdlineEnter" },
        dependencies = {
          -- https://github.com/mikavilpas/blink-ripgrep.nvim
          { "mikavilpas/blink-ripgrep.nvim" },
          -- https://github.com/rafamadriz/friendly-snippets
          { "rafamadriz/friendly-snippets" },
          -- https://github.com/L3MON4D3/LuaSnip
          { "L3MON4D3/LuaSnip" },
          -- https://github.com/saghen/blink.compat
          {
            "saghen/blink.compat",
            config = function()
              require("blink.compat").setup({
                impersonate_nvim_cmp = false,
              })
            end,
          },
          -- https://github.com/tzachar/cmp-fuzzy-buffer
          {
            "cenk1cenk2/cmp-fuzzy-buffer",
            branch = "patch-1",
          },
          -- https://github.com/cenk1cenk2/cmp-zsh
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
          -- https://github.com/petertriho/cmp-git
          {
            "petertriho/cmp-git",
            config = function()
              require("cmp_git").setup({
                filetypes = { "gitcommit" },
                remotes = { "upstream", "origin" },
                gitlab = {
                  hosts = {
                    "gitlab.kilic.dev",
                    "gitlab.common.riag.digital",
                  },
                },
              })
            end,
          },
          -- https://github.com/David-Kunz/cmp-npm
          {
            "David-Kunz/cmp-npm",
            config = function()
              require("cmp-npm").setup({
                filetypes = { "json" },
              })
            end,
          },
          -- https://github.com/Snikimonkd/cmp-go-pkgs
          {
            -- "Snikimonkd/cmp-go-pkgs",
            "cenk1cenk2/cmp-go-pkgs",
            branch = "patch-1",
          },
          -- https://github.com/wookayin/cmp-omni
          {
            "wookayin/cmp-omni",
            branch = "fix-return",
          },
        },
      }
    end,
    setup = function(config)
      ---@type blink.cmp.Config
      return {
        sources = {
          default = function(ctx)
            return {
              "lsp",
              "lazydev",
              "zsh",
              "npm",
              "git",
              "go_pkgs",
              "luasnip",
              -- "snippets",
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
              opts = {
                prefix_min_len = 3,
              },
            },
            zsh = {
              module = "blink.compat.source",
              name = "zsh",
              async = true,
            },
            git = {
              module = "blink.compat.source",
              name = "git",
              async = true,
            },
            npm = {
              module = "blink.compat.source",
              name = "npm",
              async = true,
            },
            go_pkgs = {
              module = "blink.compat.source",
              async = true,
              name = "go_pkgs",
            },
            omni = {
              module = "blink.compat.source",
              name = "omni",
              opts = { disable_omnifuncs = { "v:lua.vim.lsp.omnifunc", "sqlcomplete#Complete" } },
              async = true,
            },
            fuzzy_buffer = {
              module = "blink.compat.source",
              async = true,
              name = "fuzzy_buffer",
            },
          },
        },
        completion = {
          accept = {
            create_undo_point = true,
            auto_brackets = {
              enabled = true,
            },
          },
          list = {
            selection = "auto_insert",
          },
          menu = {
            border = nvim.ui.border,
            min_width = 40,
            max_height = 10,
            draw = {
              components = {
                ["label"] = {
                  width = {
                    fill = true,
                  },
                },
              },
              treesitter = { "lsp", "buffer" },
              columns = {
                { "kind_icon", gap = 1 },
                { "label", "label_description", gap = 1 },
                { "kind", "source_name", gap = 1 },
              },
            },
          },
          documentation = {
            window = { border = nvim.ui.border },
            auto_show = true,
          },
        },
        signature = {
          enabled = false,
          window = {
            border = nvim.ui.border,
            max_height = 15,
            min_width = 40,
            treesitter_highlighting = true,
          },
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
          ["<C-e>"] = { "cancel", "hide", "fallback" },

          ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
          ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },

          ["<Up>"] = { "select_prev", "fallback" },
          ["<Down>"] = { "select_next", "fallback" },
          ["<C-k>"] = { "select_prev", "fallback" },
          ["<C-j>"] = { "select_next", "fallback" },

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

return M
