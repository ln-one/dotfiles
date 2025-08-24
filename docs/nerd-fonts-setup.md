# Nerd Fonts 配置指南

本指南帮助你在各种终端中正确配置 Nerd Fonts，以便 Starship 提示符能够正确显示图标。

## 已安装的字体

通过 Chezmoi 自动安装的 Nerd Fonts：

- **JetBrains Mono Nerd Font** (推荐)
- **Meslo Nerd Font** (备选)

## 终端配置

### GNOME Terminal (Ubuntu 默认)

1. 打开 GNOME Terminal
2. 右键点击终端窗口 → 首选项
3. 选择当前配置文件
4. 点击 "文本" 标签
5. 取消勾选 "使用系统固定宽度字体"
6. 点击字体选择器
7. 搜索并选择 "JetBrains Mono Nerd Font"
8. 选择 Regular 或 Medium 样式
9. 点击 "选择" 保存

### Konsole (KDE 默认)

1. 打开 Konsole
2. 设置 → 编辑当前配置文件
3. 点击 "外观" 标签
4. 在 "字体" 部分点击 "选择"
5. 搜索 "JetBrains Mono Nerd Font"
6. 选择合适的样式和大小
7. 点击 "确定" 保存

### Alacritty

编辑配置文件 `~/.config/alacritty/alacritty.yml`：

```yaml
font:
  normal:
    family: "JetBrains Mono Nerd Font"
    style: Regular
  bold:
    family: "JetBrains Mono Nerd Font"
    style: Bold
  italic:
    family: "JetBrains Mono Nerd Font"
    style: Italic
  size: 12.0
```

### Kitty

编辑配置文件 `~/.config/kitty/kitty.conf`：

```conf
font_family      JetBrains Mono Nerd Font
bold_font        JetBrains Mono Nerd Font Bold
italic_font      JetBrains Mono Nerd Font Italic
bold_italic_font JetBrains Mono Nerd Font Bold Italic
font_size 12.0
```

### Terminator

1. 右键点击 Terminator 窗口
2. 选择 "首选项"
3. 在 "配置文件" 标签下选择默认配置文件
4. 取消勾选 "使用系统字体"
5. 点击字体选择器
6. 选择 "JetBrains Mono Nerd Font"
7. 点击 "关闭" 保存

### Tilix

1. 打开 Tilix
2. 首选项 → 配置文件 → 默认
3. 在 "文本" 部分取消勾选 "使用系统字体"
4. 选择 "JetBrains Mono Nerd Font"
5. 应用更改

### VS Code 集成终端

在 VS Code 设置中添加：

```json
{
    "terminal.integrated.fontFamily": "JetBrains Mono Nerd Font",
    "terminal.integrated.fontSize": 12
}
```

## 验证配置

### 1. 测试 Starship 提示符

```bash
# 启动新的 zsh 会话
zsh

# 或重新加载配置
source ~/.zshrc
```

### 2. 检查图标显示

正确配置后，你应该看到：

- 操作系统图标 (🐧 Linux)
- Git 分支图标 ()
- 编程语言图标 (🐍 Python, 🌐 Node.js 等)
- 彩色的分段提示符

## 故障排除

### 图标显示为方块或问号

**原因**: 终端没有使用 Nerd Font

**解决方案**:
1. 确认字体已安装: `fc-list | grep -i nerd`
2. 在终端设置中选择 Nerd Font
3. 重启终端应用程序

### 字体看起来很奇怪

**原因**: 可能选择了错误的字体样式

**解决方案**:
1. 选择 "Regular" 或 "Medium" 样式
2. 避免选择 "Mono" 版本 (除非特别需要)
3. 调整字体大小 (推荐 11-14px)

### Starship 提示符没有颜色

**原因**: 终端不支持真彩色或配置问题

**解决方案**:
1. 确保终端支持 256 色或真彩色
2. 检查 `$TERM` 环境变量
3. 尝试设置: `export TERM=xterm-256color`

### 性能问题

**原因**: 复杂的 Starship 配置可能影响性能

**解决方案**:
1. 在远程环境禁用部分模块
2. 使用更简单的主题
3. 调整 Starship 配置中的超时设置

## 推荐设置

### 桌面环境
- 字体: JetBrains Mono Nerd Font Regular
- 大小: 12px
- 行间距: 1.2

### 远程/服务器环境
- 字体: Hack Nerd Font Regular  
- 大小: 11px
- 简化的 Starship 配置

## 更多字体选择

如果需要其他 Nerd Fonts，可以手动安装：

```bash
# 下载其他字体
curl -L -o /tmp/font.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FontName.zip

# 解压到字体目录
unzip /tmp/font.zip -d ~/.local/share/fonts/

# 刷新字体缓存
fc-cache -fv ~/.local/share/fonts/
```

推荐的其他字体：
- Fira Code Nerd Font
- Source Code Pro Nerd Font  
- Cascadia Code Nerd Font
- Inconsolata Nerd Font

## 相关资源

- [Nerd Fonts 官网](https://www.nerdfonts.com/)
- [Starship 配置文档](https://starship.rs/config/)
- [Catppuccin 主题](https://github.com/catppuccin/catppuccin)