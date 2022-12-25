# pandoc-all-in-one

All-in-one Docker image for [`pandoc`](https://pandoc.org/), including:
  - pre-installed dependencies:
    - **TeXLive**
    - wkhtmltopdf
    - livrsvg, ghostscript
  - custom bundled filters:
    - [**Mermaid Filter**](https://mermaid.js.org/)
    - a filter for including files in your document
    - (it is planned to bundle some lua filters from the lua-filters repository, e.g. the [diagram filter](https://github.com/pandoc/lua-filters/tree/master/diagram-generator))
  - utilities for your working environment:
    - `--watch` flag for the pandoc command, keeping the process alive and recompiling on changes

## Installation

To use this image just run

with [**Podman**](https://podman.io/)
```bash
podman run --rm -it -v "$(pwd):/data:z" jakobkmar/pandoc-all-in-one
```

with [**Docker**](https://www.docker.com/)
```bash
docker run --rm -it -v "$(pwd):/data" jakobkmar/pandoc-all-in-one
```

To shorten that process, create an [`alias`](https://man7.org/linux/man-pages/man1/alias.1p.html) (`alias pandoc='...'`).

## Flags

The following flags are available:
- `watch` - the process will keep running, if you write a new change to document pandoc will be rerun

## Planned

This image is work in progress, more features are planned, for example bundling more filters and adding more command line utilities like opening a full environment for working with your input file and viewing the rendered output in real time.
