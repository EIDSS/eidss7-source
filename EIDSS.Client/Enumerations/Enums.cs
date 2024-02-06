using System;

namespace EIDSS.ClientLibrary.Enumerations
{
    public enum EmployeeGroupTypes : long
    {
        ChiefEpidemiologist = 49535210000000,
        Epidemiologist = 49535220000000,
        ChiefVeterinarian = 49535160000000,
        Veterinarian = 49535200000000,
        Administrator = 49535150000000,
        ChiefOfLaboratoryHuman = 1521580000000,
        ChiefOfLaboratoryVeterinary = 1521600000000,
        LabTechnicianHuman = 1521680000000,
        LabTechnicianVeterinary = 1521700000000
    }

    public enum AccessoryCodes : int
    {
        NoneHACode = 0,
        HumanHACode = 2,
        ExophyteHACode = 4,
        PlantHACode = 8,
        SoilHACode = 16,
        LivestockHACode = 32,
        ASHACode = 34,
        AvianHACode = 64,
        LiveStockAndAvian = 96,
        OutbreakPriorityHACode = 98,
        VectorHACode = 128,
        HALVHACode = 226,
        SyndromicHACode = 256,
        AllHACode = 510
    }

    public enum AccessoryReferenceCodes : long
    {
        All = 10040001,
        Avian = 10040003,
        Exophyte = 10040004,
        Human = 10040005,
        Livestock = 10040007,
        None = 10040008,
        Plant = 10040009,
        Soil = 10040010,
        Syndromic = 10040012,
        Vector = 10040011
    }

    public enum GoogleMapAddressType
    {
        Local = 1,
        OtherAddress = 2,
        WorkOrSchool = 3,
        LocationOfExposure = 4
    }

    public enum ClassificationQuestionType
    {
        Suspect,
        Probable
    }

    public enum RiskFactorType
    {
        DropDown,
        TextBox
    }

    public enum SPType
    {
        SPGetList = 0,
        SPGetDetail = 1,
        SPSet = 2,
        SPDelete = 3
    }

