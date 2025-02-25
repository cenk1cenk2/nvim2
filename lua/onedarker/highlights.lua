local c = require("onedarker.colors")

local M = {}
local hl = { langs = {}, plugins = {} }

---@type table<string, vim.api.keyset.highlight>
hl.common = {
  Bold = { bold = true },
  Italic = { italic = true },
  Underlined = { underline = true },

  -- MsgArea = { fg = c.fg, bg = c.bg[200] }, -- Area for messages and cmdline, don't set this highlight because of https://github.com/neovim/neovim/issues/17832
  EndOfBuffer = { fg = c.bg[200], bg = c.bg[200] },
  FoldColumn = { fg = c.fg, bg = c.bg[200] },
  ModeMsg = { fg = c.fg, bg = c.bg[200], bold = true },
  MsgSeparator = { fg = c.fg, bg = c.bg[300] },
  Normal = { fg = c.fg, bg = c.bg[200] },
  SignColumn = { fg = c.fg, bg = c.bg[200] },
  Terminal = { fg = c.fg, bg = c.bg[200] },
  WinBar = { fg = c.gray[900] },
  WinBarNc = { link = "WinBar" },
  WinSeparator = { fg = c.bg[300] },

  Cursor = { reverse = true },
  vCursor = { bg = c.cursor },
  iCursor = { reverse = true },
  lCursor = { bg = c.cursor },
  CursorIM = { reverse = true },
  CursorColumn = { bg = c.bg[300] },
  CursorLine = { bg = c.bg[300] },
  ColorColumn = { bg = c.bg[300] },
  CursorLineNr = { fg = c.fg },
  Visual = { bg = c.bg[400] },
  VisualNOS = { fg = c.none, bg = c.bg[400] },
  TermCursorNC = { bg = c.cursor },
  LineNr = { fg = c.gray[600] },
  Conceal = { fg = c.gray[600], bg = c.bg[300] },
  Folded = { fg = c.fg, bg = c.cyan[100] },
  NormalNC = { fg = c.fg, bg = c.bg[200] },
  NormalSB = { fg = c.fg, bg = c.bg[200] },
  BufferlineFill = { bg = c.bg[100] },

  DiffAdd = { fg = c.none, bg = c.diff.add },
  DiffAdded = { fg = c.diff.add_bright },
  DiffChange = { fg = c.none, bg = c.diff.change },
  DiffDelete = { fg = c.none, bg = c.diff.delete },
  DiffFile = { fg = c.diff.text_bright },
  DiffIndexLine = { fg = c.diff.change_bright },
  DiffRemoved = { fg = c.diff.delete_bright },
  DiffText = { fg = c.none, bg = c.diff.text },
  QuickFixLine = { fg = c.blue[600] },

  ErrorMsg = { fg = c.red[600], bold = true, bg = c.bg[200] },
  MoreMsg = { fg = c.cyan[600], bold = true },
  Question = { fg = c.yellow[600] },
  WarningMsg = { fg = c.orange[600], bold = true, bg = c.bg[200] },

  IncSearch = { bg = c.bg[400] },
  CurSearch = { bg = c.bg[500] },
  Search = { bg = c.bg[400] },
  Substitute = { fg = c.bg[500], bg = c.orange[600] },
  MatchParen = { fg = c.blue[600], underline = true },
  MatchParenCur = { underline = true },
  MatchWord = { underline = true },
  MatchWordCur = { underline = true },
  WildMenu = { fg = c.fg, bg = c.blue[300] },
  Directory = { fg = c.blue[600] },
  Ignore = { fg = c.cyan[600], bg = c.bg[200], bold = true },
  NonText = { fg = c.gray[600] },

  ExtraWhitespace = { bg = c.red[600] },
  Whitespace = { fg = c.red[600] },

  SpellBad = { fg = c.red[600], sp = c.red[600] },
  SpellCap = { fg = c.yellow[600], sp = c.yellow[600] },
  SpellLocal = { fg = c.blue[600], sp = c.blue[600] },
  SpellRare = { fg = c.purple[600], sp = c.purple[600] },

  ToolbarLine = { fg = c.fg },

  TabLine = { fg = c.fg, bg = c.bg[300] },
  TabLineFill = { fg = c.gray[600], bg = c.bg[200] },
  TabLineSel = { fg = c.fg, bg = c.bg[200] },

  StatusLine = { fg = c.fg, bg = c.bg[300] },
  StatusLineNC = { fg = c.gray[600], bg = c.bg[400] },
  StatusLineTerm = { fg = c.bg[200], bg = c.bg[300] },
  StatusLineTermNC = { fg = c.bg[200], bg = c.bg[400] },

  FloatBorder = { fg = c.blue[300], bg = c.bg[200] },
  FloatShadow = { bg = c.bg[200] },
  FloatShadowThrough = { bg = c.bg[200] },
  FloatTitle = { fg = c.green[300] },
  NormalFloat = { bg = c.bg[200] },

  Pmenu = { link = "NormalFloat" },
  PmenuSbar = { fg = c.none, bg = c.bg[300] },
  PmenuSel = { fg = c.none, bg = c.blue[900] },
  PmenuThumb = { fg = c.none, bg = c.gray[600] },

  SpecialKey = { fg = c.gray[600] },
  ToolbarButton = { fg = c.bg[200], bg = c.blue[900] },

  debugBreakpoint = { fg = c.bg[200], bg = c.red[600] },
  debugPC = { fg = c.bg[200], bg = c.cyan[600] },

  Bookmark = { fg = c.orange[600] },
}

