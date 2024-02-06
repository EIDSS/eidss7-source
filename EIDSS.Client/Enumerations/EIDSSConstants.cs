using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Domain.Enumerations;

namespace EIDSS.ClientLibrary.Enumerations
{
    public static class EIDSSConstants
    {
        #region Common

        public struct DBRecordStatus
        {
            public const int Active = 0;
            public const int Deleted = 1;
        }

        #endregion Common

        public struct EIDSSModules
        {
            public const string Employee = "Employee";
            public const string Organization = "Organization";
            public const string Settlement = "Settlement";
            public const string StatisticalData = "StatisticalData";
        }

        public struct DatabaseResponses
        {
            public const string Success = "SUCCESS";
            public const string DoesExist = "DOES EXIST";
        }

        public struct Roles
        {
            public const string Administrators = "Administrators";
            public const string ChiefEpidemiologists = "Chief Epidemiologists";
            public const string ChiefVeterinarians = "Chief Veterinarians";
            public const string Entomologists = "Entomologists";
            public const string Epidemiologists = "Epidemiologists";
            public const string ChiefOfLaboratoryHuman = "Chief of Laboratory (Human)";
            public const string ChiefOfLaboratoryVeterinary = "Chief of Laboratory (Veterinary)";
            public const string LaboratoryTechnicianHuman = "Laboratory Technician (Human)";
            public const string LaboratoryTechnicianVeterinary = "Laboratory Technician (Veterinary)";
            public const string Veterinarians = "Veterinarians";
        }

        public struct GlobalConstants
        {
            public const string UserSettings = "UserSettings";
            public const string DefaultLanguage = "DefaultLanguage";
            public const string UserSettingsFilePrefix = "US";

            public const string UserID = "idfUserID";
            public const string PersonID = "idfPerson";
            public const string FirstName = "strFirstName";
            public const string SecondName = "strSecondName";
            public const string FamilyName = "strFamilyName";
            public const string Institution = "idfInstitution";
            public const string UserName = "strUserName";
            public const string Organization = "strLoginOrganization";
            public const string Options = "strOptions";
            public const string IdfHumanCase = "idfHumanCase";
            public const string HdfidfHumanActual = "hdfidfHumanActual";
            public const string idfHumanActual = "idfHumanActual";
            public const string NullValue = "NULL";
            public const string MaskValue = "********";
            public const string CustomizationPackageID = "51577430000000";  // TODO:  This needs to be moved to a site/system preference.
        }

        public struct LoggingConstants
        {
            public const string ExceptionWasThrownMessage = " exception was thrown.";
            public const string MissingReferenceDataMessage = "Missing reference data.  Contact data team to resolve.";
            public const string Begin = " begins.";
            public const string Complete = " complete.";
            public const string TerminatedRequiredFieldMissing = " terminated. Required field is missing.";
            public const string TerminatedBadDataEntry = " terminated. Incorrect data entry.";
            public const string FailedCurrentlyExists = " failed. Record currently exists.";
            public const string FailedCurrentlyInUse = " failed. Record currenty in use.";
        }

        public struct SearchPersistenceKeys
        {
            public const string FarmSearchPerformedIndicatorKey = "FarmSearchPerformedIndicator";
            public const string FarmSearchModelKey = "FarmSearchModel";
            public const string PersonSearchPerformedIndicatorKey = "PersonSearchPerformedIndicator";
            public const string PersonSearchModelKey = "PersonSearchModel";
            public const string HumanDiseaseReportSearchPerformedIndicatorKey = "HumanDiseaseReportSearchPerformedIndicator";
            public const string HumanDiseaseReportSearchModelKey = "HumanDiseaseReportSearchModel";
            public const string AvianVeterinaryDiseaseReportSearchPerformedIndicatorKey = "AvianVeterinaryDiseaseReportSearchPerformedIndicator";
            public const string AvianVeterinaryDiseaseReportSearchModelKey = "AvianVeterinaryDiseaseReportSearchModel";
            public const string LivestockVeterinaryDiseaseReportSearchPerformedIndicatorKey = "LivestockVeterinaryDiseaseReportSearchPerformedIndicator";
            public const string LivestockVeterinaryDiseaseReportSearchModelKey = "LivestockVeterinaryDiseaseReportSearchModel";
            public const string AvianVeterinaryCaseSearchPerformedIndicatorKey = "AvianVeterinaryCaseSearchPerformedIndicator";
            public const string AvianVeterinaryCaseSearchModelKey = "AvianVeterinaryCaseSearchModel";
            public const string LivestockVeterinaryCaseSearchPerformedIndicatorKey = "LivestockVeterinaryCaseSearchPerformedIndicator";
            public const string LivestockVeterinaryCaseSearchModelKey = "LivestockVeterinaryCaseSearchModel";
            public const string VectorSurveillanceSessionSearchPerformedIndicatorKey = "VectorSurveillanceSessionSearchPerformedIndicator";
            public const string VectorSurveillanceSessionSearchModelKey = "VectorSurveillanceSessionSearchModel";
            public const string VeterinaryActiveSurveillanceSessionSeachPerformedIndicatorKey = "VeterinaryActiveSurveillanceSessionSeachPerformedIndicator";
            public const string VeterinaryActiveSurveillanceSessionSearchModelKey = "VeterinaryActiveSurveillanceSessionSearchModel";
            public const string VeterinaryActiveSurveillanceCampaignSearchPerformedIndicatorKey = "VetActiveSurveillanceCampaignSearchPerformedIndicator";
            public const string VeterinaryActiveSurveillanceCampaignSearchModelKey = "VetActiveSurveillanceCampaignSearchModel";
            public const string VeterinaryAggregateDiseaseReportSearchPerformedIndicatorKey = "VeterinaryAggregateDideaseReportSearchPerformedIndicatorKey";
            public const string VeterinaryAggregateDiseaseReportSearchModelKey = "VeterinaryAggregateDiseaseReportSearchModelKey";
            public const string VeterinaryAggregateActionsSearchPerformedIndicatorKey = "VeterinaryAggregateActionsSearchPerformedIndicatorKey";
            public const string VeterinaryAggregateActionsSearchModelKey = "VeterinaryAggregateActionsSearchModelKey";
            public const string HumanActiveSurveillanceCampaignSearchPerformedIndicatorKey = "HumanActiveSurveillanceCampaignSearchPerformedIndicator";
            public const string HumanActiveSurveillanceCampaignSearchModelKey = "HumanActiveSurveillanceCampaignSearchModel";
            public const string HumanActiveSurveillanceSessionSeachPerformedIndicatorKey = "HumanActiveSurveillanceSessionSeachPerformedIndicator";
            public const string HumanActiveSurveillanceSessionSearchModelKey = "HumanActiveSurveillanceSessionSearchModel";
            public const string WeeklyReportingFormSearchModelKey = "WeeklyReportingFormSearchModel";
            public const string WeeklyReportingFormSearchPerformedIndicatorKey = "WeeklyReportingFormSearchPerformedIndicator";
            public const string PersonDeduplicationSearchPerformedIndicatorKey = "PersonDeduplicationSearchPerformedIndicator";
            public const string PersonDeduplicationSearchModelKey = "PersonDeduplicationSearchModel";
            public const string FarmDeduplicationSearchPerformedIndicatorKey = "FarmDeduplicationSearchPerformedIndicator";
            public const string FarmDeduplicationSearchModelKey = "FarmDeduplicationSearchModel";
            public const string HumanDiseaseReportDeduplicationSearchPerformedIndicatorKey = "HumanDiseaseReportDeduplicationSearchPerformedIndicator";
            public const string HumanDiseaseReportDeduplicationSearchModelKey = "HumanDiseaseReporyDeduplicationSearchModel";
            public const string AvianDiseaseReportDeduplicationSearchPerformedIndicatorKey = "AvianDiseaseReportDeduplicationSearchPerformedIndicator";
            public const string AvianDiseaseReportDeduplicationSearchModelKey = "AvianDiseaseReporyDeduplicationSearchModel";
            public const string LivestockDiseaseReportDeduplicationSearchPerformedIndicatorKey = "LivestockDiseaseReportDeduplicationSearchPerformedIndicator";
            public const string LivestockDiseaseReportDeduplicationSearchModelKey = "LivestockDiseaseReporyDeduplicationSearchModel";
            public const string DataAuditTransLogSearchModelKey = "DataAuditTransLogSearchModel";
            public const string DataAuditTransLogSearchPerformedIndicatorKey = " DataAuditTransLogSearchPerformedIndicator";
            public const string SecurityEventLogSearchModelKey = "SecurityEventLogSearchModel";
            public const string SecurityEventLogSearchPerformedIndicatorKey = " SecurityEventLogPerformedIndicator";
            public const string LaboratorySamplesAdvancedSearchPerformedIndicatorKey = "LaboratorySamplesAdvancedSearchPerformedIndicator";
            public const string LaboratorySamplesAdvancedSearchModelKey = "LaboratorySamplesAdvancedSearchModel";
            public const string LaboratoryTestingAdvancedSearchPerformedIndicatorKey = "LaboratoryTestingAdvancedSearchPerformedIndicator";
            public const string LaboratoryTestingAdvancedSearchModelKey = "LaboratoryTestingAdvancedSearchModel";
            public const string LaboratoryTransferredAdvancedSearchPerformedIndicatorKey = "LaboratoryTransferredAdvancedSearchPerformedIndicator";
            public const string LaboratoryTransferredAdvancedSearchModelKey = "LaboratoryTransferredAdvancedSearchModel";
            public const string LaboratoryMyFavoritesAdvancedSearchPerformedIndicatorKey = "LaboratoryMyFavoritesAdvancedSearchPerformedIndicator";
            public const string LaboratoryMyFavoritesAdvancedSearchModelKey = "LaboratoryMyFavoritesAdvancedSearchModel";
            public const string LaboratoryBatchesAdvancedSearchPerformedIndicatorKey = "LaboratoryBatchesAdvancedSearchPerformedIndicator";
            public const string LaboratoryBatchesAdvancedSearchModelKey = "LaboratoryBatchesAdvancedSearchModel";
            public const string LaboratoryApprovalsAdvancedSearchPerformedIndicatorKey = "LaboratoryApprovalsAdvancedSearchPerformedIndicator";
            public const string LaboratoryApprovalsAdvancedSearchModelKey = "LaboratoryApprovalsAdvancedSearchModel";
            public const string SystemEventLogSearchModelKey = "SystemEventLogSearchModel";
            public const string SystemEventLogSearchPerformedIndicatorKey = " SystemEventLogPerformedIndicator";
            public const string WHOExportSearchPerformedIndicatorKey = "HumanDiseaseReportSearchPerformedIndicator";
            public const string WHOExportSearchModelKey = "WHOExportViewModel";
        }

        public struct StateKeys
        {
            public const string RefreshIndicator = "RefreshIndicator";
        }

        public struct ExceptionConstants
        {
            public const string NotFound = "Response status code does not indicate success: 404 (Not Found)";
        }

        public enum GISAdministrativeUnitTypes : long
        {
            Country = 19000001,
            Rayon = 19000003,
            Region = 19000002,
            Settlement = 19000004,
        }

        // List from trtHACode
        public struct HACodeList
        {
            public const string None = "None";
            public const string Human = "Human";
            public const string Exophyte = "Exophyte";
            public const string Plant = "Plant";
            public const string Soil = "Soil";
            public const string Livestock = "Livestock";
            public const string Avian = "Avian";
            public const string Vector = "Vector";
            public const string Syndromic = "Syndromic";
            public const string All = "All";

            public const int NoneHACode = 0;
            public const int HumanHACode = 2;
            public const int ExophyteHACode = 4;
            public const int PlantHACode = 8;
            public const int SoilHACode = 16;
            public const int LivestockHACode = 32;
            public const int ASHACode = 34;
            public const int AvianHACode = 64;
            public const int LiveStockAndAvian = 96;
            public const int OutbreakPriorityHACode = 98;
            public const int VectorHACode = 128;
            public const int HumanVectorHACode = 130;
            public const int LivestockVectorHACode = 160;
            public const int HumanLivestockVectorHACode = 162;
            public const int HALVHACode = 226;
            public const int SyndromicHACode = 256;
            public const int AllHACode = 510;
        }

        public struct HACodeBaseReferenceIds
        {
            public const long None = 10040008;
            public const long Human = 10040005;
            public const long Exophyte = 10040004;
            public const long Plant = 10040009;
            public const long Soil = 10040010;
            public const long Livestock = 10040007;
            public const long Avian = 10040003;
            public const long Vector = 10040011;
            public const long Syndromic = 10040012;
            public const long All = 10040001;
        }

        public struct ServiceConstants
        {
            public const string EvaluateHash = "EVALUATEHASH";
            public const string SetContext = "SETCONTEXT";
            public const string AuthenticateUser = "AUTHENTICATE";
            public const string ChangePassword = "CHANGEPASSWORD";
            public const string UpdatePreferences = "UPDATE_SYSTEM_PREFS";
            public const string SecurityPolicyGet = "SECURITYPOLICYGET";
            public const string SecurityPolicySet = "SECURITYPOLICYSET";
            public const string PeersonList = "PERSONLIST";
            public const string PersonGetDetail = "PERSONGETDETAIL";
            public const string OrganizationList = "ORGANIZATIONLIST";
            public const string PositionGetList = "POSITIONLIST";
            public const string PositionGetDetail = "POSITIONDETAIL";
            public const string OrganizationDetail = "ORGANIZATIONDETAIL";
            public const string TownOrVillageList = "TOWNORVILLAGELIST";
        }

        public struct UserAction
        {
            public const string Insert = "I";
            public const string Update = "U";
            public const string Delete = "D";
            public const string Read = "R";
        }

        public struct UserConstants
        {
            public const string idfUserID = "idfUserId";
            public const string FirstName = "FirstName";
            public const string Organization = "Organization";
            public const string UserSite = "UserSite";
            public const string UserName = "UserName";
        }

