# ============================================================
# Authentication
# ============================================================

variable "region_name" {
  description = "The region where resources will be created"
  type        = string
  default     = "cn-north-4"
}

variable "availability_zone" {
  description = "The availability zone for ECS"
  type        = string
  default     = "cn-north-4a"
}

# AK/SK are read from environment variables (HW_ACCESS_KEY, HW_SECRET_KEY)

# ============================================================
# VPC
# ============================================================

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "iac-eip-vpc"
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC"
  type        = string
  default     = "192.168.0.0/16"
}

# ============================================================
# Subnet
# ============================================================

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
  default     = "iac-eip-subnet"
}

variable "subnet_cidr" {
  description = "The CIDR block of the subnet"
  type        = string
  default     = "192.168.0.0/24"
}

variable "subnet_gateway_ip" {
  description = "The gateway IP of the subnet"
  type        = string
  default     = "192.168.0.1"
}

# ============================================================
# Security Group
# ============================================================

variable "security_group_name" {
  description = "The name of the security group"
  type        = string
  default     = "iac-eip-sg"
}

variable "allowed_source_ip" {
  description = "The IP/CIDR allowed to access port 80. e.g. 1.2.3.4/32 or 0.0.0.0/0"
  type        = string
  default     = "0.0.0.0/0"
}

# ============================================================
# ECS
# ============================================================

variable "ecs_name" {
  description = "The name of the ECS instance"
  type        = string
  default     = "iac-eip-web"
}

variable "ecs_flavor_id" {
  description = "The ECS flavor ID. Default: s6.small.1 (1C1G). User can specify e.g. ac7.large.2 (2C4G)"
  type        = string
  default     = "s6.small.1"
}

variable "ecs_image_name" {
  description = "The public image name for ECS"
  type        = string
  default     = "Huawei Cloud EulerOS 2.0"
}

variable "ecs_password" {
  description = "The admin password. Leave empty to auto-generate."
  type        = string
  default     = ""
  sensitive   = true
}

variable "ecs_disk_size" {
  description = "System disk size in GB"
  type        = number
  default     = 40
}

variable "ecs_disk_type" {
  description = "System disk type: SSD, GPSSD, SAS"
  type        = string
  default     = "SSD"
}

# ============================================================
# EIP
# ============================================================

variable "eip_name" {
  description = "The name of the EIP"
  type        = string
  default     = "iac-eip-web-eip"
}

variable "eip_bandwidth" {
  description = "EIP bandwidth in Mbps"
  type        = number
  default     = 5
}

# ============================================================
# Nginx (user_data)
# ============================================================

variable "nginx_page_title" {
  description = "The title displayed on the Nginx page"
  type        = string
  default     = "Hello from IaC"
}

variable "nginx_page_content" {
  description = "The HTML content served by Nginx"
  type        = string
  default     = "Nginx deployed by Terraform user_data"
}
