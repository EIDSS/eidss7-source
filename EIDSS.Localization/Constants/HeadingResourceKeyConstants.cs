using EIDSS.Localization.Enumerations;

namespace EIDSS.Localization.Constants
{
    public class HeadingResourceKeyConstants
    {
        #region Common Resources

        public static readonly string EIDSSModalHeading = (int)InterfaceEditorResourceSetEnum.CommonHeadings + "137" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string EIDSSSuccessModalHeading = (int)InterfaceEditorResourceSetEnum.CommonHeadings + "2802" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string EIDSSWarningModalHeading = (int)InterfaceEditorResourceSetEnum.CommonHeadings + "2803" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string EIDSSErrorModalHeading = (int)InterfaceEditorResourceSetEnum.CommonHeadings + "2804" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LoginPageHeading = (int)InterfaceEditorResourceSetEnum.Login + "196" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string ReviewHeading = (int)InterfaceEditorResourceSetEnum.CommonHeadings + "234" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SearchCriteriaHeading = (int)InterfaceEditorResourceSetEnum.CommonHeadings + "242" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string ChooseFileForUpload = (int)InterfaceEditorResourceSetEnum.CommonHeadings + "245" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AdvancedSearchCriteriaHeading = (int)InterfaceEditorResourceSetEnum.CommonHeadings + "21" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SearchResultsHeading = (int)InterfaceEditorResourceSetEnum.CommonHeadings + "244" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string CommonHeadingsSuccessHeading = (int)InterfaceEditorResourceSetEnum.CommonHeadings + "967" + (long)InterfaceEditorTypeEnum.Heading;

        public static readonly string LocationSelectLocationHeading = (int)InterfaceEditorResourceSetEnum.Location + "3372" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LocationSetLocationHeading = (int)InterfaceEditorResourceSetEnum.Location + "4798" + (long)InterfaceEditorTypeEnum.Heading;		

        public static readonly string AddInvestigationTypeModalHeading = (int)InterfaceEditorResourceSetEnum.AddInvestigationTypeModal + "493" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AddPersonalIDTypeModalHeading = (int)InterfaceEditorResourceSetEnum.AddPersonalIDTypeModal + "768" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AddPositionModalHeading = (int)InterfaceEditorResourceSetEnum.AddPositionModal + "769" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AddSanitaryActionModalHeading = (int)InterfaceEditorResourceSetEnum.AddSanitaryActionModal + "770" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AddSpeciesModalHeading = (int)InterfaceEditorResourceSetEnum.AddSpeciesModal + "853" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AddVaccineRouteModalHeading = (int)InterfaceEditorResourceSetEnum.AddVaccineRouteModal + "933" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AddVaccineTypeModalHeading = (int)InterfaceEditorResourceSetEnum.AddVaccineTypeModal + "934" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AddRecordModalHeading = (int)InterfaceEditorResourceSetEnum.AddRecordModal + "4747" + (long)InterfaceEditorTypeEnum.Heading;

        public static readonly string CommonHeadingsPrintHeading = (int)InterfaceEditorResourceSetEnum.CommonHeadings + "4752" + (long)InterfaceEditorTypeEnum.Heading;

        #endregion

        #region Administration Module Resources

        public static readonly string DepartmentsHeading = (int)InterfaceEditorResourceSetEnum.OrganizationInformation + "66" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DepartmentDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.AddDepartmentModal + "557" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string OrganizationInfoHeading = (int)InterfaceEditorResourceSetEnum.OrganizationInformation + "156" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string OrganizationsPageHeading = (int)InterfaceEditorResourceSetEnum.Organizations + "176" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SystemPreferencesPageHeading = (int)InterfaceEditorResourceSetEnum.SystemPreferences + "185" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string UserPreferencesPageHeading = (int)InterfaceEditorResourceSetEnum.UserPreferences + "459" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SytemPreferencesDefault = (int)InterfaceEditorResourceSetEnum.SystemPreferences + "4852" + (long)InterfaceEditorTypeEnum.FieldLabel;
        public static readonly string DataArchivingSettingsNotSet = (int)InterfaceEditorResourceSetEnum.DataArchivingSettings + "4853" + (long)InterfaceEditorTypeEnum.FieldLabel;

        //SAUC01 and SAUC02 - Enter and Edit Employee Record
        public static readonly string AccountManagementHeading = (int)InterfaceEditorResourceSetEnum.Employees + "568" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AccountSettingsHeading = (int)InterfaceEditorResourceSetEnum.Employees + "569" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string EmployeeDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.Employees + "558" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string EmployeeRoleAndPermissionsModalHeading = (int)InterfaceEditorResourceSetEnum.Employees + "578" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LoginHeading = (int)InterfaceEditorResourceSetEnum.Employees + "565" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string EmployeePersonalInformationHeading = (int)InterfaceEditorResourceSetEnum.Employees + "705" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SystemFunctionsHeading = (int)InterfaceEditorResourceSetEnum.Employees + "579" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string UserGroupsAndPermissionsHeading = (int)InterfaceEditorResourceSetEnum.Employees + "573" + (long)InterfaceEditorTypeEnum.Heading;

        //SAUC03 - Search Employee Record
        public static readonly string EmployeeListPageHeading = (int)InterfaceEditorResourceSetEnum.SearchEmployees + "725" + (long)InterfaceEditorTypeEnum.Heading;

        //SAUC09 and SAUC10 - Enter and Edit Administrative Unit Record
        public static readonly string AdministrativeUnitDetailsAdministrativeUnitInformationHeading = (int)InterfaceEditorResourceSetEnum.AdministrativeUnitDetails + "2738" + (long)InterfaceEditorTypeEnum.Heading;

        //SAUC11 - Search Administrative Unit Record
        public static readonly string AdministrativeUnitsPageHeading = (int)InterfaceEditorResourceSetEnum.AdministrativeUnits + "2727" + (long)InterfaceEditorTypeEnum.Heading;

        //SAUC13 - Enter Statistical Data Record and SAUC14 - Edit Statistical Data Record
        public static readonly string StatisticalDataPageHeading = (int)InterfaceEditorResourceSetEnum.StatisticalData + "3588" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string StatisticalDataDetailsPageHeading = (int)InterfaceEditorResourceSetEnum.StatisticalData + "2677" + (long)InterfaceEditorTypeEnum.Heading;

        //SAUC17
        public static readonly string InterfaceEditorHeading = (int)InterfaceEditorResourceSetEnum.InterfaceEditor + "928" + (long)InterfaceEditorTypeEnum.Heading;
        
        //SAUC30 - Restore a Data Audit Log Transaction
        public static readonly string DataAuditLogDetailsDataAuditTransactionDetailsHeading = (int)InterfaceEditorResourceSetEnum.DataAuditLogDetails + "3594" + (long)InterfaceEditorTypeEnum.Heading;		

        //SAUC31 - Search for a Data Audit Log Transaction
        public static readonly string SearchDataAuditLogDataAuditTransactionLogHeading = (int)InterfaceEditorResourceSetEnum.SearchDataAuditLog + "3007" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SearchUserDataAuditLogEIDSSIDHeading = (int)InterfaceEditorResourceSetEnum.SearchUserDataAuditLog + "4749" + (long)InterfaceEditorTypeEnum.Heading;

        //SAUC32 - User Search for Data Audit Log Transactions
        public static readonly string SearchUserDataAuditLogDataAuditLogSearchHeading = (int)InterfaceEditorResourceSetEnum.SearchUserDataAuditLog + "3014" + (long)InterfaceEditorTypeEnum.Heading;

        //SAUC55 - Site Alerts Subscription
        public static readonly string SiteAlertsSubscriptionPageHeading = (int)InterfaceEditorResourceSetEnum.SiteAlertSubscriptions + "702" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SiteAlertsSubscriptionSearchHeading = (int)InterfaceEditorResourceSetEnum.SiteAlertSubscriptions + "2877" + (long)InterfaceEditorTypeEnum.Heading;

        //SAUC56 - Notifications
        public static readonly string SiteAlertMessengerModalSiteAlertMessengerHeading = (int)InterfaceEditorResourceSetEnum.SiteAlertMessengerModal + "3026" + (long)InterfaceEditorTypeEnum.Heading;

        //SAUC60 - System Event Log
        public static readonly string SystemEventsLogSystemEventLogHeading = (int)InterfaceEditorResourceSetEnum.SystemEventsLog + "4495" + (long)InterfaceEditorTypeEnum.Heading;		
        public static readonly string SystemEventsLogDateHeading = (int)InterfaceEditorResourceSetEnum.SystemEventsLog + "4235" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SystemEventsLogDescriptionHeading = (int)InterfaceEditorResourceSetEnum.SystemEventsLog + "4236" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SystemEventsLogUserHeading = (int)InterfaceEditorResourceSetEnum.SystemEventsLog + "4237" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SystemEventsLogActionDateHeading = (int)InterfaceEditorResourceSetEnum.SystemEventsLog + "4241" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SystemEventsLogActionHeading = (int)InterfaceEditorResourceSetEnum.SystemEventsLog + "4242" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SystemEventsLogResultHeading = (int)InterfaceEditorResourceSetEnum.SystemEventsLog + "4243" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SystemEventsLogObjectIDHeading = (int)InterfaceEditorResourceSetEnum.SystemEventsLog + "4244" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SystemEventsLogErrorTextHeading = (int)InterfaceEditorResourceSetEnum.SystemEventsLog + "4245" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SystemEventsLogProcessIDHeading = (int)InterfaceEditorResourceSetEnum.SystemEventsLog + "4246" + (long)InterfaceEditorTypeEnum.Heading;

