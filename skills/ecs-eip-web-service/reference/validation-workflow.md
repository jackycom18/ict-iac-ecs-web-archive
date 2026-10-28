# Validation Workflow

## Configure Huawei Cloud Mirror (MUST DO FIRST)

```hcl
provider_installation {
  network_mirror {
    url = "https://mirrors.huaweicloud.com/terraform/"
    include = ["registry.terraform.io/huaweicloud/*"]
  }
  direct {
    include = ["registry.terraform.io/hashicorp/*"]
  }
}
```

```bash
export TF_CLI_CONFIG_FILE="/path/to/.tfrc"
```

**MANDATORY: Every `terraform init` MUST include TF_CLI_CONFIG_FILE.**

## Validation Order

```
terraform fmt -recursive
terraform init
terraform validate
terraform plan
```

## ECS Flavor Query

Default flavor s6.small.1 (1C1G) verified available in cn-north-4a.

To query other flavors:

```hcl
data "huaweicloud_compute_flavors" "filtered" {
  availability_zone = "cn-north-4a"
  cpu_core_count    = 2
  memory_size       = 4
}
```

## EIP Configuration

EIP requires `publicip` and `bandwidth` blocks (not flat arguments):

```hcl
resource "huaweicloud_vpc_eip" "web" {
  name = "my-eip"
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "my-eip-bw"
    size        = 5
    share_type  = "PER"
    charge_mode = "traffic"
  }
}
```

## EIP Binding to ECS

Use `huaweicloud_compute_eip_associate` (not inline `eip {}` block):

```hcl
resource "huaweicloud_compute_eip_associate" "web" {
  public_ip   = huaweicloud_vpc_eip.web.address
  instance_id = huaweicloud_compute_instance.web.id
}
```

**Note: `huaweicloud_compute_instance` does NOT support inline `eip {}` block.**

## user_data Format

user_data must be a base64-encoded script. Terraform handles encoding automatically when using heredoc:

```hcl
user_data = <<-EOF
#!/bin/bash
yum install -y nginx
systemctl start nginx
EOF
```

**Note:** `<<-EOF` allows indentation. The script is executed by cloud-init on first boot.

## Post-Apply Verification

After `terraform apply`, wait ~1-2 minutes for ECS to boot and user_data to execute:

```bash
# Get the public IP
EIP=$(terraform output -raw ecs_public_ip)

# Verify Nginx is running
curl http://$EIP

# Expected output:
# <h1>Hello from IaC</h1><p>Nginx deployed by Terraform user_data</p>
```

If curl fails:
1. Wait another minute (user_data may still be running)
2. Check ECS status in console (should be "运行中")
3. Verify security group allows port 80 from your IP

## GitCode API

### Create Repository

```bash
curl -X POST "https://gitcode.com/api/v5/user/repos" \
  -H "Content-Type: application/json" \
  -H "Authorization: token ${GITCODE_TOKEN}" \
  -d '{"name": "repo-name", "private": true}'
```

### Response

```json
{
  "clone_url": "https://gitcode.com/username/repo-name.git",
  "html_url": "https://gitcode.com/username/repo-name"
}
```

## Known Provider Quirks (Tested with provider v1.97.2)

| Resource | Quirk | Fix |
|----------|-------|-----|
| `huaweicloud_compute_instance` | No inline `eip {}` block | Use separate `huaweicloud_vpc_eip` + `huaweicloud_compute_eip_associate` |
| `huaweicloud_vpc_eip` | Requires `publicip {}` and `bandwidth {}` blocks | Don't use flat `type`/`bandwidth` arguments |
| `huaweicloud_vpc_eip` | `bandwidth {}` requires `name` attribute | Always set `name` in bandwidth block |
| `huaweicloud_images_image` | Use `name_regex` not `name` | `name` exact match returns no results |
| `huaweicloud_networking_secgroup_rule` | `ethertype` is required | Always set `ethertype = "IPv4"` |
| `provider "huaweicloud"` | AK/SK empty string causes 401 | Don't set in provider block; use env vars |
