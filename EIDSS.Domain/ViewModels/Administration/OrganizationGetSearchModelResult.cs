namespace EIDSS.Domain.ViewModels.Administration;

public class OrganizationGetSearchModelResult
{
    public long OrganizationId { get; set; }
    public string UniqueKey { get; set; }
    public string AbbreviatedName { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public int? TotalRowCount { get; set; }
}