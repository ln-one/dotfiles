-- LazyVim 特定配置覆盖
-- 禁用 LazyVim 的默认 colorscheme 设置

-- 如果 LazyVim 尝试设置 colorscheme，我们需要覆盖它
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimColorScheme",
  callback = function()
    -- 阻止 LazyVim 设置默认的 tokyonight
    pcall(vim.cmd, "colorscheme catppuccin-mocha")
  end,
})

-- 确保 vim.g.colors_name 不为空
if not vim.g.colors_name then
  vim.g.colors_name = "default"
end