---@type table<string, vim.api.keyset.highlight>
hl.syntax = {
  Boolean = { link = "@boolean" },
  Character = { link = "@character" },
  Comment = { link = "@comment" },
  Conditional = { link = "@conditional" },
  Constant = { link = "@constant" },
  Debug = { link = "@debug" },
  Define = { link = "@define" },
  Delimiter = { link = "@punctuation.delimiter" },
  Error = { link = "@error" },
  Exception = { link = "@exception" },
  Float = { link = "@float" },
  Function = { link = "@function" },
  Identifier = { link = "@field" },
  Include = { link = "@include" },
  Keyword = { link = "@keyword" },
  Label = { link = "@label" },
  Macro = { link = "@constant.macro" },
  Number = { link = "@number" },
  Operator = { link = "@operator" },
  PreCondit = { link = "@preproc" },
  PreProc = { link = "@preproc" },
  Repeat = { link = "@repeat" },
  Special = { link = "@string.special" },
  SpecialChar = { link = "@character.special" },
  SpecialComment = { link = "@comment" },
  Statement = { link = "@define" },
  StorageClass = { link = "@storageclass" },
  String = { link = "@string" },
  Structure = { link = "@constant" },
  Tag = { link = "@tag" },
  Title = { link = "@text.title" },
  Todo = { link = "@todo" },
  Type = { link = "@type" },
  Typedef = { link = "@type.definition" },
  Variable = { link = "@variable" },
}

