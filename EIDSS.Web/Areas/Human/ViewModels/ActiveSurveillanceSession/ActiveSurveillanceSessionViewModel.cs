using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using System;
using System.Collections.Generic;

namespace EIDSS.Web.Areas.Human.ViewModels.ActiveSurveillanceSession
{
    public class ActiveSurveillanceSessionViewModel
    {
        public ActiveSurveillanceSessionRequestModel SearchRequest { get; set; }
        public List<ActiveSurveillanceSessionResponseModel> SearchResults { get; set; }
        public ActiveSurveillanceSessionInformationModel SessionInformation { get; set; }
        public ActiveSurveillanceSessionDetailedInformation DetailedInformation { get; set; }
        public ActiveSurveillanceSessionTestsInformation TestsInformation { get; set; }
        public ActiveSurveillanceSessionActionsInformation ActionsInformation { get; set; }
        public ActiveSurveillanceSessionDiseaseReports DiseaseReports { get; set; }
        public List<EventSaveRequestModel> PendingSaveEvents { get; set; }
        public UserPermissions ActiveSurveillanceSessionPermissions { get; set; }
        public List<ActiveSurveillanceSessionResponseModel> Results { get; set; }
        public LocationViewModel SearchLocationViewModel { get; set; }
        public bool RecordSelectionIndicator { get; set; }
        public ActiveSurveillanceSessionSummaryHeader Summary { get; set; }
        public List<ActiveSurveillanceSessionDiseaseSampleType> DiseasesSampleTypesUnfiltered { get; set; }
        public List<ActiveSurveillanceSessionDiseaseSampleType> DiseasesSampleTypes { get; set; }
        public int DiseasesSampleTypesCount { get; set; }
        public bool RecordReadOnly { get; set; } = false;
        public int ActiveSurveillanceSessionDiseaseSampleTypeNewID { get; set; } = -1;
        public DiseaseReportGetDetailViewModel ReportDetailModel { get; set; }
        public long BottomAdminLevel { get; set; }
    }

    public class ActiveSurveillanceSessionSummaryHeader
    {
        public string SessionID { get; set; }
        public string Status { get; set; }
        public string Disease { get; set; }
    }

    public class ActiveSurveillanceSessionDiseaseSampleType
    {
        public long? ID { get; set; }
        public long? DiseaseID { get; set; }
        public string DiseaseName { get; set; }
        public long? SampleID { get; set; }
        public long? SampleTypeID { get; set; }
        public string SampleTypeName { get; set; }
        public string RowAction { get; set; }
        public int intRoWStatus { get; set; }
    }

    public class ActiveSurveillanceFilteredDisease
    {
        public string DiseaseName { get; set; }
        public long DiseaseID { get; set; }
    }

    public class ActiveSurveillanceFilteredSampleType
    {
        public long SampleTypeID { get; set; }
        public string SampleTypeName { get; set; }
    }

    public class ActiveSurveillanceSessionInformationModel
    {
        public long? MonitoringSessionID { get; set; }
        public string EIDSSSessionID { get; set; }
        public long? MonitoringSessionStatusTypeID { get; set; }
        public long? MonitoringSessionStatusTypeID_Original { get; set; }
        public long? CampaignID { get; set; }
        public string strCampaignID { get; set; }
        public string CampaignName { get; set; }
        public long? CampaignTypeID { get; set; }
        public string CampaignTypeName { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public long DiseaseID { get; set; }
        public long? SiteID { get; set; }
        public string Site { get; set; }
        public string Officer { get; set; }
        public long OfficerID { get; set; }
        public DateTime? EnteredDate { get; set; }
        public bool ReadPermissionIndicator { get; set; }
        public bool AccessToPersonalDataPermissionIndicator { get; set; }
        public bool AccessToGenderAndAgeDataPermissionIndicator { get; set; }
        public bool WritePermissionIndicator { get; set; }
        public bool DeletePermissionIndicator { get; set; }
        public LocationViewModel LocationViewModel { get; set; }
        public List<ActiveSurveillanceSessionSamplesResponseModel> MonitoringSessionToSampleTypes { get; set; }
        public List<ActiveSurveillanceSessionSamplesResponseModel> UnfilteredMonitoringSessionToSampleTypes { get; set; }
    }

