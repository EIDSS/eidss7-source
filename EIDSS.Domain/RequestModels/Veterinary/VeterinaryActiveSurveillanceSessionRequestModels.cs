using EIDSS.Domain.Abstracts;
using System;
using System.ComponentModel.DataAnnotations;
using EIDSS.Domain.Attributes;
using EIDSS.Domain.Enumerations;

namespace EIDSS.Domain.RequestModels.Veterinary
{
    public class VeterinaryActiveSurveillanceSessionSearchRequestModel : BaseGetRequestModel
    {
        public string SessionID { get; set; }
        public string LegacySessionID { get; set; }
        public string CampaignID { get; set; }
        public long? CampaignKey { get; set; }
        public long? SessionStatusTypeID { get; set; }
        public long? DiseaseID { get; set; }
        public long? AdministrativeLevelID { get; set; }
        public DateTime? DateEnteredFrom { get; set; }
        public DateTime? DateEnteredTo { get; set; }
        public long? SessionCategoryTypeID { get; set; }
        [Required]
        public long? UserSiteID { get; set; }

        [Required]
        public long? UserOrganizationID { get; set; }

        [Required]
        public long? UserEmployeeID { get; set; }

        public bool? ApplySiteFiltrationIndicator { get; set; } = false;
    }

    public class VeterinaryActiveSurveillanceSessionDetailRequestModel : BaseGetRequestModel
    {
        [Required]
        public long MonitoringSessionID { get; set; }
        [Required]
        public long? UserSiteID { get; set; }
        [Required]
        public long? UserOrganizationID { get; set; }
        [Required]
        public long? UserEmployeeID { get; set; }
        public bool? ApplyFiltrationIndicator { get; set; } = false;
    }

    public class VeterinaryActiveSurveillanceSessionNonPagedDetailRequestModel
    {
        public string LanguageID { get; set; }
        public long MonitoringSessionID { get; set; }
    }

    public class VeterinaryActiveSurveillanceSessionAggregateNonPagedRequestModel
    {
        public string LanguageID { get; set; }
        public long MonitoringSessionSummaryID { get; set; }
    }

    public class VeterinaryActiveSurveillanceSessionSampleDiseaseRequestModel
    {
        public string LanguageID { get; set; }
        public long? MonitoringSessionID { get; set; }
        public long? SampleID { get; set; }
    }

    [DataUpdateType( DataUpdateTypeEnum.Update)]
    public class VeterinaryActiveSurveillanceSessionSaveRequestModel
    {
        public long? MonitoringSessionID { get; set; }


        public string SessionID { get; set; }

        public DateTime? SessionStartDate { get; set; }

        public DateTime? SessionEndDate { get; set; }

        public long? SessionStatusTypeID { get; set; }
        public long? SessionCategoryID { get; set; }
        public long? SiteID { get; set; }
        public string LegacySessionID { get; set; }

        public long? CountryID { get; set; }

        public long? RegionID { get; set; }

        public long? RayonID { get; set; }

        public long? SettlementID { get; set; }

        public long? CampaignKey { get; set; }
        
        public string CampaignID { get; set; }

        public DateTime? DateEntered { get; set; }

        public long? EnteredByPersonID { get; set; }
        public int RowStatus { get; set; }
        public long? ReportTypeID { get; set; }
        public string AuditUserName { get; set; }
        public string FlocksOrHerds { get; set; }
        public string DiseaseSpeciesSamples { get; set; }
        public string Species { get; set; }
        public string Animals { get; set; }
        public string Farms { get; set; }
        public string Samples { get; set; }
        public string SamplesToDiseases { get; set; }
        public string LaboratoryTests { get; set; }
        public string LaboratoryTestInterpretations { get; set; }
        public string Actions { get; set; }
        public string AggregateSummaryInfo { get; set; }
        public string AggregateSummaryDiseases { get; set; }
        public string FarmsAggregate { get; set; }
        public string FlocksOrHerdsAggregate { get; set; }
        public string SpeciesAggregate { get; set; }
        public string DiseaseReports { get; set; }
        public string Events { get; set; }
        public long UserID { get; set; }
        public long? LocationID { get; set; }
        public bool LinkLocalOrFieldSampleIDToReportID { get; set; }
    }
}