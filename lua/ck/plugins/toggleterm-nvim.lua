-- https://github.com/akinsho/toggleterm.nvim
local M = {}

M.name = "akinsho/toggleterm.nvim"

local log = require("ck.log")

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "akinsho/toggleterm.nvim",
        -- cond = vim.env["TMUX"] == "",
        -- event = "VeryLazy",
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "toggleterm",
      })

      if not vim.env["TMUX"] then
        nvim.fn.toggle_log_view = M.toggle_log_view
      end

      fn.setup_callback(require("ck.plugins.edgy-nvim").name, function(c)
        vim.list_extend(c.bottom, {
          {
            ft = "toggleterm",
            size = {
              height = function()
                if vim.o.lines < 60 then
                  return 0.25
                end

                return 20
              end,
            },
            -- exclude floating windows
            filter = function(_, win)
              return vim.api.nvim_win_get_config(win).relative == ""
            end,
          },
        })

        return c
      end)
    end,
    setup = function()
      return {
        -- size can be a number or function which is passed the current terminal
        size = function(term)
          if term.direction == "horizontal" then
            return math.floor(vim.o.lines * 0.25)
          elseif term.direction == "vertical" then
            return math.floor(vim.o.columns * 0.25)
          end
        end,
        -- open_mapping = [[<c-\>]],
        open_mapping = [[<F12>]],
        hide_numbers = true, -- hide the number column in toggleterm buffers
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2, -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
        start_in_insert = true,
        insert_mappings = false, -- whether or not the open mapping applies in insert mode
        persist_size = false,
        -- direction = 'vertical' | 'horizontal' | 'window' | 'float',
        direction = "float",
        close_on_exit = true, -- close the terminal window when the process exits
        shell = vim.o.shell, -- change the default shell
        -- This field is only relevant if direction is set to 'float'
        float_opts = {
          -- The border key is *almost* the same as 'nvim_win_open'
          -- see :h nvim_win_open for details on borders however
          -- the 'curved' border is a custom border type
          -- not natively supported but implemented in this plugin.
          -- border = 'single' | 'double' | 'shadow' | 'curved' | ... other options supported by win open
          border = nvim.ui.border,
          width = function()
            if vim.o.columns < 180 then
              return math.floor(vim.o.columns * 0.975)
            end

            return math.floor(vim.o.columns * 0.9)
          end,
          height = function()
            if vim.o.lines < 60 then
              return math.floor(vim.o.lines * 0.95)
            end

            return math.floor(vim.o.lines * 0.9)
          end,
          winblend = 0,
          highlights = { border = "Normal", background = "Normal" },
        },
        winbar = {
          enabled = false,
          name_formatter = function(terminal) --  term: Terminal
            return terminal.name
          end,
        },
        on_open = M.on_open,
        on_exit = M.on_exit,
      }
    end,
    on_setup = function(c)
      require("toggleterm").setup(c)
    end,
    on_done = function()
      local editor = "nvim -b"
      local editor_split = ([[%s -cc split]]):format(editor)

      vim.env.VISUAL = editor
      vim.env.EDITOR = editor
      vim.env.GIT_EDITOR = editor

      require("telescope").load_extension("toggleterm")
    end,
    keymaps = function()
      if vim.env["TMUX"] then
        return {}
      end

      return {
        {
          "<F1>",
          function()
            M.get_current_float_terminal():toggle()
          end,
          mode = { "n" },
        },
        {
          "<F1>",
          function()
            M.close_all()
          end,
          mode = { "t" },
        },
        {
          "<F2>",
          function()
            M.float_terminal_select("prev")
          end,
          mode = { "n", "t" },
        },
        {
          "<F3>",
          function()
            M.float_terminal_select("next")
          end,
          mode = { "n", "t" },
        },
        {
          "<F4>",
          function()
            M.append_float_terminal()
          end,
          mode = { "n", "t" },
        },
        {
          "<F5>",
          function()
            M.create_buffer_terminal()
          end,
          mode = { "n", "t" },
        },
        {
          "<F7>",
          function()
            M.create_bottom_terminal()
          end,
          mode = { "n", "t" },
        },
        {
          "<F9>",
          function()
            M.kill_all()
          end,
          mode = { "n", "t" },
        },
      }
    end,
    wk = function(_, categories, fn)
      if vim.env["TMUX"] then
        return {}
      end

      local togglers = {
        { cmd = "lazygit", keymap = "g", label = "LazyGit" },
        { cmd = "lazydocker", keymap = "d", label = "LazyDocker" },
        { cmd = "dust", keymap = "n", label = "dust" },
        { cmd = "k9s", keymap = "k", label = "k9s" },
      }

      for i, exec in pairs(togglers) do
        M.create_toggle_term({
          cmd = exec.cmd,
          keymap = exec.keymap,
          label = exec.label,
          -- NOTE: unable to consistently bind id/count <= 9, see #2146
          count = i + 100,
          direction = exec.direction,
        })
      end

      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.TERMINAL, "f" }),
          function()
            require("telescope").extensions.toggleterm.list(require("telescope.themes").get_dropdown({}))
          end,
          desc = "list terminals",
        },
        {
          fn.wk_keystroke({ categories.TERMINAL, "b" }),
          function()
            M.create_buffer_terminal()
          end,
          desc = "buffer cwd terminal",
        },
        {
          fn.wk_keystroke({ categories.TERMINAL, "B" }),
          function()
            M.create_bottom_terminal()
          end,
          desc = "bottom terminal",
        },
        {
          fn.wk_keystroke({ categories.TERMINAL, "X" }),
          function()
            M.kill_all()
          end,
          desc = "kill all terminals",
        },
      }
    end,
    autocmds = function()
      return {
        {
          event = { "TermOpen" },
          group = "_toggle_term",
          pattern = "*",
          callback = function(event)
            vim.keymap.set("n", "<LeftRelease>", "<LeftRelease>i", { silent = true, buffer = event.buf })
          end,
        },
      }
    end,
  })
