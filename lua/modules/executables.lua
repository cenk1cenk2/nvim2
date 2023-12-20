local Log = require("lvim.core.log")
local job = require("utils.job")

local M = {}

local function treesitter_highlight(ft)
  return function(input)
    local parser = vim.treesitter.get_string_parser(input, ft)
    local tree = parser:parse()[1]
    local query = vim.treesitter.query.get(ft, "highlights")
    local highlights = {}

    for id, node, _ in query:iter_captures(tree:root(), input) do
      local _, cstart, _, cend = node:range()
      table.insert(highlights, { cstart, cend, "@" .. query.captures[id] })
    end

    return highlights
  end
end

function M.run_genpass()
  local shada = require("modules.shada")
  local store_key = "RUN_GENPASS_ARGS"
  local stored_value = shada.get(store_key)

  vim.ui.input({
    prompt = "Genpass arguments:",
    highlight = treesitter_highlight("bash"),
    default = stored_value,
  }, function(arguments)
    shada.set(store_key, arguments)

    job.spawn({
      command = "genpass",
      args = vim.split(arguments or {}, " "),
      on_success = function(j)
        local generated = j:result()[1]

        Log:info(("Copied generated code to clipboard: %s"):format(generated))
        vim.fn.setreg(vim.v.register or lvim.system_register, generated)
      end,
    })
  end)
end

function M.run_ansible_vault_decrypt()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  job.spawn({
    command = "ansible-vault",
    writer = lines,
    args = { "decrypt" },
    on_success = function(j)
      vim.api.nvim_buf_set_lines(0, 0, -1, false, j:result())
    end,
  })
end

function M.run_ansible_vault_encrypt()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  job.spawn({
    command = "ansible-vault",
    writer = lines,
    args = { "encrypt" },
    on_success = function(j)
      vim.api.nvim_buf_set_lines(0, 0, -1, false, j:result())
    end,
  })
end

function M.run_sd()
  local store_key = "SD_INPUT"
  local shada = require("modules.shada")
  local stored_value = shada.get(store_key)

  vim.ui.input({
    prompt = "sd: ",
    highlight = treesitter_highlight("bash"),
    default = stored_value,
  }, function(arguments)
    if arguments == nil then
      Log:warn("No arguments provided")

      return
    end

    arguments = vim.split(arguments, " ")
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    job.spawn({
      command = "sd",
      args = arguments,
      writer = lines,
      on_success = function(j)
        shada.set(store_key, table.concat(arguments, " "))

        vim.api.nvim_buf_set_lines(0, 0, -1, false, j:result())
      end,
    })
  end)
end

function M.run_jq()
  local store_key = "JQ_INPUT"
  local shada = require("modules.shada")
  local stored_value = shada.get(store_key)

  vim.ui.input({
    prompt = "jq: ",
    highlight = treesitter_highlight("bash"),
    default = stored_value,
  }, function(arguments)
    if arguments == nil then
      arguments = "."
    end

    arguments = vim.split(arguments, " ")
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    job.spawn({
      command = "jq",
      args = arguments,
      writer = lines,
      on_success = function(j)
        shada.set(store_key, table.concat(arguments, " "))

        local result = table.concat(j:result(), "\n")

        Log:info(("Copied result to clipboard: %s"):format(result))
        vim.fn.setreg(vim.v.register or lvim.system_register, result)
      end,
    })
  end)
end

function M.run_yq()
  local store_key = "YQ_INPUT"
  local shada = require("modules.shada")
  local stored_value = shada.get(store_key)

  vim.ui.input({
    prompt = "yq: ",
    highlight = treesitter_highlight("bash"),
    default = stored_value,
  }, function(arguments)
    if arguments == nil then
      arguments = "."
    end

    arguments = vim.split(arguments, " ") or { "." }
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    job.spawn({
      command = "yq",
      args = arguments,
      writer = lines,
      on_success = function(j)
        shada.set(store_key, table.concat(arguments, " "))

        local result = table.concat(j:result(), "\n")

        Log:info(("Copied result to clipboard: %s"):format(result))
        vim.fn.setreg(vim.v.register or lvim.system_register, result)
      end,
    })
  end)
end

function M.reload_file()
  local ok = pcall(function()
    vim.cmd("e")
  end)

  if not ok then
    Log:warn(("Can not reload file since it is unsaved: %s"):format(vim.fn.expand("%")))
  end
end

function M.setup()
  require("utils.setup").init({
    name = "executables",
    wk = function(_, categories)
      return {
        [categories.SEARCH] = {
          d = {
            function()
              M.run_sd()
            end,
            "sd",
          },
        },
        [categories.TASKS] = {
          d = {
            function()
              M.run_ansible_vault_decrypt()
            end,
            "ansible-vault decrypt",
          },
          D = {
            function()
              M.run_ansible_vault_encrypt()
            end,
            "ansible-vault encrypt",
          },
          g = {
            function()
              M.run_genpass()
            end,
            "run genpass",
          },
          j = {
            function()
              M.run_jq()
            end,
            "run jq",
          },
          J = {
            function()
              M.run_yq()
            end,
            "run yq",
          },
        },
      }
    end,
  })
end

return M