        //SAUC61 - Security Event Log
        public static readonly string SecurityEventsLogSecurityEventLogHeading = (int)InterfaceEditorResourceSetEnum.SecurityEventsLog + "4491" + (long)InterfaceEditorTypeEnum.Heading;		
        public static readonly string SecurityEventsLogDateHeading = (int)InterfaceEditorResourceSetEnum.SecurityEventsLog + "4235" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SecurityEventsLogDescriptionHeading = (int)InterfaceEditorResourceSetEnum.SecurityEventsLog + "4236" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SecurityEventsLogUserHeading = (int)InterfaceEditorResourceSetEnum.SecurityEventsLog + "4237" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SecurityEventsLogActionDateHeading = (int)InterfaceEditorResourceSetEnum.SecurityEventsLog + "4241" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SecurityEventsLogActionHeading = (int)InterfaceEditorResourceSetEnum.SecurityEventsLog + "4242" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SecurityEventsLogResultHeading = (int)InterfaceEditorResourceSetEnum.SecurityEventsLog + "4243" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SecurityEventsLogObjectIDHeading = (int)InterfaceEditorResourceSetEnum.SecurityEventsLog + "4244" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SecurityEventsLogErrorTextHeading = (int)InterfaceEditorResourceSetEnum.SecurityEventsLog + "4245" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SecurityEventsLogProcessIDHeading = (int)InterfaceEditorResourceSetEnum.SecurityEventsLog + "4246" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SecurityEventsLogProcessTypeHeading = (int)InterfaceEditorResourceSetEnum.SecurityEventsLog + "4247" + (long)InterfaceEditorTypeEnum.Heading;

        #region Reference Editor Sub-Module Resources

        public static readonly string ActorsHeading = (int)InterfaceEditorResourceSetEnum.DiseasesReferenceEditor + "339" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AdditionalHeading = (int)InterfaceEditorResourceSetEnum.SystemPreferences + "17" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AgeGroupDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.AddAgeGroupModal + "119" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AgeGroupsReferenceEditorPageHeading = (int)InterfaceEditorResourceSetEnum.AgeGroupsReferenceEditor + "161" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AnimalAgeDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.SpeciesAnimalAgeMatrix + "332" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string BaseReferenceDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.AddBaseReferenceModal + "120" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string BaseReferenceEditorPageHeading = (int)InterfaceEditorResourceSetEnum.BaseReferenceEditor + "162" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string CaseClassificationDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.AddCaseClassificationModal + "121" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string CaseClassificationsReferenceEditorPageHeading = (int)InterfaceEditorResourceSetEnum.CaseClassificationsReferenceEditor + "163" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DataAccessDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.DiseasesReferenceEditor + "338" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DiseaseDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.AddDiseaseModal + "122" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DiseasesReferenceEditorPageHeading = (int)InterfaceEditorResourceSetEnum.DiseasesReferenceEditor + "170" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string GenericStatisticalTypeDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.AddGenericStatisticalTypeModal + "124" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string GenericStatisticalTypesReferenceEditorPageHeading = (int)InterfaceEditorResourceSetEnum.GenericStatisticalTypes + "173" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string MeasureDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.AddMeasureTypeModal + "125" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string MeasuresReferenceEditorPageHeading = (int)InterfaceEditorResourceSetEnum.MeasuresReferenceEditor + "175" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string PermissionsHeading = (int)InterfaceEditorResourceSetEnum.DataAccessDetailsModal + "944" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string ReportDiseaseGroupDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.AddReportDiseaseGroupModal + "128" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string ReportDiseaseGroupsReferenceEditorPageHeading = (int)InterfaceEditorResourceSetEnum.ReportDiseaseGroupsReferenceEditor + "180" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string RequiredHeading = (int)InterfaceEditorResourceSetEnum.SystemPreferences + "230" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SampleTypeDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.AddSampleTypeModal + "129" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SampleTypesReferenceEditorPageHeading = (int)InterfaceEditorResourceSetEnum.SampleTypesReferenceEditor + "182" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SearchActorsModalHeading = (int)InterfaceEditorResourceSetEnum.SearchActorsModal + "511" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SiteGroupTypeDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.AddSiteGroupTypeModal + "1006" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SiteTypeDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.AddSiteTypeModal + "1001" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SpeciesTypeDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.AddSpeciesTypeModal + "130" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SpeciesTypesReferenceEditorPageHeading = (int)InterfaceEditorResourceSetEnum.SpeciesTypesReferenceEditor + "183" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string UsersAndGroupsListModalHeading = (int)InterfaceEditorResourceSetEnum.SearchActorsModal + "510" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VectorSpeciesTypeDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.AddVectorSpeciesTypeModal + "132" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VectorSpeciesTypesReferenceEditorPageHeading = (int)InterfaceEditorResourceSetEnum.VectorSpeciesTypesReferenceEditor + "187" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VectorTypesReferenceEditorPageHeading = (int)InterfaceEditorResourceSetEnum.VectorTypesReferenceEditor + "191" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VectorTypeDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.AddVectorTypeModal + "136" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AddSampleTypeModal_SampleTypeDerivativeTypeDetails_Heading = (int) InterfaceEditorResourceSetEnum.AddSampleTypeModal + "743" + (long) InterfaceEditorTypeEnum.Heading;

        //SAUC64 - Settlement Type Reference Editor
        public static readonly string SettlementTypeReferenceEditorSettlementTypeEditorHeading = (int)InterfaceEditorResourceSetEnum.SettlementTypeReferenceEditor + "3023" + (long)InterfaceEditorTypeEnum.Heading;		
        public static readonly string SettlementTypeReferenceEditorSettlementTypeDetailsHeading = (int)InterfaceEditorResourceSetEnum.SettlementTypeReferenceEditor + "3024" + (long)InterfaceEditorTypeEnum.Heading;		

        #endregion

        #region Security Sub-Module Resources

        public static readonly string AccessRulesSearchPageHeading = (int)InterfaceEditorResourceSetEnum.SearchAccessRules + "164" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AccessRuleDetailsPageHeading = (int)InterfaceEditorResourceSetEnum.AccessRuleDetails + "164" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string GrantingActorHeading = (int)InterfaceEditorResourceSetEnum.AccessRuleDetails + "88" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string ReceivingActorsHeading = (int)InterfaceEditorResourceSetEnum.AccessRuleDetails + "213" + (long)InterfaceEditorTypeEnum.Heading;

        //SAUC25 - Search for a User Group
        public static readonly string SearchUserGroupsPageHeading = (int)InterfaceEditorResourceSetEnum.SearchUserGroups + "606" + (long)InterfaceEditorTypeEnum.Heading;

        //SAUC
        public static readonly string DashboardUsersHeading = (int)InterfaceEditorResourceSetEnum.Dashboard + "4780" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DashboardUNACCESSIONEDSAMPLESHeading = (int)InterfaceEditorResourceSetEnum.Dashboard + "4781" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DashboardINVESTIGATIONSHeading = (int)InterfaceEditorResourceSetEnum.Dashboard + "4782" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DashboardMYINVESTIGATIONSHeading = (int)InterfaceEditorResourceSetEnum.Dashboard + "4783" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DashboardNOTIFICATIONSHeading = (int)InterfaceEditorResourceSetEnum.Dashboard + "4784" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DashboardMYNOTIFICATIONSHeading = (int)InterfaceEditorResourceSetEnum.Dashboard + "4785" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DashboardMYCOLLECTIONSHeading = (int)InterfaceEditorResourceSetEnum.Dashboard + "4786" + (long)InterfaceEditorTypeEnum.Heading;

        //SAUC26 and 27 - Enter and Edit a User Group
        public static readonly string UserGroupDetailsPageHeading = (int)InterfaceEditorResourceSetEnum.UserGroupDetails + "611" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string UserGroupDetailsDashboardGridsHeading = (int)InterfaceEditorResourceSetEnum.UserGroupDetails + "623" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string UserGroupDetailsDashboardIconsHeading = (int)InterfaceEditorResourceSetEnum.UserGroupDetails + "622" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string UserGroupDetailsInformationHeading = (int)InterfaceEditorResourceSetEnum.UserGroupDetails + "612" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string UserGroupDetailsSystemFunctionsHeading = (int)InterfaceEditorResourceSetEnum.UserGroupDetails + "579" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string UserGroupDetailsUsersAndGroupsHeading = (int)InterfaceEditorResourceSetEnum.UserGroupDetails + "613" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string UserGroupDetailsYoucanselectuptosixiconsHeading = (int)InterfaceEditorResourceSetEnum.UserGroupDetails + "3920" + (long)InterfaceEditorTypeEnum.Heading;

        //SAUC29 - Create an EIDSS Site
        public static readonly string SiteDetailsActorsHeading = (int)InterfaceEditorResourceSetEnum.SiteDetails + "339" + (long)InterfaceEditorTypeEnum.Heading;

        //SAUC51 - Security Policy
        public static readonly string SecurityPolicyPageHeading = (int)InterfaceEditorResourceSetEnum.SecurityPolicy + "954" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SecurityPolicyPasswordPolicyHeading = (int)InterfaceEditorResourceSetEnum.SecurityPolicy + "962" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SecurityPolicyLockoutPolicyHeading = (int)InterfaceEditorResourceSetEnum.SecurityPolicy + "963" + (long)InterfaceEditorTypeEnum.Heading;

        //SAUC53 - Sites and Site Groups Management
        public static readonly string SearchSitesPageHeading = (int)InterfaceEditorResourceSetEnum.Sites + "628" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SiteDetailsPageHeading = (int)InterfaceEditorResourceSetEnum.SiteDetails + "633" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SiteDetailsSiteInformationHeading = (int)InterfaceEditorResourceSetEnum.SiteDetails + "659" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SiteDetailsPermissionsHeading = (int)InterfaceEditorResourceSetEnum.SiteDetails + "944" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SearchSiteGroupsPageHeading = (int)InterfaceEditorResourceSetEnum.SiteGroups + "640" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SiteGroupDetailsPageHeading = (int)InterfaceEditorResourceSetEnum.SiteGroupDetails + "644" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SiteGroupDetailsSiteGroupInfoHeading = (int)InterfaceEditorResourceSetEnum.SiteGroupDetails + "645" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SiteGroupDetailsSitesHeading = (int)InterfaceEditorResourceSetEnum.SiteGroupDetails + "646" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SearchOrganizationsSearchOrganizationsModalHeading = (int)InterfaceEditorResourceSetEnum.SearchOrganizations + "745" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AddOrganizationModalOrganizationDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.AddOrganizationModal + "746" + (long)InterfaceEditorTypeEnum.Heading;

        #endregion

        #region Deduplication Sub-Module Resources

