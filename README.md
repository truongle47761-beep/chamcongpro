# CHẤM CÔNG PRO

Ứng dụng chấm công cá nhân, giao diện Organic Design, tối ưu mobile.

## Cấu hình Supabase
1. Mở Supabase Dashboard → SQL Editor.
2. Dán và chạy toàn bộ `supabase/schema.sql`.
3. Authentication → Providers → Email: bật Email provider.
4. Nếu muốn đăng ký không cần xác nhận email trong giai đoạn thử nghiệm, chỉnh Confirm email trong Authentication settings (cân nhắc bảo mật trước khi dùng thật).

## Deploy GitHub Pages
1. Repository → Settings → Pages.
2. Build and deployment: Deploy from a branch.
3. Chọn branch `main`, folder `/ (root)`, Save.
4. Chờ workflow hoàn tất, mở URL GitHub Pages.

Supabase URL và Publishable key nằm trong index.html. Publishable key có thể dùng ở client; quyền truy cập dữ liệu được giới hạn bằng Row Level Security. Không bao giờ đưa service_role/secret key vào frontend.

## Ghi chú hiện tại
- Giờ làm được tính theo ca cùng ngày; ca qua đêm chưa hỗ trợ.
- Xuất PDF dùng hộp thoại in của trình duyệt → Save as PDF.
- Xuất iPhone Calendar tạo tệp .ics, người dùng xác nhận thêm vào Lịch.
