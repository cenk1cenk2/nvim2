local log = require("ck.log")
local M = {
  fn = {},
}

---@module "which-key"
---@alias WKMappings wk.Spec
---@alias LoadWkFn fun(mappings: WKMappings): nil

--- Loads which-key mappings.
---@type LoadWkFn
function M.load_wk(mappings)
  if not is_loaded("which-key") then
    local plugin = require("ck.plugins.which-key")
    vim.list_extend(plugin._.pending_wk, mappings)

    return
  end

  require("which-key").add(mappings)
end

---@module "snacks.toggle"
---@class WKToggleMapping: WKMappings
---@field [2]? (fun(): snacks.toggle) | snacks.toggle
---@alias WKToggleMappings WKToggleMapping[]
---@alias LoadWkTogglesFn fun(mappings: WKToggleMappings): nil

--- Loads which key mappings with toggles.
---@type LoadWkTogglesFn
function M.load_toggles(mappings)
  if not is_loaded("snacks") then
    local plugin = require("ck.plugins.snacks-nvim")
    vim.list_extend(plugin._.pending_toggles, mappings)

    return
  end

  local plugin = require("ck.plugins.snacks-nvim")

  ---@type WKMappings[]
  local m = {}
  for _, mapping in pairs(mappings) do
    local keys = table.remove(mapping, 1)
    local toggle = table.remove(mapping, 1)
    plugin._.toggles[keys] = M.evaluate_property(toggle)

    table.insert(
      m,
      vim.tbl_extend("force", mapping, {
        keys,
        function()
          plugin._.toggles[keys]:toggle()
        end,
        icon = function()
          local key = plugin._.toggles[keys]:get() and "enabled" or "disabled"
          return {
            icon = type(plugin._.toggles[keys].opts.icon) == "string" and plugin._.toggles[keys].opts.icon or plugin._.toggles[keys].opts.icon[key],
            color = type(plugin._.toggles[keys].opts.color) == "string" and plugin._.toggles[keys].opts.color or plugin._.toggles[keys].opts.color[key],
          }
        end,
        desc = function()
          return (plugin._.toggles[keys]:get() and "disable " or "enable ") .. mapping.desc
        end,
      })
    )
  end

  M.load_wk(m)
end

---@alias KeymapMappings KeymapMapping[]
---@class KeymapMapping
---@field [1]? string
---@field [2]? string|fun()
---@field desc? string|fun():string
---@field buffer? number|boolean
---@field mode? string|string[]
---@alias KeymapOpts vim.keymap.set.Opts?
---@alias LoadKeymapsFn fun(mappings: KeymapMappings, opts: KeymapOpts): nil

--- Loads keymaps.
---@type LoadKeymapsFn
function M.load_keymaps(mappings, opts)
  opts = opts or {}

  for _, mapping in pairs(mappings) do
    local m = vim.tbl_extend("force", { silent = true }, mapping)
    local lhs = table.remove(m, 1)
    local rhs = table.remove(m, 1)
    local mode = m.mode or "n"
    m.mode = nil
    m = vim.tbl_extend("force", m, opts)

    local ok, result = pcall(vim.keymap.set, mode, lhs, rhs, m)

    if not ok then
      log:error("Can not map keybind: %s > %s", result, mapping)
    end
  end
end

---@class Commands: vim.api.keyset.user_command
---@field [1]? string
---@field [2]? fun() | string

---@alias CreateCommandsFn fun(commands: Commands): nil

--- Creates commands.
---@type CreateCommandsFn
function M.create_commands(commands)
  for _, cmd in pairs(commands) do
    local name = table.remove(cmd, 1)
    local callback = table.remove(cmd, 1)
    local opts = vim.tbl_deep_extend("force", { force = true }, cmd)

    vim.api.nvim_create_user_command(name, callback, opts)
  end
end

---@alias Autocmds Autocmd[]
---@class Autocmd: vim.api.keyset.create_autocmd
---@field group string
---@field event string | string[]
---@field pattern? string | string[]
---@field clear? boolean

---@alias CreateAutocmdsFn fun(autocmds: Autocmds): nil

--- Define autocommands.
---@type CreateAutocmdsFn
function M.create_autocmds(autocmds)
  for _, entry in ipairs(autocmds) do
    if type(entry.group) == "string" and entry.group ~= "" then
      M.create_augroup(entry.group, { clear = entry.clear })
    end
    entry.clear = nil

    local opts = vim.deepcopy(entry)
    opts.event = nil
    vim.api.nvim_create_autocmd(entry.event, opts)
  end
end

