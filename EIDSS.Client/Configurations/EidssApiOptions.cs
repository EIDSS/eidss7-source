namespace EIDSS.ClientLibrary.Configurations
{

    public class EidssGlobalSettingsOptions
    {
        public virtual string LeafletApiUrl { get; set; }

    }

    /// <summary>
    /// Contains application settings.
    /// </summary>
    public class EidssApiOptions
    {
        public const string EidssApi = "EIDSSApi";

        public virtual string BaseUrl { get; set; }

        public virtual string PINUrl { get; set; }

        public virtual bool MockPINService { get; set; }

        #region Admin

        public virtual string LogInPath { get; set; }

        public virtual string ValidatePasswordPath { get; set; }

        public virtual string RemoveEmployeePasswordPath { get; set; }

        public virtual string LogOutPath { get; set; }

        public virtual string VerifyUserNamePath { get; set; }

        public virtual string GetAppUserPath { get; set; }

        public virtual string GetBaseReferenceListPath { get; set; }
        public virtual string BaseReferenceAdvancedListPath { get; set; }

        public virtual string GetLanguageListPath { get; set; }

        public virtual string GetMenuListPath { get; set; }
        public virtual string GetMenuByUserListPath { get; set; }

        public virtual string GetResourceListPath { get; set; }

        public virtual string TimeOut { get; set; }

        public virtual string LockAccountPath { get; set; }

        public virtual string UnLockAccountPath { get; set; }

        public virtual string EnableUserAccountPath { get; set; }

        public virtual string DisableUserAccountPath { get; set; }

        public virtual string UpdateIdentityOptions { get; set; }

        public virtual string GetUserRolesAndPermissionsPath { get; set; }

        public virtual string GetUserClaimsPath { get; set; }

        #endregion Admin

        #region Object Access

        public virtual string GetObjectAccessListPath { get; set; }
        public virtual string SaveObjectAccessPath { get; set; }
        public virtual string GetFilteredDiseaseListPath { get; set; }
        public virtual string DiseaseGetListPagedRequestModelPath { get; set; }

        #endregion Object Access

        #region Organization

        public virtual string GetDepartmentListPath { get; set; }
        public virtual string GetOrganizationDetailPath { get; set; }
        public virtual string GetOrganizationListPath { get; set; }
        public virtual string GetAdvancedOrganizationListPath { get; set; }
        public virtual string SaveOrganizationPath { get; set; }
        public virtual string DeleteOrganizationPath { get; set; }

        #endregion Organization

        #region Site

        public virtual string GetSiteDetailsPath { get; set; }
        public virtual string GetSiteListPath { get; set; }
        public virtual string GetSiteActorListPath { get; set; }
        public virtual string SaveSitePath { get; set; }
        public virtual string DeleteSitePath { get; set; }

        #endregion Site

        #region Site Group

        public virtual string GetSiteGroupDetailsPath { get; set; }
        public virtual string GetSiteGroupListPath { get; set; }
        public virtual string SaveSiteGroupPath { get; set; }
        public virtual string DeleteSiteGroupPath { get; set; }

        #endregion Site Group

        #region Configurable Filtration

        public virtual string GetAccessRuleDetailPath { get; set; }
        public virtual string GetAccessRuleActorListPath { get; set; }
        public virtual string GetAccessRuleListPath { get; set; }
        public virtual string SaveAccessRulePath { get; set; }
        public virtual string DeleteAccessRulePath { get; set; }
        public virtual string GetActorListPath { get; set; }
        public virtual string GetDataArchivingListPath { get; set; }

        #endregion Configurable Filtration

        #region Administration

        public virtual string GetSiteAlertsSubscriptionListPath { get; set; }
        public virtual string GetNeighboringSiteListPath { get; set; }
        public virtual string SaveSiteAlertSubscriptionPath { get; set; }
        public virtual string GetEventCountPath { get; set; }
        public virtual string GetEventListPath { get; set; }
        public virtual string SaveEventStatusPath { get; set; }
        public virtual string SaveEventPath { get; set; }

        public virtual string GetSecurityPolicyPath { get; set; }
        public virtual string SaveSecurityPolicyPath { get; set; }

        public virtual string GetAdministrativeUnitsListPath { get; set; }
        public virtual string SaveAdministrativeUnitPath { get; set; }
        public virtual string DeleteAdministrativeUnitPath { get; set; }

        public virtual string GetDataAuditTransLogPath { get; set; }
        public virtual string GetDataAuditTransLogDetailPath { get; set; }
        public virtual string DataAuditRestorePath { get; set; }

        public virtual string GetSecurityEventLogPath { get; set; }
        public virtual string SaveSecurityEventPath { get; set; }
        public virtual string GetSystemEventLogPath { get; set; }

        #endregion Administration

        #region Outbreak

        public virtual string GetOutbreakSessionListPath { get; set; }
        public virtual string GetOutbreakSessionDetailsPath { get; set; }
        public virtual string SetOutbreakSessionPath { get; set; }
        public virtual string GetOutbreakSessionParametersListPath { get; set; }
        public virtual string GetOutbreakCaseListPath { get; set; }
        public virtual string GetOutbreakHumanCaseListPath { get; set; }
        public virtual string GetOutbreakVeterinaryCaseListPath { get; set; }
        public virtual string GetOutbreakCaseDetailPath { get; set; }
        public virtual string SetOutbreakCasePath { get; set; }
        public virtual string QuickSaveCasePath { get; set; }
        public virtual string GetOutbreakSessionNoteListPath { get; set; }
        public virtual string SetOutbreakSessionNotePath { get; set; }
        public virtual string GetOutbreakSessionNoteDetailsPath { get; set; }
        public virtual string DeleteOutbreakSessionNoteDeletePath { get; set; }
        public virtual string GetOutbreakNoteFilePath { get; set; }
        public virtual string GetOutbreakHeatMapDataPath { get; set; }
        public virtual string GetOutbreakCaseMonitoringListPath { get; set; }
        public virtual string GetOutbreakContactListPath { get; set; }
        public virtual string GetOutbreakVectorListPath { get; set; }
        public virtual string SaveOutbreakContactPath { get; set; }
        public virtual string OutbreakHumanCaseDetailAsyncPath { get; set; }

        #endregion Outbreak

        #region Laboratory

        public virtual string GetLaboratoryTabCountsListPath { get; set; }
        public virtual string SaveLaboratoryPath { get; set; }

        public virtual string GetLaboratorySamplesListPath { get; set; }
        public virtual string GetLaboratorySamplesAdvancedSearchListPath { get; set; }
        public virtual string GetLaboratorySamplesSimpleSearchListPath { get; set; }
        public virtual string GetLaboratorySamplesGroupAccessionInSearchListPath { get; set; }
        public virtual string GetLaboratorySampleDetailPath { get; set; }
        public virtual string GetLaboratorySampleIDListPath { get; set; }
        public virtual string GetLaboratorySampleByBarCodePath { get; set; }

        public virtual string GetLaboratoryTestingListPath { get; set; }
        public virtual string GetLaboratoryTestingAdvancedSearchListPath { get; set; }
        public virtual string GetLaboratoryTestingSimpleSearchListPath { get; set; }
        public virtual string GetLaboratoryTestDetailPath { get; set; }
        public virtual string GetLaboratoryTestAmendmentListPath { get; set; }

        public virtual string GetLaboratoryTransferredListPath { get; set; }
        public virtual string GetLaboratoryTransferredAdvancedSearchListPath { get; set; }
        public virtual string GetLaboratoryTransferredSimpleSearchListPath { get; set; }
        public virtual string GetLaboratoryTransferDetailPath { get; set; }

        public virtual string GetLaboratoryMyFavoritesListPath { get; set; }
        public virtual string GetLaboratoryMyFavoritesAdvancedSearchListPath { get; set; }
        public virtual string GetLaboratoryMyFavoritesSimpleSearchListPath { get; set; }

        public virtual string GetLaboratoryBatchesListPath { get; set; }
        public virtual string GetLaboratoryBatchesAdvancedSearchListPath { get; set; }

        public virtual string GetLaboratoryApprovalsListPath { get; set; }
        public virtual string GetLaboratoryApprovalsAdvancedSearchListPath { get; set; }
        public virtual string GetLaboratoryApprovalsSimpleSearchListPath { get; set; }

        public virtual string GetFreezerListPath { get; set; }
        public virtual string GetFreezerSubdivisionListPath { get; set; }
        public virtual string SaveFreezerPath { get; set; }

        #endregion Laboratory

        #region Base Reference

        public virtual string GetBaseReferenceTypeListPath { get; set; }
        public virtual string GetBaseReferenceTypesByNamePath { get; set; }
        public virtual string GetBaseReferenceTypesByIdPagedPath { get; set; }
        public virtual string SaveBaseReferencePath { get; set; }
        public virtual string DeleteBaseReferencePath { get; set; }
        public virtual string DeleteAgeGroupPath { get; set; }
        public virtual string SaveAgeGroupPath { get; set; }
        public virtual string GetAgeGroupListPath { get; set; }
        public virtual string GetCaseClassificationListPath { get; set; }
        public virtual string SaveCaseClassificationPath { get; set; }
        public virtual string DeleteCaseClassificationPath { get; set; }
        public virtual string GetSpeciesTypeListPath { get; set; }
        public virtual string SaveSpeciesTypePath { get; set; }

        #endregion Base Reference

        #region Vector

        public virtual string GetVectorTypeListPath { get; set; }
        public virtual string SaveVectorTypePath { get; set; }
        public virtual string DeleteVectorTypePath { get; set; }
        public virtual string GetVectorSurveillanceSessionListAsyncPath { get; set; }
        public virtual string GetVectorSessionAggregateCollectionDetailAsyncPath { get; set; }
        public virtual string SaveVectorSurveillanceSessionAsyncPath { get; set; }
        public virtual string GetVectorSurveillanceSessionMasterPath { get; set; }
        public virtual string GetVectorSurveillanceSamplesPath { get; set; }
        public virtual string GetVectorSurveillanceLabTestPath { get; set; }
        public virtual string GetVectorDetailsListPath { get; set; }
        public virtual string GetVectorSessionSummaryPath { get; set; }
        public virtual string GetVectorFieldTestPath { get; set; }
        public virtual string GetSessionDiagnosisPath { get; set; }
        public virtual string DeleteAggregateCollectionPath { get; set; }
        public virtual string DeleteVectorSurveillanceSessionPath { get; set; }
        public virtual string DeleteDetailedCollectionPath { get; set; }
        public virtual string GetVectorDetailsCollectionPath { get; set; }
        public virtual string CopyVectorDetailedCollectionPath { get; set; }


        #endregion Vector

        #region Report Disease Group List

        public virtual string GetReportDiseaseGroupListPath { get; set; }

        public virtual string SaveReportDiseaseGroupPath { get; set; }

        public virtual string DeleteReportDiseaseGroupPath { get; set; }

        #endregion Report Disease Group List

        #region Measures

        public virtual string GetMeasuresListPath { get; set; }

        public virtual string GetMeasuresDropDownListPath { get; set; }

        public virtual string SaveMeasuresPath { get; set; }

        public virtual string DeleteMeasuresPath { get; set; }

        #endregion Measures

        #region Matrix

        public virtual string GetMatrixVersionsByTypePath { get; set; }
        public virtual string SaveMatrixVersionPath { get; set; }
        public virtual string SaveVeterinaryDiagnosticInvestigationMatrixPath { get; set; }
        public virtual string SaveVeterinaryAggregateDiseaseMatrixPath { get; set; }
        public virtual string SaveHumanAggregateDiseaseMatrixPath { get; set; }
        public virtual string SaveVeterinaryProphylacticMeasureMatrixPath { get; set; }
        public virtual string SaveVeterinarySanitaryActionMatrixPath { get; set; }
        public virtual string DeleteMatrixVersionPath { get; set; }
        public virtual string GetVeterinaryDiagnosticInvestigationMatrixReportPath { get; set; }
        public virtual string GetVeterinaryProphylacticMeasureMatrixReportPath { get; set; }
        public virtual string GetVeterinarySanitaryActionMatrixReportPath { get; set; }
        public virtual string GetVeterinaryProphylacticMeasureTypesPath { get; set; }
        public virtual string GetVeterinaryDiseaseMatrixListAsyncPath { get; set; }
        public virtual string GetVeterinaryAggregateDiseaseMatrixListAsyncPath { get; set; }
        public virtual string GetHumanAggregateDiseaseMatrixListAsyncPath { get; set; }
        public virtual string GetUniqueNumberingSchemaListAsyncPath { get; set; }
        public virtual string SaveUniqueNumberingSchemaAsyncPath { get; set; }
        public virtual string GetDiseaseHumanGenderMatrixListAsyncPath { get; set; }

        public virtual string GetGenderForDiseaseOrDiagnosisMatrixAsyncPath { get; set; }
        public virtual string SaveDiseaseHumanGenderMatrixAsyncPath { get; set; }
        public virtual string GetSpeciesListAsyncPath { get; set; }
        public virtual string GetInvestigationTypeMatrixListAsyncPath { get; set; }
        public virtual string GetVeterinarySanitaryActionTypesListAsyncPath { get; set; }
        public virtual string GetHumanDiseaseDiagnosisMatrixListAsyncPath { get; set; }
        public virtual string GetDiseaseAgeGroupMatrixListAsyncPath { get; set; }
        public virtual string DeleteDiseaseAgeGroupMatrixRecordPath { get; set; }
        public virtual string DeleteDiseaseHumanGenderMatrixRecordPath { get; set; }
        public virtual string SaveDiseaseAgeGroupMatrixPath { get; set; }
        public virtual string DeleteVeterinaryDiagnosticInvestigationMatrixRecordPath { get; set; }
        public virtual string DeleteVeterinaryAggregateDiseaseMatrixRecordPath { get; set; }
        public virtual string DeleteHumanAggregateDiseaseMatrixRecordPath { get; set; }
        public virtual string DeleteVeterinaryProphylacticMeasureMatrixRecordPath { get; set; }
        public virtual string DeleteVeterinarySanitaryActionMatrixRecordPath { get; set; }
        public virtual string GetSampleTypeDerivativeMatrixListPath { get; set; }
        public virtual string SaveSampleTypeDerivativeMatrixPath { get; set; }
        public virtual string DeleteSampleTypeDerivativeMatrixPath { get; set; }

        public virtual string GetCustomReportRowsMatrixListPath { get; set; }
        public virtual string SaveCustomReportRowsMatrixPath { get; set; }
        public virtual string SaveCustomReportRowsOrderPath { get; set; }
        public virtual string DeleteCustomReportRowsMatrixPath { get; set; }
        public virtual string GetDiseaseGroupDiseaseMatrixListPath { get; set; }
        public virtual string SaveDiseaseGroupDiseaseMatrixPath { get; set; }
        public virtual string DeleteDiseaseGroupDiseaseMatrixPath { get; set; }

        public virtual string GetVectorTypeFieldTestMatrixListPath { get; set; }
        public virtual string SaveVectorTypeFieldTestMatrixPath { get; set; }
        public virtual string DeleteVectorTypeFieldTestMatrixPath { get; set; }

        public virtual string GetStatisticalAgeGroupMatrixListPath { get; set; }
        public virtual string SaveStatisticalAgeGroupMatrixPath { get; set; }
        public virtual string DeleteStatisticalAgeGroupMatrixPath { get; set; }

        public virtual string GetParameterTypeEditorListPath { get; set; }
        public virtual string SaveParameterTypeEditorPath { get; set; }
        public virtual string DeleteParameterTypeEditorPath { get; set; }
        public virtual string GetParameterFixedPresetValueListPath { get; set; }
        public virtual string GetParameterReferenceValueListPath { get; set; }
        public virtual string GetParameterReferenceListPath { get; set; }
        public virtual string DeleteParameterFixedPresetValuePath { get; set; }
        public virtual string SaveParameterFixedPresetValuePath { get; set; }
        public virtual string GetPersonalIdentificationTypeMatrixListPath { get; set; }
        public virtual string DeletePersonalIdentificationTypeMatrixPath { get; set; }
        public virtual string SavePersonalIdentificationTypeMatrixPath { get; set; }
        public virtual string GetReportDiseaseGroupDiseaseMatrixListPath { get; set; }
        public virtual string SaveReportDiseaseGroupDiseaseMatrixPath { get; set; }
        public virtual string DeleteReportDiseaseGroupDiseaseMatrixPath { get; set; }
        public virtual string GetDiseaseLabTestMatrixPath { get; set; }
        public virtual string GetDiseasePensideTestMatrixPath { get; set; }

        #endregion Matrix

        public virtual string GetSystemPreferencePath { get; set; }
        public virtual string SetSystemPreferencePath { get; set; }
        public virtual string GetUserPreferencePath { get; set; }
        public virtual string SetUserPreferencePath { get; set; }

        public virtual string GetCountryListPath { get; set; }

        public virtual string GetSampleTypesReferenceListPath { get; set; }

        public virtual string GetSampleTypesByDiseasePath { get; set; }

        public virtual string GetHACodeListPath { get; set; }

        public virtual string SaveSampleTypePath { get; set; }
        public virtual string GetDiseaseSampleTypeByDiseasePagedPath { get; set; }

        public virtual string DeleteSampleTypePath { get; set; }

        public virtual string DeleteSpeciesTypePath { get; set; }

        public virtual string GetReportLanuageListPath { get; set; }

        public virtual string GetReportYearListPath { get; set; }

        public virtual string GetReportMonthNameListPath { get; set; }

        public virtual string GetVectorSpeciesTypeListPath { get; set; }
        public virtual string SaveVectorSpeciesTypePath { get; set; }
        public virtual string DeleteVectorSpeciesTypePath { get; set; }

        public virtual string DeleteDiseasePath { get; set; }
        public virtual string SaveDiseasePath { get; set; }
        public virtual string GetDiseasesListPath { get; set; }
        public virtual string GetDiseasesDetailPath { get; set; }
        
        public virtual string GetGisLocationPath { get; set; }
        public virtual string GetGisLocationCurrentPath { get; set; }
        public virtual string GetGisLocationChildPath { get; set; }
        public virtual string GetGisLocationLevelsPath { get; set; }
        public virtual string GetStreetListPath { get; set; }

        public virtual string GetPostalCodeListPath { get; set; }
        public virtual string GetSettlementListPath { get; set; }

        public virtual string GetBaseReferenceListCrossCuttingPath { get; set; }
        public virtual string GetBaseReferenceListByIDCrossCuttingPath { get; set; }

        public virtual string GetStatisticalTypeListPath { get; set; }

        public virtual string DeleteStatisticalTypePath { get; set; }
        public virtual string SaveStatisticalTypePath { get; set; }
        public virtual string GetStatisticalDataPath { get; set; }
        public virtual string GetStatisticalDataDetailsPath { get; set; }
        public virtual string DeleteStatisticalDataPath { get; set; }
        public virtual string SaveStatisticalDataPath { get; set; }
        public virtual string GetSpeciesAnimalAgeListPath { get; set; }
        public virtual string SaveSpeciesAnimalAgePath { get; set; }
        public virtual string DeleteSpeciesAnimalAgePath { get; set; }
        public virtual string GetSettlementTypeListPath { get; set; }
        public virtual string SaveSettlementTypePath { get; set; }

        public virtual string GetVectorTypeSampleTypeMatrixListPath { get; set; }
        public virtual string SaveVectorTypeSampleTypeMatrixPath { get; set; }
        public virtual string DeleteVectorTypeSampleTypeMatrixPath { get; set; }

        public virtual string GetVectorTypeCollectionMethodMatrixListPath { get; set; }
        public virtual string SaveVectorTypeCollectionMethodMatrixPath { get; set; }
        public virtual string DeleteVectorTypeCollectionMethodMatrixPath { get; set; }

        public virtual string GetILIAggregateListPath { get; set; }
        public virtual string GetILIAggregateDetailListPath { get; set; }
        public virtual string SaveILIAggregatePath { get; set; }
        public virtual string SaveILIAggregateDetailPath { get; set; }
        public virtual string DeleteILIAggregateDetailPath { get; set; }
        public virtual string DeleteILIAggregateHeaderPath { get; set; }

        #region Cross Cutting

        public virtual string GetAccessRulesAndPermissionsPath { get; set; }
        public virtual string GetEmployeeLookupListPath { get; set; }
        public virtual string ActiveSurveillanceCampaignPath { get; set; }
        public virtual string ActiveSurveillanceCampaignDetailPath { get; set; }
        public virtual string ActiveSurveillanceCampaignDiseaseSpeciesSamplesListPath { get; set; }
        public virtual string ActiveSurveillanceCampaignSavePath { get; set; }
        public virtual string ActiveSurveillanceCampaignDeletePath { get; set; }
        public virtual string DisassociateSessionFromCampaignPath { get; set; }
        public virtual string BaseReferenceTranslationPath { get; set; }
        public virtual string GetGblSiteListPath { get; set; }
        public virtual string GetGblUserListPath { get; set; }
        public virtual string GetDiseaseTestListPath { get; set; }
        public virtual string GetBaseReferenceLookupListPath { get; set; }

        #endregion Cross Cutting

        #region Test Name Test Results

        public virtual string GetTestNameTestResultsMatrixListPath { get; set; }
        public virtual string SaveTestNameTestResultsMatrixPath { get; set; }
        public virtual string DeleteTestNameTestResultsMatrixPath { get; set; }

        #endregion Test Name Test Results

        #region Aggregate Settings

        public virtual string GetAggregateSettingsPath { get; set; }

        public virtual string SaveAggregateSettingsPath { get; set; }

        #endregion Aggregate Settings

        #region Flex Form
        public virtual string GetFlexFormTypesListPath { get; set; }
        public virtual string GetFlexFormParametersListPath { get; set; }
        public virtual string GetFlexFormSectionsListPath { get; set; }
        public virtual string GetFlexFormTemplateListPath { get; set; }
        public virtual string GetFlexFormSectionParameterListPath { get; set; }
        public virtual string SetFlexFormParameterPath { get; set; }
        public virtual string SetFlexFormTemplatePath { get; set; }
        public virtual string SetFlexFormTemplateParameterPath { get; set; }
        public virtual string SetFlexFormSectionPath { get; set; }
        public virtual string CopyFlexFormParameterPath { get; set; }
        public virtual string CopyFlexFormSectionPath { get; set; }
        public virtual string DeleteFlexFormTemplateParameterPath { get; set; }
        public virtual string DeleteFlexFormSectionPath { get; set; }
        public virtual string GetFlexFormTemplateDeterminantValuesListPath { get; set; }
        public virtual string GetFlexFormTemplateDesignListPath { get; set; }
        public virtual string GetFlexFormTemplateDetailPath { get; set; }
        public virtual string GetFlexFormParameterDetailPath { get; set; }
        public virtual string GetFlexFormTemplatesByParameterListPath { get; set; }
        public virtual string DeleteFlexFormParameterPath { get; set; }
        public virtual string SetFlexFormRequiredParameterPath { get; set; }
        public virtual string SetFlexFormTemplateParameterOrderPath { get; set; }
        public virtual string SetFlexFormTemplateSectionOrderPath { get; set; }
        public virtual string IsFlexFormParameterInUseAsyncPath { get; set; }
        public virtual string SetFlexFormDeterminantPath { get; set; }
        public virtual string GetFlexFormRulesListPath { get; set; }
        public virtual string SetFlexFormRulePath { get; set; }
        public virtual string GetFlexFormRuleDetailPath { get; set; }
        public virtual string CopyFlexFormTemplate { get; set; }
        public virtual string GetFlexFormSectionsParametersListPath { get; set; }
        public virtual string DeleteFlexFormTemplatePath { get; set; }
        public virtual string GetFlexFormDeterminantDiseaseList { get; set; }
        public virtual string GetFlexFormQuestionnairePath { get; set; }
        public virtual string GetFlexFormAnswersPath { get; set; }
        public virtual string GetFlexFormParameterSelectListPath { get; set; }
        public virtual string SetFlexFormActivityParametersPath { get; set; }
        public virtual string SetOutbreakFlexFormPath { get; set; }
        public virtual string GetFlexFormFormTemplateDetailAsyncPath { get; set; }
        public virtual string GetParameterTypeEditorMappingAsyncPath { get; set; }
        public virtual string GetFlexFormRuleListPath { get; set; }
        public virtual string GetFlexFormRuleActionsListPath { get; set; }
        
        #endregion Flex Form

        #region Reports

        public virtual string GetReportPeriodPath { get; set; }
        public virtual string GetReportPeriodTypePath { get; set; }
        public virtual string GetVetNameOfInvestigationOrMeasurePath { get; set; }
        public virtual string GetVetSummarySurveillanceType { get; set; }
        public virtual string SaveReportAuditPath { get; set; }
        public virtual string GetHumanWhoMeaslesRubellaDiagnosisPath { get; set; }
        public virtual string GetHumanComparitiveCounterPath { get; set; }
        public virtual string GetHumanComparitiveCounterGGPath { get; set; }
        public virtual string GetTuberculosisDiagnosisListPath { get; set; }
        public virtual string GetSpeciesTypesPath { get; set; }
        public virtual string GetCurrentCountryListPath { get; set; }
        public virtual string GetLABAssignmentDiagnosticAZSendToListPath { get; set; }
        public virtual string GetLABTestingResultsDepartmentListPath { get; set; }
        public virtual string GetReportListPath { get; set; }
        public virtual string GetHumDateFieldSourceListPath { get; set; }
        public virtual string GetReportOrganizationListPath { get; set; }
        public virtual string GetVetDateFieldSourceListPath { get; set; }
        public virtual string GetReportQuarterGGPath { get; set; }
        public virtual string GetVeterinaryAggregateReportDetailPath { get; set; }
        public virtual string GetHumanAggregateReportDetailPath { get; set; }
        public virtual string GetVeterinaryAggregateDiagnosticActionSummaryReportDetailPath { get; set; }
        public virtual string GetVeterinaryAggregateProphylacticActionSummaryReportDetailPath { get; set; }
        public virtual string GetVeterinaryAggregateSanitaryActionSummaryReportDetailPath { get; set; }

        #endregion Reports

        #region User Group

        public virtual string GetUserGroupDashboardListPath { get; set; }
        public virtual string SaveUserGroupDashboardPath { get; set; }
        public virtual string DeleteUserGroupPath { get; set; }
        public virtual string GetUserGroupDetailPath { get; set; }
        public virtual string GetUserGroupListPath { get; set; }
        public virtual string SaveUserGroupPath { get; set; }
        public virtual string SaveUserGroupSystemFunctionsPath { get; set; }
        public virtual string DeleteEmployeesFromUserGroupPath { get; set; }
        public virtual string GetEmployeesForUserGroupListPath { get; set; }
        public virtual string GetUsergroupSystemfunctionPermissionListPath { get; set; }
        public virtual string SaveEmployeesToUserGroupPath { get; set; }
        public virtual string GetPermissionsbyRolePath { get; set; }

        #endregion User Group

        #region Admin Security

        public virtual string GetSystemFunctionListPath { get; set; }
        public virtual string GetSystemFunctionActorsListPath { get; set; }
        public virtual string GetSystemFunctionPermissionListPath { get; set; }
        public virtual string SaveSystemFunctionUserPermissionPath { get; set; }
        public virtual string GetPersonAndEmployeeGroupListPath { get; set; }
        public virtual string DeleteSystemFunctionPersonAndEmployeeGroupPath { get; set; }

        #endregion Admin Security

        #region Employees

        public virtual string GetEmployeeListPath { get; set; }

        public virtual string GetEmployeeDetailsPath { get; set; }

        public virtual string GetUserGroupGetListPath { get; set; }

        public virtual string SaveDepartmentPath { get; set; }
        public virtual string SaveStreetPath { get; set; }
        public virtual string SavePostalCodePath { get; set; }

        public virtual string SaveSystemFunctionsPath { get; set; }

        public virtual string GetSystemFunctionsPermissionsListPath { get; set; }

        public virtual string GetEmployeeAndEmployeeGroupSystemFunctionsPermissionsListPath { get; set; }

        public virtual string GetEmployeeSiteDetailsPath { get; set; }

        public virtual string GetEmployeeSiteFromOrgPath { get; set; }

        public virtual string GetEmployeeGroupsByUserPath { get; set; }

        public virtual string GetEmployeeUserGroupAndPermissionsPath { get; set; }

        public virtual string GetEmployeeUserGroupAndPermissionDetailPath { get; set; }

        public virtual string GetAspNetUserGetDetailsPath { get; set; }

        public virtual string SaveEmployeePath { get; set; }

        public virtual string DeleteEmployeePath { get; set; }

        public virtual string SaveUserLoginInfoPath { get; set; }

        public virtual string DeleteEmployeeLoginInfoPath { get; set; }

        public virtual string SaveASPNetUserIdentityPath { get; set; }

        public virtual string UpdateUserNamePath { get; set; }

        public virtual string UpdatePasswordResetRequiredPath { get; set; }

        public virtual string ResetPasswordPath { get; set; }

        public virtual string ResetPasswordByUserPath { get; set; }

        public virtual string DeleteASPNetUserIdentityPath { get; set; }

        public virtual string SaveUserGroupMemberInfoPath { get; set; }

        public virtual string DeleteEmployeeGroupMemberInfoPath { get; set; }

        public virtual string SaveEmployeeOrganizationPath { get; set; }

        public virtual string DeleteEmployeeOrganizationPath { get; set; }

        public virtual string EmployeeOrganizationStatusSetPath { get; set; }

        public virtual string EmployeeOrganizationActivateDeactivateSetPath { get; set; }

        public virtual string SaveEmployeeNewDefaultOrganizationPath { get; set; }

        #endregion Employees

        #region Human

        public virtual string GetPersonListPath { get; set; }
        public virtual string GetPersonListForOfficePath { get; set; }
        public virtual string SavePersonPath { get; set; }
        public virtual string DeletePersonPath { get; set; }
        public virtual string DedupePersonFarmPath { get; set; }
        public virtual string DedupePersonHumanDiseasePath { get; set; }
        public virtual string DedupePersonRecordsPath { get; set; }


        public virtual string DedupeHumanDiseaseReportPath { get; set; }

        #region PIN
        public virtual string LoginUrl { get; set; }
        public virtual string PINLoginPath { get; set; }
        public virtual string GetPersonByPINPath { get; set; }
        public virtual string GetPersonData { get; set; }

        public virtual string AuditPINSystemAccess { get; set; }

        #endregion

        #region Active Surveillance Session

        public virtual string HumanActiveSurveillanceCampaignPath { get; set; }
        public virtual string HumanActiveSurveillanceSessionPath { get; set; }
        public virtual string HumanActiveSurveillanceSessionDetailsPath { get; set; }
        public virtual string HumanActiveSurveillanceSessionSamplesListPath { get; set; }
        public virtual string GetHumanActiveSurveillanceDiseaseReportsListAsyncPath { get; set; }
        public virtual string HumanActiveSurveillanceSessionDetailedInformationAsyncPath { get; set; }
        public virtual string HumanActiveSurveillanceSessionTestsAsyncPath { get; set; }
        public virtual string HumanActiveSurveillanceSessionActionsAsyncPath { get; set; }
        public virtual string HumanActiveSurveillanceSessionSetAsyncPath { get; set; }
        public virtual string HumanActiveSurveillanceSessionDetailAsyncPath { get; set; }
        public virtual string HumanActiveSurveillanceDetailedInformationListAsyncPath { get; set; }
        public virtual string HumanActiveSurveillanceDiseaseSampleTypeListAsyncPath { get; set; }
        public virtual string HumanActiveSurveillanceDeletePath { get; set; }

        #endregion Active Surveillance Session

        public virtual string SetHumanActiveSurveillanceCampaignPath { get; set; }
        public virtual string GetHumanActiveSurveillanceCampaignDetailsPath { get; set; }
        public virtual string DeleteHumanActiveSurveillanceCampaignDetailsPath { get; set; }
        public virtual string GetHumanActiveCampaignSampleToSampleTypePath { get; set; }
        public virtual string HumanActiveSurveillanceSessionTestNamesAsyncPath { get; set; }
        public virtual string HumanDiseaseReportPersonInfoPath { get; set; }

        public virtual string HumanDiseaseReportFromHumanIDPath { get; set; }
        public virtual string GetWeeklyReportingFormListPath { get; set; }
        public virtual string GetWeeklyReportingFormDetailPath { get; set; }

        public virtual string SaveWeeklyReportingFormPath { get; set; }
        public virtual string DeleteWeeklyReportingFormPath { get; set; }

        public virtual string HumanDiseaseReportListAsyncPath { get; set; }
        public virtual string HumanDiseaseReportDetailAsyncPath { get; set; }
        public virtual string HumanDiseaseReportDetailPermissionsPath { get; set; }

        public virtual string HumanDiseaseAntviralTherapiesAsyncPath { get; set; }
        public virtual string HumanDiseaseVaccinationListAsyncPath { get; set; }
        public virtual string HumanDiseaseSamplesListAsyncPath { get; set; }

        public virtual string HumanDiseaseContactListAsyncPath { get; set; }

        public virtual string HumanDiseaseReportLkupCaseClassificationAsyncPath { get; set; }

        public virtual string HumanDiseaseTestListAsyncPath { get; set; }

        public virtual string HumanDiseaseTestNameForDiseasesAsyncPath { get; set; }

        public virtual string HumanDiseaseSamplesForDiseaseListAsyncPath { get; set; }

        public virtual string SaveHumanDiseaseReportPath { get; set; }

        public virtual string DeleteHumanDiseaseReportPath { get; set; }

        public virtual string UpdateHumanDiseaseInvestigatedByPath { get; set; }

        public virtual string GetWHOExportListPath { get; set; }

        #endregion Human

        #region Interface Editor

        public virtual string GetInterfaceEditorModuleListPath { get; set; }
        public virtual string GetInterfaceEditorSectionListPath { get; set; }
        public virtual string GetInterfaceEditorResourceListPath { get; set; }
        public virtual string SaveInterfaceEditorResourcePath { get; set; }
        public virtual string GetInterfaceEditorTemplateItemsPath { get; set; }
        public virtual string UploadLanguageTranslationPath { get; set; }

        #endregion Interface Editor

        #region Aggregate Reports

        public virtual string GetAggregateReportListPath { get; set; }
        public virtual string SaveAggregateReportPath { get; set; }
        public virtual string GetAggregateReportDetailPath { get; set; }
        public virtual string DeleteAggregateReportPath { get; set; }
        public virtual string SaveObservationPath { get; set; }

        #endregion Aggregate Reports

        #region Veterinary

        public virtual string GetFarmListAsyncPath { get; set; }
        public virtual string GetFarmMasterListAsyncPath { get; set; }
        public virtual string GetFarmMasterDetailPath { get; set; }
        public virtual string GetFarmDetailPath { get; set; }
        public virtual string GetAdvancedFarmListPath { get; set; }
        public virtual string SaveFarmPath { get; set; }
        public virtual string DeleteFarmPath { get; set; }
        public virtual string GetVeterinaryDiseaseReportListAsyncPath { get; set; }
        public virtual string GetVeterinaryDiseaseReportDetailPath { get; set; }
        public virtual string GetVeterinaryDiseaseReportFarmInventoryListPath { get; set; }
        public virtual string GetVeterinaryDiseaseReportAnimalListPath { get; set; }
        public virtual string GetVeterinaryDiseaseReportVaccinationListPath { get; set; }
        public virtual string GetVeterinaryDiseaseReportSampleListPath { get; set; }
        public virtual string GetVeterinaryDiseaseReportImportSampleListPath { get; set; }
        public virtual string GetVeterinaryDiseaseReportPensideTestListPath { get; set; }
        public virtual string GetVeterinaryDiseaseReportLaboratoryTestListPath { get; set; }
        public virtual string GetVeterinaryDiseaseReportLaboratoryTestInterpretationListPath { get; set; }
        public virtual string GetVeterinaryDiseaseReportCaseLogListPath { get; set; }
        public virtual string SaveVeterinaryDiseaseReportPath { get; set; }
        public virtual string DeleteVeterinaryDiseaseReportPath { get; set; }
        public virtual string GetVeterinaryActiveSurveillanceSessionListAsyncPath { get; set; }
        public virtual string GetVeterinaryActiveSurveillanceSessionDetailAsyncPath { get; set; }
        public virtual string GetVeterinaryActiveSurveillanceSessionSamplesListAsyncPath { get; set; }
        public virtual string GetVeterinaryActiveSurveillanceSessionSampleDiseaseListAsyncPath { get; set; }
        public virtual string GetVeterinaryActiveSurveillanceSessionTestsListAsyncPath { get; set; }
        public virtual string GetVeterinaryActiveSurveillanceSessionActionsListAsyncPath { get; set; }
        public virtual string GetVeterinaryActiveSurveillanceSessionAggregateInfoListAsyncPath { get; set; }
        public virtual string GetVeterinaryActiveSurveillanceSessionAggregateDiseaseListAsyncPath { get; set; }
        public virtual string GetVeterinaryActiveSurveillanceSessionDiseaseSpeciesListAsyncPath { get; set; }
        public virtual string SaveActiveSurveillanceSessionPath { get; set; }
        public virtual string DedupeFarmPath { get; set; }
        public virtual string DedupeVeterinaryDiseaseReportPath { get; set; }
        public virtual string VetActiveSurveillanceSessionDeletePath { get; set; }

        #endregion Veterinary

        #region xsite

        public virtual string GetXSiteDocumentList { get; set; }
        public virtual string GetXSiteHelpFile { get; set; }

        #endregion xsite

        #region Dashboard

        public virtual string GetDashboardApprovalsPath { get; set; }
        public virtual string GetDashboardInvestigationsPath { get; set; }
        public virtual string GetDashboardMyInvestigationsPath { get; set; }
        public virtual string GetDashboardNotificationsPath { get; set; }
        public virtual string GetDashboardMyNotificationsPath { get; set; }
        public virtual string GetDashboardMyCollectionsPath { get; set; }
        public virtual string GetDashboardLinksPath { get; set; }
        public virtual string GetDashboardUsersPath { get; set; }

        #endregion Dashboard

        #region ConnectToArchive

        public virtual string ConnectToArchive { get; set; }

        #endregion ConnectToArchive

        #region UserGrid

        public virtual string GetUserGridConfigurationPath { get; set; }
        public virtual string SetUserGridConfigurationPath { get; set; }

        #endregion UserGrid
    }
}