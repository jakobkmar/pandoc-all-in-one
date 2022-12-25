FROM haskell:latest as builder

RUN cabal update && cabal install --lib pandoc-types base64 temporary

COPY filters filters
RUN ./filters/compile.sh


FROM fedora:latest

ENV CHROME_BIN="/usr/bin/chromium-browser" \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD="true"

RUN echo "max_parallel_downloads=10" >> /etc/dnf/dnf.conf
RUN dnf update -y

RUN dnf install -y pandoc texlive-scheme-basic
RUN dnf install -y chromium yarnpkg

RUN yarnpkg global add @mermaid-js/mermaid-cli

# tools
RUN dnf install -y inotify-tools
# conversion
RUN dnf install -y librsvg2 librsvg2-tools ghostscript wkhtmltopdf R-rsvg

COPY --from=builder filters /filters/

COPY docker/resources /resources/
COPY docker/entrypoint.sh /run/
RUN chmod +x /run/entrypoint.sh

WORKDIR /data

ENTRYPOINT ["/run/entrypoint.sh"]
