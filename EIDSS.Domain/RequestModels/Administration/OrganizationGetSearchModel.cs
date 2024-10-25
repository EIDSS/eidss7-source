namespace EIDSS.Domain.RequestModels.Administration;

public class OrganizationGetSearchModel
{
    public string FilterValue { get; init; } = string.Empty;
    public int AccessoryCode { get; set; } = 0;
    public string LanguageId { get; init; } = string.Empty;
    public int PageNumber { get; init; } = 1;
    public int PageSize { get; init; } = 10;
    public string SortColumn { get; init; } = string.Empty;
    public string SortOrder { get; init;} = string.Empty;
}