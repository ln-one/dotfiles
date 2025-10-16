return {
  {
    "akinsho/bufferline.nvim",
    dependencies = { "catppuccin" },
    config = function()
      -- 修复 Catppuccin bufferline 集成兼容性问题
      -- 确保在 LazyVim 使用前提供正确的 API
      local has_catppuccin, catppuccin_bufferline = pcall(require, "catppuccin.groups.integrations.bufferline")
      if has_catppuccin and catppuccin_bufferline then
        -- 确保 get 方法存在，兼容不同版本的 Catppuccin
        if not catppuccin_bufferline.get then
          if catppuccin_bufferline.get_theme then
            catppuccin_bufferline.get = catppuccin_bufferline.get_theme
          else
            -- 提供一个默认的空实现
            catppuccin_bufferline.get = function()
              return {}
            end
          end
        end
      end
    end,
  },
}