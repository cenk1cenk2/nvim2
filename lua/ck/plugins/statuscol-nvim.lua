-- https://github.com/luukvbaal/statuscol.nvim
local M = {}

M.name = "luukvbaal/statuscol.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "luukvbaal/statuscol.nvim",
        event = "BufReadPre",
      }
    end,
    setup = function()
      local builtin = require("statuscol.builtin")

      return {
        setopt = true, -- Whether to set the 'statuscolumn' option, may be set to false for those who
        -- want to use the click handlers in their own 'statuscolumn': _G.Sc[SFL]a().
        -- Although I recommend just using the segments field below to build your
        -- statuscolumn to benefit from the performance optimizations in this plugin.
        -- builtin.lnumfunc number string options
        thousands = false, -- or line number thousands separator string ("." / ",")
        relculright = true, -- whether to right-align the cursor line number with 'relativenumber' set
        -- Builtin 'statuscolumn' options
        ft_ignore = nvim.disabled_filetypes, -- lua table with filetypes for which 'statuscolumn' will be unset
        bt_ignore = nvim.disabled_buffer_types, -- lua table with 'buftype' values for which 'statuscolumn' will be unset
        -- Default segments (fold -> sign -> line number + separator), explained below
        segments = {
          {
            sign = { namespace = { "gitsign" }, maxwidth = 1, colwidth = 1, auto = false },
            click = "v:lua.ScSa",
          },
          {
            text = {
              function()
                return "%="
              end,
              builtin.foldfunc,
            },
            click = "v:lua.ScFa",
            auto = true,
          },
          {
            sign = { name = { "Dap*" }, auto = true },
            click = "v:lua.ScSa",
          },
          {
            sign = { namespace = { "diagnostic/signs" }, maxwidth = 1, colwidth = 1, auto = false },
            click = "v:lua.ScSa",
          },
          {
            sign = { name = { ".*" }, namespace = { ".*" }, maxwidth = 1, colwidth = 1, auto = true, wrap = true },
            click = "v:lua.ScSa",
          },
          { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
        },
      }
    end,
    on_setup = function(c)
      require("statuscol").setup(c)
    end,
  })
end

return M
