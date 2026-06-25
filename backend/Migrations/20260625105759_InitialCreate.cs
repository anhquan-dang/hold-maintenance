using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace HoldMaintenance.Api.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Assets",
                columns: table => new
                {
                    Id = table.Column<string>(type: "text", nullable: false),
                    AssetCode = table.Column<string>(type: "text", nullable: false),
                    AssetName = table.Column<string>(type: "text", nullable: false),
                    AssetType = table.Column<string>(type: "text", nullable: false),
                    Department = table.Column<string>(type: "text", nullable: false),
                    AssignedUser = table.Column<string>(type: "text", nullable: false),
                    PurchaseDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    WarrantyExpiry = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Status = table.Column<int>(type: "integer", nullable: false),
                    Note = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Assets", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Notifications",
                columns: table => new
                {
                    Id = table.Column<string>(type: "text", nullable: false),
                    UserId = table.Column<string>(type: "text", nullable: false),
                    Title = table.Column<string>(type: "text", nullable: false),
                    Message = table.Column<string>(type: "text", nullable: false),
                    Type = table.Column<int>(type: "integer", nullable: false),
                    RelatedId = table.Column<string>(type: "text", nullable: true),
                    IsRead = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Notifications", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "SupportNotes",
                columns: table => new
                {
                    Id = table.Column<string>(type: "text", nullable: false),
                    TicketId = table.Column<string>(type: "text", nullable: false),
                    AssetId = table.Column<string>(type: "text", nullable: false),
                    HandledBy = table.Column<string>(type: "text", nullable: false),
                    Content = table.Column<string>(type: "text", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SupportNotes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "SupportTickets",
                columns: table => new
                {
                    Id = table.Column<string>(type: "text", nullable: false),
                    Title = table.Column<string>(type: "text", nullable: false),
                    Description = table.Column<string>(type: "text", nullable: false),
                    Priority = table.Column<int>(type: "integer", nullable: false),
                    Status = table.Column<int>(type: "integer", nullable: false),
                    Requester = table.Column<string>(type: "text", nullable: false),
                    AssignedTo = table.Column<string>(type: "text", nullable: true),
                    AssetId = table.Column<string>(type: "text", nullable: false),
                    AssetName = table.Column<string>(type: "text", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    CompletedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SupportTickets", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    Id = table.Column<string>(type: "text", nullable: false),
                    Name = table.Column<string>(type: "text", nullable: false),
                    Email = table.Column<string>(type: "text", nullable: false),
                    PasswordHash = table.Column<string>(type: "text", nullable: false),
                    Role = table.Column<int>(type: "integer", nullable: false),
                    Department = table.Column<string>(type: "text", nullable: false),
                    IsLocked = table.Column<bool>(type: "boolean", nullable: false),
                    RequirePasswordChange = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "AssetAssignments",
                columns: table => new
                {
                    Id = table.Column<string>(type: "text", nullable: false),
                    AssetId = table.Column<string>(type: "text", nullable: false),
                    UserId = table.Column<string>(type: "text", nullable: false),
                    UserName = table.Column<string>(type: "text", nullable: false),
                    AssignedDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    ReturnedDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    Note = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AssetAssignments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AssetAssignments_Assets_AssetId",
                        column: x => x.AssetId,
                        principalTable: "Assets",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.InsertData(
                table: "Assets",
                columns: new[] { "Id", "AssetCode", "AssetName", "AssetType", "AssignedUser", "Department", "Note", "PurchaseDate", "Status", "WarrantyExpiry" },
                values: new object[,]
                {
                    { "a1", "LT001", "Dell Latitude 5440", "Laptop", "Nguyễn Văn Quản", "IT", "Thiết bị cấp cho IT Manager", new DateTime(2025, 6, 25, 10, 0, 0, 0, DateTimeKind.Utc), 0, new DateTime(2027, 6, 25, 10, 0, 0, 0, DateTimeKind.Utc) },
                    { "a10", "RT001", "Cisco Router ISR4331", "Thiết bị mạng", "", "IT", "Router lõi phòng server", new DateTime(2022, 6, 25, 10, 0, 0, 0, DateTimeKind.Utc), 0, new DateTime(2024, 6, 25, 10, 0, 0, 0, DateTimeKind.Utc) },
                    { "a11", "LT006", "MacBook Air M2", "Laptop", "Nguyễn Văn A", "Sales", "Laptop kinh doanh ngoài văn phòng", new DateTime(2025, 7, 25, 10, 0, 0, 0, DateTimeKind.Utc), 0, new DateTime(2027, 7, 25, 10, 0, 0, 0, DateTimeKind.Utc) },
                    { "a12", "MN003", "Samsung Odyssey G5", "Màn hình", "", "Sales", "Màn hình demo sản phẩm", new DateTime(2026, 4, 25, 10, 0, 0, 0, DateTimeKind.Utc), 2, new DateTime(2028, 4, 25, 10, 0, 0, 0, DateTimeKind.Utc) },
                    { "a2", "LT002", "MacBook Pro M3", "Laptop", "Admin IT", "IT", "Thiết bị phát triển ứng dụng", new DateTime(2025, 12, 25, 10, 0, 0, 0, DateTimeKind.Utc), 0, new DateTime(2027, 12, 25, 10, 0, 0, 0, DateTimeKind.Utc) },
                    { "a3", "MN001", "Dell UltraSharp 24\"", "Màn hình", "Lê Hoàng Hỗ Trợ", "IT", "Màn hình phụ bàn làm việc", new DateTime(2024, 6, 25, 10, 0, 0, 0, DateTimeKind.Utc), 0, new DateTime(2027, 6, 25, 10, 0, 0, 0, DateTimeKind.Utc) },
                    { "a4", "PR001", "Canon LBP2900", "Máy in", "Đỗ Quốc Vận Hành", "Operations", "Máy in văn phòng chung", new DateTime(2023, 6, 25, 10, 0, 0, 0, DateTimeKind.Utc), 2, new DateTime(2025, 6, 25, 10, 0, 0, 0, DateTimeKind.Utc) },
                    { "a5", "LT003", "Lenovo ThinkPad T14", "Laptop", "Đỗ Quốc Vận Hành", "Operations", "Thiết bị cá nhân làm việc", new DateTime(2025, 6, 25, 10, 0, 0, 0, DateTimeKind.Utc), 0, new DateTime(2027, 6, 25, 10, 0, 0, 0, DateTimeKind.Utc) },
                    { "a6", "LT004", "HP ProBook 450", "Laptop", "Trần Thị Tuyển", "HR", "Laptop hành chính nhân sự", new DateTime(2025, 10, 25, 10, 0, 0, 0, DateTimeKind.Utc), 0, new DateTime(2027, 10, 25, 10, 0, 0, 0, DateTimeKind.Utc) },
                    { "a7", "LT005", "Dell Vostro 3520", "Laptop", "Phạm Minh Bán", "Sales", "Laptop cho kinh doanh", new DateTime(2026, 3, 25, 10, 0, 0, 0, DateTimeKind.Utc), 0, new DateTime(2027, 3, 25, 10, 0, 0, 0, DateTimeKind.Utc) },
                    { "a8", "MN002", "LG Ergo 27\"", "Màn hình", "Trần Thị B", "HR", "Màn hình thiết kế nhân sự", new DateTime(2025, 6, 25, 10, 0, 0, 0, DateTimeKind.Utc), 0, new DateTime(2027, 6, 25, 10, 0, 0, 0, DateTimeKind.Utc) },
                    { "a9", "PR002", "HP LaserJet Pro", "Máy in", "", "HR", "Máy in màu dự phòng", new DateTime(2024, 6, 25, 10, 0, 0, 0, DateTimeKind.Utc), 2, new DateTime(2027, 6, 25, 10, 0, 0, 0, DateTimeKind.Utc) }
                });

            migrationBuilder.InsertData(
                table: "Notifications",
                columns: new[] { "Id", "CreatedAt", "IsRead", "Message", "RelatedId", "Title", "Type", "UserId" },
                values: new object[,]
                {
                    { "notif1", new DateTime(2026, 6, 24, 16, 0, 0, 0, DateTimeKind.Utc), false, "Yêu cầu 'Màn hình MN002 xuất hiện sọc dọc màu xanh' đang chờ IT duyệt và bàn giao.", "t3", "Có yêu cầu hỗ trợ mới cần duyệt", 0, "u2" },
                    { "notif2", new DateTime(2026, 6, 24, 12, 0, 0, 0, DateTimeKind.Utc), false, "Bạn đã được phân công xử lý yêu cầu 'Laptop Dell LT005 không kết nối được WiFi văn phòng'.", "t2", "Bàn giao công việc mới", 3, "u3" }
                });

            migrationBuilder.InsertData(
                table: "SupportNotes",
                columns: new[] { "Id", "AssetId", "Content", "CreatedAt", "HandledBy", "TicketId" },
                values: new object[,]
                {
                    { "n1", "a4", "Đã kiểm tra khay giấy và gỡ giấy kẹt. Đã vệ sinh trục cuốn cao su bằng cồn chuyên dụng.", new DateTime(2026, 6, 21, 6, 0, 0, 0, DateTimeKind.Utc), "Lê Hoàng Hỗ Trợ", "t1" },
                    { "n2", "a4", "Đã hoàn thành xử lý yêu cầu hỗ trợ. Test in thử 10 bản chạy tốt.", new DateTime(2026, 6, 21, 8, 0, 0, 0, DateTimeKind.Utc), "Lê Hoàng Hỗ Trợ", "t1" },
                    { "n3", "a7", "Đã cập nhật driver card mạng không dây và cấu hình lại địa chỉ IP tĩnh để test.", new DateTime(2026, 6, 25, 6, 0, 0, 0, DateTimeKind.Utc), "Lê Hoàng Hỗ Trợ", "t2" }
                });

            migrationBuilder.InsertData(
                table: "SupportTickets",
                columns: new[] { "Id", "AssetId", "AssetName", "AssignedTo", "CompletedAt", "CreatedAt", "Description", "Priority", "Requester", "Status", "Title" },
                values: new object[,]
                {
                    { "t1", "a4", "Canon LBP2900", "Lê Hoàng Hỗ Trợ", new DateTime(2026, 6, 21, 10, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 6, 20, 10, 0, 0, 0, DateTimeKind.Utc), "Kẹt giấy ở khay nạp và ra nhiệt. Cần bảo trì vệ sinh trục cuốn.", 1, "Đỗ Quốc Vận Hành", 2, "Máy in Canon PR001 bị kẹt giấy liên tục" },
                    { "t2", "a7", "Dell Vostro 3520", "Lê Hoàng Hỗ Trợ", null, new DateTime(2026, 6, 24, 10, 0, 0, 0, DateTimeKind.Utc), "Máy tính nhận sóng WiFi nhưng báo No Internet, các thiết bị khác hoạt động bình thường.", 2, "Phạm Minh Bán", 1, "Laptop Dell LT005 không kết nối được WiFi văn phòng" },
                    { "t3", "a8", "LG Ergo 27\"", null, null, new DateTime(2026, 6, 24, 16, 0, 0, 0, DateTimeKind.Utc), "Màn hình hiển thị sọc dọc đứng màu xanh lá ở góc phải màn hình, đã thử đổi cáp HDMI nhưng không hết.", 2, "Trần Thị B", 0, "Màn hình MN002 xuất hiện sọc dọc màu xanh" },
                    { "t4", "a12", "Samsung Odyssey G5", null, null, new DateTime(2026, 6, 25, 8, 0, 0, 0, DateTimeKind.Utc), "Phòng kinh doanh cần thêm màn hình phụ MN003 để lắp đặt tại bàn làm việc demo sản phẩm.", 0, "Phạm Minh Bán", 0, "Yêu cầu cấp phát màn hình Samsung MN003 cho phòng Sales" }
                });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "Department", "Email", "IsLocked", "Name", "PasswordHash", "RequirePasswordChange", "Role" },
                values: new object[,]
                {
                    { "u1", "IT", "admin@company.vn", false, "Admin IT", "ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f", false, 2 },
                    { "u2", "IT", "manager.it@company.vn", false, "Nguyễn Văn Quản", "ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f", false, 2 },
                    { "u3", "IT", "support.it@company.vn", false, "Lê Hoàng Hỗ Trợ", "ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f", false, 1 },
                    { "u4", "HR", "manager.hr@company.vn", false, "Trần Thị Tuyển", "ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f", false, 0 },
                    { "u5", "Sales", "manager.sales@company.vn", false, "Phạm Minh Bán", "ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f", false, 0 },
                    { "u6", "Operations", "manager.ops@company.vn", false, "Đỗ Quốc Vận Hành", "ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f", false, 0 },
                    { "u7", "Sales", "employee1@company.vn", false, "Nguyễn Văn A", "ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f", false, 0 },
                    { "u8", "HR", "employee2@company.vn", false, "Trần Thị B", "ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f", false, 0 }
                });

            migrationBuilder.InsertData(
                table: "AssetAssignments",
                columns: new[] { "Id", "AssetId", "AssignedDate", "Note", "ReturnedDate", "UserId", "UserName" },
                values: new object[,]
                {
                    { "asg1", "a1", new DateTime(2025, 6, 25, 10, 0, 0, 0, DateTimeKind.Utc), "Cấp phát ban đầu", null, "u2", "Nguyễn Văn Quản" },
                    { "asg2", "a2", new DateTime(2025, 12, 25, 10, 0, 0, 0, DateTimeKind.Utc), "Cấp phát máy mới M3", null, "u1", "Admin IT" },
                    { "asg3", "a3", new DateTime(2024, 6, 25, 10, 0, 0, 0, DateTimeKind.Utc), "Cấp phát màn hình làm việc", null, "u3", "Lê Hoàng Hỗ Trợ" },
                    { "asg4", "a5", new DateTime(2025, 6, 25, 10, 0, 0, 0, DateTimeKind.Utc), "Cấp phát ThinkPad", null, "u6", "Đỗ Quốc Vận Hành" },
                    { "asg5", "a6", new DateTime(2025, 10, 25, 10, 0, 0, 0, DateTimeKind.Utc), "Cấp phát máy làm việc chính", null, "u4", "Trần Thị Tuyển" },
                    { "asg6", "a7", new DateTime(2026, 3, 25, 10, 0, 0, 0, DateTimeKind.Utc), "Cấp phát làm việc kinh doanh", null, "u5", "Phạm Minh Bán" },
                    { "asg7", "a8", new DateTime(2025, 6, 25, 10, 0, 0, 0, DateTimeKind.Utc), "Cấp phát màn hình Ergo", null, "u8", "Trần Thị B" },
                    { "asg8", "a11", new DateTime(2025, 7, 25, 10, 0, 0, 0, DateTimeKind.Utc), "Cấp phát MacBook Air di động", null, "u7", "Nguyễn Văn A" },
                    { "asg9", "a4", new DateTime(2023, 6, 25, 10, 0, 0, 0, DateTimeKind.Utc), "Cấp máy in phòng Operations", null, "u6", "Đỗ Quốc Vận Hành" }
                });

            migrationBuilder.CreateIndex(
                name: "IX_AssetAssignments_AssetId",
                table: "AssetAssignments",
                column: "AssetId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AssetAssignments");

            migrationBuilder.DropTable(
                name: "Notifications");

            migrationBuilder.DropTable(
                name: "SupportNotes");

            migrationBuilder.DropTable(
                name: "SupportTickets");

            migrationBuilder.DropTable(
                name: "Users");

            migrationBuilder.DropTable(
                name: "Assets");
        }
    }
}