        public static readonly string DeduplicationPersonPageHeading = (int)InterfaceEditorResourceSetEnum.DeduplicationPerson + "2647" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DeduplicationPersonPersonInformationSearchHeading = (int)InterfaceEditorResourceSetEnum.DeduplicationPerson + "2648" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DeduplicationPersonPersonInformationListHeading = (int)InterfaceEditorResourceSetEnum.DeduplicationPerson + "2649" + (long)InterfaceEditorTypeEnum.Heading;

        public static readonly string DeduplicationHumanReportPageHeading = (int)InterfaceEditorResourceSetEnum.DeduplicationHumanReport + "2645" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DeduplicationHumanReportHumanDiseaseReportSearchHeading = (int)InterfaceEditorResourceSetEnum.DeduplicationHumanReport + "2659" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DeduplicationHumanReportHumanDiseaseReportListHeading = (int)InterfaceEditorResourceSetEnum.DeduplicationHumanReport + "2646" + (long)InterfaceEditorTypeEnum.Heading;

        public static readonly string DeduplicationFarmPageHeading = (int)InterfaceEditorResourceSetEnum.DeduplicationFarm + "2650" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DeduplicationFarmFarmInformationSearchHeading = (int)InterfaceEditorResourceSetEnum.DeduplicationFarm + "2651" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DeduplicationFarmFarmInformationListHeading = (int)InterfaceEditorResourceSetEnum.DeduplicationFarm + "2652" + (long)InterfaceEditorTypeEnum.Heading;

        public static readonly string DeduplicationAvianReportPageHeading = (int)InterfaceEditorResourceSetEnum.DeduplicationAvianReport + "2653" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DeduplicationAvianReportAvianDiseaseReportSearchHeading = (int)InterfaceEditorResourceSetEnum.DeduplicationAvianReport + "2654" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DeduplicationAvianReportAvianDiseaseReportListHeading = (int)InterfaceEditorResourceSetEnum.DeduplicationAvianReport + "2655" + (long)InterfaceEditorTypeEnum.Heading;

        public static readonly string DeduplicationLivestockReportLivestockDiseaseReportDeduplicationHeading = (int)InterfaceEditorResourceSetEnum.DeduplicationLivestockReport + "2656" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DeduplicationLivestockReportLivestockDiseaseReportSearchHeading = (int)InterfaceEditorResourceSetEnum.DeduplicationLivestockReport + "2657" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DeduplicationLivestockReportLivestockDiseaseReportListHeading = (int)InterfaceEditorResourceSetEnum.DeduplicationLivestockReport + "2658" + (long)InterfaceEditorTypeEnum.Heading;

        //DDUC03
        public static readonly string DeduplicationPersonPersonDeduplicationHeading = (int)InterfaceEditorResourceSetEnum.DeduplicationPerson + "3188" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DeduplicationPersonPersonListHeading = (int)InterfaceEditorResourceSetEnum.DeduplicationPerson + "3189" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DeduplicationPersonPersonDeduplicationDetailsHeading = (int)InterfaceEditorResourceSetEnum.DeduplicationPerson + "3190" + (long)InterfaceEditorTypeEnum.Heading;
        
        //DDUC04
        public static readonly string FarmRecordDeduplicationFarmDeduplicationDetailsHeading = (int)InterfaceEditorResourceSetEnum.FarmRecordDeduplication + "3470" + (long)InterfaceEditorTypeEnum.Heading;

        //DDUC05
        public static readonly string DeduplicationLivestockReportLivestockDiseaseReportDeduplicationDetailsHeading = (int)InterfaceEditorResourceSetEnum.DeduplicationLivestockReport + "3589" + (long)InterfaceEditorTypeEnum.Heading;

        //DDUC06
        public static readonly string AvianDiseaseReportDeduplicationAvianDiseaseReportDeduplicationDetailsHeading = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportDeduplication + "3590" + (long)InterfaceEditorTypeEnum.Heading;
        
        #endregion

        #endregion

        #region Configuration Module Resources

        public static readonly string AgeGroupStatisticalAgeGroupDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.AgeGroupStatisticalAgeGroupMatrix + "118" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AgeGroupStatisticalAgeGroupMatrixPageHeading = (int)InterfaceEditorResourceSetEnum.AgeGroupStatisticalAgeGroupMatrix + "160" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AggregateSettingsPageHeading = (int)InterfaceEditorResourceSetEnum.AggregateSettings + "506" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string CustomReportRowsPageHeading = (int)InterfaceEditorResourceSetEnum.CustomReportRows + "947" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DeterminantsHeading = (int)InterfaceEditorResourceSetEnum.Template + "340" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DeterminantEditorHeading = (int)InterfaceEditorResourceSetEnum.DeterminantEditor + "68" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DiseaseAgeGroupMatrixPageHeading = (int)InterfaceEditorResourceSetEnum.DiseaseAgeGroupMatrix + "167" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DiseaseGroupDiseaseDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.DiseaseGroupDiseaseMatrix + "123" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DiseaseGroupDiseaseMatrixPageHeading = (int)InterfaceEditorResourceSetEnum.DiseaseGroupDiseaseMatrix + "166" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DiseaseSampleTypeMatrixPageHeading = (int)InterfaceEditorResourceSetEnum.DiseaseSampleTypeMatrix + "171" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DiseaseLabTestMatrixPageHeading = (int)InterfaceEditorResourceSetEnum.DiseaseLabTestMatrix + "168" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DiseasePensideTestMatrixPageHeading = (int)InterfaceEditorResourceSetEnum.DiseasePensideTestMatrix + "169" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanAggregateDiseaseReportMatrixPageHeading = (int)InterfaceEditorResourceSetEnum.HumanAggregateCaseMatrix + "174" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string MatrixVersionHeading = (int)InterfaceEditorResourceSetEnum.CommonHeadings + "114" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string MatrixDetailsHeading = (int)InterfaceEditorResourceSetEnum.CommonHeadings + "4464" + (long)InterfaceEditorTypeEnum.Heading;		
        public static readonly string ParameterDetailsHeading = (int)InterfaceEditorResourceSetEnum.ParameterDetails + "198" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string ParameterTypesEditorParametersHeading = (int)InterfaceEditorResourceSetEnum.ParameterTypesEditor + "199" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string ParameterTypeEditorPageHeading = (int)InterfaceEditorResourceSetEnum.ParameterTypesEditor + "177" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string PersonalIdentificationTypeMatrixPageHeading = (int)InterfaceEditorResourceSetEnum.PersonalIdentificationTypeMatrix + "178" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string PersonalIdentificationTypesDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.PersonalIdentificationTypeMatrix + "126" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string ReportDiseaseGroupDiseaseDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.ReportDiagnosisGroupDiagnosisMatrix + "128" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string ReportDiseaseGroupDiseaseMatrixPageHeading = (int)InterfaceEditorResourceSetEnum.ReportDiagnosisGroupDiagnosisMatrix + "179" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SampleTypeDerivativeTypeMatrixPageHeading = (int)InterfaceEditorResourceSetEnum.SampleTypeDerivativeTypeMatrix + "181" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SearchParametersHeading = (int)InterfaceEditorResourceSetEnum.ParameterEditor + "243" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SpeciesAnimalAgeDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.SpeciesAnimalAgeMatrix + "333" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SpeciesAnimalAgeMatrixPageHeading = (int)InterfaceEditorResourceSetEnum.SpeciesAnimalAgeMatrix + "184" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string TemplateDetailsHeading = (int)InterfaceEditorResourceSetEnum.TemplateEditor + "261" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string TemplateEditorHeading = (int)InterfaceEditorResourceSetEnum.TemplateEditor + "262" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string TemplatesHeading = (int)InterfaceEditorResourceSetEnum.ParameterTypesEditor + "263" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string TemplateTitleHeading = (int)InterfaceEditorResourceSetEnum.TemplateEditor + "265" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string TemplatesWhichUseThisParameterHeading = (int)InterfaceEditorResourceSetEnum.ParameterEditor + "264" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string TestTestResultDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.TestTestResultMatrix + "131" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string TestTestResultsMatrixPageHeading = (int)InterfaceEditorResourceSetEnum.TestTestResultMatrix + "186" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VectorTypeCollectionMethodDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.VectorTypeCollectionMethodMatrix + "133" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VectorTypeCollectionMethodMatrixPageHeading = (int)InterfaceEditorResourceSetEnum.VectorTypeCollectionMethodMatrix + "190" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VectorTypeFieldTestDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.VectorTypeFieldTestMatrix + "134" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VectorTypeFieldTestMatrixPageHeading = (int)InterfaceEditorResourceSetEnum.VectorTypeFieldTestMatrix + "188" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VectorTypeSampleTypeDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.VectorTypeSampleMatrix + "135" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VectorTypeSampleTypeMatrixPageHeading = (int)InterfaceEditorResourceSetEnum.VectorTypeSampleMatrix + "189" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryAggregateDiseaseReportMatrixPageHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateCaseMatrix + "192" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryDiagnosticInvestigationMatrixPageHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryDiagnosticInvestigationMatrix + "193" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryProphylacticMeasureMatrixPageHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryProphylacticMeasureMatrix + "194" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinarySanitaryActionMatrixPageHeading = (int)InterfaceEditorResourceSetEnum.VeterinarySanitaryActionMatrix + "195" + (long)InterfaceEditorTypeEnum.Heading;

        //fixing localization for AJ 11/14/2023
        public static readonly string VeterinaryAggregateCaseHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateCaseMatrix + "4851" + (long)InterfaceEditorTypeEnum.Heading;

        //SCUC11 - Configure Test – Test Results Matrix
        public static readonly string AddTestNameModalTestNameDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.AddTestNameModal + "952" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AddTestResultModalTestResultDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.AddTestResultModal + "953" + (long)InterfaceEditorTypeEnum.Heading;

        //SCUC12 - Configure Vector Type - Collection Method Matrix
        public static readonly string VectorTypeCollectionMethodMatrixCollectionMethodDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.VectorTypeCollectionMethodMatrix + "956" + (long)InterfaceEditorTypeEnum.Heading;

        //SCUC14 - Configure Vector Type - Field Test Matrix
        public static readonly string VectorTypeFieldTestMatrixPensideTestNameDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.VectorTypeFieldTestMatrix + "957" + (long)InterfaceEditorTypeEnum.Heading;

