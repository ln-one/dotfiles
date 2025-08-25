#!/bin/zsh

# Git 功能验证脚本 - 专门测试 Zim utility 模块的 Git 集成
# 要求: 2.1, 4.1

echo "🔍 验证 Zim Git 功能集成"
echo "========================="

# 初始化 Zsh 环境
source ~/.zshrc 2>/dev/null

# 测试计数器
PASSED=0
FAILED=0

# 测试函数
test_git_alias() {
    local alias_name="$1"
    local expected_command="$2"
    
    if alias "$alias_name" >/dev/null 2>&1; then
        local actual_command=$(alias "$alias_name" | cut -d'=' -f2- | tr -d "'")
        if [[ "$actual_command" == "$expected_command" ]]; then
            echo "✅ $alias_name -> $actual_command"
            ((PASSED++))
        else
            echo "❌ $alias_name -> 期望: $expected_command, 实际: $actual_command"
            ((FAILED++))
        fi
    else
        echo "❌ 别名 $alias_name 不存在"
        ((FAILED++))
    fi
}

echo "\n📋 测试 Zim utility 模块提供的 Git 别名:"

# 测试核心 Git 别名（基于 Zim utility 模块）
test_git_alias "g" "git"
test_git_alias "ga" "git add"
test_git_alias "gb" "git branch"
test_git_alias "gc" "git commit"
test_git_alias "gco" "git checkout"
test_git_alias "gd" "git diff"
test_git_alias "gl" "git pull"
test_git_alias "gp" "git push"
test_git_alias "gs" "git status"

echo "\n🔧 测试 Git 配置兼容性:"

# 检查 Git 配置
if command -v git >/dev/null 2>&1; then
    echo "✅ Git 命令可用"
    ((PASSED++))
    
    # 检查用户配置
    if git config --get user.name >/dev/null 2>&1; then
        echo "✅ Git 用户名已配置: $(git config --get user.name)"
        ((PASSED++))
    else
        echo "❌ Git 用户名未配置"
        ((FAILED++))
    fi
    
    if git config --get user.email >/dev/null 2>&1; then
        echo "✅ Git 用户邮箱已配置: $(git config --get user.email)"
        ((PASSED++))
    else
        echo "❌ Git 用户邮箱未配置"
        ((FAILED++))
    fi
    
    # 检查默认分支
    local default_branch=$(git config --get init.defaultBranch 2>/dev/null)
    if [[ "$default_branch" == "main" ]]; then
        echo "✅ 默认分支配置正确: $default_branch"
        ((PASSED++))
    else
        echo "❌ 默认分支配置不正确，期望: main，实际: $default_branch"
        ((FAILED++))
    fi
else
    echo "❌ Git 命令不可用"
    ((FAILED++))
fi

echo "\n🎯 测试 Git 状态显示功能:"

# 检查当前是否在 Git 仓库中
if git rev-parse --git-dir >/dev/null 2>&1; then
    echo "✅ 当前目录是 Git 仓库"
    ((PASSED++))
    
    # 测试 Git 状态别名功能
    if gs --porcelain >/dev/null 2>&1; then
        echo "✅ 'gs' (git status) 别名功能正常"
        ((PASSED++))
    else
        echo "❌ 'gs' 别名功能异常"
        ((FAILED++))
    fi
    
    # 测试其他 Git 别名的实际功能
    if gb >/dev/null 2>&1; then
        echo "✅ 'gb' (git branch) 别名功能正常"
        ((PASSED++))
    else
        echo "❌ 'gb' 别名功能异常"
        ((FAILED++))
    fi
    
else
    echo "⚠️  当前目录不是 Git 仓库，跳过 Git 状态测试"
fi

echo "\n📊 测试结果总结:"
echo "通过: $PASSED"
echo "失败: $FAILED"

if [[ $FAILED -eq 0 ]]; then
    echo "\n🎉 所有 Git 功能集成测试通过！"
    echo "✅ Zim utility 模块的 Git 别名工作正常"
    echo "✅ 与现有 Git 配置兼容"
    echo "✅ Git 状态显示功能正常"
    exit 0
else
    echo "\n❌ 有 $FAILED 个测试失败"
    exit 1
fi