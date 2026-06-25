using FluentValidation;
using HoldMaintenance.Api.DTOs;

namespace HoldMaintenance.Api.Validation;

public class LoginRequestValidator : AbstractValidator<LoginRequest>
{
    public LoginRequestValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email không được để trống")
            .EmailAddress().WithMessage("Email không đúng định dạng");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Mật khẩu không được để trống")
            .MinimumLength(6).WithMessage("Mật khẩu phải dài từ 6 ký tự trở lên");
    }
}

public class CreateAssetDtoValidator : AbstractValidator<CreateAssetDto>
{
    public CreateAssetDtoValidator()
    {
        RuleFor(x => x.AssetCode)
            .NotEmpty().WithMessage("Mã tài sản không được để trống")
            .MaximumLength(20).WithMessage("Mã tài sản không dài quá 20 ký tự");

        RuleFor(x => x.AssetName)
            .NotEmpty().WithMessage("Tên tài sản không được để trống")
            .MaximumLength(100).WithMessage("Tên tài sản không dài quá 100 ký tự");

        RuleFor(x => x.AssetType)
            .NotEmpty().WithMessage("Loại tài sản không được để trống");

        RuleFor(x => x.Department)
            .NotEmpty().WithMessage("Phòng ban không được để trống");

        RuleFor(x => x.PurchaseDate)
            .NotEmpty().WithMessage("Ngày mua không được để trống");

        RuleFor(x => x.WarrantyExpiry)
            .NotEmpty().WithMessage("Hạn bảo hành không được để trống")
            .GreaterThan(x => x.PurchaseDate).WithMessage("Hạn bảo hành phải lớn hơn ngày mua");
    }
}

public class CreateSupportTicketDtoValidator : AbstractValidator<CreateSupportTicketDto>
{
    public CreateSupportTicketDtoValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty().WithMessage("Tiêu đề không được để trống")
            .MaximumLength(100).WithMessage("Tiêu đề không dài quá 100 ký tự");

        RuleFor(x => x.Description)
            .NotEmpty().WithMessage("Mô tả lỗi không được để trống");

        RuleFor(x => x.Requester)
            .NotEmpty().WithMessage("Người yêu cầu không được để trống");

        RuleFor(x => x.AssetId)
            .NotEmpty().WithMessage("Mã ID tài sản không được để trống");
    }
}
