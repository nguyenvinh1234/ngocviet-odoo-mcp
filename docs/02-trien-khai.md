# 2. Triển khai trên server ngocviet

## 2.1 Yêu cầu

- Docker Engine và Docker Compose v2 (`docker compose version`).
- Một tên miền con trỏ về IP server, ví dụ `mcp.<ten-mien>`. Cổng 80/443 mở ra Internet: Let's Encrypt cần chúng để cấp chứng chỉ, và Claude.ai, ChatGPT, Grok gọi vào từ máy chủ của họ.
- Odoo chạy trên cùng server, nghe tại `127.0.0.1:8069` (hoặc cổng khác: sửa `ODOO_URL`).
- Tài nguyên: mỗi instance chiếm khoảng 100–150 MB RAM; 5 instance dưới 1 GB.

## 2.2 Cài đặt

```bash
sudo git clone <url-repo> /opt/ngocviet-odoo-mcp
sudo chown -R $USER /opt/ngocviet-odoo-mcp
cd /opt/ngocviet-odoo-mcp
./scripts/init-env.sh
```

Điền các file trong `env/` (không bao giờ commit chúng):

| File | Cần điền |
|---|---|
| `env/common.env` | `ODOO_URL`, `ODOO_DB` (giai đoạn 1 là DB **staging**), `ODOO_MCP_ALLOWED_HOSTS` = tên miền MCP |
| `env/<phong-ban>.env` | `ODOO_API_KEY` của user AI phòng ban đó |
| `env/proxy.env` | `MCP_DOMAIN`, `ACME_EMAIL` (token đã được sinh sẵn) |

Khởi động các instance MCP:

```bash
docker compose up -d
docker compose ps
docker compose logs --tail 50 mcp-kinh-doanh
```

Log khởi động phải báo xác thực Odoo thành công. Lỗi thường gặp:

- User chưa ở nhóm **MCP User**.
- Sai `ODOO_DB`.
- Ngôn ngữ trong `ODOO_LOCALE` chưa được cài trong Odoo.

## 2.3 Reverse proxy — chọn MỘT trong hai

### A. Server chưa có web server: dùng Caddy

```bash
docker compose --profile caddy up -d
```

Caddy tự xin chứng chỉ HTTPS và tự gia hạn.

### B. Odoo đang chạy sau Nginx: dùng Nginx sẵn có

```bash
sudo certbot certonly --nginx -d mcp.<ten-mien>
./scripts/render-nginx.sh
sudo install -m 600 proxy/nginx-mcp.local.conf /etc/nginx/conf.d/mcp.conf
sudo nginx -t && sudo systemctl reload nginx
```

## 2.4 Kiểm tra

```bash
./scripts/check.sh
```

Mỗi phòng ban phải cho kết quả `OK`: thiếu token thì bị chặn (401), đúng token thì kết nối được (200).

Kiểm tra thêm từ một máy **bên ngoài**:

- Truy cập thẳng cổng `8101`–`8105` phải **không** kết nối được.
- `https://mcp.<ten-mien>/` phải trả về 404.

## 2.5 Tường lửa

```bash
sudo ufw allow 80,443/tcp
sudo ufw deny 8101:8105/tcp     # phòng hờ — container đã chỉ nghe 127.0.0.1
sudo ufw status
```

## 2.6 Cập nhật phiên bản mcp-server-odoo

1. Đọc CHANGELOG: https://github.com/ivnvxd/mcp-server-odoo/blob/main/CHANGELOG.md
2. Rà soát thay đổi mã nguồn giữa hai tag (`git diff v0.9.0..vX.Y.Z -- mcp_server_odoo/`).
3. Lấy digest mới:
   `docker buildx imagetools inspect ghcr.io/ivnvxd/mcp-server-odoo:X.Y.Z`
4. Sửa tag + digest trong `docker-compose.yml`, chạy trên staging (đổi `ODOO_DB`), chạy `scripts/check.sh` và các câu hỏi thử ở [04](04-van-hanh-bao-mat.md#kiểm-thử-định-kỳ).
5. Commit, rồi `docker compose pull && docker compose up -d` trên môi trường thật.