--- Gets an autocommand group.
---@param name string
---@return vim.api.keyset.get_autocmds.ret[] | nil
function M.get_augroup(name)
  local ok, autocmds = pcall(vim.api.nvim_get_autocmds, {
    group = name,
  })

  if ok and #autocmds > 0 then
    return autocmds
  end
end

--- Clears an autocommand group.
---@param name string
---@param opts vim.api.keyset.create_augroup
function M.create_augroup(name, opts)
  if M.get_augroup(name) and not opts.clear then
    return
  end

  vim.api.nvim_create_augroup(name, opts)
end

--- Clears an autocommand group.
---@param name string
function M.clear_augroup(name)
  log:trace("Trying to clear augroup: %s", name)

  vim.schedule(function()
    pcall(function()
      vim.api.nvim_clear_autocmds({ group = name })
    end)
  end)
end

---@param opts table
function M.legacy_setup(opts)
  for opt, val in pairs(opts) do
    vim.g[opt] = val
  end
end

---@alias SetHighlightFn fun(name: string, value: vim.api.keyset.highlight): nil

--- Sets an highlight.
---@type SetHighlightFn
function M.set_highlight(name, value)
  vim.api.nvim_set_hl(0, name, value)
end

---@alias SetSignFn fun(name: string, value: vim.fn.sign_define.dict): nil

--- Define a sign.
---@type SetSignFn
function M.set_sign(name, value)
  vim.fn.sign_define(name, value)
end

---@module "lazy"
---@class Plugin: LazyPluginSpec
---@field init? (fun(self:LazyPlugin)) | boolean
---@field config? fun(self:LazyPlugin, opts:table) | boolean

---Define the plugin in the plugin manager.
---@param config Config
---@param plugin Plugin
---@return Plugin
local function define_manager_plugin(config, plugin)
  if plugin.init ~= false and type(plugin.init) ~= "function" then
    plugin.init = function()
      require("ck.setup").plugin_init(config.name)
    end
  end

  if plugin.config ~= false and type(plugin.config) ~= "function" then
    plugin.config = function()
      require("ck.setup").plugin_configure(config.name)
    end
  end

  if plugin.enabled == nil then
    plugin.enabled = config.enabled
  end

  return plugin
end

---@class Config: table
---@field plugin? fun(config: Config): Plugin
---@field name? string
---@field enabled? boolean
---@field condition? fun(config: Config, fn: SetupFn): boolean
---@field configure? fun(config: Config, fn: SetupFn): nil
---@field on_init? fun(config: Config, fn: SetupFn): nil
---@field setup? (fun(config: Config, fn: SetupFn): any) | any
---@field on_setup? fun(c: any, config: Config, fn: SetupFn): nil
---@field legacy_setup? table
---@field on_done? fun(config: Config, fn: SetupFn): nil
---@field keymaps? (fun(config: Config, fn: SetupFn): KeymapMappings) | KeymapMappings
---@field wk? (fun(config: Config, categories: WKCategories, fn: SetupFn): WKMappings) | WKMappings
---@field toggles? (fun(config: Config, categories: WKCategories, fn: SetupFn): WKToggleMappings)
---@field autocmds? (fun(config: Config, fn: SetupFn): Autocmds[]) | Autocmds[]
---@field commands? (fun(config: Config, fn: SetupFn): Commands[]) | Commands[]
---@field hl? (fun(config: Config, fn: SetupFn): table<string, vim.api.keyset.highlight>) | table<string, vim.api.keyset.highlight>
---@field signs? (fun(config: Config, fn: SetupFn): table<string, vim.fn.sign_define.dict>) | table<string, vim.fn.sign_define.dict>
---@field plugin_spec? Plugin
---@field to_setup? SetupCallback[]
---@field to_hook? HookCallback[]
---@field current_setup any

---@alias DefinePluginFn fun(name: string, enabled: boolean, config: Config): nil