    public enum MessageType
    {
        AddUpdateSuccess,
        AddUpdatePersonSuccess,
        AddUpdateFarmSuccess,
        AddOutbreakHumanCase,
        AddOutbreakVeterinaryCase,
        AddOutbreakSession,
        AddVectorSurveillance,
        AddOutbreakVectorSurveillance,
        EditOutbreakVectorSurveillance,
        UpdateVectorSurveillance,
        UpdateOutbreakHumanCase,
        UpdateOutbreakVeterinaryCase,
        UpdateOutbreakSession,
        CampaignToSessionDiseaseMismatch,
        CampaignToSessionDateMismatch,
        ConfirmAddSampleToSpeciesTypeCombination,
        ConfirmAddSampleForMonitoringSession,
        CannotAddUpdate,
        CannotAddUpdateBaseReference,
        CannotSelectAggregateReport,
        DeleteSuccess,
        DeleteMonitoringSessionSuccess,
        CannotDelete,
        ConfirmDelete,
        ConfirmDeletePerson,
        ConfirmDeleteFarm,
        ConfirmDeleteAggregateInfoFarm,
        ConfirmDeleteDetailedInfoFarm,
        ConfirmDeleteFreezer,
        ConfirmDeleteFreezerSubdivision,
        ConfirmDeleteDiseaseReport,
        ConfirmDeleteCampaign,
        ConfirmDeleteCaseMonitoring,
        ConfirmDeleteCaseSample,
        ConfirmDeleteCaseTest,
        ConfirmDeleteTestInterpretation,
        ConfirmDeleteAggregateDiseaseReport,
        ConfirmDeleteWeeklyReportForm,
        ConfirmDeleteMonitoringSession,
        ConfirmDeleteSpeciesToSampleType,
        ConfirmDeleteFarmMasterInventory,
        ConfirmDeleteFarmInventory,
        ConfirmDeleteAggregateInfoFarmInventory,
        ConfirmDeleteDetailedInfoFarmInventory,
        ConfirmDeleteSample,
        ConfirmDeleteSamples,
        ConfirmDeleteSite,
        ConfirmDeleteLabTest,
        ConfirmDeleteLabTests,
        ConfirmDeleteLabTestInterpretation,
        ConfirmDeleteLabTestInterpretations,
        ConfirmDeletePensideTest,
        ConfirmDeleteAnimal,
        ConfirmDeleteReportLog,
        ConfirmDeleteAction,
        ConfirmDeleteActor,
        ConfirmDeleteAggregateInfo,
        ConfirmDeleteContact,
        ConfirmDeleteVetSample,
        ConfirmDeleteAntimicrobial,
        ConfirmDeleteVaccination,
        ConfirmDeleteVetVaccination,
        ConfirmDeleteVetPensideTest,
        ConfirmDeleteVetLabTest,
        CannotDeleteVetLabTest,
        ConfirmDeleteVetSpecies,
        ConfirmDeleteSpeciesClinicalInvestigation,
        ConfirmDeleteVetHerd,
        ConfirmDeleteAliquotDerivative,
        ConfirmCancelTransfer,
        ConfirmCancelDataAccessDetails,
        ConfirmCancelSearchActor,
        CancelConfirm,
        CancelConfirmAddUpdate,
        CancelAddOrganization,
        CancelSearchConfirm,
        CancelSearchResultsConfirm,
        ClosePage,
        CancelAggregateSummaryReportSelection,
        CancelAggregateSummary,
        CancelSampleConfirm,
        CancelVaccinationConfirm,
        CancelLabTestConfirm,
        CancelResultSummaryConfirm,
        CancelTestInterpretationConfirm,
        CancelActionConfirm,
        CancelAggregateInfoConfirm,
        CancelAnimalConfirm,
        CancelPensideTestConfirm,
        CancelReportLogConfirm,
        CancelOutbreakSession,
        CancelConfirmEmployee,
        CancelSearchOrganization,
        AssociatedAnimalRecords,
        AssociatedSampleRecords,
        AssociatedPensideTestRecords,
        AssociatedLabTestRecords,
        AssociatedInterpretationRecords,
        AssociatedSpeciesRecordsToFlock,
        AssociatedSpeciesRecordsToHerd,
        AssociatedRecordsToSpecies,
        CannotGetValidatorSection,
        DuplicateBaseReference,
        DuplicateFarm,
        DuplicateHuman,
        DuplicateSampleType,
        DuplicateSampleToSpeciesType,
        DuplicateCampaign,
        DuplicateAggregateDiseaseReport,
        DuplicateWeeklyReport,
        FarmTypeNotSelected,
        DuplicateSpeciesFlock,
        DuplicateSpeciesHerd,
        CampaignStatusOpenNew,
        CampaignFutureDateOpenStatus,
        CampaignStatusOpenClosed,
        UnhandledException,
        SearchCriteriaRequired,
        AdvancedSearchCriteriaRequired,
        NoFlockHerdSpeciesAssociated,
        CannotRegisterNewSample,
        CannotAccession,
        CannotAliquotDerivative,
        CannotAssignTest,
        CannotBatchTest,
        CannotCloseBatch,
        CannotSetTestResult,
        CannotAmendTestResult,
        CannotEditTest,
        CannotAddTestInterpretationDuplicateAnimalAndDisease,
        CannotEditSample,
        CannotImportSample,
        CannotGroupAccession,
        CannotTransferOut,
        CannotDeleteAnimal,
        CannotDeleteSample,
        CannotDeleteSampleType,
        CannotDeleteLabTest,
        CannotDeleteLabTestInterpretation,
        CannotRestoreSample,
        CannotSaveSampleTestDetails,
        CannotDeleteSubdivision,
        CannotDeleteFarmInventory,
        CannotDeleteFarm,
        ConfirmFarmToMonitoringSessionAddressMismatch,
        ConfirmAggregateFarmToMonitoringSessionAddressMismatch,
        ConfirmPersonToMonitoringSessionAddressMismatch,
        CannotAddPersonToSampleAgeMismatch,
        CannotAddPersonToSampleGenderMismatch,
        InvalidDateOfBirth,
        InvalidDates,
        NoSamplesToAccession,
        SampleMustBeAccessioned,
        NoSampleSelectedForSampleDestruction,
        NoSampleSelectedForSampleDeletion,
        NoSamplesToPrintBarCodes,
        NoBatchSelectedForClosure,
        RegisterNewSampleSuccess,
        NoTestSelectedForTestDeletion,
        TestMustBePreliminaryOrInProgressStatus,
        ReportSessionNotFound,
        PrintBarcodes,
        SamplesPrintBarcodes,
        MyFavoritesPrintBarcodes,
        ConfirmClose,
        ConfirmCancelAdvanceSearch,
        FieldValuePairFoundNoSelection,
        SaveSuccess,
        ConfirmMerge,
        CancelFormConfirm,
        CancelSearchPersonConfirm,
        CancelSearchFarmConfirm,
        CancelFarmAddUpdateConfirm,
        CancelPersonAddUpdateConfirm,
        CancelSearchVeterinaryDiseaseReportConfirm,
        CancelSelectMonitoringSessionForCampaign,
        CancelSelectCampaignForMonitoringSession,
        CannotSelectVeterinaryMonitoringSessionForCampaign,
        CannotSelectHumanMonitoringSessionForCampaign,
        CannotSelectDateRangeHumanMonitoringSessionForCampaign,
        InvalidDeadAnimalQuantity,
        InvalidSickAnimalQuantity,
        InvalidDeadAndSickSumQuantity,
        AllFieldValuePairsUnmatched,
        SpeciesRequired,
        FutureStartOfSignsDate,
        CancelOutbreakHumanDisease,
        CancelOutbreakVetDisease,
        ReportAlreadyCreatedForInterpretation,
        ReportSessionDiseaseNotAssociatedToAccessoryCode,
        RecordNotFound,
        AgeIncorrect,
        SurvivorSupersededNotSelected,
        NoFarmAssociatedToSampleTestOrTestInterpretation,
        NoSampleTypeCombinations,
        NoSpeciesToSampleTypeCombinations,
        CannotSaveSurvivorRecord,
        CancelLaboratory,
        UnableCompleteDeduplication,
        CentralSiteRequired,
        CentralSiteAlreadyAssignedToSiteGroup,
        AtLeastTwoSitesRequiredOnSiteGroup,
        InvalidLogin,
        UserLockedOut,
        ResetPassword,
        InsufficientPermissions,
        InsufficientFarmPermissions,
        InsufficientCampaignPermissions,
        InsufficientDiseaseReportPermissions,
        InsufficientSessionPermissions,
        InsufficientPersonPermissions,
        InsufficientAddUpdatePersonPermissions,
        DuplicateHospitalSentinelStation,
        OutbreakRedirectionDecision,
        ValidationErrors,
        UnitOfMeasureRequired,
        CancelSearchEmployeeConfirm,
        DuplicateEmployee,
        UnsavedChanges,
        ActivateEmployeeConfirm,
        CannotActivateOrDeactivate,
        DeactivateEmployeeConfirm,
        ConfirmDeletEmployee,
        SaveUserPreferences,
        MonitoringSessionRemovedFromCampaign,
        ConfirmMonitoringSessionRemoveFromCampaign,
        CampaignToMonitoringSessionStartDateRange,
        ConfirmChangeUserToNonUser,
        OnSetDateError,
        UserGroupDashBoardIconWarning,
        DeleteEmployeeFromUserGroup,
        DeleteEmployeeFromUserGroupNoRecords,
        PersonalIDRequired,
        PINSystemErrors,
        DuplicateRecord,
        SelectionOfOneCheckboxRequired
    }