        //SCUC14 - Configure Custom Report Rows
        public static readonly string CustomReportRowsCustomReportRowDetailsHeading = (int)InterfaceEditorResourceSetEnum.CustomReportRows + "4232" + (long)InterfaceEditorTypeEnum.Heading;

        //SCUC22 - Configure Unique Numbering Schema
        public static readonly string UniqueNumberingSchemaPageHeading = (int)InterfaceEditorResourceSetEnum.UniqueNumberingSchema + "786" + (long)InterfaceEditorTypeEnum.Heading;

        //SCUC25 - Configure Data Archiving Settings
        public static readonly string DataArchivingSettingsPageHeading = (int)InterfaceEditorResourceSetEnum.DataArchivingSettings + "2671" + (long)InterfaceEditorTypeEnum.Heading;

        //SCUC31 - Configure Disease-Human Gender Matrix
        public static readonly string DiseaseHumanGenderMatrixPageHeading = (int)InterfaceEditorResourceSetEnum.DiseaseHumanGenderMatrix + "165" + (long)InterfaceEditorTypeEnum.Heading;

        //Flex Form
        public static readonly string FlexibleFormDesigner_FlexibleFormDesigner_Heading = (int)InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "741" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string FlexibleFormDesigner_SectionDetails_Heading = (int)InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "742" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string FlexibleFormDesignerFlexibleFormsDesignerHeading = (int)InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "172" + (long)InterfaceEditorTypeEnum.Heading;

        #endregion

        #region Human Module Resources

        //Human Module
        public static readonly string HumanAberrationAnalysisReportPageHeading = (int)InterfaceEditorResourceSetEnum.HumanAberrationAnalysisReport + "330" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanILIAberrationAnalysisReportPageHeading = (int)InterfaceEditorResourceSetEnum.ILIAberrationAnalysisReport + "331" + (long)InterfaceEditorTypeEnum.Heading;

        //HASUC01 - Enter Human Active Surveillance Campaign
        public static readonly string HumanActiveSurveillanceCampaignHumanActiveSurveillanceCampaignHeading = (int)InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "1816" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanActiveSurveillanceCampaignCampaignInformationHeading = (int)InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "1817" + (long)InterfaceEditorTypeEnum.Heading;

        //HASUC03 - Enter Human Active Surveillance Session and HASUC04 - Edit Human Active Surveillance Session
        public static readonly string HumanActiveSurveillanceSessionPageHeading = (int)InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "862" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanSessionDetailedInformationHeading = (int)InterfaceEditorResourceSetEnum.HumanSessionDetailedInformation + "887" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanSessionDetailedInformationPersonsAndSamplesHeading = (int)InterfaceEditorResourceSetEnum.HumanSessionDetailedInformation + "888" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanSessionSampleDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.HumanSessionSampleDetailsModal + "751" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanSessionTestsHeading = (int)InterfaceEditorResourceSetEnum.HumanSessionTests + "889" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanSessionActionsHeading = (int)InterfaceEditorResourceSetEnum.HumanSessionActions + "891" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanSessionDiseaseReportsHeading = (int)InterfaceEditorResourceSetEnum.HumanSessionDiseaseReports + "893" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanActiveSurveillanceSessionReviewHeading = (int)InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "234" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanActiveSurveillanceSessionSessionInformationHeading = (int)InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "863" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanActiveSurveillanceSessionDetailedInformationHeading = (int)InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "887" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanActiveSurveillanceSessionTestsHeading = (int)InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "889" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanActiveSurveillanceSessionActionsHeading = (int)InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "891" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanActiveSurveillanceSessionDiseaseReportsHeading = (int)InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "893" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanACtiveSurveillanceSessionInformationActionsHeading = (int)InterfaceEditorResourceSetEnum.SessionInformation + "891" + (long)InterfaceEditorTypeEnum.Heading;

        //HAUC01 and HAUC02 - Enter and Edit Human Aggregate Disease Report and HAUC03 - Search for Human Aggregate Diseases Report
        public static readonly string HumanAggregateDiseaseReportPageHeading = (int)InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "929" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanAggregateDiseaseReportReportDetailsHeading = (int)InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "930" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanAggregateDiseaseReportNotificationReceivedByHeading = (int)InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "931" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanAggregateDiseaseReportGeneralInfoHeading = (int)InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "932" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanAggregateDiseaseReportNotificationSentByHeading = (int)InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "757" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanAggregateDiseaseReportEnteredByHeading = (int)InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "758" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanAggregateDiseaseReportDiseaseMatrixHeading = (int)InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "759" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanAggregateDiseaseReportReviewHeading = (int)InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "234" + (long)InterfaceEditorTypeEnum.Heading;

        //HAUC06 - Enter ILI Aggregate Form, HAUC07 - Edit ILI Aggregate Form and HAUC08 - Search for ILI Aggregate Form
        public static readonly string ILIAggregatePageHeading = (int)InterfaceEditorResourceSetEnum.ILIAggregate + "2697" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string ILIAggregateDetailsILIAggregateDetailsHeading = (int)InterfaceEditorResourceSetEnum.ILIAggregateDetails + "2698" + (long)InterfaceEditorTypeEnum.Heading;

        //HUC01 - Search Person Use Case
        public static readonly string PersonPageHeading = (int)InterfaceEditorResourceSetEnum.Person + "597" + (long)InterfaceEditorTypeEnum.Heading;
        //TODO:  Remove the resource below - not needed - replace with resource above.  Code will need updating in Human/Person/Index view.
        public static readonly string SearchPersonPersonSearchPageHeading = (int)InterfaceEditorResourceSetEnum.SearchPerson + "597" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SearchPersonDateOfBirthHeading = (int)InterfaceEditorResourceSetEnum.SearchPerson + "2717" + (long)InterfaceEditorTypeEnum.Heading;
        
        public static readonly string SearchPersonModalDateOfBirthHeading = (int)InterfaceEditorResourceSetEnum.SearchPersonModal + "2717" + (long)InterfaceEditorTypeEnum.Heading;

        //HUC02 - Enter a Person Record and HUC04 - Edit a Person Record
        public static readonly string PersonReviewHeading = (int)InterfaceEditorResourceSetEnum.Person + "234" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string PersonInformationHeading = (int)InterfaceEditorResourceSetEnum.PersonInformation + "612" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string PersonAddressHeading = (int)InterfaceEditorResourceSetEnum.PersonAddress + "1050" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string PersonAddressCurrentAddressHeading = (int)InterfaceEditorResourceSetEnum.PersonAddress + "1061" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string PersonAddressAlternateAddressHeading = (int)InterfaceEditorResourceSetEnum.PersonAddress + "1102" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string PersonEmploymentSchoolInformationHeading = (int) InterfaceEditorResourceSetEnum.PersonEmploymentSchoolInformation + "1114" + (long) InterfaceEditorTypeEnum.Heading;
        public static readonly string PersonEmploymentSchoolInformationWorkAddressHeading = (int)InterfaceEditorResourceSetEnum.PersonEmploymentSchoolInformation + "1116" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string PersonEmploymentSchoolInformationSchoolAddressHeading = (int)InterfaceEditorResourceSetEnum.PersonEmploymentSchoolInformation + "1125" + (long)InterfaceEditorTypeEnum.Heading;

        //fix for localization 10/30/2023
        public static readonly string PermanentAddressAddressHeading = (int)InterfaceEditorResourceSetEnum.PersonAddress + "4849" + (long)InterfaceEditorTypeEnum.Heading;

        //fix of localization 10/20/2023
        public static readonly string PersonAddressModalHeading = (int)InterfaceEditorResourceSetEnum.PersonAddress + "4814" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string PersonPostalCodeModalHeading = (int)InterfaceEditorResourceSetEnum.PersonAddress + "4815" + (long)InterfaceEditorTypeEnum.Heading;

        //HUC03 - Enter a Human Disease Report and HUC05 - Edit a Human Disease Report
        public static readonly string HumanDiseaseReportHumanDiseaseReportHeading = (int)InterfaceEditorResourceSetEnum.HumanDiseaseReport + "1044" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanDiseaseReportDiseaseReportSummaryHeading = (int)InterfaceEditorResourceSetEnum.HumanDiseaseReportSummary + "1045" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanDiseaseReportPersonInformationHeading = (int)InterfaceEditorResourceSetEnum.HumanDiseaseReport + "2680" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanDiseaseReportNotificationHeading = (int)InterfaceEditorResourceSetEnum.HumanDiseaseReportNotification + "1046" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanDiseaseReportClinicalInformationSymptomsHeading = (int) InterfaceEditorResourceSetEnum.HumanDiseaseReportSymptoms + "1047" + (long) InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanDiseaseReportClinicalInformationFacilityDetailsHeading = (int) InterfaceEditorResourceSetEnum.HumanDiseaseReportFacilityDetails + "1048" + (long) InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanDiseaseReportAntibioticAntiviralHistoryHeading = (int) InterfaceEditorResourceSetEnum.HumanDiseaseReportAntibioticVaccineHistory + "1049" + (long) InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanDiseaseReportClinicalInformationAntibioticHeading = (int) InterfaceEditorResourceSetEnum.HumanDiseaseReportAntibioticVaccineHistory + "1051" + (long) InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanDiseaseReportAntibioticAntiviralTherapyHeading = (int) InterfaceEditorResourceSetEnum.HumanDiseaseReportAntibioticVaccineHistory + "1052" + (long) InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanDiseaseReportClinicalInformationVaccinationHeading = (int) InterfaceEditorResourceSetEnum.HumanDiseaseReportAntibioticVaccineHistory + "1053" + (long) InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanDiseaseReportSamplesDetailHeading = (int)InterfaceEditorResourceSetEnum.HumanDiseaseReportSampleDetailsModal + "1054" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanDiseaseReportTestsDetailHeading = (int)InterfaceEditorResourceSetEnum.HumanDiseaseReportTestDetailsModal + "1055" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanDiseaseReportExternalOrganizationHeading = (int)InterfaceEditorResourceSetEnum.HumanDiseaseReportTestDetailsModal + "1056" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanDiseaseReportInterpretationHeading = (int)InterfaceEditorResourceSetEnum.HumanDiseaseReportTestDetailsModal + "1057" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanDiseaseReportCaseInvestigationDetailsHeading = (int) InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1058" + (long) InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanDiseaseReportCaseInvestigationRiskFactorsHeading = (int) InterfaceEditorResourceSetEnum.HumanDiseaseReportRiskFactors + "1059" + (long) InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanDiseaseReportCaseInvestigationContactsHeading = (int) InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1060" + (long) InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanDiseaseReportContactsListHeading = (int)InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1062" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanDiseaseReportDemographicsHeading = (int)InterfaceEditorResourceSetEnum.ContactInformationModal + "1063" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanDiseaseReportContactDetailsHeading = (int)InterfaceEditorResourceSetEnum.ContactInformationModal + "1064" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanDiseaseReportFinalOutcomeHeading = (int)InterfaceEditorResourceSetEnum.HumanDiseaseReportFinalOutcome + "1065" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanDiseaseReportTestsHeading = (int)InterfaceEditorResourceSetEnum.HumanDiseaseReportTests + "889" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanDiseaseReportSamplesHeading = (int)InterfaceEditorResourceSetEnum.HumanDiseaseReportSamples + "664" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanDiseaseReportReviewHeading = (int)InterfaceEditorResourceSetEnum.HumanDiseaseReport + "234" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanDiseaseReportRiskFactorsListofRiskFactorsHeading = (int)InterfaceEditorResourceSetEnum.HumanDiseaseReportRiskFactors + "4807" + (long)InterfaceEditorTypeEnum.Heading;

