#!/bin/bash

pandoc \
  -F /filters/mermaid \
  -F /filters/include \
  "$@"