        public struct SiteAlerts
        {
            public const string ClientUILanguageChanged = "10025001";
            public const string HumanDiseaseCreation = "10025037";
            public const string ILIAggregateCreation = "10025129";
            public const string OutbreakCreated = "10025049";
            public const string VetDiseaseCreated = "10025061";
            public const string VeterinaryDiseaseReportTestResultInterpretation = "10025519";
            public const string VeterinaryDiseaseReportClassificationChange = "10025065";
            public const string ActiveSurviellanceSessionCreated = "10025501";
            public const string VeterinaryCampaignCreation = "10025085";
            public const string VeterinaryCampaignStatusChange = "10025089";
            public const string VeterinarySessionCreation = "10025087";
            public const string VeterinarySessionNewTestResult = "10025093";
            public const string VeterinarySessionTestResultAmendment = "10025095";
            public const string VeterinarySessionTestResultInterpretation = "10025513";
            public const string HumanCampaignCreation = "10025501";
            public const string HumanCampaignStatusChanged = "10025503";
            public const string MatrixChanged = "10025123";
        }

        public struct HumanAggregateCaseMatrixHeadersConstants
        {
            public const string Diagnosis = "Diagnosis";
            public const string ICD10Code = "ICD-10 Code";
            public const string OECODE = "OE CODE";
        }

        public struct EmployeeConstants
        {
            public const string EMPLOYEE_ID = "_id";
            public const string DS_EMPLOYEE_LIST = "dsEmployeeList";
            public const string idfEmployee = "idfEmployee";
            public const string FullName = "employeeFullName";
            public const string EmployeeID = "EmployeeID";
            public const string Status = "Status";
            public const string idfsEmployeeCategory = "EmployeeCategory";
            public const string NonUser = "Non-User";
        }

        public struct LoginConstants
        {
            public const string AccountName = "strAccountName";
            public const string binPassword = "binPassword";
        }

        public struct PersonConstants
        {
            public const string idfPerson = "idfPerson";
            public const string idfsSite = "idfsSite";
            public const string idfInstitution = "idfInstitution";
            public const string UserId = "UserId";
            public const string idfsStaffPosition = "idfsStaffPosition";
        }

        public struct OrganizationConstants
        {
            public const string idfInstitution = "idfInstitution";
            public const string idOffice = "idfOffice";
            public const string OrgName = "name";
            public const string OrgFullName = "FullName";
            public const string strOrganizationID = "strOrganizationID";
            public const string EnglishFullName = "EnglishFullName";
            public const string idfOrganization = "idfOrganization";
            public const string idfLocation = "idfLocation";
            public const string idfsSite = "idfsSite";
            public const string idfsRegion = "idfsRegion";
            public const string idfsRayon = "idfsRayon";
            public const string intHACode = "intHACode";
            public const string OrganizationID = "OrganizationID";
            public const string OrganizationName = "OrganizationName";
            public const string IsDefault = "IsDefault";
            public const string UserGroupID = "UserGroupID";
        }

        public struct DepartmentConstants
        {
            public const string Name = "Name";
            public const string idfDepartment = "idfDepartment";
            public const string DefaultName = "DefaultName";
            public const string User = "User";
            public const string DepartmentId = "DepartmentID";
            public const string DepartmentName = "DepartmentName";
        }

        /// <summary>
        ///     ''' These constants are for table trtReferenceType.
        ///     ''' They are the column values for
        ///     '''
        ///     ''' column idfsReferenceType
        ///     ''' column strReferenceTypeCode
        ///     ''' column strReferenceTypeName
        ///     ''' </summary>
        public struct BaseReferenceConstants
        {
            public const string idfsBaseReference = "idfsBaseReference";
            public const string Name = "Name";

            // trtReferenceType Table - Gets idfsReferenceType matching the value with strReferenceTypeName
            public const string AberrationAnalysisMethod = "Aberration Analysis Method";

            public const string AccessionCondition = "Accession Condition";
            public const string AccessoryList = "Accessory List";
            public const string AccountState = "Account State";
            public const string AdministrativeLevel = "Administrative Level";
            public const string AgeGroups = "Age Groups";
            public const string AggregateCaseType = "Aggregate Case Type";
            public const string AnimalAge = "Animal Age";
            public const string AnimalSex = "Animal Sex";
            public const string AnimalBirdStatus = "Animal/Bird Status";
            public const string ASCampaignStatus = "AS Campaign Status";
            public const string ASCampaignType = "AS Campaign Type";
            public const string ASSessionActionStatus = "AS Session Action Status";
            public const string ASSessionActionType = "AS Session Action Type";
            public const string ASSessionStatus = "AS Session Status";
            public const string ASSpeciesType = "AS Species Type";
            public const string AvianFarmProductionType = "Avian Farm Production Type";
            public const string AvianFarmType = "Avian Farm Type";
            public const string AVRAggregateFunction = "AVR Aggregate Function";
            public const string AVRChartName = "AVR Chart Name";
            public const string AVRChartType = "AVR Chart Type";
            public const string AVRFolderName = "AVR Folder Name";
            public const string AVRGroupDate = "AVR Group Date";
            public const string AVRLayoutDescription = "AVR Layout Description";
            public const string AVRLayoutFieldName = "AVR Layout Field Name";
            public const string AVRLayoutName = "AVR Layout Name";
            public const string AVRMapName = "AVR Map Name";
            public const string AVRQueryDescription = "AVR Query Description";
            public const string AVRQueryName = "AVR Query Name";
            public const string AVRReportName = "AVR Report Name";
            public const string AVRSearchField = "AVR Search Field";
            public const string AVRSearchFieldType = "AVR Search Field Type";
            public const string AVRSearchObject = "AVR Search Object";
            public const string BasicSyndromicSurveillanceAggregateColumns = "Basic Syndromic Surveillance - Aggregate Columns";
            public const string BasicSyndromicSurveillanceMethodofMeasurement = "Basic Syndromic Surveillance - Method of Measurement";
            public const string BasicSyndromicSurveillanceOutcome = "Basic Syndromic Surveillance - Outcome";
            public const string BasicSyndromicSurveillanceTestResult = "Basic Syndromic Surveillance - Test Result";
            public const string BasicSyndromicSurveillanceType = "Basic Syndromic Surveillance - Type";
            public const string Basisofrecord = "Basis of record";
            public const string OutbreakCaseStatus = "Outbreak Case Status";
            public const string CaseClassification = "Case Classification";
            public const string CaseOutcomeList = "Case Outcome List";
            public const string CaseReportType = "Case Report Type";
            public const string CaseStatus = "Case Status";
            public const string CaseType = "Case Type";
            public const string Collectionmethod = "Collection method";
            public const string Collectiontimeperiod = "Collection time period";
            public const string ConfigurationDescription = "Configuration Description";
            public const string ContactPhoneType = "Contact Phone Type";
            public const string CustomReportType = "Custom Report Type";
            public const string DataAuditEventType = "Data Audit Event Type";
            public const string DataAuditObjectType = "Data Audit Object Type";
            public const string DataExportDetailStatus = "Data Export Detail Status";
            public const string DepartmentName = "Department Name";
            public const string DestructionMethod = "Destruction Method";
            public const string DiagnosesGroups = "Diagnoses Groups";
            public const string Diagnosis = "Diagnosis";
            public const string Disease = "Disease";
            public const string DiagnosisUsingType = "Diagnosis Using Type";
            public const string DiagnosticInvestigationList = "Diagnostic Investigation List";
            public const string EmployeeCategory = "Employee Category";
            public const string EmployeeGroupName = "Employee Group Name";
            public const string EmployeePosition = "Employee Position";
            public const string EmployeeType = "Employee Type";
            public const string EventInformationString = "Event Information String";
            public const string EventSubscriptions = "Event Subscriptions";
            public const string EventType = "Event Type";
            public const string FarmGrazingPattern = "Farm Grazing Pattern";
            public const string FarmIntendedUse = "Farm Intended Use";
            public const string FarmMovementPattern = "Farm Movement Pattern";
            public const string FarmOwnershipType = "Farm Ownership Type";
            public const string FarmingSystem = "Farming System";
            public const string FlexibleFormCheckPoint = "Flexible Form Check Point";
            public const string FlexibleFormDecorateElementType = "Flexible Form Decorate Element Type";
            public const string FlexibleFormLabelText = "Flexible Form Label Text";
            public const string FlexibleFormParameterCaption = "Flexible Form Parameter Caption";
            public const string FlexibleFormParameterEditor = "Flexible Form Parameter Editor";
            public const string FlexibleFormParameterMode = "Flexible Form Parameter Mode";
            public const string FlexibleFormParameterTooltip = "Flexible Form Parameter Tooltip";
            public const string FlexibleFormParameterType = "Flexible Form Parameter Type";
            public const string FlexibleFormParameterValue = "Flexible Form Parameter Value";
            public const string FlexibleFormRule = "Flexible Form Rule";
            public const string FlexibleFormRuleAction = "Flexible Form Rule Action";
            public const string FlexibleFormRuleFunction = "Flexible Form Rule Function";
            public const string FlexibleFormRuleMessage = "Flexible Form Rule Message";
            public const string FlexibleFormSection = "Flexible Form Section";
            public const string FlexibleFormTemplate = "Flexible Form Template";
            public const string FlexibleFormType = "Flexible Form Type";
            public const string FreezerBoxSize = "Freezer Box Size";
            public const string FreezerSubdivisionType = "Freezer Subdivision Type";
            public const string GeoLocationType = "Geo Location Type";
            public const string GroundType = "Ground Type";
            public const string HumanAgeType = "Human Age Type";
            public const string HumanGender = "Human Gender";
            public const string HospitalizationStatus = "Patient Location Type";
            public const string Identificationmethod = "Identification method";
            public const string InformationString = "Information String";
            public const string Language = "Language";
            public const string LegalForm = "Legal Form";
            public const string LivestockFarmProductionType = "Livestock Farm Production Type";
            public const string MainFormofActivity = "Main Form of Activity";
            public const string MatrixColumn = "Matrix Column";
            public const string MatrixType = "Matrix Type";
            public const string NationalityList = "Nationality List";
            public const string NonNotifiableDiagnosis = "Non-Notifiable Diagnosis";
            public const string NotificationObjectType = "Notification Object Type";
            public const string NotificationType = "Notification Type";
            public const string NumberingSchemaDocumentType = "Numbering Schema Document Type";
            public const string ObjectType = "Object Type";
            public const string ObjectTypeRelation = "Object Type Relation";
            public const string OccupationType = "Occupation Type";
            public const string OfficeType = "Office Type";
            public const string OrganizationAbbreviation = "Organization Abbreviation";
            public const string OrganizationName = "Organization Name";
            public const string OrganizationType = "Organization Type";
            public const string OutbreakContactStatus = "Outbreak Contact Status";
            public const string OutbreakContactType = "Outbreak Contact Type";
            public const string OutbreakStatus = "Outbreak Status";
            public const string OutbreakSpeciesGroup = "Outbreak Species Group";
            public const string OutbreakUpdatePriority = "Outbreak Update Priority";
            public const string OutbreakType = "Outbreak Type";
            public const string Outcome = "Case Outcome List";
            public const string OwnershipForm = "Ownership Form";
            public const string OutbreakPeriod = "AVR Group Date";
            public const string PartyType = "Party Type";
            public const string PatientContactType = "Patient Contact Type";
            public const string PatientLocationType = "Patient Location Type";
            public const string PatientState = "Patient State";
            public const string PensideTestCategory = "Penside Test Category";
            public const string PensideTestName = "Penside Test Name";
            public const string PensideTestResult = "Penside Test Result";
            public const string PersonIDType = "Person ID Type";
            public const string PersonalIDType = "Personal ID Type";
            public const string ProphylacticMeasureList = "Prophylactic Measure List";
            public const string ReasonforChangedDiagnosis = "Reason for Changed Diagnosis";
            public const string ReasonfornotCollectingSample = "Reason for not Collecting Sample";
            public const string ReferenceTypeName = "Reference Type Name";
            public const string ReportAdditionalText = "Report Additional Text";
            public const string ReportDiagnosisGroup = "Report Diagnosis Group";
            public const string ReportDiseaseGroup = "Report Disease Group";
            public const string ResidentType = "Resident Type";
            public const string ResourceType = "Resource Type";
            public const string RuleInValueforTestValidation = "Rule In Value for Test Validation";
            public const string SampleKind = "Sample Kind";
            public const string SampleStatus = "Sample Status";
            public const string SampleType = "Sample Type";
            public const string SanitaryMeasureList = "Sanitary Measure List";
            public const string SecurityAuditAction = "Security Audit Action";
            public const string SecurityAuditProcessType = "Security Audit Process Type";
            public const string SecurityAuditResult = "Security Audit Result";
            public const string SecurityConfigurationAlphabetName = "Security Configuration Alphabet Name";
            public const string SecurityLevel = "Security Level";
            public const string ReportOrSessionTypeList = "Report/Session Type List";
            public const string SettlementType = "Settlement Type";
            public const string SiteRelationType = "Site Relation Type";
            public const string SiteType = "Site Type";
            public const string SiteGroupType = "Site Group Type";
            public const string SpeciesGroups = "Species Groups";
            public const string SpeciesList = "Species List";
            public const string StatisticalAgeGroups = "Statistical Age Groups";
            public const string StatisticalAreaType = "Statistical Area Type";
            public const string StatisticalDataType = "Statistical Data Type";
            public const string StatisticalPeriodType = "Statistical Period Type";
            public const string StorageType = "Storage Type";
            public const string Surrounding = "Surrounding";
            public const string SystemFunction = "System Function";
            public const string SystemFunctionOperation = "System Function Operation";
            public const string TestCategory = "Test Category";
            public const string TestName = "Test Name";
            public const string TestResult = "Test Result";
            public const string TestStatus = "Test Status";
            public const string RuleInRuleOut = "Rule In Value for Test Validation";
            public const string VaccinationRouteList = "Vaccination Route List";
            public const string VaccinationType = "Vaccination Type";
            public const string VectorSubType = "Vector Sub Type";
            public const string VectorSurveillanceSessionStatus = "Vector Surveillance Session Status";
            public const string VectorType = "Vector Type";
            public const string VetCaseLogStatus = "Vet Case Log Status";
            public const string YesNoValueList = "Yes/No Value List";
            public const string BaseRefTbl = "BaseRef";
            public const string SearchMethod = "Search Method";
            public const string DocumentType = "Document Type";
        }

        public struct AggregateValue
        {
            public const string Human = "10102001";
            public const string Veterinary = "10102002";
            public const string TimeInterval = "idfsTimeInterval";
            public const string CaseType = "idfsAggrCaseType";
            public const string Region = "idfsAdministrativeUnit";
            public const string CaseID = "idfAggrCase";
            public const string StrSearchCaseID = "strCaseID";
            public const string Standard = "10020001";
            public const string VeterinaryAction = "10102003";
        }