        public static readonly string ContactInformationModalPhoneHeading = (int)InterfaceEditorResourceSetEnum.ContactInformationModal + "3191" + (long)InterfaceEditorTypeEnum.Heading;

        //HAUC05 - Enter Human Aggregate Disease Reports Summary
        public static readonly string HumanAggregateDiseaseReportSummaryHumanAggregateDiseaseReportsSummaryHeading = (int)InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportSummary + "1872" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanAggregateDiseaseReportSummaryDiseaseMatrixHeading = (int)InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportSummary + "759" + (long)InterfaceEditorTypeEnum.Heading;

        //HAUC09 - Search for Weekly Reporting Form
        public static readonly string SearchWeeklyReportingFormsPageHeading = (int)InterfaceEditorResourceSetEnum.SearchWeeklyReportingForms + "747" + (long)InterfaceEditorTypeEnum.Heading;

        //HAUC10 and HAUC11 - Enter and Edit Weekly Reporting Form 
        public static readonly string WeeklyReportingFormDetailsPageHeading = (int)InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "747" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string WeeklyReportingFormDetailsDetailsHeading = (int)InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "756" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string WeeklyReportingFormDetailsNotificationSentbyHeading = (int)InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "757" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string WeeklyReportingFormDetailsEnteredbyHeading = (int)InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "758" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string WeeklyReportingFormDetailsDiseaseMatrixHeading = (int)InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "759" + (long)InterfaceEditorTypeEnum.Heading;

        //HAUC13 - Enter Weekly Reporting Form Summary
        public static readonly string WeeklyReportingFormSummaryPageHeading = (int)InterfaceEditorResourceSetEnum.WeeklyReportingFormSummary + "773" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string WeeklyReportingFormSummaryNotifiableDiseaseAcuteFlaccidParalysisHeading = (int) InterfaceEditorResourceSetEnum.WeeklyReportingFormSummary + "774" + (long) InterfaceEditorTypeEnum.Heading;
        public static readonly string WeeklyReportingFormSummaryReportingPeriodHeading = (int)InterfaceEditorResourceSetEnum.WeeklyReportingFormSummary + "775" + (long)InterfaceEditorTypeEnum.Heading;

        #endregion

        #region Laboratory Module Resources

        //Laboratory Module
        public static readonly string LaboratoryPageHeading = (int)InterfaceEditorResourceSetEnum.Laboratory + "663" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LaboratorySamplesHeading = (int)InterfaceEditorResourceSetEnum.Laboratory + "664" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LaboratoryTestingHeading = (int)InterfaceEditorResourceSetEnum.Laboratory + "680" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LaboratoryTransferredHeading = (int)InterfaceEditorResourceSetEnum.Laboratory + "681" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LaboratoryMyFavoritesHeading = (int)InterfaceEditorResourceSetEnum.Laboratory + "684" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LaboratoryBatchesHeading = (int)InterfaceEditorResourceSetEnum.Laboratory + "682" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LaboratoryApprovalsHeading = (int)InterfaceEditorResourceSetEnum.Laboratory + "683" + (long)InterfaceEditorTypeEnum.Heading;

        //LUC01 - Accession a Sample
        public static readonly string LaboratoryGroupAccessionInModalHeading = (int)InterfaceEditorResourceSetEnum.Laboratory + "19" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string GroupAccessionInModalSelectSamplesHeading = (int)InterfaceEditorResourceSetEnum.GroupAccessionInModal + "4494" + (long)InterfaceEditorTypeEnum.Heading;		

        //LUC02 - Create an Aliquot/Derivative
        public static readonly string LaboratoryAliquotsDerivativesModalHeading = (int) InterfaceEditorResourceSetEnum.Laboratory + "537" + (long) InterfaceEditorTypeEnum.Heading;

        //LUC03 - Transfer a Sample
        public static readonly string LaboratoryTransferSampleModalHeading = (int)InterfaceEditorResourceSetEnum.Laboratory + "592" + (long)InterfaceEditorTypeEnum.Heading;

        //LUC04 - Assign a Test
        public static readonly string LaboratoryAssignTestModalHeading = (int)InterfaceEditorResourceSetEnum.Laboratory + "617" + (long)InterfaceEditorTypeEnum.Heading;

        //LUC06 - Edit a Transfer
        public static readonly string LaboratoryTransferDetailsHeading = (int)InterfaceEditorResourceSetEnum.Laboratory + "810" + (long)InterfaceEditorTypeEnum.Heading;

        //LUC07 - Amend Test Result
        public static readonly string LaboratoryAmendTestResultModalHeading = (int)InterfaceEditorResourceSetEnum.Laboratory + "625" + (long)InterfaceEditorTypeEnum.Heading;

        //LUC08 - Create a Batch
        public static readonly string LaboratoryCreateBatchModalHeading = (int)InterfaceEditorResourceSetEnum.Laboratory + "718" + (long)InterfaceEditorTypeEnum.Heading;

        //LUC09 - Edit a Batch
        public static readonly string LaboratoryBatchResultsDetailsModalHeading = (int) InterfaceEditorResourceSetEnum.Laboratory + "724" + (long) InterfaceEditorTypeEnum.Heading;
        public static readonly string BatchResultsDetailsModalQualityControlsHeading = (int)InterfaceEditorResourceSetEnum.BatchResultsDetailsModal + "2557" + (long)InterfaceEditorTypeEnum.Heading;

        //LUC10 - Enter a Sample
        public static readonly string RegisterNewSampleModalHeading = (int)InterfaceEditorResourceSetEnum.Laboratory + "18" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string RegisterNewSampleModalSearchPersonHeading = (int)InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "2926" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string RegisterNewSampleModalPersonHeading = (int)InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "597" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string RegisterNewSampleModalFarmHeading = (int)InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "2401" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string RegisterNewSampleModalSearchFarmHeading = (int)InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "3123" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string RegisterNewSampleModalHumanActiveSurveillanceSessionHeading = (int)InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "862" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string RegisterNewSampleModalHumanDiseaseReportHeading = (int)InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "1044" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string RegisterNewSampleModalOutbreakCaseHeading = (int)InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "2791" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string RegisterNewSampleModalVectorSurveillanceSessionHeading = (int)InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "2579" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string RegisterNewSampleModalVeterinaryActiveSurveillanceSessionHeading = (int)InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "2451" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string RegisterNewSampleModalVeterinaryDiseaseReportHeading = (int)InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "2792" + (long)InterfaceEditorTypeEnum.Heading;

        //LUC11 - Edit a Sample
        public static readonly string LaboratorySampleTestDetailsModalHeading = (int) InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "665" + (long) InterfaceEditorTypeEnum.Heading;
        public static readonly string LaboratorySampleTestDetailsModalSampleDetailsHeading = (int)InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "751" + (long)InterfaceEditorTypeEnum.Heading;

        //LUC12 - Edit a Test
        public static readonly string LaboratorySampleTestDetailsModalTestDetailsHeading = (int)InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "890" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LaboratorySampleTestDetailsModalAdditionalTestDetailsHeading = (int)InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "801" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LaboratorySampleTestDetailsModalAmendmentHistoryHeading = (int)InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "807" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LaboratorySampleTestDetailsModalQualityControlValuesHeading = (int)InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "987" + (long)InterfaceEditorTypeEnum.Heading;

        //LUC13 - Search for a Sample
        public static readonly string LaboratoryAdvancedSearchModalHeading = (int)InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "21" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LaboratoryAdvancedSearchDateRangeHeading = (int)InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "685" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LaboratoryAdvancedSearchTestResultDateRangeHeading = (int)InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "686" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string BatchesAddSampleToBatchHeading = (int)InterfaceEditorResourceSetEnum.Batches + "4388" + (long)InterfaceEditorTypeEnum.Heading;		

        //LUC15 - Lab Record Deletion
        public static readonly string LaboratorySampleDeletionHeading = (int)InterfaceEditorResourceSetEnum.Laboratory + "812" + (long)InterfaceEditorTypeEnum.Heading;

        //LUC18 - Laboratory Menu
        public static readonly string LaboratorySampleDestructionHeading = (int)InterfaceEditorResourceSetEnum.Laboratory + "1040" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LaboratoryLabRecordDeletionHeading = (int)InterfaceEditorResourceSetEnum.Laboratory + "1041" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LaboratoryPaperFormsHeading = (int)InterfaceEditorResourceSetEnum.Laboratory + "1042" + (long)InterfaceEditorTypeEnum.Heading;

        //LUC19 - Print Barcodes
        public static readonly string LaboratoryBarcodeLabelsHeading = (int)InterfaceEditorResourceSetEnum.Laboratory + "813" + (long)InterfaceEditorTypeEnum.Heading;

