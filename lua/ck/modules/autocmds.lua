local M = {}

local log = require("ck.log")

---@param pattern string | string[]
---@return Autocmd
function M.q_close_autocmd(pattern)
  return M.init_with({ "FileType" }, pattern, function(event)
    return {
      keymaps = {
        {
          "q",
          function()
            nvim.fn.close_buffer(event.buf, true)
          end,
          mode = "n",
        },
      },
    }
  end)
end

---@param pattern string | string[]
---@return Autocmd
function M.set_view_buffer(pattern)
  return {
    event = { "FileType", "BufEnter" },
    group = "_view",
    pattern = pattern,
    callback = function()
      vim.bo.bufhidden = "wipe"
      -- vim.bo.matchpairs = ""
      vim.bo.swapfile = false
      vim.bo.synmaxcol = 0
      vim.opt_local.colorcolumn = ""
      vim.opt_local.cursorcolumn = false
      vim.opt_local.cursorline = false
      vim.opt_local.foldcolumn = "0"
      vim.opt_local.list = false
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
      vim.opt_local.signcolumn = "no"
      vim.opt_local.spell = false
    end,
  }
end

---@param event string | string[]
---@param pattern string | string[]
---@param callback fun(event: table): Config
---@param options? Autocmd
---@return Autocmd
function M.init_with(event, pattern, callback, options)
  return vim.tbl_extend("force", options or {}, {
    event = event,
    group = "_init_with",
    pattern = pattern,
    callback = function(e)
      return require("ck.setup").init(callback(e))
    end,
  })
end

---@param callback fun(bufnr: number, client: vim.lsp.Client): Config
---@return Autocmd
function M.on_lspattach(callback)
  return {
    event = { "LspAttach" },
    group = "_on_lspattach",
    pattern = "*",
    callback = function(event)
      return require("ck.setup").init(callback(event.buf, vim.lsp.get_client_by_id(event.data.client_id)))
    end,
  }
end

function M.setup()
  require("ck.setup").init({
    autocmds = function()
      return {
        M.q_close_autocmd({
          "qf",
          "help",
          "man",
          "floaterm",
          "lspinfo",
          "lsp-installer",
          "dap-float",
          "lspsagaoutline",
          "neotest-summary",
        }),
        {
          event = { "BufWinEnter", "BufRead", "BufNewFile" },
          group = "_format_options",
          pattern = "*",
          callback = function()
            vim.opt_local.formatoptions:remove("c")
            vim.opt_local.formatoptions:remove("r")
            vim.opt_local.formatoptions:remove("o")
          end,
        },
        {
          event = "TextYankPost",
          group = "_filetype_settings",
          pattern = "*",
          desc = "Highlight text on yank",
          callback = function()
            require("vim.highlight").on_yank({ higroup = "Search", timeout = 500 })
          end,
        },
        {
          event = "FileType",
          group = "_filetype_settings",
          pattern = "qf",
          callback = function()
            vim.bo.buflisted = false
            vim.cmd([[wincmd J]])
          end,
        },
        {
          event = "FileType",
          group = "_filetype_settings",
          pattern = {
            "gitcommit",
            "gitrebase",
            "gitconfig",
          },
          callback = function()
            vim.bo.bufhidden = "delete"
          end,
        },
        {
          event = "FileType",
          group = "_filetype_settings",
          pattern = "gitcommit",
          callback = function()
            vim.opt_local.wrap = false
          end,
        },
        {
          event = "BufReadCmd",
          group = "_filetype_settings",
          pattern = {
            "*.pdf",
            "*.jpg",
            "*.jpeg",
            "*.png",
            "*.gif",
            "*.svg",
            "*.webm",
          },
          callback = function(event)
            local bufnr = vim.fn.bufnr("%")
            local file = require("ck.utils.fs").get_buffer_filepath(event.buf)

            if vim.fn.buflisted(bufnr) == 1 then
              vim.api.nvim_set_current_buf(bufnr)
            end

            log:info("Opening file in system: %s", require("ck.utils.fs").get_project_buffer_filepath(event.buf))

            vim.api.nvim_buf_delete(event.buf, { force = true })

            vim.ui.open(file)
          end,
        },
        -- NOTE: Telescope opens file in insert mode after neovim commit: d52cc66
        -- Ref: https://github.com/nvim-telescope/telescope.nvim/issues/2501#issuecomment-1541009573
        -- Neovim commit pull request: https://github.com/neovim/neovim/pull/22984
        -- Workaround: Leave insert mode when leaving Telescope prompt.
        -- Ref: https://github.com/nvim-telescope/telescope.nvim/issues/2027#issuecomment-1510001730
        {
          event = "WinLeave",
          group = "_telescope",
          pattern = "*",
          callback = function()
            if vim.bo.filetype == "TelescopePrompt" and vim.fn.mode() == "i" then
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "i", true)
            end
          end,
        },

        -- tmux update the pane renaming on cwd change
        {
          event = "VimEnter",
          group = "_tmux",
          pattern = "*",
          callback = function()
            if vim.env["TMUX_PANE"] then
              os.execute("tmux set-window-option automatic-rename off 2>&1 &")
            end
          end,
        },
        {
          event = { "VimEnter", "DirChanged" },
          group = "_tmux",
          pattern = "*",
          callback = function()
            if vim.env["TMUX_PANE"] then
              os.execute(("tmux rename-window 'nvim@%s' 2>&1 &"):format(vim.fs.basename(require("ck.utils.fs").get_cwd())))
            end
          end,
        },
        {
          event = { "VimLeavePre" },
          group = "_tmux",
          pattern = "*",
          callback = function()
            if vim.env["TMUX_PANE"] then
              os.execute("tmux set-window-option automatic-rename on 2>&1 &")
            end
          end,
        },
        {
          event = { "BufReadPost" },
          group = "_buffer",
          pattern = "*",
          callback = function()
            for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_buf_get_name(bufnr) == "" and vim.api.nvim_get_option_value("buftype", { buf = bufnr }) == "" then
                if not vim.api.nvim_get_option_value("modified", { buf = bufnr }) then
                  vim.api.nvim_buf_delete(bufnr, {
                    force = true,
                  })
                end
              end
            end
          end,
        },
        -- {
        --   event = { "BufWritePost" },
        --   group = "_zsh",
        --   pattern = { "/tmp/zsh*.zsh" },
        --   callback = function()
        --     nvim.fn.workspace_quit()
        --   end,
        -- },
      }
    end,
  })
end

return M
