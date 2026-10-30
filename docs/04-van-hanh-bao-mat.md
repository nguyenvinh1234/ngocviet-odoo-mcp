# 4. Vận hành và bảo mật

## Vai trò

| Vai trò | Người | Trách nhiệm |
|---|---|---|
| Chủ sở hữu hệ thống | Ban giám đốc | Duyệt phạm vi, duyệt mở quyền ghi |
| Quản trị kỹ thuật | IT | Server, token, API key, log, nâng cấp |
| Đầu mối phòng ban | Trưởng mỗi phòng | Đề xuất quyền, rà soát cách dùng hằng tháng |

## Nhật ký cần giữ (tối thiểu 90 ngày)

| Nguồn | Vị trí | Cho biết |
|---|---|---|
| Proxy | `logs/caddy/mcp-access.log` hoặc `/var/log/nginx/mcp-access.log` | Thời gian, IP, phòng ban, mã trả về |
| MCP server | `logs/<phong-ban>.log`, `docker compose logs` | Tool nào được gọi, model nào, lỗi |
| Odoo | Chatter của bản ghi, trường "Last Updated by" | Bản ghi nào bị đổi bởi user AI nào |

Sao lưu thư mục `logs/` cùng lịch backup của server.

## Thu hồi quyền — làm ngay khi có sự cố hoặc nghi lộ token

Từ nhanh đến triệt để:

1. **Tắt một phòng ban:** `docker compose stop mcp-<phong-ban>`
2. **Đổi token phòng ban:** xóa giá trị `TOKEN_*` trong `env/proxy.env`, chạy `scripts/init-env.sh` để sinh token mới, rồi reload proxy:
   - Caddy: `docker compose --profile caddy restart caddy`
   - Nginx: `scripts/render-nginx.sh`, rồi chép file và reload.

   Gửi token mới cho người dùng của phòng ban đó.
3. **Khóa ở phía Odoo:** xóa API key của user AI (Settings > Users > tab Account Security), hoặc Archive user. Hiệu lực ngay ở lời gọi kế tiếp.

**Diễn tập** bước 2 và 3 trước khi vào giai đoạn 2.

## Định kỳ

| Tần suất | Việc |
|---|---|
| Hằng ngày | Backup database Odoo (đã có) + kiểm tra `docker compose ps` |
| Hằng tuần | Xem log proxy: lượng gọi bất thường, nhiều lỗi 401 (có người dò token) |
| Hằng tháng | Trưởng phòng rà soát cách dùng; IT xem bản phát hành mới của mcp-server-odoo |
| Hằng quý | Xoay API key Odoo và token proxy; rà soát lại [ma trận quyền](ma-tran-quyen.md) |
| Khi nhân sự nghỉ việc | Đổi token của phòng ban đó (giai đoạn 1) / khóa tài khoản công ty (giai đoạn 2) |

## Kiểm thử định kỳ

Chạy sau mỗi lần nâng cấp mcp-server-odoo hoặc Odoo, và sau mỗi thay đổi quyền:

1. `scripts/check.sh` → tất cả OK.
2. Với từng phòng ban, hỏi AI một câu **được phép**: "Liệt kê 5 đơn bán gần nhất" → trả lời đúng.
3. Hỏi một câu **không được phép**, ví dụ Kinh doanh hỏi "Liệt kê bút toán kế toán tháng này" → AI phải báo không có quyền.
4. Giai đoạn 1–2: yêu cầu AI "Sửa số điện thoại khách hàng X" → phải bị từ chối.

## Rủi ro chính và biện pháp

| Rủi ro | Biện pháp |
|---|---|
| Lộ token | Token theo phòng ban, xoay hằng quý, thu hồi trong 5 phút (mục trên); giai đoạn 2 chuyển sang OAuth theo người |
| Prompt injection (nội dung trong Odoo lừa AI) | Giai đoạn 1–2 chỉ đọc; giai đoạn 3 chỉ mở ghi cho model ít rủi ro, không mở xóa |
| AI trả lời sai số liệu | Quy định người dùng đối chiếu trước khi dùng ra ngoài; ưu tiên câu hỏi tổng hợp (tool `aggregate_records`) |
| Dữ liệu cá nhân gửi tới nhà cung cấp AI | Chỉ dùng gói doanh nghiệp không huấn luyện trên dữ liệu; không bật model nhân sự/lương; tham vấn pháp chế theo quy định bảo vệ dữ liệu cá nhân hiện hành của Việt Nam |
| Lỗ hổng trong bản mcp-server-odoo mới | Ghim phiên bản + digest; rà soát trước khi nâng |
| Server ngocviet quá tải | Giới hạn `ODOO_MCP_MAX_LIMIT=100`; theo dõi CPU Odoo trong giờ cao điểm |
