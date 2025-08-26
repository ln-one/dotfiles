return {
  {
    "akinsho/bufferline.nvim",
    init = function()
      -- 临时修复 Catppuccin bufferline API 变更
      -- 参考: https://github.com/LazyVim/LazyVim/pull/6354
      local bufline = require("catppuccin.groups.integrations.bufferline")
      function bufline.get()
        return bufline.get_theme()
      end
    end,
  },
}