        public struct ReportFormValue
        {
            public const long Diagnosis = 9888840000000;
        }

        public struct ASSpeciesType
        {
            public const long Avian = 10538000;
            public const long Livestock = 10538001;
        }

        public struct YesNoValueList
        {
            public const string Yes = "10100001";
            public const string No = "10100002";
            public const string Unknown = "10100003";
            public const string ReferenceTypeId = "19000100";
        }

        public struct YesNoValues
        {
            public const long Yes = 10100001;
            public const long No = 10100002;
            public const long Unknown = 10100003;
            public const long ReferenceTypeId = 19000100;
        }

        public struct OutbreakSpeciesGroup
        {
            public const long Human = 10514001;
            public const long Avian = 10514002;
            public const long Livestock = 10514003;
            public const long Vector = 10514004;
        }

        public struct GeoLocationTypes
        {
            public const long ExactPoint = 10036003;
            public const long RelativePoint = 10036004;
            public const long Foreign = 10036001;
            public const long National = 10036005;
        }

        public struct AggregateSetting
        {
            public const string CaseTypes = "19000102";
            public const string AdminLevels = "19000089";
            public const string MinimumTimeInterVal = "19000091";
        }

        public struct CampaignCategory
        {
            public const string Human = "10501001";
            public const string Veterinary = "10501002";
        }

        public struct UsingType
        {
            public const long StandardCaseType = 10020001;
            public const long AggregateCaseType = 10020002;
        }

        public struct SessionCategory
        {
            public const long Human = 10502001;
            public const long Veterinary = 10502002;
        }

        public struct ReportSessionCategoryTypeNames
        {
            public const string Human = "Human";
            public const string Veterinary = "Veterinary";
        }

        public struct PositionConstants
        {
            public const string PositionId = "PositionId";
            public const string PositionName = "PositionName";
            public const string idfPositionId = "idfPositionId";
        }

        public struct CountryConstants
        {
            public const string CountryID = "idfsCountry";
            public const string CountryName = "strCountryName";
        }

        public struct ReferenceEditorType
        {
            public const long Disease = 19000019;
            public const long InvestigationTypes = 19000021;
            public const long SpeciesList = 19000086;
            public const long Prophylactic = 19000074;
            public const long Sanitary = 19000079;
            public const long VetAggregateCaseMatrix = 10506079;
        }

        public struct AggregateCaseT
        {
            public const long Disease = 19000019;
            public const long InvestigationTypes = 19000021;
            public const long SpeciesList = 19000086;
            public const long Prophylactic = 19000074;
            public const long Sanitary = 19000079;
            public const long VetAggregateCaseMatrix = 10506079;
        }

        public struct VeterinarySurveillanceReportType
        {
            public const long Avian = 10502002;
            public const long Livestock = 10502009;
        }

        public struct WeeklyReportFormType
        {
            public const long Disease = 19000019;
        }

        public struct MatrixTypes
        {
            public const long VetAggregateCase = 71090000000;
            public const long HumanAggregateCase = 71190000000;
            public const long VeterinarySanitaryMeasures = 71260000000;
            public const long Prophylactic = 71300000000;
            public const long DiagnosticInvestigations = 71460000000;
        }

        public struct RegionConstants
        {
            public const string RegionID = "idfsRegion";
            public const string RegionName = "strRegionName";
        }

        public struct RayonConstants
        {
            public const string RayonID = "idfsRayon";
            public const string RayonName = "strRayonName";
        }

        // TownOrVillage is same as settlement.
        // Be careful with idfsSettlement as it is same for Settlement module
        public struct TownOrVillageConstants
        {
            public const string TownOrVillageID = "idfsSettlement";
            public const string TownOrVillageName = "strSettlementName";
        }

        public struct PostalCodeConstants
        {
            public const string PostalCodeID = "PostalCodeID";
            public const string PostalCodeName = "PostalCodeString";
        }

        public struct SettlementConstants
        {
            public const string idfsSettlement = "idfsSettlement";
            public const string idfsSettlementID = "idfsSettlementID";
            public const string SettlementID = "idfsSettlement";
            public const string idfsSettlementType = "idfsSettlementType";
            public const string SettlementName = "SettlementDefaultName";
            public const string Settlement_Name = "strSettlementName";
            public const string NationalSettlement = "SettlementNationalName";
        }

        public struct SettlementGetList
        {
            public const string SettlementDefaultName = "SettlementDefaultName";
            public const string SettlementNationalName = "SettlementNationalName";
            public const string SettlementTypeDefaultName = "SettlementTypeDefaultName";
            public const string SettlementTypeNationalName = "SettlementTypeNationalName";
            public const string CountryDefaultName = "CountryDefaultName";
            public const string CountryNationalName = "CountryNationalName";
            public const string RegionDefaultName = "RegionDefaultName";
            public const string RegionNationalName = "RegionNationalName";
            public const string RayonDefaultName = "RayonDefaultName";
            public const string RayonNationalName = "RayonNationalName";
            public const string SettlementCode = "strSettlementCode";
            public const string Longitude = "dblLongitude";
            public const string Latitude = "dblLatitude";
            public const string Elevation = "intElevation";
        }

        public struct SettlementTypeConstants
        {
            public const string Name = "Name";
            public const string idfsReference = "idfsReference";
        }

        public struct EmployeeGroupConstants
        {
            public const string idfEmployeeGroup = "idfEmployeeGroup";
            public const string idfsEmployeeGroupName = "idfsEmployeeGroupName";
            public const string Name = "strName";
        }

        public struct ObjectAccessConstants
        {
            public const string idfObjectAccess = "idfObjectAccess";
            public const string idfsObjectOperation = "idfsObjectOperation";
            public const string idfsObjectType = "idfsObjectType";
            public const string idfsObjectTypeName = "idfsObjectTypeName";
            public const string idfsObjectID = "idfsObjectID";
            public const string idfEmployee = "idfEmployee";
            public const string isAllow = "isAllow";
            public const string isDeny = "isDeny";
        }

        public struct ObjectAccessOperationNames
        {
            public const string Create = "Create";
            public const string Read = "Read";
            public const string Write = "Write";
            public const string Delete = "Delete";
            public const string Execute = "Execute";
            public const string AccessToPersonalData = "Access To Personal Data";
        }

        public struct PageUsageMode
        {
            public const string Edit = "EditExisting";
            public const string CreateNew = "CreateNew";
        }

        #region Outbreak

        public struct OutbreakIDConstants
        {
            public const string idfsOutbreakID = "idOutbreak";
            public const string OutbreakIDName = "strOutbreakID";
        }

        public struct OutbreakTypes
        {
            public const Int32 Human = 10513001;
            public const Int32 Veterinary = 10513002;
            public const Int32 Zoonotic = 10513003;
        }

        public struct OutbreakCaseTypes
        {
            public const Int32 Human = 10516002;
            public const Int32 Veterinary = 10516001;
        }

        public struct OutbreakCaseStatus
        {
            public const long Infected = 10520001;
            public const long Isolated = 10520002;
            public const long Deceased = 10520003;
            public const long Recovered = 10520004;
            public const long Depopulated = 10520005;
            public const long Quarantined = 10520006;
            public const long Vaccinated = 10520007;
        }

        public struct OutbreakCaseClassification
        {
            public const long ConfirmedCase = 350000000;
            public const long ProbableCase = 360000000;
            public const long NotACase = 370000000;
            public const long Suspect = 380000000;
        }

        public struct OutbreakStatus
        {
            public const long InProgress = 10063501;
            public const long Closed = 10063502;
            public const long NotAnOutbreak = 13646170001100;
        }

        #endregion Outbreak

        public struct EntrySiteConstants
        {
            public const string idfsEntrySite = "idfsEntrySite";
            public const string EntrySiteName = "EntrySiteName";
        }

        public struct VectorTypeFeedingLifeStatus
        {
            public const string FeedingStatus = "6707190000000";
            public const string LifeStages = "6707200000000";
            public const string RodentReproduction = "6707210000000";
            public const string idfsParameter = "idfsParameterFixedPresetValue";
            public const string Name = "NationalName";
        }

        public struct OrganizationPerson
        {
            public const string PersonId = "idfPerson";
            public const string fullName = "FullName";
        }

        public struct HACodeItem
        {
            public const string ItemId = "intHACode";
            public const string Name = "strNote";
            public const string ItemName = "Name";
        }

        public struct HumanConstants
        {
            public const string HumanID = "idfHumanActual";
            public const string HumanName = "FullName";
        }

        public struct AdminOrganization
        {
            public const string OfficeID = "idfInstitution";
            public const string Name = "FullName";
        }

        public struct FarmConstants
        {
            public const string FarmID = "idfFarm";
            public const string FarmActualID = "idfFarmActual";
            public const string FarmCode = "strFarmCode";
            public const string TotalAnimalQuantity = "intTotalAnimalQty";
            public const string DeadAnimalQuantity = "intDeadAnimalQty";
            public const string SickAnimalQuantity = "intSickAnimalQty";
            public const string DiseaseReports = "Disease Reports";
            public const string ActiveSurveillanceSessions = "Active Surveillance Sessions";
            public const string LaboratoryTestSamples = "Laboratory Test Samples";
            public const string AddPersonDialog = "min-height: auto; width: 1200px";
        }

        public struct VeterinaryDiseaseReportConstants
        {
            public const string VeterinaryDiseaseReportID = "idfVetCase";
            public const string CaseTypeID = "idfsCaseType";
            public const string AvianDiseaseReportCaseType = "10012004";
            public const string LivestockDiseaseReportCaseType = "10012003";
            public const string Animals = "Animals";
            public const string Herds = "Herds";
            public const string Species = "Species";
            public const string Samples = "Samples";
            public const string LabTests = "LabTests";
            public const string Interpretations = "Interpretations";
            public const string PensideTests = "PensideTests";
            public const string Vaccinations = "Vaccinations";
            public const string VetCaseLogs = "VetCaseLogs";
        }

        public struct HerdSpeciesConstants
        {
            public const string HerdID = "idfHerd";
            public const string HerdActualID = "idfHerdActual";
            public const string HerdCode = "strHerdCode";
            public const string SpeciesID = "idfSpecies";
            public const string SpeciesActualID = "idfSpeciesActual";
            public const string SpeciesTypeID = "idfsSpeciesType";
            public const string SpeciesTypeName = "SpeciesTypeName";
            public const string TotalAnimalQuantity = "intTotalAnimalQty";
            public const string SickAnimalQuantity = "intSickAnimalQty";
            public const string DeadAnimalQuantity = "intDeadAnimalQty";
            public const string StartOfSignsDate = "datStartOfSignsDate";
            public const string AverageAge = "strAverageAge";
            public const string Comment = "strNote";
            public const string Flock = "Flock";
            public const string Herd = "Herd";
            public const string Species = "Species";
            public const string Farm = "Farm";
        }

        public struct AnimalConstants
        {
            public const string AnimalID = "idfAnimal";
            public const string AnimalAgeTypeID = "idfsAnimalAge";
            public const string AnimalAgeTypeName = "AnimalAgeTypeName";
            public const string AnimalGenderTypeID = "idfsAnimalGender";
            public const string AnimalGenderTypeName = "AnimalGenderTypeName";
            public const string AnimalConditionTypeID = "idfsAnimalCondition";
            public const string AnimalConditionTypeName = "AnimalConditionTypeName";
            public const string AnimalCode = "strAnimalCode";
            public const string AnimalName = "strName";
            public const string Color = "strColor";
            public const string SpeciesID = "idfSpecies";
            public const string SpeciesTypeName = "SpeciesTypeName";
            public const string HerdID = "idfHerd";
            public const string HerdCode = "strHerdCode";
            public const string Animal = "Animal";
        }

        public struct BaseReferenceTypeIds
        {
            public const long CaseStatus = 19000111;
            public const long CaseClassification = 19000011;
            public const long CaseReportType = 19000144;
            public const long CaseOutComeList = 19000064;
            public const long CaseType = 19000012;
            public const long Diagnosis = 19000019;
            public const long PatientState = 19000035;
            public const long PatientLocationType = 19000041;
            public const long GroundType = 19000038;
            public const long ReasonForNotCollectingSample = 19000150;
            public const long OutcomeCaseList = 19000064;
            public const long NonNotifiableDiagnosis = 19000149;
            public const long PatientContactType = 19000014;
            public const long HumanGender = 19000043;
            public const long Nationality = 19000054;
            public const long PersonalIdTypes = 19000148;
            public const long ContactPhoneTypes = 19000500;
            public const long OccupationTypes = 19000061;
            public const long HumanAgeTypes = 19000042;
            public const long SampleTypes = 19000087;
            public const long PensideTest = 19000104;
            public const long LabTest = 19000097;
            public const long AccessoryList = 19000040;
            public const long StatisticalAgeGroup = 19000145;
            public const long DiagnosisAgeGroup = 19000146;
            public const long FixedPresetValueParameter = 19000069;
            public const long AccessionCondition = 19000110;
        }

        public struct BaseReferenceEditorSetting
        {
            public const long DeleteDisabled = 1;
            public const long EditDisabled = 2;
            public const long AddDisabled = 4;
            public const long LOINCHide = 8;
            public const long HACodeHide = 16;
            public const long LOINCReadOnly = 32;
            public const long HACodeReadOnly = 64;
            public const long OrderByHide = 128;
            public const long OrderByReadOnly = 256;
            public const long DefaultHide = 512;
            public const long DefaultReadOnly = 1024;
            public const long NationalHide = 2048;
            public const long NationalReadOnly = 4096;
        }

        public struct CaseStatus
        {
            public const long InProgress = 10109001;
        }

        public struct CaseReportType
        {
            public const long Passive = 4578940000002;
            public const long Active = 4578940000001;
        }

        public struct FinalOutcome
        {
            public const long Died = 10770000000;
        }

        public struct DiagnosisIds
        {
            public const long ILI = 10019001;
            public const long SARD = 10019002;
        }

        public struct PersonalIDTypes
        {
            public const long Unknown = 389445040006233;
            public const long PIN = 58010200000000;
        }

        public struct PersonalIDTypeMatriceAttributeTypes
        {
            public const string AlphaNumeric = "Alphanumeric"; //TODO Alphanumeric localization
            public const string Numeric = "Numeric"; //TODO Numeric localization
        }

