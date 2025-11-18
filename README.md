# Terraform Infrastructure

This directory contains a complete Terraform deployment that replicates your Docker Compose stack.

## Overview

The deployment includes:

- **Networking**: Traefik proxy network and Immich backend network
- **Reverse Proxy**: Traefik v3.6.1 with Cloudflare SSL/TLS and basic auth
- **Media Management**: Sonarr, Radarr, Lidarr, Prowlarr
- **Download Client**: Transmission with OpenVPN
- **Automation**: Semaphore UI
- **Photo Management**: Immich with PostgreSQL and Redis
- **Monitoring**: Dozzle, Beszel Agent
- **Additional Services**: JellySeer, Huntarr, FlareSolverr, LazyLibrarian

## Prerequisites

1. **Terraform** >= 1.0
2. **Docker Provider** >= 3.6.2 (automatically installed via `terraform init`)
3. SSH access to your Docker host
4. The following host directories pre-created:
   - `/opt/traefik/confs/` - Traefik configuration files
   - `/opt/traefik/certs/` - Traefik certificates directory
   - `/mnt/tovpn-repo/` - Transmission downloads directory
   - `/mnt/immich-repo/` - Immich data directories
   - `/opt/jellyseer/` - Jellyseerr configuration
   - `/opt/beszel/agent_data/` - Beszel agent data

## Configuration

1. Copy the example variables file:
   ```bash
   cp .tfvars.example .tfvars
   ```

2. Edit `.tfvars` with your specific values:
   - Docker host SSH connection string
   - SSH key path
   - Traefik dashboard credentials (bcrypt hashed)
   - Database passwords
   - API keys and tokens

## Important Variables

### Required Sensitive Variables

- `traefik_dashboard_credentials` - Basic auth credentials with hashed password
- `openvpn_username` - NordVPN credentials
- `openvpn_password` - NordVPN credentials
- `db_password` - Immich database password
- `beszel_agent_key` and `beszel_agent_token` - Monitoring credentials

### Directory Paths
- `db_data_location` - PostgreSQL data directory
- `upload_location` - Immich upload directory

### Optional Variables
- `immich_version` - Defaults to "release"
- `timezone` - Defaults to "America/Los_Angeles"
- `puid` and `pgid` - Defaults to "1000"

## Deployment

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Review the plan:
   ```bash
   terraform plan -lock=false --var-file=./.tfvars
   ```

3. Apply the configuration:
   ```bash
   terraform apply -lock=false --var-file=./.tfvars
   ```

## Network Architecture

### Traefik Proxy Network
- Primary network for external-facing services
- Services: Traefik, Sonarr, Radarr, Lidarr, Prowlarr, Transmission, Dozzle, JellySeer, LazyLibrarian, FlareSolverr
- All configured with Traefik labels for automatic routing

### Immich Backend Network
- Isolated network for Immich services
- Services: Immich Server, Immich ML, Redis, PostgreSQL
- Traefik also connected for external routing

## Traefik Configuration

Services are automatically routed via Traefik with labels. Key configurations:

- **Entry Points**: 
  - `web` (HTTP:80)
  - `websecure` (HTTPS:443)
  - `external-websecure` (External HTTPS on 443)
- **Dashboard**: `traefik.local.uaccloud.com` (requires basic auth)
- **Cert Resolver**: Cloudflare
- **TLS Domains**: `*.uaccloud.com`

## Volumes

All volumes are Docker-managed except:
- NFS mount for media library: `192.168.105.20:/mnt/backup_pool/media-backup-pool`
- Host-mounted directories for configuration persistence

## Security Considerations

1. **Traefik**: Security context prevents container escape (`no-new-privileges:true`)
2. **Transmission**: NET_ADMIN capability with privileged mode for VPN tunneling
3. **Secrets**: Use `.tfvars` with sensitive=true for credentials (excluded from Git)
4. **Docker Socket**: Mounted read-only where needed

## Troubleshooting

### Docker Connection Issues
```bash
terraform login
# Ensure SSH key has proper permissions: chmod 600 ~/.ssh/id_rsa
```

### Traefik Routing Issues
- Check labels are applied: `docker inspect <container>`
- Verify DNS resolution for domains
- Check Traefik dashboard at port 8080

### Database Connection
- Verify PostgreSQL is running first
- Check Immich server logs: `docker logs immich_server`

### NFS Mount Issues
- Verify NFS export is accessible from Docker host
- Check firewall rules on NFS server

## Upgrading Services

To upgrade a service image:
1. Update the image tag in `main.tf`
2. Run `terraform plan` to preview
3. Apply with `terraform apply`

## Removing Resources

To cleanly remove all resources:
```bash
terraform destroy -lock=false --var-file=./.tfvars
```

## State Management

- State file is stored locally (`.tfstate`)
- For production, consider remote state (S3, Terraform Cloud, etc.)
- Backup state before major changes

## Additional Resources

- [Terraform Docker Provider](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs)
- [Traefik Documentation](https://doc.traefik.io/)
- [Immich Documentation](https://immich.app/)
