variable "waf_region" {
  description = "Value of Name Tag for the region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Value of Name Tag for the bucket"
  type        = string
  default     = "minas-waf-bucket"
}

variable "static_waf" {
  description = "Value of Name Tag for the static website WAF"
  type        = string
  default     = "minas-static-waf"
}