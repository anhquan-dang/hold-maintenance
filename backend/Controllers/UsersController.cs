using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using HoldMaintenance.Api.DTOs;
using HoldMaintenance.Api.Services;
using System.Security.Claims;

namespace HoldMaintenance.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "MaintenanceManager")]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;

    public UsersController(IUserService userService)
    {
        _userService = userService;
    }

    [HttpGet]
    public async Task<IActionResult> GetUsers([FromQuery] string? q)
    {
        var users = await _userService.GetUsersAsync();
        if (!string.IsNullOrEmpty(q))
        {
            var query = q.ToLower().Trim();
            users = users.Where(u => u.Name.ToLower().Contains(query) || u.Email.ToLower().Contains(query) || u.Department.ToLower().Contains(query)).ToList();
        }
        return Ok(users);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetUserById(string id)
    {
        var user = await _userService.GetUserByIdAsync(id);
        if (user == null)
        {
            return NotFound(new { Message = "Không tìm thấy người dùng này." });
        }
        return Ok(user);
    }

    [HttpPost]
    public async Task<IActionResult> CreateUser([FromBody] CreateUserRequest request)
    {
        try
        {
            var user = await _userService.CreateUserAsync(request);
            return CreatedAtAction(nameof(GetUserById), new { id = user.Id }, user);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Message = ex.Message });
        }
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateUser(string id, [FromBody] UpdateUserRequest request)
    {
        var result = await _userService.UpdateUserAsync(id, request);
        if (result == null)
        {
            return NotFound(new { Message = "Không tìm thấy người dùng để cập nhật." });
        }
        return Ok(result);
    }

    [HttpPost("{id}/lock")]
    public async Task<IActionResult> LockUser(string id)
    {
        var success = await _userService.LockUserAsync(id);
        if (!success)
        {
            return NotFound(new { Message = "Không tìm thấy người dùng." });
        }
        return Ok(new { Message = "Đã khóa người dùng thành công." });
    }

    [HttpPost("{id}/unlock")]
    public async Task<IActionResult> UnlockUser(string id)
    {
        var success = await _userService.UnlockUserAsync(id);
        if (!success)
        {
            return NotFound(new { Message = "Không tìm thấy người dùng." });
        }
        return Ok(new { Message = "Đã mở khóa người dùng thành công." });
    }

    [HttpPost("{id}/reset-password")]
    public async Task<IActionResult> ResetPassword(string id, [FromBody] ResetPasswordRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.NewPassword))
        {
            return BadRequest(new { Message = "Mật khẩu mới không được để trống." });
        }
        var success = await _userService.ResetPasswordAsync(id, request.NewPassword);
        if (!success)
        {
            return NotFound(new { Message = "Không tìm thấy người dùng." });
        }
        return Ok(new { Message = "Đã đặt lại mật khẩu thành công. Lần đăng nhập tiếp theo của người dùng này sẽ yêu cầu đổi mật khẩu." });
    }
}
