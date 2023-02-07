FROM fedora:latest

ENV CHROME_BIN="/usr/bin/chromium-browser" \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD="true"

RUN echo "max_parallel_downloads=10" >> /etc/dnf/dnf.conf
RUN dnf update -y

RUN dnf install -y texlive-scheme-medium
RUN dnf install -y chromium yarnpkg

RUN yarnpkg global add @mermaid-js/mermaid-cli

# tools
RUN dnf install -y inotify-tools wget tree
# conversion
RUN dnf install -y librsvg2 librsvg2-tools ghostscript wkhtmltopdf R-rsvg
RUN dnf install -y inkscape

# create directory for manual downloads
RUN mkdir /download/

# install pandoc
RUN wget -O /download/pandoc.tar.gz \
    https://github.com/jgm/pandoc/releases/download/3.0.1/pandoc-3.0.1-linux-amd64.tar.gz
RUN tar xvzf /download/pandoc.tar.gz --strip-components 1 -C /usr/local/

# clean manual download directory
RUN rm -rf /download/

RUN git clone https://github.com/pandoc/lua-filters.git /root/.local/share/pandoc/filters/

COPY filters/*.lua /filters/
RUN tree /filters/

COPY docker/resources /resources/
COPY docker/entrypoint.sh /run/
RUN chmod +x /run/entrypoint.sh

WORKDIR /data

ENTRYPOINT ["/run/entrypoint.sh"]
