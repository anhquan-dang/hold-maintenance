using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using HoldMaintenance.Api.DTOs;
using HoldMaintenance.Api.Services;

namespace HoldMaintenance.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AssetsController : ControllerBase
{
    private readonly IAssetService _assetService;

    public AssetsController(IAssetService assetService)
    {
        _assetService = assetService;
    }

    [HttpGet]
    public async Task<IActionResult> GetAssets([FromQuery] string? q)
    {
        if (!string.IsNullOrEmpty(q))
        {
            var results = await _assetService.SearchAssetsAsync(q);
            return Ok(results);
        }
        var assets = await _assetService.GetAssetsAsync();
        return Ok(assets);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetAssetById(string id)
    {
        var asset = await _assetService.GetAssetByIdAsync(id);
        if (asset == null)
        {
            return NotFound(new { Message = "Không tìm thấy tài sản này" });
        }
        return Ok(asset);
    }

    [HttpPost]
    public async Task<IActionResult> CreateAsset([FromBody] CreateAssetDto dto)
    {
        var result = await _assetService.CreateAssetAsync(dto);
        return CreatedAtAction(nameof(GetAssetById), new { id = result.Id }, result);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateAsset(string id, [FromBody] UpdateAssetDto dto)
    {
        var result = await _assetService.UpdateAssetAsync(id, dto);
        if (result == null)
        {
            return NotFound(new { Message = "Không tìm thấy tài sản để cập nhật" });
        }
        return Ok(result);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteAsset(string id)
    {
        var success = await _assetService.DeleteAssetAsync(id);
        if (!success)
        {
            return NotFound(new { Message = "Không tìm thấy tài sản để xóa" });
        }
        return NoContent();
    }

    [HttpGet("{id}/assignments")]
    public async Task<IActionResult> GetAssignments(string id)
    {
        var assignments = await _assetService.GetAssignmentsByAssetIdAsync(id);
        return Ok(assignments);
    }

    [HttpPost("{id}/assign")]
    public async Task<IActionResult> AssignAsset(string id, [FromBody] CreateAssetAssignmentDto dto)
    {
        try
        {
            var assignment = await _assetService.AssignAssetAsync(id, dto);
            return Ok(assignment);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Message = ex.Message });
        }
    }
}
