# Guardrails

## 代码归档的工程化要求（核心）

### 代码先于资源

IaC 工程化的核心原则：代码是资源的定义，先归档后部署。

- ✅ 正确顺序：plan 成功 → 提交代码到 GitCode → terraform apply
- ❌ 错误顺序：terraform apply → 再提交代码

### 为什么 apply 前要提交代码

- **审计追溯**：代码在仓库里有记录，可追溯谁在什么时候定义了什么资源
- **回滚能力**：出问题时可 `git revert` 回到上一个版本
- **团队协作**：代码在仓库里，团队成员可以 review 和共享
- **代码即文档**：仓库里的代码就是基础设施的完整定义

## 用户只能修改 tfvars

预置代码的 main.tf、variables.tf、providers.tf 结构固定，用户不可修改资源结构。用户只能修改 `terraform.tfvars` 中的参数：

| 参数 | 可修改 | 说明 |
|------|--------|------|
| `allowed_source_ip` | ✅ | 改为自己的公网 IP |
| `ecs_flavor_id` | ✅ | 改为其他规格 |
| `nginx_page_title` | ✅ | 自定义页面标题 |
| `nginx_page_content` | ✅ | 自定义页面内容 |
| main.tf 资源结构 | ❌ | 不可改 |
| variables.tf 变量定义 | ❌ | 不可改 |

## IP 限制

- 必须询问用户的安全组允许 IP
- 默认 `0.0.0.0/0` 仅用于测试，不推荐生产环境
- 不能伪造 IP 地址

## GitCode Token 处理

- 不在对话中直接显示 token
- Agent 提示"请提供你的 GitCode 个人令牌"
- Token 仅在 `git_push.sh` 脚本中使用
- 不将 token 存储在文件中

## .gitignore 规则

提交到 GitCode 的代码中，以下文件必须排除：

| 文件 | 排除原因 |
|------|---------|
| `terraform.tfvars` | 可能含实际 IP 等参数 |
| `.terraform/` | Provider 二进制文件 |
| `*.tfstate` | 含资源 ID 和状态数据 |
| `.tfrc` | 含镜像源配置 |

提交的文件：
- `providers.tf`、`variables.tf`、`main.tf` — 代码定义
- `terraform.tfvars.example` — 示例参数值
- `.gitignore` — 忽略规则

## Execute terraform apply with Explicit User Confirmation

- plan 成功后先提交代码（如用户选择）
- 提交完成后才提示"是否执行 terraform apply"
- 不在代码归档之前执行 apply
