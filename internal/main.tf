terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.6.2"
    }
  }
}

provider "docker" {
  host     = var.docker_host
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null", "-i", var.ssh_key_path]
}

### NETWORKS ###

resource "docker_network" "proxy" {
  name   = "traefik-proxy-backend"
  driver = "bridge"
}

resource "docker_network" "immich_net" {
  name   = "Immich Backend Network"
  driver = "bridge"
}

### VOLUMES ###

resource "docker_volume" "semaphore_config" {
  name   = "semaphore_config"
  driver = "local"
}

resource "docker_volume" "semaphore_data" {
  name   = "semaphore_data"
  driver = "local"
}

resource "docker_volume" "semaphore_tmp" {
  name   = "semaphore_tmp"
  driver = "local"
}

resource "docker_volume" "transmission_conf_vol" {
  name   = "transmission_conf_vol"
  driver = "local"
}

resource "docker_volume" "sonarr_config" {
  name   = "sonarr_config"
  driver = "local"
}

resource "docker_volume" "radarr_config" {
  name   = "radarr_config"
  driver = "local"
}

resource "docker_volume" "lidarr_config" {
  name   = "lidarr_config"
  driver = "local"
}

resource "docker_volume" "prowlarr_config" {
  name   = "prowlarr_config"
  driver = "local"
}

resource "docker_volume" "huntarr_config" {
  name   = "huntarr_config"
  driver = "local"
}

resource "docker_volume" "lazylibrarian_config" {
  name   = "lazylibrarian_config"
  driver = "local"
}

resource "docker_volume" "beszel_data" {
  name   = "beszel_data"
  driver = "local"
}

resource "docker_volume" "beszel_socket" {
  name   = "beszel_socket"
  driver = "local"
}

resource "docker_volume" "beszel_agent_data" {
  name   = "beszel_agent_data"
  driver = "local"
}

resource "docker_volume" "media_library_nfs" {
  name   = var.media_server
  driver = "local"
  driver_opts = {
    type   = "nfs4"
    o      = "addr=192.168.105.20,rw"
    device = var.media_library_mnt
  }
}

### IMAGES ###

resource "docker_image" "traefik" {
  name          = "docker.io/library/traefik:v3.6.1"
  keep_locally  = true
}

resource "docker_image" "semaphore_ui" {
  name          = "semaphoreui/semaphore:v2.16.45"
  keep_locally  = true
}

resource "docker_image" "prowlarr" {
  name          = "linuxserver/prowlarr:latest"
  keep_locally  = true
}

resource "docker_image" "sonarr" {
  name          = "linuxserver/sonarr:latest"
  keep_locally  = true
}

resource "docker_image" "radarr" {
  name          = "linuxserver/radarr:latest"
  keep_locally  = true
}

resource "docker_image" "lidarr" {
  name          = "linuxserver/lidarr:latest"
  keep_locally  = true
}

resource "docker_image" "transmission_openvpn" {
  name          = "haugene/transmission-openvpn:5.3.2"
  keep_locally  = true
}

resource "docker_image" "dozzle" {
  name          = "amir20/dozzle:latest"
  keep_locally  = true
}

resource "docker_image" "immich_server" {
  name          = "ghcr.io/immich-app/immich-server:${var.immich_version}"
  keep_locally  = true
}

resource "docker_image" "immich_machine_learning" {
  name          = "ghcr.io/immich-app/immich-machine-learning:${var.immich_version}"
  keep_locally  = true
}

resource "docker_image" "redis" {
  name          = "docker.io/redis:6.2-alpine@sha256:148bb5411c184abd288d9aaed139c98123eeb8824c5d3fce03cf721db58066d8"
  keep_locally  = true
}

resource "docker_image" "postgres" {
  name          = "docker.io/tensorchord/pgvecto-rs:pg14-v0.2.0@sha256:90724186f0a3517cf6914295b5ab410db9ce23190a2d9d0b9dd6463e3fa298f0"
  keep_locally  = true
}

resource "docker_image" "jellyseerr" {
  name          = "fallenbagel/jellyseerr:2.7.3"
  keep_locally  = true
}

