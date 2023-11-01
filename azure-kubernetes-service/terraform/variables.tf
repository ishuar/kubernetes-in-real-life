variable "ALERTMANAGER_DISCORD_CHANNEL_RECEIVER_URL" {
  type        = string
  description = "(optional) Discord channel URL used as alert manager receiver for kube-prom-stack. Which is further set up as a secret and mounted to alertmanager pod"
  default     = "FROM_TF_VAR_ALERTMANAGER_DISCORD_CHANNEL_RECEIVER_URL_ENV_VAR"
}
