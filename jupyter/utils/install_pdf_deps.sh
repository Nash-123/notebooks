#!/bin/bash

# Install dependencies required for Notebooks PDF exports

set -euxo

# Handle s390x architecture-specific dependencies
if [ "${TARGETARCH}" = "s390x" ]; then
    echo "Installing TeX Live and Pandoc packages for PDF export on s390x..."

    # Configure CentOS Stream repositories
    dnf install -y 'dnf-command(config-manager)'
    dnf config-manager --add-repo=https://mirror.stream.centos.org/9-stream/BaseOS/s390x/os/
    dnf config-manager --add-repo=https://mirror.stream.centos.org/9-stream/AppStream/s390x/os/

    # Update repo metadata
    dnf clean all && dnf makecache

    # Install texlive packages from CentOS Stream
    dnf install -y --nogpgcheck \
        texlive-9:20200406-26.el9_2 \
        texlive-base-9:20200406-26.el9_2 \
        texlive-collection-basic-9:20200406-26.el9_2 \
        texlive-collection-fontsrecommended-9:20200406-26.el9_2 \
        texlive-adjustbox-9:20200406-26.el9_2 \
        texlive-enumitem-9:20200406-26.el9_2 \
        texlive-pdfcolmk-9:20200406-26.el9_2 \
        texlive-soul-9:20200406-26.el9_2 \
        texlive-tcolorbox-9:20200406-36.el9 \
        texlive-titling-9:20200406-26.el9_2 \
        texlive-ucs-9:20200406-26.el9_2 \
        texlive-amsmath-9:20200406-26.el9_2 \
        texlive-amsfonts-9:20200406-26.el9_2 \
        texlive-caption-9:20200406-26.el9_2 \
        texlive-eurosym-9:20200406-26.el9_2 \
        texlive-fancyvrb-9:20200406-26.el9_2 \
        texlive-framed-9:20200406-26.el9_2 \
        texlive-geometry-9:20200406-26.el9_2 \
        texlive-grffile-9:20200406-26.el9_2 \
        texlive-listings-9:20200406-26.el9_2 \
        texlive-mdframed-9:20200406-36.el9 \
        texlive-ulem-9:20200406-26.el9_2 \
        texlive-upquote-9:20200406-26.el9_2 \
        texlive-xcolor-9:20200406-26.el9_2

    dnf clean all && rm -rf /var/cache/dnf /var/cache/yum
else
    # tex live installation
    echo "Installing TexLive to allow PDf export from Notebooks"
    curl -L https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz -o install-tl-unx.tar.gz
    zcat < install-tl-unx.tar.gz | tar xf -
    cd install-tl-2*
    perl ./install-tl --no-interaction --scheme=scheme-small --texdir=/usr/local/texlive
    cd /usr/local/texlive/bin/x86_64-linux
    ./tlmgr install tcolorbox pdfcol adjustbox titling enumitem soul ucs collection-fontsrecommended

    # pandoc installation
    curl -L https://github.com/jgm/pandoc/releases/download/3.7.0.2/pandoc-3.7.0.2-linux-amd64.tar.gz  -o /tmp/pandoc.tar.gz
    mkdir -p /usr/local/pandoc
    tar xvzf /tmp/pandoc.tar.gz --strip-components 1 -C /usr/local/pandoc/
    rm -f /tmp/pandoc.tar.gz
fi
