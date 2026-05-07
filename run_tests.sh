#!/bin/zsh
set -euo pipefail

LOG="test_$(date +%Y%m%d_%H%M%S).log"

# macOS ships bash 3.2 and no flock; tests require bash 5+ and flock from Homebrew
export PATH="/opt/homebrew/bin:$PATH"
# cmp_tbdata.c is compiled as C++ by autotest.sh; macOS SDK 15+ needs c++11+
export CXXFLAGS="${CXXFLAGS:+$CXXFLAGS }-std=c++11"
# Use bash 5 as the shell for autotest.sh (invoked via SHELL by make)
export SHELL=/opt/homebrew/bin/bash

echo "Running make test, logging to $LOG ..."
make test 2>&1 | tee "$LOG"
STATUS=${pipestatus[1]}

echo ""
echo "Log saved to: $LOG"
exit $STATUS
