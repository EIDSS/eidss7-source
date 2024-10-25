namespace EIDSS.Repository.ReturnModels
{
    public class USP_GBL_ORG_GETSearchResult
    {
        public long OrganizationId { get; set; }
        public string? UniqueKey { get; set; } = string.Empty;
        public string AbbreviatedName { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public int? TotalRowCount { get; set; }
    }
}
