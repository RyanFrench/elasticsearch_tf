# Variables used
variable "domain" {
  description = "The ES domain name"
  type        = "string"
}

variable "node_count" {
  description = "The number of ES nodes to deploy"
  type        = "string"
  default     = "1"
}

variable "node_instance_type" {
  description = "The type of instance to use for the ES nodes"
  type        = "string"
  default     = "m4.large.elasticsearch"
}

variable "node_volume_size" {
  description = "The size of the EBS volumes attached to the ES nodes"
  type        = "string"
  default     = "10"
}

variable "access_cidr_block" {
  description = "The CIDR block that should have access to talk to the ES Domain"
  type        = "string"
}
