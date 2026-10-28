---
name: huawei-cloud-ecs-eip-web-service
description: >-
  IaC 工程化实践：基于预置 Terraform 代码，修改参数后提交到 GitCode 代码仓归档，
  再执行 plan → apply 部署 Web 服务。体现"代码先于资源"的 IaC 最佳实践。
  Trigger when users mention 修改/modify、提交/commit、归档/archive、GitCode、
  代码仓库/repository、Terraform、plan、apply、部署/deploy、IaC 工程化
---

# Huawei Cloud ECS EIP Web Service — IaC 工程化实践

## 1. Overview

本 Skill 体现 IaC 工程化的核心实践：**代码先于资源，验证先于部署，代码归档可追溯。**

与从零生成代码不同，本 Skill 内置完整可用的 Terraform 代码（VPC、子网、安全组、EIP、ECS、Nginx user_data 全部定义好）。用户只需修改 `terraform.tfvars` 中的参数，然后走标准工程化流程：

1. **修改参数** — 根据需求修改 tfvars（ECS 规格、安全组 IP、Nginx 页面内容）
2. **验证** — fmt → init → validate → plan
3. **归档** — 代码提交到 GitCode 代码仓（plan 通过后，apply 之前）
4. **部署** — terraform apply 创建资源
5. **验证** — curl EIP 确认 Nginx 正常

## 2. 预置资源（main.tf 已定义，用户不可改结构）

| # | 资源 | Terraform 类型 | 说明 |
|---|------|---------------|------|
| 1 | VPC | `huaweicloud_vpc` | 虚拟私有云 |
| 2 | 子网 | `huaweicloud_vpc_subnet` | VPC 下的子网 |
| 3 | 安全组 + 规则 | `huaweicloud_networking_secgroup` + `_rule` | 入站 TCP 80 |
| 4 | EIP | `huaweicloud_vpc_eip` | 弹性公网 IP |
| 5 | ECS 实例 | `huaweicloud_compute_instance` | 含 user_data 自动部署 Nginx |
| 6 | EIP 绑定 | `huaweicloud_compute_eip_associate` | 将 EIP 绑定到 ECS |

> 资源结构固定在 main.tf 中，用户只改 tfvars 参数，不改资源结构。

## 3. 用户可修改的参数（terraform.tfvars）

| 参数 | 说明 | 默认值 | 是否必须修改 |
|------|------|--------|-------------|
| `allowed_source_ip` | 允许访问 80 端口的 IP | `0.0.0.0/0` | **必须改为自己的 IP** |
| `ecs_flavor_id` | ECS 规格 | `s6.small.1` (1C1G) | 可选，可改为 `ac7.large.2` (2C4G) 等 |
| `nginx_page_title` | Nginx 页面标题 | `Hello from IaC` | 可选 |
| `nginx_page_content` | Nginx 页面内容 | `Nginx deployed...` | 可选 |

其余参数（region、VPC CIDR、子网 CIDR 等）有合理默认值，一般不需要修改。

## 4. Prerequisites

| 条件 | 说明 |
|------|------|
| Terraform >= 1.9.0 | `terraform version` |
| 华为云 AK/SK | 环境变量 `HW_ACCESS_KEY` / `HW_SECRET_KEY` |
| GitCode 个人令牌 | 环境变量 `GITCODE_TOKEN`，用于代码归档 |
| Provider >= 1.50.0 | terraform init 自动安装 |

## 5. Workflow — IaC 工程化三阶段

### Phase 1: 参数修改与验证

#### 5.1 复制预置代码到工作目录

**CRITICAL: Use `cp` to copy template files, do NOT write files manually.**

```bash
cp /path/to/skill/assets/ecs-eip-web-service/{providers.tf,variables.tf,main.tf,terraform.tfvars,terraform.tfvars.example,.gitignore,README.md} /target/dir/
```

#### 5.2 理解用户修改需求

用户通过自然语言描述要修改的参数，例如：
- "ECS 规格改为 2 核 4G"
- "安全组开放给我的 IP 1.2.3.4"
- "Nginx 页面标题改为我的IaC实践"

