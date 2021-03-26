# Adopted from https://github.com/richiefi/varnish-dynamic which was adopted from 
# https://knplabs.com/en/blog/how2tip-varnish-dynamic-backend-dns-resolution-in-a-docker-swarm-context
ARG VARNISH_VERSION=6.5.1
FROM varnish:${VARNISH_VERSION} AS builder

RUN cd /hello && echo "hi"

# Adapted from https://knplabs.com/en/blog/how2tip-varnish-dynamic-backend-dns-resolution-in-a-docker-swarm-context
# Define env vars for VMOD build
ENV PKG_CONFIG_PATH /usr/local/lib/pkgconfig
ENV ACLOCAL_PATH /usr/local/share/aclocal
ENV VMOD_DYNAMIC_VERSION 2.3.1
# hadolint ignore=DL3008,DL3005
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends build-essential \
            autoconf \
            automake \
            libtool \
            make \
            pkgconf \
            python3 \
            python-docutils \
            wget \
            unzip \
            libgetdns-dev \
            "varnish-dev=$VARNISH_VERSION"
RUN wget "https://github.com/nigoroll/libvmod-dynamic/archive/v${VMOD_DYNAMIC_VERSION}.zip" -O /tmp/libvmod-dynamic.zip
RUN unzip -d /tmp /tmp/libvmod-dynamic.zip
WORKDIR /tmp/libvmod-dynamic-${VMOD_DYNAMIC_VERSION}
RUN chmod +x ./autogen.sh
RUN ./autogen.sh
RUN ./configure --prefix=/usr
RUN make -j "$(nproc)"
RUN make install

FROM varnish:${VARNISH_VERSION}
COPY --from=builder /usr/lib/varnish/vmods/ /usr/lib/varnish/vmods/
# hadolint ignore=DL3008,DL3005
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends libgetdns10 && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/sbin" ldconfig -n /usr/lib/varnish/vmods
