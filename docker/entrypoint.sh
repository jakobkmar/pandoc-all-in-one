#!/bin/bash

/usr/bin/pandoc \
  -F /filters/mermaid \
  -F /filters/include \
  "$@"
