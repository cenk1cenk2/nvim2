-- https://github.com/glepnir/lspsaga.nvim
local M = {}

local extension_name = "lspsaga_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "glepnir/lspsaga.nvim",
        config = function()
          require("utils.setup").packer_config "lspsaga_nvim"
        end,
        disable = not config.active,
      }
    end,
    setup = {
      -- Error,Warn,Info,Hint
      diagnostic_header = { " ", " ", " ", "ﴞ " },
      -- show diagnostic source
      show_diagnostic_source = true,
      -- add bracket or something with diagnostic source,just have 2 elements
      diagnostic_source_bracket = { "[", "]" },
      -- use emoji lightbulb in default
      code_action_icon = "💡",
      -- if true can press number to execute the codeaction in codeaction window
      code_action_num_shortcut = true,
      -- same as nvim-lightbulb but async
      code_action_lightbulb = {
        enable = true,
        enable_in_insert = false,
        cache_code_action = true,
        sign = true,
        update_time = 150,
        sign_priority = 20,
        virtual_text = false,
      },
      -- preview lines of lsp_finder and definition preview
      max_preview_lines = 10,
      finder_action_keys = {
        open = "<CR>",
        vsplit = "s",
        split = "h",
        quit = "q",
        scroll_down = "<C-f>",
        scroll_up = "<C-b>", -- quit can be a table
      },
      code_action_keys = {
        quit = "<C-c>",
        exec = "<CR>",
      },
      -- show symbols in winbar must nightly
      symbol_in_winbar = {
        in_custom = false,
        enable = false,
        separator = " ",
        show_file = true,
        click_support = false,
      },
      rename_action_quit = "<C-c>",
      -- "single" "double" "rounded" "bold" "plus"
      border_style = "single",
      --the range of 0 for fully opaque window (disabled) to 100 for fully
      --transparent background. Values between 0-30 are typically most useful.
      saga_winblend = 0,
      -- when cursor in saga window you config these to move
      move_in_saga = { prev = "<C-p>", next = "<C-n>" },
      -- if you don't use nvim-lspconfig you must pass your server name and
      -- the related filetypes into this table
      -- like server_filetype_map = {metals = {'sbt', 'scala'}}
      server_filetype_map = {},
      -- show outline
      show_outline = {
        win_position = "right",
        -- set the special filetype in there which in left like nvimtree neotree defx
        left_with = "",
        win_width = 50,
        auto_enter = true,
        auto_preview = true,
        virt_text = "┃",
        jump_key = "<CR>",
        -- auto refresh when change buffer
        auto_refresh = true,
      },
    },
    on_setup = function(config)
      require("lspsaga").init_lsp_saga(config.setup)
    end,
    keymaps = {
      n = {
        ["ge"] = { ":Lspsaga lsp_finder<CR>", { desc = "Finder" } },
      },
    },
    wk = {
      ["l"] = {
        ["o"] = { ":LSoutlineToggle<CR>", "file outline" },
      },
    },
  })
end

return M