---@type table<string, vim.api.keyset.highlight>
hl.treesitter = {
  -- ["@readonly"] = { fg = c.yellow[300] },
  ["@annotation"] = { fg = c.fg },
  ["@attribute"] = { fg = c.cyan[600] },
  ["@boolean"] = { fg = c.orange[600] },
  ["@character"] = { fg = c.fg },
  ["@character.special"] = { fg = c.fg },
  ["@class"] = { fg = c.orange[900] },
  ["@comment"] = { fg = c.gray[600], italic = true },
  ["@comment.error"] = { fg = c.gray[600], bg = c.red[300], italic = true },
  ["@comment.note"] = { fg = c.gray[600], bg = c.blue[300], italic = true },
  ["@comment.warning"] = { fg = c.gray[600], bg = c.yellow[300], italic = true },
  ["@constant"] = { fg = c.yellow[600] },
  ["@constant.builtin"] = { fg = c.orange[600] },
  ["@constant.macro"] = { fg = c.orange[600] },
  ["@constructor"] = { fg = c.yellow[600] },
  ["@debug"] = { fg = c.gray[600] },
  ["@decorator"] = { fg = c.cyan[600] },
  ["@diff.delta"] = { link = "DiffChange" },
  ["@diff.minus"] = { link = "DiffRemoved" },
  ["@diff.plus"] = { link = "DiffAdded" },
  ["@enum"] = { fg = c.yellow[900] },
  ["@enumMember"] = { fg = c.yellow[900] },
  ["@error"] = { fg = c.red[600] },
  ["@event"] = { fg = c.cyan[600] },
  ["@exception"] = { link = "@keyword.exception" },
  ["@function"] = { fg = c.blue[600] },
  ["@function.builtin"] = { fg = c.cyan[600] },
  ["@function.call"] = { fg = c.blue[600] },
  ["@function.macro"] = { fg = c.cyan[600] },
  ["@inlayhint"] = { italic = true, bg = c.bg[300], fg = c.bg[600] },
  ["@interface"] = { fg = c.yellow[600] },
  ["@keyword"] = { fg = c.purple[600] },
  ["@keyword.conditional"] = { fg = c.purple[600] },
  ["@keyword.directive"] = { fg = c.purple[600] },
  ["@keyword.directive.define"] = { fg = c.purple[600] },
  ["@keyword.exception"] = { fg = c.purple[600] },
  ["@keyword.export"] = { fg = c.purple[600] },
  ["@keyword.function"] = { fg = c.purple[600] },
  ["@keyword.import"] = { fg = c.purple[600] },
  ["@keyword.operator"] = { fg = c.purple[600] },
  ["@keyword.repeat"] = { fg = c.purple[600] },
  ["@keyword.return"] = { fg = c.purple[600] },
  ["@keyword.storage"] = { fg = c.yellow[600] },
  ["@label"] = { fg = c.red[600] },
  ["@markup"] = { fg = c.fg },
  ["@markup.emphasis"] = { standout = true },
  ["@markup.environment"] = { fg = c.fg },
  ["@markup.environment.name"] = { fg = c.fg },
  ["@markup.heading"] = { fg = c.yellow[600] },
  ["@markup.heading.1.markdown"] = { bg = c.bg[300], fg = c.yellow[900], bold = true },
  ["@markup.heading.2.markdown"] = { bg = c.bg[300], fg = c.orange[900], bold = true },
  ["@markup.heading.3.markdown"] = { bg = c.bg[300], fg = c.yellow[600], bold = true },
  ["@markup.heading.4.markdown"] = { bg = c.bg[300], fg = c.orange[600], underline = true },
  ["@markup.heading.5.markdown"] = { bg = c.bg[300], fg = c.yellow[300], underline = true },
  ["@markup.heading.6.markdown"] = { bg = c.bg[300], fg = c.orange[300], underline = true },
  ["@markup.link"] = { fg = c.cyan[600] },
  ["@markup.link.url"] = { fg = c.cyan[300], underline = true },
  ["@markup.list.checked"] = { fg = c.green[600] },
  ["@markup.list.unchecked"] = { fg = c.yellow[600] },
  ["@markup.math"] = { fg = c.yellow[600] },
  ["@markup.raw"] = { fg = c.green[300] },
  ["@markup.strikethrough"] = { strikethrough = true },
  ["@markup.strong"] = { bold = true },
  ["@markup.underline"] = { underline = true },
  ["@modifier"] = { fg = c.cyan[600] },
  ["@module"] = { fg = c.orange[600] },
  ["@none"] = { fg = c.fg },
  ["@number"] = { fg = c.orange[600] },
  ["@number.float"] = { fg = c.orange[600] },
  ["@operator"] = { fg = c.cyan[600] },
  ["@parameter.reference"] = { fg = c.fg },
  ["@property"] = { fg = c.red[600] },
  ["@punctuation.bracket"] = { fg = c.yellow[900] },
  ["@punctuation.delimiter"] = { fg = c.fg },
  ["@punctuation.special"] = { fg = c.cyan[600] },
  ["@regexp"] = { fg = c.orange[300] },
  ["@string"] = { fg = c.green[600] },
  ["@string.escape"] = { fg = c.red[600] },
  ["@string.regexp"] = { fg = c.orange[600] },
  ["@string.special"] = { fg = c.red[600] },
  ["@string.special.symbol"] = { fg = c.red[600] },
  ["@string.special.url"] = { fg = c.cyan[600] },
  ["@struct"] = { fg = c.orange[900] },
  ["@tag"] = { fg = c.red[600] },
  ["@tag.attribute"] = { fg = c.orange[600] },
  ["@tag.delimiter"] = { fg = c.gray[900] },
  ["@todo"] = { fg = c.cyan[600] },
  ["@type"] = { fg = c.yellow[600] },
  ["@type.builtin"] = { fg = c.yellow[600] },
  ["@type.definition"] = { fg = c.yellow[600] },
  ["@type.qualifier"] = { fg = c.purple[900] },
  ["@typeParameter"] = { fg = c.yellow[600] },
  ["@variable"] = { fg = c.red[600] },
  ["@variable.builtin"] = { fg = c.yellow[600] },
  ["@variable.member"] = { link = "@variable" },
  ["@variable.parameter"] = { fg = c.red[900] },
  -- legacy
  ["@conditional"] = { link = "@keyword.conditional" },
  ["@define"] = { link = "@keyword.directive.define" },
  ["@field"] = { link = "@variable.member" },
  ["@float"] = { link = "number.float" },
  ["@include"] = { link = "@keyword.import" },
  ["@method"] = { link = "@function.method" },
  ["@method.call"] = { link = "@function.method.call" },
  ["@namespace"] = { link = "@module" },
  ["@parameter"] = { link = "@variable.parameter" },
  ["@preproc"] = { link = "@keyword.directive" },
  ["@repeat"] = { link = "@keyword.repeat" },
  ["@storageclass"] = { link = "@keyword.storage" },
  ["@string.regex"] = { link = "@string.regexp" },
  ["@symbol"] = { link = "@string.special.symbol" },
  ["@text"] = { link = "@markup" },
  ["@text.danger"] = { link = "comment.error" },
  ["@text.diff.add"] = { link = "@diff.plus" },
  ["@text.diff.delete"] = { link = "@diff.minus" },
  ["@text.emphasis"] = { link = "@markup.italic" },
  ["@text.environment"] = { link = "@markup.environment" },
  ["@text.environment.name"] = { link = "@markup.environment.name" },
  ["@text.literal"] = { link = "@markup.raw" },
  ["@text.math"] = { link = "@markup.math" },
  ["@text.note"] = { link = "comment.note" },
  ["@text.reference"] = { link = "@markup.link" },
  ["@text.strike"] = { link = "@markup.strikethrough" },
  ["@text.strong"] = { link = "@markup.strong" },
  ["@text.title"] = { link = "@markup.heading" },
  ["@text.todo"] = { link = "comment.warning" },
  ["@text.todo.checked"] = { link = "@markup.list.checked" },
  ["@text.todo.unchecked"] = { link = "@markup.list.unchecked" },
  ["@text.underline"] = { link = "@markup.underline" },
  ["@text.uri"] = { link = "@markup.link.url" },
  ["@text.warning"] = { link = "comment.warning" },
  ["exception"] = { link = "@keyword.exception" },
  ["text.uri"] = { link = "@markup.link.uri" },
}

