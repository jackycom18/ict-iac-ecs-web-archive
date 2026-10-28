# ============================================================
# Data Sources
# ============================================================

data "huaweicloud_images_image" "os" {
  name_regex   = var.ecs_image_name
  most_recent  = true
  visibility   = "public"
  architecture = "x86"
}

# ============================================================
# Auto-generate ECS password if not provided
# ============================================================

resource "random_password" "ecs_password" {
  count            = var.ecs_password == "" ? 1 : 0
  length           = 16
  special          = true
  override_special = "!@#%^&*"
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
}

locals {
  effective_password = var.ecs_password != "" ? var.ecs_password : random_password.ecs_password[0].result
}

# ============================================================
# 1. VPC
# ============================================================

resource "huaweicloud_vpc" "main" {
  name = var.vpc_name
  cidr = var.vpc_cidr
}

# ============================================================
# 2. Subnet
# ============================================================

resource "huaweicloud_vpc_subnet" "main" {
  name          = var.subnet_name
  cidr          = var.subnet_cidr
  gateway_ip    = var.subnet_gateway_ip
  vpc_id        = huaweicloud_vpc.main.id
  primary_dns   = "100.125.1.250"
  secondary_dns = "100.125.21.250"
}

# ============================================================
# 3. Security Group + Rule (port 80)
# ============================================================

resource "huaweicloud_networking_secgroup" "main" {
  name = var.security_group_name
}

resource "huaweicloud_networking_secgroup_rule" "ingress_80" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = var.allowed_source_ip
  security_group_id = huaweicloud_networking_secgroup.main.id
}

# ============================================================
# 4. EIP (Elastic Public IP)
# ============================================================

resource "huaweicloud_vpc_eip" "web" {
  name = var.eip_name

  publicip {
    type = "5_bgp"
  }

  bandwidth {
    name        = "${var.eip_name}-bw"
    size        = var.eip_bandwidth
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

# ============================================================
# 5. ECS Instance (with user_data auto-deploying Nginx)
# ============================================================

resource "huaweicloud_compute_instance" "web" {
  name              = var.ecs_name
  flavor_id         = var.ecs_flavor_id
  image_id          = data.huaweicloud_images_image.os.id
  availability_zone = var.availability_zone
  admin_pass        = local.effective_password

  network {
    uuid = huaweicloud_vpc_subnet.main.id
  }

  security_group_ids = [
    huaweicloud_networking_secgroup.main.id
  ]

  system_disk_type = var.ecs_disk_type
  system_disk_size = var.ecs_disk_size

  user_data = <<-EOF
#!/bin/bash
# Compatible with both yum (EulerOS) and dnf (HCE 2.0)
if command -v apt-get &>/dev/null; then
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y nginx
elif command -v dnf &>/dev/null; then
  dnf install -y nginx
else
  yum install -y nginx
fi
systemctl start nginx
systemctl enable nginx
echo '<h1>${var.nginx_page_title}</h1><p>${var.nginx_page_content}</p>' > /usr/share/nginx/html/index.html
EOF

  tags = {
    Project = "iac-eip-web-service"
  }
}

# ============================================================
# 6. Bind EIP to ECS
# ============================================================

resource "huaweicloud_compute_eip_associate" "web" {
  public_ip   = huaweicloud_vpc_eip.web.address
  instance_id = huaweicloud_compute_instance.web.id
}

# ============================================================
# Outputs
# ============================================================

output "ecs_public_ip" {
  description = "ECS public IP (EIP address)"
  value       = huaweicloud_vpc_eip.web.address
}

output "ecs_private_ip" {
  description = "ECS private IP"
  value       = huaweicloud_compute_instance.web.access_ip_v4
}

output "ecs_flavor_id" {
  description = "ECS flavor ID"
  value       = huaweicloud_compute_instance.web.flavor_id
}

output "ecs_image_id" {
  description = "ECS image ID"
  value       = huaweicloud_compute_instance.web.image_id
}

output "verify_command" {
  description = "Command to verify the web service"
  value       = "curl http://${huaweicloud_vpc_eip.web.address}"
}