    public enum SystemEventLogTypes : long
    {
        AggregateSettingsChange = 10025118,
        SecurityPolicyChange = 10025119,
        FlexibleFormUNITemplateChange = 10025120,
        FlexibleFormDeterminantChange = 10025121,
        ReferenceTableChange = 10025122,
        MatrixChange = 10025123,

        // Human Active Surveillance Campaign
        HumanActiveSurveillanceCampaignStatusWasChangedAtYourSite = 10025503,

        HumanActiveSurveillanceCampaignStatusWasChangedAtAnotherSite = 10025504,
        NewHumanActiveSurveillanceCampaignWasCreatedAtYourSite = 10025501,
        NewHumanActiveSurveillanceCampaignWasCreatedAtAnotherSite = 10025502,

        // Human Active Surveillance Session
        NewHumanActiveSurveillanceSessionWasCreatedAtYourSite = 10025505,

        NewHumanActiveSurveillanceSessionWasCreatedAtAnotherSite = 10025506,
        ClosedHumanActiveSurveillanceSessionWasReopenedAtYourSite = 10025507,
        ClosedHumanActiveSurveillanceSessionWasReopenedAtAnotherSite = 10025508,
        NewLaboratoryTestResultForHumanActiveSurveillanceSessionWasRegisteredAtYourSite = 10025509,
        NewLaboratoryTestResultForHumanActiveSurveillanceSessionWasRegisteredAtAnotherSite = 10025512,
        LaboratoryTestResultForHumanActiveSurveillanceSessionWasAmendedAtYourSite = 10025510,
        LaboratoryTestResultForHumanActiveSurveillanceSessionWasAmendedAtAnotherSite = 10025511,

        // Human Disease Report
        NewHumanDiseaseReportWasCreatedAtYourSite = 10025037,

        NewHumanDiseaseReportWasCreatedAtAnotherSite = 10025038,
        HumanDiseaseReportClassificationWasChangedAtYourSite = 10025041,
        HumanDiseaseReportClassificationWasChangedAtAnotherSite = 10025042,
        NewLaboratoryTestResultForHumanDiseaseReportWasRegisteredAtYourSite = 10025554,
        NewLaboratoryTestResultForHumanDiseaseReportWasRegisteredAtAnotherSite = 10025547,
        LaboratoryTestResultForHumanDiseaseReportWasAmendedAtYourSite = 10025045,
        LaboratoryTestResultForHumanDiseaseReportWasAmendedAtAnotherSite = 10025046,
        LaboratoryTestResultForHumanDiseaseReportWasInterpretedAtYourSite = 10025517,
        LaboratoryTestResultForHumanDiseaseReportWasInterpretedAtAnotherSite = 10025518,
        ClosedHumanDiseaseReportWasReopenedAtYourSite = 10025047,
        ClosedHumanDiseaseReportWasReopenedAtAnotherSite = 10025048,