        public struct SampleConstants
        {
            public const string SampleID = "idfMaterial";
            public const string SampleCode = "strFieldBarCode";
            public const string BirdStatusTypeID = "idfsBirdStatus";
            public const string BirdStatusTypeName = "BirdStatusTypeName";
            public const string FieldCollectedByOfficeID = "idfFieldCollectedByOffice";
            public const string FieldCollectionByOfficeName = "FieldCollectedByOfficeSiteName";
            public const string FieldCollectedByPersonID = "idfFieldCollectedByPerson";
            public const string FieldCollectedByPersonName = "FieldCollectedByPersonName";
            public const string SendToOfficeID = "idfSendToOffice";
            public const string SendToOfficeName = "SendToOfficeSiteName";
            public const string AccessionDate = "datAccession";
            public const string AccessionConditionTypeID = "idfsAccessionCondition";
            public const string AccessionConditionTypeName = "AccessionConditionTypeName";
            public const string FieldCollectionDate = "datFieldCollectionDate";
            public const string ConditionReceived = "strCondition";
            public const string Note = "strNote";
            public const string Site = "idfsSite";
            public const string ReadOnlyIndicator = "blnReadOnly";
            public const string AccessionedIndicator = "blnAccessioned";
            public const string SampleStatusTypeID = "idfsSampleStatus";
            public const string FunctionalAreaID = "idfInDepartment";
            public const string FunctionalAreaName = "FunctionalAreaName";
            public const string CurrentSite = "idfsCurrentSite";
            public const string AccessionByPersonID = "idfAccesionByPerson";
            public const string CaseID = "strCalculatedCaseID";
            public const string VeterinaryDiseaseReportID = "idfVetCase";
            public const string HumanDiseaseReportID = "idfHumanCase";
            public const string MonitoringSessionID = "idfMonitoringSession";
            public const string VectorSurveillanceSessionID = "idfVectorSurveillanceSession";
            public const string HumanID = "idfHuman";
        }

        public struct SampleTypeConstants
        {
            public const string SampleTypeID = "idfsSampleType";
            public const string SampleTypeName = "SampleTypeName";
        }

        public struct TestNameTypeConstants
        {
            public const string TestNameTypeID = "TestNameTypeID";
            public const string TestNameTypeName = "TestNameTypeName";
        }

        public struct VaccinationConstants
        {
            public const string VaccinationID = "idfVaccination";
            public const string VaccinationTypeID = "idfsVaccinationType";
            public const string VaccinationTypeName = "VaccinationTypeName";
            public const string VaccinationRouteTypeID = "idfsVaccinationRoute";
            public const string VaccinationRouteTypeName = "VaccinationRouteTypeName";
            public const string SpeciesID = "idfSpecies";
            public const string SpeciesTypeName = "SpeciesTypeName";
            public const string DiseaseID = "idfsDiagnosis";
            public const string DiseaseName = "DiagnosisTypeName";
            public const string VaccinationDate = "datVaccinationDate";
            public const string NumberVaccinated = "intNumberVaccinated";
            public const string LotNumber = "strLotNumber";
            public const string ManufacturerName = "strManufacturer";
            public const string Note = "strNote";
        }

        public struct PensideTestConstants
        {
            public const string PensideTestID = "idfPensideTest";
            public const string PensideTestNameTypeID = "idfsPensideTestName";
            public const string PensideTestNameTypeName = "TestNameTypeName";
            public const string PensideTestResultTypeID = "idfsPensideTestResult";
            public const string PensideTestResultTypeName = "TestResultTypeName";
            public const string SpeciesTypeName = "SpeciesTypeName";
            public const string AnimalCode = "strAnimalCode";
        }

        public struct LabTestConstants
        {
            public const string LabTestID = "idfTesting";
            public const string LabTestCode = "strBarCode";
            public const string ConcludedDate = "datConcludedDate";
            public const string TestResultTypeID = "idfsTestResult";
            public const string TestResultTypeName = "TestResultTypeName";
            public const string TestNameTypeID = "idfsTestName";
            public const string TestNameTypeName = "TestNameTypeName";
            public const string TestCategoryTypeID = "idfsTestCategory";
            public const string TestCategoryTypeName = "TestCategoryTypeName";
            public const string TestStatusTypeID = "idfsTestStatus";
            public const string TestStatusTypeName = "TestStatusTypeName";
            public const string DiseaseID = "idfsDiagnosis";
            public const string DiseaseName = "DiagnosisName";
            public const string ReadOnlyIndicator = "blnReadOnly";
            public const string NonLaboratoryTestIndicator = "blnNonLaboratoryTest";
            public const string ObservationID = "idfObservation";
        }

        public struct InterpretationConstants
        {
            public const string InterpretationID = "idfTestValidation";
            public const string InterpretedStatusTypeID = "idfsInterpretedStatus";
            public const string InterpretedStatusTypeName = "InterpretedStatusTypeName";
            public const string InterpretedByPersonName = "InterpretedByPersonName";
            public const string InterpretedByPersonID = "idfInterpretedByPerson";
            public const string InterpretationDate = "datInterpretationDate";
            public const string ValidationDate = "datValidationDate";
            public const string InterpretedComment = "strInterpretedComment";
            public const string ValidatedComment = "strValidateComment";
            public const string ValidatedByPersonID = "idfValidatedByPerson";
            public const string ValidatedByPersonName = "ValidatedByPersonName";
            public const string ValidatedIndicator = "blnValidateStatus";
            public const string LabTestID = "idfTesting";
            public const string ReadOnlyIndicator = "blnReadOnly";
        }

        public struct CaseLogConstants
        {
            public const string VeterinaryCaseLogID = "idfVetCaseLog";
            public const string CaseLogDate = "datCaseLogDate";
            public const string PersonName = "PersonName";
            public const string ActionRequired = "strActionRequired";
            public const string CaseLogStatusTypeID = "idfsCaseLogStatus";
            public const string CaseLogStatusTypeName = "CaseLogStatusTypeName";
            public const string Note = "strNote";
        }

        public struct Months
        {
            public const string MonthName = "strTextString";
        }

        public struct StatisticTypes
        {
            public const string StatAreaType = "idfsStatisticAreaType";
            public const string StatPeriodType = "idfsStatisticPeriodType";
            public const string idfStatisticData = "idfStatistic";
            public const string idfsStatTypeData = "idfsStatisticDataType";
            public const string Population = "39850000000";
            public const string PopGender = "840900000000";
            public const string PopAgeGen = "39860000000";

            public const string StatStartDate = "datStatisticStartDate";
        }

        public struct StatisticAreaType
        {
            public const string Country = "10089001";
            public const string Rayon = "10089002";
            public const string Region = "10089003";
            public const string Settlement = "10089004";
        }

        public struct StatisticAreaTypeIds
        {
            public const long Country = 10089001;
            public const long Rayon = 10089002;
            public const long Region = 10089003;
            public const long Settlement = 10089004;
        }

        public struct StatisticPeriodType
        {
            public const string Month = "10091001";
            public const string Day = "10091002";
            public const string Quarter = "10091003";
            public const string Week = "10091004";
            public const string Year = "10091005";
        }

        public struct DiseaseReportLogStatusTypeConstants
        {
            public const string Open = "Open";
            public const string Closed = "Closed";
        }

        public struct VectorConstants
        {
            public const string VectorSurveillanceSessionID = "idfVectorSurveillanceSession";
            public const string StringSessionID = "strSessionID";
            public const string GridViewCode_VecSurv = "vecSurv";
            public const string GridViewCode_CollDetail = "CollDetail";
            public const string GridViewCode_CollSummary = "CollSummary";
            public const string GridViewCode_Samp = "samp";
            public const string GridViewCode_FieldTest = "fieldTest";
            public const string GridViewCode_LabTest = "labTest";
            public const string GridViewCode_Diseases = "Diseases";
            public const string GridViewCode_VectorSurvList = "VectorSurvList";
            public const string List = "List";
            public const string DataTable = "DT";
            public const string NewItem = "NewItem";
            public const string NewWithBrackets = "(New)";
            public const string Closed = "Closed";
        }

        public struct VectorMessages
        {
            public const string SurveillanceSessionSaved = "Vector Surveillance Session data saved sucessfully.";
            public const string PageError = "An Error occurred On this page. Please verify your information To resolve the issue.";
            public const string DetailedCollectionSaved = "Vector Detailed Collection Data saved sucessfully.";
            public const string VectorSaveValidationError = "Please first create Vector Data record.";
            public const string MessageBox_Want_To_Cancel = "Are you sure that you want To cancel?";
            public const string MessageBox_Confirm_Cancel = "Confirm Cancel";
            public const string AggregateCollectionValidationError = "Please first create Vector Surveillance Session record";
            public const string DetailedCollectionValidationError = "Please first create Vector Surveillance Session record";
            public const string SummaryCollectionSaved = "Summary collection saved successfully";
            public const string SampleDeletedSuccessfully = "Sample deleted successfully";
            public const string FieldTestDeletedSuccessfully = "FieldTest deleted successfully";
            public const string MessageBox_Want_To_Delete = "Are you sure that you want to delete this record?";
            public const string MessageBox_Confirm_Delete = "Confirm Delete";
            public const string DetailedCollectionDeleted = "Detailed Collection deleted successfully";
            public const string AggregateCollectionDeleted = "Aggregate Collection deleted successfully";
            public const string SampleSavedSuccessfully = "Sample saved successfully";
            public const string SampleSaveSampleIdValidationError = "Please enter in valid Field Sample ID";
            public const string DetailedCollectionCopied = "Vector Detailed Collection Data copied sucessfully";
            public const string SampleSavedValidationError = "Please first create Sample record.";
            public const string FieldTestSavedSuccessfully = "FieldTest saved successfully.";
            public const string FieldTestSavedValidationError = "Please first create FieldTest record.";
            public const string VectorSurveillanceSessionDeleted = "Successful Deletion Of Vector Surveillance Session record.";
            public const string SearchValidationError = "Please enter at least one search parameter.";
            public const string ValidateForCreateVectorSurveillanceError = "Please at least select status and start date parameters.";
            public const string ValidateForCreateVectorSurveillanceDescriptionMaxLengthError = "Please limit the Description and Description of Location parameters character length to 500 or less";
            public const string ValidateForExactLocationError = "Please select address region and rayon location parameters.";
            public const string ValidateForRelativeLocationError = "Please select address region, rayon, and town or village location parameters.";
            public const string ValidateForForeignLocationError = "Please select address country location parameter.";
            public const string ValidateForSpeciesError = "Please select species parameter.";
        }

        public struct GridViewCommandConstants
        {
            public const string AddCommand = "Add";
            public const string SelectCommand = "Select";
            public const string SelectRecordCommand = "Select Record";
            public const string ViewCommand = "View";
            public const string EditCommand = "Edit";
            public const string InsertCommand = "Insert";
            public const string DeleteCommand = "Delete";
            public const string UpdateCommand = "Update";
            public const string CancelCommand = "Cancel";
            public const string PageCommand = "Page";
            public const string SortCommand = "Sort";
            public const string NewInterpretationCommand = "New Lab Test Interpretation";
            public const string CreateConnectedDiseaseReportCommand = "Create Connected Disease Report";
            public const string CreateDiseaseReportCommand = "Create Disease Report";
            public const string NewTestAssignmentCommand = "New Test Assignment";
            public const string GetAliquotsCommand = "Get Aliquots";
            public const string MyFavoriteCommand = "My Favorite";
            public const string SelectAllRecordsMyFavoriteCommand = "Select All Records My Favorite";
            public const string ToggleSelectAll = "Toggle Select All";
            public const string ToggleSelect = "Toggle Select";
            public const string ToggleSelectAllBatches = "Toggle Select All Batches";
            public const string SelectFarm = "Select Farm";
            public const string RemoveCommand = "Remove";
            public const string CopyCommand = "Copy";
            public const string SelectPerson = "Select Person";
            public const string ExpandSubrow = "Expand Subrow";
            public const string PermissionsCommand = "Permissions";
        }

        public struct RecordConstants
        {
            public const string RecordID = "RecordID";
            public const string RecordType = "RecordType";
            public const string RecordAction = "RecordAction";
            public const string Read = "R";
            public const string Insert = "I";
            public const string Update = "U";
            public const string Delete = "D";
            public const string Accession = "A";
            public const string InsertAccession = "C";
            public const string InsertAliquotDerivative = "Q";
            public const string InsertTransfer = "T";
            public const string AccessionUpdateTransferOut = "O";
            public const string RejectUpdateTransferOut = "J";
            public const string InsertMonitoringSessionAggregateFarm = "F";
            public const string SelectFarm = "F";
            public const string Favorite = "Favorite";
            public const string RowStatus = "intRowStatus";
            public const string ActiveRowStatus = "0";
            public const string InactiveRowStatus = "1";
            public const string RecordCount = "RecordCount";
        }

        public struct RecordTypeConstants
        {
            public const string AvianDiseaseReport = "Avian";
            public const string LivestockDiseaseReport = "Livestock";
            public const string Farm = "Farm";
            public const string Herd = "Herd";
            public const string Species = "Species";
            public const string Animals = "Animals";
            public const string Samples = "Samples";
            public const string LabTests = "LabTests";
            public const string Interpretations = "Interpretations";
            public const string PensideTests = "PensideTests";
            public const string Vaccinations = "Vaccinations";
            public const string VetCaseLogs = "VetCaseLogs";
        }

        public struct ActiveSurveillanceCampaignConstants
        {
            public const string Campaign = "idfCampaign";
            public const string CampaignID = "strCampaignID";
            public const string CampaignName = "strCampaignName";
            public const string CampaignAdministrator = "strCampaignAdministrator";
            public const string CampaignType = "CampaignType";
            public const string CampaignTypeID = "idfsCampaignType";
            public const string StartDate = "datCampaignDateStart";
            public const string EndDate = "datCampaignDateEND";
            public const string DiagnosisID = "idfsDiagnosis";
            public const string Diagnosis = "Diagnosis";
            public const string Comments = "strComments";
            public const string Conclusion = "Conclusion";
            public const string CampaignStatus = "CampaignStatus";
            public const string CampaignStatusID = "idfsCampaignStatus";
            public const string SampleTypesList = "SampleTypesList";
        }

