#!/bin/bash

echo "=== Cross-Platform Configuration Test ==="
echo ""

# Test Linux environment (current)
echo "1. Testing Linux Environment:"
echo "   Current OS: $(chezmoi data | grep 'os:' | awk '{print $2}' | tr -d '"')"
chezmoi execute-template < .chezmoitemplates/shell-common.sh > /tmp/linux-config.sh
source /tmp/linux-config.sh

echo "   Available Linux functions:"
echo "   - proxystatus: $(type -t proxystatus)"
echo "   - themestatus: $(type -t themestatus)"
echo "   - dark: $(type -t dark)"
echo "   - light: $(type -t light)"
echo ""

# Test macOS environment (simulated)
echo "2. Testing macOS Environment (simulated):"
echo 'data:
  chezmoi:
    os: darwin' > /tmp/macos-config.yaml

chezmoi execute-template --config /tmp/macos-config.yaml < .chezmoitemplates/shell-common.sh > /tmp/macos-config.sh
source /tmp/macos-config.sh

echo "   Available macOS functions:"
echo "   - macos_version: $(type -t macos_version)"
echo "   - mas_list: $(type -t mas_list)"
echo "   - cask_list: $(type -t cask_list)"
echo "   - show_hidden: $(type -t show_hidden)"
echo "   - clean_system: $(type -t clean_system)"
echo ""

# Test function behavior
echo "3. Testing Function Behavior:"
echo "   Linux proxystatus (should work):"
source /tmp/linux-config.sh
proxystatus | head -5

echo ""
echo "   macOS macos_version (should show placeholder on Linux):"
source /tmp/macos-config.sh
macos_version

echo ""
echo "=== Cross-Platform Test Completed ==="