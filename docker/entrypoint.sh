#!/bin/bash

for arg do
  shift
  if [ "$arg" = "--watch" ]; then
    watchForChanges=true
    continue
  else
    # FIXME this is unstable, and only works if the input file comes first TODO
    if ! [[ $arg == "-*" ]] && ! [[ $arg == "--*" ]]; then
      if [ -z "$watchFile" ]; then
        watchFile=$arg
      fi
    fi
    set -- "$@" "$arg"
  fi
done

runPandoc() {
  pandoc \
    -L include-code-files/include-code-files.lua \
    -F /filters/mermaid \
    "$@"  
}

if [[ $watchForChanges == true ]]; then
  echo "Running pandoc and watching for changes of file $watchFile"
  runPandoc "$@"
  while inotifywait -e close_write "$watchFile"; do
    runPandoc "$@"
  done
else
  runPandoc "$@"
fi