        public struct ActiveSurveillanceSessionConstants
        {
            public const string Session = "idfMonitoringSession";
            public const string SessionID = "strMonitoringSessionID";
            public const string SessionStatus = "MonitoringSessionStatus";
            public const string SessionStatusID = "idfsMonitoringSessionStatus";
            public const string Organization = "EnglishName";
            public const string OrganizationID = "idfsSite";
            public const string Officer = "Officer";
            public const string OfficerID = "idfsPersonEnteredBy";
            public const string StartDate = "datStartDate";
            public const string EndDate = "datEndDate";
            public const string DateEntered = "datEnteredDate";
            public const string DiagnosisID = "idfsDiagnosis";
            public const string Diagnosis = "Diagnosis";
            public const string RegionID = "idfsRegion";
            public const string Region = "Region";
            public const string CountryID = "idfsCountry";
            public const string Country = "Country";
            public const string RayonID = "idfsRayon";
            public const string Rayon = "Rayon";
            public const string TownID = "idfsSettlement";
            public const string Town = "Town";
            public const string Animals = "Animals";
            public const string Farms = "Farms";
            public const string Herds = "Herds";
            public const string Species = "Species";
            public const string SpeciesAndSamples = "SpeciesAndSamples";
            public const string Samples = "Samples";
            public const string Tests = "Tests";
            public const string Interpretations = "Interpretations";
            public const string Actions = "Actions";
            public const string Summaries = "Summaries";
            public const string SessionCategoryID = "SessionCategoryID";
            public const string SessionCategory = "SessionCategory";
        }

        public struct ActiveSurveillanceCampaignToSampleTypeConstants
        {
            public const string Campaign = "idfCampaign";
            public const string CampaignToSampleType = "CampaignToSampleTypeUID";
            public const string PlannedNumber = "intPlannedNumber";
            public const string Order = "intOrder";
            public const string SampleTypeID = "idfsSampleType";
            public const string SampleType = "SampleType";
            public const string SampleTypeName = "SampleTypeName";
            public const string SpeciesTypeID = "idfsSpeciesType";
            public const string SpeciesType = "SpeciesType";
            public const string SpeciesTypeName = "SpeciesTypeName";
            public const string HasOpenSession = "HasOpenSession";
        }

        public struct MonitoringSessionActionConstants
        {
            public const string MonitoringSessionActionID = "idfMonitoringSessionAction";
            public const string MonitoringSessionID = "idfMonitoringSession";
            public const string ActionDate = "datActionDate";
            public const string PersonEnteredByID = "idfPersonEnteredBy";
            public const string PersonName = "strPersonEnteredBy";
            public const string PersonFullName = "PersonName";
            public const string ActionRequired = "strMonitoringSessionActionType";
            public const string MonitoringSessionActionTypeID = "idfsMonitoringSessionActionType";
            public const string MonitoringSessionActionTypeName = "strMonitoringSessionActionType"; // TODO: Combine vet and human - duplicate code
            public const string MonitoringSessionActionName = "MonitoringSessionActionTypeName"; // TODO: Combine vet and human - duplicate code
            public const string MonitoringSessionStatusTypeID = "idfsMonitoringSessionActionStatus";
            public const string MonitoringSessionStatusTypeName = "strMonitoringSessionActionStatus"; // TODO: Combine vet and human - duplicate code
            public const string MonitoringSessionStatusName = "MonitoringSessionActionStatusName"; // TODO: Combine vet and human - duplicate code
            public const string Comment = "strComments";
        }

        public struct MonitoringSessionSummaryConstants
        {
            public const string MonitoringSessionSummaryID = "idfMonitoringSessionSummary";
            public const string CollectionDate = "datCollectionDate";
            public const string SampledAnimalsQuantity = "intSampledAnimalsQty";
            public const string SamplesQuantity = "intSamplesQty";
            public const string PositiveAnimalsQuantity = "intPositiveAnimalsQty";
            public const string SampleTypeID = "idfsSampleType";
            public const string SampleTypeName = "SampleTypeName";
            public const string DiseaseTypeID = "idfsDiagnosis";
            public const string DiseaseTypeName = "DiagnosisName";
            public const string AnimalGenderTypeID = "idfsAnimalSex";
            public const string AnimalGenderTypeName = "AnimalGenderTypeName";
        }

        public struct ActiveSurveillanceMonitoringSessionToSampleTypeConstants
        {
            public const string MonitoringSession = "idfMonitoringSession";
            public const string SessionToSampleType = "MonitoringSessionToSampleType";
            public const string Order = "intOrder";
            public const string SampleTypeID = "idfsSampleType";
            public const string SampleType = "SampleType";
            public const string SampleTypeName = "SampleTypeName";
            public const string SpeciesTypeID = "idfsSpeciesType";
            public const string SpeciesType = "SpeciesType";
            public const string SpeciesTypeName = "SpeciesTypeName";
        }

        public struct SortConstants
        {
            public const string Ascending = "ASC";
            public const string Descending = "DESC";
            public const string Direction = "SortDirection";
            public const string Expression = "SortExpression";
        }

        public struct MaterialConstants
        {
            public const string Material = "idfMaterial";
            public const string SampleTypeID = "idfsSampleType";
            public const string SampleType = "SampleTypeName";
            public const string RootMaterial = "idfRootMaterial";
            public const string Parent = "idfParentMaterial";
            public const string SpeciesTypeID = "idfSpecies";
            public const string SpeciesType = "SpeciesTypeName";
            public const string AnimalID = "idfAnimal";
            public const string MonitoringSessionID = "idfMonitoringSession";
            public const string FieldCollectedByPersonID = "idfFieldCollectedByPerson";
            public const string FieldCollectedByPerson = "FieldCollectedByPersonName";
            public const string FieldCollectedByOfficeID = "idfFieldCollectedByOffice";
            public const string FieldCollectedByOffice = "FieldCollectedByOfficeSiteName";
            public const string MainTestID = "idfMainTest";
            public const string TestNumber = "intTestNumber";
            public const string FieldCollectionDate = "datFieldCollectionDate";
            public const string FieldSentDate = "datFieldSentDate";
            public const string FieldBarCode = "strFieldBarcode";
            public const string CalculatedCaseID = "strCalculatedCaseID";
            public const string CalculatedHumanName = " strCalculatedHumanName";
            public const string VectorSurveillanceSessionID = "idfVectorSurveillanceSession";
            public const string VectorID = "idfVector";
            public const string SubdivisionID = "idfSubdivision";
            public const string NameChars = "strNameChars";
            public const string SampleStatusID = "idfsSampleStatus";
            public const string SampleStatus = "SampleStatusTypeName";
            public const string InDepartmentID = "idfInDepartment";
            public const string InDepartmentSite = "InDepartmentSiteName";
            public const string DestroyedByPersonID = "idfDestroyedByPerson";
            public const string DestroyedByPersonName = "DestroyedByPersonName";
            public const string EnteringDate = "datEnteringDate";
            public const string DestructionDate = "datDestructionDate";
            public const string Barcode = "strBarcode";
            public const string Note = "strNote";
            public const string MaterialSiteID = "idfsSite";
            public const string MaterialSite = "MaterialSiteName";
            public const string RowStatus = "intRowStatus";
            public const string SendToOfficeID = "idfSendToOffice";
            public const string SendToOffice = "SendToOfficeSiteName";
            public const string IsReadOnly = "blnReadOnly";
            public const string BirdStatusID = "idfsBirdStatus";
            public const string BirdStatus = "BirdStatusTypeName";
            public const string HumanCaseID = "idfHumanCase";
            public const string VetCaseID = "idfVetCase";
            public const string AccessionDate = "datAccession";
            public const string AccessionConditionID = "idfsAccessionCondition";
            public const string AccessionCondition = "AccessionConditionTypeName";
            public const string Condition = "strCondition";
            public const string AccesionByPersonID = "idfAccesionByPerson";
            public const string AccessionByPersonName = "AccessionByPersonName";
            public const string DestructionMethodID = "idfsDestructionMethod";
            public const string DestructionMethod = "DestructionMethodTypeName";
            public const string CurrentSiteID = "idfsCurrentSite";
            public const string CurrentSite = "CurrentSiteName";
            public const string SampleKindID = "idfsSampleKind";
            public const string SampleKind = "SampleKindTypeName";
            public const string WasAccessioned = "blnAccessioned";
            public const string ShowInCaseOrSession = "blnShowInCaseOrSession";
            public const string ShowInLabList = "blnShowInLabList";
            public const string ShowInDispositionList = "blnShowInDispositionList";
            public const string ShowInAccessionInForm = " blnShowInAccessionInForm";
            public const string MarkedForDispositionByPersonID = "idfMarkedForDispositionByPerson";
            public const string MarkedForDispositionByPerson = "MarkedForDispositionByPersonName";
            public const string OutOfRepositoryDate = "datOutOfRepositoryDate";
            public const string SampleStatusDate = "datSampleStatusDate";
            public const string MaintenanceFlag = "strMaintenanceFlag";
            public const string RecordAction = "RecordAction";
        }

        public struct TestConstants
        {
            public const string TestingID = "idfTesting";
            public const string TestNameID = "idfsTestName";
            public const string TestName = "strTestName";
            public const string TestCategoryID = "idfsTestCategory";
            public const string TestCategory = "strTestCategory";
            public const string TestResultID = "idfsTestResult";
            public const string TestResult = "strTestResult";
            public const string TestStatusID = "idfsTestStatus";
            public const string TestStatus = "strTestStatus";
            public const string DiagnosisID = "idfsDiagnosis";
            public const string Diagnosis = "Diagnosis";
            public const string MaterialID = "idfMaterial";
            public const string BatchTestID = "idfBatchTest";
            public const string ObservationID = "idfObservation";
            public const string TestNumber = "intTestNumber";
            public const string Note = "strNote";
            public const string RowStatus = "intRowStatus";
            public const string StartDate = "datStartedDate";
            public const string ConclusionDate = "datConcludedDate";
            public const string TestedByOfficeID = "idfTestedByOffice";
            public const string TestedByOffice = "strTestedByOffice";
            public const string TestedByPersonID = "idfTestedByPerson";
            public const string TestedByPerson = "strTestedByPerson";
            public const string ResultEnteredByOfficeID = "idfResultEnteredByOffice";
            public const string ResultEnteredByOffice = "strResultEnteredByOffice";
            public const string ResultEnteredByPersonID = "idfResultEnteredByPerson";
            public const string ResultEnteredByPerson = "strResultEnteredByPerson";
            public const string ValidateByOfficeID = "idfValidatedByOffice";
            public const string ValidateByOffice = "strValidatedByOffice";
            public const string ValidateByPersonID = "idfValidatedByPerson";
            public const string ValidateByPerson = "strValidatedByPerson";
            public const string IsReadOnly = "blnReadOnly";
            public const string IsLaboratoryTest = "blnNonLaboratoryTest";
            public const string IsExternalTest = "blnExternalTest";
            public const string PerformedByOfficeID = "idfPerformedByOffice";
            public const string DateReceived = "datReceivedDate";
            public const string ContactPerson = "strContactPerson";
            public const string MaintenanceFlag = "strMaintenanceFlag";
            public const string ReservedAttribute = "strReservedAttribute";
            public const string RecordAction = "RecordAction";
        }

        public struct HumanAgeTypeConstants
        {
            public const string Days = "10042001";
            public const string Weeks = "10042004";
            public const string Months = "10042002";
            public const string Years = "10042003";
        }

        public struct GridViewSortConstants
        {
            public const string GridRows = "GRIDROWS";
            public const string Page = "PAGE";
        }

        public struct PagingConstants
        {
            public const string FirstButtonText = "<<";
            public const string LastButtonText = ">>";
            public const string NextButtonText = ">";
            public const string PreviousButtonText = "<";
        }

        public struct ReportSessionTypeConstants
        {
            public const string HumanDiseaseReport = "Human Disease Report";
            public const string HumanActiveSurveillanceSession = "Human Active Surveillance Session";
            public const string SearchHumanDiseaseReport = "Search Human Disease Report";
            public const string SearchPerson = "Search Person";
            public const string VectorSurveillanceSession = "Vector Surveillance Session";
            public const string VeterinaryActiveSurveillanceSession = "Veterinary Active Surveillance Session";
            public const string VeterinaryDiseaseReport = "Veterinary Disease Report";
            public const string VeterinaryActiveSurveillanceCampaign = "Veterinary Active Surveillance Campaign";
            public const string HumanActiveSurveillanceCampaign = "Human Active Surveillance Campaign";
        }

        public struct LaboratoryModuleTabConstants
        {
            public const string Samples = "Samples";
            public const string Testing = "Testing";
            public const string Transferred = "Transferred";
            public const string MyFavorites = "Favorites";
            public const string Batches = "Batches";
            public const string Approvals = "Approvals";
        }

        public struct LaboratoryApprovalConstants
        {
            public const string SampleDeletion = "Sample Deletion";
            public const string SampleDestruction = "Sample Destruction";
            public const string TestDeletion = "Test Deletion";
            public const string Validation = "Validation";
        }

        public struct LaboratoryModuleCSSClassConstants
        {
            public const string LaboratoryTab = "laboratory-tab";
            public const string MyFavoriteNo = "myFavoriteNo";
            public const string MyFavoriteYes = "myFavoriteYes";
            public const string Unaccessioned = "unaccessioned";
            public const string UnaccessionedSavePending = "unaccessionedSavePending";
            public const string NoSavePending = "noSavePending";
            public const string SavePending = "savePending";
            public const string UnaccessionedCell = "background-color: #F5E8B6;";
            public const string AccessionedCell = "background-color: #FFFFFF;";
            public const string DefaultDialogWidth = "700px";
            public const string DefaultDialogHeight = "530px";
            public const string AccessionInDialog = "height: auto; min-width: auto; width: auto";
            public const string AccessionCommentDialog = "height: auto; min-width: auto; width: auto;";
            public const string AssignTestDialog = "min-height: auto; width: 80%;";
            public const string AmendTestResultDialog = "min-height: auto; width: 700px;";
            public const string CreateAliquotDerivativeDialog = "min-height: auto; width: 90%;";
            public const string CreateBatchDialog = "min-height: auto; width: 700px;";
            public const string LaboratoryRecordDetailsDialog = "min-height: auto; width: 700px;";
            public const string LaboratoryPaperFormsDialog = "min-height: auto; width: 90%";
            public const string RegisterNewSampleDialog = "min-height: auto; width: 700px;";
            public const string TransferOutDialog = "min-height: auto; width: 700px;";
            public const string AddFarmDialog = "min-height: auto; width: 90%";
            public const string AddPersonDialog = "min-height: auto; max-height: 80%; width: 90%;";
        }

