using System.Collections.Generic;
using EIDSS.Domain.Attributes;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Auditing;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ViewModels.Administration;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update, DataAuditObjectTypeEnum.Organization)]
    public class OrganizationSaveRequestModel
    {
        public string LanguageID { get; set; }

        public OrganizationGetDetailViewModel OrganizationDetails { get; set; }

        public string Departments { get; set; }

        public string AuditUserName { get; set; }

        public long? CurrentCustomizationID { get; set; } = null;

        public bool SharedAddressIndicator { get; set; } = true;
    }
}
