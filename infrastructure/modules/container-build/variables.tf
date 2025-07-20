variable "applications" {
  description = "Application configurations for building containers"
  type = map(object({
    context    = string
    dockerfile = string
  }))

  validation {
    condition = alltrue([
      for app_name, config in var.applications :
      can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", app_name))
    ])
    error_message = "Application names must be lowercase alphanumeric with hyphens."
  }
}

variable "repository_urls" {
  description = "Map of ECR repository URLs"
  type        = map(string)
}

variable "build_version" {
  description = "Build version tag (increment to force rebuild)"
  type        = string

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.build_version))
    error_message = "Build version must be in semantic version format (x.y.z)."
  }
}

variable "keep_locally" {
  description = "Whether to keep images locally after build"
  type        = bool
  default     = false
}

variable "keep_remotely" {
  description = "Whether to keep images in registry when destroyed"
  type        = bool
  default     = true
}
