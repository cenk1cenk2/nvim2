local M = {}

local utils = require("lvim.utils")
local Log = require("lvim.core.log")

M.plugins_dir = get_data_dir() .. "/lazy"
M.plugin_manager_dir = M.plugins_dir .. "/lazy.nvim"
M.plugin_manager_cache_dir = get_cache_dir() .. "/lazy"

function M.init()
  if not utils.is_directory(M.plugin_manager_dir) then
    print("Initializing first time setup...")
    print("Installing plugin manager...")

    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "--single-branch",
      "https://github.com/folke/lazy.nvim.git",
      M.plugin_manager_dir,
    })
  end

  vim.opt.runtimepath:prepend(M.plugin_manager_dir)

  local lazy_cache = require("lazy.core.cache")

  ---@diagnostic disable-next-line: redundant-parameter
  lazy_cache.setup({
    performance = {
      cache = {
        enabled = true,
        path = M.plugin_manager_cache_dir,
      },
    },
  })
  -- HACK: Don't allow lazy to call setup second time
  lazy_cache.setup = function() end
end

function M.load()
  Log:debug("Loading plugins configurations...")

  local manager_ok, manager = pcall(require, "lazy")

  if not manager_ok then
    Log:warn("Skipping loading plugins until plugin manager is installed.")

    return
  end

  local lazy_setup = {
    root = M.plugins_dir, -- directory where plugins will be installed
    defaults = {
      lazy = true, -- should plugins be lazy-loaded?
    },
    lockfile = get_state_dir() .. "/lazy-lock.json", -- lockfile generated after running update.
    ui = {
      -- a number <1 is a percentage., >1 is a fixed size
      size = { width = 0.8, height = 0.8 },
      -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
      border = "single",
    },
    install = {
      -- install missing plugins on startup. This doesn't increase startup time.
      missing = true,
      -- try to load one of these colorscheme when starting an installation during startup
      colorscheme = { lvim.colorscheme, "habamax" },
    },
    checker = {
      -- automatically check for plugin updates
      enabled = true,
      concurrency = nil, ---@type number? set to 1 to check for updates very slowly
      notify = false, -- get a notification when new updates are found
      frequency = 3600, -- check for updates every hour
    },
    change_detection = {
      -- automatically check for config file changes and reload the ui
      enabled = true,
      notify = true, -- get a notification when changes are found
    },
    performance = {
      cache = {
        enabled = true,
        path = M.plugin_manager_cache_dir,
        -- Once one of the following events triggers, caching will be disabled.
        -- To cache all modules, set this to `{}`, but that is not recommended.
        -- The default is to disable on:
        --  * VimEnter: not useful to cache anything else beyond startup
        --  * BufReadPre: this will be triggered early when opening a file from the command line directly
        disable_events = { "VimEnter", "BufReadPre" },
      },
      reset_packpath = true,
      rtp = {
        reset = true,
        ---@type string[] list any plugins you want to disable here
        disabled_plugins = {
          "gzip",
          "matchit",
          "matchparen",
          "netrwPlugin",
          "tarPlugin",
          "tohtml",
          "tutor",
          "zipPlugin",
        },
      },
    },
    readme = {
      root = get_state_dir() .. "/lazy/readme",
      files = { "README.md" },
      skip_if_doc_exists = true,
    },
  }

  local status_ok, _ = xpcall(function()
    require("utils.setup").set_plugins()

    manager.setup(lvim.plugins, lazy_setup)
  end, debug.traceback)

  if not status_ok then
    Log:warn("Can not load plugin configurations.")
    Log:trace(debug.traceback())
  end

  require("lvim.utils.hooks").on_plugin_manager_complete()
end

function M.reset_cache()
  os.remove(require("lazy.core.cache").config.path)
end

function M.reload(spec)
  local Config = require("lazy.core.config")
  local lazy = require("lazy")

  -- TODO: reset cache? and unload plugins?

  Config.spec = spec

  require("lazy.core.plugin").load(true)
  require("lazy.core.plugin").update_state()

  local not_installed_plugins = vim.tbl_filter(function(plugin)
    return not plugin._.installed
  end, Config.plugins)

  require("lazy.manage").clear()

  if #not_installed_plugins > 0 then
    lazy.install({ wait = true })
  end

  if #Config.to_clean > 0 then
    -- TODO: set show to true when lazy shows something useful on clean
    lazy.clean({ wait = true, show = false })
  end
end

return M
