FROM alpine:3.15

# Install build dependencies and runtime dependencies
RUN apk add --no-cache \
    build-base \
    openssl-dev \
    lzo-dev \
    linux-headers \
    autoconf \
    automake \
    libtool \
    git \
    iptables \
    bash \
    ca-certificates \
    curl \
    linux-pam-dev \
    && mkdir -p /etc/openvpn/config \
    && mkdir -p /var/log/openvpn

# Download and build OpenVPN 2.4.12 from source
WORKDIR /tmp
RUN curl -sSL https://github.com/OpenVPN/openvpn/archive/refs/tags/v2.4.12.tar.gz -o openvpn-2.4.12.tar.gz && \
    tar -xzf openvpn-2.4.12.tar.gz && \
    cd openvpn-2.4.12 && \
    autoreconf -i && \
    ./configure --enable-small --disable-debug --enable-lzo --enable-crypto --enable-ssl --disable-plugin-auth-pam && \
    make && \
    make install && \
    cd .. && \
    rm -rf openvpn-2.4.12 openvpn-2.4.12.tar.gz && \
    apk del build-base openssl-dev linux-headers autoconf automake libtool git curl linux-pam-dev && \
    apk add --no-cache lzo openssl

# Set working directory
WORKDIR /etc/openvpn

# Create volume mount points
VOLUME /etc/openvpn/config
VOLUME /var/log/openvpn

# Copy entrypoint script
COPY scripts/vpn_entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/vpn_entrypoint.sh

# Use tun device when container starts
ENTRYPOINT ["/usr/local/bin/vpn_entrypoint.sh"]

# Default command to run
CMD ["openvpn", "--config", "/etc/openvpn/config/client.ovpn"]

