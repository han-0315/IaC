variable "region" {
  default     = "ap-northeast-2"
  type        = string
  description = "AWS Region"
}

variable "namespace" {
  default     = "workshop-s3-cf"
  type        = string
  description = "The project namespace to use for unique resource naming."
}

variable "environment" {
  default     = "dev"
  type        = string
  description = "The Deployment environment"
}

variable "purpose" {
  type        = string
  description = "The purpose of the resources"
}

variable "owner" {
  type        = string
  description = "Identify who is responsible for the resources"
}

variable "contents_bucket_name" {
  type        = string
  description = "The name of the S3 bucket for contents"
}
variable "logging_bucket_name" {
  type        = string
  description = "The name of the S3 bucket for logging"
}

variable "enable_logging" {
  default     = false
  type        = bool
  description = "Enable S3 bucket logging"
}

variable "enable_versioning" {
  default     = true
  type        = bool
  description = "Enable S3 bucket versioning"
}
