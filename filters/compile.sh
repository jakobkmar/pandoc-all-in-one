#!/bin/bash

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Compiling Haskell files in: $__dir"

for file in "${__dir}"/*
do
  if [[ $file == *.hs ]]; then
    echo ""
    echo "Compiling $file"
    ghc --make "$file" -no-keep-hi-files -no-keep-o-files
  fi
done
