-- https://github.com/jedrzejboczar/possession.nvim
local M = {}

M.name = "jedrzejboczar/possession.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "jedrzejboczar/possession.nvim",
        cmd = {
          "PossessionSave",
          "PossessionLoad",
          "PossessionRename",
          "PossessionClose",
          "PossessionDelete",
          "PossessionShow",
          "PossessionList",
          "PossessionMigrate",
        },
      }
    end,
    setup = function()
      return {
        session_dir = join_paths(get_data_dir(), "sessions"),
        silent = true,
        load_silent = true,
        debug = false,
        logfile = false,
        prompt_no_cr = false,
        autosave = {
          current = true, -- or fun(name): boolean
          tmp = true, -- or fun(): boolean
          tmp_name = "tmp", -- or fun(): string
          on_load = true,
          on_quit = true,
        },
        autoload = false,
        hooks = {
          before_save = function(name)
            local res = {}

            return res
          end,
          after_save = function(name, user_data, aborted) end,
          before_load = function(name, user_data)
            return user_data
          end,
          after_load = function(name, user_data) end,
        },
        plugins = {
          close_windows = {
            hooks = { "before_save", "before_load" },
            preserve_layout = false, -- or fun(win): boolean
            match = {
              floating = true,
              buftype = nvim.disabled_buffer_types,
              filetype = nvim.disabled_filetypes,
              custom = false, -- or fun(win): boolean
            },
          },
          delete_hidden_buffers = {
            hooks = {
              "before_load",
              not vim.o.sessionoptions:match("buffer") and "before_save",
            },
            force = false, -- or fun(buf): boolean
          },
          nvim_tree = true,
          neo_tree = true,
          symbols_outline = true,
          tabby = true,
          dap = true,
          dapui = true,
          neotest = true,
          delete_buffers = false,
        },
        telescope = {
          list = {
            default_action = "load",
            mappings = {
              save = { n = "<c-s>", i = "<c-s>" },
              load = { n = "<c-l>", i = "<c-l>" },
              delete = { n = "<c-d>", i = "<c-d>" },
              rename = { n = "<c-r>", i = "<c-r>" },
            },
          },
        },
      }
    end,
    on_setup = function(c)
      require("possession").setup(c)
    end,
    on_done = function()
      require("telescope").load_extension("possession")
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.SESSION, "d" }),
          function()
            require("possession.session").delete(require("possession.paths").cwd_session_name())
          end,
          desc = "delete sessions",
        },
        {
          fn.wk_keystroke({ categories.SESSION, "l" }),
          function()
            require("possession.session").load(require("possession.paths").cwd_session_name())
          end,
          desc = "load cwd last session",
        },
        {
          fn.wk_keystroke({ categories.SESSION, "s" }),
          function()
            require("possession.session").save(require("possession.paths").cwd_session_name(), { no_confirm = true })
          end,
          desc = "save session",
        },
        {
          fn.wk_keystroke({ categories.SESSION, "f" }),
          function()
            require("telescope").extensions.possession.list(require("telescope.themes").get_dropdown({}))
          end,
          desc = "list sessions",
        },
      }
    end,
  })
end

M.get_setup = require("ck.setup").fn.get_setup_wrapper(M.name)

return M