---@type table<string, vim.api.keyset.highlight>
hl.lsp = {
  DiagnosticError = { fg = c.red[600] },
  DiagnosticFloatingError = { link = "DiagnosticError" },
  DiagnosticFloatingHint = { link = "DiagnosticHint" },
  DiagnosticFloatingInfo = { link = "DiagnosticInfo" },
  DiagnosticFloatingWarn = { link = "DiagnosticWarn" },
  DiagnosticHint = { fg = c.blue[300] },
  DiagnosticInformation = { fg = c.cyan[300] },
  DiagnosticSignError = { link = "DiagnosticError" },
  DiagnosticSignHint = { link = "DiagnosticHint" },
  DiagnosticSignInfo = { link = "DiagnosticInfo" },
  DiagnosticSignWarn = { link = "DiagnosticWarn" },
  DiagnosticUnderlineError = { sp = c.red[600], undercurl = true },
  DiagnosticUnderlineHint = {},
  DiagnosticUnderlineInfo = {},
  DiagnosticUnderlineWarn = { sp = c.orange[600], undercurl = true },
  DiagnosticVirtualTextError = { link = "DiagnosticError" },
  DiagnosticVirtualTextHint = { link = "DiagnosticHint" },
  DiagnosticVirtualTextInfo = { link = "DiagnosticInfo" },
  DiagnosticVirtualTextWarning = { link = "DiagnosticWarn" },
  DiagnosticWarning = { fg = c.orange[600] },
  LspCodeLens = { fg = c.gray[600], bold = true },
  LspDiagnosticsDefaultError = { link = "DiagnosticError" },
  LspDiagnosticsDefaultHint = { link = "DiagnosticHint" },
  LspDiagnosticsDefaultInformation = { link = "DiagnosticInformation" },
  LspDiagnosticsDefaultWarning = { link = "DiagnosticWarn" },
  LspDiagnosticsError = { link = "DiagnosticError" },
  LspDiagnosticsFloatingError = { link = "DiagnosticFloatingError" },
  LspDiagnosticsFloatingHint = { link = "DiagnosticFloatingHint" },
  LspDiagnosticsFloatingInformation = { link = "DiagnosticFloatingInfo" },
  LspDiagnosticsFloatingWarning = { link = "DiagnosticFloatingWarn" },
  LspDiagnosticsHint = { link = "DiagnosticHint" },
  LspDiagnosticsInformation = { link = "DiagnosticInfo" },
  LspDiagnosticsSignError = { link = "DiagnosticSignError" },
  LspDiagnosticsSignHint = { link = "DiagnosticSignHint" },
  LspDiagnosticsSignInformation = { link = "DiagnosticSignInfo" },
  LspDiagnosticsSignWarning = { link = "DiagnosticSignWarn" },
  LspDiagnosticsUnderlineError = { link = "DiagnosticUnderlineError" },
  LspDiagnosticsUnderlineHint = { link = "DiagnosticUnderlineHint" },
  LspDiagnosticsUnderlineInformation = { link = "DiagnosticUnderlineInfo" },
  LspDiagnosticsUnderlineWarning = { link = "DiagnosticUnderlineWarn" },
  LspDiagnosticsVirtualTextError = { link = "DiagnosticVirtualTextError" },
  LspDiagnosticsVirtualTextHint = { link = "DiagnosticVirtualTextHint" },
  LspDiagnosticsVirtualTextInformation = { link = "DiagnosticVirtualTextInfo" },
  LspDiagnosticsVirtualTextWarning = { link = "DiagnosticVirtualTextWarn" },
  LspDiagnosticsWarning = { link = "DiagnosticWarn" },
  LspInlayHint = { link = "@inlayhint" },
  LspReferenceRead = { bg = c.bg[300] },
  LspReferenceText = { bg = c.bg[300] },
  LspReferenceWrite = { bg = c.bg[300] },
  LspReferenceTarget = { bg = c.bg[300] },
  LspSignatureActiveParameter = { bg = c.bg[400], bold = true },
}

