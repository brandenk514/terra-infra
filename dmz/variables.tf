variable "docker_host" {
  description = "The URL of the remote Docker host"
  type        = string
}

variable "ssh_key_path" {
  description = "File path to the SSH private key"
  type        = string
  sensitive   = true
}
