#!/bin/bash
# ========================================
# Test Script for Chezmoi Shell Templates
# ========================================
# This script tests the migrated shell functionality

set -e

echo "🧪 Testing Chezmoi Shell Templates..."
echo "======================================"

# Test aliases template
echo "📝 Testing aliases template..."
chezmoi execute-template < .chezmoitemplates/aliases.sh > /tmp/test-aliases.sh
if grep -q "alias ll=" /tmp/test-aliases.sh; then
    echo "✅ Aliases template: ll alias found"
else
    echo "❌ Aliases template: ll alias missing"
    exit 1
fi

if grep -q "alias la=" /tmp/test-aliases.sh; then
    echo "✅ Aliases template: la alias found"
else
    echo "❌ Aliases template: la alias missing"
    exit 1
fi

# Test proxy functions template
echo "📝 Testing proxy functions template..."
chezmoi execute-template < .chezmoitemplates/proxy-functions.sh > /tmp/test-proxy.sh
if grep -q "proxyon()" /tmp/test-proxy.sh; then
    echo "✅ Proxy template: proxyon function found"
else
    echo "❌ Proxy template: proxyon function missing"
    exit 1
fi

if grep -q "proxyoff()" /tmp/test-proxy.sh; then
    echo "✅ Proxy template: proxyoff function found"
else
    echo "❌ Proxy template: proxyoff function missing"
    exit 1
fi

if grep -q "proxystatus()" /tmp/test-proxy.sh; then
    echo "✅ Proxy template: proxystatus function found"
else
    echo "❌ Proxy template: proxystatus function missing"
    exit 1
fi



# Test theme functions template
echo "📝 Testing theme functions template..."
chezmoi execute-template < .chezmoitemplates/theme-functions.sh > /tmp/test-theme.sh
if grep -q "dark()" /tmp/test-theme.sh; then
    echo "✅ Theme template: dark function found"
else
    echo "❌ Theme template: dark function missing"
    exit 1
fi

if grep -q "light()" /tmp/test-theme.sh; then
    echo "✅ Theme template: light function found"
else
    echo "❌ Theme template: light function missing"
    exit 1
fi

if grep -q "themestatus()" /tmp/test-theme.sh; then
    echo "✅ Theme template: themestatus function found"
else
    echo "❌ Theme template: themestatus function missing"
    exit 1
fi

# Test basic functions template
echo "📝 Testing basic functions template..."
chezmoi execute-template < .chezmoitemplates/basic-functions.sh > /tmp/test-basic.sh
if grep -q "mkcd()" /tmp/test-basic.sh; then
    echo "✅ Basic functions: mkcd function found"
else
    echo "❌ Basic functions: mkcd function missing"
    exit 1
fi

if grep -q "sysinfo()" /tmp/test-basic.sh; then
    echo "✅ Basic functions: sysinfo function found"
else
    echo "❌ Basic functions: sysinfo function missing"
    exit 1
fi

# Test shell-common template (modular structure)
echo "📝 Testing shell-common template..."
chezmoi execute-template < .chezmoitemplates/shell-common.sh > /tmp/test-common.sh
if grep -q "mkcd()" /tmp/test-common.sh; then
    echo "✅ Common template: includes basic functions"
else
    echo "❌ Common template: missing basic functions"
    exit 1
fi

# Test that templates include each other correctly
if grep -q "includeTemplate.*aliases.sh" .chezmoitemplates/shell-common.sh; then
    echo "✅ Shell-common includes aliases template"
else
    echo "❌ Shell-common missing aliases template inclusion"
    exit 1
fi

if grep -q "includeTemplate.*basic-functions.sh" .chezmoitemplates/shell-common.sh; then
    echo "✅ Shell-common includes basic functions template"
else
    echo "❌ Shell-common missing basic functions template inclusion"
    exit 1
fi

if grep -q "includeTemplate.*proxy-functions.sh" .chezmoitemplates/shell-common.sh; then
    echo "✅ Shell-common includes proxy functions template"
else
    echo "❌ Shell-common missing proxy functions template inclusion"
    exit 1
fi

if grep -q "includeTemplate.*theme-functions.sh" .chezmoitemplates/shell-common.sh; then
    echo "✅ Shell-common includes theme functions template"
else
    echo "❌ Shell-common missing theme functions template inclusion"
    exit 1
fi

# Clean up test files
rm -f /tmp/test-*.sh

echo ""
echo "🎉 All tests passed! Shell functionality migration completed successfully."
echo ""
echo "📋 Summary of migrated functionality:"
echo "   ✅ Essential aliases (ls, ll, la) - aliases.sh"
echo "   ✅ Proxy management (proxyon, proxyoff, proxystatus) - proxy-functions.sh"
echo "     └── Linux desktop only, environment variable based"
echo "   ✅ WhiteSur theme switching (light, dark, themestatus) - theme-functions.sh"
echo "     └── Linux GNOME only, supports WhiteSur + fcitx5 themes"
echo "   ✅ Basic utility functions (mkcd, sysinfo) - basic-functions.sh"
echo "   ✅ Modular shell configuration - shell-common.sh"
echo ""
echo "🔧 Next steps:"
echo "   1. Test the templates in a real environment"
echo "   2. Apply with 'chezmoi apply'"
echo "   3. Verify functionality in shell"