resource "docker_image" "huntarr" {
  name          = "huntarr/huntarr:latest"
  keep_locally  = true
}

resource "docker_image" "flaresolverr" {
  name          = "ghcr.io/flaresolverr/flaresolverr:latest"
  keep_locally  = true
}

resource "docker_image" "lazylibrarian" {
  name          = "lscr.io/linuxserver/lazylibrarian:latest"
  keep_locally  = true
}

resource "docker_image" "beszel_hub" {
  name          = "henrygd/beszel:latest"
  keep_locally  = true
}

resource "docker_image" "beszel_agent" {
  name          = "henrygd/beszel-agent:latest"
  keep_locally  = true
}

### CONTAINERS ###

resource "docker_container" "traefik" {
  image   = docker_image.traefik.image_id
  name    = "traefik"
  restart = "unless-stopped"
  
  networks_advanced {
    name    = docker_network.proxy.name
    aliases = ["traefik"]
  }
  networks_advanced {
    name    = docker_network.immich_net.name
    aliases = ["traefik"]
  }

  ports {
    internal = 80
    external = 80
  }
  ports {
    internal = 443
    external = 443
  }
  ports {
    internal = 8080
    external = 8080
  }
  ports {
    internal = 42069
    external = 42069
  }

  volumes {
    host_path      = "/etc/localtime"
    container_path = "/etc/localtime"
    read_only      = true
  }
  volumes {
    host_path      = "/run/docker.sock"
    container_path = "/run/docker.sock"
    read_only      = true
  }
  volumes {
    host_path      = "/opt/traefik/confs/traefik.yml"
    container_path = "/traefik.yml"
    read_only      = true
  }
  volumes {
    host_path      = "/opt/traefik/certs"
    container_path = "/var/traefik/certs"
  }
  volumes {
    host_path      = "/opt/traefik/confs/config.yml"
    container_path = "/config.yml"
    read_only      = true
  }

  security_opts = ["no-new-privileges:true"]
  
  env = [
    "TRAEFIK_DASHBOARD_CREDENTIALS=${var.traefik_dashboard_credentials}",
    "PUID=${var.puid}",
    "PGID=${var.pgid}",
    "TZ=${var.timezone}"
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.traefik.rule"
    value = "Host(`traefik.local.uaccloud.com`)"
  }
  labels {
    label = "traefik.http.routers.traefik.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.traefik.tls.certresolver"
    value = "cloudflare"
  }
  labels {
    label = "traefik.http.routers.traefik.entrypoints"
    value = "websecure"
  }
  labels {
    label = "traefik.http.middlewares.traefik.basicauth.users"
    value = "${var.traefik_dashboard_credentials}"
  }
  labels {
    label = "traefik.http.routers.traefik.middlewares"
    value = "traefik"
  }
  labels {
    label = "traefik.http.routers.traefik.tls.domains[0].main"
    value = "uaccloud.com"
  }
  labels {
    label = "traefik.http.routers.traefik.tls.domains[0].sans"
    value = "*.uaccloud.com"
  }
  labels {
    label = "traefik.http.routers.traefik.service"
    value = "api@internal"
  }
}

resource "docker_container" "semaphore_ui" {
  image   = docker_image.semaphore_ui.image_id
  name    = "semaphore-ui"
  restart = "unless-stopped"

  networks_advanced {
    name    = docker_network.proxy.name
    aliases = ["semaphore-ui"]
  }

  volumes {
    volume_name    = docker_volume.semaphore_data.name
    container_path = "/var/lib/semaphore"
  }
  volumes {
    volume_name    = docker_volume.semaphore_config.name
    container_path = "/etc/semaphore"
  }
  volumes {
    volume_name    = docker_volume.semaphore_tmp.name
    container_path = "/tmp/semaphore"
  }

  env = [
    "PUID=${var.puid}",
    "PGID=${var.pgid}",
    "TZ=${var.timezone}",
    "SEMAPHORE_ADMIN=${var.semaphore_admin}",
    "SEMAPHORE_ADMIN_PASSWORD=${var.semaphore_admin_password}",
    "SEMAPHORE_ADMIN_NAME=${var.semaphore_admin_name}",
    "SEMAPHORE_ADMIN_EMAIL=${var.semaphore_admin_email}",
    "SEMAPHORE_DB_DIALECT=${var.semaphore_db_dialect}"
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.semaphore-ui.rule"
    value = "Host(`awx.local.uaccloud.com`)"
  }
  labels {
    label = "traefik.http.services.semaphore-ui.loadbalancer.server.port"
    value = "3000"
  }
  labels {
    label = "traefik.http.routers.semaphore-ui.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.semaphore-ui.tls.certresolver"
    value = "cloudflare"
  }
  labels {
    label = "traefik.http.routers.semaphore-ui.entrypoints"
    value = "websecure"
  }
}

