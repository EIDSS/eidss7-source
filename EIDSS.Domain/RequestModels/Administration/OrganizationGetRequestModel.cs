using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.Administration
{
    public class OrganizationGetRequestModel : BaseGetRequestModel
    {
        public long? OrganizationKey { get; set; }
        public string OrganizationID { get; set; }
        [StringLength(2000)]
        public string AbbreviatedName { get; set; }
        [StringLength(2000)]
        public string FullName { get; set; }
        public int? AccessoryCode { get; set; }
        public long? SiteID { get; set; }
        public long? AdministrativeLevelID { get; set; }
        public long? OrganizationTypeID { get; set; }
        public bool ShowForeignOrganizationsIndicator { get; set; }
    }
}