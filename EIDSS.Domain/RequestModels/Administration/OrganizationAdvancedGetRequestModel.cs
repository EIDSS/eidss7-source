namespace EIDSS.Domain.RequestModels.Administration
{
    public class OrganizationAdvancedGetRequestModel 
    {
        public string LangID { get; set; }
        public int? SiteFlag { get; set; }
        public int? AccessoryCode { get; set; } = null;
        public long? OrganizationTypeID { get; set; } = null;
        public string AdvancedSearch { get; set; }
        public int? RowStatus { get; set; }
        public long? LocationID { get; set; }
    }
}