--- Define a new plugin.
---@type DefinePluginFn
function M.define_plugin(name, enabled, config)
  vim.validate({
    enabled = { enabled, "b" },
    name = { name, "s" },
    config = { config, "t" },
    condition = { config.condition, "f", true },
    plugin = { config.plugin, "f", true },
    configure = { config.configure, "f", true },
    on_init = { config.on_init, "f", true },
    setup = { config.setup, { "t", "f" }, true },
    on_setup = { config.on_setup, "f", true },
    legacy_setup = { config.legacy_setup, { "t", "f" }, true },
    on_done = { config.on_done, "f", true },
    keymaps = { config.keymaps, { "t", "f" }, true },
    wk = { config.wk, { "t", "f" }, true },
    toggles = { config.toggles, { "f" }, true },
    autocmds = { config.autocmds, { "t", "f" }, true },
    commands = { config.commands, { "t", "f" }, true },
    hl = { config.hl, { "f", "t" }, true },
    signs = { config.signs, { "f", "t" }, true },
  })

  config = vim.tbl_extend("force", config, {
    name = name,
    enabled = enabled,
    store = {},
    to_setup = {},
    to_hook = {},
  }, nvim.plugins[name] or {})

  if config.plugin ~= nil then
    config.plugin_spec = define_manager_plugin(config, config.plugin(config))

    log:trace("Defining plugin: %s as %s", config.plugin_spec[1], config.name)
  end

  if config.enabled == false then
    log:debug(string.format("Plugin config stopped due to disabled: %s", name))

    return
  end

  if config.condition ~= nil and config.condition(config, M.fn) == false then
    nvim.plugins[name] = config

    log:debug(string.format("Plugin config stopped due to failed condition: %s", name))

    return
  end

  if config.configure ~= nil then
    config.configure(config, M.fn)
  end

  nvim.plugins[name] = config
end

--- Returns the current configuration.
---@param name string
---@return Config
function M.get_config(name)
  local config = nvim.plugins[name]

  if not config then
    error(("Can not get config of plugin: %s"):format(name))
  end

  return config
end

--- Initialize the plugin with the current setup.
---@param name string
function M.plugin_init(name)
  return M.init(M.get_config(name))
end

--- Configure the plugin with the current setup.
---@param name string
function M.plugin_configure(name)
  return M.configure(M.get_config(name))
end

--- Evalautes the property and returns the result.
---@param property function | any
---@return any
function M.evaluate_property(property, ...)
  if type(property) == "function" then
    return property(...)
  end

  return property
end

---@alias SetupInitFn fun(config: Config): nil

--- Initializes the plugin.
---@type SetupInitFn
function M.init(config)
  if config.on_init ~= nil then
    config.on_init(config, M.fn)
  end

  if config.autocmds ~= nil then
    M.create_autocmds(M.evaluate_property(config.autocmds, config, M.fn))
  end

  if config.keymaps ~= nil then
    M.load_keymaps(M.evaluate_property(config.keymaps, config, M.fn))
  end

  if config.wk ~= nil then
    M.load_wk(M.evaluate_property(config.wk, config, M.fn.get_wk_categories(), M.fn))
  end

  if config.toggles ~= nil then
    M.load_toggles(M.evaluate_property(config.toggles, config, M.fn.get_wk_categories(), M.fn))
  end

  if config.hl ~= nil then
    local highlights = M.evaluate_property(config.hl, config, M.fn)

    for name, value in pairs(highlights) do
      M.set_highlight(name, value)
    end
  end

  if config.signs ~= nil then
    local signs = M.evaluate_property(config.signs, config, M.fn)

    for key, value in pairs(signs) do
      M.set_sign(key, value)
    end
  end

  if config.commands ~= nil then
    M.create_commands(M.evaluate_property(config.commands, config, M.fn))
  end

  if config.legacy_setup ~= nil then
    M.legacy_setup(M.evaluate_property(config.legacy_setup, config))
  end
end

--- Configures the plugin.
---@param config Config
---@param callbacks? SetupCallback[]
function M.configure(config, callbacks)
  if config.setup ~= nil then
    nvim.plugins[config.name].current_setup = nil
    nvim.plugins[config.name].current_setup = M.evaluate_property(config.setup, config, M.fn)

    for _, to_setup in pairs(vim.list_extend(vim.deepcopy(config.to_setup or {}), callbacks or {})) do
      nvim.plugins[config.name].current_setup = to_setup(nvim.plugins[config.name].current_setup, config, M.fn)
    end

    for _, to_hook in pairs(vim.deepcopy(config.to_hook or {})) do
      to_hook(M.HOOK_EVENTS.HAS_FINISHED_SETUP, M.fn)
    end
  end

  if config.on_setup ~= nil then
    config.on_setup(M.fn.get_setup(config.name), config, M.fn)
  end

  if config.on_done ~= nil then
    config.on_done(config, M.fn)
  end
end

--- Sets the plugins for the plugin manager to consume.
function M.into_plugin_spec()
  local plugins = {}

  for _, plugin in pairs(nvim.plugins) do
    if plugin.plugin_spec ~= nil then
      table.insert(plugins, plugin.plugin_spec)
    end
  end

  return plugins
end

-- fn functions

