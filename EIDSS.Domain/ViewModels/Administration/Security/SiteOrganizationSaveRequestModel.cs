using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.ViewModels.Administration.Security
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class SiteOrganizationSaveRequestModel
    {
        public long OrganizationID { get; set; }
        public int RowAction { get; set; }
    }
}