        public struct OutbreakModuleCSSClassConstants
        {
            public const string PrimaryCaseIndicator = "savePending";
            public const string ImportCaseDialog = "height: 70%; width: 90%;";
        }

        public struct CSSClassConstants
        {
            public const string DefaultDialogWidth = "700px";
            public const string DefaultDialogHeight = "530px";
            public const string LargeDialogWidth = "80%";
            public const string LargeDialogHeight = "70%";
        }

        public struct PermissionTypeConstants
        {
            public const string AccessToAggregateSettings = "Access To Aggregate Settings";
            public const string AccessToAVRModule = "Access To Analysis, Visualization And Reporting Module (AVR)";
            public const string CanDestroySamples = "Can Destroy Samples";
            public const string CanValidateTestResultInterpretation = "Can Validate Test Result Interpretation";
            public const string CanInterpretTestResult = "Can Interpret Test Result";
            public const string CanExecuteHumanDiseaseReportDeduplicationFunction = "Can Execute Human Disease Report Deduplication Function";
            public const string AccessToPersonsList = "Access To Persons List";
            public const string CanPerformSampleTransfer = "Can Perform Sample Transfer";
            public const string AccessToStatisticsList = "Access To Statistics List";
            public const string AccessToSystemFunctionsList = "Access To System Functions List";
            public const string CanManageUserAccounts = "Can Manage User Accounts";
            public const string CanManageReferenceTables = "Can Manage Reference Tables";
            public const string AccessToEventLog = "Access To Event Log";
            public const string AccessToFlexibleFormsDesigner = "Access To Flexible Forms Designer";
            public const string AccessToGISModule = "Access To GIS Module";
            public const string AccessToReports = "Access To Reports";
            public const string CanPrintBarcodes = "Can Print Barcodes";
            public const string CanAccessObjectNumberingSchema = "Can Access Object Numbering Schema";
            public const string CanAccessOrganizationsList = "Can Access Organizations List";
            public const string CanAccessEmployeesListWithoutManagingAccessRights = "Can Access Employees List (Without Managing Access Rights)";
            public const string CanManageRepositorySchema = "Can Manage Repository Schema";
            public const string CanWorkWithAccessRightsManagement = "Can Work With Access Rights Management";
            public const string CanManageUserGroups = "Can Manage User Groups";
            public const string AccessToHumanDiseaseReportData = "Access To Human Disease Report Data";

            public const string AccessToVeterinaryDiseaseReportsData = "Access to Veterinary Cases Data";

            public const string AccessToLaboratorySamples = "Access To Laboratory Samples";
            public const string AccessToLaboratoryTests = "Access To Laboratory Tests";
            public const string AccessToEIDSSSitesListManagingDataReceptionFromOtherSites = "Access To EIDSS Sites List (Managing Data reception from Other Sites)";
            public const string CanManageSiteAlertsSubscriptions = "Can Manage Site Alerts Subscriptions";
            public const string AccessToOutbreaks = "Access To Outbreaks";
            public const string AccessToReplicateDataCommand = "Access To Replicate Data Command";
            public const string CanPerformSampleAccessionIn = "Can Perform Sample Accession In";
            public const string AccessToAVRAdministration = "Access To AVR Administration";
            public const string AccessToDataAudit = "Access To Data Audit";
            public const string AccessToSecurityLog = "Access To Security Log";
            public const string AccessToSecurityPolicy = "Access To Security Policy";

            public const string AccessToVeterinaryActiveSurveillanceCampaign = "Access to Active Surveillance Campaign";

            public const string AccessToVeterinaryActiveSurveillanceSession = "Access to Active Surveillance Session";
            public const string CanImportExportData = "Can Import/Export Data";
            public const string AccessToVectorSurveillanceSession = "Access To Vector Surveillance Session";
            public const string CanAmendTest = "Can Amend a Test";
            public const string CanAddTestResultsForCaseSession = "Can Add Test Results For a Case/Session";
            public const string CanReadArchivedData = "Can Read Archived Data";
            public const string CanRestoreDeletedRecords = "Can Restore Deleted Records";
            public const string CanSignReport = "Can Sign Report";
            public const string CanManageGISReferenceTables = "Can Manage GIS Reference Tables";
            public const string AccessToBasicSyndromicSurveillanceModule = "Access To Basic Syndromic Surveillance Module";
            public const string AccessToHumanAggregateDiseaseReport = "Access To Human Aggregate Disease Report";
            public const string AccessToVeterinaryAggregateDiseaseReports = "Access To Veterinary Aggregate Disease Reports";
            public const string AccessToVeterinaryAggregateActions = "Access To Veterinary Aggregate Actions";
            public const string CanReopenClosedDiseaseReport = "Can Reopen Closed Disease Report";
            public const string AccessToFarmsData = "Access To Farms Data";
            public const string CanFinalizeLaboratoryTest = "Can Finalize Laboratory Test";
            public const string UseSimplifiedHumanCaseReportForm = "Use Simplified Human Case Report Form";
            public const string AberrationDetection = "Aberration detection";
            public const string AccessToAberrationAnalysisReports = "Access To Aberration Analysis Reports";
            public const string AccessToAdministrativeStandardReports = "Access To Administrative Standard Reports";
            public const string AccessToEIDSSSitesListManagingDataAccessFromOtherSites = "Access To EIDSS Sites List (Managing Data access from Other Sites)";
            public const string AccessToHumanActiveSurveillanceCampaign = "Access To HUMAN Active Surveillance Campaign";
            public const string AccessToHumanActiveSurveillanceSession = "Access To HUMAN Active Surveillance Session";
            public const string AccessToHumanDiseaseReportCaseInvestigationSection = "Access To Human Disease Report Case Investigation section";
            public const string AccessToHumanDiseaseReportClinicalInformation = "Access To Human Disease Report Clinical Information";
            public const string AccessToHumanDiseaseReportContactListSection = "Access To Human Disease Report Contact List section";
            public const string AccessToHumanDiseaseReportData2 = "Access To Human Disease Report Data";
            public const string AccessToHumanDiseaseReportFinalOutcomeSection = "Access To Human Disease Report Final Outcome section";
            public const string AccessToHumanDiseaseReportNotificationSection = "Access To Human Disease Report Notification section";
            public const string AccessToHumanDiseaseReportSummarySection = "Access To Human Disease Report Summary section";
            public const string AccessToHumanStandardReports = "Access To Human Standard Reports";
            public const string AccessToHumanSyndromeList = "Access To Human Syndrome List";
            public const string AccessToLaboratoryStandardReports = "Access To Laboratory Standard Reports";
            public const string AccessToNeighboringSiteData = "Access To neighboring site data";
            public const string AccessToResourceEditor = "Access To Resource Editor";
            public const string AccessToVeterinaryStandardReports = "Access To Veterinary Standard Reports";
            public const string CanEditSampleTransferFormsAfterTransferIsSaved = "Can Edit Sample Transfer forms after Transfer Is saved";
            public const string CanExecuteFarmRecordDeduplicationFunction = "Can Execute Farm Record Deduplication Function";
            public const string CanExecuteHumanAggregateDiseaseReportDeduplicationFunction = "Can Execute Human Aggregate Disease Report Deduplication Function";
            public const string CanExecutePersonRecordDeduplicationFunction = "Can Execute Person Record Deduplication Function";
            public const string CanExecuteVeterinaryAggregateActionDeduplicationFunction = "Can Execute Veterinary Aggregate Action Deduplication Function";
            public const string CanExecuteVeterinaryAggregateDiseaseReportDeduplicationFunction = "Can Execute Veterinary Aggregate Disease Report Deduplication Function";
            public const string CanExecuteVeterinaryAvianDiseaseReportDeduplicationFunction = "Can Execute Veterinary Avian Disease Report Deduplication Function";
            public const string CanExecuteVeterinaryLivestockDiseaseReportDeduplicationFunction = "Can Execute Veterinary Livestock  Disease Report Deduplication Function";
            public const string CanManageAccessToNeighboringSites = "Can manage access To neighboring sites";
            public const string CanManageAccessToPersonalDataAtNeighboringSites = "Can manage access To personal data at neighboring sites";
            public const string CanManageColumnDisplayInGrids = "Can manage column display In grids";
            public const string CanManageConfigurations = "Can manage Configurations";
            public const string CanManageConfigurations2 = "Can manage Configurations";
            public const string CanManageDashboardLayout = "Can manage dashboard layout";
            public const string CanManageDiseaseList = "Can manage Disease List";
            public const string CanManageEIDSSSites = "Can Manage EIDSS Sites";
            public const string CanManageReferenceDataTables = "Can manage Reference Data Tables";
            public const string CanModifyAccessionDateAfterSave = "Can Modify Accession Date after Save";
            public const string CanModifyAutopopulatedDatesWithinLaboratoryModule = "Can modify autopopulated dates within the lab Module";
            public const string CanModifyRulesOfConfigurableFiltration = "Can modify rules Of configurable filtration";
            public const string CanModifyStatusOfRejectedSample = "Can modify status Of Rejected sample";
            public const string CanSetSessionActivityTimeoutTime = "Can Set session activity timeout time";
            public const string CanViewListOfChangesCapturedInDataAuditLogMadeToAttributeOfObject = "Can view list Of changes captured In Data Audit log made To an attribute Of an Object";
            public const string CanViewListOfChangesCapturedInDataAuditLogMadeToObject = "Can view list Of changes captured In Data Audit log made To an Object";
            public const string ExportToWHOCISID = "Export To WHO (CISID)";
            public const string DataArchiveSettings = "Data Archive Settings";
        }

        public struct PermissionLevelConstants
        {
            public const string AccessToPersonalData = "Access To Personal Data";
            public const string AccessToGenderAndAgeData = "Access to Gender and Age Data";
            public const string Create = "Create";
            public const string Delete = "Delete";
            public const string Read = "Read";
            public const string Write = "Write";
            public const string Execute = "Execute";
        }

        public struct CommonNameConstants
        {
            public const string Countries = "Countries";
        }

        public struct DiagnosisConstants
        {
            public const string DiagnosisID = "idfsDiagnosis";
            public const string DiagnosisName = "strName";
            public const string ReportDiagnosisName = "name";
        }

        public struct CaseTypes
        {
            public const Int64 Human = 10012001;
            public const Int64 Livestock = 10012003;
            public const Int64 Avian = 10012004;
            public const Int64 Veterinary = 10012005;
            public const Int64 Vector = 10012006;
        }

        public struct FlexFormTypes
        {
            public const Int64 AvianFarmEPI = 10034007;
            public const Int64 HumanEpiInvestigations = 10034011;
            public const Int64 LivestockFarmEPI = 10034015;
            public const Int64 OutbreakHumanCQ = 10034501;
            public const Int64 OutbreakLivestockCQ = 10034502;
            public const Int64 OutbreakAvianCQ = 10034503;
            public const Int64 OutbreakHumanCaseCM = 10034504;
            public const Int64 OutbreakLivestockCaseCM = 10034505;
            public const Int64 OutbreakAvianCaseCM = 10034506;
            public const Int64 OutbreakHumanContactCT = 10034507;
            public const Int64 OutbreakFarmLivestockContactCT = 10034508;
            public const Int64 OutbreakFarmAvianCT = 10034509;
            public const Int64 OutbreakVectorCM = 0;
            public const Int64 OutbreakVectorCT = 0;
        }

        public struct SessionNames
        {
            public const string SESSION_ACCESSION_CONDITION_TYPES_DROP_DOWN = "AccessionConditionType_DDL";
            public const string SESSION_TEST_RESULT_TYPES_DROP_DOWN = "TestResultType_DDL";
            public const string SESSION_TEST_NAME_TYPE_DROP_DOWN = "TestNameTypeDDL";
            public const string SESSION_TEST_STATUS_TYPES_DROP_DOWN_ALL = "TestStatusType_DDL_All";
            public const string SESSION_TEST_STATUS_TYPES_DROP_DOWN_RESTRICTED = "TestStatusType_DDL_Restricted";
            public const string SESSION_TEST_CATEGORY_TYPES_DROP_DOWN = "TestCategoryType_DDL";
            public const string SESSION_EIDSS_MENU = "EIDSSMenu";
        }

        public struct ReportParameters
        {
            public const string ReportPreparedByOrganiztion = "Ministry Of Labour,Health And Social Affairs Of Georgia";
        }

        public struct PageNames
        {
            public const string LABORATORY_PAGE = "Laboratory.aspx";
            public const string HUM_ACTIVESURVEILLANCECAMPAIGN = "ActiveSurveillanceCampaign.aspx";
            public const string HUM_ACTIVESURVEILLANCESESSION = "ActiveSurveillanceSession.aspx";
            public const string HUM_AGGREGATEDISEASEREPORT = "AggregateDiseaseReport.aspx";
            public const string HUM_ILIAGGREGATEREPORT = "ILIAggregateReport.aspx";

            public const string VET_AGGREGATEDISEASEREPORT = "AggregateDiseaseReport.aspx";
            public const string VET_AGGREGATEACTION = "AggregateActionReport.aspx";
            public const string VET_ACTIVESURVEILLANCECAMPAIGN = "ActiveSurveillanceCampaign.aspx";
            public const string VET_ACTIVESURVEILLANCESESSION = "ActiveSurveillanceSession.aspx";
            public const string VET_AVIAN = "AvianDiseaseReport.aspx";
            public const string VET_LIVESTOCK = "LivestockDiseaseReport.aspx";
            public const string Dashboard = "DASHBOARD";
        }

        public struct AuditPrimaryTables
        {
            // Human Module tables
            public const string HUM_CAMPAIGN = "tlbCampaign";

            public const string HUM_MONITORINGSESSION = "tlbMonitoringSession";
            public const string HUM_AGGREGATECASE = "tlbAggrCase";
            public const string HUM_ILIAGGREGATEREPORT = "tlbBasicSyndromicSurveillanceAggregateHeader";
            public const string HUM_DISEASEREPORT = "tlbHumCase";

            public const string VET_DISEASEREPORT = "tlbVetCase";
            public const string VET_AGGREGATECASE = "tlbAggrCase";
            public const string VET_AGGREGATEACTION = "tlbAggrCase";
            public const string VET_MONITORINGSESSION = "tlbMonitoringSession";
            public const string VET_CAMPAIGN = "tlbCampaign";
            public const string VET_AVIAN = "tlbVetCase";
            public const string VET_LIVESTOCN = "tlbVetCase";
        }