-- langs

---@type table<string, vim.api.keyset.highlight>
hl.langs.bash = {
  ["@lsp.type.parameter.bash"] = { fg = c.fg },
}

---@type table<string, vim.api.keyset.highlight>
hl.langs.dockerfile = {
  ["@lsp.type.parameter.dockerfile"] = { fg = c.fg },
}

---@type table<string, vim.api.keyset.highlight>
hl.langs.terraform = {
  ["@lsp.type.type.terraform"] = { fg = c.purple[600] },
  ["@lsp.type.keyword.terraform"] = { fg = c.yellow[600] },
}

---@type table<string, vim.api.keyset.highlight>
hl.langs.jinja = {
  jinjaFilter = { fg = c.blue[600] },
  jinjaOperator = { fg = c.yellow[600] },
  jinjaStatement = { fg = c.purple[600] },
  jinjaTagBlock = { fg = c.yellow[600] },
  jinjaVarBlock = { fg = c.red[600] },
  jinjaVarDelim = { fg = c.yellow[900] },
  jinjaVariable = { fg = c.red[600] },
}

---@type table<string, vim.api.keyset.highlight>
hl.langs.typescript = {
  -- ["@decorator.typescript"] = { fg = c.fg },
  ["@lsp.type.parameter.typescript"] = { fg = c.red[900] },
  ["@lsp.typemod.variable.readonly.typescript"] = { fg = c.red[300] },
}

---@type table<string, vim.api.keyset.highlight>
hl.langs.typescriptreact = {
  ["@tag.tsx"] = { fg = c.yellow[600] },
}

---@type table<string, vim.api.keyset.highlight>
hl.langs.c = {
  ["@lsp.type.comment.c"] = {},
}

---@type table<string, vim.api.keyset.highlight>
hl.langs.markdown = {
  ["@nospell.markdown_inline"] = {},
  ["@spell.markdown"] = {},
  ["@markup.raw.markdown_inline"] = { link = "@string" },
}

---@type table<string, vim.api.keyset.highlight>
hl.langs.gitignore = {
  ["@string.special.path.gitignore"] = {},
  ["@character.special.gitignore"] = { fg = c.cyan[600] },
}

-- plugins

