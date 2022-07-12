local M = {}
local Log = require "lvim.core.log"

function M.config()
  lvim.builtin.nvimtree = {
    active = true,
    on_config_done = nil,
    vars = {},
    setup = {
      -- show_icons = { git = 1, folders = 1, files = 1, folder_arrows = 1, tree_width = 40 },

      -- disables netrw completely
      disable_netrw = true,
      -- hijack netrw window on startup
      hijack_netrw = true,
      -- open the tree when running this setup function
      open_on_setup = false,
      ignore_buffer_on_setup = false,
      ignore_ft_on_setup = {
        "startify",
        "dashboard",
        "alpha",
      },
      auto_reload_on_write = true,
      hijack_unnamed_buffer_when_opening = false,
      hijack_directories = {
        enable = true,
        auto_open = true,
      },
      -- update the focused file on `BufEnter`, un-collapses the folders recursively until it finds the file
      update_focused_file = {
        -- enables the feature
        enable = false,
        -- update the root directory of the tree to the one of the folder containing the file if the file is not under the current root directory
        -- only relevant when `update_focused_file.enable` is true
        update_cwd = false,
        -- list of buffer names / filetypes that will not update the cwd if the file isn't found under the current root directory
        -- only relevant when `update_focused_file.update_cwd` is true and `update_focused_file.enable` is true
        ignore_list = {},
      },
      -- configuration options for the system open command (`s` in the tree by default)
      system_open = {
        -- the command to run this, leaving nil should work in most cases
        cmd = nil,
        -- the command arguments as a list
        args = {},
      },
      diagnostics = {
        enable = true,
        show_on_dirs = true,
        icons = {
          hint = "",
          info = "",
          warning = "",
          error = "",
        },
      },
      git = {
        enable = true,
        ignore = true,
        timeout = 200,
      },
      view = {
        -- width of the window, can be either a number (columns) or a string in `%`
        width = 40,
        -- side of the tree, can be one of 'left' | 'right' | 'top' | 'bottom'
        side = "left",
        -- if true the tree will resize itself after opening a file
        number = false,
        relativenumber = false,
        mappings = {
          -- custom only false will merge the list with the default mappings
          -- if true, it will only use your list to set the mappings
          custom_only = false,
          -- list of mappings to set on the tree manually
        },
        signcolumn = "yes",
      },
      filters = {
        dotfiles = false,
        -- custom = { "node_modules", ".cache" },
      },
      trash = {
        cmd = "trash",
        require_confirm = true,
      },
      live_filter = {
        prefix = "[FILTER]: ",
        always_show_folders = false,
      },
      renderer = {
        indent_markers = {
          enable = true,
        },
        special_files = { ["package.json"] = true, ["README.md"] = true, ["node_modules"] = true },
        icons = {
          glyphs = {
            default = "",
            symlink = "",
            git = {
              unstaged = "",
              staged = "✓",
              unmerged = "",
              renamed = "➜",
              deleted = "",
              untracked = "",
              ignored = "◌",
            },
            folder = {
              arrow_open = "",
              arrow_closed = "",
              default = "",
              open = "",
              empty = "",
              empty_open = "",
              symlink = "",
              symlink_open = "",
            },
          },
        },
      },
      actions = {
        change_dir = {
          global = false,
        },
        open_file = {
          quit_on_open = false,
          resize_window = true,
          window_picker = {
            enable = false,
            chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
            exclude = {
              filetype = { "notify", "spectre_panel", "Outline", "packer", "qf", "lsp_floating_window" },
              buftype = { "terminal" },
            },
          },
        },
      },
      log = {
        enable = false,
        truncate = false,
        types = {
          all = false,
          config = false,
          copy_paste = false,
          diagnostics = false,
          git = false,
          profile = false,
        },
      },
    },
  }
end

