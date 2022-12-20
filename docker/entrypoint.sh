#!/bin/bash

/usr/bin/pandoc \
  -F /filters/include \
  "$@"