        // Human Aggregate Disease Report
        HumanAggregateDiseaseReportWasChangedAtYourSite = 10025099,

        HumanAggregateDiseaseReportWasChangedAtAnotherSite = 10025100,
        NewHumanAggregateDiseaseReportWasCreatedAtAnotherSite = 10025098,
        NewHumanAggregateDiseaseReportWasCreatedAtYourSite = 10025097,

        // Human ILI Aggregate Form
        NewILIAggregateFormWasCreatedAtYourSite = 10025129,

        NewILIAggregateFormWasCreatedAtAnotherSite = 10025130,

        // Vector Surveillance Session
        NewVectorSurveillanceSessionWasCreatedAtYourSite = 10025075,

        NewVectorSurveillanceSessionWasCreatedAtAnotherSite = 10025076,
        NewDiseaseForVectorSurveillanceSessionWasDetectedAtYourSite = 10025077,
        NewDiseaseForVectorSurveillanceSessionWasDetectedAtAnotherSite = 10025078,
        NewFieldTestResultForVectorSurveillanceSessionWasRegisteredAtYourSite = 10025079,
        NewFieldTestResultForVectorSurveillanceSessionWasRegisteredAtAnotherSite = 10025080,
        NewLaboratoryTestResultForVectorSurveillanceSessionWasRegisteredAtYourSite = 10025081,
        NewLaboratoryTestResultForVectorSurveillanceSessionWasRegisteredAtAnotherSite = 10025082,
        LaboratoryTestResultForVectorSurveillanceSessionWasAmendedAtYourSite = 10025083,
        LaboratoryTestResultForVectorSurveillanceSessionWasAmendedAtAnotherSite = 10025084,

        // Veterinary Aggregate Disease Report
        NewVeterinaryAggregateDiseaseReportWasCreatedAtAnotherSite = 10025102,

        NewVeterinaryAggregateDiseaseReportWasCreatedAtYourSite = 10025101,
        VeterinaryAggregateDiseaseReportWasChangedAtAnotherSite = 10025104,
        VeterinaryAggregateDiseaseReportWasChangedAtYourSite = 10025103,

        // Veterinary Aggregate Action Report
        NewVeterinaryAggregateActionWasCreatedAtAnotherSite = 10025106,

        NewVeterinaryAggregateActionWasCreatedAtYourSite = 10025105,
        VeterinaryAggregateActionWasChangedAtAnotherSite = 10025108,
        VeterinaryAggregateActionWasChangedAtYourSite = 10025107,

        // Veterinary Active Surveillance Campaign
        NewVeterinaryActiveSurveillanceCampaignWasCreatedAtYourSite = 10025085,

        NewVeterinaryActiveSurveillanceCampaignWasCreatedAtAnotherSite = 10025086,
        VeterinaryActiveSurveillanceCampaignWasChangedAtYourSite = 10025089,
        VeterinaryActiveSurveillanceCampaignWasChangedAtAnotherSite = 10025090,

        // Veterinary Active Surveillance Session
        NewVeterinaryActiveSurveillanceSessionWasCreatedAtYourSite = 10025087,

        NewVeterinaryActiveSurveillanceSessionWasCreatedAtAnotherSite = 10025088,
        ClosedVeterinaryActiveSurveillanceSessionWasReopenedAtAnotherSite = 10025092,
        ClosedVeterinaryActiveSurveillanceSessionWasReopenedAtYourSite = 10025091,
        NewLaboratoryTestResultForVeterinaryActiveSurveillanceSessionWasRegisteredAtAnotherSite = 10025549,
        NewLaboratoryTestResultForVeterinaryActiveSurveillanceSessionWasRegisteredAtYourSite = 10025550,
        LaboratoryTestResultForVeterinaryActiveSurveillanceSessionWasAmendedAtAnotherSite = 10025096,
        LaboratoryTestResultForVeterinaryActiveSurveillanceSessionWasAmendedAtYourSite = 10025095,
        LaboratoryTestResultForVeterinaryActiveSurveillanceSessionWasInterpretedAtYourSite = 10025513,
        LaboratoryTestResultForVeterinaryActiveSurveillanceSessionWasInterpretedAtAnotherSite = 10025514,

        // Veterinary Disease Report
        ClosedVeterinaryDiseaseReportWasReopenedAtAnotherSite = 10025074,

