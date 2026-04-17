vim.o.termguicolors = false
vim.cmd.colorscheme("habamax")

-- 背景を透明にする（Ghosttyの透過設定を活かす）
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })