# ngocviet-odoo-mcp

Triển khai [mcp-server-odoo](https://github.com/ivnvxd/mcp-server-odoo) trên server **ngocviet** để các nền tảng AI (Claude, ChatGPT, Grok…) làm việc với Odoo của công ty qua giao thức MCP.

Repo này **chỉ chứa cấu hình triển khai và tài liệu vận hành**. Mã nguồn MCP server dùng nguyên bản chính thức của tác giả, ghim cứng phiên bản `0.9.0` theo digest. Bản này đã được rà soát mã nguồn: không có mã độc, không gửi dữ liệu ra ngoài.

## Kiến trúc

```
 Người dùng (20 người, 5 phòng ban)
   │  Claude / ChatGPT / Grok / Claude Code / Cursor
   ▼
 HTTPS  https://mcp.<ten-mien>/<phong-ban>/mcp
   │
 ┌─┴──────────────── server ngocviet ─────────────────────────────┐
 │ Reverse proxy (Caddy hoặc Nginx) — TLS + kiểm tra token        │
 │   /ban-giam-doc → 127.0.0.1:8101  ┐                            │
 │   /kinh-doanh   → 127.0.0.1:8102  │  mỗi phòng ban 1 container │
 │   /ke-toan      → 127.0.0.1:8103  │  mcp-server-odoo,          │
 │   /kho-mua-hang → 127.0.0.1:8104  │  1 user Odoo riêng,        │
 │   /cskh         → 127.0.0.1:8105  ┘  1 API key riêng           │
 │                    │ XML-RPC (localhost)                       │
 │                    ▼                                           │
 │   Odoo 16 Community (sau này 20) + module MCP (mcp_server)     │
 └────────────────────────────────────────────────────────────────┘
```

Nguyên tắc:

1. **Không instance nào mở thẳng ra Internet.** Container chỉ lắng nghe `127.0.0.1`. Mọi truy cập đi qua proxy có HTTPS và token.
2. **Mỗi phòng ban một user Odoo, một API key, một token, một instance.** Nhờ vậy nhật ký Odoo biết phòng ban nào đã làm gì, và thu hồi quyền một phòng ban không ảnh hưởng phòng ban khác.
3. **Chế độ chuẩn** (`ODOO_YOLO=off`) và module MCP phía Odoo giới hạn model. Không bao giờ dùng YOLO trên dữ liệu thật.
4. **Triển khai theo giai đoạn:** chỉ đọc trên bản sao, rồi chỉ đọc trên dữ liệu thật, rồi mới cho ghi có kiểm soát.

## Nền tảng AI được hỗ trợ

| Nền tảng | Cách kết nối | Giai đoạn |
|---|---|---|
| Claude Code, Cursor, VS Code | URL + header `Authorization: Bearer <token>` | 1 |
| Claude Desktop | Cầu nối `mcp-remote` gửi kèm header token | 1 |
| Grok (xAI API) | Remote MCP tool, trường `authorization` | 1 (cần lập trình một bot nhỏ) |
| Claude.ai web/điện thoại | Custom connector, **bắt buộc OAuth** | 2 (cần cổng OAuth) |
| ChatGPT (Developer mode / Apps) | Custom connector, **bắt buộc OAuth** | 2 (cần cổng OAuth) |
| Ứng dụng Grok, X (Twitter) | Không phải MCP client | Không hỗ trợ trực tiếp |

Chi tiết từng nền tảng: [docs/03-ket-noi-nen-tang-ai.md](docs/03-ket-noi-nen-tang-ai.md).

## Lộ trình

| Giai đoạn | Nội dung | Điều kiện để qua bước tiếp theo |
|---|---|---|
| 0. Chuẩn bị | Chuẩn hóa dữ liệu Odoo 16, duyệt [ma trận quyền](docs/ma-tran-quyen.md), chọn tên miền | Ban giám đốc ký duyệt phạm vi |
| 1. Thí điểm | **Bản sao Odoo (staging)**, chỉ đọc, 3–5 người, Claude Code/Desktop | 2–4 tuần không sự cố, có trường hợp dùng hiệu quả |
| 2. Dữ liệu thật, chỉ đọc | Cả 20 người, thêm cổng OAuth cho Claude.ai/ChatGPT | Nhật ký ổn định, đã diễn tập thu hồi token |
| 3. Ghi có kiểm soát | Vài nghiệp vụ, ví dụ tạo lead hoặc ghi chú. Không xóa, không cho đụng kế toán | Backup hằng ngày đã chạy thử khôi phục |
| 4. Nâng cấp Odoo 20 | Theo [docs/05-nang-cap-odoo-20.md](docs/05-nang-cap-odoo-20.md) | Chạy lại toàn bộ kiểm thử ở giai đoạn 1 |

## Bắt đầu nhanh

```bash
git clone <url-repo> /opt/ngocviet-odoo-mcp && cd /opt/ngocviet-odoo-mcp
./scripts/init-env.sh                # tạo env/*.env từ mẫu + sinh token
nano env/common.env                  # ODOO_URL, ODOO_DB, tên miền
nano env/kinh-doanh.env              # ODOO_USER + ODOO_API_KEY từng phòng ban (lặp lại cho các file khác)
docker compose up -d                 # 5 instance MCP
docker compose --profile caddy up -d # CHỈ khi server chưa có Nginx chiếm cổng 443
./scripts/check.sh                   # kiểm tra từng phòng ban
```

Hướng dẫn đầy đủ:

1. [Chuẩn bị Odoo](docs/01-chuan-bi-odoo.md): module, user, API key, cấp quyền
2. [Triển khai trên server](docs/02-trien-khai.md)
3. [Kết nối nền tảng AI](docs/03-ket-noi-nen-tang-ai.md)
4. [Vận hành và bảo mật](docs/04-van-hanh-bao-mat.md)
5. [Nâng cấp lên Odoo 20](docs/05-nang-cap-odoo-20.md)
6. [Ma trận quyền theo phòng ban](docs/ma-tran-quyen.md)

## Quy tắc của repo

- **Không commit bí mật.** `env/*.env` và `proxy/*.local.*` đã nằm trong `.gitignore`; chỉ commit file `*.example`.
- Nâng phiên bản mcp-server-odoo: đọc CHANGELOG của tác giả, rà soát thay đổi, chạy thử trên staging, rồi mới đổi tag và digest trong `docker-compose.yml`.
- Mọi thay đổi quyền ghi vào [docs/nhat-ky-thay-doi-quyen.md](docs/nhat-ky-thay-doi-quyen.md).
