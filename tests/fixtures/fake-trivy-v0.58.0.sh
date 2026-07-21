#!/bin/sh
# Fake trivy binary reporting version 0.58.0
case "$*" in
  *--version*)
    echo "Version: 0.58.0"
    exit 0
    ;;
  *)
    printf '{"version":"2.1.0","runs":[]}\n'
    exit 0
    ;;
esac
