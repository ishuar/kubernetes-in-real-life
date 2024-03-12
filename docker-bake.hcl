target "docker-metadata-action" {
  tags = ["docker.io/ishuar/kubernetes-in-real-life:nginx-webapp-0.0.2"]
}

target "sample-app" {
  inherits   = ["docker-metadata-action"]
  tags       = target.docker-metadata-action.tags
  platforms  = ["linux/amd64", "linux/arm64"]
  dockerfile = "sample-app.Dockerfile"
}
