# 1.20 执行证明

- VPC ID：`1525b365-4f3c-4f1d-9e35-bbb2bf5db857`
- Subnet ID：`a5a9b69e-1561-48df-9aff-1154549fc10a`
- Security Group ID：`1f83a7d2-ef61-4a08-baa8-d90ba1608bb1`
- Ingress Rule ID：`c2add383-75a7-4fdf-8a5c-fb6adbc4cf10`
- EIP ID：`4bb5d0da-9889-41b7-bd23-40057d9aca4c`
- EIP：`1.92.108.111`
- ECS ID：`5c716bd6-80b6-45ee-9d95-6e5be41429d1`
- ECS 私网 IP：`192.168.0.167`
- Web 验证：`curl http://1.92.108.111` 返回 Nginx 默认页

状态文件在销毁前脱敏保存。随后 `terraform destroy` 返回 8 个资源全部销毁。