        ClosedVeterinaryDiseaseReportWasReopenedAtYourSite = 10025073,
        LaboratoryTestResultForVeterinaryDiseaseReportWasAmendedAtAnotherSite = 10025072,
        LaboratoryTestResultForVeterinaryDiseaseReportWasAmendedAtYourSite = 10025071,
        NewFieldTestResultForVeterinaryDiseaseReportWasRegisteredAtAnotherSite = 10025068,
        NewFieldTestResultForVeterinaryDiseaseReportWasRegisteredAtYourSite = 10025067,
        LaboratoryTestResultForVeterinaryDiseaseReportWasInterpretedAtYourSite = 10025519,
        LaboratoryTestResultForVeterinaryDiseaseReportWasInterpretedAtAnotherSite = 10025520,
        NewLaboratoryTestResultForVeterinaryDiseaseReportWasRegisteredAtAnotherSite = 10025526,
        NewLaboratoryTestResultForVeterinaryDiseaseReportWasRegisteredAtYourSite = 10025525,
        NewVeterinaryDiseaseReportWasCreatedAtAnotherSite = 10025062,
        NewVeterinaryDiseaseReportWasCreatedAtYourSite = 10025061,
        VeterinaryDiseaseReportClassificationWasChangedAtAnotherSite = 10025066,
        VeterinaryDiseaseReportClassificationWasChangedAtYourSite = 10025065,

        // Outbreak Session
        NewOutbreakSessionWasCreatedAtYourSite = 10025049,

        NewOutbreakSessionWasCreatedAtAnotherSite = 10025050,
        NewHumanDiseaseReportWasAddedToOutbreakSessionAtYourSite = 10025051,
        NewHumanDiseaseReportWasAddedToOutbreakSessionAtAnotherSite = 10025052,
        NewVeterinaryDiseaseReportWasAddedToOutbreakSessionAtYourSite = 10025053,
        NewVeterinaryDiseaseReportWasAddedToOutbreakSessionAtAnotherSite = 10025054,
        NewVectorSurveillanceSessionWasAddedToOutbreakSessionAtYourSite = 10025055,
        NewVectorSurveillanceSessionWasAddedToOutbreakSessionAtAnotherSite = 10025056,
        OutbreakSessionStatusWasChangedAtYourSite = 10025057,
        OutbreakSessionStatusWasChangedAtAnotherSite = 10025058,
        OutbreakSessionPrimaryCaseWasChangedAtYourSite = 10025059,
        OutbreakSessionPrimaryCaseWasChangedAtAnotherSite = 10025060,
        HumanOutbreakCaseClassificationWasChangedAtYourSite = 10025537,
        HumanOutbreakCaseClassificationWasChangedAtAnotherSite = 10025538,
        VeterinaryOutbreakCaseClassificationWasChangedAtYourSite = 10025563,
        VeterinaryOutbreakCaseClassificationWasChangedAtAnotherSite = 10025564,
        NewLaboratoryTestResultForVeterinaryOutbreakCaseWasRegisteredAtYourSite = 10025069,
        NewLaboratoryTestResultForVeterinaryOutbreakCaseWasRegisteredAtAnotherSite = 10025070,
        LaboratoryTestResultForVeterinaryOutbreakCaseWasAmendedAtYourSite = 10025527,
        LaboratoryTestResultForVeterinaryOutbreakCaseWasAmendedAtAnotherSite = 10025528,
        LaboratoryTestResultForVeterinaryOutbreakCaseWasInterpretedAtYourSite = 10025529,
        LaboratoryTestResultForVeterinaryOutbreakCaseWasInterpretedAtAnotherSite = 10025530,
        NewLaboratoryTestResultForHumanOutbreakCaseWasRegisteredAtYourSite = 10025539,
        NewLaboratoryTestResultForHumanOutbreakCaseWasRegisteredAtAnotherSite = 10025540,

        // Laboratory Actions
        LaboratorySampleTransferredIn = 10025125,

        TestResultEnteredForLaboratorySampleTransferredOut = 10025142,
        LaboratorySampleTransferredOut = 10025131,
        LaboratoryTestResultRejected = 10056062
    }

    public enum Modules : long
    {
        Human = 10508001,
        Livestock = 10508002,
        Avian = 10508003,
        Vector = 10508004,
        All = 10508005,
        Laboratory = 10508006,
        Veterinary = 10508007
    }

    public enum ReferenceTypes
    {
        AccessionCondition = 19000110,
        AccessoryCode = 19000040,
        AgeGroups = 19000146,
        ASSessionAction = 19000127,
        BoxSize = 19000512,
        CaseProgressStatus = 19000111,
        LaboratoryTestResult = 19000096,
        LaboratoryTestName = 19000097,
        LaboratoryTestStatus = 19000001,
        LegalForm = 19000522,
        MainFormOfActivity = 19000523,
        Occupation = 19000061,
        OrganizationType = 19000504,
        OwnershipType = 19000521,
        PensideTestName = 19000104,
        PensideTestResult = 19000105,
        ReportSessionType = 19000012,
        SampleStatus = 19000015,
        SampleType = 19000087,
        SiteType = 19000085,
        SiteGroupType = 19000524,
        SpeciesList = 19000086,
        StatisticalAgeGroup = 19000145,
        Storage = 19000092,
        Subdivision = 19000093,
        SurveillanceType = 19000144,
        TestCategory = 19000095,
        VaccinationRoute = 19000098,
        Vaccination = 19000099,
        CollectionMethod = 19000135,
        TestResults = 19000096,
        Position = 19000073,
        ReportTypes = 19000133,
        YesNoValues = 19000100,
        CaseOutcomes = 19000064,
        NonNotifiableDiagnosis = 19000149,
        HumanCaseCaseClassification = 19000080
    }

