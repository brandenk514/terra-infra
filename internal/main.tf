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

resource "docker_network" "proxy_srv_net" {
  name   = "proxy_srv_net"
  driver = "bridge"
}

### VOLUMES ###

# resource "docker_volume" "transmission_dl_vol" {
#   name   = "transmission_dl_vol"
#   driver = "local"
#   driver_opts = {
#     type   = "nfs4"
#     o      = "addr=${var.media_server},rw,noatime,rsize=8192,wsize=8192,tcp,timeo=14"
#     device = var.transmission_mnt
#   }
# }

# resource "docker_volume" "media_library" {
#   name   = "media-library"
#   driver = "local"
#   driver_opts = {
#     type   = "nfs4"
#     o      = "addr=${var.media_server},rw,noatime,rsize=8192,wsize=8192,tcp,timeo=14"
#     device = var.media_library_mnt
#   }
# }

### IMAGES ###

resource "docker_image" "uptime_kuma" {
  name          = "louislam/uptime-kuma:1.23.16"
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

resource "docker_image" "traefik" {
  name          = "traefik:v3.0"
  keep_locally  = true
}

# resource "docker_image" "tdarr" {
#   name          = "ghcr.io/haveagitgat/tdarr:latest"
#   keep_locally  = true
# }

# resource "docker_image" "transmission_openvpn" {
#   name          = "haugene/transmission-openvpn"
#   keep_locally  = true
# }

# resource "docker_image" "flaresolverr" {
#   name          = "flaresolverr/flaresolverr:latest"
#   keep_locally  = true
# }

### CONTAINERS ###

resource "docker_container" "uptime_kuma" {
  image   = docker_image.uptime_kuma.image_id
  name    = "uptime-kuma"
  restart = "unless-stopped"
  networks_advanced {
    name    = docker_network.proxy_srv_net.name
    aliases = ["uptime-kuma"]
  }
  ports {
    internal = 3001
    external = 3001
  }
  volumes {
    volume_name    = "uptime_kuma_data"
    container_path = "/app/data"
  }
}

resource "docker_container" "sonarr" {
  image   = docker_image.sonarr.image_id
  name    = "sonarr"
  restart = "unless-stopped"
  networks_advanced {
    name    = docker_network.proxy_srv_net.name
    aliases = ["sonarr"]
  }
  ports {
    internal = 8989
    external = 8989
  }
  env = [
    "PUID=1000",
    "PGID=1000",
    "TZ=${var.timezone}"
  ]
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.sonarr.rule"
    value = "Host(`sonarr.localhost`)"
  }
  labels {
    label = "traefik.http.routers.sonarr.entrypoints"
    value = "web"
  }
  labels {
    label = "traefik.http.services.sonarr.loadbalancer.server.port"
    value = "8989"
  }
  volumes {
    volume_name    = "sonarr_data"
    container_path = "/config"
  }
}

resource "docker_container" "radarr" {
  image   = docker_image.radarr.image_id
  name    = "radarr"
  restart = "unless-stopped"
  networks_advanced {
    name    = docker_network.proxy_srv_net.name
    aliases = ["radarr"]
  }
  ports {
    internal = 7878
    external = 7878
  }
  env = [
    "PUID=1000",
    "PGID=1000",
    "TZ=${var.timezone}"
  ]
  volumes {
    volume_name    = "radarr_data"
    container_path = "/config"
  }
}

resource "docker_container" "lidarr" {
  image   = docker_image.lidarr.image_id
  name    = "lidarr"
  restart = "unless-stopped"
  networks_advanced {
    name    = docker_network.proxy_srv_net.name
    aliases = ["lidarr"]
  }
  ports {
    internal = 8686
    external = 8686
  }
  env = [
    "PUID=1000",
    "PGID=1000",
    "TZ=${var.timezone}"
  ]
  volumes {
    volume_name    = "lidarr_data"
    container_path = "/config"
  }
}

resource "docker_container" "traefik" {
  image   = docker_image.traefik.image_id
  name    = "traefik"
  restart = "unless-stopped"
  networks_advanced {
    name    = docker_network.proxy_srv_net.name
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
  env = [
    "TZ=${var.timezone}"
  ]
  command = [
    "--api.insecure=true",
    "--providers.docker=true",
    "--providers.docker.exposedbydefault=false",
    "--entrypoints.web.address=:80",
    "--entrypoints.websecure.address=:443"
  ]
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }
  volumes {
    volume_name    = "traefik_data"
    container_path = "/data"
  }
}

# resource "docker_container" "tdarr_server" {
#   image        = docker_image.tdarr.image_id
#   name         = "tdarr_server"
#   restart      = "unless-stopped"
#   network_mode = "bridge"
#   networks_advanced {
#     name    = docker_network.flix_net.name
#     aliases = ["tdarr_server"]
#   }
#   ports {
#     internal = 8265
#     external = 8265
#   }
#   ports {
#     internal = 8266
#     external = 8266
#   }
#   env = [
#     "TZ=${var.timezone}",
#     "PUID=1000",
#     "PGID=1000",
#     "UMASK_SET=002",
#     "serverIP=0.0.0.0",
#     "serverPort=8266",
#     "webUIPort=8265",
#     "internalNode=false",
#     "inContainer=true",
#     "ffmpegVersion=6",
#     "nodeName=dstack-tdarr",
#   ]
#   volumes {
#     volume_name    = "tdarr_data"
#     container_path = "/app/server"
#   }
#   volumes {
#     volume_name    = "tdarr_config"
#     container_path = "/app/configs"
#   }
#   volumes {
#     volume_name    = "tdarr_logs"
#     container_path = "/app/logs"
#   }
#   volumes {
#     volume_name    = docker_volume.media_library.name
#     container_path = "/media"
#   }
#   volumes {
#     volume_name    = "tdarr_transcode_cache"
#     container_path = "/temp"
#   }
# }

# resource "docker_container" "transmission_openvpn" {
#   image   = docker_image.transmission_openvpn.image_id
#   name    = "tovpn"
#   restart = "unless-stopped"
#   capabilities {
#     add = ["NET_ADMIN"]
#   }
#   privileged = true
#   networks_advanced {
#     name    = docker_network.tovpn_net.name
#     aliases = ["tovpn"]
#   }
#   ports {
#     internal = 9091
#     external = 9091
#   }
#   env = [
#     "OPENVPN_PROVIDER=NORDVPN",
#     "OPENVPN_CONFIG=",
#     "OPENVPN_USERNAME=${var.openvpn_username}",
#     "OPENVPN_PASSWORD=${var.openvpn_password}",
#     "LOCAL_NETWORK=192.168.100.0/24, 192.168.105.0/24",
#     "TRANSMISSION_WEB_HOME=/opt/transmission-ui/flood-for-transmission"
#   ]
#   volumes {
#     volume_name    = docker_volume.transmission_dl_vol.name
#     container_path = "/data"
#   }
#   volumes {
#     volume_name    = "transmission_conf_vol"
#     container_path = "/config"
#   }
# }

# resource "docker_container" "flaresolverr" {
#   image   = docker_image.flaresolverr.image_id
#   name    = "flaresolverr"
#   restart = "unless-stopped"
#   networks_advanced {
#     name    = docker_network.tovpn_net.name
#     aliases = ["flaresolverr"]
#   }
#   ports {
#     internal = 8191
#     external = 8191
#   }
#   env = [
#     "LOG_LEVEL=info",
#     "LOG_HTML=false",
#     "CAPTCHA_SOLVER=none",
#     "TZ=${var.timezone}",
#   ]
# }
