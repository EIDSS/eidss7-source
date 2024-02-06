using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ResponseModels.FlexForm;
using EIDSS.Domain.ResponseModels.Outbreak;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using System;
using System.Collections.Generic;

namespace EIDSS.Domain.ViewModels.Outbreak
{
    public class CaseGetDetailViewModel : BaseModel
    {
        public long? CaseId { get; set; }
        public long? OutbreakId { get; set; }
        public long? CaseTypeId { get; set; }
        public string CaseTypeName { get; set; }
        public string EIDSSCaseId { get; set; }
        public DateTime DateEntered { get; set; }
        public DateTime? DateLastUpdated { get; set; }
        public long? HumanDiseaseReportId { get; set; }
        public long? VeterinaryDiseaseReportId { get; set; }
        public string FarmName { get; set; }
        public long? DiseaseId { get; set; }
        public string DiseaseName { get; set; }
        public DateTime? NotificationDate { get; set; }
        public long? NotificationSentByOrganizationId { get; set; }
        public string NotificationSentByOrganizationName { get; set; }
        public long? NotificationSentByPersonId { get; set; }
        public string NotificationSentByPersonName { get; set; }
        public long? NotificationReceivedByOrganizationId { get; set; }
        public string NotificationReceivedByOrganizationName { get; set; }
        public long? NotificationReceivedByPersonId { get; set; }
        public string NotificationReceivedByPersonName { get; set; }
        public long CaseAddressAdministrativeLevel0ID { get; set; }
        public string CaseAddressAdministrativeLevel0Name { get; set; }
        public long? CaseAddressAdministrativeLevel1ID { get; set; }
        public string CaseAddressAdministrativeLevel1Name { get; set; }
        public long? CaseAddressAdministrativeLevel2ID { get; set; }
        public string CaseAddressAdministrativeLevel2Name { get; set; }
        public long? CaseAddressAdministrativeLevel3ID { get; set; }
        public string CaseAddressAdministrativeLevel3Name { get; set; }
        public long? CaseAddressSettlementTypeID { get; set; }
        public string CaseAddressSettlementTypeName { get; set; }
        public long? CaseAddressSettlementID { get; set; }
        public string CaseAddressSettlementName { get; set; }
        public long? CaseAddressStreetID { get; set; }
        public string CaseAddressStreetName { get; set; }
        public string CaseAddressBuilding { get; set; }
        public string CaseAddressApartment { get; set; }
        public string CaseAddressHouse { get; set; }
        public long? CaseAddressPostalCodeID { get; set; }
        public string CaseAddressPostalCode { get; set; }
        public double? CaseAddressLatitude { get; set; }
        public double? CaseAddressLongitude { get; set; }
        public long? FarmTypeID { get; set; }
        public long? InvestigatedByOrganizationId { get; set; }
        public string InvestigatedByOrgnizationName { get; set; }
        public long? InvestigatedByPersonId { get; set; }
        public string InvestigatedByPersonName { get; set; }
        public DateTime? InvestigationDate { get; set; }
        public long? StatusTypeId { get; set; }
        public string StatusTypeName { get; set; }
        public long? ClassificationTypeId { get; set; }
        public string ClassificationTypeName { get; set; }
        public bool PrimaryCaseIndicator { get; set; }
        public long? CaseQuestionnaireObservationId { get; set; }
        public long? CaseQuestionnaireObservationFormTypeId { get; set; }
        public long? CaseQuestionnaireTemplateId { get; set; }
        public FlexFormQuestionnaireGetRequestModel CaseQuestionnaireFlexFormRequest { get; set; }
        public IList<FlexFormActivityParametersListResponseModel> CaseQuestionnaireFlexFormAnswers { get; set; }
        public string CaseQuestionnaireObservationParameters { get; set; }
        public long? CaseEPIObservationID { get; set; }
        public long? CaseEPIObservationFormTypeId { get; set; }
        public string AdditionalComments { get; set; }
        public int RowStatus { get; set; }
        public LocationViewModel CaseLocation { get; set; }
        public IList<CaseMonitoringGetListViewModel> CaseMonitorings { get; set; }
        public IList<CaseMonitoringGetListViewModel> PendingSaveCaseMonitorings { get; set; }
        public IList<ContactGetListViewModel> Contacts { get; set; }
        public IList<ContactGetListViewModel> PendingSaveContacts { get; set; }
        public IList<EventSaveRequestModel> PendingSaveEvents { get; set; }
        public bool AccessToPersonalDataPermissionIndicator { get; set; }
        public bool CreatePermissionIndicator { get; set; }
        public bool WritePermissionIndicator { get; set; }
        public bool DeletePermissionIndicator { get; set; }
        public bool CaseDisabledIndicator { get; set; }
        public bool NotificationSectionValidIndicator { get; set; }
        public bool CaseLocationSectionValidIndicator { get; set; }
        public bool OutbreakInvestigationSectionValidIndicator { get; set; }
        public bool CaseMonitoringSectionValidIndicator { get; set; }
        public bool ContactsSectionValidIndicator { get; set; }
        public OutbreakSessionDetailsResponseModel Session { get; set; }
        public DiseaseReportGetDetailViewModel VeterinaryDiseaseReport { get; set; }
        public string CancelURL { get; set; }
    }
}