resource "docker_container" "prowlarr" {
  image   = docker_image.prowlarr.image_id
  name    = "prowlarr"
  restart = "unless-stopped"

  networks_advanced {
    name    = docker_network.proxy.name
    aliases = ["prowlarr"]
  }

  env = [
    "PUID=${var.puid}",
    "PGID=${var.pgid}",
    "TZ=${var.timezone}"
  ]

  volumes {
    volume_name    = docker_volume.prowlarr_config.name
    container_path = "/config"
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.prowlarr.rule"
    value = "Host(`prowlarr.local.uaccloud.com`)"
  }
  labels {
    label = "traefik.http.routers.prowlarr.entrypoints"
    value = "websecure"
  }
  labels {
    label = "traefik.http.services.prowlarr.loadbalancer.server.port"
    value = "9696"
  }
  labels {
    label = "traefik.http.routers.prowlarr.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.prowlarr.tls.certresolver"
    value = "cloudflare"
  }
}

resource "docker_container" "sonarr" {
  image   = docker_image.sonarr.image_id
  name    = "sonarr"
  restart = "unless-stopped"

  networks_advanced {
    name    = docker_network.proxy.name
    aliases = ["sonarr"]
  }

  env = [
    "PUID=${var.puid}",
    "PGID=${var.pgid}",
    "TZ=${var.timezone}"
  ]

  volumes {
    volume_name    = docker_volume.sonarr_config.name
    container_path = "/config"
  }
  volumes {
    volume_name    = docker_volume.media_library_nfs.name
    container_path = "/tv"
  }
  volumes {
    host_path      = var.tovpn_mnt
    container_path = "/downloads"
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.sonarr.rule"
    value = "Host(`sonarr.local.uaccloud.com`)"
  }
  labels {
    label = "traefik.http.routers.sonarr.entrypoints"
    value = "websecure"
  }
  labels {
    label = "traefik.http.services.sonarr.loadbalancer.server.port"
    value = "8989"
  }
  labels {
    label = "traefik.http.routers.sonarr.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.sonarr.tls.certresolver"
    value = "cloudflare"
  }
}

resource "docker_container" "radarr" {
  image   = docker_image.radarr.image_id
  name    = "radarr"
  restart = "unless-stopped"

  networks_advanced {
    name    = docker_network.proxy.name
    aliases = ["radarr"]
  }

  env = [
    "PUID=${var.puid}",
    "PGID=${var.pgid}",
    "TZ=${var.timezone}"
  ]

  volumes {
    volume_name    = docker_volume.radarr_config.name
    container_path = "/config"
  }
  volumes {
    volume_name    = docker_volume.media_library_nfs.name
    container_path = "/movies"
  }
  volumes {
    host_path      = var.tovpn_mnt
    container_path = "/downloads"
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.radarr.rule"
    value = "Host(`radarr.local.uaccloud.com`)"
  }
  labels {
    label = "traefik.http.routers.radarr.entrypoints"
    value = "websecure"
  }
  labels {
    label = "traefik.http.services.radarr.loadbalancer.server.port"
    value = "7878"
  }
  labels {
    label = "traefik.http.routers.radarr.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.radarr.tls.certresolver"
    value = "cloudflare"
  }
}