        public struct LoginErrors
        {
            public const string LOCKED_OUT = "locked_out";
            public const string GRANT_TYPE = "invalid_grant";
        }

        public struct CultureNames
        {
            public const string enUS = "en-US";
        }

        public struct ReportDiseaseGroupType
        {
            public const long Disease = 19000019;
            public const long ReportDiseaseGroup = 19000130;
        }

        public struct ReportDiseaseGroupTypeConstants
        {
            public const string Disease = "Disease";
            public const string ReportDiseaseGroup = "Report Disease Group";
        }

        public struct DialogResultConstants
        {
            public const string No = "No";
            public const string OK = "OK";
            public const string Yes = "Yes";
            public const string Accession = "Accession";
            public const string Add = "Add";
            public const string AssignTest = "Assign Test";
            public const string PrintBarcodes = "Print Barcodes";
            public const string Save = "Save";
            public const string Select = "Select";
            public const string Transfer = "Transfer";
            public const string SelectAll = "Select All";
        }

        public struct LaboratorySearchStorageConstants
        {
            public const string TestUnassignedSearchPerformedIndicator = "LaboratoryTestUnassignedSearchPerformed";
            public const string TestCompletedSearchPerformedIndicator = "LaboratoryCompletedSearchPerformed";
            public const string AdvancedSearchPerformedIndicator = "LaboratoryAdvancedSearchPerformed";
            public const string SamplesSearchString = "SamplesSearchString";
            public const string TestingSearchString = "TestingSearchString";
            public const string TransferredSearchString = "TransferredSearchString";
            public const string MyFavoritesSearchString = "MyFavoritesSearchString";
            public const string BatchesSearchString = "BatchesSearchString";
            public const string ApprovalsSearchString = "ApprovalsSearchString";
        }

        public struct ActiveSurveillanceSessionStatusIds
        {
            public const long Open = 10160000;
            public const long Closed = 10160001;
        }

        public struct PersonDeduplicationInfoConstants
        {
            public const string EIDSSPersonID = "EIDSSPersonID";
            public const string PersonalIDType = "PersonalIDType";
            public const string PersonalID = "PersonalID";
            public const string LastOrSurname = "LastOrSurname";
            public const string SecondName = "SecondName";
            public const string FirstOrGivenName = "FirstOrGivenName";
            public const string DateOfBirth = "DateOfBirth";
            public const string ReportedAge = "ReportedAge";
            public const string GenderTypeID = "GenderTypeID";
            public const string CitizenshipTypeID = "CitizenshipTypeID";
            public const string PassportNumber = "PassportNumber";
            public const string GenderTypeName = "GenderTypeName";
            public const string CitizenshipTypeName = "CitizenshipTypeName";
            public const string PersonalIDTypeName = "PersonalIDTypeName";
            public const string Age = "Age";
            public const string ReportedAgeUOMID = "ReportedAgeUOMID";
            public const string LastName = "LastName";
            public const string FirstName = "FirstName";
            public const string HumanGenderTypeID = "HumanGenderTypeID";
            public const string ReportAgeUOMID = "ReportAgeUOMID";
        }

        public struct PersonDeduplicationEmpConstants
        {
            public const string IsEmployedTypeID = "IsEmployedTypeID";
            public const string OccupationTypeID = "OccupationTypeID";
            public const string EmployerName = "EmployerName";
            public const string EmployedDateLastPresent = "EmployedDateLastPresent";
            public const string EmployerPhone = "EmployerPhone";
            public const string EmployerForeignAddressIndicator = "EmployerForeignAddressIndicator";
            public const string EmployerForeignAddressString = "EmployerForeignAddressString";
            public const string EmployeridfsRegion = "EmployeridfsRegion";
            public const string EmployeridfsRayon = "EmployeridfsRayon";
            public const string EmployeridfsSettlement = "EmployeridfsSettlement";
            public const string EmployerstrStreetName = "EmployerstrStreetName";
            public const string EmployerstrHouse = "EmployerstrHouse";
            public const string EmployerstrBuilding = "EmployerstrBuilding";
            public const string EmployerstrApartment = "EmployerstrApartment";
            public const string EmployerstrPostalCode = "EmployerstrPostalCode";
            public const string EmployeridfsCountry = "EmployeridfsCountry";
            public const string WorkPhone = "WorkPhone";
            public const string IsStudentTypeID = "IsStudentTypeID";
            public const string SchoolName = "SchoolName";
            public const string SchoolDateLastAttended = "SchoolDateLastAttended";
            public const string SchoolForeignAddressIndicator = "SchoolForeignAddressIndicator";
            public const string SchoolidfsCountry = "SchoolidfsCountry";
            public const string SchoolForeignAddressString = "SchoolForeignAddressString";
            public const string SchoolidfsRegion = "SchoolidfsRegion";
            public const string SchoolidfsRayon = "SchoolidfsRayon";
            public const string SchoolidfsSettlement = "SchoolidfsSettlement";
            public const string SchoolstrStreetName = "SchoolstrStreetName";
            public const string SchoolstrHouse = "SchoolstrHouse";
            public const string SchoolstrBuilding = "SchoolstrBuilding";
            public const string SchoolstrApartment = "SchoolstrApartment";
            public const string SchoolstrPostalCode = "SchoolstrPostalCode";
            public const string SchoolPhone = "SchoolPhone";
            public const string IsEmployedTypeName = "IsEmployedTypeName";
            public const string OccupationTypeName = "OccupationTypeName";
            public const string EmployerRegion = "EmployerRegion";
            public const string EmployerRayon = "EmployerRayon";
            public const string EmployerSettlement = "EmployerSettlement";
            public const string EmployerCountry = "EmployerCountry";
            public const string IsStudentTypeName = "IsStudentTypeName";
            public const string SchoolRegion = "SchoolRegion";
            public const string SchoolRayon = "SchoolRayon";
            public const string SchoolSettlement = "SchoolSettlement";
            public const string SchoolCountry = "SchoolCountry";
            public const string EmployerGeoLocationID = "EmployerGeoLocationID";
            public const string SchoolGeoLocationID = "SchoolGeoLocationID";
            public const string EmployeridfsSettlementType = "EmployeridfsSettlementType";
            public const string SchoolAltidfsSettlementType = "SchoolAltidfsSettlementType";
            public const string EmployerSettlementType = "EmployerSettlementType";
            public const string SchoolAltSettlementType = "SchoolAltSettlementType";
            public const string YNEmployerForeignAddress = "YNEmployerForeignAddress";
            public const string YNSchoolForeignAddress = "YNSchoolForeignAddress";
            public const string YNWorkSameAddress = "YNWorkSameAddress";
        }

        public struct PersonDeduplicationAddressConstants
        {
            public const string HumanidfsRegion = "HumanidfsRegion";
            public const string HumanidfsRayon = "HumanidfsRayon";
            public const string HumanidfsSettlement = "HumanidfsSettlement";
            public const string HumanidfsSettlementType = "HumanidfsSettlementType";
            public const string HumanstrStreetName = "HumanstrStreetName";
            public const string HumanstrHouse = "HumanstrHouse";
            public const string HumanstrBuilding = "HumanstrBuilding";
            public const string HumanstrApartment = "HumanstrApartment";
            public const string HumanstrPostalCode = "HumanstrPostalCode";
            public const string HumanstrLatitude = "HumanstrLatitude";
            public const string HumanstrLongitude = "HumanstrLongitude";
            public const string HumanGeoLocationID = "HumanGeoLocationID";
            public const string HumanAltGeoLocationID = "HumanAltGeoLocationID";
            public const string HumanAltForeignAddressIndicator = "HumanAltForeignAddressIndicator";
            public const string HumanAltForeignAddressString = "HumanAltForeignAddressString";
            public const string HumanAltidfsRegion = "HumanAltidfsRegion";
            public const string HumanAltidfsRayon = "HumanAltidfsRayon";
            public const string HumanAltidfsSettlementType = "HumanAltidfsSettlementType";
            public const string HumanAltidfsSettlement = "HumanAltidfsSettlement";
            public const string HumanAltstrStreetName = "HumanAltstrStreetName";
            public const string HumanAltstrHouse = "HumanAltstrHouse";
            public const string HumanAltstrBuilding = "HumanAltstrBuilding";
            public const string HumanAltstrApartment = "HumanAltstrApartment";
            public const string HumanAltstrPostalCode = "HumanAltstrPostalCode";
            public const string HumanAltidfsCountry = "HumanAltidfsCountry";
            public const string ContactPhoneCountryCode = "ContactPhoneCountryCode";
            public const string ContactPhone = "ContactPhone";
            public const string ContactPhoneTypeID = "ContactPhoneTypeID";
            public const string ContactPhone2CountryCode = "ContactPhone2CountryCode";
            public const string ContactPhone2 = "ContactPhone2";
            public const string ContactPhone2TypeID = "ContactPhone2TypeID";
            public const string HumanRegion = "HumanRegion";
            public const string HumanRayon = "HumanRayon";
            public const string HumanSettlementType = "HumanSettlementType";
            public const string HumanSettlement = "HumanSettlement";
            public const string HumanCountry = "HumanCountry";
            public const string HumanAltRegion = "HumanAltRegion";
            public const string HumanAltRayon = "HumanAltRayon";
            public const string HumanAltSettlementType = "HumanAltSettlementType";
            public const string HumanAltSettlement = "HumanAltSettlement";
            public const string HumanAltCountry = "HumanAltCountry";
            public const string ContactPhoneTypeName = "ContactPhoneTypeName";
            public const string ContactPhone2TypeName = "ContactPhone2TypeName";
            public const string HumanidfsCountry = "HumanidfsCountry";
            public const string HumanForeignAddressIndicator = "HumanForeignAddressIndicator";
            public const string HumanForeignAddressString = "HumanForeignAddressString";
            public const string IsAnotherPhone = "IsAnotherPhone";
            public const string YNAnotherAddress = "YNAnotherAddress";
            public const string YNHumanAltForeignAddress = "YNHumanAltForeignAddress";
            public const string YNPermanentSameAddress = "YNPermanentSameAddress";
            public const string HumanPermidfsRegion = "HumanPermidfsRegion";
            public const string HumanPermidfsRayon = "HumanPermidfsRayon";
            public const string HumanPermidfsSettlementType = "HumanPermidfsSettlementType";
            public const string HumanPermidfsSettlement = "HumanPermidfsSettlement";
            public const string HumanPermstrStreetName = "HumanPermstrStreetName";
            public const string HumanPermstrHouse = "HumanPermstrHouse";
            public const string HumanPermstrBuilding = "HumanPermstrBuilding";
            public const string HumanPermstrApartment = "HumanPermstrApartment";
            public const string HumanPermstrPostalCode = "HumanPermstrPostalCode";
            public const string HumanPermRegion = "HumanPermRegion";
            public const string HumanPermRayon = "HumanPermRayon";
            public const string HumanPermSettlement = "HumanPermSettlement";
            public const string HumanPermSettlementType = "HumanPermSettlementType";
            public const string HumanPermGeoLocationID = "HumanPermGeoLocationID";
        }

        public struct SiteAlertTypes
        {
            public const string Site = "Site";
            public const string Originator = "Originator";
            public const string AllSites = "All Sites";
        }

        public struct TestStatuses
        {
            public const long Final = 10001001;
        }

        public struct DashboardGrids
        {
            public const string Notifications = "dashBGridNotifications";
            public const string MyNotifications = "dashBGridMyNotifications";
            public const string Investigations = "dashBGridInvestigations";
            public const string MyInvestigations = "dashBGridMyInvestigations";
            public const string UnaccessionedSamples = "dashBGridUnaccessioned Samples";
            public const string Approvals = "dashBGridApprovals";
            public const string MyCollections = "dashBGridMyCollections";
            public const string Users = "dashBGridUsers";
        }

        public struct FarmDeduplicationFarmDetailsConstants
        {
            public const string FarmType = "FarmTypeName";
            public const string FarmID = "EIDSSFarmID";
            public const string FarmName = "FarmName";
            public const string FarmOwnerLastName = "FarmOwnerLastName";
            public const string FarmOwnerFirstName = "FarmOwnerFirstName";
            public const string FarmOwnerSecondName = "FarmOwnerSecondName";
            public const string FarmOwnerID = "FarmOwnerID";
            public const string Phone = "Phone";
            public const string Fax = "Fax";
            public const string Email = "Email";
            public const string ModifiedDate = "ModifiedDate";
            public const string Country = "FarmAddressAdministrativeLevel0Name";
            public const string Region = "FarmAddressAdministrativeLevel1Name";
            public const string Rayon = "FarmAddressAdministrativeLevel2Name";
            public const string SettlementType = "FarmAddressSettlementTypeName";
            public const string Settlement = "FarmAddressAdministrativeLevel3Name";
            public const string Street = "FarmAddressStreetName";
            public const string Building = "FarmAddressBuilding";
            public const string Apartment = "FarmAddressApartment";
            public const string House = "FarmAddressHouse";
            public const string PostalCode = "FarmAddressPostalCode";
            public const string Longitude = "FarmAddressLatitude";
            public const string Latitude = "FarmAddressLongitude";
            public const string FarmTypeID = "FarmTypeID";
            public const string RegionID = "FarmAddressAdministrativeLevel1ID";
            public const string RayonID = "FarmAddressAdministrativeLevel2ID";
            public const string SettlementID = "FarmAddressAdministrativeLevel3ID";
            public const string SettlementTypeID = "FarmAddressSettlementTypeID";
            public const string CountryID = "FarmAddressAdministrativeLevel0ID";
            public const string FarmAddressID = "FarmAddressID";
            public const string FarmAddressLocationID = "FarmAddressLocationID";
            public const string EIDSSFarmOwnerID = "EIDSSFarmOwnerID";
            public const string AvianFarmTypeID = "AvianFarmTypeID";
            public const string AvianProductionTypeID = "AvianProductionTypeID";
            public const string OwnershipStructureTypeID = "OwnershipStructureTypeID";
            public const string NumberOfBuildings = "NumberOfBuildings";
            public const string NumberOfBirdsPerBuilding = "NumberOfBirdsPerBuilding";
            public const string FarmNationalName = "FarmNationalName";
            public const string FarmAddressStreet = "FarmAddressStreet";
            public const string FarmAddressIdfsLocation = "FarmAddressIdfsLocation";
        }