end

M.terminals = {}
M.float_terminals = {}
M.float_terminal_current = 0
M.marks = {
  MARK = "__marks",
  IS_INDEXED = "is_indexed",
  INDEX = "index",
  HAS_EXIT = "has_exit",
}

function M.on_open(terminal)
  terminal:focus()

  -- if not M.get_mark(terminal, M.marks.HAS_EXIT) then
  -- terminal:set_mode(require("toggleterm.terminal").mode.INSERT)
  -- end
end

function M.on_exit(terminal) end

function M.create_toggle_term(opts)
  local binary = opts.cmd:match("(%S+)")
  if vim.fn.executable(binary) ~= 1 then
    log:debug(("Skipping configuring executable %s. Please make sure it is installed properly.").format(binary))
    return
  end

  require("ck.setup").init({
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.TERMINAL, opts.keymap }),

          function()
            M.toggle_toggle_term({ cmd = opts.cmd, count = opts.count, direction = opts.direction })
          end,
          desc = opts.label,
        },
      }
    end,
  })
end

function M.toggle_toggle_term(toggler)
  if not M.terminals[toggler.cmd] then
    M.terminals[toggler.cmd] = M.create_terminal({
      cmd = toggler.cmd,
      hidden = true,
    })
  end

  local terminal = M.terminals[toggler.cmd]

  terminal:toggle()
  terminal:set_mode(require("toggleterm.terminal").mode.INSERT)

  return terminal
end

function M.get_current_float_terminal()
  if not M.float_terminals[M.float_terminal_current] then
    M.float_terminal_current = 1
  end

  local terminal
  if vim.tbl_isempty(M.float_terminals) then
    terminal = M.create_float_terminal()
  else
    terminal = M.float_terminals[M.float_terminal_current]
  end

  log:trace(("Terminal switched: %s -> %s -> %s"):format(M.float_terminal_current, terminal.cmd, terminal.dir))

  return terminal
end

function M.float_terminal_on_open(terminal)
  if M.get_mark(terminal, M.marks.IS_INDEXED) then
    return
  end

  M.set_mark(terminal, M.marks.IS_INDEXED, true)

  local index = vim.tbl_count(M.float_terminals) + 1

  table.insert(M.float_terminals, index, terminal)
  M.set_mark(terminal, M.marks.INDEX, index)

  M.float_terminal_current = index

  log:debug(("Terminal created: %s -> %s -> %s"):format(M.float_terminal_current, terminal.cmd, terminal.dir))

  M.on_open(terminal)
end

function M.float_terminal_on_exit(terminal)
  local cb = function()
    for i, t in pairs(M.float_terminals) do
      if t.id == terminal.id then
        table.remove(M.float_terminals, i)
      end
    end

    if M.float_terminal_current > vim.tbl_count(M.float_terminals) then
      M.float_terminal_current = vim.tbl_count(M.float_terminals)
    elseif M.float_terminal_current < M.get_mark(terminal, M.marks.INDEX) then
      M.float_terminal_current = M.float_terminal_current - 1
    end
  end

  M.set_mark(terminal, M.marks.HAS_EXIT, true)

  if terminal.close_on_exit then
    cb()
  else
    local keymap_cb = function()
      terminal:shutdown()
      cb()

      log:debug(("Shutdown current terminal manually: %s"):format(terminal.cmd))
    end

    vim.keymap.set({ "n", "t", "i" }, "q", keymap_cb, { silent = true, buffer = terminal.bufnr })
    vim.keymap.set({ "n", "i", "t" }, "<CR>", keymap_cb, { silent = true, buffer = terminal.bufnr })
    vim.keymap.set({ "t", "n" }, "i", keymap_cb, { silent = true, buffer = terminal.bufnr })
  end
end

