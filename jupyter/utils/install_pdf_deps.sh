#!/bin/bash

# Install dependencies required for Notebooks PDF exports

set -euxo

# Handle s390x architecture-specific dependencies
if [ "${TARGETARCH}" = "s390x" ]; then
    echo "Installing TeX Live and Pandoc packages for PDF export on s390x..."
    
    # Enable EPEL repository
    dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
    
    # Enable CodeReady Builder repository which contains TeX packages
    dnf install -y dnf-plugins-core
    
    # Try multiple ways to enable CRB repository
    dnf config-manager --set-enabled crb || true
    dnf config-manager --set-enabled codeready-builder-for-rhel-9 || true
    
    # Enable EPEL testing repository as fallback
    dnf config-manager --set-enabled epel-testing || true
    
    # Update package lists
    dnf clean all
    dnf update -y
    
    # Install basic build tools since Development Tools group might not be available
    dnf install -y make gcc gcc-c++ kernel-devel || true
    
    # First try installing pandoc separately as it's in the main repos
    dnf install -y pandoc || true
    
    # Try to install texlive packages from EPEL
    for i in {1..3}; do
        if dnf install -y --setopt=tsflags=nodocs \
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
            texlive-xcolor; then
            break
        fi
        echo "Attempt $i failed. Retrying..."
        # Try enabling additional repos if packages aren't found
        dnf config-manager --set-enabled epel-testing || true
        dnf config-manager --set-enabled crb || true
        dnf config-manager --set-enabled codeready-builder-for-rhel-9 || true
        dnf clean all
        dnf repolist
        sleep 5
    done

    # Clean up
    dnf clean all && rm -rf /var/cache/dnf /var/cache/yum

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