---@class SetupFn
---@field add_disabled_filetypes SetupFnAddDisabledFiletypes
---@field add_disabled_buffertypes SetupFnAddDisabledBuffertypes
---@field setup_callback SetupFnSetupCallback
---@field get_wk_categories SetupFnGetWkCategories
---@field get_wk_category SetupFnGetWkCategory
---@field get_setup_wrapper SetupFnGetSetupWrapper
---@field get_setup SetupFnGetSetup
---@field get_highlight SetupFnGetHighlight
---@field keystroke SetupFnKeystroke
---@field local_keystroke SetupFnLocalKeystroke
---@field wk_keystroke SetupFnWkKeystroke

---@alias SetupFnAddDisabledFiletypes fun(ft: string[]): nil

-- Adds disabled filetypes to the global list.
---@type SetupFnAddDisabledFiletypes
function M.fn.add_disabled_filetypes(ft)
  for _, value in pairs(ft) do
    table.insert(nvim.disabled_filetypes, value)
  end
end

---@alias SetupFnAddDisabledBuffertypes fun(ft: string[]): nil

-- Adds disabled filetypes to the global list.
---@type SetupFnAddDisabledFiletypes
function M.fn.add_disabled_buffertypes(t)
  for _, value in pairs(t) do
    table.insert(nvim.disabled_buffer_types, value)
  end
end

---@alias SetupCallback fun(c: any, config: Config, fn: SetupFn): any
---@alias SetupFnSetupCallback fun(name: string, cb: SetupCallback)

-- Appends to setup of an plugin with the intend of changing the original configuration.
---@type SetupFnSetupCallback
function M.fn.setup_callback(name, cb)
  if nvim.plugins[name] == nil then
    nvim.plugins[name] = {
      to_setup = {},
    }
  end

  table.insert(nvim.plugins[name].to_setup, cb)
end

---@type SetupFnSetupCallback
M.setup_callback = M.fn.setup_callback

---@enum HookEvent
M.HOOK_EVENTS = {
  HAS_FINISHED_SETUP = "has_finished_setup",
}

---@alias HookCallback fun(event: HookEvent, fn: SetupFn): any
---@alias SetupFnHookCallback fun(name: string, cb: HookCallback)

-- Appends to setup of an plugin with the intend of changing the original configuration.
---@type SetupFnHookCallback
function M.fn.hook_callback(name, cb)
  if nvim.plugins[name] == nil then
    nvim.plugins[name] = {
      to_hook = {},
    }
  end

  table.insert(nvim.plugins[name].to_hook, cb)
end

---@type SetupFnHookCallback
M.hook_callback = M.fn.hook_callback

---@alias SetupFnGetWkCategories fun(): WKCategories

--- Returns which-key categories.
---@type SetupFnGetWkCategories
function M.fn.get_wk_categories()
  return require("ck.keys.wk").CATEGORIES
end

---@alias SetupFnGetWkCategory fun(category: string): string

--- Returns a which-key category.
---@type SetupFnGetWkCategory
function M.fn.get_wk_category(category)
  return M.fn.get_wk_categories()[category]
end

---@alias SetupFnGetSetupWrapper fun(name: string): fun(): table

--- Returns the current setup of an plugin.
---@type SetupFnGetSetupWrapper
function M.fn.get_setup_wrapper(name)
  return function()
    return M.fn.get_setup(name)
  end
end

---@alias SetupFnGetSetup fun(name: string): any

--- Returns the current setup of an plugin.
---@type SetupFnGetSetup
function M.fn.get_setup(name)
  return nvim.plugins[name].current_setup
end

---@alias SetupFnGetHighlight fun(name: string): vim.api.keyset.get_hl_info

--- Returns a highlight group.
---@type SetupFnGetHighlight
function M.fn.get_highlight(name)
  return vim.api.nvim_get_hl(0, { name = name })
end

---@alias SetupFnAddGlobalFunction fun(name: string, fn: function): function

---@alias SetupFnKeystroke fun(keystrokes: table<string>): string

--- Builds a keystroke string.
---@type SetupFnKeystroke
function M.fn.keystroke(keystrokes)
  return table.concat(keystrokes, "")
end

---@alias SetupFnLocalKeystroke fun(keystrokes: table<string>): string

--- Builds a which-key keystroke string.
---@type SetupFnLocalKeystroke
function M.fn.local_keystroke(keystrokes)
  return M.fn.keystroke(vim.list_extend({ "<localleader>" }, keystrokes))
end

---@alias SetupFnWkKeystroke fun(keystrokes: table<string>): string

--- Builds a which-key keystroke string.
---@type SetupFnWkKeystroke
function M.fn.wk_keystroke(keystrokes)
  return M.fn.keystroke(vim.list_extend({ "<Leader>" }, keystrokes))
end

return M