    public enum ApplicationActions : int
    {
        None = 0,
        PersonAddHumanDiseaseReport = 1,
        PersonAddOutbreakCaseReport = 2,
        PersonPreviewHumanDiseaseReport = 3,
        PersonPreviewOutbreakCaseReport = 4,
        PersonPreviewFarm = 5,
        FarmAddOutbreakCase = 6,
        FarmAddAvianVeterinaryDiseaseReport = 7,
        FarmAddLivestockVeterinaryDiseaseReport = 8,
        DashboardEditEmployee = 9,
        DashboardAddHumanDiseaseReport = 10,
        DashboardEditHumanDiseaseReport = 11,
        DashboardEditVeterinaryDiseaseReport = 12,
        SearchDiseaseReports = 13,
        Dashboard = 14,
        Samples = 15
    }

    public enum ApplicationSessions : int
    {
        EditEmployeeID = 1
    }

    public enum LaboratoryModuleActions : int
    {
        None = 0,
        AccessionIn = 1,
        GroupAccessionIn = 2,
        TransferOut = 3,
        AssignTest = 4,
        RegisterNewSample = 5,
        SetTestResults = 6,
        ValidateTestResult = 7,
        AmendTestResult = 8,
        SampleDestruction = 9,
        DestroyByIncineration = 10,
        DestroyByAutoclave = 11,
        ApproveDestruction = 12,
        RejectDestruction = 13,
        LabRecordDeletion = 14,
        DeleteSample = 15,
        DeleteTest = 16,
        ApproveDeletion = 17,
        RejectDeletion = 18,
        PaperForms = 19,
        SampleReport = 20,
        TestReport = 21,
        TransferReport = 22,
        DestructionReport = 23,
        PrintBarcode = 24,
        CreateAliquot = 25,
        EditSample = 26,
        Reference = 27,
        SearchPerson = 28,
        EditTest = 29,
        CreateDerivative = 30,
        AccessionInForm = 31,
        RestoreSample = 32,
        SetTestResultsForSample = 33,
        SetTestResultsForTest = 34,
        SetTestResultsForTramsfer = 35,
        AdvancedSearch = 36,
        EditTransfer = 37,
        SampleDestructionApprovals = 38,
        SampleRecordDeletionApprovals = 39,
        ValidationApprovals = 40,
        EditBatch = 41,
        TestRecordDeletionApprovals = 42,
        CreateBatch = 43
    }

    public enum SelectModes : int
    {
        Read = 0,
        FarmOwner = 1,
        AvianDiseaseReport = 3,
        LivestockDiseaseReport = 4,
        Outbreak = 5,
        VeterinarySession = 6,
        Selection = 7,
        View = 8,
        Label = 9,
        Human = 10,
        RecordDataSelection = 11
    }

    public enum ModuleTypes : int
    {
        Human = 1,
        Veterinary = 2,
        Laboratory = 3,
        Outbreak = 4,
        Administration = 5
    }

    public enum AccessionConditionTypes : long
    {
        AcceptedInGoodCondition = 10108001,
        AcceptedInPoorCondition = 10108002,
        Rejected = 10108003
    }

    public enum DestructionMethodTypes : long
    {
        Incineration = 12675220000000,
        Autoclave = 12675230000000
    }

    /// <summary>
    /// Sample types that are Base Reference Type 19000087
    /// Only the Unknown type is really needed here because
    /// it is the only 'system' sample type.
    /// </summary>
    public enum SampleTypes : long
    {
        Unknown = 10320001
    }

    public enum SampleStatusTypes : long
    {
        MarkedForDeletion = 10015002,
        MarkedForDestruction = 10015003,
        InRepository = 10015007,
        Deleted = 10015008,
        Destroyed = 10015009,
        TransferredOut = 10015010
    }

    public enum SampleKindTypes : long
    {
        Aliquot = 12675410000000,
        Derivative = 12675420000000,
        TransferredIn = 12675430000000
    }

    public enum TestResultTypes : long
    {
        Indeterminate = 9848930000000,
        Negative = 9848980000000,
        Positive = 9849050000000
    }

    public enum TestCategoryTypes : long
    {
        Confirmatory = 10095001,
        Procedural = 10095002,
        Presumptive = 10095003
    }

