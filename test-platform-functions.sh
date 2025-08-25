#!/bin/bash

echo "=== Testing Platform-Specific Functions ==="
echo ""

# Source the generated configuration
echo "Loading Linux platform configuration..."
source <(chezmoi execute-template < .chezmoitemplates/platforms/linux/proxy-functions.sh)
source <(chezmoi execute-template < .chezmoitemplates/platforms/linux/theme-functions.sh)

echo "✅ Linux configuration loaded"
echo ""

# Test Linux functions
echo "Testing Linux-specific functions:"
echo "1. Testing proxystatus function:"
proxystatus
echo ""

echo "2. Testing themestatus function:"
themestatus
echo ""

# Test macOS configuration
echo "Loading macOS platform configuration..."
source <(echo 'data:
  chezmoi:
    os: darwin' > /tmp/test-config.yaml && chezmoi execute-template --config /tmp/test-config.yaml < .chezmoitemplates/platforms/darwin/macos-specific.sh)

echo "✅ macOS configuration loaded"
echo ""

echo "3. Testing macOS-specific functions:"
echo "Testing macos_version function:"
macos_version
echo ""

echo "Testing system_status function:"
system_status
echo ""

echo "=== All tests completed ==="