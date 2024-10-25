using EIDSS.Domain.Abstracts;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Helpers;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.ViewModels.Administration.Security
{
    public class SiteGroupGetDetailViewModel : BaseModel
    {
        public long? SiteGroupID { get; set; }
        [LocalizedRequired]
        public long? SiteGroupTypeID { get; set; }
        public string SiteGroupTypeName { get; set; }
        [StringLength(40)]
        [LocalizedRequired]
        public string SiteGroupName { get; set; }
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.SiteGroupDetailsCentralSiteFieldLabel))]
        public long? CentralSiteID { get; set; }
        [StringLength(200)]
        public string CentralSiteName { get; set; }
        [StringLength(36)]
        public string CentralEIDSSSiteID { get; set; }
        [StringLength(100)]
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.SiteGroupDetailsDescriptionFieldLabel))]
        public string SiteGroupDescription { get; set; }
        public long? LocationID { get; set; }
        public long CountryID { get; set; }
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.AdministrativeLevel1FieldLabel))]
        public long? AdministrativeLevel1ID { get; set; }
        public string AdministrativeLevel1Name { get; set; }
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.AdministrativeLevel2FieldLabel))]
        public long? AdministrativeLevel2ID { get; set; }
        public string AdministrativeLevel2Name { get; set; }
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.AdministrativeLevel3FieldLabel))]
        public long? AdministrativeLevel3ID { get; set; }
        public string AdministrativeLevel3Name { get; set; }
        public long? SettlementID { get; set; }
        public string SettlementName { get; set; }
        public long? SettlementTypeID { get; set; }
        public bool ActiveStatusIndicator { get; set; }
        public int RowStatus { get; set; }
    }
}
