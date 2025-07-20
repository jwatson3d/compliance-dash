variable "repositories" {
  description = "Map of ECR repository configurations"
  type = map(object({
    type        = string
    description = string
  }))

  validation {
    condition = alltrue([
      for repo in values(var.repositories) :
      contains(["frontend", "backend"], repo.type)
    ])
    error_message = "Repository type must be either 'frontend' or 'backend'."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "AWS region"
  type        = string
}
