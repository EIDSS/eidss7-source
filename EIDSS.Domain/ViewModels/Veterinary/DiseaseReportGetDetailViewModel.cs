using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ResponseModels.FlexForm;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Localization.Helpers;
using System;
using System.Collections.Generic;

namespace EIDSS.Domain.ViewModels.Veterinary
{
    public class DiseaseReportGetDetailViewModel : BaseModel
    {
        public long DiseaseReportID { get; set; }
        public long? FarmID { get; set; }
        public long FarmMasterID { get; set; }
        public string EIDSSFarmID { get; set; }
        public string FarmName { get; set; }
        public long FarmAddressAdministrativeLevel0ID { get; set; }
        public string FarmAddressAdministrativeLevel0Name { get; set; }
        public long? FarmAddressAdministrativeLevel1ID { get; set; }
        public string FarmAddressAdministrativeLevel1Name { get; set; }
        public long? FarmAddressAdministrativeLevel2ID { get; set; }
        public string FarmAddressAdministrativeLevel2Name { get; set; }
        public long? FarmAddressAdministrativeLevel3ID { get; set; }
        public string FarmAddressAdministrativeLevel3Name { get; set; }
        public long? FarmAddressSettlementTypeID { get; set; }
        public string FarmAddressSettlementTypeName { get; set; }
        public long? FarmAddressSettlementID { get; set; }
        public string FarmAddressSettlementName { get; set; }
        public long? FarmAddressStreetID { get; set; }
        public string FarmAddressStreetName { get; set; }
        public string FarmAddressBuilding { get; set; }
        public string FarmAddressApartment { get; set; }
        public string FarmAddressHouse { get; set; }
        public long? FarmAddressPostalCodeID { get; set; }
        public string FarmAddressPostalCode { get; set; }
        public double? FarmAddressLatitude { get; set; }
        public double? FarmAddressLongitude { get; set; }
        public LocationViewModel FarmLocation { get; set; }
        public long? FarmOwnerID { get; set; }
        public string EIDSSFarmOwnerID { get; set; }
        public string FarmOwnerFirstName { get; set; }
        public string FarmOwnerLastName { get; set; }
        public string FarmOwnerSecondName { get; set; }
        public string FarmOwnerName { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public long? DiseaseID { get; set; }
        public string DiseaseName { get; set; }
        public long? EnteredByPersonID { get; set; }
        public string EnteredByPersonName { get; set; }
        public long? ReportedByPersonID { get; set; }
        public string ReportedByPersonName { get; set; }
        public long? InvestigatedByPersonID { get; set; }
        public string InvestigatedByPersonName { get; set; }
        public long? ReceivedByOrganizationID { get; set; }
        public long? ReceivedByPersonID { get; set; }
        public long? FarmEpidemiologicalObservationID { get; set; }
        public FlexFormAssignedTemplatesModel OutbreakFlexFormTemplates {get;set;}
        public FlexFormQuestionnaireGetRequestModel FarmEpidemiologicalInfoFlexForm { get; set; }
        public IList<FlexFormActivityParametersListResponseModel> FarmEpidemiologicalInfoFlexFormAnswers { get; set; }
        public string FarmEpidemiologicalInfoObservationParameters { get; set; }
        public long? ControlMeasuresObservationID { get; set; }
        public FlexFormQuestionnaireGetRequestModel ControlMeasuresFlexForm { get; set; }
        public IList<FlexFormActivityParametersListResponseModel> ControlMeasuresFlexFormAnswers { get; set; }
        public string ControlMeasuresObservationParameters { get; set; }
        public long SiteID { get; set; }
        public string SiteName { get; set; }
        public DateTime? ReportDate { get; set; }
        public DateTime? AssignedDate { get; set; }
        public DateTime? InvestigationDate { get; set; }
        public DateTime? DiagnosisDate { get; set; }
        public string EIDSSFieldAccessionID { get; set; }
        public long? TestsConductedIndicator { get; set; }
        public int RowStatus { get; set; }
        public long? ReportedByOrganizationID { get; set; }
        public string ReportedByOrganizationName { get; set; }
        public long? InvestigatedByOrganizationID { get; set; }
        public string InvestigatedByOrganizationName { get; set; }
        public long? ReportTypeID { get; set; }
        public string ReportTypeName { get; set; }
        public long? ClassificationTypeID { get; set; }
        public string ClassificationTypeName { get; set; }
        public bool OutbreakCaseIndicator { get; set; }
        public long? OutbreakID { get; set; }
        public string EIDSSOutbreakID { get; set; }
        public DateTime? EnteredDate { get; set; }
        public string EIDSSReportID { get; set; }
        public string LegacyID { get; set; }
        [LocalizedRequired]
        public long? ReportStatusTypeID { get; set; }
        public string ReportStatusTypeName { get; set; }
        public bool ReportCurrentlyClosedIndicator { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public long? ParentMonitoringSessionID { get; set; }
        public string EIDSSParentMonitoringSessionID { get; set; }
        public long? RelatedToVeterinaryDiseaseReportID { get; set; }
        public string RelatedToVeterinaryDiseaseEIDSSReportID { get; set; }
        public long? ConnectedDiseaseReportID { get; set; }
        public string ConnectedDiseaseEIDSSReportID { get; set; }
        public string YNTestConducted { get; set; }
        public string OIECode { get; set; }
        public long ReportCategoryTypeID { get; set; }
        public string ReportCategoryTypeName { get; set; }
        public long? FarmEpidemiologicalTemplateID { get; set; }
        public string RelatedToIdentifiers { get; set; }
        public string RelatedToReportIdentifiers { get; set; }
        public IList<FarmInventoryGetListViewModel> FarmInventory { get; set; }
        public IList<FarmInventoryGetListViewModel> PendingDeleteFarmInventory { get; set; }
        public IList<FarmInventoryGetListViewModel> FarmGroups { get; set; }
        public bool SpeciesAddedRemovedIndicator { get; set; }
        public long? PriorSpeciesSelectedId { get; set; }
        public IList<FarmInventoryGetListViewModel> Species { get; set; }
        public IList<VaccinationGetListViewModel> Vaccinations { get; set; }
        public IList<VaccinationGetListViewModel> PendingSaveVaccinations { get; set; }
        public IList<AnimalGetListViewModel> Animals { get; set; }
        public IList<AnimalGetListViewModel> PendingSaveAnimals { get; set; }
        public IList<SampleGetListViewModel> Samples { get; set; }
        public IList<SampleGetListViewModel> PendingSaveSamples { get; set; }
        public IList<PensideTestGetListViewModel> PensideTests { get; set; }
        public IList<PensideTestGetListViewModel> PendingSavePensideTests { get; set; }
        public IList<LaboratoryTestGetListViewModel> LaboratoryTests { get; set; }
        public IList<LaboratoryTestGetListViewModel> PendingSaveLaboratoryTests { get; set; }
        public IList<LaboratoryTestInterpretationGetListViewModel> LaboratoryTestInterpretations { get; set; }
        public IList<LaboratoryTestInterpretationGetListViewModel> PendingSaveLaboratoryTestInterpretations { get; set; }
        public IList<CaseLogGetListViewModel> CaseLogs { get; set; }
        public IList<CaseLogGetListViewModel> PendingSaveCaseLogs { get; set; }
        public IList<EventSaveRequestModel> PendingSaveEvents { get; set; }
        public bool DiseaseReportSummaryValidIndicator { get; set; }
        public bool DiseaseReportSummaryModifiedIndicator { get; set; }
        public bool FarmDetailsSectionValidIndicator { get; set; }
        public bool FarmDetailsSectionModifiedIndicator { get; set; }
        public bool NotificationSectionValidIndicator { get; set; }
        public bool NotificationSectionModifiedIndicator { get; set; }
        public bool FarmEpidemiologicalInfoSectionValidIndicator { get; set; }
        public bool FarmEpidemiologicalInfoSectionModifiedIndicator { get; set; }
        public bool SpeciesClinicalInvestigationInfoSectionValidIndicator { get; set; }
        public bool SpeciesClinicalInvestigationInfoSectionModifiedIndicator { get; set; }
        public bool AnimalsSectionValidIndicator { get; set; }
        public bool ControlMeasuresSectionValidIndicator { get; set; }
        public bool ControlMeasuresSectionModifiedIndicator { get; set; }
        public bool AccessToPersonalDataPermissionIndicator { get; set; }
        public bool ReadPermissionIndicator { get; set; }
        public bool CreatePermissionIndicator { get; set; }
        public bool WritePermissionIndicator { get; set; }
        public bool DeletePermissionIndicator { get; set; }
        public bool CanReopenClosedDiseaseReportSession { get; set; }
        public bool CreateEmployeePermissionIndicator { get; set; }
        public bool CreateBaseReferencePermissionIndicator { get; set; }
        public string Comments { get; set; }
        public SurveillanceSessionLinkedDiseaseReportViewModel SessionModel { get; set; }

        private bool reportStatusTypeDisabledIndicator;
        public bool ReportStatusTypeDisabledIndicator
        {
            get
            {
                reportStatusTypeDisabledIndicator = true;

                switch (ReportStatusTypeID)
                {
                    case null:
                        reportStatusTypeDisabledIndicator = false;
                        break;
                    case (long)DiseaseReportStatusTypeEnum.Closed:
                    {
                        if (CanReopenClosedDiseaseReportSession)
                            reportStatusTypeDisabledIndicator = false;
                        break;
                    }
                    default:
                        reportStatusTypeDisabledIndicator = false;
                        break;
                }

                return reportStatusTypeDisabledIndicator;
            }
        }
        public bool ReportViewModeIndicator { get; set; }

        private bool diseaseDisabledIndicator;
        public bool DiseaseDisabledIndicator
        {
            get
            {
                diseaseDisabledIndicator = DiseaseReportID > 0;

                return diseaseDisabledIndicator;
            }
        }

        public bool ReportDisabledIndicator { get; set; }
        public bool ShowReviewSectionIndicator { get; set; }
    }
}