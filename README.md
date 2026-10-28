# IaC 工程化 Web 服务部署与代码归档

本项目对应 ICT 2026 云赛道第 20 题，遵循“代码先于资源”：

1. 复制预置 Terraform 代码。
2. 修改 ECS、安全组和 Nginx 页面参数。
3. 完成 fmt、init、validate、plan。
4. 代码进入 Git 仓库。
5. apply 创建 VPC、子网、安全组、EIP、ECS，并绑定公网 IP。
6. `curl` 验证 Nginx。
7. destroy 清理全部资源。

## 实际结果

- ECS：`s6.small.1`，Ubuntu 22.04，40GB SSD
- EIP：`1.92.108.111`
- ECS ID：`5c716bd6-80b6-45ee-9d95-6e5be41429d1`
- Nginx：HTTP 返回 `Welcome to nginx!`
- 清理：8 个资源全部销毁
