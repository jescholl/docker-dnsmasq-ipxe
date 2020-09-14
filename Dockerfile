FROM alpine:3.11.5 AS builder

RUN apk add --update \
  git \
  g++ \
  make \
  perl \
  xz-dev \
  bash \
  cdrkit

RUN git clone git://git.ipxe.org/ipxe.git /build

WORKDIR /build/src

RUN sed -i 's/#undef.*DOWNLOAD_PROTO_HTTPS/#define DOWNLOAD_PROTO_HTTPS/g' config/general.h

RUN make bin/undionly.kpxe



FROM alpine:3.11.5

LABEL maintainer "jason.e.scholl@gmail.com"

RUN apk add --update \
  dnsmasq \
  && rm -rf /var/cache/apk/*

COPY --from=builder /build/src/bin/undionly.kpxe /var/lib/tftpboot/undionly.kpxe

ENTRYPOINT ["dnsmasq", "--no-daemon"]