    public class ActiveSurveillanceSessionDetailedInformation
    {
        public long? ID { get; set; }
        public long? idfsSampleType { get; set; }
        public string SampleType { get; set; }
        public string FieldSampleID { get; set; }
        public IEnumerable<long> DiseaseIDs { get; set; }
        public List<ActiveSurveillanceFilteredDisease> SampleTypeDiseases { get; set; }
        public long HumanMasterID { get; set; }
        public long PersonID { get; set; }
        public string EIDSSPersonID{ get; set; }
        public string PersonAddress { get; set; }
        public DateTime? CollectionDate { get; set; }
        public string Comments { get; set; }
        //[LocalizedRequired()]
        public long? SentToOrganization { get; set; }
        public IEnumerable<OrganizationAdvancedGetListViewModel> SentToOrganizations;
        public int ListCount { get; set; }
        public int NewFieldSampleId { get; set; } = 1;
        public long NewRecordId { get; set; } = -1;
        public List<ActiveSurveillanceSessionDetailedInformationResponseModel> List { get; set; }
        public List<ActiveSurveillanceSessionDetailedInformationResponseModel> UnfilteredList { get; set; }
    }

    public class ActiveSurveillanceSessionDetailInformationModel
    {
        public long SampleTypeID { get; set; }
        public string FieldSampleID { get; set; }
        public string personID { get; set; }
        public string PersonAddress { get; set; }
        public DateTime? CollectionDate { get; set; }
        public string Comments { get; set; }
        public long SentToOrganizationID { get; set; }
    }

    public class ActiveSurveillanceSessionDiseases
    {
        public long? MonitoringSessionToDiseaseID { get; set; }
        public long? MonitoringSessionID { get; set; }
        public long DiseaseID { get; set; }
        public long SampleTypeID { get; set; }
        public long SpeciesTypeID { get; set; }
        public int OrderNumber { get; set; } = 0;
        public int RowStatus { get; set; } = (int)RowStatusTypeEnum.Active;
        public string RowAction { get; set; }
    }

    public class ActiveSurveillanceSessionTestsInformation
    {
        public long? ID { get; set; }
        public string FieldSampleID { get; set; }
        public string LabSampleID { get; set; }
        public string SampleType { get; set; }
        public long SampleTypeID { get; set; }
        public long SampleID { get; set; }
        public long PersonID { get; set; }
        public string EIDSSPersonID { get; set; }
        public long? TestNameID { get; set; }
        public long? TestDiseaseID { get; set; }
        public string TestStatus { get; set; } = "Final";
        public long TestStatusID { get; set; } = 10001001;
        public long? TestCategoryID { get; set; }
        public DateTime? ResultDate { get; set; }
        public long? TestResultID { get; set; }
        public long? OriginalTestResultTypeID { get; set; }
        public bool FilterByDisease { get; set; } = true;
        public int NewRecordId { get; set; } = -1;
        public IEnumerable<ActiveSurveillanceSessionTestNamesResponseModel> TestNames { get; set; }
        public IEnumerable<TestNameTestResultsMatrixViewModel> TestResults { get; set; }
        public List<BaseReferenceEditorsViewModel> TestNameDiseases { get; set; }
        public List<ActiveSurveillanceFilteredDisease> Diseases { get; set; }
        public List<ActiveSurveillanceSessionTestsResponseModel> List { get; set; }
        public List<ActiveSurveillanceSessionTestsResponseModel> UnfilteredList { get; set; }
    }

    public class ActiveSurveillanceSessionTestsInformationModal
    {
        public long ID { get; set; }
        public string FieldSampleID { get; set; }
        public string LabSampleID { get; set; }
        public string SampleType { get; set; }
        public string PersonID { get; set; }
        public string TestDisease { get; set; }
        public string FilterByDisease { get; set; }
        public string TestName { get; set; }
        public string TestStatus { get; set; }
        public string TestCategory { get; set; }
        public string ResultDate { get; set; }
        public string TestResult { get; set; }
    }

    public class ActiveSurveillanceSessionActionsInformation
    {
        public long? ID { get; set; }
        public long? ActionRequiredID { get; set; }
        public DateTime? DateOfAction { get; set; }
        public string EnteredBy { get; set; }
        public string Comment { get; set; }
        public long StatusID { get; set; }
        public long NewRecordId { get; set; } = -1;
        public List<ActiveSurveillanceSessionActionsResponseModel> List { get; set; }
        public List<ActiveSurveillanceSessionActionsResponseModel> UnfilteredList { get; set; }
    }

