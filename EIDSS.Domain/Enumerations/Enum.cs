namespace EIDSS.Domain.Enumerations
{
    public enum AccessionConditionTypeEnum : long
    {
        AcceptedInGoodCondition = 10108001,
        AcceptedInPoorCondition = 10108002,
        Rejected = 10108003,
        Unaccessioned = 0
    }

    public enum AccessoryCodeEnum
    {
        None = 0,
        Human = 2,
        Exophyte = 4,
        Plant = 8,
        Soil = 16,
        Livestock = 32,
        AS = 34,
        Avian = 64,
        AvianAndLivestock = 96,
        Outbreak = 98,
        Vector = 128,
        HumanAvianLivestockAndVector = 226,
        Syndromic = 256,
        All = 510
    }

    public enum ActorTypeEnum : long
    {
        Employee = 10023002,
        EmployeeGroup = 10023001,
        Site = 3,
        SiteGroup = 4
    }

    public enum BaseReferenceTypeEnum
    {
        AccessionCondition = 19000110,
        AccessoryCode = 19000040,
        AgeGroups = 19000146,
        ASSessionAction = 19000127,
        BoxSize = 19000512,
        CaseProgressStatus = 19000111,
        Disease = 19000019,
        ReportDiseaseGroup = 19000130,
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
        Storage = 19000092,
        Subdivision = 19000093,
        SurveillanceType = 19000144,
        TestCategory = 19000095,
        VaccinationRoute = 19000098,
        Vaccination = 19000099,
        CollectionMethod = 19000135,
        Position = 19000073,
        ReportTypes = 19000133,
        YesNoValues = 19000100,
        CaseOutcomes = 19000064,
        NonNotifiableDiagnosis = 19000149,
        Language = 19000049,
        AgeType = 19000042
    }

    public enum BatchTestStatusTypeEnum : long
    {
        InProgress = 10001003,
        Closed = 10001001
    }

    public enum CaseLogStatusTypeEnum : long
    {
        Closed = 10103002,
        Open = 10103001
    }

    public enum CaseTypeEnum
    {
        Avian = 10012004,
        Human = 10012001,
        Livestock = 10012003,
        Vector = 10012006,
        Veterinary = 10012005
    }

    public enum MenuIdentifiersEnum
    {
        AvianDiseaseReport = 10506027,
        LivestockDiseaseReport = 10506028
    }

    public enum OutbreakTypeEnum : long
    {
        Human = 10513001,
        Veterinary = 10513002,
        Zoonotic = 10513003
    }

    public enum OutbreakSessionStatus : long
    {
        InProgress = 10063501,
        Closed = 10063502,
        NotAnOutbreak = 13646170001100
    }

    public enum DiseaseReportStatusTypeEnum : long
    {
        InProcess = 10109001,
        Closed = 10109002
    }

    public enum SampleDivisionTypeEnum
    {
        Aliquot = 1,
        Derivative = 2
    }

    public enum FarmTypeEnum : long
    {
        Both = 10040001,
        Avian = 10040003,
        Livestock = 10040007
    }

    public enum FlexFormEditMode : long
    {
        Ordinary = 10068001,
        Mandatory = 10068003
    }

    public enum FlexibleFormParameterTypeEnum : long
    {
        NumericNatural = 10071059,
        NumericPositive = 10071060,
        NumericInteger = 10071061
    }

    public enum FlexibleFormEditorTypeEnum : long
    {
        CheckBox = 10067001,
        DropDown = 10067002,
        DatePicker = 10067003,
        DateTimePicker = 10067004,
        TextArea = 10067006,
        TextBox = 10067008,
        Numeric = 10067009,
        TextBoxTotalField = 10067010,
        Statement = 10067012,
        TextBoxSummingField = 10067011,
        RadioButtonList = 217210000000,
        Empty = 217190000000
    }

    public enum FlexibleFormTypeEnum : long
    {
        LaboratoryTestRun = 10034018,
        LaboratoryBatchTest = 10034019,
        VeterinaryAggregate = 10034021,
        VeterinarySanitary = 10034022,
        VeterinaryDiagnostic = 10034023,
        VeterinaryProphylactic = 10034024,
        VectorSpecificData = 10034025,
        AvianFarmEpidemiologicalInfo = 10034007,
        AvianSpeciesClinicalInvestigation = 10034008,
        LivestockAnimalClinicalSigns = 10034013,
        LivestockControlMeasures = 10034014,
        LivestockFarmFarmEpidemiologicalInfo = 10034015,
        LivestockSpeciesClinicalInvestigation = 10034016,
        HumanClinicalSigns = 10034010,
        HumanEpiInvestigation = 10034011,
        HumanAggregate = 10034012,
        HumanOutbreakCaseQuestionnaire = 10034501,
        LivestockOutbreakCaseQuestionnaire = 10034502,
        AvianOutbreakCaseQuestionnaire = 10034503,
        HumanOutbreakCaseMonitoring = 10034504,
        LivestockOutbreakCaseMonitoring = 10034505,
        AvianOutbreakCaseMonitoring = 10034506,
        HumanOutbreakCaseContactTracing = 10034507,
        LivestockOutbreakCaseContactTracing = 10034508,
        AvianOutbreakCaseContactTracing = 10034509
    }

    public enum FlexibleFormCheckPointEnum : long
    {
        OnLoad = 10028001,
        OnSaveWithNotify = 10028002,
        OnValueChanged = 10028003,
        OnSaveWithError = 10028004
    }

    public enum FreezerSubdivisionTypeEnum : long
    {
        Box = 39890000000,
        Shelf = 39900000000,
        Rack = 10093001
    }

    public enum InterpretedStatusTypeEnum : long
    {
        RuledIn = 10104001,
        RuledOut = 10104002
    }

    public enum LaboratoryTabEnum
    {
        Samples = 0,
        Testing = 1,
        Transferred = 2,
        MyFavorites = 3,
        Batches = 4,
        Approvals = 5
    }

    public enum NotificationTypeEnum : long
    {
        ReferenceChange = 10056001,
        TestResultsReceived = 10056002,
        ReportDiseaseChange = 10056005,
        ReportStatusChange = 10056006,
        HumanDiseaseReport = 10056008,
        OutbreakReport = 10056011,
        VeterinaryDiseaseReport = 10056012,
        AVR = 10056013,
        SettlementChange = 10056014,
        VeterinaryDiseaseReportClassificationChange = 10056023,
        VeterinaryAggregateDiseaseReportCreate = 10056041,
        VeterinaryAggregateDiseaseReportUpdate = 10056042,
        LaboratoryTestResultRejected = 10056062,
        LaboratorySampleTransferIn = 10056051,
        ActiveSurveillanceSessionCreation = 10056034
    }

    public enum ObjectTypeEnum : long
    {
        Disease = 10060001,
        HumanDiseaseReport = 10060006,
        Sample = 10060009,
        Site = 10060011,
        Test = 10060012,
        VeterinaryDiseaseReport = 10060013,
        Outbreak = 10060014,
        HumanActiveSurveillanceSession = 10060054
    }

    public enum OutbreakSpeciesTypeEnum
    {
        Human = 10514001,
        Avian = 10514002,
        Livestock = 10514003,
        Vector = 10514004
    }

    public enum OutbreakContactTypeEnum
    {
        Human = 10516002,
        Veterinary = 10516001
    }

    public enum PatientRelationshipTypeEnum
    {
        Other = 10014001
    }

    public enum OutbreakContactStatusTypeEnum
    {
        Healthy = 10517001,
        ConvertToCase = 10517002
    }

    public enum PermissionLevelEnum
    {
        AccessToGenderAndAgeData = 10059007,
        AccessToPersonalData = 10059006,
        Create = 10059001,
        Delete = 10059002,
        Execute = 10059005,
        Read = 10059003,
        Write = 10059004
    }

    public enum PermissionValueTypeEnum
    {
        Allow = 2,
        Deny = 1
    }


    public enum PageActions
    {
        Delete = 0,
        Add = 1,
        Edit = 2
    }

    public enum PersonalIDTypeEnum : long
    {
        Unknown = 51577280000000,
        PIN = 58010200000000
    }

    public enum ReportOrSessionTypeEnum : long
    {
        Unknown = 10502003,
        HumanActiveSurveillanceSession = 10502001,
        HumanDiseaseReport = 10502004,
        HumanOutbreakCase = 10502005,
        VectorSurveillanceSession = 10502008,
        VeterinaryAvianActiveSurveillanceSession = 10502002,
        VeterinaryDiseaseReport = 10502006,
        VeterinaryOutbreakCase = 10502007,
        VeterinaryLivestockActiveSurveillanceSession = 10502009
    }

    public enum ReportTypeEnum
    {
        LaboratorySampleDetails = 1,
        LaboratoryTestDetails = 2,
        LaboratoryTransferDetails = 3,
        LaboratorySampleAccession = 4,
        LaboratorySampleDestruction = 5
    }

    public enum RowActionTypeEnum
    {
        Read = 0,
        Insert = 1,
        Update = 2,
        Delete = 3,
        Accession = 4,
        InsertAccession = 5,
        InsertAliquotDerivative = 6,
        InsertTransfer = 7,
        AccessionUpdateTransferOut = 8,
        RejectUpdateTransferOut = 9,
        SampleDestruction = 10,
        NarrowSearchCriteria = 99
    }

    public enum RowStatusTypeEnum
    {
        Active = 0,
        Inactive = 1
    }

    public enum SampleKindTypeEnum : long
    {
        Aliquot = 12675410000000,
        Derivative = 12675420000000,
        TransferredIn = 12675430000000
    }

    public enum SampleStatusTypeEnum : long
    {
        MarkedForDeletion = 10015002,
        MarkedForDestruction = 10015003,
        InRepository = 10015007,
        Deleted = 10015008,
        Destroyed = 10015009,
        TransferredOut = 10015010
    }

    public enum SiteAlertTypeEnum : long
    {
        Site = 10536001,
        Originator = 10536002,
        AllSites = 10536003
    }

    public enum SurveillanceTypeEnum : long
    {
        Active = 4578940000001,
        Both = 50815490000000,
        Passive = 4578940000002
    }

    public enum TestCategoryTypeEnum : long
    {
        Confirmatory = 10095001,
        Procedural = 10095002,
        Presumptive = 10095003
    }

    /// <summary>
    /// Used on the test name to test result configuration matrix.
    /// </summary>
    public enum TestResultRelationTypeEnum : long
    {
        LaboratoryTest = 19000097,
        PensideTest = 190000104
    }

    public enum TestResultTypeEnum : long
    {
        Indeterminate = 9848930000000,
        Negative = 9848980000000,
        Positive = 9849050000000
    }

    public enum TestStatusTypeEnum : long
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

    public enum TransferStatusTypeEnum : long
    {
        Final = 10001001,
        InProgress = 10001003
    }

    public enum YesNoUnknownEnum : long
    {
        Yes = 10100001,
        No = 10100002,
        Unknown = 10100003
    }

    public enum LocationType : long
    {
        None = 0,
        National = 10036005,
        ExactPoint = 10036003,
        RelativePoint = 10036004,
        ForeignAddress = 10036001
    }

    public enum PersonDeduplicationTabEnum
    {
        Information = 0,
        Address = 1,
        Employment = 2,
    }

    public enum HumanDiseaseReportDeduplicationTabEnum
    {
        Summary = 0,
        Notification = 1,
        Symptoms = 2,
        FacilityDetails = 3,
        AntibioticVaccineHistory = 4,
        Samples = 5,
        Test = 6,
        CaseInvestigation = 7,
        RiskFactors = 8,
        ContactList = 9,
        FinalOutcome = 10
    }

    public enum FarmDeduplicationTabEnum
    {
        FarmDetails = 0,
        AnimalDiseaseReports = 1
    }

    public enum VeterinaryDiseaseReportDeduplicationTabEnum
    {
        FarmDetails = 0,
        Notification = 1,
        FarmInventory = 2,
        FarmEpiInformation = 3,
        SpeciesInvestigation = 4,
        Vaccination = 5,
        ControlMeasures = 6,
        Animals = 7,
        Samples = 8,
        PensideTests = 9,
        LabTests = 10,
        CaseLog = 11
    }

    public enum AvianDiseaseReportDeduplicationTabEnum
    {
        FarmDetails = 0,
        Notification = 1,
        FarmInventory = 2,
        FarmEpiInformation = 3,
        SpeciesInvestigation = 4,
        Vaccination = 5,
        Samples = 6,
        PensideTests = 7,
        LabTests = 8,
        CaseLog = 9
    }

    public enum LivestockDiseaseReportDeduplicationTabEnum
    {
        FarmDetails = 0,
        Notification = 1,
        HerdEpiClinicalSigns = 2,
        Diagnoses = 3,
        Animals = 4,
        Samples = 5,
        PensideTests = 6,
        LabTests = 7,
        CaseLog = 8
    }

    public enum AggregateActionSummaryTabEnum
    {
        DiagnosticInvestigation = 0,
        ProphylacticMeasure = 1,
        SanitaryAction = 2,
        None = -1
    }
}