function M.set_mark(terminal, key, value)
  if not terminal[M.marks.MARK] then
    terminal[M.marks.MARK] = {}
  end

  terminal[M.marks.MARK][key] = value

  return terminal
end

function M.get_mark(terminal, key)
  if not terminal[M.marks.MARK] then
    terminal[M.marks.MARK] = {}

    return nil
  end

  return terminal[M.marks.MARK][key]
end

---Create a new terminal.
---@param opts TermCreateArgs
---@return Terminal
function M.create_terminal(opts)
  local Terminal = require("toggleterm.terminal").Terminal

  local terminal = Terminal:new(opts or {})

  return terminal
end

---Create a new terminal.
---@param opts? TermCreateArgs
---@return TermCreateArgs
function M.generate_defaults_float_terminal(opts)
  opts = opts or {}

  return vim.tbl_extend("force", opts or {}, {
    direction = "float",
    hidden = true,
    on_open = function(terminal)
      M.float_terminal_on_open(terminal)

      if opts.on_open then
        opts.on_open(terminal)
      end
    end,
    on_exit = function(terminal)
      M.float_terminal_on_exit(terminal)

      if opts.on_exit then
        opts.on_exit(terminal)
      end
    end,
  })
end

---Create a new terminal.
---@param opts? TermCreateArgs
---@return Terminal
function M.create_float_terminal(opts)
  local terminal = M.create_terminal(M.generate_defaults_float_terminal(vim.tbl_extend(
    "force",
    ---@type TermCreateArgs
    {
      cmd = vim.o.shell,
    },
    opts or {}
  )))

  return terminal
end

function M.append_float_terminal()
  if not vim.tbl_isempty(M.float_terminals) and M.get_current_float_terminal():is_open() then
    M.get_current_float_terminal():close()
  end

  local terminal = M.create_float_terminal()

  terminal:open()
end

function M.float_terminal_select(action)
  if M.get_current_float_terminal():is_open() then
    M.get_current_float_terminal():close()
  end

  if vim.tbl_isempty(M.float_terminals) then
    M.create_float_terminal()
  elseif action == "next" then
    local updated = M.float_terminal_current + 1

    if updated > vim.tbl_count(M.float_terminals) then
      M.float_terminal_current = 1
    else
      M.float_terminal_current = updated
    end
  elseif action == "prev" then
    local updated = M.float_terminal_current - 1

    if updated < 1 then
      M.float_terminal_current = vim.tbl_count(M.float_terminals)
    else
      M.float_terminal_current = updated
    end
  end

  local current = M.get_current_float_terminal()
  current:open()
  M.on_open(current)
end

function M.create_bottom_terminal()
  if not M.terminals["bottom"] then
    M.terminals["bottom"] = M.create_terminal({
      cmd = vim.o.shell,
      direction = "horizontal",
      hidden = true,
    })
  end

  M.terminals["bottom"]:toggle()

  return M.terminals["bottom"]
end

function M.create_buffer_terminal()
  local current = require("ck.utils.fs").get_buffer_dirpath()

  local t = M.create_float_terminal()

  t:toggle()

  if t.dir ~= current then
    t:change_dir(current)
  end

  return t
end

function M.get_all()
  local terms = require("toggleterm.terminal")

  local all_terminals = {}
  for _, value in pairs({ terms.get_all(true), M.terminals, M.float_terminals }) do
    vim.list_extend(all_terminals, value)
  end

  return all_terminals
end

function M.close_all()
  local all_terminals = M.get_all()

  for _, terminal in pairs(all_terminals) do
    if terminal:is_open() or terminal:is_focused() then
      terminal:close()
    end
  end

  -- let ranger act as terminal as well
  pcall(function()
    vim.cmd([[
    let win_hd = rnvimr#context#winid()
    if rnvimr#context#bufnr() != -1
        if win_hd != -1 && nvim_win_is_valid(win_hd)
            if nvim_get_current_win() == win_hd
                call nvim_win_close(win_hd, 0)
                call rnvimr#rpc#clear_image()
            endif
        endif
    endif
  ]])
  end)
end

function M.kill_all()
  local all_terminals = M.get_all()

  for _, terminal in pairs(all_terminals) do
    terminal:shutdown()
  end

  M.float_terminals = {}
  M.float_terminal_current = 0
end

---@param file string the fullpath to the logfile
function M.toggle_log_view(file)
  local ok = pcall(require, "toggleterm")

  if not ok then
    log:debug("Terminal not ready.")
    return
  end

  local cmd = nvim.log.viewer.cmd

  log:debug("Attempting to open log file: %s", file)

  cmd = cmd .. " " .. file
  local term_opts = vim.tbl_deep_extend("force", M.get_setup(), {
    cmd = cmd,
    direction = "float",
    open_mapping = "",
    float_opts = {},
  })

  local log_view = M.create_terminal(term_opts)
  log_view:toggle()
end

M.get_setup = require("ck.setup").fn.get_setup_wrapper(M.name)

return M
