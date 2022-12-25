# pandoc-all-in-one

All-in-one Docker image for [`pandoc`](https://pandoc.org/), including:
  - custom bundled filters:
    - [**Mermaid Filter**](https://mermaid.js.org/)
    - a filter for including external files in your document
    - (it is planned to bundle some lua filters from the lua-filters repository, e.g. the [diagram filter](https://github.com/pandoc/lua-filters/tree/master/diagram-generator))
  - pre-installed dependencies:
    - **TeXLive**
    - wkhtmltopdf
    - livrsvg, ghostscript
  - utilities for your working environment:
    - `--watch` flag for the pandoc command, keeping the process alive and recompiling on changes

*This image is work in progress.*

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
- `--watch` - the process will keep running, if you write a new change to document pandoc will be rerun

## Planned

More features are planned, for example:
- bundle more filters
- add more command line utilities like opening a full environment for working with your input file and viewing the rendered output in real time
- make the mermaid filter more reliable
- convert SVGs with Inkscape when the target document is a PDF, since it has better conversion in certain scenarios