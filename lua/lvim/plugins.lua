local commit = {
  bufferline = "e97a404bd7449ecebab243c796c1016c98397fc0",
  cmp_buffer = "f83773e2f433a923997c5faad7ea689ec24d1785",
  cmp_luasnip = "d6f837f4e8fe48eeae288e638691b91b97d1737f",
  cmp_nvim_lsp = "ebdfc204afb87f15ce3d3d3f5df0b8181443b5ba",
  cmp_path = "466b6b8270f7ba89abd59f402c73f63c7331ff6e",
  comment = "18a8dc0bbdfc089d5f5a850e4640d8e75381c598",
  dapinstall = "24923c3819a450a772bb8f675926d530e829665f",
  dashboard_nvim = "d82ddae95fd4dc4c3b7bbe87f09b1840fbf20ecb",
  fixcursorhold = "1bfb32e7ba1344925ad815cb0d7f901dbc0ff7c1",
  friendly_snippets = "2e575549910571ff5abb6b02178c69ad760a4e00",
  gitsigns = "1d1f043acf025f919b8dd12bb672569109c7f099",
  lua_dev = "a0ee77789d9948adce64d98700cc90cecaef88d5",
  lualine = "40849728b6c9b3389c7b54739f426f9899b53778",
  luasnip = "c1d07078dce0c9631e89a299e4b4a93334650a7b",
  nlsp_settings = "80cb4d3051366afb019ddabe619b6eb967c82f63",
  null_ls = "3059dc761b27c4c836f88879c460cd7a989caa47",
  nvim_autopairs = "784398a8f184431fd4329f20b0e4f52e87707bbd",
  nvim_cmp = "13d64460cba64950aff41e230cc801225bd9a3e2",
  nvim_dap = "9fcff6e02e1a549d47a2c559a4b833798537c0bc",
  nvim_lsp_installer = "c95ffd31428da0abaffa2459c0231fa9971fcbaa",
  nvim_lspconfig = "19a21d5a8681f721c584125a920d4cbeda1c80cc",
  nvim_notify = "8038d04d5371e49cf15728ae98cc6bff655b923b",
  nvim_tree = "2e1f82d8c0c57cbc2bfdc041a3aff26947559a1e",
  nvim_treesitter = "2298a7584414af40a6a09cbe72a81175382992c7",
  nvim_ts_context_commentstring = "097df33c9ef5bbd3828105e4bee99965b758dc3f",
  nvim_web_devicons = "e3294f687626b40754bb40ac2d636d166098b2fb",
  packer = "963cb58c3dd15699c801baf3e64393c6795b62e9",
  plenary = "66472128c3191b786966798fc956a689705ab1be",
  popup = "b7404d35d5d3548a82149238289fa71f7f6de4ac",
  project = "cef52b8da07648b750d7f1e8fb93f12cb9482988",
  schemastore = "c0c11c832fa812174cd196c723b97c493f528b5c",
  structlog = "6f1403a192791ff1fa7ac845a73de9e860f781f1",
  telescope = "df0b35c8bc0944164828ccba8ea17941423c6725",
  telescope_fzf_native = "b8662b076175e75e6497c59f3e2799b879d7b954",
  toggleterm = "f9845199f1d647890ca47f6185f7ac935991b442",
  which_key = "28d2bd129575b5e9ebddd88506601290bb2bb221",
}