resource "docker_container" "lidarr" {
  image   = docker_image.lidarr.image_id
  name    = "lidarr"
  restart = "unless-stopped"

  networks_advanced {
    name    = docker_network.proxy.name
    aliases = ["lidarr"]
  }

  env = [
    "PUID=${var.puid}",
    "PGID=${var.pgid}",
    "TZ=${var.timezone}"
  ]

  volumes {
    volume_name    = docker_volume.lidarr_config.name
    container_path = "/config"
  }
  volumes {
    volume_name    = docker_volume.media_library_nfs.name
    container_path = "/music"
  }
  volumes {
    host_path      = var.tovpn_mnt
    container_path = "/downloads"
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.lidarr.rule"
    value = "Host(`lidarr.local.uaccloud.com`)"
  }
  labels {
    label = "traefik.http.routers.lidarr.entrypoints"
    value = "websecure"
  }
  labels {
    label = "traefik.http.services.lidarr.loadbalancer.server.port"
    value = "8686"
  }
  labels {
    label = "traefik.http.routers.lidarr.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.lidarr.tls.certresolver"
    value = "cloudflare"
  }
}

resource "docker_container" "tovpn" {
  image      = docker_image.transmission_openvpn.image_id
  name       = "tovpn"
  restart    = "unless-stopped"
  privileged = true

  networks_advanced {
    name    = docker_network.proxy.name
    aliases = ["tovpn"]
  }

  capabilities {
    add = ["NET_ADMIN"]
  }

  volumes {
    host_path      = var.tovpn_mnt
    container_path = "/data"
  }
  volumes {
    volume_name    = docker_volume.transmission_conf_vol.name
    container_path = "/config"
  }

  env = [
    "OPENVPN_PROVIDER=NORDVPN",
    "OPENVPN_CONFIG=",
    "OPENVPN_USERNAME=${var.openvpn_username}",
    "OPENVPN_PASSWORD=${var.openvpn_password}",
    "LOCAL_NETWORK=192.168.100.0/24, 192.168.105.0/24",
    "TRANSMISSION_WEB_HOME=/opt/transmission-ui/flood-for-transmission"
  ]

  log_driver = "json-file"
  log_opts = {
    "max-size" = "10m"
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.tovpn.rule"
    value = "Host(`tovpn.local.uaccloud.com`)"
  }
  labels {
    label = "traefik.http.services.tovpn.loadbalancer.server.port"
    value = "9091"
  }
  labels {
    label = "traefik.http.routers.tovpn.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.tovpn.tls.certresolver"
    value = "cloudflare"
  }
  labels {
    label = "traefik.http.routers.tovpn.entrypoints"
    value = "websecure"
  }
}

resource "docker_container" "dozzle" {
  image   = docker_image.dozzle.image_id
  name    = "dozzle"
  restart = "unless-stopped"

  networks_advanced {
    name    = docker_network.proxy.name
    aliases = ["dozzle"]
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }

  env = [
    "DOZZLE_ENABLE_ACTIONS=true",
    "DOZZLE_ENABLE_SHELL=true"
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.dozzle.rule"
    value = "Host(`dozzle.local.uaccloud.com`)"
  }
  labels {
    label = "traefik.http.services.dozzle.loadbalancer.server.port"
    value = "8080"
  }
  labels {
    label = "traefik.http.routers.dozzle.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.dozzle.tls.certresolver"
    value = "cloudflare"
  }
  labels {
    label = "traefik.http.routers.dozzle.entrypoints"
    value = "websecure"
  }
}

resource "docker_container" "immich_redis" {
  image   = docker_image.redis.image_id
  name    = "immich_redis"
  restart = "unless-stopped"

  networks_advanced {
    name    = docker_network.immich_net.name
    aliases = ["immich_redis"]
  }
}

resource "docker_container" "immich_postgres" {
  image   = docker_image.postgres.image_id
  name    = "immich_postgres"
  restart = "unless-stopped"

  networks_advanced {
    name    = docker_network.immich_net.name
    aliases = ["immich_postgres"]
  }

  env = [
    "POSTGRES_PASSWORD=${var.db_password}",
    "POSTGRES_USER=${var.db_username}",
    "POSTGRES_DB=${var.db_database_name}",
    "POSTGRES_INITDB_ARGS=--data-checksums"
  ]

  volumes {
    host_path      = var.db_data_location
    container_path = "/var/lib/postgresql/data"
  }

  command = [
    "postgres",
    "-c", "shared_preload_libraries=vectors.so",
    "-c", "search_path=\"$user\", public, vectors",
    "-c", "logging_collector=on",
    "-c", "max_wal_size=2GB",
    "-c", "shared_buffers=512MB",
    "-c", "wal_compression=on"
  ]
}

