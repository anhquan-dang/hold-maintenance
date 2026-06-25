using Microsoft.EntityFrameworkCore;
using HoldMaintenance.Api.Entities;

namespace HoldMaintenance.Api.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    public DbSet<User> Users => Set<User>();
    public DbSet<Asset> Assets => Set<Asset>();
    public DbSet<AssetAssignment> AssetAssignments => Set<AssetAssignment>();
    public DbSet<SupportTicket> SupportTickets => Set<SupportTicket>();
    public DbSet<SupportNote> SupportNotes => Set<SupportNote>();
    public DbSet<Notification> Notifications => Set<Notification>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configure relations and keys
        modelBuilder.Entity<AssetAssignment>()
            .HasOne(a => a.Asset)
            .WithMany()
            .HasForeignKey(a => a.AssetId)
            .OnDelete(DeleteBehavior.Cascade);

        // Seed data
        var now = new DateTime(2026, 6, 25, 10, 0, 0, DateTimeKind.Utc);

        // Seeding Users (Password: password123, hashed using SHA-256)
        // SHA256 of "password123" is "ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f";
        const string defaultPasswordHash = "ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f";

        modelBuilder.Entity<User>().HasData(
            new User { Id = "u1", Name = "Admin IT", Email = "admin@company.vn", PasswordHash = defaultPasswordHash, Role = UserRole.MaintenanceManager, Department = "IT", IsLocked = false, RequirePasswordChange = false },
            new User { Id = "u2", Name = "Nguyễn Văn Quản", Email = "manager.it@company.vn", PasswordHash = defaultPasswordHash, Role = UserRole.MaintenanceManager, Department = "IT", IsLocked = false, RequirePasswordChange = false },
            new User { Id = "u3", Name = "Lê Hoàng Hỗ Trợ", Email = "support.it@company.vn", PasswordHash = defaultPasswordHash, Role = UserRole.Technician, Department = "IT", IsLocked = false, RequirePasswordChange = false },
            new User { Id = "u4", Name = "Trần Thị Tuyển", Email = "manager.hr@company.vn", PasswordHash = defaultPasswordHash, Role = UserRole.DepartmentManager, Department = "HR", IsLocked = false, RequirePasswordChange = false },
            new User { Id = "u5", Name = "Phạm Minh Bán", Email = "manager.sales@company.vn", PasswordHash = defaultPasswordHash, Role = UserRole.DepartmentManager, Department = "Sales", IsLocked = false, RequirePasswordChange = false },
            new User { Id = "u6", Name = "Đỗ Quốc Vận Hành", Email = "manager.ops@company.vn", PasswordHash = defaultPasswordHash, Role = UserRole.DepartmentManager, Department = "Operations", IsLocked = false, RequirePasswordChange = false },
            new User { Id = "u7", Name = "Nguyễn Văn A", Email = "employee1@company.vn", PasswordHash = defaultPasswordHash, Role = UserRole.DepartmentManager, Department = "Sales", IsLocked = false, RequirePasswordChange = false },
            new User { Id = "u8", Name = "Trần Thị B", Email = "employee2@company.vn", PasswordHash = defaultPasswordHash, Role = UserRole.DepartmentManager, Department = "HR", IsLocked = false, RequirePasswordChange = false }
        );

        modelBuilder.Entity<Asset>().HasData(
            new Asset { Id = "a1", AssetCode = "LT001", AssetName = "Dell Latitude 5440", AssetType = "Laptop", Department = "IT", AssignedUser = "Nguyễn Văn Quản", PurchaseDate = now.AddYears(-1), WarrantyExpiry = now.AddYears(1), Status = AssetStatus.InUse, Note = "Thiết bị cấp cho IT Manager" },
            new Asset { Id = "a2", AssetCode = "LT002", AssetName = "MacBook Pro M3", AssetType = "Laptop", Department = "IT", AssignedUser = "Admin IT", PurchaseDate = now.AddMonths(-6), WarrantyExpiry = now.AddMonths(18), Status = AssetStatus.InUse, Note = "Thiết bị phát triển ứng dụng" },
            new Asset { Id = "a3", AssetCode = "MN001", AssetName = "Dell UltraSharp 24\"", AssetType = "Màn hình", Department = "IT", AssignedUser = "Lê Hoàng Hỗ Trợ", PurchaseDate = now.AddYears(-2), WarrantyExpiry = now.AddYears(1), Status = AssetStatus.InUse, Note = "Màn hình phụ bàn làm việc" },
            new Asset { Id = "a4", AssetCode = "PR001", AssetName = "Canon LBP2900", AssetType = "Máy in", Department = "Operations", AssignedUser = "Đỗ Quốc Vận Hành", PurchaseDate = now.AddYears(-3), WarrantyExpiry = now.AddYears(-1), Status = AssetStatus.Available, Note = "Máy in văn phòng chung" },
            new Asset { Id = "a5", AssetCode = "LT003", AssetName = "Lenovo ThinkPad T14", AssetType = "Laptop", Department = "Operations", AssignedUser = "Đỗ Quốc Vận Hành", PurchaseDate = now.AddYears(-1), WarrantyExpiry = now.AddYears(1), Status = AssetStatus.InUse, Note = "Thiết bị cá nhân làm việc" },
            new Asset { Id = "a6", AssetCode = "LT004", AssetName = "HP ProBook 450", AssetType = "Laptop", Department = "HR", AssignedUser = "Trần Thị Tuyển", PurchaseDate = now.AddMonths(-8), WarrantyExpiry = now.AddMonths(16), Status = AssetStatus.InUse, Note = "Laptop hành chính nhân sự" },
            new Asset { Id = "a7", AssetCode = "LT005", AssetName = "Dell Vostro 3520", AssetType = "Laptop", Department = "Sales", AssignedUser = "Phạm Minh Bán", PurchaseDate = now.AddMonths(-3), WarrantyExpiry = now.AddMonths(9), Status = AssetStatus.InUse, Note = "Laptop cho kinh doanh" },
            new Asset { Id = "a8", AssetCode = "MN002", AssetName = "LG Ergo 27\"", AssetType = "Màn hình", Department = "HR", AssignedUser = "Trần Thị B", PurchaseDate = now.AddYears(-1), WarrantyExpiry = now.AddYears(1), Status = AssetStatus.InUse, Note = "Màn hình thiết kế nhân sự" },
            new Asset { Id = "a9", AssetCode = "PR002", AssetName = "HP LaserJet Pro", AssetType = "Máy in", Department = "HR", AssignedUser = "", PurchaseDate = now.AddYears(-2), WarrantyExpiry = now.AddYears(1), Status = AssetStatus.Available, Note = "Máy in màu dự phòng" },
            new Asset { Id = "a10", AssetCode = "RT001", AssetName = "Cisco Router ISR4331", AssetType = "Thiết bị mạng", Department = "IT", AssignedUser = "", PurchaseDate = now.AddYears(-4), WarrantyExpiry = now.AddYears(-2), Status = AssetStatus.InUse, Note = "Router lõi phòng server" },
            new Asset { Id = "a11", AssetCode = "LT006", AssetName = "MacBook Air M2", AssetType = "Laptop", Department = "Sales", AssignedUser = "Nguyễn Văn A", PurchaseDate = now.AddMonths(-11), WarrantyExpiry = now.AddMonths(13), Status = AssetStatus.InUse, Note = "Laptop kinh doanh ngoài văn phòng" },
            new Asset { Id = "a12", AssetCode = "MN003", AssetName = "Samsung Odyssey G5", AssetType = "Màn hình", Department = "Sales", AssignedUser = "", PurchaseDate = now.AddMonths(-2), WarrantyExpiry = now.AddMonths(22), Status = AssetStatus.Available, Note = "Màn hình demo sản phẩm" }
        );

        modelBuilder.Entity<AssetAssignment>().HasData(
            new AssetAssignment { Id = "asg1", AssetId = "a1", UserId = "u2", UserName = "Nguyễn Văn Quản", AssignedDate = now.AddYears(-1), Note = "Cấp phát ban đầu" },
            new AssetAssignment { Id = "asg2", AssetId = "a2", UserId = "u1", UserName = "Admin IT", AssignedDate = now.AddMonths(-6), Note = "Cấp phát máy mới M3" },
            new AssetAssignment { Id = "asg3", AssetId = "a3", UserId = "u3", UserName = "Lê Hoàng Hỗ Trợ", AssignedDate = now.AddYears(-2), Note = "Cấp phát màn hình làm việc" },
            new AssetAssignment { Id = "asg4", AssetId = "a5", UserId = "u6", UserName = "Đỗ Quốc Vận Hành", AssignedDate = now.AddYears(-1), Note = "Cấp phát ThinkPad" },
            new AssetAssignment { Id = "asg5", AssetId = "a6", UserId = "u4", UserName = "Trần Thị Tuyển", AssignedDate = now.AddMonths(-8), Note = "Cấp phát máy làm việc chính" },
            new AssetAssignment { Id = "asg6", AssetId = "a7", UserId = "u5", UserName = "Phạm Minh Bán", AssignedDate = now.AddMonths(-3), Note = "Cấp phát làm việc kinh doanh" },
            new AssetAssignment { Id = "asg7", AssetId = "a8", UserId = "u8", UserName = "Trần Thị B", AssignedDate = now.AddYears(-1), Note = "Cấp phát màn hình Ergo" },
            new AssetAssignment { Id = "asg8", AssetId = "a11", UserId = "u7", UserName = "Nguyễn Văn A", AssignedDate = now.AddMonths(-11), Note = "Cấp phát MacBook Air di động" },
            new AssetAssignment { Id = "asg9", AssetId = "a4", UserId = "u6", UserName = "Đỗ Quốc Vận Hành", AssignedDate = now.AddYears(-3), Note = "Cấp máy in phòng Operations" }
        );

        modelBuilder.Entity<SupportTicket>().HasData(
            new SupportTicket { Id = "t1", Title = "Máy in Canon PR001 bị kẹt giấy liên tục", Description = "Kẹt giấy ở khay nạp và ra nhiệt. Cần bảo trì vệ sinh trục cuốn.", Priority = TicketPriority.Medium, Status = TicketStatus.Completed, Requester = "Đỗ Quốc Vận Hành", AssignedTo = "Lê Hoàng Hỗ Trợ", AssetId = "a4", AssetName = "Canon LBP2900", CreatedAt = now.AddDays(-5), CompletedAt = now.AddDays(-4) },
            new SupportTicket { Id = "t2", Title = "Laptop Dell LT005 không kết nối được WiFi văn phòng", Description = "Máy tính nhận sóng WiFi nhưng báo No Internet, các thiết bị khác hoạt động bình thường.", Priority = TicketPriority.High, Status = TicketStatus.InProgress, Requester = "Phạm Minh Bán", AssignedTo = "Lê Hoàng Hỗ Trợ", AssetId = "a7", AssetName = "Dell Vostro 3520", CreatedAt = now.AddDays(-1) },
            new SupportTicket { Id = "t3", Title = "Màn hình MN002 xuất hiện sọc dọc màu xanh", Description = "Màn hình hiển thị sọc dọc đứng màu xanh lá ở góc phải màn hình, đã thử đổi cáp HDMI nhưng không hết.", Priority = TicketPriority.High, Status = TicketStatus.Pending, Requester = "Trần Thị B", AssetId = "a8", AssetName = "LG Ergo 27\"", CreatedAt = now.AddHours(-18) },
            new SupportTicket { Id = "t4", Title = "Yêu cầu cấp phát màn hình Samsung MN003 cho phòng Sales", Description = "Phòng kinh doanh cần thêm màn hình phụ MN003 để lắp đặt tại bàn làm việc demo sản phẩm.", Priority = TicketPriority.Low, Status = TicketStatus.Pending, Requester = "Phạm Minh Bán", AssetId = "a12", AssetName = "Samsung Odyssey G5", CreatedAt = now.AddHours(-2) }
        );

        modelBuilder.Entity<SupportNote>().HasData(
            new SupportNote { Id = "n1", TicketId = "t1", AssetId = "a4", HandledBy = "Lê Hoàng Hỗ Trợ", Content = "Đã kiểm tra khay giấy và gỡ giấy kẹt. Đã vệ sinh trục cuốn cao su bằng cồn chuyên dụng.", CreatedAt = now.AddDays(-4).AddHours(-4) },
            new SupportNote { Id = "n2", TicketId = "t1", AssetId = "a4", HandledBy = "Lê Hoàng Hỗ Trợ", Content = "Đã hoàn thành xử lý yêu cầu hỗ trợ. Test in thử 10 bản chạy tốt.", CreatedAt = now.AddDays(-4).AddHours(-2) },
            new SupportNote { Id = "n3", TicketId = "t2", AssetId = "a7", HandledBy = "Lê Hoàng Hỗ Trợ", Content = "Đã cập nhật driver card mạng không dây và cấu hình lại địa chỉ IP tĩnh để test.", CreatedAt = now.AddHours(-4) }
        );

        modelBuilder.Entity<Notification>().HasData(
            new Notification { Id = "notif1", UserId = "u2", Title = "Có yêu cầu hỗ trợ mới cần duyệt", Message = "Yêu cầu 'Màn hình MN002 xuất hiện sọc dọc màu xanh' đang chờ IT duyệt và bàn giao.", Type = NotificationType.NewRequest, RelatedId = "t3", IsRead = false, CreatedAt = now.AddHours(-18) },
            new Notification { Id = "notif2", UserId = "u3", Title = "Bàn giao công việc mới", Message = "Bạn đã được phân công xử lý yêu cầu 'Laptop Dell LT005 không kết nối được WiFi văn phòng'.", Type = NotificationType.Assigned, RelatedId = "t2", IsRead = false, CreatedAt = now.AddDays(-1).AddHours(2) }
        );
    }
}
