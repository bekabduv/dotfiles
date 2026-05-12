-- return {
--   { "catppuccin/nvim", name = "catppuccin", priority = 1000, opts = {
--     flavour = "latte",
--   } },
--   {
--     "LazyVim/LazyVim",
--     opts = {
--       colorscheme = "catppuccin",
--     },
--   },
-- }

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

-- return {
--   {
--     "craftzdog/solarized-osaka.nvim", -- Or another Solarized port like altercation/vim-colors-solarized
--     lazy = false, -- Load it at startup if it's your main theme
--     priority = 1000, -- Ensure it loads before others
--     opts = {
--       -- You can add options here, e.g., for transparency if supported
--       -- transparent = true, -- Example option for some themes
--       style = "light", -- Explicitly set to light mode
--     },
--   },
--   {
--     "LazyVim/LazyVim",
--     opts = {
--       colorscheme = "solarized-osaka", -- Match the theme name here
--     },
--   },
-- }

return {
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
      -- 1. Setup the base "Soft" environment
      vim.o.background = "light"
      vim.g.gruvbox_material_background = "soft"
      vim.g.gruvbox_material_foreground = "material"
      vim.g.gruvbox_material_better_performance = 1

      -- 2. Define our 7:1 AAA Compliant Palette
      local hc_bg = "#f2e5bc" -- The specific Gruvbox Light Soft background
      local hc_fg = "#282828"
      local colors = {
        comment = "#504841", -- 7.13:1
        string = "#4e4b09", -- 7.16:1
        functions = "#055160", -- 7.10:1
        keyword = "#990005", -- 7.09:1
        constant = "#65420a", -- 7.15:1
        type = "#65420b", -- 7.15:1
        number = "#73325b", -- 7.15:1
        operator = "#2b513a", -- 7.14:1
      }

      -- 3. Apply the overrides
      local group = vim.api.nvim_create_augroup("GruvboxHC", { clear = true })
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = group,
        callback = function()
          local hl = function(name, opts)
            vim.api.nvim_set_hl(0, name, opts)
          end

          -- Core UI
          hl("Normal", { bg = hc_bg, fg = hc_fg })
          hl("NormalFloat", { bg = hc_bg, fg = hc_fg })

          -- Syntax Highlighting (The 7:1 compliant set)
          hl("Comment", { fg = colors.comment, italic = true })
          hl("String", { fg = colors.string })
          hl("Function", { fg = colors.functions })
          hl("Keyword", { fg = colors.keyword, bold = true })
          hl("Statement", { fg = colors.keyword })
          hl("Type", { fg = colors.type })
          hl("Constant", { fg = colors.constant })
          hl("Number", { fg = colors.number })
          hl("Boolean", { fg = colors.number })
          hl("Operator", { fg = colors.operator })
          hl("@variable", { fg = "#3c3836" }) -- Original contrast was already high
        end,
      })

      vim.cmd.colorscheme("gruvbox-material")
    end,
  },
  -- Tell LazyVim to use this as the default theme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox-material",
    },
  },
}