resource "docker_container" "immich_server" {
  image   = docker_image.immich_server.image_id
  name    = "immich_server"
  restart = "unless-stopped"
  
  depends_on = [
    docker_container.immich_redis,
    docker_container.immich_postgres
  ]

  networks_advanced {
    name    = docker_network.proxy.name
    aliases = ["immich_server"]
  }
  networks_advanced {
    name    = docker_network.immich_net.name
    aliases = ["immich_server"]
  }

  volumes {
    host_path      = var.upload_location
    container_path = "/usr/src/app/upload"
  }
  volumes {
    host_path      = "/etc/localtime"
    container_path = "/etc/localtime"
    read_only      = true
  }

  env = [
    "PUID=${var.puid}",
    "PGID=${var.pgid}",
    "TZ=${var.timezone}"
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = "traefik-proxy-backend"
  }
  labels {
    label = "traefik.http.routers.immich-server.rule"
    value = "Host(`photos.uaccloud.com`)"
  }
  labels {
    label = "traefik.http.services.immich-server.loadbalancer.server.port"
    value = "2283"
  }
  labels {
    label = "traefik.http.routers.immich-server.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.immich-server.tls.certresolver"
    value = "cloudflare"
  }
  labels {
    label = "traefik.http.routers.immich-server.entrypoints"
    value = "external-websecure"
  }
}

resource "docker_container" "immich_machine_learning" {
  image   = docker_image.immich_machine_learning.image_id
  name    = "immich_machine_learning"
  restart = "unless-stopped"

  networks_advanced {
    name    = docker_network.immich_net.name
    aliases = ["immich_machine_learning"]
  }

  volumes {
    host_path      = "/mnt/immich-repo/model-cache"
    container_path = "/cache"
  }

  env = [
    "PUID=${var.puid}",
    "PGID=${var.pgid}",
    "TZ=${var.timezone}"
  ]
}

resource "docker_container" "jellyseerr" {
  image   = docker_image.jellyseerr.image_id
  name    = "jellyseerr"
  restart = "unless-stopped"

  networks_advanced {
    name    = docker_network.proxy.name
    aliases = ["jellyseerr"]
  }

  volumes {
    host_path      = "/opt/jellyseer"
    container_path = "/app/config"
  }

  env = [
    "LOG_LEVEL=info",
    "TZ=${var.timezone}"
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = "traefik-proxy-backend"
  }
  labels {
    label = "traefik.http.routers.jellyseerr.rule"
    value = "Host(`request.uaccloud.com`)"
  }
  labels {
    label = "traefik.http.services.jellyseerr.loadbalancer.server.port"
    value = "5055"
  }
  labels {
    label = "traefik.http.routers.jellyseerr.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.jellyseerr.tls.certresolver"
    value = "cloudflare"
  }
  labels {
    label = "traefik.http.routers.jellyseerr.entrypoints"
    value = "external-websecure"
  }
}

resource "docker_container" "huntarr" {
  image   = docker_image.huntarr.image_id
  name    = "huntarr"
  restart = "unless-stopped"

  networks_advanced {
    name    = docker_network.proxy.name
    aliases = ["huntarr"]
  }

  volumes {
    volume_name    = docker_volume.huntarr_config.name
    container_path = "/config"
  }

  env = [
    "TZ=${var.timezone}"
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.huntarr.rule"
    value = "Host(`huntarr.local.uaccloud.com`)"
  }
  labels {
    label = "traefik.http.services.huntarr.loadbalancer.server.port"
    value = "9705"
  }
  labels {
    label = "traefik.http.routers.huntarr.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.huntarr.tls.certresolver"
    value = "cloudflare"
  }
  labels {
    label = "traefik.http.routers.huntarr.entrypoints"
    value = "websecure"
  }
}