        //LUC20 - Configure Sample Storage Schema and LUC23 - Edit Sample Storage Schema
        public static readonly string FreezerDetailsSampleStorageSchemaHeading = (int)InterfaceEditorResourceSetEnum.FreezerDetails + "814" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string FreezerDetailsFreezerAttributesHeading = (int)InterfaceEditorResourceSetEnum.FreezerDetails + "815" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string FreezerDetailsSubdivisionAttributesHeading = (int)InterfaceEditorResourceSetEnum.FreezerDetails + "816" + (long)InterfaceEditorTypeEnum.Heading;

        //LUC22 - Search for a Freezer
        public static readonly string FreezersPageHeading = (int)InterfaceEditorResourceSetEnum.Freezers + "820" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string FreezersSearchFreezersModalHeading = (int)InterfaceEditorResourceSetEnum.Freezers + "821" + (long)InterfaceEditorTypeEnum.Heading;

        //LUC24, 25, 26, 27 - Printed Paper Forms
        public static readonly string LaboratorySampleReportHeading = (int)InterfaceEditorResourceSetEnum.Laboratory + "2872" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LaboratoryAccessionInFormHeading = (int)InterfaceEditorResourceSetEnum.Laboratory + "2873" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LaboratoryTestResultReportHeading = (int)InterfaceEditorResourceSetEnum.Laboratory + "2874" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LaboratoryTransferReportHeading = (int)InterfaceEditorResourceSetEnum.Laboratory + "2875" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LaboratoryDestructionReportHeading = (int)InterfaceEditorResourceSetEnum.Laboratory + "2876" + (long)InterfaceEditorTypeEnum.Heading;

        #endregion

        #region Reports Module Resources

        public static readonly string AdditionalIndicatorsOfAFPSurveillancePageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "964" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AdministrativeEventLogPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "283" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AdministrativeReportAuditLogPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "284" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AnalysisParametersHeading = (int)InterfaceEditorResourceSetEnum.Reports + "285" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AntibioticResistanceCardLMAPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "286" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AntibioticResistanceCardNCDCPHPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "287" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AssignmentForLaboratoryDiagnosticPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "288" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryReportFormVet1PageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "289" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryReportFormVet1APageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "290" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string BorderRayonsIncidenceComparativeReportPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "291" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string ComparativeReportOfInfectiousDiseasesConditionsByMonthsPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "292" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string ComparativeReportOfSeveralYearsByMonthsPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "293" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string ComparativeReportPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "294" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string ComparativeReportOfSeveralYearsByMonthPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "295" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string ConcordanceBetweenInitialAndFinalDiagnosisPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "296" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DataQualityIndicatorsPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "297" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string DataQualityIndicatorsForRayonsPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "298" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string ExternalComparativeReportPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "299" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanForm1A3PageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "300" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanForm1A4PageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "301" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanMonthlyMorbidityAndMortalityPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "302" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanReportOnTuberculosisCasesTestedForHIVPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "303" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanCasesByRayonAndDiseaseSummaryPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "304" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string IntermediaryReportByAnnualFormIV03PageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "305" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string IntermediaryReportByMonthlyFormIV031PageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "306" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string IntermediateReportByMonthlyFormIV03PageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "307" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string IntermediaryReportByMonthlyFormIV03Order0127NPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "308" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string IntermediaryReportByMonthlyFormIV03Order0182NPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "309" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SixtyBJournalPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "310" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LaboratoryTestingResultsPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "311" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string MainIndicatorsOfAFPSurveillancePageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "312" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string MicrobiologyResearchResultPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "313" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string ParametersHeading = (int)InterfaceEditorResourceSetEnum.Reports + "199" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string RabiesBulletinEuropeQuarterlySurveillanceSheetPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "315" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string ReportOfActivitiesConductedInVeterinaryLaboratoriesPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "316" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string ReportOnCasesOfAnnuallyReportableInfectiousDiseasesAnnualFormIV03Order101NPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "317" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string ReportOnCasesOfInfectiousDiseasesMonthlyFormIV031Order101NPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "318" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string ReportOnCertainDiseasesConditionsMonthlyFormIV03PageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "319" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string ReportOnCertainDiseasesConditionsMonthlyFormIV03Order0127NPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "320" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string ReportOnCertainDiseasesConditionsMonthlyFormIV03Order0182NPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "321" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SerologyResearchResultPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "322" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SummaryVeterinaryReportPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "323" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryActiveSurveillancePageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "324" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryYearlySituationPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "325" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryCaseReportPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "326" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryDataQualityIndicatorsPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "327" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string WHOReportOnMeaslesAndRubellaPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "328" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string ZoonoticComparativeReportByMonthsPageHeading = (int)InterfaceEditorResourceSetEnum.Reports + "1014" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string HumanReportsHumanCaseReportHeading = (int)InterfaceEditorResourceSetEnum.HumanReports + "4750" + (long)InterfaceEditorTypeEnum.Heading;

        //SRUC03 - Aberration Analysis - Vet
        public static readonly string AvianLivestockAberrationAnalysisReportPageHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAberrationAnalysisReport + "329" + (long)InterfaceEditorTypeEnum.Heading;

        //SYSUC12 - Print Barcodes
        public static readonly string PrintBarcodesPageHeading = (int)InterfaceEditorResourceSetEnum.PrintBarcodes + "2810" + (long)InterfaceEditorTypeEnum.Heading;

        #endregion

        #region Outbreak Module Resources

        //Outbreak Module
        public static readonly string OutbreakCasesOutbreakPersonSearchHeading = (int)InterfaceEditorResourceSetEnum.OutbreakCases + "3652" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string OutbreakCasesOutbreakFarmSearchHeading = (int)InterfaceEditorResourceSetEnum.OutbreakCases + "3653" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string OutbreakCasesImportHumanDiseaseReportHeading = (int)InterfaceEditorResourceSetEnum.OutbreakCases + "3654" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string OutbreakCasesImportVeterinaryDiseaseReportHeading = (int)InterfaceEditorResourceSetEnum.OutbreakCases + "3655" + (long)InterfaceEditorTypeEnum.Heading;

        //OMUC01, OMUC02
        public static readonly string OutbreakSessionOutbreakSummaryHeading = (int)InterfaceEditorResourceSetEnum.OutbreakSession + "977" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string OutbreakSessionOutbreakSessionHeading = (int)InterfaceEditorResourceSetEnum.OutbreakSession + "978" + (long)InterfaceEditorTypeEnum.Heading;

        public static readonly string CreateOutbreakOutbreakParametersHeading = (int)InterfaceEditorResourceSetEnum.CreateOutbreak + "1043" + (long)InterfaceEditorTypeEnum.Heading;

        public static readonly string OutbreakManagementListOutbreakManagementListHeading = (int)InterfaceEditorResourceSetEnum.OutbreakManagementList + "986" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string OutbreakManagementListSearchResultsHeading = (int)InterfaceEditorResourceSetEnum.OutbreakManagementList + "244" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string OutbreakManagementListOutbreakSessionListHeading = (int)InterfaceEditorResourceSetEnum.OutbreakManagementList + "3641" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string OutbreakManagementListOutbreakCasesListHeading = (int)InterfaceEditorResourceSetEnum.OutbreakManagementList + "4753" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string OutbreakManagementListSearchOutbreakHeading = (int)InterfaceEditorResourceSetEnum.OutbreakManagementList + "4801" + (long)InterfaceEditorTypeEnum.Heading;		

        public static readonly string OutbreakCaseInvestigationCaseQuestionnaireHeading = (int)InterfaceEditorResourceSetEnum.OutbreakCaseInvestigation + "3533" + (long)InterfaceEditorTypeEnum.Heading;

        //OMUC04, OMUC05
        public static readonly string CreateHumanCaseCaseDetailsHeading = (int)InterfaceEditorResourceSetEnum.CreateHumanCase + "3435" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string CreateHumanCaseCaseLocationHeading = (int)InterfaceEditorResourceSetEnum.CreateHumanCase + "3205" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string CreateHumanCaseClinicalInformationHeading = (int)InterfaceEditorResourceSetEnum.CreateHumanCase + "3207" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string CreateHumanCaseCaseInvestigationHeading = (int)InterfaceEditorResourceSetEnum.CreateHumanCase + "3540" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string CreateHumanCaseCaseMonitoringHeading = (int)InterfaceEditorResourceSetEnum.CreateHumanCase + "3208" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string CreateHumanCaseContactsHeading = (int)InterfaceEditorResourceSetEnum.CreateHumanCase + "3209" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string CreateHumanCaseOutbreakInvestigationHeading = (int)InterfaceEditorResourceSetEnum.CreateHumanCase + "3211" + (long)InterfaceEditorTypeEnum.Heading;

        //OMUC06 - Enter Veterinary Case and OMUC07 - Edit Veterinary Case
        public static readonly string CreateVeterinaryCaseCaseDetailsHeading = (int)InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3435" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string CreateVeterinaryCaseOutbreakDetailsHeading = (int)InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3436" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string CreateVeterinaryCaseNotificationHeading = (int)InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "1046" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string CreateVeterinaryCaseCaseLocationHeading = (int)InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3205" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string CreateVeterinaryCaseHerdFlockSpeciesInfoHeading = (int) InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3206" + (long) InterfaceEditorTypeEnum.Heading;
        public static readonly string CreateVeterinaryCaseClinicalInformationHeading = (int)InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3207" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string CreateVeterinaryCaseAnimalInvestigationsHeading = (int)InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3468" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string CreateVeterinaryCaseCaseMonitoringHeading = (int)InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3208" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string CreateVeterinaryCaseContactsHeading = (int)InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3209" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string CreateVeterinaryCaseVaccinationInformationHeading = (int)InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3210" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string CreateVeterinaryCaseOutbreakInvestigationHeading = (int)InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3211" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string CreateVeterinaryCaseSearchFarmHeading = (int)InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3123" + (long)InterfaceEditorTypeEnum.Heading;

        public static readonly string CreateVeterinaryCaseSamplesHeading = (int)InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "664" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string CreateVeterinaryCasePensideTestsHeading = (int)InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "2460" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string CreateVeterinaryCaseLabTestsInterpretationHeading = (int) InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3212" + (long) InterfaceEditorTypeEnum.Heading;
        public static readonly string CreateVeterinaryCaseOutbreakCaseReportReviewHeading = (int)InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3213" + (long)InterfaceEditorTypeEnum.Heading;

