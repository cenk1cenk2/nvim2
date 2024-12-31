local s = require("ck.utils.snippets")

local conventional_commits = {
  "feat",
  "fix",
  "docs",
  "style",
  "refactor",
  "perf",
  "test",
  "build",
  "ci",
  "chore",
  "revert",
}

local snippets = {
  s.s({
    trig = "sci",
    name = "skip-ci",
    desc = { "Skips the CI configuration in pipelines." },
  }, s.fmt("[skip-ci]", {})),
}

vim.list_extend(
  snippets,
  vim.tbl_map(function(value)
    return s.s(
      {
        trig = ("c%s"):format(value),
        name = value,
        desc = { "Conventional commit type: " .. value },
      },
      s.fmt(("%s: {}"):format(value), {
        s.i(1),
      })
    )
  end, conventional_commits)
)

vim.list_extend(
  snippets,
  vim.tbl_map(function(value)
    return s.s(
      {
        trig = ("s%s"):format(value),
        name = value,
        desc = { "Scoped Conventional commit type: " .. value },
      },
      s.fmt(("%s({}): {}"):format(value), {
        s.i(1),
        s.i(2),
      })
    )
  end, conventional_commits)
)

return snippets
