local log = require("ck.log")
local job = require("ck.utils.job")
local utils = require("ck.utils")

local M = {}

---@module "plenary.job"
---@module "toggleterm"

---@return string[]
function M.get_selection()
  local bufnr = vim.api.nvim_get_current_buf()

  return utils.get_visual_selection() or vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
end

---
---@param lines string[]
---@param opts CommandJob
---@return Job
function M.run_buffer_command(lines, opts)
  local bufnr = vim.api.nvim_get_current_buf()
  local j = job.create(vim.tbl_extend("force", opts, {
    writer = lines,
    on_success = function(j)
      log:info("Ran command: %s", opts.command)

      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, j:result())
    end,
    on_failure = function(j)
      log:error("Error running command:\n%s", table.concat(j:stderr_result(), "\n"))
    end,
  }))
  j:start()

  return j
end

---
---@param opts CommandJob
---@return Job
function M.run_clipboard_command(opts)
  local j = job.create(vim.tbl_extend("force", opts, {
    on_success = function(j)
      local generated = j:result()

      log:info("Copied result of command to clipboard: %s", opts.command)
      vim.fn.setreg(vim.v.register or nvim.system_register, generated)
    end,
  }))

  j:start()

  return j
end

---
---@param lines string[]
---@param opts CommandJob
---@return Job
function M.run_buffer_clipboard_command(lines, opts)
  local j = job.create(vim.tbl_extend("force", opts, {
    writer = lines,
    on_success = function(j)
      local generated = j:result()

      log:info("Copied result of command to clipboard: %s", opts.command)
      vim.fn.setreg(vim.v.register or nvim.system_register, generated)
    end,
    on_failure = function(j)
      log:error("Error running command:\n%s", table.concat(j:stderr_result(), "\n"))
    end,
  }))
  j:start()

  return j
end

---@class Executables.RunTemporaryBufferToTerminalCommandOptions: TermCreateArgs
---@field cmd (fun(path: string, filetype: string): string) | string

---
---@param opts Executables.RunTemporaryBufferToTerminalCommandOptions
---@return Terminal?
function M.run_buffer_to_terminal_command(opts)
  local terminal = require("ck.plugins.toggleterm-nvim")

  local bufnr = vim.api.nvim_get_current_buf()

  local path = require("ck.utils.fs").get_buffer_filepath(bufnr)
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })

  if type(opts.cmd) == "function" then
    opts.cmd = opts.cmd(path, filetype)
  end

  return terminal
    .create_float_terminal(vim.tbl_extend("force", opts, {
      on_failure = function(j)
        log:error("Error running command:\n%s", table.concat(j:stderr_result(), "\n"))
      end,
    }))
    :toggle()
end

---
---@param lines string[]
---@param opts Executables.RunTemporaryBufferToTerminalCommandOptions
---@return Terminal?
function M.run_buffer_to_temporary_terminal_command(lines, opts)
  local terminal = require("ck.plugins.toggleterm-nvim")

  local bufnr = vim.api.nvim_get_current_buf()

  local path = table.concat({ os.tmpname(), require("ck.utils.fs").get_buffer_extension(bufnr) }, ".")
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })

  local fd, err = io.open(path, "w+")

  if fd == nil or err then
    log:error("Failed to open temporary file: %s", err)

    return
  end

  fd:write(table.concat(lines, "\n"))
  fd:flush()
  fd:close()

  if type(opts.cmd) == "function" then
    opts.cmd = opts.cmd(path, filetype)
  end

  return terminal
    .create_float_terminal(vim.tbl_extend("force", opts, {
      on_close = function()
        local ok = os.remove(path)

        if not ok then
          log:error("Failed to remove temporary path: %s", path)

          return
        end

        log:info("Temporary path removed: %s", path)
      end,
      on_failure = function(j)
        log:error("Error running command:\n%s", table.concat(j:stderr_result(), "\n"))
      end,
    }))
    :toggle()
end

function M.run_genpass()
  local shada = require("ck.modules.shada")
  local store_key = "RUN_GENPASS_ARGS"
  local stored_value = shada.get(store_key)

  vim.ui.input({
    prompt = "Genpass arguments:",
    highlight = utils.treesitter_highlight("bash"),
    default = stored_value,
  }, function(arguments)
    shada.set(store_key, arguments)

    M.run_clipboard_command({
      command = "genpass",
      args = vim.split(arguments or {}, " "),
    })
  end)
end

function M.run_sd()
  local store_key = "SD_INPUT"
  local shada = require("ck.modules.shada")
  local stored_value = shada.get(store_key)
  local lines = M.get_selection()

  vim.ui.input({
    prompt = "sd: ",
    highlight = utils.treesitter_highlight("bash"),
    default = stored_value,
  }, function(arguments)
    if arguments == nil then
      log:warn("No arguments provided")

      return
    end

    arguments = vim.split(arguments, " ")

    M.run_buffer_command(lines, {
      command = "sd",
      args = arguments,
    })
  end)
end

function M.set_env()
  local store_key = "SET_ENV_VAR"
  local shada = require("ck.modules.shada")
  local stored_value = shada.get(store_key)

  vim.ui.input({
    prompt = "Environment Variable:",
    default = stored_value,
    completion = "environment",
  }, function(env)
    if env == nil then
      log:warn("Nothing to do.")

      return
    end

    shada.set(store_key, env)

    vim.ui.input({
      prompt = "Value:",
      default = vim.env[env],
      completion = "file",
    }, function(val)
      if val == nil then
        log:warn("Nothing to do.")

        return
      end

      vim.env[env] = vim.fn.expand(tostring(val))
    end)
  end)
