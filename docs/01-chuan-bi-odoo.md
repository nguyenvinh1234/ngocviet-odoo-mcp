# 1. Chuẩn bị Odoo

Làm **trên bản sao (staging) trước**, rồi mới lặp lại trên Odoo thật.

## 1.1 Tạo bản sao staging

1. Sao lưu database thật (Settings > Database Manager > Backup, hoặc `pg_dump`).
2. Khôi phục thành database mới, ví dụ `ngocviet_staging`.
3. Trên staging: tắt máy chủ gửi mail đi (Settings > Technical > Outgoing Mail Servers) và tắt các cron gửi email/đồng bộ. Mục đích là để AI thử nghiệm không gửi thư thật cho khách hàng.

## 1.2 Cài module MCP phía Odoo

1. Tải module `mcp_server` **đúng bản 16.0** trên Odoo Apps: https://apps.odoo.com/apps/modules/16.0/mcp_server (nếu trang 16.0 không có, liên hệ tác giả; chế độ chuẩn yêu cầu Odoo 16.0 trở lên).
2. Chép vào thư mục addons, cập nhật danh sách ứng dụng, cài **MCP Server**.
3. Kiểm tra: `curl http://127.0.0.1:8069/mcp/health`.

## 1.3 Bật model cho MCP — đây là "trần quyền" chung

Settings > MCP Server > Enabled Models. Danh sách này áp dụng cho **mọi** user AI, nên chỉ bật những model có trong [ma trận quyền](ma-tran-quyen.md). Mỗi model có 4 quyền: đọc, sửa, tạo, xóa.

- **Giai đoạn 1–2: chỉ bật quyền đọc.**
- Không bật: `res.users`, `ir.*` (trừ `ir.model` khi cần tạo activity), `hr.payslip`, `hr.contract`, các model cấu hình.

## 1.4 Tạo user AI cho từng phòng ban — đây là quyền thực tế

Quyền thực tế = **giao** của (model được bật trong module MCP) và (quyền Odoo của user). Module MCP cho cùng một danh sách model cho mọi user, nên khác biệt giữa các phòng ban nằm ở **nhóm quyền Odoo** của từng user.

| User | Phòng ban | Nhóm quyền Odoo gợi ý (giai đoạn 1) |
|---|---|---|
| `ai.bangiamdoc` | Ban giám đốc | Bán hàng: "User: All Documents"; Kế toán: "Billing" hoặc "Read-only"; Kho: User; Mua hàng: User |
| `ai.kinhdoanh` | Kinh doanh | Bán hàng: "User: Own Documents Only" hoặc "All Documents"; CRM |
| `ai.ketoan` | Kế toán | Kế toán: "Billing" hoặc "Read-only" (KHÔNG cấp Adviser) |
| `ai.khomuahang` | Kho – Mua hàng | Kho: User; Mua hàng: User |
| `ai.cskh` | Chăm sóc khách hàng | Bán hàng: "User: All Documents"; Liên hệ |

Mỗi user:

1. Settings > Users > New. Đặt tên rõ, ví dụ "AI – Kinh doanh". Email nội bộ, **loại Internal User**.
2. Chỉ chọn đúng các nhóm ở bảng trên. **Không** cấp Administration / Settings.
3. Giới hạn công ty (Allowed Companies) nếu có nhiều công ty.
4. Thêm vào nhóm **MCP User** (tab Access Rights). Module mới từ chối API key của user ngoài nhóm này.
5. Tab Account Security > **New API Key**, đặt tên "mcp-<phong-ban>-<yyyymm>", chép key vào `env/<phong-ban>.env` (`ODOO_API_KEY`).
6. Đặt mật khẩu ngẫu nhiên dài và không lưu lại: user này không bao giờ đăng nhập giao diện.

> Odoo 16 cần cả `ODOO_USER` (login của user) và `ODOO_API_KEY`. File mẫu đã có sẵn tên user.

## 1.5 Record rules (khuyến nghị)

Nếu cần giới hạn theo dòng dữ liệu (ví dụ CSKH không xem đơn của chi nhánh khác), tạo record rule trong Settings > Technical > Record Rules áp cho một nhóm riêng `AI – CSKH`. Odoo áp record rule cho **mọi** lời gọi qua MCP.

## 1.6 Chuẩn hóa dữ liệu trước khi mở cho AI

AI chỉ tốt bằng dữ liệu nó đọc. Trước giai đoạn 2:

- Gộp khách hàng trùng (Contacts > chọn > Merge), chuẩn hóa mã số thuế và số điện thoại.
- Sản phẩm: mã nội bộ (Internal Reference) duy nhất, đơn vị tính đúng, phân loại rõ.
- Đóng hoặc hủy báo giá, đơn hàng treo nhiều năm.
- Ghi chú khách hàng: xóa thông tin nhạy cảm không cần thiết (số CCCD, số tài khoản cá nhân).
