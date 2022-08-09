local M = {}

local Log = require "lvim.core.log"

function M.find_command(command)
  return command
end

function M.list_registered_providers_names(filetype)
  local s = require "null-ls.sources"
  local available_sources = s.get_available(filetype)
  local registered = {}

  for _, source in ipairs(available_sources) do
    for method in pairs(source.methods) do
      registered[method] = registered[method] or {}
      table.insert(registered[method], source.name)
    end
  end

  return registered
end

function M.register_sources(configs, method)
  local null_ls = require "null-ls"
  local is_registered = require("null-ls.sources").is_registered

  local sources, registered_names = {}, {}

  for _, config in ipairs(configs) do
    local cmd = config.exe or config.command
    local name = config.name or cmd:gsub("-", "_")
    local type = method == null_ls.methods.CODE_ACTION and "code_actions" or null_ls.methods[method]:lower()
    local source = type and null_ls.builtins[type][name]
    Log:debug(string.format("Received request to register [%s] as a %s source", name, type))
    if not source then
      Log:error("Not a valid source: " .. name)

      return registered_names
    elseif is_registered { name = source.name or name, method = method } then
      Log:trace(string.format("Skipping registering [%s] more than once", name))

      return registered_names
    end

    local requested_server = require("mason-registry").get_package(name)

    if not requested_server then
      local command = M.find_command(source._opts.command)

      if command then
        local opts = {
          name = name,
          command = command,
        }

        Log:debug("Registering source from globally source " .. name)
        Log:trace(vim.inspect(opts))

        table.insert(sources, source.with(opts))

        vim.list_extend(registered_names, { name })
      elseif name then
        local opts = {
          name = name,
        }

        Log:debug("Registering source from the default source " .. name)
        Log:trace(vim.inspect(opts))

        table.insert(sources, source.with(opts))

        vim.list_extend(registered_names, { name })
      else
        Log:warn("Not found source: " .. name)
      end
    else
      local opts = {
        name = name,
        command = cmd,
        dynamic_command = config.dynamic_command,
        env = config.env,
        extra_args = config.extra_args,
        filetypes = config.filetypes,
        extra_filetypes = config.extra_filetypes,
        disabled_filetypes = config.disabled_filetypes,
        condition = config.condition,
        runtime_condition = config.runtime_condition,
      }

      Log:debug("Registering source " .. name)
      Log:trace(vim.inspect(opts))

      local s = source.with(opts)

      if opts.dynamic_command == false then
        s._opts.dynamic_command = nil
      end

      table.insert(sources, s)

      vim.list_extend(registered_names, { name })
    end
  end

  if #sources > 0 then
    null_ls.register { sources = sources }
  end

  return registered_names
end

return M
