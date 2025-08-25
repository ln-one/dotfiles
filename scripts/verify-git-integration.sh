#!/bin/bash

# Git 功能集成验证脚本
# 验证 Zim utility 模块提供的 Git 别名和功能

set -e

echo "🔍 验证 Git 功能集成..."
echo "================================"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 计数器
TESTS_PASSED=0
TESTS_FAILED=0

# 测试函数
test_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} $2"
        ((TESTS_FAILED++))
    fi
}

# 1. 验证 Zim utility 模块是否已加载
echo -e "\n${YELLOW}1. 检查 Zim utility 模块状态${NC}"

# 检查 ZIM_HOME 是否设置
if [ -n "$ZIM_HOME" ]; then
    test_result 0 "ZIM_HOME 环境变量已设置: $ZIM_HOME"
else
    test_result 1 "ZIM_HOME 环境变量未设置"
fi

# 检查 Zim 初始化脚本是否存在
if [ -f "${ZIM_HOME}/init.zsh" ]; then
    test_result 0 "Zim 初始化脚本存在"
else
    test_result 1 "Zim 初始化脚本不存在"
fi

# 2. 验证 Git 别名
echo -e "\n${YELLOW}2. 检查 Git 别名${NC}"

# 常用的 Git 别名列表（Zim utility 模块提供）
declare -a git_aliases=(
    "g"      # git
    "ga"     # git add
    "gaa"    # git add --all
    "gb"     # git branch
    "gba"    # git branch --all
    "gbd"    # git branch --delete
    "gc"     # git commit
    "gca"    # git commit --all
    "gcam"   # git commit --all --message
    "gcm"    # git commit --message
    "gco"    # git checkout
    "gcob"   # git checkout -b
    "gd"     # git diff
    "gds"    # git diff --staged
    "gf"     # git fetch
    "gl"     # git log
    "glo"    # git log --oneline
    "gp"     # git push
    "gpl"    # git pull
    "gr"     # git remote
    "gra"    # git remote add
    "grv"    # git remote --verbose
    "gs"     # git status
    "gss"    # git status --short
    "gst"    # git stash
)

for alias_name in "${git_aliases[@]}"; do
    if alias "$alias_name" >/dev/null 2>&1; then
        alias_def=$(alias "$alias_name" 2>/dev/null | cut -d'=' -f2- | tr -d "'")
        test_result 0 "别名 '$alias_name' 存在: $alias_def"
    else
        test_result 1 "别名 '$alias_name' 不存在"
    fi
done

# 3. 验证 Git 配置兼容性
echo -e "\n${YELLOW}3. 检查 Git 配置兼容性${NC}"

# 检查 Git 是否可用
if command -v git >/dev/null 2>&1; then
    test_result 0 "Git 命令可用"
    
    # 检查 Git 配置
    git_user_name=$(git config --get user.name 2>/dev/null || echo "")
    if [ -n "$git_user_name" ]; then
        test_result 0 "Git 用户名已配置: $git_user_name"
    else
        test_result 1 "Git 用户名未配置"
    fi
    
    git_user_email=$(git config --get user.email 2>/dev/null || echo "")
    if [ -n "$git_user_email" ]; then
        test_result 0 "Git 用户邮箱已配置: $git_user_email"
    else
        test_result 1 "Git 用户邮箱未配置"
    fi
    
    # 检查默认分支配置
    default_branch=$(git config --get init.defaultBranch 2>/dev/null || echo "")
    if [ "$default_branch" = "main" ]; then
        test_result 0 "默认分支配置正确: $default_branch"
    else
        test_result 1 "默认分支配置不正确，期望: main，实际: $default_branch"
    fi
    
else
    test_result 1 "Git 命令不可用"
fi

# 4. 验证 Git 状态显示功能
echo -e "\n${YELLOW}4. 检查 Git 状态显示功能${NC}"

# 检查是否在 Git 仓库中
if git rev-parse --git-dir >/dev/null 2>&1; then
    test_result 0 "当前目录是 Git 仓库"
    
    # 测试 Git 状态别名
    if alias gs >/dev/null 2>&1; then
        echo "测试 'gs' 别名 (git status):"
        gs --porcelain >/dev/null 2>&1
        test_result $? "'gs' 别名功能正常"
    fi
    
    if alias gss >/dev/null 2>&1; then
        echo "测试 'gss' 别名 (git status --short):"
        gss >/dev/null 2>&1
        test_result $? "'gss' 别名功能正常"
    fi
    
else
    echo -e "${YELLOW}注意: 当前目录不是 Git 仓库，跳过 Git 状态测试${NC}"
fi

# 5. 验证 Git 提示符集成（如果启用了 git-info 模块）
echo -e "\n${YELLOW}5. 检查 Git 提示符集成${NC}"

# 检查是否启用了 Starship
if [ -n "$STARSHIP_CONFIG" ] || command -v starship >/dev/null 2>&1; then
    test_result 0 "Starship 提示符已启用，Git 信息由 Starship 处理"
else
    # 检查 Zim git-info 模块
    if [ -f "${ZIM_HOME}/modules/git-info/init.zsh" ]; then
        test_result 0 "Zim git-info 模块可用"
    else
        test_result 1 "Zim git-info 模块不可用"
    fi
fi

# 6. 测试 Git 别名的实际功能
echo -e "\n${YELLOW}6. 测试 Git 别名实际功能${NC}"

if git rev-parse --git-dir >/dev/null 2>&1; then
    # 测试一些安全的 Git 别名
    if alias gb >/dev/null 2>&1; then
        gb >/dev/null 2>&1
        test_result $? "'gb' (git branch) 别名功能正常"
    fi
    
    if alias gr >/dev/null 2>&1; then
        gr >/dev/null 2>&1
        test_result $? "'gr' (git remote) 别名功能正常"
    fi
    
    if alias glo >/dev/null 2>&1; then
        glo --max-count=1 >/dev/null 2>&1
        test_result $? "'glo' (git log --oneline) 别名功能正常"
    fi
else
    echo -e "${YELLOW}注意: 当前目录不是 Git 仓库，跳过 Git 别名功能测试${NC}"
fi

# 总结
echo -e "\n${YELLOW}================================${NC}"
echo -e "${YELLOW}测试总结${NC}"
echo -e "通过: ${GREEN}$TESTS_PASSED${NC}"
echo -e "失败: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 所有 Git 功能集成测试通过！${NC}"
    exit 0
else
    echo -e "\n${RED}❌ 有 $TESTS_FAILED 个测试失败，请检查配置${NC}"
    exit 1
fi