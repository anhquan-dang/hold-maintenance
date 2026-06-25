using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using AutoMapper;
using Microsoft.IdentityModel.Tokens;
using HoldMaintenance.Api.Data.Repositories;
using HoldMaintenance.Api.DTOs;
using HoldMaintenance.Api.Entities;

namespace HoldMaintenance.Api.Services;

public class UserService : IUserService
{
    private readonly IUserRepository _userRepository;
    private readonly IMapper _mapper;
    private readonly IConfiguration _configuration;

    public UserService(IUserRepository userRepository, IMapper mapper, IConfiguration configuration)
    {
        _userRepository = userRepository;
        _mapper = mapper;
        _configuration = configuration;
    }

    public async Task<LoginResponse?> LoginAsync(LoginRequest request)
    {
        var user = await _userRepository.GetUserByEmailAsync(request.Email);
        if (user == null) return null;

        if (user.IsLocked)
        {
            throw new Exception("Tài khoản của bạn đã bị khóa. Vui lòng liên hệ Admin.");
        }

        // Verify SHA256 password hash
        var inputHash = HashPassword(request.Password);
        if (user.PasswordHash != inputHash) return null;

        // Generate JWT Token
        var token = GenerateJwtToken(user);

        return new LoginResponse
        {
            Token = token,
            UserId = user.Id,
            Name = user.Name,
            Email = user.Email,
            Role = user.Role.ToString(),
            Department = user.Department,
            RequirePasswordChange = user.RequirePasswordChange
        };
    }

    public async Task<List<UserDto>> GetUsersAsync()
    {
        var users = await _userRepository.GetUsersAsync();
        return users.Select(u => new UserDto
        {
            Id = u.Id,
            Name = u.Name,
            Email = u.Email,
            Role = u.Role.ToString(),
            Department = u.Department,
            IsLocked = u.IsLocked,
            RequirePasswordChange = u.RequirePasswordChange
        }).ToList();
    }

    public async Task<UserDto?> GetUserByIdAsync(string id)
    {
        var user = await _userRepository.GetUserByIdAsync(id);
        if (user == null) return null;

        return new UserDto
        {
            Id = user.Id,
            Name = user.Name,
            Email = user.Email,
            Role = user.Role.ToString(),
            Department = user.Department,
            IsLocked = user.IsLocked,
            RequirePasswordChange = user.RequirePasswordChange
        };
    }

    public async Task<UserDto> CreateUserAsync(CreateUserRequest request)
    {
        var existing = await _userRepository.GetUserByEmailAsync(request.Email);
        if (existing != null)
        {
            throw new Exception("Email đã tồn tại trong hệ thống.");
        }

        if (!Enum.TryParse<UserRole>(request.Role, true, out var role))
        {
            role = UserRole.DepartmentManager;
        }

        var newUser = new User
        {
            Id = "u-" + Guid.NewGuid().ToString("n").Substring(0, 8),
            Name = request.Name,
            Email = request.Email.Trim().ToLower(),
            PasswordHash = HashPassword(request.Password),
            Role = role,
            Department = request.Department,
            IsLocked = false,
            RequirePasswordChange = true // Enforce password change on first login
        };

        await _userRepository.AddUserAsync(newUser);

        return new UserDto
        {
            Id = newUser.Id,
            Name = newUser.Name,
            Email = newUser.Email,
            Role = newUser.Role.ToString(),
            Department = newUser.Department,
            IsLocked = newUser.IsLocked,
            RequirePasswordChange = newUser.RequirePasswordChange
        };
    }

    public async Task<UserDto?> UpdateUserAsync(string id, UpdateUserRequest request)
    {
        var user = await _userRepository.GetUserByIdAsync(id);
        if (user == null) return null;

        if (!Enum.TryParse<UserRole>(request.Role, true, out var role))
        {
            role = user.Role;
        }

        user.Name = request.Name;
        user.Role = role;
        user.Department = request.Department;

        await _userRepository.UpdateUserAsync(user);

        return new UserDto
        {
            Id = user.Id,
            Name = user.Name,
            Email = user.Email,
            Role = user.Role.ToString(),
            Department = user.Department,
            IsLocked = user.IsLocked,
            RequirePasswordChange = user.RequirePasswordChange
        };
    }

    public async Task<bool> LockUserAsync(string id)
    {
        var user = await _userRepository.GetUserByIdAsync(id);
        if (user == null) return false;

        user.IsLocked = true;
        await _userRepository.UpdateUserAsync(user);
        return true;
    }

    public async Task<bool> UnlockUserAsync(string id)
    {
        var user = await _userRepository.GetUserByIdAsync(id);
        if (user == null) return false;

        user.IsLocked = false;
        await _userRepository.UpdateUserAsync(user);
        return true;
    }

    public async Task<bool> ResetPasswordAsync(string id, string newPassword)
    {
        var user = await _userRepository.GetUserByIdAsync(id);
        if (user == null) return false;

        user.PasswordHash = HashPassword(newPassword);
        user.RequirePasswordChange = true; // Next login must change password
        await _userRepository.UpdateUserAsync(user);
        return true;
    }

    public async Task<bool> ChangePasswordAsync(string userId, ChangePasswordRequest request)
    {
        var user = await _userRepository.GetUserByIdAsync(userId);
        if (user == null) return false;

        var oldHash = HashPassword(request.OldPassword);
        if (user.PasswordHash != oldHash)
        {
            throw new Exception("Mật khẩu cũ không chính xác.");
        }

        user.PasswordHash = HashPassword(request.NewPassword);
        user.RequirePasswordChange = false; // Successfully changed password
        await _userRepository.UpdateUserAsync(user);
        return true;
    }

    private string GenerateJwtToken(User user)
    {
        var tokenHandler = new JwtSecurityTokenHandler();
        var key = Encoding.UTF8.GetBytes(_configuration["Jwt:Key"] ?? "superSecretKey12345678901234567890");

        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(new[]
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id),
                new Claim(ClaimTypes.Name, user.Name),
                new Claim(ClaimTypes.Email, user.Email),
                new Claim(ClaimTypes.Role, user.Role.ToString()),
                new Claim("department", user.Department)
            }),
            Expires = DateTime.UtcNow.AddDays(7),
            SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature),
            Issuer = _configuration["Jwt:Issuer"],
            Audience = _configuration["Jwt:Audience"]
        };

        var token = tokenHandler.CreateToken(tokenDescriptor);
        return tokenHandler.WriteToken(token);
    }

    private string HashPassword(string password)
    {
        using var sha256 = System.Security.Cryptography.SHA256.Create();
        var bytes = Encoding.UTF8.GetBytes(password);
        var hash = sha256.ComputeHash(bytes);
        return string.Concat(hash.Select(b => b.ToString("x2")));
    }
}
