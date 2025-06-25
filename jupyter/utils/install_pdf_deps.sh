#!/bin/bash

# Install dependencies required for Notebooks PDF exports

set -euxo

# Handle s390x architecture-specific dependencies
if [ "${TARGETARCH}" = "s390x" ]; then
    echo "Installing TeX Live and Pandoc packages for PDF export on s390x..."

    # Enable EPEL repository for pandoc
    dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm

    # Install basic build tools and dependencies
    dnf install -y make gcc gcc-c++ perl wget which

    # Install pandoc from EPEL
    dnf install -y pandoc || true

    # Install TexLive directly using installer
    echo "Installing TexLive using direct installer..."
    TEXLIVE_MIRROR="https://mirror.ctan.org/systems/texlive/tlnet"

    # Create temporary directory for installation
    TEMP_DIR=$(mktemp -d)
    cd $TEMP_DIR

    # Download and extract installer
    curl -L ${TEXLIVE_MIRROR}/install-tl-unx.tar.gz -o install-tl-unx.tar.gz
    tar xzf install-tl-unx.tar.gz
    cd install-tl-*

    # Create a minimal profile for TexLive installation
    cat > texlive.profile << EOF
selected_scheme scheme-small
TEXDIR /usr/local/texlive
TEXMFCONFIG ~/.texlive/texmf-config
TEXMFHOME ~/texmf
TEXMFLOCAL /usr/local/texlive/texmf-local
TEXMFSYSCONFIG /usr/local/texlive/texmf-config
TEXMFSYSVAR /usr/local/texlive/texmf-var
TEXMFVAR ~/.texlive/texmf-var
binary_s390x-linux 1
instopt_adjustpath 1
instopt_adjustrepo 1
instopt_letter 0
instopt_portable 0
instopt_write18_restricted 1
tlpdbopt_autobackup 0
tlpdbopt_create_formats 1
tlpdbopt_generate_updmap 0
tlpdbopt_install_docfiles 0
tlpdbopt_install_srcfiles 0
EOF

    # Run installer with profile
    ./install-tl --profile=texlive.profile

    # Add TeX Live binaries to PATH
    export PATH="/usr/local/texlive/bin/s390x-linux:$PATH"

    # Install required packages using tlmgr
    tlmgr install \
        collection-basic \
        collection-fontsrecommended \
        adjustbox \
        enumitem \
        pdfcolmk \
        soul \
        tcolorbox \
        titling \
        ucs \
        amsmath \
        amsfonts \
        caption \
        eurosym \
        fancyvrb \
        framed \
        geometry \
        grffile \
        listings \
        mdframed \
        ulem \
        upquote \
        xcolor

    # Clean up
    cd /
    rm -rf $TEMP_DIR

    # Create symlinks for binaries
    ln -sf /usr/local/texlive/bin/s390x-linux/pdflatex /usr/local/bin/pdflatex
    ln -sf /usr/local/texlive/bin/s390x-linux/xelatex /usr/local/bin/xelatex

    # Verify installations
    which pdflatex || echo "pdflatex not found"
    which pandoc || echo "pandoc not found"
else
    # For other architectures (x86_64, etc), use the standard installation
    echo "Installing TexLive to allow PDF export from Notebooks"
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

