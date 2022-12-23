FROM haskell:latest as builder

RUN cabal update && cabal install --lib pandoc-types base64

COPY . .
RUN ./filters/compile.sh


FROM fedora:latest

ENV CHROME_BIN="/usr/bin/chromium-browser" \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD="true"

RUN dnf update -y

RUN dnf install -y pandoc
# TeX
RUN dnf install -y texlive-scheme-full
# conversion
RUN dnf install -y librsvg2 ghostscript

# some js filters
RUN dnf install -y chromium yarnpkg
RUN yarnpkg global add @mermaid-js/mermaid-cli

COPY --from=builder filters /filters

COPY docker/resources /resources
COPY docker/entrypoint.sh /run
RUN chmod +x /run/entrypoint.sh

WORKDIR /data

ENTRYPOINT ["/run/entrypoint.sh"]
