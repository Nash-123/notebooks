#!/bin/bash

# Install dependencies required for Notebooks PDF exports

set -euxo

# Get the system architecture
ARCH=$(uname -m)

if [ "$ARCH" = "s390x" ]; then
    echo "Running on s390x architecture - using system-provided TexLive packages"
    # TexLive packages are already installed via dnf in the Dockerfile
    # No need to install from CTAN as it doesn't support s390x
    # Install pandoc from dnf (already done in Dockerfile)
    echo "Using system-provided pandoc package"
else
    # For other architectures (x86_64, etc), use the standard installation
    echo "Installing TexLive to allow PDF export from Notebooks"
    curl -L https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz -o install-tl-unx.tar.gz
    zcat < install-tl-unx.tar.gz | tar xf -
    cd install-tl-2*
    perl ./install-tl --no-interaction --scheme=scheme-small --texdir=/usr/local/texlive
    cd /usr/local/texlive/bin/x86_64-linux
    ./tlmgr install tcolorbox pdfcol adjustbox titling enumitem soul ucs collection-fontsrecommended

    # pandoc installation for x86_64
    curl -L https://github.com/jgm/pandoc/releases/download/3.7.0.2/pandoc-3.7.0.2-linux-amd64.tar.gz  -o /tmp/pandoc.tar.gz
    mkdir -p /usr/local/pandoc
    tar xvzf /tmp/pandoc.tar.gz --strip-components 1 -C /usr/local/pandoc/
    rm -f /tmp/pandoc.tar.gz
fi

