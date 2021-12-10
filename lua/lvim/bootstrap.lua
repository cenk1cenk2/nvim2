local M = {}

local uv = vim.loop
local path_sep = uv.os_uname().version:match "Windows" and "\\" or "/"
local in_headless = #vim.api.nvim_list_uis() == 0

---Join path segments that were passed as input
---@return string
function _G.join_paths(...)
  local result = table.concat({ ... }, path_sep)
  return result
end

---Get the full path to `$LUNARVIM_RUNTIME_DIR`
---@return string
function _G.get_runtime_dir()
  -- when nvim is used directly
  return vim.fn.stdpath "data"
end

---Get the full path to `$LUNARVIM_CONFIG_DIR`
---@return string
function _G.get_config_dir()
  return vim.fn.stdpath "config"
end

---Get the full path to `$LUNARVIM_CACHE_DIR`
---@return string
function _G.get_cache_dir()
  return vim.fn.stdpath "cache"
end

---Get the full path to the currently installed lunarvim repo
---@return string
local function get_install_path()
  -- when nvim is used directly
  return vim.fn.stdpath "config"
end

---Initialize the `&runtimepath` variables and prepare for startup
---@return table
function M:init(base_dir)
  self.runtime_dir = get_runtime_dir()
  self.config_dir = get_config_dir()
  self.cache_dir = get_cache_dir()
  self.pack_dir = join_paths(self.runtime_dir, "site", "pack")
  self.packer_install_dir = join_paths(self.runtime_dir, "site", "pack", "packer", "start", "packer.nvim")
  self.packer_cache_path = join_paths(self.config_dir, "plugin", "packer_compiled.lua")

  vim.cmd [[let &packpath = &runtimepath]]
  vim.cmd("set spellfile=" .. join_paths(self.config_dir, "spell", "en.utf-8.add"))
  ---Get the full path to LunarVim's base directory
  ---@return string
  function _G.get_lvim_base_dir()
    return base_dir
  end

  if os.getenv "LUNARVIM_RUNTIME_DIR" then
    -- vim.opt.rtp:append(os.getenv "LUNARVIM_RUNTIME_DIR" .. path_sep .. "lvim")
    vim.opt.rtp:remove(join_paths(vim.fn.stdpath "data", "site"))
    vim.opt.rtp:remove(join_paths(vim.fn.stdpath "data", "site", "after"))
    vim.opt.rtp:prepend(join_paths(self.runtime_dir, "site"))
    vim.opt.rtp:append(join_paths(self.runtime_dir, "site", "after"))

    vim.opt.rtp:remove(vim.fn.stdpath "config")
    vim.opt.rtp:remove(join_paths(vim.fn.stdpath "config", "after"))
    vim.opt.rtp:prepend(self.config_dir)
    vim.opt.rtp:append(join_paths(self.config_dir, "after"))
    -- TODO: we need something like this: vim.opt.packpath = vim.opt.rtp

    vim.cmd [[let &packpath = &runtimepath]]
  end

  -- FIXME: currently unreliable in unit-tests
  if not in_headless then
    _G.PLENARY_DEBUG = false
    require("lvim.impatient").setup {
      path = join_paths(self.cache_dir, "lvim_cache"),
      enable_profiling = true,
    }
  end

  require("lvim.config"):init()

  require("lvim.plugin-loader").init {
    package_root = self.pack_dir,
    install_path = self.packer_install_dir,
  }

  return self
end

---Update LunarVim
---pulls the latest changes from github and, resets the startup cache
function M:update()
  package.loaded["lvim.utils.hooks"] = nil
  local _, hooks = pcall(require, "lvim.utils.hooks")
  hooks.run_pre_update()
  M:update_repo()
  hooks.run_post_update()
end

local function git_cmd(subcmd, opts)
  local Job = require "plenary.job"
  local Log = require "lvim.core.log"
  local args = { "-C", opts.cwd }
  vim.list_extend(args, subcmd)

  local stderr = {}
  local stdout, ret = Job
    :new({
      command = "git",
      args = args,
      cwd = opts.cwd,
      on_stderr = function(_, data)
        table.insert(stderr, data)
      end,
    })
    :sync()

  if not vim.tbl_isempty(stderr) then
    Log:debug(stderr)
  end

  if not vim.tbl_isempty(stdout) then
    Log:debug(stdout)
  end

  return ret, stdout
end

---pulls the latest changes from github
function M:update_repo()
  local Log = require "lvim.core.log"
  local sub_commands = {
    fetch = { "fetch" },
    diff = { "diff", "--quiet", "@{upstream}" },
    merge = { "merge", "--ff-only", "--progress" },
  }
  local opts = {
    cwd = get_lvim_base_dir(),
  }
  Log:info "Checking for updates"

  local ret = git_cmd(sub_commands.fetch, opts)
  if ret ~= 0 then
    Log:error "Update failed! Check the log for further information"
    return
  end

  ret = git_cmd(sub_commands.diff, opts)

  if ret == 0 then
    Log:info "Configuration is already up-to-date"
    return
  end

  ret = git_cmd(sub_commands.merge, opts)

  if ret ~= 0 then
    Log:error "Update failed! Please pull the changes manually instead."
    return
  end
end

---Get currently installed version of LunarVim
---@param type string can be "short"
---@return string
function M:get_version(type)
  type = type or ""
  local opts = { cwd = get_lvim_base_dir() }

  local _, branch = git_cmd({ "branch", "--show-current" }, opts)

  local is_on_master = branch == "rolling"
  if not is_on_master then
    local log_status_ok, log_results = git_cmd({ "log", "--pretty=format:%h", "-1" }, opts)
    local abbrev_version = log_results[1] or ""
    if not log_status_ok or string.match(abbrev_version, "%d") == nil then
      return nil
    end
    return "dev-" .. abbrev_version
  end

  local tag_status_ok, results = git_cmd({ "describe", "--tags" }, opts)
  local lvim_full_ver = results[1] or ""

  if not tag_status_ok or string.match(lvim_full_ver, "%d") == nil then
    return nil
  end
  if type == "short" then
    return vim.fn.split(lvim_full_ver, "-")[1]
  else
    return string.sub(lvim_full_ver, 1, #lvim_full_ver - 1)
  end
end

---Get currently installed version of LunarVim
---@return string
function M:get_nvim_version()
  local Job = require "plenary.job"
  local Log = require "lvim.core.log"

  local stderr = {}
  local stdout, status_ok = Job
    :new({
      command = "nvim",
      args = { "--version" },
      on_stderr = function(_, data)
        table.insert(stderr, data)
      end,
    })
    :sync()

  if not vim.tbl_isempty(stderr) then
    Log:debug(stderr)
  end

  if not vim.tbl_isempty(stdout) then
    Log:debug(stdout)
  end

  if not status_ok then
    return nil
  end

  return stdout[1]
end

return M
