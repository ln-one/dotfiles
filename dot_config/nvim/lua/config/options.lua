-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- Add any additional options here

-- 设置一个安全的默认 colorscheme，防止 tokyonight 加载错误
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 尝试设置 catppuccin，如果不可用则使用内置的暗色主题
local ok, _ = pcall(vim.cmd, "colorscheme catppuccin-mocha")
if not ok then
  vim.cmd("colorscheme default")
  vim.o.background = "dark"
end
