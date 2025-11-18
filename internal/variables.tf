variable "docker_host" {
  description = "The URL of the remote Docker host"
  type        = string
}

variable "ssh_key_path" {
  description = "File path to the SSH private key"
  type        = string
  sensitive   = true
}

variable "timezone" {
  description = "Region/City timezone"
  type        = string
  default     = "America/Los_Angeles"
}

variable "puid" {
  description = "User ID for container permissions"
  type        = string
  default     = "1000"
}

variable "pgid" {
  description = "Group ID for container permissions"
  type        = string
  default     = "1000"
}

variable "traefik_dashboard_credentials" {
  description = "Traefik dashboard basic auth credentials"
  type        = string
  sensitive   = true
}

variable "openvpn_username" {
  description = "OpenVPN username"
  type        = string
  sensitive   = true
}

variable "openvpn_password" {
  description = "OpenVPN password"
  type        = string
  sensitive   = true
}

variable "immich_version" {
  description = "Immich container version"
  type        = string
  default     = "release"
}

variable "db_password" {
  description = "Immich database password"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "Immich database username"
  type        = string
  default     = "postgres"
}

variable "db_database_name" {
  description = "Immich database name"
  type        = string
  default     = "immich"
}

variable "db_data_location" {
  description = "Path to immich database data directory"
  type        = string
}

variable "upload_location" {
  description = "Path to immich upload directory"
  type        = string
}

variable "log_level" {
  description = "FlareSolverr log level"
  type        = string
  default     = "info"
}

variable "log_html" {
  description = "FlareSolverr log HTML"
  type        = string
  default     = "false"
}

variable "captcha_solver" {
  description = "FlareSolverr captcha solver"
  type        = string
  default     = "none"
}

variable "beszel_key" {
  description = "Beszel agent key"
  type        = string
  sensitive   = true
}

variable "beszel_token" {
  description = "Beszel agent token"
  type        = string
  sensitive   = true
}

variable "semaphore_admin" {
  description = "Semaphore admin username"
  type        = string
}

variable "semaphore_admin_password" {
  description = "Semaphore admin password"
  type        = string
  sensitive   = true
}

variable "semaphore_admin_name" {
  description = "Semaphore admin name"
  type        = string
}

variable "semaphore_admin_email" {
  description = "Semaphore admin email"
  type        = string
}

variable "semaphore_db_dialect" {
  description = "Semaphore database dialect"
  type        = string
}

variable "media_server" {
  description = "Media server address"
  type        = string
}

variable "media_library_mnt" {
  description = "Path to media library"
  type        = string
}

variable "cf_dns_api_token" {
  description = "Cloudflare DNS API Token"
  type        = string
  sensitive   = true
}

variable "tovpn_mnt" {
  description = "Path to media library"
  type        = string
}