return {
  -- Packer can manage itself as an optional plugin
  { "wbthomason/packer.nvim" },

  { "nvim-lua/plenary.nvim" },

  { "neovim/nvim-lspconfig" },
  { "tamago324/nlsp-settings.nvim" },
  {
    "jose-elias-alvarez/null-ls.nvim",
  },
  {
    "jose-elias-alvarez/nvim-lsp-ts-utils",
  },
  {
    "williamboman/nvim-lsp-installer",
  },

  {
    "rcarriga/nvim-notify",
    disable = not lvim.builtin.notify.active,
    config = function()
      require("lvim.core.notify").setup()
    end,
    event = "BufRead",
  },
  { "nvim-lua/popup.nvim" },

  { "Tastyep/structlog.nvim" },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    config = function()
      require("lvim.core.telescope").setup()
    end,
    disable = not lvim.builtin.telescope.active,
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    run = "make",
    disable = not lvim.builtin.telescope.active,
    requires = "nvim-telescope/telescope.nvim",
  },
  { "tzachar/fuzzy.nvim", requires = { "nvim-telescope/telescope-fzf-native.nvim" } },

  {
    "folke/todo-comments.nvim",
    config = function()
      require("extensions.todo-comments").setup()
    end,
    disable = not lvim.extensions.todo_comments.active,
  },
  {
    "nvim-telescope/telescope-github.nvim",
    requires = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension "gh"
    end,
    disable = not lvim.builtin.telescope.active,
  },
  {
    "tom-anders/telescope-vim-bookmarks.nvim",
    requires = { "nvim-telescope/telescope.nvim" },
    config = function()
      local telescope = require "telescope"
      telescope.load_extension "vim_bookmarks"

      local bookmark_actions = telescope.extensions.vim_bookmarks.actions
      telescope.extensions.vim_bookmarks.all {
        attach_mappings = function(_, map)
          map("n", "dd", bookmark_actions.delete_selected_or_at_cursor)
          map("n", "D", bookmark_actions.delete_all)

          return true
        end,
      }

      telescope.extensions.vim_bookmarks.current_file {
        attach_mappings = function(_, map)
          map("n", "dd", bookmark_actions.delete_selected_or_at_cursor)
          map("n", "D", bookmark_actions.delete_all)

          return true
        end,
      }
    end,
    disable = not lvim.builtin.telescope.active,
  },
  {
    "AckslD/nvim-neoclip.lua",
    requires = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("extensions.nvim-neoclip").setup()
    end,
    disable = not lvim.builtin.telescope.active,
  },

  -- Install nvim-cmp, and buffer source as a dependency
  {
    "hrsh7th/nvim-cmp",
    config = function()
      require("lvim.core.cmp").setup()
      require("extensions.cmp-extensions").setup()
    end,
    requires = {
      {
        "rafamadriz/friendly-snippets",
      },
      {
        "L3MON4D3/LuaSnip",
        config = function()
          require("luasnip/loaders/from_vscode").lazy_load()
        end,
      },
      {
        "saadparwaiz1/cmp_luasnip",
      },
      {
        "hrsh7th/cmp-buffer",
      },
      {
        "hrsh7th/cmp-nvim-lsp",
      },
      {
        "hrsh7th/cmp-path",
      },
      {
        "hrsh7th/cmp-nvim-lua",
      },

      "hrsh7th/cmp-vsnip",

      "petertriho/cmp-git",

      "David-Kunz/cmp-npm",

      "hrsh7th/cmp-cmdline",

      "davidsierradz/cmp-conventionalcommits",

      "tzachar/cmp-fuzzy-buffer",

      "lukas-reineke/cmp-rg",

      -- { "tzachar/cmp-tabnine", run = "./install.sh" },
    },
    run = function()
      -- cmp's config requires cmp to be installed to run the first time
      if lvim.builtin.cmp then
        require("lvim.core.cmp").setup()
      end
    end,
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    -- event = "InsertEnter",
    after = "nvim-cmp",
    config = function()
      require("lvim.core.autopairs").setup()
    end,
    disable = not lvim.builtin.autopairs.active,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    branch = vim.fn.has "nvim-0.6" == 1 and "master" or "0.5-compat",
    -- run = ":TSUpdate",
    config = function()
      require("lvim.core.treesitter").setup()
    end,
  },

  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    event = "BufReadPost",
    requires = { "nvim-treesitter/nvim-treesitter" },
  },

  { "nvim-treesitter/playground", requires = { "nvim-treesitter/nvim-treesitter" } },
  { "p00f/nvim-ts-rainbow", run = ":TSUpdate", requires = { "nvim-treesitter/nvim-treesitter" } },
  { "windwp/nvim-ts-autotag", requires = { "nvim-treesitter/nvim-treesitter" } },

  -- NvimTree
  {
    "kyazdani42/nvim-tree.lua",
    -- event = "BufWinOpen",
    -- cmd = "NvimTreeToggle",
    commit = commit.nvim_tree,
    config = function()
      require("lvim.core.nvimtree").setup()
    end,
    disable = not lvim.builtin.nvimtree.active,
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    config = function()
      require("extensions.neotree-nvim").setup()
    end,
    disable = not lvim.extensions.neotree_nvim.active,
    requires = {
      "nvim-lua/plenary.nvim",
      "kyazdani42/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
  },

  {
    "lewis6991/gitsigns.nvim",

    config = function()
      require("lvim.core.gitsigns").setup()
    end,
    event = "BufRead",
    disable = not lvim.builtin.gitsigns.active,
  },

  -- Whichkey
  {
    "folke/which-key.nvim",
    config = function()
      require("lvim.core.which-key").setup()
    end,
    disable = not lvim.builtin.which_key.active,
  },

  -- Comments
  {
    "numToStr/Comment.nvim",
    event = "BufRead",
    config = function()
      require("lvim.core.comment").setup()
    end,
    disable = not lvim.builtin.comment.active,
  },

  -- project.nvim
  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("lvim.core.project").setup()
    end,
    disable = not lvim.builtin.project.active,
  },

  -- Icons
  { "kyazdani42/nvim-web-devicons" },

  -- Status Line and Bufferline
  {
    -- "hoob3rt/lualine.nvim",
    "nvim-lualine/lualine.nvim",
    -- "Lunarvim/lualine.nvim",
    config = function()
      require("lvim.core.lualine").setup()
    end,
    disable = not lvim.builtin.lualine.active,
  },

  {
    "romgrk/barbar.nvim",
    config = function()
      require("lvim.core.bufferline").setup()
    end,
    event = "BufWinEnter",
    disable = not lvim.builtin.bufferline.active,
  },

  -- Debugging
  {
    "mfussenegger/nvim-dap",
    -- event = "BufWinEnter",
    config = function()
      require("lvim.core.dap").setup()
    end,
    disable = not lvim.builtin.dap.active,
  },

  -- Debugger management
  {
    "Pocco81/DAPInstall.nvim",
    -- event = "BufWinEnter",
    -- event = "BufRead",
    disable = not lvim.builtin.dap.active,
  },

  { "rcarriga/nvim-dap-ui", disable = not lvim.builtin.dap.active, requires = { "mfussenegger/nvim-dap" } },

  -- Dashboard
  {
    "goolord/alpha-nvim",
    event = "BufWinEnter",
    config = function()
      require("extensions.alpha-nvim").setup()
    end,
    disable = not lvim.extensions.alpha.active,
  },

  -- Session Manager
  {
    "Shatur/neovim-session-manager",
    config = function()
      require("extensions.neovim-session-manager").setup()
    end,
    disable = not lvim.extensions.session_manager.active,
  },

  -- Terminal
  {
    "akinsho/toggleterm.nvim",
    event = "BufWinEnter",
    config = function()
      require("lvim.core.terminal").setup()
    end,
    disable = not lvim.builtin.terminal.active,
  },

  -- hop
  {
    "phaazon/hop.nvim",
    config = function()
      require("extensions.hop").setup()
    end,
    disable = not lvim.extensions.hop.active,
  },

  -- Repeat last commands
  {
    "tpope/vim-repeat",
    config = function()
      require("extensions.vim-repeat").setup()
    end,
    disable = not lvim.extensions.vim_repeat.active,
  },

  -- surround, change surround
  {
    "tpope/vim-surround",
    config = function()
      require("extensions.vim-surround").setup()
    end,
    disable = not lvim.extensions.vim_surround.active,
  },

  -- search highlighting
  {
    "kevinhwang91/nvim-hlslens",
    config = function()
      require("extensions.nvim-hlslens").setup()
    end,
    disable = not lvim.extensions.nvim_hlslens.active,
  },

  -- scrollbar
  {
    "petertriho/nvim-scrollbar",
    config = function()
      require("extensions.nvim-scrollbar").setup()
    end,
    disable = not lvim.extensions.nvim_scrollbar.active,
  },

  -- smooth scroll
  {
    "karb94/neoscroll.nvim",
    event = "BufWinEnter",
    config = function()
      require("extensions.neoscroll").setup()
    end,
    disable = not lvim.extensions.neoscroll.active,
  },

  -- find and replace
  {
    "cenk1cenk2/nvim-spectre",
    config = function()
      require("extensions.spectre").setup()
    end,
    disable = not lvim.extensions.spectre.active,
  },

  -- multiple cursors
  {
    "mg979/vim-visual-multi",
    config = function()
      require("extensions.vim-visual-multi").setup()
    end,
    disable = not lvim.extensions.vim_visual_multi.active,
  },

  -- ranger
  {
    "kevinhwang91/rnvimr",
    config = function()
      require("extensions.rnvimr").setup()
    end,
    disable = not lvim.extensions.rnvimr.active,
  },

  -- maximize windows temporararily
  {
    "szw/vim-maximizer",
    config = function()
      require("extensions.vim-maximizer").setup()
    end,
    disable = not lvim.extensions.vim_maximizer.active,
  },

  -- move windows with keybinds
  {
    "wesQ3/vim-windowswap",
    config = function()
      require("extensions.vim-windowswap").setup()
    end,
    disable = not lvim.extensions.vim_windowswap.active,
  },

  -- whitespace control
  {
    "ntpeters/vim-better-whitespace",
    config = function()
      require("extensions.vim-better-whitespace").setup()
    end,
    disable = not lvim.extensions.vim_better_whitespace.active,
  },

  -- undo-tree
  {
    "mbbill/undotree",
    config = function()
      require("extensions.undotree").setup()
    end,
    disable = not lvim.extensions.undotree.active,
  },

  -- better quick fix window
  {
    "kevinhwang91/nvim-bqf",
    config = function()
      require("extensions.nvim-bqf").setup()
    end,
    disable = not lvim.extensions.nvim_bqf.active,
  },

  -- lsp extensions
  {
    "folke/lsp-trouble.nvim",
    config = function()
      require("extensions.lsp-trouble").setup()
    end,
    disable = not lvim.extensions.lsp_trouble.active,
  },

  {
    "simrat39/symbols-outline.nvim",
    config = function()
      require("extensions.symbols-outline").setup()
    end,
    disable = not lvim.extensions.symbols_outline.active,
  },

  -- lsp loader information
  {
    "j-hui/fidget.nvim",
    config = function()
      require("extensions.fidget-nvim").setup()
    end,
    disable = not lvim.extensions.fidget_nvim.active,
  },

  -- Colorized
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("extensions.colorizer").setup()
    end,
    disable = not lvim.extensions.colorizer.active,
  },

  -- tab markers
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("extensions.indent-blankline").setup()
    end,
    disable = not lvim.extensions.indent_blankline.active,
  },

  -- git related
  {
    "tpope/vim-fugitive",
    config = function()
      require("extensions.vim-fugitive").setup()
    end,
    disable = not lvim.extensions.vim_fugitive.active,
  },

  {
    "pwntester/octo.nvim",
    config = function()
      require("extensions.octo").setup()
    end,
    disable = not lvim.extensions.octo.active,
  },

  {
    "sindrets/diffview.nvim",
    config = function()
      require("extensions.diffview").setup()
    end,
    disable = not lvim.extensions.diffview.active,
  },

  -- coc
  {
    "neoclide/coc.nvim",
    branch = "release",
    config = function()
      require("extensions.coc").setup()
    end,
    disable = not lvim.extensions.coc.active,
  },

  -- easy align
  {
    "junegunn/vim-easy-align",
    config = function()
      require("extensions.vim-easy-align").setup()
    end,
    disable = not lvim.extensions.vim_easy_align.active,
  },

  -- markdown preview
  {
    "iamcco/markdown-preview.nvim",
    run = { "cd app & yarn & yarn add -D tslib", ":call mkdp#util#install()" },
    config = function()
      require("extensions.markdown-preview").setup()
    end,
    disable = not lvim.extensions.markdown_preview.active,
  },

  {
    "MattesGroeger/vim-bookmarks",
    branch = "fix/118",
    config = function()
      require("extensions.vim-bookmarks").setup()
    end,
    disable = not lvim.extensions.vim_bookmarks.active,
  },

  {
    "vuki656/package-info.nvim",
    requires = "MunifTanjim/nui.nvim",
    config = function()
      require("extensions.package-info").setup()
    end,
    disable = not lvim.extensions.package_info.active,
  },

  {
    "danymat/neogen",
    config = function()
      require("extensions.neogen").setup()
    end,
    requires = { "nvim-treesitter/nvim-treesitter" },
    disable = not lvim.extensions.neogen.active,
  },

  {
    "chipsenkbeil/distant.nvim",
    config = function()
      require("extensions.distant").setup()
    end,
    disable = not lvim.extensions.distant.active,
  },

  {
    "lepture/vim-jinja",
    config = function()
      require("extensions.vim-jinja").setup()
    end,
    disable = not lvim.extensions.vim_jinja.active,
  },

  {
    "stevearc/dressing.nvim",
    config = function()
      require("extensions.dressing").setup()
    end,
    disable = not lvim.extensions.dressing.active,
  },

  {
    "arthurxavierx/vim-caser",
    config = function()
      require("extensions.vim-caser").setup()
    end,
    disable = not lvim.extensions.vim_caser.active,
  },

  {
    "nvim-orgmode/orgmode",
    config = function()
      require("extensions.nvim-orgmode").setup()
    end,
    disable = not lvim.extensions.orgmode.active,
  },

  {
    "ripxorip/aerojump.nvim",
    config = function()
      require("extensions.aerojump-nvim").setup()
    end,
    disable = not lvim.extensions.aerojump_nvim.active,
    run = ":UpdateRemotePlugins",
  },

  {
    "inkarkat/vim-UnconditionalPaste",
    config = function()
      require("extensions.vim-unconditionalpaste").setup()
    end,
    disable = not lvim.extensions.vim_unconditionalpaste.active,
  },

  {
    "tpope/vim-unimpaired",
    config = function()
      require("extensions.vim-unimpaired").setup()
    end,
    disable = not lvim.extensions.vim_unimpaired.active,

    -- SchemaStore
    {
      "b0o/schemastore.nvim",
    },
  },

  {
    "ThePrimeagen/refactoring.nvim",
    requires = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-treesitter/nvim-treesitter" },
    },
    config = function()
      require("extensions.refactoring-nvim").setup()
    end,
    disable = not lvim.extensions.refactoring_nvim.active,
  },
}