---@type table<string, vim.api.keyset.highlight>
hl.plugins.whichkey = {
  WhichKey = { fg = c.red[600] },
  WhichKeyDesc = { fg = c.blue[600] },
  WhichKeyFloat = { bg = c.bg[200] },
  WhichKeyGroup = { fg = c.orange[600] },
  WhichKeySeperator = { fg = c.green[300] },
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.gitgutter = {
  GitGutterAdd = { fg = c.green[300] },
  GitGutterChange = { fg = c.cyan[900] },
  GitGutterDelete = { fg = c.red[900] },
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.hop = {
  HopNextKey = { fg = c.bg[100], bg = c.yellow[600], bold = true },
  HopNextKey1 = { fg = c.bg[200], bg = c.red[600], bold = true },
  HopNextKey2 = { fg = c.bg[200], bg = c.red[900], bold = true },
  HopUnmatched = { fg = c.none, bg = c.none },
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.leap = {
  -- LeapBackdrop = { link = "Comment" },
  LeapLabelPrimary = { fg = c.bg[200], bg = c.red[600], bold = true },
  LeapLabelSecondary = { fg = c.bg[200], bg = c.orange[600], bold = true },
  LeapLabelSelected = { fg = c.bg[200], bg = c.blue[600], bold = true },
  LeapMatch = { fg = c.bg[200], bg = c.cyan[600], bold = true },
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.flash = {
  -- FlashBackdrop = { link = "Comment" },
  FlashCurrent = { fg = c.bg[200], bg = c.blue[900], bold = true },
  FlashLabel = { fg = c.bg[200], bg = c.orange[600], bold = true },
  FlashMatch = { fg = c.bg[200], bg = c.cyan[600], bold = true },
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.vim_illuminate = {
  IlluminatedWordRead = { bg = c.bg[300] },
  IlluminatedWordText = { bg = c.bg[300] },
  IlluminatedWordWrite = { bg = c.bg[300] },
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.indentblankline = {
  IndentBlankLineChar = { fg = c.bg[500] },
  IndentBlanklineContextChar = { fg = c.cursor },
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.diffview = {
  DiffviewCursorLine = hl.common.CursorLine,
  DiffviewEndOfBuffer = hl.common.EndOfBuffer,
  DiffviewFilePanelCounter = { fg = c.purple[600], bold = true },
  DiffviewFilePanelDeletions = { fg = c.red[600] },
  DiffviewFilePanelFileName = { fg = c.fg },
  DiffviewFilePanelInsertions = { fg = c.green[300] },
  DiffviewFilePanelPath = { fg = c.gray[600] },
  DiffviewFilePanelRootPath = { fg = c.gray[600] },
  DiffviewFilePanelTitle = { fg = c.blue[600], bold = true },
  DiffviewNormal = hl.common.Normal,
  DiffviewSignColumn = hl.common.SignColumn,
  DiffviewStatusAdded = { fg = c.green[300] },
  DiffviewStatusBroken = { fg = c.red[600] },
  DiffviewStatusCopied = { fg = c.yellow[900] },
  DiffviewStatusDeleted = { fg = c.red[600] },
  DiffviewStatusLine = hl.common.StatusLine,
  DiffviewStatusLineNC = hl.common.StatusLineNC,
  DiffviewStatusModified = { fg = c.blue[600] },
  DiffviewStatusRenamed = { fg = c.yellow[600] },
  DiffviewStatusTypeChange = { fg = c.cyan[600] },
  DiffviewStatusUnknown = { fg = c.red[600] },
  DiffviewStatusUnmerged = { fg = c.orange[600] },
  DiffviewStatusUntracked = { fg = c.gray[600] },
  DiffviewVertSplit = hl.common.VertSplit,
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.gitsigns = {
  GitSignsAdd = { fg = c.green[300] },
  GitSignsAddLn = { fg = c.green[300] },
  GitSignsAddNr = { fg = c.green[300] },
  GitSignsChange = { fg = c.blue[600] },
  GitSignsChangeLn = { fg = c.blue[600] },
  GitSignsChangeNr = { fg = c.blue[600] },
  GitSignsDelete = { fg = c.red[600] },
  GitSignsDeleteLn = { fg = c.red[600] },
  GitSignsDeleteNr = { fg = c.red[600] },
  GitSignsTopdelete = { fg = c.red[300] },
  GitSignsTopdeleteLn = { fg = c.red[300] },
  GitSignsTopdeleteNr = { fg = c.red[300] },
  GitSignsChangedelete = { fg = c.red[900] },
  GitSignsChangedeleteLn = { fg = c.red[900] },
  GitSignsChangedeleteNr = { fg = c.red[900] },
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.nvim_tree = {
  NvimTreeEndOfBuffer = { fg = c.bg[200], bg = c.bg[200] },
  NvimTreeFolderName = { fg = c.blue[600] },
  NvimTreeGitDeleted = { fg = c.red[600] },
  NvimTreeGitDirty = { fg = c.orange[600] },
  NvimTreeGitNew = { fg = c.green[300] },
  NvimTreeImageFile = { fg = c.purple[600] },
  NvimTreeIndentMarker = { fg = c.fg },
  NvimTreeNormal = { fg = c.fg, bg = c.bg[200] },
  NvimTreeRootFolder = { fg = c.purple[600], bold = true },
  NvimTreeSpecialFile = { fg = c.yellow[600] },
  NvimTreeSymlink = { fg = c.purple[600] },
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.neotree_nvim = {
  NeoTreeBufferNumber = {},
  NeoTreeCursorLine = {},
  NeoTreeDimText = { fg = c.bg[500] },
  NeoTreeDirectoryIcon = {},
  NeoTreeDirectoryName = {},
  NeoTreeDotfile = { fg = c.bg[700] },
  NeoTreeExpander = { fg = c.bg[500] },
  NeoTreeFadeText1 = {},
  NeoTreeFadeText2 = {},
  NeoTreeFileIcon = {},
  NeoTreeFileName = {},
  NeoTreeFileNameOpened = {},
  NeoTreeFilterTerm = {},
  NeoTreeFloatBorder = {},
  NeoTreeFloatTitle = {},
  NeoTreeGitAdded = { fg = c.file.add },
  NeoTreeGitConflict = { fg = c.file.conflict },
  NeoTreeGitDeleted = { fg = c.file.delete },
  NeoTreeGitIgnored = { fg = c.file.ignored },
  NeoTreeGitModified = { fg = c.file.modified },
  NeoTreeGitRenamed = { fg = c.file.renamed },
  NeoTreeGitUntracked = { fg = c.file.untracked },
  NeoTreeHiddenByName = {},
  NeoTreeIndentMarker = { fg = c.bg[400] },
  NeoTreeModified = { fg = c.file.change },
  NeoTreeNormal = {},
  NeoTreeNormalNC = {},
  NeoTreeRootName = {},
  NeoTreeSymbolicLinkTarget = { fg = c.file.symbolic_link },
  NeoTreeTitleBar = {},
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.telescope = {
  -- TelescopePreviewBorder = { fg = c.grey[100], bg = c.grey[100] },
  Prompt = { bg = c.bg[200] },
  TelescopeBorder = { fg = c.bg[100], bg = c.bg[100] },
  TelescopeMatching = { fg = c.green[300] },
  TelescopeNormal = { bg = c.bg[200] },
  TelescopePreviewTitle = { fg = c.bg[100], bg = c.green[600] },
  TelescopePromptBorder = { fg = c.bg[100], bg = c.bg[100] },
  TelescopePromptNormal = { fg = c.white, bg = c.bg[100] },
  TelescopePromptPrefix = { fg = c.yellow[600], bg = c.bg[100] },
  TelescopePromptTitle = { fg = c.bg[100], bg = c.red[600] },
  TelescopeResultsDiffAdd = { fg = c.green[600] },
  TelescopeResultsDiffChange = { fg = c.yellow[600] },
  TelescopeResultsDiffDelete = { fg = c.red[600] },
  TelescopeResultsNormal = { bg = c.bg[100] },
  TelescopeResultsTitle = { fg = c.bg[100], bg = c.bg[100] },
  TelescopeSelection = { bg = c.bg[300], fg = c.white },
  TelescopeSelectionCaret = { fg = c.yellow[600] },
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.dashboard = {
  DashboardCenter = { fg = c.yellow[600] },
  DashboardFooter = { fg = c.gray[600], bold = true },
  DashboardHeader = { fg = c.orange[600] },
  DashboardShortcut = { fg = c.fg },
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.spectre = {
  SpectreChange = { fg = c.yellow[600] },
  SpectreDelete = { fg = c.green[300] },
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.nvim_cmp = {
  CmpDocumentation = { fg = c.fg },
  CmpDocumentationBorder = { fg = c.bg[500] },
  CmpItemAbbr = { fg = c.fg },
  CmpItemAbbrDeprecated = { fg = c.gray[600] },
  CmpItemAbbrMatch = { fg = c.green[300] },
  CmpItemAbbrMatchFuzzy = { fg = c.yellow[300] },
  CmpItemKind = { fg = c.orange[300] },
  CmpItemKindCopilot = { fg = c.red[900] },
  CmpItemKindDefault = { fg = c.orange[300] },
  CmpItemMenu = { fg = c.gray[600] },
  CmpItemMenuDefault = { fg = c.fg },
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.blink_cmp = {
  BlinkCmpMenu = { link = "NormalFloat" },
  BlinkCmpMenuBorder = { link = "FloatBorder" },
  BlinkCmpSignatureHelpBorder = { link = "FloatBorder" },
  BlinkCmpDocBorder = { link = "FloatBorder" },
  BlinkCmpMenuSelection = { bg = c.gray[300] },
  BlinkCmpLabelMatch = { bg = c.bg[400] },
  BlinkCmpKind = { fg = c.orange[300] },
  BlinkCmpKindCopilot = { fg = c.red[900] },
  BlinkCmpSource = { fg = c.gray[600] },
  BlinkCmpLabelDeprecated = { fg = c.gray[600] },
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.fidget = {
  FidgetTask = { fg = c.orange[300] },
  FidgetTitle = { fg = c.green[300] },
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.noice = {
  NoiceLspProgressClient = { fg = c.orange[300] },
  NoiceLspProgressSpinner = { fg = c.yellow[300] },
  NoiceLspProgressTitle = { fg = c.green[300] },
  NoiceMini = { link = "NormalFloat" },
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.notify = {
  NotifyDEBUGBody = { fg = c.fg },
  NotifyDEBUGBorder = { fg = c.cyan[600] },
  NotifyDEBUGIcon = { fg = c.cyan[600] },
  NotifyDEBUGTitle = { fg = c.cyan[600] },
  NotifyERRORBody = { fg = c.fg },
  NotifyERRORBorder = { fg = c.red[600] },
  NotifyERRORIcon = { fg = c.red[600] },
  NotifyERRORTitle = { fg = c.red[600] },
  NotifyINFOBody = { fg = c.fg },
  NotifyINFOBorder = { fg = c.green[300] },
  NotifyINFOIcon = { fg = c.green[300] },
  NotifyINFOTitle = { fg = c.green[300] },
  NotifyTRACEBody = { fg = c.fg },
  NotifyTRACEBorder = { fg = c.gray[600] },
  NotifyTRACEIcon = { fg = c.gray[600] },
  NotifyTRACETitle = { fg = c.gray[600] },
  NotifyWARNBody = { fg = c.fg },
  NotifyWARNBorder = { fg = c.orange[600] },
  NotifyWARNIcon = { fg = c.orange[600] },
  NotifyWARNTitle = { fg = c.orange[600] },
}

-- https://github.com/folke/snacks.nvim?tab=readme-ov-file#-highlight-groups
---@type table<string, vim.api.keyset.highlight>
hl.plugins.snacks = {
  SnacksDashboardDesc = { fg = c.fg, bold = true },
  SnacksDashboardIcon = { fg = c.green[600] },
  SnacksDashboardFile = { fg = c.blue[600] },
  SnacksDashboardSpecial = { fg = c.orange[900], bold = true },
  SnacksDashboardHeader = { fg = c.orange[600] },
  SnacksIndent = { fg = c.bg[500] },
  SnacksIndentScope = { fg = c.cursor },
  SnacksIndentChunk = { fg = c.cursor },
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.vim_visual_multi = {
  VM_Cursor = { bg = c.blue[900] },
  VM_Extend = { bg = c.blue[300] },
  VM_Insert = { fg = c.none, bg = c.blue[300] },
  VM_Mono = { fg = c.none, bg = c.blue[600] },
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.symbols_outline = {
  FocusedSymbol = { bg = c.bg[300] },
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.aerojump = {
  SearchHighlight = { bg = c.green[300] },
  SearchResult = { bg = c.yellow[600] },
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.hlslens = {
  HlSearchFloat = { link = "IncSearch" },
  HlSearchLens = { link = "WildMenu" },
  HlSearchLensNear = { link = "IncSearch" },
  HlSearchNear = { link = "IncSearch" },
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.lspsaga = {
  ActionPreviewBorder = { fg = c.yellow[600] },
  CodeActionBorder = { fg = c.yellow[300] },
  DiagnosticBorder = { fg = c.bg[200] },
  DiagnosticErrorBorder = { link = "DiagnosticError" },
  DiagnosticHintBorder = { link = "DiagnosticHint" },
  DiagnosticInfoBorder = { link = "DiagnosticInfo" },
  DiagnosticWarnBorder = { link = "DiagnosticWarn" },
  FinderBorder = { fg = c.cyan[300] },
  FinderPreviewBorder = { fg = c.cyan[600] },
  HoverBorder = { fg = c.orange[600] },
  RenameBorder = { fg = c.purple[600] },
  SagaBeacon = { bg = c.yellow[300] },
  SagaBorder = { fg = c.bg[600] },
  SagaFileName = { fg = c.gray[900] },
  SagaFolderName = { fg = c.gray[900] },
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.autopairs = {
  AutoPairsFastWrap = { bg = c.orange[600], fg = c.black },
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.treesitter_rainbow = {
  TSRainbow1 = { fg = c.yellow[900] },
  TSRainbow2 = { fg = c.cyan[900] },
  TSRainbow3 = { fg = c.orange[900] },
  TSRainbow4 = { fg = c.blue[900] },
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.treesitter_context = {
  TreesitterContext = { bg = c.bg[300] },
  TreesitterContextBottom = { bg = c.bg[300] },
  TreesitterContextLineNumber = { fg = c.cyan[600] },
  TreesitterContextSeparator = { fg = c.bg[400], bg = c.bg[300] },
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.mini_icons = {
  MiniIconsAzure = { fg = c.blue[600] },
  MiniIconsBlue = { fg = c.blue[300] },
  MiniIconsCyan = { fg = c.cyan[300] },
  MiniIconsGreen = { fg = c.green[300] },
  MiniIconsGrey = { fg = c.gray[900] },
  MiniIconsOrange = { fg = c.orange[300] },
  MiniIconsPurple = { fg = c.purple[300] },
  MiniIconsRed = { fg = c.red[300] },
  MiniIconsYellow = { fg = c.yellow[300] },
}

---@type table<string, vim.api.keyset.highlight>
hl.plugins.symbol_usage_nvim = {
  ["SymbolUsageDef"] = { fg = c.purple[300], bold = true },
  ["SymbolUsageImpl"] = { fg = c.red[300], bold = true },
  ["SymbolUsageRef"] = { fg = c.yellow[300], bold = true },
}

function M.load_highlights(ns, highlights)
  for group_name, group_settings in pairs(highlights) do
    vim.api.nvim_set_hl(ns, group_name, group_settings)
  end
end

function M.setup()
  M.load_highlights(0, hl.common)
  M.load_highlights(0, hl.syntax)
  M.load_highlights(0, hl.lsp)

  for _, group in pairs(hl.langs) do
    M.load_highlights(0, group)
  end

  for _, group in pairs(hl.plugins) do
    M.load_highlights(0, group)
  end

  M.load_highlights(0, hl.treesitter)
end

return M
