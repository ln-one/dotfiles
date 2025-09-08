-- 禁用 LazyVim 默认插件
return {
  -- 明确禁用所有 tokyonight 相关的插件
  { "folke/tokyonight.nvim", enabled = false },
  
  -- 覆盖 LazyVim 的核心 colorscheme 插件
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
    },
  },
}
