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
    dnf config-manager --add-repo=https://mirror.stream.centos.org/9-stream/CRB/s390x/os/

    # Update repo metadata
    dnf clean all && dnf makecache

    # Install texlive and pandoc packages from CentOS Stream
    dnf install -y --nogpgcheck \
        pandoc \
        texlive \
        texlive-collection-basic \
        texlive-collection-fontsrecommended \
        texlive-adjustbox \
        texlive-enumitem \
        texlive-pdfcolmk \
        texlive-soul \
        texlive-tcolorbox \
        texlive-titling \
        texlive-ucs \
        texlive-amsmath \
        texlive-amsfonts \
        texlive-caption \
        texlive-eurosym \
        texlive-fancyvrb \
        texlive-framed \
        texlive-geometry \
        texlive-grffile \
        texlive-listings \
        texlive-mdframed \
        texlive-ulem \
        texlive-upquote \
        texlive-xcolor

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
