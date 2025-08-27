# ========================================
# 桌面开发环境配置
# ========================================
# 桌面特有的开发工具和IDE配置

# IDE和编辑器启动器
{{- if eq .chezmoi.os "linux" }}
# VS Code
if command -v code >/dev/null 2>&1; then
    alias vscode='code'
    alias ide='code'
fi

# JetBrains IDEs
if command -v idea >/dev/null 2>&1; then
    alias intellij='idea'
fi

if command -v webstorm >/dev/null 2>&1; then
    alias webstorm='webstorm'
fi

if command -v pycharm >/dev/null 2>&1; then
    alias pycharm='pycharm'
fi

{{- else if eq .chezmoi.os "darwin" }}
# macOS IDE启动器
ide_launcher() {
    local ide="$1"
    shift
    
    case "$ide" in
        vscode|code)
            if [[ -d "/Applications/Visual Studio Code.app" ]]; then
                open -a "Visual Studio Code" "$@"
            else
                echo "❌ VS Code 未安装"
                return 1
            fi
            ;;
        intellij|idea)
            if [[ -d "/Applications/IntelliJ IDEA.app" ]]; then
                open -a "IntelliJ IDEA" "$@"
            else
                echo "❌ IntelliJ IDEA 未安装"
                return 1
            fi
            ;;
        webstorm)
            if [[ -d "/Applications/WebStorm.app" ]]; then
                open -a "WebStorm" "$@"
            else
                echo "❌ WebStorm 未安装"
                return 1
            fi
            ;;
        pycharm)
            if [[ -d "/Applications/PyCharm.app" ]]; then
                open -a "PyCharm" "$@"
            else
                echo "❌ PyCharm 未安装"
                return 1
            fi
            ;;
        *)
            echo "支持的IDE: vscode, intellij, webstorm, pycharm"
            return 1
            ;;
    esac
}

alias vscode='ide_launcher vscode'
alias code='ide_launcher vscode'
alias ide='ide_launcher vscode'
alias intellij='ide_launcher intellij'
alias webstorm='ide_launcher webstorm'
alias pycharm='ide_launcher pycharm'
{{- end }}

# 开发工具函数
setup_dev_environment() {
    local project_type="$1"
    
    case "$project_type" in
        node|nodejs)
            echo "📦 设置Node.js开发环境..."
            if [[ -f "package.json" ]]; then
                npm install
                echo "✅ Node.js依赖已安装"
            else
                echo "⚠️ 未找到package.json文件"
            fi
            ;;
        python)
            echo "🐍 设置Python开发环境..."
            if [[ -f "requirements.txt" ]]; then
                pip install -r requirements.txt
                echo "✅ Python依赖已安装"
            elif [[ -f "Pipfile" ]]; then
                pipenv install
                echo "✅ Pipenv环境已设置"
            elif [[ -f "pyproject.toml" ]]; then
                poetry install
                echo "✅ Poetry环境已设置"
            else
                echo "⚠️ 未找到Python依赖文件"
            fi
            ;;
        java)
            echo "☕ 设置Java开发环境..."
            if [[ -f "pom.xml" ]]; then
                mvn install
                echo "✅ Maven依赖已安装"
            elif [[ -f "build.gradle" ]] || [[ -f "build.gradle.kts" ]]; then
                ./gradlew build
                echo "✅ Gradle构建完成"
            else
                echo "⚠️ 未找到Java构建文件"
            fi
            ;;
        *)
            echo "支持的项目类型: node, python, java"
            echo "用法: setup_dev_environment <project_type>"
            return 1
            ;;
    esac
}

# 项目初始化模板
init_project() {
    local project_type="$1"
    local project_name="$2"
    
    if [[ -z "$project_name" ]]; then
        echo "用法: init_project <type> <name>"
        echo "支持的类型: node, python, java, rust, go"
        return 1
    fi
    
    mkdir -p "$project_name" && cd "$project_name"
    
    case "$project_type" in
        node|nodejs)
            npm init -y
            echo "node_modules/" > .gitignore
            echo "# $project_name" > README.md
            ;;
        python)
            cat > requirements.txt <<EOF
# Add your dependencies here
EOF
            cat > .gitignore <<EOF
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
.venv/
EOF
            echo "# $project_name" > README.md
            ;;
        java)
            mkdir -p src/main/java src/test/java
            cat > .gitignore <<EOF
target/
*.class
*.jar
*.war
.idea/
*.iml
EOF
            echo "# $project_name" > README.md
            ;;
        rust)
            cargo init --name "$project_name" .
            ;;
        go)
            go mod init "$project_name"
            cat > main.go <<EOF
package main

import "fmt"

func main() {
    fmt.Println("Hello, $project_name!")
}
EOF
            ;;
        *)
            echo "❌ 不支持的项目类型: $project_type"
            cd ..
            rmdir "$project_name" 2>/dev/null
            return 1
            ;;
    esac
    
    git init
    git add .
    git commit -m "Initial commit"
    
    echo "✅ 项目 '$project_name' 已创建并初始化"
    
    # 在支持的IDE中打开项目
    if command -v code >/dev/null 2>&1; then
        code .
    fi
}

# Git GUI工具
{{- if eq .chezmoi.os "linux" }}
if command -v gitg >/dev/null 2>&1; then
    alias gitgui='gitg'
elif command -v gitk >/dev/null 2>&1; then
    alias gitgui='gitk'
fi

{{- else if eq .chezmoi.os "darwin" }}
if command -v gitk >/dev/null 2>&1; then
    alias gitgui='gitk'
fi
{{- end }}
