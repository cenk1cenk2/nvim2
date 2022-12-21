local Log = require "lvim.core.log"
local M = { fn = {} }

local keymappings = require "lvim.keymappings"
local keys_which_key = require "keys.which-key"

---
---@param mappings table
function M.load_wk_mappings(mappings, mode)
  local current
  if mode == "v" then
    current = lvim.wk.vmappings
  else
    current = lvim.wk.mappings
  end

  for key, value in pairs(mappings) do
    current[key] = vim.tbl_deep_extend("force", current[key] or {}, value)
  end
end

---
---@param mappings table
function M.load_mappings(mappings)
  keymappings.load(mappings)
end

---
---@param opts table
function M.legacy_setup(opts)
  for opt, val in pairs(opts) do
    vim.g[opt] = val
  end
end

---@alias fn { add_disabled_filetypes: (fun(ft: table<string>): nil), extension_get_active: (fun(extension: string): boolean), get_current_setup: (fun(extension: string): (fun(): table)), fetch_current_setup: (fun(extension:string): table) }
---@alias config table

---
---@param extension_name string
---@param active boolean
---@param config config
function M.define_extension(extension_name, active, config)
  vim.validate {
    active = { active, "b" },
    extension_name = { extension_name, "s" },
    config = { config, "t" },
    on_init = { config.on_init, "f", true },
    condition = { config.condition, "f", true },
    plugin = { config.plugin, "f", true },
    to_inject = { config.to_inject, "f", true },
    autocmds = { config.autocmds, { "t", "f" }, true },
    keymaps = { config.keymaps, { "t", "f" }, true },
    wk = { config.wk, { "t", "f" }, true },
    wk_v = { config.wk_v, { "t", "f" }, true },
    legacy_setup = { config.legacy_setup, "t", true },
    setup = { config.legacy_setup, { "t", "f" }, true },
    on_setup = { config.on_setup, "f", true },
    hl = { config.hl, { "f", "t" }, true },
    signs = { config.signs, { "f", "t" }, true },
    on_complete = { config.on_complete, "f", true },
  }

  lvim.extensions[extension_name] = {
    name = extension_name,
    active = active,
    inject = {},
    store = {},
    to_setup = {},
    set_injected = function(key, value)
      lvim.extensions[extension_name].inject[key] = value

      return value
    end,
    get_injected = function(key)
      return lvim.extensions[extension_name].inject[key]
    end,
    set_store = function(key, value)
      lvim.extensions[extension_name].store[key] = value

      return value
    end,
    get_store = function(key)
      return lvim.extensions[extension_name].store[key]
    end,
  }

  config = vim.tbl_extend("force", config, lvim.extensions[extension_name])

  local function define_plugin(plugin)
    if plugin.init ~= false or type(plugin.init) ~= "function" then
      plugin.init = function()
        require("utils.setup").plugin_init(extension_name)
      end
    end

    if plugin.config ~= false or type(plugin.config) ~= "function" then
      plugin.config = function()
        require("utils.setup").plugin_configure(extension_name)
      end
    end

    return plugin
  end

  if config ~= nil and config.plugin ~= nil then
    local plugins = {}

    if config.plugin ~= nil then
      local extension = config.plugin(config)

      if config.opts ~= nil and config.opts.multiple_packages then
        for _, e in pairs(extension) do
          table.insert(plugins, define_plugin(e))
        end
      else
        table.insert(plugins, define_plugin(extension))
      end
    end

    config.plugin = plugins
  end

  if config ~= nil and config.condition ~= nil and config.condition(lvim.extensions[extension_name]) == false then
    lvim.extensions[extension_name] = vim.tbl_extend("force", lvim.extensions[extension_name], config or {})

    Log:debug(string.format("Extension config stopped due to failed condition: %s", extension_name))

    return
  end

  if config ~= nil and config.configure ~= nil then
    config.configure(config, M.fn)
  end

  lvim.extensions[extension_name] = vim.tbl_extend("force", lvim.extensions[extension_name], config or {})
end

---
---@param extension_name string
---@return table
function M.get_config(extension_name)
  return lvim.extensions[extension_name]
end

---@param definitions table contains a tuple of event, opts, see `:h nvim_create_autocmd`
function M.define_autocmds(definitions)
  require("lvim.core.autocmds").define_autocmds(definitions)
end

---
---@param extension_name string
function M.plugin_configure(extension_name)
  return M.configure(M.get_config(extension_name))
end