    public enum TestStatusTypes : long
    {
        Final = 10001001,
        Declined = 10001002,
        InProgress = 10001003,
        Preliminary = 10001004,
        NotStarted = 10001005,
        Amended = 10001006,
        Deleted = 10001007,
        MarkedForDeletion = 10001008
    }

    public enum BatchTestStatusTypes : long
    {
        InProgress = 10001003,
        Closed = 10001001
    }

    public enum InterpretedStatusTypes : long
    {
        RuledIn = 10104001,
        RuledOut = 10104002
    }

    public enum VeterinaryDiseaseReportStatusTypes : long
    {
        InProcess = 10109001,
        Closed = 10109002
    }

    public enum DiseaseReportLogStatusTypes : long
    {
        Open = 10103001,
        Closed = 10103002
    }

    public enum TransferStatusTypes : long
    {
        Final = 10001001,
        Declined = 10001002,
        InProgress = 10001003,
        Preliminary = 10001004,
        NotStarted = 10001005,
        Amended = 10001006,
        MarkedForDeletion = 10001007
    }

    public enum ReportSessionTypes : int
    {
        Avian = 10012004,
        Human = 10012001,
        Livestock = 10012003,
        Vector = 10012006,
        Veterinary = 10012005
    }

    public enum YesNoUnknown : long
    {
        Yes = 10100001,
        No = 10100002,
        Unknown = 10100003
    }

    public enum OrganizationTypes : int
    {
        Laboratory = 10504001,
        Hospital = 10504002,
        Other = 10504003
    }

    public enum SubdivisionTypes : long
    {
        Box = 39890000000,
        Shelf = 39900000000,
        Rack = 10093001
    }

    public enum LaboratoryActionsRequested
    {
        SampleDeletion,
        SampleDestruction,
        Validation,
        Unknown
    }

    public enum SettlementTypes : long
    {
        Settlement = 730120000000,
        Town = 730130000000,
        Village = 730140000000
    }

    public enum CampaignStatusTypes : long
    {
        NewStatus = 10140000,
        Open = 10140001,
        Closed = 10140002
    }

    public enum MonitoringSessionStatusTypes : long
    {
        Open = 10160000,
        Closed = 10160001
    }

    public enum DiagnosisGroups : long
    {
        Anthrax = 51529030000000,
        Plague = 51529040000000,
        Tularemia = 51529050000000
    }

    [Obsolete("This enum is being deprecated, instead use EIDSS.Client.Enumerations.PermissionLevelEnum")]
    public enum PermissionLevelTypes : long
    {
        Create = 10059001,
        Delete = 10059002,
        Read = 10059003,
        Write = 10059004,
        Execute = 10059005,
        AccessToPersonalData = 10059006,
        AccessToGenderAndAgeData = 10059007
    }

    public enum DiseaseAccessPermissionTypes : int
    {
        Allow = 2,
        Deny = 1
    }

    public enum UserAccessPermissionTypes : int
    {
        Allow = 10515001,
        Deny = 10515002,
        None = 10515003
    }

    public enum ReportTypes : long
    {
        Active = 4578940000001,
        Passive = 4578940000002
    }

    public enum AggregateDiseaseReportTypes : long
    {
        HumanAggregateDiseaseReport = 10102001,
        VeterinaryAggregateDiseaseReport = 10102002,
        VeterinaryAggregateActionReport = 10102003
    }

    public enum ReportFormTypes : long
    {
        HumanWeeklyReportForm = 10506188,
        HumanWeeklyReportFormSummary = 10506189
    }

    public enum AdministrativeUnitTypes : long
    {
        Country = 10089001,
        Rayon = 10089002,
        Region = 10089003,
        Settlement = 10089004,
        Organization = 10089005
    }

    public enum GISAdministrativeUnitTypes : long
    {
        Country = 19000001,
        Rayon = 19000003,
        Region = 19000002,
        Settlement = 19000004,
    }

    public enum GISAdministrativeLevels : long
    {
        AdminLevel0 = 19000001,
        AdminLevel1 = 19000003,
        AdminLevel2 = 19000002,
        AdminLevel3 = 19000004
    }

    public enum TimePeriodTypes : long
    {
        Month = 10091001,
        Day = 10091002,
        Quarter = 10091003,
        Week = 10091004,
        Year = 10091005
    }

    public enum FlexibleFormTypes : long
    {
        LaboratoryBatchTest = 10034019,
        VeterinaryAggregate = 10034021,
        VeterinarySanitary = 10034022,
        VeterinaryDiagnostic = 10034023,
        VeterinaryProphylactic = 10034024,
        AvianFarmEpidemiologicalInfo = 10034007,
        AvianSpeciesClinicalInvestigation = 10034008,
        LivestockAnimalClinicalSigns = 10034013,
        LivestockControlMeasures = 10034014,
        LivestockFarmFarmEpidemiologicalInfo = 10034015,
        LivestockSpeciesClinicalInvestigation = 10034016,
        HumanAggregate = 10034012,
        VectorSpecificData = 10034025
    }

