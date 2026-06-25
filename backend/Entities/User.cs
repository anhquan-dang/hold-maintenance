namespace HoldMaintenance.Api.Entities;

public enum UserRole
{
    DepartmentManager = 0,
    Technician = 1,
    MaintenanceManager = 2
}

public class User
{
    public string Id { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public UserRole Role { get; set; }
    public string Department { get; set; } = string.Empty;
    public bool IsLocked { get; set; }
    public bool RequirePasswordChange { get; set; }
}
