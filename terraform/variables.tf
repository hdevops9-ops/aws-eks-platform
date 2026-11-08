variable "region" {
  type    = string
  default = "us-east-1"
}
variable "environment" {
  type    = string
  default = "lab"
  validation {
    condition     = contains(["lab", "staging", "production"], var.environment)
    error_message = "Choose lab, staging, or production."
  }
}
variable "kubernetes_version" {
  description = "Select an EKS version currently supported in your AWS region."
  type        = string
}
variable "administrator_role_arn" {
  description = "Existing IAM role to grant cluster administration; do not use a root ARN."
  type        = string
  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.administrator_role_arn))
    error_message = "Supply an IAM role ARN."
  }
}
