variable "ibmcloud_api_key" {
  description = "IBM Cloud API key"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "IBM Cloud region"
  type        = string
  default     = "us-south"
}

variable "resource_group" {
  description = "Resource group name"
  type        = string
  default     = "app-resource-group"
}

variable "cr_namespace" {
  description = "Container Registry namespace"
  type        = string
  default     = "app-namespace"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "node-app"
}

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 8080
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "app.example.com"
}
