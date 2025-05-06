# Docker OpenVPN SOCKS Proxy

A Docker-based solution that routes all traffic from a SOCKS proxy server through an OpenVPN connection, allowing applications to easily connect to VPN-only resources without configuring VPN clients directly.

It is designed to work on the Raspberry Pi 5, but should also work on any Linux-based machines and should be compatible with macOS too.

## Features

- OpenVPN client (v2.6.14) with optimized performance settings
- Integrated SOCKS proxy server (Dante)
- Docker-based deployment for easy setup and management

## Prerequisites

- Docker
- Docker Compose
- OpenVPN configuration file (`.ovpn`)


## Setup Instructions

1. Place your OpenVPN configuration file in the `config` directory as `client.ovpn`

2. Start the services:
   ```bash
   docker compose up -d
   ```

3. Verify the services are running:
   ```bash
   docker compose ps
   ```

## Configuration

### Port Configuration

The SOCKS proxy server listens on public port 1080 by default. You can modify this in the `docker-compose.yml` file under the `ports` section. For example, bind to localhost `"127.0.0.1:1080:1080"`

### DNS Settings

The container uses Cloudflare (1.1.1.1) and Google (8.8.8.8) DNS servers by default. You can modify these in the `docker-compose.yml` file.

### Network optimizations

You can apply some network optimizations by executing `sudo ./scripts/linux-optimize-network.sh`

### Git client configuration

Example of the `~/.ssh/config`:

```
Host github.com
    HostName github.com
    User <user_name>
    IdentityFile ~/.ssh/<key>
    ProxyCommand /usr/bin/nc -X 5 -x <host>:1080 %h %p
```

## Security Considerations

- The container runs with `NET_ADMIN` and `NET_RAW` capabilities
- TUN device is required for OpenVPN operation
- Container runs in privileged mode for full network access
- Configuration files should be kept secure and backed up


## Troubleshooting

1. Check OpenVPN logs:
   ```bash
	docker compose logs openvpn
   ```

2. Check SOCKS proxy logs:
   ```bash
   docker compose logs socks-proxy
   ```

3. Verify network connectivity and IP address:
   ```bash
   curl --socks5 localhost:1080 https://ifconfig.me
   ```

## License

WTFPL
