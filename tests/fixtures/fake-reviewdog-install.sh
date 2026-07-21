#!/bin/sh
# Fake reviewdog installer: parse -b BINDIR and create a fake reviewdog binary there
bindir="/usr/local/bin"
prev=""
for arg in "$@"; do
  case "$prev" in
    -b) bindir="$arg" ;;
  esac
  prev="$arg"
done
mkdir -p "$bindir"
printf '#!/bin/sh\ncat > /dev/null\nexit 0\n' > "$bindir/reviewdog"
chmod +x "$bindir/reviewdog"
