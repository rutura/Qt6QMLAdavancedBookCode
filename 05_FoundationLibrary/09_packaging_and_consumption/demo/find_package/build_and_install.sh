#!/usr/bin/env bash
# Build + install QmlAdvCore to a local prefix, then build the find_package
# consumer demo pointing at that prefix.
#
# Usage:
#   ./build_and_install.sh [QT_CMAKE]
# Defaults to ~/Qt/6.11.1/gcc_64/bin/qt-cmake if QT_CMAKE is not given.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
SECTION_ROOT="$HERE/../.."         # 09_packaging_and_consumption
LIB_ROOT="$SECTION_ROOT/QmlAdvCore"
INSTALL_PREFIX="$SECTION_ROOT/_install"
LIB_BUILD="$SECTION_ROOT/build/_lib"
CONSUMER_BUILD="$HERE/build"

QT_CMAKE="${1:-$HOME/Qt/6.11.1/gcc_64/bin/qt-cmake}"

echo "==> Qt:        $QT_CMAKE"
echo "==> Library:   $LIB_ROOT"
echo "==> Prefix:    $INSTALL_PREFIX"
echo

# 1. Configure + build the library
"$QT_CMAKE" -S "$LIB_ROOT" -B "$LIB_BUILD" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"
cmake --build "$LIB_BUILD" --parallel

# 2. Install to the local prefix
cmake --install "$LIB_BUILD"

# 3. Configure + build the consumer pointing at that prefix
"$QT_CMAKE" -S "$HERE" -B "$CONSUMER_BUILD" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="$INSTALL_PREFIX"
cmake --build "$CONSUMER_BUILD" --parallel

echo
echo "==> Done. Run:"
echo "    $CONSUMER_BUILD/QmlAdvCoreFindPkgDemo"
