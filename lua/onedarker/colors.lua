-- https://colordesigner.io/color-scheme-builder 6 palette

local colors = {
  none = nil,

  bg = {
    [100] = "#17191e",
    [200] = "#1e2127",
    [300] = "#22282f",
    [400] = "#2c333d",
    [500] = "#4b5263",
    [600] = "#5c6370",
    [700] = "#7c8a9d",
    [800] = "#979eab",
    [900] = "#abb2bf",
  },

  cursor = "#6c778d",
  fg = "#abb2bf",
  white = "#efefef",
  bright_white = "#ffffff",
  black = "#121212",

  gray = {
    [300] = "#38404b",
    [600] = "#5c6370",
    [900] = "#b0b0b0",
  },

  orange = {
    [300] = "#b07335",
    [600] = "#d19a66",
    [900] = "#f1b862",
  },

  red = {
    [100] = "#432023",
    [300] = "#ce7277",
    [600] = "#e06c75",
    [900] = "#ef9ea1",
  },

  yellow = {
    [100] = "#453a25",
    [300] = "#d3b051",
    [600] = "#e5c07b",
    [900] = "#eed5a8",
  },

  green = {
    [100] = "#2e3a24",
    [300] = "#729c0c",
    [600] = "#98c379",
    [900] = "#d4ff79",
  },

  blue = {
    [100] = "#1d3448",
    [300] = "#4676ac",
    [600] = "#61afef",
    [900] = "#98caf6",
  },

  cyan = {
    [100] = "#1a373a",
    [300] = "#348690",
    [600] = "#56b6c2",
    [900] = "#94ced6",
  },

  purple = {
    [300] = "#9e30bf",
    [600] = "#c678dd",
    [900] = "#daa6ea",
  },

  magenta = {
    [300] = "#730554",
    [600] = "#a40778",
    [900] = "#ca6da4",
  },
}

colors.diff = {
  add = colors.green[100],
  delete = colors.red[100],
  text = colors.blue[100],
  change = colors.yellow[100],
  add_bright = colors.green[600],
  delete_bright = colors.red[600],
  text_bright = colors.blue[600],
  change_bright = colors.cyan[600],
}

colors.file = {
  add = colors.green[300],
  delete = colors.red[300],
  change = colors.blue[300],
  conflict = colors.red[600],
  modified = colors.yellow[300],
  renamed = colors.orange[300],
  untracked = colors.green[600],
  ignored = colors.gray[600],
  symbolic_link = colors.cyan[300],
}

return colors
