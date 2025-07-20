output "image_ids" {
  description = "Docker image IDs that were built"
  value = {
    for k, v in docker_image.applications : k => v.image_id
  }
}

output "image_tags" {
  description = "Image tags that were pushed"
  value = {
    for k, v in local.build_configs : k => v.tags
  }
}

output "pushed_images" {
  description = "Registry images that were pushed"
  value = {
    for k, v in docker_registry_image.applications : k => {
      name          = v.name
      sha256_digest = v.sha256_digest
    }
  }
}
