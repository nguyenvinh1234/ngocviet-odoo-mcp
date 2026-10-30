# BÀN GIAO – Dự án AI kết nối Odoo (MCP) – Ngọc Việt

Ngày lập: 30/10/2026 · Trạng thái: **Đã soạn xong cấu hình và tài liệu. CHƯA triển khai lên server. CHƯA kết nối với AI nào.**

Bản Google Docs của tài liệu này nằm trong thư mục Drive `ngocviet-odoo-mcp`.

## 1. Dự án này là gì

Cho phép nhân viên dùng các trợ lý AI (Claude, ChatGPT, Grok…) để hỏi và thao tác dữ liệu trên Odoo của công ty, ví dụ "doanh thu tháng này theo nhân viên", "tồn kho mã X", "khách hàng nào chưa thanh toán".

Cầu nối giữa AI và Odoo là phần mềm mã nguồn mở **mcp-server-odoo**, phiên bản 0.9.0 (https://github.com/ivnvxd/mcp-server-odoo). Mã nguồn bản này đã được rà soát ngày 30/10/2026: không có mã độc, không gửi dữ liệu ra ngoài, chỉ kết nối tới Odoo của công ty.

## 2. Phạm vi đã thống nhất

- Odoo: **16 Community**, chạy trên server **ngocviet**. Sau khi chuẩn hóa dữ liệu sẽ nâng lên **Odoo 20 Community**, cùng server.
- Nền tảng AI: Claude, ChatGPT, Grok. X/Twitter không kết nối trực tiếp (xem mục 6).
- Người dùng: khoảng **20 người**, 5 nhóm: Ban giám đốc, Kinh doanh, Kế toán, Kho–Mua hàng, CSKH.
- Dự án **tách riêng**, không dính tới các dự án khác của công ty.

## 3. Thiết kế (tóm tắt)

- **Mỗi phòng ban một "cổng" MCP riêng**, mỗi cổng có user Odoo, API key và mật mã truy cập (token) riêng. Nhờ vậy biết phòng nào làm gì, và khóa một phòng không ảnh hưởng phòng khác.
- Các cổng chỉ chạy nội bộ trong server. Người dùng vào qua địa chỉ `https://mcp.<tên-miền>/<phòng-ban>/mcp`, có mã hóa HTTPS và bắt buộc token.
- **Quyền:** giai đoạn đầu AI **chỉ được đọc**. Không bao giờ cho xóa. Không cho sửa dữ liệu kế toán. Chi tiết trong [docs/ma-tran-quyen.md](docs/ma-tran-quyen.md).

## 4. Tài liệu bàn giao

| Tệp | Dành cho | Nội dung |
|---|---|---|
| [README.md](README.md) | Mọi người | Tổng quan, kiến trúc, lộ trình |
| [docs/01-chuan-bi-odoo.md](docs/01-chuan-bi-odoo.md) | Quản trị Odoo | Cài module MCP, tạo 5 user AI, cấp quyền, chuẩn hóa dữ liệu |
| [docs/02-trien-khai.md](docs/02-trien-khai.md) | IT | Cài lên server, chọn proxy (Caddy hoặc Nginx), kiểm tra |
| [docs/03-ket-noi-nen-tang-ai.md](docs/03-ket-noi-nen-tang-ai.md) | IT + người dùng | Cách kết nối Claude, ChatGPT, Grok, Cursor; hướng dẫn người dùng cuối |
| [docs/04-van-hanh-bao-mat.md](docs/04-van-hanh-bao-mat.md) | IT | Log, thu hồi quyền khi sự cố, lịch định kỳ, rủi ro |
| [docs/05-nang-cap-odoo-20.md](docs/05-nang-cap-odoo-20.md) | IT + Quản trị Odoo | Những gì phải làm cho MCP khi lên Odoo 20 |
| [docs/ma-tran-quyen.md](docs/ma-tran-quyen.md) | Ban giám đốc duyệt | Phòng nào được xem/sửa gì |
| [docs/nhat-ky-thay-doi-quyen.md](docs/nhat-ky-thay-doi-quyen.md) | IT ghi | Sổ ghi mọi thay đổi quyền |
| `docker-compose.yml`, `env/`, `proxy/`, `scripts/` | IT | Tệp cấu hình để chạy trên server |

## 5. Lộ trình và việc cần làm tiếp

| # | Việc | Người làm | Trạng thái |
|---|---|---|---|
| 1 | Tạo repo GitHub riêng `ngocviet-odoo-mcp` (Private) và đưa bộ tệp lên | IT / anh Vinh | ⏳ Chưa làm |
| 2 | Ban giám đốc duyệt **ma trận quyền** | Ban giám đốc | ⏳ |
| 3 | Chọn tên miền cho MCP (ví dụ `mcp.<tên-miền-công-ty>`), trỏ DNS về server ngocviet | IT | ⏳ |
| 4 | Tạo bản sao Odoo (staging), cài module MCP bản 16.0, tạo 5 user AI | Quản trị Odoo | ⏳ |
| 5 | Triển khai trên server theo `docs/02`, chạy `scripts/check.sh` | IT | ⏳ |
| 6 | Thí điểm 2–4 tuần: 3–5 người, chỉ đọc, dữ liệu staging | Trưởng phòng + IT | ⏳ |
| 7 | Mở cho 20 người trên dữ liệu thật (chỉ đọc); thêm cổng OAuth cho Claude.ai và ChatGPT | IT | ⏳ |
| 8 | Cho phép ghi có kiểm soát (tạo lead, ghi chú…) | Ban giám đốc duyệt | ⏳ |
| 9 | Nâng cấp Odoo 20 theo `docs/05` | IT + Quản trị Odoo | ⏳ |

## 6. Những điều người tiếp nhận PHẢI biết

1. **Claude.ai và ChatGPT bản web/điện thoại chưa dùng được ở giai đoạn 1.** Hai nền tảng này bắt buộc đăng nhập kiểu OAuth, nên cần thêm một cổng đăng nhập (đề xuất Pomerium). Giai đoạn 1 dùng Claude Code, Claude Desktop, Cursor, hoặc Grok qua API.
2. **Ứng dụng Grok và X không kết nối trực tiếp được.** Grok chỉ dùng được qua xAI API (cần làm bot). Không làm bot công khai trên X cho dữ liệu ERP.
3. **Không bao giờ bật `ODOO_YOLO=true` hay `ODOO_MCP_ENABLE_METHOD_CALLS=true` trên dữ liệu thật.**
4. **Không đưa file `env/*.env` (chứa API key, token) lên Git, Drive hay chat.** Chỉ các file `*.example` là an toàn để chia sẻ.
5. Gói `mcp-remote` (dùng cho Claude Desktop) đã **đổi người phát hành** từ 9/2026. Tài liệu ghim bản `0.1.38`; không dùng `latest`.
6. **Chưa kiểm tra:**
   - Proxy Caddy/Nginx chưa được chạy thử thực tế với MCP server. Chạy `scripts/check.sh` khi triển khai.
   - Module `mcp_server` bản cho Odoo 16 chưa được xác nhận trên Odoo Apps. Kiểm tra trước khi cài.
7. **Sự cố hoặc nghi lộ token:** làm theo mục "Thu hồi quyền" trong `docs/04-van-hanh-bao-mat.md`. Bước nhanh nhất: `docker compose stop mcp-<phòng-ban>`.

## 7. Liên hệ

| Vai trò | Người | Liên lạc |
|---|---|---|
| Chủ dự án | | |
| IT phụ trách server ngocviet | | |
| Quản trị Odoo | | |
