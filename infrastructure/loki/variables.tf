variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-gov-west-1"
}

variable "bucket_name" {
  description = "Bucket name for Loki storage"
  type    = string
  default = "loki-cluster-logs"
}

variable "cluster_name" {
  description = "Name of EKS cluster"
  type = string
}

variable "namespace" {
  description = "Namespace of Loki installation"
  type        = string
}

variable "serviceaccount" {
  description = "Service account of Loki installation"
  type        = string
  default     = "loki"
}