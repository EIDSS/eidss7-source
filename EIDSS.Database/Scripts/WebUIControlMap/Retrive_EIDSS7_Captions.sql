if OBJECT_ID(N'tempdb..#Caption') is not null
	exec sp_executesql N'drop table #Caption'

if OBJECT_ID(N'tempdb..#Caption') is null
create table #Caption
(	id bigint not null identity(1, 1),
	captionClass nvarchar(200) collate Cyrillic_General_CI_AS not null,
	controlCaptionConstant nvarchar(200) collate Cyrillic_General_CI_AS null,
	controlCaptionIdRaw nvarchar(200) collate Cyrillic_General_CI_AS null,
	controlCaptionId bigint null,
	controlCaptionEn nvarchar(2000) collate Cyrillic_General_CI_AS null
)

truncate table #Caption


-- ColumnHeadingResourceKeyConstants
insert into #Caption (captionClass, controlCaptionConstant, controlCaptionIdRaw) values
 (N'ColumnHeadingResourceKeyConstants', N'AbbreviationColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "1"')
,(N'ColumnHeadingResourceKeyConstants', N'AccessRuleIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchAccessRules + "8"')
,(N'ColumnHeadingResourceKeyConstants', N'AccessRuleNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchAccessRules + "9"')
,(N'ColumnHeadingResourceKeyConstants', N'AccessoryCodeColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "4"')
,(N'ColumnHeadingResourceKeyConstants', N'ActorTypeNameColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "500"')
,(N'ColumnHeadingResourceKeyConstants', N'AdministrativeLevelColumnHeading', N'InterfaceEditorResourceSetEnum.AggregateSettings + "508"')
,(N'ColumnHeadingResourceKeyConstants', N'AggregateCaseTypeColumnHeading', N'InterfaceEditorResourceSetEnum.AggregateSettings + "507"')
,(N'ColumnHeadingResourceKeyConstants', N'AgeGroupColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "22"')
,(N'ColumnHeadingResourceKeyConstants', N'AnimalAgeColumnHeading', N'InterfaceEditorResourceSetEnum.SpeciesAnimalAgeMatrix + "24"')
,(N'ColumnHeadingResourceKeyConstants', N'AreaTypeColumnHeading', N'InterfaceEditorResourceSetEnum.GenericStatisticalTypes + "503"')
,(N'ColumnHeadingResourceKeyConstants', N'BorderingAreaRuleIndicatorColumnHeading', N'InterfaceEditorResourceSetEnum.SearchAccessRules + "30"')
,(N'ColumnHeadingResourceKeyConstants', N'CodeColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "44"')
,(N'ColumnHeadingResourceKeyConstants', N'CollectedByPoolColumnHeading', N'InterfaceEditorResourceSetEnum.VectorTypesReferenceEditor + "45"')
,(N'ColumnHeadingResourceKeyConstants', N'CollectionMethodColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "46"')
,(N'ColumnHeadingResourceKeyConstants', N'CustomReportTypeColumnHeading', N'InterfaceEditorResourceSetEnum.ReportDiagnosisGroupDiagnosisMatrix + "48"')
,(N'ColumnHeadingResourceKeyConstants', N'DefaultRuleIndicatorColumnHeading', N'InterfaceEditorResourceSetEnum.SearchAccessRules + "57"')
,(N'ColumnHeadingResourceKeyConstants', N'DefaultValueColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "58"')
,(N'ColumnHeadingResourceKeyConstants', N'DepartmentNameColumnHeading', N'InterfaceEditorResourceSetEnum.OrganizationInformation + "65"')
,(N'ColumnHeadingResourceKeyConstants', N'DerivativeTypeColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "67"')
,(N'ColumnHeadingResourceKeyConstants', N'DiagnosisColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "70"')
,(N'ColumnHeadingResourceKeyConstants', N'DiseaseColumnAdditionalTextColumnHeading', N'InterfaceEditorResourceSetEnum.CustomReportRows + "488"')
,(N'ColumnHeadingResourceKeyConstants', N'DiseaseGroupColumnHeading', N'InterfaceEditorResourceSetEnum.DiseaseGroupDiseaseMatrix + "72"')
,(N'ColumnHeadingResourceKeyConstants', N'DiseaseOrGroupColumnHeading', N'InterfaceEditorResourceSetEnum.CustomReportRows + "489"')
,(N'ColumnHeadingResourceKeyConstants', N'DiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'EmployeeGroupDescriptionColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "490"')
,(N'ColumnHeadingResourceKeyConstants', N'FieldTypeColumnHeading', N'InterfaceEditorResourceSetEnum.PersonalIdentificationTypeMatrix + "80"')
,(N'ColumnHeadingResourceKeyConstants', N'FinalCaseClassificationColumnHeading', N'InterfaceEditorResourceSetEnum.CaseClassificationsReferenceEditor + "82"')
,(N'ColumnHeadingResourceKeyConstants', N'GenderColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "86"')
,(N'ColumnHeadingResourceKeyConstants', N'ICD10ColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "93"')
,(N'ColumnHeadingResourceKeyConstants', N'ICD10ColumnAdditionalTextColumnHeading', N'InterfaceEditorResourceSetEnum.CustomReportRows + "491"')
,(N'ColumnHeadingResourceKeyConstants', N'IndicativeColumnHeading', N'InterfaceEditorResourceSetEnum.TestTestResultMatrix + "96"')
,(N'ColumnHeadingResourceKeyConstants', N'InitialCaseClassificationColumnHeading', N'InterfaceEditorResourceSetEnum.CaseClassificationsReferenceEditor + "97"')
,(N'ColumnHeadingResourceKeyConstants', N'IntervalTypeColumnHeading', N'InterfaceEditorResourceSetEnum.AgeGroupsReferenceEditor + "98"')
,(N'ColumnHeadingResourceKeyConstants', N'InvestigationTypeColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinaryDiagnosticInvestigationMatrix + "102"')
,(N'ColumnHeadingResourceKeyConstants', N'IsDeletedColumnHeading', N'InterfaceEditorResourceSetEnum.ReportDiagnosisGroupDiagnosisMatrix + "103"')
,(N'ColumnHeadingResourceKeyConstants', N'LabTestColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "106"')
,(N'ColumnHeadingResourceKeyConstants', N'LengthColumnHeading', N'InterfaceEditorResourceSetEnum.PersonalIdentificationTypeMatrix + "108"')
,(N'ColumnHeadingResourceKeyConstants', N'LOINCCodeColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "492"')
,(N'ColumnHeadingResourceKeyConstants', N'LowerBoundColumnHeading', N'InterfaceEditorResourceSetEnum.AgeGroupsReferenceEditor + "111"')
,(N'ColumnHeadingResourceKeyConstants', N'MeasureCodeColumnHeading', N'InterfaceEditorResourceSetEnum.MeasuresReferenceEditor + "115"')
,(N'ColumnHeadingResourceKeyConstants', N'MeasureTypeColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "117"')
,(N'ColumnHeadingResourceKeyConstants', N'NameColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "501"')
,(N'ColumnHeadingResourceKeyConstants', N'NationalValueColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "140"')
,(N'ColumnHeadingResourceKeyConstants', N'OIECodeColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "147"')
,(N'ColumnHeadingResourceKeyConstants', N'OrderColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "151"')
,(N'ColumnHeadingResourceKeyConstants', N'OrganizationColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "661"')
,(N'ColumnHeadingResourceKeyConstants', N'OrganizationAddressColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "152"')
,(N'ColumnHeadingResourceKeyConstants', N'OrganizationFullNameColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "153"')
,(N'ColumnHeadingResourceKeyConstants', N'OrganizationNameColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "494"')
,(N'ColumnHeadingResourceKeyConstants', N'ParameterTypeColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "502"')
,(N'ColumnHeadingResourceKeyConstants', N'PensideTestColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "203"')
,(N'ColumnHeadingResourceKeyConstants', N'PeriodTypeColumnHeading', N'InterfaceEditorResourceSetEnum.GenericStatisticalTypes + "504"')
,(N'ColumnHeadingResourceKeyConstants', N'PersonalIDTypeColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "205"')
,(N'ColumnHeadingResourceKeyConstants', N'PositionColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "638"')
,(N'ColumnHeadingResourceKeyConstants', N'ReadColumnHeading', N'InterfaceEditorResourceSetEnum.DataAccessDetailsModal + "513"')
,(N'ColumnHeadingResourceKeyConstants', N'ReciprocalRuleIndicatorColumnHeading', N'InterfaceEditorResourceSetEnum.SearchAccessRules + "217"')
,(N'ColumnHeadingResourceKeyConstants', N'ReportDiseaseGroupColumnHeading', N'InterfaceEditorResourceSetEnum.ReportDiagnosisGroupDiagnosisMatrix + "229"')
,(N'ColumnHeadingResourceKeyConstants', N'RowColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "235"')
,(N'ColumnHeadingResourceKeyConstants', N'SampleCodeColumnHeading', N'InterfaceEditorResourceSetEnum.SampleTypesReferenceEditor + "44"')
,(N'ColumnHeadingResourceKeyConstants', N'SampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'SanitaryActionColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "237"')
,(N'ColumnHeadingResourceKeyConstants', N'SanitaryCodeColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "238"')
,(N'ColumnHeadingResourceKeyConstants', N'SiteNameColumnHeading', N'InterfaceEditorResourceSetEnum.ReceivingActors + "252"')
,(N'ColumnHeadingResourceKeyConstants', N'SpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'SpeciesCodeColumnHeading', N'InterfaceEditorResourceSetEnum.SpeciesTypesReferenceEditor + "44"')
,(N'ColumnHeadingResourceKeyConstants', N'StatisticalAgeGroupColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "256"')
,(N'ColumnHeadingResourceKeyConstants', N'SyndromicSurveillanceColumnHeading', N'InterfaceEditorResourceSetEnum.DiseasesReferenceEditor + "259"')
,(N'ColumnHeadingResourceKeyConstants', N'TestCategoryColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "266"')
,(N'ColumnHeadingResourceKeyConstants', N'TestNameColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "267"')
,(N'ColumnHeadingResourceKeyConstants', N'TestResultColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "268"')
,(N'ColumnHeadingResourceKeyConstants', N'TimeIntervalColumnHeading', N'InterfaceEditorResourceSetEnum.AggregateSettings + "509"')
,(N'ColumnHeadingResourceKeyConstants', N'UniqueOrganizationIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchOrganizations + "594"')
,(N'ColumnHeadingResourceKeyConstants', N'UpperBoundColumnHeading', N'InterfaceEditorResourceSetEnum.AgeGroupsReferenceEditor + "273"')
,(N'ColumnHeadingResourceKeyConstants', N'UsingTypeColumnHeading', N'InterfaceEditorResourceSetEnum.DiseasesReferenceEditor + "277"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorTypeColumnHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "278"')
,(N'ColumnHeadingResourceKeyConstants', N'ZoonoticDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.DiseasesReferenceEditor + "282"')

,(N'ColumnHeadingResourceKeyConstants', N'SearchActorsModalActorNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchActorsModal + "501"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchActorsModalActorTypeNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchActorsModal + "500"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchActorsModalOrganizationNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchActorsModal + "661"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchActorsModalDescriptionColumnHeading', N'InterfaceEditorResourceSetEnum.SearchActorsModal + "610"')

--region Administration Module Resources

--        //SAUC01 and SAUC02 - Enter and Edit Employee Record
,(N'ColumnHeadingResourceKeyConstants', N'EmployeeRowColumnHeading', N'InterfaceEditorResourceSetEnum.Employees + "235"')
,(N'ColumnHeadingResourceKeyConstants', N'EmployeeSiteIDColumnHeading', N'InterfaceEditorResourceSetEnum.Employees + "650"')
,(N'ColumnHeadingResourceKeyConstants', N'EmployeeOrganizationColumnHeading', N'InterfaceEditorResourceSetEnum.Employees + "661"')
,(N'ColumnHeadingResourceKeyConstants', N'EmployeeUserGroupColumnHeading', N'InterfaceEditorResourceSetEnum.Employees + "706"')
,(N'ColumnHeadingResourceKeyConstants', N'EmployeeStatusColumnHeading', N'InterfaceEditorResourceSetEnum.Employees + "707"')
,(N'ColumnHeadingResourceKeyConstants', N'EmployeeDefaultColumnHeading', N'InterfaceEditorResourceSetEnum.Employees + "57"')
,(N'ColumnHeadingResourceKeyConstants', N'EmployeesActiveHeading', N'InterfaceEditorResourceSetEnum.Employees + "917"')
,(N'ColumnHeadingResourceKeyConstants', N'EmployeesFunctionsColumnHeading', N'InterfaceEditorResourceSetEnum.Employees + "3923"')

--        //SAUC03 - Search Employee Record
,(N'ColumnHeadingResourceKeyConstants', N'SearchEmployeeAccountStateColumnHeading', N'InterfaceEditorResourceSetEnum.SearchEmployees + "637"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchEmployeeEmployeeCategoryColumnHeading', N'InterfaceEditorResourceSetEnum.SearchEmployees + "636"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchEmployeeFirstNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchEmployees + "600"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchEmployeeLastNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchEmployees + "599"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchEmployeeMiddleNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchEmployees + "660"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchEmployeeOrganizationColumnHeading', N'InterfaceEditorResourceSetEnum.SearchEmployees + "661"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchEmployeePhoneColumnHeading', N'InterfaceEditorResourceSetEnum.SearchEmployees + "639"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchEmployeePositionColumnHeading', N'InterfaceEditorResourceSetEnum.SearchEmployees + "638"')

--        //SAUC11 - Search Administrative Unit Record
,(N'ColumnHeadingResourceKeyConstants', N'SearchAdministrativeUnitsDefaultNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "2732"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchAdministrativeUnitsNationalNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "2733"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchAdministrativeUnitsAdministrativeLevelColumnHeading', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "508"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchAdministrativeUnitsSettlementTypeColumnHeading', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "2737"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchAdministrativeUnitsAdministrativeLevel0ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "652"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchAdministrativeUnitsAdministrativeLevel1ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "604"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchAdministrativeUnitsAdministrativeLevel2ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "603"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchAdministrativeUnitsAdministrativeLevel3ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "2413"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchAdministrativeUnitsLatitudeColumnHeading', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "2734"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchAdministrativeUnitsLongitudeColumnHeading', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "2735"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchAdministrativeUnitsElevationColumnHeading', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "2736"')

--        //SAUC13 - Statistical Data
,(N'ColumnHeadingResourceKeyConstants', N'StatisticalDataAreaColumnHeading', N'InterfaceEditorResourceSetEnum.StatisticalData + "3406"')

--        //SAUC13 - 1 - Statistical Data
,(N'ColumnHeadingResourceKeyConstants', N'StatisticalDataDateColumnHeading', N'InterfaceEditorResourceSetEnum.StatisticalData + "763"')
,(N'ColumnHeadingResourceKeyConstants', N'StatisticalDataUsernameColumnHeading', N'InterfaceEditorResourceSetEnum.StatisticalData + "2667"')
,(N'ColumnHeadingResourceKeyConstants', N'StatisticalDataInformationColumnHeading', N'InterfaceEditorResourceSetEnum.StatisticalData + "3192"')
,(N'ColumnHeadingResourceKeyConstants', N'StatisticalDataNotesColumnHeading', N'InterfaceEditorResourceSetEnum.StatisticalData + "973"')

--        //SAUC15 - Search Statistical Data Record
,(N'ColumnHeadingResourceKeyConstants', N'SearchStatisticalDataRecordValueColumnHeading', N'InterfaceEditorResourceSetEnum.SearchStatisticalDataRecord + "3387"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchStatisticalDataRecordParameterColumnHeading', N'InterfaceEditorResourceSetEnum.SearchStatisticalDataRecord + "3388"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchStatisticalDataRecordStatisticalPeriodTypeColumnHeading', N'InterfaceEditorResourceSetEnum.SearchStatisticalDataRecord + "3389"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchStatisticalDataRecordStartDateforPeriodColumnHeading', N'InterfaceEditorResourceSetEnum.SearchStatisticalDataRecord + "3390"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchStatisticalDataRecordStatisticalAreaTypeColumnHeading', N'InterfaceEditorResourceSetEnum.SearchStatisticalDataRecord + "3391"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchStatisticalDataRecordStatisticalAgeGroupColumnHeading', N'InterfaceEditorResourceSetEnum.SearchStatisticalDataRecord + "256"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchStatisticalDataRecordParameterTypeColumnHeading', N'InterfaceEditorResourceSetEnum.SearchStatisticalDataRecord + "502"')

--        //SAUC25 Search User Groups
,(N'ColumnHeadingResourceKeyConstants', N'SearchUserGroupsGroupColumnHeading', N'InterfaceEditorResourceSetEnum.SearchUserGroups + "609"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchUserGroupsDescriptionColumnHeading', N'InterfaceEditorResourceSetEnum.SearchUserGroups + "610"')

--        //SAUC26 and 27 - Enter and Edit a User Group
,(N'ColumnHeadingResourceKeyConstants', N'UserGroupDetailsAccessToGenderAndAgeDataColumnHeading', N'InterfaceEditorResourceSetEnum.UserGroupDetails + "620"')
,(N'ColumnHeadingResourceKeyConstants', N'UserGroupDetailsAccessToPersonalDataColumnHeading', N'InterfaceEditorResourceSetEnum.UserGroupDetails + "621"')
,(N'ColumnHeadingResourceKeyConstants', N'UserGroupDetailsCreateColumnHeading', N'InterfaceEditorResourceSetEnum.UserGroupDetails + "615"')
,(N'ColumnHeadingResourceKeyConstants', N'UserGroupDetailsDeleteColumnHeading', N'InterfaceEditorResourceSetEnum.UserGroupDetails + "616"')
,(N'ColumnHeadingResourceKeyConstants', N'UserGroupDetailsDescriptionColumnHeading', N'InterfaceEditorResourceSetEnum.UserGroupDetails + "610"')
,(N'ColumnHeadingResourceKeyConstants', N'UserGroupDetailsGridColumnHeading', N'InterfaceEditorResourceSetEnum.UserGroupDetails + "624"')
,(N'ColumnHeadingResourceKeyConstants', N'UserGroupDetailsExecuteColumnHeading', N'InterfaceEditorResourceSetEnum.UserGroupDetails + "619"')
,(N'ColumnHeadingResourceKeyConstants', N'UserGroupDetailsNameColumnHeading', N'InterfaceEditorResourceSetEnum.UserGroupDetails + "501"')
,(N'ColumnHeadingResourceKeyConstants', N'UserGroupDetailsOperationColumnHeading', N'InterfaceEditorResourceSetEnum.UserGroupDetails + "614"')
,(N'ColumnHeadingResourceKeyConstants', N'UserGroupDetailsOrganizationColumnHeading', N'InterfaceEditorResourceSetEnum.UserGroupDetails + "661"')
,(N'ColumnHeadingResourceKeyConstants', N'UserGroupDetailsReadColumnHeading', N'InterfaceEditorResourceSetEnum.UserGroupDetails + "513"')
,(N'ColumnHeadingResourceKeyConstants', N'UserGroupDetailsTypeColumnHeading', N'InterfaceEditorResourceSetEnum.UserGroupDetails + "500"')
,(N'ColumnHeadingResourceKeyConstants', N'UserGroupDetailsWriteColumnHeading', N'InterfaceEditorResourceSetEnum.UserGroupDetails + "618"')

,(N'ColumnHeadingResourceKeyConstants', N'SearchUsersAndUserGroupsDescriptionColumnHeading', N'InterfaceEditorResourceSetEnum.SearchUsersAndUserGroupsModal + "610"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchUsersAndUserGroupsNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchUsersAndUserGroupsModal + "501"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchUsersAndUserGroupsOrganizationColumnHeading', N'InterfaceEditorResourceSetEnum.SearchUsersAndUserGroupsModal + "661"')

--        //SAUC29 and SAUC57 - Create and Edit EIDSS Sites
,(N'ColumnHeadingResourceKeyConstants', N'SiteDetailsAccessToGenderAndAgeDataColumnHeading', N'InterfaceEditorResourceSetEnum.SiteDetails + "620"')
,(N'ColumnHeadingResourceKeyConstants', N'SiteDetailsAccessToPersonalDataColumnHeading', N'InterfaceEditorResourceSetEnum.SiteDetails + "621"')
,(N'ColumnHeadingResourceKeyConstants', N'SiteDetailsCreateDataColumnHeading', N'InterfaceEditorResourceSetEnum.SiteDetails + "615"')
,(N'ColumnHeadingResourceKeyConstants', N'SiteDetailsDeleteColumnHeading', N'InterfaceEditorResourceSetEnum.SiteDetails + "616"')
,(N'ColumnHeadingResourceKeyConstants', N'SiteDetailsReadColumnHeading', N'InterfaceEditorResourceSetEnum.SiteDetails + "513"')
,(N'ColumnHeadingResourceKeyConstants', N'SiteDetailsWriteColumnHeading', N'InterfaceEditorResourceSetEnum.SiteDetails + "618"')

--        //SAUC30 - Restore a Data Audit Log Transaction
,(N'ColumnHeadingResourceKeyConstants', N'DataAuditLogDetailsActionColumnHeading', N'InterfaceEditorResourceSetEnum.DataAuditLogDetails + "2997"')		
,(N'ColumnHeadingResourceKeyConstants', N'DataAuditLogDetailsChangedColumnNameColumnHeading', N'InterfaceEditorResourceSetEnum.DataAuditLogDetails + "2998"')		
,(N'ColumnHeadingResourceKeyConstants', N'DataAuditLogDetailsOldColumnValueColumnHeading', N'InterfaceEditorResourceSetEnum.DataAuditLogDetails + "2999"')		
,(N'ColumnHeadingResourceKeyConstants', N'DataAuditLogDetailsNewColumnValueColumnHeading', N'InterfaceEditorResourceSetEnum.DataAuditLogDetails + "3000"')		
,(N'ColumnHeadingResourceKeyConstants', N'DataAuditLogDetailsObjectIDColumnHeading', N'InterfaceEditorResourceSetEnum.DataAuditLogDetails + "3001"')		
,(N'ColumnHeadingResourceKeyConstants', N'DataAuditLogDetailsObjectID1ColumnHeading', N'InterfaceEditorResourceSetEnum.DataAuditLogDetails + "3002"')		
,(N'ColumnHeadingResourceKeyConstants', N'DataAuditLogDetailsTableNameColumnHeading', N'InterfaceEditorResourceSetEnum.DataAuditLogDetails + "3003"')

--        //SAUC31 - Search for a Data Audit Log Transaction
,(N'ColumnHeadingResourceKeyConstants', N'SearchDataAuditLogTransactionDateColumnHeading', N'InterfaceEditorResourceSetEnum.SearchDataAuditLog + "3010"')		
,(N'ColumnHeadingResourceKeyConstants', N'SearchDataAuditLogObjectTypeColumnHeading', N'InterfaceEditorResourceSetEnum.SearchDataAuditLog + "3011"')		
,(N'ColumnHeadingResourceKeyConstants', N'SearchDataAuditLogSiteColumnHeading', N'InterfaceEditorResourceSetEnum.SearchDataAuditLog + "3012"')		
,(N'ColumnHeadingResourceKeyConstants', N'SearchDataAuditLogUserColumnHeading', N'InterfaceEditorResourceSetEnum.SearchDataAuditLog + "3013"')		
,(N'ColumnHeadingResourceKeyConstants', N'SearchDataAuditLogActionColumnHeading', N'InterfaceEditorResourceSetEnum.SearchDataAuditLog + "2997"')		
,(N'ColumnHeadingResourceKeyConstants', N'SearchDataAuditLogSiteNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchDataAuditLog + "252"')		
,(N'ColumnHeadingResourceKeyConstants', N'SearchDataAuditLogSiteIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchDataAuditLog + "650"')		

--        //SAUC32 - User Search for Data Audit Log Transactions
,(N'ColumnHeadingResourceKeyConstants', N'SearchUserDataAuditLogTransactionDateColumnHeading', N'InterfaceEditorResourceSetEnum.SearchUserDataAuditLog + "3010"')		
,(N'ColumnHeadingResourceKeyConstants', N'SearchUserDataAuditLogAttributeColumnHeading', N'InterfaceEditorResourceSetEnum.SearchUserDataAuditLog + "3016"')		
,(N'ColumnHeadingResourceKeyConstants', N'SearchUserDataAuditLogOldValueColumnHeading', N'InterfaceEditorResourceSetEnum.SearchUserDataAuditLog + "3018"')		
,(N'ColumnHeadingResourceKeyConstants', N'SearchUserDataAuditLogNewValueColumnHeading', N'InterfaceEditorResourceSetEnum.SearchUserDataAuditLog + "3019"')		

--        //SAUC54 - System Functions
,(N'ColumnHeadingResourceKeyConstants', N'SystemFunctionsNameColumnHeading', N'InterfaceEditorResourceSetEnum.SystemFunctions + "501"')

--        //SAUC56 - Notifications/Site Alert Messenger
,(N'ColumnHeadingResourceKeyConstants', N'SiteAlertMessengerModalMessageTypeColumnHeading', N'InterfaceEditorResourceSetEnum.SiteAlertMessengerModal + "3185"')
,(N'ColumnHeadingResourceKeyConstants', N'SiteAlertMessengerModalDateColumnHeading', N'InterfaceEditorResourceSetEnum.SiteAlertMessengerModal + "906"')
,(N'ColumnHeadingResourceKeyConstants', N'SiteAlertMessengerModalSiteIDColumnHeading', N'InterfaceEditorResourceSetEnum.SiteAlertMessengerModal + "650"')
,(N'ColumnHeadingResourceKeyConstants', N'SiteAlertMessengerModalAdministrativeLevel1ColumnHeading', N'InterfaceEditorResourceSetEnum.SiteAlertMessengerModal + "604"')
,(N'ColumnHeadingResourceKeyConstants', N'SiteAlertMessengerModalAdministrativeLevel2ColumnHeading', N'InterfaceEditorResourceSetEnum.SiteAlertMessengerModal + "603"')
,(N'ColumnHeadingResourceKeyConstants', N'SiteAlertMessengerModalDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.SiteAlertMessengerModal + "662"')

--        //SAUC57 - Search Sites
,(N'ColumnHeadingResourceKeyConstants', N'SearchSitesSiteIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchSites + "650"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchSitesSiteCodeColumnHeading', N'InterfaceEditorResourceSetEnum.SearchSites + "653"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchSitesSiteNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchSites + "252"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchSitesSiteTypeColumnHeading', N'InterfaceEditorResourceSetEnum.SearchSites + "654"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchSitesHASCBasedSiteIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchSites + "632"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchSitesOrganizationNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchSites + "494"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchSitesCountryColumnHeading', N'InterfaceEditorResourceSetEnum.SearchSites + "652"')

,(N'ColumnHeadingResourceKeyConstants', N'SearchSitesModalSiteIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchSitesModal + "650"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchSitesModalSiteCodeColumnHeading', N'InterfaceEditorResourceSetEnum.SearchSitesModal + "653"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchSitesModalSiteNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchSitesModal + "252"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchSitesModalSiteTypeColumnHeading', N'InterfaceEditorResourceSetEnum.SearchSitesModal + "654"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchSitesModalHASCBasedSiteIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchSitesModal + "632"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchSitesModalOrganizationNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchSitesModal + "494"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchSitesModalCountryColumnHeading', N'InterfaceEditorResourceSetEnum.SearchSitesModal + "652"')

,(N'ColumnHeadingResourceKeyConstants', N'SearchSiteGroupsSiteGroupIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchSiteGroups + "658"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchSiteGroupsSiteGroupNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchSiteGroups + "656"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchSiteGroupsSiteGroupTypeColumnHeading', N'InterfaceEditorResourceSetEnum.SearchSiteGroups + "657"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchSiteGroupsAdministrativeLevel3NameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchSiteGroups + "603"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchSiteGroupsAdministrativeLevelColumnHeading', N'InterfaceEditorResourceSetEnum.SearchSiteGroups + "508"')
        
,(N'ColumnHeadingResourceKeyConstants', N'SiteGroupSitesSiteNameColumnHeading', N'InterfaceEditorResourceSetEnum.SiteGroupSites + "252"')
,(N'ColumnHeadingResourceKeyConstants', N'SiteGroupSitesEIDSSSiteIDColumnHeading', N'InterfaceEditorResourceSetEnum.SiteGroupSites + "653"')

--        //SAUC55 - Site Alerts Subscription
,(N'ColumnHeadingResourceKeyConstants', N'SiteAlertsSubscriptionEventNameColumnHeading', N'InterfaceEditorResourceSetEnum.SiteAlertSubscriptions + "699"')
,(N'ColumnHeadingResourceKeyConstants', N'SiteAlertsSubscriptionReceiveEventAlertColumnHeading', N'InterfaceEditorResourceSetEnum.SiteAlertSubscriptions + "700"')
,(N'ColumnHeadingResourceKeyConstants', N'SiteAlertsSubscriptionRecipientsColumnHeading', N'InterfaceEditorResourceSetEnum.SiteAlertSubscriptions + "701"')
,(N'ColumnHeadingResourceKeyConstants', N'SiteAlertsSubscriptionRowColumnHeading', N'InterfaceEditorResourceSetEnum.SiteAlertSubscriptions + "235"')

--region Deduplication Sub-Module Resources

--        //DDUC02 - Human Disease Report Deduplication
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsReportIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "748"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsDateEnteredColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "993"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsLocationColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "913"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsCaseClassificationColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "912"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsPersonIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "598"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsLegacyIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "1854"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsPersonNameColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "1855"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsDiseasesColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "1856"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsReportStatusColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "1857"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsEnteredbyOrganizationColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "1858"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsEnteredbyNameColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "1859"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsReportTypeColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "1860"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsHospitalizationColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "1861"')

,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportAntibioticVaccineHistoryAntibioticNameColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportAntibioticVaccineHistory + "1108"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportAntibioticVaccineHistoryDoseColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportAntibioticVaccineHistory + "1109"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportAntibioticVaccineHistoryDateAntibioticFirstAdministeredColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportAntibioticVaccineHistory + "1110"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportAntibioticVaccineHistoryVaccinationNameColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportAntibioticVaccineHistory + "1111"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportAntibioticVaccineHistoryDateOfVaccinationColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportAntibioticVaccineHistory + "1112"')

,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportSamplesLabSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportSamples + "691"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportSamplesSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportSamples + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportSamplesLocalSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportSamples + "2561"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportSamplesCollectionDateColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportSamples + "897"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportSamplesCollectedByInstitutionColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportSamples + "2562"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportSamplesCollectedByOfficerColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportSamples + "2563"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportSamplesSentDateColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportSamples + "2501"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportSamplesSentToOrganizationColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportSamples + "898"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportSamplesAccessionDateColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportSamples + "998"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportSamplesSampleConditionReceivedColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportSamples + "2564"')

,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportTestsLocalSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportTests + "2561"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportTestsLabSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportTests + "691"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportTestsSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportTests + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportTestsTestDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportTests + "901"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportTestsTestNameColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportTests + "267"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportTestsTestCategoryColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportTests + "266"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportTestsTestResultColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportTests + "268"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportTestsRuleOutRuleInColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportTests + "2508"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportTestsValidatedColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportTests + "2512"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportTestsDateReceivedColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportTests + "3914"')

,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportContactListFirstNameColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportContactList + "1809"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportContactListMiddleNameColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportContactList + "1810"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportContactListLastNameColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportContactList + "1811"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportContactListRelationColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportContactList + "2558"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportContactListDateOfLastContactColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportContactList + "2559"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportContactListPlaceOfLastContactColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportContactList + "2560"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportContactListContactsInformationColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportContactList + "1069"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationHumanDiseaseReportContactListCommentsColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportContactList + "3535"')

,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportDeduplicationReportIDColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportDeduplication + "748"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportDeduplicationPersonIDColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportDeduplication + "598"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportDeduplicationDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportDeduplication + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportDeduplicationReportStatusColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportDeduplication + "1857"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportDeduplicationDateEnteredColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportDeduplication + "993"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportDeduplicationFinalCaseClassificationColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportDeduplication + "82"')

--        //DDUC03 - Person Record Deduplication
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchPersonAdministrativeLevel2ColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchPerson + "604"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchPersonAdministrativeLevel3ColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchPerson + "603"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchPersonDateOfBirthColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchPerson + "602"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchPersonFirstNameColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchPerson + "600"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchPersonLastNameColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchPerson + "599"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchPersonPersonalIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchPerson + "601"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchPersonPersonIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchPerson + "598"')

--        //DDUC04 - Farm Record Deduplication
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchFarmFarmIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchFarm + "2408"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchFarmFarmTypeColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchFarm + "2409"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchFarmFarmOwnerNameColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchFarm + "2410"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchFarmFarmOwnerIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchFarm + "2411"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchFarmFarmNameColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchFarm + "2412"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchFarmAdministrativeLevel1ColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchFarm + "604"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchFarmAdministrativeLevel2ColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchFarm + "603"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchFarmAdministrativeLevel3ColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchFarm + "2413"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchFarmAdministrativeLevel4ColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchFarm + "2414"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchFarmAdministrativeLevel5ColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchFarm + "2415"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchFarmAdministrativeLevel6ColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchFarm + "2416"')

--        //DDUC05 - Livestock Disease Report Deduplication
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsReportIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "2408"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsDateEnteredColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "993"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsCaseClassificationColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "912"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsFarmNameColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "2412"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsFarmAddressColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "2442"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsReportStatusColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "1857"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsReportTypeColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "1860"')

,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportFarmHerdSpeciesSpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportFarmHerdSpecies + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportFarmHerdSpeciesTotalColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportFarmHerdSpecies + "782"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportFarmHerdSpeciesDeadColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportFarmHerdSpecies + "2476"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportFarmHerdSpeciesSickColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportFarmHerdSpecies + "2477"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportFarmHerdSpeciesStartOfSignsColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportFarmHerdSpecies + "2478"')

,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportAnimalsHerdIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportAnimals + "2491"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportAnimalsAnimalIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportAnimals + "694"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportAnimalsSpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportAnimals + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportAnimalsAgeColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportAnimals + "2492"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportAnimalsSexColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportAnimals + "2493"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportAnimalsStatusColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportAnimals + "707"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportAnimalsNoteAdditionalInfoColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportAnimals + "2494"')

,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportSamplesLabSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportSamples + "691"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportSamplesSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportSamples + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportSamplesFieldSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportSamples + "896"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportSamplesAnimalIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportSamples + "694"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportSamplesSpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportSamples + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportSamplesCollectionDateColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportSamples + "897"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportSamplesSentDateColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportSamples + "2501"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportSamplesSentToOrganizationColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportSamples + "898"')

,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportPensideTestsTestNameColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportPensideTests + "267"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportPensideTestsFieldSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportPensideTests + "896"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportPensideTestsSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportPensideTests + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportPensideTestsAnimalIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportPensideTests + "694"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportPensideTestsResultColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportPensideTests + "2504"')

,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportLabTestsFieldSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportLabTests + "896"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportLabTestsAnimalIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportLabTests + "694"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportLabTestsTestDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportLabTests + "901"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportLabTestsTestNameColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportLabTests + "267"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportLabTestsResultObservationColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportLabTests + "2506"')

,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportResultSummaryInterpretationsAnimalIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportResultSummaryInterpretations + "694"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportResultSummaryInterpretationsDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportResultSummaryInterpretations + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportResultSummaryInterpretationsTestNameColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportResultSummaryInterpretations + "267"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportResultSummaryInterpretationsTestCategoryColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportResultSummaryInterpretations + "266"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportResultSummaryInterpretationsLabSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportResultSummaryInterpretations + "691"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportResultSummaryInterpretationsSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportResultSummaryInterpretations + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportResultSummaryInterpretationsFieldSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportResultSummaryInterpretations + "896"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportResultSummaryInterpretationsRuleOutRuleInColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportResultSummaryInterpretations + "2508"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportResultSummaryInterpretationsCommentsRuleOutRuleInColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportResultSummaryInterpretations + "2509"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportResultSummaryInterpretationsDateInterpretedColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportResultSummaryInterpretations + "2510"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportResultSummaryInterpretationsInterpretedByColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportResultSummaryInterpretations + "2511"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportResultSummaryInterpretationsValidatedColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportResultSummaryInterpretations + "2512"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportResultSummaryInterpretationsValidatedByColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportResultSummaryInterpretations + "2513"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportResultSummaryInterpretationsCommentsValidatedColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportResultSummaryInterpretations + "2514"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationLivestockDiseaseReportResultSummaryInterpretationsDateValidatedColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportResultSummaryInterpretations + "2515"')

,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationVeterinaryDiseaseReportVaccinationsDiseaseNameColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationVeterinaryDiseaseReportVaccinations + "2485"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationVeterinaryDiseaseReportVaccinationsDateColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationVeterinaryDiseaseReportVaccinations + "906"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationVeterinaryDiseaseReportVaccinationsSpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationVeterinaryDiseaseReportVaccinations + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationVeterinaryDiseaseReportVaccinationsVaccinatedNumberColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationVeterinaryDiseaseReportVaccinations + "2486"')

,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationVeterinaryDiseaseReportCaseLogActionRequiredColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationVeterinaryDiseaseReportCaseLog + "905"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationVeterinaryDiseaseReportCaseLogDateColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationVeterinaryDiseaseReportCaseLog + "906"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationVeterinaryDiseaseReportCaseLogEnteredByColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationVeterinaryDiseaseReportCaseLog + "907"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationVeterinaryDiseaseReportCaseLogCommentColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationVeterinaryDiseaseReportCaseLog + "908"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationVeterinaryDiseaseReportCaseLogStatusColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationVeterinaryDiseaseReportCaseLog + "707"')

--        //DDUC06 - Avian Disease Report Deduplication
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsReportIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "2408"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsDateEnteredColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "993"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsCaseClassificationColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "912"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsFarmNameColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "2412"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsFarmAddressColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "2442"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsReportStatusColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "1857"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsReportTypeColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "1860"')

,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportFarmFlockSpeciesSpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportFarmFlockSpecies + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportFarmFlockSpeciesTotalColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportFarmFlockSpecies + "782"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportFarmFlockSpeciesDeadColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportFarmFlockSpecies + "2476"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportFarmFlockSpeciesSickColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportFarmFlockSpecies + "2477"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportFarmFlockSpeciesStartOfSignsColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportFarmFlockSpecies + "2478"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportFarmFlockSpeciesAverageAgeWeeksColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportFarmFlockSpecies + "2480"')

,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportSamplesLabSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportSamples + "691"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportSamplesSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportSamples + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportSamplesFieldSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportSamples + "896"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportSamplesSpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportSamples + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportSamplesBirdStatusColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportSamples + "2500"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportSamplesCollectionDateColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportSamples + "897"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportSamplesSentDateColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportSamples + "2501"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportSamplesSentToOrganizationColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportSamples + "898"')

,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportPensideTestsTestNameColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportPensideTests + "267"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportPensideTestsFieldSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportPensideTests + "896"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportPensideTestsSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportPensideTests + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportPensideTestsSpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportPensideTests + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportPensideTestsResultColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportPensideTests + "2504"')

,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportLabTestsFieldSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportLabTests + "896"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportLabTestsSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportLabTests + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportLabTestsSpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportLabTests + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportLabTestsTestDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportLabTests + "901"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportLabTestsTestNameColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportLabTests + "267"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportLabTestsResultObservationColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportLabTests + "2506"')

,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportResultSummaryInterpretationsSpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportResultSummaryInterpretations + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportResultSummaryInterpretationsDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportResultSummaryInterpretations + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportResultSummaryInterpretationsTestNameColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportResultSummaryInterpretations + "267"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportResultSummaryInterpretationsTestCategoryColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportResultSummaryInterpretations + "266"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportResultSummaryInterpretationsTestResultColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportResultSummaryInterpretations + "268"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportResultSummaryInterpretationsLabSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportResultSummaryInterpretations + "691"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportResultSummaryInterpretationsSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportResultSummaryInterpretations + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportResultSummaryInterpretationsFieldSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportResultSummaryInterpretations + "896"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportResultSummaryInterpretationsRuleOutRuleInColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportResultSummaryInterpretations + "2508"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportResultSummaryInterpretationsCommentsRuleOutRuleInColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportResultSummaryInterpretations + "2509"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportResultSummaryInterpretationsDateInterpretedColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportResultSummaryInterpretations + "2510"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportResultSummaryInterpretationsInterpretedByColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportResultSummaryInterpretations + "2511"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportResultSummaryInterpretationsValidatedColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportResultSummaryInterpretations + "2512"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportResultSummaryInterpretationsValidatedByColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportResultSummaryInterpretations + "2513"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportResultSummaryInterpretationsCommentsValidatedColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportResultSummaryInterpretations + "2514"')
,(N'ColumnHeadingResourceKeyConstants', N'DeduplicationAvianDiseaseReportResultSummaryInterpretationsDateValidatedColumnHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportResultSummaryInterpretations + "2515"')


--region Configuration Module Resources

,(N'ColumnHeadingResourceKeyConstants', N'ConfigureVeterinaryAggregateReportMatrixDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateCaseMatrix + "662"')

--        //SCUC14 - Configure Vector Type - Field Tests Matrix
,(N'ColumnHeadingResourceKeyConstants', N'VectorTypeFieldTestMatrixFieldTestColumnHeading', N'InterfaceEditorResourceSetEnum.VectorTypeFieldTestMatrix + "955"')

--        //SCUC17 - Configure Custom Report
,(N'ColumnHeadingResourceKeyConstants', N'CustomReportRowsNameColumnHeading', N'InterfaceEditorResourceSetEnum.CustomReportRows + "501"')

--        //SCUC22 - Configure Unique Numbering Schema
,(N'ColumnHeadingResourceKeyConstants', N'UniqueNumberingSchemaRowColumnHeading', N'InterfaceEditorResourceSetEnum.UniqueNumberingSchema + "235"')
,(N'ColumnHeadingResourceKeyConstants', N'UniqueNumberingSchemaIDTypeDefaultColumnHeading', N' InterfaceEditorResourceSetEnum.UniqueNumberingSchema + "787"')
,(N'ColumnHeadingResourceKeyConstants', N'UniqueNumberingSchemaIDTypeNationalColumnHeading', N' InterfaceEditorResourceSetEnum.UniqueNumberingSchema + "788"')
,(N'ColumnHeadingResourceKeyConstants', N'UniqueNumberingSchemaPrefixColumnHeading', N'InterfaceEditorResourceSetEnum.UniqueNumberingSchema + "789"')
,(N'ColumnHeadingResourceKeyConstants', N'UniqueNumberingSchemaSiteIDColumnHeading', N'InterfaceEditorResourceSetEnum.UniqueNumberingSchema + "650"')
,(N'ColumnHeadingResourceKeyConstants', N'UniqueNumberingSchemaYearColumnHeading', N'InterfaceEditorResourceSetEnum.UniqueNumberingSchema + "790"')
,(N'ColumnHeadingResourceKeyConstants', N'UniqueNumberingSchemaLastDocumentNumberColumnHeading', N'InterfaceEditorResourceSetEnum.UniqueNumberingSchema + "791"')				
,(N'ColumnHeadingResourceKeyConstants', N'UniqueNumberingSchemaNextNumberValueColumnHeading', N'InterfaceEditorResourceSetEnum.UniqueNumberingSchema + "792"')
,(N'ColumnHeadingResourceKeyConstants', N'UniqueNumberingSchemaSpecialCharacterColumnHeading', N'InterfaceEditorResourceSetEnum.UniqueNumberingSchema + "793"')
,(N'ColumnHeadingResourceKeyConstants', N'UniqueNumberingSchemaSuffixColumnHeading', N'InterfaceEditorResourceSetEnum.UniqueNumberingSchema + "794"')
,(N'ColumnHeadingResourceKeyConstants', N'UniqueNumberingSchemaMinimumLengthColumnHeading', N'InterfaceEditorResourceSetEnum.UniqueNumberingSchema + "795"')


--region Human Module Resources

--        //HASUC01-02
,(N'ColumnHeadingResourceKeyConstants', N'HumanActiveSurveillanceCampaignSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanActiveSurveillanceCampaignPlannedNumberColumnHeading', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "832"')

--        //HASUC03 - Enter Human Active Surveillance Session and HASUC04 - Edit Human Active Surveillance Session
,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionDetailedSamplesPersonIDColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionDetailedSamples + "598"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionDetailedSamplesPersonAddressColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionDetailedSamples + "895"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionDetailedSamplesFieldSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionDetailedSamples + "896"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionDetailedSamplesCollectionDateColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionDetailedSamples + "897"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionDetailedSamplesSentToOrganizationColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionDetailedSamples + "898"')
        
--        //Aliquots/Derivatives
,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionDetailedSamplesLabSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionDetailedSamples + "691"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionDetailedSamplesStatusColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionDetailedSamples + "707"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionDetailedSamplesLabColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionDetailedSamples + "2502"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionDetailedSamplesFunctionalAreaColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionDetailedSamples + "693"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionDetailedSamplesAdditionalTestRequestedAndSampleNotesColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionDetailedSamples + "2538"')

,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionTestsFieldSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionTests + "896"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionTestsLabSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionTests + "691"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionTestsSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionTests + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionTestsPersonIDColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionTests + "598"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionTestsTestNameColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionTests + "267"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionTestsTestDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionTests + "901"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionTestsResultDateColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionTests + "904"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionTestsTestCategoryColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionTests + "266"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionTestsTestResultColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionTests + "268"')

,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionActionsActionRequiredColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionActions + "905"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionActionsDateColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionActions + "906"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionActionsEnteredByColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionActions + "907"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionActionsCommentColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionActions + "908"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionActionsStatusColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionActions + "707"')

,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionDiseaseReportsReportIDColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionDiseaseReports + "748"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionDiseaseReportsCaseDateColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionDiseaseReports + "911"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionDiseaseReportsCaseClassificationColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionDiseaseReports + "912"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionDiseaseReportsDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionDiseaseReports + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionDiseaseReportsLocationColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionDiseaseReports + "913"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanSessionDiseaseReportsAddressColumnHeading', N'InterfaceEditorResourceSetEnum.HumanSessionDiseaseReports + "662"')

--        //HASUC05 - Search for Human Active Surveillance Campaign
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanActiveSurveillanceCampaignCampaignIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceCampaigns + "802"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanActiveSurveillanceCampaignCampaignNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceCampaigns + "803"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanActiveSurveillanceCampaignCampaignTypeColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceCampaigns + "804"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanActiveSurveillanceCampaignCampaignStatusColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceCampaigns + "805"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanActiveSurveillanceCampaignCampaignStartDateColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceCampaigns + "806"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanActiveSurveillanceCampaignDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceCampaigns + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanActiveSurveillanceCampaignsEndDateColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceCampaigns + "1815"')

--        //HASCU06 - Search for Human Active Surveillance Session
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsSessionIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessions + "817"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsSessionStatusColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessions + "818"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsSessionStartDateColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessions + "819"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsSessionAdministrativeLevel1ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessions + "604"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsSessionAdministrativeLevel2ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessions + "603"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsSessionDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessions + "662"')

,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsModalSessionIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessionsModal + "817"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsModalSessionStatusColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessionsModal + "818"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsModalSessionStartDateColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessionsModal + "819"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsModalSessionAdministrativeLevel1ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessionsModal + "604"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsModalSessionAdministrativeLevel2ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessionsModal + "603"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsModalSessionDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessionsModal + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessions + "662"')

--        //HAUC06 - Enter ILI Aggregate Form and HAUC07 - Edit ILI Aggregate Form
,(N'ColumnHeadingResourceKeyConstants', N'ILIAggregateDetails0To4ColumnHeading', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "2706"')
,(N'ColumnHeadingResourceKeyConstants', N'ILIAggregateDetails5To14ColumnHeading', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "2707"')
,(N'ColumnHeadingResourceKeyConstants', N'ILIAggregateDetails15To29ColumnHeading', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "2708"')
,(N'ColumnHeadingResourceKeyConstants', N'ILIAggregateDetails30To64ColumnHeading', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "2709"')
,(N'ColumnHeadingResourceKeyConstants', N'ILIAggregateDetailsGreaterThanOrEqualTo65ColumnHeading', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "2710"')
,(N'ColumnHeadingResourceKeyConstants', N'ILIAggregateDetailsTotalILIColumnHeading', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "2711"')
,(N'ColumnHeadingResourceKeyConstants', N'ILIAggregateDetailsTotalAdmissionsColumnHeading', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "2712"')
,(N'ColumnHeadingResourceKeyConstants', N'ILIAggregateDetailsILISamplesColumnHeading', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "2713"')

--        //HAUC08 - Search for ILI Aggregate Form
,(N'ColumnHeadingResourceKeyConstants', N'SearchILIAggregateFormIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchILIAggregate + "2703"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchILIAggregateLegacyIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchILIAggregate + "1854"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchILIAggregateWeekColumnHeading', N'InterfaceEditorResourceSetEnum.SearchILIAggregate + "2704"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchILIAggregateNameOfHospitalSentinelStationColumnHeading', N'InterfaceEditorResourceSetEnum.SearchILIAggregate + "2705"')

--        //HUC01 - Search Person Use Case
,(N'ColumnHeadingResourceKeyConstants', N'SearchPersonAdministrativeLevel2ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchPerson + "604"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchPersonAdministrativeLevel3ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchPerson + "603"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchPersonDateOfBirthColumnHeading', N'InterfaceEditorResourceSetEnum.SearchPerson + "602"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchPersonFirstNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchPerson + "600"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchPersonLastNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchPerson + "599"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchPersonPersonalIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchPerson + "601"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchPersonPersonIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchPerson + "598"')

,(N'ColumnHeadingResourceKeyConstants', N'SearchPersonModalAdministrativeLevel1ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchPersonModal + "604"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchPersonModalAdministrativeLevel2ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchPersonModal + "603"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchPersonModalDateOfBirthColumnHeading', N'InterfaceEditorResourceSetEnum.SearchPersonModal + "602"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchPersonModalFirstNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchPersonModal + "600"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchPersonModalLastNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchPersonModal + "599"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchPersonModalPersonalIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchPersonModal + "601"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchPersonModalPersonIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchPersonModal + "598"')

--        //HUC03 - Enter a Human Disease Report and HUC05 - Edit a Human Disease Report

--        //Vaccine History
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportAntibioticVaccineHistoryAntibioticNameColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportAntibioticVaccineHistory + "1108"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportAntibioticVaccineHistoryDoseColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportAntibioticVaccineHistory + "1109"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportAntibioticVaccineHistoryDateAntibioticFirstAdministeredColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportAntibioticVaccineHistory + "1110"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportAntibioticVaccineHistoryVaccinationNameColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportAntibioticVaccineHistory + "1111"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportAntibioticVaccineHistoryDateOfVaccinationColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportAntibioticVaccineHistory + "1112"')

--        //Samples
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportSamplesSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSamples + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportSamplesLocalSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSamples + "2561"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportSamplesCollectionDateColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSamples + "897"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportSamplesCollectedbyInstitutionColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSamples + "2562"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportSamplesCollectedbyOfficerColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSamples + "2563"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportSamplesSentDateColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSamples + "2501"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportSamplesSentToOrganizationColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSamples + "898"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportSamplesAccessionDateColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSamples + "998"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportSamplesSampleConditionReceivedColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSamples + "2564"')

--        //Aliquots/Derivatives
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportSamplesLabSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSamples + "691"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportSamplesStatusColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSamples + "707"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportSamplesFunctionalAreaColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSamples + "693"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportSamplesAdditionalTestRequestedAndSampleNotesColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSamples + "2538"')

--        //Tests
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportTestsLocalSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTests + "2561"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportTestsSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTests + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportTestsTestDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTests + "901"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportTestsTestNameColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTests + "267"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportTestsTestCategoryColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTests + "266"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportTestsTestResultColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTests + "268"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportTestsRuleOutRuleInColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTests + "2508"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportTestsValidatedColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTests + "2512"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportTestsTestStatusColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTests + "880"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportTestsResultDateColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTests + "904"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportTestsDateInterpretedColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTests + "2510"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportTestsInterpretedByColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTests + "2511"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportTestsDateValidatedColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTests + "2515"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanDiseaseReportTestsValidatedByColumnHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTests + "2513"')

--        //Contacts
,(N'ColumnHeadingResourceKeyConstants', N'ContactListPersonNameFirstColumnHeading', N'InterfaceEditorResourceSetEnum.ContactList + "1809"')
,(N'ColumnHeadingResourceKeyConstants', N'ContactListPersonNameMIColumnHeading', N'InterfaceEditorResourceSetEnum.ContactList + "1810"')
,(N'ColumnHeadingResourceKeyConstants', N'ContactListPersonNameLastColumnHeading', N'InterfaceEditorResourceSetEnum.ContactList + "1811"')
,(N'ColumnHeadingResourceKeyConstants', N'ContactListRelationColumnHeading', N'InterfaceEditorResourceSetEnum.ContactList + "2558"')
,(N'ColumnHeadingResourceKeyConstants', N'ContactListDateOfLastContactColumnHeading', N'InterfaceEditorResourceSetEnum.ContactList + "2559"')
,(N'ColumnHeadingResourceKeyConstants', N'ContactListPlaceOfLastContactColumnHeading', N'InterfaceEditorResourceSetEnum.ContactList + "2560"')
,(N'ColumnHeadingResourceKeyConstants', N'ContactListContactsInformationColumnHeading', N'InterfaceEditorResourceSetEnum.ContactList + "1069"')

--        //HUC09 - Search for Human Disease Report
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanDiseaseReportsReportIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "748"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanDiseaseReportsDateEnteredColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "993"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanDiseaseReportsLocationColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "913"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanDiseaseReportsCaseClassificationColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "912"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanDiseaseReportsPersonIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "598"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanDiseaseReportsLegacyIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1854"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanDiseaseReportsPersonNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1855"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanDiseaseReportsDiseasesColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1856"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanDiseaseReportsReportStatusColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1857"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanDiseaseReportsEnteredbyOrganizationColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1858"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanDiseaseReportsEnteredbyNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1859"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanDiseaseReportsReportTypeColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1860"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanDiseaseReportsHospitalizationColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1861"')

,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanDiseaseReportsModalReportIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "748"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanDiseaseReportsModalDateEnteredColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "993"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanDiseaseReportsModalLocationColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "913"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanDiseaseReportsModalCaseClassificationColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "912"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanDiseaseReportsModalPersonIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "598"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanDiseaseReportsModalLegacyIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "1854"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanDiseaseReportsModalPersonNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "1855"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanDiseaseReportsModalDiseasesColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "1856"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanDiseaseReportsModalReportStatusColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "1857"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanDiseaseReportsModalEnteredbyOrganizationColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "1858"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanDiseaseReportsModalEnteredbyNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "1859"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanDiseaseReportsModalReportTypeColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "1860"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanDiseaseReportsModalHospitalizationColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "1861"')

--        //HAUC03 - Search for Human Aggregate Diseases Report
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanAggregateDiseaseReportsReportIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanAggregateDiseaseReports + "748"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanAggregateDiseaseReportsStartDateColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanAggregateDiseaseReports + "749"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanAggregateDiseaseReportsTimeIntervalColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanAggregateDiseaseReports + "509"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanAggregateDiseaseReportsRegionColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanAggregateDiseaseReports + "604"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanAggregateDiseaseReportsRayonColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanAggregateDiseaseReports + "603"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanAggregateDiseaseReportsSettlementColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanAggregateDiseaseReports + "752"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchHumanAggregateDiseaseReportsOrganizationColumnHeading', N'InterfaceEditorResourceSetEnum.SearchHumanAggregateDiseaseReports + "661"')

--        //HAUC09 - Search for Weekly Reporting Form
,(N'ColumnHeadingResourceKeyConstants', N'SearchWeeklyReportingFormsReportIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchWeeklyReportingForms + "748"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchWeeklyReportingFormsStartDateColumnHeading', N'InterfaceEditorResourceSetEnum.SearchWeeklyReportingForms + "749"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchWeeklyReportingFormsAdministrativeLevel1ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchWeeklyReportingForms + "604"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchWeeklyReportingFormsAdministrativelevel2ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchWeeklyReportingForms + "603"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchWeeklyReportingFormsSettlementColumnHeading', N'InterfaceEditorResourceSetEnum.SearchWeeklyReportingForms + "752"')
        
--        //HAUC10 - Search for Weekly Reporting Form
,(N'ColumnHeadingResourceKeyConstants', N'WeeklyReportingFormICD10ColumnHeading', N' InterfaceEditorResourceSetEnum.WeeklyReportingForm + "93"')
,(N'ColumnHeadingResourceKeyConstants', N'WeeklyReportingFormDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.WeeklyReportingForm + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'WeeklyReportingFormTotalColumnHeading', N'InterfaceEditorResourceSetEnum.WeeklyReportingForm + "782"')
,(N'ColumnHeadingResourceKeyConstants', N'WeeklyReportingFormAmongthemnotifiedColumnHeading', N'InterfaceEditorResourceSetEnum.WeeklyReportingForm + "784"')
,(N'ColumnHeadingResourceKeyConstants', N'WeeklyReportingFormCommentColumnHeading', N'InterfaceEditorResourceSetEnum.WeeklyReportingForm + "908"')

--        //HAUC13 - Enter Weekly Reporting Form Summary
,(N'ColumnHeadingResourceKeyConstants', N'WeeklyReportingFormSummaryAdministrativeLevel1ColumnHeading', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormSummary + "428"')
,(N'ColumnHeadingResourceKeyConstants', N'WeeklyReportingFormSummaryAdministrativeLevel2ColumnHeading', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormSummary + "426"')
,(N'ColumnHeadingResourceKeyConstants', N'WeeklyReportingFormSummaryWeek1ColumnHeading', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormSummary + "776"')
,(N'ColumnHeadingResourceKeyConstants', N'WeeklyReportingFormSummaryWeek2ColumnHeading', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormSummary + "777"')
,(N'ColumnHeadingResourceKeyConstants', N'WeeklyReportingFormSummaryWeek3ColumnHeading', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormSummary + "778"')
,(N'ColumnHeadingResourceKeyConstants', N'WeeklyReportingFormSummaryWeek4ColumnHeading', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormSummary + "779"')
,(N'ColumnHeadingResourceKeyConstants', N'WeeklyReportingFormSummaryWeek5ColumnHeading', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormSummary + "780"')
,(N'ColumnHeadingResourceKeyConstants', N'WeeklyReportingFormSummaryWeek6ColumnHeading', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormSummary + "781"')
,(N'ColumnHeadingResourceKeyConstants', N'WeeklyReportingFormSummaryWeekSubTotalColumnHeading', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormSummary + "782"')
,(N'ColumnHeadingResourceKeyConstants', N'WeeklyReportingFormSummaryTotalColumnHeading', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormSummary + "783"')
,(N'ColumnHeadingResourceKeyConstants', N'WeeklyReportingFormSummaryAmongThemNotifiedColumnHeading', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormSummary + "784"')

,(N'ColumnHeadingResourceKeyConstants', N'WeeklyReportingFormAcuteFlaccidParalysisColumnHeading', N'InterfaceEditorResourceSetEnum.WeeklyReportingForm + "4810"')		


--region Laboratory Module Resources

--        //LUC01 - Accession a Sample, LUC02 - Create an Aliquot-Derivative, LUC03 - Transfer a Sample, LUC04 - Assign a Test, LUC10 - Enter a New Sample, LUC11 - Edit a Sample, LUC13 - Search for a Sample, LUC14 - Sample Destruction, and LUC15 - Lab Record Deletion
,(N'ColumnHeadingResourceKeyConstants', N'LaboratorySamplesAccessionDateTimeColumnHeading', N'InterfaceEditorResourceSetEnum.Samples + "689"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratorySamplesAnimalIDColumnHeading', N'InterfaceEditorResourceSetEnum.Samples + "694"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratorySamplesDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.Samples + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratorySamplesFunctionalAreaColumnHeading', N'InterfaceEditorResourceSetEnum.Samples + "693"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratorySamplesLabSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.Samples + "691"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratorySamplesLocalFieldSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.Samples + "690"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratorySamplesPatientFarmOwnerColumnHeading', N'InterfaceEditorResourceSetEnum.Samples + "688"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratorySamplesReportSessionIDColumnHeading', N'InterfaceEditorResourceSetEnum.Samples + "687"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratorySamplesSampleStatusColumnHeading', N'InterfaceEditorResourceSetEnum.Samples + "692"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratorySamplesSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.Samples + "236"')

--        //LUC04 - Assign a Test, LUC05 - Enter a Test Result, LUC07 - Amend Test Result, LUC08 - Create a Batch, LUC12 - Edit a Test, LUC13 - Search for a Sample, and LUC15 - Lab Record Deletion
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTestingAccessionDateTimeColumnHeading', N'InterfaceEditorResourceSetEnum.Testing + "689"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTestingAnimalIDColumnHeading', N'InterfaceEditorResourceSetEnum.Testing + "694"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTestingDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.Testing + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTestingFunctionalAreaColumnHeading', N'InterfaceEditorResourceSetEnum.Testing + "693"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTestingLabSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.Testing + "691"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTestingLocalFieldSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.Testing + "690"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTestingPatientFarmOwnerColumnHeading', N'InterfaceEditorResourceSetEnum.Testing + "688"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTestingReportSessionIDColumnHeading', N'InterfaceEditorResourceSetEnum.Testing + "687"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTestingResultDateColumnHeading', N'InterfaceEditorResourceSetEnum.Testing + "904"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTestingSampleStatusColumnHeading', N'InterfaceEditorResourceSetEnum.Testing + "692"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTestingSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.Testing + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTestingTestCategoryColumnHeading', N'InterfaceEditorResourceSetEnum.Testing + "266"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTestingTestNameColumnHeading', N'InterfaceEditorResourceSetEnum.Testing + "267"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTestingTestResultColumnHeading', N'InterfaceEditorResourceSetEnum.Testing + "268"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTestingTestStatusColumnHeading', N'InterfaceEditorResourceSetEnum.Testing + "880"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTestingTestStartedDateColumnHeading', N'InterfaceEditorResourceSetEnum.Testing + "882"')

--        //LUC08 - Create a Batch, LUC09 - Edit a Batch, and LUC13 - Search for a Sample
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryBatchesBatchIDColumnHeading', N'InterfaceEditorResourceSetEnum.Batches + "2781"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryBatchesBatchStatusColumnHeading', N'InterfaceEditorResourceSetEnum.Batches + "2782"')

,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryBatchesAccessionDateTimeColumnHeading', N'InterfaceEditorResourceSetEnum.Batches + "689"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryBatchesDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.Batches + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryBatchesFunctionalAreaColumnHeading', N'InterfaceEditorResourceSetEnum.Batches + "693"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryBatchesLabSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.Batches + "691"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryBatchesPatientFarmOwnerColumnHeading', N'InterfaceEditorResourceSetEnum.Batches + "688"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryBatchesReportSessionIDColumnHeading', N'InterfaceEditorResourceSetEnum.Batches + "687"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryBatchesResultDateColumnHeading', N'InterfaceEditorResourceSetEnum.Batches + "904"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryBatchesSampleStatusColumnHeading', N'InterfaceEditorResourceSetEnum.Batches + "692"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryBatchesSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.Batches + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryBatchesTestCategoryColumnHeading', N'InterfaceEditorResourceSetEnum.Batches + "266"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryBatchesTestNameColumnHeading', N'InterfaceEditorResourceSetEnum.Batches + "267"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryBatchesTestResultColumnHeading', N'InterfaceEditorResourceSetEnum.Batches + "268"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryBatchesTestStatusColumnHeading', N'InterfaceEditorResourceSetEnum.Batches + "880"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryBatchesTestStartedDateColumnHeading', N'InterfaceEditorResourceSetEnum.Batches + "882"')

--        //LUC03 - Transfer a Sample, LUC06 - Edit a Transfer, LUC13 - Search for a Sample
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTransferredAccessionDateTimeColumnHeading', N'InterfaceEditorResourceSetEnum.Transferred + "689"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTransferredAnimalIDColumnHeading', N'InterfaceEditorResourceSetEnum.Transferred + "694"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTransferredDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.Transferred + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTransferredFunctionalAreaColumnHeading', N'InterfaceEditorResourceSetEnum.Transferred + "693"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTransferredLabSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.Transferred + "691"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTransferredLocalFieldSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.Transferred + "690"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTransferredPatientFarmOwnerColumnHeading', N'InterfaceEditorResourceSetEnum.Transferred + "688"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTransferredReportSessionIDColumnHeading', N'InterfaceEditorResourceSetEnum.Transferred + "687"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTransferredSampleStatusColumnHeading', N'InterfaceEditorResourceSetEnum.Transferred + "692"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTransferredSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.Transferred + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTransferredTransferIDColumnHeading', N'InterfaceEditorResourceSetEnum.Transferred + "20"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTransferredTransferredToColumnHeading', N'InterfaceEditorResourceSetEnum.Transferred + "2752"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTransferredTransferDateColumnHeading', N'InterfaceEditorResourceSetEnum.Transferred + "2753"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTransferredTestRequestedColumnHeading', N'InterfaceEditorResourceSetEnum.Transferred + "2754"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTransferredTestNameColumnHeading', N'InterfaceEditorResourceSetEnum.Transferred + "267"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTransferredTestResultColumnHeading', N'InterfaceEditorResourceSetEnum.Transferred + "268"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTransferredResultDateColumnHeading', N'InterfaceEditorResourceSetEnum.Transferred + "904"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryTransferredPointOfContactColumnHeading', N'InterfaceEditorResourceSetEnum.Transferred + "2755"')

--        //LUC01 - Accession a Sample
,(N'ColumnHeadingResourceKeyConstants', N'GroupAccessionInModalSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.GroupAccessionInModal + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'GroupAccessionInModalCollectionDateColumnHeading', N'InterfaceEditorResourceSetEnum.GroupAccessionInModal + "897"')
,(N'ColumnHeadingResourceKeyConstants', N'GroupAccessionInModalReportSessionIDColumnHeading', N'InterfaceEditorResourceSetEnum.GroupAccessionInModal + "687"')
,(N'ColumnHeadingResourceKeyConstants', N'GroupAccessionInModalSentToOrganizationColumnHeading', N'InterfaceEditorResourceSetEnum.GroupAccessionInModal + "898"')
,(N'ColumnHeadingResourceKeyConstants', N'GroupAccessionInModalPatientFarmOwnerColumnHeading', N'InterfaceEditorResourceSetEnum.GroupAccessionInModal + "688"')

--        //LUC02 - Create an Aliquot-Derivative
,(N'ColumnHeadingResourceKeyConstants', N'AliquotDerivativeModalNewLabSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.AliquotDerivativeModal + "836"')
,(N'ColumnHeadingResourceKeyConstants', N'AliquotDerivativeModalStorageLocationColumnHeading', N'InterfaceEditorResourceSetEnum.AliquotDerivativeModal + "837"')

--        //LUC07 - Amend Test Result
,(N'ColumnHeadingResourceKeyConstants', N'LaboratorySampleTestDetailsModalAmendmentDateColumnHeading', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "856"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratorySampleTestDetailsModalAmendedByPersonColumnHeading', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "857"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratorySampleTestDetailsModalAmendedByOrganizationColumnHeading', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "858"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratorySampleTestDetailsModalOriginalTestResultsColumnHeading', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "859"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratorySampleTestDetailsModalChangedTestResultColumnHeading', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "860"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratorySampleTestDetailsModalReasonForAmendmentColumnHeading', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "861"')

--        //LUC16 - Approvals Workflow
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryApprovalsActionRequestedColumnHeading', N'InterfaceEditorResourceSetEnum.Approvals + "997"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryApprovalsReportSessionIDColumnHeading', N'InterfaceEditorResourceSetEnum.Approvals + "687"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryApprovalsPatientFarmOwnerColumnHeading', N'InterfaceEditorResourceSetEnum.Approvals + "688"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryApprovalsSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.Approvals + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryApprovalsDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.Approvals + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryApprovalsLabSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.Approvals + "691"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryApprovalsSampleStatusColumnHeading', N'InterfaceEditorResourceSetEnum.Approvals + "692"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryApprovalsTestNameColumnHeading', N'InterfaceEditorResourceSetEnum.Approvals + "267"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryApprovalsTestStatusColumnHeading', N'InterfaceEditorResourceSetEnum.Approvals + "880"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryApprovalsTestResultColumnHeading', N'InterfaceEditorResourceSetEnum.Approvals + "268"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryApprovalsResultDateColumnHeading', N'InterfaceEditorResourceSetEnum.Approvals + "904"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryApprovalsAccessionDateColumnHeading', N'InterfaceEditorResourceSetEnum.Approvals + "998"')

--        //fix for localization 10/20/2023
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryApprovalsNumberOfRecordsColumnHeading', N'InterfaceEditorResourceSetEnum.Approvals + "4823"')

--        //LUC17 - Lab-My Favorites
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryMyFavoritesReportSessionIDColumnHeading', N'InterfaceEditorResourceSetEnum.MyFavorites + "687"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryMyFavoritesPatientFarmOwnerColumnHeading', N'InterfaceEditorResourceSetEnum.MyFavorites + "688"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryMyFavoritesSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.MyFavorites + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryMyFavoritesDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.MyFavorites + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryMyFavoritesLabSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.MyFavorites + "691"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryMyFavoritesTestNameColumnHeading', N'InterfaceEditorResourceSetEnum.MyFavorites + "267"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryMyFavoritesTestStatusColumnHeading', N'InterfaceEditorResourceSetEnum.MyFavorites + "880"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryMyFavoritesTestStartedDateColumnHeading', N'InterfaceEditorResourceSetEnum.MyFavorites + "882"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryMyFavoritesTestResultColumnHeading', N'InterfaceEditorResourceSetEnum.MyFavorites + "268"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryMyFavoritesResultDateColumnHeading', N'InterfaceEditorResourceSetEnum.MyFavorites + "904"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryMyFavoritesTestCategoryColumnHeading', N'InterfaceEditorResourceSetEnum.MyFavorites + "266"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryMyFavoritesAccessionDateTimeColumnHeading', N'InterfaceEditorResourceSetEnum.MyFavorites + "689"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryMyFavoritesFunctionalAreaColumnHeading', N'InterfaceEditorResourceSetEnum.MyFavorites + "693"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryMyFavoritesSampleStatusColumnHeading', N'InterfaceEditorResourceSetEnum.MyFavorites + "692"')
,(N'ColumnHeadingResourceKeyConstants', N'LaboratoryMyFavoritesAnimalIDColumnHeading', N'InterfaceEditorResourceSetEnum.MyFavorites + "694"')

--        //LUC22 - Search for a Freezer
,(N'ColumnHeadingResourceKeyConstants', N'FreezersFreezerNameColumnHeading', N'InterfaceEditorResourceSetEnum.Freezers + "1825"')
,(N'ColumnHeadingResourceKeyConstants', N'FreezersNoteColumnHeading', N'InterfaceEditorResourceSetEnum.Freezers + "1826"')
,(N'ColumnHeadingResourceKeyConstants', N'FreezersStorageTypeColumnHeading', N'InterfaceEditorResourceSetEnum.Freezers + "1827"')
,(N'ColumnHeadingResourceKeyConstants', N'FreezersBuildingColumnHeading', N'InterfaceEditorResourceSetEnum.Freezers + "1828"')
,(N'ColumnHeadingResourceKeyConstants', N'FreezersRoomColumnHeading', N'InterfaceEditorResourceSetEnum.Freezers + "1829"')


--region Outbreak Module Resources

,(N'ColumnHeadingResourceKeyConstants', N'OutbreakManagementListOutbreakIDColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakManagementList + "979"')
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakManagementListStatusColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakManagementList + "707"')
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakManagementListTypeColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakManagementList + "500"')
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakManagementListAdministrativeLevel2ColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakManagementList + "604"')
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakManagementListAdministrativeLevel3ColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakManagementList + "603"')
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakManagementListDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakManagementList + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakManagementListStartDateColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakManagementList + "749"')
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakCasesOutbreakCaseIDColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakCases + "992"')
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakCasesDateEnteredColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakCases + "993"')
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakCasesTypeColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakCases + "500"')
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakCasesStatusColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakCases + "707"')
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakCasesDateSymptonOnsetColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakCases + "996"')
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakCasesCaseClassificationColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakCases + "912"')
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakCasesLocationColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakCases + "913"')
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakSessionOutbreakInformationColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakSession + "2767"')
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakCasesTPatientFarmOwnerColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakCases + "688"')

--        //OMUC11
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakContactsPersonFarmIDButtonText', N' InterfaceEditorResourceSetEnum.OutbreakContacts + "3602"')
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakContactsNameColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "501"')
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakContactsGenderColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "86"')
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakContactsDateOfLastContactColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "2559"')
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakContactsContactStatusColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "3537"')
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakContactsCurrentLocationButtonText', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "3603"')

,(N'ColumnHeadingResourceKeyConstants', N'OutbreakCaseClinicalInformationSpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakCaseClinicalInformation + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakCaseClinicalInformationStatusColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakCaseClinicalInformation + "707"')

,(N'ColumnHeadingResourceKeyConstants', N'OutbreakCaseMonitoringMonitoringDateColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakCaseMonitoring + "3532"')

,(N'ColumnHeadingResourceKeyConstants', N'OutbreakCaseContactsContactTypeColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakCaseContacts + "3536"')
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakCaseContactsContactNameColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakCaseContacts + "3534"')
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakCaseContactsRelationColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakCaseContacts + "2558"')
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakCaseContactsDateOfLastContactColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakCaseContacts + "2559"')
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakCaseContactsPlaceOfLastContactColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakCaseContacts + "2560"')
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakCaseContactsContactStatusColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakCaseContacts + "3537"')
,(N'ColumnHeadingResourceKeyConstants', N'OutbreakCaseContactsCommentsColumnHeading', N'InterfaceEditorResourceSetEnum.OutbreakCaseContacts + "3535"')

--        //OMUC12 - Enter Outbreak Vector
,(N'ColumnHeadingResourceKeyConstants', N'CreateVectorSessionCaseSessionIDColumnHeading', N'InterfaceEditorResourceSetEnum.CreateVectorSessionCase + "817"')
,(N'ColumnHeadingResourceKeyConstants', N'CreateVectorSessionCaseStatusColumnHeading', N'InterfaceEditorResourceSetEnum.CreateVectorSessionCase + "707"')
,(N'ColumnHeadingResourceKeyConstants', N'CreateVectorSessionCaseStartDateColumnHeading', N'InterfaceEditorResourceSetEnum.CreateVectorSessionCase + "749"')
,(N'ColumnHeadingResourceKeyConstants', N'CreateVectorSessionCaseCloseDateColumnHeading', N'InterfaceEditorResourceSetEnum.CreateVectorSessionCase + "2585"')
,(N'ColumnHeadingResourceKeyConstants', N'CreateVectorSessionCaseAdministrativeLevel1ColumnHeading', N'InterfaceEditorResourceSetEnum.CreateVectorSessionCase + "604"')
,(N'ColumnHeadingResourceKeyConstants', N'CreateVectorSessionCaseAdministrativeLevel2ColumnHeading', N'InterfaceEditorResourceSetEnum.CreateVectorSessionCase + "603"')
,(N'ColumnHeadingResourceKeyConstants', N'CreateVectorSessionCaseAdministrativeLevel3ColumnHeading', N'InterfaceEditorResourceSetEnum.CreateVectorSessionCase + "2413"')
,(N'ColumnHeadingResourceKeyConstants', N'CreateVectorSessionCaseAdministrativeLevel4ColumnHeading', N'InterfaceEditorResourceSetEnum.CreateVectorSessionCase + "2414"')
,(N'ColumnHeadingResourceKeyConstants', N'CreateVectorSessionCaseAdministrativeLevel5ColumnHeading', N'InterfaceEditorResourceSetEnum.CreateVectorSessionCase + "2415"')
,(N'ColumnHeadingResourceKeyConstants', N'CreateVectorSessionCaseAdministrativeLevel6ColumnHeading', N'InterfaceEditorResourceSetEnum.CreateVectorSessionCase + "2416"')
,(N'ColumnHeadingResourceKeyConstants', N'CreateVectorSessionCaseVectorTypeColumnHeading', N'InterfaceEditorResourceSetEnum.CreateVectorSessionCase + "278"')
,(N'ColumnHeadingResourceKeyConstants', N'CreateVectorSessionCaseDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.CreateVectorSessionCase + "662"')


--region Vector Module Resources

--       //VSUC01 - Enter Vector Surveillance Session and VSUC02 - Edit Vector Surevillance Session
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionPoolVectorIDColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "2601"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionFieldPoolVectorIDColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "2602"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionVectorTypeColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "278"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionCollectionDateColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "897"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionAdministrativeLevel1ColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "604"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionAdministrativeLevel2ColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "603"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionAdministrativeLevel3ColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "2413"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionAdministrativeLevel4ColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "2414"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionAdministrativeLevel5ColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "2415"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionAdministrativeLevel6ColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "2416"')

,(N'ColumnHeadingResourceKeyConstants', N'VectorAggregateCollectionRecordIDColumnHeading', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "2607"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorAggregateCollectionVectorTypeColumnHeading', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "278"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorAggregateCollectionCollectionDateColumnHeading', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "897"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorAggregateCollectionNumberOfPoolsVectorsCollectedColumnHeading', N' InterfaceEditorResourceSetEnum.VectorAggregateCollection + "2608"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorAggregateCollectionDiseaseNumberOfPositivePoolsVectorsColumnHeading', N' InterfaceEditorResourceSetEnum.VectorAggregateCollection + "2609"')

--        //VUC05 - Enter Detailed Collection Record
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionSamplesLabSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionSamples + "691"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionSamplesFieldSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionSamples + "896"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionSamplesSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionSamples + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionSamplesDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionSamples + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionSamplesCollectionDateColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionSamples + "897"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionSamplesSentToOrganizationColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionSamples + "898"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionSamplesCollectedByInstitutionColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionSamples + "2562"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionSamplesCommentColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionSamples + "908"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionSamplesAccessionDateColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionSamples + "998"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionSamplesSampleConditionReceivedColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionSamples + "2564"')

,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionFieldTestsFieldSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionFieldTests + "896"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionFieldTestsSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionFieldTests + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionFieldTestsCollectionDateColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionFieldTests + "897"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionFieldTestsTestNameColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionFieldTests + "267"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionFieldTestsTestCategoryColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionFieldTests + "266"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionFieldTestsTestedbyInstitutionColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionFieldTests + "2633"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionFieldTestsTestedbyColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionFieldTests + "2634"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionFieldTestsTestResultColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionFieldTests + "268"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionFieldTestsResultDateColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionFieldTests + "904"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionFieldTestsDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionFieldTests + "662"')

,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionLaboratoryTestsLabSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionLaboratoryTests + "691"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionLaboratoryTestsFieldSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionLaboratoryTests + "896"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionLaboratoryTestsSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionLaboratoryTests + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionLaboratoryTestsSpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionLaboratoryTests + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionLaboratoryTestsTestNameColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionLaboratoryTests + "267"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionLaboratoryTestsTestResultColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionLaboratoryTests + "268"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionLaboratoryTestsResultDateColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionLaboratoryTests + "904"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorDetailedCollectionLaboratoryTestsDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionLaboratoryTests + "662"')

--        //VSUC06 - Enter Aggregate Collection Record
,(N'ColumnHeadingResourceKeyConstants', N'VectorAggregateCollectionDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'VectorAggregateCollectionNumberOfPositivePoolsVectorsColumnHeading', N' InterfaceEditorResourceSetEnum.VectorAggregateCollection + "2641"')

--        //VSUC03 - Search for Vector Surveillance Session
,(N'ColumnHeadingResourceKeyConstants', N'SearchVectorSurveillanceSessionsSessionIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "817"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVectorSurveillanceSessionsStatusColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "707"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVectorSurveillanceSessionsStartDateColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "749"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVectorSurveillanceSessionsCloseDateColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "2585"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVectorSurveillanceSessionsAdministrativeLevel1ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "604"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVectorSurveillanceSessionsAdministrativeLevel2ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "603"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVectorSurveillanceSessionsAdministrativeLevel3ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "2413"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVectorSurveillanceSessionsAdministrativeLevel4ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "2414"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVectorSurveillanceSessionsAdministrativeLevel5ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "2415"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVectorSurveillanceSessionsAdministrativeLevel6ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "2416"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVectorSurveillanceSessionsVectorTypeColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "278"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVectorSurveillanceSessionsDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "662"')


--region Veterinary Module Resources

,(N'ColumnHeadingResourceKeyConstants', N'VeterinaryDiseaseReportVaccinationsDiseaseNameColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinaryDiseaseReportVaccinations + "2485"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinaryDiseaseReportVaccinationsDateColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinaryDiseaseReportVaccinations + "906"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinaryDiseaseReportVaccinationsSpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinaryDiseaseReportVaccinations + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinaryDiseaseReportVaccinationsVaccinatedNumberColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinaryDiseaseReportVaccinations + "2486"')

,(N'ColumnHeadingResourceKeyConstants', N'VeterinaryDiseaseReportCaseLogActionRequiredColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinaryDiseaseReportCaseLog + "905"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinaryDiseaseReportCaseLogDateColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinaryDiseaseReportCaseLog + "906"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinaryDiseaseReportCaseLogEnteredByColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinaryDiseaseReportCaseLog + "907"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinaryDiseaseReportCaseLogCommentColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinaryDiseaseReportCaseLog + "908"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinaryDiseaseReportCaseLogStatusColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinaryDiseaseReportCaseLog + "707"')

--        //VASUC02 - Set Up Veterinary Active Surveillance Session and VASUC03 - Edit Veterinary Active Surveillance Session
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionDetailedInformationFarmIDColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2408"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionDetailedInformationFarmNameColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2412"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionDetailedInformationFarmOwnerColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2530"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionDetailedInformationFarmOwnerIDColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2411"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionDetailedInformationFarmAddressColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "914"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionDetailedInformationSpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionDetailedInformationTotalColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "782"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionDetailedInformationDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionDetailedInformationAnimalIDColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "694"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionDetailedInformationSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionDetailedInformationFieldSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "896"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionDetailedInformationCollectionDateColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "897"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionDetailedInformationSentToOrganizationColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "898"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionDetailedInformationLabSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "691"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionDetailedInformationStatusColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "707"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionDetailedInformationLabColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2502"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionDetailedInformationFunctionalAreaColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "693"')

,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionTestsFieldSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionTests + "896"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionTestsLabSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionTests + "691"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionTestsFarmIDColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionTests + "2408"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionTestsSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionTests + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionTestsAnimalIDColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionTests + "694"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionTestsTestNameColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionTests + "267"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionTestsTestDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionTests + "901"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionTestsResultDateColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionTests + "904"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionTestsTestCategoryColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionTests + "266"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionTestsTestStatusColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionTests + "880"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionTestsTestResultColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionTests + "268"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionTestsSpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionTests + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionTestsDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionTests + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionTestsRuleInRuleOutColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionTests + "2508"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionTestsCommentsRuleInRuleOutColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionTests + "2509"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionTestsDateInterpretedColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionTests + "2510"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionTestsInterpretedByColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionTests + "2511"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionTestsValidatedColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionTests + "2512"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionTestsValidatedByColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionTests + "2513"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionTestsCommentsValidatedColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionTests + "2514"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionTestsDateValidatedColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionTests + "2515"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionTestsDiseaseReportCreatedColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionTests + "2539"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionTestsDiseaseReportIDColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionTests + "2540"')

,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionActionsActionRequiredColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionActions + "905"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionActionsDateColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionActions + "906"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionActionsEnteredByColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionActions + "907"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionActionsCommentColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionActions + "908"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionActionsStatusColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionActions + "707"')

,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionAggregateInformationFarmIDColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2408"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionAggregateInformationSpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionAggregateInformationSexColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2493"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionAggregateInformationAnimalsSampledColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2541"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionAggregateInformationSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionAggregateInformationNumberOfSamplesColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2542"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionAggregateInformationCollectionDateColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "897"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionAggregateInformationPositiveNumberColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2543"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionAggregateInformationDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionAggregateInformationTotalColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "782"')

,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionDiseaseReportsReportIDColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDiseaseReports + "748"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionDiseaseReportsCaseDateColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDiseaseReports + "911"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionDiseaseReportsCaseClassificationColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDiseaseReports + "912"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionDiseaseReportsDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDiseaseReports + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionDiseaseReportsLocationColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDiseaseReports + "913"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinarySessionDiseaseReportsAddressColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDiseaseReports + "914"')

--        //VASUC04 - Search for Active Surveillance Campaign
,(N'ColumnHeadingResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceCampaignsCampaignIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceCampaigns + "802"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceCampaignsCampaignNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceCampaigns + "803"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceCampaignsCampaignTypeColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceCampaigns + "804"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceCampaignsCampaignStatusColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceCampaigns + "805"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceCampaignsCampaignStartDateColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceCampaigns + "806"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceCampaignsDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceCampaigns + "662"')

--        //VASUC05 - Search for Active Surveillance Session
,(N'ColumnHeadingResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsSessionIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessions + "817"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsSessionStatusColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessions + "818"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsSessionStartDateColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessions + "819"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsAdministrativeLevel1ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessions + "604"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsAdministrativeLevel2ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessions + "603"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsAdministrativeLevel3ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessions + "2413"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessions + "662"')

--        //VAUC07 - Search for Veterinary Aggregate Disease Report and VAUC11 - Search for Veterinary Aggregate Action Report
,(N'ColumnHeadingResourceKeyConstants', N'SearchVeterinaryAggregateDiseaseAndActionReportsReportIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVeterinaryAggregateDiseaseAndActionReports + "748"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVeterinaryAggregateDiseaseAndActionReportsTimeIntervalColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVeterinaryAggregateDiseaseAndActionReports + "509"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVeterinaryAggregateDiseaseAndActionReportsStartDateColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVeterinaryAggregateDiseaseAndActionReports + "749"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVeterinaryAggregateDiseaseAndActionReportsEndDateFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryAggregateDiseaseAndActionReports + "1815"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVeterinaryAggregateDiseaseAndActionReportsAdministrativeLevel1ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVeterinaryAggregateDiseaseAndActionReports + "604"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVeterinaryAggregateDiseaseAndActionReportsAdministrativeLevel2ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVeterinaryAggregateDiseaseAndActionReports + "603"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVeterinaryAggregateDiseaseAndActionReportsSettlementColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVeterinaryAggregateDiseaseAndActionReports + "752"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchVeterinaryAggregateDiseaseAndActionReportsOrganizationColumnHeading', N'InterfaceEditorResourceSetEnum.SearchVeterinaryAggregateDiseaseAndActionReports + "661"')

--        //VAUC13 - Enter Veterinary Aggregate Disease Reports Summary and VAUC14 - Enter Veterinary Aggregate Action Reports Summary
,(N'ColumnHeadingResourceKeyConstants', N'SelectedAggregateActionReportsReportIDColumnHeading', N'InterfaceEditorResourceSetEnum.SelectedAggregateActionReports + "748"')
,(N'ColumnHeadingResourceKeyConstants', N'SelectedAggregateActionReportsTimeIntervalColumnHeading', N'InterfaceEditorResourceSetEnum.SelectedAggregateActionReports + "509"')
,(N'ColumnHeadingResourceKeyConstants', N'SelectedAggregateActionReportsStartDateColumnHeading', N'InterfaceEditorResourceSetEnum.SelectedAggregateActionReports + "749"')
,(N'ColumnHeadingResourceKeyConstants', N'SelectedAggregateActionReportsEndDateFieldLabel', N'InterfaceEditorResourceSetEnum.SelectedAggregateActionReports + "1815"')
,(N'ColumnHeadingResourceKeyConstants', N'SelectedAggregateActionReportsAdministrativeLevel1ColumnHeading', N'InterfaceEditorResourceSetEnum.SelectedAggregateActionReports + "604"')
,(N'ColumnHeadingResourceKeyConstants', N'SelectedAggregateActionReportsAdministrativeLevel2ColumnHeading', N'InterfaceEditorResourceSetEnum.SelectedAggregateActionReports + "603"')
,(N'ColumnHeadingResourceKeyConstants', N'SelectedAggregateActionReportsSettlementColumnHeading', N'InterfaceEditorResourceSetEnum.SelectedAggregateActionReports + "752"')
,(N'ColumnHeadingResourceKeyConstants', N'SelectedAggregateActionReportsOrganizationColumnHeading', N'InterfaceEditorResourceSetEnum.SelectedAggregateActionReports + "661"')

--        //VUC04 - Enter Livestock Disease Report and VUC06 - Edit Livestock Disease Report
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportFarmHerdSpeciesHerdColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "3149"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportFarmHerdSpeciesSpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportFarmHerdSpeciesTotalColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "782"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportFarmHerdSpeciesDeadColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2476"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportFarmHerdSpeciesSickColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2477"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportFarmHerdSpeciesStartOfSignsColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2478"')

,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportAnimalsHerdIDColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportAnimals + "2491"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportAnimalsAnimalIDColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportAnimals + "694"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportAnimalsSpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportAnimals + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportAnimalsAgeColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportAnimals + "2492"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportAnimalsSexColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportAnimals + "2493"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportAnimalsStatusColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportAnimals + "707"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportAnimalsNoteAdditionalInfoColumnHeading', N' InterfaceEditorResourceSetEnum.LivestockDiseaseReportAnimals + "2494"')

,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportSamplesLabSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSamples + "691"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportSamplesSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSamples + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportSamplesFieldSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSamples + "896"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportSamplesAnimalIDColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSamples + "694"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportSamplesSpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSamples + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportSamplesCollectionDateColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSamples + "897"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportSamplesSentDateColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSamples + "2501"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportSamplesSentToOrganizationColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSamples + "898"')

--        //Aliquots/Derivatives Child Grid
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportSamplesAliquotsDerivativesLabSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSamples + "691"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportSamplesAliquotsDerivativesLabAbbreviatedNameColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSamples + "2502"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportSamplesAliquotsDerivativesStatusColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSamples + "707"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportSamplesAliquotsDerivativesFunctionalAreaColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSamples + "693"')

,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportPensideTestsTestNameColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportPensideTests + "267"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportPensideTestsFieldSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportPensideTests + "896"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportPensideTestsSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportPensideTests + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportPensideTestsAnimalIDColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportPensideTests + "694"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportPensideTestsResultColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportPensideTests + "2504"')

,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportLabTestsFieldSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportLabTests + "896"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportLabTestsAnimalIDColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportLabTests + "694"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportLabTestsTestDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportLabTests + "901"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportLabTestsTestNameColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportLabTests + "267"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportLabTestsResultObservationColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportLabTests + "2506"')

,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportResultsSummaryInterpretationAnimalIDColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportResultsSummaryInterpretation + "694"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportResultsSummaryInterpretationDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportResultsSummaryInterpretation + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportResultsSummaryInterpretationTestNameColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportResultsSummaryInterpretation + "267"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportResultsSummaryInterpretationTestCategoryColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportResultsSummaryInterpretation + "266"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportResultsSummaryInterpretationTestResultColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportResultsSummaryInterpretation + "268"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportResultsSummaryInterpretationLabSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportResultsSummaryInterpretation + "691"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportResultsSummaryInterpretationSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportResultsSummaryInterpretation + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportResultsSummaryInterpretationFieldSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportResultsSummaryInterpretation + "896"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportResultsSummaryInterpretationRuleOutRuleInColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportResultsSummaryInterpretation + "2508"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportResultsSummaryInterpretationCommentsRuleOutRuleInColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportResultsSummaryInterpretation + "2509"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportResultsSummaryInterpretationDateInterpretedColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportResultsSummaryInterpretation + "2510"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportResultsSummaryInterpretationInterpretedByColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportResultsSummaryInterpretation + "2511"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportResultsSummaryInterpretationValidatedColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportResultsSummaryInterpretation + "2512"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportResultsSummaryInterpretationValidatedByColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportResultsSummaryInterpretation + "2513"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportResultsSummaryInterpretationCommentsValidatedColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportResultsSummaryInterpretation + "2514"')
,(N'ColumnHeadingResourceKeyConstants', N'LivestockDiseaseReportResultsSummaryInterpretationDateValidatedColumnHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportResultsSummaryInterpretation + "2515"')

--        //VUC05 - Enter Avian Disease Report and VUC07 - Edit Avian Disease Report
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportFarmFlockSpeciesFlockColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "3148"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportFarmFlockSpeciesSpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportFarmFlockSpeciesTotalColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "782"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportFarmFlockSpeciesDeadColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2476"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportFarmFlockSpeciesSickColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2477"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportFarmFlockSpeciesStartOfSignsColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2478"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportFarmFlockSpeciesAverageAgeWeeksColumnHeading', N' InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2480"')

,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportSamplesLabSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSamples + "691"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportSamplesSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSamples + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportSamplesFieldSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSamples + "896"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportSamplesSpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSamples + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportSamplesBirdStatusColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSamples + "2500"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportSamplesCollectionDateColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSamples + "897"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportSamplesSentDateColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSamples + "2501"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportSamplesSentToOrganizationColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSamples + "898"')

--        //Aliquots/Derivatives Child Grid
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportSamplesAliquotsDerivativesLabSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSamples + "691"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportSamplesAliquotsDerivativesStatusColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSamples + "707"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportSamplesAliquotsDerivativesLabAbbreviatedNameColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSamples + "2502"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportSamplesAliquotsDerivativesFunctionalAreaColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSamples + "693"')

,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportPensideTestsTestNameColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportPensideTests + "267"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportPensideTestsFieldSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportPensideTests + "896"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportPensideTestsSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportPensideTests + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportPensideTestsSpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportPensideTests + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportPensideTestsResultColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportPensideTests + "2504"')

,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportLabTestsFieldSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportLabTests + "896"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportLabTestsSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportLabTests + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportLabTestsSpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportLabTests + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportLabTestsTestDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportLabTests + "901"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportLabTestsTestNameColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportLabTests + "267"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportLabTestsResultObservationColumnHeading', N' InterfaceEditorResourceSetEnum.AvianDiseaseReportLabTests + "2506"')

,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportResultsSummaryInterpretationSpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportResultsSummaryInterpretation + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportResultsSummaryInterpretationDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportResultsSummaryInterpretation + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportResultsSummaryInterpretationTestNameColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportResultsSummaryInterpretation + "267"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportResultsSummaryInterpretationTestCategoryColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportResultsSummaryInterpretation + "266"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportResultsSummaryInterpretationTestResultColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportResultsSummaryInterpretation + "268"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportResultsSummaryInterpretationLabSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportResultsSummaryInterpretation + "691"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportResultsSummaryInterpretationSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportResultsSummaryInterpretation + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportResultsSummaryInterpretationFieldSampleIDColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportResultsSummaryInterpretation + "896"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportResultsSummaryInterpretationRuleOutRuleInColumnHeading', N' InterfaceEditorResourceSetEnum.AvianDiseaseReportResultsSummaryInterpretation + "2508"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportResultsSummaryInterpretationCommentsRuleOutRuleInColumnHeading', N' InterfaceEditorResourceSetEnum.AvianDiseaseReportResultsSummaryInterpretation + "2509"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportResultsSummaryInterpretationDateInterpretedColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportResultsSummaryInterpretation + "2510"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportResultsSummaryInterpretationInterpretedByColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportResultsSummaryInterpretation + "2511"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportResultsSummaryInterpretationValidatedColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportResultsSummaryInterpretation + "2512"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportResultsSummaryInterpretationValidatedByColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportResultsSummaryInterpretation + "2513"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportResultsSummaryInterpretationCommentsValidatedColumnHeading', N' InterfaceEditorResourceSetEnum.AvianDiseaseReportResultsSummaryInterpretation + "2514"')
,(N'ColumnHeadingResourceKeyConstants', N'AvianDiseaseReportResultsSummaryInterpretationDateValidatedColumnHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportResultsSummaryInterpretation + "2515"')

--        //VUC10 - Search for an Animal Disease Report
,(N'ColumnHeadingResourceKeyConstants', N'SearchAvianDiseaseReportsReportIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "748"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchAvianDiseaseReportsDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchAvianDiseaseReportsDateEnteredColumnHeading', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "993"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchAvianDiseaseReportsCaseClassificationColumnHeading', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "912"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchAvianDiseaseReportsFarmNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "2412"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchAvianDiseaseReportsFarmAddressColumnHeading', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "2442"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchAvianDiseaseReportsReportStatusColumnHeading', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "1857"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchAvianDiseaseReportsReportTypeColumnHeading', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "1860"')

,(N'ColumnHeadingResourceKeyConstants', N'SearchLivestockDiseaseReportsReportIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "2408"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchLivestockDiseaseReportsDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchLivestockDiseaseReportsDateEnteredColumnHeading', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "993"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchLivestockDiseaseReportsCaseClassificationColumnHeading', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "912"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchLivestockDiseaseReportsFarmNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "2412"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchLivestockDiseaseReportsFarmAddressColumnHeading', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "2442"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchLivestockDiseaseReportsReportStatusColumnHeading', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "1857"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchLivestockDiseaseReportsReportTypeColumnHeading', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "1860"')

--        //VUC16 - Search for a Farm Record
,(N'ColumnHeadingResourceKeyConstants', N'SearchFarmsFarmIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchFarms + "2408"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchFarmsFarmTypeColumnHeading', N'InterfaceEditorResourceSetEnum.SearchFarms + "2409"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchFarmsFarmOwnerNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchFarms + "2410"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchFarmsFarmOwnerIDColumnHeading', N'InterfaceEditorResourceSetEnum.SearchFarms + "2411"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchFarmsFarmNameColumnHeading', N'InterfaceEditorResourceSetEnum.SearchFarms + "2412"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchFarmsAdministrativeLevel1ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchFarms + "604"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchFarmsAdministrativeLevel2ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchFarms + "603"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchFarmsAdministrativeLevel3ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchFarms + "2413"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchFarmsAdministrativeLevel4ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchFarms + "2414"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchFarmsAdministrativeLevel5ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchFarms + "2415"')
,(N'ColumnHeadingResourceKeyConstants', N'SearchFarmsAdministrativeLevel6ColumnHeading', N'InterfaceEditorResourceSetEnum.SearchFarms + "2416"')

--        //VUC17/18 - Add or Edit a Farm Record - Outbreak Grid
,(N'ColumnHeadingResourceKeyConstants', N'FarmOutbreakCasesOutbreakCaseIDColumnHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "992"')
,(N'ColumnHeadingResourceKeyConstants', N'FarmOutbreakCasesSpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'FarmOutbreakCasesDateEnteredColumnHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "993"')
,(N'ColumnHeadingResourceKeyConstants', N'FarmOutbreakCasesInvestigationDateColumnHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "3214"')
,(N'ColumnHeadingResourceKeyConstants', N'FarmOutbreakCasesDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'FarmOutbreakCasesTypeColumnHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "500"')
,(N'ColumnHeadingResourceKeyConstants', N'FarmOutbreakCasesStatusColumnHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "707"')
,(N'ColumnHeadingResourceKeyConstants', N'FarmOutbreakCasesDateSymptonOnsetColumnHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "996"')
,(N'ColumnHeadingResourceKeyConstants', N'FarmOutbreakCasesCaseClassificationColumnHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "912"')
,(N'ColumnHeadingResourceKeyConstants', N'FarmOutbreakCasesOutbreakIDColumnHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "979"')

--        //VUC17/18 - Add or Edit a Farm Record - Disease Reports Grid
insert into #Caption (captionClass, controlCaptionConstant, controlCaptionIdRaw) values
 (N'ColumnHeadingResourceKeyConstants', N'FarmDiseaseReportsReportIDColumnHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "748"')
,(N'ColumnHeadingResourceKeyConstants', N'FarmDiseaseReportsCaseDateColumnHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "911"')
,(N'ColumnHeadingResourceKeyConstants', N'FarmDiseaseReportsCaseClassificationColumnHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "912"')
,(N'ColumnHeadingResourceKeyConstants', N'FarmDiseaseReportsDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'FarmDiseaseReportsReportStatusColumnHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "1857"')
,(N'ColumnHeadingResourceKeyConstants', N'FarmDiseaseReportsSpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'FarmDiseaseReportsDateEnteredColumnHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "993"')
,(N'ColumnHeadingResourceKeyConstants', N'FarmDiseaseReportsInvestigationDateColumnHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "3214"')
,(N'ColumnHeadingResourceKeyConstants', N'FarmDiseaseReportsReportTypeColumnHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "500"')


--        //Human and Veterinary Aggregate Disease Reports Summary Common
--        //HAUC05 - Enter Human Aggregate Disease Reports Summary
--        //VAUC13 - Enter Veterinary Aggregate Disease Reports Summary
,(N'ColumnHeadingResourceKeyConstants', N'SelectedAggregateDiseaseReportsReportIDColumnHeading', N'InterfaceEditorResourceSetEnum.SelectedAggregateDiseaseReports + "748"')
,(N'ColumnHeadingResourceKeyConstants', N'SelectedAggregateDiseaseReportsTimeIntervalColumnHeading', N'InterfaceEditorResourceSetEnum.SelectedAggregateDiseaseReports + "509"')
,(N'ColumnHeadingResourceKeyConstants', N'SelectedAggregateDiseaseReportsStartDateColumnHeading', N'InterfaceEditorResourceSetEnum.SelectedAggregateDiseaseReports + "749"')
,(N'ColumnHeadingResourceKeyConstants', N'SelectedAggregateDiseaseReportsEndDateFieldLabel', N'InterfaceEditorResourceSetEnum.SelectedAggregateDiseaseReports + "1815"')
,(N'ColumnHeadingResourceKeyConstants', N'SelectedAggregateDiseaseReportsAdministrativeLevel1ColumnHeading', N'InterfaceEditorResourceSetEnum.SelectedAggregateDiseaseReports + "604"')
,(N'ColumnHeadingResourceKeyConstants', N'SelectedAggregateDiseaseReportsAdministrativeLevel2ColumnHeading', N'InterfaceEditorResourceSetEnum.SelectedAggregateDiseaseReports + "603"')
,(N'ColumnHeadingResourceKeyConstants', N'SelectedAggregateDiseaseReportsSettlementColumnHeading', N'InterfaceEditorResourceSetEnum.SelectedAggregateDiseaseReports + "752"')
,(N'ColumnHeadingResourceKeyConstants', N'SelectedAggregateDiseaseReportsOrganizationColumnHeading', N'InterfaceEditorResourceSetEnum.SelectedAggregateDiseaseReports + "661"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanAggregateDiseaseReportSummaryDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportSummary + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanAggregateDiseaseReportSummaryICD10ColumnHeading', N' InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportSummary + "93"')

--        //HAUC01 - Enter Human Aggregate Disease Reports
,(N'ColumnHeadingResourceKeyConstants', N'HumanAggregateDiseaseReportDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanAggregateDiseaseReportICD10ColumnHeading', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "93"')


--        //Human and Veterinary Active Surveillance Campaign Common
--        //HASUC01 - Enter Active Surveillance Campaign and HASUC02 - Edit Active Surveillance Campaign
--        //VASUC01 - Enter Active Surveillance Campaign and VASUC06 - Edit Active Surveillance Campaign
,(N'ColumnHeadingResourceKeyConstants', N'CampaignInformationDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.CampaignInformation + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'CampaignInformationSpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.CampaignInformation + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'CampaignInformationSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.CampaignInformation + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'CampaignInformationPlannedNumberColumnHeading', N'InterfaceEditorResourceSetEnum.CampaignInformation + "832"')
,(N'ColumnHeadingResourceKeyConstants', N'CampaignInformationCommentsDescriptionsColumnHeading', N' InterfaceEditorResourceSetEnum.CampaignInformation + "2517"')


,(N'ColumnHeadingResourceKeyConstants', N'HumanActiveSurveillanceCampaignSessionIDColumnHeading', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "817"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanActiveSurveillanceCampaignSessionStatusColumnHeading', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "818"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanActiveSurveillanceCampaignSessionStartDateColumnHeading', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "819"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanActiveSurveillanceCampaignSessionEndDateColumnHeading', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "2518"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanActiveSurveillanceCampaignSessionAdministrativeLevel1ColumnHeading', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "604"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanActiveSurveillanceCampaignSessionAdministrativeLevel2ColumnHeading', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "603"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanActiveSurveillanceCampaignSessionSettlementColumnHeading', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "752"')

,(N'ColumnHeadingResourceKeyConstants', N'VeterinaryActiveSurveillanceCampaignSessionIDColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceCampaign + "817"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinaryActiveSurveillanceCampaignSessionStatusColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceCampaign + "818"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinaryActiveSurveillanceCampaignSessionStartDateColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceCampaign + "819"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinaryActiveSurveillanceCampaignSessionEndDateColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceCampaign + "2518"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinaryActiveSurveillanceCampaignSessionAdministrativeLevel1ColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceCampaign + "604"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinaryActiveSurveillanceCampaignSessionAdministrativeLevel2ColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceCampaign + "603"')
,(N'ColumnHeadingResourceKeyConstants', N'VeterinaryActiveSurveillanceCampaignSessionSettlementColumnHeading', N'InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceCampaign + "752"')

--        //Human and Veterinary Active Surveillance Session Common
--        //HASUC03 - Enter Human Active Surveillance Session and HASUC04 - Edit Human Active Surveillance Session
--        //VASUC02 - Set Up Veterinary Active Surveillance Session and VASUC03 - Edit Veterinary Active Surveillance Session
,(N'ColumnHeadingResourceKeyConstants', N'SessionInformationDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.SessionInformation + "662"')
,(N'ColumnHeadingResourceKeyConstants', N'SessionInformationSpeciesColumnHeading', N'InterfaceEditorResourceSetEnum.SessionInformation + "254"')
,(N'ColumnHeadingResourceKeyConstants', N'SessionInformationSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.SessionInformation + "236"')

--region WHO Export
--        //SINT03
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDCaseIDColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4612"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDAreaIDColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4613"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDDateofonsetofrashColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4614"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDAgeofrashonsetColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4615"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDNumberofmeaslesrubellavaccineColumnHeading', N' InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4616"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDDateoflastmeaslesvaccinationColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4617"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDDateofnotificationColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4618"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDDateofinvestigationColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4619"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDFeverColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4620"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDCoughorcoryzaorconjunctivitisColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4621"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDDurationofrashColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4622"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDOutcomeColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4623"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDSourceofInfectionColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4624"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDOutbreakrelatedColumnHeading', N' InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4625"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDComplicationsColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4626"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDEncephalitisColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4627"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDPneumoniaColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4628"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDMalnutritionColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4629"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDDiarrheaColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4630"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDOtherColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4631"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDFinalClassificationColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4632"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDDateofCollectionColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4633"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDDateoflaboratoryresultsColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4634"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDMeasleslgMColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4635"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDMeaslesvirusdetectionColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4636"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDRubellalgMColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4637"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDRubellavirusdetectionColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4638"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDGenderColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "86"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDSampleTypeColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "236"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDDateofBirthColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "602"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDOutbreakIDColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "979"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDHospitalizationColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "1861"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDCommentsColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "3535"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDImportationcountryColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4639"')
,(N'ColumnHeadingResourceKeyConstants', N'HumanExporttoCISIDInitialDiagnosisColumnHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4640"')

--        //fix for localization
,(N'ColumnHeadingResourceKeyConstants', N'MainPageInvestigationsGridDateEnteredColumnHeading', N'InterfaceEditorResourceSetEnum.Global + "4824"')
,(N'ColumnHeadingResourceKeyConstants', N'MainPageInvestigationsGridDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.Global + "4825"')
,(N'ColumnHeadingResourceKeyConstants', N'MainPageInvestigationsGridInvestigationDateColumnHeading', N'InterfaceEditorResourceSetEnum.Global + "4826"')
,(N'ColumnHeadingResourceKeyConstants', N'MainPageInvestigationsGridClassificationColumnHeading', N'InterfaceEditorResourceSetEnum.Global + "4827"')
,(N'ColumnHeadingResourceKeyConstants', N'MainPageInvestigationsGridAddressColumnHeading', N'InterfaceEditorResourceSetEnum.Global + "4828"')
,(N'ColumnHeadingResourceKeyConstants', N'MainPageMyInvestigationsGridDateEnteredColumnHeading', N'InterfaceEditorResourceSetEnum.Global + "4829"')
,(N'ColumnHeadingResourceKeyConstants', N'MainPageMyInvestigationsGridInvestigationDateColumnHeading', N'InterfaceEditorResourceSetEnum.Global + "4830"')
,(N'ColumnHeadingResourceKeyConstants', N'MainPageMyInvestigationsGridClassificationColumnHeading', N'InterfaceEditorResourceSetEnum.Global + "4831"')
,(N'ColumnHeadingResourceKeyConstants', N'MainPageMyInvestigationsGridDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.Global + "4832"')
,(N'ColumnHeadingResourceKeyConstants', N'MainPageMyInvestigationsGridAddressColumnHeading', N'InterfaceEditorResourceSetEnum.Global + "4833"')
,(N'ColumnHeadingResourceKeyConstants', N'MainPageMyNotificationsGridDateEnteredColumnHeading', N'InterfaceEditorResourceSetEnum.Global + "4834"')
,(N'ColumnHeadingResourceKeyConstants', N'MainPageMyNotificationsGridReportIdColumnHeading', N'InterfaceEditorResourceSetEnum.Global + "4835"')
,(N'ColumnHeadingResourceKeyConstants', N'MainPageMyNotificationsGridPersonColumnHeading', N'InterfaceEditorResourceSetEnum.Global + "4836"')
,(N'ColumnHeadingResourceKeyConstants', N'MainPageMyNotificationsGridDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.Global + "4837"')
,(N'ColumnHeadingResourceKeyConstants', N'MainPageMyNotificationsGridDiseaseDateColumnHeading', N'InterfaceEditorResourceSetEnum.Global + "4838"')
,(N'ColumnHeadingResourceKeyConstants', N'MainPageMyNotificationsGridClassificationColumnHeading', N'InterfaceEditorResourceSetEnum.Global + "4839"')
,(N'ColumnHeadingResourceKeyConstants', N'MainPageMyNotificationsGridInvestigatedByDateColumnHeading', N'InterfaceEditorResourceSetEnum.Global + "4840"')
,(N'ColumnHeadingResourceKeyConstants', N'MainPageMyCollectionsGridSessionIdColumnHeading', N'InterfaceEditorResourceSetEnum.Global + "4841"')
,(N'ColumnHeadingResourceKeyConstants', N'MainPageMyCollectionsGridDateEnteredColumnHeading', N'InterfaceEditorResourceSetEnum.Global + "4842"')
,(N'ColumnHeadingResourceKeyConstants', N'MainPageMyCollectionsGridVectorPoolsColumnHeading', N'InterfaceEditorResourceSetEnum.Global + "4843"')
,(N'ColumnHeadingResourceKeyConstants', N'MainPageMyCollectionsGridDiseaseColumnHeading', N'InterfaceEditorResourceSetEnum.Global + "4844"')
,(N'ColumnHeadingResourceKeyConstants', N'MainPageMyCollectionsGridStartDateColumnHeading', N'InterfaceEditorResourceSetEnum.Global + "4845"')
,(N'ColumnHeadingResourceKeyConstants', N'MainPageMyCollectionsGridRegionColumnHeading', N'InterfaceEditorResourceSetEnum.Global + "4846"')
,(N'ColumnHeadingResourceKeyConstants', N'MainPageMyCollectionsGridRayonColumnHeading', N'InterfaceEditorResourceSetEnum.Global + "4847"')
,(N'ColumnHeadingResourceKeyConstants', N'MainPageNotificationsGridNotifyingOrganisationColumnHeading', N'InterfaceEditorResourceSetEnum.Global + "4820"')
,(N'ColumnHeadingResourceKeyConstants', N'MainPageNotificationsGridNotifiedByColumnHeading', N'InterfaceEditorResourceSetEnum.Global + "4821"')

,(N'ColumnHeadingResourceKeyConstants', N'MainPageELECTRONICINTEGRATEDDISEASESURVEILLANCESYSTEMHeading', N'InterfaceEditorResourceSetEnum.Global + "4822"')


--HeadingResourceKeyConstants

--region Common Resources

insert into #Caption (captionClass, controlCaptionConstant, controlCaptionIdRaw) values
 (N'HeadingResourceKeyConstants', N'EIDSSModalHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "137"')
,(N'HeadingResourceKeyConstants', N'EIDSSSuccessModalHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "2802"')
,(N'HeadingResourceKeyConstants', N'EIDSSWarningModalHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "2803"')
,(N'HeadingResourceKeyConstants', N'EIDSSErrorModalHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "2804"')
,(N'HeadingResourceKeyConstants', N'LoginPageHeading', N'InterfaceEditorResourceSetEnum.Login + "196"')
,(N'HeadingResourceKeyConstants', N'ReviewHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "234"')
,(N'HeadingResourceKeyConstants', N'SearchCriteriaHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "242"')
,(N'HeadingResourceKeyConstants', N'ChooseFileForUpload', N'InterfaceEditorResourceSetEnum.CommonHeadings + "245"')
,(N'HeadingResourceKeyConstants', N'AdvancedSearchCriteriaHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "21"')
,(N'HeadingResourceKeyConstants', N'SearchResultsHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "244"')
,(N'HeadingResourceKeyConstants', N'CommonHeadingsSuccessHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "967"')

,(N'HeadingResourceKeyConstants', N'LocationSelectLocationHeading', N'InterfaceEditorResourceSetEnum.Location + "3372"')
,(N'HeadingResourceKeyConstants', N'LocationSetLocationHeading', N'InterfaceEditorResourceSetEnum.Location + "4798"')		

,(N'HeadingResourceKeyConstants', N'AddInvestigationTypeModalHeading', N'InterfaceEditorResourceSetEnum.AddInvestigationTypeModal + "493"')
,(N'HeadingResourceKeyConstants', N'AddPersonalIDTypeModalHeading', N'InterfaceEditorResourceSetEnum.AddPersonalIDTypeModal + "768"')
,(N'HeadingResourceKeyConstants', N'AddPositionModalHeading', N'InterfaceEditorResourceSetEnum.AddPositionModal + "769"')
,(N'HeadingResourceKeyConstants', N'AddSanitaryActionModalHeading', N'InterfaceEditorResourceSetEnum.AddSanitaryActionModal + "770"')
,(N'HeadingResourceKeyConstants', N'AddSpeciesModalHeading', N'InterfaceEditorResourceSetEnum.AddSpeciesModal + "853"')
,(N'HeadingResourceKeyConstants', N'AddVaccineRouteModalHeading', N'InterfaceEditorResourceSetEnum.AddVaccineRouteModal + "933"')
,(N'HeadingResourceKeyConstants', N'AddVaccineTypeModalHeading', N'InterfaceEditorResourceSetEnum.AddVaccineTypeModal + "934"')
,(N'HeadingResourceKeyConstants', N'AddRecordModalHeading', N'InterfaceEditorResourceSetEnum.AddRecordModal + "4747"')

,(N'HeadingResourceKeyConstants', N'CommonHeadingsPrintHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "4752"')



--region Administration Module Resources

,(N'HeadingResourceKeyConstants', N'DepartmentsHeading', N'InterfaceEditorResourceSetEnum.OrganizationInformation + "66"')
,(N'HeadingResourceKeyConstants', N'DepartmentDetailsModalHeading', N'InterfaceEditorResourceSetEnum.AddDepartmentModal + "557"')
,(N'HeadingResourceKeyConstants', N'OrganizationInfoHeading', N'InterfaceEditorResourceSetEnum.OrganizationInformation + "156"')
,(N'HeadingResourceKeyConstants', N'OrganizationsPageHeading', N'InterfaceEditorResourceSetEnum.Organizations + "176"')
,(N'HeadingResourceKeyConstants', N'SystemPreferencesPageHeading', N'InterfaceEditorResourceSetEnum.SystemPreferences + "185"')
,(N'HeadingResourceKeyConstants', N'UserPreferencesPageHeading', N'InterfaceEditorResourceSetEnum.UserPreferences + "459"')
,(N'HeadingResourceKeyConstants', N'SytemPreferencesDefault', N'InterfaceEditorResourceSetEnum.SystemPreferences + "4852"')
,(N'HeadingResourceKeyConstants', N'DataArchivingSettingsNotSet', N'InterfaceEditorResourceSetEnum.DataArchivingSettings + "4853"')

--        //SAUC01 and SAUC02 - Enter and Edit Employee Record
,(N'HeadingResourceKeyConstants', N'AccountManagementHeading', N'InterfaceEditorResourceSetEnum.Employees + "568"')
,(N'HeadingResourceKeyConstants', N'AccountSettingsHeading', N'InterfaceEditorResourceSetEnum.Employees + "569"')
,(N'HeadingResourceKeyConstants', N'EmployeeDetailsModalHeading', N'InterfaceEditorResourceSetEnum.Employees + "558"')
,(N'HeadingResourceKeyConstants', N'EmployeeRoleAndPermissionsModalHeading', N'InterfaceEditorResourceSetEnum.Employees + "578"')
,(N'HeadingResourceKeyConstants', N'LoginHeading', N'InterfaceEditorResourceSetEnum.Employees + "565"')
,(N'HeadingResourceKeyConstants', N'EmployeePersonalInformationHeading', N'InterfaceEditorResourceSetEnum.Employees + "705"')
,(N'HeadingResourceKeyConstants', N'SystemFunctionsHeading', N'InterfaceEditorResourceSetEnum.Employees + "579"')
,(N'HeadingResourceKeyConstants', N'UserGroupsAndPermissionsHeading', N'InterfaceEditorResourceSetEnum.Employees + "573"')

--        //SAUC03 - Search Employee Record
,(N'HeadingResourceKeyConstants', N'EmployeeListPageHeading', N'InterfaceEditorResourceSetEnum.SearchEmployees + "725"')

--        //SAUC09 and SAUC10 - Enter and Edit Administrative Unit Record
,(N'HeadingResourceKeyConstants', N'AdministrativeUnitDetailsAdministrativeUnitInformationHeading', N'InterfaceEditorResourceSetEnum.AdministrativeUnitDetails + "2738"')

--        //SAUC11 - Search Administrative Unit Record
,(N'HeadingResourceKeyConstants', N'AdministrativeUnitsPageHeading', N'InterfaceEditorResourceSetEnum.AdministrativeUnits + "2727"')

--        //SAUC13 - Enter Statistical Data Record and SAUC14 - Edit Statistical Data Record
,(N'HeadingResourceKeyConstants', N'StatisticalDataPageHeading', N'InterfaceEditorResourceSetEnum.StatisticalData + "3588"')
,(N'HeadingResourceKeyConstants', N'StatisticalDataDetailsPageHeading', N'InterfaceEditorResourceSetEnum.StatisticalData + "2677"')

--        //SAUC17
,(N'HeadingResourceKeyConstants', N'InterfaceEditorHeading', N'InterfaceEditorResourceSetEnum.InterfaceEditor + "928"')
        
--        //SAUC30 - Restore a Data Audit Log Transaction
,(N'HeadingResourceKeyConstants', N'DataAuditLogDetailsDataAuditTransactionDetailsHeading', N'InterfaceEditorResourceSetEnum.DataAuditLogDetails + "3594"')		

--        //SAUC31 - Search for a Data Audit Log Transaction
,(N'HeadingResourceKeyConstants', N'SearchDataAuditLogDataAuditTransactionLogHeading', N'InterfaceEditorResourceSetEnum.SearchDataAuditLog + "3007"')
,(N'HeadingResourceKeyConstants', N'SearchUserDataAuditLogEIDSSIDHeading', N'InterfaceEditorResourceSetEnum.SearchUserDataAuditLog + "4749"')

--        //SAUC32 - User Search for Data Audit Log Transactions
,(N'HeadingResourceKeyConstants', N'SearchUserDataAuditLogDataAuditLogSearchHeading', N'InterfaceEditorResourceSetEnum.SearchUserDataAuditLog + "3014"')

--        //SAUC55 - Site Alerts Subscription
,(N'HeadingResourceKeyConstants', N'SiteAlertsSubscriptionPageHeading', N'InterfaceEditorResourceSetEnum.SiteAlertSubscriptions + "702"')
,(N'HeadingResourceKeyConstants', N'SiteAlertsSubscriptionSearchHeading', N'InterfaceEditorResourceSetEnum.SiteAlertSubscriptions + "2877"')

--        //SAUC56 - Notifications
,(N'HeadingResourceKeyConstants', N'SiteAlertMessengerModalSiteAlertMessengerHeading', N'InterfaceEditorResourceSetEnum.SiteAlertMessengerModal + "3026"')

--        //SAUC60 - System Event Log
,(N'HeadingResourceKeyConstants', N'SystemEventsLogSystemEventLogHeading', N'InterfaceEditorResourceSetEnum.SystemEventsLog + "4495"')		
,(N'HeadingResourceKeyConstants', N'SystemEventsLogDateHeading', N'InterfaceEditorResourceSetEnum.SystemEventsLog + "4235"')
,(N'HeadingResourceKeyConstants', N'SystemEventsLogDescriptionHeading', N'InterfaceEditorResourceSetEnum.SystemEventsLog + "4236"')
,(N'HeadingResourceKeyConstants', N'SystemEventsLogUserHeading', N'InterfaceEditorResourceSetEnum.SystemEventsLog + "4237"')
,(N'HeadingResourceKeyConstants', N'SystemEventsLogActionDateHeading', N'InterfaceEditorResourceSetEnum.SystemEventsLog + "4241"')
,(N'HeadingResourceKeyConstants', N'SystemEventsLogActionHeading', N'InterfaceEditorResourceSetEnum.SystemEventsLog + "4242"')
,(N'HeadingResourceKeyConstants', N'SystemEventsLogResultHeading', N'InterfaceEditorResourceSetEnum.SystemEventsLog + "4243"')
,(N'HeadingResourceKeyConstants', N'SystemEventsLogObjectIDHeading', N'InterfaceEditorResourceSetEnum.SystemEventsLog + "4244"')
,(N'HeadingResourceKeyConstants', N'SystemEventsLogErrorTextHeading', N'InterfaceEditorResourceSetEnum.SystemEventsLog + "4245"')
,(N'HeadingResourceKeyConstants', N'SystemEventsLogProcessIDHeading', N'InterfaceEditorResourceSetEnum.SystemEventsLog + "4246"')

--        //SAUC61 - Security Event Log
,(N'HeadingResourceKeyConstants', N'SecurityEventsLogSecurityEventLogHeading', N'InterfaceEditorResourceSetEnum.SecurityEventsLog + "4491"')		
,(N'HeadingResourceKeyConstants', N'SecurityEventsLogDateHeading', N'InterfaceEditorResourceSetEnum.SecurityEventsLog + "4235"')
,(N'HeadingResourceKeyConstants', N'SecurityEventsLogDescriptionHeading', N'InterfaceEditorResourceSetEnum.SecurityEventsLog + "4236"')
,(N'HeadingResourceKeyConstants', N'SecurityEventsLogUserHeading', N'InterfaceEditorResourceSetEnum.SecurityEventsLog + "4237"')
,(N'HeadingResourceKeyConstants', N'SecurityEventsLogActionDateHeading', N'InterfaceEditorResourceSetEnum.SecurityEventsLog + "4241"')
,(N'HeadingResourceKeyConstants', N'SecurityEventsLogActionHeading', N'InterfaceEditorResourceSetEnum.SecurityEventsLog + "4242"')
,(N'HeadingResourceKeyConstants', N'SecurityEventsLogResultHeading', N'InterfaceEditorResourceSetEnum.SecurityEventsLog + "4243"')
,(N'HeadingResourceKeyConstants', N'SecurityEventsLogObjectIDHeading', N'InterfaceEditorResourceSetEnum.SecurityEventsLog + "4244"')
,(N'HeadingResourceKeyConstants', N'SecurityEventsLogErrorTextHeading', N'InterfaceEditorResourceSetEnum.SecurityEventsLog + "4245"')
,(N'HeadingResourceKeyConstants', N'SecurityEventsLogProcessIDHeading', N'InterfaceEditorResourceSetEnum.SecurityEventsLog + "4246"')
,(N'HeadingResourceKeyConstants', N'SecurityEventsLogProcessTypeHeading', N'InterfaceEditorResourceSetEnum.SecurityEventsLog + "4247"')

--region Reference Editor Sub-Module Resources

,(N'HeadingResourceKeyConstants', N'ActorsHeading', N'InterfaceEditorResourceSetEnum.DiseasesReferenceEditor + "339"')
,(N'HeadingResourceKeyConstants', N'AdditionalHeading', N'InterfaceEditorResourceSetEnum.SystemPreferences + "17"')
,(N'HeadingResourceKeyConstants', N'AgeGroupDetailsModalHeading', N'InterfaceEditorResourceSetEnum.AddAgeGroupModal + "119"')
,(N'HeadingResourceKeyConstants', N'AgeGroupsReferenceEditorPageHeading', N'InterfaceEditorResourceSetEnum.AgeGroupsReferenceEditor + "161"')
,(N'HeadingResourceKeyConstants', N'AnimalAgeDetailsModalHeading', N'InterfaceEditorResourceSetEnum.SpeciesAnimalAgeMatrix + "332"')
,(N'HeadingResourceKeyConstants', N'BaseReferenceDetailsModalHeading', N'InterfaceEditorResourceSetEnum.AddBaseReferenceModal + "120"')
,(N'HeadingResourceKeyConstants', N'BaseReferenceEditorPageHeading', N'InterfaceEditorResourceSetEnum.BaseReferenceEditor + "162"')
,(N'HeadingResourceKeyConstants', N'CaseClassificationDetailsModalHeading', N'InterfaceEditorResourceSetEnum.AddCaseClassificationModal + "121"')
,(N'HeadingResourceKeyConstants', N'CaseClassificationsReferenceEditorPageHeading', N'InterfaceEditorResourceSetEnum.CaseClassificationsReferenceEditor + "163"')
,(N'HeadingResourceKeyConstants', N'DataAccessDetailsModalHeading', N'InterfaceEditorResourceSetEnum.DiseasesReferenceEditor + "338"')
,(N'HeadingResourceKeyConstants', N'DiseaseDetailsModalHeading', N'InterfaceEditorResourceSetEnum.AddDiseaseModal + "122"')
,(N'HeadingResourceKeyConstants', N'DiseasesReferenceEditorPageHeading', N'InterfaceEditorResourceSetEnum.DiseasesReferenceEditor + "170"')
,(N'HeadingResourceKeyConstants', N'GenericStatisticalTypeDetailsModalHeading', N'InterfaceEditorResourceSetEnum.AddGenericStatisticalTypeModal + "124"')
,(N'HeadingResourceKeyConstants', N'GenericStatisticalTypesReferenceEditorPageHeading', N'InterfaceEditorResourceSetEnum.GenericStatisticalTypes + "173"')
,(N'HeadingResourceKeyConstants', N'MeasureDetailsModalHeading', N'InterfaceEditorResourceSetEnum.AddMeasureTypeModal + "125"')
,(N'HeadingResourceKeyConstants', N'MeasuresReferenceEditorPageHeading', N'InterfaceEditorResourceSetEnum.MeasuresReferenceEditor + "175"')
,(N'HeadingResourceKeyConstants', N'PermissionsHeading', N'InterfaceEditorResourceSetEnum.DataAccessDetailsModal + "944"')
,(N'HeadingResourceKeyConstants', N'ReportDiseaseGroupDetailsModalHeading', N'InterfaceEditorResourceSetEnum.AddReportDiseaseGroupModal + "128"')
,(N'HeadingResourceKeyConstants', N'ReportDiseaseGroupsReferenceEditorPageHeading', N'InterfaceEditorResourceSetEnum.ReportDiseaseGroupsReferenceEditor + "180"')
,(N'HeadingResourceKeyConstants', N'RequiredHeading', N'InterfaceEditorResourceSetEnum.SystemPreferences + "230"')
,(N'HeadingResourceKeyConstants', N'SampleTypeDetailsModalHeading', N'InterfaceEditorResourceSetEnum.AddSampleTypeModal + "129"')
,(N'HeadingResourceKeyConstants', N'SampleTypesReferenceEditorPageHeading', N'InterfaceEditorResourceSetEnum.SampleTypesReferenceEditor + "182"')
,(N'HeadingResourceKeyConstants', N'SearchActorsModalHeading', N'InterfaceEditorResourceSetEnum.SearchActorsModal + "511"')
,(N'HeadingResourceKeyConstants', N'SiteGroupTypeDetailsModalHeading', N'InterfaceEditorResourceSetEnum.AddSiteGroupTypeModal + "1006"')
,(N'HeadingResourceKeyConstants', N'SiteTypeDetailsModalHeading', N'InterfaceEditorResourceSetEnum.AddSiteTypeModal + "1001"')
,(N'HeadingResourceKeyConstants', N'SpeciesTypeDetailsModalHeading', N'InterfaceEditorResourceSetEnum.AddSpeciesTypeModal + "130"')
,(N'HeadingResourceKeyConstants', N'SpeciesTypesReferenceEditorPageHeading', N'InterfaceEditorResourceSetEnum.SpeciesTypesReferenceEditor + "183"')
,(N'HeadingResourceKeyConstants', N'UsersAndGroupsListModalHeading', N'InterfaceEditorResourceSetEnum.SearchActorsModal + "510"')
,(N'HeadingResourceKeyConstants', N'VectorSpeciesTypeDetailsModalHeading', N'InterfaceEditorResourceSetEnum.AddVectorSpeciesTypeModal + "132"')
,(N'HeadingResourceKeyConstants', N'VectorSpeciesTypesReferenceEditorPageHeading', N'InterfaceEditorResourceSetEnum.VectorSpeciesTypesReferenceEditor + "187"')
,(N'HeadingResourceKeyConstants', N'VectorTypesReferenceEditorPageHeading', N'InterfaceEditorResourceSetEnum.VectorTypesReferenceEditor + "191"')
,(N'HeadingResourceKeyConstants', N'VectorTypeDetailsModalHeading', N'InterfaceEditorResourceSetEnum.AddVectorTypeModal + "136"')
,(N'HeadingResourceKeyConstants', N'AddSampleTypeModal_SampleTypeDerivativeTypeDetails_Heading', N' InterfaceEditorResourceSetEnum.AddSampleTypeModal + "743"')

--        //SAUC64 - Settlement Type Reference Editor
,(N'HeadingResourceKeyConstants', N'SettlementTypeReferenceEditorSettlementTypeEditorHeading', N'InterfaceEditorResourceSetEnum.SettlementTypeReferenceEditor + "3023"')		
,(N'HeadingResourceKeyConstants', N'SettlementTypeReferenceEditorSettlementTypeDetailsHeading', N'InterfaceEditorResourceSetEnum.SettlementTypeReferenceEditor + "3024"')		



--region Security Sub-Module Resources

,(N'HeadingResourceKeyConstants', N'AccessRulesSearchPageHeading', N'InterfaceEditorResourceSetEnum.SearchAccessRules + "164"')
,(N'HeadingResourceKeyConstants', N'AccessRuleDetailsPageHeading', N'InterfaceEditorResourceSetEnum.AccessRuleDetails + "164"')
,(N'HeadingResourceKeyConstants', N'GrantingActorHeading', N'InterfaceEditorResourceSetEnum.AccessRuleDetails + "88"')
,(N'HeadingResourceKeyConstants', N'ReceivingActorsHeading', N'InterfaceEditorResourceSetEnum.AccessRuleDetails + "213"')

--        //SAUC25 - Search for a User Group
,(N'HeadingResourceKeyConstants', N'SearchUserGroupsPageHeading', N'InterfaceEditorResourceSetEnum.SearchUserGroups + "606"')

--        //SAUC
,(N'HeadingResourceKeyConstants', N'DashboardUsersHeading', N'InterfaceEditorResourceSetEnum.Dashboard + "4780"')
,(N'HeadingResourceKeyConstants', N'DashboardUNACCESSIONEDSAMPLESHeading', N'InterfaceEditorResourceSetEnum.Dashboard + "4781"')
,(N'HeadingResourceKeyConstants', N'DashboardINVESTIGATIONSHeading', N'InterfaceEditorResourceSetEnum.Dashboard + "4782"')
,(N'HeadingResourceKeyConstants', N'DashboardMYINVESTIGATIONSHeading', N'InterfaceEditorResourceSetEnum.Dashboard + "4783"')
,(N'HeadingResourceKeyConstants', N'DashboardNOTIFICATIONSHeading', N'InterfaceEditorResourceSetEnum.Dashboard + "4784"')
,(N'HeadingResourceKeyConstants', N'DashboardMYNOTIFICATIONSHeading', N'InterfaceEditorResourceSetEnum.Dashboard + "4785"')
,(N'HeadingResourceKeyConstants', N'DashboardMYCOLLECTIONSHeading', N'InterfaceEditorResourceSetEnum.Dashboard + "4786"')

--        //SAUC26 and 27 - Enter and Edit a User Group
,(N'HeadingResourceKeyConstants', N'UserGroupDetailsPageHeading', N'InterfaceEditorResourceSetEnum.UserGroupDetails + "611"')
,(N'HeadingResourceKeyConstants', N'UserGroupDetailsDashboardGridsHeading', N'InterfaceEditorResourceSetEnum.UserGroupDetails + "623"')
,(N'HeadingResourceKeyConstants', N'UserGroupDetailsDashboardIconsHeading', N'InterfaceEditorResourceSetEnum.UserGroupDetails + "622"')
,(N'HeadingResourceKeyConstants', N'UserGroupDetailsInformationHeading', N'InterfaceEditorResourceSetEnum.UserGroupDetails + "612"')
,(N'HeadingResourceKeyConstants', N'UserGroupDetailsSystemFunctionsHeading', N'InterfaceEditorResourceSetEnum.UserGroupDetails + "579"')
,(N'HeadingResourceKeyConstants', N'UserGroupDetailsUsersAndGroupsHeading', N'InterfaceEditorResourceSetEnum.UserGroupDetails + "613"')
,(N'HeadingResourceKeyConstants', N'UserGroupDetailsYoucanselectuptosixiconsHeading', N'InterfaceEditorResourceSetEnum.UserGroupDetails + "3920"')

--        //SAUC29 - Create an EIDSS Site
,(N'HeadingResourceKeyConstants', N'SiteDetailsActorsHeading', N'InterfaceEditorResourceSetEnum.SiteDetails + "339"')

--        //SAUC51 - Security Policy
,(N'HeadingResourceKeyConstants', N'SecurityPolicyPageHeading', N'InterfaceEditorResourceSetEnum.SecurityPolicy + "954"')
,(N'HeadingResourceKeyConstants', N'SecurityPolicyPasswordPolicyHeading', N'InterfaceEditorResourceSetEnum.SecurityPolicy + "962"')
,(N'HeadingResourceKeyConstants', N'SecurityPolicyLockoutPolicyHeading', N'InterfaceEditorResourceSetEnum.SecurityPolicy + "963"')

--        //SAUC53 - Sites and Site Groups Management
,(N'HeadingResourceKeyConstants', N'SearchSitesPageHeading', N'InterfaceEditorResourceSetEnum.Sites + "628"')
,(N'HeadingResourceKeyConstants', N'SiteDetailsPageHeading', N'InterfaceEditorResourceSetEnum.SiteDetails + "633"')
,(N'HeadingResourceKeyConstants', N'SiteDetailsSiteInformationHeading', N'InterfaceEditorResourceSetEnum.SiteDetails + "659"')
,(N'HeadingResourceKeyConstants', N'SiteDetailsPermissionsHeading', N'InterfaceEditorResourceSetEnum.SiteDetails + "944"')
,(N'HeadingResourceKeyConstants', N'SearchSiteGroupsPageHeading', N'InterfaceEditorResourceSetEnum.SiteGroups + "640"')
,(N'HeadingResourceKeyConstants', N'SiteGroupDetailsPageHeading', N'InterfaceEditorResourceSetEnum.SiteGroupDetails + "644"')
,(N'HeadingResourceKeyConstants', N'SiteGroupDetailsSiteGroupInfoHeading', N'InterfaceEditorResourceSetEnum.SiteGroupDetails + "645"')
,(N'HeadingResourceKeyConstants', N'SiteGroupDetailsSitesHeading', N'InterfaceEditorResourceSetEnum.SiteGroupDetails + "646"')
,(N'HeadingResourceKeyConstants', N'SearchOrganizationsSearchOrganizationsModalHeading', N'InterfaceEditorResourceSetEnum.SearchOrganizations + "745"')
,(N'HeadingResourceKeyConstants', N'AddOrganizationModalOrganizationDetailsModalHeading', N'InterfaceEditorResourceSetEnum.AddOrganizationModal + "746"')



--region Deduplication Sub-Module Resources

,(N'HeadingResourceKeyConstants', N'DeduplicationPersonPageHeading', N'InterfaceEditorResourceSetEnum.DeduplicationPerson + "2647"')
,(N'HeadingResourceKeyConstants', N'DeduplicationPersonPersonInformationSearchHeading', N'InterfaceEditorResourceSetEnum.DeduplicationPerson + "2648"')
,(N'HeadingResourceKeyConstants', N'DeduplicationPersonPersonInformationListHeading', N'InterfaceEditorResourceSetEnum.DeduplicationPerson + "2649"')

,(N'HeadingResourceKeyConstants', N'DeduplicationHumanReportPageHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanReport + "2645"')
,(N'HeadingResourceKeyConstants', N'DeduplicationHumanReportHumanDiseaseReportSearchHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanReport + "2659"')
,(N'HeadingResourceKeyConstants', N'DeduplicationHumanReportHumanDiseaseReportListHeading', N'InterfaceEditorResourceSetEnum.DeduplicationHumanReport + "2646"')

,(N'HeadingResourceKeyConstants', N'DeduplicationFarmPageHeading', N'InterfaceEditorResourceSetEnum.DeduplicationFarm + "2650"')
,(N'HeadingResourceKeyConstants', N'DeduplicationFarmFarmInformationSearchHeading', N'InterfaceEditorResourceSetEnum.DeduplicationFarm + "2651"')
,(N'HeadingResourceKeyConstants', N'DeduplicationFarmFarmInformationListHeading', N'InterfaceEditorResourceSetEnum.DeduplicationFarm + "2652"')

,(N'HeadingResourceKeyConstants', N'DeduplicationAvianReportPageHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianReport + "2653"')
,(N'HeadingResourceKeyConstants', N'DeduplicationAvianReportAvianDiseaseReportSearchHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianReport + "2654"')
,(N'HeadingResourceKeyConstants', N'DeduplicationAvianReportAvianDiseaseReportListHeading', N'InterfaceEditorResourceSetEnum.DeduplicationAvianReport + "2655"')

,(N'HeadingResourceKeyConstants', N'DeduplicationLivestockReportLivestockDiseaseReportDeduplicationHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockReport + "2656"')
,(N'HeadingResourceKeyConstants', N'DeduplicationLivestockReportLivestockDiseaseReportSearchHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockReport + "2657"')
,(N'HeadingResourceKeyConstants', N'DeduplicationLivestockReportLivestockDiseaseReportListHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockReport + "2658"')

--        //DDUC03
,(N'HeadingResourceKeyConstants', N'DeduplicationPersonPersonDeduplicationHeading', N'InterfaceEditorResourceSetEnum.DeduplicationPerson + "3188"')
,(N'HeadingResourceKeyConstants', N'DeduplicationPersonPersonListHeading', N'InterfaceEditorResourceSetEnum.DeduplicationPerson + "3189"')
,(N'HeadingResourceKeyConstants', N'DeduplicationPersonPersonDeduplicationDetailsHeading', N'InterfaceEditorResourceSetEnum.DeduplicationPerson + "3190"')
        
--        //DDUC04
,(N'HeadingResourceKeyConstants', N'FarmRecordDeduplicationFarmDeduplicationDetailsHeading', N'InterfaceEditorResourceSetEnum.FarmRecordDeduplication + "3470"')

--        //DDUC05
,(N'HeadingResourceKeyConstants', N'DeduplicationLivestockReportLivestockDiseaseReportDeduplicationDetailsHeading', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockReport + "3589"')

--        //DDUC06
,(N'HeadingResourceKeyConstants', N'AvianDiseaseReportDeduplicationAvianDiseaseReportDeduplicationDetailsHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportDeduplication + "3590"')
        




--region Configuration Module Resources

,(N'HeadingResourceKeyConstants', N'AgeGroupStatisticalAgeGroupDetailsModalHeading', N'InterfaceEditorResourceSetEnum.AgeGroupStatisticalAgeGroupMatrix + "118"')
,(N'HeadingResourceKeyConstants', N'AgeGroupStatisticalAgeGroupMatrixPageHeading', N'InterfaceEditorResourceSetEnum.AgeGroupStatisticalAgeGroupMatrix + "160"')
,(N'HeadingResourceKeyConstants', N'AggregateSettingsPageHeading', N'InterfaceEditorResourceSetEnum.AggregateSettings + "506"')
,(N'HeadingResourceKeyConstants', N'CustomReportRowsPageHeading', N'InterfaceEditorResourceSetEnum.CustomReportRows + "947"')
,(N'HeadingResourceKeyConstants', N'DeterminantsHeading', N'InterfaceEditorResourceSetEnum.Template + "340"')
,(N'HeadingResourceKeyConstants', N'DeterminantEditorHeading', N'InterfaceEditorResourceSetEnum.DeterminantEditor + "68"')
,(N'HeadingResourceKeyConstants', N'DiseaseAgeGroupMatrixPageHeading', N'InterfaceEditorResourceSetEnum.DiseaseAgeGroupMatrix + "167"')
,(N'HeadingResourceKeyConstants', N'DiseaseGroupDiseaseDetailsModalHeading', N'InterfaceEditorResourceSetEnum.DiseaseGroupDiseaseMatrix + "123"')
,(N'HeadingResourceKeyConstants', N'DiseaseGroupDiseaseMatrixPageHeading', N'InterfaceEditorResourceSetEnum.DiseaseGroupDiseaseMatrix + "166"')
,(N'HeadingResourceKeyConstants', N'DiseaseSampleTypeMatrixPageHeading', N'InterfaceEditorResourceSetEnum.DiseaseSampleTypeMatrix + "171"')
,(N'HeadingResourceKeyConstants', N'DiseaseLabTestMatrixPageHeading', N'InterfaceEditorResourceSetEnum.DiseaseLabTestMatrix + "168"')
,(N'HeadingResourceKeyConstants', N'DiseasePensideTestMatrixPageHeading', N'InterfaceEditorResourceSetEnum.DiseasePensideTestMatrix + "169"')
,(N'HeadingResourceKeyConstants', N'HumanAggregateDiseaseReportMatrixPageHeading', N'InterfaceEditorResourceSetEnum.HumanAggregateCaseMatrix + "174"')
,(N'HeadingResourceKeyConstants', N'MatrixVersionHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "114"')
,(N'HeadingResourceKeyConstants', N'MatrixDetailsHeading', N'InterfaceEditorResourceSetEnum.CommonHeadings + "4464"')		
,(N'HeadingResourceKeyConstants', N'ParameterDetailsHeading', N'InterfaceEditorResourceSetEnum.ParameterDetails + "198"')
,(N'HeadingResourceKeyConstants', N'ParameterTypesEditorParametersHeading', N'InterfaceEditorResourceSetEnum.ParameterTypesEditor + "199"')
,(N'HeadingResourceKeyConstants', N'ParameterTypeEditorPageHeading', N'InterfaceEditorResourceSetEnum.ParameterTypesEditor + "177"')
,(N'HeadingResourceKeyConstants', N'PersonalIdentificationTypeMatrixPageHeading', N'InterfaceEditorResourceSetEnum.PersonalIdentificationTypeMatrix + "178"')
,(N'HeadingResourceKeyConstants', N'PersonalIdentificationTypesDetailsModalHeading', N'InterfaceEditorResourceSetEnum.PersonalIdentificationTypeMatrix + "126"')
,(N'HeadingResourceKeyConstants', N'ReportDiseaseGroupDiseaseDetailsModalHeading', N'InterfaceEditorResourceSetEnum.ReportDiagnosisGroupDiagnosisMatrix + "128"')
,(N'HeadingResourceKeyConstants', N'ReportDiseaseGroupDiseaseMatrixPageHeading', N'InterfaceEditorResourceSetEnum.ReportDiagnosisGroupDiagnosisMatrix + "179"')
,(N'HeadingResourceKeyConstants', N'SampleTypeDerivativeTypeMatrixPageHeading', N'InterfaceEditorResourceSetEnum.SampleTypeDerivativeTypeMatrix + "181"')
,(N'HeadingResourceKeyConstants', N'SearchParametersHeading', N'InterfaceEditorResourceSetEnum.ParameterEditor + "243"')
,(N'HeadingResourceKeyConstants', N'SpeciesAnimalAgeDetailsModalHeading', N'InterfaceEditorResourceSetEnum.SpeciesAnimalAgeMatrix + "333"')
,(N'HeadingResourceKeyConstants', N'SpeciesAnimalAgeMatrixPageHeading', N'InterfaceEditorResourceSetEnum.SpeciesAnimalAgeMatrix + "184"')
,(N'HeadingResourceKeyConstants', N'TemplateDetailsHeading', N'InterfaceEditorResourceSetEnum.TemplateEditor + "261"')
,(N'HeadingResourceKeyConstants', N'TemplateEditorHeading', N'InterfaceEditorResourceSetEnum.TemplateEditor + "262"')
,(N'HeadingResourceKeyConstants', N'TemplatesHeading', N'InterfaceEditorResourceSetEnum.ParameterTypesEditor + "263"')
,(N'HeadingResourceKeyConstants', N'TemplateTitleHeading', N'InterfaceEditorResourceSetEnum.TemplateEditor + "265"')
,(N'HeadingResourceKeyConstants', N'TemplatesWhichUseThisParameterHeading', N'InterfaceEditorResourceSetEnum.ParameterEditor + "264"')
,(N'HeadingResourceKeyConstants', N'TestTestResultDetailsModalHeading', N'InterfaceEditorResourceSetEnum.TestTestResultMatrix + "131"')
,(N'HeadingResourceKeyConstants', N'TestTestResultsMatrixPageHeading', N'InterfaceEditorResourceSetEnum.TestTestResultMatrix + "186"')
,(N'HeadingResourceKeyConstants', N'VectorTypeCollectionMethodDetailsModalHeading', N'InterfaceEditorResourceSetEnum.VectorTypeCollectionMethodMatrix + "133"')
,(N'HeadingResourceKeyConstants', N'VectorTypeCollectionMethodMatrixPageHeading', N'InterfaceEditorResourceSetEnum.VectorTypeCollectionMethodMatrix + "190"')
,(N'HeadingResourceKeyConstants', N'VectorTypeFieldTestDetailsModalHeading', N'InterfaceEditorResourceSetEnum.VectorTypeFieldTestMatrix + "134"')
,(N'HeadingResourceKeyConstants', N'VectorTypeFieldTestMatrixPageHeading', N'InterfaceEditorResourceSetEnum.VectorTypeFieldTestMatrix + "188"')
,(N'HeadingResourceKeyConstants', N'VectorTypeSampleTypeDetailsModalHeading', N'InterfaceEditorResourceSetEnum.VectorTypeSampleMatrix + "135"')
,(N'HeadingResourceKeyConstants', N'VectorTypeSampleTypeMatrixPageHeading', N'InterfaceEditorResourceSetEnum.VectorTypeSampleMatrix + "189"')
,(N'HeadingResourceKeyConstants', N'VeterinaryAggregateDiseaseReportMatrixPageHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateCaseMatrix + "192"')
,(N'HeadingResourceKeyConstants', N'VeterinaryDiagnosticInvestigationMatrixPageHeading', N'InterfaceEditorResourceSetEnum.VeterinaryDiagnosticInvestigationMatrix + "193"')
,(N'HeadingResourceKeyConstants', N'VeterinaryProphylacticMeasureMatrixPageHeading', N'InterfaceEditorResourceSetEnum.VeterinaryProphylacticMeasureMatrix + "194"')
,(N'HeadingResourceKeyConstants', N'VeterinarySanitaryActionMatrixPageHeading', N'InterfaceEditorResourceSetEnum.VeterinarySanitaryActionMatrix + "195"')

--        //fixing localization for AJ 11/14/2023
,(N'HeadingResourceKeyConstants', N'VeterinaryAggregateCaseHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateCaseMatrix + "4851"')

--        //SCUC11 - Configure Test – Test Results Matrix
,(N'HeadingResourceKeyConstants', N'AddTestNameModalTestNameDetailsModalHeading', N'InterfaceEditorResourceSetEnum.AddTestNameModal + "952"')
,(N'HeadingResourceKeyConstants', N'AddTestResultModalTestResultDetailsModalHeading', N'InterfaceEditorResourceSetEnum.AddTestResultModal + "953"')

--        //SCUC12 - Configure Vector Type - Collection Method Matrix
,(N'HeadingResourceKeyConstants', N'VectorTypeCollectionMethodMatrixCollectionMethodDetailsModalHeading', N'InterfaceEditorResourceSetEnum.VectorTypeCollectionMethodMatrix + "956"')

--        //SCUC14 - Configure Vector Type - Field Test Matrix
,(N'HeadingResourceKeyConstants', N'VectorTypeFieldTestMatrixPensideTestNameDetailsModalHeading', N'InterfaceEditorResourceSetEnum.VectorTypeFieldTestMatrix + "957"')

--        //SCUC14 - Configure Custom Report Rows
,(N'HeadingResourceKeyConstants', N'CustomReportRowsCustomReportRowDetailsHeading', N'InterfaceEditorResourceSetEnum.CustomReportRows + "4232"')

--        //SCUC22 - Configure Unique Numbering Schema
,(N'HeadingResourceKeyConstants', N'UniqueNumberingSchemaPageHeading', N'InterfaceEditorResourceSetEnum.UniqueNumberingSchema + "786"')

--        //SCUC25 - Configure Data Archiving Settings
,(N'HeadingResourceKeyConstants', N'DataArchivingSettingsPageHeading', N'InterfaceEditorResourceSetEnum.DataArchivingSettings + "2671"')

--        //SCUC31 - Configure Disease-Human Gender Matrix
,(N'HeadingResourceKeyConstants', N'DiseaseHumanGenderMatrixPageHeading', N'InterfaceEditorResourceSetEnum.DiseaseHumanGenderMatrix + "165"')

--        //Flex Form
,(N'HeadingResourceKeyConstants', N'FlexibleFormDesigner_FlexibleFormDesigner_Heading', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "741"')
,(N'HeadingResourceKeyConstants', N'FlexibleFormDesigner_SectionDetails_Heading', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "742"')
,(N'HeadingResourceKeyConstants', N'FlexibleFormDesignerFlexibleFormsDesignerHeading', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "172"')



--region Human Module Resources

--        //Human Module
,(N'HeadingResourceKeyConstants', N'HumanAberrationAnalysisReportPageHeading', N'InterfaceEditorResourceSetEnum.HumanAberrationAnalysisReport + "330"')
,(N'HeadingResourceKeyConstants', N'HumanILIAberrationAnalysisReportPageHeading', N'InterfaceEditorResourceSetEnum.ILIAberrationAnalysisReport + "331"')

--        //HASUC01 - Enter Human Active Surveillance Campaign
,(N'HeadingResourceKeyConstants', N'HumanActiveSurveillanceCampaignHumanActiveSurveillanceCampaignHeading', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "1816"')
,(N'HeadingResourceKeyConstants', N'HumanActiveSurveillanceCampaignCampaignInformationHeading', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "1817"')

--        //HASUC03 - Enter Human Active Surveillance Session and HASUC04 - Edit Human Active Surveillance Session
,(N'HeadingResourceKeyConstants', N'HumanActiveSurveillanceSessionPageHeading', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "862"')
,(N'HeadingResourceKeyConstants', N'HumanSessionDetailedInformationHeading', N'InterfaceEditorResourceSetEnum.HumanSessionDetailedInformation + "887"')
,(N'HeadingResourceKeyConstants', N'HumanSessionDetailedInformationPersonsAndSamplesHeading', N'InterfaceEditorResourceSetEnum.HumanSessionDetailedInformation + "888"')
,(N'HeadingResourceKeyConstants', N'HumanSessionSampleDetailsModalHeading', N'InterfaceEditorResourceSetEnum.HumanSessionSampleDetailsModal + "751"')
,(N'HeadingResourceKeyConstants', N'HumanSessionTestsHeading', N'InterfaceEditorResourceSetEnum.HumanSessionTests + "889"')
,(N'HeadingResourceKeyConstants', N'HumanSessionActionsHeading', N'InterfaceEditorResourceSetEnum.HumanSessionActions + "891"')
,(N'HeadingResourceKeyConstants', N'HumanSessionDiseaseReportsHeading', N'InterfaceEditorResourceSetEnum.HumanSessionDiseaseReports + "893"')
,(N'HeadingResourceKeyConstants', N'HumanActiveSurveillanceSessionReviewHeading', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "234"')
,(N'HeadingResourceKeyConstants', N'HumanActiveSurveillanceSessionSessionInformationHeading', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "863"')
,(N'HeadingResourceKeyConstants', N'HumanActiveSurveillanceSessionDetailedInformationHeading', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "887"')
,(N'HeadingResourceKeyConstants', N'HumanActiveSurveillanceSessionTestsHeading', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "889"')
,(N'HeadingResourceKeyConstants', N'HumanActiveSurveillanceSessionActionsHeading', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "891"')
,(N'HeadingResourceKeyConstants', N'HumanActiveSurveillanceSessionDiseaseReportsHeading', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "893"')
,(N'HeadingResourceKeyConstants', N'HumanACtiveSurveillanceSessionInformationActionsHeading', N'InterfaceEditorResourceSetEnum.SessionInformation + "891"')

--        //HAUC01 and HAUC02 - Enter and Edit Human Aggregate Disease Report and HAUC03 - Search for Human Aggregate Diseases Report
,(N'HeadingResourceKeyConstants', N'HumanAggregateDiseaseReportPageHeading', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "929"')
,(N'HeadingResourceKeyConstants', N'HumanAggregateDiseaseReportReportDetailsHeading', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "930"')
,(N'HeadingResourceKeyConstants', N'HumanAggregateDiseaseReportNotificationReceivedByHeading', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "931"')
,(N'HeadingResourceKeyConstants', N'HumanAggregateDiseaseReportGeneralInfoHeading', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "932"')
,(N'HeadingResourceKeyConstants', N'HumanAggregateDiseaseReportNotificationSentByHeading', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "757"')
,(N'HeadingResourceKeyConstants', N'HumanAggregateDiseaseReportEnteredByHeading', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "758"')
,(N'HeadingResourceKeyConstants', N'HumanAggregateDiseaseReportDiseaseMatrixHeading', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "759"')
,(N'HeadingResourceKeyConstants', N'HumanAggregateDiseaseReportReviewHeading', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "234"')

--        //HAUC06 - Enter ILI Aggregate Form, HAUC07 - Edit ILI Aggregate Form and HAUC08 - Search for ILI Aggregate Form
,(N'HeadingResourceKeyConstants', N'ILIAggregatePageHeading', N'InterfaceEditorResourceSetEnum.ILIAggregate + "2697"')
,(N'HeadingResourceKeyConstants', N'ILIAggregateDetailsILIAggregateDetailsHeading', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "2698"')

--        //HUC01 - Search Person Use Case
,(N'HeadingResourceKeyConstants', N'PersonPageHeading', N'InterfaceEditorResourceSetEnum.Person + "597"')
--        //TODO:  Remove the resource below - not needed - replace with resource above.  Code will need updating in Human/Person/Index view.
,(N'HeadingResourceKeyConstants', N'SearchPersonPersonSearchPageHeading', N'InterfaceEditorResourceSetEnum.SearchPerson + "597"')
,(N'HeadingResourceKeyConstants', N'SearchPersonDateOfBirthHeading', N'InterfaceEditorResourceSetEnum.SearchPerson + "2717"')
        
,(N'HeadingResourceKeyConstants', N'SearchPersonModalDateOfBirthHeading', N'InterfaceEditorResourceSetEnum.SearchPersonModal + "2717"')

--        //HUC02 - Enter a Person Record and HUC04 - Edit a Person Record
,(N'HeadingResourceKeyConstants', N'PersonReviewHeading', N'InterfaceEditorResourceSetEnum.Person + "234"')
,(N'HeadingResourceKeyConstants', N'PersonInformationHeading', N'InterfaceEditorResourceSetEnum.PersonInformation + "612"')
,(N'HeadingResourceKeyConstants', N'PersonAddressHeading', N'InterfaceEditorResourceSetEnum.PersonAddress + "1050"')
,(N'HeadingResourceKeyConstants', N'PersonAddressCurrentAddressHeading', N'InterfaceEditorResourceSetEnum.PersonAddress + "1061"')
,(N'HeadingResourceKeyConstants', N'PersonAddressAlternateAddressHeading', N'InterfaceEditorResourceSetEnum.PersonAddress + "1102"')
,(N'HeadingResourceKeyConstants', N'PersonEmploymentSchoolInformationHeading', N' InterfaceEditorResourceSetEnum.PersonEmploymentSchoolInformation + "1114"')
,(N'HeadingResourceKeyConstants', N'PersonEmploymentSchoolInformationWorkAddressHeading', N'InterfaceEditorResourceSetEnum.PersonEmploymentSchoolInformation + "1116"')
,(N'HeadingResourceKeyConstants', N'PersonEmploymentSchoolInformationSchoolAddressHeading', N'InterfaceEditorResourceSetEnum.PersonEmploymentSchoolInformation + "1125"')

--        //fix for localization 10/30/2023
,(N'HeadingResourceKeyConstants', N'PermanentAddressAddressHeading', N'InterfaceEditorResourceSetEnum.PersonAddress + "4849"')

--        //fix of localization 10/20/2023
,(N'HeadingResourceKeyConstants', N'PersonAddressModalHeading', N'InterfaceEditorResourceSetEnum.PersonAddress + "4814"')
,(N'HeadingResourceKeyConstants', N'PersonPostalCodeModalHeading', N'InterfaceEditorResourceSetEnum.PersonAddress + "4815"')

--        //HUC03 - Enter a Human Disease Report and HUC05 - Edit a Human Disease Report
,(N'HeadingResourceKeyConstants', N'HumanDiseaseReportHumanDiseaseReportHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReport + "1044"')
,(N'HeadingResourceKeyConstants', N'HumanDiseaseReportDiseaseReportSummaryHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSummary + "1045"')
,(N'HeadingResourceKeyConstants', N'HumanDiseaseReportPersonInformationHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReport + "2680"')
,(N'HeadingResourceKeyConstants', N'HumanDiseaseReportNotificationHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportNotification + "1046"')
,(N'HeadingResourceKeyConstants', N'HumanDiseaseReportClinicalInformationSymptomsHeading', N' InterfaceEditorResourceSetEnum.HumanDiseaseReportSymptoms + "1047"')
,(N'HeadingResourceKeyConstants', N'HumanDiseaseReportClinicalInformationFacilityDetailsHeading', N' InterfaceEditorResourceSetEnum.HumanDiseaseReportFacilityDetails + "1048"')
,(N'HeadingResourceKeyConstants', N'HumanDiseaseReportAntibioticAntiviralHistoryHeading', N' InterfaceEditorResourceSetEnum.HumanDiseaseReportAntibioticVaccineHistory + "1049"')
,(N'HeadingResourceKeyConstants', N'HumanDiseaseReportClinicalInformationAntibioticHeading', N' InterfaceEditorResourceSetEnum.HumanDiseaseReportAntibioticVaccineHistory + "1051"')
,(N'HeadingResourceKeyConstants', N'HumanDiseaseReportAntibioticAntiviralTherapyHeading', N' InterfaceEditorResourceSetEnum.HumanDiseaseReportAntibioticVaccineHistory + "1052"')
,(N'HeadingResourceKeyConstants', N'HumanDiseaseReportClinicalInformationVaccinationHeading', N' InterfaceEditorResourceSetEnum.HumanDiseaseReportAntibioticVaccineHistory + "1053"')
,(N'HeadingResourceKeyConstants', N'HumanDiseaseReportSamplesDetailHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSampleDetailsModal + "1054"')
,(N'HeadingResourceKeyConstants', N'HumanDiseaseReportTestsDetailHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTestDetailsModal + "1055"')
,(N'HeadingResourceKeyConstants', N'HumanDiseaseReportExternalOrganizationHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTestDetailsModal + "1056"')
,(N'HeadingResourceKeyConstants', N'HumanDiseaseReportInterpretationHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTestDetailsModal + "1057"')
,(N'HeadingResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationDetailsHeading', N' InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1058"')
,(N'HeadingResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationRiskFactorsHeading', N' InterfaceEditorResourceSetEnum.HumanDiseaseReportRiskFactors + "1059"')
,(N'HeadingResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationContactsHeading', N' InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1060"')
,(N'HeadingResourceKeyConstants', N'HumanDiseaseReportContactsListHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1062"')
,(N'HeadingResourceKeyConstants', N'HumanDiseaseReportDemographicsHeading', N'InterfaceEditorResourceSetEnum.ContactInformationModal + "1063"')
,(N'HeadingResourceKeyConstants', N'HumanDiseaseReportContactDetailsHeading', N'InterfaceEditorResourceSetEnum.ContactInformationModal + "1064"')
,(N'HeadingResourceKeyConstants', N'HumanDiseaseReportFinalOutcomeHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportFinalOutcome + "1065"')
,(N'HeadingResourceKeyConstants', N'HumanDiseaseReportTestsHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTests + "889"')
,(N'HeadingResourceKeyConstants', N'HumanDiseaseReportSamplesHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSamples + "664"')
,(N'HeadingResourceKeyConstants', N'HumanDiseaseReportReviewHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReport + "234"')
,(N'HeadingResourceKeyConstants', N'HumanDiseaseReportRiskFactorsListofRiskFactorsHeading', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportRiskFactors + "4807"')

,(N'HeadingResourceKeyConstants', N'ContactInformationModalPhoneHeading', N'InterfaceEditorResourceSetEnum.ContactInformationModal + "3191"')

--        //HAUC05 - Enter Human Aggregate Disease Reports Summary
,(N'HeadingResourceKeyConstants', N'HumanAggregateDiseaseReportSummaryHumanAggregateDiseaseReportsSummaryHeading', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportSummary + "1872"')
,(N'HeadingResourceKeyConstants', N'HumanAggregateDiseaseReportSummaryDiseaseMatrixHeading', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportSummary + "759"')

--        //HAUC09 - Search for Weekly Reporting Form
,(N'HeadingResourceKeyConstants', N'SearchWeeklyReportingFormsPageHeading', N'InterfaceEditorResourceSetEnum.SearchWeeklyReportingForms + "747"')

--        //HAUC10 and HAUC11 - Enter and Edit Weekly Reporting Form 
,(N'HeadingResourceKeyConstants', N'WeeklyReportingFormDetailsPageHeading', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "747"')
,(N'HeadingResourceKeyConstants', N'WeeklyReportingFormDetailsDetailsHeading', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "756"')
,(N'HeadingResourceKeyConstants', N'WeeklyReportingFormDetailsNotificationSentbyHeading', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "757"')
,(N'HeadingResourceKeyConstants', N'WeeklyReportingFormDetailsEnteredbyHeading', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "758"')
,(N'HeadingResourceKeyConstants', N'WeeklyReportingFormDetailsDiseaseMatrixHeading', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "759"')

--        //HAUC13 - Enter Weekly Reporting Form Summary
,(N'HeadingResourceKeyConstants', N'WeeklyReportingFormSummaryPageHeading', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormSummary + "773"')
,(N'HeadingResourceKeyConstants', N'WeeklyReportingFormSummaryNotifiableDiseaseAcuteFlaccidParalysisHeading', N' InterfaceEditorResourceSetEnum.WeeklyReportingFormSummary + "774"')
,(N'HeadingResourceKeyConstants', N'WeeklyReportingFormSummaryReportingPeriodHeading', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormSummary + "775"')



--region Laboratory Module Resources

--        //Laboratory Module
,(N'HeadingResourceKeyConstants', N'LaboratoryPageHeading', N'InterfaceEditorResourceSetEnum.Laboratory + "663"')
,(N'HeadingResourceKeyConstants', N'LaboratorySamplesHeading', N'InterfaceEditorResourceSetEnum.Laboratory + "664"')
,(N'HeadingResourceKeyConstants', N'LaboratoryTestingHeading', N'InterfaceEditorResourceSetEnum.Laboratory + "680"')
,(N'HeadingResourceKeyConstants', N'LaboratoryTransferredHeading', N'InterfaceEditorResourceSetEnum.Laboratory + "681"')
,(N'HeadingResourceKeyConstants', N'LaboratoryMyFavoritesHeading', N'InterfaceEditorResourceSetEnum.Laboratory + "684"')
,(N'HeadingResourceKeyConstants', N'LaboratoryBatchesHeading', N'InterfaceEditorResourceSetEnum.Laboratory + "682"')
,(N'HeadingResourceKeyConstants', N'LaboratoryApprovalsHeading', N'InterfaceEditorResourceSetEnum.Laboratory + "683"')

--        //LUC01 - Accession a Sample
,(N'HeadingResourceKeyConstants', N'LaboratoryGroupAccessionInModalHeading', N'InterfaceEditorResourceSetEnum.Laboratory + "19"')
,(N'HeadingResourceKeyConstants', N'GroupAccessionInModalSelectSamplesHeading', N'InterfaceEditorResourceSetEnum.GroupAccessionInModal + "4494"')		

--        //LUC02 - Create an Aliquot/Derivative
,(N'HeadingResourceKeyConstants', N'LaboratoryAliquotsDerivativesModalHeading', N' InterfaceEditorResourceSetEnum.Laboratory + "537"')

--        //LUC03 - Transfer a Sample
,(N'HeadingResourceKeyConstants', N'LaboratoryTransferSampleModalHeading', N'InterfaceEditorResourceSetEnum.Laboratory + "592"')

--        //LUC04 - Assign a Test
,(N'HeadingResourceKeyConstants', N'LaboratoryAssignTestModalHeading', N'InterfaceEditorResourceSetEnum.Laboratory + "617"')

--        //LUC06 - Edit a Transfer
,(N'HeadingResourceKeyConstants', N'LaboratoryTransferDetailsHeading', N'InterfaceEditorResourceSetEnum.Laboratory + "810"')

--        //LUC07 - Amend Test Result
,(N'HeadingResourceKeyConstants', N'LaboratoryAmendTestResultModalHeading', N'InterfaceEditorResourceSetEnum.Laboratory + "625"')

--        //LUC08 - Create a Batch
,(N'HeadingResourceKeyConstants', N'LaboratoryCreateBatchModalHeading', N'InterfaceEditorResourceSetEnum.Laboratory + "718"')

--        //LUC09 - Edit a Batch
,(N'HeadingResourceKeyConstants', N'LaboratoryBatchResultsDetailsModalHeading', N' InterfaceEditorResourceSetEnum.Laboratory + "724"')
,(N'HeadingResourceKeyConstants', N'BatchResultsDetailsModalQualityControlsHeading', N'InterfaceEditorResourceSetEnum.BatchResultsDetailsModal + "2557"')

--        //LUC10 - Enter a Sample
,(N'HeadingResourceKeyConstants', N'RegisterNewSampleModalHeading', N'InterfaceEditorResourceSetEnum.Laboratory + "18"')
,(N'HeadingResourceKeyConstants', N'RegisterNewSampleModalSearchPersonHeading', N'InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "2926"')
,(N'HeadingResourceKeyConstants', N'RegisterNewSampleModalPersonHeading', N'InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "597"')
,(N'HeadingResourceKeyConstants', N'RegisterNewSampleModalFarmHeading', N'InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "2401"')
,(N'HeadingResourceKeyConstants', N'RegisterNewSampleModalSearchFarmHeading', N'InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "3123"')
,(N'HeadingResourceKeyConstants', N'RegisterNewSampleModalHumanActiveSurveillanceSessionHeading', N'InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "862"')
,(N'HeadingResourceKeyConstants', N'RegisterNewSampleModalHumanDiseaseReportHeading', N'InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "1044"')
,(N'HeadingResourceKeyConstants', N'RegisterNewSampleModalOutbreakCaseHeading', N'InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "2791"')
,(N'HeadingResourceKeyConstants', N'RegisterNewSampleModalVectorSurveillanceSessionHeading', N'InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "2579"')
,(N'HeadingResourceKeyConstants', N'RegisterNewSampleModalVeterinaryActiveSurveillanceSessionHeading', N'InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "2451"')
,(N'HeadingResourceKeyConstants', N'RegisterNewSampleModalVeterinaryDiseaseReportHeading', N'InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "2792"')

--        //LUC11 - Edit a Sample
,(N'HeadingResourceKeyConstants', N'LaboratorySampleTestDetailsModalHeading', N' InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "665"')
,(N'HeadingResourceKeyConstants', N'LaboratorySampleTestDetailsModalSampleDetailsHeading', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "751"')

--        //LUC12 - Edit a Test
,(N'HeadingResourceKeyConstants', N'LaboratorySampleTestDetailsModalTestDetailsHeading', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "890"')
,(N'HeadingResourceKeyConstants', N'LaboratorySampleTestDetailsModalAdditionalTestDetailsHeading', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "801"')
,(N'HeadingResourceKeyConstants', N'LaboratorySampleTestDetailsModalAmendmentHistoryHeading', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "807"')
,(N'HeadingResourceKeyConstants', N'LaboratorySampleTestDetailsModalQualityControlValuesHeading', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "987"')

--        //LUC13 - Search for a Sample
,(N'HeadingResourceKeyConstants', N'LaboratoryAdvancedSearchModalHeading', N'InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "21"')
,(N'HeadingResourceKeyConstants', N'LaboratoryAdvancedSearchDateRangeHeading', N'InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "685"')
,(N'HeadingResourceKeyConstants', N'LaboratoryAdvancedSearchTestResultDateRangeHeading', N'InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "686"')
,(N'HeadingResourceKeyConstants', N'BatchesAddSampleToBatchHeading', N'InterfaceEditorResourceSetEnum.Batches + "4388"')		

--        //LUC15 - Lab Record Deletion
,(N'HeadingResourceKeyConstants', N'LaboratorySampleDeletionHeading', N'InterfaceEditorResourceSetEnum.Laboratory + "812"')

--        //LUC18 - Laboratory Menu
,(N'HeadingResourceKeyConstants', N'LaboratorySampleDestructionHeading', N'InterfaceEditorResourceSetEnum.Laboratory + "1040"')
,(N'HeadingResourceKeyConstants', N'LaboratoryLabRecordDeletionHeading', N'InterfaceEditorResourceSetEnum.Laboratory + "1041"')
,(N'HeadingResourceKeyConstants', N'LaboratoryPaperFormsHeading', N'InterfaceEditorResourceSetEnum.Laboratory + "1042"')

--        //LUC19 - Print Barcodes
,(N'HeadingResourceKeyConstants', N'LaboratoryBarcodeLabelsHeading', N'InterfaceEditorResourceSetEnum.Laboratory + "813"')

--        //LUC20 - Configure Sample Storage Schema and LUC23 - Edit Sample Storage Schema
,(N'HeadingResourceKeyConstants', N'FreezerDetailsSampleStorageSchemaHeading', N'InterfaceEditorResourceSetEnum.FreezerDetails + "814"')
,(N'HeadingResourceKeyConstants', N'FreezerDetailsFreezerAttributesHeading', N'InterfaceEditorResourceSetEnum.FreezerDetails + "815"')
,(N'HeadingResourceKeyConstants', N'FreezerDetailsSubdivisionAttributesHeading', N'InterfaceEditorResourceSetEnum.FreezerDetails + "816"')

--        //LUC22 - Search for a Freezer
,(N'HeadingResourceKeyConstants', N'FreezersPageHeading', N'InterfaceEditorResourceSetEnum.Freezers + "820"')
,(N'HeadingResourceKeyConstants', N'FreezersSearchFreezersModalHeading', N'InterfaceEditorResourceSetEnum.Freezers + "821"')

--        //LUC24, 25, 26, 27 - Printed Paper Forms
,(N'HeadingResourceKeyConstants', N'LaboratorySampleReportHeading', N'InterfaceEditorResourceSetEnum.Laboratory + "2872"')
,(N'HeadingResourceKeyConstants', N'LaboratoryAccessionInFormHeading', N'InterfaceEditorResourceSetEnum.Laboratory + "2873"')
,(N'HeadingResourceKeyConstants', N'LaboratoryTestResultReportHeading', N'InterfaceEditorResourceSetEnum.Laboratory + "2874"')
,(N'HeadingResourceKeyConstants', N'LaboratoryTransferReportHeading', N'InterfaceEditorResourceSetEnum.Laboratory + "2875"')
,(N'HeadingResourceKeyConstants', N'LaboratoryDestructionReportHeading', N'InterfaceEditorResourceSetEnum.Laboratory + "2876"')



--region Reports Module Resources

,(N'HeadingResourceKeyConstants', N'AdditionalIndicatorsOfAFPSurveillancePageHeading', N'InterfaceEditorResourceSetEnum.Reports + "964"')
,(N'HeadingResourceKeyConstants', N'AdministrativeEventLogPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "283"')
,(N'HeadingResourceKeyConstants', N'AdministrativeReportAuditLogPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "284"')
,(N'HeadingResourceKeyConstants', N'AnalysisParametersHeading', N'InterfaceEditorResourceSetEnum.Reports + "285"')
,(N'HeadingResourceKeyConstants', N'AntibioticResistanceCardLMAPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "286"')
,(N'HeadingResourceKeyConstants', N'AntibioticResistanceCardNCDCPHPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "287"')
,(N'HeadingResourceKeyConstants', N'AssignmentForLaboratoryDiagnosticPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "288"')
,(N'HeadingResourceKeyConstants', N'VeterinaryReportFormVet1PageHeading', N'InterfaceEditorResourceSetEnum.Reports + "289"')
,(N'HeadingResourceKeyConstants', N'VeterinaryReportFormVet1APageHeading', N'InterfaceEditorResourceSetEnum.Reports + "290"')
,(N'HeadingResourceKeyConstants', N'BorderRayonsIncidenceComparativeReportPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "291"')
,(N'HeadingResourceKeyConstants', N'ComparativeReportOfInfectiousDiseasesConditionsByMonthsPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "292"')
,(N'HeadingResourceKeyConstants', N'ComparativeReportOfSeveralYearsByMonthsPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "293"')
,(N'HeadingResourceKeyConstants', N'ComparativeReportPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "294"')
,(N'HeadingResourceKeyConstants', N'ComparativeReportOfSeveralYearsByMonthPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "295"')
,(N'HeadingResourceKeyConstants', N'ConcordanceBetweenInitialAndFinalDiagnosisPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "296"')
,(N'HeadingResourceKeyConstants', N'DataQualityIndicatorsPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "297"')
,(N'HeadingResourceKeyConstants', N'DataQualityIndicatorsForRayonsPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "298"')
,(N'HeadingResourceKeyConstants', N'ExternalComparativeReportPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "299"')
,(N'HeadingResourceKeyConstants', N'HumanForm1A3PageHeading', N'InterfaceEditorResourceSetEnum.Reports + "300"')
,(N'HeadingResourceKeyConstants', N'HumanForm1A4PageHeading', N'InterfaceEditorResourceSetEnum.Reports + "301"')
,(N'HeadingResourceKeyConstants', N'HumanMonthlyMorbidityAndMortalityPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "302"')
,(N'HeadingResourceKeyConstants', N'HumanReportOnTuberculosisCasesTestedForHIVPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "303"')
,(N'HeadingResourceKeyConstants', N'HumanCasesByRayonAndDiseaseSummaryPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "304"')
,(N'HeadingResourceKeyConstants', N'IntermediaryReportByAnnualFormIV03PageHeading', N'InterfaceEditorResourceSetEnum.Reports + "305"')
,(N'HeadingResourceKeyConstants', N'IntermediaryReportByMonthlyFormIV031PageHeading', N'InterfaceEditorResourceSetEnum.Reports + "306"')
,(N'HeadingResourceKeyConstants', N'IntermediateReportByMonthlyFormIV03PageHeading', N'InterfaceEditorResourceSetEnum.Reports + "307"')
,(N'HeadingResourceKeyConstants', N'IntermediaryReportByMonthlyFormIV03Order0127NPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "308"')
,(N'HeadingResourceKeyConstants', N'IntermediaryReportByMonthlyFormIV03Order0182NPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "309"')
,(N'HeadingResourceKeyConstants', N'SixtyBJournalPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "310"')
,(N'HeadingResourceKeyConstants', N'LaboratoryTestingResultsPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "311"')
,(N'HeadingResourceKeyConstants', N'MainIndicatorsOfAFPSurveillancePageHeading', N'InterfaceEditorResourceSetEnum.Reports + "312"')
,(N'HeadingResourceKeyConstants', N'MicrobiologyResearchResultPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "313"')
,(N'HeadingResourceKeyConstants', N'ParametersHeading', N'InterfaceEditorResourceSetEnum.Reports + "199"')
,(N'HeadingResourceKeyConstants', N'RabiesBulletinEuropeQuarterlySurveillanceSheetPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "315"')
,(N'HeadingResourceKeyConstants', N'ReportOfActivitiesConductedInVeterinaryLaboratoriesPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "316"')
,(N'HeadingResourceKeyConstants', N'ReportOnCasesOfAnnuallyReportableInfectiousDiseasesAnnualFormIV03Order101NPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "317"')
,(N'HeadingResourceKeyConstants', N'ReportOnCasesOfInfectiousDiseasesMonthlyFormIV031Order101NPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "318"')
,(N'HeadingResourceKeyConstants', N'ReportOnCertainDiseasesConditionsMonthlyFormIV03PageHeading', N'InterfaceEditorResourceSetEnum.Reports + "319"')
,(N'HeadingResourceKeyConstants', N'ReportOnCertainDiseasesConditionsMonthlyFormIV03Order0127NPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "320"')
,(N'HeadingResourceKeyConstants', N'ReportOnCertainDiseasesConditionsMonthlyFormIV03Order0182NPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "321"')
,(N'HeadingResourceKeyConstants', N'SerologyResearchResultPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "322"')
,(N'HeadingResourceKeyConstants', N'SummaryVeterinaryReportPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "323"')
,(N'HeadingResourceKeyConstants', N'VeterinaryActiveSurveillancePageHeading', N'InterfaceEditorResourceSetEnum.Reports + "324"')
,(N'HeadingResourceKeyConstants', N'VeterinaryYearlySituationPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "325"')
,(N'HeadingResourceKeyConstants', N'VeterinaryCaseReportPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "326"')
,(N'HeadingResourceKeyConstants', N'VeterinaryDataQualityIndicatorsPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "327"')
,(N'HeadingResourceKeyConstants', N'WHOReportOnMeaslesAndRubellaPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "328"')
,(N'HeadingResourceKeyConstants', N'ZoonoticComparativeReportByMonthsPageHeading', N'InterfaceEditorResourceSetEnum.Reports + "1014"')
,(N'HeadingResourceKeyConstants', N'HumanReportsHumanCaseReportHeading', N'InterfaceEditorResourceSetEnum.HumanReports + "4750"')

--        //SRUC03 - Aberration Analysis - Vet
,(N'HeadingResourceKeyConstants', N'AvianLivestockAberrationAnalysisReportPageHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAberrationAnalysisReport + "329"')

--        //SYSUC12 - Print Barcodes
,(N'HeadingResourceKeyConstants', N'PrintBarcodesPageHeading', N'InterfaceEditorResourceSetEnum.PrintBarcodes + "2810"')



--region Outbreak Module Resources

--        //Outbreak Module
,(N'HeadingResourceKeyConstants', N'OutbreakCasesOutbreakPersonSearchHeading', N'InterfaceEditorResourceSetEnum.OutbreakCases + "3652"')
,(N'HeadingResourceKeyConstants', N'OutbreakCasesOutbreakFarmSearchHeading', N'InterfaceEditorResourceSetEnum.OutbreakCases + "3653"')
,(N'HeadingResourceKeyConstants', N'OutbreakCasesImportHumanDiseaseReportHeading', N'InterfaceEditorResourceSetEnum.OutbreakCases + "3654"')
,(N'HeadingResourceKeyConstants', N'OutbreakCasesImportVeterinaryDiseaseReportHeading', N'InterfaceEditorResourceSetEnum.OutbreakCases + "3655"')

--        //OMUC01, OMUC02
,(N'HeadingResourceKeyConstants', N'OutbreakSessionOutbreakSummaryHeading', N'InterfaceEditorResourceSetEnum.OutbreakSession + "977"')
,(N'HeadingResourceKeyConstants', N'OutbreakSessionOutbreakSessionHeading', N'InterfaceEditorResourceSetEnum.OutbreakSession + "978"')

,(N'HeadingResourceKeyConstants', N'CreateOutbreakOutbreakParametersHeading', N'InterfaceEditorResourceSetEnum.CreateOutbreak + "1043"')

,(N'HeadingResourceKeyConstants', N'OutbreakManagementListOutbreakManagementListHeading', N'InterfaceEditorResourceSetEnum.OutbreakManagementList + "986"')
,(N'HeadingResourceKeyConstants', N'OutbreakManagementListSearchResultsHeading', N'InterfaceEditorResourceSetEnum.OutbreakManagementList + "244"')
,(N'HeadingResourceKeyConstants', N'OutbreakManagementListOutbreakSessionListHeading', N'InterfaceEditorResourceSetEnum.OutbreakManagementList + "3641"')
,(N'HeadingResourceKeyConstants', N'OutbreakManagementListOutbreakCasesListHeading', N'InterfaceEditorResourceSetEnum.OutbreakManagementList + "4753"')
,(N'HeadingResourceKeyConstants', N'OutbreakManagementListSearchOutbreakHeading', N'InterfaceEditorResourceSetEnum.OutbreakManagementList + "4801"')		

,(N'HeadingResourceKeyConstants', N'OutbreakCaseInvestigationCaseQuestionnaireHeading', N'InterfaceEditorResourceSetEnum.OutbreakCaseInvestigation + "3533"')

--        //OMUC04, OMUC05
,(N'HeadingResourceKeyConstants', N'CreateHumanCaseCaseDetailsHeading', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "3435"')
,(N'HeadingResourceKeyConstants', N'CreateHumanCaseCaseLocationHeading', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "3205"')
,(N'HeadingResourceKeyConstants', N'CreateHumanCaseClinicalInformationHeading', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "3207"')
,(N'HeadingResourceKeyConstants', N'CreateHumanCaseCaseInvestigationHeading', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "3540"')
,(N'HeadingResourceKeyConstants', N'CreateHumanCaseCaseMonitoringHeading', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "3208"')
,(N'HeadingResourceKeyConstants', N'CreateHumanCaseContactsHeading', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "3209"')
,(N'HeadingResourceKeyConstants', N'CreateHumanCaseOutbreakInvestigationHeading', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "3211"')

--        //OMUC06 - Enter Veterinary Case and OMUC07 - Edit Veterinary Case
,(N'HeadingResourceKeyConstants', N'CreateVeterinaryCaseCaseDetailsHeading', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3435"')
,(N'HeadingResourceKeyConstants', N'CreateVeterinaryCaseOutbreakDetailsHeading', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3436"')
,(N'HeadingResourceKeyConstants', N'CreateVeterinaryCaseNotificationHeading', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "1046"')
,(N'HeadingResourceKeyConstants', N'CreateVeterinaryCaseCaseLocationHeading', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3205"')
,(N'HeadingResourceKeyConstants', N'CreateVeterinaryCaseHerdFlockSpeciesInfoHeading', N' InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3206"')
,(N'HeadingResourceKeyConstants', N'CreateVeterinaryCaseClinicalInformationHeading', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3207"')
,(N'HeadingResourceKeyConstants', N'CreateVeterinaryCaseAnimalInvestigationsHeading', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3468"')
,(N'HeadingResourceKeyConstants', N'CreateVeterinaryCaseCaseMonitoringHeading', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3208"')
,(N'HeadingResourceKeyConstants', N'CreateVeterinaryCaseContactsHeading', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3209"')
,(N'HeadingResourceKeyConstants', N'CreateVeterinaryCaseVaccinationInformationHeading', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3210"')
,(N'HeadingResourceKeyConstants', N'CreateVeterinaryCaseOutbreakInvestigationHeading', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3211"')
,(N'HeadingResourceKeyConstants', N'CreateVeterinaryCaseSearchFarmHeading', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3123"')

,(N'HeadingResourceKeyConstants', N'CreateVeterinaryCaseSamplesHeading', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "664"')
,(N'HeadingResourceKeyConstants', N'CreateVeterinaryCasePensideTestsHeading', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "2460"')
,(N'HeadingResourceKeyConstants', N'CreateVeterinaryCaseLabTestsInterpretationHeading', N' InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3212"')
,(N'HeadingResourceKeyConstants', N'CreateVeterinaryCaseOutbreakCaseReportReviewHeading', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3213"')

--        //OMUC08-3
,(N'HeadingResourceKeyConstants', N'OutbreakContactsOutbreakContactsListHeading', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "4751"')

--        //OMUC11
,(N'HeadingResourceKeyConstants', N'OutbreakContactsContactDetailsHeading', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "1064"')
,(N'HeadingResourceKeyConstants', N'OutbreakContactsContactPremiseHeading', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "3618"')
,(N'HeadingResourceKeyConstants', N'OutbreakContactsContactTracingHeading', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "2690"')
,(N'HeadingResourceKeyConstants', N'OutbreakContactsDemographicsHeading', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "1063"')
,(N'HeadingResourceKeyConstants', N'OutbreakContactsCurrentAddressHeading', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "1061"')

--        //OMUC13
,(N'HeadingResourceKeyConstants', N'OutbreakUpdatesNewRecordHeading', N'InterfaceEditorResourceSetEnum.OutbreakUpdates + "2758"')

--        //OMUC14
,(N'HeadingResourceKeyConstants', N'OutbreakUpdatesEditRecordHeading', N'InterfaceEditorResourceSetEnum.OutbreakUpdates + "2772"')

--        //fixes for localization 10/20/2023
,(N'HeadingResourceKeyConstants', N'OutbreakEpiCurveHeading', N'InterfaceEditorResourceSetEnum.OutbreakAnalysis + "4816"') --//TODO: We don't have GG value for this. It's AZ bugs.


--region Vector Module Resources

,(N'HeadingResourceKeyConstants', N'VectorSessionAddSurroundingModalHeading', N'InterfaceEditorResourceSetEnum.VectorSessionAddSurrounding + "884"')

--        //VSUC01 - Enter Vector Surveillance Session and VSUC02 - Edit Vector Surevillance Session
,(N'HeadingResourceKeyConstants', N'VectorSurveillanceSessionSessionSummaryHeading', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSession + "2588"')
,(N'HeadingResourceKeyConstants', N'VectorSurveillanceSessionSessionLocationHeading', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSession + "2589"')
,(N'HeadingResourceKeyConstants', N'VectorAggregateCollectionAggregateCollectionsHeading', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "2590"')
,(N'HeadingResourceKeyConstants', N'VectorDetailedCollectionDetailedCollectionsHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "2591"')
,(N'HeadingResourceKeyConstants', N'VectorDetailedCollectionCopyDetailedCollectionRecordModalHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "2592"')
,(N'HeadingResourceKeyConstants', N'VectorSurveillanceSessionReviewHeading', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSession + "234"')

,(N'HeadingResourceKeyConstants', N'VectorDetailedCollectionHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "2610"')
,(N'HeadingResourceKeyConstants', N'VectorDetailedCollectionSessionSummaryHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "2588"')
,(N'HeadingResourceKeyConstants', N'VectorDetailedCollectionSamplesHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "664"')
,(N'HeadingResourceKeyConstants', N'VectorDetailedCollectionFieldTestsHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "2615"')
,(N'HeadingResourceKeyConstants', N'VectorDetailedCollectionLaboratoryTestsHeading', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "2616"')

,(N'HeadingResourceKeyConstants', N'VectorSessionCollectionDataCollectionDataHeading', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "2611"')
,(N'HeadingResourceKeyConstants', N'VectorSessionCollectionDataCollectionLocationHeading', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "2612"')
        
,(N'HeadingResourceKeyConstants', N'VectorSessionVectorDataVectorDataHeading', N'InterfaceEditorResourceSetEnum.VectorSessionVectorData + "2613"')
        
,(N'HeadingResourceKeyConstants', N'VectorSessionVectorSpecificDataVectorSpecificDataHeading', N'InterfaceEditorResourceSetEnum.VectorSessionVectorSpecificData + "2614"')

,(N'HeadingResourceKeyConstants', N'VectorAggregateCollectionHeading', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "2637"')
,(N'HeadingResourceKeyConstants', N'VectorAggregateCollectionCollectionLocationHeading', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "2612"')
,(N'HeadingResourceKeyConstants', N'VectorAggregateCollectionListofDiseasesHeading', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "2638"')

--        //VSUC03 - Search for Vector Surveillance Session
,(N'HeadingResourceKeyConstants', N'VectorPageHeading', N'InterfaceEditorResourceSetEnum.Vector + "2579"')
,(N'HeadingResourceKeyConstants', N'VectorSurveillanceSessionsListPageHeading', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "4471"')



--region Veterinary Module Resources

,(N'HeadingResourceKeyConstants', N'VeterinaryActiveSurveillanceCampaignPageHeading', N'InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceCampaign + "2450"')
,(N'HeadingResourceKeyConstants', N'AvianDiseaseReportPageHeading', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "2435"')
,(N'HeadingResourceKeyConstants', N'LivestockDiseaseReportPageHeading', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "2436"')
,(N'HeadingResourceKeyConstants', N'VeterinaryDiseaseReportVaccinationsHeading', N'InterfaceEditorResourceSetEnum.VeterinaryDiseaseReportVaccinations + "2456"')
,(N'HeadingResourceKeyConstants', N'VaccinationDetailsModalHeading', N'InterfaceEditorResourceSetEnum.VaccinationDetailsModal + "2457"')
,(N'HeadingResourceKeyConstants', N'VeterinaryDiseaseReportCaseLogHeading', N'InterfaceEditorResourceSetEnum.VeterinaryDiseaseReportCaseLog + "2466"')
,(N'HeadingResourceKeyConstants', N'CaseLogDetailsModalHeading', N'InterfaceEditorResourceSetEnum.CaseLogDetailsModal + "2467"')
,(N'HeadingResourceKeyConstants', N'AvianDiseaseReportReviewHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReport + "234"')
,(N'HeadingResourceKeyConstants', N'LivestockDiseaseReportReviewHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReport + "234"')
,(N'HeadingResourceKeyConstants', N'VeterinaryAggregateDiseaseReportPageHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReport + "2546"')
,(N'HeadingResourceKeyConstants', N'VeterinaryAggregateActionReportPageHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReport + "2547"')
,(N'HeadingResourceKeyConstants', N'AvianAddTestCategoryModalHeading', N'InterfaceEditorResourceSetEnum.AvianAddTestCategoryModal + "935"')
,(N'HeadingResourceKeyConstants', N'LivestockAddTestCategoryModalHeading', N'InterfaceEditorResourceSetEnum.LivestockAddTestCategoryModal + "935"')
,(N'HeadingResourceKeyConstants', N'VeterinaryDiseaseReportsListHeading', N'InterfaceEditorResourceSetEnum.VeterinaryReports + "3516"')

--        //VASUC02 - Set Up Veterinary Active Surveillance Session and VASUC03 - Edit Veterinary Active Surveillance Session
,(N'HeadingResourceKeyConstants', N'VeterinaryActiveSurveillanceSessionPageHeading', N'InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceSession + "2451"')
,(N'HeadingResourceKeyConstants', N'VeterinarySessionDetailedInformationHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "887"')
,(N'HeadingResourceKeyConstants', N'VeterinarySessionDetailedInformationSearchFarmHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "3123"')
,(N'HeadingResourceKeyConstants', N'VeterinarySessionDetailedInformationFarmListHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2524"')
,(N'HeadingResourceKeyConstants', N'VeterinarySessionDetailedInformationFarmHerdSpeciesDetailsHeading', N' InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2531"')
,(N'HeadingResourceKeyConstants', N'VeterinarySessionDetailedInformationFarmFlockSpeciesDetailsHeading', N' InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2532"')
,(N'HeadingResourceKeyConstants', N'VeterinarySessionDetailedInformationDetailedAnimalsAndSamplesHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2525"')
,(N'HeadingResourceKeyConstants', N'VeterinarySessionSampleDetailsModalHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionSampleDetailsModal + "751"')
,(N'HeadingResourceKeyConstants', N'VeterinarySessionTestsHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionTests + "889"')
,(N'HeadingResourceKeyConstants', N'VeterinarySessionInterpretationDetailsModalHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionInterpretationDetailsModal + "2526"')
,(N'HeadingResourceKeyConstants', N'VeterinarySessionActionsHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionActions + "891"')
,(N'HeadingResourceKeyConstants', N'VeterinarySessionAggregateInformationHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2527"')
,(N'HeadingResourceKeyConstants', N'VeterinarySessionAggregateInformationFarmListHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2524"')
,(N'HeadingResourceKeyConstants', N'VeterinarySessionAggregateInformationFarmHerdSpeciesDetailsHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2531"')
,(N'HeadingResourceKeyConstants', N'VeterinarySessionAggregateInformationFarmFlockSpeciesDetailsHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2532"')
,(N'HeadingResourceKeyConstants', N'VeterinarySessionAggregateInformationAggregateAnimalsAndSamplesHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2528"')
,(N'HeadingResourceKeyConstants', N'VeterinarySessionAggregateInformationDetailsModalHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformationDetailsModal + "2529"')
,(N'HeadingResourceKeyConstants', N'VeterinarySessionSessionDiseaseReportsHeading', N'InterfaceEditorResourceSetEnum.VeterinarySessionDiseaseReports + "893"')
,(N'HeadingResourceKeyConstants', N'VeterinaryActiveSurveillanceSessionReviewHeading', N'InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceSession + "234"')

--        //VAUC05 - Enter Veterinary Aggregate Disease Report and VAUC06 - Edit Veterinary Aggregate Disease Report
,(N'HeadingResourceKeyConstants', N'VeterinaryAggregateDiseaseReportReviewHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReport + "234"')

--        //VAUC09 - Enter Veterinary Aggregate Action Report and VAUC10 - Edit Veterinary Aggregate Action Report
,(N'HeadingResourceKeyConstants', N'VeterinaryAggregateActionReportReviewHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReport + "234"')

--        //VAUC07 - Search for Veterinary Aggregate Disease Report and VAUC11 - Search for Veterinary Aggregate Action Report
,(N'HeadingResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationReportDetailsHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "930"')
,(N'HeadingResourceKeyConstants', N'VeterinaryAggregateDiseaseReportInformationReportDetailsHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "930"')
,(N'HeadingResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationNotificationSentByHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "757"')
,(N'HeadingResourceKeyConstants', N'VeterinaryAggregateDiseaseReportInformationNotificationSentByHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "757"')
,(N'HeadingResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationNotificationReceivedByHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "931"')
,(N'HeadingResourceKeyConstants', N'VeterinaryAggregateDiseaseReportInformationNotificationReceivedByHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "931"')
,(N'HeadingResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationEnteredByHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "758"')
,(N'HeadingResourceKeyConstants', N'VeterinaryAggregateDiseaseReportInformationEnteredByHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "758"')
,(N'HeadingResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationGeneralInfoHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "932"')
,(N'HeadingResourceKeyConstants', N'VeterinaryAggregateDiseaseReportInformationGeneralInfoHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "932"')
,(N'HeadingResourceKeyConstants', N'VeterinaryAggregateDiseaseReportDiseaseMatrixHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateReportMatrix + "759"')

--        //VAUC13 - Enter Veterinary Aggregate Disease Reports Summary and VAUC14 - Enter Veterinary Aggregate Action Reports Summary
,(N'HeadingResourceKeyConstants', N'VeterinaryAggregateDiseaseReportSummaryPageHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportSummary + "2548"')
,(N'HeadingResourceKeyConstants', N'VeterinaryAggregateActionReportSummaryPageHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReportSummary + "2549"')
,(N'HeadingResourceKeyConstants', N'SelectedAggregateActionReportsHeading', N'InterfaceEditorResourceSetEnum.SelectedAggregateActionReports + "2550"')
,(N'HeadingResourceKeyConstants', N'VeterinaryAggregateDiseaseReportSummarySummaryHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportSummary + "2551"')
,(N'HeadingResourceKeyConstants', N'VeterinaryAggregateActionReportSummarySummaryHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReportSummary + "2551"')
,(N'HeadingResourceKeyConstants', N'VeterinaryAggregateDiseaseReportSummarySearchHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportSummary + "2877"')
,(N'HeadingResourceKeyConstants', N'VeterinaryAggregateDiseaseReportSummarySummaryAggregateSettingsHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportSummary + "1873"')
,(N'HeadingResourceKeyConstants', N'VeterinaryAggregateDiseaseReportSummarySelectedAggregateDiseaseReportsHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportSummary + "1874"')
,(N'HeadingResourceKeyConstants', N'VeterinaryAggregateActionReportSummaryDiagnosticInvestigationsHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReportSummary + "4804"')		
,(N'HeadingResourceKeyConstants', N'VeterinaryAggregateActionReportSummaryTreatmentProphylacticAndVaccinationMeasuresHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReportSummary + "4805"')		
,(N'HeadingResourceKeyConstants', N'VeterinaryAggregateActionReportSummaryVeterinarySanitaryMeasuresHeading', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReportSummary + "4806"')		

--        //VUC16 - Search for Farm Record
,(N'HeadingResourceKeyConstants', N'SearchFarmsFarmOwnerHeading', N'InterfaceEditorResourceSetEnum.SearchFarms + "2402"')
,(N'HeadingResourceKeyConstants', N'FarmPageHeading', N'InterfaceEditorResourceSetEnum.SearchFarms + "2401"')

--        //VUC17 - Enter New Farm Record
,(N'HeadingResourceKeyConstants', N'FarmDetailsFarmInformationHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "2421"')
,(N'HeadingResourceKeyConstants', N'FarmDetailsFarmAddressHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "2422"')
,(N'HeadingResourceKeyConstants', N'FarmDetailsOwnershipStructureHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "2423"')
,(N'HeadingResourceKeyConstants', N'FarmDetailsAvianFarmTypeHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "2424"')
,(N'HeadingResourceKeyConstants', N'FarmDetailsFarmDetailsHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "2425"')
,(N'HeadingResourceKeyConstants', N'FarmDetailsFarmReviewHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "2426"')
,(N'HeadingResourceKeyConstants', N'FarmDetailsHerdsandSpeciesHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "2427"')
,(N'HeadingResourceKeyConstants', N'FarmDetailsFlocksandSpeciesHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "2428"')
,(N'HeadingResourceKeyConstants', N'FarmDetailsDiseaseReportsHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "893"')
,(N'HeadingResourceKeyConstants', N'FarmDetailsOutbreakCasesHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "2429"')
,(N'HeadingResourceKeyConstants', N'FarmDetailsReviewHeading', N'InterfaceEditorResourceSetEnum.FarmDetails + "234"')

--        //VUC04 - Enter Livestock Disease Report and VUC06 - Edit Livestock Disease Report
,(N'HeadingResourceKeyConstants', N'LivestockDiseaseReportDiseaseReportSummaryHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSummary + "1045"')
,(N'HeadingResourceKeyConstants', N'LivestockDiseaseReportFarmDetailsHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmDetails + "2425"')
,(N'HeadingResourceKeyConstants', N'LivestockDiseaseReportNotificationHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportNotification + "1046"')
,(N'HeadingResourceKeyConstants', N'LivestockDiseaseReportNotificationInvestigatedHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportNotification + "2452"')
,(N'HeadingResourceKeyConstants', N'LivestockDiseaseReportNotificationDataEntryHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportNotification + "2453"')
,(N'HeadingResourceKeyConstants', N'LivestockDiseaseReportFarmHerdSpeciesHeading', N' InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2454"')
,(N'HeadingResourceKeyConstants', N'LivestockDiseaseReportFarmEpiInformationHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmEpidemiologicalInformation + "2468"')
,(N'HeadingResourceKeyConstants', N'LivestockDiseaseReportSpeciesInvestigationHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSpeciesInvestigation + "2469"')
,(N'HeadingResourceKeyConstants', N'LivestockDiseaseReportAnimalsHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportAnimals + "2458"')
,(N'HeadingResourceKeyConstants', N'LivestockDiseaseReportAnimalDetailsModalHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportAnimalDetailsModal + "2459"')
,(N'HeadingResourceKeyConstants', N'LivestockDiseaseReportControlMeasuresHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportControlMeasures + "2470"')
,(N'HeadingResourceKeyConstants', N'LivestockDiseaseReportSamplesHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSamples + "664"')
,(N'HeadingResourceKeyConstants', N'LivestockDiseaseReportSampleDetailsModalHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSampleDetailsModal + "751"')
,(N'HeadingResourceKeyConstants', N'LivestockDiseaseReportPensideTestsHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportPensideTests + "2460"')
,(N'HeadingResourceKeyConstants', N'LivestockDiseaseReportPensideTestDetailsModalHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportPensideTestDetailsModal + "2461"')
,(N'HeadingResourceKeyConstants', N'LivestockDiseaseReportLabTestsHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportLabTests + "2462"')
,(N'HeadingResourceKeyConstants', N'LivestockDiseaseReportLabTestDetailsModalHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportLabTestDetailsModal + "2463"')
,(N'HeadingResourceKeyConstants', N'LivestockDiseaseReportResultsSummaryInterpretationHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportResultsSummaryInterpretation + "2464"')
,(N'HeadingResourceKeyConstants', N'LivestockDiseaseReportInterpretationDetailsModalHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportInterpretationDetailsModal + "2465"')
,(N'HeadingResourceKeyConstants', N'LivestockDiseaseReportImportSamplesTestResultsModalImportSamplesTestResultsHeading', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportImportSamplesTestResultsModal + "3122"')

--        //VUC05 - Enter Avian Disease Report and VUC07 - Edit Avian Disease Report
,(N'HeadingResourceKeyConstants', N'AvianDiseaseReportDiseaseReportSummaryHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSummary + "1045"')
,(N'HeadingResourceKeyConstants', N'AvianDiseaseReportFarmDetailsHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmDetails + "2425"')
,(N'HeadingResourceKeyConstants', N'AvianDiseaseReportNotificationHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportNotification + "2426"')
,(N'HeadingResourceKeyConstants', N'AvianDiseaseReportNotificationInvestigatedHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportNotification + "2452"')
,(N'HeadingResourceKeyConstants', N'AvianDiseaseReportNotificationDataEntryHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportNotification + "2453"')
,(N'HeadingResourceKeyConstants', N'AvianDiseaseReportFarmFlockSpeciesHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2455"')
,(N'HeadingResourceKeyConstants', N'AvianDiseaseReportFarmEpiInformationHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmEpidemiologicalInformation + "2468"')
,(N'HeadingResourceKeyConstants', N'AvianDiseaseReportSpeciesInvestigationHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSpeciesInvestigation + "2469"')
,(N'HeadingResourceKeyConstants', N'AvianDiseaseReportSamplesHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSamples + "664"')
,(N'HeadingResourceKeyConstants', N'AvianDiseaseReportSampleDetailsModalHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSampleDetailsModal + "751"')
,(N'HeadingResourceKeyConstants', N'AvianDiseaseReportPensideTestsHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportPensideTests + "2460"')
,(N'HeadingResourceKeyConstants', N'AvianDiseaseReportPensideTestDetailsModalHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportPensideTestDetailsModal + "2461"')
,(N'HeadingResourceKeyConstants', N'AvianDiseaseReportLabTestsHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportLabTests + "2462"')
,(N'HeadingResourceKeyConstants', N'AvianDiseaseReportLabTestDetailsModalHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportLabTestDetailsModal + "2463"')
,(N'HeadingResourceKeyConstants', N'AvianDiseaseReportResultsSummaryInterpretationHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportResultsSummaryInterpretation + "2464"')
,(N'HeadingResourceKeyConstants', N'AvianDiseaseReportInterpretationDetailsModalHeading', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportInterpretationDetailsModal + "2465"')
,(N'HeadingResourceKeyConstants', N'AvianDiseaseReportImportSamplesTestResultsModalImportSamplesTestResultsHeading', N' InterfaceEditorResourceSetEnum.AvianDiseaseReportImportSamplesTestResultsModal + "3122"')



--region Aggregate Disease Report Common Resources

--        //Human and Veterinary Aggregate Disease Reports Summary Common
--        //HAUC05 - Enter Human Aggregate Disease Reports Summary
--        //VAUC13 - Enter Veterinary Aggregate Disease Reports Summary and VAUC14 - Enter Veterinary Aggregate Action Reports Summary
,(N'HeadingResourceKeyConstants', N'SummaryAggregateSettingsHeading', N'InterfaceEditorResourceSetEnum.SummaryAggregateSettings + "1873"')
,(N'HeadingResourceKeyConstants', N'SelectedAggregateDiseaseReportsHeading', N'InterfaceEditorResourceSetEnum.SelectedAggregateDiseaseReports + "1874"')



--region Active Surveillance Campaign Common Resources

--        //Human and Veterinary Active Surveillance Campaign Common
--        //HASUC01 - Enter Active Surveillance Campaign and HASUC02 - Edit Active Surveillance Campaign
--        //VASUC01 - Enter Active Surveillance Campaign and VASUC06 - Edit Active Surveillance Campaign
,(N'HeadingResourceKeyConstants', N'CampaignInformationHeading', N'InterfaceEditorResourceSetEnum.CampaignInformation + "1817"')
,(N'HeadingResourceKeyConstants', N'CampaignInformationSessionsHeading', N'InterfaceEditorResourceSetEnum.CampaignInformation + "2516"')



--region Active Surveillance Session Common Resources

--        //Human and Veterinary Active Surveillance Session Common
--        //HASUC03 - Enter Human Active Surveillance Session and HASUC04 - Edit Human Active Surveillance Session
,(N'HeadingResourceKeyConstants', N'SessionInformationDetailedPersonsandSamplesHeading', N'InterfaceEditorResourceSetEnum.SessionInformation + "2847"')
,(N'HeadingResourceKeyConstants', N'SessionInformationSampleDetailsHeading', N'InterfaceEditorResourceSetEnum.SessionInformation + "751"')
,(N'HeadingResourceKeyConstants', N'SessionInformationTestDetailsHeading', N'InterfaceEditorResourceSetEnum.SessionInformation + "890"')

--        //VASUC02 - Set Up Veterinary Active Surveillance Session and VASUC03 - Edit Veterinary Active Surveillance Session
,(N'HeadingResourceKeyConstants', N'SessionInformationSessionInformationHeading', N'InterfaceEditorResourceSetEnum.SessionInformation + "863"')
,(N'HeadingResourceKeyConstants', N'SessionInformationLocationHeading', N'InterfaceEditorResourceSetEnum.SessionInformation + "864"')
,(N'HeadingResourceKeyConstants', N'TestDetailsModalHeading', N'InterfaceEditorResourceSetEnum.TestDetailsModal + "890"')
,(N'HeadingResourceKeyConstants', N'ActionDetailsModalHeading', N'InterfaceEditorResourceSetEnum.ActionDetailsModal + "892"')



--region WHO Export
--        //SINT03
,(N'HeadingResourceKeyConstants', N'HumanExporttoCISIDWHOExportHeading', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4641"')



--FieldLabelResourceKeyConstants

--region Common Resources

--region Paging

insert into #Caption (captionClass, controlCaptionConstant, controlCaptionIdRaw) values
 (N'FieldLabelResourceKeyConstants', N'FirstFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "334"')
,(N'FieldLabelResourceKeyConstants', N'LastFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "336"')
,(N'FieldLabelResourceKeyConstants', N'NextFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "337"')
,(N'FieldLabelResourceKeyConstants', N'PageFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "159"')
,(N'FieldLabelResourceKeyConstants', N'PreviousFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "335"')
,(N'FieldLabelResourceKeyConstants', N'CommonLabelsItemsPerPageFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "3670"')

--endregion Paging

--        //Common - Validation
,(N'FieldLabelResourceKeyConstants', N'FieldIsRequiredMessage', N'InterfaceEditorResourceSetEnum.CommonLabels + "231"')

--        //Common - New Record
,(N'FieldLabelResourceKeyConstants', N'CommonLabelsNewFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "3091"')

--        //SYSUC04 - Change Password
,(N'FieldLabelResourceKeyConstants', N'ChangePasswordCurrentPasswordFieldLabel', N'InterfaceEditorResourceSetEnum.ChangePassword + "2555"')

,(N'FieldLabelResourceKeyConstants', N'ChangePasswordNewPasswordFieldLabel', N'InterfaceEditorResourceSetEnum.ChangePassword + "2554"')
,(N'FieldLabelResourceKeyConstants', N'ChangePasswordConfirmPasswordFieldLabel', N'InterfaceEditorResourceSetEnum.ChangePassword + "566"')

,(N'FieldLabelResourceKeyConstants', N'SecurityConnecttoarchiveFieldLabel', N'InterfaceEditorResourceSetEnum.Security + "3620"')
,(N'FieldLabelResourceKeyConstants', N'SecurityLogoutFieldLabel', N'InterfaceEditorResourceSetEnum.Security + "3621"')
,(N'FieldLabelResourceKeyConstants', N'SecurityUserPreferencesFieldLabel', N'InterfaceEditorResourceSetEnum.Security + "3622"')
,(N'FieldLabelResourceKeyConstants', N'SecurityDisconnectFromArchiveFieldLabel', N'InterfaceEditorResourceSetEnum.Security + "3623"')

--        //SYSUC07 - Enter Address
,(N'FieldLabelResourceKeyConstants', N'LocationAdministrativeLevel0FieldLabel', N'InterfaceEditorResourceSetEnum.Location + "47"')

,(N'FieldLabelResourceKeyConstants', N'LocationAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.Location + "428"')
,(N'FieldLabelResourceKeyConstants', N'LocationAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.Location + "426"')
,(N'FieldLabelResourceKeyConstants', N'LocationAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.Location + "248"')
,(N'FieldLabelResourceKeyConstants', N'LocationAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.Location + "949"')
,(N'FieldLabelResourceKeyConstants', N'LocationAdministrativeLevel5FieldLabel', N'InterfaceEditorResourceSetEnum.Location + "950"')
,(N'FieldLabelResourceKeyConstants', N'LocationAdministrativeLevel6FieldLabel', N'InterfaceEditorResourceSetEnum.Location + "951"')
,(N'FieldLabelResourceKeyConstants', N'LocationAllFieldLabel', N'InterfaceEditorResourceSetEnum.Location + "946"')
,(N'FieldLabelResourceKeyConstants', N'LocationMapFieldLabel', N'InterfaceEditorResourceSetEnum.Location + "3371"')

,(N'FieldLabelResourceKeyConstants', N'AdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "428"')
,(N'FieldLabelResourceKeyConstants', N'AdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "426"')
,(N'FieldLabelResourceKeyConstants', N'AdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "248"')

--        //Actor Resources
,(N'FieldLabelResourceKeyConstants', N'ActorNameFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "14"')

,(N'FieldLabelResourceKeyConstants', N'ActorTypeFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "15"')

--region Aggregate Disease Reports Common

--        //Human and Veterinary Aggregate Disease Reports Summary Common
--        //HAUC05 - Enter Human Aggregate Disease Reports Summary
--        //VAUC13 - Enter Veterinary Aggregate Disease Reports Summary and VAUC14 - Enter Veterinary Aggregate Action Reports Summary
,(N'FieldLabelResourceKeyConstants', N'SummaryAggregateSettingsAdministrativeLevelFieldLabel', N'InterfaceEditorResourceSetEnum.SummaryAggregateSettings + "943"')

,(N'FieldLabelResourceKeyConstants', N'SummaryAggregateSettingsTimeIntervalFieldLabel', N'InterfaceEditorResourceSetEnum.SummaryAggregateSettings + "1872"')

--        //Human and Veterinary Active Surveillance Campaign Common
--        //HASUC01 - Enter Active Surveillance Campaign and HASUC02 - Edit Active Surveillance Campaign
--        //VASUC01 - Enter Active Surveillance Campaign and VASUC06 - Edit Active Surveillance Campaign
,(N'FieldLabelResourceKeyConstants', N'CampaignInformationCampaignIDFieldLabel', N'InterfaceEditorResourceSetEnum.CampaignInformation + "796"')

,(N'FieldLabelResourceKeyConstants', N'CampaignInformationLegacyIDFieldLabel', N'InterfaceEditorResourceSetEnum.CampaignInformation + "796"')
,(N'FieldLabelResourceKeyConstants', N'CampaignInformationCampaignNameFieldLabel', N'InterfaceEditorResourceSetEnum.CampaignInformation + "797"')
,(N'FieldLabelResourceKeyConstants', N'CampaignInformationCampaignTypeFieldLabel', N'InterfaceEditorResourceSetEnum.CampaignInformation + "798"')
,(N'FieldLabelResourceKeyConstants', N'CampaignInformationCampaignStatusFieldLabel', N'InterfaceEditorResourceSetEnum.CampaignInformation + "799"')
,(N'FieldLabelResourceKeyConstants', N'CampaignInformationCampaignStartDateFieldLabel', N'InterfaceEditorResourceSetEnum.CampaignInformation + "827"')
,(N'FieldLabelResourceKeyConstants', N'CampaignInformationCampaignEndDateFieldLabel', N'InterfaceEditorResourceSetEnum.CampaignInformation + "828"')
,(N'FieldLabelResourceKeyConstants', N'CampaignInformationCampaignAdministratorFieldLabel', N'InterfaceEditorResourceSetEnum.CampaignInformation + "829"')

,(N'FieldLabelResourceKeyConstants', N'HumanActiveSurveillanceCampaignConclusionFieldLabel', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "2519"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryActiveSurveillanceCampaignConclusionFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceCampaign + "2519"')

--endregion Aggregate Disease Reports Common

--region Active Surveillance Campaigns Common

--        //Search Human and Veterinary Activw Surveillance Campaign Modal
,(N'FieldLabelResourceKeyConstants', N'SearchActiveSurveillanceCampaignsModalCampaignIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchActiveSurveillanceCampaignsModal + "796"')

,(N'FieldLabelResourceKeyConstants', N'SearchActiveSurveillanceCampaignsModalCampaignNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchActiveSurveillanceCampaignsModal + "797"')
,(N'FieldLabelResourceKeyConstants', N'SearchActiveSurveillanceCampaignsModalCampaignTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchActiveSurveillanceCampaignsModal + "798"')
,(N'FieldLabelResourceKeyConstants', N'SearchActiveSurveillanceCampaignsModalCampaignStatusFieldLabel', N'InterfaceEditorResourceSetEnum.SearchActiveSurveillanceCampaignsModal + "799"')
,(N'FieldLabelResourceKeyConstants', N'SearchActiveSurveillanceCampaignsModalCampaignStartDateRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchActiveSurveillanceCampaignsModal + "800"')
,(N'FieldLabelResourceKeyConstants', N'SearchActiveSurveillanceCampaignsModalCampaignDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.SearchActiveSurveillanceCampaignsModal + "71"')

--endregion Active Surveillance Campaigns Common

--region Active Surveillance Sessions Common

--        //Human and Veterinary Active Surveillance Session Common
--        //HASUC03 - Enter Human Active Surveillance Session and HASUC04 - Edit Human Active Surveillance Session
--        //VASUC02 - Set Up Veterinary Active Surveillance Session and VASUC03 - Edit Veterinary Active Surveillance Session
,(N'FieldLabelResourceKeyConstants', N'SessionInformationSessionIDFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "808"')

,(N'FieldLabelResourceKeyConstants', N'SessionInformationLegacyIDFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "936"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationSessionStatusFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "809"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationCampaignIDFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "796"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationCampaignNameFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "797"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationCampaignTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "798"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationSesionStartDateFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "850"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationSesionEndDateFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "851"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationSpeciesTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "440"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationSiteFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "549"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "762"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationDateEnteredFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "854"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationAdministrativeLevel0FieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "47"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "428"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "426"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "248"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "949"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationAdministrativeLevel5FieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "950"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationAdministrativeLevel6FieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "951"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "249"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "365"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationFieldSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "870"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationPersonIDFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "871"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationPersonAddressFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "872"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationCollectionDateFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "873"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationCommentsFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "874"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationSentToOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "875"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "71"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationLabSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "668"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationFilterByDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "877"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationTestNameFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "370"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationTestDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "876"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationTestStatusFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "679"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationTestCategoryFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "369"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationResultDateFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "881"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationTestResultFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "371"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationFilterByTestNameFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "2867"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationActionRequiredFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "883"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationEnteredByFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "885"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationCommentFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "767"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationStatusFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "575"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationDateofActionFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "2870"')
,(N'FieldLabelResourceKeyConstants', N'SessionInformationSessionDateFieldLabel', N'InterfaceEditorResourceSetEnum.SessionInformation + "2906"')

--        //Human, Avian, and Livestock Disease Reports Common Test Details Interface Editor Set
,(N'FieldLabelResourceKeyConstants', N'TestDetailsModalFieldSampleIDieldLabel', N'InterfaceEditorResourceSetEnum.TestDetailsModal + "870"')

,(N'FieldLabelResourceKeyConstants', N'TestDetailsModalLabSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.TestDetailsModal + "668"')
,(N'FieldLabelResourceKeyConstants', N'TestDetailsModalSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.TestDetailsModal + "365"')
,(N'FieldLabelResourceKeyConstants', N'TestDetailsModalPersonIDFieldLabel', N'InterfaceEditorResourceSetEnum.TestDetailsModal + "871"')
,(N'FieldLabelResourceKeyConstants', N'TestDetailsModalFarmIDFieldLabel', N'InterfaceEditorResourceSetEnum.TestDetailsModal + "2403"')
,(N'FieldLabelResourceKeyConstants', N'TestDetailsModalAnimalIDFieldLabel', N'InterfaceEditorResourceSetEnum.TestDetailsModal + "2495"')
,(N'FieldLabelResourceKeyConstants', N'TestDetailsModalTestDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.TestDetailsModal + "876"')
,(N'FieldLabelResourceKeyConstants', N'TestDetailsModalFilterByDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.TestDetailsModal + "877"')
,(N'FieldLabelResourceKeyConstants', N'TestDetailsModalTestNameFieldLabel', N'InterfaceEditorResourceSetEnum.TestDetailsModal + "370"')
,(N'FieldLabelResourceKeyConstants', N'TestDetailsModalTestCategoryFieldLabel', N'InterfaceEditorResourceSetEnum.TestDetailsModal + "369"')
,(N'FieldLabelResourceKeyConstants', N'TestDetailsModalTestStatusFieldLabel', N'InterfaceEditorResourceSetEnum.TestDetailsModal + "679"')
,(N'FieldLabelResourceKeyConstants', N'TestDetailsModalResultDateFieldLabel', N'InterfaceEditorResourceSetEnum.TestDetailsModal + "881"')
,(N'FieldLabelResourceKeyConstants', N'TestDetailsModalTestResultFieldLabel', N'InterfaceEditorResourceSetEnum.TestDetailsModal + "371"')
,(N'FieldLabelResourceKeyConstants', N'TestDetailsModalDateResultsReceivedFieldLabel', N'InterfaceEditorResourceSetEnum.TestDetailsModal + "1127"')
,(N'FieldLabelResourceKeyConstants', N'TestDetailsModalLaboratoryFieldLabel', N'InterfaceEditorResourceSetEnum.TestDetailsModal + "2871"')
,(N'FieldLabelResourceKeyConstants', N'TestDetailsModalEmployeeFieldLabel', N'InterfaceEditorResourceSetEnum.TestDetailsModal + "1126"')

,(N'FieldLabelResourceKeyConstants', N'ActionDetailsModalActionRequiredFieldLabel', N'InterfaceEditorResourceSetEnum.ActionDetailsModal + "883"')
,(N'FieldLabelResourceKeyConstants', N'ActionDetailsModalDateFieldLabel', N'InterfaceEditorResourceSetEnum.ActionDetailsModal + "763"')
,(N'FieldLabelResourceKeyConstants', N'ActionDetailsModalEnteredByFieldLabel', N'InterfaceEditorResourceSetEnum.ActionDetailsModal + "885"')
,(N'FieldLabelResourceKeyConstants', N'ActionDetailsModalCommentFieldLabel', N'InterfaceEditorResourceSetEnum.ActionDetailsModal + "767"')
,(N'FieldLabelResourceKeyConstants', N'ActionDetailsModalStatusFieldLabel', N'InterfaceEditorResourceSetEnum.ActionDetailsModal + "575"')
,(N'FieldLabelResourceKeyConstants', N'ActionDetailsModalDateofActionFieldLabel', N'InterfaceEditorResourceSetEnum.ActionDetailsModal + "2870"')

--endregion Active Surveillance Sessions Common

--endregion Common Resources

--region Administration Module Resources

,(N'FieldLabelResourceKeyConstants', N'AbbreviationFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "464"')
,(N'FieldLabelResourceKeyConstants', N'AbbreviationDefaultValueFieldLabel', N'InterfaceEditorResourceSetEnum.OrganizationInformation + "2"')
,(N'FieldLabelResourceKeyConstants', N'AbbreviationNationalValueFieldLabel', N'InterfaceEditorResourceSetEnum.OrganizationInformation + "3"')
,(N'FieldLabelResourceKeyConstants', N'AccessoryCodeFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "465"')
,(N'FieldLabelResourceKeyConstants', N'OrganizationInfoAccessoryCodeFieldLabel', N'InterfaceEditorResourceSetEnum.OrganizationInformation + "465"')
,(N'FieldLabelResourceKeyConstants', N'ActionFieldLabel', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "514"')
,(N'FieldLabelResourceKeyConstants', N'ActionParametersFieldLabel', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "530"')
,(N'FieldLabelResourceKeyConstants', N'ActivationDateFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "13"')
,(N'FieldLabelResourceKeyConstants', N'AgeGroupFieldLabel', N'InterfaceEditorResourceSetEnum.DiseaseAgeGroupMatrix + "471"')
,(N'FieldLabelResourceKeyConstants', N'AgeGroupDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.DiseaseAgeGroupMatrix + "71"')
,(N'FieldLabelResourceKeyConstants', N'AllowPastDatesInLaboratoryModuleFieldLabel', N'InterfaceEditorResourceSetEnum.SystemPreferences + "23"')
,(N'FieldLabelResourceKeyConstants', N'AnimalAgeFieldLabel', N'InterfaceEditorResourceSetEnum.SpeciesAnimalAgeMatrix + "472"')
,(N'FieldLabelResourceKeyConstants', N'ApartmentUnitFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "25"')
,(N'FieldLabelResourceKeyConstants', N'AreaTypeFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "26"')
,(N'FieldLabelResourceKeyConstants', N'BuildingFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "31"')
,(N'FieldLabelResourceKeyConstants', N'ButtonFieldLabel', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "520"')
,(N'FieldLabelResourceKeyConstants', N'CheckPointFieldLabel', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "515"')
,(N'FieldLabelResourceKeyConstants', N'CodeFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "476"')
,(N'FieldLabelResourceKeyConstants', N'CollectedByPoolFieldLabel', N'InterfaceEditorResourceSetEnum.AddVectorTypeModal + "477"')
,(N'FieldLabelResourceKeyConstants', N'CollectionMethodFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "478"')
,(N'FieldLabelResourceKeyConstants', N'CountryFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "47"')
,(N'FieldLabelResourceKeyConstants', N'CustomReportTypeFieldLabel', N'InterfaceEditorResourceSetEnum.CustomReportRows + "479"')
,(N'FieldLabelResourceKeyConstants', N'DataAccessDetailsReadPermissionIndicatorFieldLabel', N'InterfaceEditorResourceSetEnum.DataAccessDetailsModal + "212"')
,(N'FieldLabelResourceKeyConstants', N'DefaultLongNameFieldLabel', N'InterfaceEditorResourceSetEnum.ParameterDetails + "54"')
,(N'FieldLabelResourceKeyConstants', N'DefaultMapProjectFieldLabel', N'InterfaceEditorResourceSetEnum.SystemPreferences + "55"')
,(N'FieldLabelResourceKeyConstants', N'DefaultNameFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "56"')
,(N'FieldLabelResourceKeyConstants', N'DefaultAdministrativeLevel1InSearchPanelsFieldLabel', N'InterfaceEditorResourceSetEnum.SystemPreferences + "52"')
,(N'FieldLabelResourceKeyConstants', N'DefaultAdministrativeLevel2InSearchPanelsFieldLabel', N'InterfaceEditorResourceSetEnum.SystemPreferences + "53"')
,(N'FieldLabelResourceKeyConstants', N'DefaultValueFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "481"')
,(N'FieldLabelResourceKeyConstants', N'DerivativeTypeFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "342"')
,(N'FieldLabelResourceKeyConstants', N'DeterminantsFieldLabel', N'InterfaceEditorResourceSetEnum.DeterminantEditor + "69"')
,(N'FieldLabelResourceKeyConstants', N'DiagnosisFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "341"')
,(N'FieldLabelResourceKeyConstants', N'DiseaseColumnAdditionalTextFieldLabel', N'InterfaceEditorResourceSetEnum.CustomReportRows + "485"')
,(N'FieldLabelResourceKeyConstants', N'DiseaseGroupFieldLabel', N'InterfaceEditorResourceSetEnum.DiseaseGroupDiseaseMatrix + "343"')
,(N'FieldLabelResourceKeyConstants', N'DiseaseOrGroupFieldLabel', N'InterfaceEditorResourceSetEnum.CustomReportRows + "386"')
,(N'FieldLabelResourceKeyConstants', N'DisplayTypeFieldLabel', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "525"')
,(N'FieldLabelResourceKeyConstants', N'EditorFieldLabel', N'InterfaceEditorResourceSetEnum.ParameterDetails + "75"')
,(N'FieldLabelResourceKeyConstants', N'EmployeeGroupDescriptionFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "486"')
,(N'FieldLabelResourceKeyConstants', N'EnteredByOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "399"')
,(N'FieldLabelResourceKeyConstants', N'FieldTypeFieldLabel', N'InterfaceEditorResourceSetEnum.PersonalIdentificationTypeMatrix + "484"')
,(N'FieldLabelResourceKeyConstants', N'FillWithValueTextFieldLabel', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "516"')
,(N'FieldLabelResourceKeyConstants', N'FilterSamplesByDiseaseLabel', N'InterfaceEditorResourceSetEnum.SystemPreferences + "81"')
,(N'FieldLabelResourceKeyConstants', N'FinalCaseClassificationFieldLabel', N'InterfaceEditorResourceSetEnum.CaseClassificationsReferenceEditor + "344"')
,(N'FieldLabelResourceKeyConstants', N'FirstNameLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "402"')
,(N'FieldLabelResourceKeyConstants', N'FixedPresetValuesLabel', N'InterfaceEditorResourceSetEnum.ParameterTypesEditor + "546"')
,(N'FieldLabelResourceKeyConstants', N'FlexibleFormDesignerFieldLabel', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "533"')
,(N'FieldLabelResourceKeyConstants', N'ForeignAddressLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "83"')
,(N'FieldLabelResourceKeyConstants', N'FullPathLabel', N'InterfaceEditorResourceSetEnum.ParameterDetails + "84"')
,(N'FieldLabelResourceKeyConstants', N'FunctionFieldLabel', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "517"')
,(N'FieldLabelResourceKeyConstants', N'GenderFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "345"')
,(N'FieldLabelResourceKeyConstants', N'HeadingFieldLabel', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "532"')
,(N'FieldLabelResourceKeyConstants', N'HospitalFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "408"')
,(N'FieldLabelResourceKeyConstants', N'HouseFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "92"')
,(N'FieldLabelResourceKeyConstants', N'ICD10FieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "346"')
,(N'FieldLabelResourceKeyConstants', N'IndicatesRequiredFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "95"')
,(N'FieldLabelResourceKeyConstants', N'IndicativeFieldLabel', N'InterfaceEditorResourceSetEnum.TestTestResultMatrix + "347"')
,(N'FieldLabelResourceKeyConstants', N'InitialCaseClassificationFieldLabel', N'InterfaceEditorResourceSetEnum.CaseClassificationsReferenceEditor + "348"')
,(N'FieldLabelResourceKeyConstants', N'IntervalTypeFieldLabel', N'InterfaceEditorResourceSetEnum.AddAgeGroupModal + "349"')
,(N'FieldLabelResourceKeyConstants', N'IsUNITemplateFieldLabel', N'InterfaceEditorResourceSetEnum.TemplateEditor + "104"')
,(N'FieldLabelResourceKeyConstants', N'LabelFieldLabel', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "524"')
,(N'FieldLabelResourceKeyConstants', N'LabTestFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "350"')
,(N'FieldLabelResourceKeyConstants', N'LastNameLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "414"')
,(N'FieldLabelResourceKeyConstants', N'LegalFormFieldLabel', N'InterfaceEditorResourceSetEnum.OrganizationInformation + "107"')
,(N'FieldLabelResourceKeyConstants', N'LengthFieldLabel', N'InterfaceEditorResourceSetEnum.PersonalIdentificationTypeMatrix + "351"')
,(N'FieldLabelResourceKeyConstants', N'LinkLocalSampleIDToReportSessionIDFieldLabel', N'InterfaceEditorResourceSetEnum.SystemPreferences + "109"')
,(N'FieldLabelResourceKeyConstants', N'LOINCCodeFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "487"')
,(N'FieldLabelResourceKeyConstants', N'LowerBoundFieldLabel', N'InterfaceEditorResourceSetEnum.AddAgeGroupModal + "353"')
,(N'FieldLabelResourceKeyConstants', N'MainFormOfActivityFieldLabel', N'InterfaceEditorResourceSetEnum.OrganizationInformation + "112"')
,(N'FieldLabelResourceKeyConstants', N'MatrixSelectFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "247"')
,(N'FieldLabelResourceKeyConstants', N'MeasureCodeFieldLabel', N'InterfaceEditorResourceSetEnum.MeasuresReferenceEditor + "476"')
,(N'FieldLabelResourceKeyConstants', N'MeasureReferenceTypeFieldLabel', N'InterfaceEditorResourceSetEnum.MeasuresReferenceEditor + "116"')
,(N'FieldLabelResourceKeyConstants', N'MessageTextFieldLabel', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "526"')
,(N'FieldLabelResourceKeyConstants', N'MessageNationalTextFieldLabel', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "527"')
,(N'FieldLabelResourceKeyConstants', N'MiddleNameLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "416"')
,(N'FieldLabelResourceKeyConstants', N'MonthLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "418"')
,(N'FieldLabelResourceKeyConstants', N'NationalLongNameFieldLabel', N'InterfaceEditorResourceSetEnum.ParameterDetails + "138"')
,(N'FieldLabelResourceKeyConstants', N'NationalNameFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "139"')
,(N'FieldLabelResourceKeyConstants', N'NationalValueFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "354"')
,(N'FieldLabelResourceKeyConstants', N'NoFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "356"')
,(N'FieldLabelResourceKeyConstants', N'NotFieldLabel', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "528"')
,(N'FieldLabelResourceKeyConstants', N'NoteFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "145"')
,(N'FieldLabelResourceKeyConstants', N'NotificationReceivedFromFacilityFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "422"')
,(N'FieldLabelResourceKeyConstants', N'NumberDaysDisplayedByDefaultFieldLabel', N'InterfaceEditorResourceSetEnum.SystemPreferences + "146"')
,(N'FieldLabelResourceKeyConstants', N'OIECodeFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "357"')
,(N'FieldLabelResourceKeyConstants', N'OrderFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "358"')
,(N'FieldLabelResourceKeyConstants', N'OrganizationFullNameFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "359"')
,(N'FieldLabelResourceKeyConstants', N'OrganizationFullNameDefaultValueFieldLabel', N'InterfaceEditorResourceSetEnum.OrganizationInformation + "154"')
,(N'FieldLabelResourceKeyConstants', N'OrganizationFullNameNationalValueFieldLabel', N'InterfaceEditorResourceSetEnum.OrganizationInformation + "155"')
,(N'FieldLabelResourceKeyConstants', N'OrganizationNameFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "488"')
,(N'FieldLabelResourceKeyConstants', N'OrganizationTypeFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "157"')
,(N'FieldLabelResourceKeyConstants', N'OwnershipFormFieldLabel', N'InterfaceEditorResourceSetEnum.OrganizationInformation + "158"')
,(N'FieldLabelResourceKeyConstants', N'ParameterFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "197"')
,(N'FieldLabelResourceKeyConstants', N'ParameterTypeFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "201"')
,(N'FieldLabelResourceKeyConstants', N'ParentSectionFieldLabel', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "531"')
,(N'FieldLabelResourceKeyConstants', N'PasswordFieldLabel', N'InterfaceEditorResourceSetEnum.Login + "202"')
,(N'FieldLabelResourceKeyConstants', N'PensideTestFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "360"')
,(N'FieldLabelResourceKeyConstants', N'PeriodTypeFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "204"')
,(N'FieldLabelResourceKeyConstants', N'PersonalIDTypeFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "361"')
,(N'FieldLabelResourceKeyConstants', N'PhoneFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "206"')
,(N'FieldLabelResourceKeyConstants', N'PostalCodeFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "208"')
,(N'FieldLabelResourceKeyConstants', N'PrintMapInVeterinaryInvestigationFormsFieldLabel', N'InterfaceEditorResourceSetEnum.SystemPreferences + "210"')
,(N'FieldLabelResourceKeyConstants', N'ReferenceLabel', N'InterfaceEditorResourceSetEnum.ParameterTypesEditor + "547"')
,(N'FieldLabelResourceKeyConstants', N'ReferenceTypeFieldLabel', N'InterfaceEditorResourceSetEnum.BaseReferenceEditor + "227"')
,(N'FieldLabelResourceKeyConstants', N'ReportDiseaseGroupFieldLabel', N'InterfaceEditorResourceSetEnum.ReportDiagnosisGroupDiagnosisMatrix + "363"')
,(N'FieldLabelResourceKeyConstants', N'RowFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "364"')
,(N'FieldLabelResourceKeyConstants', N'RuleFieldLabel', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "518"')
,(N'FieldLabelResourceKeyConstants', N'SampleCodeFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "44"')
,(N'FieldLabelResourceKeyConstants', N'SampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.SampleTypesReferenceEditor + "435"')
,(N'FieldLabelResourceKeyConstants', N'SampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "365"')
,(N'FieldLabelResourceKeyConstants', N'SectionFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "245"')
,(N'FieldLabelResourceKeyConstants', N'SearchActorsActorNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchActorsModal + "916"')
,(N'FieldLabelResourceKeyConstants', N'SearchActorsActorTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchActorsModal + "915"')
,(N'FieldLabelResourceKeyConstants', N'SearchActorsOrganizationNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchActorsModal + "423"')
,(N'FieldLabelResourceKeyConstants', N'SearchActorsUserGroupDescriptionFieldLabel', N'InterfaceEditorResourceSetEnum.SearchActorsModal + "486"')
,(N'FieldLabelResourceKeyConstants', N'SectionParametersFieldLabel', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "529"')
,(N'FieldLabelResourceKeyConstants', N'SelectMatrixVersionFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "246"')
,(N'FieldLabelResourceKeyConstants', N'SelectVersionFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "113"')
,(N'FieldLabelResourceKeyConstants', N'SettlementFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "248"')
,(N'FieldLabelResourceKeyConstants', N'SettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "249"')
,(N'FieldLabelResourceKeyConstants', N'ShowForeignOrganizationsFieldLabel', N'InterfaceEditorResourceSetEnum.SearchOrganizations + "250"')
,(N'FieldLabelResourceKeyConstants', N'ShowWarningForFinalCaseClassificationFieldLabel', N'InterfaceEditorResourceSetEnum.SystemPreferences + "251"')
,(N'FieldLabelResourceKeyConstants', N'SiteFieldLabel', N'InterfaceEditorResourceSetEnum.SearchActorsModal + "549"')
,(N'FieldLabelResourceKeyConstants', N'SiteGroupFieldLabel', N'InterfaceEditorResourceSetEnum.SearchActorsModal + "550"')
,(N'FieldLabelResourceKeyConstants', N'SpecializationFieldLabel', N'InterfaceEditorResourceSetEnum.SearchOrganizations + "253"')
,(N'FieldLabelResourceKeyConstants', N'SpeciesFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "366"')
,(N'FieldLabelResourceKeyConstants', N'SpeciesTypeFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "440"')
,(N'FieldLabelResourceKeyConstants', N'SpeciesCodeFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "476"')
,(N'FieldLabelResourceKeyConstants', N'StartupLanguageFieldLabel', N'InterfaceEditorResourceSetEnum.SystemPreferences + "255"')
,(N'FieldLabelResourceKeyConstants', N'StatisticalAgeGroupFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "367"')
,(N'FieldLabelResourceKeyConstants', N'StatisticalParameterTypeFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "2695"')
,(N'FieldLabelResourceKeyConstants', N'FlexibleFormDesignerNewEntryFieldLabel', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "2785"')
,(N'FieldLabelResourceKeyConstants', N'FlexibleFormDesignerNationalNameFieldLabel', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "139"')
,(N'FieldLabelResourceKeyConstants', N'FlexibleFormDesignerDefaultNameFieldLabel', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "56"')
,(N'FieldLabelResourceKeyConstants', N'SystemPreferencesDefaultRegionFieldLabel', N'InterfaceEditorResourceSetEnum.SystemPreferences + "3916"')
,(N'FieldLabelResourceKeyConstants', N'SystemPreferencesDefaultRayonFieldLabel', N'InterfaceEditorResourceSetEnum.SystemPreferences + "3917"')

,(N'FieldLabelResourceKeyConstants', N'SearchActorsModalActorNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchActorsModal + "608"')
,(N'FieldLabelResourceKeyConstants', N'SearchActorsModalActorTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchActorsModal + "201"')
,(N'FieldLabelResourceKeyConstants', N'SearchActorsModalOrganizationNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchActorsModal + "423"')
,(N'FieldLabelResourceKeyConstants', N'SearchActorsModalUserGroupDescriptionFieldLabel', N'InterfaceEditorResourceSetEnum.SearchActorsModal + "486"')

,(N'FieldLabelResourceKeyConstants', N'StreetFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "257"')
,(N'FieldLabelResourceKeyConstants', N'SyndromicSurveillanceFieldLabel', N'InterfaceEditorResourceSetEnum.DiseasesReferenceEditor + "368"')
,(N'FieldLabelResourceKeyConstants', N'TestCategoryFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "369"')
,(N'FieldLabelResourceKeyConstants', N'TestNameFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "370"')
,(N'FieldLabelResourceKeyConstants', N'TestResultsRelationsFieldLabel', N'InterfaceEditorResourceSetEnum.TestTestResultMatrix + "269"')
,(N'FieldLabelResourceKeyConstants', N'TestResultFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "371"')
,(N'FieldLabelResourceKeyConstants', N'UniqueOrganizationIDFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "272"')
,(N'FieldLabelResourceKeyConstants', N'UpperBoundFieldLabel', N'InterfaceEditorResourceSetEnum.AddAgeGroupModal + "372"')
,(N'FieldLabelResourceKeyConstants', N'UserNameFieldLabel', N'InterfaceEditorResourceSetEnum.Login + "275"')
,(N'FieldLabelResourceKeyConstants', N'UsingTypeFieldLabel', N'InterfaceEditorResourceSetEnum.DiseasesReferenceEditor + "373"')
,(N'FieldLabelResourceKeyConstants', N'VectorTypeFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "374"')
,(N'FieldLabelResourceKeyConstants', N'VersionNameFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "279"')
,(N'FieldLabelResourceKeyConstants', N'YesFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "375"')
,(N'FieldLabelResourceKeyConstants', N'ZoonoticDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.DiseasesReferenceEditor + "376"')
,(N'FieldLabelResourceKeyConstants', N'CommonLabelsUnknownFieldLabel', N'InterfaceEditorResourceSetEnum.CommonLabels + "2786"')

--        //SAUC01 and SAUC02 - Enter and Edit Employee Record
,(N'FieldLabelResourceKeyConstants', N'AccountIsDisabledFieldLabel', N'InterfaceEditorResourceSetEnum.Employees + "571"')

,(N'FieldLabelResourceKeyConstants', N'EmployeeCategoryFieldLabel', N'InterfaceEditorResourceSetEnum.Employees + "559"')
,(N'FieldLabelResourceKeyConstants', N'EmployeeFirstNameFieldLabel', N'InterfaceEditorResourceSetEnum.Employees + "402"')
,(N'FieldLabelResourceKeyConstants', N'EmployeeLastNameFieldLabel', N'InterfaceEditorResourceSetEnum.Employees + "414"')
,(N'FieldLabelResourceKeyConstants', N'EmployeeMiddleNameFieldLabel', N'InterfaceEditorResourceSetEnum.Employees + "416"')
,(N'FieldLabelResourceKeyConstants', N'EmployeeOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.Employees + "423"')
,(N'FieldLabelResourceKeyConstants', N'ConfirmPasswordFieldLabel', N'InterfaceEditorResourceSetEnum.Employees + "566"')
,(N'FieldLabelResourceKeyConstants', N'DepartmentFieldLabel', N'InterfaceEditorResourceSetEnum.Employees + "563"')
,(N'FieldLabelResourceKeyConstants', N'OrganizationDefaultFieldLabel', N'InterfaceEditorResourceSetEnum.Employees + "561"')
,(N'FieldLabelResourceKeyConstants', N'PersonalIDFieldLabel', N'InterfaceEditorResourceSetEnum.Employees + "560"')
,(N'FieldLabelResourceKeyConstants', N'PositionFieldLabel', N'InterfaceEditorResourceSetEnum.Employees + "564"')
,(N'FieldLabelResourceKeyConstants', N'ReasonFieldLabel', N'InterfaceEditorResourceSetEnum.Employees + "572"')
,(N'FieldLabelResourceKeyConstants', N'SiteIDDefaultFieldLabel', N'InterfaceEditorResourceSetEnum.Employees + "562"')
,(N'FieldLabelResourceKeyConstants', N'SiteIDFieldLabel', N'InterfaceEditorResourceSetEnum.Employees + "587"')
,(N'FieldLabelResourceKeyConstants', N'StatusFieldLabel', N'InterfaceEditorResourceSetEnum.Employees + "575"')
,(N'FieldLabelResourceKeyConstants', N'EmployeeLockedFieldLabel', N'InterfaceEditorResourceSetEnum.Employees + "570"')
,(N'FieldLabelResourceKeyConstants', N'UserGroupFieldLabel', N'InterfaceEditorResourceSetEnum.Employees + "574"')
,(N'FieldLabelResourceKeyConstants', N'UserMustChangePasswordAtNextLoginFieldLabel', N'InterfaceEditorResourceSetEnum.Employees + "567"')

--        //SAUC03 - Search Employee Record
,(N'FieldLabelResourceKeyConstants', N'SearchEmployeeAccountStateFieldLabel', N'InterfaceEditorResourceSetEnum.SearchEmployees + "655"')

,(N'FieldLabelResourceKeyConstants', N'SearchEmployeeEmployeeCategoryFieldLabel', N'InterfaceEditorResourceSetEnum.SearchEmployees + "559"')
,(N'FieldLabelResourceKeyConstants', N'SearchEmployeeFirstNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchEmployees + "402"')
,(N'FieldLabelResourceKeyConstants', N'SearchEmployeeLastNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchEmployees + "414"')
,(N'FieldLabelResourceKeyConstants', N'SearchEmployeePhoneFieldLabel', N'InterfaceEditorResourceSetEnum.SearchEmployees + "206"')
,(N'FieldLabelResourceKeyConstants', N'SearchEmployeePositionFieldLabel', N'InterfaceEditorResourceSetEnum.SearchEmployees + "564"')
,(N'FieldLabelResourceKeyConstants', N'SearchEmployeeMiddleNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchEmployees + "416"')

--        //SAUC07 - Search Organization Record
,(N'FieldLabelResourceKeyConstants', N'SearchOrganizationOrganizationTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchOrganizations + "157"')

,(N'FieldLabelResourceKeyConstants', N'SearchOrganizationSpecializationFieldLabel', N'InterfaceEditorResourceSetEnum.SearchOrganizations + "253"')

--        //SAUC09 and SAUC10 - Enter and Edit Administrative Unit Record
,(N'FieldLabelResourceKeyConstants', N'AdministrativeUnitDetailsUniqueCodeFieldLabel', N'InterfaceEditorResourceSetEnum.AdministrativeUnitDetails + "2739"')

,(N'FieldLabelResourceKeyConstants', N'AdministrativeUnitDetailsDefaultNameFieldLabel', N'InterfaceEditorResourceSetEnum.AdministrativeUnitDetails + "56"')
,(N'FieldLabelResourceKeyConstants', N'AdministrativeUnitDetailsNationalNameFieldLabel', N'InterfaceEditorResourceSetEnum.AdministrativeUnitDetails + "139"')
,(N'FieldLabelResourceKeyConstants', N'AdministrativeUnitDetailsAdministrativeLevelFieldLabel', N'InterfaceEditorResourceSetEnum.AdministrativeUnitDetails + "943"')
,(N'FieldLabelResourceKeyConstants', N'AdministrativeUnitDetailsSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.AdministrativeUnitDetails + "249"')
,(N'FieldLabelResourceKeyConstants', N'AdministrativeUnitDetailsAdministrativeLevel0FieldLabel', N'InterfaceEditorResourceSetEnum.AdministrativeUnitDetails + "47"')
,(N'FieldLabelResourceKeyConstants', N'AdministrativeUnitDetailsAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.AdministrativeUnitDetails + "428"')
,(N'FieldLabelResourceKeyConstants', N'AdministrativeUnitDetailsAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.AdministrativeUnitDetails + "426"')
,(N'FieldLabelResourceKeyConstants', N'AdministrativeUnitDetailsAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.AdministrativeUnitDetails + "248"')
,(N'FieldLabelResourceKeyConstants', N'AdministrativeUnitDetailsAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.AdministrativeUnitDetails + "949"')
,(N'FieldLabelResourceKeyConstants', N'AdministrativeUnitDetailsAdministrativeLevel5FieldLabel', N'InterfaceEditorResourceSetEnum.AdministrativeUnitDetails + "950"')
,(N'FieldLabelResourceKeyConstants', N'AdministrativeUnitDetailsAdministrativeLevel6FieldLabel', N'InterfaceEditorResourceSetEnum.AdministrativeUnitDetails + "951"')
,(N'FieldLabelResourceKeyConstants', N'AdministrativeUnitDetailsLatitudeFieldLabel', N'InterfaceEditorResourceSetEnum.AdministrativeUnitDetails + "2418"')
,(N'FieldLabelResourceKeyConstants', N'AdministrativeUnitDetailsLongitudeFieldLabel', N'InterfaceEditorResourceSetEnum.AdministrativeUnitDetails + "2419"')
,(N'FieldLabelResourceKeyConstants', N'AdministrativeUnitDetailsElevationFieldLabel', N'InterfaceEditorResourceSetEnum.AdministrativeUnitDetails + "2420"')
,(N'FieldLabelResourceKeyConstants', N'AdministrativeUnitDetailsHASCCodeFieldLabel', N'InterfaceEditorResourceSetEnum.AdministrativeUnitDetails + "4594"')

--        //SAUC11 - Search Administrative Unit Record
,(N'FieldLabelResourceKeyConstants', N'SearchAdministrativeUnitsDefaultNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "56"')

,(N'FieldLabelResourceKeyConstants', N'SearchAdministrativeUnitsNationalNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "139"')
,(N'FieldLabelResourceKeyConstants', N'SearchAdministrativeUnitsAdministrativeLevelFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "943"')
,(N'FieldLabelResourceKeyConstants', N'SearchAdministrativeUnitsAdministrativeLevel0FieldLabel', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "47"')
,(N'FieldLabelResourceKeyConstants', N'SearchAdministrativeUnitsAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "428"')
,(N'FieldLabelResourceKeyConstants', N'SearchAdministrativeUnitsAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "426"')
,(N'FieldLabelResourceKeyConstants', N'SearchAdministrativeUnitsAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "248"')
,(N'FieldLabelResourceKeyConstants', N'SearchAdministrativeUnitsAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "949"')
,(N'FieldLabelResourceKeyConstants', N'SearchAdministrativeUnitsAdministrativeLevel5FieldLabel', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "950"')
,(N'FieldLabelResourceKeyConstants', N'SearchAdministrativeUnitsAdministrativeLevel6FieldLabel', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "951"')
,(N'FieldLabelResourceKeyConstants', N'SearchAdministrativeUnitsSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "249"')
,(N'FieldLabelResourceKeyConstants', N'SearchAdministrativeUnitsLatitudeFromFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "314"')
,(N'FieldLabelResourceKeyConstants', N'SearchAdministrativeUnitsLatitudeToFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "1839"')
,(N'FieldLabelResourceKeyConstants', N'SearchAdministrativeUnitsLongitudeFromFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "2728"')
,(N'FieldLabelResourceKeyConstants', N'SearchAdministrativeUnitsLongitudeToFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "2729"')
,(N'FieldLabelResourceKeyConstants', N'SearchAdministrativeUnitsElevationFromFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "2730"')
,(N'FieldLabelResourceKeyConstants', N'SearchAdministrativeUnitsElevationToFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAdministrativeUnits + "2731"')

--        //SAUC13 - Enter Statistical Data Record and SAUC14 - Edit Statistical Data Record
,(N'FieldLabelResourceKeyConstants', N'StatisticalDataDetailsStatisticalDataTypeFieldLabel', N'InterfaceEditorResourceSetEnum.StatisticalDataDetails + "2691"')

,(N'FieldLabelResourceKeyConstants', N'StatisticalDataDetailsStatisticalPeriodTypeFieldLabel', N'InterfaceEditorResourceSetEnum.StatisticalDataDetails + "2692"')
,(N'FieldLabelResourceKeyConstants', N'StatisticalDataDetailsStartDateForPeriodFieldLabel', N'InterfaceEditorResourceSetEnum.StatisticalDataDetails + "2693"')
,(N'FieldLabelResourceKeyConstants', N'StatisticalDataStatisticalAreaTypeFieldLabel', N'InterfaceEditorResourceSetEnum.StatisticalDataDetails + "2694"')
,(N'FieldLabelResourceKeyConstants', N'StatisticalDataDetailsAdministrativeLevel0FieldLabel', N'InterfaceEditorResourceSetEnum.StatisticalDataDetails + "47"')
,(N'FieldLabelResourceKeyConstants', N'StatisticalDataDetailsAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.StatisticalDataDetails + "428"')
,(N'FieldLabelResourceKeyConstants', N'StatisticalDataDetailsAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.StatisticalDataDetails + "426"')
,(N'FieldLabelResourceKeyConstants', N'StatisticalDataDetailsAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.StatisticalDataDetails + "248"')
,(N'FieldLabelResourceKeyConstants', N'StatisticalDataDetailsAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.StatisticalDataDetails + "949"')
,(N'FieldLabelResourceKeyConstants', N'StatisticalDateDetailsStatisticalAgeGroupFieldLabel', N'InterfaceEditorResourceSetEnum.StatisticalDataDetails + "367"')
,(N'FieldLabelResourceKeyConstants', N'StatisticalDataDetailsParameterTypeFieldLabel', N'InterfaceEditorResourceSetEnum.StatisticalDataDetails + "2695"')
,(N'FieldLabelResourceKeyConstants', N'StatisticalDataDetailsParameterFieldLabel', N'InterfaceEditorResourceSetEnum.StatisticalDataDetails + "197"')
,(N'FieldLabelResourceKeyConstants', N'StatisticalDataDetailsValueFieldLabel', N'InterfaceEditorResourceSetEnum.StatisticalDataDetails + "2696"')

--        //SAUC13 -1 - Load Statistical Data
,(N'FieldLabelResourceKeyConstants', N'StatisticalDataDateofdataimportFieldLabel', N'InterfaceEditorResourceSetEnum.StatisticalData + "3464"')

,(N'FieldLabelResourceKeyConstants', N'StatisticalDataNameofuserwhoinitiateddataimportFieldLabel', N'InterfaceEditorResourceSetEnum.StatisticalData + "3465"')
,(N'FieldLabelResourceKeyConstants', N'StatisticalData_actualnumberofimportedrecords_of_numberofrecordsontheimportfile_recordswereimportedFieldLabel', N'InterfaceEditorResourceSetEnum.StatisticalData + "3466"')
,(N'FieldLabelResourceKeyConstants', N'StatisticalDataDescriptionofStatisticalDataImportFieldLabel', N'InterfaceEditorResourceSetEnum.StatisticalData + "3467"')
,(N'FieldLabelResourceKeyConstants', N'StatisticalDataDateFieldLabel', N'InterfaceEditorResourceSetEnum.StatisticalData + "763"')
,(N'FieldLabelResourceKeyConstants', N'StatisticalDataUsernameFieldLabel', N'InterfaceEditorResourceSetEnum.StatisticalData + "2667"')
,(N'FieldLabelResourceKeyConstants', N'StatisticalDataInformationFieldLabel', N'InterfaceEditorResourceSetEnum.StatisticalData + "3192"')
,(N'FieldLabelResourceKeyConstants', N'StatisticalDataNotesFieldLabel', N'InterfaceEditorResourceSetEnum.StatisticalData + "973"')

--        //SAUC17 - Interface Editor
,(N'FieldLabelResourceKeyConstants', N'InterfaceEditorRequiredFieldLabel', N'InterfaceEditorResourceSetEnum.InterfaceEditor + "918"')

,(N'FieldLabelResourceKeyConstants', N'InterfaceEditorHiddenFieldLabel', N'InterfaceEditorResourceSetEnum.InterfaceEditor + "919"')
,(N'FieldLabelResourceKeyConstants', N'InterfaceEditorAddaLanguageFileFieldLabel', N'InterfaceEditorResourceSetEnum.InterfaceEditor + "920"')
,(N'FieldLabelResourceKeyConstants', N'InterfaceEditorLanguageFieldLabel', N'InterfaceEditorResourceSetEnum.InterfaceEditor + "413"')
,(N'FieldLabelResourceKeyConstants', N'InterfaceEditorEnteralanguagenameFieldLabel', N'InterfaceEditorResourceSetEnum.InterfaceEditor + "922"')
,(N'FieldLabelResourceKeyConstants', N'InterfaceEditorChooseafileFieldLabel', N'InterfaceEditorResourceSetEnum.InterfaceEditor + "923"')
,(N'FieldLabelResourceKeyConstants', N'InterfaceEditorUploadFileFieldLabel', N'InterfaceEditorResourceSetEnum.InterfaceEditor + "924"')
,(N'FieldLabelResourceKeyConstants', N'InterfaceEditorAllModulesFieldLabel', N'InterfaceEditorResourceSetEnum.InterfaceEditor + "925"')
,(N'FieldLabelResourceKeyConstants', N'InterfaceEditorSearchwithinmoduleFieldLabel', N'InterfaceEditorResourceSetEnum.InterfaceEditor + "926"')
,(N'FieldLabelResourceKeyConstants', N'InterfaceEditorTypeFieldLabel', N'InterfaceEditorResourceSetEnum.InterfaceEditor + "201"')
,(N'FieldLabelResourceKeyConstants', N'InterfaceEditorModuleFieldLabel', N'InterfaceEditorResourceSetEnum.InterfaceEditor + "4797"')
,(N'FieldLabelResourceKeyConstants', N'InterfaceEditorSectionFieldLabel', N'InterfaceEditorResourceSetEnum.InterfaceEditor + "245"')

--        //fix for localization 10/20/2023
,(N'FieldLabelResourceKeyConstants', N'InterfaceEditorDownloadTemplateFieldLabel', N'InterfaceEditorResourceSetEnum.InterfaceEditor + "4818"')
,(N'FieldLabelResourceKeyConstants', N'InterfaceEditorUploadFieldLabel', N'InterfaceEditorResourceSetEnum.InterfaceEditor + "4819"')

--        //SAUC30 - Restore a Data Audit Log Transaction
,(N'FieldLabelResourceKeyConstants', N'DataAuditLogDetailsObjectTypeFieldLabel', N'InterfaceEditorResourceSetEnum.DataAuditLogDetails + "3595"')

,(N'FieldLabelResourceKeyConstants', N'DataAuditLogDetailsTableNameFieldLabel', N'InterfaceEditorResourceSetEnum.DataAuditLogDetails + "3596"')
,(N'FieldLabelResourceKeyConstants', N'DataAuditLogDetailsTransactionDateFieldLabel', N'InterfaceEditorResourceSetEnum.DataAuditLogDetails + "3597"')
,(N'FieldLabelResourceKeyConstants', N'DataAuditLogDetailsActionFieldLabel', N'InterfaceEditorResourceSetEnum.DataAuditLogDetails + "514"')
,(N'FieldLabelResourceKeyConstants', N'DataAuditLogDetailsObjectIDFieldLabel', N'InterfaceEditorResourceSetEnum.DataAuditLogDetails + "3598"')
,(N'FieldLabelResourceKeyConstants', N'DataAuditLogDetailsSiteIDFieldLabel', N'InterfaceEditorResourceSetEnum.DataAuditLogDetails + "587"')
,(N'FieldLabelResourceKeyConstants', N'DataAuditLogDetailsUserFieldLabel', N'InterfaceEditorResourceSetEnum.DataAuditLogDetails + "3599"')

--        //SAUC31 - Search for a Data Audit Log Transaction
,(N'FieldLabelResourceKeyConstants', N'SearchDataAuditLogTransactionDateFromFieldLabel', N'InterfaceEditorResourceSetEnum.SearchDataAuditLog + "3008"')

,(N'FieldLabelResourceKeyConstants', N'SearchDataAuditLogTransactionDateToFieldLabel', N'InterfaceEditorResourceSetEnum.SearchDataAuditLog + "3009"')
,(N'FieldLabelResourceKeyConstants', N'SearchDataAuditLogSiteFieldLabel', N'InterfaceEditorResourceSetEnum.SearchDataAuditLog + "549"')
,(N'FieldLabelResourceKeyConstants', N'SearchDataAuditLogUserFieldLabel', N'InterfaceEditorResourceSetEnum.SearchDataAuditLog + "3599"')
,(N'FieldLabelResourceKeyConstants', N'SearchDataAuditLogActionFieldLabel', N'InterfaceEditorResourceSetEnum.SearchDataAuditLog + "514"')
,(N'FieldLabelResourceKeyConstants', N'SearchDataAuditLogObjectTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchDataAuditLog + "3595"')
,(N'FieldLabelResourceKeyConstants', N'SearchDataAuditLogObjectIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchDataAuditLog + "3598"')

--        //SAUC32 - User Search for Data Audit Log Transactions
,(N'FieldLabelResourceKeyConstants', N'SearchUserDataAuditLogTransactionDateFromFieldLabel', N'InterfaceEditorResourceSetEnum.SearchUserDataAuditLog + "3008"')

,(N'FieldLabelResourceKeyConstants', N'SearchUserDataAuditLogTransactionDateToFieldLabel', N'InterfaceEditorResourceSetEnum.SearchUserDataAuditLog + "3009"')
,(N'FieldLabelResourceKeyConstants', N'SearchUserDataAuditLogObjectTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchUserDataAuditLog + "3595"')
,(N'FieldLabelResourceKeyConstants', N'SearchUserDataAuditLogEIDSSIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchUserDataAuditLog + "3015"')
,(N'FieldLabelResourceKeyConstants', N'SearchUserDataAuditLogSiteNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchUserDataAuditLog + "651"')
,(N'FieldLabelResourceKeyConstants', N'SearchUserDataAuditLogTransactionDatesFieldLabel', N'InterfaceEditorResourceSetEnum.SearchUserDataAuditLog + "3017"')

--        //SAUC51 - Security Policy
,(N'FieldLabelResourceKeyConstants', N'SecurityPolicyPasswordsMustBeAtLeastXCharactersFieldLabel', N'InterfaceEditorResourceSetEnum.SecurityPolicy + "4789"')

,(N'FieldLabelResourceKeyConstants', N'SecurityPolicyPasswordsMustHaveAtLeastOneLowerCaseaTozFieldLabel', N'InterfaceEditorResourceSetEnum.SecurityPolicy + "4790"')
,(N'FieldLabelResourceKeyConstants', N'SecurityPolicyPasswordsMustHaveAtLeastOneUpperCaseAToZFieldLabel', N'InterfaceEditorResourceSetEnum.SecurityPolicy + "4791"')
,(N'FieldLabelResourceKeyConstants', N'SecurityPolicyPasswordsMustHaveAtLeastOneSpecialCharXFieldLabel', N'InterfaceEditorResourceSetEnum.SecurityPolicy + "4792"')
,(N'FieldLabelResourceKeyConstants', N'SecurityPolicyPasswordsMustNotContainXSequentialCharactersFieldLabel', N'InterfaceEditorResourceSetEnum.SecurityPolicy + "4793"')
,(N'FieldLabelResourceKeyConstants', N'SecurityPolicyPasswordsMustNotSpaceFieldLabel', N'InterfaceEditorResourceSetEnum.SecurityPolicy + "4794"')
,(N'FieldLabelResourceKeyConstants', N'SecurityPolicyPreventUseOfTheUserNameAsThePasswordFieldLabel', N'InterfaceEditorResourceSetEnum.SecurityPolicy + "4795"')
,(N'FieldLabelResourceKeyConstants', N'SecurityPolicyPasswordsMustHaveAtLeastOneDigit0To9FieldLabel', N'InterfaceEditorResourceSetEnum.SecurityPolicy + "4796"')

--        //SAUC60 - System Event Log
,(N'FieldLabelResourceKeyConstants', N'SystemEventsLogDescriptionFieldLabel', N'InterfaceEditorResourceSetEnum.SystemEventsLog + "486"')

,(N'FieldLabelResourceKeyConstants', N'SystemEventsLogTransactionDateFromFieldLabel', N'InterfaceEditorResourceSetEnum.SystemEventsLog + "3008"')
,(N'FieldLabelResourceKeyConstants', N'SystemEventsLogTransactionDateToFieldLabel', N'InterfaceEditorResourceSetEnum.SystemEventsLog + "3009"')
,(N'FieldLabelResourceKeyConstants', N'SystemEventsLogUserFieldLabel', N'InterfaceEditorResourceSetEnum.SystemEventsLog + "3599"')
,(N'FieldLabelResourceKeyConstants', N'SystemEventsLogActionFieldLabel', N'InterfaceEditorResourceSetEnum.SystemEventsLog + "514"')
,(N'FieldLabelResourceKeyConstants', N'SystemEventsLogResultFieldLabel', N'InterfaceEditorResourceSetEnum.SystemEventsLog + "1431"')
,(N'FieldLabelResourceKeyConstants', N'SystemEventsLogObjectIDFieldLabel', N'InterfaceEditorResourceSetEnum.SystemEventsLog + "3598"')
,(N'FieldLabelResourceKeyConstants', N'SystemEventsLogProcessTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SystemEventsLog + "4238"')
,(N'FieldLabelResourceKeyConstants', N'SystemEventsLogErrorTextFieldLabel', N'InterfaceEditorResourceSetEnum.SystemEventsLog + "4239"')
,(N'FieldLabelResourceKeyConstants', N'SystemEventsLogProcessIDFieldLabel', N'InterfaceEditorResourceSetEnum.SystemEventsLog + "4240"')

--        //SAUC61 - Security Event Log
,(N'FieldLabelResourceKeyConstants', N'SecurityEventsLogDescriptionFieldLabel', N'InterfaceEditorResourceSetEnum.SecurityEventsLog + "486"')

,(N'FieldLabelResourceKeyConstants', N'SecurityEventsLogTransactionDateFromFieldLabel', N'InterfaceEditorResourceSetEnum.SecurityEventsLog + "3008"')
,(N'FieldLabelResourceKeyConstants', N'SecurityEventsLogTransactionDateToFieldLabel', N'InterfaceEditorResourceSetEnum.SecurityEventsLog + "3009"')
,(N'FieldLabelResourceKeyConstants', N'SecurityEventsLogUserFieldLabel', N'InterfaceEditorResourceSetEnum.SecurityEventsLog + "3599"')
,(N'FieldLabelResourceKeyConstants', N'SecurityEventsLogActionFieldLabel', N'InterfaceEditorResourceSetEnum.SecurityEventsLog + "514"')
,(N'FieldLabelResourceKeyConstants', N'SecurityEventsLogResultFieldLabel', N'InterfaceEditorResourceSetEnum.SecurityEventsLog + "1431"')
,(N'FieldLabelResourceKeyConstants', N'SecurityEventsLogObjectIDFieldLabel', N'InterfaceEditorResourceSetEnum.SecurityEventsLog + "3598"')
,(N'FieldLabelResourceKeyConstants', N'SecurityEventsLogProcessTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SecurityEventsLog + "4238"')
,(N'FieldLabelResourceKeyConstants', N'SecurityEventsLogErrorTextFieldLabel', N'InterfaceEditorResourceSetEnum.SecurityEventsLog + "4239"')
,(N'FieldLabelResourceKeyConstants', N'SecurityEventsLogProcessIDFieldLabel', N'InterfaceEditorResourceSetEnum.SecurityEventsLog + "4240"')

--region Security Sub-Module Resources

--        //SAUC25 - Search for a User Group
,(N'FieldLabelResourceKeyConstants', N'SearchUserGroupsDescriptionFieldLabel', N'InterfaceEditorResourceSetEnum.SearchUserGroups + "486"')

,(N'FieldLabelResourceKeyConstants', N'SearchUserGroupsGroupFieldLabel', N'InterfaceEditorResourceSetEnum.SearchUserGroups + "607"')
,(N'FieldLabelResourceKeyConstants', N'SearchUserGroupsYoucanselectuptosixiconsFieldLabel', N'InterfaceEditorResourceSetEnum.SearchUserGroups + "3918"')

--        //SAUC26 and 27 - Enter and Edit a User Group
,(N'FieldLabelResourceKeyConstants', N'UserGroupDetailsDefaultNameFieldLabel', N'InterfaceEditorResourceSetEnum.UserGroupDetails + "56"')

,(N'FieldLabelResourceKeyConstants', N'UserGroupDetailsDescriptionFieldLabel', N'InterfaceEditorResourceSetEnum.UserGroupDetails + "486"')
,(N'FieldLabelResourceKeyConstants', N'UserGroupDetailsNationalNameFieldLabel', N'InterfaceEditorResourceSetEnum.UserGroupDetails + "139"')

,(N'FieldLabelResourceKeyConstants', N'SearchUsersAndUserGroupsDescriptionFieldLabel', N'InterfaceEditorResourceSetEnum.SearchUsersAndUserGroupsModal + "486"')
,(N'FieldLabelResourceKeyConstants', N'SearchUsersAndUserGroupsEmployeeTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchUsersAndUserGroupsModal + "201"')
,(N'FieldLabelResourceKeyConstants', N'SearchUsersAndUserGroupsNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchUsersAndUserGroupsModal + "608"')
,(N'FieldLabelResourceKeyConstants', N'SearchUsersAndUserGroupsOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.SearchUsersAndUserGroupsModal + "423"')
,(N'FieldLabelResourceKeyConstants', N'SearchUsersAndUserGroupsTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchUsersAndUserGroupsModal + "626"')
,(N'FieldLabelResourceKeyConstants', N'UserGroupDetailsYoucanselectuptosixiconsFieldLabel', N'InterfaceEditorResourceSetEnum.UserGroupDetails + "3919"')

--        //SAUC51 - Security Policy
,(N'FieldLabelResourceKeyConstants', N'SecurityPolicy_MinimumPasswordLength_FieldLabel', N'InterfaceEditorResourceSetEnum.SecurityPolicy + "708"')

,(N'FieldLabelResourceKeyConstants', N'SecurityPolicy_EnforcePasswordHistory_FieldLabel', N'InterfaceEditorResourceSetEnum.SecurityPolicy + "709"')
,(N'FieldLabelResourceKeyConstants', N'SecurityPolicy_MinimumPasswordAgeDays_FieldLabel', N'InterfaceEditorResourceSetEnum.SecurityPolicy + "710"')
,(N'FieldLabelResourceKeyConstants', N'SecurityPolicy_ForceUpperCaseCharacters_FieldLabel', N'InterfaceEditorResourceSetEnum.SecurityPolicy + "711"')
,(N'FieldLabelResourceKeyConstants', N'SecurityPolicy_ForceLowerCaseCharacters_FieldLabel', N'InterfaceEditorResourceSetEnum.SecurityPolicy + "713"')
,(N'FieldLabelResourceKeyConstants', N'SecurityPolicy_ForceNumbers_FieldLabel', N'InterfaceEditorResourceSetEnum.SecurityPolicy + "712"')
,(N'FieldLabelResourceKeyConstants', N'SecurityPolicy_ForceSpecialCharacters_FieldLabel', N'InterfaceEditorResourceSetEnum.SecurityPolicy + "714"')
,(N'FieldLabelResourceKeyConstants', N'SecurityPolicy_AllowUseOfSpace_FieldLabel', N'InterfaceEditorResourceSetEnum.SecurityPolicy + "715"')
,(N'FieldLabelResourceKeyConstants', N'SecurityPolicy_PreventSequentialCharacters_FieldLabel', N'InterfaceEditorResourceSetEnum.SecurityPolicy + "716"')
,(N'FieldLabelResourceKeyConstants', N'SecurityPolicy_PreventUseOfTheUsernameAsThePassword_FieldLabel', N'InterfaceEditorResourceSetEnum.SecurityPolicy + "717"')
,(N'FieldLabelResourceKeyConstants', N'SecurityPolicy_AccountLockoutThreshold_FieldLabel', N'InterfaceEditorResourceSetEnum.SecurityPolicy + "719"')
,(N'FieldLabelResourceKeyConstants', N'SecurityPolicy_SessionInactivityTimeoutMinutes_FieldLabel', N'InterfaceEditorResourceSetEnum.SecurityPolicy + "720"')
,(N'FieldLabelResourceKeyConstants', N'SecurityPolicy_SessionMaximumLengthHours_FieldLabel', N'InterfaceEditorResourceSetEnum.SecurityPolicy + "721"')
,(N'FieldLabelResourceKeyConstants', N'SecurityPolicy_DisplaySessionInactivityTimeoutWarningMinutes_FieldLabel', N'InterfaceEditorResourceSetEnum.SecurityPolicy + "722"')
,(N'FieldLabelResourceKeyConstants', N'SecurityPolicy_DisplaySessionCloseoutWarningMinutes_FieldLabel', N'InterfaceEditorResourceSetEnum.SecurityPolicy + "723"')

--        //SAUC53 - Sites and Site Groups Management
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchSitesSiteIDFieldLabel', N'"587"')

,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchSitesSiteCodeFieldLabel', N'"629"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchSitesSiteNameFieldLabel', N'"651"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchSitesSiteTypeFieldLabel', N'"630"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchSitesHASCSiteIDFieldLabel', N'"631"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchSitesOrganizationFieldLabel', N'"423"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchSitesCountryFieldLabel', N'"47"')

,(N'FieldLabelResourceKeyConstants', N'SearchSitesSiteIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchSites + "587"')
,(N'FieldLabelResourceKeyConstants', N'SearchSitesSiteCodeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchSites + "629"')
,(N'FieldLabelResourceKeyConstants', N'SearchSitesSiteNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchSites + "651"')
,(N'FieldLabelResourceKeyConstants', N'SearchSitesSiteTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchSites + "630"')
,(N'FieldLabelResourceKeyConstants', N'SearchSitesHASCSiteIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchSites + "631"')
,(N'FieldLabelResourceKeyConstants', N'SearchSitesOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.SearchSites + "423"')
,(N'FieldLabelResourceKeyConstants', N'SearchSitesCountryFieldLabel', N'InterfaceEditorResourceSetEnum.SearchSites + "47"')

,(N'FieldLabelResourceKeyConstants', N'SearchSitesModalSiteIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchSitesModal + "587"')
,(N'FieldLabelResourceKeyConstants', N'SearchSitesModalSiteCodeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchSitesModal + "629"')
,(N'FieldLabelResourceKeyConstants', N'SearchSitesModalSiteNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchSitesModal + "651"')
,(N'FieldLabelResourceKeyConstants', N'SearchSitesModalSiteTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchSitesModal + "630"')
,(N'FieldLabelResourceKeyConstants', N'SearchSitesModalHASCSiteIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchSitesModal + "631"')
,(N'FieldLabelResourceKeyConstants', N'SearchSitesModalOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.SearchSitesModal + "423"')
,(N'FieldLabelResourceKeyConstants', N'SearchSitesModalCountryFieldLabel', N'InterfaceEditorResourceSetEnum.SearchSitesModal + "47"')

,(N'FieldLabelResourceKeyConstants', N'SiteDetailsSiteIDFieldLabel', N'InterfaceEditorResourceSetEnum.SiteDetails + "587"')
,(N'FieldLabelResourceKeyConstants', N'SiteDetailsSiteCodeFieldLabel', N'InterfaceEditorResourceSetEnum.SiteDetails + "629"')
,(N'FieldLabelResourceKeyConstants', N'SiteDetailsSiteNameFieldLabel', N'InterfaceEditorResourceSetEnum.SiteDetails + "651"')
,(N'FieldLabelResourceKeyConstants', N'SiteDetailsSiteTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SiteDetails + "630"')
,(N'FieldLabelResourceKeyConstants', N'SiteDetailsParentSiteFieldLabel', N'InterfaceEditorResourceSetEnum.SiteDetails + "634"')
,(N'FieldLabelResourceKeyConstants', N'SiteDetailsHASCSiteIDFieldLabel', N'InterfaceEditorResourceSetEnum.SiteDetails + "631"')
,(N'FieldLabelResourceKeyConstants', N'SiteDetailsOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.SiteDetails + "423"')
,(N'FieldLabelResourceKeyConstants', N'SiteDetailsSiteActiveFieldLabel', N'InterfaceEditorResourceSetEnum.SiteDetails + "635"')

,(N'FieldLabelResourceKeyConstants', N'SearchSiteGroupsSiteGroupNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchSiteGroups + "641"')
,(N'FieldLabelResourceKeyConstants', N'SearchSiteGroupsSiteGroupTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchSiteGroups + "642"')
,(N'FieldLabelResourceKeyConstants', N'SearchSiteGroupsAdministrativeLevel2NameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchSiteGroups + "428"')
,(N'FieldLabelResourceKeyConstants', N'SearchSiteGroupsAdministrativeLevel3NameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchSiteGroups + "426"')

,(N'FieldLabelResourceKeyConstants', N'SiteGroupDetailsSiteGroupIDFieldLabel', N'InterfaceEditorResourceSetEnum.SiteGroupDetails + "643"')
,(N'FieldLabelResourceKeyConstants', N'SiteGroupDetailsSiteGroupNameFieldLabel', N'InterfaceEditorResourceSetEnum.SiteGroupDetails + "641"')
,(N'FieldLabelResourceKeyConstants', N'SiteGroupDetailsSiteGroupTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SiteGroupDetails + "642"')
,(N'FieldLabelResourceKeyConstants', N'SiteGroupDetailsDescriptionFieldLabel', N'InterfaceEditorResourceSetEnum.SiteGroupDetails + "486"')
,(N'FieldLabelResourceKeyConstants', N'SiteGroupDetailsCentralSiteFieldLabel', N'InterfaceEditorResourceSetEnum.SiteGroupDetails + "647"')
,(N'FieldLabelResourceKeyConstants', N'SiteGroupDetailsAdministrativeLevel3NameFieldLabel', N'InterfaceEditorResourceSetEnum.SiteGroupDetails + "426"')
,(N'FieldLabelResourceKeyConstants', N'SiteGroupDetailsSiteGroupActiveFieldLabel', N'InterfaceEditorResourceSetEnum.SiteGroupDetails + "648"')
,(N'FieldLabelResourceKeyConstants', N'SiteGroupDetailsSitesFieldLabel', N'InterfaceEditorResourceSetEnum.SiteGroupDetails + "649"')

--        //Configurable Filtration
,(N'FieldLabelResourceKeyConstants', N'SearchAccessRulesAccessRuleIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAccessRules + "466"')

,(N'FieldLabelResourceKeyConstants', N'SearchAccessRulesAccessRuleNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAccessRules + "467"')
,(N'FieldLabelResourceKeyConstants', N'SearchAccessRulesAccessToGenderAndAgeDataPermissionIndicatorFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAccessRules + "10"')
,(N'FieldLabelResourceKeyConstants', N'SearchAccessRulesAccessToPersonalDataPermissionIndicatorFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAccessRules + "11"')
,(N'FieldLabelResourceKeyConstants', N'SearchAccessRulesBorderingAreaRuleFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAccessRules + "473"')
,(N'FieldLabelResourceKeyConstants', N'SearchAccessRulesCreatePermissionIndicatorFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAccessRules + "2927"')
,(N'FieldLabelResourceKeyConstants', N'SearchAccessRulesDefaultRuleFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAccessRules + "480"')
,(N'FieldLabelResourceKeyConstants', N'SearchAccessRulesDeletePermissionIndicatorFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAccessRules + "64"')
,(N'FieldLabelResourceKeyConstants', N'SearchAccessRulesGrantingActorSiteCodeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAccessRules + "89"')
,(N'FieldLabelResourceKeyConstants', N'SearchAccessRulesGrantingActorSiteHASCCodeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAccessRules + "90"')
,(N'FieldLabelResourceKeyConstants', N'SearchAccessRulesGrantingActorSiteNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAccessRules + "91"')
,(N'FieldLabelResourceKeyConstants', N'SearchAccessRulesReadPermissionIndicatorFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAccessRules + "212"')
,(N'FieldLabelResourceKeyConstants', N'SearchAccessRulesReceivingActorSiteCodeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAccessRules + "214"')
,(N'FieldLabelResourceKeyConstants', N'SearchAccessRulesReceivingActorSiteHASCCodeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAccessRules + "215"')
,(N'FieldLabelResourceKeyConstants', N'SearchAccessRulesReceivingActorSiteNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAccessRules + "216"')
,(N'FieldLabelResourceKeyConstants', N'SearchAccessRulesReciprocalRuleFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAccessRules + "362"')
,(N'FieldLabelResourceKeyConstants', N'SearchAccessRulesWritePermissionIndicatorFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAccessRules + "280"')

,(N'FieldLabelResourceKeyConstants', N'AccessRuleDetailsAccessRuleIDFieldLabel', N'InterfaceEditorResourceSetEnum.AccessRuleDetails + "466"')
,(N'FieldLabelResourceKeyConstants', N'AccessRuleDetailsAccessRuleNameFieldLabel', N'InterfaceEditorResourceSetEnum.AccessRuleDetails + "467"')
,(N'FieldLabelResourceKeyConstants', N'AccessRuleDetailsAccessToGenderAndAgeDataPermissionIndicatorFieldLabel', N'InterfaceEditorResourceSetEnum.AccessRuleDetails + "10"')
,(N'FieldLabelResourceKeyConstants', N'AccessRuleDetailsAccessToPersonalDataPermissionIndicatorFieldLabel', N'InterfaceEditorResourceSetEnum.AccessRuleDetails + "11"')
,(N'FieldLabelResourceKeyConstants', N'AccessRuleDetailsBorderingAreaRuleFieldLabel', N'InterfaceEditorResourceSetEnum.AccessRuleDetails + "473"')
,(N'FieldLabelResourceKeyConstants', N'AccessRuleDetailsCreatePermissionIndicatorFieldLabel', N'InterfaceEditorResourceSetEnum.AccessRuleDetails + "2927"')
,(N'FieldLabelResourceKeyConstants', N'AccessRuleDetailsDefaultRuleFieldLabel', N'InterfaceEditorResourceSetEnum.AccessRuleDetails + "480"')
,(N'FieldLabelResourceKeyConstants', N'AccessRuleDetailsDeletePermissionIndicatorFieldLabel', N'InterfaceEditorResourceSetEnum.AccessRuleDetails + "64"')
,(N'FieldLabelResourceKeyConstants', N'AccessRuleDetailsGrantingActorSiteCodeFieldLabel', N'InterfaceEditorResourceSetEnum.AccessRuleDetails + "89"')
,(N'FieldLabelResourceKeyConstants', N'AccessRuleDetailsGrantingActorSiteHASCCodeFieldLabel', N'InterfaceEditorResourceSetEnum.AccessRuleDetails + "90"')
,(N'FieldLabelResourceKeyConstants', N'AccessRuleDetailsGrantingActorSiteNameFieldLabel', N'InterfaceEditorResourceSetEnum.AccessRuleDetails + "91"')
,(N'FieldLabelResourceKeyConstants', N'AccessRuleDetailsReadPermissionIndicatorFieldLabel', N'InterfaceEditorResourceSetEnum.AccessRuleDetails + "212"')
,(N'FieldLabelResourceKeyConstants', N'AccessRuleDetailsReceivingActorSiteCodeFieldLabel', N'InterfaceEditorResourceSetEnum.AccessRuleDetails + "214"')
,(N'FieldLabelResourceKeyConstants', N'AccessRuleDetailsReceivingActorSiteHASCCodeFieldLabel', N'InterfaceEditorResourceSetEnum.AccessRuleDetails + "215"')
,(N'FieldLabelResourceKeyConstants', N'AccessRuleDetailsReceivingActorSiteNameFieldLabel', N'InterfaceEditorResourceSetEnum.AccessRuleDetails + "216"')
,(N'FieldLabelResourceKeyConstants', N'AccessRuleDetailsReciprocalRuleFieldLabel', N'InterfaceEditorResourceSetEnum.AccessRuleDetails + "362"')
,(N'FieldLabelResourceKeyConstants', N'AccessRuleDetailsWritePermissionIndicatorFieldLabel', N'InterfaceEditorResourceSetEnum.AccessRuleDetails + "280"')

--endregion Security Sub-Module Resources

--region Deduplication Sub-Module Resources

--        //DDUC02 - Human Disease Report Deduplication
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsReportIDFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "750"')

,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "71"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsReportStatusFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "1080"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsLastNameFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "414"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsFirstNameFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "402"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsMiddleNameFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "416"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "428"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "426"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsDateEnteredRangeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "811"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsCaseClassificationFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "387"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsHospitalizationFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "988"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsSentByFacilityFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "1862"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsReceivedByFacilityFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "1863"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsDataEntrySiteFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "1864"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsLocationOfExposureFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "1865"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsLocationOfExposureRegionFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "1866"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsLocationOfExposureRayonFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "1867"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsDateOfFinalCaseClassificationRangeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "1868"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsNotificationDateRangeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "1869"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsDateOfSymptomsOnsetRangeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "1870"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsDiagnosisDateRangeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "1871"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsLocalSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "1117"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchHumanDiseaseReportsOutcomeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchHumanDiseaseReports + "1077"')

--        //Notification Section
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportNotificationDateOfCompletionOfPaperFormFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportNotification + "1084"')

,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportNotificationLocalIdentifierFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportNotification + "1085"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportNotificationDateOfDiagnosisFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportNotification + "1086"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportNotificationDateOfNotificationFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportNotification + "1087"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportNotificationStatusOfPatientAtTimeOfNotificationFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportNotification + "1088"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportNotificationNotificationSentbyFacilityFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportNotification + "1089"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportNotificationNotificationSentbyNameFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportNotification + "1090"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportNotificationNotificationReceivedbyFacilityFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportNotification + "1091"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportNotificationNotificationReceivedbyNameFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportNotification + "1092"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportNotificationCurrentLocationOfPatientFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportNotification + "1093"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportNotificationHospitalNameFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportNotification + "1094"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportNotificationOtherLocationFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportNotification + "1095"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportNotificationDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportNotification + "71"')

--        //Clinical Information-Facility Details Section
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportFacilityDetailsPatientPreviouslySoughtCareForSimilarSymptomsFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportFacilityDetails + "1097"')

,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportFacilityDetailsFacilityPatientFirstSoughtCareFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportFacilityDetails + "1098"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportFacilityDetailsDatePatientFirstSoughtCareFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportFacilityDetails + "1099"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportFacilityDetailsNonNotifiableDiagnosisFromFacilityWherePatientFirstSoughtCareFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportFacilityDetails + "1100"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportFacilityDetailsHospitalizationFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportFacilityDetails + "1101"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportFacilityDetailsDateOfHospitalizationFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportFacilityDetails + "1103"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportFacilityDetailsDateOfDischargeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportFacilityDetails + "1104"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportFacilityDetailsHospitalNameFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportFacilityDetails + "1094"')

--        //Symptoms Section
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiesaseReportSymptomsDateOfSymptomsOnsetFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportSymptoms + "1096"')

,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiesaseReportSymptomsInitialCaseClassificationFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportSymptoms + "348"')

--        //Antibiotic/Vaccine History Section
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportAntibioticVaccineHistoryAntibioticAntiviralTherapyAdministeredFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportAntibioticVaccineHistory + "1105"')

,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportAntibioticVaccineHistoryWasSpecificVaccinationAdministeredFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportAntibioticVaccineHistory + "1106"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportAntibioticVaccineHistoryAdditionalInformationCommentsFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportAntibioticVaccineHistory + "1107"')

--        //Case Investigation Section
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationInvestigatingOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "1136"')

,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationStartDateOfInvestigationFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "1137"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationOutbreakIDFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "969"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationCommentsFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "874"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationLocationofExposureisknownFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "1138"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationDateOfPotentialExposureFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "1139"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationExposureLocationFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "1140"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationLocationOfExposureExactPointDescriptionFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "1786"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationLocationOfExposureExactPointAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "1787"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationLocationOfExposureExactPointAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "1788"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationLocationOfExposureExactPointAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "1789"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationLocationOfExposureExactPointSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "1790"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationLocationOfExposureExactPointAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "1791"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationLocationOfExposureExactPointLatitudeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "1792"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationLocationOfExposureExactPointLongitudeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "1793"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationLocationOfExposureExactPointElevationFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "1794"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationLocationOfExposureRelativePointDescriptionFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "1795"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationLocationOfExposureRelativePointAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "1796"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationLocationOfExposureRelativePointAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "1797"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationLocationOfExposureRelativePointAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "1798"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationLocationOfExposureRelativePointSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "1799"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationLocationOfExposureRelativePointAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "1800"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationLocationOfExposureRelativePointLatitudeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "1801"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationLocationOfExposureRelativePointLongitudeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "1802"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationLocationOfExposureRelativePointGroundTypeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "1803"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationLocationOfExposureRelativePointDistancekmFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "1804"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationLocationOfExposureRelativePointDirectionFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "1805"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationLocationOfExposureForeignAddressCountryFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "1806"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportCaseInvestigationLocationOfExposureForeignAddressAddressFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportCaseInvestigation + "1807"')

--        //Final Outcome Section
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportFinalOutcomeFinalCaseClassificationFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportFinalOutcome + "344"')

,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportFinalOutcomeDateOfFinalCaseClassificationFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportFinalOutcome + "1075"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportFinalOutcomeBasisOfDiagnosisFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportFinalOutcome + "1076"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportFinalOutcomeOutcomeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportFinalOutcome + "1077"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportFinalOutcomeDateOfDeathFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportFinalOutcome + "1078"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationHumanDiseaseReportFinalOutcomeEpidemiologistNameFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationHumanDiseaseReportFinalOutcome + "1079"')

,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportDeduplicationSurvivorFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportDeduplication + "1072"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportDeduplicationSupercededFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportDeduplication + "1073"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportDeduplicationSurvivorSupersededReportRecordIdentifierFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportDeduplication + "3600"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportDeduplicationFieldSelectionIdentifierFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportDeduplication + "3601"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportDeduplicationCheckAllFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportDeduplication + "3195"')

--        //DDUC03 - Person Record Deduplication
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchPersonPersonIDFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchPerson + "871"')

,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchPersonPersonalIDTypeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchPerson + "361"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchPersonPersonalIDNumberFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchPerson + "560"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchPersonLastNameFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchPerson + "414"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchPersonMiddleNameFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchPerson + "416"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchPersonFirstNameFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchPerson + "402"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchPersonDateOfBirthFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchPerson + "2565"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchPersonGenderFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchPerson + "345"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchPersonAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchPerson + "428"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchPersonAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchPerson + "426"')

,(N'FieldLabelResourceKeyConstants', N'PersonRecordDeduplicationSurvivorFieldLabel', N'InterfaceEditorResourceSetEnum.PersonRecordDeduplication + "1072"')
,(N'FieldLabelResourceKeyConstants', N'PersonRecordDeduplicationSupercededFieldLabel', N'InterfaceEditorResourceSetEnum.PersonRecordDeduplication + "1073"')

,(N'FieldLabelResourceKeyConstants', N'DeduplicationPersonInformationFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationPerson + "3192"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationPersonEmploymentFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationPerson + "3193"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationPersonSupersededFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationPerson + "3194"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationPersonCheckAllFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationPerson + "3195"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationPersonAddressFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationPerson + "2570"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationPersonSurvivorFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationPerson + "1072"')

--        //DDUC04 - Farm Record Deduplication
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchFarmFarmIDFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchFarm + "2403"')

,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchFarmFarmTypeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchFarm + "2404"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchFarmFarmOwnerLastNameFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchFarm + "2405"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchFarmFarmOwnerFirstNameFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchFarm + "2406"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchFarmFarmOwnerIDFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchFarm + "2407"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchFarmAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchFarm + "428"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchFarmAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchFarm + "426"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchFarmAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchFarm + "248"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchFarmAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchFarm + "949"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchFarmAdministrativeLevel5FieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchFarm + "950"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchFarmAdministrativeLevel6FieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchFarm + "951"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchFarmSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchFarm + "249"')
,(N'FieldLabelResourceKeyConstants', N'FarmRecordDeduplicationFarmDetailsFieldLabel', N'InterfaceEditorResourceSetEnum.FarmRecordDeduplication + "3471"')
,(N'FieldLabelResourceKeyConstants', N'FarmRecordDeduplicationAnimalDiseaseReportsFieldLabel', N'InterfaceEditorResourceSetEnum.FarmRecordDeduplication + "3472"')

--        //public static readonly string FarmInformationDateEnteredFieldLabel', N'InterfaceEditorResourceSetEnum.dedu + "854"')
--        //public static readonly string FarmInformationDateLastUpdatedFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "1083"')
--        //public static readonly string FarmInformationFarmIDFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "2403"')
--        //public static readonly string FarmInformationLegacyIDFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "936"')
--        //public static readonly string FarmInformationFarmTypeFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "2404"')
--        //public static readonly string FarmInformationFarmNameFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "2430"')
--        //public static readonly string FarmInformationFarmOwnerFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "674"')
--        //public static readonly string FarmInformationPhoneFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "206"')
--        //public static readonly string FarmInformationFaxFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "2431"')
--        //public static readonly string FarmInformationEmailFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "2432"')
--        //public static readonly string FarmInformationNumberOfBarnsBuildingsFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "2433"')
--        //public static readonly string FarmInformationNumberOfBirdsPerBarnBuildingFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "2434"')
--        //public static readonly string FarmAddressDateEnteredFieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "854"')
--        //public static readonly string FarmAddressDateLastUpdatedFieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "1083"')
--        //public static readonly string FarmAddressAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "428"')
--        //public static readonly string FarmAddressAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "426"')
--        //public static readonly string FarmAddressAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "248"')
--        //public static readonly string FarmAddressAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "949"')
--        //public static readonly string FarmAddressAdministrativeLevel5FieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "950"')
--        //public static readonly string FarmAddressAdministrativeLevel6FieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "951"')
--        //public static readonly string FarmAddressSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "249"')
--        //public static readonly string FarmAddressStreetFieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "248"')
--        //public static readonly string FarmAddressBuildingFieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "31"')
--        //public static readonly string FarmAddressHouseFieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "92"')
--        //public static readonly string FarmAddressApartmentFieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "2417"')
--        //public static readonly string FarmAddressPostalCodeFieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "208"')
--        //public static readonly string FarmAddressLatitudeFieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "2418"')
--        //public static readonly string FarmAddressLongitudeFieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "2419"')
--        //public static readonly string FarmAddressElevationFieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "2420"')

,(N'FieldLabelResourceKeyConstants', N'FarmRecordDeduplicationSurvivorFieldLabel', N'InterfaceEditorResourceSetEnum.FarmRecordDeduplication + "1072"')
,(N'FieldLabelResourceKeyConstants', N'FarmRecordDeduplicationSupercededFieldLabel', N'InterfaceEditorResourceSetEnum.FarmRecordDeduplication + "1073"')

--        //DDUC05 - Livestock Disease Report Deduplication
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsReportIDFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "750"')

,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsLegacyIDFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "936"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsSpeciesTypeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "440"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "71"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsReportStatusFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "1080"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsReportTypeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "434"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "428"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "426"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "248"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "949"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "249"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsDateEnteredFromFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "2437"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsDateEnteredToFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "2438"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsCaseClassificationFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "387"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsDiagnosisDateRangeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "1871"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsInvestigationDateRangeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "2439"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsFieldSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "870"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsTotalAnimalQuantityFromFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "2440"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsTotalAnimalQuantityToFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "2441"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsSessionIDFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "808"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsDataEntrySiteFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "1864"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsReportDateFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "2443"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsReportedByFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "2444"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsInvestigationDateFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "2445"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsInvestigatedByFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "2446"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsSpeciesFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "366"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsTotalAnimalsFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "2447"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsSickAnimalQuantityFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "2448"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchLivestockDiseaseReportsDeadAnimalQuantityFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchLivestockDiseaseReports + "2449"')

,(N'FieldLabelResourceKeyConstants', N'DeduplicationLivestockDiseaseReportNotificationOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportNotification + "423"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationLivestockDiseaseReportNotificationReportedByFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportNotification + "2444"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationLivestockDiseaseReportNotificationInitialReportDateFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportNotification + "2472"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationLivestockDiseaseReportNotificationInvestigationOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportNotification + "2473"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationLivestockDiseaseReportNotificationInvestigatorNameFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportNotification + "2474"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationLivestockDiseaseReportNotificationAssignedDateFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportNotification + "2475"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationLivestockDiseaseReportNotificationInvestigationDateFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportNotification + "2445"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationLivestockDiseaseReportNotificationDataEntrySiteFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportNotification + "549"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationLivestockDiseaseReportNotificationDataEntryOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportNotification + "762"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationLivestockDiseaseReportNotificationDataEntryDateFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockDiseaseReportNotification + "763"')

,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportDeduplicationSurvivorFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportDeduplication + "1072"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportDeduplicationSupercededFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportDeduplication + "1073"')

--        //DDUC06 - Avian Disease Report Deduplication
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsReportIDFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "750"')

,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsLegacyIDFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "936"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsSpeciesTypeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "440"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "71"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsReportStatusFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "1080"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsReportTypeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "434"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "428"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "426"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "248"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "949"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "249"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsDateEnteredFromFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "2437"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsDateEnteredToFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "2438"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsCaseClassificationFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "387"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsDiagnosisDateRangeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "1871"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsInvestigationDateRangeFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "2439"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsFieldSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "870"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsTotalAnimalQuantityFromFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "2440"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsTotalAnimalQuantityToFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "2441"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsSessionIDFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "808"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsDataEntrySiteFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "1864"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsReportDateFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "2443"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsReportedByFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "2444"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsInvestigationDateFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "2445"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsInvestigatedByFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "2446"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsSpeciesFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "366"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsTotalAnimalsFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "2447"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsSickAnimalQuantityFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "2448"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationSearchAvianDiseaseReportsDeadAnimalQuantityFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationSearchAvianDiseaseReports + "2449"')

,(N'FieldLabelResourceKeyConstants', N'DeduplicationAvianDiseaseReportNotificationOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportNotification + "423"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationAvianDiseaseReportNotificationReportedByFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportNotification + "2444"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationAvianDiseaseReportNotificationInitialReportDateFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportNotification + "2472"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationAvianDiseaseReportNotificationInvestigationOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportNotification + "2473"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationAvianDiseaseReportNotificationInvestigatorNameFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportNotification + "2474"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationAvianDiseaseReportNotificationAssignedDateFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportNotification + "2475"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationAvianDiseaseReportNotificationInvestigationDateFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportNotification + "2445"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationAvianDiseaseReportNotificationDataEntrySiteFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportNotification + "549"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationAvianDiseaseReportNotificationDataEntryOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportNotification + "762"')
,(N'FieldLabelResourceKeyConstants', N'DeduplicationAvianDiseaseReportNotificationDataEntryDateFieldLabel', N'InterfaceEditorResourceSetEnum.DeduplicationAvianDiseaseReportNotification + "763"')

,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportDeduplicationSurvivorFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportDeduplication + "1072"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportDeduplicationSupercededFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportDeduplication + "1073"')

--endregion Deduplication Sub-Module Resources

--endregion Administration Module Resources

--region Configuration Module Resources

,(N'FieldLabelResourceKeyConstants', N'TestTestResultMatrixLaboratoryTestFieldLabel', N'InterfaceEditorResourceSetEnum.TestTestResultMatrix + "4463"')
,(N'FieldLabelResourceKeyConstants', N'TestTestResultMatrixPensideTestFieldLabel', N'InterfaceEditorResourceSetEnum.TestTestResultMatrix + "360"')

--        //SCUC14 - Configure Vector Type - Field Test Matrix
,(N'FieldLabelResourceKeyConstants', N'VectorTypeFieldTestMatrixFieldTestFieldLabel', N'InterfaceEditorResourceSetEnum.VectorTypeFieldTestMatrix + "961"')

--        //SCUC18 - Configure Disease Group - Disease Matrix
,(N'FieldLabelResourceKeyConstants', N'ConfigureDieaseGroupDiseaseMatrixDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.DiseaseGroupDiseaseMatrix + "71"')

,(N'FieldLabelResourceKeyConstants', N'ConfigureDiseaseGroupDiseaseMatrixAccessoryCodeFieldLabel', N'InterfaceEditorResourceSetEnum.DiseaseGroupDiseaseMatrix + "465"')

--        //SCUC17 - Custom Report Rows
,(N'FieldLabelResourceKeyConstants', N'CustomReportRowsICD10ColumnAdditionalTextFieldLabel', N'InterfaceEditorResourceSetEnum.CustomReportRows + "627"')

--        //SCUC25 - Configure Data Archiving Settings
,(N'FieldLabelResourceKeyConstants', N'DataArchivingSettingsScheduleSummaryDescriptionFieldLabel', N'InterfaceEditorResourceSetEnum.DataArchivingSettings + "2639"')

,(N'FieldLabelResourceKeyConstants', N'DataArchivingSettingsIntervalOfDataRelevanceInYearsFieldLabel', N'InterfaceEditorResourceSetEnum.DataArchivingSettings + "2672"')
,(N'FieldLabelResourceKeyConstants', N'DataArchivingSettingsOccursEveryDayAtFieldLabel', N'InterfaceEditorResourceSetEnum.DataArchivingSettings + "2787"')
,(N'FieldLabelResourceKeyConstants', N'DataArchivingSettingsNotSetFieldLabel', N'InterfaceEditorResourceSetEnum.DataArchivingSettings + "2788"')

--        //fix of localization 10/20/2023
,(N'FieldLabelResourceKeyConstants', N'AlphanumericValue', N'InterfaceEditorResourceSetEnum.Configuration + "4812"')
,(N'FieldLabelResourceKeyConstants', N'NumericValue', N'InterfaceEditorResourceSetEnum.Configuration + "4813"')

--endregion Configuration Module Resources

--region Human Module Resources

--        //HUC01 - Search for Person Record
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchPersonPersonIDLabel', N'"871"')

,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchPersonOrLabel', N'"605"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchPersonPersonalIDTypeLabel', N'"361"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchPersonPersonalIDLabel', N'"560"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchPersonFirstNameLabel', N'"402"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchPersonLastNameLabel', N'"414"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchPersonMiddleNameLabel', N'"416"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchPersonDateOfBirthFromLabel', N'"404"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchPersonDateOfBirthToLabel', N'"446"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchPersonGenderLabel', N'"345"')

,(N'FieldLabelResourceKeyConstants', N'SearchPersonPersonIDLabel', N'InterfaceEditorResourceSetEnum.SearchPerson + "871"')
,(N'FieldLabelResourceKeyConstants', N'SearchPersonOrLabel', N'InterfaceEditorResourceSetEnum.SearchPerson + "605"')
,(N'FieldLabelResourceKeyConstants', N'SearchPersonPersonalIDTypeLabel', N'InterfaceEditorResourceSetEnum.SearchPerson + "361"')
,(N'FieldLabelResourceKeyConstants', N'SearchPersonPersonalIDLabel', N'InterfaceEditorResourceSetEnum.SearchPerson + "560"')
,(N'FieldLabelResourceKeyConstants', N'SearchPersonFirstNameLabel', N'InterfaceEditorResourceSetEnum.SearchPerson + "402"')
,(N'FieldLabelResourceKeyConstants', N'SearchPersonLastNameLabel', N'InterfaceEditorResourceSetEnum.SearchPerson + "414"')
,(N'FieldLabelResourceKeyConstants', N'SearchPersonMiddleNameLabel', N'InterfaceEditorResourceSetEnum.SearchPerson + "416"')
,(N'FieldLabelResourceKeyConstants', N'SearchPersonDateOfBirthFromLabel', N'InterfaceEditorResourceSetEnum.SearchPerson + "404"')
,(N'FieldLabelResourceKeyConstants', N'SearchPersonDateOfBirthToLabel', N'InterfaceEditorResourceSetEnum.SearchPerson + "446"')
,(N'FieldLabelResourceKeyConstants', N'SearchPersonGenderLabel', N'InterfaceEditorResourceSetEnum.SearchPerson + "345"')

,(N'FieldLabelResourceKeyConstants', N'SearchPersonModalPersonIDLabel', N'InterfaceEditorResourceSetEnum.SearchPersonModal + "871"')
,(N'FieldLabelResourceKeyConstants', N'SearchPersonModalOrLabel', N'InterfaceEditorResourceSetEnum.SearchPersonModal + "605"')
,(N'FieldLabelResourceKeyConstants', N'SearchPersonModalPersonalIDTypeLabel', N'InterfaceEditorResourceSetEnum.SearchPersonModal + "361"')
,(N'FieldLabelResourceKeyConstants', N'SearchPersonModalPersonalIDLabel', N'InterfaceEditorResourceSetEnum.SearchPersonModal + "560"')
,(N'FieldLabelResourceKeyConstants', N'SearchPersonModalFirstNameLabel', N'InterfaceEditorResourceSetEnum.SearchPersonModal + "402"')
,(N'FieldLabelResourceKeyConstants', N'SearchPersonModalLastNameLabel', N'InterfaceEditorResourceSetEnum.SearchPersonModal + "414"')
,(N'FieldLabelResourceKeyConstants', N'SearchPersonModalMiddleNameLabel', N'InterfaceEditorResourceSetEnum.SearchPersonModal + "416"')
,(N'FieldLabelResourceKeyConstants', N'SearchPersonModalDateOfBirthFromLabel', N'InterfaceEditorResourceSetEnum.SearchPersonModal + "404"')
,(N'FieldLabelResourceKeyConstants', N'SearchPersonModalDateOfBirthToLabel', N'InterfaceEditorResourceSetEnum.SearchPersonModal + "446"')
,(N'FieldLabelResourceKeyConstants', N'SearchPersonModalGenderLabel', N'InterfaceEditorResourceSetEnum.SearchPersonModal + "345"')

--        //HUC02 - Enter a Person Record and HUC04 - Edit a Person Record

--        //Person Information Section
,(N'FieldLabelResourceKeyConstants', N'PersonInformationPersonIDFieldLabel', N'InterfaceEditorResourceSetEnum.PersonInformation + "871"')

,(N'FieldLabelResourceKeyConstants', N'PersonInformationPersonalIDTypeFieldLabel', N'InterfaceEditorResourceSetEnum.PersonInformation + "361"')
,(N'FieldLabelResourceKeyConstants', N'PersonInformationPersonalIDFieldLabel', N'InterfaceEditorResourceSetEnum.PersonInformation + "560"')
,(N'FieldLabelResourceKeyConstants', N'PersonInformationLastNameFieldLabel', N'InterfaceEditorResourceSetEnum.PersonInformation + "414"')
,(N'FieldLabelResourceKeyConstants', N'PersonInformationFirstNameFieldLabel', N'InterfaceEditorResourceSetEnum.PersonInformation + "402"')
,(N'FieldLabelResourceKeyConstants', N'PersonInformationMiddleNameFieldLabel', N'InterfaceEditorResourceSetEnum.PersonInformation + "416"')
,(N'FieldLabelResourceKeyConstants', N'PersonInformationDateOfBirthFieldLabel', N'InterfaceEditorResourceSetEnum.PersonInformation + "2565"')
,(N'FieldLabelResourceKeyConstants', N'PersonInformationAgeFieldLabel', N'InterfaceEditorResourceSetEnum.PersonInformation + "1070"')
,(N'FieldLabelResourceKeyConstants', N'PersonInformationGenderFieldLabel', N'InterfaceEditorResourceSetEnum.PersonInformation + "345"')
,(N'FieldLabelResourceKeyConstants', N'PersonInformationCitizenshipFieldLabel', N'InterfaceEditorResourceSetEnum.PersonInformation + "1071"')
,(N'FieldLabelResourceKeyConstants', N'PersonInformationPassportNumberFieldLabel', N'InterfaceEditorResourceSetEnum.PersonInformation + "1141"')

--        //Person Address Section
,(N'FieldLabelResourceKeyConstants', N'PersonAddressCurrentAddressAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressCurrentAddress + "428"')

,(N'FieldLabelResourceKeyConstants', N'PersonAddressCurrentAddressAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressCurrentAddress + "426"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressCurrentAddressAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressCurrentAddress + "248"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressCurrentAddressAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressCurrentAddress + "949"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressCurrentAddressAdministrativeLevel5FieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressCurrentAddress + "950"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressCurrentAddressAdministrativeLevel6FieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressCurrentAddress + "951"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressCurrentAddressSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressCurrentAddress + "249"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressCurrentAddressStreetFieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressCurrentAddress + "257"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressCurrentAddressHouseFieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressCurrentAddress + "92"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressCurrentAddressBuildingFieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressCurrentAddress + "31"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressCurrentAddressApartmentFieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressCurrentAddress + "25"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressCurrentAddressPostalCodeFieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressCurrentAddress + "208"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressCurrentAddressLatitudeFieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressCurrentAddress + "1792"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressCurrentAddressLongitudeFieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressCurrentAddress + "1793"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressCurrentAddressCountryCodeAndNumberFieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressCurrentAddress + "2566"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressCurrentAddressPhoneTypeFieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressCurrentAddress + "2567"')

,(N'FieldLabelResourceKeyConstants', N'PersonAddressIsThereAnotherPhoneNumberForThisPersonFieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddress + "1785"')
,(N'FieldLabelResourceKeyConstants', N'PersonCurrentAddressAlternatePhoneCountryCodeAndNumberFieldLabel', N'InterfaceEditorResourceSetEnum.PersonCurrentAddressAlternatePhone + "2566"')
,(N'FieldLabelResourceKeyConstants', N'PersonCurrentAddressAlternatePhonePhoneTypeFieldLabel', N'InterfaceEditorResourceSetEnum.PersonCurrentAddressAlternatePhone + "2567"')

,(N'FieldLabelResourceKeyConstants', N'PersonAddressIsThereAnotherAddressWhereThisPersonCanResideFieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddress + "1808"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressPermanentAddressSameAsCurrentAddressFieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddress + "2568"')

,(N'FieldLabelResourceKeyConstants', N'PersonAddressAlternateAddressAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressAlternateAddress + "428"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressAlternateAddressAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressAlternateAddress + "426"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressAlternateAddressAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressAlternateAddress + "248"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressAlternateAddressAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressAlternateAddress + "949"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressAlternateAddressAdministrativeLevel5FieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressAlternateAddress + "950"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressAlternateAddressAdministrativeLevel6FieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressAlternateAddress + "951"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressAlternateAddressSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressAlternateAddress + "249"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressAlternateAddressStreetFieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressAlternateAddress + "257"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressAlternateAddressHouseFieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressAlternateAddress + "92"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressAlternateAddressBuildingFieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressAlternateAddress + "31"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressAlternateAddressApartmentFieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressAlternateAddress + "25"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressAlternateAddressPostalCodeFieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressAlternateAddress + "208"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressAlternateAddressLatitudeFieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressAlternateAddress + "1792"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressAlternateAddressLongitudeFieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressAlternateAddress + "1793"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressAlternateAddressForeignAddressFieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressAlternateAddress + "83"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressAlternateAddressCountryFieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressAlternateAddress + "47"')
,(N'FieldLabelResourceKeyConstants', N'PersonAddressAlternateAddressOtherForeignAddressFieldLabel', N'InterfaceEditorResourceSetEnum.PersonAddressAlternateAddress + "2569"')

--        //Person Employment/School Information Section
,(N'FieldLabelResourceKeyConstants', N'PersonEmploymentSchoolInformationIsThisPersonCurrentlyEmployedFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmploymentSchoolInformation + "2571"')

,(N'FieldLabelResourceKeyConstants', N'PersonEmploymentSchoolInformationOccupationFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmploymentSchoolInformation + "2572"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmploymentSchoolInformationEmployerNameFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmploymentSchoolInformation + "2573"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmploymentSchoolInformationDateofLastPresenceatWorkFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmploymentSchoolInformation + "2574"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmploymentSchoolInformationWorkAddresssameasCurrentAddressFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmploymentSchoolInformation + "2575"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmploymentSchoolInformationDoesthePersonCurrentlyAttendCchoolFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmploymentSchoolInformation + "2576"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmploymentSchoolInformationSchoolNameFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmploymentSchoolInformation + "2577"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmploymentSchoolInformationDateofLastPresenceatSchoolFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmploymentSchoolInformation + "2578"')

,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationWorkAddressAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationWorkAddress + "428"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationWorkAddressAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationWorkAddress + "426"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationWorkAddressAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationWorkAddress + "248"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationWorkAddressAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationWorkAddress + "949"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationWorkAddressAdministrativeLevel5FieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationWorkAddress + "950"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationWorkAddressAdministrativeLevel6FieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationWorkAddress + "951"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationWorkAddressSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationWorkAddress + "249"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationWorkAddressStreetFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationWorkAddress + "257"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationWorkAddressHouseFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationWorkAddress + "92"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationWorkAddressBuildingFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationWorkAddress + "31"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationWorkAddressApartmentFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationWorkAddress + "25"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationWorkAddressPostalCodeFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationWorkAddress + "208"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationWorkAddressCountryCodeAndNumberFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationWorkAddress + "2566"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationWorkAddressForeignAddressFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationWorkAddress + "83"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationWorkAddressCountryFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationWorkAddress + "47"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationWorkAddressAddressFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationWorkAddress + "2570"')

,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationSchoolAddressAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationSchoolAddress + "428"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationSchoolAddressAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationSchoolAddress + "426"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationSchoolAddressAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationSchoolAddress + "248"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationSchoolAddressAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationSchoolAddress + "949"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationSchoolAddressAdministrativeLevel5FieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationSchoolAddress + "950"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationSchoolAddressAdministrativeLevel6FieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationSchoolAddress + "951"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationSchoolAddressSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationSchoolAddress + "249"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationSchoolAddressStreetFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationSchoolAddress + "257"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationSchoolAddressHouseFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationSchoolAddress + "92"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationSchoolAddressBuildingFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationSchoolAddress + "31"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationSchoolAddressApartmentFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationSchoolAddress + "25"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationSchoolAddressPostalCodeFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationSchoolAddress + "208"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationSchoolAddressCountryCodeAndNumberFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationSchoolAddress + "2566"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationSchoolAddressForeignAddressFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationSchoolAddress + "83"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationSchoolAddressCountryFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationSchoolAddress + "47"')
,(N'FieldLabelResourceKeyConstants', N'PersonEmployerSchoolInformationSchoolAddressAddressFieldLabel', N'InterfaceEditorResourceSetEnum.PersonEmployerSchoolInformationSchoolAddress + "2570"')

--        //HASUC01 - Enter Human Active Surveillance Campaign
,(N'FieldLabelResourceKeyConstants', N'HumanActiveSurveillanceCampaignCampaignStartDateFieldLabel', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "827"')

,(N'FieldLabelResourceKeyConstants', N'HumanActiveSurveillanceCampaignCampaignEndDateFieldLabel', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "828"')
,(N'FieldLabelResourceKeyConstants', N'HumanActiveSurveillanceCampaignCampaignAdministratorFieldLabel', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "829"')
,(N'FieldLabelResourceKeyConstants', N'HumanActiveSurveillanceCampaignSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "365"')
,(N'FieldLabelResourceKeyConstants', N'HumanActiveSurveillanceCampaignPlannedNumberFieldLabel', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "2764"')

--        //HASUC03 - Enter Human Active Surveillance Session and HASUC04 - Edit Human Active Surveillance Session
,(N'FieldLabelResourceKeyConstants', N'HumanSessionSampleDetailsModalSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.HumanSessionSampleDetailsModal + "365"')

,(N'FieldLabelResourceKeyConstants', N'HumanSessionSampleDetailsModalDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.HumanSessionSampleDetailsModal + "71"')
,(N'FieldLabelResourceKeyConstants', N'HumanSessionSampleDetailsModalFieldSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.HumanSessionSampleDetailsModal + "870"')
,(N'FieldLabelResourceKeyConstants', N'HumanSessionSampleDetailsModalPersonIDFieldLabel', N'InterfaceEditorResourceSetEnum.HumanSessionSampleDetailsModal + "871"')
,(N'FieldLabelResourceKeyConstants', N'HumanSessionSampleDetailsModalPersonAddressFieldLabel', N'InterfaceEditorResourceSetEnum.HumanSessionSampleDetailsModal + "872"')
,(N'FieldLabelResourceKeyConstants', N'HumanSessionSampleDetailsModalCollectionDateFieldLabel', N'InterfaceEditorResourceSetEnum.HumanSessionSampleDetailsModal + "873"')
,(N'FieldLabelResourceKeyConstants', N'HumanSessionSampleDetailsModalCommentsFieldLabel', N'InterfaceEditorResourceSetEnum.HumanSessionSampleDetailsModal + "874"')
,(N'FieldLabelResourceKeyConstants', N'HumanSessionSampleDetailsModalSentToOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.HumanSessionSampleDetailsModal + "875"')
,(N'FieldLabelResourceKeyConstants', N'HumanActiveSurveillanceSessionSessionIDFieldLabel', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "808"')
,(N'FieldLabelResourceKeyConstants', N'HumanActiveSurveillanceSessionSessionStatusFieldLabel', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "809"')
,(N'FieldLabelResourceKeyConstants', N'HumanActiveSurveillanceSessionCampaignIDFieldLabel', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "796"')
,(N'FieldLabelResourceKeyConstants', N'HumanActiveSurveillanceSessionCampaignNameFieldLabel', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "797"')
,(N'FieldLabelResourceKeyConstants', N'HumanActiveSurveillanceSessionCampaignTypeFieldLabel', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "798"')
,(N'FieldLabelResourceKeyConstants', N'HumanActiveSurveillanceSessionSessionStartDateFieldLabel', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "850"')
,(N'FieldLabelResourceKeyConstants', N'HumanActiveSurveillanceSessionSessionEndDateFieldLabel', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "851"')
,(N'FieldLabelResourceKeyConstants', N'HumanActiveSurveillanceSessionDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "71"')
,(N'FieldLabelResourceKeyConstants', N'HumanActiveSurveillanceSessionSiteFieldLabel', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "549"')
,(N'FieldLabelResourceKeyConstants', N'HumanActiveSurveillanceSessionOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "762"')
,(N'FieldLabelResourceKeyConstants', N'HumanActiveSurveillanceSessionDateEnteredFieldLabel', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "854"')
,(N'FieldLabelResourceKeyConstants', N'HumanActiveSurveillanceSessionSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "365"')
,(N'FieldLabelResourceKeyConstants', N'HumanActiveSurveillanceSessionLocationFieldLabel', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "975"')

--        //HASUC05 - Search Human Active Surveillance Campaign
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceCampaignsCampaignIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceCampaigns + "796"')

,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceCampaignsCampaignNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceCampaigns + "797"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceCampaignsCampaignTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceCampaigns + "798"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceCampaignsCampaignStatusFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceCampaigns + "799"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceCampaignsCampaignStartDateRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceCampaigns + "800"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceCampaignsCampaignDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceCampaigns + "71"')

--        //HASUC06 - Search Human Active Surveillance Session
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanActiveSurveillanceSessionsSessionIDFieldLabel', N'"808"')

,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanActiveSurveillanceSessionsSessionStatusFieldLabel', N'"809"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanActiveSurveillanceSessionsDiseaseFieldLabel', N'"71"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanActiveSurveillanceSessionsDateEnteredRangeFieldLabel', N'"811"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanActiveSurveillanceSessionsAdministrativeLevel1FieldLabel', N'"428"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanActiveSurveillanceSessionsAdministrativeLevel2FieldLabel', N'"426"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanActiveSurveillanceSessionsAdministrativeLevel3FieldLabel', N'"248"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanActiveSurveillanceSessionsAdministrativeLevel4FieldLabel', N'"949"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanActiveSurveillanceSessionsSettlementTypeFieldLabel', N'"249"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanActiveSurveillanceSessionsSessionEndDateFieldLabel', N'"851"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanActiveSurveillanceSessionsSiteFieldLabel', N'"549"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanActiveSurveillanceSessionsOfficerFieldLabel', N'"762"')

,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsDateEnteredToFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessions + "2438"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsDateEnteredFromFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessions + "2437"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsSessionIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessions + "808"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsSessionStatusFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessions + "809"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessions + "71"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsDateEnteredRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessions + "811"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessions + "428"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessions + "426"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessions + "248"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessions + "949"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessions + "249"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsSessionEndDateFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessions + "851"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsSiteFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessions + "549"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessions + "762"')

,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsModalSessionIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessionsModal + "808"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsModalSessionStatusFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessionsModal + "809"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsModalDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessionsModal + "71"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsModalDateEnteredRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessionsModal + "811"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsModalAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessionsModal + "428"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsModalAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessionsModal + "426"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsModalAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessionsModal + "248"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsModalAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessionsModal + "949"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsModalSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessionsModal + "249"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsModalSessionEndDateFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessionsModal + "851"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsModalSiteFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessionsModal + "549"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsModalOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessionsModal + "762"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanActiveSurveillanceSessionsLocationFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanActiveSurveillanceSessions + "975"')

--        //HUC03 - Enter a Human Disease Report and HUC05 - Edit a Human Disease Report
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportRelatedToDiseaseReportFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReport + "3121"')

--        //Disease Report Summary
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportSummaryReportIDFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSummary + "750"')

,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportSummaryLegacyIDFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSummary + "936"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportSummaryReportStatusFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSummary + "1080"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportSummaryDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSummary + "71"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportSummaryPersonIDFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSummary + "871"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportSummaryPersonNameFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSummary + "1081"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportSummaryReportTypeFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSummary + "434"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportSummaryEnteredByFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSummary + "885"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportSummaryDateLastUpdatedFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSummary + "1083"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportSummaryStatusFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSummary + "575"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportSummaryRelatedToFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSummary + "1082"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportSummaryCaseClassificationFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSummary + "387"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportSummaryEnteredByOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSummary + "399"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportSummarySessionIDFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSummary + "808"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportSummaryDateEnteredFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSummary + "854"')

--        //Notification
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportNotificationDateOfCompletionOfPaperFormFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportNotification + "1084"')

,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportNotificationLocalIdentifierFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportNotification + "1085"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportNotificationDateOfDiagnosisFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportNotification + "1086"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportNotificationDateOfNotificationFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportNotification + "1087"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportNotificationStatusOfPatientAtTimeOfNotificationFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportNotification + "1088"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportNotificationNotificationSentbyFacilityFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportNotification + "1089"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportNotificationNotificationSentbyNameFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportNotification + "1090"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportNotificationNotificationReceivedbyFacilityFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportNotification + "1091"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportNotificationNotificationReceivedbyNameFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportNotification + "1092"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportNotificationCurrentLocationOfPatientFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportNotification + "1093"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportNotificationHospitalNameFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportNotification + "1094"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportNotificationOtherLocationFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportNotification + "1095"')

--        //Clinical Information-Symptoms
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportSymptomsDateOfSymptomsOnsetFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSymptoms + "1096"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportSymptomsInitialCaseClassificationFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSymptoms + "348"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportSymptomsListofSymptomsFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSymptoms + "4803"')

--        //Clinical Information-Facility Details
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportFacilityDetailsPatientPreviouslySoughtCareForSimilarSymptomsFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportFacilityDetails + "1097"')

,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportFacilityDetailsFacilityPatientFirstSoughtCareFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportFacilityDetails + "1098"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportFacilityDetailsDatePatientFirstSoughtCareFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportFacilityDetails + "1099"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportFacilityDetailsNonNotifiableDiagnosisFromFacilityWherePatientFirstSoughtCareFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportFacilityDetails + "1100"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportFacilityDetailsHospitalizationFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportFacilityDetails + "1101"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportFacilityDetailsDateOfHospitalizationFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportFacilityDetails + "1103"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportFacilityDetailsDateOfDischargeFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportFacilityDetails + "1104"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportFacilityDetailsHospitalNameFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportFacilityDetails + "1094"')

--        //Clinical Information-Antibiotic
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportAntibioticVaccineHistoryAntibioticAntiviralTherapyAdministeredFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportAntibioticVaccineHistory + "1105"')

,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportAntibioticVaccineHistoryWasSpecificVaccinationAdministeredFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportAntibioticVaccineHistory + "1106"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportAntibioticVaccineHistoryAdditionalInformationCommentsFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportAntibioticVaccineHistory + "1107"')

--        //Clinical Information-Vaccination

--        //Samples
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportSamplesSamplesCollectedFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSamples + "1113"')

,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportSamplesReasonFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSamples + "572"')

--        //Sample Details Modal
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportFilterSampleByDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSampleDetailsModal + "1115"')

,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportLocalSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSampleDetailsModal + "1117"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCollectedByInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSampleDetailsModal + "1118"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCollectedByOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSampleDetailsModal + "1119"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportSentDateFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSampleDetailsModal + "1120"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportAccessionDateFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSampleDetailsModal + "1121"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportSampleConditionReceivedFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSampleDetailsModal + "1122"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSampleDetailsModal + "365"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportSentToOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSampleDetailsModal + "875"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportLabSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSampleDetailsModal + "668"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportDateFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSampleDetailsModal + "763"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportFunctionalLabFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSampleDetailsModal + "868"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportAdditionalTestRequestedAndSampleNotesFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSampleDetailsModal + "869"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCollectionDateFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSampleDetailsModal + "873"')

--        //Tests
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportTestsTestsConductedFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTests + "1123"')

,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportTestsTestStatusFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTests + "679"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportTestsResultDateFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTests + "881"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportTestsDateInterpretedFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTests + "1130"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportTestsInterpretedByFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTests + "1131"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportTestsDateValidatedFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTests + "1134"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportTestsValidatedByFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTests + "1135"')

--        //Test and Interpretation Details Modal
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportTestDetailsModalFilterTestNameByDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTestDetailsModal + "1124"')

,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportTestDetailsModalLocalSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTestDetailsModal + "1117"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportTestDetailsModalLabSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTestDetailsModal + "668"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportTestDetailsModalSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTestDetailsModal + "365"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportTestDetailsModalTestDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTestDetailsModal + "876"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportTestDetailsModalTestNameFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTestDetailsModal + "370"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportTestDetailsModalTestStatusFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTestDetailsModal + "679"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportTestDetailsModalTestCategoryFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTestDetailsModal + "369"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportTestDetailsModalTestResultFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTestDetailsModal + "371"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportTestDetailsModalResultDateFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTestDetailsModal + "881"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportTestDetailsModalLaboratoryFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTestDetailsModal + "2871"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportTestDetailsModalEmployeeFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTestDetailsModal + "1126"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportTestDetailsModalDateResultsReceivedFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTestDetailsModal + "1127"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportTestDetailsModalRuleOutRuleInFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTestDetailsModal + "1128"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportTestDetailsModalDateInterpretedFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTestDetailsModal + "1130"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportTestDetailsModalInterpretedByFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTestDetailsModal + "1131"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportTestDetailsModalValidatedFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTestDetailsModal + "1132"')
insert into #Caption (captionClass, controlCaptionConstant, controlCaptionIdRaw) values
 (N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportTestDetailsModalDateValidatedFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTestDetailsModal + "1134"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportTestDetailsModalValidatedByFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportTestDetailsModal + "1135"')

--        //Case Investigation
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationInvestigatingOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1136"')

,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationStartDateOfInvestigationFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1137"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationOutbreakIDFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "969"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationCommentsFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "874"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationLocationofExposureisknownFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1138"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationDateOfPotentialExposureFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1139"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationExposureLocationFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1140"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationLocationOfExposureExactPointDescriptionFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1786"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationLocationOfExposureExactPointAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1787"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationLocationOfExposureExactPointAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1788"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationLocationOfExposureExactPointAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1789"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationLocationOfExposureExactPointSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1790"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationLocationOfExposureExactPointAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1791"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationLocationOfExposureExactPointLatitudeFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1792"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationLocationOfExposureExactPointLongitudeFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1793"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationLocationOfExposureExactPointElevationFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1794"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationLocationOfExposureRelativePointDescriptionFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1795"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationLocationOfExposureRelativePointAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1796"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationLocationOfExposureRelativePointAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1797"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationLocationOfExposureRelativePointAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1798"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationLocationOfExposureRelativePointSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1799"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationLocationOfExposureRelativePointAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1800"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationLocationOfExposureRelativePointLatitudeFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1801"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationLocationOfExposureRelativePointLongitudeFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1802"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationLocationOfExposureRelativePointGroundTypeFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1803"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationLocationOfExposureRelativePointDistancekmFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1804"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationLocationOfExposureRelativePointDirectionFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1805"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationLocationOfExposureForeignAddressCountryFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1806"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationLocationOfExposureForeignAddressAddressFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "1807"')

--        //Contact Information Modal
,(N'FieldLabelResourceKeyConstants', N'ContactInformationModalFirstNameFieldLabel', N'InterfaceEditorResourceSetEnum.ContactInformationModal + "402"')

,(N'FieldLabelResourceKeyConstants', N'ContactInformationModalLastNameFieldLabel', N'InterfaceEditorResourceSetEnum.ContactInformationModal + "414"')
,(N'FieldLabelResourceKeyConstants', N'ContactInformationModalMiddleNameFieldLabel', N'InterfaceEditorResourceSetEnum.ContactInformationModal + "416"')
,(N'FieldLabelResourceKeyConstants', N'ContactInformationModalAgeFieldLabel', N'InterfaceEditorResourceSetEnum.ContactInformationModal + "1070"')
,(N'FieldLabelResourceKeyConstants', N'ContactInformationModalCitizenshipFieldLabel', N'InterfaceEditorResourceSetEnum.ContactInformationModal + "1071"')
,(N'FieldLabelResourceKeyConstants', N'ContactInformationModalForeignAddressFieldLabel', N'InterfaceEditorResourceSetEnum.ContactInformationModal + "83"')
,(N'FieldLabelResourceKeyConstants', N'ContactInformationModalCountryFieldLabel', N'InterfaceEditorResourceSetEnum.ContactInformationModal + "47"')
,(N'FieldLabelResourceKeyConstants', N'ContactInformationModalAddressFieldLabel', N'InterfaceEditorResourceSetEnum.ContactInformationModal + "2570"')
,(N'FieldLabelResourceKeyConstants', N'ContactInformationModalGenderFieldLabel', N'InterfaceEditorResourceSetEnum.ContactInformationModal + "345"')
,(N'FieldLabelResourceKeyConstants', N'ContactInformationModalDateOfBirthFieldLabel', N'InterfaceEditorResourceSetEnum.ContactInformationModal + "2565"')
,(N'FieldLabelResourceKeyConstants', N'ContactInformationModalRelationFieldLabel', N'InterfaceEditorResourceSetEnum.ContactInformationModal + "1066"')
,(N'FieldLabelResourceKeyConstants', N'ContactInformationModalPhoneFieldLabel', N'InterfaceEditorResourceSetEnum.ContactInformationModal + "206"')
,(N'FieldLabelResourceKeyConstants', N'ContactInformationModalCountryCodeAndNumberFieldLabel', N'InterfaceEditorResourceSetEnum.ContactInformationModal + "2566"')
,(N'FieldLabelResourceKeyConstants', N'ContactInformationModalPhoneTypeFieldLabel', N'InterfaceEditorResourceSetEnum.ContactInformationModal + "2567"')
,(N'FieldLabelResourceKeyConstants', N'ContactInformationModalDateOfLastContactFieldLabel', N'InterfaceEditorResourceSetEnum.ContactInformationModal + "1067"')
,(N'FieldLabelResourceKeyConstants', N'ContactInformationModalPlaceOfLastContactFieldLabel', N'InterfaceEditorResourceSetEnum.ContactInformationModal + "1068"')
,(N'FieldLabelResourceKeyConstants', N'ContactInformationModalCommentsFieldLabel', N'InterfaceEditorResourceSetEnum.ContactInformationModal + "874"')

--        //Final Outcome
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportFinalOutcomeFinalCaseClassificationFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportFinalOutcome + "344"')

,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportFinalOutcomeDateOfFinalCaseClassificationFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportFinalOutcome + "1075"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportFinalOutcomeBasisOfDiagnosisFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportFinalOutcome + "1076"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportFinalOutcomeClinicalFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportFinalOutcome + "3117"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportFinalOutcomeEpidemiologicalLinksFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportFinalOutcome + "3118"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportFinalOutcomeLaboratoryTestsFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportFinalOutcome + "3119"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportFinalOutcomeOutcomeFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportFinalOutcome + "1077"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportFinalOutcomeDateOfDeathFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportFinalOutcome + "1078"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportFinalOutcomeEpidemiologistNameFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportFinalOutcome + "1079"')
,(N'FieldLabelResourceKeyConstants', N'HumanDiseaseReportFinalOutcomeCommentsFieldLabel', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportFinalOutcome + "874"')

--        //HUC09 - Search for Human Disease Report
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanDiseaseReportsReportIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "750"')

,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanDiseaseReportsLegacyIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "936"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanDiseaseReportsDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "71"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanDiseaseReportsReportStatusFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1080"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanDiseaseReportsLastNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "414"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanDiseaseReportsFirstNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "402"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanDiseaseReportsMiddleNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "416"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanDiseaseReportsAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "428"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanDiseaseReportsAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "426"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanDiseaseReportsAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "248"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanDiseaseReportsDateEnteredRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "811"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanDiseaseReportsCaseClassificationFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "387"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanDiseaseReportsHospitalizationFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "988"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanDiseaseReportsAdvancedSearchFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1101"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanDiseaseReportsSentByFacilityFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1862"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanDiseaseReportsReceivedByFacilityFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1863"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanDiseaseReportsDataEntrySiteFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1864"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanDiseaseReportsLocationOfExposureFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1865"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanDiseaseReportsLocationOfExposureAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1866"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanDiseaseReportsLocationOfExposureAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1867"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanDiseaseReportsDateOfFinalCaseClassificationRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1868"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanDiseaseReportsNotificationDateRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1869"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanDiseaseReportsDateOfSymptomsOnsetRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1870"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanDiseaseReportsDiagnosisDateRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1871"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanDiseaseReportsLocalSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1117"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchHumanDiseaseReportsOutcomeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1077"')

,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsReportIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "750"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsLegacyIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "936"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "71"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsReportStatusFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1080"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsLastNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "414"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsFirstNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "402"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsMiddleNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "416"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "428"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "426"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "248"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsLocationFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "975"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsDateEnteredRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "811"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsCaseClassificationFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "387"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsHospitalizationFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1101"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsAdvancedSearchFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "988"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsSentByFacilityFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1862"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsReceivedByFacilityFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1863"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsDataEntrySiteFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1864"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsLocationOfExposureFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1865"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsLocationOfExposureRegionFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1866"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsLocationOfExposureRayonFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1867"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsDateOfFinalCaseClassificationRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1868"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsNotificationDateRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1869"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsDateOfSymptomsOnsetRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1870"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsDiagnosisDateRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1871"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsLocalSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1117"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsOutcomeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReports + "1077"')

,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsModalReportIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "750"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsModalLegacyIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "936"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsModalDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "71"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsModalReportStatusFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "1080"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsModalLastNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "414"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsModalFirstNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "402"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsModalMiddleNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "416"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsModalAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "428"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsModalAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "426"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsModalAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "248"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsModalLocationFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "975"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsModalDateEnteredRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "811"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsModalCaseClassificationFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "387"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsModalHospitalizationFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "988"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsModalAdvancedSearchFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "1101"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsModalSentByFacilityFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "1862"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsModalReceivedByFacilityFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "1863"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsModalDataEntrySiteFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "1864"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsModalLocationOfExposureFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "1865"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsModalLocationOfExposureAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "1866"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsModalLocationOfExposureAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "1867"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsModalDateOfFinalCaseClassificationRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "1868"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsModalNotificationDateRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "1869"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsModalDateOfSymptomsOnsetRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "1870"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsModalDiagnosisDateRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "1871"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsModalLocalSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "1117"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanDiseaseReportsModalOutcomeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanDiseaseReportsModal + "1077"')

--        //HAUC01 and HAUC02 - Enter and Edit Human Aggregate Disease Report
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportNotificationSentByInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportNotificationSentBy + "761"')

,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportNotificationSentByOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportNotificationSentBy + "762"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportNotificationSentByDateFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportNotificationSentBy + "763"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportNotificationReceivedByInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportNotificationReceivedBy + "761"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportNotificationReceivedByOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportNotificationReceivedBy + "762"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportNotificationReceivedByDateFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportNotificationReceivedBy + "763"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportEnteredByInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportEnteredBy + "761"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportEnteredByOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportEnteredBy + "762"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportEnteredByDateFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportEnteredBy + "763"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportReportIDFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "750"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportYearFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "455"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportQuarterFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "425"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportMonthFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "418"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportWeekFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "760"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportDayFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "937"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportAdministrativeLevel0FieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "47"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "428"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "426"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "248"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "949"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "423"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportMatrixVersionFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "938"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportTemplateFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "939"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportNotificationReceivedbyInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "2776"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportDateReceivedFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "2777"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportReportEnteredbyInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "2778"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportNotificationSentbyInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "753"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportDateSentFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "844"')

--        //HAUC03 - Search for Human Aggregate Diseases Report
,(N'FieldLabelResourceKeyConstants', N'SearchHumanAggregateDiseaseReportsReportIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanAggregateDiseaseReports + "750"')

,(N'FieldLabelResourceKeyConstants', N'SearchHumanAggregateDiseaseReportsLegacyIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanAggregateDiseaseReports + "936"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanAggregateDiseaseReportsTimeIntervalUnitFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanAggregateDiseaseReports + "942"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanAggregateDiseaseReportsStartDateFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanAggregateDiseaseReports + "441"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanAggregateDiseaseReportsEndDateFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanAggregateDiseaseReports + "397"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanAggregateDiseaseReportsAdministrativeLevelFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanAggregateDiseaseReports + "943"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanAggregateDiseaseReportsAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanAggregateDiseaseReports + "428"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanAggregateDiseaseReportsAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanAggregateDiseaseReports + "426"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanAggregateDiseaseReportsAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanAggregateDiseaseReports + "248"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanAggregateDiseaseReportsAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanAggregateDiseaseReports + "949"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanAggregateDiseaseReportsOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanAggregateDiseaseReports + "423"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanAggregateDiseaseReportsNotificationReceivedbyInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanAggregateDiseaseReports + "2776"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanAggregateDiseaseReportsDateReceivedFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanAggregateDiseaseReports + "2777"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanAggregateDiseaseReportsReportEnteredbyInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanAggregateDiseaseReports + "2778"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanAggregateDiseaseReportsNotificationSentbyInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanAggregateDiseaseReports + "753"')
,(N'FieldLabelResourceKeyConstants', N'SearchHumanAggregateDiseaseReportsDateSentFieldLabel', N'InterfaceEditorResourceSetEnum.SearchHumanAggregateDiseaseReports + "844"')

--        //HAUC05 - Enter Human Aggregate Disease Reports Summary
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportSummaryLessThan1FieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportSummary + "1873"')

,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportSummary1Through4FieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportSummary + "1874"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportSummary5Through14FieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportSummary + "1875"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportSummary15Through19FieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportSummary + "1876"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportSummary20Through29FieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportSummary + "1877"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportSummary30Through59FieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportSummary + "1878"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportSummary60AndMoreFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportSummary + "1879"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportSummaryAmongThemNumberLethalCasesFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportSummary + "1880"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportSummaryNumberLabTestedFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportSummary + "1881"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportSummaryAmongThemNumberLabConfirmedFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportSummary + "1882"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportSummaryTotalConfirmedLabOrEpidLinkFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportSummary + "1883"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportSummaryStartDateFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportSummary + "441"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportSummaryEndDateFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportSummary + "397"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportSummaryDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportSummary + "71"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportSummaryICD10CodeFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportSummary + "764"')
,(N'FieldLabelResourceKeyConstants', N'HumanAggregateDiseaseReportSummaryTotalFieldLabel', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportSummary + "765"')

--        //HAUC06 - Enter ILI Aggregate Form and HAUC07 - Edit ILI Aggregate Form
,(N'FieldLabelResourceKeyConstants', N'ILIAggregateDetailsFormIDFieldLabel', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "2699"')

,(N'FieldLabelResourceKeyConstants', N'ILIAggregateDetailsLegacyIDFieldLabel', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "936"')
,(N'FieldLabelResourceKeyConstants', N'ILIAggregateDetailsDateEnteredFieldLabel', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "854"')
,(N'FieldLabelResourceKeyConstants', N'ILIAggregateDetailsDateLastUpdatedFieldLabel', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "1083"')
,(N'FieldLabelResourceKeyConstants', N'ILIAggregateDetailsEnteredByFieldLabel', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "885"')
,(N'FieldLabelResourceKeyConstants', N'ILIAggregateDetailsSiteFieldLabel', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "549"')
,(N'FieldLabelResourceKeyConstants', N'ILIAggregateDetailsYearFieldLabel', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "455"')
,(N'FieldLabelResourceKeyConstants', N'ILIAggregateDetailsWeekFieldLabel', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "760"')
,(N'FieldLabelResourceKeyConstants', N'ILIAggregateDetailsNameOfHospitalSentinelStationFieldLabel', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "2702"')
,(N'FieldLabelResourceKeyConstants', N'ILIAggregateDetails0To4FieldLabel', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "4380"')
,(N'FieldLabelResourceKeyConstants', N'ILIAggregateDetails5To14FieldLabel', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "4381"')
,(N'FieldLabelResourceKeyConstants', N'ILIAggregateDetails15To29FieldLabel', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "4382"')
,(N'FieldLabelResourceKeyConstants', N'ILIAggregateDetails30To64FieldLabel', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "4383"')
,(N'FieldLabelResourceKeyConstants', N'ILIAggregateDetailsGreaterThanOrEqualTo65FieldLabel', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "4384"')
,(N'FieldLabelResourceKeyConstants', N'ILIAggregateDetailsTotalILIFieldLabel', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "4385"')
,(N'FieldLabelResourceKeyConstants', N'ILIAggregateDetailsTotalAdmissionsFieldLabel', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "4386"')
,(N'FieldLabelResourceKeyConstants', N'ILIAggregateDetailsILISamplesFieldLabel', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "4387"')

--        //HAUC08 - Search for ILI Aggregate Form
,(N'FieldLabelResourceKeyConstants', N'SearchILIAggregateFormIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchILIAggregate + "2699"')

,(N'FieldLabelResourceKeyConstants', N'SearchILIAggregateLegacyIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchILIAggregate + "936"')
,(N'FieldLabelResourceKeyConstants', N'SearchILIAggregateWeeksFromFieldLabel', N'InterfaceEditorResourceSetEnum.SearchILIAggregate + "2700"')
,(N'FieldLabelResourceKeyConstants', N'SearchILIAggregateWeeksToFieldLabel', N'InterfaceEditorResourceSetEnum.SearchILIAggregate + "2701"')
,(N'FieldLabelResourceKeyConstants', N'SearchILIAggregateNameOfHospitalSentinelStationFieldLabel', N'InterfaceEditorResourceSetEnum.SearchILIAggregate + "2702"')
,(N'FieldLabelResourceKeyConstants', N'SearchILIAggregateDataEntrySiteFieldLabel', N'InterfaceEditorResourceSetEnum.SearchILIAggregate + "1864"')

--        //HAUC09 - Search for Weekly Reporting Form
,(N'FieldLabelResourceKeyConstants', N'SearchWeeklyReportingFormsReportIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchWeeklyReportingForms + "750"')

,(N'FieldLabelResourceKeyConstants', N'SearchWeeklyReportingFormsAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.SearchWeeklyReportingForms + "428"')
,(N'FieldLabelResourceKeyConstants', N'SearchWeeklyReportingFormsAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.SearchWeeklyReportingForms + "426"')
,(N'FieldLabelResourceKeyConstants', N'SearchWeeklyReportingFormsAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.SearchWeeklyReportingForms + "754"')
,(N'FieldLabelResourceKeyConstants', N'SearchWeeklyReportingFormsNotificationSentbyInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.SearchWeeklyReportingForms + "753"')
,(N'FieldLabelResourceKeyConstants', N'SearchWeeklyReportingFormsNotificationSentbyOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.SearchWeeklyReportingForms + "754"')
,(N'FieldLabelResourceKeyConstants', N'SearchWeeklyReportingFormsNotificationSentbyDateFieldLabel', N'InterfaceEditorResourceSetEnum.SearchWeeklyReportingForms + "755"')

--        //HAUC10 and HAUC11 - Enter and Edit Weekly Reporting Form
,(N'FieldLabelResourceKeyConstants', N'WeeklyReportingFormDetailsReportIDFieldLabel', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "750"')

,(N'FieldLabelResourceKeyConstants', N'WeeklyReportingFormDetailsYearFieldLabel', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "455"')
,(N'FieldLabelResourceKeyConstants', N'WeeklyReportingFormDetailsWeekFieldLabel', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "760"')
,(N'FieldLabelResourceKeyConstants', N'WeeklyReportingFormDetailsCountryFieldLabel', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "47"')
,(N'FieldLabelResourceKeyConstants', N'WeeklyReportingFormDetailsAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "428"')
,(N'FieldLabelResourceKeyConstants', N'WeeklyReportingFormDetailsAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "426"')
,(N'FieldLabelResourceKeyConstants', N'WeeklyReportingFormDetailsAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "248"')
,(N'FieldLabelResourceKeyConstants', N'WeeklyReportingFormDetailsAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "949"')
,(N'FieldLabelResourceKeyConstants', N'WeeklyReportingFormDetailsNotificationSentByInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormNotificationSentBy + "761"')
,(N'FieldLabelResourceKeyConstants', N'WeeklyReportingFormDetailsNotificationSentByOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormNotificationSentBy + "762"')
,(N'FieldLabelResourceKeyConstants', N'WeeklyReportingFormDetailsNotificationSentByDateFieldLabel', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormNotificationSentBy + "763"')
,(N'FieldLabelResourceKeyConstants', N'WeeklyReportingFormDetailsEnteredByInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormEnteredBy + "761"')
,(N'FieldLabelResourceKeyConstants', N'WeeklyReportingFormDetailsEnteredByOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormEnteredBy + "762"')
,(N'FieldLabelResourceKeyConstants', N'WeeklyReportingFormDetailsEnteredByDateFieldLabel', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormEnteredBy + "763"')
,(N'FieldLabelResourceKeyConstants', N'WeeklyReportingFormDetailsDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "71"')
,(N'FieldLabelResourceKeyConstants', N'WeeklyReportingFormDetailsICD10CodeFieldLabel', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "764"')
,(N'FieldLabelResourceKeyConstants', N'WeeklyReportingFormDetailsTotalFieldLabel', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "765"')
,(N'FieldLabelResourceKeyConstants', N'WeeklyReportingFormDetailsAmongThemNotifiedFieldLabel', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "766"')
,(N'FieldLabelResourceKeyConstants', N'WeeklyReportingFormDetailsCommentFieldLabel', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "767"')

--        //HAUC13 - Enter Weekly Reporting Form Summary
,(N'FieldLabelResourceKeyConstants', N'WeeklyReportingFormSummaryAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormSummary + "428"')

,(N'FieldLabelResourceKeyConstants', N'WeeklyReportingFormSummaryAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormSummary + "426"')
,(N'FieldLabelResourceKeyConstants', N'WeeklyReportingFormSummaryMonthFieldLabel', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormSummary + "418"')
,(N'FieldLabelResourceKeyConstants', N'WeeklyReportingFormSummaryYearFieldLabel', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormSummary + "455"')

--endregion Human Module Resources

--region Laboratory Module Resources

--        //LUC01 - Accession a Sample
,(N'FieldLabelResourceKeyConstants', N'GroupAccessionInModalLocalFieldSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.GroupAccessionInModal + "669"')

,(N'FieldLabelResourceKeyConstants', N'GroupAccessionInModalPrintBarcodeFieldLabel', N'InterfaceEditorResourceSetEnum.GroupAccessionInModal + "852"')

--        //LUC02 - Create an Aliquot-Derivative
,(N'FieldLabelResourceKeyConstants', N'AliquotDerivativeModalCreateAliquotFieldLabel', N'InterfaceEditorResourceSetEnum.AliquotDerivativeModal + "830"')

,(N'FieldLabelResourceKeyConstants', N'AliquotDerivativeModalCreateDerivativeFieldLabel', N'InterfaceEditorResourceSetEnum.AliquotDerivativeModal + "831"')
,(N'FieldLabelResourceKeyConstants', N'AliquotDerivativeModalNewSamplesFieldLabel', N'InterfaceEditorResourceSetEnum.AliquotDerivativeModal + "834"')
,(N'FieldLabelResourceKeyConstants', N'AliquotDerivativeModalTypeofDerivativeFieldLabel', N'InterfaceEditorResourceSetEnum.AliquotDerivativeModal + "835"')
,(N'FieldLabelResourceKeyConstants', N'AliquotDerivativeModalPrintBarcodesFieldLabel', N'InterfaceEditorResourceSetEnum.AliquotDerivativeModal + "847"')

--        //LUC03 - Transfer a Sample
,(N'FieldLabelResourceKeyConstants', N'TransferOutModalSampleTransferIDFieldLabel', N'InterfaceEditorResourceSetEnum.TransferOutModal + "855"')

,(N'FieldLabelResourceKeyConstants', N'TransferOutModalPurposeofTransferFieldLabel', N'InterfaceEditorResourceSetEnum.TransferOutModal + "841"')
,(N'FieldLabelResourceKeyConstants', N'TransferOutModalTestRequestedFieldLabel', N'InterfaceEditorResourceSetEnum.TransferOutModal + "842"')
,(N'FieldLabelResourceKeyConstants', N'TransferOutModalTransferredToFieldLabel', N'InterfaceEditorResourceSetEnum.TransferOutModal + "843"')
,(N'FieldLabelResourceKeyConstants', N'TransferOutModalDateSentFieldLabel', N'InterfaceEditorResourceSetEnum.TransferOutModal + "844"')
,(N'FieldLabelResourceKeyConstants', N'TransferOutModalTransferFromFieldLabel', N'InterfaceEditorResourceSetEnum.TransferOutModal + "845"')
,(N'FieldLabelResourceKeyConstants', N'TransferOutModalSentByFieldLabel', N'InterfaceEditorResourceSetEnum.TransferOutModal + "846"')
,(N'FieldLabelResourceKeyConstants', N'TransferOutModalPrintBarcodeFieldLabel', N'InterfaceEditorResourceSetEnum.TransferOutModal + "852"')

--        //LUC04 - Assign a Test
,(N'FieldLabelResourceKeyConstants', N'AssignTestModalFilterTestNameByDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.AssignTestModal + "1124"')

,(N'FieldLabelResourceKeyConstants', N'AssignTestModalDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.AssignTestModal + "71"')
,(N'FieldLabelResourceKeyConstants', N'AssignTestModalTestNameFieldLabel', N'InterfaceEditorResourceSetEnum.AssignTestModal + "370"')
,(N'FieldLabelResourceKeyConstants', N'AssignTestModalTestResultFieldLabel', N'InterfaceEditorResourceSetEnum.AssignTestModal + "371"')

--        //LUC07 - Amend Test Result
,(N'FieldLabelResourceKeyConstants', N'AmendTestResultModalCurrentTestResultFieldLabel', N'InterfaceEditorResourceSetEnum.AmendTestResultModal + "838"')

,(N'FieldLabelResourceKeyConstants', N'AmendTestResultModalChangedTestResultFieldLabel', N'InterfaceEditorResourceSetEnum.AmendTestResultModal + "839"')
,(N'FieldLabelResourceKeyConstants', N'AmendTestResultModalReasonforAmendmentFieldLabel', N'InterfaceEditorResourceSetEnum.AmendTestResultModal + "840"')

--        //LUC08 - Create a Batch
,(N'FieldLabelResourceKeyConstants', N'BatchModalBatchIDFieldLabel', N'InterfaceEditorResourceSetEnum.BatchModal + "878"')

,(N'FieldLabelResourceKeyConstants', N'BatchModalTestedNameFieldLabel', N'InterfaceEditorResourceSetEnum.BatchModal + "370"')
,(N'FieldLabelResourceKeyConstants', N'BatchModalTestedByFieldLabel', N'InterfaceEditorResourceSetEnum.BatchModal + "879"')
,(N'FieldLabelResourceKeyConstants', N'BatchModalTestStartedDateFieldLabel', N'InterfaceEditorResourceSetEnum.BatchModal + "886"')
,(N'FieldLabelResourceKeyConstants', N'LaboratoryBatchesAddSampleToBatchFieldLabel', N'InterfaceEditorResourceSetEnum.Batches + "1821"')

--        //LUC09 - Edit a Batch
,(N'FieldLabelResourceKeyConstants', N'BatchResultsDetailsModalBatchIDFieldLabel', N'InterfaceEditorResourceSetEnum.BatchResultsDetailsModal + "878"')

,(N'FieldLabelResourceKeyConstants', N'BatchResultsDetailsModalTestNameFieldLabel', N'InterfaceEditorResourceSetEnum.BatchResultsDetailsModal + "370"')
,(N'FieldLabelResourceKeyConstants', N'BatchResultsDetailsModalTestResultFieldLabel', N'InterfaceEditorResourceSetEnum.BatchResultsDetailsModal + "371"')
,(N'FieldLabelResourceKeyConstants', N'BatchResultsDetailsModalTestedByFieldLabel', N'InterfaceEditorResourceSetEnum.BatchResultsDetailsModal + "879"')
,(N'FieldLabelResourceKeyConstants', N'BatchResultsDetailsModalTestStartedDateFieldLabel', N'InterfaceEditorResourceSetEnum.BatchResultsDetailsModal + "886"')
,(N'FieldLabelResourceKeyConstants', N'BatchResultsDetailsModalResultDateFieldLabel', N'InterfaceEditorResourceSetEnum.BatchResultsDetailsModal + "881"')
,(N'FieldLabelResourceKeyConstants', N'BatchResultsDetailsModalNotesFieldLabel', N'InterfaceEditorResourceSetEnum.BatchResultsDetailsModal + "973"')

--        //LUC10 - Enter a Sample
,(N'FieldLabelResourceKeyConstants', N'RegisterNewSampleModalSampleCategoryFieldLabel', N'InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "1822"')

,(N'FieldLabelResourceKeyConstants', N'RegisterNewSampleModalReportSessionTypeFieldLabel', N'InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "671"')
,(N'FieldLabelResourceKeyConstants', N'RegisterNewSampleModalReportSessionIDFieldLabel', N'InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "900"')
,(N'FieldLabelResourceKeyConstants', N'RegisterNewSampleModalPatientFarmFieldLabel', N'InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "1823"')
,(N'FieldLabelResourceKeyConstants', N'RegisterNewSampleModalCollectionDateFieldLabel', N'InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "873"')
,(N'FieldLabelResourceKeyConstants', N'RegisterNewSampleModalSpeciesFieldLabel', N'InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "366"')
,(N'FieldLabelResourceKeyConstants', N'RegisterNewSampleModalSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "365"')
,(N'FieldLabelResourceKeyConstants', N'RegisterNewSampleModalNumberOfSamplesFieldLabel', N'InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "1824"')
,(N'FieldLabelResourceKeyConstants', N'RegisterNewSampleModalDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.RegisterNewSampleModal + "71"')

--        //LUC11 - Edit a Sample
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalReportSessionIDFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "900"')

,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalLocalFieldSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "669"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalSampleStatusFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "670"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalReasonforDeletionFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "902"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalLabSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "668"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "365"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalAccessionDateTimeFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "903"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalSampleStatusCommentFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "909"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalCollectionDateFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "873"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalEnteredDateFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "854"')

,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalStorageLocationFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "910"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalFunctionalAreaFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "921"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalOriginalSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "927"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalReportSessionTypeFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "671"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalPatientSpeciesVectorInfoFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "970"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalTestsCountFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "971"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalOrganizationSentToFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "675"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalCollectedByInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "1118"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalCollectedByOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "1119"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalDestructionMethodFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "972"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalNotesFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "973"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalFreezerFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "2798"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalBuildingFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "31"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalRoomFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "1831"')

--        //LUC12 - Edit a Test
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "71"')

,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalTestNameFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "370"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalTestStatusFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "679"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalTestResultFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "371"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalTestStartedDateFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "886"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalResultDateFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "881"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalTestCategoryFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "369"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalTestedByFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "879"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalResultsEnteredByFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "974"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalValidatedByFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "1135"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalExternalResultsFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "980"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalResultsReceivedFromFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "678"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalDateResultReceivedFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "981"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalPointofContactFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "982"')

--        //TODO - add notes field - already one on this modal - what to do?
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalBatchIDFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "878"')

,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalBatchStatusFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "983"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalReagentLotNumberFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "984"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySampleTestDetailsModalPositiveControlLotNumberFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "985"')

--        //LUC13 - Search for a Sample
,(N'FieldLabelResourceKeyConstants', N'LaboratorySamplesFilterFieldLabel', N'InterfaceEditorResourceSetEnum.Samples + "698"')

,(N'FieldLabelResourceKeyConstants', N'LaboratorySamplesTestNotAssignedFieldLabel', N'InterfaceEditorResourceSetEnum.Samples + "666"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySamplesTestCompleteFieldLabel', N'InterfaceEditorResourceSetEnum.Samples + "667"')
,(N'FieldLabelResourceKeyConstants', N'LaboratoryAdvancedSearchLaboratorySampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "668"')
,(N'FieldLabelResourceKeyConstants', N'LaboratoryAdvancedSearchLocalFieldSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "669"')
,(N'FieldLabelResourceKeyConstants', N'LaboratoryAdvancedSearchSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "365"')
,(N'FieldLabelResourceKeyConstants', N'LaboratoryAdvancedSearchSampleStatusFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "670"')
,(N'FieldLabelResourceKeyConstants', N'LaboratoryAdvancedSearchDateFromFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "404"')
,(N'FieldLabelResourceKeyConstants', N'LaboratoryAdvancedSearchDateToFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "446"')
,(N'FieldLabelResourceKeyConstants', N'LaboratoryAdvancedSearchReportSessionTypeFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "671"')
,(N'FieldLabelResourceKeyConstants', N'LaboratoryAdvancedSearchSurveillanceTypeFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "443"')
,(N'FieldLabelResourceKeyConstants', N'LaboratoryAdvancedSearchReportSessionCampaignIDFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "672"')
,(N'FieldLabelResourceKeyConstants', N'LaboratoryAdvancedSearchDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "71"')
,(N'FieldLabelResourceKeyConstants', N'LaboratoryAdvancedSearchPersonFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "673"')
,(N'FieldLabelResourceKeyConstants', N'LaboratoryAdvancedSearchFarmOwnerFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "674"')
,(N'FieldLabelResourceKeyConstants', N'LaboratoryAdvancedSearchSpeciesFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "366"')
,(N'FieldLabelResourceKeyConstants', N'LaboratoryAdvancedSearchOrganizationSentToFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "675"')
,(N'FieldLabelResourceKeyConstants', N'LaboratoryAdvancedSearchOrganizationTransferredToFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "676"')
,(N'FieldLabelResourceKeyConstants', N'LaboratoryAdvancedSearchTransferIDFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "677"')
,(N'FieldLabelResourceKeyConstants', N'LaboratoryAdvancedSearchResultsReceivedFromFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "678"')
,(N'FieldLabelResourceKeyConstants', N'LaboratoryAdvancedSearchTestNameFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "370"')
,(N'FieldLabelResourceKeyConstants', N'LaboratoryAdvancedSearchTestStatusFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "679"')
,(N'FieldLabelResourceKeyConstants', N'LaboratoryAdvancedSearchTestResultFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "371"')
,(N'FieldLabelResourceKeyConstants', N'LaboratoryAdvancedSearchTestResultDateFromFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "2768"')
,(N'FieldLabelResourceKeyConstants', N'LaboratoryAdvancedSearchTestResultDateToFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "2769"')
,(N'FieldLabelResourceKeyConstants', N'LaboratoryAdvancedSearchModalUnaccessionedFieldLabel', N'InterfaceEditorResourceSetEnum.LaboratoryAdvancedSearchModal + "2775"')

--        //LUC15 - Lab Record Deletion
,(N'FieldLabelResourceKeyConstants', N'LaboratorySamplesLabSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.Samples + "668"')

,(N'FieldLabelResourceKeyConstants', N'LaboratorySamplesSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.Samples + "365"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySamplesPatientFarmOwnerFieldLabel', N'InterfaceEditorResourceSetEnum.Samples + "994"')
,(N'FieldLabelResourceKeyConstants', N'LaboratorySamplesReasonForDeletionFieldLabel', N'InterfaceEditorResourceSetEnum.Samples + "902"')

--        //LUC22 - Search for a Freezer
,(N'FieldLabelResourceKeyConstants', N'FreezerAdvancedSearchModalFreezerNameFieldLabel', N'InterfaceEditorResourceSetEnum.FreezerAdvancedSearchModal + "1830"')

,(N'FieldLabelResourceKeyConstants', N'FreezerAdvancedSearchModalBuildingFieldLabel', N'InterfaceEditorResourceSetEnum.FreezerAdvancedSearchModal + "31"')
,(N'FieldLabelResourceKeyConstants', N'FreezerAdvancedSearchModalNoteFieldLabel', N'InterfaceEditorResourceSetEnum.FreezerAdvancedSearchModal + "145"')
,(N'FieldLabelResourceKeyConstants', N'FreezerAdvancedSearchModalRoomFieldLabel', N'InterfaceEditorResourceSetEnum.FreezerAdvancedSearchModal + "1831"')
,(N'FieldLabelResourceKeyConstants', N'FreezerAdvancedSearchModalStorageTypeFieldLabel', N'InterfaceEditorResourceSetEnum.FreezerAdvancedSearchModal + "1832"')

--        //LUC20 - Configure Storage Schema and LUC23 - Edit Sample Storage Schema
,(N'FieldLabelResourceKeyConstants', N'FreezerDetailsFreezerNameFieldLabel', N'InterfaceEditorResourceSetEnum.FreezerDetails + "1830"')

,(N'FieldLabelResourceKeyConstants', N'FreezerDetailsBuildingFieldLabel', N'InterfaceEditorResourceSetEnum.FreezerDetails + "31"')
,(N'FieldLabelResourceKeyConstants', N'FreezerDetailsFreezerNotesFieldLabel', N'InterfaceEditorResourceSetEnum.FreezerDetails + "973"')
,(N'FieldLabelResourceKeyConstants', N'FreezerDetailsRoomFieldLabel', N'InterfaceEditorResourceSetEnum.FreezerDetails + "1831"')
,(N'FieldLabelResourceKeyConstants', N'FreezerDetailsStorageTypeFieldLabel', N'InterfaceEditorResourceSetEnum.FreezerDetails + "1832"')
,(N'FieldLabelResourceKeyConstants', N'FreezerDetailsFreezerBarcodeFieldLabel', N'InterfaceEditorResourceSetEnum.FreezerDetails + "1833"')
,(N'FieldLabelResourceKeyConstants', N'FreezerDetailsSubdivisionNameFieldLabel', N'InterfaceEditorResourceSetEnum.FreezerDetails + "1834"')
,(N'FieldLabelResourceKeyConstants', N'FreezerDetailsSubdivisionTypeFieldLabel', N'InterfaceEditorResourceSetEnum.FreezerDetails + "1835"')
,(N'FieldLabelResourceKeyConstants', N'FreezerDetailsNumberofLocationsFieldLabel', N'InterfaceEditorResourceSetEnum.FreezerDetails + "1836"')
,(N'FieldLabelResourceKeyConstants', N'FreezerDetailsBoxSizeFieldLabel', N'InterfaceEditorResourceSetEnum.FreezerDetails + "1837"')
,(N'FieldLabelResourceKeyConstants', N'FreezerDetailsSubdivisionBarcodeFieldLabel', N'InterfaceEditorResourceSetEnum.FreezerDetails + "1838"')
,(N'FieldLabelResourceKeyConstants', N'FreezerDetailsShelfNotesFieldLabel', N'InterfaceEditorResourceSetEnum.Shelf + "973"')
,(N'FieldLabelResourceKeyConstants', N'FreezerDetailsRackNotesFieldLabel', N'InterfaceEditorResourceSetEnum.Rack + "973"')
,(N'FieldLabelResourceKeyConstants', N'FreezerDetailsBoxNotesFieldLabel', N'InterfaceEditorResourceSetEnum.Box + "973"')

--endregion Laboratory Module Resources

--region Outbreak Module Resources

--        //OMUC01 - Create Outbreak Session/OMUC02 - Edit Outbreak Session
,(N'FieldLabelResourceKeyConstants', N'OutbreakSessionOutbreakIDFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakSession + "969"')

,(N'FieldLabelResourceKeyConstants', N'OutbreakSessionStartDateFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakSession + "441"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakSessionEndDateFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakSession + "397"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakSessionTypeFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakSession + "201"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakSessionDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakSession + "71"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakSessionStatusFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakSession + "575"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakSessionLocationFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakSession + "975"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakSessionOutbreakManagementFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakSession + "976"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakManagementListAdvancedSearchFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakManagementList + "988"')
,(N'FieldLabelResourceKeyConstants', N'CreateOutbreakHumanFieldLabel', N'InterfaceEditorResourceSetEnum.CreateOutbreak + "1002"')
,(N'FieldLabelResourceKeyConstants', N'CreateOutbreakAvianFieldLabel', N'InterfaceEditorResourceSetEnum.CreateOutbreak + "1003"')
,(N'FieldLabelResourceKeyConstants', N'CreateOutbreakLivestockFieldLabel', N'InterfaceEditorResourceSetEnum.CreateOutbreak + "1004"')
,(N'FieldLabelResourceKeyConstants', N'CreateOutbreakVectorFieldLabel', N'InterfaceEditorResourceSetEnum.CreateOutbreak + "1005"')
,(N'FieldLabelResourceKeyConstants', N'CreateOutbreakSpeciesAffectedFieldLabel', N'InterfaceEditorResourceSetEnum.CreateOutbreak + "1007"')
,(N'FieldLabelResourceKeyConstants', N'CreateOutbreakFrequencyFieldLabel', N'InterfaceEditorResourceSetEnum.CreateOutbreak + "1008"')
,(N'FieldLabelResourceKeyConstants', N'CreateOutbreakDurationFieldLabel', N'InterfaceEditorResourceSetEnum.CreateOutbreak + "1009"')
,(N'FieldLabelResourceKeyConstants', N'CreateOutbreakContactTracingFieldLabel', N'InterfaceEditorResourceSetEnum.CreateOutbreak + "1012"')
,(N'FieldLabelResourceKeyConstants', N'CreateOutbreakCaseMonitoringFieldLabel', N'InterfaceEditorResourceSetEnum.CreateOutbreak + "1013"')
,(N'FieldLabelResourceKeyConstants', N'CreateOutbreakContactTracingDurationFieldLabel', N'InterfaceEditorResourceSetEnum.CreateOutbreak + "2773"')
,(N'FieldLabelResourceKeyConstants', N'CreateOutbreakTypeOfCaseFieldLabel', N'InterfaceEditorResourceSetEnum.CreateOutbreak + "1840"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakCasesTotalCasesFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakCases + "765"')

,(N'FieldLabelResourceKeyConstants', N'CaseMonitoringDetailsModalMonitoringDateFieldLabel', N'InterfaceEditorResourceSetEnum.CaseMonitoringDetailsModal + "3538"')
,(N'FieldLabelResourceKeyConstants', N'CaseMonitoringDetailsModalAdditionalCommentsFieldLabel', N'InterfaceEditorResourceSetEnum.CaseMonitoringDetailsModal + "3539"')
,(N'FieldLabelResourceKeyConstants', N'CaseMonitoringDetailsModalInvestigatorOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.CaseMonitoringDetailsModal + "3201"')
,(N'FieldLabelResourceKeyConstants', N'CaseMonitoringDetailsModalInvestigatorNameFieldLabel', N'InterfaceEditorResourceSetEnum.CaseMonitoringDetailsModal + "2474"')

--        //OMUC03 - Import Disease Report
,(N'FieldLabelResourceKeyConstants', N'OutbreakCasesHumanFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakCases + "1002"')

,(N'FieldLabelResourceKeyConstants', N'OutbreakCasesVeterinaryFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakCases + "3619"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakCasesAvianFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakCases + "1003"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakCasesLivestockFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakCases + "1004"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakCasesVectorFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakCases + "1005"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakCasesCaseFollowupsFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakCases + "2763"')

--        //OMUC04 - Enter Human Case
,(N'FieldLabelResourceKeyConstants', N'CreateHumanCaseTypeOfCaseFieldLabel', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "1840"')

,(N'FieldLabelResourceKeyConstants', N'CreateHumanCasePersonIDFieldLabel', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "871"')
,(N'FieldLabelResourceKeyConstants', N'CreateHumanCaseNameFieldLabel', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "608"')
,(N'FieldLabelResourceKeyConstants', N'CreateHumanCaseCaseClassificationFieldLabel', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "387"')
,(N'FieldLabelResourceKeyConstants', N'CreateHumanCaseDateEnteredFieldLabel', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "854"')
,(N'FieldLabelResourceKeyConstants', N'CreateHumanCaseDateLastUpdatedFieldLabel', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "1083"')
,(N'FieldLabelResourceKeyConstants', N'CreateHumanCaseOutbreakDetailsFieldLabel', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "1847"')
,(N'FieldLabelResourceKeyConstants', N'CreateHumanCaseOutbreakIDFieldLabel', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "969"')
,(N'FieldLabelResourceKeyConstants', N'CreateHumanCaseStartDateFieldLabel', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "441"')
,(N'FieldLabelResourceKeyConstants', N'CreateHumanCaseEndDateFieldLabel', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "397"')
,(N'FieldLabelResourceKeyConstants', N'CreateHumanCaseDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "71"')
,(N'FieldLabelResourceKeyConstants', N'CreateHumanCaseOutbreakStatusFieldLabel', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "1852"')
,(N'FieldLabelResourceKeyConstants', N'CreateHumanCaseOutbreakTypeFieldLabel', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "1853"')
,(N'FieldLabelResourceKeyConstants', N'CreateHumanCasePrimaryCaseFieldLabel', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "3202"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakCaseClinicalInformationInvestigatorNameFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakCaseClinicalInformation + "2474"')
,(N'FieldLabelResourceKeyConstants', N'CreateHumanCaseInvestigatorOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "3201"')
,(N'FieldLabelResourceKeyConstants', N'CreateHumanCaseInvestigatorNameFieldLabel', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "2474"')
,(N'FieldLabelResourceKeyConstants', N'CreateHumanCaseDateofDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "4540"')
,(N'FieldLabelResourceKeyConstants', N'CreateHumanCaseDateOfNotificationFieldLabel', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "1087"')
,(N'FieldLabelResourceKeyConstants', N'CreateHumanCaseLastUpdatedFieldLabel', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "4802"')
,(N'FieldLabelResourceKeyConstants', N'CreateHumanCaseListofSymptomsFieldLabel', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "4803"')

--        //OMUC06 - Enter Veterinary Case
,(N'FieldLabelResourceKeyConstants', N'CreateVeterinaryCaseFarmIDFieldLabel', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "2403"')

,(N'FieldLabelResourceKeyConstants', N'CreateVeterinaryCaseTypeOfCaseFieldLabel', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "1840"')

,(N'FieldLabelResourceKeyConstants', N'CreateVeterinaryCaseNameFieldLabel', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "608"')
,(N'FieldLabelResourceKeyConstants', N'CreateVeterinaryCaseDateEnteredFieldLabel', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "854"')
,(N'FieldLabelResourceKeyConstants', N'CreateVeterinaryCaseDateLastUpdatedFieldLabel', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "1083"')
,(N'FieldLabelResourceKeyConstants', N'CreateVeterinaryCaseOutbreakIDFieldLabel', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "969"')
,(N'FieldLabelResourceKeyConstants', N'CreateVeterinaryCaseStartDateFieldLabel', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "441"')
,(N'FieldLabelResourceKeyConstants', N'CreateVeterinaryCaseEndDateFieldLabel', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "397"')
,(N'FieldLabelResourceKeyConstants', N'CreateVeterinaryCaseDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "71"')
,(N'FieldLabelResourceKeyConstants', N'CreateVeterinaryCaseOutbreakStatusFieldLabel', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "1852"')
,(N'FieldLabelResourceKeyConstants', N'CreateVeterinaryCaseOutbreakTypeFieldLabel', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "1853"')

,(N'FieldLabelResourceKeyConstants', N'CreateVeterinaryCaseDateOfNotificationFieldLabel', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "1087"')
,(N'FieldLabelResourceKeyConstants', N'CreateVeterinaryCaseNotificationSentByFacilityFieldLabel', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "1089"')
,(N'FieldLabelResourceKeyConstants', N'CreateVeterinaryCaseNotificationSentByNameFieldLabel', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "1090"')
,(N'FieldLabelResourceKeyConstants', N'CreateVeterinaryCaseNotificationReceivedByFacilityFieldLabel', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "1091"')
,(N'FieldLabelResourceKeyConstants', N'CreateVeterinaryCaseNotificationReceivedByNameFieldLabel', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "1092"')
,(N'FieldLabelResourceKeyConstants', N'CreateVeterinaryCaseStartingDateOfInvestigationFieldLabel', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3200"')
,(N'FieldLabelResourceKeyConstants', N'CreateVeterinaryCaseInvestigatorOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3201"')
,(N'FieldLabelResourceKeyConstants', N'CreateVeterinaryCaseInvestigatorNameFieldLabel', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "2474"')
,(N'FieldLabelResourceKeyConstants', N'CreateVeterinaryCaseCaseClassificationFieldLabel', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "387"')
,(N'FieldLabelResourceKeyConstants', N'CreateVeterinaryCasePrimaryCaseFieldLabel', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3202"')
,(N'FieldLabelResourceKeyConstants', N'CreateVeterinaryCaseCaseStatusFieldLabel', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3203"')

--        //OMUC08-1 - Search Outbreaks
,(N'FieldLabelResourceKeyConstants', N'SearchOutbreaksStartDateFromFieldLabel', N'InterfaceEditorResourceSetEnum.SearchOutbreaks + "2720"')

,(N'FieldLabelResourceKeyConstants', N'SearchOutbreaksStartDateToFieldLabel', N'InterfaceEditorResourceSetEnum.SearchOutbreaks + "2721"')
,(N'FieldLabelResourceKeyConstants', N'SearchOutbreaksOutbreakIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchOutbreaks + "969"')
,(N'FieldLabelResourceKeyConstants', N'SearchOutbreaksTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchOutbreaks + "201"')
,(N'FieldLabelResourceKeyConstants', N'SearchOutbreaksDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.SearchOutbreaks + "71"')
,(N'FieldLabelResourceKeyConstants', N'SearchOutbreaksStatusFieldLabel', N'InterfaceEditorResourceSetEnum.SearchOutbreaks + "575"')
,(N'FieldLabelResourceKeyConstants', N'SearchOutbreaksSearchboxFieldLabel', N'InterfaceEditorResourceSetEnum.SearchOutbreaks + "2687"')
,(N'FieldLabelResourceKeyConstants', N'SearchOutbreaksStartDateFieldLabel', N'InterfaceEditorResourceSetEnum.SearchOutbreaks + "441"')

--        //OMUC11 - Edit a Contact
,(N'FieldLabelResourceKeyConstants', N'OutbreakContactsLastNameFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "414"')

,(N'FieldLabelResourceKeyConstants', N'OutbreakContactsFirstNameFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "402"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakContactsMiddleNameFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "416"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakContactsDateOfBirthFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "1399"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakContactsAgeFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "1070"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakContactsGenderFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "345"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakContactsCitizenshipFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "1071"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakContactsDetailsOfLastContactFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "2681"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakContactsPhoneFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "206"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakContactsContactStatusFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "2682"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakContactsRelationFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "1066"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakContactsDateOfLastContactFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "1067"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakContactsPlaceOfLastContactFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "1068"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakContactsEIDSSFarmIDFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "2683"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakContactsDateOfLastFollowupFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "2684"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakContactsCurrentLocationFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "2685"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakContactsTodaysFollowupsFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "2686"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakContactsSearchboxFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "2687"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakContactsNameFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "608"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakContactsFarmNameFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "2430"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakContactsAddressFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "1155"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakContactsCountryFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "47"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakContactsForeignAddressFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "83"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakContactsTotalContactsFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "3617"')

--        //OMUC12 - Enter Outbreak Vector
,(N'FieldLabelResourceKeyConstants', N'CreateVectorSessionCaseFieldSessionIDFieldLabel', N'InterfaceEditorResourceSetEnum.CreateVectorSessionCase + "2580"')

,(N'FieldLabelResourceKeyConstants', N'CreateVectorSessionCaseAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.CreateVectorSessionCase + "949"')
,(N'FieldLabelResourceKeyConstants', N'CreateVectorSessionCaseAdministrativeLevel5FieldLabel', N'InterfaceEditorResourceSetEnum.CreateVectorSessionCase + "950"')
,(N'FieldLabelResourceKeyConstants', N'CreateVectorSessionCaseLatitudeFieldLabel', N'InterfaceEditorResourceSetEnum.CreateVectorSessionCase + "2418"')
,(N'FieldLabelResourceKeyConstants', N'CreateVectorSessionCaseLongitudeFieldLabel', N'InterfaceEditorResourceSetEnum.CreateVectorSessionCase + "2419"')

--        //OMUC13 - Enter Outbreak Update/OMUC14 - Edit Outbreak Update
,(N'FieldLabelResourceKeyConstants', N'OutbreakUpdatesUserNameFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakUpdates + "2667"')

,(N'FieldLabelResourceKeyConstants', N'OutbreakUpdatesTimesincepostedFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakUpdates + "2668"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakUpdatesDateTimeFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakUpdates + "2669"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakUpdatesRecordIDFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakUpdates + "2670"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakUpdatesEnteredbyFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakUpdates + "885"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakUpdatesOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakUpdates + "423"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakUpdatesPriorityFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakUpdates + "2673"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakUpdatesDateTimeStampFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakUpdates + "2674"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakUpdatesRecordTitleFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakUpdates + "2675"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakUpdatesRecordDetailsFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakUpdates + "2676"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakUpdatesUploadFileFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakUpdates + "924"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakUpdatesFileDescriptionFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakUpdates + "2678"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakUpdatesEmployeeNameFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakUpdates + "2757"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakCasesInfectedFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakCases + "2740"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakCasesIsolatedFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakCases + "2741"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakCasesDeceasedFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakCases + "2742"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakCasesRecoveredFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakCases + "2743"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakCasesDepopulatedFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakCases + "2744"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakCasesQuarantinedFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakCases + "2745"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakCasesVaccinatedFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakCases + "2746"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakCasesConfirmedCasesFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakCases + "2747"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakCasesProbableCasesFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakCases + "2748"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakCasesNotACasesFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakCases + "2749"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakCasesSuspectFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakCases + "2750"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakCasesClassificationFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakCases + "2751"')

--        //OMUC15 - Outbreak Analysis
,(N'FieldLabelResourceKeyConstants', N'OutbreakAnalysisTimeFrameFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakAnalysis + "2660"')

,(N'FieldLabelResourceKeyConstants', N'OutbreakAnalysisDateofSymptomsOnsetStartofSignsFromFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakAnalysis + "2661"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakAnalysisDateofSymptomsOnsetStartofSignsToFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakAnalysis + "2662"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakAnalysisEpiCurveFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakAnalysis + "2663"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakAnalysisSpeciesAffectedFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakAnalysis + "2664"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakAnalysisCaseClassificationFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakAnalysis + "2665"')
,(N'FieldLabelResourceKeyConstants', N'OutbreakAnalysisHeatMapFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakAnalysis + "2666"')

--        //OMUC - Common
,(N'FieldLabelResourceKeyConstants', N'OutbreakCaseSummaryRelatedToFieldLabel', N'InterfaceEditorResourceSetEnum.OutbreakCaseSummary + "1082"')

--endregion Outbreak Module Resources

--region Reports Module Resources

,(N'FieldLabelResourceKeyConstants', N'ActiveSurveillanceFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "377"')
,(N'FieldLabelResourceKeyConstants', N'AddSignatureFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "378"')
,(N'FieldLabelResourceKeyConstants', N'AgeFromYearsFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "379"')
,(N'FieldLabelResourceKeyConstants', N'AgeGroupYearsFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "380"')
,(N'FieldLabelResourceKeyConstants', N'AgeToYearsFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "381"')
,(N'FieldLabelResourceKeyConstants', N'AggregateActionsFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "382"')
,(N'FieldLabelResourceKeyConstants', N'AnalysisMethodFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "383"')
,(N'FieldLabelResourceKeyConstants', N'ArrangeRayonsAlphabeticallyFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "384"')
,(N'FieldLabelResourceKeyConstants', N'BaselineFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "385"')
,(N'FieldLabelResourceKeyConstants', N'CaseClassificationFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "387"')
,(N'FieldLabelResourceKeyConstants', N'CaseIDFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "388"')
,(N'FieldLabelResourceKeyConstants', N'CaseTypeFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "389"')
,(N'FieldLabelResourceKeyConstants', N'ConcordanceMoreThanFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "390"')
,(N'FieldLabelResourceKeyConstants', N'CounterFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "391"')
,(N'FieldLabelResourceKeyConstants', N'DateFieldSourceFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "392"')
,(N'FieldLabelResourceKeyConstants', N'DateFromFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "393"')
,(N'FieldLabelResourceKeyConstants', N'DateToFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "395"')
,(N'FieldLabelResourceKeyConstants', N'MoveDownFullViewFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "396"')
,(N'FieldLabelResourceKeyConstants', N'EndDateFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "397"')
,(N'FieldLabelResourceKeyConstants', N'EndIssueDateFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "398"')
,(N'FieldLabelResourceKeyConstants', N'ReportsFirstNameFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "402"')
,(N'FieldLabelResourceKeyConstants', N'FinalDiagnosisLabel', N'InterfaceEditorResourceSetEnum.Reports + "400"')
,(N'FieldLabelResourceKeyConstants', N'FirstYearFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "403"')
,(N'FieldLabelResourceKeyConstants', N'FromFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "404"')
,(N'FieldLabelResourceKeyConstants', N'FromMonthFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "405"')
,(N'FieldLabelResourceKeyConstants', N'FromYearFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "407"')
,(N'FieldLabelResourceKeyConstants', N'ReportsHospitalFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "408"')
,(N'FieldLabelResourceKeyConstants', N'IncludeSignatureFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "409"')
,(N'FieldLabelResourceKeyConstants', N'InitialDiagnosisFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "410"')
,(N'FieldLabelResourceKeyConstants', N'LabDepartmentFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "411"')
,(N'FieldLabelResourceKeyConstants', N'LagFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "412"')
,(N'FieldLabelResourceKeyConstants', N'LanguageFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "413"')
,(N'FieldLabelResourceKeyConstants', N'ReportsLastNameLabel', N'InterfaceEditorResourceSetEnum.Reports + "414"')
,(N'FieldLabelResourceKeyConstants', N'MaximizeScreenViewFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "415"')
,(N'FieldLabelResourceKeyConstants', N'ReportsMiddleNameLabel', N'InterfaceEditorResourceSetEnum.Reports + "416"')
,(N'FieldLabelResourceKeyConstants', N'MinimizeScreenViewFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "417"')
,(N'FieldLabelResourceKeyConstants', N'ReportsMonthLabel', N'InterfaceEditorResourceSetEnum.Reports + "418"')
,(N'FieldLabelResourceKeyConstants', N'NameOfInvestigationMeasureFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "419"')
,(N'FieldLabelResourceKeyConstants', N'NoneSelectedFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "420"')
,(N'FieldLabelResourceKeyConstants', N'ReportsNotificationReceivedFromFacilityFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "422"')
,(N'FieldLabelResourceKeyConstants', N'ReportsOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "423"')
,(N'FieldLabelResourceKeyConstants', N'PassiveSurveillanceFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "424"')
,(N'FieldLabelResourceKeyConstants', N'QuarterFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "425"')
,(N'FieldLabelResourceKeyConstants', N'RayonFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "426"')
,(N'FieldLabelResourceKeyConstants', N'Rayon1FieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "463"')
,(N'FieldLabelResourceKeyConstants', N'Rayon2FieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "427"')
,(N'FieldLabelResourceKeyConstants', N'RegionFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "428"')
,(N'FieldLabelResourceKeyConstants', N'Region1FieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "429"')
,(N'FieldLabelResourceKeyConstants', N'Region2FieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "430"')
,(N'FieldLabelResourceKeyConstants', N'ReportingPeriodFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "431"')
,(N'FieldLabelResourceKeyConstants', N'ReportingPeriodTypeFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "432"')
,(N'FieldLabelResourceKeyConstants', N'ReportNameFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "433"')
,(N'FieldLabelResourceKeyConstants', N'ReportTypeFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "434"')
,(N'FieldLabelResourceKeyConstants', N'ReportsSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "435"')
,(N'FieldLabelResourceKeyConstants', N'SecondYearFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "436"')
,(N'FieldLabelResourceKeyConstants', N'SelectAllFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "437"')
,(N'FieldLabelResourceKeyConstants', N'SelectedFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "438"')
,(N'FieldLabelResourceKeyConstants', N'SentToFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "439"')
,(N'FieldLabelResourceKeyConstants', N'ReportsSpeciesTypeFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "440"')
,(N'FieldLabelResourceKeyConstants', N'StartDateFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "441"')
,(N'FieldLabelResourceKeyConstants', N'StartIssueDateFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "442"')
,(N'FieldLabelResourceKeyConstants', N'SurveillanceTypeFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "443"')
,(N'FieldLabelResourceKeyConstants', N'ThresholdFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "444"')
,(N'FieldLabelResourceKeyConstants', N'TimeUnitFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "445"')
,(N'FieldLabelResourceKeyConstants', N'ToFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "446"')
,(N'FieldLabelResourceKeyConstants', N'ToMonthFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "447"')
,(N'FieldLabelResourceKeyConstants', N'ToYearFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "452"')
,(N'FieldLabelResourceKeyConstants', N'MoveUpReportViewFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "453"')
,(N'FieldLabelResourceKeyConstants', N'UseArchivedDataFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "454"')
,(N'FieldLabelResourceKeyConstants', N'YearFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "455"')
,(N'FieldLabelResourceKeyConstants', N'Year1FieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "456"')
,(N'FieldLabelResourceKeyConstants', N'Year2FieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "457"')

--        //localization fixes 11/22/2023
,(N'FieldLabelResourceKeyConstants', N'InitialDiagnosisValidationFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "4854"')
,(N'FieldLabelResourceKeyConstants', N'FinalDiagnosisValidationFieldLabel', N'InterfaceEditorResourceSetEnum.Reports + "4855"')

--        //SYSUC12 - Print Barcodes
,(N'FieldLabelResourceKeyConstants', N'PrintBarcodesDateFieldLabel', N'InterfaceEditorResourceSetEnum.PrintBarcodes + "763"')

,(N'FieldLabelResourceKeyConstants', N'PrintBarcodesPrefixFieldLabel', N'InterfaceEditorResourceSetEnum.PrintBarcodes + "2807"')
,(N'FieldLabelResourceKeyConstants', N'PrintBarcodesNumberOfLabelsToPrintFieldLabel', N'InterfaceEditorResourceSetEnum.PrintBarcodes + "2808"')
,(N'FieldLabelResourceKeyConstants', N'PrintBarcodesTypeOfBarcodeLabelFieldLabel', N'InterfaceEditorResourceSetEnum.PrintBarcodes + "2809"')

--endregion Reports Module Resources

--region Vector Module Resources

--        //VSUC01 - Enter Vector Surveillance Session and VSUC02 - Edit Vector Surevillance Session

--        //Session Summary Section
,(N'FieldLabelResourceKeyConstants', N'VectorSurveillanceSessionSessionIDFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSession + "808"')

,(N'FieldLabelResourceKeyConstants', N'VectorSurveillanceSessionFieldSessionIDFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSession + "2580"')
,(N'FieldLabelResourceKeyConstants', N'VectorSurveillanceSessionOutbreakIDFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSession + "969"')
,(N'FieldLabelResourceKeyConstants', N'VectorSurveillanceSessionStatusFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSession + "575"')
,(N'FieldLabelResourceKeyConstants', N'VectorSurveillanceSessionStartDateFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSession + "441"')
,(N'FieldLabelResourceKeyConstants', N'VectorSurveillanceSessionCloseDateFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSession + "2593"')
,(N'FieldLabelResourceKeyConstants', N'VectorSurveillanceSessionDescriptionFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSession + "486"')
,(N'FieldLabelResourceKeyConstants', N'VectorSurveillanceSessionVectorTypesFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSession + "2594"')
,(N'FieldLabelResourceKeyConstants', N'VectorSurveillanceSessionDiseasesFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSession + "2595"')
,(N'FieldLabelResourceKeyConstants', N'VectorSurveillanceSessionCollectionEffortFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSession + "2596"')

--        //Session Location Section
,(N'FieldLabelResourceKeyConstants', N'VectorSurveillanceSessionSessionLocationTypeFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSessionSessionLocation + "2597"')

,(N'FieldLabelResourceKeyConstants', N'VectorSurveillanceSessionSessionLocationAdministrativeLevel0FieldLabel', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSessionSessionLocation + "47"')
,(N'FieldLabelResourceKeyConstants', N'VectorSurveillanceSessionSessionLocationAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSessionSessionLocation + "428"')
,(N'FieldLabelResourceKeyConstants', N'VectorSurveillanceSessionSessionLocationAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSessionSessionLocation + "426"')
,(N'FieldLabelResourceKeyConstants', N'VectorSurveillanceSessionSessionLocationAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSessionSessionLocation + "248"')
,(N'FieldLabelResourceKeyConstants', N'VectorSurveillanceSessionSessionLocationAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSessionSessionLocation + "949"')
,(N'FieldLabelResourceKeyConstants', N'VectorSurveillanceSessionSessionLocationAdministrativeLevel5FieldLabel', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSessionSessionLocation + "950"')
,(N'FieldLabelResourceKeyConstants', N'VectorSurveillanceSessionSessionLocationAdministrativeLevel6FieldLabel', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSessionSessionLocation + "951"')
,(N'FieldLabelResourceKeyConstants', N'VectorSurveillanceSessionSessionLocationSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSessionSessionLocation + "249"')
,(N'FieldLabelResourceKeyConstants', N'VectorSurveillanceSessionSessionLocationLatitudeFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSessionSessionLocation + "2418"')
,(N'FieldLabelResourceKeyConstants', N'VectorSurveillanceSessionSessionLocationLongitudeFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSessionSessionLocation + "2419"')
,(N'FieldLabelResourceKeyConstants', N'VectorSurveillanceSessionSessionLocationDescriptionFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSessionSessionLocation + "486"')
,(N'FieldLabelResourceKeyConstants', N'VectorSurveillanceSessionSessionLocationGroundTypeFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSessionSessionLocation + "2598"')
,(N'FieldLabelResourceKeyConstants', N'VectorSurveillanceSessionSessionLocationDistanceFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSessionSessionLocation + "2599"')
,(N'FieldLabelResourceKeyConstants', N'VectorSurveillanceSessionSessionLocationDirectionFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSessionSessionLocation + "2600"')
,(N'FieldLabelResourceKeyConstants', N'VectorSurveillanceSessionSessionLocationAddressFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSessionSessionLocation + "2570"')

--        //Detailed Collections
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionCollectedByInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "1118"')

,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionSpeciesFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "366"')
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "71"')
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionFieldSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "870"')
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "365"')
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionResultDateFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "881"')
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionTestNameFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "370"')
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionTestResultFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "371"')

--        //Copy Detailed Collection Indicators
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionCollectionDataFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "2603"')

,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionVectorDataFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "2604"')
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionSamplesFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "2605"')
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionFieldTestsFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollection + "2606"')

--        //Surveillance Session Collection Data and Location
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataPoolVectorIDFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "2617"')

,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataFieldPoolVectorIDFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "2618"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataVectorTypeFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "374"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataCollectionLocationTypeFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "2619"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataAdministrativeLevel0FieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "47"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "428"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "426"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "248"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "949"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataAdministrativeLevel5FieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "950"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataAdministrativeLevel6FieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "951"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "249"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataLatitudeFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "2418"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataLongitudeFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "2419"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataDescriptionFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "486"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataGroundTypeFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "2598"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataDistanceFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "2599"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataDirectionFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "2600"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataAddressFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "2570"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataElevationMetersFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "2620"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataSurroundingsFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "2621"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataGEOReferenceSourceFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "2622"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataBasisOfRecordFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "2623"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataHostReferenceFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "2624"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataCollectedByInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "1118"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataCollectorFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "2625"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataCollectionDateFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "873"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataCollectionTimeFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "2626"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataCollectionMethodFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "478"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionCollectionDataEctoparasitesCollectedFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionCollectionData + "2627"')

--        //Surveillance Session Vector Data
,(N'FieldLabelResourceKeyConstants', N'VectorSessionVectorDataQuantityFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionVectorData + "2628"')

,(N'FieldLabelResourceKeyConstants', N'VectorSessionVectorDataSpeciesFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionVectorData + "366"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionVectorDataSexFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionVectorData + "2496"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionVectorDataIdentifiedByInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionVectorData + "2629"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionVectorDataIdentifiedByFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionVectorData + "2630"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionVectorDataIdentifyingMethodFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionVectorData + "2631"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionVectorDataIdentifyingDateFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionVectorData + "2632"')
,(N'FieldLabelResourceKeyConstants', N'VectorSessionVectorDataCommentFieldLabel', N'InterfaceEditorResourceSetEnum.VectorSessionVectorData + "767"')

--        //Detailed Collection Sample Details
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionSampleDetailsModalFieldSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionSampleDetailsModal + "870"')

,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionSampleDetailsModalSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionSampleDetailsModal + "365"')
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionSampleDetailsModalDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionSampleDetailsModal + "71"')
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionSampleDetailsModalCollectionDateFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionSampleDetailsModal + "873"')
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionSampleDetailsModalSentToOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionSampleDetailsModal + "875"')
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionSampleDetailsModalCollectedByInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionSampleDetailsModal + "1118"')
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionSampleDetailsModalCommentFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionSampleDetailsModal + "767"')
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionSampleDetailsModalAccessionDateFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionSampleDetailsModal + "1121"')
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionSampleDetailsModalSampleConditionReceivedFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionSampleDetailsModal + "1122"')

--        //Detailed Collection Field Test Details
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionFieldTestDetailsModalFieldSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionFieldTestDetailsModal + "870"')

,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionFieldTestDetailsModalSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionFieldTestDetailsModal + "365"')
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionFieldTestDetailsModalTestNameFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionFieldTestDetailsModal + "370"')
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionFieldTestDetailsModalTestCategoryFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionFieldTestDetailsModal + "369"')
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionFieldTestDetailsModalTestedByInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionFieldTestDetailsModal + "2635"')
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionFieldTestDetailsModalTestedByFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionFieldTestDetailsModal + "879"')
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionFieldTestDetailsModalTestResultFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionFieldTestDetailsModal + "371"')
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionFieldTestDetailsModalResultDateFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionFieldTestDetailsModal + "881"')
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionFieldTestDetailsModalDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionFieldTestDetailsModal + "71"')
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionFieldTestDetailsModalCollectionDateFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionFieldTestDetailsModal + "873"')

--        //Detailed Collection Laboratory Tests Sub-Row
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionLaboratoryTestsCollectionDateFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionLaboratoryTests + "873"')

,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionLaboratoryTestsTestCategoryFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionLaboratoryTests + "369"')
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionLaboratoryTestsTestedByInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionLaboratoryTests + "2635"')
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionLaboratoryTestsTestedByFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionLaboratoryTests + "879"')
,(N'FieldLabelResourceKeyConstants', N'VectorDetailedCollectionLaboratoryTestsAmendmentHistoryFieldLabel', N'InterfaceEditorResourceSetEnum.VectorDetailedCollectionLaboratoryTests + "2363"')

--        //Aggregate Collection
,(N'FieldLabelResourceKeyConstants', N'VectorAggregateCollectionRecordIDFieldLabel', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "2670"')

,(N'FieldLabelResourceKeyConstants', N'VectorAggregateCollectionCollectionDateFieldLabel', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "873"')
,(N'FieldLabelResourceKeyConstants', N'VectorAggregateCollectionVectorTypeFieldLabel', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "374"')
,(N'FieldLabelResourceKeyConstants', N'VectorAggregateCollectionSpeciesFieldLabel', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "366"')
,(N'FieldLabelResourceKeyConstants', N'VectorAggregateCollectionSexFieldLabel', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "2496"')
,(N'FieldLabelResourceKeyConstants', N'VectorAggregateCollectionNumberOfPoolsVectorsCollectedFieldLabel', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "2640"')

--        //Aggregate Collection Data and Location
,(N'FieldLabelResourceKeyConstants', N'VectorAggregateCollectionCollectionLocationTypeFieldLabel', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "2619"')

,(N'FieldLabelResourceKeyConstants', N'VectorAggregateCollectionAdministrativeLevel0FieldLabel', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "47"')
,(N'FieldLabelResourceKeyConstants', N'VectorAggregateCollectionAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "428"')
,(N'FieldLabelResourceKeyConstants', N'VectorAggregateCollectionAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "426"')
,(N'FieldLabelResourceKeyConstants', N'VectorAggregateCollectionAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "248"')
,(N'FieldLabelResourceKeyConstants', N'VectorAggregateCollectionAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "949"')
,(N'FieldLabelResourceKeyConstants', N'VectorAggregateCollectionAdministrativeLevel5FieldLabel', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "950"')
,(N'FieldLabelResourceKeyConstants', N'VectorAggregateCollectionAdministrativeLevel6FieldLabel', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "951"')
,(N'FieldLabelResourceKeyConstants', N'VectorAggregateCollectionSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "249"')
,(N'FieldLabelResourceKeyConstants', N'VectorAggregateCollectionLatitudeFieldLabel', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "2418"')
,(N'FieldLabelResourceKeyConstants', N'VectorAggregateCollectionLongitudeFieldLabel', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "2419"')
,(N'FieldLabelResourceKeyConstants', N'VectorAggregateCollectionDescriptionFieldLabel', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "486"')
,(N'FieldLabelResourceKeyConstants', N'VectorAggregateCollectionGroundTypeFieldLabel', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "2598"')
,(N'FieldLabelResourceKeyConstants', N'VectorAggregateCollectionDistanceFieldLabel', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "2599"')
,(N'FieldLabelResourceKeyConstants', N'VectorAggregateCollectionDirectionFieldLabel', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "2600"')
,(N'FieldLabelResourceKeyConstants', N'VectorAggregateCollectionAddressFieldLabel', N'InterfaceEditorResourceSetEnum.VectorAggregateCollection + "2570"')

--        //VSUC03 - Search for Vector Surveillance Session
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVectorSurveillanceSessionsSessionIDFieldLabel', N'"808"')

,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVectorSurveillanceSessionsFieldSessionIDFieldLabel', N'"2580"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVectorSurveillanceSessionsStartDateFromFieldLabel', N'"2581"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVectorSurveillanceSessionsStartDateToFieldLabel', N'"2582"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVectorSurveillanceSessionsCloseDateFromFieldLabel', N'"2583"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVectorSurveillanceSessionsCloseDateToFieldLabel', N'"2584"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVectorSurveillanceSessionsVectorTypeFieldLabel', N'"374"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVectorSurveillanceSessionsSpeciesFieldLabel', N'"366"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVectorSurveillanceSessionsDiseaseFieldLabel', N'"71"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVectorSurveillanceSessionsAdministrativeLevel1FieldLabel', N'"428"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVectorSurveillanceSessionsAdministrativeLevel2FieldLabel', N'"426"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVectorSurveillanceSessionsAdministrativeLevel3FieldLabel', N'"248"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVectorSurveillanceSessionsAdministrativeLevel4FieldLabel', N'"949"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVectorSurveillanceSessionsAdministrativeLevel5FieldLabel', N'"950"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVectorSurveillanceSessionsAdministrativeLevel6FieldLabel', N'"951"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVectorSurveillanceSessionsSettlementTypeFieldLabel', N'"249"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVectorSurveillanceSessionsLatitudeFieldLabel', N'"2418"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVectorSurveillanceSessionsLongitudeFieldLabel', N'"2419"')

,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsSessionIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "808"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsFieldSessionIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "2580"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsStartDateFromFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "2581"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsStartDateToFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "2582"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsCloseDateFromFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "2583"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsCloseDateToFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "2584"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsVectorTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "374"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsSpeciesFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "366"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "71"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "428"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "426"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "248"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "949"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsAdministrativeLevel5FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "950"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsAdministrativeLevel6FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "951"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "249"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsLatitudeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "2418"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsLongitudeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessions + "2419"')

,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsModalSessionIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessionsModal + "808"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsModalFieldSessionIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessionsModal + "2580"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsModalStartDateFromFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessionsModal + "2581"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsModalStartDateToFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessionsModal + "2582"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsModalCloseDateFromFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessionsModal + "2583"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsModalCloseDateToFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessionsModal + "2584"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsModalVectorTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessionsModal + "374"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsModalSpeciesFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessionsModal + "366"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsModalDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessionsModal + "71"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsModalAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessionsModal + "428"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsModalAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessionsModal + "426"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsModalAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessionsModal + "248"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsModalAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessionsModal + "949"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsModalAdministrativeLevel5FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessionsModal + "950"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsModalAdministrativeLevel6FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessionsModal + "951"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsModalSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessionsModal + "249"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsModalLatitudeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessionsModal + "2418"')
,(N'FieldLabelResourceKeyConstants', N'SearchVectorSurveillanceSessionsModalLongitudeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVectorSurveillanceSessionsModal + "2419"')

--endregion Vector Module Resources

--region Veterinary Module Resources

,(N'FieldLabelResourceKeyConstants', N'VeterinaryDiseaseReportVaccinationsTypeFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryDiseaseReportVaccinations + "201"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryDiseaseReportVaccinationsRouteFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryDiseaseReportVaccinations + "2487"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryDiseaseReportVaccinationsLotNumberFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryDiseaseReportVaccinations + "2488"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryDiseaseReportVaccinationsManufacturerFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryDiseaseReportVaccinations + "2489"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryDiseaseReportVaccinationsCommentsFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryDiseaseReportVaccinations + "874"')

,(N'FieldLabelResourceKeyConstants', N'VaccinationDetailsModalDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.VaccinationDetailsModal + "71"')
,(N'FieldLabelResourceKeyConstants', N'VaccinationDetailsModalDateFieldLabel', N'InterfaceEditorResourceSetEnum.VaccinationDetailsModal + "763"')
,(N'FieldLabelResourceKeyConstants', N'VaccinationDetailsModalSpeciesFieldLabel', N'InterfaceEditorResourceSetEnum.VaccinationDetailsModal + "366"')
,(N'FieldLabelResourceKeyConstants', N'VaccinationDetailsModalVaccinatedNumberFieldLabel', N'InterfaceEditorResourceSetEnum.VaccinationDetailsModal + "2490"')
,(N'FieldLabelResourceKeyConstants', N'VaccinationDetailsModalTypeFieldLabel', N'InterfaceEditorResourceSetEnum.VaccinationDetailsModal + "201"')
,(N'FieldLabelResourceKeyConstants', N'VaccinationDetailsModalRouteFieldLabel', N'InterfaceEditorResourceSetEnum.VaccinationDetailsModal + "2487"')
,(N'FieldLabelResourceKeyConstants', N'VaccinationDetailsModalLotNumberFieldLabel', N'InterfaceEditorResourceSetEnum.VaccinationDetailsModal + "2488"')
,(N'FieldLabelResourceKeyConstants', N'VaccinationDetailsModalManufacturerFieldLabel', N'InterfaceEditorResourceSetEnum.VaccinationDetailsModal + "2489"')
,(N'FieldLabelResourceKeyConstants', N'VaccinationDetailsModalCommentsFieldLabel', N'InterfaceEditorResourceSetEnum.VaccinationDetailsModal + "874"')

,(N'FieldLabelResourceKeyConstants', N'CaseLogDetailsModalActionRequiredFieldLabel', N'InterfaceEditorResourceSetEnum.CaseLogDetailsModal + "883"')
,(N'FieldLabelResourceKeyConstants', N'CaseLogDetailsModalDateFieldLabel', N'InterfaceEditorResourceSetEnum.CaseLogDetailsModal + "763"')
,(N'FieldLabelResourceKeyConstants', N'CaseLogDetailsModalEnteredByFieldLabel', N'InterfaceEditorResourceSetEnum.CaseLogDetailsModal + "885"')
,(N'FieldLabelResourceKeyConstants', N'CaseLogDetailsModalCommentFieldLabel', N'InterfaceEditorResourceSetEnum.CaseLogDetailsModal + "767"')
,(N'FieldLabelResourceKeyConstants', N'CaseLogDetailsModalStatusFieldLabel', N'InterfaceEditorResourceSetEnum.CaseLogDetailsModal + "575"')

--        //VASUC02 - Set Up Veterinary Active Surveillance Session and VASUC03 - Edit Veterinary Active Surveillance Session
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionDetailedInformationFarmIDFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2403"')

,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionDetailedInformationFarmNameFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2430"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionDetailedInformationFarmOwnerLastNameFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "414"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionDetailedInformationFarmOwnerFirstNameFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "402"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionDetailedInformationFarmOwnerMiddleNameFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "416"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionDetailedInformationFarmOwnerIDFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2407"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionDetailedInformationPhoneFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "206"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionDetailedInformationEmailFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2432"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionDetailedInformationNumberFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2533"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionDetailedInformationTotalNumberOfAnimalsSampledFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2534"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionDetailedInformationTotalNumberOfSamplesFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2535"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionDetailedInformationAgeFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "1070"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionDetailedInformationNameFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "608"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionDetailedInformationColorFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2537"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionDetailedInformationSexFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2496"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionDetailedInformationSampleConditionReceivedFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "1122"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionDetailedInformationCommentsFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "874"')

,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionFlockSpeciesFlockFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionSampleDetailsModal + "2986"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionHerdSpeciesHerdFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionSampleDetailsModal + "2987"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionSampleDetailsModalFarmIDFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionSampleDetailsModal + "2403"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionSampleDetailsModalSpeciesFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionSampleDetailsModal + "366"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionSampleDetailsModalSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionSampleDetailsModal + "365"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionSampleDetailsModalDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionSampleDetailsModal + "71"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionSampleDetailsModalAnimalIDFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionSampleDetailsModal + "2495"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionSampleDetailsModalFieldSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionSampleDetailsModal + "870"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionSampleDetailsModalAgeFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionSampleDetailsModal + "1070"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionSampleDetailsModalNameFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionSampleDetailsModal + "608"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionSampleDetailsModalColorFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionSampleDetailsModal + "2537"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionSampleDetailsModalSexFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionSampleDetailsModal + "2496"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionSampleDetailsModalCollectionDateFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionSampleDetailsModal + "873"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionSampleDetailsModalSampleConditionReceivedFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionSampleDetailsModal + "1122"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionSampleDetailsModalCommentsFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionSampleDetailsModal + "874"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionSampleDetailsModalSentToOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionSampleDetailsModal + "875"')

,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionInterpretationDetailsModalFarmIDFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionInterpretationDetailsModal + "2403"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionInterpretationDetailsModalSpeciesFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionInterpretationDetailsModal + "366"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionInterpretationDetailsModalAnimalIDFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionInterpretationDetailsModal + "2495"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionInterpretationDetailsModalDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionInterpretationDetailsModal + "71"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionInterpretationDetailsModalTestNameFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionInterpretationDetailsModal + "370"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionInterpretationDetailsModalTestCategoryFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionInterpretationDetailsModal + "369"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionInterpretationDetailsModalLabSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionInterpretationDetailsModal + "668"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionInterpretationDetailsModalSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionInterpretationDetailsModal + "365"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionInterpretationDetailsModalFieldSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionInterpretationDetailsModal + "870"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionInterpretationDetailsModalRuleOutRuleInFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionInterpretationDetailsModal + "1128"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionInterpretationDetailsModalCommentsRuleOutRuleInFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionInterpretationDetailsModal + "1129"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionInterpretationDetailsModalDateInterpretedFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionInterpretationDetailsModal + "1130"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionInterpretationDetailsModalInterpretedByFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionInterpretationDetailsModal + "1131"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionInterpretationDetailsModalValidatedFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionInterpretationDetailsModal + "1132"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionInterpretationDetailsModalCommentsValidatedFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionInterpretationDetailsModal + "1133"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionInterpretationDetailsModalDateValidatedFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionInterpretationDetailsModal + "1134"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionInterpretationDetailsModalValidatedByFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionInterpretationDetailsModal + "1135"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionInterpretationDetailsModalReportIDFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionInterpretationDetailsModal + "750"')

,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionAggregateInformationFarmIDFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2403"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionAggregateInformationFarmNameFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2430"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionAggregateInformationFarmOwnerLastNameFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "414"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionAggregateInformationFarmOwnerFirstNameFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "402"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionAggregateInformationFarmOwnerMiddleNameFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "416"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionAggregateInformationFarmOwnerIDFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2407"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionAggregateInformationPhoneFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "206"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionAggregateInformationEmailFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2432"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionAggregateInformationTotalNumberOfAnimalsSampledFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2534"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionAggregateInformationTotalNumberOfSamplesFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2535"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionAggregateInformationTotalNumberOfAnimalsWithPositiveReactionFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2536"')

,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionAggregateInformationDetailsModalFarmIDFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformationDetailsModal + "2403"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionAggregateInformationDetailsModalSpeciesFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformationDetailsModal + "366"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionAggregateInformationDetailsModalSexFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformationDetailsModal + "2496"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionAggregateInformationDetailsModalAnimalsSampledFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformationDetailsModal + "2545"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionAggregateInformationDetailsModalSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformationDetailsModal + "365"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionAggregateInformationDetailsModalNumberOfSamplesFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformationDetailsModal + "1824"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionAggregateInformationDetailsModalCollectionDateFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformationDetailsModal + "873"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionAggregateInformationDetailsModalPositiveNumberFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformationDetailsModal + "2544"')
,(N'FieldLabelResourceKeyConstants', N'VeterinarySessionAggregateInformationDetailsModalDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformationDetailsModal + "71"')

--        //VASUC04 - Search for Active Surveillance Campaign
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceCampaignsCampaignIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceCampaigns + "796"')

,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceCampaignsLegacyIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceCampaigns + "936"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceCampaignsCampaignNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceCampaigns + "797"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceCampaignsCampaignTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceCampaigns + "798"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceCampaignsCampaignStatusFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceCampaigns + "799"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceCampaignsCampaignStartDateRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceCampaigns + "800"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceCampaignsDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceCampaigns + "71"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceCampaignsCampaignEndDateFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceCampaigns + "828"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceCampaignsCampaignAdministratorFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceCampaigns + "829"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceCampaignsSpeciesFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceCampaigns + "366"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceCampaignsSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceCampaigns + "365"')

--        //VASUC05 - Search for Active Surveillance Session
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVeterinaryActiveSurveillanceSessionsSessionIDFieldLabel', N'"808"')

,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVeterinaryActiveSurveillanceSessionsLegacyIDFieldLabel', N'"936"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVeterinaryActiveSurveillanceSessionsSessionStatusFieldLabel', N'"809"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVeterinaryActiveSurveillanceSessionsDiseaseFieldLabel', N'"71"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVeterinaryActiveSurveillanceSessionsDateEnteredRangeFieldLabel', N'"811"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVeterinaryActiveSurveillanceSessionsAdministrativeLevel1FieldLabel', N'"428"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVeterinaryActiveSurveillanceSessionsAdministrativeLevel2FieldLabel', N'"426"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVeterinaryActiveSurveillanceSessionsAdministrativeLevel3FieldLabel', N'"248"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVeterinaryActiveSurveillanceSessionsSettlementTypeFieldLabel', N'"249"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVeterinaryActiveSurveillanceSessionsAdministrativeLevel4FieldLabel', N'"949"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVeterinaryActiveSurveillanceSessionsSessionEndDateFieldLabel', N'"851"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVeterinaryActiveSurveillanceSessionsSiteFieldLabel', N'"549"')
,(N'FieldLabelResourceKeyConstants', N'SharedComponentSearchVeterinaryActiveSurveillanceSessionsOfficerFieldLabel', N'"762"')

,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsSessionIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessions + "808"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsLegacyIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessions + "936"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsSessionStatusFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessions + "809"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessions + "71"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsDateEnteredRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessions + "811"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessions + "428"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessions + "426"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessions + "248"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessions + "249"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessions + "949"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsSessionEndDateFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessions + "851"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsSiteFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessions + "549"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessions + "762"')

,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsModalSessionIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessionsModal + "808"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsModalLegacyIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessionsModal + "936"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsModalSessionStatusFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessionsModal + "809"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsModalDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessionsModal + "71"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsModalDateEnteredRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessionsModal + "811"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsModalAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessionsModal + "428"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsModalAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessionsModal + "426"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsModalAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessionsModal + "248"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsModalSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessionsModal + "249"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsModalAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessionsModal + "949"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsModalSessionEndDateFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessionsModal + "851"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsModalSiteFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessionsModal + "549"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryActiveSurveillanceSessionsModalOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryActiveSurveillanceSessionsModal + "762"')

--        //VAUC05 - Enter Veterinary Aggregate Disease Report and VAUC06 - Edit Veterinary Aggregate Disease Report
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateDiseaseReportInformationNotificationSentByInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "761"')

,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateDiseaseReportInformationNotificationSentByOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "762"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateDiseaseReportInformationNotificationSentByDateFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "763"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateDiseaseReportInformationNotificationReceivedByInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "352"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateDiseaseReportInformationNotificationReceivedByOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "2799"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateDiseaseReportInformationNotificationReceivedByDateFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "3586"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateDiseaseReportInformationEnteredByInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "761"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateDiseaseReportInformationEnteredByOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "762"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateDiseaseReportInformationEnteredByDateFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "763"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateDiseaseReportInformationReportIDFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "750"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateDiseaseReportInformationYearFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "455"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateDiseaseReportInformationQuarterFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "425"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateDiseaseReportInformationMonthFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "418"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateDiseaseReportInformationWeekFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "760"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateDiseaseReportInformationDayFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "937"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateDiseaseReportInformationAdministrativeLevel0FieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "47"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateDiseaseReportInformationAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "428"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateDiseaseReportInformationAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "426"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateDiseaseReportInformationAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "248"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateDiseaseReportInformationAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "949"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateDiseaseReportInformationOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "423"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateDiseaseReportDiseaseMatrixVersionFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "938"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateDiseaseReportDiseaseMatrixTemplateFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportInformation + "939"')

--        //VAUC09 - Enter Veterinary Aggregate Action Report and VAUC10 - Edit Veterinary Aggregate Action Report
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationNotificationSentByInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "761"')

,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationNotificationSentByOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "762"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationNotificationSentByDateFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "763"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationNotificationReceivedByInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "352"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationNotificationReceivedByOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "2799"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationNotificationReceivedByDateFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "3586"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationEnteredByInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "761"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationEnteredByOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "762"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationEnteredByDateFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "763"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationReportIDFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "750"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationYearFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "455"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationQuarterFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "425"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationMonthFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "418"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationWeekFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "760"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationDayFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "937"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationAdministrativeLevel0FieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "47"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "428"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "426"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "248"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "949"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "423"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationLegacyIDFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "936"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateActionsReportMatrixVersionFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "938"')
,(N'FieldLabelResourceKeyConstants', N'VeterinaryAggregateActionsReportTemplateVersionFieldLabel', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionsReportInformation + "939"')

--        //VAUC07 - Search for Veterinary Aggregate Disease Report and VAUC11 - Search for Veterinary Aggregate Action Report
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryAggregateDiseaseAndActionReportsReportIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryAggregateDiseaseAndActionReports + "750"')

,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryAggregateDiseaseAndActionReportsLegacyIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryAggregateDiseaseAndActionReports + "936"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryAggregateDiseaseAndActionReportsTimeIntervalUnitFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryAggregateDiseaseAndActionReports + "942"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryAggregateDiseaseAndActionReportsStartDateFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryAggregateDiseaseAndActionReports + "441"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryAggregateDiseaseAndActionReportsEndDateFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryAggregateDiseaseAndActionReports + "397"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryAggregateDiseaseAndActionReportsAdministrativeLevelFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryAggregateDiseaseAndActionReports + "943"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryAggregateDiseaseAndActionReportsAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryAggregateDiseaseAndActionReports + "428"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryAggregateDiseaseAndActionReportsAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryAggregateDiseaseAndActionReports + "426"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryAggregateDiseaseAndActionReportsAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryAggregateDiseaseAndActionReports + "248"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryAggregateDiseaseAndActionReportsAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryAggregateDiseaseAndActionReports + "949"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryAggregateDiseaseAndActionReportsOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryAggregateDiseaseAndActionReports + "423"')

--        //VUC04 - Enter Livestock Disease Report and VUC06 - Edit Livestock Disease Report
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportRelatedToDiseaseReportFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReport + "3121"')

,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSummaryReportIDFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSummary + "750"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSummaryLegacyIDFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSummary + "936"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSummaryFieldAccessionIDFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSummary + "2471"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSummaryOutbreakIDFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSummary + "969"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSummaryReportStatusFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSummary + "1080"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSummaryDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSummary + "71"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSummaryDateOfDiagnosisFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSummary + "1086"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSummarySessionIDFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSummary + "808"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSummaryCaseClassificationFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSummary + "387"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSummaryReportTypeFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSummary + "434"')

,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportFarmDetailsFarmIDFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmDetails + "2403"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportFarmDetailsFarmNameFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmDetails + "2430"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportFarmDetailsFarmOwnerLastNameFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmDetails + "414"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportFarmDetailsFarmOwnerFirstNameFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmDetails + "402"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportFarmDetailsFarmOwnerMiddleNameFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmDetails + "416"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportFarmDetailsFarmOwnerIDFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmDetails + "2407"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportFarmDetailsPhoneFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmDetails + "206"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportFarmDetailsEmailFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmDetails + "2432"')

insert into #Caption (captionClass, controlCaptionConstant, controlCaptionIdRaw) values
 (N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportNotificationOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportNotification + "423"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportNotificationReportedByFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportNotification + "2444"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportNotificationInitialReportDateFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportNotification + "2472"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportNotificationInvestigationOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportNotification + "2473"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportNotificationInvestigatorNameFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportNotification + "2474"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportNotificationAssignedDateFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportNotification + "2475"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportNotificationInvestigationDateFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportNotification + "2445"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportNotificationDataEntrySiteFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportNotification + "549"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportNotificationDataEntryOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportNotification + "762"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportNotificationDataEntryDateFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportNotification + "763"')

,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportFarmHerdSpeciesNoteIncludeBreedFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2479"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportFarmHerdSpeciesFarmFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "3173"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportFarmHerdSpeciesHerdFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2987"')

,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportAnimalDetailsModalHerdIDFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportAnimalDetailsModal + "2907"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportAnimalDetailsModalAnimalIDFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportAnimalDetailsModal + "2495"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportAnimalDetailsModalSpeciesFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportAnimalDetailsModal + "366"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportAnimalDetailsModalAgeFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportAnimalDetailsModal + "1070"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportAnimalDetailsModalSexFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportAnimalDetailsModal + "2496"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportAnimalDetailsModalStatusFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportAnimalDetailsModal + "575"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportAnimalDetailsModalNoteAdditionalInfoFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportAnimalDetailsModal + "2497"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportAnimalDetailsModalClinicalSignsforthisAnimalFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportAnimalDetailsModal + "2498"')

,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSamplesAccessionDateFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSamples + "1121"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSamplesSampleConditionReceivedFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSamples + "1122"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSamplesCommentFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSamples + "767"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSamplesCollectedByInsitutionFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSamples + "1118"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSamplesCollectedByOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSamples + "1119"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSamplesAdditionalTestRequestedAndSampleNotesFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSamples + "869"')

,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSampleDetailsModalFilterSamplesByDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSampleDetailsModal + "81"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSampleDetailsModalLabSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSampleDetailsModal + "668"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSampleDetailsModalSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSampleDetailsModal + "365"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSampleDetailsModalFieldSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSampleDetailsModal + "870"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSampleDetailsModalAnimalIDFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSampleDetailsModal + "2495"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSampleDetailsModalSpeciesFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSampleDetailsModal + "366"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSampleDetailsModalAccessionDateFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSampleDetailsModal + "1121"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSampleDetailsModalSampleConditionReceivedFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSampleDetailsModal + "1122"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSampleDetailsModalCommentFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSampleDetailsModal + "767"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSampleDetailsModalCollectionDateFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSampleDetailsModal + "873"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSampleDetailsModalCollectionByInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSampleDetailsModal + "1118"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSampleDetailsModalCollectionByOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSampleDetailsModal + "1119"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSampleDetailsModalSentDateFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSampleDetailsModal + "1120"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSampleDetailsModalSentToOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSampleDetailsModal + "875"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportSampleDetailsModalAdditionalTestRequestedAndSampleNotesFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSampleDetailsModal + "869"')

,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportPensideTestDetailsModalTestNameFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportPensideTestDetailsModal + "370"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportPensideTestDetailsModalFieldSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportPensideTestDetailsModal + "870"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportPensideTestDetailsModalSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportPensideTestDetailsModal + "365"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportPensideTestDetailsModalAnimalIDFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportPensideTestDetailsModal + "2495"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportPensideTestDetailsModalResultFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportPensideTestDetailsModal + "2505"')

,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportLabTestsTestsConductedFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportLabTests + "1123"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportLabTestsLabSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportLabTests + "668"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportLabTestsSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportLabTests + "365"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportLabTestsTestStatusFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportLabTests + "679"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportLabTestsTestCategoryFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportLabTests + "369"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportLabTestsResultDateFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportLabTests + "881"')

--        //localization fix 11/2/2023
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportLabTestsCommentsFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportLabTests + "4850"')

,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportLabTestDetailsModalFieldSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportLabTestDetailsModal + "870"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportLabTestDetailsModalLabSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportLabTestDetailsModal + "668"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportLabTestDetailsModalSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportLabTestDetailsModal + "365"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportLabTestDetailsModalAnimalIDFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportLabTestDetailsModal + "2495"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportLabTestDetailsModalTestDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportLabTestDetailsModal + "876"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportLabTestDetailsModalTestNameFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportLabTestDetailsModal + "370"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportLabTestDetailsModalTestStatusFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportLabTestDetailsModal + "679"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportLabTestDetailsModalTestCategoryFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportLabTestDetailsModal + "369"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportLabTestDetailsModalResultDateFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportLabTestDetailsModal + "881"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportLabTestDetailsModalResultObservationFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportLabTestDetailsModal + "2507"')

,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportInterpretationDetailsModalAnimalIDFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportInterpretationDetailsModal + "2495"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportInterpretationDetailsModalDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportInterpretationDetailsModal + "71"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportInterpretationDetailsModalTestNameFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportInterpretationDetailsModal + "370"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportInterpretationDetailsModalTestCategoryFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportInterpretationDetailsModal + "369"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportInterpretationDetailsModalLabSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportInterpretationDetailsModal + "668"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportInterpretationDetailsModalSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportInterpretationDetailsModal + "365"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportInterpretationDetailsModalFieldSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportInterpretationDetailsModal + "870"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportInterpretationDetailsModalRuleOutRuleInFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportInterpretationDetailsModal + "1128"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportInterpretationDetailsModalCommentsRuleOutRuleInFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportInterpretationDetailsModal + "1129"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportInterpretationDetailsModalDateInterpretedFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportInterpretationDetailsModal + "1130"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportInterpretationDetailsModalInterpretedByFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportInterpretationDetailsModal + "1131"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportInterpretationDetailsModalValidatedFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportInterpretationDetailsModal + "1132"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportInterpretationDetailsModalCommentsValidatedFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportInterpretationDetailsModal + "1133"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportInterpretationDetailsModalDateValidatedFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportInterpretationDetailsModal + "1134"')
,(N'FieldLabelResourceKeyConstants', N'LivestockDiseaseReportInterpretationDetailsModalValidatedByFieldLabel', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportInterpretationDetailsModal + "1135"')

--        //VUC05 - Enter Avian Disease Report and VUC07 - Edit Avian Disease Report
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportRelatedToDiseaseReportFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReport + "3121"')

,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSummaryReportIDFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSummary + "750"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSummaryLegacyIDFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSummary + "936"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSummaryFieldAccessionIDFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSummary + "2471"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSummaryOutbreakIDFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSummary + "969"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSummaryReportStatusFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSummary + "1080"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSummaryDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSummary + "71"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSummaryDateOfDiagnosisFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSummary + "1086"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSummarySessionIDFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSummary + "808"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSummaryCaseClassificationFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSummary + "387"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSummaryReportTypeFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSummary + "434"')

,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportFarmDetailsFarmIDFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmDetails + "2403"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportFarmDetailsFarmNameFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmDetails + "2430"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportFarmDetailsFarmOwnerLastNameFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmDetails + "414"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportFarmDetailsFarmOwnerFirstNameFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmDetails + "402"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportFarmDetailsFarmOwnerMiddleNameFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmDetails + "416"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportFarmDetailsFarmOwnerIDFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmDetails + "2407"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportFarmDetailsPhoneFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmDetails + "206"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportFarmDetailsEmailFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmDetails + "2432"')

,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportNotificationOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportNotification + "423"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportNotificationReportedByFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportNotification + "2444"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportNotificationInitialReportDateFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportNotification + "2472"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportNotificationInvestigationOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportNotification + "2473"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportNotificationInvestigatorNameFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportNotification + "2474"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportNotificationAssignedDateFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportNotification + "2475"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportNotificationInvestigationDateFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportNotification + "2445"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportNotificationDataEntrySiteFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportNotification + "549"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportNotificationDataEntryOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportNotification + "762"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportNotificationDataEntryDateFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportNotification + "763"')

,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportFarmFlockSpeciesFarmFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "3173"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportFarmFlockSpeciesFlockFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2986"')

,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSamplesAccessionDateFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSamples + "1121"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSamplesSampleConditionReceivedFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSamples + "1122"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSamplesCommentFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSamples + "767"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSamplesCollectedByInsitutionFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSamples + "1118"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSamplesCollectedByOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSamples + "1119"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSamplesAdditionalTestRequestedAndSampleNotesFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSamples + "869"')

,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSampleDetailsModalFilterSamplesByDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSampleDetailsModal + "81"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSampleDetailsModalLabSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSampleDetailsModal + "668"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSampleDetailsModalSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSampleDetailsModal + "365"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSampleDetailsModalFieldSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSampleDetailsModal + "870"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSampleDetailsModalSpeciesFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSampleDetailsModal + "366"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSampleDetailsModalBirdStatusFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSampleDetailsModal + "2503"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSampleDetailsModalAccessionDateFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSampleDetailsModal + "1121"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSampleDetailsModalSampleConditionReceivedFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSampleDetailsModal + "1122"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSampleDetailsModalCommentFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSampleDetailsModal + "767"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSampleDetailsModalCollectionDateFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSampleDetailsModal + "873"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSampleDetailsModalCollectionByInstitutionFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSampleDetailsModal + "1118"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSampleDetailsModalCollectionByOfficerFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSampleDetailsModal + "1119"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSampleDetailsModalSentDateFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSampleDetailsModal + "1120"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSampleDetailsModalSentToOrganizationFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSampleDetailsModal + "875"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportSampleDetailsModalAdditionalTestRequestedAndSampleNotesFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSampleDetailsModal + "869"')

,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportPensideTestDetailsModalTestNameFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportPensideTestDetailsModal + "370"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportPensideTestDetailsModalFieldSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportPensideTestDetailsModal + "870"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportPensideTestDetailsModalSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportPensideTestDetailsModal + "365"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportPensideTestDetailsModalSpeciesFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportPensideTestDetailsModal + "366"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportPensideTestDetailsModalResultFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportPensideTestDetailsModal + "2505"')

,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportLabTestsTestsConductedFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportLabTests + "1123"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportLabTestsLabSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportLabTests + "668"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportLabTestsSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportLabTests + "365"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportLabTestsTestStatusFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportLabTests + "679"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportLabTestsTestCategoryFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportLabTests + "369"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportLabTestsResultDateFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportLabTests + "881"')

,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportLabTestDetailsModalFieldSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportLabTestDetailsModal + "870"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportLabTestDetailsModalLabSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportLabTestDetailsModal + "668"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportLabTestDetailsModalSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportLabTestDetailsModal + "365"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportLabTestDetailsModalSpeciesFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportLabTestDetailsModal + "366"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportLabTestDetailsModalTestDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportLabTestDetailsModal + "876"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportLabTestDetailsModalTestNameFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportLabTestDetailsModal + "370"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportLabTestDetailsModalTestStatusFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportLabTestDetailsModal + "679"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportLabTestDetailsModalTestCategoryFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportLabTestDetailsModal + "369"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportLabTestDetailsModalResultDateFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportLabTestDetailsModal + "881"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportLabTestDetailsModalResultObservationFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportLabTestDetailsModal + "2507"')

,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportInterpretationDetailsModalSpeciesFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportInterpretationDetailsModal + "366"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportInterpretationDetailsModalDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportInterpretationDetailsModal + "71"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportInterpretationDetailsModalTestNameFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportInterpretationDetailsModal + "370"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportInterpretationDetailsModalTestCategoryFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportInterpretationDetailsModal + "369"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportInterpretationDetailsModalLabSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportInterpretationDetailsModal + "668"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportInterpretationDetailsModalSampleTypeFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportInterpretationDetailsModal + "365"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportInterpretationDetailsModalFieldSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportInterpretationDetailsModal + "870"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportInterpretationDetailsModalRuleOutRuleInFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportInterpretationDetailsModal + "1128"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportInterpretationDetailsModalCommentsRuleOutRuleInFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportInterpretationDetailsModal + "1129"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportInterpretationDetailsModalDateInterpretedFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportInterpretationDetailsModal + "1130"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportInterpretationDetailsModalInterpretedByFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportInterpretationDetailsModal + "1131"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportInterpretationDetailsModalValidatedFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportInterpretationDetailsModal + "1132"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportInterpretationDetailsModalCommentsValidatedFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportInterpretationDetailsModal + "1133"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportInterpretationDetailsModalDateValidatedFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportInterpretationDetailsModal + "1134"')
,(N'FieldLabelResourceKeyConstants', N'AvianDiseaseReportInterpretationDetailsModalValidatedByFieldLabel', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportInterpretationDetailsModal + "1135"')

--        //VUC10 - Search for an Animal Disease Report
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsReportIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "750"')

,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsLegacyIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "936"')
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsSpeciesTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "440"')
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "71"')
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsReportStatusFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "1080"')
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsReportTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "434"')
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "428"')
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "426"')
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "248"')
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "249"')
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "949"')
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsDateEnteredFromFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "2437"')
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsDateEnteredToFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "2438"')
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsCaseClassificationFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "387"')
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsDiagnosisDateRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "1871"')
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsInvestigationDateRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "2439"')
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsFieldSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "870"')
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsTotalAnimalQuantityFromFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "2440"')
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsTotalAnimalQuantityToFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "2441"')
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsSessionIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "808"')
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsDataEntrySiteFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "1864"')
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsReportDateFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "2443"')
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsReportedByFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "2444"')
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsInvestigationDateFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "2445"')
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsInvestigatedByFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "2446"')
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsSpeciesFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "366"')
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsTotalAnimalsFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "2447"')
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsSickAnimalQuantityFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "2448"')
,(N'FieldLabelResourceKeyConstants', N'SearchAvianDiseaseReportsDeadAnimalQuantityFieldLabel', N'InterfaceEditorResourceSetEnum.SearchAvianDiseaseReports + "2449"')

,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsReportIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "750"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsLegacyIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "936"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsSpeciesTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "440"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "71"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsReportStatusFieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "1080"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsReportTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "434"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "428"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "426"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "248"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "249"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "949"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsDateEnteredFromFieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "2437"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsDateEnteredToFieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "2438"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsCaseClassificationFieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "387"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsDiagnosisDateRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "1871"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsInvestigationDateRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "2439"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsFieldSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "870"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsTotalAnimalQuantityFromFieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "2440"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsTotalAnimalQuantityToFieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "2441"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsSessionIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "808"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsDataEntrySiteFieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "1864"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsReportDateFieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "2443"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsReportedByFieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "2444"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsInvestigationDateFieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "2445"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsInvestigatedByFieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "2446"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsSpeciesFieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "366"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsTotalAnimalsFieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "2447"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsSickAnimalQuantityFieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "2448"')
,(N'FieldLabelResourceKeyConstants', N'SearchLivestockDiseaseReportsDeadAnimalQuantityFieldLabel', N'InterfaceEditorResourceSetEnum.SearchLivestockDiseaseReports + "2449"')

,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalReportIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "750"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalLegacyIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "936"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalSpeciesTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "440"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "71"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalReportStatusFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "1080"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalReportTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "434"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "428"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "426"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "248"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "249"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "949"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalDateEnteredFromFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "2437"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalDateEnteredToFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "2438"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalCaseClassificationFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "387"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalDiagnosisDateRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "1871"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalInvestigationDateRangeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "2439"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalFieldSampleIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "870"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalTotalAnimalQuantityFromFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "2440"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalTotalAnimalQuantityToFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "2441"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalSessionIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "808"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalDataEntrySiteFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "1864"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalReportDateFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "2443"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalReportedByFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "2444"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalInvestigationDateFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "2445"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalInvestigatedByFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "2446"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalSpeciesFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "366"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalTotalAnimalsFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "2447"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalSickAnimalQuantityFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "2448"')
,(N'FieldLabelResourceKeyConstants', N'SearchVeterinaryDiseaseReportsModalDeadAnimalQuantityFieldLabel', N'InterfaceEditorResourceSetEnum.SearchVeterinaryDiseaseReportsModal + "2449"')

--        //VUC16 - Search for a Farm Record
,(N'FieldLabelResourceKeyConstants', N'SearchFarmsFarmIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchFarms + "2403"')

,(N'FieldLabelResourceKeyConstants', N'SearchFarmsLegacyIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchFarms + "936"')
,(N'FieldLabelResourceKeyConstants', N'SearchFarmsFarmTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchFarms + "2404"')
,(N'FieldLabelResourceKeyConstants', N'SearchFarmsFarmNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchFarms + "2430"')
,(N'FieldLabelResourceKeyConstants', N'SearchFarmsFarmOwnerLastNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchFarms + "2405"')
,(N'FieldLabelResourceKeyConstants', N'SearchFarmsFarmOwnerFirstNameFieldLabel', N'InterfaceEditorResourceSetEnum.SearchFarms + "2406"')
,(N'FieldLabelResourceKeyConstants', N'SearchFarmsFarmOwnerIDFieldLabel', N'InterfaceEditorResourceSetEnum.SearchFarms + "2407"')
,(N'FieldLabelResourceKeyConstants', N'SearchFarmsAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.SearchFarms + "428"')
,(N'FieldLabelResourceKeyConstants', N'SearchFarmsAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.SearchFarms + "426"')
,(N'FieldLabelResourceKeyConstants', N'SearchFarmsAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.SearchFarms + "248"')
,(N'FieldLabelResourceKeyConstants', N'SearchFarmsAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.SearchFarms + "949"')
,(N'FieldLabelResourceKeyConstants', N'SearchFarmsAdministrativeLevel5FieldLabel', N'InterfaceEditorResourceSetEnum.SearchFarms + "950"')
,(N'FieldLabelResourceKeyConstants', N'SearchFarmsAdministrativeLevel6FieldLabel', N'InterfaceEditorResourceSetEnum.SearchFarms + "951"')
,(N'FieldLabelResourceKeyConstants', N'SearchFarmsSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchFarms + "249"')
,(N'FieldLabelResourceKeyConstants', N'SearchFarmsBuildingFieldLabel', N'InterfaceEditorResourceSetEnum.SearchFarms + "31"')
,(N'FieldLabelResourceKeyConstants', N'SearchFarmsHouseFieldLabel', N'InterfaceEditorResourceSetEnum.SearchFarms + "92"')
,(N'FieldLabelResourceKeyConstants', N'SearchFarmsApartmentFieldLabel', N'InterfaceEditorResourceSetEnum.SearchFarms + "2417"')
,(N'FieldLabelResourceKeyConstants', N'SearchFarmsPostalCodeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchFarms + "208"')
,(N'FieldLabelResourceKeyConstants', N'SearchFarmsLatitudeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchFarms + "2418"')
,(N'FieldLabelResourceKeyConstants', N'SearchFarmsLongitudeFieldLabel', N'InterfaceEditorResourceSetEnum.SearchFarms + "2419"')
,(N'FieldLabelResourceKeyConstants', N'SearchFarmsElevationFieldLabel', N'InterfaceEditorResourceSetEnum.SearchFarms + "2420"')

--        //VUC17 - Enter New Farm Record and VUC18 - Edit Farm
,(N'FieldLabelResourceKeyConstants', N'FarmInformationDateEnteredFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "854"')

,(N'FieldLabelResourceKeyConstants', N'FarmInformationDateLastUpdatedFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "1083"')
,(N'FieldLabelResourceKeyConstants', N'FarmInformationFarmIDFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "2403"')
,(N'FieldLabelResourceKeyConstants', N'FarmInformationLegacyIDFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "936"')
,(N'FieldLabelResourceKeyConstants', N'FarmInformationFarmTypeFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "2404"')
,(N'FieldLabelResourceKeyConstants', N'FarmInformationFarmNameFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "2430"')
,(N'FieldLabelResourceKeyConstants', N'FarmInformationFarmOwnerFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "674"')
,(N'FieldLabelResourceKeyConstants', N'FarmInformationPhoneFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "206"')
,(N'FieldLabelResourceKeyConstants', N'FarmInformationFaxFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "2431"')
,(N'FieldLabelResourceKeyConstants', N'FarmInformationEmailFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "2432"')
,(N'FieldLabelResourceKeyConstants', N'FarmInformationNumberOfBarnsBuildingsFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "2433"')
,(N'FieldLabelResourceKeyConstants', N'FarmInformationNumberOfBirdsPerBarnBuildingFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "2434"')
,(N'FieldLabelResourceKeyConstants', N'FarmInformationAvianFarmTypeIDFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "3204"')
,(N'FieldLabelResourceKeyConstants', N'FarmAddressDateEnteredFieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "854"')
,(N'FieldLabelResourceKeyConstants', N'FarmAddressDateLastUpdatedFieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "1083"')
,(N'FieldLabelResourceKeyConstants', N'FarmAddressAdministrativeLevel1FieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "428"')
,(N'FieldLabelResourceKeyConstants', N'FarmAddressAdministrativeLevel2FieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "426"')
,(N'FieldLabelResourceKeyConstants', N'FarmAddressAdministrativeLevel3FieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "248"')
,(N'FieldLabelResourceKeyConstants', N'FarmAddressAdministrativeLevel4FieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "949"')
,(N'FieldLabelResourceKeyConstants', N'FarmAddressAdministrativeLevel5FieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "950"')
,(N'FieldLabelResourceKeyConstants', N'FarmAddressAdministrativeLevel6FieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "951"')
,(N'FieldLabelResourceKeyConstants', N'FarmAddressSettlementTypeFieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "249"')
,(N'FieldLabelResourceKeyConstants', N'FarmAddressStreetFieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "248"')
,(N'FieldLabelResourceKeyConstants', N'FarmAddressBuildingFieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "31"')
,(N'FieldLabelResourceKeyConstants', N'FarmAddressHouseFieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "92"')
,(N'FieldLabelResourceKeyConstants', N'FarmAddressApartmentFieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "2417"')
,(N'FieldLabelResourceKeyConstants', N'FarmAddressPostalCodeFieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "208"')
,(N'FieldLabelResourceKeyConstants', N'FarmAddressLatitudeFieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "2418"')
,(N'FieldLabelResourceKeyConstants', N'FarmAddressLongitudeFieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "2419"')
,(N'FieldLabelResourceKeyConstants', N'FarmAddressElevationFieldLabel', N'InterfaceEditorResourceSetEnum.FarmAddress + "2420"')

--        //VUC18 - Farm Disease Report Listing and Outbreak Report Listing - Expanded Grid Details
,(N'FieldLabelResourceKeyConstants', N'FarmDiseaseAndOutbreakReportsReportDateFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "2443"')

,(N'FieldLabelResourceKeyConstants', N'FarmDiseaseAndOutbreakReportsReportedByFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "2444"')
,(N'FieldLabelResourceKeyConstants', N'FarmDiseaseAndOutbreakReportsInvestigationDateFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "2445"')
,(N'FieldLabelResourceKeyConstants', N'FarmDiseaseAndOutbreakReportsInvestigatedByFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "2446"')
,(N'FieldLabelResourceKeyConstants', N'FarmDiseaseAndOutbreakReportsSpeciesFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "366"')
,(N'FieldLabelResourceKeyConstants', N'FarmDiseaseAndOutbreakReportsTotalAnimalsFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "2447"')
,(N'FieldLabelResourceKeyConstants', N'FarmDiseaseAndOutbreakReportsSickAnimalQuantityFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "2448"')
,(N'FieldLabelResourceKeyConstants', N'FarmDiseaseAndOutbreakReportsDeadAnimalQuantityFieldLabel', N'InterfaceEditorResourceSetEnum.FarmInformation + "2449"')

--endregion Veterinary Module Resources

--region WHO Export

--        //SINT03
,(N'FieldLabelResourceKeyConstants', N'HumanExporttoCISIDDiseaseFieldLabel', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "71"')

,(N'FieldLabelResourceKeyConstants', N'HumanExporttoCISIDDateFromFieldLabel', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "393"')
,(N'FieldLabelResourceKeyConstants', N'HumanExporttoCISIDDateToFieldLabel', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "395"')
,(N'FieldLabelResourceKeyConstants', N'HumanExporttoCISIDDateEnteredRangeFieldLabel', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "811"')

--endregion WHO Export

--ButtonResourceKeyConstants

--region Common Resources

insert into #Caption (captionClass, controlCaptionConstant, controlCaptionIdRaw) values
 (N'ButtonResourceKeyConstants', N'ActivateMatrixVersionButton', N'InterfaceEditorResourceSetEnum.CommonButtons + "12"')
,(N'ButtonResourceKeyConstants', N'AddButton', N'InterfaceEditorResourceSetEnum.CommonButtons + "16"')
,(N'ButtonResourceKeyConstants', N'AddToOutbreakButton', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "521"')
,(N'ButtonResourceKeyConstants', N'AddToParameterTreeViewButton', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "522"')
,(N'ButtonResourceKeyConstants', N'AdvancedSearchButton', N'InterfaceEditorResourceSetEnum.CommonButtons + "21"')
,(N'ButtonResourceKeyConstants', N'CancelButton', N'InterfaceEditorResourceSetEnum.CommonButtons + "32"')
,(N'ButtonResourceKeyConstants', N'ClearButton', N'InterfaceEditorResourceSetEnum.CommonButtons + "35"')
,(N'ButtonResourceKeyConstants', N'CloseButton', N'InterfaceEditorResourceSetEnum.CommonButtons + "495"')
,(N'ButtonResourceKeyConstants', N'DeleteButton', N'InterfaceEditorResourceSetEnum.CommonButtons + "60"')
,(N'ButtonResourceKeyConstants', N'DeleteMatrixRecordButton', N'InterfaceEditorResourceSetEnum.CommonButtons + "62"')
,(N'ButtonResourceKeyConstants', N'DeleteMatrixVersionButton', N'InterfaceEditorResourceSetEnum.CommonButtons + "63"')
,(N'ButtonResourceKeyConstants', N'GenerateButton', N'InterfaceEditorResourceSetEnum.CommonButtons + "87"')
,(N'ButtonResourceKeyConstants', N'GenerateReportButton', N'InterfaceEditorResourceSetEnum.Reports + "505"')
,(N'ButtonResourceKeyConstants', N'ImportButton', N'InterfaceEditorResourceSetEnum.CommonButtons + "94"')
,(N'ButtonResourceKeyConstants', N'LoginButton', N'InterfaceEditorResourceSetEnum.Login + "110"')
,(N'ButtonResourceKeyConstants', N'NewMatrixVersionButton', N'InterfaceEditorResourceSetEnum.CommonButtons + "142"')
,(N'ButtonResourceKeyConstants', N'NextButton', N'InterfaceEditorResourceSetEnum.CommonButtons + "496"')
,(N'ButtonResourceKeyConstants', N'NoButton', N'InterfaceEditorResourceSetEnum.CommonButtons + "143"')
,(N'ButtonResourceKeyConstants', N'OKButton', N'InterfaceEditorResourceSetEnum.CommonButtons + "148"')
,(N'ButtonResourceKeyConstants', N'PreviousButton', N'InterfaceEditorResourceSetEnum.CommonButtons + "497"')
,(N'ButtonResourceKeyConstants', N'PrintButton', N'InterfaceEditorResourceSetEnum.CommonButtons + "209"')
,(N'ButtonResourceKeyConstants', N'ReturnToDashboardButton', N'InterfaceEditorResourceSetEnum.CommonButtons + "1814"')
,(N'ButtonResourceKeyConstants', N'ReturnToOutbreakButton', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "523"')
,(N'ButtonResourceKeyConstants', N'SaveButton', N'InterfaceEditorResourceSetEnum.CommonButtons + "239"')
,(N'ButtonResourceKeyConstants', N'SearchButton', N'InterfaceEditorResourceSetEnum.CommonButtons + "241"')
,(N'ButtonResourceKeyConstants', N'SelectButton', N'InterfaceEditorResourceSetEnum.CommonButtons + "498"')
,(N'ButtonResourceKeyConstants', N'SelectAllButton', N'InterfaceEditorResourceSetEnum.CommonButtons + "499"')
,(N'ButtonResourceKeyConstants', N'SubmitButton', N'InterfaceEditorResourceSetEnum.CommonButtons + "258"')
,(N'ButtonResourceKeyConstants', N'YesButton', N'InterfaceEditorResourceSetEnum.CommonButtons + "281"')
,(N'ButtonResourceKeyConstants', N'Copy_ButtonText', N'InterfaceEditorResourceSetEnum.CommonButtons + "744"')

--        //SYSUC04 - Change Password
,(N'ButtonResourceKeyConstants', N'ChangePasswordButton', N'InterfaceEditorResourceSetEnum.ChangePassword + "461"')

--endregion Common Resources

--region Administration Module Resources

--        //SAUC15 = Search Statistical Data Record
,(N'ButtonResourceKeyConstants', N'SearchStatisticalDataRecordLoadDataButtonText', N'InterfaceEditorResourceSetEnum.SearchStatisticalDataRecord + "3392"')

--        //SAUC30 - Restore a Data Audit Log Transaction
,(N'ButtonResourceKeyConstants', N'DataAuditLogDetailsRestoreButtonText', N'InterfaceEditorResourceSetEnum.DataAuditLogDetails + "3004"')		

--        //SAUC56 - Notifications/Site Alert Messenger
,(N'ButtonResourceKeyConstants', N'SiteAlertMessengerModalClearAllButtonText', N'InterfaceEditorResourceSetEnum.SiteAlertMessengerModal + "3187"')

,(N'ButtonResourceKeyConstants', N'SiteAlertSubscriptionsUnselectAllButtonText', N'InterfaceEditorResourceSetEnum.SiteAlertSubscriptions + "3025"')		

--region Deduplication Sub-Module Resources

,(N'ButtonResourceKeyConstants', N'DeduplicationAddforDeduplicationButtonText', N'InterfaceEditorResourceSetEnum.Deduplication + "2642"')
,(N'ButtonResourceKeyConstants', N'DeduplicationDeduplicateButtonText', N'InterfaceEditorResourceSetEnum.Deduplication + "2643"')
,(N'ButtonResourceKeyConstants', N'DeduplicationMergeButtonText', N'InterfaceEditorResourceSetEnum.Deduplication + "2644"')

--endregion Deduplication Sub-Module Resources

--endregion Administration Module Resources

--region Human Module Resources

--        //HASUC01 - Enter Human Active Surveillance Campaign and HASUC02 - Edit Human Active Surveillance Campaign
,(N'ButtonResourceKeyConstants', N'HumanActiveSurveillanceCampaignReturnToActiveSurveillanceCampaignButtonText', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "2770"')
,(N'ButtonResourceKeyConstants', N'HumanActiveSurveillanceCampaignReturnToDashboardButtonText', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "1814"')
,(N'ButtonResourceKeyConstants', N'HumanActiveSurveillanceSessionReturnToActiveSurveillanceSessionButtonText', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceSession + "865"')

--        //HUC02 - Enter a Person Record and HUC04 - Edit a Person Record
,(N'ButtonResourceKeyConstants', N'FindInPINSystemButton', N'InterfaceEditorResourceSetEnum.PersonalInformation + "704"')

,(N'ButtonResourceKeyConstants', N'PersonReturnToPersonRecordButtonText', N'InterfaceEditorResourceSetEnum.Person + "1142"')

--        //HUC03 - Human Disease Report
,(N'ButtonResourceKeyConstants', N'HumanDiseaseReportPrintBarcodeButtonText', N'InterfaceEditorResourceSetEnum.HumanDiseaseReport + "1039"')

,(N'ButtonResourceKeyConstants', N'HumanDiseaseReportReturntoDiseaseReportButtonText', N'InterfaceEditorResourceSetEnum.HumanDiseaseReport + "1813"')
,(N'ButtonResourceKeyConstants', N'HumanDiseaseReportReturntoDashboardButtonText', N'InterfaceEditorResourceSetEnum.HumanDiseaseReport + "1814"')

--        //HAUC01 and HAUC02 - Enter and Edit Human Aggregate Disease Report
,(N'ButtonResourceKeyConstants', N'HumanAggregateDiseaseReportReturnToAggregateDiseaseReportButton', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReport + "940"')

--        //HAUC05 - Human Aggregate Disease Report Summary
,(N'ButtonResourceKeyConstants', N'HumanAggregateDiseaseReportSummaryPaperFormButtonText', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportSummary + "1875"')

--        //HAUC06 - Enter ILI Aggregate Form and HAUC07 - Edit ILI Aggregate Form
,(N'ButtonResourceKeyConstants', N'ILIAggregateDetailsReturntoILIAggregateFormButtonText', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "2716"')

--        //HAUC10 and HAUC11 - Enter and Edit Weekly Reporting Form
,(N'ButtonResourceKeyConstants', N'WeeklyReportingFormDetailsReturntoWeeklyReportingFormButton', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "771"')

--        //HAUC13 - Enter Weekly Reporting Form Summary
,(N'ButtonResourceKeyConstants', N'WeeklyReportingFormSummaryShowSummaryDataButton', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormSummary + "772"')

--endregion Human Module Resources

--region Laboratory Module Resources

,(N'ButtonResourceKeyConstants', N'LaboratorySamplesAdvancedSearchButtonText', N'InterfaceEditorResourceSetEnum.Samples + "470"')
,(N'ButtonResourceKeyConstants', N'LaboratoryTestingAdvancedSearchButtonText', N'InterfaceEditorResourceSetEnum.Testing + "470"')
,(N'ButtonResourceKeyConstants', N'LaboratoryTransferredAdvancedSearchButtonText', N'InterfaceEditorResourceSetEnum.Transferred + "470"')
,(N'ButtonResourceKeyConstants', N'LaboratoryMyFavoritesAdvancedSearchButtonText', N'InterfaceEditorResourceSetEnum.MyFavorites + "470"')
,(N'ButtonResourceKeyConstants', N'LaboratoryApprovalsAdvancedSearchButtonText', N'InterfaceEditorResourceSetEnum.Approvals + "470"')

--        //LUC01 - Accession a Sample
,(N'ButtonResourceKeyConstants', N'LaboratorySamplesAccessionButton', N'InterfaceEditorResourceSetEnum.Samples + "695"')

,(N'ButtonResourceKeyConstants', N'GroupAccessionInModalAccessionButton', N'InterfaceEditorResourceSetEnum.GroupAccessionInModal + "695"')

--        //LUC02 - Create an Aliquot-Derivative
,(N'ButtonResourceKeyConstants', N'LaboratorySamplesAliquotButton', N'InterfaceEditorResourceSetEnum.Samples + "696"')

--        //LUC03 - Transfer a Sample
,(N'ButtonResourceKeyConstants', N'LaboratoryTransferredCancelTransferButtonText', N'InterfaceEditorResourceSetEnum.Transferred + "1818"')

,(N'ButtonResourceKeyConstants', N'LaboratoryTransferredPrintTransferButtonText', N'InterfaceEditorResourceSetEnum.Transferred + "2722"')

--        //LUC04 - Assign a Test
,(N'ButtonResourceKeyConstants', N'LaboratorySamplesAssignTestButton', N'InterfaceEditorResourceSetEnum.Samples + "697"')

,(N'ButtonResourceKeyConstants', N'LaboratoryTestingAssignTestButton', N'InterfaceEditorResourceSetEnum.Testing + "697"')

--        //LUC03 - Transfer a Sample
,(N'ButtonResourceKeyConstants', N'TransferOutModalTransferButtonText', N'InterfaceEditorResourceSetEnum.TransferOutModal + "848"')

--        //LUC07 - Amend Test Result
,(N'ButtonResourceKeyConstants', N'AmendTestResultModalAmendButtonText', N'InterfaceEditorResourceSetEnum.AmendTestResultModal + "866"')

--        //LUC08 - Create a Batch
,(N'ButtonResourceKeyConstants', N'LaboratoryTestingBatchButtonText', N'InterfaceEditorResourceSetEnum.Testing + "894"')

,(N'ButtonResourceKeyConstants', N'BatchModalBatchButtonText', N'InterfaceEditorResourceSetEnum.BatchModal + "894"')
,(N'ButtonResourceKeyConstants', N'LaboratoryBatchesRemoveSampleButtonText', N'InterfaceEditorResourceSetEnum.Batches + "1819"')
,(N'ButtonResourceKeyConstants', N'LaboratoryBatchesAddGroupResultButtonText', N'InterfaceEditorResourceSetEnum.Batches + "1820"')
,(N'ButtonResourceKeyConstants', N'LaboratoryBatchesCloseBatchButtonText', N'InterfaceEditorResourceSetEnum.Batches + "2725"')

--        //LUC16 - Approvals Workflow
,(N'ButtonResourceKeyConstants', N'LaboratoryApprovalsApproveButtonText', N'InterfaceEditorResourceSetEnum.Approvals + "999"')

,(N'ButtonResourceKeyConstants', N'LaboratoryApprovalsRejectButtonText', N'InterfaceEditorResourceSetEnum.Approvals + "1010"')

--        //LUC17 - Lab-My Favorites
,(N'ButtonResourceKeyConstants', N'LaboratoryMyFavoritesAccessionButton', N'InterfaceEditorResourceSetEnum.MyFavorites + "695"')

,(N'ButtonResourceKeyConstants', N'LaboratoryMyFavoritesAssignTestButton', N'InterfaceEditorResourceSetEnum.MyFavorites + "697"')
,(N'ButtonResourceKeyConstants', N'LaboratoryMyFavoritesBatchButton', N'InterfaceEditorResourceSetEnum.MyFavorites + "894"')

--        //LUC18 - Laboratory Menu
,(N'ButtonResourceKeyConstants', N'LaboratoryAccessionInButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "1015"')

,(N'ButtonResourceKeyConstants', N'LaboratoryGroupAccessionButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "1016"')
,(N'ButtonResourceKeyConstants', N'LaboratoryAssignTestButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "697"')
,(N'ButtonResourceKeyConstants', N'LaboratoryCreateAliquotButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "1018"')
,(N'ButtonResourceKeyConstants', N'LaboratoryCreateDerivativeButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "1019"')
,(N'ButtonResourceKeyConstants', N'LaboratoryTransferOutButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "1020"')
,(N'ButtonResourceKeyConstants', N'LaboratoryRegisterNewSampleButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "1021"')
,(N'ButtonResourceKeyConstants', N'LaboratorySetTestResultsButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "1022"')
,(N'ButtonResourceKeyConstants', N'LaboratoryValidateTestResultButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "1023"')
,(N'ButtonResourceKeyConstants', N'LaboratoryAmendTestResultButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "1024"')
,(N'ButtonResourceKeyConstants', N'LaboratoryDestroyByIncinerationButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "1025"')
,(N'ButtonResourceKeyConstants', N'LaboratoryDestroyByAutoclaveButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "1026"')
,(N'ButtonResourceKeyConstants', N'LaboratoryApproveDestructionButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "1027"')
,(N'ButtonResourceKeyConstants', N'LaboratoryRejectDestructionButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "1028"')
,(N'ButtonResourceKeyConstants', N'LaboratoryDeleteSampleButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "1029"')
,(N'ButtonResourceKeyConstants', N'LaboratoryDeleteTestButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "1030"')
,(N'ButtonResourceKeyConstants', N'LaboratoryApproveDeletionButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "1031"')
,(N'ButtonResourceKeyConstants', N'LaboratoryRejectDeletionButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "1032"')
,(N'ButtonResourceKeyConstants', N'LaboratoryRestoreSampleButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "1033"')
,(N'ButtonResourceKeyConstants', N'LaboratorySampleReportButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "1034"')
,(N'ButtonResourceKeyConstants', N'LaboratoryAccessionInFormButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "1035"')
,(N'ButtonResourceKeyConstants', N'LaboratoryHumanDiseaseReportOutbreakCaseAccessionInFormButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "2992"')
,(N'ButtonResourceKeyConstants', N'LaboratoryVeterinaryDiseaseReportOutbreakCaseAccessionInFormButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "2993"')
,(N'ButtonResourceKeyConstants', N'LaboratoryHumanActiveSurveillanceSessionAccessionInFormButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "2994"')
,(N'ButtonResourceKeyConstants', N'LaboratoryVeterinaryActiveSurveillanceSessionAccessionInFormButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "2995"')
,(N'ButtonResourceKeyConstants', N'LaboratoryVectorSurveillanceSessionAccessionInFormButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "2996"')
,(N'ButtonResourceKeyConstants', N'LaboratoryTestResultReportButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "1036"')
,(N'ButtonResourceKeyConstants', N'LaboratoryTransferReportButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "1037"')
,(N'ButtonResourceKeyConstants', N'LaboratoryDestructionReportButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "1038"')
,(N'ButtonResourceKeyConstants', N'LaboratoryPrintBarcodeButtonText', N'InterfaceEditorResourceSetEnum.Laboratory + "1039"')

--        //LUC22 - Search for a Freezer
,(N'ButtonResourceKeyConstants', N'FreezersCopyFreezerButtonText', N'InterfaceEditorResourceSetEnum.Freezers + "822"')

--endregion Laboratory Module Resources

--region Reports Module Resources

,(N'ButtonResourceKeyConstants', N'ReportsValidateButton', N'InterfaceEditorResourceSetEnum.Reports + "965"')

--endregion Reports Module Resources

--region Outbreak Module Resources

--        //Outbreak (OMUC01, OMUC02, OMUC03)
,(N'ButtonResourceKeyConstants', N'OutbreakCasesCASESButtonText', N'InterfaceEditorResourceSetEnum.OutbreakCases + "989"')
,(N'ButtonResourceKeyConstants', N'OutbreakCasesCONTACTSButtonText', N'InterfaceEditorResourceSetEnum.OutbreakCases + "990"')
,(N'ButtonResourceKeyConstants', N'OutbreakCasesANALYSISButtonText', N'InterfaceEditorResourceSetEnum.OutbreakCases + "991"')
,(N'ButtonResourceKeyConstants', N'CreateOutbreakSaveButtonText', N'InterfaceEditorResourceSetEnum.CreateOutbreak + "239"')
,(N'ButtonResourceKeyConstants', N'OutbreakCasesImportButtonText', N'InterfaceEditorResourceSetEnum.OutbreakCases + "94"')
,(N'ButtonResourceKeyConstants', N'OutbreakCasesCreateButtonText', N'InterfaceEditorResourceSetEnum.OutbreakCases + "2760"')
,(N'ButtonResourceKeyConstants', N'OutbreakCasesVECTORButtonText', N'InterfaceEditorResourceSetEnum.OutbreakCases + "2761"')
,(N'ButtonResourceKeyConstants', N'CreateVectorSessionCaseAddButtonText', N'InterfaceEditorResourceSetEnum.CreateVectorSessionCase + "16"')
,(N'ButtonResourceKeyConstants', N'OutbreakCasesUPDATESButtonText', N'InterfaceEditorResourceSetEnum.OutbreakCases + "2762"')
,(N'ButtonResourceKeyConstants', N'OutbreakCasesCasesButtonText', N'InterfaceEditorResourceSetEnum.OutbreakCases + "989"')
,(N'ButtonResourceKeyConstants', N'OutbreakCasesContactsButtonText', N'InterfaceEditorResourceSetEnum.OutbreakCases + "990"')
,(N'ButtonResourceKeyConstants', N'OutbreakCasesAnalysisButtonText', N'InterfaceEditorResourceSetEnum.OutbreakCases + "991"')
,(N'ButtonResourceKeyConstants', N'OutbreakCasesReturntoOutbreakParametersButtonText', N'InterfaceEditorResourceSetEnum.OutbreakCases + "3695"')
,(N'ButtonResourceKeyConstants', N'OutbreakCasesProceedtoOutbreakSessionButtonText', N'InterfaceEditorResourceSetEnum.OutbreakCases + "3696"')
,(N'ButtonResourceKeyConstants', N'OutbreakCasesReturntoDashboardButtonText', N'InterfaceEditorResourceSetEnum.OutbreakCases + "1814"')


--        //OMUC06 and OMMUC07 - Create and Edit a Veterinary Case
,(N'ButtonResourceKeyConstants', N'OutbreakCasesReturnToOutbreakCaseReportButtonText', N'InterfaceEditorResourceSetEnum.OutbreakCases + "3587"')
,(N'ButtonResourceKeyConstants', N'OutbreakCasesReturnToOutbreakSessionButtonText', N'InterfaceEditorResourceSetEnum.OutbreakCases + "2587"')

--        //OMUC08-1
,(N'ButtonResourceKeyConstants', N'SearchOutbreaksAdvancedSearchButtonText', N'InterfaceEditorResourceSetEnum.SearchOutbreaks + "470"')

--        //OMUC11 - Edit a Contact
,(N'ButtonResourceKeyConstants', N'OutbreakContactsSaveButtonText', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "239"')

--        //OMUC14
,(N'ButtonResourceKeyConstants', N'OutbreakUpdatesBrowseButtonText', N'InterfaceEditorResourceSetEnum.OutbreakUpdates + "2679"')

--endregion Outbreak Module Resources

--region Vector Module Resources

,(N'ButtonResourceKeyConstants', N'VectorSurveillanceSessionReturnToVectorSurveillanceSessionButton', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSession + "2586"')
,(N'ButtonResourceKeyConstants', N'VectorSurveillanceSessionReturntoOutbreakSessionButtonText', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSession + "2587"')

--endregion Vector Module Resources

--region Veterinary Module Resources

--        //VASUC01 - Enter Veterinary Active Surveillance Campaign and VASUC06 - Edit Veterinary Active Surveillance Campaign
,(N'ButtonResourceKeyConstants', N'VeterinaryActiveSurveillanceCampaignReturnToActiveSurveillanceCampaignButtonText', N'InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceCampaign + "2770"')

--        //VASUC02 - Set Up Veterinary Active Surveillance Session and VASUC03 - Edit Veterinary Active Surveillance Session
,(N'ButtonResourceKeyConstants', N'VeterinarySessionDetailedInformationAddHerdButtonText', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2483"')

,(N'ButtonResourceKeyConstants', N'VeterinarySessionDetailedInformationAddFlockButtonText', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2481"')
,(N'ButtonResourceKeyConstants', N'VeterinarySessionAggregateInformationAddHerdButtonText', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2483"')
,(N'ButtonResourceKeyConstants', N'VeterinarySessionAggregateInformationAddFlockButtonText', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2481"')
,(N'ButtonResourceKeyConstants', N'VeterinarySessionReturnToActiveSurveillanceSessionText', N'InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceSession + "865"')

--        //VAUC13 - Enter Veterinary Aggregate Disease Reports Summary and VAUC14 - Enter Veterinary Aggregate Action Reports Summary
,(N'ButtonResourceKeyConstants', N'SelectedAggregateActionReportsRemoveAllButtonText', N'InterfaceEditorResourceSetEnum.SelectedAggregateActionReports + "1876"')

,(N'ButtonResourceKeyConstants', N'SelectedAggregateActionReportsShowSummaryDataButtonText', N'InterfaceEditorResourceSetEnum.SelectedAggregateActionReports + "772"')
,(N'ButtonResourceKeyConstants', N'VeterinaryAggregateActionReportSummaryPaperFormButtonText', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReportSummary + "1875"')
,(N'ButtonResourceKeyConstants', N'VeterinaryAggregateDiseaseReportSummaryPaperFormButtonText', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportSummary + "1875"')

--        //VAUC09/10/11/12 - Enter and Edit Veterinary Aggregate Actions Report
,(N'ButtonResourceKeyConstants', N'VeterinaryAggregateActionsReportReturntoAggregateActionsReportButtonText', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReport + "3469"')

--        //VUC04 - Enter Livestock Disease Report and VUC06 - Edit Livestock Disease Report
,(N'ButtonResourceKeyConstants', N'LivestockDiseaseReportFarmHerdSpeciesAddHerdButtonText', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2483"')

,(N'ButtonResourceKeyConstants', N'LivestockDiseaseReportSamplesImportButtonText', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSamples + "94"')
,(N'ButtonResourceKeyConstants', N'LivestockDiseaseReportReturnToDiseaseReportButtonText', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReport + "1813"')

--        //VUC05 - Enter Avian Disease Report and VUC07 - Edit Avian Disease Report
,(N'ButtonResourceKeyConstants', N'AvianDiseaseReportFarmFlockSpeciesAddFlockButtonText', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2481"')

,(N'ButtonResourceKeyConstants', N'AvianDiseaseReportSamplesImportButtonText', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSamples + "94"')
,(N'ButtonResourceKeyConstants', N'AvianDiseaseReportReturnToDiseaseReportButtonText', N'InterfaceEditorResourceSetEnum.AvianDiseaseReport + "1813"')

--        //VUC17 and 18 - Add Disease Reports
,(N'ButtonResourceKeyConstants', N'FarmDiseaseReportsAddLivestockDiseaseReportButtonText', N'InterfaceEditorResourceSetEnum.FarmDetails + "3259"')

,(N'ButtonResourceKeyConstants', N'FarmDiseaseReportsAddAvianDiseaseReportButtonText', N'InterfaceEditorResourceSetEnum.FarmDetails + "3260"')

--endregion Veterinary Module Resources

--        //Human and Veterinary Aggregate Disease Reports Summary Common
--        //HAUC05 - Enter Human Aggregate Disease Reports Summary
--        //VAUC13 - Enter Veterinary Aggregate Disease Reports Summary
,(N'ButtonResourceKeyConstants', N'SelectedAggregateDiseaseReportsRemoveAllButtonText', N'InterfaceEditorResourceSetEnum.SelectedAggregateDiseaseReports + "1876"')

,(N'ButtonResourceKeyConstants', N'SelectedAggregateDiseaseReportsShowSummaryDataButtonText', N'InterfaceEditorResourceSetEnum.SelectedAggregateDiseaseReports + "772"')

--        // VUC17 Veterniary Farm Add
--        // VUC18 Veterniary Farm Edit
,(N'ButtonResourceKeyConstants', N'ReturnToFarmButtonText', N'InterfaceEditorResourceSetEnum.Farm + "3186"')

--region WHO Export
--        //SINT03
,(N'ButtonResourceKeyConstants', N'HumanExporttoCISIDGenerateButtonText', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "87"')
,(N'ButtonResourceKeyConstants', N'HumanExporttoCISIDExportButtonText', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4643"')
,(N'ButtonResourceKeyConstants', N'HumanExporttoCISIDReturntoWHOExportButtonText', N'InterfaceEditorResourceSetEnum.HumanExporttoCISID + "4646"')

--        #endregion


--MessageResourceKeyConstants

--region Common Resources

insert into #Caption (captionClass, controlCaptionConstant, controlCaptionIdRaw) values
 (N'MessageResourceKeyConstants', N'AccessoryCodeMandatoryMessage', N'InterfaceEditorResourceSetEnum.WarningMessages + "5"')
,(N'MessageResourceKeyConstants', N'AccessRuleCreatedSuccessfullyMessage', N'InterfaceEditorResourceSetEnum.AccessRuleDetails + "552"')
,(N'MessageResourceKeyConstants', N'AccessRuleDeletedSuccessfullyMessage', N'InterfaceEditorResourceSetEnum.AccessRuleDetails + "554"')
,(N'MessageResourceKeyConstants', N'AccessRuleUpdatedSuccessfullyMessage', N'InterfaceEditorResourceSetEnum.AccessRuleDetails + "553"')
,(N'MessageResourceKeyConstants', N'ActivateEmployeeAccessForOrganizationConfirmationMessage', N'InterfaceEditorResourceSetEnum.Employees + "576"')
,(N'MessageResourceKeyConstants', N'ActivateEmployeeRoleAndPermissionsConfirmationMessage', N'InterfaceEditorResourceSetEnum.Employees + "581"')
,(N'MessageResourceKeyConstants', N'ChangeEmployeeCategoryConfirmationMessage', N'InterfaceEditorResourceSetEnum.Employees + "580"')
,(N'MessageResourceKeyConstants', N'ChangesMadeToTheRecordWillBeLostIfYouLeaveThePageDoYouWantToContinueMessage', N'InterfaceEditorResourceSetEnum.Messages + "945"')
,(N'MessageResourceKeyConstants', N'Date1MustBeSameOrEarlierThanDate2Message', N'InterfaceEditorResourceSetEnum.WarningMessages + "49"')
,(N'MessageResourceKeyConstants', N'Date2MustBeSameOrLaterThanDate1Message', N'InterfaceEditorResourceSetEnum.WarningMessages + "50"')
,(N'MessageResourceKeyConstants', N'FutureDatesAreNotAllowedMessage', N'InterfaceEditorResourceSetEnum.WarningMessages + "85"')
,(N'MessageResourceKeyConstants', N'DeactivateEmployeeAccessForOrganizationConfirmationMessage', N'InterfaceEditorResourceSetEnum.Employees + "577"')
,(N'MessageResourceKeyConstants', N'DefaultValueMandatoryMessage', N'InterfaceEditorResourceSetEnum.WarningMessages + "59"')
,(N'MessageResourceKeyConstants', N'DoYouWantToCancelMessage', N'InterfaceEditorResourceSetEnum.WarningMessages + "34"')
,(N'MessageResourceKeyConstants', N'DoYouWantToSaveYourChangesMessage', N'InterfaceEditorResourceSetEnum.WarningMessages + "240"')
,(N'MessageResourceKeyConstants', N'DoYouWantToCancelChangesMessage', N'InterfaceEditorResourceSetEnum.WarningMessages + "33"')
,(N'MessageResourceKeyConstants', N'DoYouWantToDeleteThisRecordMessage', N'InterfaceEditorResourceSetEnum.WarningMessages + "61"')
,(N'MessageResourceKeyConstants', N'DoYouWantToPrintBarcodesMessage', N'InterfaceEditorResourceSetEnum.WarningMessages + "1011"')
,(N'MessageResourceKeyConstants', N'UnableToDeleteBecauseOfChildRecordsMessage', N'InterfaceEditorResourceSetEnum.WarningMessages + "948"')
,(N'MessageResourceKeyConstants', N'DuplicateInvestigationTypeSpeciesDiseaseValueMessage', N'InterfaceEditorResourceSetEnum.VeterinaryDiagnosticInvestigation + "556"')
,(N'MessageResourceKeyConstants', N'DuplicateOrganizationAbbreviatedNameFullNameMessage', N'InterfaceEditorResourceSetEnum.Organizations + "590"')
,(N'MessageResourceKeyConstants', N'DuplicateRecordsAreNotAllowedMessage', N'InterfaceEditorResourceSetEnum.DataAccessDetailsModal + "512"')
,(N'MessageResourceKeyConstants', N'DuplicateRecordsHaveBeenFoundMessage', N'InterfaceEditorResourceSetEnum.Employees + "586"')
,(N'MessageResourceKeyConstants', N'ItIsNotPossibleToHaveTwoRecordsWithSameValueDoYouWantToCorrectValueMessage', N'InterfaceEditorResourceSetEnum.WarningMessages + "73"')
,(N'MessageResourceKeyConstants', N'DuplicateReferenceValueMessage', N'InterfaceEditorResourceSetEnum.WarningMessages + "74"')
,(N'MessageResourceKeyConstants', N'DuplicateUniqueOrganizationIDMessage', N'InterfaceEditorResourceSetEnum.Organizations + "589"')
,(N'MessageResourceKeyConstants', N'DuplicateValueMessage', N'InterfaceEditorResourceSetEnum.DiseaseAgeGroupMatrix + "589"')
,(N'MessageResourceKeyConstants', N'ItIsNotPossibleToCreateTwoRecordsWithTheSameValueTheRecordWithAlreadyExistsDoYouWantToCorrectTheValueMessage', N'InterfaceEditorResourceSetEnum.Messages + "966"')
,(N'MessageResourceKeyConstants', N'NoRecordsFoundMessage', N'InterfaceEditorResourceSetEnum.Messages + "144"')
,(N'MessageResourceKeyConstants', N'EnterAtLeastOneParameterMessage', N'InterfaceEditorResourceSetEnum.WarningMessages + "77"')
,(N'MessageResourceKeyConstants', N'EnterBetweenXandXCharactersMessage', N'InterfaceEditorResourceSetEnum.Messages + "726"')
,(N'MessageResourceKeyConstants', N'FieldIsRequiredMessage', N'InterfaceEditorResourceSetEnum.WarningMessages + "231"')
,(N'MessageResourceKeyConstants', N'FieldIsInvalidValidRangeIsMessage', N'InterfaceEditorResourceSetEnum.Messages + "555"')
,(N'MessageResourceKeyConstants', N'InUseReferenceValueMessage', N'InterfaceEditorResourceSetEnum.WarningMessages + "99"')
,(N'MessageResourceKeyConstants', N'InUseReferenceValueAreYouSureMessage', N'InterfaceEditorResourceSetEnum.WarningMessages + "596"')
,(N'MessageResourceKeyConstants', N'InvalidFieldMessage', N'InterfaceEditorResourceSetEnum.WarningMessages + "100"')
,(N'MessageResourceKeyConstants', N'IsRequiredMessage', N'InterfaceEditorResourceSetEnum.Messages + "588"')
,(N'MessageResourceKeyConstants', N'LoginMustBeMessage', N'InterfaceEditorResourceSetEnum.Employees + "583"')
,(N'MessageResourceKeyConstants', N'LowerBoundaryMustBeLessThanUpperBoundaryMessage', N'InterfaceEditorResourceSetEnum.WarningMessages + "551"')
,(N'MessageResourceKeyConstants', N'NationalValueMandatoryMessage', N'InterfaceEditorResourceSetEnum.WarningMessages + "141"')
,(N'MessageResourceKeyConstants', N'NumberIsOutOfRangeMessage', N'InterfaceEditorResourceSetEnum.Messages + "958"')
,(N'MessageResourceKeyConstants', N'PleaseWaitWhileWeProcessYourRequestMessage', N'InterfaceEditorResourceSetEnum.Employees + "595"')
,(N'MessageResourceKeyConstants', N'ProblemHasOccurredMessage', N'InterfaceEditorResourceSetEnum.ErrorMessages + "ProblemHasOccurred"')
,(N'MessageResourceKeyConstants', N'RangeFromXandXCharactersMessage', N'InterfaceEditorResourceSetEnum.Messages + "968"')
,(N'MessageResourceKeyConstants', N'RecordDeletedSuccessfullyMessage', N'InterfaceEditorResourceSetEnum.Messages + "219"')
,(N'MessageResourceKeyConstants', N'RecordSavedSuccessfullyMessage', N'InterfaceEditorResourceSetEnum.Messages + "591"')
,(N'MessageResourceKeyConstants', N'RecordSubmittedSuccessfullyMessage', N'InterfaceEditorResourceSetEnum.Messages + "223"')
,(N'MessageResourceKeyConstants', N'RecordSubmittedSuccessfullyDoYouWantToAddAnotherRecordMessage', N'InterfaceEditorResourceSetEnum.Messages + "29"')
,(N'MessageResourceKeyConstants', N'ReferenceRecordCreatedSuccessfullyMessage', N'InterfaceEditorResourceSetEnum.Messages + "218"')
,(N'MessageResourceKeyConstants', N'SearchReturnedTooManyResultsMessage', N'InterfaceEditorResourceSetEnum.Messages + "2801"')
,(N'MessageResourceKeyConstants', N'UnableToDeleteContainsChildObjectsMessage', N'InterfaceEditorResourceSetEnum.WarningMessages + "270"')
,(N'MessageResourceKeyConstants', N'YourChangesSavedSuccessfullyMessage', N'InterfaceEditorResourceSetEnum.Messages + "703"')
,(N'MessageResourceKeyConstants', N'WarningMessagesYourPermissionsAreInsufficientToPerformThisFunctionMessage', N'InterfaceEditorResourceSetEnum.WarningMessages + "2812"')
,(N'MessageResourceKeyConstants', N'MessagesRecordIDisMessage', N'InterfaceEditorResourceSetEnum.Messages + "2868"')

,(N'MessageResourceKeyConstants', N'GlobalMustBeEqualToMessage', N'InterfaceEditorResourceSetEnum.Global + "2793"')
,(N'MessageResourceKeyConstants', N'GlobalMustBeGreaterThanMessage', N'InterfaceEditorResourceSetEnum.Global + "2794"')
,(N'MessageResourceKeyConstants', N'GlobalMustBeGreaterThanOrEqualToMessage', N'InterfaceEditorResourceSetEnum.Global + "2795"')
,(N'MessageResourceKeyConstants', N'GlobalMustBeLessThanMessage', N'InterfaceEditorResourceSetEnum.Global + "2796"')
,(N'MessageResourceKeyConstants', N'GlobalMustBeLessThanOrEqualToMessage', N'InterfaceEditorResourceSetEnum.Global + "2797"')
,(N'MessageResourceKeyConstants', N'ErrorMessagesTheFieldIsInErrorYouMustCorrectDataInThisFieldBeforeSavingTheFormMessage', N'InterfaceEditorResourceSetEnum.ErrorMessages + "3150"')

--        //SYSUC01 - Login
,(N'MessageResourceKeyConstants', N'LoginCombinationOfUserPasswordYouEnteredIsNotCorrectMessage', N'InterfaceEditorResourceSetEnum.Login + "2756"')

,(N'MessageResourceKeyConstants', N'LoginTheUserIsLockedOutMessage', N'InterfaceEditorResourceSetEnum.Login + "274"')

--        //SYSUC04 - Change Password
,(N'MessageResourceKeyConstants', N'PasswordMustBeMessage', N'InterfaceEditorResourceSetEnum.Employees + "584"')

,(N'MessageResourceKeyConstants', N'PasswordsDoNotMatchMessage', N'InterfaceEditorResourceSetEnum.Employees + "585"')
,(N'MessageResourceKeyConstants', N'ChangePasswordPasswordIsSuccessfullySavedMessage', N'InterfaceEditorResourceSetEnum.ChangePassword + "2556"')

--        //Human and Veterinary Active Surveillance Campaign Common
--        //HASUC01 - Enter Active Surveillance Campaign and HASUC02 - Edit Active Surveillance Campaign
--        //VASUC01 - Enter Active Surveillance Campaign and VASUC06 - Edit Active Surveillance Campaign
,(N'MessageResourceKeyConstants', N'HumanActiveSurveillanceCampaignUnableToDeleteDependentOnAnotherObjectMessage', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "271"')

,(N'MessageResourceKeyConstants', N'HumanActiveSurveillanceCampaignDuplicateRecordFoundDoYouWantToContinueSavingTheCurrentRecordMessage', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "2520"')
,(N'MessageResourceKeyConstants', N'HumanActiveSurveillanceCampaignCampaignStartDateMustBeEarlierThanOrSameAsCampaignEndDateMessage', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "2521"')
,(N'MessageResourceKeyConstants', N'HumanActiveSurveillanceCampaignActiveSurveillanceCampaignStatusCanNotBeClosedOpenSessionsAssociatedMessage', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "2522"')
,(N'MessageResourceKeyConstants', N'HumanActiveSurveillanceCampaignActivesurveillanceCampaignStatusCanNotBeNewSessionsAssociatedMessage', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "2523"')
,(N'MessageResourceKeyConstants', N'HumanActiveSurveillanceCampaignDiseaseSampleRequiredMessage', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "4233"')

,(N'MessageResourceKeyConstants', N'VeterinaryActiveSurveillanceCampaignUnableToDeleteDependentOnAnotherObjectMessage', N'InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceCampaign + "271"')
,(N'MessageResourceKeyConstants', N'VeterinaryActiveSurveillanceCampaignDuplicateRecordFoundDoYouWantToContinueSavingTheCurrentRecordMessage', N'InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceCampaign + "2520"')
,(N'MessageResourceKeyConstants', N'VeterinaryActiveSurveillanceCampaignCampaignStartDateMustBeEarlierThanOrSameAsCampaignEndDateMessage', N'InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceCampaign + "2521"')
,(N'MessageResourceKeyConstants', N'VeterinaryActiveSurveillanceCampaignActiveSurveillanceCampaignStatusCanNotBeClosedOpenSessionsAssociatedMessage', N'InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceCampaign + "2522"')
,(N'MessageResourceKeyConstants', N'VeterinaryActiveSurveillanceCampaignActivesurveillanceCampaignStatusCanNotBeNewSessionsAssociatedMessage', N'InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceCampaign + "2523"')
,(N'MessageResourceKeyConstants', N'VeterinaryActiveSurveillanceCampaignDiseaseSpeciesSampleRequiredMessage', N'InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceCampaign + "4234"')

--        //VASUC09 - Deleting Active Surveillance Session
,(N'MessageResourceKeyConstants', N'VeterinaryActiveSurveillanceSessionUnabletodeletethisrecordasitisdependentonanotherobjectMessage', N'InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceSession + "3752"')

,(N'MessageResourceKeyConstants', N'VeterinarySessionDiseaseSpeciesListMustBeTheSameAsCampaignMessage', N'InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceSession + "4136"')
,(N'MessageResourceKeyConstants', N'VeterinaryActiveSurveillanceSessionUnabletodeletethisrecordasitcontainsdependentchildobjectsMessage', N'InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceSession + "948"')

--endregion Common Resources

--region Administration Module Resources

--        //SAUC08 - Delete Organization
,(N'MessageResourceKeyConstants', N'CannotDeleteOrganizationConnectedToSiteMessage', N'InterfaceEditorResourceSetEnum.Organizations + "593"')

--        //SAUC13 -1 - Load Statistical Data
,(N'MessageResourceKeyConstants', N'StatisticalDataInvalidnumberoffieldsinlineLinemustcontains8fieldsseparatedbycommaMessage', N'InterfaceEditorResourceSetEnum.StatisticalData + "3449"')

,(N'MessageResourceKeyConstants', N'StatisticalDataInvalidnumberoffieldsinlineLinemustcontains12fieldsseparatedbycommaMessage', N'InterfaceEditorResourceSetEnum.StatisticalData + "3449"')
,(N'MessageResourceKeyConstants', N'StatisticalDataInvalidstatisticaldatatypeValueXisemptyornotfoundinreferencestableMessage', N'InterfaceEditorResourceSetEnum.StatisticalData + "3450"')
,(N'MessageResourceKeyConstants', N'StatisticalDataInvalidstatisticvalueStringXcantbeconvertedtointegerMessage', N'InterfaceEditorResourceSetEnum.StatisticalData + "3451"')
,(N'MessageResourceKeyConstants', N'StatisticalDataInvaliddateformatStringXcantbeconvertedtodateAlldatesmustbepresentedinformat_ddmmyyyy_Message', N'InterfaceEditorResourceSetEnum.StatisticalData + "3452"')
,(N'MessageResourceKeyConstants', N'StatisticalDataDateXisnotvalidstartmonthdateMessage', N'InterfaceEditorResourceSetEnum.StatisticalData + "3453"')
,(N'MessageResourceKeyConstants', N'StatisticalDataDateXisnotvalidstartquarterdateMessage', N'InterfaceEditorResourceSetEnum.StatisticalData + "3454"')
,(N'MessageResourceKeyConstants', N'StatisticalDataDateXisnotvalidstartweekdateMessage', N'InterfaceEditorResourceSetEnum.StatisticalData + "3455"')
,(N'MessageResourceKeyConstants', N'StatisticalDataDateXisnotvalidstartyeardateMessage', N'InterfaceEditorResourceSetEnum.StatisticalData + "3456"')
,(N'MessageResourceKeyConstants', N'StatisticalDataInvalidcountrynameValueXisemptyornotfoundinreferencestableMessage', N'InterfaceEditorResourceSetEnum.StatisticalData + "3457"')
,(N'MessageResourceKeyConstants', N'StatisticalDataInvalidregionnameValueXisemptyornotfoundinreferencestableMessage', N'InterfaceEditorResourceSetEnum.StatisticalData + "3458"')
,(N'MessageResourceKeyConstants', N'StatisticalDataInvalidrayonnameValueXisemptyornotfoundinreferencestableMessage', N'InterfaceEditorResourceSetEnum.StatisticalData + "3459"')
,(N'MessageResourceKeyConstants', N'StatisticalDataInvalidsettlementnameValueXisemptyornotfoundinreferencestableMessage', N'InterfaceEditorResourceSetEnum.StatisticalData + "3460"')
,(N'MessageResourceKeyConstants', N'StatisticalDataInvalidparameternameValueXisemptyornotfoundinreferencestableMessage', N'InterfaceEditorResourceSetEnum.StatisticalData + "3461"')
,(N'MessageResourceKeyConstants', N'StatisticalDataFieldismissedMessage', N'InterfaceEditorResourceSetEnum.StatisticalData + "3462"')
,(N'MessageResourceKeyConstants', N'StatisticalDataThedataappearstobecorruptedatpositionXMessage', N'InterfaceEditorResourceSetEnum.StatisticalData + "3463"')
,(N'MessageResourceKeyConstants', N'StatisticalDataLine0Column1Message', N'InterfaceEditorResourceSetEnum.StatisticalData + "3473"')
,(N'MessageResourceKeyConstants', N'StatisticalDataDatawasnotimportedInputdatacontainstoomanyerrorsMaximumErrorNumberisexceededMessage', N'InterfaceEditorResourceSetEnum.StatisticalData + "3528"')
,(N'MessageResourceKeyConstants', N'StatisticalDataDataimportwascompletedwithmistakesThefollowinglinescontainederrorsandwerenotimportedMessage', N'InterfaceEditorResourceSetEnum.StatisticalData + "3529"')
,(N'MessageResourceKeyConstants', N'StatisticalDataThefollowinglinescontainerrorsandwillnotbeimportedImportdataMessage', N'InterfaceEditorResourceSetEnum.StatisticalData + "3530"')
,(N'MessageResourceKeyConstants', N'StatisticalDataThefileformatisincorrectPleaseselectproperfileformatMessage', N'InterfaceEditorResourceSetEnum.StatisticalData + "3531"')
,(N'MessageResourceKeyConstants', N'StatisticalDataImportdataMessage', N'InterfaceEditorResourceSetEnum.StatisticalData + "3541"')
,(N'MessageResourceKeyConstants', N'StatisticalDataThefollowinglinescontainerrorsandwillnotbeimportedMessage', N'InterfaceEditorResourceSetEnum.StatisticalData + "3542"')

--        //SAUC15 - Search Statistical Data Record
,(N'MessageResourceKeyConstants', N'SearchStatisticalDataRecordDateenteredmustbeearlierthanStatisticalDataforPeriodToMessage', N'InterfaceEditorResourceSetEnum.SearchStatisticalDataRecord + "3393"')

,(N'MessageResourceKeyConstants', N'SearchStatisticalDataRecordStartDateforPeriodTomustoccurafterStatisticalDataforPeriodFromMessage', N'InterfaceEditorResourceSetEnum.SearchStatisticalDataRecord + "3394"')

--        //SAUC26 and 27 - Enter and Edit a User Group
,(N'MessageResourceKeyConstants', N'UserGroupDetailsYoucanselectuptosixiconsMessage', N'InterfaceEditorResourceSetEnum.UserGroupDetails + "3921"')

--        //SAUC30 - Restore a Data Audit Log Transaction
,(N'MessageResourceKeyConstants', N'DataAuditLogDetailsObjectsAreSuccessfullyRestoredMessage', N'InterfaceEditorResourceSetEnum.DataAuditLogDetails + "3005"')

,(N'MessageResourceKeyConstants', N'DataAuditLogDetailsThisObjectCantBeRestoredMessage', N'InterfaceEditorResourceSetEnum.DataAuditLogDetails + "3006"')

--        //SAUC53 - Edit EIDSS Sites
,(N'MessageResourceKeyConstants', N'AttentionModifyingTheseSettingsMayDamageIntegrityOfDataMessage', N'InterfaceEditorResourceSetEnum.WarningMessages + "1000"')

--region Deduplication Sub-Module

,(N'MessageResourceKeyConstants', N'AvianDiseaseReportDeduplicationFieldValuePairsFoundWithNoSelectionAllFieldValuePairsMustContainASelectedValueToSurviveMessage', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportDeduplication + "899"')
,(N'MessageResourceKeyConstants', N'AvianDiseaseReportDeduplicationDoYouWantToDeduplicateRecordMessage', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportDeduplication + "941"')
,(N'MessageResourceKeyConstants', N'AvianDiseaseReportDeduplicationMergeCompleteSavedSuccessfullyToTheDatabaseMessage', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportDeduplication + "1074"')

--        //DDUC03
,(N'MessageResourceKeyConstants', N'DeduplicationPersonDoyouwanttodeduplicaterecordMessage', N'InterfaceEditorResourceSetEnum.DeduplicationPerson + "3196"')

,(N'MessageResourceKeyConstants', N'DeduplicationPersonFieldvaluepairsfoundwithnoselectionAllfieldvaluepairsmustcontainaselectedvaluetosurviveMessage', N'InterfaceEditorResourceSetEnum.DeduplicationPerson + "3197"')
,(N'MessageResourceKeyConstants', N'DeduplicationPersonAllfieldvaluepairscontainunmatchedvaluesUnabletocompletededuplicationofrecordreportMessage', N'InterfaceEditorResourceSetEnum.DeduplicationPerson + "3198"')
,(N'MessageResourceKeyConstants', N'DeduplicationPersonSurvivorSupersededReportRecordIdentifierfoundwithnoselectionUnabletocompletededuplicationofrecordreportMessage', N'InterfaceEditorResourceSetEnum.DeduplicationPerson + "3199"')

--        //DDUC05
,(N'MessageResourceKeyConstants', N'DeduplicationLivestockReportUnabletocompletededuplicationofrecordswithmorethanoneherdMessage', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockReport + "3591"')

,(N'MessageResourceKeyConstants', N'DeduplicationLivestockReportUnabletocompletededuplicationofrecordswithmorethanonespeciesMessage', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockReport + "3592"')
,(N'MessageResourceKeyConstants', N'DeduplicationLivestockReportUnabletocompletededuplicationofrecordswithdifferentspeciesMessage', N'InterfaceEditorResourceSetEnum.DeduplicationLivestockReport + "3593"')

--        //DDUC06
,(N'MessageResourceKeyConstants', N'AvianDiseaseReportDeduplicationUnabletocompletededuplicationofrecordswithmorethanoneflockMessage', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportDeduplication + "3584"')

,(N'MessageResourceKeyConstants', N'AvianDiseaseReportDeduplicationUnabletocompletededuplicationofrecordsfromdifferentfarmsMessage', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportDeduplication + "3922"')

--endregion Deduplication Sub-Module

--endregion Administration Module Resources

--region Configuration Module Resources

--        //SCUC11 - Configure Test – Test Results Matrix
,(N'MessageResourceKeyConstants', N'TestTestResultMatrixTestResultsIsMandatoryMessage', N'InterfaceEditorResourceSetEnum.TestTestResultMatrix + "960"')

--        //SCUC14 - Configure Vector Type - Field Test Matrix
,(N'MessageResourceKeyConstants', N'VectorTypeFieldTestMatrixFieldTestIsMandatoryMessage', N'InterfaceEditorResourceSetEnum.VectorTypeFieldTestMatrix + "959"')

--region Flexible Form Designer

,(N'MessageResourceKeyConstants', N'FlexibleFormDesignerFlexFormAssignedToOutbreakSessionMessage', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "2726"')
,(N'MessageResourceKeyConstants', N'FlexibleFormDesignerTherecordissavedsuccessfullyMessage', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "591"')
,(N'MessageResourceKeyConstants', N'FlexibleFormDesignerDoyouwanttodeletethisparameterMessage', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "3915"')
,(N'MessageResourceKeyConstants', N'FlexibleFormDesignerProblemWithDesignMessage', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "4490"')

--endregion Flexible Form Designer

--endregion Configuration Module Resources

--region Reports Module Resources

,(N'MessageResourceKeyConstants', N'FirstAndSecondYearsMessage', N'InterfaceEditorResourceSetEnum.Reports + "401"')
,(N'MessageResourceKeyConstants', N'ReportsSecondAndFirstYearsMessage', N'InterfaceEditorResourceSetEnum.Reports + "SecondAndFirstYears"')
,(N'MessageResourceKeyConstants', N'DatesCompareMessage', N'InterfaceEditorResourceSetEnum.Reports + "394"')
,(N'MessageResourceKeyConstants', N'FromToDatesCompareMessage', N'InterfaceEditorResourceSetEnum.Reports + "406"')
,(N'MessageResourceKeyConstants', N'ReportsOnlyFiveSelectedYearsWillBeRepresentedInTheReportMessage', N'InterfaceEditorResourceSetEnum.Reports + "2805"')
,(N'MessageResourceKeyConstants', N'ReportsTooManyDiseasesMessage', N'InterfaceEditorResourceSetEnum.Reports + "448"')
,(N'MessageResourceKeyConstants', N'ReportsTooManyDiseasesAllow12Message', N'InterfaceEditorResourceSetEnum.Reports + "449"')
,(N'MessageResourceKeyConstants', N'ReportsTooManyItemsMessage', N'InterfaceEditorResourceSetEnum.Reports + "450"')
,(N'MessageResourceKeyConstants', N'ReportsTooManySpeciesTypesMessage', N'InterfaceEditorResourceSetEnum.Reports + "451"')
,(N'MessageResourceKeyConstants', N'ReportsYearSelectedInToFilterShallBeGreaterThanYearSelectedInFromFilterYearsMessage', N'InterfaceEditorResourceSetEnum.Reports + "458"')
,(N'MessageResourceKeyConstants', N'ReportsYear1ShallBeGreaterThanYear2Message', N'InterfaceEditorResourceSetEnum.Reports + "2799"')
,(N'MessageResourceKeyConstants', N'ReportsYouCanSpecifyNotMoreThanThreeSpeciesInSpeciesTypeFilterMessage', N'InterfaceEditorResourceSetEnum.Reports + "2806"')

--endregion Reports Module Resources

--region Human Module Resources

--        //Common
,(N'MessageResourceKeyConstants', N'MessagesTherecordissavedsuccessfullyMessage', N'InterfaceEditorResourceSetEnum.Messages + "2771"')

--        //HASUC01
,(N'MessageResourceKeyConstants', N'HumanActiveSurveillanceCampaignReturntoActiveSurveillanceCampaignMessage', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "833"')

,(N'MessageResourceKeyConstants', N'HumanActiveSurveillanceCampaignReturntoDashboardMessage', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "232"')

--        //HASUC03
,(N'MessageResourceKeyConstants', N'HumanActiveSurveillanceCampaignReturntoActiveSurveillanceSessionMessage', N'InterfaceEditorResourceSetEnum.HumanActiveSurveillanceCampaign + "865"')

--        //HAUC05 - Enter Human Aggregate Disease Reports Summary
,(N'MessageResourceKeyConstants', N'HumanAggregateDiseaseReportSummaryAdministrativeLevelMismatchMessage', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportSummary + "2552"')

,(N'MessageResourceKeyConstants', N'HumanAggregateDiseaseReportSummaryTimeIntervalUnitMismatchMessage', N'InterfaceEditorResourceSetEnum.HumanAggregateDiseaseReportSummary + "2553"')

--        //HAUC06 - Enter ILI Aggregate Form and HAUC07 - Edit ILI Aggregate Form
,(N'MessageResourceKeyConstants', N'ILIAggregateDetailsRecordWithThisHospitalSentinelStationAlreadyExistsMessage', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "2714"')

,(N'MessageResourceKeyConstants', N'ILIAggregateDetailsOnlyOneFormCanBeCreatedForTheSameTimeIntervalAndSiteMessage', N'InterfaceEditorResourceSetEnum.ILIAggregateDetails + "2715"')

--        //HAUC10 and HAUC11 - Enter and Edit Weekly Reporting Form
,(N'MessageResourceKeyConstants', N'WeeklyReportingFormDetailsDuplicateRecordMessage', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "785"')
,(N'MessageResourceKeyConstants', N'WeeklyReportingFormDetailsRecordSavedSuccessfullyTheRecordIDIsMessage', N'InterfaceEditorResourceSetEnum.WeeklyReportingFormDetails + "3407"')

--        //HUC03 - Enter a Human Disease Report and HUC05 - Edit a Human Disease Report
,(N'MessageResourceKeyConstants', N'HumanDiseaseReportYouSuccessfullyCreatedANewDiseaseReportInTheEIDSSSystemTheEIDSSIDIsMessage', N'InterfaceEditorResourceSetEnum.HumanDiseaseReport + "3116"')

,(N'MessageResourceKeyConstants', N'HumanDiseaseReportSymptomsDateShallBeOnOrEarlierThanDateOfSymptomOnsetNoFutureDatesAreAllowedMessage', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSymptoms + "2783"')
,(N'MessageResourceKeyConstants', N'HumanDiseaseReportCaseInvestigationDateShallBeOnOrAfterDateOfNotificationNoFutureDatesAreAllowedMessage', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportCaseInvestigation + "2784"')
,(N'MessageResourceKeyConstants', N'HumanDiseaseReportSamplesSampleIsAccessionedDoYouWantToDeleteTheSampleRecordMessage', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportSamples + "2811"')
,(N'MessageResourceKeyConstants', N'HumanDiseaseReportFinalOutcomeFinalCaseClassificationDoesNotMatchTheBasisOfDiagnosisMessage', N'InterfaceEditorResourceSetEnum.HumanDiseaseReportFinalOutcome + "3174"')
,(N'MessageResourceKeyConstants', N'HumanDiseaseReportTheSelectedDiseaseValueDoesNotMatchToPersonGenderMessage', N'InterfaceEditorResourceSetEnum.HumanDiseaseReport + "3404"')
,(N'MessageResourceKeyConstants', N'HumanDiseaseReportTheSelectedDiseaseValueDoesNotMatchToPersonAgeMessage', N'InterfaceEditorResourceSetEnum.HumanDiseaseReport + "3405"')
,(N'MessageResourceKeyConstants', N'HumanDiseaseReportSoughtCareDateShallBeOnOrAfterDateOfSymptomOnsetAndNoLaterThanDateOfDiagnosisMessage', N'InterfaceEditorResourceSetEnum.HumanDiseaseReport + "4369"')
,(N'MessageResourceKeyConstants', N'HumanDiseaseReportDateshallbeonorearlierthanDateofDiagnosisMessage', N'InterfaceEditorResourceSetEnum.HumanDiseaseReport + "4748"')

--        //HUC11 - Create a Connected Human Disease Report
,(N'MessageResourceKeyConstants', N'HumanDiseaseReportDoYouWantToCreateANewNotifiableDiseaseReportWithAChangedDiseaseValueForThisPersonMessage', N'InterfaceEditorResourceSetEnum.HumanDiseaseReport + "3375"')

,(N'MessageResourceKeyConstants', N'HumanDiseaseReportDiseasevalueinoriginalandconnectedDiseaseReportscannotbesameMessage', N'InterfaceEditorResourceSetEnum.HumanDiseaseReport + "3408"')

--        //PIN Messages
,(N'MessageResourceKeyConstants', N'PersonInformationAccordingToTheSearchCriteriaNoRecordsFoundPleaseUpdateSearchCriteriaAndTryToFindPersonAgainMessage', N'InterfaceEditorResourceSetEnum.PersonInformation + "4754"')

,(N'MessageResourceKeyConstants', N'PersonInformationCivilRegistryServiceIsNotRespondingPleaseTryToFindThePersonLaterInCurrentLanguageMessage', N'InterfaceEditorResourceSetEnum.PersonInformation + "4755"')

--        //HUC02 
,(N'MessageResourceKeyConstants', N'PersonInformationDOBErrorMessage', N' InterfaceEditorResourceSetEnum.PersonInformation + "4808"')
,(N'MessageResourceKeyConstants', N'PersonInformationDOBWarningMessage100Years', N' InterfaceEditorResourceSetEnum.PersonInformation + "4809"')

,(N'MessageResourceKeyConstants', N'WeeklyReportingFormTotalMustBeGreaterThanAmongThemNotifiedMessage', N'InterfaceEditorResourceSetEnum.WeeklyReportingForm + "4811"')		

--endregion Human Module Resources

--region Laboratory Module Resources

--        //LUC01 - Accession a Sample
,(N'MessageResourceKeyConstants', N'LaboratorySamplesCommentMustBeAtLeastSixCharactersInLengthMessage', N'InterfaceEditorResourceSetEnum.Samples + "2779"')

,(N'MessageResourceKeyConstants', N'LaboratorySamplesCommentIsRequiredWhenSampleStatusIsAcceptedInPoorConditionOrRejectedMessage', N'InterfaceEditorResourceSetEnum.Samples + "2780"')

,(N'MessageResourceKeyConstants', N'GroupAccessionInModalLocalOrFieldSampleIDDoesNotExistMessage', N'InterfaceEditorResourceSetEnum.GroupAccessionInModal + "2765"')
,(N'MessageResourceKeyConstants', N'GroupAccessionInModalLocalOrFieldSampleIDIsAlreadyAccessionedMessage', N'InterfaceEditorResourceSetEnum.GroupAccessionInModal + "2766"')

--        //LUC03 - Transfer a Sample
,(N'MessageResourceKeyConstants', N'LaboratoryTransferredAreYouSureYouWantToCancelThisTransferMessage', N'InterfaceEditorResourceSetEnum.Transferred + "2789"')

--        //LUC09 - Edit a Test
,(N'MessageResourceKeyConstants', N'LaboratorySampleTestDetailsModalTestStartedDateMustBeOnOrAfterSampleAccessionDateMessage', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "4466"')

,(N'MessageResourceKeyConstants', N'LaboratorySampleTestDetailsModalResultDateMustBeOnOrAfterTestStartedDateMessage', N'InterfaceEditorResourceSetEnum.LaboratorySampleTestDetailsModal + "4413"')
,(N'MessageResourceKeyConstants', N'TestingTestResultIsRequiredMessage', N'InterfaceEditorResourceSetEnum.Testing + "4496"')
,(N'MessageResourceKeyConstants', N'TestingResultDateIsRequiredMessage', N'InterfaceEditorResourceSetEnum.Testing + "4497"')
,(N'MessageResourceKeyConstants', N'TestingResultDateMustBeEarlierOrEqualToTheCurrentDateMessage', N'InterfaceEditorResourceSetEnum.Testing + "4498"')

--        //LUC15 - Lab Record Deletion
,(N'MessageResourceKeyConstants', N'LaboratorySamplesFollowingSampleWillBeDeletedPleaseEnterReasonForDeletingSampleMessage', N'InterfaceEditorResourceSetEnum.Samples + "995"')

--        //LUC09 - Edit a Batch
,(N'MessageResourceKeyConstants', N'BatchesAllTestResultsMustBeEnteredToCloseABatchMessage', N'InterfaceEditorResourceSetEnum.Batches + "4389"')

--        //LUC16 - Approvals Workflow
,(N'MessageResourceKeyConstants', N'ApprovalsTestResultNotValidatedNotificationMessage', N'InterfaceEditorResourceSetEnum.Approvals + "2915"')

--        //LUC20 - Configure Sample Storage and LUC23 - Edit Sample Storage Schema
,(N'MessageResourceKeyConstants', N'FreezerDetailsOnceAFreezerIsDeletedNeitherTheFreezerNorItsSubdivisionsCanBeFurtherUsedOrAutomaticallRestoredDoYouWantToDeleteThisFreezerMessage', N'InterfaceEditorResourceSetEnum.FreezerDetails + "2499"')

,(N'MessageResourceKeyConstants', N'FreezerDetailsADuplicateRecordIsFoundTheBarCodeValueEnteredAlreadyExistsMessage', N'InterfaceEditorResourceSetEnum.FreezerDetails + "2718"')
,(N'MessageResourceKeyConstants', N'FreezerDetailsUnableToDeleteThisFreezerAsItContainsSamplesMessage', N'InterfaceEditorResourceSetEnum.FreezerDetails + "2719"')

--endregion Laboratory Module Resources

--region Outbreak Module Resources

--        //OMUC01
,(N'MessageResourceKeyConstants', N'CreateOutbreakThisrecordIDisMessage', N'InterfaceEditorResourceSetEnum.CreateOutbreak + "2790"')

--        //OMUC02
,(N'MessageResourceKeyConstants', N'CreateOutbreakTheFrequencycannotbelargerthanthedurationMessage', N'InterfaceEditorResourceSetEnum.CreateOutbreak + "2774"')

--        //OMUC03 - Import Disease Report
,(N'MessageResourceKeyConstants', N'ImportHumanCaseSelectedDiseaseReportIsAlreadyAssociatedWithAnOutbreakSessionMessage', N'InterfaceEditorResourceSetEnum.ImportHumanCase + "3020"')

,(N'MessageResourceKeyConstants', N'ImportVeterinaryCaseSelectedDiseaseReportIsAlreadyAssociatedWithAnOutbreakSessionMessage', N'InterfaceEditorResourceSetEnum.ImportVeterinaryCase + "3020"')
,(N'MessageResourceKeyConstants', N'ImportHumanCaseDateOfSymptomsOnsetStartOfSignsCannotBePriorToTheOutbreakStartDateMessage', N'InterfaceEditorResourceSetEnum.ImportHumanCase + "3021"')
,(N'MessageResourceKeyConstants', N'ImportVeterinaryCaseDateOfSymptomsOnsetStartOfSignsCannotBePriorToTheOutbreakStartDateMessage', N'InterfaceEditorResourceSetEnum.ImportVeterinaryCase + "3021"')
,(N'MessageResourceKeyConstants', N'ImportHumanCaseSelectedDiseaseReportsDiseaseDoesNotMatchTheOutbreakDiseaseMessage', N'InterfaceEditorResourceSetEnum.ImportHumanCase + "3022"')
,(N'MessageResourceKeyConstants', N'ImportVeterinaryCaseSelectedDiseaseReportsDiseaseDoesNotMatchTheOutbreakDiseaseMessage', N'InterfaceEditorResourceSetEnum.ImportVeterinaryCase + "3022"')

--        //OMUC04
,(N'MessageResourceKeyConstants', N'CreateHumanCaseHumanCasehasbeensavedsuccessfullyNewCaseIDMessage', N'InterfaceEditorResourceSetEnum.CreateHumanCase + "3656"')

--        //OMUC06
,(N'MessageResourceKeyConstants', N'CreateVeterinaryCaseVeterinaryCaseHasBeenSavedSuccessfullyNewCaseIDMessage', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3407"')

,(N'MessageResourceKeyConstants', N'CreateVeterinaryCaseTheFarmAddressDoesNotMatchTheSessionLocationDoYouWantToContinueMessage', N'InterfaceEditorResourceSetEnum.CreateVeterinaryCase + "3604"')

--endregion Outbreak Module Resources

--region Vector Module Resources

,(N'MessageResourceKeyConstants', N'VectorCollectionDateShallBeOnOrAfterSessionStartDateMessage', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSession + "3120"')
,(N'MessageResourceKeyConstants', N'VectorSurveillanceSessionUnableToDeleteDependentOnAnotherObjectMessage', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSession + "271"')
,(N'MessageResourceKeyConstants', N'VectorCollectionDateShallBeOnOrBeforeIdentifyingDateMessage', N'InterfaceEditorResourceSetEnum.VectorSessionVectorData + "4500"')
,(N'MessageResourceKeyConstants', N'VectorSurveillanceSessionNewSessionSavedSuccessfullyMessage', N'InterfaceEditorResourceSetEnum.VectorSurveillanceSession + "3407"')
,(N'MessageResourceKeyConstants', N'VectorIdentifyingDateShallBeOnOrAfterSessionStartDateMessage', N'InterfaceEditorResourceSetEnum.VectorSessionVectorData + "4501"')
,(N'MessageResourceKeyConstants', N'VectorIdentifyingDateShallBeOnOrAfterCollectionDateMessage', N'InterfaceEditorResourceSetEnum.VectorSessionVectorData + "4502"')
,(N'MessageResourceKeyConstants', N'VectorIdentifyingDateShallBeOnOrBeforeSessionCloseDateMessage', N'InterfaceEditorResourceSetEnum.VectorSessionVectorData + "4592"')

--endregion Vector Module Resources

--region Veterinary Module Resources

--        //VAUC13 - Enter Veterinary Aggregate Disease Reports Summary and VAUC14 - Enter Veterinary Aggregate Action Reports Summary
,(N'MessageResourceKeyConstants', N'VeterinaryAggregateActionReportSummaryAdministrativeLevelMismatchMessage', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReportSummary + "2552"')

,(N'MessageResourceKeyConstants', N'VeterinaryAggregateDiseaseReportDuplicateReportExistsMessage', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReport + "4465"')
,(N'MessageResourceKeyConstants', N'VeterinaryAggregateDiseaseReportSummaryAdministrativeLevelMismatchMessage', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReportSummary + "2552"')
,(N'MessageResourceKeyConstants', N'VeterinaryAggregateActionReportSummaryTimeIntervalUnitMismatchMessage', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReportSummary + "2553"')
,(N'MessageResourceKeyConstants', N'VeterinaryAggregateDiseaseReportSummaryTimeIntervalUnitMismatchMessage', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReportSummary + "2553"')
,(N'MessageResourceKeyConstants', N'VeterinaryAggregateActionsReportInformationNotificationReceivedByDateMustBeOnOrAfterNotificationSentByDateMessage', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReportNotificationReceivedBy + "4499"')
,(N'MessageResourceKeyConstants', N'VeterinaryAggregateDiseaseReportInformationNotificationReceivedByDateMustBeOnOrAfterNotificationSentByDateMessage', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateDiseaseReportNotificationReceivedBy + "4499"')

--        //VAUC02 and VAUC03 - Enter and Edit Veterinary Surveillance Session
,(N'MessageResourceKeyConstants', N'VeterinarySessionAggregatePositiveSampleQtyMoreThanAnimalsSampledMessage', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformationDetailsModal + "3374"')

,(N'MessageResourceKeyConstants', N'VeterinarySessionYouSuccessfullyCreatedANewVeterinarySurveillancSessionInTheEIDSSSystemTheEIDSSIDIsMessage', N'InterfaceEditorResourceSetEnum.VeterinaryActiveSurveillanceSession + "3407"')

--        //VAUC05 and VAUC07 - Enter and Edit Avian Disease Report
,(N'MessageResourceKeyConstants', N'AvianDiseaseReportUnableToDeleteDependentOnAnotherObjectMessage', N'InterfaceEditorResourceSetEnum.AvianDiseaseReport + "271"')

,(N'MessageResourceKeyConstants', N'AvianDiseaseReportYouSuccessfullyCreatedANewDiseaseReportInTheEIDSSSystemTheEIDSSIDIsMessage', N'InterfaceEditorResourceSetEnum.AvianDiseaseReport + "3407"')

--        //VAUC09/10/11/12 - Enter, Edit, Delete Veterinary Aggregate Actions Report
,(N'MessageResourceKeyConstants', N'VeterinaryAggregateActionsReportSuccessfullySavedTheEIDSSIDIsMessage', N'InterfaceEditorResourceSetEnum.VeterinaryAggregateActionReport + "3407"')

--        //Farm/Flock/Species Section
,(N'MessageResourceKeyConstants', N'AvianDiseaseReportFarmFlockSpeciesSpeciesIsRequiredMessage', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2974"')

,(N'MessageResourceKeyConstants', N'AvianDiseaseReportFarmFlockSpeciesTotalNumberOfAnimalsMessage', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2975"')
,(N'MessageResourceKeyConstants', N'AvianDiseaseReportFarmFlockSpeciesCantBeLessThanTheNumberOfDeadAnimalsMessage', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2976"')
,(N'MessageResourceKeyConstants', N'AvianDiseaseReportFarmFlockSpeciesCantBeLessThanTheNumberOfSickAnimalsMessage', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2977"')
,(N'MessageResourceKeyConstants', N'AvianDiseaseReportFarmFlockSpeciesTheFieldSpeciesIsRequiredYouMustEnterDataForEachFlockBeforeSavingTheRecordMessage', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2978"')
,(N'MessageResourceKeyConstants', N'AvianDiseaseReportFarmFlockSpeciesStartOfSignsMustBeTheSameOrEarlierThanCurrentDateMessage', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2979"')
,(N'MessageResourceKeyConstants', N'AvianDiseaseReportFarmFlockSpeciesThereAreNoFlocksLivestockAssociatedWithThisFarmDoYouWishToContinueMessage', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2980"')
,(N'MessageResourceKeyConstants', N'AvianDiseaseReportFarmFlockSpeciesTheSpeciesTypeSelectedHasAlreadyBeenAddedToTheSelectedFlockMessage', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2981"')
,(N'MessageResourceKeyConstants', N'AvianDiseaseReportFarmFlockSpeciesTheSpeciesTypeSelectedHasAlreadyBeenAddedToTheSelectedHerdMessage', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2982"')
,(N'MessageResourceKeyConstants', N'AvianDiseaseReportFarmFlockSpeciesTheSumOfDeadMessage', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2983"')
,(N'MessageResourceKeyConstants', N'AvianDiseaseReportFarmFlockSpeciesAndSickMessage', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2984"')
,(N'MessageResourceKeyConstants', N'AvianDiseaseReportFarmFlockSpeciesCantBeMoreThanTotalMessage', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2985"')

--        //Notification Section
,(N'MessageResourceKeyConstants', N'AvianDiseaseReportNotificationTheInitialReportDateMustBeEarlierThanOrSameAsAssignedDateMessage', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportNotification + "2988"')

,(N'MessageResourceKeyConstants', N'AvianDiseaseReportNotificationTheInvestigationDateMustBeLaterThanOrTheSameAstheAssignedDateMessage', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportNotification + "2989"')
,(N'MessageResourceKeyConstants', N'AvianDiseaseReportNotificationTheInitialReportDateMustBeEarlierThanOrSameAsInvestigationDateMessage', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportNotification + "2990"')

--        //Samples Section
,(N'MessageResourceKeyConstants', N'AvianDiseaseReportSamplesTheSentDateMustBeLaterThanOrSameAsCollectionDateMessage', N'InterfaceEditorResourceSetEnum.AvianDiseaseReportSamples + "2991"')

--        //VAUC04 and VAUC06 - Enter and Edit Livestock Disease Report
,(N'MessageResourceKeyConstants', N'LivestockDiseaseReportUnableToDeleteDependentOnAnotherObjectMessage', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReport + "271"')

,(N'MessageResourceKeyConstants', N'LivestockDiseaseReportYouSuccessfullyCreatedANewDiseaseReportInTheEIDSSSystemTheEIDSSIDIsMessage', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReport + "3407"')

--        //Farm/Herd/Species Section
,(N'MessageResourceKeyConstants', N'LivestockDiseaseReportFarmHerdSpeciesSpeciesIsRequiredMessage', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2974"')

,(N'MessageResourceKeyConstants', N'LivestockDiseaseReportFarmHerdSpeciesTotalNumberOfAnimalsMessage', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2975"')
,(N'MessageResourceKeyConstants', N'LivestockDiseaseReportFarmHerdSpeciesCantBeLessThanTheNumberOfDeadAnimalsMessage', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2976"')
,(N'MessageResourceKeyConstants', N'LivestockDiseaseReportFarmHerdSpeciesCantBeLessThanTheNumberOfSickAnimalsMessage', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2977"')
,(N'MessageResourceKeyConstants', N'LivestockDiseaseReportFarmHerdSpeciesTheFieldSpeciesIsRequiredYouMustEnterDataForEachFlockBeforeSavingTheRecordMessage', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2978"')
,(N'MessageResourceKeyConstants', N'LivestockDiseaseReportFarmHerdSpeciesStartOfSignsMustBeTheSameOrEarlierThanCurrentDateMessage', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2979"')
,(N'MessageResourceKeyConstants', N'LivestockDiseaseReportFarmHerdSpeciesThereAreNoFlocksLivestockAssociatedWithThisFarmDoYouWishToContinueMessage', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2980"')
,(N'MessageResourceKeyConstants', N'LivestockDiseaseReportFarmHerdSpeciesTheSpeciesTypeSelectedHasAlreadyBeenAddedToTheSelectedHerdMessage', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2982"')
,(N'MessageResourceKeyConstants', N'LivestockDiseaseReportFarmHerdSpeciesTheSumOfDeadMessage', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2983"')
,(N'MessageResourceKeyConstants', N'LivestockDiseaseReportFarmHerdSpeciesAndSickMessage', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2984"')
,(N'MessageResourceKeyConstants', N'LivestockDiseaseReportFarmHerdSpeciesCantBeMoreThanTotalMessage', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2985"')

--        //Notification Section
,(N'MessageResourceKeyConstants', N'LivestockDiseaseReportNotificationTheInitialReportDateMustBeEarlierThanOrSameAsAssignedDateMessage', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportNotification + "2988"')

,(N'MessageResourceKeyConstants', N'LivestockDiseaseReportNotificationTheInvestigationDateMustBeLaterThanOrTheSameAstheAssignedDateMessage', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportNotification + "2989"')
,(N'MessageResourceKeyConstants', N'LivestockDiseaseReportNotificationTheInitialReportDateMustBeEarlierThanOrSameAsInvestigationDateMessage', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportNotification + "2990"')

--        //Samples Section
,(N'MessageResourceKeyConstants', N'LivestockDiseaseReportSamplesTheSentDateMustBeLaterThanOrSameAsCollectionDateMessage', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSamples + "2991"')

--        //VUC17 - Enter New Farm Record
,(N'MessageResourceKeyConstants', N'FarmTheRecordWithTheSameFarmAddressAndSameFarmOwnerIsFoundInTheDatabaseDoYouWantToCreateThisFarmRecordMessage', N'InterfaceEditorResourceSetEnum.Farm + "3739"')

,(N'MessageResourceKeyConstants', N'FarmStreetRequiredWhenFarmOwnerAndFarmNameLeftBlank', N'InterfaceEditorResourceSetEnum.Farm + "4800"')
,(N'MessageResourceKeyConstants', N'FarmRegionRayonAndSettlementRequiredWhenFarmOwnerLeftBlank', N'InterfaceEditorResourceSetEnum.Farm + "4799"')

--        //VUC 19 - Delete Farm
,(N'MessageResourceKeyConstants', N'FarmUnableToDeleteDependentOnAnotherObjectMessage', N'InterfaceEditorResourceSetEnum.Farm + "271"')

--endregion Veterinary Module Resources


--TooltipResourceKeyConstants

insert into #Caption (captionClass, controlCaptionConstant, controlCaptionIdRaw) values
 (N'TooltipResourceKeyConstants', N'GridAdd', N'InterfaceEditorResourceSetEnum.CommonButtons + "543"')
,(N'TooltipResourceKeyConstants', N'GridCancel', N'InterfaceEditorResourceSetEnum.CommonButtons + "540"')
,(N'TooltipResourceKeyConstants', N'GridDelete', N'InterfaceEditorResourceSetEnum.CommonButtons + "538"')
,(N'TooltipResourceKeyConstants', N'GridDetails', N'InterfaceEditorResourceSetEnum.CommonButtons + "541"')
,(N'TooltipResourceKeyConstants', N'GridEdit', N'InterfaceEditorResourceSetEnum.CommonButtons + "539"')
,(N'TooltipResourceKeyConstants', N'GridSave', N'InterfaceEditorResourceSetEnum.CommonButtons + "542"')
,(N'TooltipResourceKeyConstants', N'GridPermissions', N'InterfaceEditorResourceSetEnum.CommonButtons + "544"')
,(N'TooltipResourceKeyConstants', N'Close', N'InterfaceEditorResourceSetEnum.CommonButtons + "548"')
,(N'TooltipResourceKeyConstants', N'SavegridconfigurationTooltip', N'InterfaceEditorResourceSetEnum.CommonButtons + "3669"')
,(N'TooltipResourceKeyConstants', N'CommonButtonsClickToAddARecordToolTip', N'InterfaceEditorResourceSetEnum.CommonButtons + "36"')		
,(N'TooltipResourceKeyConstants', N'CommonButtonsClickToCancelToolTip', N'InterfaceEditorResourceSetEnum.CommonButtons + "474"')		
,(N'TooltipResourceKeyConstants', N'CommonButtonsClickToDeleteToolTip', N'InterfaceEditorResourceSetEnum.CommonButtons + "37"')		
,(N'TooltipResourceKeyConstants', N'CommonButtonsClickToEditTheRecordToolTip', N'InterfaceEditorResourceSetEnum.CommonButtons + "4758"')		
,(N'TooltipResourceKeyConstants', N'CommonButtonsClickToUpdateToolTip', N'InterfaceEditorResourceSetEnum.CommonButtons + "4757"')		
,(N'TooltipResourceKeyConstants', N'CommonButtonsClickToSearchToolTip', N'InterfaceEditorResourceSetEnum.CommonButtons + "42"')		
,(N'TooltipResourceKeyConstants', N'CommonButtonsClickToSubmitToolTip', N'InterfaceEditorResourceSetEnum.CommonButtons + "43"')		
,(N'TooltipResourceKeyConstants', N'CommonButtonsClickToClearToolTip', N'InterfaceEditorResourceSetEnum.CommonButtons + "475"')		
,(N'TooltipResourceKeyConstants', N'CommonButtonsClickToSelectToolTip', N'InterfaceEditorResourceSetEnum.CommonButtons + "4766"')		
,(N'TooltipResourceKeyConstants', N'CommonButtonsClickToSelectAllRecordsToolTip', N'InterfaceEditorResourceSetEnum.CommonButtons + "4767"')		
,(N'TooltipResourceKeyConstants', N'CommonButtonsClickToUnselectAllToolTip', N'InterfaceEditorResourceSetEnum.CommonButtons + "4768"')		
,(N'TooltipResourceKeyConstants', N'CommonButtonsClickToAcceptToolTip', N'InterfaceEditorResourceSetEnum.CommonButtons + "4769"')		
,(N'TooltipResourceKeyConstants', N'CommonButtonsClickToClearTheFormToolTip', N'InterfaceEditorResourceSetEnum.CommonButtons + "4770"')		
,(N'TooltipResourceKeyConstants', N'CommonButtonsClickToConfirmNoToolTip', N'InterfaceEditorResourceSetEnum.CommonButtons + "4771"')		
,(N'TooltipResourceKeyConstants', N'CommonButtonsClickToConfirmYesToolTip', N'InterfaceEditorResourceSetEnum.CommonButtons + "4772"')		
,(N'TooltipResourceKeyConstants', N'CommonButtonsClickToCopyToolTip', N'InterfaceEditorResourceSetEnum.CommonButtons + "4773"')		
,(N'TooltipResourceKeyConstants', N'CommonButtonsClickToPasteToolTip', N'InterfaceEditorResourceSetEnum.CommonButtons + "4774"')		

,(N'TooltipResourceKeyConstants', N'SiteAlertMessengerModalClickToMarkTheAlertAsReadToolTip', N'InterfaceEditorResourceSetEnum.SiteAlertMessengerModal + "4787"')		
,(N'TooltipResourceKeyConstants', N'SiteAlertMessengerModalClickToDeleteAllAlertsToolTip', N'InterfaceEditorResourceSetEnum.SiteAlertMessengerModal + "4788"')		

--        //SYSUC04 - Change Password
,(N'TooltipResourceKeyConstants', N'ChangePasswordButtonToolTip', N'InterfaceEditorResourceSetEnum.ChangePassword + "462"')

--        //Flex Form Designer
,(N'TooltipResourceKeyConstants', N'FlexibleFormDesigner_AddSection_Tooltip', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "727"')
,(N'TooltipResourceKeyConstants', N'FlexibleFormDesigner_DeleteSection_Tooltip', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "728"')
,(N'TooltipResourceKeyConstants', N'FlexibleFormDesigner_AddParameter_Tooltip', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "729"')
,(N'TooltipResourceKeyConstants', N'FlexibleFormDesigner_DeleteParameter_Tooltip', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "730"')
,(N'TooltipResourceKeyConstants', N'FlexibleFormDesigner_CopyTreeviewNode_Tooltip', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "731"')
,(N'TooltipResourceKeyConstants', N'FlexibleFormDesigner_PasteTreeviewNode_Tooltip', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "732"')
,(N'TooltipResourceKeyConstants', N'FlexibleFormDesigner_ShowTemplates_Tooltip', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "733"')
,(N'TooltipResourceKeyConstants', N'FlexibleFormDesigner_ShowTemplateParameters_Tooltip', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "734"')
,(N'TooltipResourceKeyConstants', N'FlexibleFormDesigner_ShowTemplateRules_Tooltip', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "735"')
,(N'TooltipResourceKeyConstants', N'FlexibleFormDesigner_AddTemplate_Tooltip', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "736"')
,(N'TooltipResourceKeyConstants', N'FlexibleFormDesigner_DeleteTemplate_Tooltip', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "737"')
,(N'TooltipResourceKeyConstants', N'FlexibleFormDesigner_AddTemplateParameter_Tooltip', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "738"')
,(N'TooltipResourceKeyConstants', N'FlexibleFormDesigner_CopyTemplate_Tooltip', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "739"')
,(N'TooltipResourceKeyConstants', N'FlexibleFormDesigner_AddaDeterminant_Tooltip', N'InterfaceEditorResourceSetEnum.FlexibleFormDesigner + "740"')

--        //Laboratory Module
,(N'TooltipResourceKeyConstants', N'SamplesAccessionToolTip', N' InterfaceEditorResourceSetEnum.Samples + "823"')
,(N'TooltipResourceKeyConstants', N'SamplesAssignTestToolTip', N' InterfaceEditorResourceSetEnum.Samples + "824"')
,(N'TooltipResourceKeyConstants', N'SamplesCreateAliquotDerivativeToolTip', N' InterfaceEditorResourceSetEnum.Samples + "825"')
,(N'TooltipResourceKeyConstants', N'TestingBatchToolTip', N' InterfaceEditorResourceSetEnum.Testing + "826"')
,(N'TooltipResourceKeyConstants', N'AssignTestModalClickToAssignTheListedTestsToTheCorrespondingSamplesToolTip', N'InterfaceEditorResourceSetEnum.AssignTestModal + "824"')
,(N'TooltipResourceKeyConstants', N'LaboratoryClickToDisplayTheAliquotPopupToolTip', N'InterfaceEditorResourceSetEnum.Laboratory + "4759"')		
,(N'TooltipResourceKeyConstants', N'LaboratoryClickToDisplayTheTransferPopupToolTip', N'InterfaceEditorResourceSetEnum.Laboratory + "4760"')		
,(N'TooltipResourceKeyConstants', N'LaboratoryClickToDisplayTheAccessionInPopupToolTip', N'InterfaceEditorResourceSetEnum.Laboratory + "4761"')		
,(N'TooltipResourceKeyConstants', N'LaboratoryClickToDisplayTheAssignTestPopupToolTip', N'InterfaceEditorResourceSetEnum.Laboratory + "4762"')		
,(N'TooltipResourceKeyConstants', N'LaboratoryClickToDisplayTheBatchPopupToolTip', N'InterfaceEditorResourceSetEnum.Laboratory + "4763"')		
,(N'TooltipResourceKeyConstants', N'BatchesClickToCloseTheBatchToolTip', N'InterfaceEditorResourceSetEnum.Batches + "4764"')		
,(N'TooltipResourceKeyConstants', N'LaboratoryClickToShowRecordInMyFavoritesTabToolTip', N'InterfaceEditorResourceSetEnum.Laboratory + "4765"')		
,(N'TooltipResourceKeyConstants', N'ApprovalsClickToApproveTheSelectedRecordsToolTip', N'InterfaceEditorResourceSetEnum.Approvals + "4756"')		
,(N'TooltipResourceKeyConstants', N'ApprovalsClickToRejectTheSelectedRecordsToolTip', N'InterfaceEditorResourceSetEnum.Approvals + "4775"')		
,(N'TooltipResourceKeyConstants', N'BatchesClickToRemoveTheSelectedSamplesFromTheBatchToolTip', N'InterfaceEditorResourceSetEnum.Batches + "4776"')		
,(N'TooltipResourceKeyConstants', N'BatchesClickToAddATestResultToTheSelectedRecordsToolTip', N'InterfaceEditorResourceSetEnum.Batches + "4777"')		
,(N'TooltipResourceKeyConstants', N'TransferredClickToCancelTheSelectedTransfersToolTip', N'InterfaceEditorResourceSetEnum.Transferred + "4778"')		
,(N'TooltipResourceKeyConstants', N'TransferredClickToDisplayTheSelectedTransfersReportForPrintingToolTip', N'InterfaceEditorResourceSetEnum.Transferred + "4779"')		

--        //LUC03 - Transfer a Sample
,(N'TooltipResourceKeyConstants', N'TransferOutModalClickToSaveTransferRecordsToTheDatabaseToolTip', N' InterfaceEditorResourceSetEnum.TransferOutModal + "849"')

--        //LUC07 - Amend Test Result
,(N'TooltipResourceKeyConstants', N'AmendTestResultModalAmendToolTip', N' InterfaceEditorResourceSetEnum.AmendTestResultModal + "867"')

--        //LUC08 - Create a Batch
,(N'TooltipResourceKeyConstants', N'BatchModalBatchToolTip', N' InterfaceEditorResourceSetEnum.BatchModal + "899"')

--        //OMUC11
,(N'TooltipResourceKeyConstants', N'OutbreakContactsContactMonitoringQuestionsTooltip', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "2688"')
,(N'TooltipResourceKeyConstants', N'OutbreakContactsAddContactMonitoringFollowupTooltip', N'InterfaceEditorResourceSetEnum.OutbreakContacts + "2689"')


--        //Veterinary Module

--        //VASUC02 - Set Up Veterinary Active Surveillance Session and VASUC03 - Edit Veterinary Active Surveillance Session
,(N'TooltipResourceKeyConstants', N'VeterinarySessionDetailedInformationAddHerdToolTip', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2484"')
,(N'TooltipResourceKeyConstants', N'VeterinarySessionDetailedInformationAddFlockToolTip', N'InterfaceEditorResourceSetEnum.VeterinarySessionDetailedInformation + "2482"')
,(N'TooltipResourceKeyConstants', N'VeterinarySessionAggregateInformationAddHerdToolTip', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2484"')
,(N'TooltipResourceKeyConstants', N'VeterinarySessionAggregateInformationAddFlockToolTip', N'InterfaceEditorResourceSetEnum.VeterinarySessionAggregateInformation + "2482"')

--        //VUC04 - Enter Livestock Disease Report and VUC06 - Edit Livestock Disease Report
,(N'TooltipResourceKeyConstants', N'LivestockDiseaseReportFarmHerdSpeciesAddHerdToolTip', N' InterfaceEditorResourceSetEnum.LivestockDiseaseReportFarmHerdSpecies + "2484"')
,(N'TooltipResourceKeyConstants', N'LivestockDiseaseReportSamplesImportToolTip', N'InterfaceEditorResourceSetEnum.LivestockDiseaseReportSamples + "2499"')

--        //VUC05 - Enter Avian Disease Report and VUC07 - Edit Avian Disease Report
,(N'TooltipResourceKeyConstants', N'AvianDiseaseReportFarmFlockSpeciesAddFlockToolTip', N' InterfaceEditorResourceSetEnum.AvianDiseaseReportFarmFlockSpecies + "2482"')
,(N'TooltipResourceKeyConstants', N'AvianDiseaseReportSamplesImportToolTip', N' InterfaceEditorResourceSetEnum.AvianDiseaseReportSamples + "2499"')


update	c
set		c.controlCaptionId =
		case
			when CHARINDEX(N'"', c.controlCaptionIdRaw, 0) > 0
				and LEN(c.controlCaptionIdRaw) > CHARINDEX(N'"', c.controlCaptionIdRaw, 0)
				and CHARINDEX(N'"', c.controlCaptionIdRaw, CHARINDEX(N'"', c.controlCaptionIdRaw, 0) + 1) > 0
				then	case 
							when isnumeric(SUBSTRING(c.controlCaptionIdRaw, CHARINDEX(N'"', c.controlCaptionIdRaw, 0) + 1, CHARINDEX(N'"', c.controlCaptionIdRaw, CHARINDEX(N'"', c.controlCaptionIdRaw, 0) + 1) - CHARINDEX(N'"', c.controlCaptionIdRaw, 0) - 1)) = 1 
								then CAST(SUBSTRING(c.controlCaptionIdRaw, CHARINDEX(N'"', c.controlCaptionIdRaw, 0) + 1, CHARINDEX(N'"', c.controlCaptionIdRaw, CHARINDEX(N'"', c.controlCaptionIdRaw, 0) + 1) - CHARINDEX(N'"', c.controlCaptionIdRaw, 0) - 1) as bigint)
							else null
						end
			else null
		end
from	#Caption c
where	c.controlCaptionIdRaw like N'%"%"%' collate Cyrillic_General_CI_AS

update		c
set			c.controlCaptionEn = coalesce(rtr.strResourceString, r.strResourceName, N'')
from		#Caption c
join		trtResource r
on			r.idfsResource = c.controlCaptionId
left join	trtResourceTranslation rtr
on			rtr.idfsResource = r.idfsResource
			and rtr.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(N'en-US')



select	*
from	#Caption
order by captionClass, controlCaptionConstant

if OBJECT_ID(N'tempdb..#Caption') is not null
	exec sp_executesql N'drop table #Caption'
