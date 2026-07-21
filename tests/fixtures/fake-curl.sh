#!/bin/sh
# Fake curl: intercepts reviewdog and trivy downloads
# Supports both pipe form (stdout) and -o FILE form (write to file)
out=""
prev=""
for arg in "$@"; do
  case "$prev" in
    -o|--output) out="$arg" ;;
  esac
  prev="$arg"
done

case "$*" in
  *reviewdog*)
    if [ -n "$out" ] && [ "$out" != "/dev/null" ]; then
      cat /tmp/fake-reviewdog-install.sh > "$out"
    else
      cat /tmp/fake-reviewdog-install.sh
    fi
    exit 0
    ;;
  *trivy*releases*download*)
    if [ -n "$out" ] && [ "$out" != "/dev/null" ]; then
      cat /tmp/fake-trivy.tar.gz > "$out"
    else
      cat /tmp/fake-trivy.tar.gz
    fi
    exit 0
    ;;
  *trivy*releases*latest*|*trivy*releases*tag*)
    echo "https://github.com/aquasecurity/trivy/releases/tag/v0.99.0"
    exit 0
    ;;
esac

exec /usr/bin/curl "$@"