resource "docker_container" "flaresolverr" {
  image   = docker_image.flaresolverr.image_id
  name    = "flaresolverr"
  restart = "unless-stopped"
  hostname = "flaresolverr"

  networks_advanced {
    name    = docker_network.proxy.name
    aliases = ["flaresolverr"]
  }

  env = [
    "LOG_LEVEL=${var.log_level}",
    "LOG_HTML=${var.log_html}",
    "CAPTCHA_SOLVER=${var.captcha_solver}",
    "TZ=${var.timezone}",
    "TEST_URL=https://www.google.com"
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.flaresolverr.rule"
    value = "Host(`flaresolverr.local.uaccloud.com`)"
  }
  labels {
    label = "traefik.http.services.flaresolverr.loadbalancer.server.port"
    value = "8191"
  }
  labels {
    label = "traefik.http.routers.flaresolverr.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.flaresolverr.tls.certresolver"
    value = "cloudflare"
  }
  labels {
    label = "traefik.http.routers.flaresolverr.entrypoints"
    value = "websecure"
  }
}

resource "docker_container" "lazylibrarian" {
  image   = docker_image.lazylibrarian.image_id
  name    = "lazylibrarian"
  restart = "unless-stopped"

  networks_advanced {
    name    = docker_network.proxy.name
    aliases = ["lazylibrarian"]
  }

  volumes {
    volume_name    = docker_volume.lazylibrarian_config.name
    container_path = "/config"
  }
  volumes {
    host_path      = var.tovpn_mnt
    container_path = "/downloads"
  }
  volumes {
    volume_name    = docker_volume.media_library_nfs.name
    container_path = "/books"
  }

  env = [
    "PUID=${var.puid}",
    "PGID=${var.pgid}",
    "TZ=${var.timezone}",
    "DOCKER_MODS=linuxserver/mods:universal-calibre|linuxserver/mods:lazylibrarian-ffmpeg"
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.lazylibrarian.rule"
    value = "Host(`lazylibrarian.local.uaccloud.com`)"
  }
  labels {
    label = "traefik.http.services.lazylibrarian.loadbalancer.server.port"
    value = "5299"
  }
  labels {
    label = "traefik.http.routers.lazylibrarian.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.lazylibrarian.tls.certresolver"
    value = "cloudflare"
  }
  labels {
    label = "traefik.http.routers.lazylibrarian.entrypoints"
    value = "websecure"
  }
}

resource "docker_container" "beszel_hub" {
  image   = docker_image.beszel_hub.image_id
  name    = "beszel"
  restart = "unless-stopped"

  networks_advanced {
    name    = docker_network.proxy.name
    aliases = ["beszel"]
  }

  ports {
    internal = 8090
    external = 8090
  }

  volumes {
    volume_name    = docker_volume.beszel_data.name
    container_path = "/beszel_data"
  }
  volumes {
    volume_name    = docker_volume.beszel_socket.name
    container_path = "/beszel_socket"
  }

  env = [
    "PUID=${var.puid}",
    "PGID=${var.pgid}",
    "TZ=${var.timezone}"
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.beszel.rule"
    value = "Host(`beszel.local.uaccloud.com`)"
  }
  labels {
    label = "traefik.http.services.beszel.loadbalancer.server.port"
    value = "8090"
  }
  labels {
    label = "traefik.http.routers.beszel.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.beszel.tls.certresolver"
    value = "cloudflare"
  }
  labels {
    label = "traefik.http.routers.beszel.entrypoints"
    value = "websecure"
  }
}

resource "docker_container" "beszel_agent" {
  image   = docker_image.beszel_agent.image_id
  name    = "beszel-agent"
  restart = "unless-stopped"
  network_mode = "host"

  volumes {
    volume_name    = docker_volume.beszel_agent_data.name
    container_path = "/var/lib/beszel-agent"
  }
  volumes {
    volume_name    = docker_volume.beszel_socket.name
    container_path = "/beszel_socket"
  }
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }

  env = [
    "LISTEN=/beszel_socket/beszel.sock",
    "HUB_URL=http://localhost:8090",
    "TOKEN=${var.beszel_agent_token}",
    "KEY=${var.beszel_agent_key}"
  ]
}
