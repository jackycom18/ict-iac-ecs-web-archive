region_name       = "cn-north-4"
availability_zone = "cn-north-4a"

vpc_name = "ict115-eip-vpc"
vpc_cidr = "192.168.0.0/16"

subnet_name       = "ict115-eip-subnet"
subnet_cidr       = "192.168.0.0/24"
subnet_gateway_ip = "192.168.0.1"

security_group_name = "ict115-eip-sg"
allowed_source_ip   = "183.11.219.62/32"

ecs_name       = "ict115-eip-web"
ecs_flavor_id  = "s6.small.1"
ecs_image_name = "Ubuntu 22.04 server 64bit"
ecs_password   = ""
ecs_disk_size  = 40
ecs_disk_type  = "SSD"

eip_name      = "ict115-eip-web-eip"
eip_bandwidth = 5

nginx_page_title   = "ICT 1.15 IaC Web Service"
nginx_page_content = "Deployed by Terraform and archived before apply"
