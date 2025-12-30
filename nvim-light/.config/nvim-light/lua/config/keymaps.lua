-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
--- In ~/.config/nvim/lua/config/keymaps.lua

------------------- APPROACH 1 -------------------------------------
-- vim.keymap.set("o", "w", function()
--   return vim.v.operator == "d" and "iw" or vim.v.operator == "y" and "iw" or vim.v.operator == "c" and "iw" or "w" -- default motion for other cases
-- end, { expr = true })
--
-- -- Same for quotes
-- vim.keymap.set("o", '"', function()
--   return vim.v.operator and 'i"' or '"'
-- end, { expr = true })
--
-- vim.keymap.set("o", "'", function()
--   return vim.v.operator and "i'" or "'"
-- end, { expr = true })
------------------- APPROACH 1 END ---------------------------------

-- ----------------------- APPROACH 2 END ----------------------------
vim.keymap.set("o", "w", "iw", { desc = "Inner word" })
vim.keymap.set("o", '"', 'i"', { desc = "Inner double quotes" })
vim.keymap.set("o", "'", "i'", { desc = "Inner single quotes" })
vim.keymap.set("o", "`", "i`", { desc = "Inner backticks" })
vim.keymap.set("o", "(", "i(", { desc = "Inner parentheses" })
vim.keymap.set("o", ")", "i)", { desc = "Inner parentheses" })
vim.keymap.set("o", "{", "i{", { desc = "Inner braces" })
vim.keymap.set("o", "}", "i}", { desc = "Inner braces" })
vim.keymap.set("o", "[", "i[", { desc = "Inner brackets" })
vim.keymap.set("o", "]", "i]", { desc = "Inner brackets" })
vim.keymap.set("o", "<", "i<", { desc = "Inner <" })
vim.keymap.set("o", ">", "i>", { desc = "Inner >" })
-- ----------------------- APPROACH 2 END ----------------------------

-------------------------- APPROACH 3 ----------------------------
-- vim.keymap.set("n", "dw", "diw", { desc = "Delete inner word" })
-- vim.keymap.set("n", "cw", "ciw", { desc = "Change inner word" })
-- vim.keymap.set("n", "yw", "yiw", { desc = "Yank inner word" })
--
-- vim.keymap.set("n", 'd"', 'di"', { desc = "Delete inside double quotes" })
-- vim.keymap.set("n", 'c"', 'ci"', { desc = "Change inside double quotes" })
-- vim.keymap.set("n", 'y"', 'yi"', { desc = "Yank inside double quotes" })
--
-- vim.keymap.set("n", "d'", "di'", { desc = "Delete inside single quotes" })
-- vim.keymap.set("n", "c'", "ci'", { desc = "Change inside single quotes" })
-- vim.keymap.set("n", "y'", "yi'", { desc = "Yank inside single quotes" })
--
-- -- Optional: Add more text objects
-- vim.keymap.set("n", "d(", "di(", { desc = "Delete inside parentheses" })
-- vim.keymap.set("n", "c(", "ci(", { desc = "Change inside parentheses" })
-- vim.keymap.set("n", "y(", "yi(", { desc = "Yank inside parentheses" })
-------------------------- APPROACH 3 END ----------------------------
