using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Helpers;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.ViewModels.Administration.Security
{
    public class SiteGetDetailViewModel : BaseModel
    {
        public long? SiteID { get; set; }

        [LocalizedRequired]
        public long? SiteTypeID { get; set; }
        public string SiteTypeName { get; set; }
        public long? CustomizationPackageID { get; set; }
        public string CustomizationPackageName { get; set; }
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.SiteDetailsOrganizationFieldLabel))]
        public long? SiteOrganizationID { get; set; }
        public string SiteOrganizationName { get; set; }

        [StringLength(200)]
        [LocalizedRequired]
        public string SiteName { get; set; }
        
        [StringLength(50)]
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.SiteDetailsHASCSiteIDFieldLabel))]
        public string HASCSiteID { get; set; }

        [StringLength(36)]
        [LocalizedRequired]
        public string EIDSSSiteID { get; set; }
        public long? ParentSiteID { get; set; }
        public string ParentSiteName { get; set; }
        public bool ActiveStatusIndicator { get; set; }
        public int RowStatus { get; set; }
        public long? LanguageID { get; set; }
        public long? UserID { get; set; }
        public long? PersonID { get; set; }
        public long? PreferredLanguageID { get; set; }
        public long? PreferredLanguageReferenceTypeID { get; set; }
        public string PreferredLanguageReferenceCode { get; set; }
        public string PreferredLanguageName { get; set; }
        public int? PreferredLanguageAccessoryCode { get; set; }

        public long? CountryID { get; set; }
        public long? AdministrativeLevel2ID { get; set; }
        public long? AdministrativeLevel3ID { get; set; }
        public long? SettlementID { get; set; }
    }
}