function M.setup()
  if lvim.builtin.nvimtree._setup_called then
    Log:debug "ignoring repeated setup call for nvim-tree, see kyazdani42/nvim-tree.lua#1308"
    return
  end

  local table_utils = require "lvim.utils.table"
  for opt, val in pairs(lvim.builtin.nvimtree.vars) do
    vim.g["nvim_tree_" .. opt] = val
  end

  lvim.builtin.which_key.mappings["e"] = { "<cmd>NvimTreeToggle<CR>", "Explorer" }
  lvim.builtin.nvimtree._setup_called = true

  -- Implicitly update nvim-tree when project module is active
  if lvim.builtin.project.active then
    lvim.builtin.nvimtree.respect_buf_cwd = 0 -- this was 1 before, so if anything goes wrong lets switch it back
    lvim.builtin.nvimtree.setup.update_cwd = true
    -- lvim.builtin.nvimtree.setup.disable_netrw = false
    -- lvim.builtin.nvimtree.setup.hijack_netrw = false
    -- vim.g.netrw_banner = false
  end

  -- Add useful keymaps
  if not lvim.builtin.nvimtree.setup.view.mappings.list or #lvim.builtin.nvimtree.setup.view.mappings.list == 0 then
    lvim.builtin.nvimtree.setup.view.mappings.list = {
      -- mappings
      { key = "<CR>", action = "edit" },
      { key = "l", action = "edit" },
      { key = "o", action = "edit" },
      { key = "<2-LeftMouse>", action = "edit" },
      { key = "<2-RightMouse>", action = "cd" },
      { key = "w", action = "cd" },
      { key = "v", action = "vsplit" },
      { key = "V", action = "split" },
      { key = "<C-t>", action = "tabnew" },
      { key = "h", action = "close_node" },
      { key = "<BS>", action = "close_node" },
      { key = "<S-CR>", action = "close_node" },
      { key = "<Tab>", action = "preview" },
      { key = "I", action = "toggle_ignored" },
      { key = "H", action = "toggle_dotfiles" },
      { key = "R", action = "refresh" },
      { key = "a", action = "create" },
      { key = "d", action = "remove" },
      { key = "r", action = "rename" },
      { key = "<C-r>", action = "full_rename" },
      { key = "x", action = "cut" },
      { key = "c", action = "copy" },
      { key = "p", action = "paste" },
      { key = "[c", action = "prev_git_item" },
      { key = "]c", action = "next_git_item" },
      { key = "f", action = "live_filter" },
      { key = "F", action = "clear_live_filter" },
      { key = "W", action = "collapse_all" },
      { key = "E", action = "expand_all" },
      { key = "S", action = "search_node" },
      { key = ".", action = "run_file_command" },
      { key = "K", action = "toggle_file_info" },
      { key = "-", action = "dir_up" },
      { key = "q", action = "close" },
      { key = "gtf", cb = "<cmd>lua require'lvim.core.nvimtree'.start_telescope('find_files')<cr>" },
      { key = "gtg", cb = "<cmd>lua require'lvim.core.nvimtree'.start_telescope('live_grep')<cr>" },
    }
  end

  lvim.builtin.which_key.mappings["e"] = { "<cmd>NvimTreeToggle<CR>", "Explorer" }
  lvim.builtin.which_key.mappings[","] = { ":NvimTreeFindFile<CR>", "find file in explorer" }
  lvim.builtin.which_key.mappings["."] = { ":NvimTreeFindFile<CR>", "find file in explorer" }

  require("nvim-tree").setup(lvim.builtin.nvimtree.setup)

  if lvim.builtin.nvimtree.on_config_done then
    lvim.builtin.nvimtree.on_config_done(lvim.builtin.nvimtree)
  end
end

function M.start_telescope(telescope_mode)
  local node = require("nvim-tree.lib").get_node_at_cursor()
  local abspath = node.link_to or node.absolute_path
  local is_folder = node.open ~= nil
  local basedir = is_folder and abspath or vim.fn.fnamemodify(abspath, ":h")
  require("telescope.builtin")[telescope_mode] {
    cwd = basedir,
  }
end

return M