        //OMUC08-3
        public static readonly string OutbreakContactsOutbreakContactsListHeading = (int)InterfaceEditorResourceSetEnum.OutbreakContacts + "4751" + (long)InterfaceEditorTypeEnum.Heading;

        //OMUC11
        public static readonly string OutbreakContactsContactDetailsHeading = (int)InterfaceEditorResourceSetEnum.OutbreakContacts + "1064" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string OutbreakContactsContactPremiseHeading = (int)InterfaceEditorResourceSetEnum.OutbreakContacts + "3618" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string OutbreakContactsContactTracingHeading = (int)InterfaceEditorResourceSetEnum.OutbreakContacts + "2690" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string OutbreakContactsDemographicsHeading = (int)InterfaceEditorResourceSetEnum.OutbreakContacts + "1063" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string OutbreakContactsCurrentAddressHeading = (int)InterfaceEditorResourceSetEnum.OutbreakContacts + "1061" + (long)InterfaceEditorTypeEnum.Heading;

        //OMUC13
        public static readonly string OutbreakUpdatesNewRecordHeading = (int)InterfaceEditorResourceSetEnum.OutbreakUpdates + "2758" + (long)InterfaceEditorTypeEnum.Heading;

        //OMUC14
        public static readonly string OutbreakUpdatesEditRecordHeading = (int)InterfaceEditorResourceSetEnum.OutbreakUpdates + "2772" + (long)InterfaceEditorTypeEnum.Heading;

        //fixes for localization 10/20/2023
        public static readonly string OutbreakEpiCurveHeading = (int)InterfaceEditorResourceSetEnum.OutbreakAnalysis + "4816" + (long)InterfaceEditorTypeEnum.Heading;
        #endregion

        #region Vector Module Resources

        public static readonly string VectorSessionAddSurroundingModalHeading = (int)InterfaceEditorResourceSetEnum.VectorSessionAddSurrounding + "884" + (long)InterfaceEditorTypeEnum.Heading;

        //VSUC01 - Enter Vector Surveillance Session and VSUC02 - Edit Vector Surevillance Session
        public static readonly string VectorSurveillanceSessionSessionSummaryHeading = (int)InterfaceEditorResourceSetEnum.VectorSurveillanceSession + "2588" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VectorSurveillanceSessionSessionLocationHeading = (int)InterfaceEditorResourceSetEnum.VectorSurveillanceSession + "2589" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VectorAggregateCollectionAggregateCollectionsHeading = (int)InterfaceEditorResourceSetEnum.VectorAggregateCollection + "2590" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VectorDetailedCollectionDetailedCollectionsHeading = (int)InterfaceEditorResourceSetEnum.VectorDetailedCollection + "2591" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VectorDetailedCollectionCopyDetailedCollectionRecordModalHeading = (int)InterfaceEditorResourceSetEnum.VectorDetailedCollection + "2592" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VectorSurveillanceSessionReviewHeading = (int)InterfaceEditorResourceSetEnum.VectorSurveillanceSession + "234" + (long)InterfaceEditorTypeEnum.Heading;

        public static readonly string VectorDetailedCollectionHeading = (int)InterfaceEditorResourceSetEnum.VectorDetailedCollection + "2610" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VectorDetailedCollectionSessionSummaryHeading = (int)InterfaceEditorResourceSetEnum.VectorDetailedCollection + "2588" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VectorDetailedCollectionSamplesHeading = (int)InterfaceEditorResourceSetEnum.VectorDetailedCollection + "664" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VectorDetailedCollectionFieldTestsHeading = (int)InterfaceEditorResourceSetEnum.VectorDetailedCollection + "2615" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VectorDetailedCollectionLaboratoryTestsHeading = (int)InterfaceEditorResourceSetEnum.VectorDetailedCollection + "2616" + (long)InterfaceEditorTypeEnum.Heading;

        public static readonly string VectorSessionCollectionDataCollectionDataHeading = (int)InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "2611" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VectorSessionCollectionDataCollectionLocationHeading = (int)InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "2612" + (long)InterfaceEditorTypeEnum.Heading;
        
        public static readonly string VectorSessionVectorDataVectorDataHeading = (int)InterfaceEditorResourceSetEnum.VectorSessionVectorData + "2613" + (long)InterfaceEditorTypeEnum.Heading;
        
        public static readonly string VectorSessionVectorSpecificDataVectorSpecificDataHeading = (int)InterfaceEditorResourceSetEnum.VectorSessionVectorSpecificData + "2614" + (long)InterfaceEditorTypeEnum.Heading;

        public static readonly string VectorAggregateCollectionHeading = (int)InterfaceEditorResourceSetEnum.VectorAggregateCollection + "2637" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VectorAggregateCollectionCollectionLocationHeading = (int)InterfaceEditorResourceSetEnum.VectorAggregateCollection + "2612" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VectorAggregateCollectionListofDiseasesHeading = (int)InterfaceEditorResourceSetEnum.VectorAggregateCollection + "2638" + (long)InterfaceEditorTypeEnum.Heading;

        //VSUC03 - Search for Vector Surveillance Session
        public static readonly string VectorPageHeading = (int)InterfaceEditorResourceSetEnum.Vector + "2579" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VectorSurveillanceSessionsListPageHeading = (int)InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "4471" + (long)InterfaceEditorTypeEnum.Heading;

        #endregion

        #region Veterinary Module Resources

        public static readonly string VeterinaryActiveSurveillanceCampaignPageHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceCampaign + "2450" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AvianDiseaseReportPageHeading = (int)InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "2435" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LivestockDiseaseReportPageHeading = (int)InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "2436" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryDiseaseReportVaccinationsHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryDiseaseReportVaccinations + "2456" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VaccinationDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.VaccinationDetailsModal + "2457" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryDiseaseReportCaseLogHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryDiseaseReportCaseLog + "2466" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string CaseLogDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.CaseLogDetailsModal + "2467" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AvianDiseaseReportReviewHeading = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReport + "234" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LivestockDiseaseReportReviewHeading = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReport + "234" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryAggregateDiseaseReportPageHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReport + "2546" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryAggregateActionReportPageHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReport + "2547" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AvianAddTestCategoryModalHeading = (int)InterfaceEditorResourceSetEnum.AvianAddTestCategoryModal + "935" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LivestockAddTestCategoryModalHeading = (int)InterfaceEditorResourceSetEnum.LivestockAddTestCategoryModal + "935" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryDiseaseReportsListHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryReports + "3516" + (long)InterfaceEditorTypeEnum.Heading;

        //VASUC02 - Set Up Veterinary Active Surveillance Session and VASUC03 - Edit Veterinary Active Surveillance Session
        public static readonly string VeterinaryActiveSurveillanceSessionPageHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceSession + "2451" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinarySessionDetailedInformationHeading = (int)InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "887" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinarySessionDetailedInformationSearchFarmHeading = (int)InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "3123" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinarySessionDetailedInformationFarmListHeading = (int)InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2524" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinarySessionDetailedInformationFarmHerdSpeciesDetailsHeading = (int) InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2531" + (long) InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinarySessionDetailedInformationFarmFlockSpeciesDetailsHeading = (int) InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2532" + (long) InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinarySessionDetailedInformationDetailedAnimalsAndSamplesHeading = (int)InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2525" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinarySessionSampleDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.VeterinarySessionSampleDetailsModal + "751" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinarySessionTestsHeading = (int)InterfaceEditorResourceSetEnum.VeterinarySessionTests + "889" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinarySessionInterpretationDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.VeterinarySessionInterpretationDetailsModal + "2526" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinarySessionActionsHeading = (int)InterfaceEditorResourceSetEnum.VeterinarySessionActions + "891" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinarySessionAggregateInformationHeading = (int)InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2527" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinarySessionAggregateInformationFarmListHeading = (int)InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2524" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinarySessionAggregateInformationFarmHerdSpeciesDetailsHeading = (int)InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2531" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinarySessionAggregateInformationFarmFlockSpeciesDetailsHeading = (int)InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2532" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinarySessionAggregateInformationAggregateAnimalsAndSamplesHeading = (int)InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2528" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinarySessionAggregateInformationDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformationDetailsModal + "2529" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinarySessionSessionDiseaseReportsHeading = (int)InterfaceEditorResourceSetEnum.VeterinarySessionDiseaseReports + "893" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryActiveSurveillanceSessionReviewHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceSession + "234" + (long)InterfaceEditorTypeEnum.Heading;

        //VAUC05 - Enter Veterinary Aggregate Disease Report and VAUC06 - Edit Veterinary Aggregate Disease Report
        public static readonly string VeterinaryAggregateDiseaseReportReviewHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReport + "234" + (long)InterfaceEditorTypeEnum.Heading;

        //VAUC09 - Enter Veterinary Aggregate Action Report and VAUC10 - Edit Veterinary Aggregate Action Report
        public static readonly string VeterinaryAggregateActionReportReviewHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReport + "234" + (long)InterfaceEditorTypeEnum.Heading;

        //VAUC07 - Search for Veterinary Aggregate Disease Report and VAUC11 - Search for Veterinary Aggregate Action Report
        public static readonly string VeterinaryAggregateActionsReportInformationReportDetailsHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "930" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryAggregateDiseaseReportInformationReportDetailsHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "930" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryAggregateActionsReportInformationNotificationSentByHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "757" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryAggregateDiseaseReportInformationNotificationSentByHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "757" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryAggregateActionsReportInformationNotificationReceivedByHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "931" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryAggregateDiseaseReportInformationNotificationReceivedByHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "931" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryAggregateActionsReportInformationEnteredByHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "758" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryAggregateDiseaseReportInformationEnteredByHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "758" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryAggregateActionsReportInformationGeneralInfoHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "932" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryAggregateDiseaseReportInformationGeneralInfoHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "932" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryAggregateDiseaseReportDiseaseMatrixHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateReportMatrix + "759" + (long)InterfaceEditorTypeEnum.Heading;

