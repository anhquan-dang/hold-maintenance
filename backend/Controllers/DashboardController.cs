using Microsoft.AspNetCore.Mvc;
using HoldMaintenance.Api.Services;

namespace HoldMaintenance.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DashboardController : ControllerBase
{
    private readonly IDashboardService _dashboardService;

    public DashboardController(IDashboardService dashboardService)
    {
        _dashboardService = dashboardService;
    }

    [HttpGet]
    public async Task<IActionResult> GetMetrics()
    {
        var metrics = await _dashboardService.GetDashboardMetricsAsync();
        return Ok(metrics);
    }
}