    public class ActiveSurveillanceSessionActionsInformationModal
    {
        public long ActionRequiredID { get; set; }
        public DateTime? DateOfAction { get; set; }
        public string EnteredBy { get; set; }
        public string Comment { get; set; }
        public long StatusID { get; set; }
    }

    public class ActiveSurveillanceSessionDiseaseReports
    {
        public IEnumerable<ActiveSurveillanceSessionDiseaseReportsResponseModel> List { get; set; }
    }

    public class ActiveSurveillanceSessionDisease
    {
        public long? MonitoringSessionToDiseaseID { get; set; }
        public long? MonitoringSessionID { get; set; }
        public long DiseaseID { get; set; }
        public string DiseaseName { get; set; }
        public int OrderNumber { get; set; } = 1;
        public int RowStatus { get; set; } = (int)RowStatusTypeEnum.Active;
        public long SampleTypeID { get; set; }
        public string Comments { get; set; }
        public string SampleTypeName { get; set; }
        public string RowAction { get; set; }
    }

    public class ActiveSurveillanceSessionSample
    {
        public long? SampleID { get; set; }
        public long SampleTypeID { get; set; }
        public long? SampleStatusTypeID { get; set; }
        public DateTime? CollectionDate { get; set; }
        public long CollectedByOrganizationID { get; set; }
        public long CollectedByPersonID { get; set; }
        public DateTime SentDate { get; set; }
        public long SentToOrganizationID { get; set; }
        public string EIDSSLocalOrFieldSampleID { get; set; }
        public string Comments { get; set; }
        public long SiteID { get; set; }
        //public long? CurrentSiteID { get; set; }
        public long? DiseaseID { get; set; }
        public long? HumanID { get; set; }
        public long HumanMasterID { get; set; }
        public int RowStatus { get; set; } = (int)RowStatusTypeEnum.Active;
        public string RowAction { get; set; }
        public bool ReadOnlyIndicator { get; set; } = false;
    }

    public class ActiveSurveillanceSessionAction
    {
        public long? MonitoringSessionActionID { get; set; }
        public long? MonitoringSessionID { get; set; }
        public long EnteredByPersonID { get; set; }
        public long ActionTypeID { get; set; }
        public long ActionStatusTypeID { get; set; }
        public DateTime? ActionDate { get; set; }
        public string Comments { get; set; }
        public int RowStatus { get; set; } = (int)RowStatusTypeEnum.Active;
        public string RowAction { get; set; }
    }

    public class ActiveSurveillanceMonitoringSessionToSampleType
    {
        public long? MonitoringSessionToSampleTypeID { get; set; } = -1;
        public long? MonitoringSessionID { get; set; }
        public long? SampleTypeID { get; set; }
        public int OrderNumber { get; set; } = 0;
        public int RowStatus { get; set; }
        public string RowAction { get; set; }
    }

    public class ActiveSurveillanceSessionTest
    {
        public long? TestID { get; set; }
        public long? MonitoringSessionID { get; set; }
        public long TestNameTypeID { get; set; }
        public long? TestCategoryTypeID { get; set; }
        public long TestResultTypeID { get; set; }
        public long? OriginalTestResultTypeID { get; set; }
        public long? TestStatusTypeID { get; set; }
        public long DiseaseID { get; set; }
        public long SampleTypeID { get; set; }
        public long SampleID { get; set; }
        public long BatchTestID { get; set; }
        public long? ObservationID { get; set; }
        public int TestNumber { get; set; }
        public string Comments { get; set; }
        public DateTime StartedDate { get; set; }
        public DateTime? ResultDate { get; set; }
        public long? TestedByOrganizationID { get; set; }
        public long? TestedByPersonID { get; set; }
        public long? ResultEnteredByOrganizationID { get; set; }
        public long? ResultEnteredByPersonID { get; set; }
        public long? ValidatedByOrganizationID { get; set; }
        public long? ValidatedByPersonID { get; set; }
        public bool ReadOnlyIndicator { get; set; }
        public bool NonLaboratoryTestIndicator { get; set; } = false;
        public bool ExternalTestIndicator { get; set; } = false;
        public long? PerformedByOrganizationID { get; set; }
        public DateTime? ReceivedDate { get; set; }
        public string ContactPersonName { get; set; }
        public int RowStatus { get; set; } = (int)RowStatusTypeEnum.Active;
        public string RowAction { get; set; }
    }
}