---
---@param extension_name string
function M.plugin_init(extension_name)
  return M.configure(M.get_config(extension_name))
end

---
---@param extension_name string
function M.plugin_config(extension_name)
  return M.configure(M.get_config(extension_name))
end

---
---@param property function | table
---@return table
function M.evaluate_property(property, ...)
  if type(property) == "function" then
    return property(...)
  end

  return property
end

---@param ft table<string>
function M.fn.add_disabled_filetypes(ft)
  for _, value in pairs(ft) do
    table.insert(lvim.disabled_filetypes, value)
  end
end

---@param extension string
function M.fn.extension_get_active(extension)
  return (M.get_config(extension) or {}).active
end

function M.fn.get_current_setup(extension_name)
  return function()
    return lvim.extensions[extension_name].current_setup
  end
end

function M.fn.fetch_current_setup(extension_name)
  return lvim.extensions[extension_name].current_setup
end

---
---@param config config
function M.init(config)
  if config ~= nil and config.to_inject ~= nil then
    local ok = pcall(function()
      ---@diagnostic disable-next-line: assign-type-mismatch
      config.inject = vim.tbl_extend("force", config.inject, config.to_inject(config))
    end)

    if not ok then
      Log:warn(string.format("Can not inject in extension: %s", config.name))

      return
    end
  end

  if config ~= nil and config.on_init ~= nil then
    config.on_init(config)
  end

  if config ~= nil and config.autocmds ~= nil then
    M.define_autocmds(M.evaluate_property(config.autocmds, config))
  end

  if config ~= nil and config.keymaps ~= nil then
    M.load_mappings(M.evaluate_property(config.keymaps, config))
  end

  if config ~= nil and config.wk ~= nil then
    M.load_wk_mappings(M.evaluate_property(config.wk, config, keys_which_key.CATEGORIES))
  end

  if config ~= nil and config.wk_v ~= nil then
    M.load_wk_mappings(M.evaluate_property(config.wk_v, config, keys_which_key.CATEGORIES), "v")
  end

  if config ~= nil and config.hl ~= nil then
    local highlights = M.evaluate_property(config.hl, config)

    for key, value in pairs(highlights) do
      vim.api.nvim_set_hl(0, key, value)
    end
  end

  if config ~= nil and config.signs ~= nil and lvim.use_icons then
    local signs = M.evaluate_property(config.signs, config)

    for key, value in pairs(signs) do
      vim.fn.sign_define(key, value)
    end
  end

  if config ~= nil and config.commands ~= nil then
    require("utils.command").create_commands(M.evaluate_property(config.commands, config))
  end

  if config ~= nil and config.nvim_opts ~= nil then
    require("utils.command").set_option(config.nvim_opts)
  end
end

---
---@param config config
function M.configure(config)
  if config ~= nil and config.to_inject ~= nil then
    local ok = pcall(function()
      ---@diagnostic disable-next-line: assign-type-mismatch
      config.inject = vim.tbl_extend("force", config.inject, config.to_inject(config))
    end)

    if not ok then
      Log:warn(string.format("Can not inject in extension: %s", config.name))

      return
    end
  end

  if config ~= nil and config.legacy_setup ~= nil then
    M.legacy_setup(config.legacy_setup)
  end

  if config ~= nil and config.setup ~= nil then
    config.setup = M.evaluate_property(config.setup, config, M.fn)

    if config.to_setup ~= nil then
      config.setup = vim.tbl_deep_extend("force", config.setup, config.to_setup)
    end

    lvim.extensions[config.name].current_setup = vim.deepcopy(config.setup)
  end

  if config ~= nil and config.on_setup ~= nil then
    config.on_setup(config, M.fn)
  end

  if config ~= nil and config.on_done ~= nil then
    config.on_done(config, M.fn)
  end

  if config ~= nil and config.define_global_fn ~= nil then
    local functions = config.define_global_fn(config)

    for key, value in pairs(functions) do
      lvim.fn[key] = value
    end
  end

  if config ~= nil and config.on_complete ~= nil then
    config.on_complete(config, M.fn)
  end
end

---
---@param extension_name string
---@return table
function M.plugin(extension_name)
  return M.get_config(extension_name).plugin
end

---
function M.set_plugins()
  local plugins = {}

  for _, extension in pairs(lvim.extensions) do
    if extension.plugin ~= nil then
      for _, e in pairs(extension.plugin) do
        table.insert(plugins, e)
      end
    end
  end

  lvim.plugins = plugins
end

return M
