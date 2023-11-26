variable "ALERTMANAGER_DISCORD_CHANNEL_RECEIVER_URL" {
  type        = string
  description = "(optional) Discord channel URL used as alert manager receiver for kube-prom-stack. Which is further set up as a secret and mounted to alertmanager pod"
  default     = "FROM_AUTO_TFVARS_FILE"
  sensitive   = true
}

variable "secret_management_key_vault_name" {
  type        = string
  description = "(optional) Key vault used for kubernetes secret management with external secrets operator."
  default     = "k8s-projects-secrets-02"
}

