#!/usr/bin/env bash
# ==============================================================================
# Aspect Chumley Navigator — CI Quality Gate Script
# Checks:
# 1. Code formatting compliance (dart format)
# 2. Static analysis with zero warnings/errors (flutter analyze)
# 3. Complete unit & widget test suite execution (flutter test)
# 4. Large file size advisory check (>1,200 LOC)
# ==============================================================================

set -e

echo "=========================================="
echo " [1/4] Running Code Formatting Check..."
echo "=========================================="
dart format --output=none --set-exit-if-changed lib test
echo "✓ Code formatting is 100% compliant."
echo ""

echo "=========================================="
echo " [2/4] Running Flutter Analyzer..."
echo "=========================================="
flutter analyze
echo "✓ Zero analyzer issues found."
echo ""

echo "=========================================="
echo " [3/4] Running Test Suite..."
echo "=========================================="
flutter test
echo "✓ All test cases passed."
echo ""

echo "=========================================="
echo " [4/4] Checking File Size Thresholds..."
echo "=========================================="
LARGE_FILES=$(find lib -name "*.dart" -exec wc -l {} + | awk '$2 != "total" && $1 > 1200 {print $1, $2}')
if [ -n "$LARGE_FILES" ]; then
  echo "⚠️  Advisory: The following Dart files exceed 1,200 LOC:"
  echo "$LARGE_FILES"
else
  echo "✓ All files in lib/ are within the 1,200 LOC threshold."
fi

echo ""
echo "=========================================="
echo "🎉 CI QUALITY GATES PASSED SUCCESSFULLY"
echo "=========================================="
