FROM alpine:3.22.0 AS builder

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

RUN sed -i 's/.*[ \t]*DOWNLOAD_PROTO_HTTPS/#define DOWNLOAD_PROTO_HTTPS/g' config/general.h
RUN sed -i 's/.*[ \t]*DIGEST_CMD/#define DIGEST_CMD/g' config/general.h

RUN sed -i 's/.*[ \t]*SANBOOT_PROTO_AOE/#undef SANBOOT_PROTO_AOE/g' config/general.h
RUN sed -i 's/.*[ \t]*SANBOOT_PROTO_ISCSI/#undef SANBOOT_PROTO_ISCSI/g' config/general.h
RUN sed -i 's/.*[ \t]*SANBOOT_CMD/#undef SANBOOT_CMD/g' config/general.h
RUN sed -i 's/.*[ \t]*DOWNLOAD_PROTO_FTP/#undef DOWNLOAD_PROTO_FTP/g' config/general.h
RUN sed -i 's/.*[ \t]*CRYPTO_80211_WEP/#undef CRYPTO_80211_WEP/g' config/general.h
RUN sed -i 's/.*[ \t]*CRYPTO_80211_WPA/#undef CRYPTO_80211_WPA/g' config/general.h
RUN sed -i 's/.*[ \t]*CRYPTO_80211_WPA2/#undef CRYPTO_80211_WPA2/g' config/general.h

RUN make bin/undionly.kpxe bin-x86_64-efi/ipxe.efi



FROM alpine:3.22.0

LABEL maintainer "jason.e.scholl@gmail.com"

RUN apk add --update \
  dnsmasq \
  && rm -rf /var/cache/apk/*

COPY --from=builder /build/src/bin/undionly.kpxe /build/src/bin-x86_64-efi/ipxe.efi /var/lib/tftpboot/

ENTRYPOINT ["dnsmasq", "--no-daemon"]
