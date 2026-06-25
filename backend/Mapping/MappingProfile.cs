using AutoMapper;
using HoldMaintenance.Api.Entities;
using HoldMaintenance.Api.DTOs;

namespace HoldMaintenance.Api.Mapping;

public class MappingProfile : Profile
{
    public MappingProfile()
    {
        // Asset Mappings
        CreateMap<Asset, AssetDto>()
            .ForMember(dest => dest.Status, opt => opt.MapFrom(src => src.Status.ToString()));

        CreateMap<CreateAssetDto, Asset>()
            .ForMember(dest => dest.Status, opt => opt.MapFrom(src => Enum.Parse<AssetStatus>(src.Status, true)));

        CreateMap<UpdateAssetDto, Asset>()
            .ForMember(dest => dest.Status, opt => opt.MapFrom(src => Enum.Parse<AssetStatus>(src.Status, true)));

        // AssetAssignment Mappings
        CreateMap<AssetAssignment, AssetAssignmentDto>();
        CreateMap<CreateAssetAssignmentDto, AssetAssignment>();

        // SupportTicket Mappings
        CreateMap<SupportTicket, SupportTicketDto>()
            .ForMember(dest => dest.Priority, opt => opt.MapFrom(src => src.Priority.ToString()))
            .ForMember(dest => dest.Status, opt => opt.MapFrom(src => src.Status.ToString()));

        CreateMap<CreateSupportTicketDto, SupportTicket>()
            .ForMember(dest => dest.Priority, opt => opt.MapFrom(src => Enum.Parse<TicketPriority>(src.Priority, true)))
            .ForMember(dest => dest.Status, opt => opt.MapFrom(src => TicketStatus.Pending));

        // SupportNote Mappings
        CreateMap<SupportNote, SupportNoteDto>();
        CreateMap<CreateSupportNoteDto, SupportNote>();
    }
}
