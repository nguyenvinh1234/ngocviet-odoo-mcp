# Ngữ cảnh dự án — cập nhật 30/10/2026

Cập nhật file này **cuối mỗi phiên làm việc**: sửa mục "Trạng thái", "Việc đang dở", thêm dòng vào "Nhật ký".

## 1. Bối cảnh

| Hạng mục | Giá trị |
|---|---|
| Công ty | Ngọc Việt CNC |
| Chủ dự án | anh Vinh — GitHub `nguyenvinh1234` |
| Odoo | 16 Community, `https://odoo.ngocvietai.com`, database `odoo`, có module Website |
| Server | "ngocviet" — Odoo và MCP chạy cùng server |
| Kế hoạch Odoo | Chuẩn hóa dữ liệu trên 16 → nâng lên **Odoo 20 Community** (xem `docs/05-nang-cap-odoo-20.md`) |
| Người dùng AI | ~20 người, 5 phòng ban: Ban giám đốc, Kinh doanh, Kế toán, Kho–Mua hàng, CSKH |
| Nền tảng AI | Claude, ChatGPT, Grok (X/Twitter không phải MCP client) |
| Repo | `github.com/nguyenvinh1234/ngocviet-odoo-mcp` (Private) — **tách riêng**, không trộn với `hermes-agent` hay dự án khác |
| Bản sao tài liệu | Google Drive, thư mục `ngocviet-odoo-mcp` (kèm Google Doc "BÀN GIAO") — GitHub là bản chính |

## 2. Cách truy cập (đọc kỹ — nguồn gốc của nhiều hiểu lầm)

- **Claude Code trên máy tính của anh Vinh** (Windows, tên máy `desktop-n3dr22n`, mở từ VS Code hoặc terminal,
  nối về app qua Remote Control): **vào được server** — đây là cách các phiên trước đã làm
  (ví dụ các phiên "Openmausbot", "502 bad gateway error", "Hermes Zalo plugin").
- **Phiên Claude trên đám mây** (mở từ app desktop/web mà không chọn máy tính): **không vào được server**.
  Proxy mạng của môi trường chặn `odoo.ngocvietai.com`, `controlplane.tailscale.com`, `pkgs.tailscale.com`.
  Phiên đám mây chỉ nối được máy **Mac/Linux** qua Remote Control, không nối được máy Windows.
- **Tailscale:** anh muốn dùng Tailscale để vào server. Phiên đám mây chỉ dùng được Tailscale khi:
  (1) thêm `controlplane.tailscale.com`, `login.tailscale.com`, `pkgs.tailscale.com`, `*.tailscale.com`,
  `derp*.tailscale.com` vào **Allowed domains** của môi trường (menu môi trường ở thanh tiêu đề phiên → Edit →
  Network access); (2) có **Tailscale auth key** (ephemeral, tag riêng, ACL chỉ cho tới server) lưu trong
  **Secrets của môi trường**, không dán vào chat; (3) có thông tin SSH vào server (user + key) cũng lưu trong Secrets.
  Chưa làm 3 việc này → phiên đám mây không dùng được Tailscale.
- Việc nhanh nhất cho thao tác trên server: mở Claude Code trên máy tính Windows như trước.

## 3. Trạng thái (30/10/2026)

| Việc | Trạng thái |
|---|---|
| Rà soát mã nguồn `mcp-server-odoo` 0.9.0 | ✅ An toàn, không mã độc, không telemetry |
| Thiết kế + cấu hình triển khai (repo này) | ✅ Xong — 5 instance theo phòng ban, proxy Caddy/Nginx có token |
| Tài liệu bàn giao (`BAN-GIAO.md` + Google Doc) | ✅ Xong |
| Module `mcp_server` trong Odoo | ❌ Chưa cài (`/mcp/health` → 404) |
| Triển khai MCP lên server | ❌ Chưa |
| Kết nối Claude/ChatGPT/Grok | ❌ Chưa |
| Proxy Caddy/Nginx chạy thử thực tế | ⚠️ Chưa (chỉ kiểm tra cú pháp compose) |
| Module `mcp_server` bản 16.0 có trên Odoo Apps không | ⚠️ Chưa xác nhận |

## 4. ⚠️ Lỗ hổng bảo mật đang mở (phát hiện 30/10/2026)

`https://odoo.ngocvietai.com/web/database/manager` **mở công khai**: thấy database `odoo` với nút Backup/Duplicate/Delete,
và nút **"Set Master Password"** (dấu hiệu master password chưa được đặt).

Cách xử lý đã thống nhất:
1. Anh Vinh **tự** bấm "Set Master Password" trên trình duyệt (Claude không đặt — mật khẩu sẽ lộ trong lịch sử chat).
2. Trên server: sao lưu file cấu hình Odoo, đặt `list_db = False`, `dbfilter = ^odoo$`; nếu có Nginx thêm
   `location ~* ^/web/database { return 403; }`; khởi động lại; kiểm tra trang đã bị chặn và Odoo vẫn đăng nhập được.
3. Rà log Nginx/Odoo tìm `/web/database/(backup|drop|duplicate|restore|create|change_password)` từ IP lạ.

**Trạng thái: CHƯA xác nhận đã xử lý.** Phiên tiếp theo hỏi anh Vinh và kiểm tra lại trang đó trước tiên.

Phát hiện phụ: website còn dữ liệu mẫu (`+1 555-555-5556`, `info@yourcompany.example.com`) — sửa trong
Settings > Companies (thuộc việc chuẩn hóa dữ liệu).

## 5. Việc đang dở — theo thứ tự

1. Đóng lỗ hổng database manager (mục 4).
2. Khảo sát server: cài Odoo trực tiếp hay Docker, `addons_path`, có Nginx không, RAM/ổ đĩa.
3. Ban giám đốc duyệt `docs/ma-tran-quyen.md`.
4. Chọn tên miền MCP — đề xuất `mcp.ngocvietai.com`; trỏ DNS về server.
5. Tạo bản sao Odoo (staging), cài `mcp_server` 16.0, tạo 5 user AI (`docs/01-chuan-bi-odoo.md`).
6. Triển khai theo `docs/02-trien-khai.md`, chạy `scripts/check.sh`.
7. Thí điểm 2–4 tuần, chỉ đọc. Sau đó: cổng OAuth (Pomerium) cho Claude.ai/ChatGPT — cần biết công ty dùng
   Google Workspace hay Microsoft 365.

## 6. Quyết định đã chốt — không bàn lại trừ khi anh Vinh yêu cầu

- Chế độ chuẩn (`ODOO_YOLO=off`), không bật `ODOO_MCP_ENABLE_METHOD_CALLS` trên dữ liệu thật.
- Mỗi phòng ban: 1 user Odoo + 1 API key + 1 token + 1 instance (cổng 8101–8105, chỉ nghe 127.0.0.1).
- Giai đoạn 1–2 chỉ đọc; không bao giờ cho xóa; không cho ghi kế toán.
- `mcp-remote` (Claude Desktop) ghim `0.1.38` — gói đổi người phát hành từ 9/2026.
- Không làm bot công khai trên X cho dữ liệu ERP.

## 7. Nhật ký phiên

| Ngày | Nội dung | Kết quả |
|---|---|---|
| 30/10/2026 | Rà soát mcp-server-odoo; thiết kế + soạn repo; lưu Drive + bàn giao; tạo repo GitHub; phát hiện lỗ hổng database manager; thử Tailscale từ phiên đám mây (bị chặn mạng) | Repo + tài liệu xong; chưa triển khai; lỗ hổng chưa xác nhận đã đóng |
