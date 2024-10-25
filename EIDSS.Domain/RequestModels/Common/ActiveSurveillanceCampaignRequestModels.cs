using EIDSS.Domain.Abstracts;
using System;
using EIDSS.Domain.Attributes;
using EIDSS.Domain.Enumerations;

namespace EIDSS.Domain.RequestModels.Common
{
    public class ActiveSurveillanceCampaignRequestModel : BaseGetRequestModel
    {
        public string CampaignID { get; set; }
        public string LegacyCampaignID { get; set; }
        public string CampaignName { get; set; }
        public long? CampaignTypeID { get; set; }
        public long? CampaignStatusTypeID { get; set; }
        public long? CampaignCategoryID { get; set; }
        public DateTime? StartDateFrom { get; set; }
        public DateTime? StartDateTo { get; set; }
        public long? DiseaseID { get; set; }
        public long? UserSiteID { get; set; }
        public long? UserEmployeeID { get; set; }
        public bool? ApplySiteFiltrationIndicator { get; set; }
    }

    public class ActiveSurveillanceCampaignDetailRequestModel 
    {
        public long CampaignID { get; set; }
        public string LanguageId { get; set; }
    }

    public class ActiveSurveillanceCampaignDiseaseSpeciesSamplesGetRequestModel : BaseGetRequestModel
    {
        public long CampaignID { get; set; }
    }

    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class ActiveSurveillanceCampaignSaveRequestModel 
    {
        public string LanguageId { get; set; }

        public long? idfCampaign { get; set; }

        public long CampaignTypeID { get; set; }

        public long CampaignStatusTypeID { get; set; }

        public DateTime? CampaignDateStart { get; set; }

        public DateTime? CampaignDateEnd { get; set; }

        public string strCampaignID { get; set; }

        public string CampaignName { get; set; }

        public string CampaignAdministrator { get; set; }

        public string Conclusion { get; set; }


        public long SiteID { get; set; }


        public long CampaignCategoryTypeID { get; set; }
        public string AuditUserName { get; set; }
        public string CampaignToDiagnosisCombo { get; set; }
        public string MonitoringSessions { get; set; }
        public string Events { get; set; }
    }

    public class DisassociateSessionFromCampaignSaveRequestModel
    {
        public long idfCampaign { get; set; }
        public long idfMonitoringSesion { get; set; }
        public string AuditUserName { get; set; }
    }

    public class TlbCampaignToDiagnosis
    {
        public long idfCampaignToDiagnosis { get; set; }
        public long? idfsDiagnosis { get; set; }
        public int intOrder { get; set; }
        public int? intPlannedNumber { get; set; }
        public long? idfsSpeciesType { get; set; }
        public long? idfsSampleType { get; set; }
        public string Comments { get; set; }
    }

    public class TlbCampaignSession
    {
        public long idfMonitoringSession { get; set; }
        public bool deleteFlag { get; set; }
    }
}