        //VAUC13 - Enter Veterinary Aggregate Disease Reports Summary and VAUC14 - Enter Veterinary Aggregate Action Reports Summary
        public static readonly string VeterinaryAggregateDiseaseReportSummaryPageHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportSummary + "2548" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryAggregateActionReportSummaryPageHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReportSummary + "2549" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SelectedAggregateActionReportsHeading = (int)InterfaceEditorResourceSetEnum.SelectedAggregateActionReports + "2550" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryAggregateDiseaseReportSummarySummaryHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportSummary + "2551" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryAggregateActionReportSummarySummaryHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReportSummary + "2551" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryAggregateDiseaseReportSummarySearchHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportSummary + "2877" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryAggregateDiseaseReportSummarySummaryAggregateSettingsHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportSummary + "1873" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryAggregateDiseaseReportSummarySelectedAggregateDiseaseReportsHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportSummary + "1874" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string VeterinaryAggregateActionReportSummaryDiagnosticInvestigationsHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReportSummary + "4804" + (long)InterfaceEditorTypeEnum.Heading;		
        public static readonly string VeterinaryAggregateActionReportSummaryTreatmentProphylacticAndVaccinationMeasuresHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReportSummary + "4805" + (long)InterfaceEditorTypeEnum.Heading;		
        public static readonly string VeterinaryAggregateActionReportSummaryVeterinarySanitaryMeasuresHeading = (int)InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReportSummary + "4806" + (long)InterfaceEditorTypeEnum.Heading;		

        //VUC16 - Search for Farm Record
        public static readonly string SearchFarmsFarmOwnerHeading = (int)InterfaceEditorResourceSetEnum.SearchFarms + "2402" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string FarmPageHeading = (int)InterfaceEditorResourceSetEnum.SearchFarms + "2401" + (long)InterfaceEditorTypeEnum.Heading;

        //VUC17 - Enter New Farm Record
        public static readonly string FarmDetailsFarmInformationHeading = (int)InterfaceEditorResourceSetEnum.FarmDetails + "2421" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string FarmDetailsFarmAddressHeading = (int)InterfaceEditorResourceSetEnum.FarmDetails + "2422" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string FarmDetailsOwnershipStructureHeading = (int)InterfaceEditorResourceSetEnum.FarmDetails + "2423" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string FarmDetailsAvianFarmTypeHeading = (int)InterfaceEditorResourceSetEnum.FarmDetails + "2424" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string FarmDetailsFarmDetailsHeading = (int)InterfaceEditorResourceSetEnum.FarmDetails + "2425" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string FarmDetailsFarmReviewHeading = (int)InterfaceEditorResourceSetEnum.FarmDetails + "2426" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string FarmDetailsHerdsandSpeciesHeading = (int)InterfaceEditorResourceSetEnum.FarmDetails + "2427" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string FarmDetailsFlocksandSpeciesHeading = (int)InterfaceEditorResourceSetEnum.FarmDetails + "2428" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string FarmDetailsDiseaseReportsHeading = (int)InterfaceEditorResourceSetEnum.FarmDetails + "893" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string FarmDetailsOutbreakCasesHeading = (int)InterfaceEditorResourceSetEnum.FarmDetails + "2429" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string FarmDetailsReviewHeading = (int)InterfaceEditorResourceSetEnum.FarmDetails + "234" + (long)InterfaceEditorTypeEnum.Heading;

        //VUC04 - Enter Livestock Disease Report and VUC06 - Edit Livestock Disease Report
        public static readonly string LivestockDiseaseReportDiseaseReportSummaryHeading = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportSummary + "1045" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LivestockDiseaseReportFarmDetailsHeading = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmDetails + "2425" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LivestockDiseaseReportNotificationHeading = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportNotification + "1046" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LivestockDiseaseReportNotificationInvestigatedHeading = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportNotification + "2452" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LivestockDiseaseReportNotificationDataEntryHeading = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportNotification + "2453" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LivestockDiseaseReportFarmHerdSpeciesHeading = (int) InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2454" + (long) InterfaceEditorTypeEnum.Heading;
        public static readonly string LivestockDiseaseReportFarmEpiInformationHeading = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmEpidemiologicalInformation + "2468" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LivestockDiseaseReportSpeciesInvestigationHeading = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportSpeciesInvestigation + "2469" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LivestockDiseaseReportAnimalsHeading = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportAnimals + "2458" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LivestockDiseaseReportAnimalDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportAnimalDetailsModal + "2459" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LivestockDiseaseReportControlMeasuresHeading = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportControlMeasures + "2470" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LivestockDiseaseReportSamplesHeading = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportSamples + "664" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LivestockDiseaseReportSampleDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportSampleDetailsModal + "751" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LivestockDiseaseReportPensideTestsHeading = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportPensideTests + "2460" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LivestockDiseaseReportPensideTestDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportPensideTestDetailsModal + "2461" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LivestockDiseaseReportLabTestsHeading = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportLabTests + "2462" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LivestockDiseaseReportLabTestDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportLabTestDetailsModal + "2463" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LivestockDiseaseReportResultsSummaryInterpretationHeading = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportResultsSummaryInterpretation + "2464" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LivestockDiseaseReportInterpretationDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportInterpretationDetailsModal + "2465" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string LivestockDiseaseReportImportSamplesTestResultsModalImportSamplesTestResultsHeading = (int)InterfaceEditorResourceSetEnum.LivestockDiseaseReportImportSamplesTestResultsModal + "3122" + (long)InterfaceEditorTypeEnum.Heading;

        //VUC05 - Enter Avian Disease Report and VUC07 - Edit Avian Disease Report
        public static readonly string AvianDiseaseReportDiseaseReportSummaryHeading = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportSummary + "1045" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AvianDiseaseReportFarmDetailsHeading = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmDetails + "2425" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AvianDiseaseReportNotificationHeading = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportNotification + "2426" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AvianDiseaseReportNotificationInvestigatedHeading = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportNotification + "2452" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AvianDiseaseReportNotificationDataEntryHeading = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportNotification + "2453" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AvianDiseaseReportFarmFlockSpeciesHeading = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2455" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AvianDiseaseReportFarmEpiInformationHeading = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmEpidemiologicalInformation + "2468" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AvianDiseaseReportSpeciesInvestigationHeading = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportSpeciesInvestigation + "2469" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AvianDiseaseReportSamplesHeading = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportSamples + "664" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AvianDiseaseReportSampleDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportSampleDetailsModal + "751" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AvianDiseaseReportPensideTestsHeading = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportPensideTests + "2460" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AvianDiseaseReportPensideTestDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportPensideTestDetailsModal + "2461" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AvianDiseaseReportLabTestsHeading = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportLabTests + "2462" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AvianDiseaseReportLabTestDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportLabTestDetailsModal + "2463" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AvianDiseaseReportResultsSummaryInterpretationHeading = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportResultsSummaryInterpretation + "2464" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AvianDiseaseReportInterpretationDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.AvianDiseaseReportInterpretationDetailsModal + "2465" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string AvianDiseaseReportImportSamplesTestResultsModalImportSamplesTestResultsHeading = (int) InterfaceEditorResourceSetEnum.AvianDiseaseReportImportSamplesTestResultsModal + "3122" + (long) InterfaceEditorTypeEnum.Heading;

        #endregion

        #region Aggregate Disease Report Common Resources

        //Human and Veterinary Aggregate Disease Reports Summary Common
        //HAUC05 - Enter Human Aggregate Disease Reports Summary
        //VAUC13 - Enter Veterinary Aggregate Disease Reports Summary and VAUC14 - Enter Veterinary Aggregate Action Reports Summary
        public static readonly string SummaryAggregateSettingsHeading = (int)InterfaceEditorResourceSetEnum.SummaryAggregateSettings + "1873" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SelectedAggregateDiseaseReportsHeading = (int)InterfaceEditorResourceSetEnum.SelectedAggregateDiseaseReports + "1874" + (long)InterfaceEditorTypeEnum.Heading;

        #endregion

        #region Active Surveillance Campaign Common Resources

        //Human and Veterinary Active Surveillance Campaign Common
        //HASUC01 - Enter Active Surveillance Campaign and HASUC02 - Edit Active Surveillance Campaign
        //VASUC01 - Enter Active Surveillance Campaign and VASUC06 - Edit Active Surveillance Campaign
        public static readonly string CampaignInformationHeading = (int)InterfaceEditorResourceSetEnum.CampaignInformation + "1817" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string CampaignInformationSessionsHeading = (int)InterfaceEditorResourceSetEnum.CampaignInformation + "2516" + (long)InterfaceEditorTypeEnum.Heading;

        #endregion

        #region Active Surveillance Session Common Resources

        //Human and Veterinary Active Surveillance Session Common
        //HASUC03 - Enter Human Active Surveillance Session and HASUC04 - Edit Human Active Surveillance Session
        public static readonly string SessionInformationDetailedPersonsandSamplesHeading = (int)InterfaceEditorResourceSetEnum.SessionInformation + "2847" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SessionInformationSampleDetailsHeading = (int)InterfaceEditorResourceSetEnum.SessionInformation + "751" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SessionInformationTestDetailsHeading = (int)InterfaceEditorResourceSetEnum.SessionInformation + "890" + (long)InterfaceEditorTypeEnum.Heading;

        //VASUC02 - Set Up Veterinary Active Surveillance Session and VASUC03 - Edit Veterinary Active Surveillance Session
        public static readonly string SessionInformationSessionInformationHeading = (int)InterfaceEditorResourceSetEnum.SessionInformation + "863" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string SessionInformationLocationHeading = (int)InterfaceEditorResourceSetEnum.SessionInformation + "864" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string TestDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.TestDetailsModal + "890" + (long)InterfaceEditorTypeEnum.Heading;
        public static readonly string ActionDetailsModalHeading = (int)InterfaceEditorResourceSetEnum.ActionDetailsModal + "892" + (long)InterfaceEditorTypeEnum.Heading;

        #endregion

        #region WHO Export
        //SINT03
        public static readonly string HumanExporttoCISIDWHOExportHeading = (int)InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4641" + (long)InterfaceEditorTypeEnum.Heading;
        #endregion
    }
}