end

function M.set_kubeconfig()
  local store_key = "KUBECONFIG"
  local shada = require("ck.modules.shada")
  local stored_value = shada.get(store_key)

  vim.ui.input({
    prompt = "Kubeconfig file:",
    default = stored_value,
    completion = "file",
  }, function(arguments)
    if arguments == nil then
      log:warn("Nothing to do.")

      return
    end

    local kubeconfig = vim.fn.expand(arguments)

    if not is_file(kubeconfig) then
      log:warn("Kubeconfig file not found: %s", kubeconfig)

      return
    end

    shada.set(store_key, arguments)

    vim.env["KUBECONFIG"] = kubeconfig
  end)
end

function M.setup()
  require("ck.setup").init({
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.SEARCH, "d" }),
          function()
            M.run_sd()
          end,
          desc = "sd",
        },
        {
          fn.wk_keystroke({ categories.ISSUES, "m" }),
          function()
            local lines = M.get_selection()

            M.run_buffer_clipboard_command(lines, {
              command = "jira-printer",
              args = { "-i", "markdown", "-o", "jira" },
            })
          end,
          desc = "convert markdown to jira",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.ISSUES, "M" }),
          function()
            local lines = M.get_selection()

            M.run_buffer_clipboard_command(lines, {
              command = "jira-printer",
              args = { "-i", "jira", "-o", "markdown" },
            })
          end,
          desc = "convert jira to markdown",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.RUN, "d" }),
          function()
            local lines = M.get_selection()

            vim.ui.select({
              { command = "ansible-vault", args = { "decrypt" } },
              { command = "sttr", args = { "ascii85-decode" } },
              { command = "sttr", args = { "base32-decode" } },
              { command = "sttr", args = { "base64-decode" } },
              { command = "sttr", args = { "base64url-decode" } },
              { command = "sttr", args = { "hex-decode" } },
              { command = "sttr", args = { "html-decode" } },
              { command = "sttr", args = { "json-unescape" } },
              { command = "sttr", args = { "url-decode" } },
              { command = "sttr", args = { "zeropad" } },
            }, {
              prompt = "decrypt",
              format_item = function(item)
                return ("%s %s"):format(item.command, table.concat(item.args, " "))
              end,
            }, function(item)
              M.run_buffer_clipboard_command(lines, item)
            end)
          end,
          desc = "decode",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.RUN, "D" }),
          function()
            local lines = M.get_selection()

            vim.ui.select({
              { command = "ansible-vault", args = { "encrypt" } },
              { command = "sttr", args = { "ascii85-encode" } },
              { command = "sttr", args = { "base32-encode" } },
              { command = "sttr", args = { "base64-encode" } },
              { command = "sttr", args = { "base64url-encode" } },
              { command = "sttr", args = { "hex-encode" } },
              { command = "sttr", args = { "html-encode" } },
              { command = "sttr", args = { "url-encode" } },

              { command = "sttr", args = { "bcrypt" } },
              { command = "sttr", args = { "count-chars" } },
              { command = "sttr", args = { "count-lines" } },
              { command = "sttr", args = { "count-words" } },
              { command = "sttr", args = { "escape-quotes" } },
              { command = "sttr", args = { "extract-emails" } },
              { command = "sttr", args = { "extract-ip" } },
              { command = "sttr", args = { "extract-url" } },
              { command = "sttr", args = { "hex-rgb" } },
              { command = "sttr", args = { "json" } },
              { command = "sttr", args = { "json-escape" } },
              { command = "sttr", args = { "json-msgpack" } },
              { command = "sttr", args = { "json-yaml" } },
              { command = "sttr", args = { "markdown-html" } },
              { command = "sttr", args = { "md5" } },
              { command = "sttr", args = { "morse-encode" } },
              { command = "sttr", args = { "msgpack-json" } },
              { command = "sttr", args = { "remove-newlines" } },
              { command = "sttr", args = { "remove-spaces" } },
              { command = "sttr", args = { "reverse" } },
              { command = "sttr", args = { "reverse-lines" } },
              { command = "sttr", args = { "rot13" } },
              { command = "sttr", args = { "sha1" } },
              { command = "sttr", args = { "sha224" } },
              { command = "sttr", args = { "sha256" } },
              { command = "sttr", args = { "sha384" } },
              { command = "sttr", args = { "sha512" } },
              { command = "sttr", args = { "slug" } },
              { command = "sttr", args = { "unique-lines" } },
              { command = "sttr", args = { "yaml-json" } },
            }, {
              prompt = "encode",
              format_item = function(item)
                return ("%s %s"):format(item.command, table.concat(item.args, " "))
              end,
            }, function(item)
              M.run_buffer_clipboard_command(lines, item)
            end)
          end,
          desc = "encode",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.RUN, "e" }),
          function()
            M.set_env()
          end,
          desc = "set environment variable",
        },
        {
          fn.wk_keystroke({ categories.RUN, "g" }),
          function()
            M.run_genpass()
          end,
          desc = "run genpass",
        },
        {
          fn.wk_keystroke({ categories.RUN, "o" }),
          function()
            local lines = M.get_selection()

            M.run_buffer_to_temporary_terminal_command(lines, {
              cmd = function(path)
                return ("otree '%s'"):format(path)
              end,
            })
          end,
          desc = "run otree",
        },
        {
          fn.wk_keystroke({ categories.RUN, "k" }),
          function()
            M.set_kubeconfig()
          end,
          desc = "set kubeconfig",
        },
      }
    end,
  })
end

return M
