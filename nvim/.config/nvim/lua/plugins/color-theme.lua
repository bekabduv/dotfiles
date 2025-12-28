return {
  { "catppuccin/nvim", name = "catppuccin", priority = 1000, opts = {
    flavour = "mocha",
  } },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
-- return {
--   {
--     "ellisonleao/gruvbox.nvim",
--     priority = 1000,
--     config = function()
--       require("gruvbox").setup({
--         contrast = "soft", -- can be "hard", "soft" or empty string
--       })
--     end,
--   },
--   {
--     "LazyVim/LazyVim",
--     opts = {
--       colorscheme = "gruvbox",
--     },
--   },
-- }
