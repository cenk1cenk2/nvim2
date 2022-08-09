local M = {}

M.config = function()
  lvim.builtin.dap = {
    active = true,
    on_config_done = nil,
    breakpoint = { text = "", texthl = "LspDiagnosticsSignError", linehl = "", numhl = "" },
    breakpoint_rejected = { text = "", texthl = "LspDiagnosticsSignHint", linehl = "", numhl = "" },
    stopped = {
      text = "",
      texthl = "LspDiagnosticsSignInformation",
      linehl = "DiagnosticUnderlineInfo",
      numhl = "LspDiagnosticsSignInformation",
    },
  }
end

M.setup = function()
  local dap = require "dap"

  if lvim.use_icons then
    vim.fn.sign_define("DapBreakpoint", lvim.builtin.dap.breakpoint)
    vim.fn.sign_define("DapBreakpointRejected", lvim.builtin.dap.breakpoint_rejected)
    vim.fn.sign_define("DapStopped", lvim.builtin.dap.stopped)
  end

  dap.defaults.fallback.terminal_win_cmd = ":30hsplit new"

  lvim.builtin.which_key.mappings["d"] = {
    name = "Debug",
    t = { ":lua require'dap'.toggle_breakpoint()<cr>", "toggle breakpoint" },
    b = { ":lua require'dap'.step_back()<cr>", "step back" },
    c = { ":lua require'dap'.continue()<cr>", "continue" },
    C = { ":lua require'dap'.run_to_cursor()<cr>", "run to cursor" },
    d = { ":lua require'dap'.disconnect()<cr>", "disconnect" },
    g = { ":lua require'dap'.session()<cr>", "get session" },
    i = { ":lua require'dap'.step_into()<cr>", "step into" },
    o = { ":lua require'dap'.step_over()<cr>", "step over" },
    k = { ":lua require('dap.ui.widgets').hover()<cr>", "inspect element" },
    K = { ':lua require("dapui").float_element()<CR>', "floating element" },
    l = { ":lua require('dap').list_breakpoints()<cr>", "list breakpoints" },
    O = { ":lua require'dap'.step_out()<cr>", "step out" },
    p = { "<cmd>lua require'dap'.pause()<cr>", "Pause" },
    r = { ":lua require'dap'.repl.toggle()<cr>", "toggle repl" },
    R = { ":lua require('dap.ext.vscode').load_launchjs()<cr>", "reload launch.json" },
    q = { ":lua require'dap'.close()<cr>", "quit" },
    u = { ':lua require("dapui").toggle()<CR>', "toggle ui" },
  }

  require("dap.ext.vscode").load_launchjs()

  if lvim.builtin.dap.on_config_done then
    lvim.builtin.dap.on_config_done(dap)
  end
end

return M
