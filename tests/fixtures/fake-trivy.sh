#!/bin/sh
# Fake trivy binary
case "$*" in
  *--version*)
    echo "Version: 0.99.0"
    exit 0
    ;;
  *)
    printf '{"version":"2.1.0","runs":[]}\n'
    exit 0
    ;;
esac