Agent 解析后修改 `terraform.tfvars` 中对应参数。

#### 5.3 验证

```
terraform fmt -recursive
terraform init     # with TF_CLI_CONFIG_FILE
terraform validate
terraform plan
```

### Phase 2: 代码归档到 GitCode（核心环节 — MANDATORY）

**CRITICAL: 代码归档是强制步骤，不可跳过。plan 成功后必须先归档，然后才能 apply。**

**FORBIDDEN:**
- ❌ 在代码归档之前执行 `terraform apply`
- ❌ 跳过用户确认直接执行归档
- ❌ 跳过用户确认直接执行 apply

**强制流程：**

1. plan 成功后，Agent **必须** 使用 `clarify` 工具向用户确认："plan 已通过，是否将代码提交到 GitCode 代码仓进行归档？"
2. 用户确认后，Agent 要求用户提供 GitCode 个人令牌
3. Agent 执行 `scripts/git_push.sh`：
   - 调 GitCode API 自动创建新仓库
   - git init + add + commit + push
4. 输出仓库链接

> 如果用户选择不提交，Agent **必须** 再次确认："代码未归档，是否仍然继续执行 terraform apply？" 用户明确确认后才能进入 Phase 3。

### Phase 3: 部署与验证（MANDATORY — 需用户确认）

**CRITICAL: terraform apply 前必须获得用户明确确认。**

**强制流程：**

1. Agent **必须** 使用 `clarify` 工具向用户确认："是否执行 terraform apply？"
2. 用户确认 → `terraform apply`
3. 等待 ECS 启动 + user_data 执行（~1-2 分钟）
4. 验证：`curl http://$(terraform output -raw ecs_public_ip)`
5. 预期返回 Nginx HTML 页面

## 6. IaC 工程化流程图

```
预置完整 Terraform 代码
    ↓
用户修改 terraform.tfvars（规格、IP、页面内容）
    ↓
terraform fmt → init → validate → plan
    ↓
plan 成功
    ↓
★ 代码提交到 GitCode（归档，apply 之前）★
    ↓
terraform apply（创建资源）
    ↓
curl EIP 验证 Nginx
```

核心原则：**代码是资源的定义，先归档后部署，可追溯可回滚。**

## 7. Template Location

```
assets/ecs-eip-web-service/
├── providers.tf                   # Provider 配置（不改）
├── variables.tf                   # 变量定义（不改）
├── main.tf                        # 资源定义（不改）
├── terraform.tfvars               # 用户修改这个文件 ★
├── terraform.tfvars.example       # 示例值（提交到 git 的版本）
├── .gitignore                     # Git 忽略规则
└── README.md                      # 模板说明
```

## 8. Git 归档说明

### 提交的文件

| 文件 | 是否提交 | 说明 |
|------|----------|------|
| providers.tf | ✅ | Provider 配置 |
| variables.tf | ✅ | 变量定义 |
| main.tf | ✅ | 资源定义 |
| terraform.tfvars.example | ✅ | 示例值 |
| .gitignore | ✅ | 忽略规则 |
| terraform.tfvars | ❌ | 含实际参数，不提交 |
| .terraform/ | ❌ | Provider 二进制 |
| *.tfstate | ❌ | 状态文件 |

### 为什么先提交代码再 apply

- **代码是资源的定义** — 先有定义，后有资源
- **审计追溯** — 代码在仓库里有记录，可追溯
- **回滚能力** — 出问题时可 `git revert` 回到上一版本
- **团队协作** — 代码在仓库里，可 review 和共享

## 9. Quality Checklist

- [ ] terraform.tfvars 参数已正确修改（IP、规格等）
- [ ] terraform fmt / validate / plan 全部通过
- [ ] **plan 后使用 clarify 工具向用户确认是否归档（强制）**
- [ ] 代码已提交到 GitCode 仓库（plan 之后 apply 之前）
- [ ] **apply 前使用 clarify 工具向用户确认是否执行（强制）**
- [ ] terraform apply 成功
- [ ] curl EIP 返回 Nginx HTML 页面
- [ ] GitCode 仓库可访问，.tf 文件完整
