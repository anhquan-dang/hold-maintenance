using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using HoldMaintenance.Api.DTOs;
using HoldMaintenance.Api.Services;
using System.Security.Claims;

namespace HoldMaintenance.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IUserService _userService;

    public AuthController(IUserService userService)
    {
        _userService = userService;
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        try
        {
            var response = await _userService.LoginAsync(request);
            if (response == null)
            {
                return Unauthorized(new { Message = "Email hoặc mật khẩu không chính xác" });
            }
            return Ok(response);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Message = ex.Message });
        }
    }

    [HttpPost("change-password")]
    [Authorize]
    public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
        {
            return Unauthorized(new { Message = "Không xác định được người dùng." });
        }

        try
        {
            var success = await _userService.ChangePasswordAsync(userId, request);
            if (!success)
            {
                return NotFound(new { Message = "Không tìm thấy người dùng." });
            }
            return Ok(new { Message = "Đã thay đổi mật khẩu thành công." });
        }
        catch (Exception ex)
        {
            return BadRequest(new { Message = ex.Message });
        }
    }
}
