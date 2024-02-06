using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Common
{
    public class ActiveSurveillanceCampaignListViewModel : BaseModel
    {
        public long CampaignKey { get; set; }
        public string CampaignID { get; set; }
        public string CampaignTypeName { get; set; }
        public string CampaignStatusTypeName { get; set; }
        public string DiseaseList { get; set; }
        public string SpeciesList { get; set; }
        public string SampleTypesList { get; set; }
        public DateTime? CampaignStartDate { get; set; }
        public DateTime? CampaignEndDate { get; set; }
        public string CampaignName { get; set; }
        public string CampaignAdministrator { get; set; }
        public DateTime? EnteredDate { get; set; }
        public long SiteID { get; set; }
        public bool? ReadPermissionIndicator { get; set; }
        public bool? AccessToPersonalDataPermissionIndicator { get; set; }
        public bool? AccessToGenderAndAgeDataPermissionIndicator { get; set; }
        public bool? WritePermissionIndicator { get; set; }
        public bool? DeletePermissionIndicator { get; set; }

    }

    public class ActiveSurveillanceCampaignDetailViewModel
    {
        public ActiveSurveillanceCampaignDetailViewModel()
        {
            DisableEIDSSCampaignID = false;
            DisableCampaignTypeID = false;
            DisableCampaignTypeName = false;
            DisableCampaignStartDate = false;
            DisableCampaignEndDate  = false;
            DisableLegacyCampaignID = false;
            DisableCampaignAdministrator = false;
        }
        public long CampaignID { get; set; }
        public long? CampaignTypeID { get; set; }
        public string CampaignTypeName { get; set; }
        public long? CampaignStatusTypeID { get; set; }
        public string CampaignStatusTypeName { get; set; }
        public string LegacyCampaignID { get; set; }
        public DateTime? CampaignStartDate { get; set; }
        public DateTime? CampaignEndDate { get; set; }
        public string EIDSSCampaignID { get; set; }
        [Required]
        public string CampaignName { get; set; }
        public string CampaignAdministrator { get; set; }
        public string Conclusion { get; set; }
        public long SiteId { get; set; }
        public bool DisableEIDSSCampaignID { get; set; } = false;
        public bool DisableCampaignTypeID { get; set; } = false;
        public bool DisableCampaignTypeName { get; set; } = false;
        public bool DisableCampaignStartDate { get; set; } = false;
        public bool DisableCampaignEndDate { get; set; } = false;
        public bool DisableLegacyCampaignID { get; set; } = false;
        public bool DisableCampaignAdministrator { get; set; } = false;

    }

    public class ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel : BaseModel
    {

        public ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel ShallowCopy()
        {
            return (ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel)MemberwiseClone();
        }
        public long? idfCampaignToDiagnosis { get; set; }
        public long idfCampaign { get; set; }
        public long? idfsDiagnosis { get; set; }
        public string Disease { get; set; }
        public long? SampleID { get; set; }
        public long? idfsSampleType { get; set; }
        public string SampleTypeName { get; set; }
        public long? idfsSpeciesType { get; set; }
        public string SpeciesTypeName { get; set; }
        public int? intPlannedNumber { get; set; }
        public string Comments { get; set; }
        public string intOrder { get; set; }
        public int RowStatus { get; set; } = 0;
        public int RowAction { get; set; } = 0;
        public int RowNumber { get; set; }
        public bool IsEditDisabled { get; set; }
        public int? HACode { get; set; }
        public long? idfsSpecies { get; set; }

        public bool IsInEditMode { get; set; }

    }

}
