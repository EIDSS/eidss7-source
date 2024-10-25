namespace EIDSS.Domain.RequestModels.Vector
{
    public class USP_VCTS_VSSESSION_NEW_GetDetailRequestModel
    {
        public long idfVectorSurveillanceSession { get; set; }
        public string LangID { get; set; }
        public bool ApplyFiltrationIndicator { get; set; }
        public long? UserSiteID { get; set; }
        public long? UserOrganizationID { get; set; }
        public long? UserEmployeeID { get; set; }
    }
}
