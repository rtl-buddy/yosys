#!/usr/bin/env bash
# install-symlinks.sh — replace installed yosys binaries with symlinks to the build tree
#
# After running this once (with sudo), 'make' in this directory immediately
# takes effect at the installed location without needing 'sudo make install'.
#
# Usage:
#   cd /path/to/yosys
#   sudo bash install-symlinks.sh [--destdir /usr/local/bin]
#
# To revert to real copies: sudo make install

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BINDIR="/usr/local/bin"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --destdir) BINDIR="$2"; shift 2 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

BINS=(yosys yosys-abc yosys-config yosys-filterlib yosys-smtbmc yosys-witness)

echo "Linking build executables → ${BINDIR}"
for bin in "${BINS[@]}"; do
    src="${SCRIPT_DIR}/${bin}"
    dst="${BINDIR}/${bin}"
    if [[ ! -f "${src}" ]]; then
        echo "  skip  ${bin}  (not built)"
        continue
    fi
    if [[ -L "${dst}" && "$(readlink "${dst}")" == "${src}" ]]; then
        echo "  ok    ${bin}  (already linked)"
        continue
    fi
    ln -sf "${src}" "${dst}"
    echo "  linked ${dst} → ${src}"
done

echo "Done. 'make' updates take effect immediately at ${BINDIR}."