        public struct DiseasereportDeduplicationSummaryConstants
        {
            public const string Disease = "strFinalDiagnosis";
            public const string ReportID = "strCaseId";
            public const string LegacyID = "LegacyCaseID";
            public const string ReportStatus = "CaseProgressStatus";
            public const string PersonID = "EIDSSPersonID";
            public const string ReportType = "ReportType";
            public const string PersonName = "PatientFarmOwnerName";
            public const string DateEntered = "datEnteredDate";
            public const string EnteredBy = "EnteredByPerson";
            public const string EnteredByOrganization = "strOfficeEnteredBy";
            public const string DateLastUpdated = "datModificationDate";
            public const string CaseClassification = "SummaryCaseClassification";
            public const string DiseaseID = "idfsFinalDiagnosis";
            public const string ReportStatusID = "idfsCaseProgressStatus";
            public const string ReportTypeID = "DiseaseReportTypeID";
            public const string EnteredByPersonID = "idfPersonEnteredBy";
            public const string EnteredByOrganizationID = "idfOfficeEnteredBy";
        }

        public struct DiseasereportDeduplicationNotificationConstants
        {
            public const string CompletionPaperFormDate = "datCompletionPaperFormDate";
            public const string LocalIdentifier = "strLocalIdentifier";
            public const string Disease = "SummaryIdfsFinalDiagnosis";
            public const string DateOfDisease = "datDateOfDiagnosis";
            public const string NotificationDate = "datNotificationDate";
            public const string PatientStatus = "PatientStatus";
            public const string SentByOffice = "SentByOffice";
            public const string SentByPerson = "SentByPerson";
            public const string ReceivedByOffice = "ReceivedByOffice";
            public const string ReceivedByPerson = "ReceivedByPerson";
            public const string PatientCurrentLocation = "HospitalizationStatus";

            public const string OtherLocation = "strCurrentLocation";

            public const string DiseaseID = "idfsFinalDiagnosis";
            public const string PatientStatusID = "idfsFinalState";
            public const string SentByOfficeID = "idfSentByOffice";
            public const string SentByPersonID = "idfSentByPerson";
            public const string ReceivedByOfficeID = "idfReceivedByOffice";
            public const string ReceivedByPersonID = "idfReceivedByPerson";
            public const string PatientCurrentLocationID = "idfsHospitalizationStatus";
        }

        public struct DiseasereportDeduplicationSymptomsConstants
        {
            public const string OnSetDate = "datOnSetDate";
            public const string InitialCaseStatus = "InitialCaseStatus";
            public const string idfCSObservation = "idfCSObservation";
            public const string InitialCaseStatusID = "idfsInitialCaseStatus";
        }

        public struct DiseasereportDeduplicationFacilityDetailsConstants
        {
            public const string PreviouslySoughtCare = "PreviouslySoughtCare";
            public const string FacilityFirstSoughtCare = "strSoughtCareFacility";
            public const string FirstSoughtCareDate = "datFirstSoughtCareDate";
            public const string NonNotifiableDiagnosis = "NonNotifiableDiagnosis";
            public const string Hospitalization = "YNHospitalization";
            public const string HospitalName = "HospitalName";
            public const string HospitalizationDate = "datHospitalizationDate";
            public const string DischargeDate = "datDischargeDate";
            public const string PreviouslySoughtCareID = "idfsYNPreviouslySoughtCare";
            public const string FacilityFirstSoughtCareID = "idfSoughtCareFacility";
            public const string NonNotifiableDiagnosisID = "idfsNonNotifiableDiagnosis";
            public const string HospitalizationID = "idfsYNHospitalization";
            public const string HospitalID = "idfHospital";
            public const string idfsNonNotIFiableDiagnosis = "idfsNonNotIFiableDiagnosis";
        }

        public struct DiseasereportDeduplicationAntibioticVaccineHistoryConstants
        {
            public const string AntimicrobialTherapy = "YNAntimicrobialTherapy";
            public const string AntimicrobialTherapyName = "strAntibioticName";
            public const string Dosage = "strDosage";
            public const string FirstAdministeredDate = "datFirstAdministeredDate";
            public const string strAntibioticComments = "AdditionalComments";
            public const string SpecificVaccinationAdministered = "YNSpecificVaccinationAdministered";
            public const string VaccinationName = "VaccinationName";
            public const string VaccinationDate = "VaccinationDate";
            public const string AntimicrobialTherapyID = "idfsYNAntimicrobialTherapy";
            public const string SpecificVaccinationAdministeredID = "idfsYNSpecificVaccinationAdministered";
            public const string idfHumanCase = "idfHumanCase";
            public const string strClinicalNotes = "strClinicalNotes";
        }

        public struct DiseasereportDeduplicationSamplesConstants
        {
            public const string SampleCollected = "YNSpecimenCollected";
            public const string SampleCollectedID = "idfsYNSpecimenCollected";
            public const string idfHumanCase = "idfHumanCase";
        }

        public struct DiseasereportDeduplicationTestConstants
        {
            public const string TestCollected = "YNTestConducted";
            public const string TestCollectedID = "idfsYNTestsConducted";
            public const string idfHumanCase = "idfHumanCase";
        }

        public struct DiseasereportDeduplicationCaseInvestigationDetailsConstants
        {
            public const string InvestigatedByOffice = "InvestigatedByOffice";
            public const string StartDateofInvestigation = "StartDateofInvestigation";

            public const string Outbreak = "strOutbreakID";

            public const string Comments = "strNote";
            public const string ExposureLocationKnown = "YNExposureLocationKnown";
            public const string ExposureDate = "datExposureDate";
            public const string Description = "ExposureLocationDescription";
            public const string LocationType = "ExposureLocationType";
            public const string Country = "Country";
            public const string Region = "Region";
            public const string Rayon = "Rayon";
            public const string Settlement = "Settlement";
            public const string Latitude = "dblPointLatitude";
            public const string Longitude = "dblPointLongitude";
            public const string Elevation = "dblPointElevation";
            public const string GroundType = "strGroundType";
            public const string Distance = "dblPointDistance";
            public const string Direction = "dblPointAlignment";
            public const string PointForeignAddress = "strPointForeignAddress";

            public const string OutbreakID = "idfOutbreak";

            public const string ExposureLocationKnownID = "idfsYNExposureLocationKnown";
            public const string LocationTypeID = "idfsPointGeoLocationType";
            public const string RegionID = "idfsPointRegion";
            public const string RayonID = "idfsPointRayon";
            public const string SettlementID = "idfsPointSettlement";
            public const string CountryID = "idfsPointCountry";
            public const string InvestigatedByOfficeID = "idfInvestigatedByOffice";
            public const string GroundTypeID = "idfsPointGroundType";
            public const string LocationID = "idfPointGeoLocation";
            public const string GeoLocationTypeID = "idfsGeoLocationType";
            public const string LocationCountryID = "idfsLocationCountry";
            public const string LocationRegionID = "idfsLocationRegion";
            public const string LocationRayonID = "idfsLocationRayon";
            public const string LocationSettlementID = "idfsLocationSettlement";
            public const string LocationLatitude = "intLocationLatitude";
            public const string LocationLongitude = "intLocationLongitude";
            public const string LocationElevation = "intElevation";
            public const string LocationGroundTypeID = "idfsLocationGroundType";
            public const string LocationDistance = "intLocationDistance";
            public const string LocationDirection = "intLocationDirection";
            public const string ForeignAddress = "strForeignAddress";
        }

        public struct DiseasereportDeduplicationRiskFactorsConstants
        {
            public const string idfEpiObservation = "idfEpiObservation";
        }

        public struct DiseasereportDeduplicationContactsConstants
        {
            public const string idfHumanCase = "idfHumanCase";
        }

        public struct DiseasereportDeduplicationFinalOutcomeConstants
        {
            public const string FinalCaseStatus = "FinalCaseStatus";

            public const string DateofClassification = "DateofClassification";
            public const string BasisofDiagnosis = "strClinicalDiagnosis";
            public const string Outcome = "Outcome";

            public const string strEpidemiologistsName = "strEpidemiologistsName";

            public const string strSummaryNotes = "strSummaryNotes";
            public const string idfsFinalCaseStatus = "idfsFinalCaseStatus";
            public const string idfsOutCome = "idfsOutCome";
            public const string idfInvestigatedByPerson = "idfInvestigatedByPerson";
            public const string idfsOutcome = "idfsOutcome";
        }

        public struct VeterinaryDiseaseReportDeduplicationFarmDetailsConstants
        {
            public const string EIDSSReportID = "EIDSSReportID";
            public const string ReportStatus = "ReportStatusTypeName";
            public const string CaseClassification = "ClassificationTypeName";
            public const string LegacyID = "LegacyID";
            public const string EIDSSFieldAccessionID = "EIDSSFieldAccessionID";
            public const string EIDSSOutbreakID = "EIDSSOutbreakID";
            public const string EIDSSParentMonitoringSessionID = "EIDSSParentMonitoringSessionID";
            public const string ReportType = "ReportTypeName";
            public const string DiagnosisDate = "DiagnosisDate";
            public const string Disease = "DiseaseName";
            public const string FarmType = "FarmTypeName";
            public const string EIDSSFarmID = "EIDSSFarmID";
            public const string FarmName = "FarmName";
            public const string FarmOwnerLastName = "FarmOwnerLastName";
            public const string FarmOwnerFirstName = "FarmOwnerFirstName";
            public const string FarmOwnerSecondName = "FarmOwnerSecondName";
            public const string FarmOwnerID = "FarmOwnerID";
            public const string Phone = "Phone";
            public const string Fax = "Fax";
            public const string Email = "Email";
            public const string ModifiedDate = "ModifiedDate";
            public const string Country = "FarmAddressAdministrativeLevel0Name";
            public const string Region = "FarmAddressAdministrativeLevel1Name";
            public const string Rayon = "FarmAddressAdministrativeLevel2Name";
            public const string SettlementType = "FarmAddressSettlementTypeName";
            public const string Settlement = "FarmAddressAdministrativeLevel3Name";
            public const string Street = "FarmAddressStreetName";
            public const string Building = "FarmAddressBuilding";
            public const string Apartment = "FarmAddressApartment";
            public const string House = "FarmAddressHouse";
            public const string PostalCode = "FarmAddressPostalCode";
            public const string Longitude = "FarmAddressLatitude";
            public const string Latitude = "FarmAddressLongitude";
            public const string ReportStatusTypeID = "ReportStatusTypeID";
            public const string ClassificationTypeID = "ClassificationTypeID";
            public const string ReportTypeID = "ReportTypeID";
            public const string DiseaseID = "DiseaseID";
            public const string FarmTypeID = "FarmTypeID";
            public const string RegionID = "FarmAddressAdministrativeLevel1ID";
            public const string RayonID = "FarmAddressAdministrativeLevel2ID";
            public const string SettlementID = "FarmAddressAdministrativeLevel3ID";
            public const string SettlementTypeID = "FarmAddressSettlementTypeID";
            public const string CountryID = "FarmAddressAdministrativeLevel0ID";
            public const string FarmAddressID = "FarmAddressID";
            public const string FarmAddressLocationID = "FarmAddressLocationID";
            public const string EIDSSFarmOwnerID = "EIDSSFarmOwnerID";

            public const string FarmNationalName = "FarmNationalName";

            public const string FarmAddressStreet = "FarmAddressStreet";
            public const string FarmAddressIdfsLocation = "FarmAddressIdfsLocation";
            public const string StatusTypeID = "StatusTypeID";
            public const string OutbreakID = "OutbreakID";
            public const string MonitoringSessionID = "MonitoringSessionID";
            public const string FarmLongitude = "FarmAddressLatitude";
            public const string FarmLatitude = "FarmAddressLongitude";
            public const string ParentMonitoringSessionID = "ParentMonitoringSessionID";
            public const string FarmID = "FarmID";
            public const string FarmMasterID = "FarmMasterID";
            public const string ReceivedByOrganizationID = "ReceivedByOrganizationID";
            public const string ReceivedByPersonID = "ReceivedByPersonID";
            public const string ReportCategoryTypeID = "ReportCategoryTypeID";
            public const string FarmEpidemiologicalObservationID = "FarmEpidemiologicalObservationID";
            public const string ControlMeasuresObservationID = "ControlMeasuresObservationID";
            public const string TestsConductedIndicator = "TestsConductedIndicator";
            public const string OutbreakCaseIndicator = "OutbreakCaseIndicator";
        }

        public struct VeterinaryDiseaseReportDeduplicationNotificationConstants
        {
            public const string ReportedByOrganizationName = "ReportedByOrganizationName";
            public const string ReportedByPersonName = "ReportedByPersonName";
            public const string ReportDate = "ReportDate";
            public const string InvestigatedByOrganizationName = "InvestigatedByOrganizationName";
            public const string InvestigatedByPersonName = "InvestigatedByPersonName";
            public const string AssignedDate = "AssignedDate";
            public const string InvestigationDate = "InvestigationDate";
            public const string SiteName = "SiteName";
            public const string EnteredByPersonName = "EnteredByPersonName";
            public const string EnteredDate = "EnteredDate";
            public const string ReportedByOrganizationID = "ReportedByOrganizationID";
            public const string ReportedByPersonID = "ReportedByPersonID";
            public const string InvestigatedByOrganizationID = "InvestigatedByOrganizationID";
            public const string InvestigatedByPersonID = "InvestigatedByPersonID";
            public const string FarmEpidemiologicalObservationID = "FarmEpidemiologicalObservationID";
            public const string ControlMeasuresObservationID = "ControlMeasuresObservationID";
            public const string SiteID = "SiteID";
        }

        public static readonly string[] SubAreas = { "/AJ/", "/GG/", "/DEDUPLICATION/", "/SECURITY/" };

        public struct PaperFormsMenu
        {
            public const string HumanDiseaseInvestigationForm = "HumanDiseaseInvestigationForm";
            public const string AvianDiseaseInvestigationForm = "AvianDiseaseInvestigationForm";
            public const string LivestockDiseaseInvestigationForm = "LivestockDiseaseInvestigationForm";
            public const long PaperFormsParentMenuId = 10506101;
        }

        public struct PaperFormsFileName
        {
            public const string HumanDiseaseInvestigationForm = "General Case Investigation Form.pdf";
            public const string AvianDiseaseInvestigationForm = "Investigation Form For Avian Disease Outbreaks.pdf";
            public const string LivestockDiseaseInvestigationForm = "Investigation Form For Livestock Disease Outbreaks.pdf";
        }
    }
}