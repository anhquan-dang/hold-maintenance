using HoldMaintenance.Api.DTOs;

namespace HoldMaintenance.Api.Services;

public interface IUserService
{
    Task<LoginResponse?> LoginAsync(LoginRequest request);
    Task<List<UserDto>> GetUsersAsync();
    Task<UserDto?> GetUserByIdAsync(string id);
    Task<UserDto> CreateUserAsync(CreateUserRequest request);
    Task<UserDto?> UpdateUserAsync(string id, UpdateUserRequest request);
    Task<bool> LockUserAsync(string id);
    Task<bool> UnlockUserAsync(string id);
    Task<bool> ResetPasswordAsync(string id, string newPassword);
    Task<bool> ChangePasswordAsync(string userId, ChangePasswordRequest request);
}

public interface IAssetService
{
    Task<List<AssetDto>> GetAssetsAsync();
    Task<AssetDto?> GetAssetByIdAsync(string id);
    Task<AssetDto> CreateAssetAsync(CreateAssetDto dto);
    Task<AssetDto?> UpdateAssetAsync(string id, UpdateAssetDto dto);
    Task<bool> DeleteAssetAsync(string id);
    Task<List<AssetDto>> SearchAssetsAsync(string query);
    Task<List<AssetAssignmentDto>> GetAssignmentsByAssetIdAsync(string assetId);
    Task<AssetAssignmentDto> AssignAssetAsync(string assetId, CreateAssetAssignmentDto dto);
}

public interface ISupportService
{
    Task<List<SupportTicketDto>> GetTicketsAsync();
    Task<SupportTicketDto?> GetTicketByIdAsync(string id);
    Task<List<SupportTicketDto>> GetTicketsByStatusAsync(string status);
    Task<List<SupportTicketDto>> GetTicketsByAssetIdAsync(string assetId);
    Task<SupportTicketDto> CreateTicketAsync(CreateSupportTicketDto dto);
    Task<bool> AssignTicketAsync(string ticketId, string supportUser);
    Task<bool> UpdateTicketStatusAsync(string ticketId, string status);
    Task<bool> CompleteTicketAsync(string ticketId, string completedBy);
    Task<List<SupportNoteDto>> GetNotesByAssetIdAsync(string assetId);
    Task<List<SupportNoteDto>> GetNotesByTicketIdAsync(string ticketId);
    Task<SupportNoteDto> AddNoteAsync(CreateSupportNoteDto dto);
}

public interface IDashboardService
{
    Task<DashboardMetricsDto> GetDashboardMetricsAsync();
}

public class UserDto
{
    public string Id { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;
    public string Department { get; set; } = string.Empty;
    public bool IsLocked { get; set; }
    public bool RequirePasswordChange { get; set; }
}

public class CreateUserRequest
{
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;
    public string Department { get; set; } = string.Empty;
}

public class UpdateUserRequest
{
    public string Name { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;
    public string Department { get; set; } = string.Empty;
}

public class ResetPasswordRequest
{
    public string NewPassword { get; set; } = string.Empty;
}

public class ChangePasswordRequest
{
    public string OldPassword { get; set; } = string.Empty;
    public string NewPassword { get; set; } = string.Empty;
}
