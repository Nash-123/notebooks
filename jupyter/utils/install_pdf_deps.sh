#!/bin/bash

# Install dependencies required for Notebooks PDF exports

set -euxo

# Handle s390x architecture-specific dependencies
if [ "${TARGETARCH}" = "s390x" ]; then
    echo "Installing TeX Live and Pandoc packages for PDF export on s390x..."

    # First try UBI repositories
    dnf install -y pandoc texlive texlive-collection-basic texlive-collection-fontsrecommended || true

    # For packages not available in UBI, install from CentOS Stream
    # Note: This is a temporary solution until these packages are available in UBI
    # See: https://issues.redhat.com/browse/RHEL-100189 for similar request
    rpm -ivh --nodeps \
        https://mirror.stream.centos.org/9-stream/AppStream/s390x/os/Packages/texlive-adjustbox-*.rpm \
        https://mirror.stream.centos.org/9-stream/AppStream/s390x/os/Packages/texlive-enumitem-*.rpm \
        https://mirror.stream.centos.org/9-stream/AppStream/s390x/os/Packages/texlive-pdfcolmk-*.rpm \
        https://mirror.stream.centos.org/9-stream/AppStream/s390x/os/Packages/texlive-soul-*.rpm \
        https://mirror.stream.centos.org/9-stream/AppStream/s390x/os/Packages/texlive-tcolorbox-*.rpm \
        https://mirror.stream.centos.org/9-stream/AppStream/s390x/os/Packages/texlive-titling-*.rpm \
        https://mirror.stream.centos.org/9-stream/AppStream/s390x/os/Packages/texlive-ucs-*.rpm \
        https://mirror.stream.centos.org/9-stream/AppStream/s390x/os/Packages/texlive-amsmath-*.rpm \
        https://mirror.stream.centos.org/9-stream/AppStream/s390x/os/Packages/texlive-amsfonts-*.rpm \
        https://mirror.stream.centos.org/9-stream/AppStream/s390x/os/Packages/texlive-caption-*.rpm \
        https://mirror.stream.centos.org/9-stream/AppStream/s390x/os/Packages/texlive-eurosym-*.rpm \
        https://mirror.stream.centos.org/9-stream/AppStream/s390x/os/Packages/texlive-fancyvrb-*.rpm \
        https://mirror.stream.centos.org/9-stream/AppStream/s390x/os/Packages/texlive-framed-*.rpm \
        https://mirror.stream.centos.org/9-stream/AppStream/s390x/os/Packages/texlive-geometry-*.rpm \
        https://mirror.stream.centos.org/9-stream/AppStream/s390x/os/Packages/texlive-grffile-*.rpm \
        https://mirror.stream.centos.org/9-stream/AppStream/s390x/os/Packages/texlive-listings-*.rpm \
        https://mirror.stream.centos.org/9-stream/AppStream/s390x/os/Packages/texlive-mdframed-*.rpm \
        https://mirror.stream.centos.org/9-stream/AppStream/s390x/os/Packages/texlive-ulem-*.rpm \
        https://mirror.stream.centos.org/9-stream/AppStream/s390x/os/Packages/texlive-upquote-*.rpm \
        https://mirror.stream.centos.org/9-stream/AppStream/s390x/os/Packages/texlive-xcolor-*.rpm

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
