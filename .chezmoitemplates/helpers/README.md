# 辅助模板使用示例

这个文件展示了如何使用新创建的辅助模板。

## 使用方法

### 1. tool-check.sh - 工具检测

```bash
# 基本用法
{{ includeTemplate "helpers/tool-check.sh" (dict "tool" "git") }}

# 带功能开关
{{ includeTemplate "helpers/tool-check.sh" (dict 
    "tool" "starship" 
    "feature" .features.enable_starship 
    "found" "eval \"$(starship init zsh)\"" 
) }}

# 自定义错误消息
{{ includeTemplate "helpers/tool-check.sh" (dict 
    "tool" "fzf" 
    "feature" .features.enable_fzf 
    "found" "source ~/.fzf.zsh" 
    "notFound" "echo \"建议安装 fzf: brew install fzf\"" 
) }}

# 必需工具
{{ includeTemplate "helpers/tool-check.sh" (dict 
    "tool" "git" 
    "required" true
    "notFound" "echo \"Git 是必需的，请先安装\"; exit 1" 
) }}

# 静默模式
{{ includeTemplate "helpers/tool-check.sh" (dict 
    "tool" "optional-tool" 
    "silent" true
    "found" "setup_optional_tool" 
) }}
```

### 2. defer-load.sh - 延迟加载

```bash
# 基本延迟加载
{{ includeTemplate "helpers/defer-load.sh" (dict 
    "command" "eval \"$(starship init zsh)\"" 
) }}

# 带条件的延迟加载
{{ includeTemplate "helpers/defer-load.sh" (dict 
    "command" "source ~/.fzf.zsh" 
    "condition" .features.enable_fzf 
) }}

# 带备选方案的延迟加载
{{ includeTemplate "helpers/defer-load.sh" (dict 
    "command" "eval \"$(pyenv init -)\"" 
    "fallback" "echo \"Pyenv 初始化跳过\"" 
) }}

# 带延迟时间和优先级
{{ includeTemplate "helpers/defer-load.sh" (dict 
    "command" "eval \"$(zoxide init zsh)\"" 
    "delay" "0.1"
    "priority" "10"
) }}
```

### 3. config-section.sh - 配置节

```bash
# 主要配置节
{{ includeTemplate "helpers/config-section.sh" (dict 
    "name" "Shell 增强配置"
    "description" "配置各种 shell 增强工具"
    "level" 1
    "content" "# Shell 增强配置内容"
) }}

# 次要配置节
{{ includeTemplate "helpers/config-section.sh" (dict 
    "name" "Starship 配置"
    "description" "配置 Starship 提示符"
    "level" 2
    "condition" .features.enable_starship
    "content" "eval \"$(starship init zsh)\""
) }}

# 小节
{{ includeTemplate "helpers/config-section.sh" (dict 
    "name" "FZF 键绑定"
    "level" 3
    "condition" .features.enable_fzf
    "content" "source ~/.fzf.zsh"
) }}
```

## 组合使用示例

```bash
{{ includeTemplate "helpers/config-section.sh" (dict 
    "name" "开发工具配置"
    "description" "配置各种开发相关工具"
    "level" 1
    "condition" true
    "content" (printf "%s\n\n%s\n\n%s" 
        (includeTemplate "helpers/tool-check.sh" (dict 
            "tool" "pyenv" 
            "feature" .features.enable_python 
            "found" (includeTemplate "helpers/defer-load.sh" (dict 
                "command" "eval \"$(pyenv init -)\""
                "delay" "0.1"
            ))
        ))
        (includeTemplate "helpers/tool-check.sh" (dict 
            "tool" "nvm" 
            "feature" .features.enable_node 
            "found" "source ~/.nvm/nvm.sh"
        ))
        (includeTemplate "helpers/tool-check.sh" (dict 
            "tool" "rbenv" 
            "feature" .features.enable_ruby 
            "found" (includeTemplate "helpers/defer-load.sh" (dict 
                "command" "eval \"$(rbenv init -)\""
            ))
        ))
    )
) }}
```

## 迁移现有配置

要将现有配置迁移到使用这些辅助模板，请按照以下步骤：

1. 识别工具检测模式并替换为 `tool-check.sh`
2. 识别可以延迟加载的命令并使用 `defer-load.sh`
3. 为配置添加结构化的节标题使用 `config-section.sh`

这些模板将使您的配置更加一致、可读和可维护。
