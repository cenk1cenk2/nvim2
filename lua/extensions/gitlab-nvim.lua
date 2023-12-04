-- https://github.com/harrisoncramer/gitlab.nvim
local M = {}

local extension_name = "harrisoncramer/gitlab.nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "harrisoncramer/gitlab.nvim",
        dependencies = {
          "MunifTanjim/nui.nvim",
          "nvim-lua/plenary.nvim",
          "sindrets/diffview.nvim",
          "stevearc/dressing.nvim",
          "nvim-tree/nvim-web-devicons",
        },
        build = function()
          require("gitlab.server").build(true)
        end,
      }
    end,
    setup = function()
      return {
        port = nil, -- The port of the Go server, which runs in the background, if omitted or `nil` the port will be chosen automatically
        log_path = vim.fn.stdpath("cache") .. "/gitlab.nvim.log", -- Log path for the Go server
        config_path = nil, -- Custom path for `.gitlab.nvim` file, please read the "Connecting to Gitlab" section
        debug = { go_request = false, go_response = false }, -- Which values to log
        attachment_dir = nil, -- The local directory for files (see the "summary" section)
        popup = { -- The popup for comment creation, editing, and replying
          exit = "<Esc>",
          perform_action = "<C-s>", -- Once in normal mode, does action (like saving comment or editing description, etc)
          perform_linewise_action = "<C-l>", -- Once in normal mode, does the linewise action (see logs for this job, etc)
        },
        discussion_tree = { -- The discussion tree that holds all comments
          blacklist = {}, -- List of usernames to remove from tree (bots, CI, etc)
          jump_to_file = "o", -- Jump to comment location in file
          jump_to_reviewer = "m", -- Jump to the location in the reviewer window
          edit_comment = "e", -- Edit comment
          delete_comment = "dd", -- Delete comment
          reply = "r", -- Reply to comment
          toggle_node = "t", -- Opens or closes the discussion
          toggle_resolved = "p", -- Toggles the resolved status of the whole discussion
          position = "left", -- "top", "right", "bottom" or "left"
          size = "20%", -- Size of split
          relative = "editor", -- Position of tree split relative to "editor" or "window"
          resolved = lvim.ui.icons.ui.Check, -- Symbol to show next to resolved discussions
          unresolved = lvim.ui.icons.ui.Close, -- Symbol to show next to unresolved discussions
          tree_type = "simple", -- Type of discussion tree - "simple" means just list of discussions, "by_file_name" means file tree with discussions under file
        },
        info = { -- Show additional fields in the summary pane
          enabled = true,
          horizontal = false, -- Display metadata to the left of the summary rather than underneath
          fields = { -- The fields listed here will be displayed, in whatever order you choose
            "author",
            "created_at",
            "updated_at",
            "merge_status",
            "draft",
            "conflicts",
            "assignees",
            "reviewers",
            "branch",
            "pipeline",
          },
        },
        discussion_sign_and_diagnostic = {
          skip_resolved_discussion = false,
          skip_old_revision_discussion = true,
        },
        discussion_sign = {
          -- See :h sign_define for details about sign configuration.
          enabled = true,
          text = lvim.ui.icons.ui.Comment,
          linehl = nil,
          texthl = nil,
          culhl = nil,
          numhl = nil,
          priority = 20, -- Priority of sign, the lower the number the higher the priority
          helper_signs = {
            -- For multiline comments the helper signs are used to indicate the whole context
            -- Priority of helper signs is lower than the main sign (-1).
            enabled = true,
            start = lvim.ui.icons.ui.ChevronShortUp,
            mid = lvim.ui.icons.borderchars[1],
            ["end"] = lvim.ui.icons.ui.ChevronShortDown,
          },
        },
        discussion_diagnostic = {
          -- If you want to customize diagnostics for discussions you can make special config
          -- for namespace `gitlab_discussion`. See :h vim.diagnostic.config
          enabled = true,
          severity = vim.diagnostic.severity.INFO,
          code = nil, -- see :h diagnostic-structure
          display_opts = {}, -- see opts in vim.diagnostic.set
        },
        pipeline = {
          created = "",
          pending = "",
          preparing = "",
          scheduled = "",
          running = "ﰌ",
          canceled = "ﰸ",
          skipped = "ﰸ",
          success = "✓",
          failed = "",
        },
        colors = {
          discussion_tree = {
            username = "Keyword",
            date = "Comment",
            chevron = "DiffviewNonText",
            directory = "Directory",
            directory_icon = "DiffviewFolderSign",
            file_name = "Normal",
          },
        },
      }
    end,
    on_setup = function(config)
      require("gitlab").setup(config.setup)
    end,
    wk = function(_, categories)
      return {
        [categories.GIT] = {
          ["G"] = {
            ["r"] = {
              function()
                require("gitlab").review()
              end,
              "gitlab review",
            },
            ["s"] = {
              function()
                require("gitlab").summary()
              end,
              "gitlab summary",
            },
            ["a"] = {
              function()
                require("gitlab").approve()
              end,
              "gitlab mr approve",
            },
            ["A"] = {
              function()
                require("gitlab").revoke()
              end,
              "gitlab mr revoke",
            },
            ["c"] = {
              function()
                require("gitlab").create_comment()
              end,
              "gitlab mr create comment",
            },
            ["m"] = {
              function()
                require("gitlab").move_to_discussion_tree_from_diagnostic()
              end,
              "gitlab mr move to discussion tree",
            },
            ["n"] = {
              function()
                require("gitlab").create_note()
              end,
              "gitlab mr create note",
            },
            ["d"] = {
              function()
                require("gitlab").toggle_discussions()
              end,
              "gitlab mr toggle discussions",
            },
            ["p"] = {
              function()
                require("gitlab").pipeline()
              end,
              "gitlab mr pipeline",
            },
            ["f"] = {
              function()
                require("gitlab").open_in_browser()
              end,
              "gitlab mr open in browser",
            },
          },
        },
      }
    end,
    wk_v = function(_, categories)
      return {
        [categories.GIT] = {
          ["G"] = {
            ["c"] = {
              function()
                require("gitlab").create_multiline_comment()
              end,
              "gitlab mr create comment",
            },
          },
        },
      }
    end,
  })
end

return M