    public enum FlexibleFormParameterTypes : long
    {
        DateType = 10071029,
        DateTimeType = 10071030,
        NumericNatural = 10071059,
        NumericPositive = 10071060,
        NumericInteger = 10071061,
        StringType = 10071045,
        YesNoUnknown = 217140000000
    }

    public enum FarmTypes : long
    {
        Both = 10040001,
        Avian = 10040003,
        Livestock = 10040007
    }

    public enum DiseaseUsingTypes : long
    {
        Standard = 10020001,
        Aggregate = 10020002
    }

    public enum SourceSystemNames : long
    {
        EIDSS7 = 10519001,
        EIDSS61 = 10519002,
        EIDSS7ODK = 10519003,
        HIMS = 10519004,
        LIMS = 10519005
    }

    /// <summary>
    /// Used on the organization lookup for dropdowns and listboxes (non-grid related searches).
    /// </summary>
    public enum OrganizationSiteAssociations : int
    {
        OrganizationWithSite = 0,
        OrganizationWithNoSite = 1,
        OrganizationsWithOrWithoutSite = 2
    }

    public enum SiteTypes : long
    {
        CentralDataRepository = 10085001,
        SecondLevel = 10085002,
        GeneralDataRepository = 10085003,
        MORU = 10085004,
        PACS = 10085005,
        ProxyEMS = 10085006,
        ThirdLevel = 10085007
    }

    public enum SiteGroupTypes : long
    {
        Bordering = 10524000,
        NonBordering = 10524001
    }

    public enum CitizenshipTypes : long
    {
        American = 10054237,
        Armenian = 10054012,
        Azerbaijani = 10054016,
        Georgian = 10054082,
        Iraqi = 10054106,
        Jordanian = 10054114,
        Kazakhstani = 10054115,
        Russian = 10054183,
        Thai = 10054221,
        Ukrainian = 10054233
    }

    public enum Countries : long
    {
        Azerbaijan = 170000000,
        Armenia = 80000000,
        Georgia = 780000000,
        Iraq = 1050000000,
        Jordan = 1110000000,
        Kazakhstan = 1240000000,
        Russia = 1880000000,
        Thailand = 2150000000,
        Ukraine = 2260000000,
        USA = 2340000000
    }

    public enum FlexFormType : System.Int64
    {
        HumanDiseaseQuestionnaire = 10034011,
        HumanDiseaseClinicalSymptoms = 10034010,
        LivestockDiseaseQuestionnaire = 10034015,
        AvianDiseaseQuestionnaire = 10034007,
        HumanCaseMonitoring = 10034504,
        HumanContactTracing = 10034507,
        AvianCaseMonitoring = 10034506,
        AvianContactTracing = 10034509,
        LivestockCaseMonitoring = 10034505,
        LivestockContactTracing = 10034508,
        VectorCaseQuestionnaire = 6,
        VectorCaseMonitoring = 7,
        VectorContactTracing = 8,
        HumanCaseQuestionnaire = 10034501,
        LivestockCaseQuestionnaire = 10034502,
        AvianCaseQuestionnaire = 10034503
    }

    public enum FlexFormCategory
    {
        CaseMonitoring,
        ContactTracing,
        CaseQuestionnaire,
        Clinical
    }

    public enum VeterinaryDiseaseReportTypes : long
    {
        Avian = 10012004,
        Livestock = 10012003
    }

    public enum EmployeeCategory : long
    {
        User = 10526001,
        NonUser = 10526002
    }

    public enum ActorTypes : long
    {
        Employee = 10023002,
        EmployeeGroup = 10023001,
        Site = 3,
        SiteGroup = 4
    }

    public enum SearchMethod : long
    {
        ByAttribute = 10529000,
        ByIdentityDocument = 10529001,
        ByPIN = 10529002
    }

    public enum DocumentType : long
    {
        Passport = 10530000,
        IDCardForAdultResident = 10530001,
        IDCardForChildResident = 10530002,
        TemporaryResidencePermit = 10530003,
        PermanentResidencePermit = 10530004,
        BirthCertificate = 10530005
    }

    public enum RowStatusTypes : int
    {
        Active = 0,
        Inactive = 1
    }

    public enum AdministrativeLevelReferenceIds : long
    {
        AdminLevel0Id = 10003001,
        AdminLevel1Id = 10003003,
        AdminLevel2Id = 10003002,
        AdminLevel3Id = 10003004,
    }

    public enum VectorSurveillanceSessionStatusIds : long
    {
        InProcess = 10310001,
        Closed = 10310002
    }

    public enum MenuEnum : long
    {
        DashBoard = 10506219
    }
}