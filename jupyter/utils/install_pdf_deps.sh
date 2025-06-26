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
    
    # Enable EPEL repository for pandoc
    dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm

    # Update repo metadata
    dnf clean all && dnf makecache

    # Install texlive packages from CentOS Stream and pandoc from EPEL
    dnf install -y --nogpgcheck \
        texlive.s390x \
        texlive-base.noarch \
        texlive-latex.noarch \
        texlive-latex-fonts.noarch \
        texlive-collection-basic.noarch \
        texlive-collection-latex.noarch \
        texlive-collection-latexrecommended.noarch \
        texlive-collection-fontsrecommended.noarch \
        texlive-collection-xetex.noarch \
        texlive-tex.s390x \
        texlive-kpathsea.s390x \
        texlive-lib.s390x \
        texlive-pdftex.s390x \
        texlive-dvipdfmx.s390x \
        texlive-dvips.s390x \
        texlive-xetex.s390x \
        texlive-makeindex.s390x \
        texlive-metafont.s390x \
        texlive-tex-gyre.noarch \
        texlive-cm.noarch \
        texlive-cm-super.noarch \
        texlive-babel.noarch \
        texlive-babel-english.noarch \
        texlive-pdfpages.noarch \
        texlive-pdflscape.noarch \
        texlive-graphics.noarch \
        texlive-graphics-def.noarch \
        texlive-hyperref.noarch \
        texlive-geometry.noarch \
        texlive-fancyhdr.noarch \
        texlive-caption.noarch \
        texlive-tools.noarch \
        texlive-etoolbox.noarch \
        texlive-xcolor.noarch \
        texlive-pgf.noarch \
        texlive-times.noarch \
        texlive-helvetic.noarch \
        texlive-courier.noarch \
        texlive-lm.noarch \
        texlive-lm-math.noarch \
        texlive-psnfss.noarch \
        texlive-amsmath.noarch \
        texlive-amsfonts.noarch \
        texlive-amscls.noarch \
        texlive-unicode-math.noarch \
        texlive-fontspec.noarch \
        texlive-microtype.noarch \
        texlive-parskip.noarch \
        texlive-enumitem.noarch \
        texlive-booktabs.noarch \
        texlive-multirow.noarch \
        texlive-listings.noarch \
        texlive-float.noarch \
        texlive-wrapfig.noarch \
        texlive-adjustbox.noarch \
        texlive-collectbox.noarch \
        texlive-upquote.noarch \
        texlive-url.noarch \
        texlive-fancyvrb.noarch \
        texlive-natbib.noarch \
        texlive-beamer.noarch \
	pandoc
    
    dnf clean all && rm -rf /var/cache/dnf /var/cache/yum
    
    # Verify installations
    pandoc --version
    tex --version
    pdftex --version
    xetex --version

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
