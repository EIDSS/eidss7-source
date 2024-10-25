
set nocount on

declare @GenerateOption int = 2 /* 1 - Customization package + GeoLocationShared, 2 - Data Modules*/

-- Create temporary table with order and draft query of tables migration

if OBJECT_ID(N'tempdb..#TablesToMigrate') is not null
begin
	exec sp_executesql N'drop table #TablesToMigrate'
end


if OBJECT_ID(N'tempdb..#TablesToMigrate') is null
begin
	create table #TablesToMigrate
	(	idfId						int not null identity(1,1) primary key,
		table_id_v6					bigint null,
		table_id_v7					bigint null,
		table_name					sysname not null,
		sch_id_v6					bigint null,
		sch_id_v7					bigint null,
		sch_name					sysname not null,
		strInsertHeader				nvarchar(2000) collate Cyrillic_General_CI_AS null default(N''),
		strInsertColumns			nvarchar(max) collate Cyrillic_General_CI_AS null default(N''),
		strSelectColumns			nvarchar(max) collate Cyrillic_General_CI_AS null default(N''),
		strInsertFromHeader			nvarchar(2000) collate Cyrillic_General_CI_AS null default(N''),
		strInsertFromJoins			nvarchar(max) collate Cyrillic_General_CI_AS null default(N''),
		strInsertWhereHeader		nvarchar(2000) collate Cyrillic_General_CI_AS null default(N''),
		strInsertWhereConditions	nvarchar(max) collate Cyrillic_General_CI_AS null default(N''),
		strInsertPrint				nvarchar(2000) collate Cyrillic_General_CI_AS null default(N''),
		strUpdateHeader				nvarchar(2000) collate Cyrillic_General_CI_AS null default(N''),
		strUpdateColumns			nvarchar(max) collate Cyrillic_General_CI_AS null default(N''),
		strUpdateFromHeader			nvarchar(2000) collate Cyrillic_General_CI_AS null default(N''),
		strUpdateFromJoins			nvarchar(max) collate Cyrillic_General_CI_AS null default(N''),
		strUpdateWhereHeader		nvarchar(2000) collate Cyrillic_General_CI_AS null default(N''),
		strUpdateWhereConditions	nvarchar(max) collate Cyrillic_General_CI_AS null default(N''),
		strUpdatePrint				nvarchar(2000) collate Cyrillic_General_CI_AS null default(N''),
		strUpdateAfterInsert		nvarchar(max) collate Cyrillic_General_CI_AS null default(N''),
		strUpdateAfterInsert2		nvarchar(max) collate Cyrillic_General_CI_AS null default(N''),
		strStatementBeforeInsert	nvarchar(max) collate Cyrillic_General_CI_AS null default(N''),
		strStatementBeforeInsert2	nvarchar(max) collate Cyrillic_General_CI_AS null default(N''),
		strStatementBeforeInsert3	nvarchar(max) collate Cyrillic_General_CI_AS null default(N''),
		strStatementBeforeInsert4	nvarchar(max) collate Cyrillic_General_CI_AS null default(N''),
		strStatementBeforeInsert5	nvarchar(max) collate Cyrillic_General_CI_AS null default(N''),
		strStatementBeforeInsert6	nvarchar(max) collate Cyrillic_General_CI_AS null default(N''),
		strStatementBeforeUpdate	nvarchar(max) collate Cyrillic_General_CI_AS null default(N''),
		strStatementBeforeUpdate2	nvarchar(max) collate Cyrillic_General_CI_AS null default(N''),
		strStatementBeforeUpdate3	nvarchar(max) collate Cyrillic_General_CI_AS null default(N''),
		strStatementBeforeUpdate4	nvarchar(max) collate Cyrillic_General_CI_AS null default(N''),
		strStatementBeforeUpdate5	nvarchar(max) collate Cyrillic_General_CI_AS null default(N''),
		strStatementBeforeUpdate6	nvarchar(max) collate Cyrillic_General_CI_AS null default(N'')
	)
end

truncate table #TablesToMigrate





if OBJECT_ID(N'tempdb..#PKColumns') is not null
begin
	exec sp_executesql N'drop table #PKColumns'
end


if OBJECT_ID(N'tempdb..#PKColumns') is null
begin
	create table #PKColumns
	(	
		[sch_id_v7]			bigint not null,
		[sch_id_v6]			bigint not null,
		[sch_name]			sysname not null,
		[table_id_v7]		bigint not null,
		[table_id_v6]		bigint not null,
		[table_name]		sysname not null,
		[ind_id_v7]			bigint not null,
		[ind_id_v6]			bigint null,
		[ind_name_v7]		sysname not null,
		[ind_name_v6]		sysname null,
		[ind_col_id_v7]		bigint not null,
		[col_id_v7]			bigint not null,
		[col_name]			sysname not null,
		[col_type_id_v7]	bigint not null,
		[col_type_name_v7]	sysname not null,

		primary key
		(	[table_id_v7] asc,
			[ind_col_id_v7] asc
		)
	)
end

truncate table #PKColumns



if OBJECT_ID(N'tempdb..#FK') is not null
begin
	exec sp_executesql N'drop table #FK'
end


if OBJECT_ID(N'tempdb..#FK') is null
begin
	create table #FK
	(	
		[fk_id_v7]					bigint not null primary key,
		[fk_name_v7]				sysname not null,
		[fk_disabled_v7]			bit null default(0),

		[fk_id_v6]					bigint null,
		[fk_name_v6]				sysname null,

		[fk_nullable_v7]			bit null default(0),

		[parent_sch_id_v7]			bigint not null,
		[parent_sch_id_v6]			bigint null,
		[parent_sch_name]			sysname not null,
		[parent_table_id_v7]		bigint not null,
		[parent_table_id_v6]		bigint null,
		[parent_table_name]			sysname not null,
		[ref_sch_id_v7]				bigint not null,
		[ref_sch_id_v6]				bigint null,
		[ref_sch_name]				sysname not null,
		[ref_table_id_v7]			bigint not null,
		[ref_table_id_v6]			bigint null,
		[ref_table_name]			sysname not null,
		strJoinTable				nvarchar(2000) collate Cyrillic_General_CI_AS null default(N''),
		strJoinOnCondition			nvarchar(max) collate Cyrillic_General_CI_AS null default(N''),
		strFKTableAlias				nvarchar(2000) collate Cyrillic_General_CI_AS null default(N'')
	)
end

truncate table #FK



if OBJECT_ID(N'tempdb..#FKColumns') is not null
begin
	exec sp_executesql N'drop table #FKColumns'
end


if OBJECT_ID(N'tempdb..#FKColumns') is null
begin
	create table #FKColumns
	(	
		[fk_id_v7]					bigint not null,
		[fk_name_v7]				sysname not null,
		[fk_disabled_v7]			bit null default(0),

		[fk_id_v6]					bigint null,
		[fk_name_v6]				sysname null,

		[parent_sch_id_v7]			bigint not null,
		[parent_sch_id_v6]			bigint null,
		[parent_sch_name]			sysname not null,
		[parent_table_id_v7]		bigint not null,
		[parent_table_id_v6]		bigint null,
		[parent_table_name]			sysname not null,
		[ref_sch_id_v7]				bigint not null,
		[ref_sch_id_v6]				bigint null,
		[ref_sch_name]				sysname not null,
		[ref_table_id_v7]			bigint not null,
		[ref_table_id_v6]			bigint null,
		[ref_table_name]			sysname not null,
		
		[fk_col_id_v7]				int not null,
		[parent_col_id_v7]			int not null,
		[parent_col_name]			sysname not null,
		[parent_col_nullable_v7]	bit null default(0),
		[parent_col_type_id_v7]		bigint not null,
		[parent_col_type_name_v7]	sysname not null,
		[ref_col_id_v7]				int not null,
		[ref_col_name]				sysname not null,

		primary key
		(	[fk_id_v7] asc,
			[fk_col_id_v7] asc
		)
	)
end

truncate table #FKColumns



if OBJECT_ID(N'tempdb..#Columns') is not null
begin
	exec sp_executesql N'drop table #Columns'
end


if OBJECT_ID(N'tempdb..#Columns') is null
begin
	create table #Columns
	(	
		[sch_id_v7]				bigint not null,
		[sch_id_v6]				bigint not null,
		[sch_name]				sysname not null,
		[table_id_v7]			bigint not null,
		[table_id_v6]			bigint not null,
		[table_name]			sysname not null,
		
		[col_id_v7]				int not null,
		[col_name]				sysname not null,
		[col_type_id_v7]		bigint not null,
		[col_type_name_v7]		sysname not null,
		[collation_v7]			sysname null,
		[max_length_v7]			int null,
		[is_identity_v7]		bit null default(0),
		[is_rowguidcol_v7]		bit null default(0),
		[is_nullable_v7]		bit null default(0),
		[is_computed_v7]		bit null default(0),

		[col_id_v6]				int null,
		[col_type_id_v6]		bigint null,
		[col_type_name_v6]		sysname null,
		[collation_v6]			sysname null,
		[max_length_v6]			int null,
		[is_identity_v6]		bit null,
		[is_rowguidcol_v6]		bit null,
		[is_nullable_v6]		bit null,
		[is_computed_v6]		bit null,

		primary key
		(	[table_id_v7] asc,
			[col_id_v7] asc
		)
	)
end

truncate table #Columns



-- Fill in tables that should be migrated in the proper order
insert into	#TablesToMigrate (sch_name, table_name)
values
--Reference tables

--No need to transfer-- (N'dbo', N'trtReferenceType'),
 (N'dbo', N'trtBaseReference')
,(N'dbo', N'trtBssAggregateColumns')
,(N'dbo', N'trtCaseClassification')
,(N'dbo', N'trtDiagnosis')
--No need to transfer--,(N'dbo', N'trtEventType')
--No need to transfer--,(N'dbo', N'trtHACodeList')
,(N'dbo', N'trtMatrixType')
,(N'dbo', N'trtMatrixColumn')
,(N'dbo', N'trtProphilacticAction')
,(N'dbo', N'trtSanitaryAction')
,(N'dbo', N'trtDiagnosisAgeGroup')
,(N'dbo', N'trtReportDiagnosisGroup')
,(N'dbo', N'trtSampleType')
,(N'dbo', N'trtSpeciesType')
,(N'dbo', N'trtSpeciesGroup')
,(N'dbo', N'trtStatisticDataType')
--No need to transfer--,(N'dbo', N'trtSystemFunction')
,(N'dbo', N'trtVectorType')
,(N'dbo', N'trtVectorSubType')
--No need to transfer--,(N'dbo', N'tstNextNumbers')
,(N'dbo', N'trtStringNameTranslation')

--GIS Reference tables

,(N'dbo', N'gisReferenceType')
,(N'dbo', N'gisBaseReference')
,(N'dbo', N'gisOtherBaseReference')
,(N'dbo', N'gisCountry')
,(N'dbo', N'gisRegion')
,(N'dbo', N'gisRayon')
,(N'dbo', N'gisSettlement')
,(N'dbo', N'gisDistrictSubdistrict')
,(N'dbo', N'gisMainCityForRayon')
,(N'dbo', N'gisMetadata')
,(N'dbo', N'gisLegendSymbol')
,(N'dbo', N'gisWKBCountry')
,(N'dbo', N'gisWKBRegion')
,(N'dbo', N'gisWKBRayon')
,(N'dbo', N'gisWKBDistrict')
,(N'dbo', N'gisWKBSettlement')
,(N'dbo', N'gisWKBEarthRoad')
,(N'dbo', N'gisWKBForest')
,(N'dbo', N'gisWKBHighway')
,(N'dbo', N'gisWKBInlandWater')
,(N'dbo', N'gisWKBLake')
,(N'dbo', N'gisWKBLanduse')
,(N'dbo', N'gisWKBMainRiver')
,(N'dbo', N'gisWKBMajorRoad')
,(N'dbo', N'gisWKBPath')
,(N'dbo', N'gisWKBRailroad')
,(N'dbo', N'gisWKBRiver')
,(N'dbo', N'gisWKBRiverPolygon')
,(N'dbo', N'gisWKBRuralDistrict')
,(N'dbo', N'gisWKBSea')
,(N'dbo', N'gisWKBSmallRiver')
,(N'dbo', N'gisWKBRegionReady')
,(N'dbo', N'gisWKBRayonReady')
,(N'dbo', N'gisWKBDistrictReady')
,(N'dbo', N'gisWKBSettlementReady')
,(N'dbo', N'gisOtherStringNameTranslation')
,(N'dbo', N'gisStringNameTranslation')

--Flexible Form tables

,(N'dbo', N'ffParameterType')
,(N'dbo', N'ffFormTemplate')
,(N'dbo', N'ffParameterFixedPresetValue')
,(N'dbo', N'ffSection')
,(N'dbo', N'ffParameter')
,(N'dbo', N'ffDecorElement')
,(N'dbo', N'ffDecorElementLine')
,(N'dbo', N'ffDecorElementText')
,(N'dbo', N'ffParameterForTemplate')
,(N'dbo', N'ffParameterDesignOption')
,(N'dbo', N'ffRuleFunction')
,(N'dbo', N'ffRule')
,(N'dbo', N'ffRuleConstant')
,(N'dbo', N'ffParameterForFunction')
,(N'dbo', N'ffParameterForAction')
,(N'dbo', N'ffSectionForTemplate')
,(N'dbo', N'ffSectionDesignOption')
,(N'dbo', N'ffSectionForAction')
,(N'dbo', N'ffDeterminantType')
,(N'dbo', N'ffDeterminantValue')

--Reference Matrices tables

,(N'dbo', N'trtCollectionMethodForVectorType')
,(N'dbo', N'trtDerivativeForSampleType')
,(N'dbo', N'trtDiagnosisAgeGroupToStatisticalAgeGroup')
,(N'dbo', N'trtDiagnosisAgeGroupToDiagnosis')
,(N'dbo', N'trtDiagnosisToDiagnosisGroup')
,(N'dbo', N'trtDiagnosisToGroupForReportType')
,(N'dbo', N'trtFFObjectForCustomReport')
,(N'dbo', N'trtFFObjectToDiagnosisForCustomReport')
,(N'dbo', N'trtMaterialForDisease')
,(N'dbo', N'trtObjectTypeToObjectOperation')
,(N'dbo', N'trtObjectTypeToObjectType')
,(N'dbo', N'trtPensideTestForDisease')
,(N'dbo', N'trtPensideTestTypeForVectorType')
,(N'dbo', N'trtPensideTestTypeToTestResult')
,(N'dbo', N'trtReportRows')
,(N'dbo', N'trtSampleTypeForVectorType')
,(N'dbo', N'trtSpeciesContentInCustomReport')
,(N'dbo', N'trtSpeciesToGroupForCustomReport')
,(N'dbo', N'trtSpeciesTypeToAnimalAge')
,(N'dbo', N'trtTestForDisease')
,(N'dbo', N'trtTestTypeForCustomReport')
,(N'dbo', N'trtTestTypeToTestResult')
,(N'dbo', N'trtGISObjectForCustomReport')

--Customization Package Information tables

,(N'dbo', N'tstCustomizationPackage')
,(N'dbo', N'tstCustomizationPackageSettings')
,(N'dbo', N'tstGeoLocationFormat')

--GIS/Reference Attributes tables

,(N'dbo', N'trtAttributeType')
,(N'dbo', N'trtGISBaseReferenceAttribute')
,(N'dbo', N'trtBaseReferenceAttribute')

--Tables with links from reference and matrices tables to Customization Package

,(N'dbo', N'trtBaseReferenceToCP')
,(N'dbo', N'trtLanguageToCP')
,(N'dbo', N'trtStringNameTranslationToCP')
,(N'dbo', N'trtBaseReferenceAttributeToCP')
,(N'dbo', N'trtCollectionMethodForVectorTypeToCP')
,(N'dbo', N'trtDerivativeForSampleTypeToCP')
,(N'dbo', N'trtDiagnosisAgeGroupToDiagnosisToCP')
,(N'dbo', N'trtDiagnosisAgeGroupToStatisticalAgeGroupToCP')
,(N'dbo', N'trtDiagnosisToDiagnosisGroupToCP')
,(N'dbo', N'trtMaterialForDiseaseToCP')
,(N'dbo', N'trtPensideTestForDiseaseToCP')
,(N'dbo', N'trtPensideTestTypeForVectorTypeToCP')
,(N'dbo', N'trtPensideTestTypeToTestResultToCP')
,(N'dbo', N'trtSampleTypeForVectorTypeToCP')
,(N'dbo', N'trtSpeciesTypeToAnimalAgeToCP')
,(N'dbo', N'trtTestForDiseaseToCP')
,(N'dbo', N'trtTestTypeToTestResultToCP')

--Tables with rows of the aggregate matrices
,(N'dbo', N'tlbAggrMatrixVersionHeader')
,(N'dbo', N'tlbAggrHumanCaseMTX')
,(N'dbo', N'tlbAggrVetCaseMTX')
,(N'dbo', N'tlbAggrDiagnosticActionMTX')
,(N'dbo', N'tlbAggrProphylacticActionMTX')
,(N'dbo', N'tlbAggrSanitaryActionMTX')


--Tables with data of administrative module
,(N'dbo', N'tstSite')--TODO: remove [idfOffice], [idfsParentSite] from the insert and add a separate update statement when tlbOffice is transferred
,(N'dbo', N'tstSecurityConfigurationAlphabet')
,(N'dbo', N'tstSecurityConfiguration')--TODO: remove [idfParentSecurityConfiguration] from the insert and add a separate update statement after insert statement; TODO: update table SecurityPolicyConfiguration if possible
,(N'dbo', N'tstSecurityConfigurationAlphabetParticipation')
,(N'dbo', N'tlbGeoLocationShared')--TODO: migrate records that match office addresses only, process idfsLocation = coalesce([idfsSettlement], [idfsRayon], [idfsRegion], [idfsCountry])
,(N'dbo', N'tlbOffice')--TODO: add customization for the list
,(N'dbo', N'tlbDepartment')
,(N'dbo', N'tlbStatistic')

,(N'dbo', N'tlbEmployee')--TODO: mark system admins as deleted, exclude user groups, add concordance table for custom user groups with negative identifiers; process idfsEmployeeCategory with User value for all accounts; insert/update Employee Group Names (trtBaseReference, trtStringNameTranslation) based on concordance table
,(N'dbo', N'tlbEmployeeGroup')--TODO: process table with concordance table of employee groups
,(N'dbo', N'tlbPerson')--TODO: mark system admins as deleted; set Unknown in the new field Personal ID Type and null in the PersonalIDValue

,(N'dbo', N'tlbEmployeeGroupMember')--TODO: process table with concordance table of employee groups

,(N'dbo', N'tstUserTable')--TODO: mark system admins as deleted; replace password hash with predefined temporary password
--No need to transfer--,(N'dbo', N'tstUserTableLocal')
--No need to transfer--,(N'dbo', N'tstUserTableOldPassword')
--No need to transfer--,(N'dbo', N'tstUserTicket')
,(N'dbo', N'tstObjectAccess')--TODO: process table with concordance table of employee groups; exclude permissions to anything except sites and diagnoses; match permissions of system functions with LkupRoleMenuAccess and LkupRoleSystemFunctionAccess using LkupSystemFunctionToOperation
--TODO: insert records in AspNetUsers, EmployeeToInstitution

,(N'dbo', N'tstRayonToReportSite')
,(N'dbo', N'tstAggrSetting')
,(N'dbo', N'tstGlobalSiteOptions')

--Tables with configuration of data filtration
,(N'dbo', N'tflSite')
,(N'dbo', N'tflSiteGroup')
,(N'dbo', N'tflSiteGroupRelation')
,(N'dbo', N'tflSiteToSiteGroup')


--Tables with addresses,persons and farms catalogs, herd/species/animal structure of farms
,(N'dbo', N'tlbGeoLocationShared')--TODO: process idfsLocation = coalesce([idfsSettlement], [idfsRayon], [idfsRegion], [idfsCountry])
,(N'dbo', N'tlbStreet')--TODO: idfsLocation = idfsSettlement
,(N'dbo', N'tlbPostalCode')--TODO: idfsLocation = idfsSettlement
,(N'dbo', N'tlbHumanActual')--TODO: generate records for two new addresses of HumanActualAddlInfo, generate records for HumanActualAddlInfo with links to the new addresses
,(N'dbo', N'tlbFarmActual')--TODO: create _dmccFarmActual for fixing duplicated strFarmCode
,(N'dbo', N'tlbHerdActual')
,(N'dbo', N'tlbSpeciesActual')

--Tables with records of data modules

,(N'dbo', N'tlbObservation')--TODO: use _dmccObservation, insert values _dmccNewObservation
,(N'dbo', N'tlbActivityParameters')--TODO: use _dmccActivityParameters
,(N'dbo', N'tlbGeoLocation')--TODO: use _dmccGeoLocation, insert values _dmccNewGeoLocation (including generated records for two new addresses of HumanAddInfo); process idfsLocation = coalesce([idfsSettlement], [idfsRayon], [idfsRegion], [idfsCountry])
--TODO: how to process tlbGeoLocationTranslation ?
,(N'dbo', N'tlbHuman')--TODO: use _dmccHuman 
,(N'dbo', N'tlbFarm')--TODO: use _dmccHuman, Update idfMonitoringSession later, replace strFarmCode with strFarmCode of tlbFarmActual
,(N'dbo', N'tlbHerd')
,(N'dbo', N'tlbSpecies')
,(N'dbo', N'tlbAnimal')

,(N'dbo', N'tlbCampaign')--TODO: check the rule for new columns CampaignCategoryID = 10501002/*Veterinary Active Surveillance Campaign*/, LegacyCampaignID=strCampaignID
,(N'dbo', N'tlbCampaignToDiagnosis')

,(N'dbo', N'tlbFreezer')
,(N'dbo', N'tlbFreezerSubdivision')--TODO:Update idfParentSubdivision later, check the rules for new  fields

,(N'dbo', N'tlbOutbreak')--TODO: update [idfPrimaryCaseOrSession] later, calculate [idfsLocation] based on Outbreak GeoLocation, calculate [OutbreakTypeID], rules for idfsOutbreakStatus:case when idfsOutbreakStatus_v6 = 53418740000000 /*Not an Outbreak*/ then 10063503 /*Not an Outbreak*/ when idfsOutbreakStatus_v6 is null or <> 53418740000000 /*Not an Outbreak*/ and datFinishDate_v6 is null then 10063501 /*In Progress*/ else 10063502 /*Closed*/ end
,(N'dbo', N'tlbOutbreakNote')
,(N'dbo', N'tflOutbreakFiltered')


,(N'dbo', N'tlbAggrCase')--TODO: check rule for new column [idfOffice]
,(N'dbo', N'tflAggregateCaseFiltered')

,(N'dbo', N'tlbVectorSurveillanceSession')
,(N'dbo', N'tlbVector')--TODO: update [idfHostVector] later
,(N'dbo', N'tlbVectorSurveillanceSessionSummary')
,(N'dbo', N'tlbVectorSurveillanceSessionSummaryDiagnosis')
,(N'dbo', N'tflVectorSurveillanceSessionFiltered')

,(N'dbo', N'tlbMonitoringSession')-- Calculate [idfsLocation], [idfsMonitoringSessionSpeciesType], [LegacySessionID]?
,(N'dbo', N'tlbMonitoringSessionToDiagnosis')
--TODO: how to process new table [dbo].[tlbMonitoringSessionToMaterial]?
,(N'dbo', N'tlbMonitoringSessionAction')
,(N'dbo', N'tlbMonitoringSessionSummary')
,(N'dbo', N'tlbMonitoringSessionSummaryDiagnosis')
,(N'dbo', N'tlbMonitoringSessionSummarySample')
,(N'dbo', N'tflMonitoringSessionFiltered')
--TODO: Update idfMonitoringSession in tlbFarm here

,(N'dbo', N'tlbHumanCase')--TODO: use _dmccHumanCase, datFinalDiagnosisDate = isnull(_dmccHumanCase.datDiagnosisDate, datFinalDiagnosisDate v6)
,(N'dbo', N'tlbAntimicrobialTherapy')--TODO: use _dmccAntimicrobialTherapy
,(N'dbo', N'tlbChangeDiagnosisHistory')
,(N'dbo', N'tlbContactedCasePerson')--TODO: use _dmccContactedCasePerson
,(N'dbo', N'tflHumanCaseFilitered')--TODO: use _dmccHumanCaseFilitered

,(N'dbo', N'tlbVetCase')--TODO:calculate LegacyCaseID, strSummaryNotes = info from all Diagnoses of v6.1 (use resource names/translations: 410 - Initial Diagnosis, 400 - Final Diagnosis), idfsFinalDiagnosis v7 = idfsShowDiagnosis v6 
,(N'dbo', N'tlbVaccination')
,(N'dbo', N'tlbVetCaseLog')
--TODO: Decide if we transfer?,(N'dbo', N'tlbVetCaseDisplayDiagnosis')
,(N'dbo', N'tflVetCaseFiltered')

--TODO: update [idfPrimaryCaseOrSession] for Outbreak

,(N'dbo', N'tlbMaterial') --TODO: use _dmccMaterial, Update idfRootMaterial and idfParentMaterial, and idfMainTest later
,(N'dbo', N'tlbTransferOUT')
,(N'dbo', N'tflTransferOutFiltered')
,(N'dbo', N'tlbTransferOutMaterial')--TODO: do not use _dmccMaterial
,(N'dbo', N'tlbPensideTest')--TODO: do not use _dmccMaterial

,(N'dbo', N'tlbBatchTest')
,(N'dbo', N'tflBatchTestFiltered')

,(N'dbo', N'tlbTesting')--TODO: use _dmccLabTest, update idfMainTest in tlbMaterial
,(N'dbo', N'tlbTestAmendmentHistory')
,(N'dbo', N'tlbTestValidation')--TODO: use _dmccTestValidation


,(N'dbo', N'tlbBasicSyndromicSurveillanceAggregateHeader')
,(N'dbo', N'tlbBasicSyndromicSurveillanceAggregateDetail')
,(N'dbo', N'tflBasicSyndromicSurveillanceAggregateHeaderFiltered')

,(N'dbo', N'tlbBasicSyndromicSurveillance')--TODO: do not use _dmccHuman
,(N'dbo', N'tflBasicSyndromicSurveillanceFiltered')




-- Retrieve information about the tables from the current EIDSSv7 and EIDSSv6.1
update		ttm
set			ttm.sch_id_v6 = s_v6.[schema_id],
			ttm.sch_id_v7 = s_v7.[schema_id],
			ttm.table_id_v6 = t_v6.[object_id],
			ttm.table_id_v7 = t_v7.[object_id],
			ttm.strInsertHeader = N'insert into [Giraffe].[' + ttm.[sch_name] + N'].[' + ttm.[table_name] + N'] ' collate Cyrillic_General_CI_AS,
			ttm.strSelectColumns = N'select ',
			ttm.strInsertFromHeader = N'from [Falcon].[' + ttm.[sch_name] + N'].[' + ttm.[table_name] + N'] ' + ttm.[table_name] +'_v6 ' collate Cyrillic_General_CI_AS,
			ttm.strInsertWhereHeader = N'where ',
			ttm.strInsertPrint = N'print N''Table [' + t_v7.[name] + N'] - insert: '' + cast(@@rowcount as nvarchar(20))',
			ttm.strUpdateHeader = N'update ' + ttm.[table_name] +'_v7 
set ' collate Cyrillic_General_CI_AS,
			ttm.strUpdateFromHeader = N'from [Giraffe].[' + ttm.[sch_name] + N'].[' + ttm.[table_name] + N'] ' + ttm.[table_name] +'_v7 
inner join	[Falcon].[' + ttm.[sch_name] + N'].[' + ttm.[table_name] + N'] ' + ttm.[table_name] +'_v6 
on	' collate Cyrillic_General_CI_AS,
			ttm.strUpdateWhereHeader = N'',
			ttm.strUpdatePrint = N'print N''Table [' + t_v7.[name] + N'] - update: '' + cast(@@rowcount as nvarchar(20))'
from		#TablesToMigrate ttm
join		[EIDSS7_GG_AzurePackage].sys.schemas s_v7
on			s_v7.[name] = ttm.[sch_name] collate Cyrillic_General_CI_AS
join		[EIDSS7_GG_AzurePackage].sys.tables t_v7
on			t_v7.[name] = ttm.table_name collate Cyrillic_General_CI_AS
			and t_v7.[schema_id] = s_v7.[schema_id]
join		[Falcon_GG].sys.schemas s_v6
on			s_v6.[name] = s_v7.[name] collate Cyrillic_General_CI_AS
join		[Falcon_GG].sys.tables t_v6
on			t_v6.[name] = t_v7.[name] collate Cyrillic_General_CI_AS
			and t_v6.[type] = N'U' collate Cyrillic_General_CI_AS
			and t_v6.[schema_id] = s_v6.[schema_id]
--join		[EIDSS7_GG_AzurePackage].sys.all_columns c
--on			c.[object_id]
where		t_v7.[type] = N'U' collate Cyrillic_General_CI_AS
--order by	s_v7.[name], t_v7.[name]

--select *
--from #TablesToMigrate ttm

insert into	#FKColumns
(	[fk_id_v7],
	[fk_name_v7],
	[fk_disabled_v7],

	[fk_id_v6],
	[fk_name_v6],

	[parent_sch_id_v7],
	[parent_sch_id_v6],
	[parent_sch_name],
	[parent_table_id_v7],
	[parent_table_id_v6],
	[parent_table_name],
	[ref_sch_id_v7],
	[ref_sch_id_v6],
	[ref_sch_name],
	[ref_table_id_v7],
	[ref_table_id_v6],
	[ref_table_name],
		
	[fk_col_id_v7],
	[parent_col_id_v7],
	[parent_col_name],
	[parent_col_nullable_v7],
	[parent_col_type_id_v7],
	[parent_col_type_name_v7],
	[ref_col_id_v7],
	[ref_col_name]
)
select	distinct
		fk_v7.[object_id] as [fk_id_v7],
		fk_v7.[name] as [fk_name_v7],
		fk_v7.[is_disabled] as [fk_disabled_v7],

		fk_v6.[object_id] as [fk_id_v6],
		fk_v6.[name] as [fk_name_v6],

		ttm.[sch_id_v7] as [parent_sch_id_v7],
		ttm.[sch_id_v6] as [parent_sch_id_v6],
		ttm.[sch_name] as [parent_sch_name],
		ttm.[table_id_v7] as [parent_table_id_v7],
		ttm.[table_id_v6] as [parent_table_id_v6],
		ttm.[table_name] as [parent_table_name],
		sch_ref_v7.[schema_id] as [ref_sch_id_v7],
		sch_ref_v6.[schema_id] as [ref_sch_id_v6],
		sch_ref_v7.[name] as [ref_sch_name],
		t_ref_v7.[object_id] as [ref_table_id_v7],
		t_ref_v6.[object_id] as [ref_table_id_v6],
		t_ref_v7.[name] as [ref_table_name],
		
		fkc_v7.[constraint_column_id] as [fk_col_id_v7],
		fkc_c_parent_v7.[column_id] as [parent_col_id_v7],
		fkc_c_parent_v7.[name] as [parent_col_name],
		fkc_c_parent_v7.[is_nullable] as [parent_col_nullable_v7],
		fkc_c_parent_v7.[user_type_id] as [parent_col_type_id_v7],
		fkc_c_parent_typ_v7.[name] as [parent_col_type_name_v7],
		fkc_c_ref_v7.[column_id] as [ref_col_id_v7],
		fkc_c_ref_v7.[name] as [ref_col_name]

from	[EIDSS7_GG_AzurePackage].sys.foreign_keys fk_v7

join	#TablesToMigrate ttm
on	ttm.[table_id_v7] = fk_v7.[parent_object_id]
join	[EIDSS7_GG_AzurePackage].sys.tables t_ref_v7
on	t_ref_v7.[object_id] = fk_v7.[referenced_object_id]
join	[EIDSS7_GG_AzurePackage].sys.schemas sch_ref_v7
on	sch_ref_v7.[schema_id] = t_ref_v7.[schema_id]

left join	[Falcon_GG].sys.tables t_ref_v6
	join	[Falcon_GG].sys.schemas sch_ref_v6
	on	sch_ref_v6.[schema_id] = t_ref_v6.[schema_id]
on	t_ref_v6.[name] = t_ref_v7.[name] collate Cyrillic_General_CI_AS
	and sch_ref_v6.[name] = sch_ref_v7.[name] collate Cyrillic_General_CI_AS

left join	[Falcon_GG].sys.foreign_keys fk_v6
on	fk_v6.[parent_object_id] = ttm.[table_id_v6]
	and fk_v6.[referenced_object_id] = t_ref_v6.[object_id]
	and not exists
		(	select	1
			from	(
				[Falcon_GG].sys.foreign_key_columns fkc_v6_ex
				join	[Falcon_GG].sys.columns fkc_c_parent_v6_ex
				on	fkc_c_parent_v6_ex.[object_id] = fkc_v6_ex.[parent_object_id]
					and fkc_c_parent_v6_ex.[column_id] = fkc_v6_ex.[parent_column_id]
					and fkc_v6_ex.[constraint_object_id] = fk_v6.[object_id]
				join	[Falcon_GG].sys.columns fkc_c_ref_v6_ex
				on	fkc_c_ref_v6_ex.[object_id] = fkc_v6_ex.[referenced_object_id]
					and fkc_c_ref_v6_ex.[column_id] = fkc_v6_ex.[referenced_column_id]
					)
			full join	[EIDSS7_GG_AzurePackage].sys.foreign_key_columns fkc_v7_ex
				join	[EIDSS7_GG_AzurePackage].sys.columns fkc_c_parent_v7_ex
				on	fkc_c_parent_v7_ex.[object_id] = fkc_v7_ex.[parent_object_id]
					and fkc_c_parent_v7_ex.[column_id] = fkc_v7_ex.[parent_column_id]
					and fkc_v7_ex.[constraint_object_id] = fk_v7.[object_id]
				join	[EIDSS7_GG_AzurePackage].sys.columns fkc_c_ref_v7_ex
				on	fkc_c_ref_v7_ex.[object_id] = fkc_v7_ex.[referenced_object_id]
					and fkc_c_ref_v7_ex.[column_id] = fkc_v7_ex.[referenced_column_id]
			on	fkc_c_parent_v7_ex.[name] = fkc_c_parent_v6_ex.[name] collate Cyrillic_General_CI_AS
				and fkc_c_ref_v7_ex.[name] = fkc_c_ref_v6_ex.[name] collate Cyrillic_General_CI_AS
			where	fkc_v6_ex.[constraint_object_id] is null or fkc_v7_ex.[constraint_object_id] is null
					
		)

left join	[EIDSS7_GG_AzurePackage].sys.foreign_key_columns fkc_v7
	join	[EIDSS7_GG_AzurePackage].sys.columns fkc_c_parent_v7
	on	fkc_c_parent_v7.[object_id] = fkc_v7.[parent_object_id]
		and fkc_c_parent_v7.[column_id] = fkc_v7.[parent_column_id]
	left join	[EIDSS7_GG_AzurePackage].sys.types fkc_c_parent_typ_v7
	on	fkc_c_parent_typ_v7.[user_type_id] = fkc_c_parent_v7.[user_type_id]
	join	[EIDSS7_GG_AzurePackage].sys.columns fkc_c_ref_v7
	on	fkc_c_ref_v7.[object_id] = fkc_v7.[referenced_object_id]
		and fkc_c_ref_v7.[column_id] = fkc_v7.[referenced_column_id]
on	fkc_v7.[constraint_object_id] = fk_v7.[object_id]

where	
		-- exclude new column SourceSystemNameID
		not exists
		(	select	1
			from	[EIDSS7_GG_AzurePackage].sys.foreign_key_columns fkc_SourceSystemNameID_v7
			join	[EIDSS7_GG_AzurePackage].sys.columns fkc_SourceSystemNameID_c_parent_v7
			on	fkc_SourceSystemNameID_c_parent_v7.[object_id] = fkc_SourceSystemNameID_v7.[parent_object_id]
					and fkc_SourceSystemNameID_c_parent_v7.[column_id] = fkc_SourceSystemNameID_v7.[parent_column_id]
			where	fkc_SourceSystemNameID_v7.[constraint_object_id] = fk_v7.[object_id]
					and fkc_SourceSystemNameID_c_parent_v7.[name] = N'SourceSystemNameID' collate Cyrillic_General_CI_AS
		)
		--exclude FKs for the new columns in v7
		and not exists
		(	select	1
			from		[EIDSS7_GG_AzurePackage].sys.foreign_key_columns fkc_newcol_v7
			join		[EIDSS7_GG_AzurePackage].sys.columns fkc_newcol_c_parent_v7
			on	fkc_newcol_c_parent_v7.[object_id] = fkc_newcol_v7.[parent_object_id]
				and fkc_newcol_c_parent_v7.[column_id] = fkc_newcol_v7.[parent_column_id]
			left join	[FALCON_GG].sys.columns c_parent_v6
			on			c_parent_v6.[object_id] = ttm.[table_id_v6]
						and c_parent_v6.[name] = fkc_newcol_c_parent_v7.[name] collate Cyrillic_General_CI_AS
			where	fkc_newcol_v7.[constraint_object_id] = fk_v7.[object_id]
					and c_parent_v6.[column_id] is null
		)



insert into	#FK
(	[fk_id_v7],
	[fk_name_v7],
	[fk_disabled_v7],
	[fk_nullable_v7],

	[fk_id_v6],
	[fk_name_v6],

	[parent_sch_id_v7],
	[parent_sch_id_v6],
	[parent_sch_name],
	[parent_table_id_v7],
	[parent_table_id_v6],
	[parent_table_name],
	[ref_sch_id_v7],
	[ref_sch_id_v6],
	[ref_sch_name],
	[ref_table_id_v7],
	[ref_table_id_v6],
	[ref_table_name]
)
select	distinct
	fkc.[fk_id_v7],
	fkc.[fk_name_v7],
	fkc.[fk_disabled_v7],
	cast(fkc_col_info.[is_nullable] as bit),

	fkc.[fk_id_v6],
	fkc.[fk_name_v6],

	fkc.[parent_sch_id_v7],
	fkc.[parent_sch_id_v6],
	fkc.[parent_sch_name],
	fkc.[parent_table_id_v7],
	fkc.[parent_table_id_v6],
	fkc.[parent_table_name],
	fkc.[ref_sch_id_v7],
	fkc.[ref_sch_id_v6],
	fkc.[ref_sch_name],
	fkc.[ref_table_id_v7],
	fkc.[ref_table_id_v6],
	fkc.[ref_table_name]
from	#FKColumns fkc
outer apply
(	select	max(isnull(cast(fkc_null_max.[parent_col_nullable_v7] as int), 0)) as [is_nullable]
	from	#FKColumns fkc_null_max
	where	fkc_null_max.[fk_id_v7] = fkc.[fk_id_v7]
) fkc_col_info

update	fk
set		fk.strJoinTable = case when fk.[fk_nullable_v7] = 1 then N'left' else 'inner' end + 
		N' join	[Giraffe].[' + fk.[ref_sch_name] + N'].[' + fk.[ref_table_name] + N'] j_' + fk.[ref_table_name] + colListFK.strParentColumns + N'_v7
		on	' collate Cyrillic_General_CI_AS,
		fk.strJoinOnCondition = onJoinCond.strJoinOnCondition collate Cyrillic_General_CI_AS,
		fk.strFKTableAlias = N'j_' + fk.[ref_table_name] + colListFK.strParentColumns + N'_v7' collate Cyrillic_General_CI_AS
from	#FK fk
cross apply
(	select
		replace	(isnull	(
			(
				select	N'_' + fkc.[parent_col_name] collate Cyrillic_General_CI_AS
				from	#FKColumns fkc
				where	fkc.[fk_id_v7] = fk.[fk_id_v7]
				order by	fkc.[fk_col_id_v7]
				for xml path ('')
			), N''), N'&#x0D;', N'
') as strParentColumns
) colListFK
cross apply
(	select
		replace	(isnull	(
			(
				select	N'
					' + 
					case
						when fkc.[fk_col_id_v7] > 1
							then N'and ' 
						else N''
					end +
					N'j_' + fk.[ref_table_name] + colListFK.strParentColumns + N'_v7' + N'.[' + 
					fkc.[ref_col_name] + N'] = ' + 
					fkc.[parent_table_name] + N'_v6.[' + 
					fkc.[parent_col_name] + N'] ' +
					case
						when fkc.[parent_col_type_name_v7] like N'%char%' collate Cyrillic_General_CI_AS 
							then N' collate Cyrillic_General_CI_AS' 
						else N'' 
					end collate Cyrillic_General_CI_AS
				from	#FKColumns fkc
				where	fkc.[fk_id_v7] = fk.[fk_id_v7]
				order by	fkc.[fk_col_id_v7]
				for xml path ('')
			), N''), N'&#x0D;', N'
') as strJoinOnCondition
) onJoinCond




insert into #PKColumns
(	[sch_id_v7],
	[sch_id_v6],
	[sch_name],
	[table_id_v7],
	[table_id_v6],
	[table_name],
	[ind_id_v7],
	[ind_id_v6],
	[ind_name_v7],
	[ind_name_v6],
	[ind_col_id_v7],
	[col_id_v7],
	[col_name],
	[col_type_id_v7],
	[col_type_name_v7]
)
select	distinct
		ttm.[sch_id_v7],
		ttm.[sch_id_v6],
		ttm.[sch_name],
		ttm.[table_id_v7],
		ttm.[table_id_v6],
		ttm.[table_name],
		ind_v7.[index_id] as [ind_id_v7],
		ind_v6.[index_id] as [ind_id_v6],
		ind_v7.[name] as [ind_name_v7],
		ind_v6.[name] as [ind_name_v6],
		ind_col_v7.[index_column_id] as [ind_col_id_v7],
		ind_col_c_v7.[column_id] as [col_id_v7],
		ind_col_c_v7.[name] as [col_name],
		ind_col_c_typ_v7.[user_type_id] as [col_type_id_v7],
		ind_col_c_typ_v7.[name] as [col_type_name_v7]
from	#TablesToMigrate ttm
join	[EIDSS7_GG_AzurePackage].sys.indexes ind_v7
on	ind_v7.[object_id] = ttm.[table_id_v7]
	and ind_v7.is_primary_key = 1

left join	[Falcon_GG].sys.indexes ind_v6
on	ind_v6.[object_id] = ttm.[table_id_v6]
	and ind_v6.is_primary_key = 1
	and not exists
		(	select	1
			from	(
				[Falcon_GG].sys.index_columns ind_col_v6_ex
				join	[Falcon_GG].sys.columns ind_col_c_v6_ex
				on	ind_col_c_v6_ex.[object_id] = ind_col_v6_ex.[object_id]
					and ind_col_c_v6_ex.[column_id] = ind_col_v6_ex.[column_id]
					and	ind_col_v6_ex.[object_id] = ind_v6.[object_id]
					and	ind_col_v6_ex.[index_id] = ind_v6.[index_id]
					and (	ind_col_v6_ex.[is_included_column] = 0
							or	ind_col_v6_ex.[is_included_column] is null
						)
					)
			full join	[EIDSS7_GG_AzurePackage].sys.index_columns ind_col_v7_ex
				join	[EIDSS7_GG_AzurePackage].sys.columns ind_col_c_v7_ex
				on	ind_col_c_v7_ex.[object_id] = ind_col_v7_ex.[object_id]
					and ind_col_c_v7_ex.[column_id] = ind_col_v7_ex.[column_id]
					and ind_col_v7_ex.[object_id] = ind_v7.[object_id]
					and ind_col_v7_ex.[index_id] = ind_v7.[index_id]
					and (	ind_col_v7_ex.[is_included_column] = 0
							or	ind_col_v7_ex.[is_included_column] is null
						)
			on	ind_col_c_v7_ex.[name] = ind_col_c_v6_ex.[name] collate Cyrillic_General_CI_AS
			where	ind_col_v6_ex.[index_id] is null or ind_col_v7_ex.[index_id] is null
		)

join	[EIDSS7_GG_AzurePackage].sys.index_columns ind_col_v7
on	ind_col_v7.[object_id] = ind_v7.[object_id]
	and ind_col_v7.[index_id] = ind_v7.[index_id]
join	[EIDSS7_GG_AzurePackage].sys.columns ind_col_c_v7
on	ind_col_c_v7.[object_id] = ind_col_v7.[object_id]
	and ind_col_c_v7.[column_id] = ind_col_v7.[column_id]
	and (	ind_col_v7.[is_included_column] = 0
			or	ind_col_v7.[is_included_column] is null
		)
left join	[EIDSS7_GG_AzurePackage].sys.types ind_col_c_typ_v7
on	ind_col_c_typ_v7.[user_type_id] = ind_col_c_v7.[user_type_id]



update	ttm
set		ttm.strUpdateFromHeader = ttm.strUpdateFromHeader + onJoinCond.strJoinOnCondition collate Cyrillic_General_CI_AS
from	#TablesToMigrate ttm
cross apply
(	select
		replace	(isnull	(
			(
				select	N'
					' + 
					case
						when pkc.[ind_col_id_v7] > 1
							then N'and ' 
						else N''
					end +
					ttm.[table_name] + '_v7.[' + 
					pkc.[col_name] + N'] = ' + 
					ttm.[table_name] + N'_v6.[' + 
					pkc.[col_name] + N'] ' +
					case
						when pkc.[col_type_name_v7] like N'%char%' collate Cyrillic_General_CI_AS 
							then N' collate Cyrillic_General_CI_AS' 
						else N'' 
					end collate Cyrillic_General_CI_AS
				from	#PKColumns pkc
				where	pkc.[table_id_v7] = ttm.[table_id_v7]
				order by	pkc.[ind_col_id_v7]
				for xml path ('')
			), N''), N'&#x0D;', N'
') as strJoinOnCondition
) onJoinCond



update	ttm
set		ttm.strInsertFromJoins = joinTables.strJoinStatement,
		ttm.strUpdateFromJoins = joinTables.strJoinStatement
from	#TablesToMigrate ttm
cross apply
(	select
		replace	(isnull	(
			(
				select	N'
					' + fk.strJoinTable + fk.strJoinOnCondition collate Cyrillic_General_CI_AS
				from	#FK fk
				where	fk.[parent_table_id_v7] = ttm.[table_id_v7]
				order by fk.[fk_nullable_v7], fk.[fk_id_v7]
				for xml path ('')
			), N''), N'&#x0D;', N'
') as strJoinStatement
) joinTables



update	ttm
set		ttm.strInsertFromJoins = ttm.strInsertFromJoins + N'
left join	[Giraffe].[' + ttm.[sch_name] + N'].[' + ttm.[table_name] + N'] ' + ttm.[table_name] +'_v7 
on	' + onJoinCond.strJoinOnCondition collate Cyrillic_General_CI_AS,
		ttm.strInsertWhereConditions = ttm.[table_name] +'_v7.[' + pkc_first.[col_name] + '] is null ' collate Cyrillic_General_CI_AS
from	#TablesToMigrate ttm
cross apply
(	select
		replace	(isnull	(
			(
				select	N'
					' + 
					case
						when pkc.[ind_col_id_v7] > 1
							then N'and ' 
						else N''
					end +
					ttm.[table_name] + '_v7.[' + 
					pkc.[col_name] + N'] = ' + 
					ttm.[table_name] + N'_v6.[' + 
					pkc.[col_name] + N'] ' +
					case
						when pkc.[col_type_name_v7] like N'%char%' collate Cyrillic_General_CI_AS 
							then N' collate Cyrillic_General_CI_AS' 
						else N'' 
					end collate Cyrillic_General_CI_AS
				from	#PKColumns pkc
				where	pkc.[table_id_v7] = ttm.[table_id_v7]
				order by	pkc.[ind_col_id_v7]
				for xml path ('')
			), N''), N'&#x0D;', N'
') as strJoinOnCondition
) onJoinCond
inner join	#PKColumns pkc_first
on			pkc_first.[table_id_v7] = ttm.[table_id_v7]
			and pkc_first.ind_col_id_v7 = 1


insert into	#Columns
(	[sch_id_v7],
	[sch_id_v6],
	[sch_name],
	[table_id_v7],
	[table_id_v6],
	[table_name],
		
	[col_id_v7],
	[col_name],
	[col_type_id_v7],
	[col_type_name_v7],
	[collation_v7],
	[max_length_v7],
	[is_identity_v7],
	[is_rowguidcol_v7],
	[is_nullable_v7],
	[is_computed_v7],

	[col_id_v6],
	[col_type_id_v6],
	[col_type_name_v6],
	[collation_v6],
	[max_length_v6],
	[is_identity_v6],
	[is_rowguidcol_v6],
	[is_nullable_v6],
	[is_computed_v6]
)
select	distinct
		ttm.[sch_id_v7],
		ttm.[sch_id_v6],
		ttm.[sch_name],
		ttm.[table_id_v7],
		ttm.[table_id_v6],
		ttm.[table_name],
		c_v7.[column_id] as [col_id_v7],
		c_v7.[name] as [col_name],
		c_typ_v7.[user_type_id] as [col_type_id_v7],
		c_typ_v7.[name] as [col_type_name_v7],

		c_v7.[collation_name] as [collation_v7],
		c_v7.[max_length] as [max_length_v7],

		c_v7.[is_identity] as [is_identity_v7],
		c_v7.[is_rowguidcol] as [is_rowguidcol_v7],
		c_v7.[is_nullable] as [is_nullable_v7],
		c_v7.[is_computed] as [is_computed_v7],

		c_v6.[column_id] as [col_id_v6],
		c_typ_v6.[user_type_id] as [col_type_id_v6],
		c_typ_v6.[name] as [col_type_name_v6],

		c_v6.[collation_name] as [collation_v6],
		c_v6.[max_length] as [max_length_v6],

		c_v6.[is_identity] as [is_identity_v6],
		c_v6.[is_rowguidcol] as [is_rowguidcol_v6],
		c_v6.[is_nullable] as [is_nullable_v6],
		c_v6.[is_computed] as [is_computed_v6]

from	#TablesToMigrate ttm
join	[EIDSS7_GG_AzurePackage].sys.columns c_v7
on		c_v7.[object_id] = ttm.[table_id_v7]
left join	[EIDSS7_GG_AzurePackage].sys.types c_typ_v7
on	c_typ_v7.[user_type_id] = c_v7.[user_type_id]

left join	[Falcon_GG].sys.columns c_v6
on	c_v6.[object_id] = ttm.[table_id_v6]
	and c_v6.[name] = c_v7.[name] collate Cyrillic_General_CI_AS
left join	[Falcon_GG].sys.types c_typ_v6
on	c_typ_v6.[user_type_id] = c_v6.[user_type_id]

--order by ttm.idfId, c_v7.[column_id]




update	ttm
set	ttm.strInsertHeader =
		case
			when	c_identity.[is_identity_v7] = 1
				then	N'
SET IDENTITY_INSERT [Giraffe].[' + ttm.[sch_name] + N'].[' + ttm.[table_name] + N']  ON

' collate Cyrillic_General_CI_AS
			else	N''
		end +
		ttm.strInsertHeader collate Cyrillic_General_CI_AS,
	ttm.strInsertWhereConditions = ttm.strInsertWhereConditions +
		case
			when	c_identity.[is_identity_v7] = 1
				then	N'
SET IDENTITY_INSERT [Giraffe].[' + ttm.[sch_name] + N'].[' + ttm.[table_name] + N']  OFF

' collate Cyrillic_General_CI_AS
			else	N''
		end collate Cyrillic_General_CI_AS,
	ttm.strInsertColumns = 
		case 
			when minColInsert.[col_id_v7] > 0 
				then N'
('			else N'' 
		end + 
		colListInsert.strColumns + 
		case 
			when minColInsert.[col_id_v7] > 0 
				then N'
)'			else N'' 
		end collate Cyrillic_General_CI_AS,
	ttm.strSelectColumns = ttm.strSelectColumns +
		colListSelect.strColumns,
	ttm.strUpdateColumns = ttm.strUpdateColumns +
		colListUpdate.strColumns
from	#TablesToMigrate ttm
left join	#Columns c_identity
on		c_identity.[table_id_v7] = ttm.[table_id_v7]
		and c_identity.[is_identity_v7] = 1
		and c_identity.[col_id_v6] is not null
cross apply
(	select	min(c_min.[col_id_v7]) as [col_id_v7]
	from	#Columns c_min
	where	c_min.[table_id_v7] = ttm.[table_id_v7]
			and (c_min.[is_computed_v7] = 0 or c_min.[is_computed_v7] is null)
			and (c_min.[is_identity_v7] = 0 or c_min.[is_identity_v7] is null or c_min.[col_id_v6] is not null)
) minColInsert
cross apply
(	select
		replace	(isnull	(
			(
				select	N'
					' + 
					case
						when c.[col_id_v7] > minColInsert.[col_id_v7]
							then N', ' 
						else N''
					end +
					N'[' + c.[col_name] + N']' collate Cyrillic_General_CI_AS
				from	#Columns c
				where	c.[table_id_v7] = ttm.[table_id_v7]
						and (c.[is_computed_v7] = 0 or c.[is_computed_v7] is null)
						and (c.[is_identity_v7] = 0 or c.[is_identity_v7] is null or c.[col_id_v6] is not null)
				order by	c.[col_id_v7]
				for xml path ('')
			), N''), N'&#x0D;', N'
') as strColumns
) colListInsert
cross apply
(	select
		replace	(isnull	( N'N''[{'' + ' +
			(
				select	
					case
						when pkc.[ind_col_id_v7] > 1
							then N' + N'','' + ' 
						else N''
					end +
					N'N''"' + pkc.[col_name] + N'":'' + isnull(' + 
					case
						when pkc.[col_type_name_v7] like N'%char%' collate Cyrillic_General_CI_AS
							then N'N''"'' + ' + pkc.[table_name] + '_v6.[' + pkc.[col_name] + ']' + N' + N''"'' collate Cyrillic_General_CI_AS' collate Cyrillic_General_CI_AS
						when (	pkc.[col_type_name_v7] = N'bigint' collate Cyrillic_General_CI_AS
								or pkc.[col_type_name_v7] = N'int' collate Cyrillic_General_CI_AS
							 )
							then N'cast(' + pkc.[table_name] + '_v6.[' + pkc.[col_name] + ']' + N' as nvarchar(20))' collate Cyrillic_General_CI_AS
						else N'N''"'' + cast(' + pkc.[table_name] + '_v6.[' + pkc.[col_name] + ']' + N' as nvarchar(200)) + N''"'' collate Cyrillic_General_CI_AS' collate Cyrillic_General_CI_AS
					end + N', N''null'')' collate Cyrillic_General_CI_AS
				from	#PKColumns pkc
				where	pkc.[table_id_v7] = ttm.[table_id_v7]
				order by	pkc.[ind_col_id_v7]
				for xml path ('')
			) + N' + N''}]'' collate Cyrillic_General_CI_AS' collate Cyrillic_General_CI_AS, N''), N'&#x0D;', N'
') as strValue
) jsonPK
cross apply
(	select
		replace(	replace(	replace	(isnull	(
			(
				select	N'
					' + 
					case
						when c.[col_id_v7] > minColInsert.[col_id_v7]
							then N', ' 
						else N''
					end +
					case
						when	c.[col_id_v6] is null
								and c.[col_name] = N'SourceSystemNameID' collate Cyrillic_General_CI_AS
							then	N'10519002 /*Record Source: EIDSS6.1*/'
						when	c.[col_id_v6] is null
								and c.[col_name] = N'SourceSystemKeyValue' collate Cyrillic_General_CI_AS
							then	jsonPK.strValue
						when	c.[col_id_v6] is null
								and c.[col_name] = N'AuditCreateUser' collate Cyrillic_General_CI_AS
							then	N'N''system'''
						when	c.[col_id_v6] is null
								and c.[col_name] = N'AuditCreateDTM' collate Cyrillic_General_CI_AS
							then	N'GETUTCDATE()'
						when	c.[col_id_v6] is null
								and c.[col_name] = N'AuditUpdateUser' collate Cyrillic_General_CI_AS
							then	N'N''system'''
						when	c.[col_id_v6] is null
								and c.[col_name] = N'AuditUpdateDTM' collate Cyrillic_General_CI_AS
							then	N'GETUTCDATE()'
						when	c.[col_id_v6] is null
								and c.[col_name] <> N'SourceSystemNameID' collate Cyrillic_General_CI_AS
								and c.[col_name] <> N'SourceSystemKeyValue' collate Cyrillic_General_CI_AS
								and c.[col_name] <> N'AuditCreateUser' collate Cyrillic_General_CI_AS
								and c.[col_name] <> N'AuditCreateDTM' collate Cyrillic_General_CI_AS
								and c.[col_name] <> N'AuditUpdateUser' collate Cyrillic_General_CI_AS
								and c.[col_name] <> N'AuditUpdateDTM' collate Cyrillic_General_CI_AS
								and c.[is_rowguidcol_v7] = 1
							then	N'newid() /*rowguid column*/'
						when	c.[col_id_v6] is null
								and (c.[is_rowguidcol_v7] = 0 or c.[is_rowguidcol_v7] is null)
								and (	(	c.[table_name] = N'trtDiagnosis' collate Cyrillic_General_CI_AS
											and c.[col_name] = N'blnSyndrome' collate Cyrillic_General_CI_AS
										)
										or	c.[col_name] = N'intRowStatus' collate Cyrillic_General_CI_AS
										or	(	c.[table_name] = N'ffSection' collate Cyrillic_General_CI_AS
												and c.[col_name] = N'blnFixedRowSet' collate Cyrillic_General_CI_AS
											)
										or	(	c.[table_name] = N'tlbMaterial' collate Cyrillic_General_CI_AS
												and (	c.[col_name] = N'LabModuleSourceIndicator' collate Cyrillic_General_CI_AS
														or	c.[col_name] = N'TestUnassignedIndicator' collate Cyrillic_General_CI_AS
														or	c.[col_name] = N'TestCompletedIndicator' collate Cyrillic_General_CI_AS
														or	c.[col_name] = N'TransferIndicator' collate Cyrillic_General_CI_AS
													)
											)
									)
							then	N'0 /*Rule for the new field in EIDSSv7: ' + c.[col_name] + N'*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and (c.[is_rowguidcol_v7] = 0 or c.[is_rowguidcol_v7] is null)
								and (	c.[table_name] = N'tstAggrSetting' collate Cyrillic_General_CI_AS
										and c.[col_name] = N'idfsSite' collate Cyrillic_General_CI_AS
									)
							then	N'@CDRSite /*Rule for the new field in EIDSSv7: ' + c.[col_name] + N'*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and (c.[is_rowguidcol_v7] = 0 or c.[is_rowguidcol_v7] is null)
								and (	(	c.[table_name] = N'tlbGeoLocationShared' collate Cyrillic_General_CI_AS
											or	c.[table_name] = N'tlbGeoLocation' collate Cyrillic_General_CI_AS
											or	c.[table_name] = N'tlbMonitoringSession' collate Cyrillic_General_CI_AS
										)
										and c.[col_name] = N'idfsLocation' collate Cyrillic_General_CI_AS
									)
							then	N'coalesce(j_gisSettlement_idfsSettlement_v7.[idfsSettlement], j_gisRayon_idfsRayon_v7.[idfsRayon], j_gisRegion_idfsRegion_v7.[idfsRegion], j_gisCountry_idfsCountry_v7.[idfsCountry]) /*Rule for the new field in EIDSSv7: ' + c.[col_name] + N'*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and (c.[is_rowguidcol_v7] = 0 or c.[is_rowguidcol_v7] is null)
								and (	(	c.[table_name] = N'tlbStreet' collate Cyrillic_General_CI_AS
											or	c.[table_name] = N'tlbPostalCode' collate Cyrillic_General_CI_AS
										)
										and c.[col_name] = N'idfsLocation' collate Cyrillic_General_CI_AS
									)
							then	N'j_gisSettlement_idfsSettlement_v7.[idfsSettlement] /*Rule for the new field in EIDSSv7: ' + c.[col_name] + N'*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and (c.[is_rowguidcol_v7] = 0 or c.[is_rowguidcol_v7] is null)
								and (	c.[table_name] = N'tlbOutbreak' collate Cyrillic_General_CI_AS
										and c.[col_name] = N'idfsLocation' collate Cyrillic_General_CI_AS
									)
							then	N'j_tlbGeoLocation_idfGeoLocation_v7.[idfsLocation] /*Rule for the new field in EIDSSv7: ' + c.[col_name] + N'*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and (c.[is_rowguidcol_v7] = 0 or c.[is_rowguidcol_v7] is null)
								and (	c.[table_name] = N'tlbEmployee' collate Cyrillic_General_CI_AS
										and c.[col_name] = N'idfsEmployeeCategory' collate Cyrillic_General_CI_AS
									)
							then	N'(10023002 - tlbEmployee_v6.[idfsEmployeeType] /*1 when Employee Group, otherwise 0*/) * 10526002 /*Non-User*/ + (tlbEmployee_v6.[idfsEmployeeType] - 10023001 /*1 when Person, otherwise 0*/) * 10526001 /*User*/'
						when	c.[col_id_v6] is null
								and (c.[is_rowguidcol_v7] = 0 or c.[is_rowguidcol_v7] is null)
								and (	c.[table_name] = N'tlbPerson' collate Cyrillic_General_CI_AS
										and c.[col_name] = N'PersonalIDTypeID' collate Cyrillic_General_CI_AS
									)
							then	N'pIdType_v7.[idfsBaseReference] /*Rule for the new field in EIDSSv7: ' + c.[col_name] + N'*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and (c.[is_rowguidcol_v7] = 0 or c.[is_rowguidcol_v7] is null)
								and (	c.[table_name] = N'tstUserTable' collate Cyrillic_General_CI_AS
										and c.[col_name] = N'PreferredLanguageID' collate Cyrillic_General_CI_AS
									)
							then	N'@idfsPreferredNationalLanguage /*Rule for the new field in EIDSSv7: ' + c.[col_name] + N'*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and (c.[is_rowguidcol_v7] = 0 or c.[is_rowguidcol_v7] is null)
								and (	c.[table_name] = N'tlbCampaign' collate Cyrillic_General_CI_AS
										and c.[col_name] = N'CampaignCategoryID' collate Cyrillic_General_CI_AS
									)
							then	N'10501002 /*Rule for the new field in EIDSSv7: ' + c.[col_name] + N' - default value [Veterinary Active Surveillance Campaign]*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and (c.[is_rowguidcol_v7] = 0 or c.[is_rowguidcol_v7] is null)
								and (	c.[table_name] = N'tlbCampaign' collate Cyrillic_General_CI_AS
										and c.[col_name] = N'LegacyCampaignID' collate Cyrillic_General_CI_AS
									)
							then	N'tlbCampaign_v6.strCampaignID /*Rule for the new field in EIDSSv7: ' + c.[col_name] + N'*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and (c.[is_rowguidcol_v7] = 0 or c.[is_rowguidcol_v7] is null)
								and (	c.[table_name] = N'tlbOutbreak' collate Cyrillic_General_CI_AS
										and c.[col_name] = N'OutbreakTypeID' collate Cyrillic_General_CI_AS
									)
							then	N'
					  case
						when	vc_count.intCount = 0 and hc_count.intCount > 0
							then	10513001 /*Human*/
						when	vc_count.intCount > 0 and hc_count.intCount = 0
							then	10513001 /*Veterinary*/
						else	10513003 /*Zoonotic*/
					  end /*Rule for the new field in EIDSSv7: ' + c.[col_name] + N'*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and (c.[is_rowguidcol_v7] = 0 or c.[is_rowguidcol_v7] is null)
								and (	c.[table_name] = N'tlbMonitoringSession' collate Cyrillic_General_CI_AS
										and c.[col_name] = N'LegacySessionID' collate Cyrillic_General_CI_AS
									)
							then	N'tlbMonitoringSession_v6.strMonitoringSessionID /*Rule for the new field in EIDSSv7: ' + c.[col_name] + N'*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and (c.[is_rowguidcol_v7] = 0 or c.[is_rowguidcol_v7] is null)
								and (	c.[table_name] = N'tlbMonitoringSession' collate Cyrillic_General_CI_AS
										and c.[col_name] = N'idfsMonitoringSessionSpeciesType' collate Cyrillic_General_CI_AS
									)
							then	N'null /*TODO: Check the rule for the new field in EIDSSv7: ' + c.[col_name] + N'*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and (c.[is_rowguidcol_v7] = 0 or c.[is_rowguidcol_v7] is null)
								and (	c.[table_name] = N'tlbHumanCase' collate Cyrillic_General_CI_AS
										and c.[col_name] = N'LegacyCaseID' collate Cyrillic_General_CI_AS
									)
							then	N'cchc.strLegacyID_v6 /*Rule for the new field in EIDSSv7: ' + c.[col_name] + N'*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and (c.[is_rowguidcol_v7] = 0 or c.[is_rowguidcol_v7] is null)
								and (	c.[table_name] = N'tlbBasicSyndromicSurveillanceAggregateHeader' collate Cyrillic_General_CI_AS
										and c.[col_name] = N'LegacyFormID' collate Cyrillic_General_CI_AS
									)
							then	N'tlbBasicSyndromicSurveillanceAggregateHeader_v6.[strFormID] /*Rule for the new field in EIDSSv7: ' + c.[col_name] + N'*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and (c.[is_rowguidcol_v7] = 0 or c.[is_rowguidcol_v7] is null)
								and (	c.[table_name] = N'tlbHumanCase' collate Cyrillic_General_CI_AS
										and c.[col_name] = N'DiseaseReportTypeID' collate Cyrillic_General_CI_AS
									)
							then	N'cchc.DiseaseReportTypeID_v7 /*Rule for the new field in EIDSSv7: ' + c.[col_name] + N'*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and (c.[is_rowguidcol_v7] = 0 or c.[is_rowguidcol_v7] is null)
								and (	c.[table_name] = N'tlbHumanCase' collate Cyrillic_General_CI_AS
										and c.[col_name] = N'idfsYNPreviouslySoughtCare' collate Cyrillic_General_CI_AS
									)
							then	N'case when j_tlbOffice_idfSoughtCareFacility_v7.[idfOffice] is not null or tlbHumanCase_v6.[datFirstSoughtCareDate] is not null or j_trtBaseReference_idfsNonNotifiableDiagnosis_v7.[idfsBaseReference] is not null then 10100001 /*Yes*/ else null end /*Rule for the new field in EIDSSv7: ' + c.[col_name] + N'*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and (c.[is_rowguidcol_v7] = 0 or c.[is_rowguidcol_v7] is null)
								and (	c.[table_name] = N'tlbHumanCase' collate Cyrillic_General_CI_AS
										and c.[col_name] = N'idfsYNExposureLocationKnown' collate Cyrillic_General_CI_AS
									)
							then	N'case when (j_tlbGeoLocation_idfPointGeoLocation_v7.[idfsLocation] is not null and j_tlbGeoLocation_idfPointGeoLocation_v7.[idfsLocation] <> @idfsCountry) or j_tlbGeoLocation_idfPointGeoLocation_v7.[blnForeignAddress] = 1 or tlbHumanCase_v6.[datExposureDate] is not null then 10100001 /*Yes*/ else null end /*Rule for the new field in EIDSSv7: ' + c.[col_name] + N'*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and (c.[is_rowguidcol_v7] = 0 or c.[is_rowguidcol_v7] is null)
								and (	c.[table_name] = N'tlbVetCase' collate Cyrillic_General_CI_AS
										and c.[col_name] = N'LegacyCaseID' collate Cyrillic_General_CI_AS
									)
							then	N'tlbVetCase_v6.strCaseID /*Rule for the new field in EIDSSv7: ' + c.[col_name] + N'*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and (c.[is_rowguidcol_v7] = 0 or c.[is_rowguidcol_v7] is null)
								and (	c.[table_name] = N'tlbMaterial' collate Cyrillic_General_CI_AS
										and c.[col_name] = N'DiseaseID' collate Cyrillic_General_CI_AS
									)
							then	N'coalesce(j_tlbHumanCase_idfHumanCase_v7.[idfsFinalDiagnosis], j_tlbHumanCase_idfHumanCase_v7.[idfsTentativeDiagnosis], j_tlbVetCase_idfVetCase_v7.[idfsFinalDiagnosis]) /*Rule for the new field in EIDSSv7: ' + c.[col_name] + N'*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and (c.[is_rowguidcol_v7] = 0 or c.[is_rowguidcol_v7] is null)
								and (	c.[table_name] = N'tlbTesting' collate Cyrillic_General_CI_AS
										and c.[col_name] = N'idfMonitoringSession' collate Cyrillic_General_CI_AS
									)
							then	N'j_tlbMaterial_idfMaterial_v7.[idfMonitoringSession] /*Rule for the new field in EIDSSv7: ' + c.[col_name] + N'*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and (c.[is_rowguidcol_v7] = 0 or c.[is_rowguidcol_v7] is null)
								and (	c.[table_name] = N'tlbTesting' collate Cyrillic_General_CI_AS
										and c.[col_name] = N'idfHumanCase' collate Cyrillic_General_CI_AS
									)
							then	N'j_tlbMaterial_idfMaterial_v7.[idfHumanCase] /*Rule for the new field in EIDSSv7: ' + c.[col_name] + N'*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and (c.[is_rowguidcol_v7] = 0 or c.[is_rowguidcol_v7] is null)
								and (	c.[table_name] = N'tlbTesting' collate Cyrillic_General_CI_AS
										and c.[col_name] = N'idfVetCase' collate Cyrillic_General_CI_AS
									)
							then	N'j_tlbMaterial_idfMaterial_v7.[idfVetCase] /*Rule for the new field in EIDSSv7: ' + c.[col_name] + N'*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and (c.[is_rowguidcol_v7] = 0 or c.[is_rowguidcol_v7] is null)
								and (	c.[table_name] = N'tlbTesting' collate Cyrillic_General_CI_AS
										and c.[col_name] = N'idfVector' collate Cyrillic_General_CI_AS
									)
							then	N'j_tlbMaterial_idfMaterial_v7.[idfVector] /*Rule for the new field in EIDSSv7: ' + c.[col_name] + N'*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and c.[col_name] <> N'SourceSystemNameID' collate Cyrillic_General_CI_AS
								and c.[col_name] <> N'SourceSystemKeyValue' collate Cyrillic_General_CI_AS
								and c.[col_name] <> N'AuditCreateUser' collate Cyrillic_General_CI_AS
								and c.[col_name] <> N'AuditCreateDTM' collate Cyrillic_General_CI_AS
								and c.[col_name] <> N'AuditUpdateUser' collate Cyrillic_General_CI_AS
								and c.[col_name] <> N'AuditUpdateDTM' collate Cyrillic_General_CI_AS
								and (c.[is_rowguidcol_v7] = 0 or c.[is_rowguidcol_v7] is null)
								and (	c.[table_name] <> N'trtDiagnosis' collate Cyrillic_General_CI_AS
										or c.[col_name] <> N'blnSyndrome' collate Cyrillic_General_CI_AS
									)
								and (	c.[table_name] <> N'tstAggrSetting' collate Cyrillic_General_CI_AS
										or c.[col_name] <> N'idfsSite' collate Cyrillic_General_CI_AS
									)
								and	(	c.[table_name] <> N'ffSection' collate Cyrillic_General_CI_AS
										or c.[col_name] <> N'blnFixedRowSet' collate Cyrillic_General_CI_AS
									)
								and (	c.[table_name] <> N'tlbMaterial' collate Cyrillic_General_CI_AS
										or (	c.[col_name] <> N'LabModuleSourceIndicator' collate Cyrillic_General_CI_AS
												and	c.[col_name] <> N'TestUnassignedIndicator' collate Cyrillic_General_CI_AS
												and	c.[col_name] <> N'TestCompletedIndicator' collate Cyrillic_General_CI_AS
												and	c.[col_name] <> N'TransferIndicator' collate Cyrillic_General_CI_AS
												and c.[col_name] <> N'DiseaseID' collate Cyrillic_General_CI_AS
											)
									)
								and	(	(	c.[table_name] <> N'tlbGeoLocationShared' collate Cyrillic_General_CI_AS
											and c.[table_name] <> N'tlbGeoLocation' collate Cyrillic_General_CI_AS
											and c.[table_name] <> N'tlbStreet' collate Cyrillic_General_CI_AS
											and c.[table_name] <> N'tlbPostalCode' collate Cyrillic_General_CI_AS
											and c.[table_name] <> N'tlbOutbreak' collate Cyrillic_General_CI_AS
											and c.[table_name] <> N'tlbMonitoringSession' collate Cyrillic_General_CI_AS
										)
										or c.[col_name] <> N'idfsLocation' collate Cyrillic_General_CI_AS
									)
								and	(	c.[table_name] <> N'tlbEmployee' collate Cyrillic_General_CI_AS
										or c.[col_name] <> N'idfsEmployeeCategory' collate Cyrillic_General_CI_AS
									)
								and	(	c.[table_name] <> N'tlbPerson' collate Cyrillic_General_CI_AS
										or c.[col_name] <> N'PersonalIDTypeID' collate Cyrillic_General_CI_AS
									)
								and	(	c.[table_name] <> N'tstUserTable' collate Cyrillic_General_CI_AS
										or c.[col_name] <> N'PreferredLanguageID' collate Cyrillic_General_CI_AS
									)
								and	(	c.[table_name] <> N'tlbCampaign' collate Cyrillic_General_CI_AS
										or	(	c.[col_name] <> N'CampaignCategoryID' collate Cyrillic_General_CI_AS
												and c.[col_name] <> N'LegacyCampaignID' collate Cyrillic_General_CI_AS
											)
									)
								and	(	c.[table_name] <> N'tlbMonitoringSession' collate Cyrillic_General_CI_AS
										or	(	c.[col_name] <> N'idfsMonitoringSessionSpeciesType' collate Cyrillic_General_CI_AS
												and c.[col_name] <> N'LegacySessionID' collate Cyrillic_General_CI_AS
											)
									)
								and	(	c.[table_name] <> N'tlbBasicSyndromicSurveillanceAggregateHeader' collate Cyrillic_General_CI_AS
										or c.[col_name] <> N'LegacyFormID' collate Cyrillic_General_CI_AS
									)
								and (	c.[table_name] <> N'tlbOutbreak' collate Cyrillic_General_CI_AS
										or c.[col_name] <> N'OutbreakTypeID' collate Cyrillic_General_CI_AS
									)
								and	(	c.[table_name] <> N'tlbHumanCase' collate Cyrillic_General_CI_AS
										or	(	c.[col_name] <> N'LegacyCaseID' collate Cyrillic_General_CI_AS
												and c.[col_name] <> N'DiseaseReportTypeID' collate Cyrillic_General_CI_AS
												and c.[col_name] <> N'idfsYNPreviouslySoughtCare' collate Cyrillic_General_CI_AS
												and c.[col_name] <> N'idfsYNExposureLocationKnown' collate Cyrillic_General_CI_AS
											)
									)
								and	(	c.[table_name] <> N'tlbVetCase' collate Cyrillic_General_CI_AS
										or	c.[col_name] <> N'LegacyCodeID' collate Cyrillic_General_CI_AS
									)
								and	(	c.[table_name] <> N'tlbTesting' collate Cyrillic_General_CI_AS
										or	(	c.[col_name] <> N'idfMonitoringSession' collate Cyrillic_General_CI_AS
												and c.[col_name] <> N'idfHumanCase' collate Cyrillic_General_CI_AS
												and c.[col_name] <> N'idfVetCase' collate Cyrillic_General_CI_AS
												and c.[col_name] <> N'idfVector' collate Cyrillic_General_CI_AS
											)
									)
								and c.[col_name] <> N'intRowStatus' collate Cyrillic_General_CI_AS
							then	N'null /*TODO: Check the rule for the new field in EIDSSv7: ' + c.[col_name] + N'*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is not null
								and c.[table_name] = N'tstSite' collate Cyrillic_General_CI_AS
								and (	c.[col_name] = N'idfOffice' collate Cyrillic_General_CI_AS
										or c.[col_name] = N'idfsParentSite' collate Cyrillic_General_CI_AS
									)
							then	N'null /*Will be updated below when foreign key data is available*/' collate Cyrillic_General_CI_AS 
						when	c.[col_id_v6] is not null
								and c.[table_name] = N'tlbFreezerSubdivision' collate Cyrillic_General_CI_AS
								and c.[col_name] = N'idfParentSubdivision' collate Cyrillic_General_CI_AS
							then	N'null /*Will be updated below when foreign key data is available*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is not null
								and c.[table_name] = N'tlbOutbreak' collate Cyrillic_General_CI_AS
								and c.[col_name] = N'idfPrimaryCaseOrSession' collate Cyrillic_General_CI_AS
							then	N'null /*Will be updated below when foreign key data is available*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is not null
								and c.[table_name] = N'tlbVector' collate Cyrillic_General_CI_AS
								and c.[col_name] = N'idfHostVector' collate Cyrillic_General_CI_AS
							then	N'null /*Will be updated below when foreign key data is available*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is not null
								and c.[table_name] = N'tlbHumanCase' collate Cyrillic_General_CI_AS
								and c.[col_name] = N'idfDeduplicationResultCase' collate Cyrillic_General_CI_AS
							then	N'null /*Will be updated below when foreign key data is available*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is not null
								and c.[table_name] = N'tlbMaterial' collate Cyrillic_General_CI_AS
								and (	c.[col_name] = N'idfRootMaterial' collate Cyrillic_General_CI_AS
										or c.[col_name] = N'idfParentMaterial' collate Cyrillic_General_CI_AS
										or c.[col_name] = N'idfMainTest' collate Cyrillic_General_CI_AS
									)
							then	N'null /*Will be updated below when foreign key data is available*/' collate Cyrillic_General_CI_AS 
						when	c.[col_id_v6] is not null
								and fkc.[fk_col_id_v7] is not null
								and (	c.[table_name] <> N'tstSite' collate Cyrillic_General_CI_AS
										or	(	c.[col_name] <> N'idfOffice' collate Cyrillic_General_CI_AS
												and c.[col_name] <> N'idfsParentSite' collate Cyrillic_General_CI_AS
											)
									)
								and (	c.[table_name] <> N'tlbFreezerSubdivision' collate Cyrillic_General_CI_AS
										or c.[col_name] <> N'idfParentSubdivision' collate Cyrillic_General_CI_AS
									)
								and (	c.[table_name] <> N'tlbOutbreak' collate Cyrillic_General_CI_AS
										or c.[col_name] <> N'idfPrimaryCaseOrSession' collate Cyrillic_General_CI_AS
									)
								and (	c.[table_name] <> N'tlbVector' collate Cyrillic_General_CI_AS
										or c.[col_name] <> N'idfHostVector' collate Cyrillic_General_CI_AS
									)
								and (	c.[table_name] <> N'tlbHumanCase' collate Cyrillic_General_CI_AS
										or c.[col_name] <> N'idfDeduplicationResultCase' collate Cyrillic_General_CI_AS
									)
								and (	c.[table_name] <> N'tlbMaterial' collate Cyrillic_General_CI_AS
										or	(	c.[col_name] <> N'idfRootMaterial' collate Cyrillic_General_CI_AS
												and c.[col_name] <> N'idfParentMaterial' collate Cyrillic_General_CI_AS
												and c.[col_name] <> N'idfMainTest' collate Cyrillic_General_CI_AS
											)
									)
							then	fk.strFKTableAlias + N'.[' + fkc.[ref_col_name] + N']' collate Cyrillic_General_CI_AS 
						when	c.[col_id_v6] is not null
								and fkc.[fk_col_id_v7] is null
								and (	c.[table_name] <> N'tstSite' collate Cyrillic_General_CI_AS
										or	(	c.[col_name] <> N'idfOffice' collate Cyrillic_General_CI_AS
												and c.[col_name] <> N'idfsParentSite' collate Cyrillic_General_CI_AS
											)
									)
								and (	c.[table_name] <> N'tlbFreezerSubdivision' collate Cyrillic_General_CI_AS
										or c.[col_name] <> N'idfParentSubdivision' collate Cyrillic_General_CI_AS
									)
								and (	c.[table_name] <> N'tlbOutbreak' collate Cyrillic_General_CI_AS
										or c.[col_name] <> N'idfPrimaryCaseOrSession' collate Cyrillic_General_CI_AS
									)
								and (	c.[table_name] <> N'tlbVector' collate Cyrillic_General_CI_AS
										or c.[col_name] <> N'idfHostVector' collate Cyrillic_General_CI_AS
									)
								and (	c.[table_name] <> N'tlbHumanCase' collate Cyrillic_General_CI_AS
										or c.[col_name] <> N'idfDeduplicationResultCase' collate Cyrillic_General_CI_AS
									)
								and (	c.[table_name] <> N'tlbMaterial' collate Cyrillic_General_CI_AS
										or	(	c.[col_name] <> N'idfRootMaterial' collate Cyrillic_General_CI_AS
												and c.[col_name] <> N'idfParentMaterial' collate Cyrillic_General_CI_AS
												and c.[col_name] <> N'idfMainTest' collate Cyrillic_General_CI_AS
											)
									)
							then	c.[table_name] + N'_v6.[' + c.[col_name] + N']' collate Cyrillic_General_CI_AS
					end collate Cyrillic_General_CI_AS
				from	#Columns c
				left join	#FKColumns fkc
					join	#FK fk
					on	fk.[fk_id_v7] = fkc.[fk_id_v7]
				on	fkc.[parent_table_id_v7] = c.[table_id_v7]
					and fkc.[parent_col_id_v7] = c.[col_id_v7]
					and fk.[ref_table_id_v7] <> fk.[parent_table_id_v7] -- exclude FK from the table to the same table
				where	c.[table_id_v7] = ttm.[table_id_v7]
						and (c.[is_computed_v7] = 0 or c.[is_computed_v7] is null)
						and (c.[is_identity_v7] = 0 or c.[is_identity_v7] is null or c.[col_id_v6] is not null)
				order by	c.[col_id_v7]
				for xml path ('')
			), N''), N'&#x0D;', N'
'), N'&gt;', N'>'), N'&lt;', N'<') as strColumns
) colListSelect
cross apply
(	select	min(c_min.[col_id_v7]) as [col_id_v7]
	from	#Columns c_min
	where	c_min.[table_id_v7] = ttm.[table_id_v7]
			and (c_min.[is_computed_v7] = 0 or c_min.[is_computed_v7] is null)
			and c_min.[col_name] <> N'AuditCreateUser' collate Cyrillic_General_CI_AS
			and c_min.[col_name] <> N'AuditCreateDTM' collate Cyrillic_General_CI_AS
			and (	c_min.[table_name] <> N'tstUserTable' collate Cyrillic_General_CI_AS
					or	(	c_min.[col_name] <> N'datTryDate' collate Cyrillic_General_CI_AS
							and c_min.[col_name] <> N'intTry' collate Cyrillic_General_CI_AS
							and c_min.[col_name] <> N'datPasswordSet' collate Cyrillic_General_CI_AS
							and c_min.[col_name] <> N'binPassword' collate Cyrillic_General_CI_AS
						)
				)
			and not exists
				(	select	1
					from	#PKColumns pkc_min
					where	pkc_min.[table_id_v7] = c_min.[table_id_v7]
							and pkc_min.[col_id_v7] = c_min.[col_id_v7]
				)
) minColUpdate
cross apply
(	select
		replace	(isnull	(
			(
				select	N'
					' + 
					case
						when	c.[col_id_v7] > minColUpdate.[col_id_v7]
								and not (
										c.[col_id_v6] is null
										and c.[col_name] <> N'SourceSystemNameID' collate Cyrillic_General_CI_AS
										and c.[col_name] <> N'SourceSystemKeyValue' collate Cyrillic_General_CI_AS
										and c.[col_name] <> N'AuditUpdateUser' collate Cyrillic_General_CI_AS
										and c.[col_name] <> N'AuditUpdateDTM' collate Cyrillic_General_CI_AS
										and (c.[is_rowguidcol_v7] = 0 or c.[is_rowguidcol_v7] is null)
										)
							then N', ' 
						else N''
					end +
					case
						when	c.[col_id_v6] is null
								and c.[col_name] = N'SourceSystemNameID' collate Cyrillic_General_CI_AS
							then	N'[' + c.[col_name] + N'] = 10519002 /*Record Source: EIDSS6.1*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and c.[col_name] = N'SourceSystemKeyValue' collate Cyrillic_General_CI_AS
							then	N'[' + c.[col_name] + N'] = ' + jsonPK.strValue collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and c.[col_name] = N'AuditUpdateUser' collate Cyrillic_General_CI_AS
							then	N'[' + c.[col_name] + N'] = N''system''' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and c.[col_name] = N'AuditUpdateDTM' collate Cyrillic_General_CI_AS
							then	N'[' + c.[col_name] + N'] = GETUTCDATE()' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and c.[col_name] <> N'SourceSystemNameID' collate Cyrillic_General_CI_AS
								and c.[col_name] <> N'SourceSystemKeyValue' collate Cyrillic_General_CI_AS
								and c.[col_name] <> N'AuditUpdateUser' collate Cyrillic_General_CI_AS
								and c.[col_name] <> N'AuditUpdateDTM' collate Cyrillic_General_CI_AS
								and c.[is_rowguidcol_v7] = 1
							then	N'[' + c.[col_name] + N'] = isnull(' + 
								c.[table_name] + N'_v7.[' + c.[col_name] + N'], newid()) /*rowguid column*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is null
								and c.[col_name] <> N'SourceSystemNameID' collate Cyrillic_General_CI_AS
								and c.[col_name] <> N'SourceSystemKeyValue' collate Cyrillic_General_CI_AS
								and c.[col_name] <> N'AuditUpdateUser' collate Cyrillic_General_CI_AS
								and c.[col_name] <> N'AuditUpdateDTM' collate Cyrillic_General_CI_AS
								and (c.[is_rowguidcol_v7] = 0 or c.[is_rowguidcol_v7] is null)
							then	N'/*TODO: Check the rule for the new field in EIDSSv7: ' + c.[col_name] + N'*/' collate Cyrillic_General_CI_AS
						when	c.[col_id_v6] is not null
								and fkc.[fk_col_id_v7] is not null
							then	N'[' + c.[col_name] + N'] = ' + fk.strFKTableAlias + N'.[' + fkc.[ref_col_name] + N']' collate Cyrillic_General_CI_AS 
						when	c.[col_id_v6] is not null
								and fkc.[fk_col_id_v7] is null
							then	N'[' + c.[col_name] + N'] = ' + c.[table_name] + N'_v6.[' + c.[col_name] + N']' collate Cyrillic_General_CI_AS
					end collate Cyrillic_General_CI_AS
				from	#Columns c
				left join	#FKColumns fkc
					join	#FK fk
					on	fk.[fk_id_v7] = fkc.[fk_id_v7]
				on	fkc.[parent_table_id_v7] = c.[table_id_v7]
					and fkc.[parent_col_id_v7] = c.[col_id_v7]
				where	c.[table_id_v7] = ttm.[table_id_v7]
						and (c.[is_computed_v7] = 0 or c.[is_computed_v7] is null)
						and c.[col_name] <> N'AuditCreateUser' collate Cyrillic_General_CI_AS
						and c.[col_name] <> N'AuditCreateDTM' collate Cyrillic_General_CI_AS
						and (	c.[table_name] <> N'tstUserTable' collate Cyrillic_General_CI_AS
								or	(	c.[col_name] <> N'datTryDate' collate Cyrillic_General_CI_AS
										and c.[col_name] <> N'intTry' collate Cyrillic_General_CI_AS
										and c.[col_name] <> N'datPasswordSet' collate Cyrillic_General_CI_AS
										and c.[col_name] <> N'binPassword' collate Cyrillic_General_CI_AS
									)
							)
						and not exists
							(	select	1
								from	#PKColumns pkc
								where	pkc.[table_id_v7] = c.[table_id_v7]
										and pkc.[col_id_v7] = c.[col_id_v7]
							)
				order by	c.[col_id_v7]
				for xml path ('')
			), N''), N'&#x0D;', N'
') as strColumns
) colListUpdate


update	ttm
set		ttm.strInsertWhereConditions = ttm.strInsertWhereConditions + N'
	and (	trtBaseReference_v6.idfsReferenceType in
			(	19000165, -- Aberration Analysis Method
				--System--19000515, -- Access Permission
				--present above in separate selection--119000537, -- Access Rule
				--System--19000110, -- Accession Condition
				--System--19000040, -- Accessory List
				--System--19000527, -- Account State
				--System--19000003, -- Administrative Level
				19000146, -- Age Groups
				--System--19000102, -- Aggregate Case Type
				19000005, -- Animal Age
				--System--19000007, -- Animal Sex
				19000006, -- Animal/Bird Status

				--System--19000115, -- AS Campaign Status
				19000116, -- AS Campaign Type
				--System--19000128, -- AS Session Action Status
				19000127, -- AS Session Action Type
				--System--19000117, -- AS Session Status
				--System--19000538, -- AS Species Type
				19000009, -- Avian Farm Production Type
				19000008, -- Avian Farm Type
				19000004, -- AVR Aggregate Function

				19000125, -- AVR Chart Name
				--System--19000013, -- AVR Chart Type
				19000123, -- AVR Folder Name
				--System--19000039, -- AVR Group Date
				19000122, -- AVR Layout Description
				19000143, -- AVR Layout Field Name
				19000050, -- AVR Layout Name
				19000126, -- AVR Map Name
				19000121, -- AVR Query Description
				19000075, -- AVR Query Name
				19000124, -- AVR Report Name
				--System--19000080, -- AVR Search Field--TODO: check if needed to uncomment
				--System--19000081, -- AVR Search Field Type
				--System--19000082, -- AVR Search Object--TODO: check if needed to uncomment
				19000163, -- Basic Syndromic Surveillance - Aggregate Columns
				19000160, -- Basic Syndromic Surveillance - Method of Measurement
				19000161, -- Basic Syndromic Surveillance - Outcome
				19000162, -- Basic Syndromic Surveillance - Test Result
				19000159, -- Basic Syndromic Surveillance - Type
				19000137, -- Basis of record
				--System--19000501, -- Campaign Category
				19000011, -- Case Classification
				19000064, -- Case Outcome List
				--System--19000144, -- Case Report Type
				--System--19000111, -- Case Status
				--System--19000012, -- Case Type
				19000135, -- Collection method
				--System--19000136, -- Collection time period
				--System--19000120, -- Configuration Description
				--System--19000500, -- Contact Phone Type
				19000129, -- Custom Report Type
				--System--19000016, -- Data Audit Event Type
				--System--19000017, -- Data Audit Object Type
				--System--19000018, -- Data Export Detail Status
				19000164, -- Departament Name
				--System--19000157, -- Destruction Method
				19000156, -- Diagnoses Groups
				19000021, -- Diagnostic Investigation List
				--System--19000020, -- Diagnosis Using Type
				19000019, -- Disease
				--System--19000503, -- Disease Report Relationship
				--System--19000510, -- EIDSSAppModuleGroup
				--System--19000506, -- EIDSSAppObjectList
				--System--19000505, -- EIDSSAppObjectType
				--System--19000509, -- EIDSSAppPreference
				--System--19000511, -- EIDSSAuditParameters
				--System--19000508, -- EIDSSModuleConstant
				--System--19000507, -- EIDSSPageTitle
				--System--19000526, -- Employee Category
				--Will be processed separately--19000022, -- Employee Group Name
				--System--19000073, -- Employee Position
				--System--19000023, -- Employee Type
				--System--19000024, -- Event Information String
				--System--19000155, -- Event Subscriptions
				--System--19000025, -- Event Type
				19000037, -- Farm Grazing Pattern
				19000026, -- Farm Intended Use
				19000053, -- Farm Movement Pattern
				19000065, -- Farm Ownership Type
				19000027, -- Farming System
' +	
N'
				--System--19000028, -- Flexible Form Check Point
				--System--19000108, -- Flexible Form Decorate Element Type
				19000131, -- Flexible Form Label Text
				19000066, -- Flexible Form Parameter Caption
				--System--19000067, -- Flexible Form Parameter Editor
				--System--19000068, -- Flexible Form Parameter Mode
				19000070, -- Flexible Form Parameter Tooltip
				19000071, -- Flexible Form Parameter Type
				19000069, -- Flexible Form Parameter Value
				19000029, -- Flexible Form Rule
				--System--19000030, -- Flexible Form Rule Action
				--System--19000031, -- Flexible Form Rule Function
				19000032, -- Flexible Form Rule Message
				19000101, -- Flexible Form Section
				--System--19000525, -- Flexible Form Section Type
				19000033, -- Flexible Form Template
				--System--19000034, -- Flexible Form Type

				--System--19000512, -- Freezer Box Size
				--System--19000093, -- Freezer Subdivision Type
				--System--19000036, -- Geo Location Type
				--System--19000038, -- Ground Type
				--System--19000042, -- Human Age Type
				--System--19000043, -- Human Gender
				19000138, -- Identification method
				--System--19000044, -- Information String
				19000049, -- Language--TODO: fill in strBaseReferenceCode for language with its abbreviation
				--System--19000522, -- Legal Form
				19000051, -- Livestock Farm Production Type
				--System--19000523, -- Main Form of Activity
				19000152, -- Matrix Column
				19000151, -- Matrix Type

				19000054, -- Nationality List
				19000149, -- Non-Notifiable Diagnosis

				--System--19000055, -- Notification Object Type
				--System--19000056, -- Notification Type
				--System--19000057, -- Numbering Schema Document Type
				--System--19000060, -- Object Type
				--System--19000109, -- Object Type Relation

				19000061, -- Occupation Type

				--System--19000062, -- Office Type

				19000045, -- Organization Abbreviation
				19000046, -- Organization Name

				--System--19000504, -- Organization Type
				--System--19000520, -- Outbreak Case Status
				--System--19000517, -- Outbreak Contact Status
				--System--19000516, -- Outbreak Contact Type
				--System--19000514, -- Outbreak Species Group
				--System--19000063, -- Outbreak Status
				--System--19000513, -- Outbreak Type
				--System--19000518, -- Outbreak Update Priority
				--System--19000521, -- Ownership Form
				--System--19000072, -- Party Type
				--System--19000014, -- Patient Contact Type
				--System--19000041, -- Patient Location Type
				19000035, -- Patient State
				19000134, -- Penside Test Category
				19000104, -- Penside Test Name
				19000105, -- Penside Test Result
				--System--19000148, -- Personal ID Type

				19000074, -- Prophylactic Measure List

				19000147, -- Reason for Changed Diagnosis
				19000150, -- Reason for not Collecting Sample
				--System--19000076, -- Reference Type Name

				19000132, -- Report Additional Text
				19000130, -- Report Diagnoses Group

				--System--19000502, -- Report/Session Type List
				--System--19000078, -- Resident Type
				--System--19000535, -- Resource Flag
				--System--19000531, -- Resource Type
				--System--19000106, -- Rule In Value for Test Validation
				--System--19000158, -- Sample Kind
				--System--19000015, -- Sample Status

				19000087, -- Sample Type
				19000079, -- Sanitary Measure List

				--System--19000112, -- Security Audit Action
				--System--19000114, -- Security Audit Process Type
				--System--19000113, -- Security Audit Result
				19000118, -- Security Configuration Alphabet Name
				--System--19000119, -- Security Level
				--System--19000536, -- Site Alert Type
				--System--19000524, -- Site Group Type
				--System--19000084, -- Site Relation Type
				--System--19000085, -- Site Type
				--System--19000519, -- Source System Name

				19000166, -- Species Groups
				19000086, -- Species List
				19000145, -- Statistical Age Groups
				--System--19000089, -- Statistical Area Type
				19000090, -- Statistical Data Type
				--System--19000091, -- Statistical Period Type
				--System--19000092, -- Storage Type
				--System--19000139, -- Surrounding
				--System--19000094, -- System Function
				--System--19000059, -- System Function Operation
				19000095, -- Test Category
				19000097, -- Test Name
				19000096, -- Test Result
				--System--19000001, -- Test Status
				19000098, -- Vaccination Route List
				19000099, -- Vaccination Type
				19000141, -- Vector sub type
				--System--19000133, -- Vector Surveillance Session Status
				19000140  -- Vector type
				--System--19000103, -- Vet Case Log Status
				--System--19000100, -- Yes/No Value List
			)
' +	
N'
			or	(	trtBaseReference_v6.idfsBaseReference = 10320001			-- Sample Type: Unknown
					or	(	trtBaseReference_v6.idfsReferenceType = 19000146	-- Age Groups
							and trtBaseReference_v6.blnSystem <> 1				-- WHO and CDC Groups
						)
					--will be processed separately--or	trtBaseReference_v6.idfsBaseReference <> 123800000000	-- Employee Group Name: Default
					or	trtBaseReference_v6.idfsBaseReference in
					-- Orgnaization full name or abbreviation: Disposition
						(	704130000000, 
							704140000000
						)
					or	trtBaseReference_v6.idfsBaseReference = 39850000000		-- Statistical Data Type: Population
					or	trtBaseReference_v6.idfsBaseReference = 39860000000		-- Statistical Data Type: Population by Age Groups or Gender
					or	trtBaseReference_v6.idfsBaseReference = 840900000000	-- Statistical Data Type: Population by Gender
					or	trtBaseReference_v6.idfsBaseReference in
						(	10071025,		-- Flexible Form Parameter Type: Boolean
							10071029,		-- Flexible Form Parameter Type: Date
							10071030,		-- Flexible Form Parameter Type: DateTime
							10071045,		-- Flexible Form Parameter Type: String
							10071059,		-- Flexible Form Parameter Type: Numeric Natural
							10071060,		-- Flexible Form Parameter Type: Numeric Positive
							10071061,		-- Flexible Form Parameter Type: Numeric Integer
							217140000000,	-- Flexible Form Parameter Type: Y_N_Unk
							216820000000,	-- Flexible Form Parameter Type: Diagnosis List
							216880000000,	-- Flexible Form Parameter Type: Investigation Type
							217020000000,	-- Flexible Form Parameter Type: Prophylactic Action
							217030000000,	-- Flexible Form Parameter Type: Sanitary Action
							217050000000	-- Flexible Form Parameter Type: Species
						)
					or	trtBaseReference_v6.idfsBaseReference in
						(	25460000000,	-- Flexible Form Parameter Value: Yes
							25640000000,	-- Flexible Form Parameter Value: No
							25660000000		-- Flexible Form Parameter Value: Unknown
						)
				)
		)
' collate Cyrillic_General_CI_AS



from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'trtBaseReference' collate Cyrillic_General_CI_AS

update	ttm
set		ttm.strUpdateAfterInsert = N'
update		tstSite_v7
set			tstSite_v7.idfsParentSite = tstSite_parent_v7.idfsSite
from		[Giraffe].[dbo].[tstSite] tstSite_v7
inner join	[Falcon].[dbo].[tstSite] tstSite_v6
on			tstSite_v6.idfsSite = tstSite_v7.idfsSite
inner join	[Giraffe].[dbo].[tstSite] tstSite_parent_v7
on			tstSite_parent_v7.idfsSite = tstSite_v6.idfsParentSite
where		tstSite_V7.idfsParentSite is null
print	N''Table [tstSite] - update link to the parent site from migrated sites: '' + cast(@@rowcount as nvarchar(20))

update		tstSite_v7
set			tstSite_v7.idfOffice = tlbOffice_v7.idfOffice
from		[Giraffe].[dbo].[tstSite] tstSite_v7
inner join	[Falcon].[dbo].[tstSite] tstSite_v6
on			tstSite_v6.idfsSite = tstSite_v7.idfsSite
inner join	[Giraffe].[dbo].[tlbOffice] tlbOffice_v7
on			tlbOffice_v7.idfOffice = tstSite_v6.idfOffice
where		tstSite_V7.idfOffice is null
print	N''Table [tstSite] - update link to organization: '' + cast(@@rowcount as nvarchar(20))

'
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tstSite' collate Cyrillic_General_CI_AS

		
update	ttm
set		ttm.strUpdateAfterInsert = N'
update		tstSecurityConfiguration_v7
set			tstSecurityConfiguration_v7.idfParentSecurityConfiguration = tstSecurityConfiguration_parent_v7.idfSecurityConfiguration
from		[Giraffe].[dbo].[tstSecurityConfiguration] tstSecurityConfiguration_v7
inner join	[Falcon].[dbo].[tstSecurityConfiguration] tstSecurityConfiguration_v6
on			tstSecurityConfiguration_v6.idfSecurityConfiguration = tstSecurityConfiguration_v7.idfSecurityConfiguration
inner join	[Giraffe].[dbo].[tstSecurityConfiguration] tstSecurityConfiguration_parent_v7
on			tstSecurityConfiguration_parent_v7.idfSecurityConfiguration = tstSecurityConfiguration_v6.idfParentSecurityConfiguration
where		tstSecurityConfiguration_V7.idfParentSecurityConfiguration is null
print	N''Table [tstSecurityConfiguration] - update link to the parent security configuration from migrated configurations: '' + cast(@@rowcount as nvarchar(20))

update		SecurityPolicyConfiguration_v7
set			SecurityPolicyConfiguration_v7.MinPasswordLength = 
				case
					when	tstSecurityConfiguration_v6.intPasswordMinimalLength >= 8
						then	tstSecurityConfiguration_v6.intPasswordMinimalLength
					when	(	tstSecurityConfiguration_v6.intPasswordMinimalLength is null
								or tstSecurityConfiguration_v6.intPasswordMinimalLength < 8
							)
							and SecurityPolicyConfiguration_v7.MinPasswordLength >= 8
						then	SecurityPolicyConfiguration_v7.MinPasswordLength
					else	8
				end,
			SecurityPolicyConfiguration_v7.MinPasswordAgeDays = 
				case
					when	tstSecurityConfiguration_v6.intPasswordAge <= 60
						then	tstSecurityConfiguration_v6.intPasswordAge
					when	(	tstSecurityConfiguration_v6.intPasswordAge is null
								or tstSecurityConfiguration_v6.intPasswordAge > 60
							)
							and SecurityPolicyConfiguration_v7.MinPasswordAgeDays <= 60
						then	SecurityPolicyConfiguration_v7.MinPasswordAgeDays
					else	60
				end,
			SecurityPolicyConfiguration_v7.LockoutThld = isnull(tstSecurityConfiguration_v6.intAccountTryCount, SecurityPolicyConfiguration_v7.LockoutThld)
from		[Giraffe].[dbo].[SecurityPolicyConfiguration] SecurityPolicyConfiguration_v7
inner join	[Falcon].[dbo].[tstSecurityConfiguration] tstSecurityConfiguration_v6
on			tstSecurityConfiguration_v6.idfSecurityConfiguration = 708190000000 /*Default Security Configuration in v6.1*/
where		SecurityPolicyConfiguration_v7.SecurityPolicyConfigurationUID = 1 /*Default Security Configuration in v7*/
print	N''Table [SecurityPolicyConfiguration] - update applicable settings from migrated default configuration: '' + cast(@@rowcount as nvarchar(20))

'
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tstSecurityConfiguration' collate Cyrillic_General_CI_AS

update	ttm
set		ttm.strInsertWhereConditions = ttm.strInsertWhereConditions + N'
	and exists (select 1 from [Falcon].[dbo].[tlbOffice] tlbOffice_v6 where tlbOffice_v6.[idfLocation] = tlbGeoLocationShared_v6.[idfGeoLocationShared])
' collate Cyrillic_General_CI_AS
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tlbGeoLocationShared' collate Cyrillic_General_CI_AS
		and not exists
				(	select	1
					from	#TablesToMigrate ttm_first
					where	ttm_first.[table_id_v7] = ttm.[table_id_v7]
							and ttm_first.idfId < ttm.idfId
				)



update	ttm
set		ttm.strStatementBeforeInsert = N'
if object_id(N''_dmccCustomUserGroup'') is null
create table _dmccCustomUserGroup
(	idfEmployeeGroup_v6	bigint not null primary key,
	idfsEmployeeGroupName_v6 bigint null,
	idfEmployeeGroup_v7 bigint not null,
	idfsEmployeeGroupName_v7 bigint null,
	intIncrement int not null default(0)
)


insert into [Giraffe].[dbo].[_dmccCustomUserGroup]
(	idfEmployeeGroup_v6,
	idfsEmployeeGroupName_v6,
	idfEmployeeGroup_v7,
	idfsEmployeeGroupName_v7

)
select		tlbEmployeeGroup_v6.idfEmployeeGroup,
			tlbEmployeeGroup_v6.idfsEmployeeGroupName,
			isnull(tlbEmployee_v7.idfEmployee, tlbEmployeeGroup_v6.idfEmployeeGroup),
			tlbEmployeeGroup_v7.idfsEmployeeGroupName
from		[Falcon].[dbo].[tlbEmployee] tlbEmployee_v6
inner join	[Falcon].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v6
on			tlbEmployeeGroup_v6.idfEmployeeGroup = tlbEmployee_v6.idfEmployee
left join	[Giraffe].[dbo].[tlbEmployee] tlbEmployee_v7
	inner join	[Giraffe].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v7
	on			tlbEmployeeGroup_v7.idfEmployeeGroup = tlbEmployee_v7.idfEmployee
on			tlbEmployee_v7.idfEmployee = tlbEmployee_v6.idfEmployee
			and tlbEmployee_v7.idfsEmployeeType = 10023001 /*User Group*/
left join	[Giraffe].[dbo].[_dmccCustomUserGroup] cug
on			cug.[idfEmployeeGroup_v6] = tlbEmployeeGroup_v6.idfEmployeeGroup
where		tlbEmployee_v6.idfsEmployeeType = 10023001 /*User Group*/
			and cug.[idfEmployeeGroup_v6] is null

update		cug
set			cug.intIncrement = id_increment.intValue
from		[Giraffe].[dbo].[_dmccCustomUserGroup] cug
cross apply
(	select	count(cug_count.idfEmployeeGroup_v6) as intValue
	from	[Giraffe].[dbo].[_dmccCustomUserGroup] cug_count
	where	cug_count.idfEmployeeGroup_v7 = cug_count.idfEmployeeGroup_v6
			and cug_count.idfEmployeeGroup_v7 >= 0
			and cug_count.idfEmployeeGroup_v6 <= cug.idfEmployeeGroup_v6
) id_increment
where		cug.idfEmployeeGroup_v7 = cug.idfEmployeeGroup_v6
			and cug.idfEmployeeGroup_v7 >= 0
' +
N'
declare	@MinGroupId bigint

select	@MinGroupId = min(tlbEmployeeGroup_v7.idfEmployeeGroup)
from	[Giraffe].[dbo].[tlbEmployee] tlbEmployee_v7
inner join	[Giraffe].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v7
on			tlbEmployeeGroup_v7.idfEmployeeGroup = tlbEmployee_v7.idfEmployee
where	tlbEmployee_v7.idfsEmployeeType = 10023001 /*User Group*/

if @MinGroupId is null or @MinGroupId > -512 /*Standard Group "Notifiers"*/
set	@MinGroupId = -512 /*Standard Group "Notifiers"*/

update		cug
set			cug.idfEmployeeGroup_v7 = @MinGroupId - cug.intIncrement,
			cug.idfsEmployeeGroupName_v7 =
				case
					when	cug.idfsEmployeeGroupName_v7 is null
						then	@MinGroupId - cug.intIncrement
					else	cug.idfsEmployeeGroupName_v7
				end
from		[Giraffe].[dbo].[_dmccCustomUserGroup] cug
where		cug.idfEmployeeGroup_v7 = cug.idfEmployeeGroup_v6
			and cug.idfEmployeeGroup_v7 >= 0

/************************************************************
* Insert records - Names of user-defined (custom) user groups - start
************************************************************/
print N''''
print N''Insert records - Names of user-defined (custom) user groups - start''
print N''''
',
		ttm.strStatementBeforeInsert2 = N'
/************************************************************
* Insert records - [trtBaseReference]
************************************************************/
insert into [Giraffe].[dbo].[trtBaseReference] 

(					  [idfsBaseReference]
					, [idfsReferenceType]
					, [strBaseReferenceCode]
					, [strDefault]
					, [intHACode]
					, [intOrder]
					, [blnSystem]
					, [intRowStatus]
					, [rowguid]
					, [strMaintenanceFlag]
					, [strReservedAttribute]
					, [SourceSystemNameID]
					, [SourceSystemKeyValue]
					, [AuditCreateUser]
					, [AuditCreateDTM]
					, [AuditUpdateUser]
					, [AuditUpdateDTM]
)
select distinct		  cug.idfsEmployeeGroupName_v7
					, 19000022 /*Employee Group Name*/
					,  @CountryPrefix + replace(replace(replace(replace(replace(replace(isnull(trtBaseReference_v6.[strDefault], N''''), N'' '', N''''), N''('', N''''), N'')'', N''''), N'''''''', N''''), N''№'', N''N''), N''"'', N'''')
					, trtBaseReference_v6.[strDefault]
					, trtBaseReference_v6.[intHACode]
					, trtBaseReference_v6.[intOrder]
					, trtBaseReference_v6.[blnSystem]
					, trtBaseReference_v6.[intRowStatus]
					, trtBaseReference_v6.[rowguid]
					, trtBaseReference_v6.[strMaintenanceFlag]
					, trtBaseReference_v6.[strReservedAttribute]
					, 10519002 /*Record Source: EIDSS6.1*/
					, N''[{'' + N''"idfsBaseReference":'' + isnull(cast(cug.idfsEmployeeGroupName_v7 as nvarchar(20)), N''null'') + N''}]'' collate Cyrillic_General_CI_AS
					, N''system''
					, GETUTCDATE()
					, N''system''
					, GETUTCDATE()

from		[Falcon].[dbo].[tlbEmployee] tlbEmployee_v6
inner join	[Falcon].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v6
on			tlbEmployeeGroup_v6.idfEmployeeGroup = tlbEmployee_v6.idfEmployee
inner join	[Giraffe].[dbo].[_dmccCustomUserGroup] cug
on			cug.idfEmployeeGroup_v6 = tlbEmployeeGroup_v6.idfEmployeeGroup
inner join	[Falcon].[dbo].[trtBaseReference] trtBaseReference_v6
on			trtBaseReference_v6.idfsBaseReference = tlbEmployeeGroup_v6.idfsEmployeeGroupName
left join	[Giraffe].[dbo].[trtBaseReference] trtBaseReference_v7 
on			trtBaseReference_v7.[idfsBaseReference] = cug.idfsEmployeeGroupName_v7
where		tlbEmployee_v6.idfsEmployeeType = 10023001 /*User Group*/
			and cug.idfsEmployeeGroupName_v7 is not null
			and trtBaseReference_v7.[idfsBaseReference] is null 
print N''Table [trtBaseReference] - insert: '' + cast(@@rowcount as nvarchar(20))
',
		ttm.strStatementBeforeInsert3 = N'

/************************************************************
* Insert records - [trtStringNameTranslation]
************************************************************/
insert into [Giraffe].[dbo].[trtStringNameTranslation] 

(					  [idfsBaseReference]
					, [idfsLanguage]
					, [strTextString]
					, [intRowStatus]
					, [rowguid]
					, [strMaintenanceFlag]
					, [strReservedAttribute]
					, [SourceSystemNameID]
					, [SourceSystemKeyValue]
					, [AuditCreateUser]
					, [AuditCreateDTM]
					, [AuditUpdateUser]
					, [AuditUpdateDTM]
)
select distinct		  cug.idfsEmployeeGroupName_v7
					, j_trtBaseReference_idfsLanguage_v7.[idfsBaseReference]
					, trtStringNameTranslation_v6.[strTextString]
					, trtStringNameTranslation_v6.[intRowStatus]
					, trtStringNameTranslation_v6.[rowguid]
					, trtStringNameTranslation_v6.[strMaintenanceFlag]
					, trtStringNameTranslation_v6.[strReservedAttribute]
					, 10519002 /*Record Source: EIDSS6.1*/
					, N''[{'' + N''"idfsBaseReference":'' + isnull(cast(cug.idfsEmployeeGroupName_v7 as nvarchar(20)), N''null'') + N'','' + N''"idfsLanguage":'' + isnull(cast(trtStringNameTranslation_v6.[idfsLanguage] as nvarchar(20)), N''null'') + N''}]'' collate Cyrillic_General_CI_AS
					, N''system''
					, GETUTCDATE()
					, N''system''
					, GETUTCDATE()

from		[Falcon].[dbo].[tlbEmployee] tlbEmployee_v6
inner join	[Falcon].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v6
on			tlbEmployeeGroup_v6.idfEmployeeGroup = tlbEmployee_v6.idfEmployee
inner join	[Giraffe].[dbo].[_dmccCustomUserGroup] cug
on			cug.idfEmployeeGroup_v6 = tlbEmployeeGroup_v6.idfEmployeeGroup
inner join	[Falcon].[dbo].[trtBaseReference] trtBaseReference_v6
on			trtBaseReference_v6.idfsBaseReference = tlbEmployeeGroup_v6.idfsEmployeeGroupName
inner join	[Falcon].[dbo].[trtStringNameTranslation] trtStringNameTranslation_v6
on			trtStringNameTranslation_v6.idfsBaseReference = tlbEmployeeGroup_v6.idfsEmployeeGroupName
' +
N'
inner join	[Giraffe].[dbo].[trtBaseReference] trtBaseReference_v7 
on			trtBaseReference_v7.[idfsBaseReference] = cug.idfsEmployeeGroupName_v7
inner join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsLanguage_v7
on			j_trtBaseReference_idfsLanguage_v7.[idfsBaseReference] = trtStringNameTranslation_v6.[idfsLanguage] 

left join	[Giraffe].[dbo].[trtStringNameTranslation] trtStringNameTranslation_v7 
on			trtStringNameTranslation_v7.[idfsBaseReference] = cug.idfsEmployeeGroupName_v7 
			and trtStringNameTranslation_v7.[idfsLanguage] = trtStringNameTranslation_v6.[idfsLanguage] 

where		tlbEmployee_v6.idfsEmployeeType = 10023001 /*User Group*/
			and cug.idfsEmployeeGroupName_v7 is not null
			and trtStringNameTranslation_v7.[idfsBaseReference] is null 
print N''Table [trtStringNameTranslation] - insert: '' + cast(@@rowcount as nvarchar(20))


print N''''
print N''Insert records - Names of user-defined (custom) user groups - end''
print N''''
print N''''
/************************************************************
* Insert records - Names of user-defined (custom) user groups - end
************************************************************/

' collate Cyrillic_General_CI_AS,
		ttm.strInsertFromHeader = replace(replace(ttm.strInsertFromHeader, 
			N'from [Falcon].[dbo].[tlbEmployee] tlbEmployee_v6', 
			N'from [Falcon].[dbo].[tlbEmployee] tlbEmployee_v6
left join	[Giraffe].[dbo].[_dmccCustomUserGroup] cug
on			cug.idfEmployeeGroup_v6 = tlbEmployee_v6.idfEmployee
outer apply
(	select	top 1 ut_sysadm_v6.[idfUserID], ut_sysadm_v6.[idfPerson]
	from	[Falcon].[dbo].[tstUserTable] ut_sysadm_v6
	join	[Falcon].[dbo].[tlbPerson] p_sysadm_v6
	on		p_sysadm_v6.[idfPerson] = ut_sysadm_v6.[idfPerson]
			and p_sysadm_v6.[strFamilyName] like N''% Administrator'' collate Cyrillic_General_CI_AS
	where	ut_sysadm_v6.[idfPerson] = tlbEmployee_v6.[idfEmployee]
			and ut_sysadm_v6.[strAccountName] like N''% Administrator'' collate Cyrillic_General_CI_AS
) sysadm_v6'), 
				N'tlbEmployee_v7.[idfEmployee] = tlbEmployee_v6.[idfEmployee]', 
				N'tlbEmployee_v7.[idfEmployee] = isnull(cug.idfEmployeeGroup_v7, tlbEmployee_v6.[idfEmployee])'),
		ttm.strInsertFromJoins = replace(ttm.strInsertFromJoins,
			N'tlbEmployee_v7.[idfEmployee] = tlbEmployee_v6.[idfEmployee]', 
			N'tlbEmployee_v7.[idfEmployee] = isnull(cug.idfEmployeeGroup_v7, tlbEmployee_v6.[idfEmployee])'),
		ttm.strSelectColumns = replace(replace(ttm.strSelectColumns, 
			N'tlbEmployee_v6.[idfEmployee]', 
			N'isnull(cug.idfEmployeeGroup_v7, tlbEmployee_v6.[idfEmployee])'),
				N'tlbEmployee_v6.[intRowStatus]',
				N'case when sysadm_v6.[idfUserID] is not null then 1 else tlbEmployee_v6.[intRowStatus] end'),
		ttm.strUpdateFromHeader = replace(replace(ttm.strUpdateFromHeader, 
			N'inner join	[Falcon].[dbo].[tlbEmployee] tlbEmployee_v6', 
			N'inner join	[Falcon].[dbo].[tlbEmployee] tlbEmployee_v6
	left join	[Giraffe].[dbo].[_dmccCustomUserGroup] cug
	on			cug.idfEmployeeGroup_v6 = tlbEmployee_v6.idfEmployee
	outer apply
	(	select	top 1 ut_sysadm_v6.[idfUserID], ut_sysadm_v6.[idfPerson]
		from	[Falcon].[dbo].[tstUserTable] ut_sysadm_v6
		join	[Falcon].[dbo].[tlbPerson] p_sysadm_v6
		on		p_sysadm_v6.[idfPerson] = ut_sysadm_v6.[idfPerson]
				and p_sysadm_v6.[strFamilyName] like N''% Administrator'' collate Cyrillic_General_CI_AS
		where	ut_sysadm_v6.[idfPerson] = tlbEmployee_v6.[idfEmployee]
				and ut_sysadm_v6.[strAccountName] like N''% Administrator'' collate Cyrillic_General_CI_AS
	) sysadm_v6'), 
				N'tlbEmployee_v7.[idfEmployee] = tlbEmployee_v6.[idfEmployee]', 
				N'tlbEmployee_v7.[idfEmployee] = isnull(cug.idfEmployeeGroup_v7, tlbEmployee_v6.[idfEmployee])'),
		ttm.strUpdateFromJoins = replace(ttm.strUpdateFromJoins,
			N'tlbEmployee_v7.[idfEmployee] = tlbEmployee_v6.[idfEmployee]', 
			N'tlbEmployee_v7.[idfEmployee] = isnull(cug.idfEmployeeGroup_v7, tlbEmployee_v6.[idfEmployee])'),
		ttm.strUpdateColumns = replace(ttm.strUpdateColumns,
			N'[intRowStatus] = tlbEmployee_v6.[intRowStatus]',
			N'[intRowStatus] = case when sysadm_v6.[idfUserID] is not null then 1 else tlbEmployee_v6.[intRowStatus] end'),
		ttm.strStatementBeforeUpdate = N'
if object_id(N''_dmccCustomUserGroup'') is null
create table _dmccCustomUserGroup
(	idfEmployeeGroup_v6	bigint not null primary key,
	idfsEmployeeGroupName_v6 bigint null,
	idfEmployeeGroup_v7 bigint not null,
	idfsEmployeeGroupName_v7 bigint null,
	intIncrement int not null default(0)
)


insert into [Giraffe].[dbo].[_dmccCustomUserGroup]
(	idfEmployeeGroup_v6,
	idfsEmployeeGroupName_v6,
	idfEmployeeGroup_v7,
	idfsEmployeeGroupName_v7

)
select		tlbEmployeeGroup_v6.idfEmployeeGroup,
			tlbEmployeeGroup_v6.idfsEmployeeGroupName,
			isnull(tlbEmployee_v7.idfEmployee, tlbEmployeeGroup_v6.idfEmployeeGroup),
			tlbEmployeeGroup_v7.idfsEmployeeGroupName
from		[Falcon].[dbo].[tlbEmployee] tlbEmployee_v6
inner join	[Falcon].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v6
on			tlbEmployeeGroup_v6.idfEmployeeGroup = tlbEmployee_v6.idfEmployee
left join	[Giraffe].[dbo].[tlbEmployee] tlbEmployee_v7
	inner join	[Giraffe].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v7
	on			tlbEmployeeGroup_v7.idfEmployeeGroup = tlbEmployee_v7.idfEmployee
on			tlbEmployee_v7.idfEmployee = tlbEmployee_v6.idfEmployee
			and tlbEmployee_v7.idfsEmployeeType = 10023001 /*User Group*/
left join	[Giraffe].[dbo].[_dmccCustomUserGroup] cug
on			cug.[idfEmployeeGroup_v6] = tlbEmployeeGroup_v6.idfEmployeeGroup
where		tlbEmployee_v6.idfsEmployeeType = 10023001 /*User Group*/
			and cug.[idfEmployeeGroup_v6] is null

update		cug
set			cug.intIncrement = id_increment.intValue
from		[Giraffe].[dbo].[_dmccCustomUserGroup] cug
cross apply
(	select	count(cug_count.idfEmployeeGroup_v6) as intValue
	from	[Giraffe].[dbo].[_dmccCustomUserGroup] cug_count
	where	cug_count.idfEmployeeGroup_v7 = cug_count.idfEmployeeGroup_v6
			and cug_count.idfEmployeeGroup_v7 >= 0
			and cug_count.idfEmployeeGroup_v6 <= cug.idfEmployeeGroup_v6
) id_increment
where		cug.idfEmployeeGroup_v7 = cug.idfEmployeeGroup_v6
			and cug.idfEmployeeGroup_v7 >= 0
' +
N'
declare	@MinGroupId bigint

select	@MinGroupId = min(tlbEmployeeGroup_v7.idfEmployeeGroup)
from	[Giraffe].[dbo].[tlbEmployee] tlbEmployee_v7
inner join	[Giraffe].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v7
on			tlbEmployeeGroup_v7.idfEmployeeGroup = tlbEmployee_v7.idfEmployee
where	tlbEmployee_v7.idfsEmployeeType = 10023001 /*User Group*/

if @MinGroupId is null or @MinGroupId > -512 /*Standard Group "Notifiers"*/
set	@MinGroupId = -512 /*Standard Group "Notifiers"*/

update		cug
set			cug.idfEmployeeGroup_v7 = @MinGroupId - cug.intIncrement,
			cug.idfsEmployeeGroupName_v7 =
				case
					when	cug.idfsEmployeeGroupName_v7 is null
						then	@MinGroupId - cug.intIncrement
					else	cug.idfsEmployeeGroupName_v7
				end
from		[Giraffe].[dbo].[_dmccCustomUserGroup] cug
where		cug.idfEmployeeGroup_v7 = cug.idfEmployeeGroup_v6
			and cug.idfEmployeeGroup_v7 >= 0

/************************************************************
* Update records - Names of user-defined (custom) user groups - start
************************************************************/
print N''''
print N''Update records - Names of user-defined (custom) user groups - start''
print N''''
',
		ttm.strStatementBeforeUpdate2 = N'
/************************************************************
* Update records - [trtBaseReference]
************************************************************/

update				trtBaseReference_v7
set					  [idfsReferenceType] = 19000022 /*Employee Group Name*/
					, [strDefault] = trtBaseReference_v6.[strDefault]
					, [intHACode] = trtBaseReference_v6.[intHACode]
					, [intOrder] = trtBaseReference_v6.[intOrder]
					, [blnSystem] = trtBaseReference_v6.[blnSystem]
					, [intRowStatus] = trtBaseReference_v6.[intRowStatus]
					, [SourceSystemNameID] = 10519002 /*Record Source: EIDSS6.1*/
					, [SourceSystemKeyValue] = N''[{'' + N''"idfsBaseReference":'' + isnull(cast(trtBaseReference_v7.[idfsBaseReference] as nvarchar(20)), N''null'') + N''}]'' collate Cyrillic_General_CI_AS
					, [AuditUpdateUser] = N''system''
					, [AuditUpdateDTM] = GETUTCDATE()

from		[Falcon].[dbo].[tlbEmployee] tlbEmployee_v6
inner join	[Falcon].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v6
on			tlbEmployeeGroup_v6.idfEmployeeGroup = tlbEmployee_v6.idfEmployee
inner join	[Giraffe].[dbo].[_dmccCustomUserGroup] cug
on			cug.idfEmployeeGroup_v6 = tlbEmployeeGroup_v6.idfEmployeeGroup
inner join	[Falcon].[dbo].[trtBaseReference] trtBaseReference_v6
on			trtBaseReference_v6.idfsBaseReference = tlbEmployeeGroup_v6.idfsEmployeeGroupName
inner join	[Giraffe].[dbo].[trtBaseReference] trtBaseReference_v7 
on			trtBaseReference_v7.[idfsBaseReference] = cug.idfsEmployeeGroupName_v7
where		tlbEmployee_v6.idfsEmployeeType = 10023001 /*User Group*/
print N''Table [trtBaseReference] - update: '' + cast(@@rowcount as nvarchar(20))
',
		ttm.strStatementBeforeUpdate3 = N'

/************************************************************
* Update records - [trtStringNameTranslation]
************************************************************/
update				 trtStringNameTranslation_v7
set					  [strTextString] = trtStringNameTranslation_v6.[strTextString]
					, [intRowStatus] = trtStringNameTranslation_v6.[intRowStatus]
					, [SourceSystemNameID] = 10519002 /*Record Source: EIDSS6.1*/
					, [SourceSystemKeyValue] = N''[{'' + N''"idfsBaseReference":'' + isnull(cast(trtStringNameTranslation_v7.[idfsBaseReference] as nvarchar(20)), N''null'') + N'','' + N''"idfsLanguage":'' + isnull(cast(trtStringNameTranslation_v7.[idfsLanguage] as nvarchar(20)), N''null'') + N''}]'' collate Cyrillic_General_CI_AS
					, [AuditUpdateUser] =  N''system''
					, [AuditUpdateDTM] = GETUTCDATE()

from		[Falcon].[dbo].[tlbEmployee] tlbEmployee_v6
inner join	[Falcon].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v6
on			tlbEmployeeGroup_v6.idfEmployeeGroup = tlbEmployee_v6.idfEmployee
inner join	[Giraffe].[dbo].[_dmccCustomUserGroup] cug
on			cug.idfEmployeeGroup_v6 = tlbEmployeeGroup_v6.idfEmployeeGroup
inner join	[Falcon].[dbo].[trtBaseReference] trtBaseReference_v6
on			trtBaseReference_v6.idfsBaseReference = tlbEmployeeGroup_v6.idfsEmployeeGroupName
inner join	[Falcon].[dbo].[trtStringNameTranslation] trtStringNameTranslation_v6
on			trtStringNameTranslation_v6.idfsBaseReference = tlbEmployeeGroup_v6.idfsEmployeeGroupName

inner join	[Giraffe].[dbo].[trtBaseReference] trtBaseReference_v7 
on			trtBaseReference_v7.[idfsBaseReference] = cug.idfsEmployeeGroupName_v7
inner join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsLanguage_v7
on			j_trtBaseReference_idfsLanguage_v7.[idfsBaseReference] = trtStringNameTranslation_v6.[idfsLanguage] 

inner join	[Giraffe].[dbo].[trtStringNameTranslation] trtStringNameTranslation_v7 
on			trtStringNameTranslation_v7.[idfsBaseReference] = cug.idfsEmployeeGroupName_v7 
			and trtStringNameTranslation_v7.[idfsLanguage] = trtStringNameTranslation_v6.[idfsLanguage] 

where		tlbEmployee_v6.idfsEmployeeType = 10023001 /*User Group*/
print N''Table [trtStringNameTranslation] - update: '' + cast(@@rowcount as nvarchar(20))


print N''''
print N''Update records - Names of user-defined (custom) user groups - end''
print N''''
print N''''
/************************************************************
* Update records - Names of user-defined (custom) user groups - end
************************************************************/

' collate Cyrillic_General_CI_AS

from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tlbEmployee' collate Cyrillic_General_CI_AS


update	ttm
set		ttm.strInsertFromHeader = replace(replace(ttm.strInsertFromHeader, 
			N'from [Falcon].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v6', 
			N'from [Falcon].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v6
left join	[Giraffe].[dbo].[_dmccCustomUserGroup] cug
on			cug.idfEmployeeGroup_v6 = tlbEmployeeGroup_v6.idfEmployeeGroup'), 
				N'tlbEmployeeGroup_v7.[idfEmployeeGroup] = tlbEmployeeGroup_v6.[idfEmployeeGroup]', 
				N'tlbEmployeeGroup_v7.[idfEmployeeGroup] = isnull(cug.idfEmployeeGroup_v7, tlbEmployeeGroup_v6.[idfEmployeeGroup])'),
		ttm.strInsertFromJoins = replace(replace(replace(ttm.strInsertFromJoins, 
			N'tlbEmployeeGroup_v7.[idfEmployeeGroup] = tlbEmployeeGroup_v6.[idfEmployeeGroup]', 
			N'tlbEmployeeGroup_v7.[idfEmployeeGroup] = isnull(cug.idfEmployeeGroup_v7, tlbEmployeeGroup_v6.[idfEmployeeGroup])'),
				N'j_trtBaseReference_idfsEmployeeGroupName_v7.[idfsBaseReference] = tlbEmployeeGroup_v6.[idfsEmployeeGroupName]',
				N'j_trtBaseReference_idfsEmployeeGroupName_v7.[idfsBaseReference] = isnull(cug.idfsEmployeeGroupName_v7, tlbEmployeeGroup_v6.[idfsEmployeeGroupName])'),
					N'j_tlbEmployee_idfEmployeeGroup_v7.[idfEmployee] = tlbEmployeeGroup_v6.[idfEmployeeGroup]',
					N'j_tlbEmployee_idfEmployeeGroup_v7.[idfEmployee] = isnull(cug.idfsEmployeeGroupName_v7, tlbEmployeeGroup_v6.[idfsEmployeeGroupName])'),
		ttm.strSelectColumns = replace(ttm.strSelectColumns, 
			N'tlbEmployeeGroup_v6.[idfEmployeeGroup]', 
			N'isnull(cug.idfEmployeeGroup_v7, tlbEmployeeGroup_v6.[idfEmployeeGroup])'),
		ttm.strUpdateFromHeader = replace(replace(ttm.strUpdateFromHeader, 
			N'inner join	[Falcon].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v6', 
			N'inner join	[Falcon].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v6
	left join	[Giraffe].[dbo].[_dmccCustomUserGroup] cug
	on			cug.idfEmployeeGroup_v6 = tlbEmployeeGroup_v6.idfEmployeeGroup'), 
				N'tlbEmployeeGroup_v7.[idfEmployeeGroup] = tlbEmployeeGroup_v6.[idfEmployeeGroup]', 
				N'tlbEmployeeGroup_v7.[idfEmployeeGroup] = isnull(cug.idfEmployeeGroup_v7, tlbEmployeeGroup_v6.[idfEmployeeGroup])'),
		ttm.strUpdateFromJoins = replace(replace(replace(ttm.strUpdateFromJoins, 
			N'tlbEmployeeGroup_v7.[idfEmployeeGroup] = tlbEmployeeGroup_v6.[idfEmployeeGroup]', 
			N'tlbEmployeeGroup_v7.[idfEmployeeGroup] = isnull(cug.idfEmployeeGroup_v7, tlbEmployeeGroup_v6.[idfEmployeeGroup])'),
				N'j_trtBaseReference_idfsEmployeeGroupName_v7.[idfsBaseReference] = tlbEmployeeGroup_v6.[idfsEmployeeGroupName]',
				N'j_trtBaseReference_idfsEmployeeGroupName_v7.[idfsBaseReference] = isnull(cug.idfsEmployeeGroupName_v7, tlbEmployeeGroup_v6.[idfsEmployeeGroupName])'),
					N'j_tlbEmployee_idfEmployeeGroup_v7.[idfEmployee] = tlbEmployeeGroup_v6.[idfEmployeeGroup]',
					N'j_tlbEmployee_idfEmployeeGroup_v7.[idfEmployee] = isnull(cug.idfsEmployeeGroupName_v7, tlbEmployeeGroup_v6.[idfsEmployeeGroupName])')
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tlbEmployeeGroup' collate Cyrillic_General_CI_AS


update	ttm
set		ttm.strInsertFromHeader = replace(ttm.strInsertFromHeader, 
			N'from [Falcon].[dbo].[tlbPerson] tlbPerson_v6', 
			N'from [Falcon].[dbo].[tlbPerson] tlbPerson_v6
outer apply
(	select	top 1 ut_sysadm_v6.[idfUserID], ut_sysadm_v6.[idfPerson]
	from	[Falcon].[dbo].[tstUserTable] ut_sysadm_v6
	where	ut_sysadm_v6.[idfPerson] = tlbPerson_v6.[idfPerson]
			and tlbPerson_v6.[strFamilyName] like N''% Administrator'' collate Cyrillic_General_CI_AS
			and ut_sysadm_v6.[strAccountName] like N''% Administrator'' collate Cyrillic_General_CI_AS
) sysadm_v6
left join	[Giraffe].[dbo].[trtBaseReference] pIdType_v7
on			pIdType_v7.[idfsBaseReference] = 51577280000000 /*Unknown Personal ID Type*/
'),
		ttm.strSelectColumns = replace(ttm.strSelectColumns, 
			N'tlbPerson_v6.[intRowStatus]',
			N'case when sysadm_v6.[idfUserID] is not null then 1 else tlbPerson_v6.[intRowStatus] end'),
		ttm.strUpdateFromHeader = replace(ttm.strUpdateFromHeader, 
			N'inner join	[Falcon].[dbo].[tlbPerson] tlbPerson_v6', 
			N'inner join	[Falcon].[dbo].[tlbPerson] tlbPerson_v6
	outer apply
	(	select	top 1 ut_sysadm_v6.[idfUserID], ut_sysadm_v6.[idfPerson]
		from	[Falcon].[dbo].[tstUserTable] ut_sysadm_v6
		where	ut_sysadm_v6.[idfPerson] = tlbPerson_v6.[idfPerson]
				and tlbPerson_v6.[strFamilyName] like N''% Administrator'' collate Cyrillic_General_CI_AS
				and ut_sysadm_v6.[strAccountName] like N''% Administrator'' collate Cyrillic_General_CI_AS
	) sysadm_v6'),
		ttm.strUpdateColumns = replace(ttm.strUpdateColumns,
			N'[intRowStatus] = tlbPerson_v6.[intRowStatus]',
			N'[intRowStatus] = case when sysadm_v6.[idfUserID] is not null then 1 else tlbPerson_v6.[intRowStatus] end')
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tlbPerson' collate Cyrillic_General_CI_AS




update	ttm
set		ttm.strInsertFromHeader = replace(replace(replace(ttm.strInsertFromHeader, 
			N'from [Falcon].[dbo].[tlbEmployeeGroupMember] tlbEmployeeGroupMember_v6', 
			N'from [Falcon].[dbo].[tlbEmployeeGroupMember] tlbEmployeeGroupMember_v6
left join	[Giraffe].[dbo].[_dmccCustomUserGroup] cug_Parent
on			cug_Parent.idfEmployeeGroup_v6 = tlbEmployeeGroupMember_v6.idfEmployeeGroup
left join	[Giraffe].[dbo].[_dmccCustomUserGroup] cug_Child
on			cug_Child.idfEmployeeGroup_v6 = tlbEmployeeGroupMember_v6.idfEmployee'), 
				N'tlbEmployeeGroupMember_v7.[idfEmployeeGroup] = tlbEmployeeGroupMember_v6.[idfEmployeeGroup]', 
				N'tlbEmployeeGroupMember_v7.[idfEmployeeGroup] = isnull(cug_Parent.idfEmployeeGroup_v7, tlbEmployeeGroupMember_v6.[idfEmployeeGroup])'), 
					N'tlbEmployeeGroupMember_v7.[idfEmployee] = tlbEmployeeGroupMember_v6.[idfEmployee]', 
					N'tlbEmployeeGroupMember_v7.[idfEmployee] = isnull(cug_Child.idfEmployeeGroup_v7,  tlbEmployeeGroupMember_v6.[idfEmployee])'),
		ttm.strInsertFromJoins = replace(replace(replace(replace(ttm.strInsertFromJoins, 
			N'tlbEmployeeGroupMember_v7.[idfEmployeeGroup] = tlbEmployeeGroupMember_v6.[idfEmployeeGroup]', 
			N'tlbEmployeeGroupMember_v7.[idfEmployeeGroup] = isnull(cug_Parent.idfEmployeeGroup_v7, tlbEmployeeGroupMember_v6.[idfEmployeeGroup])'), 
				N'tlbEmployeeGroupMember_v7.[idfEmployee] = tlbEmployeeGroupMember_v6.[idfEmployee]', 
				N'tlbEmployeeGroupMember_v7.[idfEmployee] = isnull(cug_Child.idfEmployeeGroup_v7,  tlbEmployeeGroupMember_v6.[idfEmployee])'), 
					N'j_tlbEmployeeGroup_idfEmployeeGroup_v7.[idfEmployeeGroup] = tlbEmployeeGroupMember_v6.[idfEmployeeGroup]', 
					N'j_tlbEmployeeGroup_idfEmployeeGroup_v7.[idfEmployeeGroup] = isnull(cug_Parent.idfEmployeeGroup_v7, tlbEmployeeGroupMember_v6.[idfEmployeeGroup])'), 
						N'j_tlbEmployee_idfEmployee_v7.[idfEmployee] = tlbEmployeeGroupMember_v6.[idfEmployee]', 
						N'j_tlbEmployee_idfEmployee_v7.[idfEmployee] = isnull(cug_Child.idfEmployeeGroup_v7,  tlbEmployeeGroupMember_v6.[idfEmployee])'),
		ttm.strSelectColumns = replace(replace(ttm.strSelectColumns, 
			N'tlbEmployeeGroupMember_v6.[idfEmployeeGroup]', 
			N'isnull(cug_Parent.idfEmployeeGroup_v7, tlbEmployeeGroupMember_v6.[idfEmployeeGroup])'),
				N'tlbEmployeeGroupMember_v6.[idfEmployee]',
				N'isnull(cug_Child.idfEmployeeGroup_v7,  tlbEmployeeGroupMember_v6.[idfEmployee])'),
		ttm.strUpdateFromHeader = replace(replace(ttm.strUpdateFromHeader, 
			N'inner join	[Falcon].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v6', 
			N'inner join	[Falcon].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v6
	left join	[Giraffe].[dbo].[_dmccCustomUserGroup] cug
	on			cug.idfEmployeeGroup_v6 = tlbEmployeeGroup_v6.idfEmployeeGroup'), 
				N'tlbEmployeeGroup_v7.[idfEmployeeGroup] = tlbEmployeeGroup_v6.[idfEmployeeGroup]', 
				N'tlbEmployeeGroup_v7.[idfEmployeeGroup] = isnull(cug.idfEmployeeGroup_v7, tlbEmployeeGroup_v6.[idfEmployeeGroup])'),
		ttm.strUpdateFromJoins = replace(replace(replace(replace(ttm.strUpdateFromJoins, 
			N'tlbEmployeeGroupMember_v7.[idfEmployeeGroup] = tlbEmployeeGroupMember_v6.[idfEmployeeGroup]', 
			N'tlbEmployeeGroupMember_v7.[idfEmployeeGroup] = isnull(cug_Parent.idfEmployeeGroup_v7, tlbEmployeeGroupMember_v6.[idfEmployeeGroup])'), 
				N'tlbEmployeeGroupMember_v7.[idfEmployee] = tlbEmployeeGroupMember_v6.[idfEmployee]', 
				N'tlbEmployeeGroupMember_v7.[idfEmployee] = isnull(cug_Child.idfEmployeeGroup_v7,  tlbEmployeeGroupMember_v6.[idfEmployee])'), 
					N'j_tlbEmployeeGroup_idfEmployeeGroup_v7.[idfEmployeeGroup] = tlbEmployeeGroupMember_v6.[idfEmployeeGroup]', 
					N'j_tlbEmployeeGroup_idfEmployeeGroup_v7.[idfEmployeeGroup] = isnull(cug_Parent.idfEmployeeGroup_v7, tlbEmployeeGroupMember_v6.[idfEmployeeGroup])'), 
						N'j_tlbEmployee_idfEmployee_v7.[idfEmployee] = tlbEmployeeGroupMember_v6.[idfEmployee]', 
						N'j_tlbEmployee_idfEmployee_v7.[idfEmployee] = isnull(cug_Child.idfEmployeeGroup_v7,  tlbEmployeeGroupMember_v6.[idfEmployee])')
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tlbEmployeeGroupMember' collate Cyrillic_General_CI_AS



update	ttm
set		ttm.strSelectColumns = replace(replace(replace(replace(replace(replace(ttm.strSelectColumns, 
			N'tstUserTable_v6.[intRowStatus]',
			N'case when j_tlbPerson_idfPerson_v7.[strFamilyName] like N''% Administrator'' collate Cyrillic_General_CI_AS and tstUserTable_v6.[strAccountName] like N''% Administrator'' collate Cyrillic_General_CI_AS then 1 else tstUserTable_v6.[intRowStatus] end'),
				N'tstUserTable_v6.[datTryDate]',
				N'null'),
					N'tstUserTable_v6.[intTry]',
					N'null'), 
						N'tstUserTable_v6.[blnDisabled]',
						N'case when j_tlbPerson_idfPerson_v7.[strFamilyName] like N''% Administrator'' collate Cyrillic_General_CI_AS and tstUserTable_v6.[strAccountName] like N''% Administrator'' collate Cyrillic_General_CI_AS then 1 else tstUserTable_v6.[blnDisabled] end'),
							N'tstUserTable_v6.[binPassword]',
							N'HASHBYTES(N''SHA1'', cast(@NewTempPassword as nvarchar(500)))'),
								N'tstUserTable_v6.[datPasswordSet]',
								N'GETUTCDATE()'),
		ttm.strUpdateColumns = replace(replace(ttm.strUpdateColumns,
			N'tstUserTable_v6.[intRowStatus]',
			N'case when j_tlbPerson_idfPerson_v7.[strFamilyName] like N''% Administrator'' collate Cyrillic_General_CI_AS and tstUserTable_v6.[strAccountName] like N''% Administrator'' collate Cyrillic_General_CI_AS then 1 else tstUserTable_v6.[intRowStatus] end'), 
				N'tstUserTable_v6.[blnDisabled]',
				N'case when j_tlbPerson_idfPerson_v7.[strFamilyName] like N''% Administrator'' collate Cyrillic_General_CI_AS and tstUserTable_v6.[strAccountName] like N''% Administrator'' collate Cyrillic_General_CI_AS then 1 else tstUserTable_v6.[blnDisabled] end')
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tstUserTable' collate Cyrillic_General_CI_AS




update	ttm
set		ttm.strInsertFromHeader = replace(ttm.strInsertFromHeader, 
			N'from [Falcon].[dbo].[tstObjectAccess] tstObjectAccess_v6', 
			N'from [Falcon].[dbo].[tstObjectAccess] tstObjectAccess_v6
left join	[Giraffe].[dbo].[_dmccCustomUserGroup] cug
on			cug.idfEmployeeGroup_v6 = tstObjectAccess_v6.[idfActor]
left join	[Giraffe].[dbo].trtDiagnosis trtDiagnosis_v7_PermissionTo
on			trtDiagnosis_v7_PermissionTo.[idfsDiagnosis] = tstObjectAccess_v6.[idfsObjectID]
			and tstObjectAccess_v6.[idfsObjectType] = 10060001 /*Diagnosis*/
left join	[Giraffe].[dbo].tstSite tstSite_v7_PermissionTo
on			tstSite_v7_PermissionTo.[idfsSite] = tstObjectAccess_v6.[idfsObjectID]
			and tstObjectAccess_v6.[idfsObjectType] = 10060011 /*Site*/'),
		ttm.strInsertFromJoins = replace(ttm.strInsertFromJoins, 
			N'j_tlbEmployee_idfActor_v7.[idfEmployee] = tstObjectAccess_v6.[idfActor]', 
			N'j_tlbEmployee_idfActor_v7.[idfEmployee] = isnull(cug.idfEmployeeGroup_v7, tstObjectAccess_v6.[idfActor])'),
		ttm.strUpdateFromHeader = replace(ttm.strUpdateFromHeader, 
			N'inner join	[Falcon].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v6', 
			N'inner join	[Falcon].[dbo].[tstObjectAccess] tstObjectAccess_v6
	left join	[Giraffe].[dbo].[_dmccCustomUserGroup] cug
	on			cug.idfEmployeeGroup_v6 = tstObjectAccess_v6.[idfActor]'),
		ttm.strUpdateFromJoins = replace(ttm.strUpdateFromJoins, 
			N'j_tlbEmployee_idfActor_v7.[idfEmployee] = tstObjectAccess_v6.[idfActor]', 
			N'j_tlbEmployee_idfActor_v7.[idfEmployee] = isnull(cug.idfEmployeeGroup_v7, tstObjectAccess_v6.[idfActor])'),
		ttm.strInsertWhereConditions = ttm.strInsertWhereConditions +
			N'
	and	(	trtDiagnosis_v7_PermissionTo.[idfsDiagnosis] is not null
			or	 tstSite_v7_PermissionTo.[idfsSite] is not null
		)
' collate Cyrillic_General_CI_AS
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tstObjectAccess' collate Cyrillic_General_CI_AS





update	ttm
set		ttm.strInsertFromJoins = replace(ttm.strInsertFromJoins, 
			N'tstAggrSetting_v7.[idfsSite] = tstAggrSetting_v6.[idfsSite]', 
			N'tstAggrSetting_v7.[idfsSite] = @CDRSite'),
		ttm.strSelectColumns = replace(ttm.strSelectColumns, 
			N'tstAggrSetting_v6.[idfsSite]',
			N'@CDRSite')
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tstAggrSetting' collate Cyrillic_General_CI_AS



update	ttm
set		ttm.strInsertWhereConditions = ttm.strInsertWhereConditions + N'
	and not exists (select 1 from [Giraffe].[dbo].[tlbPostalCode] tlbPostalCode_v7_UK where tlbPostalCode_v7_UK.[idfsLocation] =  j_gisSettlement_idfsSettlement_v7.[idfsSettlement] and tlbPostalCode_v7_UK.[strPostCode] = tlbPostalCode_v6.[strPostCode] collate Cyrillic_General_CI_AS)
' collate Cyrillic_General_CI_AS
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tlbPostalCode' collate Cyrillic_General_CI_AS

update	ttm
set		ttm.strInsertWhereConditions = ttm.strInsertWhereConditions + N'
	and not exists (select 1 from [Giraffe].[dbo].[tlbStreet] tlbStreet_v7_UK where tlbStreet_v7_UK.[idfsLocation] =  j_gisSettlement_idfsSettlement_v7.[idfsSettlement] and tlbStreet_v7_UK.[strStreetName] = tlbStreet_v6.[strStreetName] collate Cyrillic_General_CI_AS)
' collate Cyrillic_General_CI_AS
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tlbStreet' collate Cyrillic_General_CI_AS


update	ttm
set		ttm.strStatementBeforeInsert = N'
/************************************************************
* Reset identifier seed value to the temporary one - start
************************************************************/

declare	@sqlIdResetCmd				nvarchar(max)
set	@sqlIdResetCmd = N''''

set	@sqlIdResetCmd = N''

declare @TempIdentifierSeedValue bigint = '' + cast((@TempIdentifierSeedValue - case when db_name() like N''%_Archive'' collate Cyrillic_General_CI_AS then 1 else 0 end) as nvarchar(20)) + N''

declare	@max_value			bigint
set	@max_value = @TempIdentifierSeedValue

declare	@seed_value			bigint
set	@seed_value = null
declare	@increment_value	bigint
set	@increment_value = null

declare	@sqlCmd				nvarchar(max)
set	@sqlCmd = N''''''''

'' collate Cyrillic_General_CI_AS

select	@sqlIdResetCmd = @sqlIdResetCmd + N''
	-- dbo.'' + t.[name] + N'': '' + c_ic.[name] + N''
	if	exists	(
			select	1 
			from	[Falcon].[sys].[tables] t
			inner join	[Falcon].sys.objects o_t
			on			o_t.[object_id] = t.[object_id]
						and o_t.[type] = N''''U'''' collate Cyrillic_General_CI_AS
			inner join	[Falcon].sys.schemas s
			on			s.[schema_id] = t.[schema_id]
						and s.[name] = N''''dbo'''' collate Cyrillic_General_CI_AS			
			where		t.[name] = N'''''' + t.[name] + N'''''' collate Cyrillic_General_CI_AS
				)
	begin
		if	exists	(
				select	1
				from	[Falcon].[dbo].['' + t.[name] + N'']
				where	['' + c_ic.[name] + N''] >= @max_value
						and (['' + c_ic.[name] + ''] - @TempIdentifierSeedValue) % 10000000 = 0
					)
		begin
			select		@max_value = max('' + c_ic.[name] + N'') + 10000000
			from		[Falcon].[dbo].['' + t.[name] + N'']
			where		(['' + c_ic.[name] + ''] - @TempIdentifierSeedValue) % 10000000 = 0
		end
	end
''
from
-- Table
			[Falcon].sys.tables t
inner join	[Falcon].sys.objects o_t
on			o_t.[object_id] = t.[object_id]
			and o_t.[type] = N''U'' collate Cyrillic_General_CI_AS
			and o_t.[name] not like N''gis%'' collate Cyrillic_General_CI_AS
			and o_t.[name] not like N''tfl%'' collate Cyrillic_General_CI_AS
			and o_t.[name] not like N''Lkup%'' collate Cyrillic_General_CI_AS

inner join	[Falcon].sys.schemas s
on			s.[schema_id] = t.[schema_id]
			and s.[name] = N''dbo'' collate Cyrillic_General_CI_AS

-- PK
inner join	[Falcon].sys.indexes i
on			i.[object_id] = t.[object_id]
			and i.is_primary_key = 1

-- PK column
inner join	[Falcon].sys.index_columns ic
on			ic.[object_id] = i.[object_id]
			and ic.[index_id] = i.[index_id]
inner join	[Falcon].sys.columns c_ic
on			c_ic.[object_id] = ic.[object_id]
			and c_ic.[column_id] = ic.[column_id]
			and c_ic.[name] <> N''idfsLanguage''
			and c_ic.[system_type_id] in (127, 56)
where		not exists	(
					select	1
					from		[Falcon].sys.index_columns ic_second
					inner join	[Falcon].sys.columns c_ic_second
					on			c_ic_second.[object_id] = ic_second.[object_id]
								and c_ic_second.[column_id] = ic_second.[column_id]
								and c_ic_second.[name] <> N''idfsLanguage''
								and c_ic_second.[system_type_id]  in (127, 56)
								and	c_ic_second.[column_id] <> c_ic.[column_id]
					where		ic_second.[object_id] = i.[object_id]
								and ic_second.[index_id] = i.[index_id]
						)

' collate Cyrillic_General_CI_AS,--TODO: consider if we need to find max value in Giraffe DB as well?
	ttm.strStatementBeforeInsert2 = N'
set	@sqlIdResetCmd = @sqlIdResetCmd + N''
-- Update initial ID in the table tstNewID

select		@seed_value = cast(seed_value as bigint),
			@increment_value = cast(increment_value as bigint)
from		[Giraffe].sys.identity_columns NewIDcol
inner join	[Giraffe].sys.columns col
on			col.[object_id] = NewIDcol.[object_id]
			and col.[column_id] = NewIDcol.[column_id]
			and col.[name] = NewIDcol.[name]
			and col.is_identity = 1
inner join	[Giraffe].dbo.sysobjects NewIDtable
on			NewIDtable.[id] = NewIDcol.[object_id]
where		NewIDtable.[id] = object_id(N''''[dbo].[tstNewID]'''') 
			and OBJECTPROPERTY(NewIDtable.[id], N''''IsUserTable'''') = 1
			and NewIDcol.[name] = N''''NewID''''

if	(@seed_value is null) or (@increment_value is null)
	or (@seed_value is not null and (@seed_value < @max_value) and ((isnull(@seed_value, 0) - @max_value) % 10000000 = 0))
	or (@seed_value is not null and ((isnull(@seed_value, 0) - @max_value) % 10000000 <> 0))
--			or (@increment_value <> 10000000)
begin
	set @sqlCmd = N''''
if	exists	(
select	1 
from	[Giraffe].[dbo].sysobjects 
where	id = object_id(N''''''''[dbo].[tstNewID]'''''''') 
		and OBJECTPROPERTY(id, N''''''''IsUserTable'''''''') = 1
	)
drop table [dbo].[tstNewID]

''''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''''
create table	[dbo].[tstNewID]
(	NewID		bigint IDENTITY('''' + cast(@max_value as nvarchar(20)) + N'''', 10000000) not null,
	idfTable	bigint null,
	idfKey1		bigint null,
	idfKey2		bigint null,
	strRowGuid	nvarchar(36) collate Cyrillic_General_CI_AS null,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[SourceSystemNameID] [bigint] NULL,
	[SourceSystemKeyValue] [nvarchar](max) NULL,
	[AuditCreateUser] [nvarchar](200) NULL,
	[AuditCreateDTM] [datetime] NULL,
	[AuditUpdateUser] [nvarchar](200) NULL,
	[AuditUpdateDTM] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
''''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''''
ALTER TABLE [dbo].[tstNewID] ADD  CONSTRAINT [DF_tstNewID_rowguid]  DEFAULT (newsequentialid()) FOR [rowguid]
''''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''''
ALTER TABLE [dbo].[tstNewID] ADD  CONSTRAINT [DF_tstNewID_CreateDTM]  DEFAULT (getdate()) FOR [AuditCreateDTM]
''''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''''
ALTER TABLE [dbo].[tstNewID]  WITH CHECK ADD  CONSTRAINT [FK_tstNewID_trtBaseReference_SourceSystemNameID] FOREIGN KEY([SourceSystemNameID])
REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
''''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''''
ALTER TABLE [dbo].[tstNewID] CHECK CONSTRAINT [FK_tstNewID_trtBaseReference_SourceSystemNameID]
''''
	execute sp_executesql @sqlCmd

	print	''''New temporary consequent ID value in the table tstNewID: '''' + cast(@max_value as varchar(30))
end
else 
	print ''''Update of temporary consequent ID value in the table tstNewID is not needed: '''' + cast(@seed_value as varchar(30))
''
exec [Giraffe].[sys].sp_executesql @sqlIdResetCmd
/************************************************************
* Reset identifier seed value to the temporary one - end
************************************************************/

declare @ArchiveCmd nvarchar(max) = N''''

if DB_NAME() like N''%_Archive'' collate Latin1_General_CI_AS
begin
	set @ArchiveCmd = N''
INSERT INTO ['' + DB_NAME() + N''].[dbo].[tlbGeoLocationShared]
(	  [idfGeoLocationShared]
	, [idfsSite]
	, [idfsGeoLocationType]
	, [idfsCountry]
	, [blnForeignAddress]
	, [intRowStatus]
	, [SourceSystemNameID]
	, [SourceSystemKeyValue]
	, [AuditCreateUser]
	, [AuditCreateDTM]
	, [AuditUpdateUser]
	, [AuditUpdateDTM]
	, [idfsLocation]
)
SELECT	  tlbGeoLocationShared_v7_Actual.[idfGeoLocationShared]
		, tlbGeoLocationShared_v7_Actual.[idfsSite]
		, tlbGeoLocationShared_v7_Actual.[idfsGeoLocationType]
		, tlbGeoLocationShared_v7_Actual.[idfsCountry]
		, tlbGeoLocationShared_v7_Actual.[blnForeignAddress]
		, tlbGeoLocationShared_v7_Actual.[intRowStatus]
		, tlbGeoLocationShared_v7_Actual.[SourceSystemNameID]
		, tlbGeoLocationShared_v7_Actual.[SourceSystemKeyValue]
		, tlbGeoLocationShared_v7_Actual.[AuditCreateUser]
		, tlbGeoLocationShared_v7_Actual.[AuditCreateDTM]
		, tlbGeoLocationShared_v7_Actual.[AuditUpdateUser]
		, tlbGeoLocationShared_v7_Actual.[AuditUpdateDTM]
		, tlbGeoLocationShared_v7_Actual.[idfsLocation]

FROM	['' + left(DB_NAME(), len(DB_NAME()) - 8) + N''].[dbo].[tlbHumanActual] tlbHumanActual_v7_Actual
join	[Falcon].[dbo].[tlbHumanActual] tlbHumanActual_v6_Archive
on		tlbHumanActual_v6_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]
join	['' + left(DB_NAME(), len(DB_NAME()) - 8) + N''].[dbo].[HumanActualAddlInfo] HumanActualAddlInfo_v7_Actual
on		HumanActualAddlInfo_v7_Actual.[HumanActualAddlInfoUID] = tlbHumanActual_v7_Actual.[idfHumanActual]
join	['' + left(DB_NAME(), len(DB_NAME()) - 8) + N''].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v7_Actual
on		tlbGeoLocationShared_v7_Actual.[idfGeoLocationShared] = HumanActualAddlInfo_v7_Actual.[SchoolAddressID]
left join	['' + DB_NAME() + N''].[dbo].[tlbHumanActual] tlbHumanActual_v7_Archive
on		tlbHumanActual_v7_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]
left join	['' + DB_NAME() + N''].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v7_Archive
on		tlbGeoLocationShared_v7_Archive.[idfGeoLocationShared] = HumanActualAddlInfo_v7_Actual.[SchoolAddressID]

WHERE	tlbHumanActual_v7_Archive.[idfHumanActual] is null
		and tlbGeoLocationShared_v7_Archive.[idfGeoLocationShared] is null
print N''''Table [tlbGeoLocationShared] - Insert school addresses of persons by copying from actual database: '''' + cast(@@rowcount as nvarchar(20))
	
	''
	exec sp_executesql @ArchiveCmd
' collate Cyrillic_General_CI_AS,
	ttm.strStatementBeforeInsert3 = N'

	set @ArchiveCmd = N''
INSERT INTO ['' + DB_NAME() + N''].[dbo].[tlbGeoLocationShared]
(	  [idfGeoLocationShared]
	, [idfsSite]
	, [idfsGeoLocationType]
	, [idfsCountry]
	, [blnForeignAddress]
	, [intRowStatus]
	, [SourceSystemNameID]
	, [SourceSystemKeyValue]
	, [AuditCreateUser]
	, [AuditCreateDTM]
	, [AuditUpdateUser]
	, [AuditUpdateDTM]
	, [idfsLocation]
)
SELECT	  tlbGeoLocationShared_v7_Actual.[idfGeoLocationShared]
		, tlbGeoLocationShared_v7_Actual.[idfsSite]
		, tlbGeoLocationShared_v7_Actual.[idfsGeoLocationType]
		, tlbGeoLocationShared_v7_Actual.[idfsCountry]
		, tlbGeoLocationShared_v7_Actual.[blnForeignAddress]
		, tlbGeoLocationShared_v7_Actual.[intRowStatus]
		, tlbGeoLocationShared_v7_Actual.[SourceSystemNameID]
		, tlbGeoLocationShared_v7_Actual.[SourceSystemKeyValue]
		, tlbGeoLocationShared_v7_Actual.[AuditCreateUser]
		, tlbGeoLocationShared_v7_Actual.[AuditCreateDTM]
		, tlbGeoLocationShared_v7_Actual.[AuditUpdateUser]
		, tlbGeoLocationShared_v7_Actual.[AuditUpdateDTM]
		, tlbGeoLocationShared_v7_Actual.[idfsLocation]

FROM	['' + left(DB_NAME(), len(DB_NAME()) - 8) + N''].[dbo].[tlbHumanActual] tlbHumanActual_v7_Actual
join	[Falcon].[dbo].[tlbHumanActual] tlbHumanActual_v6_Archive
on		tlbHumanActual_v6_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]
join	['' + left(DB_NAME(), len(DB_NAME()) - 8) + N''].[dbo].[HumanActualAddlInfo] HumanActualAddlInfo_v7_Actual
on		HumanActualAddlInfo_v7_Actual.[HumanActualAddlInfoUID] = tlbHumanActual_v7_Actual.[idfHumanActual]
join	['' + left(DB_NAME(), len(DB_NAME()) - 8) + N''].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v7_Actual
on		tlbGeoLocationShared_v7_Actual.[idfGeoLocationShared] = HumanActualAddlInfo_v7_Actual.[AltAddressID]
left join	['' + DB_NAME() + N''].[dbo].[tlbHumanActual] tlbHumanActual_v7_Archive
on		tlbHumanActual_v7_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]
left join	['' + DB_NAME() + N''].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v7_Archive
on		tlbGeoLocationShared_v7_Archive.[idfGeoLocationShared] = HumanActualAddlInfo_v7_Actual.[AltAddressID]

WHERE	tlbHumanActual_v7_Archive.[idfHumanActual] is null
		and tlbGeoLocationShared_v7_Archive.[idfGeoLocationShared] is null
print N''''Table [tlbGeoLocationShared] - Insert alternative addresses of persons by copying from actual database: '''' + cast(@@rowcount as nvarchar(20))
	
	''
	exec sp_executesql @ArchiveCmd

	set @ArchiveCmd = N''
INSERT INTO ['' + DB_NAME() + N''].[dbo].[tlbGeoLocationShared]
(	  [idfGeoLocationShared]
	, [idfsSite]
	, [idfsGeoLocationType]
	, [idfsCountry]
	, [idfsRegion]
	, [idfsRayon]
	, [idfsSettlement]
	, [strPostCode]
	, [strStreetName]
	, [strHouse]
	, [strBuilding]
	, [strApartment]
	, [dblLatitude]
	, [dblLongitude]
	, [intRowStatus]
	, [blnForeignAddress]
	, [strForeignAddress]
	, [SourceSystemNameID]
	, [SourceSystemKeyValue]
	, [AuditCreateUser]
	, [AuditCreateDTM]
	, [AuditUpdateUser]
	, [AuditUpdateDTM]
	, [idfsLocation]
)
SELECT	  tlbGeoLocationShared_v7_Actual.[idfGeoLocationShared]
		, tlbGeoLocationShared_v7_Actual.[idfsSite]
		, tlbGeoLocationShared_v7_Actual.[idfsGeoLocationType]
		, tlbGeoLocationShared_v7_Actual.[idfsCountry]
		, tlbGeoLocationShared_v7_Actual.[idfsRegion]
		, tlbGeoLocationShared_v7_Actual.[idfsRayon]
		, tlbGeoLocationShared_v7_Actual.[idfsSettlement]
		, tlbGeoLocationShared_v7_Actual.[strPostCode]
		, tlbGeoLocationShared_v7_Actual.[strStreetName]
		, tlbGeoLocationShared_v7_Actual.[strHouse]
		, tlbGeoLocationShared_v7_Actual.[strBuilding]
		, tlbGeoLocationShared_v7_Actual.[strApartment]
		, tlbGeoLocationShared_v7_Actual.[dblLatitude]
		, tlbGeoLocationShared_v7_Actual.[dblLongitude]
		, tlbGeoLocationShared_v7_Actual.[intRowStatus]
		, tlbGeoLocationShared_v7_Actual.[blnForeignAddress]
		, tlbGeoLocationShared_v7_Actual.[strForeignAddress]
		, tlbGeoLocationShared_v7_Actual.[SourceSystemNameID]
		, tlbGeoLocationShared_v7_Actual.[SourceSystemKeyValue]
		, tlbGeoLocationShared_v7_Actual.[AuditCreateUser]
		, tlbGeoLocationShared_v7_Actual.[AuditCreateDTM]
		, tlbGeoLocationShared_v7_Actual.[AuditUpdateUser]
		, tlbGeoLocationShared_v7_Actual.[AuditUpdateDTM]
		, tlbGeoLocationShared_v7_Actual.[idfsLocation]

FROM	['' + left(DB_NAME(), len(DB_NAME()) - 8) + N''].[dbo].[tlbHumanActual] tlbHumanActual_v7_Actual
join	[Falcon].[dbo].[tlbHumanActual] tlbHumanActual_v6_Archive
on		tlbHumanActual_v6_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]
join	['' + left(DB_NAME(), len(DB_NAME()) - 8) + N''].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v7_Actual
on		tlbGeoLocationShared_v7_Actual.[idfGeoLocationShared] = tlbHumanActual_v7_Actual.[idfCurrentResidenceAddress]
left join	['' + DB_NAME() + N''].[dbo].[tlbHumanActual] tlbHumanActual_v7_Archive
on		tlbHumanActual_v7_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]
left join	['' + DB_NAME() + N''].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v7_Archive
on		tlbGeoLocationShared_v7_Archive.[idfGeoLocationShared] = tlbHumanActual_v7_Actual.[idfCurrentResidenceAddress]

WHERE	tlbHumanActual_v7_Archive.[idfHumanActual] is null
		and tlbGeoLocationShared_v7_Archive.[idfGeoLocationShared] is null
print N''''Table [tlbGeoLocationShared] - Insert missing current residence addresses of persons by copying from actual database: '''' + cast(@@rowcount as nvarchar(20))
	
	''
	exec sp_executesql @ArchiveCmd
' collate Cyrillic_General_CI_AS,
	ttm.strStatementBeforeInsert4 = N'

	set @ArchiveCmd = N''
INSERT INTO ['' + DB_NAME() + N''].[dbo].[tlbGeoLocationShared]
(	  [idfGeoLocationShared]
	, [idfsSite]
	, [idfsGeoLocationType]
	, [idfsCountry]
	, [idfsRegion]
	, [idfsRayon]
	, [idfsSettlement]
	, [strPostCode]
	, [strStreetName]
	, [strHouse]
	, [strBuilding]
	, [strApartment]
	, [dblLatitude]
	, [dblLongitude]
	, [intRowStatus]
	, [blnForeignAddress]
	, [strForeignAddress]
	, [SourceSystemNameID]
	, [SourceSystemKeyValue]
	, [AuditCreateUser]
	, [AuditCreateDTM]
	, [AuditUpdateUser]
	, [AuditUpdateDTM]
	, [idfsLocation]
)
SELECT	  tlbGeoLocationShared_v7_Actual.[idfGeoLocationShared]
		, tlbGeoLocationShared_v7_Actual.[idfsSite]
		, tlbGeoLocationShared_v7_Actual.[idfsGeoLocationType]
		, tlbGeoLocationShared_v7_Actual.[idfsCountry]
		, tlbGeoLocationShared_v7_Actual.[idfsRegion]
		, tlbGeoLocationShared_v7_Actual.[idfsRayon]
		, tlbGeoLocationShared_v7_Actual.[idfsSettlement]
		, tlbGeoLocationShared_v7_Actual.[strPostCode]
		, tlbGeoLocationShared_v7_Actual.[strStreetName]
		, tlbGeoLocationShared_v7_Actual.[strHouse]
		, tlbGeoLocationShared_v7_Actual.[strBuilding]
		, tlbGeoLocationShared_v7_Actual.[strApartment]
		, tlbGeoLocationShared_v7_Actual.[dblLatitude]
		, tlbGeoLocationShared_v7_Actual.[dblLongitude]
		, tlbGeoLocationShared_v7_Actual.[intRowStatus]
		, tlbGeoLocationShared_v7_Actual.[blnForeignAddress]
		, tlbGeoLocationShared_v7_Actual.[strForeignAddress]
		, tlbGeoLocationShared_v7_Actual.[SourceSystemNameID]
		, tlbGeoLocationShared_v7_Actual.[SourceSystemKeyValue]
		, tlbGeoLocationShared_v7_Actual.[AuditCreateUser]
		, tlbGeoLocationShared_v7_Actual.[AuditCreateDTM]
		, tlbGeoLocationShared_v7_Actual.[AuditUpdateUser]
		, tlbGeoLocationShared_v7_Actual.[AuditUpdateDTM]
		, tlbGeoLocationShared_v7_Actual.[idfsLocation]

FROM	['' + left(DB_NAME(), len(DB_NAME()) - 8) + N''].[dbo].[tlbHumanActual] tlbHumanActual_v7_Actual
join	[Falcon].[dbo].[tlbHumanActual] tlbHumanActual_v6_Archive
on		tlbHumanActual_v6_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]
join	['' + left(DB_NAME(), len(DB_NAME()) - 8) + N''].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v7_Actual
on		tlbGeoLocationShared_v7_Actual.[idfGeoLocationShared] = tlbHumanActual_v7_Actual.[idfRegistrationAddress]
left join	['' + DB_NAME() + N''].[dbo].[tlbHumanActual] tlbHumanActual_v7_Archive
on		tlbHumanActual_v7_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]
left join	['' + DB_NAME() + N''].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v7_Archive
on		tlbGeoLocationShared_v7_Archive.[idfGeoLocationShared] = tlbHumanActual_v7_Actual.[idfRegistrationAddress]

WHERE	tlbHumanActual_v7_Archive.[idfHumanActual] is null
		and tlbGeoLocationShared_v7_Archive.[idfGeoLocationShared] is null
print N''''Table [tlbGeoLocationShared] - Insert missing permanent residence addresses of persons by copying from actual database: '''' + cast(@@rowcount as nvarchar(20))
	
	''
	exec sp_executesql @ArchiveCmd

	set @ArchiveCmd = N''
INSERT INTO ['' + DB_NAME() + N''].[dbo].[tlbGeoLocationShared]
(	  [idfGeoLocationShared]
	, [idfsSite]
	, [idfsGeoLocationType]
	, [idfsCountry]
	, [idfsRegion]
	, [idfsRayon]
	, [idfsSettlement]
	, [strPostCode]
	, [strStreetName]
	, [strHouse]
	, [strBuilding]
	, [strApartment]
	, [dblLatitude]
	, [dblLongitude]
	, [intRowStatus]
	, [blnForeignAddress]
	, [strForeignAddress]
	, [SourceSystemNameID]
	, [SourceSystemKeyValue]
	, [AuditCreateUser]
	, [AuditCreateDTM]
	, [AuditUpdateUser]
	, [AuditUpdateDTM]
	, [idfsLocation]
)
SELECT	  tlbGeoLocationShared_v7_Actual.[idfGeoLocationShared]
		, tlbGeoLocationShared_v7_Actual.[idfsSite]
		, tlbGeoLocationShared_v7_Actual.[idfsGeoLocationType]
		, tlbGeoLocationShared_v7_Actual.[idfsCountry]
		, tlbGeoLocationShared_v7_Actual.[idfsRegion]
		, tlbGeoLocationShared_v7_Actual.[idfsRayon]
		, tlbGeoLocationShared_v7_Actual.[idfsSettlement]
		, tlbGeoLocationShared_v7_Actual.[strPostCode]
		, tlbGeoLocationShared_v7_Actual.[strStreetName]
		, tlbGeoLocationShared_v7_Actual.[strHouse]
		, tlbGeoLocationShared_v7_Actual.[strBuilding]
		, tlbGeoLocationShared_v7_Actual.[strApartment]
		, tlbGeoLocationShared_v7_Actual.[dblLatitude]
		, tlbGeoLocationShared_v7_Actual.[dblLongitude]
		, tlbGeoLocationShared_v7_Actual.[intRowStatus]
		, tlbGeoLocationShared_v7_Actual.[blnForeignAddress]
		, tlbGeoLocationShared_v7_Actual.[strForeignAddress]
		, tlbGeoLocationShared_v7_Actual.[SourceSystemNameID]
		, tlbGeoLocationShared_v7_Actual.[SourceSystemKeyValue]
		, tlbGeoLocationShared_v7_Actual.[AuditCreateUser]
		, tlbGeoLocationShared_v7_Actual.[AuditCreateDTM]
		, tlbGeoLocationShared_v7_Actual.[AuditUpdateUser]
		, tlbGeoLocationShared_v7_Actual.[AuditUpdateDTM]
		, tlbGeoLocationShared_v7_Actual.[idfsLocation]

FROM	['' + left(DB_NAME(), len(DB_NAME()) - 8) + N''].[dbo].[tlbHumanActual] tlbHumanActual_v7_Actual
join	[Falcon].[dbo].[tlbHumanActual] tlbHumanActual_v6_Archive
on		tlbHumanActual_v6_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]
join	['' + left(DB_NAME(), len(DB_NAME()) - 8) + N''].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v7_Actual
on		tlbGeoLocationShared_v7_Actual.[idfGeoLocationShared] = tlbHumanActual_v7_Actual.[idfEmployerAddress]
left join	['' + DB_NAME() + N''].[dbo].[tlbHumanActual] tlbHumanActual_v7_Archive
on		tlbHumanActual_v7_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]
left join	['' + DB_NAME() + N''].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v7_Archive
on		tlbGeoLocationShared_v7_Archive.[idfGeoLocationShared] = tlbHumanActual_v7_Actual.[idfEmployerAddress]

WHERE	tlbHumanActual_v7_Archive.[idfHumanActual] is null
		and tlbGeoLocationShared_v7_Archive.[idfGeoLocationShared] is null
print N''''Table [tlbGeoLocationShared] - Insert missing employer addresses of persons by copying from actual database: '''' + cast(@@rowcount as nvarchar(20))
	
	''
	exec sp_executesql @ArchiveCmd
' collate Cyrillic_General_CI_AS,
	ttm.strStatementBeforeInsert5 = N'

	set @ArchiveCmd = N''
INSERT INTO ['' + DB_NAME() + N''].[dbo].[tlbHumanActual]
(	 [idfHumanActual]
	,[idfsOccupationType]
	,[idfsNationality]
	,[idfsHumanGender]
	,[idfCurrentResidenceAddress]
	,[idfEmployerAddress]
	,[idfRegistrationAddress]
	,[datDateofBirth]
	,[datDateOfDeath]
	,[strLastName]
	,[strSecondName]
	,[strFirstName]
	,[strRegistrationPhone]
	,[strEmployerName]
	,[strHomePhone]
	,[strWorkPhone]
	,[intRowStatus]
	,[idfsPersonIDType]
	,[strPersonID]
	,[datEnteredDate]
	,[datModificationDate]
	,[SourceSystemNameID]
	,[SourceSystemKeyValue]
	,[AuditCreateUser]
	,[AuditCreateDTM]
	,[AuditUpdateUser]
	,[AuditUpdateDTM]
)
SELECT	 tlbHumanActual_v7_Actual.[idfHumanActual]
		,tlbHumanActual_v7_Actual.[idfsOccupationType]
		,tlbHumanActual_v7_Actual.[idfsNationality]
		,tlbHumanActual_v7_Actual.[idfsHumanGender]
		,tlbHumanActual_v7_Actual.[idfCurrentResidenceAddress]
		,tlbHumanActual_v7_Actual.[idfEmployerAddress]
		,tlbHumanActual_v7_Actual.[idfRegistrationAddress]
		,tlbHumanActual_v7_Actual.[datDateofBirth]
		,tlbHumanActual_v7_Actual.[datDateOfDeath]
		,tlbHumanActual_v7_Actual.[strLastName]
		,tlbHumanActual_v7_Actual.[strSecondName]
		,tlbHumanActual_v7_Actual.[strFirstName]
		,tlbHumanActual_v7_Actual.[strRegistrationPhone]
		,tlbHumanActual_v7_Actual.[strEmployerName]
		,tlbHumanActual_v7_Actual.[strHomePhone]
		,tlbHumanActual_v7_Actual.[strWorkPhone]
		,tlbHumanActual_v7_Actual.[intRowStatus]
		,tlbHumanActual_v7_Actual.[idfsPersonIDType]
		,tlbHumanActual_v7_Actual.[strPersonID]
		,tlbHumanActual_v7_Actual.[datEnteredDate]
		,tlbHumanActual_v7_Actual.[datModificationDate]
		,tlbHumanActual_v7_Actual.[SourceSystemNameID]
		,tlbHumanActual_v7_Actual.[SourceSystemKeyValue]
		,tlbHumanActual_v7_Actual.[AuditCreateUser]
		,tlbHumanActual_v7_Actual.[AuditCreateDTM]
		,tlbHumanActual_v7_Actual.[AuditUpdateUser]
		,tlbHumanActual_v7_Actual.[AuditUpdateDTM]

FROM	['' + left(DB_NAME(), len(DB_NAME()) - 8) + N''].[dbo].[tlbHumanActual] tlbHumanActual_v7_Actual
join	[Falcon].[dbo].[tlbHumanActual] tlbHumanActual_v6_Archive
on		tlbHumanActual_v6_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]
left join	['' + DB_NAME() + N''].[dbo].[tlbHumanActual] tlbHumanActual_v7_Archive
on		tlbHumanActual_v7_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]

WHERE	tlbHumanActual_v7_Archive.[idfHumanActual] is null
print N''''Table [tlbHumanActual] - Insert persons by copying from actual database: '''' + cast(@@rowcount as nvarchar(20))
	
	''
	exec sp_executesql @ArchiveCmd


	set @ArchiveCmd = N''
INSERT INTO ['' + DB_NAME() + N''].[dbo].[HumanActualAddlInfo]
(	[HumanActualAddlInfoUID],
	[EIDSSPersonID],
	[PassportNbr],
	[SchoolAddressID],
	[AltAddressID],
	[DeduplicationResultHumanActualID],
	[IsEmployedID],
	[EmployerPhoneNbr],
	[EmployedDTM],
	[ContactPhoneCountryCode],
	[ContactPhoneNbr],
	[ContactPhoneNbrTypeID],
	[ContactPhone2CountryCode],
	[ContactPhone2Nbr],
	[ContactPhone2NbrTypeID],
	[IsStudentID],
	[SchoolName],
	[SchoolPhoneNbr],
	[SchoolLastAttendDTM],
	[IsAnotherPhoneID],
	[IsAnotherAddressID],
	[intRowStatus],
	[AuditCreateUser],
	[AuditCreateDTM],
	[AuditUpdateUser],
	[AuditUpdateDTM],
	[SourceSystemNameID],
	[SourceSystemKeyValue]
)
SELECT	HumanActualAddlInfo_v7_Actual.[HumanActualAddlInfoUID],
		HumanActualAddlInfo_v7_Actual.[EIDSSPersonID],
		HumanActualAddlInfo_v7_Actual.[PassportNbr],
		HumanActualAddlInfo_v7_Actual.[SchoolAddressID],
		HumanActualAddlInfo_v7_Actual.[AltAddressID],
		HumanActualAddlInfo_v7_Actual.[DeduplicationResultHumanActualID],
		HumanActualAddlInfo_v7_Actual.[IsEmployedID],
		HumanActualAddlInfo_v7_Actual.[EmployerPhoneNbr],
		HumanActualAddlInfo_v7_Actual.[EmployedDTM],
		HumanActualAddlInfo_v7_Actual.[ContactPhoneCountryCode],
		HumanActualAddlInfo_v7_Actual.[ContactPhoneNbr],
		HumanActualAddlInfo_v7_Actual.[ContactPhoneNbrTypeID],
		HumanActualAddlInfo_v7_Actual.[ContactPhone2CountryCode],
		HumanActualAddlInfo_v7_Actual.[ContactPhone2Nbr],
		HumanActualAddlInfo_v7_Actual.[ContactPhone2NbrTypeID],
		HumanActualAddlInfo_v7_Actual.[IsStudentID],
		HumanActualAddlInfo_v7_Actual.[SchoolName],
		HumanActualAddlInfo_v7_Actual.[SchoolPhoneNbr],
		HumanActualAddlInfo_v7_Actual.[SchoolLastAttendDTM],
		HumanActualAddlInfo_v7_Actual.[IsAnotherPhoneID],
		HumanActualAddlInfo_v7_Actual.[IsAnotherAddressID],
		HumanActualAddlInfo_v7_Actual.[intRowStatus],
		HumanActualAddlInfo_v7_Actual.[AuditCreateUser],
		HumanActualAddlInfo_v7_Actual.[AuditCreateDTM],
		HumanActualAddlInfo_v7_Actual.[AuditUpdateUser],
		HumanActualAddlInfo_v7_Actual.[AuditUpdateDTM],
		HumanActualAddlInfo_v7_Actual.[SourceSystemNameID],
		HumanActualAddlInfo_v7_Actual.[SourceSystemKeyValue]

FROM	['' + left(DB_NAME(), len(DB_NAME()) - 8) + N''].[dbo].[tlbHumanActual] tlbHumanActual_v7_Actual
join	[Falcon].[dbo].[tlbHumanActual] tlbHumanActual_v6_Archive
on		tlbHumanActual_v6_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]
join	['' + left(DB_NAME(), len(DB_NAME()) - 8) + N''].[dbo].[HumanActualAddlInfo] HumanActualAddlInfo_v7_Actual
on		HumanActualAddlInfo_v7_Actual.[HumanActualAddlInfoUID] = tlbHumanActual_v7_Actual.[idfHumanActual]
join	['' + DB_NAME() + N''].[dbo].[tlbHumanActual] tlbHumanActual_v7_Archive
on		tlbHumanActual_v7_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]
left join	['' + DB_NAME() + N''].[dbo].[HumanActualAddlInfo] HumanActualAddlInfo_v7_Archive
on		HumanActualAddlInfo_v7_Archive.[HumanActualAddlInfoUID] = tlbHumanActual_v7_Actual.[idfHumanActual]

WHERE	HumanActualAddlInfo_v7_Archive.[HumanActualAddlInfoUID] is null
print N''''Table [HumanActualAddlInfo] - Insert persons details by copying from actual database: '''' + cast(@@rowcount as nvarchar(20))
	
	''
	exec sp_executesql @ArchiveCmd

end
' collate Cyrillic_General_CI_AS,
	ttm.strStatementBeforeInsert6 = N'

/************************************************************
* Insert records - [tlbGeoLocationShared]
************************************************************/
insert into	[Giraffe].[dbo].[tstNewID]
(	[idfTable],
	[idfKey1],
	[idfKey2],
	[strRowGuid]
)
select		4572590000000	/*tlbGeoLocationShared*/
			, tlbHumanActual_v6.idfHumanActual
			, address_Type.idfKey
			, @TempIdentifierKey
from		[Falcon].[dbo].[tlbHumanActual] tlbHumanActual_v6
left join	[Giraffe].[dbo].[tlbHumanActual] tlbHumanActual_v7
on			tlbHumanActual_v7.[idfHumanActual] = tlbHumanActual_v6.[idfHumanActual]
cross join
(		select	1 /*Alternative Address*/ as idfKey union all
		select	2 /*School Address*/
) address_Type
where		tlbHumanActual_v7.[idfHumanActual] is null

exec [Giraffe].sys.sp_executesql N''ALTER INDEX ALL ON dbo.tstNewID REBUILD''

insert into [Giraffe].[dbo].[tlbGeoLocationShared] 
(	  [idfGeoLocationShared]
	, [idfsSite]
	, [idfsGeoLocationType]
	, [idfsCountry]
	, [blnForeignAddress]
	, [SourceSystemNameID]
	, [SourceSystemKeyValue]
	, [AuditCreateUser]
	, [AuditCreateDTM]
	, [AuditUpdateUser]
	, [AuditUpdateDTM]
	, [idfsLocation]
)
select		  tstNewID_v7.[NewID]
			, @CDRSite
			, 10036001 /*Address*/
			, @idfsCountry
			, 0
			, 10519002 /*Record Source: EIDSS6.1*/
			, N''[{'' + N''"idfGeoLocationShared":'' + isnull(cast(tstNewID_v7.[NewID] as nvarchar(20)), N''null'') + N''}]'' collate Cyrillic_General_CI_AS
			, N''system''
			, GETUTCDATE()
			, N''system''
			, GETUTCDATE()
			, @idfsCountry
from		[Falcon].[dbo].[tlbHumanActual] tlbHumanActual_v6
inner join	[Giraffe].[dbo].[tstNewID] tstNewID_v7
on			tstNewID_v7.[idfTable] = 4572590000000	/*tlbGeoLocationShared*/
			and tstNewID_v7.[idfKey1] = tlbHumanActual_v6.idfHumanActual
			and tstNewID_v7.[idfKey2] in (1, 2)
			and tstNewID_v7.[strRowGuid] = @TempIdentifierKey
left join	[Giraffe].[dbo].[tlbHumanActual] tlbHumanActual_v7
on			tlbHumanActual_v7.[idfHumanActual] = tlbHumanActual_v6.[idfHumanActual]
left join	[Giraffe].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v7 
on			tlbGeoLocationShared_v7.[idfGeoLocationShared] = tstNewID_v7.[NewID] 
where		tlbHumanActual_v7.[idfHumanActual] is null
			and tlbGeoLocationShared_v7.[idfGeoLocationShared] is null 
print N''Table [tlbGeoLocationShared] - insert new alternative and school addresses of persons from the catalog: '' + cast(@@rowcount as nvarchar(20))

',
		ttm.strInsertWhereConditions = ttm.strInsertWhereConditions + N'
	and (	exists (select 1 from [Falcon].[dbo].[tlbHumanActual] tlbHumanActual_v6 where tlbHumanActual_v6.[idfCurrentResidenceAddress] = tlbGeoLocationShared_v6.[idfGeoLocationShared])
			or exists (select 1 from [Falcon].[dbo].[tlbHumanActual] tlbHumanActual_v6 where tlbHumanActual_v6.[idfEmployerAddress] = tlbGeoLocationShared_v6.[idfGeoLocationShared])
			or exists (select 1 from [Falcon].[dbo].[tlbHumanActual] tlbHumanActual_v6 where tlbHumanActual_v6.[idfRegistrationAddress] = tlbGeoLocationShared_v6.[idfGeoLocationShared])
			or exists (select 1 from [Falcon].[dbo].[tlbFarmActual] tlbFarmActual_v6 where tlbFarmActual_v6.[idfFarmAddress] = tlbGeoLocationShared_v6.[idfGeoLocationShared])
		)
' collate Cyrillic_General_CI_AS
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tlbGeoLocationShared' collate Cyrillic_General_CI_AS
		and not exists
			(	select	1
				from	#TablesToMigrate ttm_max
				where	ttm_max.[table_id_v7] = ttm.[table_id_v7]
						and ttm_max.idfId > ttm.idfId
			)


update	ttm
set		ttm.strUpdateAfterInsert = N'

select	@NumberOfExistingMigratedRecords = count(tlbHumanActual_v6.[idfHumanActual])
from	[Falcon].[dbo].[tlbHumanActual] tlbHumanActual_v6
inner join	[Giraffe].[dbo].[tlbHumanActual] tlbHumanActual_v7
on	tlbHumanActual_v7.[idfHumanActual] = tlbHumanActual_v6.[idfHumanActual]
inner join	[Giraffe].[dbo].[HumanActualAddlInfo] HumanActualAddlInfo_v7
on	HumanActualAddlInfo_v7.[HumanActualAddlInfoUID] = tlbHumanActual_v6.[idfHumanActual]

IF OBJECT_ID(''tempdb..#HumanActualAddlInfo'') IS NOT NULL
	exec sp_executesql N''drop table #HumanActualAddlInfo''

IF OBJECT_ID(''tempdb..#HumanActualAddlInfo'') IS NULL
create table #HumanActualAddlInfo
(	idfId bigint not null identity(1, 1),
	[HumanActualAddlInfoUID] bigint not null primary key,
	[SchoolAddressID] bigint null,
	[AltAddressID] bigint null,
	[EIDSSPersonID] nvarchar(200) collate Cyrillic_General_CI_AS null,
	[intRowStatus] int not null,
	[IsEmployedID] bigint null,
	[EmployerPhoneNbr] nvarchar(200) collate Cyrillic_General_CI_AS null,
	[ContactPhoneNbr] nvarchar(200) collate Cyrillic_General_CI_AS null
)

truncate table #HumanActualAddlInfo

insert into	#HumanActualAddlInfo
(	[HumanActualAddlInfoUID],
	[intRowStatus],
	[IsEmployedID],
	[EmployerPhoneNbr],
	[ContactPhoneNbr]

)
select	tlbHumanActual_v6.[idfHumanActual],
		tlbHumanActual_v7.[intRowStatus],
		case
			when	(	tlbHumanActual_v7.strEmployerName is not null
						and ltrim(rtrim(tlbHumanActual_v7.strEmployerName)) <> N'''' collate Cyrillic_General_CI_AS
					)
					or	(	tlbGeoLocationShared_EmployerAddress_v7.blnForeignAddress = 1 
							or tlbGeoLocationShared_EmployerAddress_v7.idfsRegion is not null
						)
					or	(	tlbHumanActual_v7.strWorkPhone is not null
							and ltrim(rtrim(tlbHumanActual_v7.strWorkPhone)) <> N'''' collate Cyrillic_General_CI_AS
						)
				then 10100001 /*Yes*/
			else null
		end,
		tlbHumanActual_v7.strWorkPhone,
		tlbHumanActual_v7.strHomePhone
from	[Falcon].[dbo].[tlbHumanActual] tlbHumanActual_v6
inner join	[Giraffe].[dbo].[tlbHumanActual] tlbHumanActual_v7
on	tlbHumanActual_v7.[idfHumanActual] = tlbHumanActual_v6.[idfHumanActual]
left join	[Giraffe].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_EmployerAddress_v7
on	tlbGeoLocationShared_EmployerAddress_v7.[idfGeoLocationShared] = tlbHumanActual_v7.[idfEmployerAddress]
left join	[Giraffe].[dbo].[HumanActualAddlInfo] HumanActualAddlInfo_v7
on	HumanActualAddlInfo_v7.[HumanActualAddlInfoUID] = tlbHumanActual_v6.[idfHumanActual]
where	HumanActualAddlInfo_v7.[HumanActualAddlInfoUID] is null

update	temp
set		temp.[AltAddressID] = altAddress_v7.[idfGeoLocationShared]
from	#HumanActualAddlInfo temp
left join	[Giraffe].[dbo].[tlbGeoLocationShared] altAddress_v7
	inner join	[Giraffe].[dbo].[tstNewID] tstNewID_altAddress_v7
	on	tstNewID_altAddress_v7.[NewID] = altAddress_v7.[idfGeoLocationShared]
		and tstNewID_altAddress_v7.[idfTable] = 4572590000000	/*tlbGeoLocationShared*/
		and tstNewID_altAddress_v7.[idfKey1] = 1 /*Alternative Address*/
		and tstNewID_altAddress_v7.[strRowGuid] = @TempIdentifierKey
on	tstNewID_altAddress_v7.[idfKey1] = temp.[HumanActualAddlInfoUID]

update	temp
set		temp.[SchoolAddressID] = schAddress_v7.[idfGeoLocationShared]
from	#HumanActualAddlInfo temp
left join	[Giraffe].[dbo].[tlbGeoLocationShared] schAddress_v7
	inner join	[Giraffe].[dbo].[tstNewID] tstNewID_schAddress_v7
	on	tstNewID_schAddress_v7.[NewID] = schAddress_v7.[idfGeoLocationShared]
		and tstNewID_schAddress_v7.[idfTable] = 4572590000000	/*tlbGeoLocationShared*/
		and tstNewID_schAddress_v7.[idfKey1] = 2 /*School Address*/
		and tstNewID_schAddress_v7.[strRowGuid] = @TempIdentifierKey
on	tstNewID_schAddress_v7.[idfKey1] = temp.[HumanActualAddlInfoUID]

',
	ttm.strUpdateAfterInsert2 = N'
if db_name() like N''%_Archive'' collate Cyrillic_General_CI_AS and @IdMigrationPrefix not like N''%ARCH'' collate Cyrillic_General_CI_AS
	set	@IdMigrationPrefix = @IdMigrationPrefix + N''ARCH'' collate Cyrillic_General_CI_AS
update	temp
set		temp.[EIDSSPersonID] = N''PER'' + @IdMigrationPrefix + @YY + dbo.fnAlphaNumeric(@NumberOfExistingMigratedRecords + temp.idfId, @IdGenerateDigitNumber)
from	#HumanActualAddlInfo temp


insert into	[Giraffe].[dbo].[HumanActualAddlInfo]
(	[HumanActualAddlInfoUID],
	[EIDSSPersonID],
	[SchoolAddressID],
	[AltAddressID],
	[DeduplicationResultHumanActualID],
	[IsEmployedID],
	[EmployerPhoneNbr],
	[ContactPhoneNbr],
	[intRowStatus],
	[AuditCreateUser],
	[AuditCreateDTM],
	[AuditUpdateUser],
	[AuditUpdateDTM],
	[SourceSystemNameID],
	[SourceSystemKeyValue]
)
select	  temp.[HumanActualAddlInfoUID]
		, temp.[EIDSSPersonID]
		, temp.[SchoolAddressID]
		, temp.[AltAddressID]
		, null
		, [IsEmployedID]
		, [EmployerPhoneNbr]
		, [ContactPhoneNbr]
		, temp.intRowStatus
		, ''system''
		, GETUTCDATE()
		, ''system''
		, GETUTCDATE()
		, 10519002 /*Record Source: EIDSS6.1*/
		, N''[{'' + N''"HumanActualAddlInfoUID":'' + isnull(cast(temp.[HumanActualAddlInfoUID] as nvarchar(20)), N''null'') + N''}]'' collate Cyrillic_General_CI_AS
from	#HumanActualAddlInfo temp
--left join	[Giraffe].[dbo].[HumanActualAddlInfo] HumanActualAddlInfo_v7
--on	HumanActualAddlInfo_v7.[HumanActualAddlInfoUID] = temp.[HumanActualAddlInfoUID]
--where	HumanActualAddlInfo_v7.[HumanActualAddlInfoUID] is null
print N''Table [HumanActualAddlInfo] - insert new detailed info for persons from the catalog: '' + cast(@@rowcount as nvarchar(20))

IF OBJECT_ID(''tempdb..#HumanActualAddlInfo'') IS NOT NULL
	exec sp_executesql N''drop table #HumanActualAddlInfo''
' collate Cyrillic_General_CI_AS,
	ttm.strInsertFromJoins = replace(ttm.strInsertFromJoins, 
		N'j_trtBaseReference_idfsPersonIDType_v7.[idfsBaseReference] = tlbHumanActual_v6.[idfsPersonIDType]', 
		N'j_trtBaseReference_idfsPersonIDType_v7.[idfsBaseReference] = isnull(tlbHumanActual_v6.[idfsPersonIDType], 51577280000000 /*Unknown*/)'),
	ttm.strUpdateFromJoins = replace(ttm.strUpdateFromJoins, 
		N'j_trtBaseReference_idfsPersonIDType_v7.[idfsBaseReference] = tlbHumanActual_v6.[idfsPersonIDType]', 
		N'j_trtBaseReference_idfsPersonIDType_v7.[idfsBaseReference] = isnull(tlbHumanActual_v6.[idfsPersonIDType], 51577280000000 /*Unknown*/)')

from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tlbHumanActual' collate Cyrillic_General_CI_AS


update	ttm
set		ttm.strStatementBeforeInsert = N'
if DB_NAME() like N''%_Archive'' collate Latin1_General_CI_AS
begin
	set @ArchiveCmd = N''
INSERT INTO ['' + DB_NAME() + N''].[dbo].[tlbGeoLocationShared]
(	  [idfGeoLocationShared]
	, [idfsSite]
	, [idfsGeoLocationType]
	, [idfsCountry]
	, [idfsRegion]
	, [idfsRayon]
	, [idfsSettlement]
	, [strPostCode]
	, [strStreetName]
	, [strHouse]
	, [strBuilding]
	, [strApartment]
	, [dblLatitude]
	, [dblLongitude]
	, [intRowStatus]
	, [blnForeignAddress]
	, [strForeignAddress]
	, [SourceSystemNameID]
	, [SourceSystemKeyValue]
	, [AuditCreateUser]
	, [AuditCreateDTM]
	, [AuditUpdateUser]
	, [AuditUpdateDTM]
	, [idfsLocation]
)
SELECT	  tlbGeoLocationShared_v7_Actual.[idfGeoLocationShared]
		, tlbGeoLocationShared_v7_Actual.[idfsSite]
		, tlbGeoLocationShared_v7_Actual.[idfsGeoLocationType]
		, tlbGeoLocationShared_v7_Actual.[idfsCountry]
		, tlbGeoLocationShared_v7_Actual.[idfsRegion]
		, tlbGeoLocationShared_v7_Actual.[idfsRayon]
		, tlbGeoLocationShared_v7_Actual.[idfsSettlement]
		, tlbGeoLocationShared_v7_Actual.[strPostCode]
		, tlbGeoLocationShared_v7_Actual.[strStreetName]
		, tlbGeoLocationShared_v7_Actual.[strHouse]
		, tlbGeoLocationShared_v7_Actual.[strBuilding]
		, tlbGeoLocationShared_v7_Actual.[strApartment]
		, tlbGeoLocationShared_v7_Actual.[dblLatitude]
		, tlbGeoLocationShared_v7_Actual.[dblLongitude]
		, tlbGeoLocationShared_v7_Actual.[intRowStatus]
		, tlbGeoLocationShared_v7_Actual.[blnForeignAddress]
		, tlbGeoLocationShared_v7_Actual.[strForeignAddress]
		, tlbGeoLocationShared_v7_Actual.[SourceSystemNameID]
		, tlbGeoLocationShared_v7_Actual.[SourceSystemKeyValue]
		, tlbGeoLocationShared_v7_Actual.[AuditCreateUser]
		, tlbGeoLocationShared_v7_Actual.[AuditCreateDTM]
		, tlbGeoLocationShared_v7_Actual.[AuditUpdateUser]
		, tlbGeoLocationShared_v7_Actual.[AuditUpdateDTM]
		, tlbGeoLocationShared_v7_Actual.[idfsLocation]

FROM	['' + left(DB_NAME(), len(DB_NAME()) - 8) + N''].[dbo].[tlbFarmActual] tlbFarmActual_v7_Actual
join	[Falcon].[dbo].[tlbFarmActual] tlbFarmActual_v6_Archive
on		tlbFarmActual_v6_Archive.[idfFarmActual] = tlbFarmActual_v7_Actual.[idfFarmActual]
join	['' + left(DB_NAME(), len(DB_NAME()) - 8) + N''].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v7_Actual
on		tlbGeoLocationShared_v7_Actual.[idfGeoLocationShared] = tlbFarmActual_v7_Actual.[idfFarmAddress]
left join	['' + DB_NAME() + N''].[dbo].[tlbFarmActual] tlbFarmActual_v7_Archive
on		tlbFarmActual_v7_Archive.[idfFarmActual] = tlbFarmActual_v7_Actual.[idfFarmActual]
left join	['' + DB_NAME() + N''].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v7_Archive
on		tlbGeoLocationShared_v7_Archive.[idfGeoLocationShared] = tlbFarmActual_v7_Actual.[idfFarmAddress]

WHERE	tlbFarmActual_v7_Archive.[idfFarmActual] is null
		and tlbGeoLocationShared_v7_Archive.[idfGeoLocationShared] is null
print N''''Table [tlbGeoLocationShared] - Insert missing farm addresses by copying from actual database: '''' + cast(@@rowcount as nvarchar(20))
	
	''
	exec sp_executesql @ArchiveCmd
',
		ttm.strStatementBeforeInsert2 = N'

	set @ArchiveCmd = N''
INSERT INTO ['' + DB_NAME() + N''].[dbo].[tlbFarmActual]
(	  [idfFarmActual]
	, [idfsAvianFarmType]
	, [idfsAvianProductionType]
	, [idfsFarmCategory]
	, [idfsOwnershipStructure]
	, [idfsMovementPattern]
	, [idfsIntendedUse]
	, [idfsGrazingPattern]
	, [idfsLivestockProductionType]
	, [idfHumanActual]
	, [idfFarmAddress]
	, [strInternationalName]
	, [strNationalName]
	, [strFarmCode]
	, [strFax]
	, [strEmail]
	, [strContactPhone]
	, [intLivestockTotalAnimalQty]
	, [intAvianTotalAnimalQty]
	, [intLivestockSickAnimalQty]
	, [intAvianSickAnimalQty]
	, [intLivestockDeadAnimalQty]
	, [intAvianDeadAnimalQty]
	, [intBuidings]
	, [intBirdsPerBuilding]
	, [strNote]
	, [rowguid]
	, [intRowStatus]
	, [intHACode]
	, [datModificationDate]
	, [strMaintenanceFlag]
	, [strReservedAttribute]
	, [SourceSystemNameID]
	, [SourceSystemKeyValue]
	, [AuditCreateUser]
	, [AuditCreateDTM]
	, [AuditUpdateUser]
	, [AuditUpdateDTM]
)
SELECT	  tlbFarmActual_v7_Actual.[idfFarmActual]
		, tlbFarmActual_v7_Actual.[idfsAvianFarmType]
		, tlbFarmActual_v7_Actual.[idfsAvianProductionType]
		, tlbFarmActual_v7_Actual.[idfsFarmCategory]
		, tlbFarmActual_v7_Actual.[idfsOwnershipStructure]
		, tlbFarmActual_v7_Actual.[idfsMovementPattern]
		, tlbFarmActual_v7_Actual.[idfsIntendedUse]
		, tlbFarmActual_v7_Actual.[idfsGrazingPattern]
		, tlbFarmActual_v7_Actual.[idfsLivestockProductionType]
		, tlbFarmActual_v7_Actual.[idfHumanActual]
		, tlbFarmActual_v7_Actual.[idfFarmAddress]
		, tlbFarmActual_v7_Actual.[strInternationalName]
		, tlbFarmActual_v7_Actual.[strNationalName]
		, tlbFarmActual_v7_Actual.[strFarmCode]
		, tlbFarmActual_v7_Actual.[strFax]
		, tlbFarmActual_v7_Actual.[strEmail]
		, tlbFarmActual_v7_Actual.[strContactPhone]
		, tlbFarmActual_v7_Actual.[intLivestockTotalAnimalQty]
		, tlbFarmActual_v7_Actual.[intAvianTotalAnimalQty]
		, tlbFarmActual_v7_Actual.[intLivestockSickAnimalQty]
		, tlbFarmActual_v7_Actual.[intAvianSickAnimalQty]
		, tlbFarmActual_v7_Actual.[intLivestockDeadAnimalQty]
		, tlbFarmActual_v7_Actual.[intAvianDeadAnimalQty]
		, tlbFarmActual_v7_Actual.[intBuidings]
		, tlbFarmActual_v7_Actual.[intBirdsPerBuilding]
		, tlbFarmActual_v7_Actual.[strNote]
		, tlbFarmActual_v7_Actual.[rowguid]
		, tlbFarmActual_v7_Actual.[intRowStatus]
		, tlbFarmActual_v7_Actual.[intHACode]
		, tlbFarmActual_v7_Actual.[datModificationDate]
		, tlbFarmActual_v7_Actual.[strMaintenanceFlag]
		, tlbFarmActual_v7_Actual.[strReservedAttribute]
		, tlbFarmActual_v7_Actual.[SourceSystemNameID]
		, tlbFarmActual_v7_Actual.[SourceSystemKeyValue]
		, tlbFarmActual_v7_Actual.[AuditCreateUser]
		, tlbFarmActual_v7_Actual.[AuditCreateDTM]
		, tlbFarmActual_v7_Actual.[AuditUpdateUser]
		, tlbFarmActual_v7_Actual.[AuditUpdateDTM]

FROM	['' + left(DB_NAME(), len(DB_NAME()) - 8) + N''].[dbo].[tlbFarmActual] tlbFarmActual_v7_Actual
join	[Falcon].[dbo].[tlbFarmActual] tlbFarmActual_v6_Archive
on		tlbFarmActual_v6_Archive.[idfFarmActual] = tlbFarmActual_v7_Actual.[idfFarmActual]
left join	['' + DB_NAME() + N''].[dbo].[tlbFarmActual] tlbFarmActual_v7_Archive
on		tlbFarmActual_v7_Archive.[idfFarmActual] = tlbFarmActual_v7_Actual.[idfFarmActual]

WHERE	tlbFarmActual_v7_Archive.[idfFarmActual] is null
print N''''Table [tlbFarmActual] - Insert farms by copying from actual database: '''' + cast(@@rowcount as nvarchar(20))
	
	''
	exec sp_executesql @ArchiveCmd
end
',
		ttm.strInsertFromHeader = ttm.strInsertFromHeader + N'
	left join	[Giraffe].[dbo].[_dmccFarmActual] ccfa
	on			ccfa.[idfFarmActual_v6] = tlbFarmActual_v6.[idfFarmActual]
				and ccfa.[idfFarmActual_v7] is null
' collate Cyrillic_General_CI_AS,
		ttm.strSelectColumns = replace(ttm.strSelectColumns,
			N'tlbFarmActual_v6.[strFarmCode]',
			N'isnull(ccfa.[strFarmCode_v7], tlbFarmActual_v6.[strFarmCode])'),
		ttm.strUpdateColumns = replace(ttm.strUpdateColumns,
			N'tlbFarmActual_v7.[strFarmCode] = tlbFarmActual_v6.[strFarmCode],',--TODO: check if comma is in correct place
			N''),
		ttm.strUpdateAfterInsert = N'
update		ccfa
set			ccfa.[idfFarmActual_v7] = tlbFarmActual_v7.[idfFarmActual]
from		[Giraffe].[dbo].[_dmccFarmActual] ccfa
inner join	[Giraffe].[dbo].[tlbFarmActual] tlbFarmActual_v7
on			tlbFarmActual_v7.[idfFarmActual] = ccfa.[idfFarmActual_v6]
where		ccfa.[idfFarmActual_v7] is null
'
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tlbFarmActual' collate Cyrillic_General_CI_AS


update	ttm
set		ttm.strInsertFromHeader = replace(replace(ttm.strInsertFromHeader, 
			N'from [Falcon].[dbo].[tlbObservation] tlbObservation_v6', 
			N'from [Falcon].[dbo].[tlbObservation] tlbObservation_v6
left join	[Giraffe].[dbo].[_dmccObservation] ccobs
on			ccobs.idfObservation_v6 = tlbObservation_v6.[idfObservation]'), 
				N'tlbObservation_v7.[idfObservation] = tlbObservation_v6.[idfObservation]', 
				N'tlbObservation_v7.[idfObservation] = isnull(ccobs.idfObservation_v7, tlbObservation_v6.[idfObservation])'),
		ttm.strInsertFromJoins = replace(replace(ttm.strInsertFromJoins, 
			N'tlbObservation_v7.[idfObservation] = tlbObservation_v6.[idfObservation]', 
			N'tlbObservation_v7.[idfObservation] = isnull(ccobs.idfObservation_v7, tlbObservation_v6.[idfObservation])'),
				N'j_ffFormTemplate_idfsFormTemplate_v7.[idfsFormTemplate] = tlbObservation_v6.[idfsFormTemplate]',
				N'j_ffFormTemplate_idfsFormTemplate_v7.[idfsFormTemplate] = isnull(ccobs.idfsTemplate_v7, tlbObservation_v6.[idfsFormTemplate])'),
		ttm.strSelectColumns = replace(ttm.strSelectColumns, 
			N'tlbObservation_v6.[idfObservation]', 
			N'isnull(ccobs.idfObservation_v7, tlbObservation_v6.[idfObservation])'),
		ttm.strUpdateFromHeader = replace(replace(ttm.strUpdateFromHeader, 
			N'inner join	[Falcon].[dbo].[tlbObservation] tlbObservation_v6', 
			N'inner join	[Falcon].[dbo].[tlbObservation] tlbObservation_v6
	left join	[Giraffe].[dbo].[_dmccObservation] ccobs
	on			ccobs.idfObservation_v6 = tlbObservation_v6.[idfObservation]'), 
				N'tlbObservation_v7.[idfObservation] = tlbObservation_v6.[idfObservation]', 
				N'tlbObservation_v7.[idfObservation] = isnull(ccobs.idfObservation_v7, tlbObservation_v6.[idfObservation])'),
		ttm.strUpdateFromJoins = replace(ttm.strUpdateFromJoins, 
			N'j_ffFormTemplate_idfsFormTemplate_v7.[idfsFormTemplate] = tlbObservation_v6.[idfsFormTemplate]', 
			N'j_ffFormTemplate_idfsFormTemplate_v7.[idfsFormTemplate] = isnull(ccobs.idfsTemplate_v7, tlbObservation_v6.[idfsFormTemplate])'),
		ttm.strStatementBeforeInsert = N'
insert into	[Giraffe].[dbo].[tlbObservation]
(	[idfObservation],
	[idfsFormTemplate],
	[intRowStatus],
	[idfsSite],
	[SourceSystemNameID],
	[SourceSystemKeyValue],
	[AuditCreateUser],
	[AuditCreateDTM],
	[AuditUpdateUser],
	[AuditUpdateDTM]
)
select		  ccnobs.[idfObservation_v7]
			, ccnobs.[idfsFormTemplate]
			, ccnobs.[intRowStatus]
			, ccnobs.[idfsSite]
			, ccnobs.[SourceSystemNameID]
			, ccnobs.[SourceSystemKeyValue]
			, ccnobs.[AuditCreateUser]
			, ccnobs.[AuditCreateDTM]
			, ccnobs.[AuditUpdateUser]
			, ccnobs.[AuditUpdateDTM]
from		[Giraffe].[dbo].[_dmccNewObservation] ccnobs
left join	[Giraffe].[dbo].[tlbObservation] tlbObservation_v7
on			tlbObservation_v7.[idfObservation] = ccnobs.[idfObservation_v7]
where		tlbObservation_v7.[idfObservation] is null
print N''Table [tlbObservation] - insert new FF instances that were missing in v6.1: '' + cast(@@rowcount as nvarchar(20))

'
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tlbObservation' collate Cyrillic_General_CI_AS

update	ttm
set		ttm.strInsertFromHeader = replace(replace(ttm.strInsertFromHeader, 
			N'from [Falcon].[dbo].[tlbActivityParameters] tlbActivityParameters_v6', 
			N'from [Falcon].[dbo].[tlbActivityParameters] tlbActivityParameters_v6
left join	[Giraffe].[dbo].[_dmccActivityParameters] ccap
on			ccap.idfActivityParameters_v6 = tlbActivityParameters_v6.[idfActivityParameters]'), 
				N'tlbActivityParameters_v7.[idfActivityParameters] = tlbActivityParameters_v6.[idfActivityParameters]', 
				N'tlbActivityParameters_v7.[idfActivityParameters] = isnull(ccap.idfActivityParameters_v7, tlbActivityParameters_v6.[idfActivityParameters])'),
		ttm.strInsertFromJoins = replace(replace(ttm.strInsertFromJoins, 
			N'tlbActivityParameters_v7.[idfActivityParameters] = tlbActivityParameters_v6.[idfActivityParameters]', 
			N'tlbActivityParameters_v7.[idfActivityParameters] = isnull(ccap.idfActivityParameters_v7, tlbActivityParameters_v6.[idfActivityParameters])'),
				N'j_tlbObservation_idfObservation_v7.[idfObservation] = tlbActivityParameters_v6.[idfObservation]',
				N'j_tlbObservation_idfObservation_v7.[idfObservation] = isnull(ccap.idfObservation_v7, tlbActivityParameters_v6.[idfObservation])'),
		ttm.strSelectColumns = replace(ttm.strSelectColumns, 
			N'tlbActivityParameters_v6.[idfActivityParameters]', 
			N'isnull(ccap.idfActivityParameters_v7, tlbActivityParameters_v6.[idfActivityParameters])'),
		ttm.strUpdateFromHeader = replace(replace(ttm.strUpdateFromHeader, 
			N'inner join	[Falcon].[dbo].[tlbActivityParameters] tlbActivityParameters_v6', 
			N'inner join	[Falcon].[dbo].[tlbActivityParameters] tlbActivityParameters_v6
	left join	[Giraffe].[dbo].[_dmccActivityParameters] ccap
	on			ccap.idfActivityParameters_v6 = tlbActivityParameters_v6.[idfActivityParameters]'), 
				N'tlbActivityParameters_v7.[idfActivityParameters] = tlbActivityParameters_v6.[idfActivityParameters]', 
				N'tlbActivityParameters_v7.[idfActivityParameters] = isnull(ccap.idfActivityParameters_v7, tlbActivityParameters_v6.[idfActivityParameters])'),
		ttm.strUpdateFromJoins = replace(ttm.strUpdateFromJoins, 
			N'j_tlbObservation_idfObservation_v7.[idfObservation] = tlbActivityParameters_v6.[idfObservation]', 
			N'j_tlbObservation_idfObservation_v7.[idfObservation] = isnull(ccap.idfObservation_v7, tlbActivityParameters_v6.[idfObservation])')
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tlbActivityParameters' collate Cyrillic_General_CI_AS





update	ttm
set		ttm.strInsertFromHeader = replace(replace(ttm.strInsertFromHeader, 
			N'from [Falcon].[dbo].[tlbGeoLocation] tlbGeoLocation_v6', 
			N'from [Falcon].[dbo].[tlbGeoLocation] tlbGeoLocation_v6
left join	[Giraffe].[dbo].[_dmccGeoLocation] ccgl
on			ccgl.idfGeoLocation_v6 = tlbGeoLocation_v6.[idfGeoLocation]'), 
				N'tlbGeoLocation_v7.[idfGeoLocation] = tlbGeoLocation_v6.[idfGeoLocation]', 
				N'tlbGeoLocation_v7.[idfGeoLocation] = isnull(ccgl.idfGeoLocation_v7, tlbGeoLocation_v6.[idfGeoLocation])'),
		ttm.strInsertFromJoins = replace(ttm.strInsertFromJoins, 
			N'tlbGeoLocation_v7.[idfGeoLocation] = tlbGeoLocation_v6.[idfGeoLocation]', 
			N'tlbGeoLocation_v7.[idfGeoLocation] = isnull(ccgl.idfGeoLocation_v7, tlbGeoLocation_v6.[idfGeoLocation])'),
		ttm.strSelectColumns = replace(ttm.strSelectColumns, 
			N'tlbGeoLocation_v6.[idfGeoLocation]', 
			N'isnull(ccgl.idfGeoLocation_v7, tlbGeoLocation_v6.[idfGeoLocation])'),
		ttm.strUpdateFromHeader = replace(replace(ttm.strUpdateFromHeader, 
			N'inner join	[Falcon].[dbo].[tlbGeoLocation] tlbGeoLocation_v6', 
			N'inner join	[Falcon].[dbo].[tlbGeoLocation] tlbGeoLocation_v6
	left join	[Giraffe].[dbo].[_dmccGeoLocation] ccgl
	on			ccgl.idfGeoLocation_v6 = tlbGeoLocation_v6.[idfGeoLocation]'), 
				N'tlbGeoLocation_v7.[idfGeoLocation] = tlbGeoLocation_v6.[idfGeoLocation]', 
				N'tlbGeoLocation_v7.[idfGeoLocation] = isnull(ccgl.idfGeoLocation_v7, tlbGeoLocation_v6.[idfGeoLocation])'),
		ttm.strStatementBeforeInsert = N'
insert into	[Giraffe].[dbo].[tlbGeoLocation]
(	  [idfGeoLocation]
	, [idfsSite]
	, [idfsGeoLocationType]
	, [idfsCountry]
	, [blnForeignAddress]
	, [intRowStatus]
	, [SourceSystemNameID]
	, [SourceSystemKeyValue]
	, [AuditCreateUser]
	, [AuditCreateDTM]
	, [AuditUpdateUser]
	, [AuditUpdateDTM]
	, [idfsLocation]
)
select		  ccngl.[idfGeoLocation_v7]
			, ccngl.[idfsSite]
			, ccngl.[idfsGeoLocationType]
			, ccngl.[idfsCountry]
			, ccngl.[blnForeignAddress]
			, ccngl.[intRowStatus]
			, ccngl.[SourceSystemNameID]
			, ccngl.[SourceSystemKeyValue]
			, ccngl.[AuditCreateUser]
			, ccngl.[AuditCreateDTM]
			, ccngl.[AuditUpdateUser]
			, ccngl.[AuditUpdateDTM]
			, ccngl.[idfsLocation]
from		[Giraffe].[dbo].[_dmccNewGeoLocation] ccngl
left join	[Giraffe].[dbo].[tlbGeoLocation] tlbGeoLocation_v7
on			tlbGeoLocation_v7.[idfGeoLocation] = ccngl.[idfGeoLocation_v7]
where		tlbGeoLocation_v7.[idfGeoLocation] is null
print N''Table [tlbGeoLocation] - insert new Addresses/Locations that were missing in v6.1: '' + cast(@@rowcount as nvarchar(20))

'
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tlbGeoLocation' collate Cyrillic_General_CI_AS


--TODO: check if inner join to _dmccHuman fits transfer of all persons in the system
update	ttm
set		ttm.strInsertFromHeader = replace(replace(ttm.strInsertFromHeader, 
			N'from [Falcon].[dbo].[tlbHuman] tlbHuman_v6', 
			N'from [Falcon].[dbo].[tlbHuman] tlbHuman_v6
inner join	[Giraffe].[dbo].[_dmccHuman] cch
on			cch.idfHuman_v6 = tlbHuman_v6.[idfHuman]'), 
				N'tlbHuman_v7.[idfHuman] = tlbHuman_v6.[idfHuman]', 
				N'tlbHuman_v7.[idfHuman] = cch.idfHuman_v7'),
		ttm.strInsertFromJoins = replace(replace(replace(replace(ttm.strInsertFromJoins, 
			N'tlbHuman_v7.[idfHuman] = tlbHuman_v6.[idfHuman]', 
			N'tlbHuman_v7.[idfHuman] = cch.[idfHuman_v7]'),
				N'j_tlbGeoLocation_idfCurrentResidenceAddress_v7.[idfGeoLocation] = tlbHuman_v6.[idfCurrentResidenceAddress]',
				N'j_tlbGeoLocation_idfCurrentResidenceAddress_v7.[idfGeoLocation] = cch.[idfHumanCRAddress_v7]'),
					N'j_tlbGeoLocation_idfRegistrationAddress_v7.[idfGeoLocation] = tlbHuman_v6.[idfRegistrationAddress]',
					N'j_tlbGeoLocation_idfRegistrationAddress_v7.[idfGeoLocation] = cch.[idfHumanPRAddress_v7]'),
						N'j_tlbGeoLocation_idfEmployerAddress_v7.[idfGeoLocation] = tlbHuman_v6.[idfEmployerAddress]',
						N'j_tlbGeoLocation_idfEmployerAddress_v7.[idfGeoLocation] = cch.[idfHumanEmpAddress_v7]'),
		ttm.strSelectColumns = replace(ttm.strSelectColumns, 
			N'tlbHuman_v6.[idfHuman]', 
			N'cch.idfHuman_v7'),
		ttm.strUpdateFromHeader = replace(replace(ttm.strUpdateFromHeader, 
			N'inner join	[Falcon].[dbo].[tlbHuman] tlbHuman_v6', 
			N'inner join	[Falcon].[dbo].[tlbHuman] tlbHuman_v6
	inner join	[Giraffe].[dbo].[_dmccHuman] cch
	on			cch.idfHuman_v6 = tlbHuman_v6.[idfHuman]'), 
				N'tlbHuman_v7.[idfHuman] = tlbHuman_v6.[idfHuman]', 
				N'tlbHuman_v7.[idfHuman] = cch.idfHuman_v7'),
		ttm.strUpdateFromJoins = replace(replace(replace(ttm.strUpdateFromJoins, 
			N'j_tlbGeoLocation_idfCurrentResidenceAddress_v7.[idfGeoLocation] = tlbHuman_v6.[idfCurrentResidenceAddress]', 
			N'j_tlbGeoLocation_idfCurrentResidenceAddress_v7.[idfGeoLocation] = cch.[idfHumanCRAddress_v7]'),
				N'j_tlbGeoLocation_idfRegistrationAddress_v7.[idfGeoLocation] = tlbHuman_v6.[idfRegistrationAddress]',
				N'j_tlbGeoLocation_idfRegistrationAddress_v7.[idfGeoLocation] = cch.[idfHumanPRAddress_v7]'),
					N'j_tlbGeoLocation_idfEmployerAddress_v7.[idfGeoLocation] = tlbHuman_v6.[idfEmployerAddress]',
					N'j_tlbGeoLocation_idfEmployerAddress_v7.[idfGeoLocation] = cch.[idfHumanEmpAddress_v7]'),
		ttm.strUpdateAfterInsert = N'
insert into	[Giraffe].[dbo].[HumanAddlInfo]
(	[HumanAdditionalInfo],
	[ReportedAge],
	[ReportedAgeUOMID],
	[ReportedAgeDTM],
	[SchoolAddressID],
	[AltAddressID],
	[IsEmployedID],
	[EmployerPhoneNbr],
	[ContactPhoneNbr],
	[intRowStatus],
	[AuditCreateUser],
	[AuditCreateDTM],
	[AuditUpdateUser],
	[AuditUpdateDTM],
	[SourceSystemNameID],
	[SourceSystemKeyValue]
)
select	  cch.[idfHuman_v7]
		, tlbHumanCase_v6.[intPatientAge]
		, tlbHumanCase_v6.[idfsHumanAgeType]
		, coalesce(tlbHumanCase_v6.[datOnSetDate], tlbHumanCase_v6.[datNotificationDate], tlbHumanCase_v6.[datEnteredDate])
		, j_tlbGeoLocation_SchoolAddressID_v7.[idfGeoLocation]
		, j_tlbGeoLocation_AltAddressID_v7.[idfGeoLocation]
		, cch.[IsEmployedID]
		, cch.[EmployerPhoneNbr]
		, cch.[ContactPhoneNbr]
		, tlbHuman_v7.[intRowStatus]
		, ''system''
		, GETUTCDATE()
		, ''system''
		, GETUTCDATE()
		, 10519002 /*Record Source: EIDSS6.1*/
		, N''[{'' + N''"HumanAdditionalInfo":'' + isnull(cast(cch.[idfHuman_v7] as nvarchar(20)), N''null'') + N''}]'' collate Cyrillic_General_CI_AS
from	[Giraffe].[dbo].[_dmccHuman] cch
inner join	[Giraffe].[dbo].[tlbHuman] tlbHuman_v7
on	tlbHuman_v7.[idfHuman] = cch.[idfHuman_v7]
left join	[Falcon].[dbo].[tlbHumanCase] tlbHumanCase_v6
on			tlbHumanCase_v6.[idfHumanCase] = cch.[idfHumanCase_v6]
left join	[Giraffe].[dbo].[tlbGeoLocation] j_tlbGeoLocation_SchoolAddressID_v7
on	j_tlbGeoLocation_SchoolAddressID_v7.[idfGeoLocation] = cch.[idfHumanSchAddress_v7]
left join	[Giraffe].[dbo].[tlbGeoLocation] j_tlbGeoLocation_AltAddressID_v7
on	j_tlbGeoLocation_AltAddressID_v7.[idfGeoLocation] = cch.[idfHumanAltAddress_v7]
left join	[Giraffe].[dbo].[HumanAddlInfo] HumanAddlInfo_v7
on	HumanAddlInfo_v7.[HumanAdditionalInfo] = cch.[idfHuman_v7]
where	HumanAddlInfo_v7.[HumanAdditionalInfo] is null
print N''Table [HumanAddlInfo] - insert new detailed info (including reported Age) for copies of the persons: '' + cast(@@rowcount as nvarchar(20))

'
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tlbHuman' collate Cyrillic_General_CI_AS



update	ttm
set		ttm.strInsertFromJoins = replace(replace(ttm.strInsertFromJoins, 
			N'left join	[Giraffe].[dbo].[tlbHuman] j_tlbHuman_idfHuman_v7', 
			N'left join	[Giraffe].[dbo].[_dmccHuman] cch
						inner join	[Giraffe].[dbo].[tlbHuman] j_tlbHuman_idfHuman_v7
						on	j_tlbHuman_idfHuman_v7.[idfHuman] = cch.[idfHuman_v7]'),
				N'j_tlbHuman_idfHuman_v7.[idfHuman] = tlbFarm_v6.[idfHuman]',
				N'cch.[idfHuman_V6] = tlbFarm_v6.[idfHuman] and cch.[idfFarm_v6] = tlbFarm_v6.[idfFarm] and cch.[idfFarm_v7] = tlbFarm_v6.[idfFarm]'),
		ttm.strSelectColumns = replace(ttm.strSelectColumns,
			N'tlbFarm_v6.[strFarmCode]',
			N'isnull(j_tlbFarmActual_idfFarmActual_v7.[strFarmCode], tlbFarm_v6.[strFarmCode])'),
		ttm.strUpdateFromJoins = replace(replace(ttm.strUpdateFromJoins, 
			N'left join	[Giraffe].[dbo].[tlbHuman] j_tlbHuman_idfHuman_v7', 
			N'left join	[Giraffe].[dbo].[_dmccHuman] cch
						inner join	[Giraffe].[dbo].[tlbHuman] j_tlbHuman_idfHuman_v7
						on	j_tlbHuman_idfHuman_v7.[idfHuman] = cch.[idfHuman_v7]'),
				N'j_tlbHuman_idfHuman_v7.[idfHuman] = tlbFarm_v6.[idfHuman]',
				N'cch.[idfHuman_V6] = tlbFarm_v6.[idfHuman] and cch.[idfFarm_v6] = tlbFarm_v6.[idfFarm] and cch.[idfFarm_v7] = tlbFarm_v6.[idfFarm]'),
		ttm.strUpdateColumns = replace(ttm.strUpdateColumns, 
			N'tlbFarm_v6.[strFarmCode]', 
			N'isnull(j_tlbFarmActual_idfFarmActual_v7.[strFarmCode], tlbFarm_v6.[strFarmCode])')
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tlbFarm' collate Cyrillic_General_CI_AS


update	ttm
set		ttm.strUpdateAfterInsert = N'
update		tlbFreezerSubdivision_v7
set			tlbFreezerSubdivision_v7.idfParentSubdivision = tlbFreezerSubdivision_parent_v7.idfSubdivision
from		[Giraffe].[dbo].[tlbFreezerSubdivision] tlbFreezerSubdivision_v7
inner join	[Falcon].[dbo].[tlbFreezerSubdivision] tlbFreezerSubdivision_v6
on			tlbFreezerSubdivision_v6.idfSubdivision = tlbFreezerSubdivision_v7.idfSubdivision
inner join	[Giraffe].[dbo].[tlbFreezerSubdivision] tlbFreezerSubdivision_parent_v7
on			tlbFreezerSubdivision_parent_v7.idfSubdivision = tlbFreezerSubdivision_v6.idfParentSubdivision
where		tlbFreezerSubdivision_V7.idfParentSubdivision is null
print	N''Table [tlbFreezerSubdivision] - update link to the parent subdivision from migrated subdivisions: '' + cast(@@rowcount as nvarchar(20))

'
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tlbFreezerSubdivision' collate Cyrillic_General_CI_AS



update	ttm
set		ttm.strInsertFromHeader = replace(ttm.strInsertFromHeader, 
			N'from [Falcon].[dbo].[tlbOutbreak] tlbOutbreak_v6', 
			N'from [Falcon].[dbo].[tlbOutbreak] tlbOutbreak_v6
outer apply
(	select	count(tlbHumanCase_childForOutbreak_v6.[idfHumanCase]) as intCount
	from	[Falcon].[dbo].[tlbHumanCase] tlbHumanCase_childForOutbreak_v6
	where	tlbHumanCase_childForOutbreak_v6.[idfOutbreak] = tlbOutbreak_v6.[idfOutbreak]
			and tlbHumanCase_childForOutbreak_v6.[intRowStatus] <= tlbOutbreak_v6.[intRowStatus]
) hc_count
outer apply
(	select	count(tlbVetCase_childForOutbreak_v6.[idfVetCase]) as intCount
	from	[Falcon].[dbo].[tlbVetCase] tlbVetCase_childForOutbreak_v6
	where	tlbVetCase_childForOutbreak_v6.[idfOutbreak] = tlbOutbreak_v6.[idfOutbreak]
			and tlbVetCase_childForOutbreak_v6.[intRowStatus] <= tlbOutbreak_v6.[intRowStatus]
) vc_count
outer apply
(	select	count(tlbVSS_childForOutbreak_v6.[idfVectorSurveillanceSession]) as intCount
	from	[Falcon].[dbo].[tlbVectorSurveillanceSession] tlbVSS_childForOutbreak_v6
	where	tlbVSS_childForOutbreak_v6.[idfOutbreak] = tlbOutbreak_v6.[idfOutbreak]
			and tlbVSS_childForOutbreak_v6.[intRowStatus] <= tlbOutbreak_v6.[intRowStatus]
) vss_count
'),
		ttm.strInsertFromJoins = replace(ttm.strInsertFromJoins, 
			N'j_trtBaseReference_idfsOutbreakStatus_v7.[idfsBaseReference] = tlbOutbreak_v6.[idfsOutbreakStatus]',
			N'(	(j_trtBaseReference_idfsOutbreakStatus_v7.[idfsBaseReference] = 10063503 /*Not an Outbreak*/ and tlbOutbreak_v6.[idfsOutbreakStatus] = 53418740000000 /*Not an Outbreak*/)
		or (j_trtBaseReference_idfsOutbreakStatus_v7.[idfsBaseReference] = 10063501 /*In Progress*/ and (tlbOutbreak_v6.[idfsOutbreakStatus] is null or tlbOutbreak_v6.[idfsOutbreakStatus] <> 53418740000000 /*Not an Outbreak*/) and tlbOutbreak_v6.[datFinishDate] is null)
		or (j_trtBaseReference_idfsOutbreakStatus_v7.[idfsBaseReference] = 10063502 /*Closed*/ and (tlbOutbreak_v6.[idfsOutbreakStatus] is null or tlbOutbreak_v6.[idfsOutbreakStatus] <> 53418740000000 /*Not an Outbreak*/) and tlbOutbreak_v6.[datFinishDate] is not null))'),
		ttm.strUpdateFromJoins = replace(ttm.strInsertFromJoins, 
			N'j_trtBaseReference_idfsOutbreakStatus_v7.[idfsBaseReference] = tlbOutbreak_v6.[idfsOutbreakStatus]',
			N'(	(j_trtBaseReference_idfsOutbreakStatus_v7.[idfsBaseReference] = 10063503 /*Not an Outbreak*/ and tlbOutbreak_v6.[idfsOutbreakStatus] = 53418740000000 /*Not an Outbreak*/)
		or (j_trtBaseReference_idfsOutbreakStatus_v7.[idfsBaseReference] = 10063501 /*In Progress*/ and (tlbOutbreak_v6.[idfsOutbreakStatus] is null or tlbOutbreak_v6.[idfsOutbreakStatus] <> 53418740000000 /*Not an Outbreak*/) and tlbOutbreak_v6.[datFinishDate] is null)
		or (j_trtBaseReference_idfsOutbreakStatus_v7.[idfsBaseReference] = 10063502 /*Closed*/ and (tlbOutbreak_v6.[idfsOutbreakStatus] is null or tlbOutbreak_v6.[idfsOutbreakStatus] <> 53418740000000 /*Not an Outbreak*/) and tlbOutbreak_v6.[datFinishDate] is not null))'),
		ttm.strUpdateAfterInsert = N'
update		tlbOutbreak_v7
set			tlbOutbreak_v7.[idfPrimaryCaseOrSession] = coalesce(tlbHumanCase_v7.[idfHumanCase], tlbVetCase_v7.[idfVetCase], tlbVectorSurveillanceSession_v7.[idfVectorSurveillanceSession])
from		[Giraffe].[dbo].[tlbOutbreak] tlbOutbreak_v7
inner join	[Falcon].[dbo].[tlbOutbreak] tlbOutbreak_v6
on			tlbOutbreak_v6.[idfOutbreak] = tlbOutbreak_v7.[idfOutbreak]
left join	[Giraffe].[dbo].[_dmccHumanCase] cchc
	inner join	[Giraffe].[dbo].[tlbHumanCase] tlbHumanCase_v7
	on			tlbHumanCase_v7.[idfHumanCase] = cchc.[idfHumanCase_v7]
on			cchc.[idfHumanCase_v6] = tlbOutbreak_v6.[idfPrimaryCaseOrSession]
left join	[Giraffe].[dbo].[tlbVetCase] tlbVetCase_v7
on			tlbVetCase_v7.[idfVetCase] = tlbOutbreak_v6.[idfPrimaryCaseOrSession]
left join	[Giraffe].[dbo].[tlbVectorSurveillanceSession] tlbVectorSurveillanceSession_v7
on			tlbVectorSurveillanceSession_v7.[idfVectorSurveillanceSession] = tlbOutbreak_v6.[idfPrimaryCaseOrSession]
where		tlbOutbreak_v7.[idfPrimaryCaseOrSession] is null
print	N''Table [tlbOutbreak] - update link to the primary case/session from migrated outbreaks: '' + cast(@@rowcount as nvarchar(20))

'
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tlbOutbreak' collate Cyrillic_General_CI_AS




update	ttm
set		ttm.strUpdateAfterInsert = N'
update		tlbVector_v7
set			tlbVector_v7.idfHostVector = tlbVector_host_v7.idfVector
from		[Giraffe].[dbo].[tlbVector] tlbVector_v7
inner join	[Falcon].[dbo].[tlbVector] tlbVector_v6
on			tlbVector_v6.idfVector = tlbVector_v7.idfVector
inner join	[Giraffe].[dbo].[tlbVector] tlbVector_host_v7
on			tlbVector_host_v7.idfVector = tlbVector_v6.idfHostVector
where		tlbVector_V7.idfHostVector is null
print	N''Table [tlbVector] - update link to the host Vector from migrated vectors: '' + cast(@@rowcount as nvarchar(20))

'
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tlbVector' collate Cyrillic_General_CI_AS



update	ttm
set		ttm.strUpdateAfterInsert = N'
update		tlbFarm_v7
set			tlbFarm_v7.[idfMonitoringSession] = tlbMonitoringSession_v7.[idfMonitoringSession]
from		[Giraffe].[dbo].[tlbFarm] tlbFarm_v7
inner join	[Falcon].[dbo].[tlbFarm] tlbFarm_v6
on			tlbFarm_v6.[idfFarm] = tlbFarm_v7.[idfFarm]
inner join	[Giraffe].[dbo].[tlbMonitoringSession] tlbMonitoringSession_v7
on			tlbMonitoringSession_v7.[idfMonitoringSession] = tlbFarm_v6.[idfMonitoringSession]
where		tlbFarm_v7.[idfMonitoringSession] is null
print	N''Table [tlbFarm] - update link to the AS Session from migrated copies of farms: '' + cast(@@rowcount as nvarchar(20))

'
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tlbMonitoringSession' collate Cyrillic_General_CI_AS



update	ttm
set		ttm.strInsertFromHeader = replace(replace(ttm.strInsertFromHeader, 
			N'from [Falcon].[dbo].[tlbHumanCase] tlbHumanCase_v6', 
			N'from [Falcon].[dbo].[tlbHumanCase] tlbHumanCase_v6
inner join	[Giraffe].[dbo].[_dmccHumanCase] cchc
on			cchc.idfHumanCase_v6 = tlbHumanCase_v6.[idfHumanCase]'), 
				N'tlbHumanCase_v7.[idfHumanCase] = tlbHumanCase_v6.[idfHumanCase]', 
				N'tlbHumanCase_v7.[idfHumanCase] = cchc.idfHumanCase_v7'),
		ttm.strInsertFromJoins = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(ttm.strInsertFromJoins, 
			N'tlbHumanCase_v7.[idfHumanCase] = tlbHumanCase_v6.[idfHumanCase]', 
			N'tlbHumanCase_v7.[idfHumanCase] = cchc.idfHumanCase_v7'),
				N'j_tlbGeoLocation_idfPointGeoLocation_v7.[idfGeoLocation] = tlbHumanCase_v6.[idfPointGeoLocation]',
				N'j_tlbGeoLocation_idfPointGeoLocation_v7.[idfGeoLocation] = cchc.[idfPointGeoLocation_v7]'),
					N'j_tlbObservation_idfCSObservation_v7.[idfObservation] = tlbHumanCase_v6.[idfCSObservation]',
					N'j_tlbObservation_idfCSObservation_v7.[idfObservation] = cchc.[idfCSObservation_v7]'),
						N'j_tlbObservation_idfEpiObservation_v7.[idfObservation] = tlbHumanCase_v6.[idfEpiObservation]',
						N'j_tlbObservation_idfEpiObservation_v7.[idfObservation] = cchc.[idfEpiObservation_v7]'),
							N'j_tlbHuman_idfHuman_v7.[idfHuman] = tlbHumanCase_v6.[idfHuman]',
							N'j_tlbHuman_idfHuman_v7.[idfHuman] = cchc.[idfHuman_v7]'),
								N'j_tlbOutbreak_idfOutbreak_v7.[idfOutbreak] = tlbHumanCase_v6.[idfOutbreak]',
								N'j_tlbOutbreak_idfOutbreak_v7.[idfOutbreak] = cchc.[idfOutbreak_v7]'),
									N'j_trtDiagnosis_idfsTentativeDiagnosis_v7.[idfsDiagnosis] = tlbHumanCase_v6.[idfsTentativeDiagnosis]',
									N'j_trtDiagnosis_idfsTentativeDiagnosis_v7.[idfsDiagnosis] = cchc.[idfsTentativeDiagnosis]'),
										N'j_trtDiagnosis_idfsFinalDiagnosis_v7.[idfsDiagnosis] = tlbHumanCase_v6.[idfsFinalDiagnosis]',
										N'j_trtDiagnosis_idfsFinalDiagnosis_v7.[idfsDiagnosis] = cchc.[idfsFinalDiagnosis]'),
											N'j_trtBaseReference_idfsCaseProgressStatus_v7.[idfsBaseReference] = tlbHumanCase_v6.[idfsCaseProgressStatus]',
											N'j_trtBaseReference_idfsCaseProgressStatus_v7.[idfsBaseReference] = cchc.[idfsCaseProgressStatus_v7]'),
												N'j_trtBaseReference_idfsFinalCaseStatus_v7.[idfsBaseReference] = tlbHumanCase_v6.[idfsFinalCaseStatus]',
												N'j_trtBaseReference_idfsFinalCaseStatus_v7.[idfsBaseReference] = cchc.[idfsFinalCaseStatus_v7]'),
		ttm.strSelectColumns = replace(replace(replace(replace(replace(replace(replace(replace(replace(ttm.strSelectColumns, 
			N'tlbHumanCase_v6.[idfHumanCase]', 
			N'cchc.idfHumanCase_v7'), 
				N'tlbHumanCase_v6.[datTentativeDiagnosisDate]', 
				N'cchc.[datTentativeDiagnosisDate]'), 
					N'tlbHumanCase_v6.[datFinalDiagnosisDate]', 
					N'cchc.[datFinalDiagnosisDate]'), 
						N'tlbHumanCase_v6.[strCaseID]', 
						N'cchc.[strCaseID_v7]'), 
							N'tlbHumanCase_v6.[strNote]', 
							N'cchc.[strNote]'), 
								N'tlbHumanCase_v6.[blnClinicalDiagBasis]', 
								N'cchc.[blnClinicalDiagBasis_v7]'), 
									N'tlbHumanCase_v6.[blnEpiDiagBasis]', 
									N'cchc.[blnEpiDiagBasis_v7]'), 
										N'tlbHumanCase_v6.[blnLabDiagBasis]', 
										N'cchc.[blnLabDiagBasis_v7]'), 
											N'tlbHumanCase_v6.[datFinalCaseClassificationDate]', 
											N'cchc.[datFinalCaseClassificationDate_v7]'),
		ttm.strUpdateFromHeader = replace(replace(ttm.strUpdateFromHeader, 
			N'inner join	[Falcon].[dbo].[tlbHumanCase] tlbHumanCase_v6', 
			N'inner join	[Falcon].[dbo].[tlbHumanCase] tlbHumanCase_v6
	inner join	[Giraffe].[dbo].[_dmccHumanCase] cchc
	on			cchc.idfHumanCase_v6 = tlbHuman_v6.[idfHumanCase]'), 
				N'tlbHumanCase_v7.[idfHumanCase] = tlbHumanCase_v6.[idfHumanCase]', 
				N'tlbHumanCase_v7.[idfHumanCase] = cchc.idfHumanCase_v7'),
		ttm.strUpdateFromJoins = replace(replace(replace(replace(replace(ttm.strUpdateFromJoins, 
			N'j_tlbGeoLocation_idfPointGeoLocation_v7.[idfGeoLocation] = tlbHumanCase_v6.[idfPointGeoLocation]',
			N'j_tlbGeoLocation_idfPointGeoLocation_v7.[idfGeoLocation] = cchc.[idfPointGeoLocation_v7]'),
				N'j_tlbObservation_idfCSObservation_v7.[idfObservation] = tlbHumanCase_v6.[idfCSObservation]',
				N'j_tlbObservation_idfCSObservation_v7.[idfObservation] = cchc.[idfCSObservation_v7]'),
					N'j_tlbObservation_idfEpiObservation_v7.[idfObservation] = tlbHumanCase_v6.[idfEpiObservation]',
					N'j_tlbObservation_idfEpiObservation_v7.[idfObservation] = cchc.[idfEpiObservation_v7]'),
						N'j_tlbHuman_idfHuman_v7.[idfHuman] = tlbHumanCase_v6.[idfHuman]',
						N'j_tlbHuman_idfHuman_v7.[idfHuman] = cchc.[idfHuman_v7]'),
							N'j_tlbOutbreak_idfOutbreak_v7.[idfOutbreak] = tlbHumanCase_v6.[idfOutbreak]',
							N'j_tlbOutbreak_idfOutbreak_v7.[idfOutbreak] = cchc.[idfOutbreak_v7]'),
		ttm.strUpdateColumns = replace(ttm.strUpdateColumns, 
			N'tlbHumanCase_v6.[strCaseID]', 
			N'cchc.[strCaseID_v7]'), 
		ttm.strUpdateAfterInsert = N'
update		tlbHumanCase_v7
set			tlbHumanCase_v7.[idfDeduplicationResultCase] = tlbHumanCase_dedupl_v7.[idfHumanCase]
from		[Giraffe].[dbo].[tlbHumanCase] tlbHumanCase_v7
inner join	[Giraffe].[dbo].[_dmccHumanCase] cchc
on			cchc.[idfHumanCase_v7] = tlbHumanCase_v7.[idfHumanCase]
inner join	[Giraffe].[dbo].[tlbHumanCase] tlbHumanCase_dedupl_v7
on			tlbHumanCase_dedupl_v7.[idfHumanCase] = cchc.[idfDeduplicationResultCase_v7]
where		tlbHumanCase_v7.[idfDeduplicationResultCase] is null
print	N''Table [tlbHumanCase] - update link to the deduplication case survivor from migrated HDRs: '' + cast(@@rowcount as nvarchar(20))
'
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tlbHumanCase' collate Cyrillic_General_CI_AS



update	ttm
set		ttm.strInsertFromHeader = replace(replace(ttm.strInsertFromHeader, 
			N'from [Falcon].[dbo].[tlbAntimicrobialTherapy] tlbAntimicrobialTherapy_v6', 
			N'from [Falcon].[dbo].[tlbAntimicrobialTherapy] tlbAntimicrobialTherapy_v6
inner join	[Giraffe].[dbo].[_dmccAntimicrobialTherapy] ccat
on			ccat.idfAntimicrobialTherapy_v6 = tlbAntimicrobialTherapy_v6.[idfAntimicrobialTherapy]'), 
				N'tlbAntimicrobialTherapy_v7.[idfAntimicrobialTherapy] = tlbAntimicrobialTherapy_v6.[idfAntimicrobialTherapy]', 
				N'tlbAntimicrobialTherapy_v7.[idfAntimicrobialTherapy] = ccat.idfAntimicrobialTherapy_v7'),
		ttm.strInsertFromJoins = replace(replace(ttm.strInsertFromJoins, 
			N'tlbAntimicrobialTherapy_v7.[idfAntimicrobialTherapy] = tlbAntimicrobialTherapy_v6.[idfAntimicrobialTherapy]', 
			N'tlbAntimicrobialTherapy_v7.[idfAntimicrobialTherapy] = isnull(ccat.idfAntimicrobialTherapy_v7, tlbAntimicrobialTherapy_v6.[idfAntimicrobialTherapy])'),
				N'j_tlbHumanCase_idfHumanCase_v7.[idfHumanCase] = tlbAntimicrobialTherapy_v6.[idfHumanCase]',
				N'j_tlbHumanCase_idfHumanCase_v7.[idfHumanCase] = ccat.idfHumanCase_v7'),
		ttm.strSelectColumns = replace(ttm.strSelectColumns, 
			N'tlbAntimicrobialTherapy_v6.[idfAntimicrobialTherapy]', 
			N'isnull(ccat.idfAntimicrobialTherapy_v7, tlbAntimicrobialTherapy_v6.[idfAntimicrobialTherapy])'),
		ttm.strUpdateFromHeader = replace(replace(ttm.strUpdateFromHeader, 
			N'inner join	[Falcon].[dbo].[tlbAntimicrobialTherapy] tlbAntimicrobialTherapy_v6', 
			N'inner join	[Falcon].[dbo].[tlbAntimicrobialTherapy] tlbAntimicrobialTherapy_v6
	inner join	[Giraffe].[dbo].[_dmccAntimicrobialTherapy] ccat
	on			ccat.idfAntimicrobialTherapy_v6 = tlbAntimicrobialTherapy_v6.[idfAntimicrobialTherapy]'), 
				N'tlbAntimicrobialTherapy_v7.[idfAntimicrobialTherapy] = tlbAntimicrobialTherapy_v6.[idfAntimicrobialTherapy]', 
				N'tlbAntimicrobialTherapy_v7.[idfAntimicrobialTherapy] = ccat.idfAntimicrobialTherapy_v7'),
		ttm.strUpdateFromJoins = replace(ttm.strUpdateFromJoins, 
			N'j_tlbHumanCase_idfHumanCase_v7.[idfHumanCase] = tlbAntimicrobialTherapy_v6.[idfHumanCase]', 
			N'j_tlbHumanCase_idfHumanCase_v7.[idfHumanCase] = ccat.idfHumanCase_v7')
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tlbAntimicrobialTherapy' collate Cyrillic_General_CI_AS



update	ttm
set		ttm.strInsertFromHeader = replace(replace(ttm.strInsertFromHeader, 
			N'from [Falcon].[dbo].[tlbContactedCasePerson] tlbContactedCasePerson_v6', 
			N'from [Falcon].[dbo].[tlbContactedCasePerson] tlbContactedCasePerson_v6
inner join	[Giraffe].[dbo].[_dmccContactedCasePerson] ccccp
on			ccccp.idfContactedCasePerson_v6 = tlbContactedCasePerson_v6.[idfContactedCasePerson]'), 
				N'tlbContactedCasePerson_v7.[idfContactedCasePerson] = tlbContactedCasePerson_v6.[idfContactedCasePerson]', 
				N'tlbContactedCasePerson_v7.[idfContactedCasePerson] = ccccp.idfContactedCasePerson_v7'),
		ttm.strInsertFromJoins = replace(replace(replace(ttm.strInsertFromJoins, 
			N'tlbContactedCasePerson_v7.[idfContactedCasePerson] = tlbContactedCasePerson_v6.[idfContactedCasePerson]', 
			N'tlbContactedCasePerson_v7.[idfContactedCasePerson] = ccccp.idfContactedCasePerson_v7'),
				N'j_tlbHumanCase_idfHumanCase_v7.[idfHumanCase] = tlbContactedCasePerson_v6.[idfHumanCase]',
				N'j_tlbHumanCase_idfHumanCase_v7.[idfHumanCase] = ccccp.idfHumanCase_v7'),
					N'j_tlbHuman_idfHuman_v7.[idfHuman] = tlbContactedCasePerson_v6.[idfHuman]',
					N'j_tlbHuman_idfHuman_v7.[idfHuman] = ccccp.idfHuman_v7'),
		ttm.strSelectColumns = replace(ttm.strSelectColumns, 
			N'tlbContactedCasePerson_v6.[idfContactedCasePerson]', 
			N'isnull(ccccp.idfContactedCasePerson_v7, tlbContactedCasePerson_v6.[idfContactedCasePerson])'),
		ttm.strUpdateFromHeader = replace(replace(ttm.strUpdateFromHeader, 
			N'inner join	[Falcon].[dbo].[tlbContactedCasePerson] tlbContactedCasePerson_v6', 
			N'inner join	[Falcon].[dbo].[tlbContactedCasePerson] tlbContactedCasePerson_v6
	inner join	[Giraffe].[dbo].[_dmccContactedCasePerson] ccccp
	on			ccccp.idfContactedCasePerson_v6 = tlbContactedCasePerson_v6.[idfContactedCasePerson]'), 
				N'tlbContactedCasePerson_v7.[idfContactedCasePerson] = tlbContactedCasePerson_v6.[idfContactedCasePerson]', 
				N'tlbContactedCasePerson_v7.[idfContactedCasePerson] = ccccp.idfContactedCasePerson_v7'),
		ttm.strUpdateFromJoins = replace(replace(ttm.strUpdateFromJoins, 
			N'j_tlbHumanCase_idfHumanCase_v7.[idfHumanCase] = tlbContactedCasePerson_v6.[idfHumanCase]', 
			N'j_tlbHumanCase_idfHumanCase_v7.[idfHumanCase] = ccccp.idfHumanCase_v7'),
				N'j_tlbHuman_idfHuman_v7.[idfHuman] = tlbContactedCasePerson_v6.[idfHuman]',
				N'j_tlbHuman_idfHuman_v7.[idfHuman] = ccccp.idfHuman_v7')
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tlbContactedCasePerson' collate Cyrillic_General_CI_AS



update	ttm
set		ttm.strInsertFromHeader = replace(replace(ttm.strInsertFromHeader, 
			N'from [Falcon].[dbo].[tflHumanCaseFiltered] tflHumanCaseFiltered_v6', 
			N'from [Falcon].[dbo].[tflHumanCaseFiltered] tflHumanCaseFiltered_v6
inner join	[Giraffe].[dbo].[_dmcctflHumanCaseFiltered] cchcf
on			cchcf.idfHumanCaseFiltered_v6 = tflHumanCaseFiltered_v6.[idfHumanCaseFiltered]'), 
				N'tflHumanCaseFiltered_v7.[idfHumanCaseFiltered] = tflHumanCaseFiltered_v6.[idfHumanCaseFiltered]', 
				N'tflHumanCaseFiltered_v7.[idfHumanCaseFiltered] = cchcf.idfHumanCaseFiltered_v7'),
		ttm.strInsertFromJoins = replace(replace(ttm.strInsertFromJoins, 
			N'tflHumanCaseFiltered_v7.[idfHumanCaseFiltered] = tflHumanCaseFiltered_v6.[idfHumanCaseFiltered]', 
			N'tflHumanCaseFiltered_v7.[idfHumanCaseFiltered] = isnull(cchcf.idfHumanCaseFiltered_v7, tflHumanCaseFiltered_v6.[idfHumanCaseFiltered])'),
				N'j_tlbHumanCase_idfHumanCase_v7.[idfHumanCase] = tflHumanCaseFiltered_v6.[idfHumanCase]',
				N'j_tlbHumanCase_idfHumanCase_v7.[idfHumanCase] = cchcf.idfHumanCase_v7'),
		ttm.strSelectColumns = replace(ttm.strSelectColumns, 
			N'tflHumanCaseFiltered_v6.[idfHumanCaseFiltered]', 
			N'isnull(cchcf.idfHumanCaseFiltered_v7, tflHumanCaseFiltered_v6.[idfHumanCaseFiltered])'),
		ttm.strUpdateFromHeader = replace(replace(ttm.strUpdateFromHeader, 
			N'inner join	[Falcon].[dbo].[tflHumanCaseFiltered] tflHumanCaseFiltered_v6', 
			N'inner join	[Falcon].[dbo].[tflHumanCaseFiltered] tflHumanCaseFiltered_v6
	inner join	[Giraffe].[dbo].[_dmccHumanCaseFiltered] cchcf
	on			cchcf.idfHumanCaseFiltered_v6 = tflHumanCaseFiltered_v6.[idfHumanCaseFiltered]'), 
				N'tflHumanCaseFiltered_v7.[idfHumanCaseFiltered] = tflHumanCaseFiltered_v6.[idfHumanCaseFiltered]', 
				N'tflHumanCaseFiltered_v7.[idfHumanCaseFiltered] = cchcf.idfHumanCaseFiltered_v7'),
		ttm.strUpdateFromJoins = replace(ttm.strUpdateFromJoins, 
			N'j_tlbHumanCase_idfHumanCase_v7.[idfHumanCase] = tflHumanCaseFiltered_v6.[idfHumanCase]', 
			N'j_tlbHumanCase_idfHumanCase_v7.[idfHumanCase] = cchcf.idfHumanCase_v7')
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tflHumanCaseFiltered' collate Cyrillic_General_CI_AS



update	ttm
set		ttm.strInsertFromJoins = replace(replace(replace(replace(ttm.strInsertFromJoins, 
			N'j_trtDiagnosis_idfsFinalDiagnosis_v7.[idfsDiagnosis] = tlbVetCase_v6.[idfsFinalDiagnosis]',
			N'j_trtDiagnosis_idfsFinalDiagnosis_v7.[idfsDiagnosis] = tlbVetCase_v6.[idfsShowDiagnosis] /*Rule for the field in EIDSSv7: idfsFinalDiagnosis*/'),
				N'left join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsTentativeDiagnosis_v7',
				N'left join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsTentativeDiagnosis_v7
		left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsTentativeDiagnosis_v7
		on	j_trtBaseReference_idfsTentativeDiagnosis_v7.[idfsBaseReference] = j_trtDiagnosis_idfsTentativeDiagnosis_v7.[idfsDiagnosis]
		left join	[Giraffe].[dbo].[trtStringNameTranslation] j_trtStringNameTranslation_idfsTentativeDiagnosis_v7
		on	j_trtStringNameTranslation_idfsTentativeDiagnosis_v7.[idfsBaseReference] = j_trtDiagnosis_idfsTentativeDiagnosis_v7.[idfsDiagnosis]
			and j_trtStringNameTranslation_idfsTentativeDiagnosis_v7.[idfsLanguage] = @idfsPreferredNationalLanguage'),
				N'left join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsTentativeDiagnosis1_v7',
				N'left join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsTentativeDiagnosis1_v7
		left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsTentativeDiagnosis1_v7
		on	j_trtBaseReference_idfsTentativeDiagnosis1_v7.[idfsBaseReference] = j_trtDiagnosis_idfsTentativeDiagnosis1_v7.[idfsDiagnosis]
		left join	[Giraffe].[dbo].[trtStringNameTranslation] j_trtStringNameTranslation_idfsTentativeDiagnosis1_v7
		on	j_trtStringNameTranslation_idfsTentativeDiagnosis1_v7.[idfsBaseReference] = j_trtDiagnosis_idfsTentativeDiagnosis1_v7.[idfsDiagnosis]
			and j_trtStringNameTranslation_idfsTentativeDiagnosis1_v7.[idfsLanguage] = @idfsPreferredNationalLanguage'),
				N'left join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsTentativeDiagnosis2_v7',
				N'left join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsTentativeDiagnosis2_v7
		left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsTentativeDiagnosis2_v7
		on	j_trtBaseReference_idfsTentativeDiagnosis2_v7.[idfsBaseReference] = j_trtDiagnosis_idfsTentativeDiagnosis2_v7.[idfsDiagnosis]
		left join	[Giraffe].[dbo].[trtStringNameTranslation] j_trtStringNameTranslation_idfsTentativeDiagnosis2_v7
		on	j_trtStringNameTranslation_idfsTentativeDiagnosis2_v7.[idfsBaseReference] = j_trtDiagnosis_idfsTentativeDiagnosis2_v7.[idfsDiagnosis]
			and j_trtStringNameTranslation_idfsTentativeDiagnosis2_v7.[idfsLanguage] = @idfsPreferredNationalLanguage'),
		ttm.strSelectColumns = replace(replace(ttm.strSelectColumns, 
			N'tlbVetCase_v6.[datFinalDiagnosisDate]',
			N'case
							when tlbVetCase_v6.[datFinalDiagnosisDate] IS NOT NULL
								then tlbVetCase_v6.[datFinalDiagnosisDate] 
							when tlbVetCase_v6.[datFinalDiagnosisDate] IS NULL AND tlbVetCase_v6.[datTentativeDiagnosisDate] IS NOT NULL AND tlbVetCase_v6.[idfsTentativeDiagnosis] IS NOT NULL 
								AND tlbVetCase_v6.[datTentativeDiagnosisDate]>=isnull(tlbVetCase_v6.[datTentativeDiagnosis1Date],(0)) 
								AND tlbVetCase_v6.[datTentativeDiagnosisDate]>=isnull(tlbVetCase_v6.[datTentativeDiagnosis2Date],(0))
								then tlbVetCase_v6.[datTentativeDiagnosisDate]
							when tlbVetCase_v6.[datFinalDiagnosisDate] IS NULL AND tlbVetCase_v6.[datTentativeDiagnosis1Date] IS NOT NULL AND tlbVetCase_v6.[idfsTentativeDiagnosis1] IS NOT NULL 
								AND tlbVetCase_v6.[datTentativeDiagnosis1Date]>=isnull(tlbVetCase_v6.[datTentativeDiagnosisDate],(0)) 
								AND tlbVetCase_v6.[datTentativeDiagnosis1Date]>=isnull(tlbVetCase_v6.[datTentativeDiagnosis2Date],(0)) 
								then tlbVetCase_v6.[datTentativeDiagnosis1Date] 
							when tlbVetCase_v6.[datFinalDiagnosisDate] IS NULL AND tlbVetCase_v6.[datTentativeDiagnosis2Date] IS NOT NULL AND tlbVetCase_v6.[idfsTentativeDiagnosis2] IS NOT NULL 
								AND tlbVetCase_v6.[datTentativeDiagnosis2Date]>=isnull(tlbVetCase_v6.[datTentativeDiagnosisDate],(0)) 
								AND tlbVetCase_v6.[datTentativeDiagnosis2Date]>=isnull(tlbVetCase_v6.[datTentativeDiagnosis1Date],(0)) 
								then tlbVetCase_v6.[datTentativeDiagnosis2Date] 
							else null
					  end /*Rule for the field in EIDSSv7: datFinalDiagnosisDate*/'),
				N'tlbVetCase_v6.[strSummaryNotes]', 
				N'isnull(@InitialDiagResource + N'' 1: '' + 
							isnull(j_trtStringNameTranslation_idfsTentativeDiagnosis_v7.[strTextString], j_trtBaseReference_idfsTentativeDiagnosis_v7.[strDefault]) + 
							isnull(N'' '' + convert(nvarchar, tlbVetCase_v6.[datTentativeDiagnosisDate], 103) collate Cyrillic_General_CI_AS, N'''') + N''
						'' collate Cyrillic_General_CI_AS, N'''') +
					  isnull(@InitialDiagResource + N'' 2: '' + 
							isnull(j_trtStringNameTranslation_idfsTentativeDiagnosis1_v7.[strTextString], j_trtBaseReference_idfsTentativeDiagnosis1_v7.[strDefault]) + 
							isnull(N'' '' + convert(nvarchar, tlbVetCase_v6.[datTentativeDiagnosis1Date], 103) collate Cyrillic_General_CI_AS, N'''') + N''
						'' collate Cyrillic_General_CI_AS, N'''') +
					  isnull(@InitialDiagResource + N'' 3: '' + 
							isnull(j_trtStringNameTranslation_idfsTentativeDiagnosis2_v7.[strTextString], j_trtBaseReference_idfsTentativeDiagnosis2_v7.[strDefault]) + 
							isnull(N'' '' + convert(nvarchar, tlbVetCase_v6.[datTentativeDiagnosis2Date], 103) collate Cyrillic_General_CI_AS, N'''') + N''
						'' collate Cyrillic_General_CI_AS, N'''')
					  collate Cyrillic_General_CI_AS /*Rule for the field in EIDSSv7: strSummaryNotes*/')
					  /*TODO: consider if needed
					  -- isnull(@FinalDiagResource + 
						--	isnull(j_trtStringNameTranslation_idfsFinalDiagnosis_v7.[strTextString], j_trtBaseReference_idfsFinalDiagnosis_v7.[strDefault]) + 
						--	isnull(N'' '' + convert(nvarchar, tlbVetCase_v6.[datFinalDiagnosisDate], 103) collate Cyrillic_General_CI_AS, N'''') + N''
						--'' collate Cyrillic_General_CI_AS, N'''') collate Cyrillic_General_CI_AS, N'''') */,
		ttm.strUpdateFromJoins = replace(replace(replace(replace(ttm.strUpdateFromJoins, 
			N'j_trtDiagnosis_idfsFinalDiagnosis_v7.[idfsDiagnosis] = tlbVetCase_v6.[idfsFinalDiagnosis]',
			N'j_trtDiagnosis_idfsFinalDiagnosis_v7.[idfsDiagnosis] = tlbVetCase_v6.[idfsShowDiagnosis] /*Rule for the field in EIDSSv7: idfsFinalDiagnosis*/'),
				N'left join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsTentativeDiagnosis_v7',
				N'left join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsTentativeDiagnosis_v7
		left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsTentativeDiagnosis_v7
		on	j_trtBaseReference_idfsTentativeDiagnosis_v7.[idfsBaseReference] = j_trtDiagnosis_idfsTentativeDiagnosis_v7.[idfsDiagnosis]
		left join	[Giraffe].[dbo].[trtStringNameTranslation] j_trtStringNameTranslation_idfsTentativeDiagnosis_v7
		on	j_trtStringNameTranslation_idfsTentativeDiagnosis_v7.[idfsBaseReference] = j_trtDiagnosis_idfsTentativeDiagnosis_v7.[idfsDiagnosis]
			and j_trtStringNameTranslation_idfsTentativeDiagnosis_v7.[idfsLanguage] = @idfsPreferredNationalLanguage'),
				N'left join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsTentativeDiagnosis1_v7',
				N'left join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsTentativeDiagnosis1_v7
		left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsTentativeDiagnosis1_v7
		on	j_trtBaseReference_idfsTentativeDiagnosis1_v7.[idfsBaseReference] = j_trtDiagnosis_idfsTentativeDiagnosis1_v7.[idfsDiagnosis]
		left join	[Giraffe].[dbo].[trtStringNameTranslation] j_trtStringNameTranslation_idfsTentativeDiagnosis1_v7
		on	j_trtStringNameTranslation_idfsTentativeDiagnosis1_v7.[idfsBaseReference] = j_trtDiagnosis_idfsTentativeDiagnosis1_v7.[idfsDiagnosis]
			and j_trtStringNameTranslation_idfsTentativeDiagnosis1_v7.[idfsLanguage] = @idfsPreferredNationalLanguage'),
				N'left join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsTentativeDiagnosis2_v7',
				N'left join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsTentativeDiagnosis2_v7
		left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsTentativeDiagnosis2_v7
		on	j_trtBaseReference_idfsTentativeDiagnosis2_v7.[idfsBaseReference] = j_trtDiagnosis_idfsTentativeDiagnosis2_v7.[idfsDiagnosis]
		left join	[Giraffe].[dbo].[trtStringNameTranslation] j_trtStringNameTranslation_idfsTentativeDiagnosis2_v7
		on	j_trtStringNameTranslation_idfsTentativeDiagnosis2_v7.[idfsBaseReference] = j_trtDiagnosis_idfsTentativeDiagnosis2_v7.[idfsDiagnosis]
			and j_trtStringNameTranslation_idfsTentativeDiagnosis2_v7.[idfsLanguage] = @idfsPreferredNationalLanguage'),
		ttm.strUpdateColumns = replace(replace(ttm.strUpdateColumns, 
			N'tlbVetCase_v6.[datFinalDiagnosisDate]',
			N'case
							when tlbVetCase_v6.[datFinalDiagnosisDate] IS NOT NULL
								then tlbVetCase_v6.[datFinalDiagnosisDate] 
							when tlbVetCase_v6.[datFinalDiagnosisDate] IS NULL AND tlbVetCase_v6.[datTentativeDiagnosisDate] IS NOT NULL AND tlbVetCase_v6.[idfsTentativeDiagnosis] IS NOT NULL 
								AND tlbVetCase_v6.[datTentativeDiagnosisDate]>=isnull(tlbVetCase_v6.[datTentativeDiagnosis1Date],(0)) 
								AND tlbVetCase_v6.[datTentativeDiagnosisDate]>=isnull(tlbVetCase_v6.[datTentativeDiagnosis2Date],(0))
								then tlbVetCase_v6.[datTentativeDiagnosisDate]
							when tlbVetCase_v6.[datFinalDiagnosisDate] IS NULL AND tlbVetCase_v6.[datTentativeDiagnosis1Date] IS NOT NULL AND tlbVetCase_v6.[idfsTentativeDiagnosis1] IS NOT NULL 
								AND tlbVetCase_v6.[datTentativeDiagnosis1Date]>=isnull(tlbVetCase_v6.[datTentativeDiagnosisDate],(0)) 
								AND tlbVetCase_v6.[datTentativeDiagnosis1Date]>=isnull(tlbVetCase_v6.[datTentativeDiagnosis2Date],(0)) 
								then tlbVetCase_v6.[datTentativeDiagnosis1Date] 
							when tlbVetCase_v6.[datFinalDiagnosisDate] IS NULL AND tlbVetCase_v6.[datTentativeDiagnosis2Date] IS NOT NULL AND tlbVetCase_v6.[idfsTentativeDiagnosis2] IS NOT NULL 
								AND tlbVetCase_v6.[datTentativeDiagnosis2Date]>=isnull(tlbVetCase_v6.[datTentativeDiagnosisDate],(0)) 
								AND tlbVetCase_v6.[datTentativeDiagnosis2Date]>=isnull(tlbVetCase_v6.[datTentativeDiagnosis1Date],(0)) 
								then tlbVetCase_v6.[datTentativeDiagnosis2Date] 
							else null
					  end /*Rule for the field in EIDSSv7: datFinalDiagnosisDate*/'),
				N'tlbVetCase_v6.[strSummaryNotes]', 
				N'isnull(@InitialDiagResource + N'' 1: '' + 
							isnull(j_trtStringNameTranslation_idfsTentativeDiagnosis_v7.[strTextString], j_trtBaseReference_idfsTentativeDiagnosis_v7.[strDefault]) + 
							isnull(N'' '' + convert(nvarchar, tlbVetCase_v6.[datTentativeDiagnosisDate], 103) collate Cyrillic_General_CI_AS, N'''') + N''
						'' collate Cyrillic_General_CI_AS, N'''') +
					  isnull(@InitialDiagResource + N'' 2: '' + 
							isnull(j_trtStringNameTranslation_idfsTentativeDiagnosis1_v7.[strTextString], j_trtBaseReference_idfsTentativeDiagnosis1_v7.[strDefault]) + 
							isnull(N'' '' + convert(nvarchar, tlbVetCase_v6.[datTentativeDiagnosis1Date], 103) collate Cyrillic_General_CI_AS, N'''') + N''
						'' collate Cyrillic_General_CI_AS, N'''') +
					  isnull(@InitialDiagResource + N'' 3: '' + 
							isnull(j_trtStringNameTranslation_idfsTentativeDiagnosis2_v7.[strTextString], j_trtBaseReference_idfsTentativeDiagnosis2_v7.[strDefault]) + 
							isnull(N'' '' + convert(nvarchar, tlbVetCase_v6.[datTentativeDiagnosis2Date], 103) collate Cyrillic_General_CI_AS, N'''') + N''
						'' collate Cyrillic_General_CI_AS, N'''')
					  collate Cyrillic_General_CI_AS /*Rule for the field in EIDSSv7: strSummaryNotes*/')
					  /*TODO: consider if needed
					  -- isnull(@FinalDiagResource + 
						--	isnull(j_trtStringNameTranslation_idfsFinalDiagnosis_v7.[strTextString], j_trtBaseReference_idfsFinalDiagnosis_v7.[strDefault]) + 
						--	isnull(N'' '' + convert(nvarchar, tlbVetCase_v6.[datFinalDiagnosisDate], 103) collate Cyrillic_General_CI_AS, N'''') + N''
						--'' collate Cyrillic_General_CI_AS, N'''') collate Cyrillic_General_CI_AS, N'''') */
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tlbVetCase' collate Cyrillic_General_CI_AS


update	ttm
set		ttm.strInsertFromHeader = replace(replace(ttm.strInsertFromHeader, 
			N'from [Falcon].[dbo].[tlbMaterial] tlbMaterial_v6', 
			N'from [Falcon].[dbo].[tlbMaterial] tlbMaterial_v6
left join	[Giraffe].[dbo].[_dmccMaterial] ccm
on			ccm.idfMaterial_v6 = tlbMaterial_v6.[idfMaterial]'), 
				N'tlbMaterial_v7.[idfMaterial] = tlbMaterial_v6.[idfMaterial]', 
				N'tlbMaterial_v7.[idfMaterial] = isnull(ccm.idfMaterial_v7, tlbMaterial_v6.[idfMaterial])'),
		ttm.strInsertFromJoins = replace(replace(replace(ttm.strInsertFromJoins, 
			N'tlbMaterial_v7.[idfMaterial] = tlbMaterial_v6.[idfMaterial]', 
			N'tlbMaterial_v7.[idfMaterial] = isnull(ccm.idfMaterial_v7, tlbMaterial_v6.[idfMaterial])'),
				N'j_tlbHumanCase_idfHumanCase_v7.[idfHumanCase] = tlbMaterial_v6.[idfHumanCase]',
				N'j_tlbHumanCase_idfHumanCase_v7.[idfHumanCase] = ccm.idfHumanCase_v7'),
					N'j_tlbHuman_idfHuman_v7.[idfHuman] = tlbMaterial_v6.[idfHuman]',
					N'j_tlbHuman_idfHuman_v7.[idfHuman] = ccm.idfHuman_v7'),
		ttm.strSelectColumns = replace(replace(replace(replace(ttm.strSelectColumns, 
			N'tlbMaterial_v6.[idfMaterial]', 
			N'isnull(ccm.idfMaterial_v7, tlbMaterial_v6.[idfMaterial])'),
				N'tlbMaterial_v6.[blnReadonly]', 
				N'isnull(ccm.[blnReadOnly_v7], tlbMaterial_v6.[blnReadOnly])'),
					N'tlbMaterial_v6.[strCalculatedCaseID]', 
					N'isnull(ccm.[strCalculatedCaseID_v7], tlbMaterial_v6.[strCalculatedCaseID])'),
						N'tlbMaterial_v6.[strCalculatedHumanName]', 
						N'isnull(ccm.[strCalculatedHumanName_v7], tlbMaterial_v6.[strCalculatedHumanName])'),
		ttm.strUpdateFromHeader = replace(replace(ttm.strUpdateFromHeader, 
			N'inner join	[Falcon].[dbo].[tlbMaterial] tlbMaterial_v6', 
			N'inner join	[Falcon].[dbo].[tlbMaterial] tlbMaterial_v6
	left join	[Giraffe].[dbo].[_dmccMaterial] ccm
	on			ccm.idfMaterial_v6 = tlbMaterial_v6.[idfMaterial]'), 
				N'tlbMaterial_v7.[idfMaterial] = tlbMaterial_v6.[idfMaterial]', 
				N'tlbMaterial_v7.[idfMaterial] = isnull(ccm.idfMaterial_v7, tlbMaterial_v6.[idfMaterial])'),
		ttm.strUpdateFromJoins = replace(replace(ttm.strUpdateFromJoins, 
			N'j_tlbHumanCase_idfHumanCase_v7.[idfHumanCase] = tlbMaterial_v6.[idfHumanCase]', 
			N'j_tlbHumanCase_idfHumanCase_v7.[idfHumanCase] = ccm.idfHumanCase_v7'),
				N'j_tlbHuman_idfHuman_v7.[idfHuman] = tlbMaterial_v6.[idfHuman]',
				N'j_tlbHuman_idfHuman_v7.[idfHuman] = ccm.idfHuman_v7'),
		ttm.strUpdateColumns = replace(replace(replace(ttm.strUpdateColumns, 
			N'tlbMaterial_v6.[blnReadonly]', 
			N'isnull(ccm.[blnReadOnly_v7], tlbMaterial_v6.[blnReadOnly])'),
				N'tlbMaterial_v6.[strCalculatedCaseID]', 
				N'isnull(ccm.[strCalculatedCaseID_v7], tlbMaterial_v6.[strCalculatedCaseID])'),
					N'tlbMaterial_v6.[strCalculatedHumanName]', 
					N'isnull(ccm.[strCalculatedHumanName_v7], tlbMaterial_v6.[strCalculatedHumanName])'),
		ttm.strUpdateAfterInsert = N'
update		tlbMaterial_v7
set			tlbMaterial_v7.[idfParentMaterial] = tlbMaterial_Parent_v7.[idfMaterial]
from		[Giraffe].[dbo].[tlbMaterial] tlbMaterial_v7
left join	[Giraffe].[dbo].[_dmccMaterial] ccm
on			ccm.[idfMaterial_v7] = tlbMaterial_v7.[idfMaterial]
inner join	[Falcon].[dbo].[tlbMaterial] tlbMaterial_v6
on			tlbMaterial_v6.[idfMaterial] = isnull(ccm.[idfMaterial_v6], tlbMaterial_v7.[idfMaterial])
inner join	[Giraffe].[dbo].[tlbMaterial] tlbMaterial_Parent_v7
on			tlbMaterial_Parent_v7.[idfMaterial] = isnull(ccm.[idfParentMaterial_v7], tlbMaterial_v6.[idfParentMaterial])
where		tlbMaterial_V7.[idfParentMaterial] is null
print	N''Table [tlbMaterial] - update link to the parent sample from migrated samples: '' + cast(@@rowcount as nvarchar(20))

update		tlbMaterial_v7
set			tlbMaterial_v7.[idfRootMaterial] = tlbMaterial_Root_v7.[idfMaterial]
from		[Giraffe].[dbo].[tlbMaterial] tlbMaterial_v7
left join	[Giraffe].[dbo].[_dmccMaterial] ccm
on			ccm.[idfMaterial_v7] = tlbMaterial_v7.[idfMaterial]
inner join	[Falcon].[dbo].[tlbMaterial] tlbMaterial_v6
on			tlbMaterial_v6.[idfMaterial] = isnull(ccm.[idfMaterial_v6], tlbMaterial_v7.[idfMaterial])
inner join	[Giraffe].[dbo].[tlbMaterial] tlbMaterial_Root_v7
on			tlbMaterial_Root_v7.[idfMaterial] = isnull(ccm.[idfRootMaterial_v7], tlbMaterial_v6.[idfRootMaterial])
where		tlbMaterial_V7.[idfRootMaterial] is null
print	N''Table [tlbMaterial] - update link to the root sample from migrated samples: '' + cast(@@rowcount as nvarchar(20))

'
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tlbMaterial' collate Cyrillic_General_CI_AS



update	ttm
set		ttm.strInsertFromHeader = replace(replace(ttm.strInsertFromHeader, 
			N'from [Falcon].[dbo].[tlbTesting] tlbTesting_v6', 
			N'from [Falcon].[dbo].[tlbTesting] tlbTesting_v6
left join	[Giraffe].[dbo].[_dmccLabTest] cct
on			cct.idfTesting_v6 = tlbTesting_v6.[idfTesting]'), 
				N'tlbTesting_v7.[idfTesting] = tlbTesting_v6.[idfTesting]', 
				N'tlbTesting_v7.[idfTesting] = isnull(cct.idfTesting_v7, tlbTesting_v6.[idfTesting])'),
		ttm.strInsertFromJoins = replace(replace(replace(replace(ttm.strInsertFromJoins, 
			N'tlbTesting_v7.[idfTesting] = tlbTesting_v6.[idfTesting]', 
			N'tlbTesting_v7.[idfTesting] = isnull(cct.idfTesting_v7, tlbTesting_v6.[idfTesting])'),
				N'j_tlbMaterial_idfMaterial_v7.[idfMaterial] = tlbTesting_v6.[idfMaterial]',
				N'j_tlbMaterial_idfMaterial_v7.[idfMaterial] = isnull(cct.idfMaterial_v7, tlbTesting_v6.[idfMaterial])'),
					N'j_tlbBatchTest_idfBatchTest_v7.[idfBatchTest] = tlbTesting_v6.[idfBatchTest]',
					N'((j_tlbBatchTest_idfBatchTest_v7.[idfBatchTest] = cct.[idfBatchTest_v7] and cct.[idfTesting_v7] is not null) or (j_tlbBatchTest_idfBatchTest_v7.[idfBatchTest] = tlbTesting_v6.[idfBatchTest] and cct.[idfTesting_v7] is null))'),
						N'j_tlbObservation_idfObservation_v7.[idfObservation] = tlbTesting_v6.[idfObservation]',
						N'((j_tlbObservation_idfObservation_v7.[idfObservation] = cct.[idfObservation_v7] and cct.[idfTesting_v7] is not null) or (j_tlbObservation_idfObservation_v7.[idfObservation] = tlbTesting_v6.[idfObservation] and cct.[idfTesting_v7] is null))'),
		ttm.strSelectColumns = replace(replace(replace(ttm.strSelectColumns, 
			N'tlbTesting_v6.[idfTesting]', 
			N'isnull(cct.idfTesting_v7, tlbTesting_v6.[idfTesting])'),
				N'tlbTesting_v6.[blnReadonly]', 
				N'isnull(cct.[blnReadOnly_v7], tlbTesting_v6.[blnReadOnly])'),
					N'tlbTesting_v6.[idfObservation]',
					N'isnull(cct.[idfObservation_v7], tlbTesting_v6.[idfObservation])'),
		ttm.strUpdateFromHeader = replace(replace(ttm.strUpdateFromHeader, 
			N'inner join	[Falcon].[dbo].[tlbTesting] tlbTesting_v6', 
			N'inner join	[Falcon].[dbo].[tlbTesting] tlbTesting_v6
	left join	[Giraffe].[dbo].[_dmccLabTest] cct
	on			cct.idfTesting_v6 = tlbTesting_v6.[idfTesting]'), 
				N'tlbTesting_v7.[idfTesting] = tlbTesting_v6.[idfTesting]', 
				N'tlbTesting_v7.[idfTesting] = isnull(cct.idfTesting_v7, tlbTesting_v6.[idfTesting])'),
		ttm.strUpdateFromJoins = replace(replace(replace(ttm.strUpdateFromJoins, 
			N'j_tlbMaterial_idfMaterial_v7.[idfMaterial] = tlbTesting_v6.[idfMaterial]', 
			N'j_tlbMaterial_idfMaterial_v7.[idfMaterial] = isnull(cct.idfMaterial_v7, tlbTesting_v6.[idfMaterial])'),
				N'j_tlbBatchTest_idfBatchTest_v7.[idfBatchTest] = tlbTesting_v6.[idfBatchTest]',
				N'((j_tlbBatchTest_idfBatchTest_v7.[idfBatchTest] = cct.[idfBatch_v7] and cct.[idfTesting_v7] is not null) or (j_tlbBatchTest_idfBatchTest_v7.[idfBatchTest] = tlbTesting_v6.[idfBatchTest] and cct.[idfTesting_v7] is null))'),
					N'j_tlbObservation_idfObservation_v7.[idfObservation] = tlbTesting_v6.[idfObservation]',
					N'((j_tlbObservation_idfObservation_v7.[idfObservation] = cct.[idfObservation_v7] and cct.[idfTesting_v7] is not null) or (j_tlbObservation_idfObservation_v7.[idfObservation] = tlbTesting_v6.[idfObservation] and cct.[idfTesting_v7] is null))'),
		ttm.strUpdateColumns = replace(replace(ttm.strUpdateColumns, 
			N'tlbTesting_v6.[blnReadonly]', 
			N'isnull(cct.[blnReadOnly_v7], tlbTesting_v6.[blnReadOnly])'),
				N'tlbTesting_v6.[idfObservation]',
				N'isnull(cct.[idfObservation_v7], tlbTesting_v6.[idfObservation])'),
		ttm.strUpdateAfterInsert = N'
update		tlbMaterial_v7
set			tlbMaterial_v7.[idfMainTest] = tlbTesting_MainTest_v7.[idfTesting]
from		[Giraffe].[dbo].[tlbMaterial] tlbMaterial_v7
inner join	[Giraffe].[dbo].[_dmccMaterial] ccm
on			ccm.[idfMaterial_v7] = tlbMaterial_v7.[idfMaterial]
inner join	[Falcon].[dbo].[tlbMaterial] tlbMaterial_v6
on			tlbMaterial_v6.[idfMaterial] = ccm.[idfMaterial_v6]
inner join	[Giraffe].[dbo].[_dmccLabTest] cct
on			cct.[idfMaterial_v7] = tlbMaterial_v7.[idfMaterial]
			and cct.[idfTesting_v6] = tlbMaterial_v6.[idfMainTest]
inner join	[Giraffe].[dbo].[tlbTesting] tlbTesting_MainTest_v7
on			tlbTesting_MainTest_v7.[idfTesting] = cct.[idfTesting_v7]
where		tlbMaterial_V7.[idfMainTest] is null
print	N''Table [tlbMaterial] - update link to the main test from migrated samples: '' + cast(@@rowcount as nvarchar(20))



update		tlbMaterial_v7
set			tlbMaterial_v7.[TestUnassignedIndicator] = 1
from		[Giraffe].[dbo].[tlbMaterial] tlbMaterial_v7
left join	[Giraffe].[dbo].[_dmccMaterial] ccm
on			ccm.[idfMaterial_v7] = tlbMaterial_v7.[idfMaterial]
inner join	[Falcon].[dbo].[tlbMaterial] tlbMaterial_v6
on			tlbMaterial_v6.[idfMaterial] = isnull(ccm.[idfMaterial_v6], tlbMaterial_v7.[idfMaterial])
where		tlbMaterial_V7.[TestUnassignedIndicator] = 0
			and tlbMaterial_V7.[blnReadOnly] = 0
			and tlbMaterial_V7.[blnShowInLabList] = 1
			and not exists	(
						select	1 
						from	[Giraffe].[dbo].[tlbTesting] tlbTesting_v7 
						where	tlbTesting_v7.[idfMaterial] = tlbMaterial_v7.[idfMaterial] 
								and tlbTesting_v7.[intRowStatus] <= tlbMaterial_v7.[intRowStatus] 
								and tlbTesting_v7.[blnReadOnly] = 0 
								and tlbTesting_v7.[blnNonLaboratoryTest] = 0
								and (tlbTesting_v7.[blnExternalTest] = 0 or tlbTesting_v7.[blnExternalTest] is null)
							)
print	N''Table [tlbMaterial] - update Test Unassigned Indicator for migrated samples: '' + cast(@@rowcount as nvarchar(20))
',
		ttm.strUpdateAfterInsert2 = N'

update		tlbMaterial_v7
set			tlbMaterial_v7.[TestCompletedIndicator] = 1
from		[Giraffe].[dbo].[tlbMaterial] tlbMaterial_v7
left join	[Giraffe].[dbo].[_dmccMaterial] ccm
on			ccm.[idfMaterial_v7] = tlbMaterial_v7.[idfMaterial]
inner join	[Falcon].[dbo].[tlbMaterial] tlbMaterial_v6
on			tlbMaterial_v6.[idfMaterial] = isnull(ccm.[idfMaterial_v6], tlbMaterial_v7.[idfMaterial])
where		tlbMaterial_V7.[TestCompletedIndicator] = 0
			and tlbMaterial_V7.[blnReadOnly] = 0
			and tlbMaterial_V7.[blnShowInLabList] = 1
			and exists	(
						select	1 
						from	[Giraffe].[dbo].[tlbTesting] tlbTesting_v7 
						where	tlbTesting_v7.[idfMaterial] = tlbMaterial_v7.[idfMaterial] 
								and tlbTesting_v7.[intRowStatus] <= tlbMaterial_v7.[intRowStatus] 
								and tlbTesting_v7.[blnReadOnly] = 0 
								and tlbTesting_v7.[blnNonLaboratoryTest] = 0
								and (tlbTesting_v7.[blnExternalTest] = 0 or tlbTesting_v7.[blnExternalTest] is null)
								and tlbTesting_v7.[idfsTestStatus] = 10001001 /*Final*/
						)
print	N''Table [tlbMaterial] - update Test Completed Indicator for migrated samples: '' + cast(@@rowcount as nvarchar(20))

update		tlbMaterial_v7
set			tlbMaterial_v7.[TransferIndicator] = 1
from		[Giraffe].[dbo].[tlbMaterial] tlbMaterial_v7
left join	[Giraffe].[dbo].[_dmccMaterial] ccm
on			ccm.[idfMaterial_v7] = tlbMaterial_v7.[idfMaterial]
inner join	[Falcon].[dbo].[tlbMaterial] tlbMaterial_v6
on			tlbMaterial_v6.[idfMaterial] = isnull(ccm.[idfMaterial_v6], tlbMaterial_v7.[idfMaterial])
where		tlbMaterial_V7.[TransferIndicator] = 0
			and tlbMaterial_V7.[blnReadOnly] = 0
			and tlbMaterial_V7.[blnShowInLabList] = 1
			and exists	(
						select	1 
						from	[Giraffe].[dbo].[tlbTransferOutMaterial] tlbTransferOutMaterial_v7 
						join	[Giraffe].[dbo].[tlbTransferOUT] tlbTransferOUT_v7
						on		tlbTransferOUT_v7.[idfTransferOut] = tlbTransferOutMaterial_v7.[idfTransferOut]
								and tlbTransferOUT_v7.[intRowStatus] <= tlbMaterial_v7.[intRowStatus]
						where	tlbTransferOutMaterial_v7.[idfMaterial] = tlbMaterial_v7.[idfMaterial] 
								and tlbTransferOutMaterial_v7.[intRowStatus] <= tlbMaterial_v7.[intRowStatus] 

						)
print	N''Table [tlbMaterial] - update Transfer Indicator for migrated samples: '' + cast(@@rowcount as nvarchar(20))


'
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tlbTesting' collate Cyrillic_General_CI_AS




update	ttm
set		ttm.strInsertFromHeader = replace(replace(ttm.strInsertFromHeader, 
			N'from [Falcon].[dbo].[tlbTestValidation] tlbTestValidation_v6', 
			N'from [Falcon].[dbo].[tlbTestValidation] tlbTestValidation_v6
left join	[Giraffe].[dbo].[_dmccTestValidation] cctv
on			cctv.idfTestValidation_v6 = tlbTestValidation_v6.[idfTestValidation]'), 
				N'tlbTestValidation_v7.[idfTestValidation] = tlbTestValidation_v6.[idfTestValidation]', 
				N'tlbTestValidation_v7.[idfTestValidation] = isnull(cctv.idfTestValidation_v7, tlbTestValidation_v6.[idfTestValidation])'),
		ttm.strInsertFromJoins = replace(replace(ttm.strInsertFromJoins, 
			N'tlbTestValidation_v7.[idfTestValidation] = tlbTestValidation_v6.[idfTestValidation]', 
			N'tlbTestValidation_v7.[idfTestValidation] = isnull(cctv.idfTestValidation_v7, tlbTestValidation_v6.[idfTestValidation])'),
				N'j_tlbTesting_idfTesting_v7.[idfTesting] = tlbTestValidation_v6.[idfTesting]',
				N'j_tlbTesting_idfTesting_v7.[idfTesting] = isnull(cctv.idfTesting_v7, tlbTestValidation_v6.[idfTesting])'),
		ttm.strSelectColumns = replace(replace(ttm.strSelectColumns, 
			N'tlbTestValidation_v6.[idfTestValidation]', 
			N'isnull(cctv.idfTestValidation_v7, tlbTestValidation_v6.[idfTestValidation])'),
				N'tlbTestValidation_v6.[blnReadonly]', 
				N'isnull(cctv.[blnReadOnly_v7], tlbTestValidation_v6.[blnReadOnly])'),
		ttm.strUpdateFromHeader = replace(replace(ttm.strUpdateFromHeader, 
			N'inner join	[Falcon].[dbo].[tlbTestValidation] tlbTestValidation_v6', 
			N'inner join	[Falcon].[dbo].[tlbTestValidation] tlbTestValidation_v6
	left join	[Giraffe].[dbo].[_dmccTestValidation] cctv
	on			cctv.idfTestValidation_v6 = tlbTestValidation_v6.[idfTestValidation]'), 
				N'tlbTestValidation_v7.[idfTestValidation] = tlbTestValidation_v6.[idfTestValidation]', 
				N'tlbTestValidation_v7.[idfTestValidation] = isnull(cctv.idfTestValidation_v7, tlbTestValidation_v6.[idfTestValidation])'),
		ttm.strUpdateFromJoins = replace(ttm.strUpdateFromJoins, 
			N'j_tlbTesting_idfTesting_v7.[idfTesting] = tlbTestValidation_v6.[idfTesting]', 
			N'j_tlbTesting_idfTesting_v7.[idfTesting] = isnull(cctv.idfTesting_v7, tlbTestValidation_v6.[idfTesting])'),
		ttm.strUpdateColumns = replace(ttm.strUpdateColumns, 
			N'tlbTestValidation_v6.[blnReadonly]', 
			N'isnull(cctv.[blnReadOnly_v7], tlbTestValidation_v6.[blnReadOnly])')
from	#TablesToMigrate ttm
where	ttm.[sch_name] = N'dbo' collate Cyrillic_General_CI_AS
		and ttm.[table_name] = N'tlbTestValidation' collate Cyrillic_General_CI_AS


--TODO: continue here

/*



*/


--Print the script
declare @BRTableId int

declare @RefTableIdFirst int
declare @RefTableIdLast int

declare @GisRefTableIdFirst int
declare @GisRefTableIdLast int

declare @FfTableIdFirst int
declare @FfTableIdLast int

declare @RefMtrxTableIdFirst int
declare @RefMtrxTableIdLast int

declare @CpTableIdFirst int
declare @CpTableIdLast int

declare @AttrTableIdFirst int
declare @AttrTableIdLast int

declare @LinkToCpTableIdFirst int
declare @LinkToCpTableIdLast int

declare @AggrMtxTableIdFirst int
declare @AggrMtxTableIdLast int

declare @AdminPart1TableIdFirst int
declare @AdminPart1TableIdLast int

declare @AdminPart2TableIdFirst int
declare @AdminPart2TableIdLast int

declare @AdminPart3TableIdFirst int
declare @AdminPart3TableIdLast int

declare @AdminPart4TableIdFirst int
declare @AdminPart4TableIdLast int

declare @ConfigFiltrTableIdFirst int
declare @ConfigFiltrTableIdLast int

declare @CommonCatalogTableIdFirst int
declare @CommonCatalogTableIdLast int

declare @DataModuleTableIdFirst int
declare @DataModuleTableIdLast int


select	@BRTableId = ttm.idfId
from	#TablesToMigrate ttm
where	ttm.[table_name] = N'trtBaseReference' collate Cyrillic_General_CI_AS


select	@RefTableIdFirst = min(ttm.idfId)
from	#TablesToMigrate ttm
where	ttm.idfId > @BRTableId

select	@RefTableIdLast = ttm.idfId
from	#TablesToMigrate ttm
where	ttm.[table_name] = N'trtStringNameTranslation' collate Cyrillic_General_CI_AS


select	@GisRefTableIdFirst = min(ttm.idfId)
from	#TablesToMigrate ttm
where	ttm.idfId > @RefTableIdLast

select	@GisRefTableIdLast = ttm.idfId
from	#TablesToMigrate ttm
where	ttm.[table_name] = N'gisStringNameTranslation' collate Cyrillic_General_CI_AS


select	@FfTableIdFirst = min(ttm.idfId)
from	#TablesToMigrate ttm
where	ttm.idfId > @GisRefTableIdLast

select	@FfTableIdLast = ttm.idfId
from	#TablesToMigrate ttm
where	ttm.[table_name] = N'ffDeterminantValue' collate Cyrillic_General_CI_AS


select	@RefMtrxTableIdFirst = min(ttm.idfId)
from	#TablesToMigrate ttm
where	ttm.idfId > @FfTableIdLast

select	@RefMtrxTableIdLast = ttm.idfId
from	#TablesToMigrate ttm
where	ttm.[table_name] = N'trtGISObjectForCustomReport' collate Cyrillic_General_CI_AS


select	@CpTableIdFirst = min(ttm.idfId)
from	#TablesToMigrate ttm
where	ttm.idfId > @RefMtrxTableIdLast

select	@CpTableIdLast = ttm.idfId
from	#TablesToMigrate ttm
where	ttm.[table_name] = N'tstGeoLocationFormat' collate Cyrillic_General_CI_AS


select	@AttrTableIdFirst = min(ttm.idfId)
from	#TablesToMigrate ttm
where	ttm.idfId > @CpTableIdLast

select	@AttrTableIdLast = ttm.idfId
from	#TablesToMigrate ttm
where	ttm.[table_name] = N'trtBaseReferenceAttribute' collate Cyrillic_General_CI_AS


select	@LinkToCpTableIdFirst = min(ttm.idfId)
from	#TablesToMigrate ttm
where	ttm.idfId > @AttrTableIdLast

select	@LinkToCpTableIdLast = ttm.idfId
from	#TablesToMigrate ttm
where	ttm.[table_name] = N'trtTestTypeToTestResultToCP' collate Cyrillic_General_CI_AS


select	@AggrMtxTableIdFirst = min(ttm.idfId)
from	#TablesToMigrate ttm
where	ttm.idfId > @LinkToCpTableIdLast

select	@AggrMtxTableIdLast = ttm.idfId
from	#TablesToMigrate ttm
where	ttm.[table_name] = N'tlbAggrSanitaryActionMTX' collate Cyrillic_General_CI_AS


select	@AdminPart1TableIdFirst = min(ttm.idfId)
from	#TablesToMigrate ttm
where	ttm.idfId > @AggrMtxTableIdLast

select	@AdminPart1TableIdLast = ttm.idfId
from	#TablesToMigrate ttm
where	ttm.[table_name] = N'tlbStatistic' collate Cyrillic_General_CI_AS

select	@AdminPart2TableIdFirst = min(ttm.idfId)
from	#TablesToMigrate ttm
where	ttm.idfId > @AdminPart1TableIdLast

select	@AdminPart2TableIdLast = ttm.idfId
from	#TablesToMigrate ttm
where	ttm.[table_name] = N'tstUserTable' collate Cyrillic_General_CI_AS

select	@AdminPart3TableIdFirst = min(ttm.idfId)
from	#TablesToMigrate ttm
where	ttm.idfId > @AdminPart2TableIdLast

select	@AdminPart3TableIdLast = ttm.idfId
from	#TablesToMigrate ttm
where	ttm.[table_name] = N'tstObjectAccess' collate Cyrillic_General_CI_AS

select	@AdminPart4TableIdFirst = min(ttm.idfId)
from	#TablesToMigrate ttm
where	ttm.idfId > @AdminPart3TableIdLast

select	@AdminPart4TableIdLast = ttm.idfId
from	#TablesToMigrate ttm
where	ttm.[table_name] = N'tstGlobalSiteOptions' collate Cyrillic_General_CI_AS

select	@ConfigFiltrTableIdFirst = min(ttm.idfId)
from	#TablesToMigrate ttm
where	ttm.idfId > @AdminPart4TableIdLast

select	@ConfigFiltrTableIdLast = ttm.idfId
from	#TablesToMigrate ttm
where	ttm.[table_name] = N'tflSiteToSiteGroup' collate Cyrillic_General_CI_AS

select	@CommonCatalogTableIdFirst = min(ttm.idfId)
from	#TablesToMigrate ttm
where	ttm.idfId > @ConfigFiltrTableIdLast

select	@CommonCatalogTableIdLast = ttm.idfId
from	#TablesToMigrate ttm
where	ttm.[table_name] = N'tlbSpeciesActual' collate Cyrillic_General_CI_AS

select	@DataModuleTableIdFirst = min(ttm.idfId)
from	#TablesToMigrate ttm
where	ttm.idfId > @CommonCatalogTableIdLast

select	@DataModuleTableIdLast = ttm.idfId
from	#TablesToMigrate ttm
where	ttm.[table_name] = N'tflBasicSyndromicSurveillanceFiltered' collate Cyrillic_General_CI_AS

--TODO: add new tables here


select	N'
/**************************************************************************************************************************************
* Data Migration script from EIDSSv6.1 to EIDSSv7.
* Execute script on any database, e.g. master, on the server, where both databases of EIDSS v6.1 and v7 ("empty DB") are located.
* By default, in the script EIDSSv6.1 database has the name Falcon and EIDSSv7 database has the name Giraffe.
**************************************************************************************************************************************/

use [Giraffe]
GO
'

select	N'
/**************************************************************************************************************************************
* Disable Triggers
**************************************************************************************************************************************/
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER	FUNCTION [dbo].[FN_GBL_TriggersWork] ()
RETURNS BIT
AS
BEGIN
RETURN 0
--RETURN 1
END

GO

'


select	N'

SET XACT_ABORT ON 
SET NOCOUNT ON 

declare @NewTempPassword nvarchar(100) = N''EIDss 2023$''	
declare @NewTempPwdHash nvarchar(max) = N''AQAAAAEAACcQAAAAEIvm12VITc96N39k6s7XDMYN3Nb63T3uPagwEE/lk+5uh3gz10qlliJV5N97SoAE3w==''
declare @NewTempSecurityStamp nvarchar(max) = N''6SCD5I2AKVRSE4QVA6JISRSMXQREY45R''
declare @PreferredNationalLanguage nvarchar(50) = ''ka''

declare @TempIdentifierSeedValue bigint = 99999989
declare @TempIdentifierKey nvarchar(36)
set @TempIdentifierKey = cast(newid() as nvarchar(36))

declare @IdMigrationPrefix nvarchar(4) = N''MIGR''
declare @IdGenerateDigitNumber int = 5
declare	@YY nvarchar(2)
set @YY = right(cast(year(getutcdate()) as nvarchar(10)), 2)

declare	@Error	int
set	@Error = 0

declare	@ErrorMsg	nvarchar(MAX)
set	@ErrorMsg = N''''

declare	@cmd	nvarchar(4000)
set	@cmd = N''''


BEGIN TRAN

BEGIN TRY
'

select	N'
/**************************************************************************************************************************************
* SetContext
**************************************************************************************************************************************/
DECLARE @Context VARBINARY(128)
SET @Context = CAST(''DataMigration'' AS VARBINARY(128))
SET CONTEXT_INFO @Context

IF NOT EXISTS (SELECT 1 FROM [Giraffe].[dbo].tstLocalSiteOptions WHERE strName = ''Context'' collate Cyrillic_General_CI_AS)
INSERT INTO [Giraffe].[dbo].tstLocalSiteOptions 
(strName, strValue)
VALUES
(''Context'', ''DataMigration'')

/**************************************************************************************************************************************
* Insert records to the tables
**************************************************************************************************************************************/


DECLARE @idfCustomizationPackage BIGINT
	, @idfsCountry BIGINT
	, @CDRSite BIGINT
	, @CountryPrefix NVARCHAR(2)
	, @idfsPreferredNationalLanguage BIGINT
	, @InitialDiagResource nvarchar(200)
	, @FinalDiagResource nvarchar(200)

SELECT @idfCustomizationPackage = [Falcon].[dbo].fnCustomizationPackage()
SELECT @idfsCountry = [Falcon].[dbo].fnCustomizationCountry()
SELECT 
	@CDRSite = ts.idfsSite
FROM	[Falcon].[dbo].tstSite ts
WHERE	ts.intRowStatus = 0
		and ts.idfCustomizationPackage = @idfCustomizationPackage
		and ts.idfsSiteType = 10085001 /*CDR*/

SELECT	@CountryPrefix = left(isnull(c.strHASC, N''''), 2)
FROM	[Falcon].[dbo].gisCountry c
WHERE	c.idfsCountry = @idfsCountry

IF @CountryPrefix is null or @CountryPrefix = N'''' collate Cyrillic_General_CI_AS
	SET @CountryPrefix = N''US''

SET @idfsPreferredNationalLanguage = [Falcon].dbo.fnGetLanguageCode(@PreferredNationalLanguage)

declare @NumberOfExistingMigratedRecords bigint = 0

select	@InitialDiagResource = coalesce(trtResourceTranslation_v7.[strResourceString], trtResource_v7.[strResourceName], N''Initial Diagnosis'')
from	[Giraffe].[dbo].[trtResource] trtResource_v7
left join	[Giraffe].[dbo].[trtResourceTranslation] trtResourceTranslation_v7
on			trtResourceTranslation_v7.[idfsResource] = trtResource_v7.[idfsResource]
			and trtResourceTranslation_v7.[idfsLanguage] = @idfsPreferredNationalLanguage
where	trtResource_v7.[idfsResource] = 410 /*Initial Diagnosis*/


select	@FinalDiagResource = coalesce(trtResourceTranslation_v7.[strResourceString], trtResource_v7.[strResourceName], N''Final Diagnosis'')
from	[Giraffe].[dbo].[trtResource] trtResource_v7
left join	[Giraffe].[dbo].[trtResourceTranslation] trtResourceTranslation_v7
on			trtResourceTranslation_v7.[idfsResource] = trtResource_v7.[idfsResource]
			and trtResourceTranslation_v7.[idfsLanguage] = @idfsPreferredNationalLanguage
where	trtResource_v7.[idfsResource] = 400 /*Final Diagnosis*/



'

if @GenerateOption = 1 /*Customization package + GeoLocationShared*/
begin

select	N'
/************************************************************
* Insert records - [' + [table_name] + N']
************************************************************/
' + strInsertHeader + N'
' + strInsertColumns + N'
' + strSelectColumns + N'
' + strInsertFromHeader + N'
' + strInsertFromJoins + N'
' + strInsertWhereHeader + strInsertWhereConditions + N'
' + strInsertPrint + N'
' collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId < @BRTableId
order by idfId


select	N'
/************************************************************
* Insert records - Base Reference table with user-defined values - start
************************************************************/
print N''''
print N''Insert records - Base Reference table with user-defined values - start''
print N''''
'

select	N'
/************************************************************
* Insert records - [' + [table_name] + N']
************************************************************/
' + strInsertHeader + N'
' + strInsertColumns + N'
' + strSelectColumns + N'
' + strInsertFromHeader + N'
' + strInsertFromJoins + N'
' + strInsertWhereHeader + strInsertWhereConditions + N'
' + strInsertPrint + N'
' collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId = @BRTableId


select	N'
print N''''
print N''Insert records - Base Reference table with user-defined values - end''
print N''''
print N''''
/************************************************************
* Insert records - Base Reference table with user-defined values - end
************************************************************/
'



select	N'
/************************************************************
* Insert records - Reference tables - start
************************************************************/
print N''''
print N''Insert records - Reference tables - start''
print N''''
'

select	N'
/************************************************************
* Insert records - [' + [table_name] + N']
************************************************************/
' + strInsertHeader + N'
' + strInsertColumns + N'
' + strSelectColumns + N'
' + strInsertFromHeader + N'
' + strInsertFromJoins + N'
' + strInsertWhereHeader + strInsertWhereConditions + N'
' + strInsertPrint + N'
' collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @RefTableIdFirst and @RefTableIdLast
order by idfId


select	N'
print N''''
print N''Insert records - Reference tables - end''
print N''''
print N''''
/************************************************************
* Insert records - Reference tables - end
************************************************************/
'


select	N'
/************************************************************
* Insert records - GIS Reference tables - start
************************************************************/
print N''''
print N''Insert records - GIS Reference tables - start''
print N''''
'

select	N'
/************************************************************
* Insert records - [' + [table_name] + N']
************************************************************/
' + strInsertHeader + N'
' + strInsertColumns + N'
' + strSelectColumns + N'
' + strInsertFromHeader + N'
' + strInsertFromJoins + N'
' + strInsertWhereHeader + strInsertWhereConditions + N'
' + strInsertPrint + N'
' collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @GisRefTableIdFirst and @GisRefTableIdLast
order by idfId

select	N'
print N''''
print N''''
print N''''

/************************************************************
* Calculate records in EIDSSv7 - [gisLocation] - start
************************************************************/
print N''Calculate records in EIDSSv7 - [gisLocation] - start''

insert into	[Giraffe].[dbo].[gisLocation]
(	[idfsLocation],
	[node],
	[strHASC],
	[strCode],
	[idfsType],
	[dblLongitude],
	[dblLatitude],
	[blnIsCustom],
	[intElevation],
	[rowguid],
	[intRowStatus],
	[strMaintenanceFlag],
	[strReservedAttribute],
	[SourceSystemNameID],
	[SourceSystemKeyValue],
	[AuditCreateUser],
	[AuditCreateDTM],
	[AuditUpdateUser],
	[AuditUpdateDTM]
)
select	lev.idfsCountry,
		N''/'' + cast((isnull(lev_last_ex.intLastLevelValue, 0) + lev_num.intLevelSeqNumber) as nvarchar(20)) + N''/'' collate Cyrillic_General_CI_AS,
		lev.strHASC,
		lev.strCode,
		null, /*Settlement Type*/
		null, /*Longitude*/
		null, /*Latitude*/
		0, /*Is Custom*/
		null, /*Elevation*/
		lev.rowguid,
		lev.intRowStatus,
		lev.strMaintenanceFlag,
		lev.strReservedAttribute,
		lev.SourceSystemNameID,
		N''[{'' + N''"idfsLocation":'' + isnull(cast(lev.idfsCountry as nvarchar(20)), N''null'') + N''}]'' collate Cyrillic_General_CI_AS,
		N''system'',
		GETUTCDATE(),
		N''system'',
		GETUTCDATE()
from	[Giraffe].[dbo].[gisCountry] lev
join	[Giraffe].[dbo].gisBaseReference br_lev
on	br_lev.idfsGISBaseReference = lev.idfsCountry
left join	[Giraffe].[dbo].[gisLocation] loc_ex
on	loc_ex.idfsLocation = lev.idfsCountry
outer apply
(	select	max(cast(replace(cast(loc_last.[node] as nvarchar(200)), N''/'', N'''') as bigint)) as intLastLevelValue
	from	[Giraffe].[dbo].[gisLocation] loc_last
	where	loc_last.[node].GetLevel() = 1
) lev_last_ex
outer apply
(	select	count(lev_count.idfsCountry) as intLevelSeqNumber
	from	[Giraffe].[dbo].[gisCountry] lev_count
	join	[Giraffe].[dbo].gisBaseReference br_lev_count
	on	br_lev_count.idfsGISBaseReference = lev_count.idfsCountry
	left join	[Giraffe].[dbo].[gisLocation] loc_ex_count
	on	loc_ex_count.idfsLocation = lev_count.idfsCountry
	where	loc_ex_count.idfsLocation is null
			and lev_count.idfsCountry <= lev.idfsCountry
) lev_num
where	loc_ex.idfsLocation is null
print N''Table [gisLocation] - insert calculated records from gisCountry (level 1): '' + cast(@@rowcount as nvarchar(20))
'

select	N'
insert into	[Giraffe].[dbo].[gisLocation]
(	[idfsLocation],
	[node],
	[strHASC],
	[strCode],
	[idfsType],
	[dblLongitude],
	[dblLatitude],
	[blnIsCustom],
	[intElevation],
	[rowguid],
	[intRowStatus],
	[strMaintenanceFlag],
	[strReservedAttribute],
	[SourceSystemNameID],
	[SourceSystemKeyValue],
	[AuditCreateUser],
	[AuditCreateDTM],
	[AuditUpdateUser],
	[AuditUpdateDTM]
)
select	lev.idfsRegion,
		cast(lev_up.[node] as nvarchar(200)) + cast((isnull(lev_last_ex.intLastLevelValue, 0) + lev_num.intLevelSeqNumber) as nvarchar(20)) + N''/'' collate Cyrillic_General_CI_AS,
		lev.strHASC,
		lev.strCode,
		null, /*Settlement Type*/
		null, /*Longitude*/
		null, /*Latitude*/
		0, /*Is Custom*/
		null, /*Elevation*/
		lev.rowguid,
		lev.intRowStatus,
		lev.strMaintenanceFlag,
		lev.strReservedAttribute,
		lev.SourceSystemNameID,
		N''[{'' + N''"idfsLocation":'' + isnull(cast(lev.idfsRegion as nvarchar(20)), N''null'') + N''}]'' collate Cyrillic_General_CI_AS,
		N''system'',
		GETUTCDATE(),
		N''system'',
		GETUTCDATE()
from	[Giraffe].[dbo].[gisRegion] lev
join	[Giraffe].[dbo].gisBaseReference br_lev
on	br_lev.idfsGISBaseReference = lev.idfsRegion
join	[Giraffe].[dbo].[gisLocation] lev_up
on		lev_up.idfsLocation = lev.idfsCountry
left join	[Giraffe].[dbo].[gisLocation] loc_ex
on	loc_ex.idfsLocation = lev.idfsRegion
outer apply
(	select	max(cast(replace(RIGHT(cast(loc_last.[node] as nvarchar(200)), LEN(cast(loc_last.[node] as nvarchar(200))) - [Falcon].[dbo].fnGetLastCharIndexOfSubstringInNonTrimString(left(cast(loc_last.[node] as nvarchar(200)), LEN(cast(loc_last.[node] as nvarchar(200))) - 1), N''/'', 0) + 1), N''/'', N'''') as bigint)) as intLastLevelValue
	from	[Giraffe].[dbo].[gisLocation] loc_last
	where	loc_last.[node].GetLevel() = 2
) lev_last_ex
outer apply
(	select	count(lev_count.idfsRegion) as intLevelSeqNumber
	from	[Giraffe].[dbo].[gisRegion] lev_count
	join	[Giraffe].[dbo].gisBaseReference br_lev_count
	on	br_lev_count.idfsGISBaseReference = lev_count.idfsRegion
	join	[Giraffe].[dbo].[gisLocation] lev_up
	on		lev_up.idfsLocation = lev.idfsCountry
	left join	[Giraffe].[dbo].[gisLocation] loc_ex_count
	on	loc_ex_count.idfsLocation = lev_count.idfsRegion
	where	loc_ex_count.idfsLocation is null
			and lev_count.idfsRegion <= lev.idfsRegion
) lev_num
where	loc_ex.idfsLocation is null
print N''Table [gisLocation] - insert calculated records from gisRegion (level 2): '' + cast(@@rowcount as nvarchar(20))
'

select	N'
insert into	[Giraffe].[dbo].[gisLocation]
(	[idfsLocation],
	[node],
	[strHASC],
	[strCode],
	[idfsType],
	[dblLongitude],
	[dblLatitude],
	[blnIsCustom],
	[intElevation],
	[rowguid],
	[intRowStatus],
	[strMaintenanceFlag],
	[strReservedAttribute],
	[SourceSystemNameID],
	[SourceSystemKeyValue],
	[AuditCreateUser],
	[AuditCreateDTM],
	[AuditUpdateUser],
	[AuditUpdateDTM]
)
select	lev.idfsRayon,
		cast(lev_up.[node] as nvarchar(200)) + cast((isnull(lev_last_ex.intLastLevelValue, 0) + lev_num.intLevelSeqNumber) as nvarchar(20)) + N''/'' collate Cyrillic_General_CI_AS,
		lev.strHASC,
		lev.strCode,
		null, /*Settlement Type*/
		null, /*Longitude*/
		null, /*Latitude*/
		0, /*Is Custom*/
		null, /*Elevation*/
		lev.rowguid,
		lev.intRowStatus,
		lev.strMaintenanceFlag,
		lev.strReservedAttribute,
		lev.SourceSystemNameID,
		N''[{'' + N''"idfsLocation":'' + isnull(cast(lev.idfsRayon as nvarchar(20)), N''null'') + N''}]'' collate Cyrillic_General_CI_AS,
		N''system'',
		GETUTCDATE(),
		N''system'',
		GETUTCDATE()
from	[Giraffe].[dbo].[gisRayon] lev
join	[Giraffe].[dbo].gisBaseReference br_lev
on	br_lev.idfsGISBaseReference = lev.idfsRayon
join	[Giraffe].[dbo].[gisLocation] lev_up
on		lev_up.idfsLocation = lev.idfsRegion
left join	[Giraffe].[dbo].[gisLocation] loc_ex
on	loc_ex.idfsLocation = lev.idfsRayon
outer apply
(	select	max(cast(replace(RIGHT(cast(loc_last.[node] as nvarchar(200)), LEN(cast(loc_last.[node] as nvarchar(200))) - [Falcon].[dbo].fnGetLastCharIndexOfSubstringInNonTrimString(left(cast(loc_last.[node] as nvarchar(200)), LEN(cast(loc_last.[node] as nvarchar(200))) - 1), N''/'', 0) + 1), N''/'', N'''') as bigint)) as intLastLevelValue
	from	[Giraffe].[dbo].[gisLocation] loc_last
	where	loc_last.[node].GetLevel() = 3
) lev_last_ex
outer apply
(	select	count(lev_count.idfsRayon) as intLevelSeqNumber
	from	[Giraffe].[dbo].[gisRayon] lev_count
	join	[Giraffe].[dbo].gisBaseReference br_lev_count
	on	br_lev_count.idfsGISBaseReference = lev_count.idfsRayon
	join	[Giraffe].[dbo].[gisLocation] lev_up
	on		lev_up.idfsLocation = lev.idfsRegion
	left join	[Giraffe].[dbo].[gisLocation] loc_ex_count
	on	loc_ex_count.idfsLocation = lev_count.idfsRayon
	where	loc_ex_count.idfsLocation is null
			and lev_count.idfsRayon <= lev.idfsRayon
) lev_num
where	loc_ex.idfsLocation is null
print N''Table [gisLocation] - insert calculated records from gisRayon (level 3): '' + cast(@@rowcount as nvarchar(20))
'

select	N'
insert into	[Giraffe].[dbo].[gisLocation]
(	[idfsLocation],
	[node],
	[strHASC],
	[strCode],
	[idfsType],
	[dblLongitude],
	[dblLatitude],
	[blnIsCustom],
	[intElevation],
	[rowguid],
	[intRowStatus],
	[strMaintenanceFlag],
	[strReservedAttribute],
	[SourceSystemNameID],
	[SourceSystemKeyValue],
	[AuditCreateUser],
	[AuditCreateDTM],
	[AuditUpdateUser],
	[AuditUpdateDTM]
)
select	lev.idfsSettlement,
		cast(lev_up.[node] as nvarchar(200)) + cast((isnull(lev_last_ex.intLastLevelValue, 0) + lev_num.intLevelSeqNumber) as nvarchar(20)) + N''/'' collate Cyrillic_General_CI_AS,
		null,
		lev.strSettlementCode,
		lev.idfsSettlementType, /*Settlement Type*/
		lev.dblLongitude, /*Longitude*/
		lev.dblLatitude, /*Latitude*/
		lev.blnIsCustomSettlement, /*Is Custom*/
		lev.intElevation, /*Elevation*/
		lev.rowguid,
		lev.intRowStatus,
		lev.strMaintenanceFlag,
		lev.strReservedAttribute,
		lev.SourceSystemNameID,
		N''[{'' + N''"idfsLocation":'' + isnull(cast(lev.idfsSettlement as nvarchar(20)), N''null'') + N''}]'' collate Cyrillic_General_CI_AS,
		N''system'',
		GETUTCDATE(),
		N''system'',
		GETUTCDATE()
from	[Giraffe].[dbo].[gisSettlement] lev
join	[Giraffe].[dbo].gisBaseReference br_lev
on	br_lev.idfsGISBaseReference = lev.idfsSettlement
join	[Giraffe].[dbo].[gisLocation] lev_up
on		lev_up.idfsLocation = lev.idfsRayon
left join	[Giraffe].[dbo].[gisLocation] loc_ex
on	loc_ex.idfsLocation = lev.idfsSettlement
outer apply
(	select	max(cast(replace(RIGHT(cast(loc_last.[node] as nvarchar(200)), LEN(cast(loc_last.[node] as nvarchar(200))) - [Falcon].[dbo].fnGetLastCharIndexOfSubstringInNonTrimString(left(cast(loc_last.[node] as nvarchar(200)), LEN(cast(loc_last.[node] as nvarchar(200))) - 1), N''/'', 0) + 1), N''/'', N'''') as bigint)) as intLastLevelValue
	from	[Giraffe].[dbo].[gisLocation] loc_last
	where	loc_last.[node].GetLevel() = 4
) lev_last_ex
outer apply
(	select	count(lev_count.idfsSettlement) as intLevelSeqNumber
	from	[Giraffe].[dbo].[gisSettlement] lev_count
	join	[Giraffe].[dbo].gisBaseReference br_lev_count
	on	br_lev_count.idfsGISBaseReference = lev_count.idfsSettlement
	join	[Giraffe].[dbo].[gisLocation] lev_up
	on		lev_up.idfsLocation = lev.idfsRayon
	left join	[Giraffe].[dbo].[gisLocation] loc_ex_count
	on	loc_ex_count.idfsLocation = lev_count.idfsSettlement
	where	loc_ex_count.idfsLocation is null
			and lev_count.idfsSettlement <= lev.idfsSettlement
) lev_num
where	loc_ex.idfsLocation is null
print N''Table [gisLocation] - insert calculated records from gisSettlement (level 4): '' + cast(@@rowcount as nvarchar(20))

print N''Calculate records in EIDSSv7 - [gisLocation] - end''
/************************************************************
* Calculate records in EIDSSv7 - [gisLocation] - end
************************************************************/

print N''''
print N''''
print N''''

'




select	N'
/************************************************************
* Calculate records in EIDSSv7 - [gisLocationDenormalized] - start
************************************************************/
print N''Calculate records in EIDSSv7 - [gisLocationDenormalized] - start''

update	gld_ex
set		gld_ex.[Level1ID] = loc.idfsLocation,
		gld_ex.[Level2ID] = null,
		gld_ex.[Level3ID] = null,
		gld_ex.[Level4ID] = null,
		gld_ex.[Level5ID] = null,
		gld_ex.[Level6ID] = null,
		gld_ex.[Level7ID] = null,
		gld_ex.[Level1Name] = coalesce(gsnt.strTextString, gbr.strDefault, gld_ex.[Level1Name]),
		gld_ex.[Level2Name] = null,
		gld_ex.[Level3Name] = null,
		gld_ex.[Level4Name] = null,
		gld_ex.[Level5Name] = null,
		gld_ex.[Level6Name] = null,
		gld_ex.[Level7Name] = null,
		gld_ex.[Node] = loc.[node],
		gld_ex.[LevelType] = isnull(grt.strGISReferenceTypeName, gld_ex.LevelType),
		gld_ex.[Level] = 1

from	[Giraffe].[dbo].[gisLocation] loc
left join	[Giraffe].[dbo].[gisBaseReference] gbr
on	gbr.idfsGISBaseReference = loc.idfsLocation
left join	[Giraffe].[dbo].[gisReferenceType] grt
on	grt.idfsGISReferenceType = gbr.idfsGISReferenceType

join	[Falcon].[dbo].[trtLanguageToCP] lang_cp
on	lang_cp.idfCustomizationPackage = @idfCustomizationPackage
join	[Giraffe].[dbo].[trtBaseReference] lang
on	lang.idfsBaseReference = lang_cp.idfsLanguage

left join	[Giraffe].[dbo].[gisStringNameTranslation] gsnt
on	gsnt.idfsGISBaseReference = gbr.idfsGISBaseReference
	and gsnt.idfsLanguage = lang.idfsBaseReference

join	[Giraffe].[dbo].[gisLocationDenormalized] gld_ex
on	gld_ex.idfsLocation = loc.idfsLocation
	and gld_ex.idfsLanguage = lang.idfsBaseReference

where	loc.[node].GetLevel() = 1
print N''Table [gisLocationDenormalized] - update calculated records from gisLocation (level 1): '' + cast(@@rowcount as nvarchar(20))

'

select	N'
insert into	[Giraffe].[dbo].[gisLocationDenormalized]
(	[Level1ID],
	[Level2ID],
	[Level3ID],
	[Level4ID],
	[Level5ID],
	[Level6ID],
	[Level7ID],
	[Level1Name],
	[Level2Name],
	[Level3Name],
	[Level4Name],
	[Level5Name],
	[Level6Name],
	[Level7Name],
	[Node],
	[Level],
	[idfsLocation],
	[LevelType],
	[idfsLanguage]
)
select	loc.idfsLocation,
		null,
		null,
		null,
		null,
		null,
		null,
		isnull(gsnt.strTextString, gbr.strDefault),
		null,
		null,
		null,
		null,
		null,
		null,
		loc.[node],
		1,
		loc.idfsLocation,
		grt.strGISReferenceTypeName,
		lang.idfsBaseReference

from	[Giraffe].[dbo].[gisLocation] loc
join	[Giraffe].[dbo].[gisBaseReference] gbr
on	gbr.idfsGISBaseReference = loc.idfsLocation
join	[Giraffe].[dbo].[gisReferenceType] grt
on	grt.idfsGISReferenceType = gbr.idfsGISReferenceType

join	[Falcon].[dbo].[trtLanguageToCP] lang_cp
on	lang_cp.idfCustomizationPackage = @idfCustomizationPackage
join	[Giraffe].[dbo].[trtBaseReference] lang
on	lang.idfsBaseReference = lang_cp.idfsLanguage

left join	[Giraffe].[dbo].[gisStringNameTranslation] gsnt
on	gsnt.idfsGISBaseReference = gbr.idfsGISBaseReference
	and gsnt.idfsLanguage = lang.idfsBaseReference

left join	[Giraffe].[dbo].[gisLocationDenormalized] gld_ex
on	gld_ex.idfsLocation = loc.idfsLocation
	and gld_ex.idfsLanguage = lang.idfsBaseReference

where	loc.[node].GetLevel() = 1
		and gld_ex.idfsLocation is null
print N''Table [gisLocationDenormalized] - insert calculated records from gisLocation (level 1): '' + cast(@@rowcount as nvarchar(20))

'

select	N'
update	gld_child
set		gld_child.[Level1ID] = loc.idfsLocation,
		gld_child.[Level1Name] = coalesce(gsnt.strTextString, gbr.strDefault, gld_ex.[Level1Name])
from	[Giraffe].[dbo].[gisLocation] loc
join	[Giraffe].[dbo].[gisBaseReference] gbr
on	gbr.idfsGISBaseReference = loc.idfsLocation
join	[Giraffe].[dbo].[gisReferenceType] grt
on	grt.idfsGISReferenceType = gbr.idfsGISReferenceType

join	[Falcon].[dbo].[trtLanguageToCP] lang_cp
on	lang_cp.idfCustomizationPackage = @idfCustomizationPackage
join	[Giraffe].[dbo].[trtBaseReference] lang
on	lang.idfsBaseReference = lang_cp.idfsLanguage

left join	[Giraffe].[dbo].[gisStringNameTranslation] gsnt
on	gsnt.idfsGISBaseReference = gbr.idfsGISBaseReference
	and gsnt.idfsLanguage = lang.idfsBaseReference

join	[Giraffe].[dbo].[gisLocationDenormalized] gld_ex
on	gld_ex.idfsLocation = loc.idfsLocation
	and gld_ex.idfsLanguage = lang.idfsBaseReference

join	[Giraffe].[dbo].[gisLocationDenormalized] gld_child
on	gld_child.[Node].IsDescendantOf(gld_ex.[Node]) = 1
	and gld_child.idfsLanguage = lang.idfsBaseReference
	and gld_child.[Node].GetLevel() > 1

where	loc.[node].GetLevel() = 1
print N''Table [gisLocationDenormalized] - update calculated records from gisLocation (descendants of level 1): '' + cast(@@rowcount as nvarchar(20))
print N''''

'

select	N'
update	gld_ex
set		gld_ex.[Level2ID] = loc.idfsLocation,
		gld_ex.[Level3ID] = null,
		gld_ex.[Level4ID] = null,
		gld_ex.[Level5ID] = null,
		gld_ex.[Level6ID] = null,
		gld_ex.[Level7ID] = null,
		gld_ex.[Level2Name] = coalesce(gsnt.strTextString, gbr.strDefault, gld_ex.[Level2Name]),
		gld_ex.[Level3Name] = null,
		gld_ex.[Level4Name] = null,
		gld_ex.[Level5Name] = null,
		gld_ex.[Level6Name] = null,
		gld_ex.[Level7Name] = null,
		gld_ex.[Node] = loc.[node],
		gld_ex.[LevelType] = isnull(grt.strGISReferenceTypeName, gld_ex.LevelType),
		gld_ex.[Level] = 2

from	[Giraffe].[dbo].[gisLocation] loc
left join	[Giraffe].[dbo].[gisBaseReference] gbr
on	gbr.idfsGISBaseReference = loc.idfsLocation
left join	[Giraffe].[dbo].[gisReferenceType] grt
on	grt.idfsGISReferenceType = gbr.idfsGISReferenceType

join	[Falcon].[dbo].[trtLanguageToCP] lang_cp
on	lang_cp.idfCustomizationPackage = @idfCustomizationPackage
join	[Giraffe].[dbo].[trtBaseReference] lang
on	lang.idfsBaseReference = lang_cp.idfsLanguage

left join	[Giraffe].[dbo].[gisStringNameTranslation] gsnt
on	gsnt.idfsGISBaseReference = gbr.idfsGISBaseReference
	and gsnt.idfsLanguage = lang.idfsBaseReference

join	[Giraffe].[dbo].[gisLocationDenormalized] gld_ex
on	gld_ex.idfsLocation = loc.idfsLocation
	and gld_ex.idfsLanguage = lang.idfsBaseReference

where	loc.[node].GetLevel() = 2
print N''Table [gisLocationDenormalized] - update calculated records from gisLocation (level 2): '' + cast(@@rowcount as nvarchar(20))


'

select	N'
insert into	[Giraffe].[dbo].[gisLocationDenormalized]
(	[Level1ID],
	[Level2ID],
	[Level3ID],
	[Level4ID],
	[Level5ID],
	[Level6ID],
	[Level7ID],
	[Level1Name],
	[Level2Name],
	[Level3Name],
	[Level4Name],
	[Level5Name],
	[Level6Name],
	[Level7Name],
	[Node],
	[Level],
	[idfsLocation],
	[LevelType],
	[idfsLanguage]
)
select	gld_lev_up.[Level1ID],
		loc.idfsLocation,
		null,
		null,
		null,
		null,
		null,
		gld_lev_up.[Level1Name],
		isnull(gsnt.strTextString, gbr.strDefault),
		null,
		null,
		null,
		null,
		null,
		loc.[node],
		2,
		loc.idfsLocation,
		grt.strGISReferenceTypeName,
		lang.idfsBaseReference

from	[Giraffe].[dbo].[gisLocation] loc
join	[Giraffe].[dbo].[gisBaseReference] gbr
on	gbr.idfsGISBaseReference = loc.idfsLocation
join	[Giraffe].[dbo].[gisReferenceType] grt
on	grt.idfsGISReferenceType = gbr.idfsGISReferenceType

join	[Falcon].[dbo].[trtLanguageToCP] lang_cp
on	lang_cp.idfCustomizationPackage = @idfCustomizationPackage
join	[Giraffe].[dbo].[trtBaseReference] lang
on	lang.idfsBaseReference = lang_cp.idfsLanguage

left join	[Giraffe].[dbo].[gisStringNameTranslation] gsnt
on	gsnt.idfsGISBaseReference = gbr.idfsGISBaseReference
	and gsnt.idfsLanguage = lang.idfsBaseReference

left join	[Giraffe].[dbo].[gisLocationDenormalized] gld_lev_up
on	gld_lev_up.[Node] = loc.[node].GetAncestor(1)
	and gld_lev_up.idfsLanguage = lang.idfsBaseReference

left join	[Giraffe].[dbo].[gisLocationDenormalized] gld_ex
on	gld_ex.idfsLocation = loc.idfsLocation
	and gld_ex.idfsLanguage = lang.idfsBaseReference

where	loc.[node].GetLevel() = 2
		and gld_ex.idfsLocation is null
print N''Table [gisLocationDenormalized] - insert calculated records from gisLocation (level 2): '' + cast(@@rowcount as nvarchar(20))

'

select	N'
update	gld_child
set		gld_child.[Level2ID] = loc.idfsLocation,
		gld_child.[Level2Name] = coalesce(gsnt.strTextString, gbr.strDefault, gld_ex.[Level2Name])
from	[Giraffe].[dbo].[gisLocation] loc
join	[Giraffe].[dbo].[gisBaseReference] gbr
on	gbr.idfsGISBaseReference = loc.idfsLocation
join	[Giraffe].[dbo].[gisReferenceType] grt
on	grt.idfsGISReferenceType = gbr.idfsGISReferenceType

join	[Falcon].[dbo].[trtLanguageToCP] lang_cp
on	lang_cp.idfCustomizationPackage = @idfCustomizationPackage
join	[Giraffe].[dbo].[trtBaseReference] lang
on	lang.idfsBaseReference = lang_cp.idfsLanguage

left join	[Giraffe].[dbo].[gisStringNameTranslation] gsnt
on	gsnt.idfsGISBaseReference = gbr.idfsGISBaseReference
	and gsnt.idfsLanguage = lang.idfsBaseReference

join	[Giraffe].[dbo].[gisLocationDenormalized] gld_ex
on	gld_ex.idfsLocation = loc.idfsLocation
	and gld_ex.idfsLanguage = lang.idfsBaseReference

join	[Giraffe].[dbo].[gisLocationDenormalized] gld_child
on	gld_child.[Node].IsDescendantOf(gld_ex.[Node]) = 1
	and gld_child.idfsLanguage = lang.idfsBaseReference
	and gld_child.[Node].GetLevel() > 2

where	loc.[node].GetLevel() = 2
print N''Table [gisLocationDenormalized] - update calculated records from gisLocation (descendants of level 2): '' + cast(@@rowcount as nvarchar(20))
print N''''

'

select	N'
update	gld_ex
set		gld_ex.[Level3ID] = loc.idfsLocation,
		gld_ex.[Level4ID] = null,
		gld_ex.[Level5ID] = null,
		gld_ex.[Level6ID] = null,
		gld_ex.[Level7ID] = null,
		gld_ex.[Level3Name] = coalesce(gsnt.strTextString, gbr.strDefault, gld_ex.[Level3Name]),
		gld_ex.[Level4Name] = null,
		gld_ex.[Level5Name] = null,
		gld_ex.[Level6Name] = null,
		gld_ex.[Level7Name] = null,
		gld_ex.[Node] = loc.[node],
		gld_ex.[LevelType] = isnull(grt.strGISReferenceTypeName, gld_ex.LevelType),
		gld_ex.[Level] = 3

from	[Giraffe].[dbo].[gisLocation] loc
left join	[Giraffe].[dbo].[gisBaseReference] gbr
on	gbr.idfsGISBaseReference = loc.idfsLocation
left join	[Giraffe].[dbo].[gisReferenceType] grt
on	grt.idfsGISReferenceType = gbr.idfsGISReferenceType

join	[Falcon].[dbo].[trtLanguageToCP] lang_cp
on	lang_cp.idfCustomizationPackage = @idfCustomizationPackage
join	[Giraffe].[dbo].[trtBaseReference] lang
on	lang.idfsBaseReference = lang_cp.idfsLanguage

left join	[Giraffe].[dbo].[gisStringNameTranslation] gsnt
on	gsnt.idfsGISBaseReference = gbr.idfsGISBaseReference
	and gsnt.idfsLanguage = lang.idfsBaseReference

join	[Giraffe].[dbo].[gisLocationDenormalized] gld_ex
on	gld_ex.idfsLocation = loc.idfsLocation
	and gld_ex.idfsLanguage = lang.idfsBaseReference

where	loc.[node].GetLevel() = 3
print N''Table [gisLocationDenormalized] - update calculated records from gisLocation (level 3): '' + cast(@@rowcount as nvarchar(20))


'

select	N'
insert into	[Giraffe].[dbo].[gisLocationDenormalized]
(	[Level1ID],
	[Level2ID],
	[Level3ID],
	[Level4ID],
	[Level5ID],
	[Level6ID],
	[Level7ID],
	[Level1Name],
	[Level2Name],
	[Level3Name],
	[Level4Name],
	[Level5Name],
	[Level6Name],
	[Level7Name],
	[Node],
	[Level],
	[idfsLocation],
	[LevelType],
	[idfsLanguage]
)
select	gld_lev_up.[Level1ID],
		gld_lev_up.[Level2ID],
		loc.idfsLocation,
		null,
		null,
		null,
		null,
		gld_lev_up.[Level1Name],
		gld_lev_up.[Level2Name],
		isnull(gsnt.strTextString, gbr.strDefault),
		null,
		null,
		null,
		null,
		loc.[node],
		3,
		loc.idfsLocation,
		grt.strGISReferenceTypeName,
		lang.idfsBaseReference

from	[Giraffe].[dbo].[gisLocation] loc
join	[Giraffe].[dbo].[gisBaseReference] gbr
on	gbr.idfsGISBaseReference = loc.idfsLocation
join	[Giraffe].[dbo].[gisReferenceType] grt
on	grt.idfsGISReferenceType = gbr.idfsGISReferenceType

join	[Falcon].[dbo].[trtLanguageToCP] lang_cp
on	lang_cp.idfCustomizationPackage = @idfCustomizationPackage
join	[Giraffe].[dbo].[trtBaseReference] lang
on	lang.idfsBaseReference = lang_cp.idfsLanguage

left join	[Giraffe].[dbo].[gisStringNameTranslation] gsnt
on	gsnt.idfsGISBaseReference = gbr.idfsGISBaseReference
	and gsnt.idfsLanguage = lang.idfsBaseReference

left join	[Giraffe].[dbo].[gisLocationDenormalized] gld_lev_up
on	gld_lev_up.[Node] = loc.[node].GetAncestor(1)
	and gld_lev_up.idfsLanguage = lang.idfsBaseReference

left join	[Giraffe].[dbo].[gisLocationDenormalized] gld_ex
on	gld_ex.idfsLocation = loc.idfsLocation
	and gld_ex.idfsLanguage = lang.idfsBaseReference

where	loc.[node].GetLevel() = 3
		and gld_ex.idfsLocation is null
print N''Table [gisLocationDenormalized] - insert calculated records from gisLocation (level 3): '' + cast(@@rowcount as nvarchar(20))

'

select	N'
update	gld_child
set		gld_child.[Level3ID] = loc.idfsLocation,
		gld_child.[Level3Name] = coalesce(gsnt.strTextString, gbr.strDefault, gld_ex.[Level3Name])
from	[Giraffe].[dbo].[gisLocation] loc
join	[Giraffe].[dbo].[gisBaseReference] gbr
on	gbr.idfsGISBaseReference = loc.idfsLocation
join	[Giraffe].[dbo].[gisReferenceType] grt
on	grt.idfsGISReferenceType = gbr.idfsGISReferenceType

join	[Falcon].[dbo].[trtLanguageToCP] lang_cp
on	lang_cp.idfCustomizationPackage = @idfCustomizationPackage
join	[Giraffe].[dbo].[trtBaseReference] lang
on	lang.idfsBaseReference = lang_cp.idfsLanguage

left join	[Giraffe].[dbo].[gisStringNameTranslation] gsnt
on	gsnt.idfsGISBaseReference = gbr.idfsGISBaseReference
	and gsnt.idfsLanguage = lang.idfsBaseReference

join	[Giraffe].[dbo].[gisLocationDenormalized] gld_ex
on	gld_ex.idfsLocation = loc.idfsLocation
	and gld_ex.idfsLanguage = lang.idfsBaseReference

join	[Giraffe].[dbo].[gisLocationDenormalized] gld_child
on	gld_child.[Node].IsDescendantOf(gld_ex.[Node]) = 1
	and gld_child.idfsLanguage = lang.idfsBaseReference
	and gld_child.[Node].GetLevel() > 3

where	loc.[node].GetLevel() = 3
print N''Table [gisLocationDenormalized] - update calculated records from gisLocation (descendants of level 3): '' + cast(@@rowcount as nvarchar(20))
print N''''


'

select	N'
update	gld_ex
set		gld_ex.[Level4ID] = loc.idfsLocation,
		gld_ex.[Level5ID] = null,
		gld_ex.[Level6ID] = null,
		gld_ex.[Level7ID] = null,
		gld_ex.[Level4Name] = coalesce(gsnt.strTextString, gbr.strDefault, gld_ex.[Level4Name]),
		gld_ex.[Level5Name] = null,
		gld_ex.[Level6Name] = null,
		gld_ex.[Level7Name] = null,
		gld_ex.[Node] = loc.[node],
		gld_ex.[LevelType] = isnull(grt.strGISReferenceTypeName, gld_ex.LevelType),
		gld_ex.[Level] = 4

from	[Giraffe].[dbo].[gisLocation] loc
left join	[Giraffe].[dbo].[gisBaseReference] gbr
on	gbr.idfsGISBaseReference = loc.idfsLocation
left join	[Giraffe].[dbo].[gisReferenceType] grt
on	grt.idfsGISReferenceType = gbr.idfsGISReferenceType

join	[Falcon].[dbo].[trtLanguageToCP] lang_cp
on	lang_cp.idfCustomizationPackage = @idfCustomizationPackage
join	[Giraffe].[dbo].[trtBaseReference] lang
on	lang.idfsBaseReference = lang_cp.idfsLanguage

left join	[Giraffe].[dbo].[gisStringNameTranslation] gsnt
on	gsnt.idfsGISBaseReference = gbr.idfsGISBaseReference
	and gsnt.idfsLanguage = lang.idfsBaseReference

join	[Giraffe].[dbo].[gisLocationDenormalized] gld_ex
on	gld_ex.idfsLocation = loc.idfsLocation
	and gld_ex.idfsLanguage = lang.idfsBaseReference

where	loc.[node].GetLevel() = 4
print N''Table [gisLocationDenormalized] - update calculated records from gisLocation (level 4): '' + cast(@@rowcount as nvarchar(20))


'

select	N'
insert into	[Giraffe].[dbo].[gisLocationDenormalized]
(	[Level1ID],
	[Level2ID],
	[Level3ID],
	[Level4ID],
	[Level5ID],
	[Level6ID],
	[Level7ID],
	[Level1Name],
	[Level2Name],
	[Level3Name],
	[Level4Name],
	[Level5Name],
	[Level6Name],
	[Level7Name],
	[Node],
	[Level],
	[idfsLocation],
	[LevelType],
	[idfsLanguage]
)
select	gld_lev_up.[Level1ID],
		gld_lev_up.[Level2ID],
		gld_lev_up.[Level3ID],
		loc.idfsLocation,
		null,
		null,
		null,
		gld_lev_up.[Level1Name],
		gld_lev_up.[Level2Name],
		gld_lev_up.[Level3Name],
		isnull(gsnt.strTextString, gbr.strDefault),
		null,
		null,
		null,
		loc.[node],
		4,
		loc.idfsLocation,
		grt.strGISReferenceTypeName,
		lang.idfsBaseReference

from	[Giraffe].[dbo].[gisLocation] loc
join	[Giraffe].[dbo].[gisBaseReference] gbr
on	gbr.idfsGISBaseReference = loc.idfsLocation
join	[Giraffe].[dbo].[gisReferenceType] grt
on	grt.idfsGISReferenceType = gbr.idfsGISReferenceType

join	[Falcon].[dbo].[trtLanguageToCP] lang_cp
on	lang_cp.idfCustomizationPackage = @idfCustomizationPackage
join	[Giraffe].[dbo].[trtBaseReference] lang
on	lang.idfsBaseReference = lang_cp.idfsLanguage

left join	[Giraffe].[dbo].[gisStringNameTranslation] gsnt
on	gsnt.idfsGISBaseReference = gbr.idfsGISBaseReference
	and gsnt.idfsLanguage = lang.idfsBaseReference

left join	[Giraffe].[dbo].[gisLocationDenormalized] gld_lev_up
on	gld_lev_up.[Node] = loc.[node].GetAncestor(1)
	and gld_lev_up.idfsLanguage = lang.idfsBaseReference

left join	[Giraffe].[dbo].[gisLocationDenormalized] gld_ex
on	gld_ex.idfsLocation = loc.idfsLocation
	and gld_ex.idfsLanguage = lang.idfsBaseReference

where	loc.[node].GetLevel() = 4
		and gld_ex.idfsLocation is null
print N''Table [gisLocationDenormalized] - insert calculated records from gisLocation (level 4): '' + cast(@@rowcount as nvarchar(20))

'

select	N'
update	gld_child
set		gld_child.[Level4ID] = loc.idfsLocation,
		gld_child.[Level4Name] = coalesce(gsnt.strTextString, gbr.strDefault, gld_ex.[Level4Name])
from	[Giraffe].[dbo].[gisLocation] loc
join	[Giraffe].[dbo].[gisBaseReference] gbr
on	gbr.idfsGISBaseReference = loc.idfsLocation
join	[Giraffe].[dbo].[gisReferenceType] grt
on	grt.idfsGISReferenceType = gbr.idfsGISReferenceType

join	[Falcon].[dbo].[trtLanguageToCP] lang_cp
on	lang_cp.idfCustomizationPackage = @idfCustomizationPackage
join	[Giraffe].[dbo].[trtBaseReference] lang
on	lang.idfsBaseReference = lang_cp.idfsLanguage

left join	[Giraffe].[dbo].[gisStringNameTranslation] gsnt
on	gsnt.idfsGISBaseReference = gbr.idfsGISBaseReference
	and gsnt.idfsLanguage = lang.idfsBaseReference

join	[Giraffe].[dbo].[gisLocationDenormalized] gld_ex
on	gld_ex.idfsLocation = loc.idfsLocation
	and gld_ex.idfsLanguage = lang.idfsBaseReference

join	[Giraffe].[dbo].[gisLocationDenormalized] gld_child
on	gld_child.[Node].IsDescendantOf(gld_ex.[Node]) = 1
	and gld_child.idfsLanguage = lang.idfsBaseReference
	and gld_child.[Node].GetLevel() > 4

where	loc.[node].GetLevel() = 4
print N''Table [gisLocationDenormalized] - update calculated records from gisLocation (descendants of level 4): '' + cast(@@rowcount as nvarchar(20))
print N''''




print N''Calculate records in EIDSSv7 - [gisLocationDenormalized] - end''
/************************************************************
* Calculate records in EIDSSv7 - [gisLocationDenormalized] - end
************************************************************/

print N''''
print N''''
print N''''

'






















select	N'
print N''''
print N''Insert records - GIS Reference tables - end''
print N''''
print N''''
/************************************************************
* Insert records - GIS Reference tables - end
************************************************************/
'


select	N'
/************************************************************
* Insert records - Flexible Forms tables - start
************************************************************/
print N''''
print N''Insert records - Flexible Forms tables - start''
print N''''
'

select	N'
/************************************************************
* Insert records - [' + [table_name] + N']
************************************************************/
' + strInsertHeader + N'
' + strInsertColumns + N'
' + strSelectColumns + N'
' + strInsertFromHeader + N'
' + strInsertFromJoins + N'
' + strInsertWhereHeader + strInsertWhereConditions + N'
' + strInsertPrint + N'
' collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @FfTableIdFirst and @FfTableIdLast
order by idfId


select	N'
print N''''
print N''Insert records - Flexible Forms tables - end''
print N''''
print N''''
/************************************************************
* Insert records - Flexible Forms tables - end
************************************************************/
'



select	N'
/************************************************************
* Insert records - Reference Matrices tables - start
************************************************************/
print N''''
print N''Insert records - Reference Matrices tables - start''
print N''''
'

select	N'
/************************************************************
* Insert records - [' + [table_name] + N']
************************************************************/
' + strInsertHeader + N'
' + strInsertColumns + N'
' + strSelectColumns + N'
' + strInsertFromHeader + N'
' + strInsertFromJoins + N'
' + strInsertWhereHeader + strInsertWhereConditions + N'
' + strInsertPrint + N'
' collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @RefMtrxTableIdFirst and @RefMtrxTableIdLast
order by idfId


select	N'
print N''''
print N''Insert records - Reference Matrices tables - end''
print N''''
print N''''
/************************************************************
* Insert records - Reference Matrices tables - end
************************************************************/
'



select	N'
/************************************************************
* Insert records - Customization Package Information tables - start
************************************************************/
print N''''
print N''Insert records - Customization Package Information tables - start''
print N''''
'

select	N'
/************************************************************
* Insert records - [' + [table_name] + N']
************************************************************/
' + strInsertHeader + N'
' + strInsertColumns + N'
' + strSelectColumns + N'
' + strInsertFromHeader + N'
' + strInsertFromJoins + N'
' + strInsertWhereHeader + strInsertWhereConditions + N'
' + strInsertPrint + N'
' collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @CpTableIdFirst and @CpTableIdLast
order by idfId


select	N'
print N''''
print N''Insert records - Customization Package Information tables - end''
print N''''
print N''''
/************************************************************
* Insert records - Customization Package Information tables - end
************************************************************/
'



select	N'
/************************************************************
* Insert records - GIS/Reference Attributes tables - start
************************************************************/
print N''''
print N''Insert records - GIS/Reference Attributes tables - start''
print N''''
'

select	N'
/************************************************************
* Insert records - [' + [table_name] + N']
************************************************************/
' + strInsertHeader + N'
' + strInsertColumns + N'
' + strSelectColumns + N'
' + strInsertFromHeader + N'
' + strInsertFromJoins + N'
' + strInsertWhereHeader + strInsertWhereConditions + N'
' + strInsertPrint + N'
' collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @AttrTableIdFirst and @AttrTableIdLast
order by idfId


select	N'
print N''''
print N''Insert records - GIS/Reference Attributes tables - end''
print N''''
print N''''
/************************************************************
* Insert records - GIS/Reference Attributes tables - end
************************************************************/
'



select	N'
/************************************************************
* Insert records - Tables with links from reference and matrices tables to Customization Package - start
************************************************************/
print N''''
print N''Insert records - Tables with links from reference and matrices tables to Customization Package - start''
print N''''
'

select	N'
/************************************************************
* Insert records - [' + [table_name] + N']
************************************************************/
' + strInsertHeader + N'
' + strInsertColumns + N'
' + strSelectColumns + N'
' + strInsertFromHeader + N'
' + strInsertFromJoins + N'
' + strInsertWhereHeader + strInsertWhereConditions + N'
' + strInsertPrint + N'
' collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @LinkToCpTableIdFirst and @LinkToCpTableIdLast
order by idfId


select	N'
print N''''
print N''Insert records - Tables with links from reference and matrices tables to Customization Package - end''
print N''''
print N''''
/************************************************************
* Insert records - Tables with links from reference and matrices tables to Customization Package - end
************************************************************/
'





select	N'
/************************************************************
* Insert records - Tables with rows of aggregate matrices - start
************************************************************/
print N''''
print N''Insert records - Tables with rows of aggregate matrices - start''
print N''''
'

select	N'
/************************************************************
* Insert records - [' + [table_name] + N']
************************************************************/
' + strInsertHeader + N'
' + strInsertColumns + N'
' + strSelectColumns + N'
' + strInsertFromHeader + N'
' + strInsertFromJoins + N'
' + strInsertWhereHeader + strInsertWhereConditions + N'
' + strInsertPrint + N'
' collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @AggrMtxTableIdFirst and @AggrMtxTableIdLast
order by idfId


select	N'
print N''''
print N''Insert records - Tables with rows of aggregate matrices - end''
print N''''
print N''''
/************************************************************
* Insert records - Tables with rows of aggregate matrices - end
************************************************************/
'





select	N'
/************************************************************
* Insert records - Tables with administrative module data - part 1 - start
************************************************************/
print N''''
print N''Insert records - Tables with administrative module data - part 1 - start''
print N''''
'

select	N'
/************************************************************
* Prepare data before insert - [' + [table_name] + N']
************************************************************/
' + strStatementBeforeInsert collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert2 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert3 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert4 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert5 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert6 collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @AdminPart1TableIdFirst and @AdminPart1TableIdLast
		and len(strStatementBeforeInsert) > 0 
order by idfId


select	N'
/************************************************************
* Insert records - [' + [table_name] + N']
************************************************************/
' + strInsertHeader + N'
' + strInsertColumns + N'
' + strSelectColumns + N'
' + strInsertFromHeader + N'
' + strInsertFromJoins + N'
' + strInsertWhereHeader + strInsertWhereConditions + N'
' + strInsertPrint + N'
' collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @AdminPart1TableIdFirst and @AdminPart1TableIdLast
order by idfId


select	N'
/************************************************************
* Update records with links to foreign key data - [' + [table_name] + N']
************************************************************/
' + strUpdateAfterInsert + N'
' collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @AdminPart1TableIdFirst and @AdminPart1TableIdLast
		and len(strUpdateAfterInsert) > 0 
order by idfId


select	N'
print N''''
print N''Insert records - Tables with administrative module data - part 1 - end''
print N''''
print N''''
/************************************************************
* Insert records - Tables with administrative module data - part 1 - end
************************************************************/
'





select	N'
/************************************************************
* Insert records - Tables with administrative module data - part 2 - start
************************************************************/
print N''''
print N''Insert records - Tables with administrative module data - part 2 - start''
print N''''
'

select	N'
/************************************************************
* Prepare data before insert - [' + [table_name] + N']
************************************************************/
' + strStatementBeforeInsert collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert2 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert3 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert4 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert5 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert6 collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @AdminPart2TableIdFirst and @AdminPart2TableIdLast
		and len(strStatementBeforeInsert) > 0 
order by idfId

select	N'
/************************************************************
* Insert records - [' + [table_name] + N']
************************************************************/
' + strInsertHeader + N'
' + strInsertColumns + N'
' + strSelectColumns + N'
' + strInsertFromHeader + N'
' + strInsertFromJoins + N'
' + strInsertWhereHeader + strInsertWhereConditions + N'
' + strInsertPrint + N'
' collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @AdminPart2TableIdFirst and @AdminPart2TableIdLast
order by idfId


select	N'
/************************************************************
* Update records with links to foreign key data - [' + [table_name] + N']
************************************************************/
' + strUpdateAfterInsert + N'
' collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @AdminPart2TableIdFirst and @AdminPart2TableIdLast
		and len(strUpdateAfterInsert) > 0 
order by idfId

select	N'
print N''''
print N''Insert records - Tables with administrative module data - part 2 - end''
print N''''
print N''''
/************************************************************
* Insert records - Tables with administrative module data - part 2 - end
************************************************************/
'


select	N'
/************************************************************
* Insert records - New tables with user account information - start
************************************************************/
print N''''
print N''Insert records - New tables with user account information - start''
print N''''

declare @ArchiveCmd nvarchar(max) = N''''

if DB_NAME() like N''%_Archive'' collate Latin1_General_CI_AS
begin
	set @ArchiveCmd = N''
INSERT INTO ['' + DB_NAME() + N''].[dbo].[AspNetUsers]
(	 [Id]
	,[idfUserID]
	,[Email]
	,[EmailConfirmed]
	,[PasswordHash]
	,[SecurityStamp]
	,[PhoneNumber]
	,[PhoneNumberConfirmed]
	,[TwoFactorEnabled]
	,[LockoutEnd]
	,[LockoutEnabled]
	,[AccessFailedCount]
	,[UserName]
	,[blnDisabled]
	,[strDisabledReason]
	,[datPasswordLastChanged]
	,[PasswordResetRequired]
	,[NormalizedUsername]
	,[ConcurrencyStamp]
	,[NormalizedEmail]
	,[DateDisabled]
)
SELECT	 AspNetUsers_v7_Actual.[Id]
		,AspNetUsers_v7_Actual.[idfUserID]
		,AspNetUsers_v7_Actual.[Email]
		,AspNetUsers_v7_Actual.[EmailConfirmed]
		,AspNetUsers_v7_Actual.[PasswordHash]
		,AspNetUsers_v7_Actual.[SecurityStamp]
		,AspNetUsers_v7_Actual.[PhoneNumber]
		,AspNetUsers_v7_Actual.[PhoneNumberConfirmed]
		,AspNetUsers_v7_Actual.[TwoFactorEnabled]
		,AspNetUsers_v7_Actual.[LockoutEnd]
		,AspNetUsers_v7_Actual.[LockoutEnabled]
		,AspNetUsers_v7_Actual.[AccessFailedCount]
		,AspNetUsers_v7_Actual.[UserName]
		,AspNetUsers_v7_Actual.[blnDisabled]
		,AspNetUsers_v7_Actual.[strDisabledReason]
		,AspNetUsers_v7_Actual.[datPasswordLastChanged]
		,AspNetUsers_v7_Actual.[PasswordResetRequired]
		,AspNetUsers_v7_Actual.[NormalizedUsername]
		,AspNetUsers_v7_Actual.[ConcurrencyStamp]
		,AspNetUsers_v7_Actual.[NormalizedEmail]
		,AspNetUsers_v7_Actual.[DateDisabled]

FROM	['' + left(DB_NAME(), len(DB_NAME()) - 8) + N''].[dbo].[AspNetUsers] AspNetUsers_v7_Actual
join	['' + DB_NAME() + N''].[dbo].[tstUserTable] tstUserTable_v7_Archive
on		tstUserTable_v7_Archive.[idfUserID] = AspNetUsers_v7_Actual.[idfUserID] 
WHERE	not exists
		(	select	1
			from	['' + DB_NAME() + N''].[dbo].[AspNetUsers] AspNetUsers_v7_Archive
			where	AspNetUsers_v7_Archive.[idfUserID] = AspNetUsers_v7_Actual.[idfUserID] 
		)
		and tstUserTable_v7_Archive.intRowStatus = 0
print N''''Table [AspNetUsers] - Insert user accounts not marked as deleted by copying from actual database: '''' + cast(@@rowcount as nvarchar(20))
	
	''
	exec sp_executesql @ArchiveCmd
end
'
select	N'
else begin
INSERT INTO [Giraffe].[dbo].[AspNetUsers]
(	 [Id]
	,[idfUserID]
	,[Email]
	,[EmailConfirmed]
	,[PasswordHash]
	,[SecurityStamp]
	,[PhoneNumber]
	,[PhoneNumberConfirmed]
	,[TwoFactorEnabled]
	,[LockoutEnd]
	,[LockoutEnabled]
	,[AccessFailedCount]
	,[UserName]
	,[blnDisabled]
	,[strDisabledReason]
	,[datPasswordLastChanged]
	,[PasswordResetRequired]
	,[NormalizedUsername]
	,[ConcurrencyStamp]
	,[NormalizedEmail]
	,[DateDisabled]
)
SELECT	 NEWID()
		,tstUserTable_v7.[idfUserID]
		,replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(tstUserTable_v7.[strAccountName], N'' '', N''''), N'''''''', N''''), N''('', N''''), N'')'', N''''), N''#'', N''N''), N''№'', N''N''), N''?'', N''''), N''*'', N''''), N''%'', N''''), N''@'', N''''), N''&'', N''''), N''$'', N''''), N''['', N''''), N'']'', N''''), N''^'', N''''), N''`'', N''''), N''~'', N'''') +
			N''@dummyemail.com'' collate Cyrillic_General_CI_AS
		,0
		,@NewTempPwdHash
		,@NewTempSecurityStamp
		,tlbPerson_v7.[strContactPhone]
		,1
		,1
		,null
		,1
		,0
		,tstUserTable_v7.[strAccountName]
		,isnull(tstUserTable_v7.[blnDisabled], 0)
		,case when tstUserTable_v7.[blnDisabled] = 1 then N''Disabled by Administartor'' else N'''' end
		,GETUTCDATE()
		,1
		,UPPER(tstUserTable_v7.[strAccountName])
		,null
		,UPPER(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(tstUserTable_v7.[strAccountName], N'' '', N''''), N'''''''', N''''), N''('', N''''), N'')'', N''''), N''#'', N''N''), N''№'', N''N''), N''?'', N''''), N''*'', N''''), N''%'', N''''), N''@'', N''''), N''&'', N''''), N''$'', N''''), N''['', N''''), N'']'', N''''), N''^'', N''''), N''`'', N''''), N''~'', N'''') +
			N''@dummyemail.com'' collate Cyrillic_General_CI_AS)
		,case when tstUserTable_v7.[blnDisabled] = 1 then GETUTCDATE() else null end

FROM	[Giraffe].[dbo].[tstUserTable] tstUserTable_v7
join	[Falcon].[dbo].[tstUserTable] tstUserTable_v6
on		tstUserTable_v6.[idfUserID] = tstUserTable_v7.[idfUserID]
join	[Giraffe].[dbo].[tlbPerson] tlbPerson_v7
on		tlbPerson_v7.idfPerson = tstUserTable_v7.idfPerson
WHERE	not exists
		(	select	1
			from	[Giraffe].[dbo].[AspNetUsers] AspNetUsers_v7
			where	AspNetUsers_v7.[idfUserID] = tstUserTable_v7.[idfUserID]
		)
		and tstUserTable_v7.intRowStatus = 0
		-- Avoid users with same account name
		and not exists
			(	select	1
				from	[Giraffe].[dbo].[tstUserTable] tstUserTable_v7_other
				where	tstUserTable_v7_other.strAccountName = tstUserTable_v7.[strAccountName] collate Cyrillic_General_CI_AS
						and tstUserTable_v7_other.intRowStatus = 0
						and tstUserTable_v7_other.idfUserID < tstUserTable_v7.[idfUserID]
			)
print N''Table [AspNetUsers] - insert user accounts not marked as deleted: '' + cast(@@rowcount as nvarchar(20))
end
print N''''
'

select	N'

declare	@LastId bigint = 0
select	@LastId = max(EmployeeToInstitution_v7.EmployeeToInstitution)
from	[Giraffe].[dbo].[EmployeeToInstitution] EmployeeToInstitution_v7

if @LastID is null
	set @LastId = 0

INSERT INTO [Giraffe].[dbo].[EmployeeToInstitution]
(	 [EmployeeToInstitution]
	,[aspNetUserId]
	,[idfUserId]
	,[idfInstitution]
	,[IsDefault]
	,[intRowStatus]
	,[rowguid]
	,[strMaintenanceFlag]
	,[strReservedAttribute]
	,[SourceSystemNameID]
	,[SourceSystemKeyValue]
	,[AuditCreateUser]
	,[AuditCreateDTM]
	,[AuditUpdateUser]
	,[AuditUpdateDTM]
	,[Active]
)
select	 @LastId + id_increment.intIncrement
		,aspNetU_v7.[aspNetUserId]
		,tstUserTable_v7.[idfUserID]
		,tlbPerson_v7.[idfInstitution]
		,1
		,0
		,NEWID()
		,null
		,null
		,10519002 /*Record Source: EIDSS6.1*/
		,N''[{'' + N''"EmployeeToInstitution":'' + isnull(cast((@LastId + id_increment.intIncrement) as nvarchar(20)), N''null'') + N''}]'' collate Cyrillic_General_CI_AS
		,N''system''
		,GETUTCDATE()
		,N''system''
		,GETUTCDATE()
		,cast((1-cast(aspNetU_v7.[blnDisabled] as int)) as bit)

FROM	[Giraffe].[dbo].[tstUserTable] tstUserTable_v7
join	[Falcon].[dbo].[tstUserTable] tstUserTable_v6
on		tstUserTable_v6.[idfUserID] = tstUserTable_v7.[idfUserID]
join	[Giraffe].[dbo].[tlbPerson] tlbPerson_v7
on		tlbPerson_v7.[idfPerson] = tstUserTable_v7.[idfPerson]
cross apply
(	select	top 1 AspNetUsers_v7.[Id] as [aspNetUserId], AspNetUsers_v7.[blnDisabled]
	from	[Giraffe].[dbo].[AspNetUsers] AspNetUsers_v7
	where	AspNetUsers_v7.[idfUserID] = tstUserTable_v7.[idfUserID]
) aspNetU_v7
outer apply
(	select	count(tstUserTable_v7_count.[idfUserID]) as intIncrement
	from	[Giraffe].[dbo].[tstUserTable] tstUserTable_v7_count
	join	[Giraffe].[dbo].[tlbPerson] tlbPerson_v7_count
	on		tlbPerson_v7_count.idfPerson = tstUserTable_v7_count.idfPerson
	where	tstUserTable_v7_count.intRowStatus = 0
			and tlbPerson_v7_count.[idfInstitution] is not null
			and not exists
				(	select	1
					from	[Giraffe].[dbo].[EmployeeToInstitution] EmployeeToInstitution_v7_count
					where	EmployeeToInstitution_v7_count.[idfUserId] = tstUserTable_v7_count.[idfUserID]
				)
			and exists
				(	select	1
					from	[Giraffe].[dbo].[AspNetUsers] AspNetUsers_v7_count
					where	AspNetUsers_v7_count.[idfUserID] = tstUserTable_v7_count.[idfUserID]
				)
			and tstUserTable_v7_count.[idfUserID] <= tstUserTable_v7.[idfUserID]
) id_increment
where	tstUserTable_v7.intRowStatus = 0
		and tlbPerson_v7.[idfInstitution] is not null
		and not exists
			(	select	1
				from	[Giraffe].[dbo].[EmployeeToInstitution] EmployeeToInstitution_v7
				where	EmployeeToInstitution_v7.[idfUserId] = tstUserTable_v7.[idfUserID]
			)
print N''Table [EmployeeToInstitution] - insert links from user accounts not marked as deleted to default organizations: '' + cast(@@rowcount as nvarchar(20))
print N''''
'


select	N'
print N''''
print N''Insert records - New tables with user account information - end''
print N''''
print N''''
/************************************************************
* Insert records - New tables with user account information - end
************************************************************/
'







select	N'
/************************************************************
* Insert records - Tables with administrative module data - part 3 - start
************************************************************/
print N''''
print N''Insert records - Tables with administrative module data - part 3 - start''
print N''''
'

select	N'
/************************************************************
* Prepare data before insert - [' + [table_name] + N']
************************************************************/
' + strStatementBeforeInsert collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert2 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert3 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert4 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert5 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert6 collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @AdminPart3TableIdFirst and @AdminPart3TableIdLast
		and len(strStatementBeforeInsert) > 0 
order by idfId

select	N'
/************************************************************
* Insert records - [' + [table_name] + N']
************************************************************/
' + strInsertHeader + N'
' + strInsertColumns + N'
' + strSelectColumns + N'
' + strInsertFromHeader + N'
' + strInsertFromJoins + N'
' + strInsertWhereHeader + strInsertWhereConditions + N'
' + strInsertPrint + N'
' collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @AdminPart3TableIdFirst and @AdminPart3TableIdLast
order by idfId


select	N'
/************************************************************
* Update records with links to foreign key data - [' + [table_name] + N']
************************************************************/
' + strUpdateAfterInsert + N'
' collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @AdminPart3TableIdFirst and @AdminPart3TableIdLast
		and len(strUpdateAfterInsert) > 0 
order by idfId


select N'
/************************************************************
* Create concordance table of system functions and operations - #dmccSystemFunctionOperation
************************************************************/

if object_id(N''tempdb..#dmccSystemFunctionOperation'') is not null
exec sp_executesql N''drop table #dmccSystemFunctionOperation''

if object_id(N''tempdb..#dmccSystemFunctionOperation'') is null
create table	#dmccSystemFunctionOperation
(	idfsSF_v6			bigint not null,
	strSF_v6			nvarchar(200) collate Cyrillic_General_CI_AS null,
	idfsOperation_v6	bigint not null,
	stOperation_v6		nvarchar(200) collate Cyrillic_General_CI_AS null,
	idfsSF_v7			bigint not null,
	strSF_v7			nvarchar(200) collate Cyrillic_General_CI_AS null,
	idfsOperation_v7	bigint not null,
	stOperation_v7		nvarchar(200) collate Cyrillic_General_CI_AS null,
	primary key
	(	idfsSF_v6 asc,
		idfsOperation_v6 asc,
		idfsSF_v7 asc,
		idfsOperation_v7 asc
	)
)

truncate table #dmccSystemFunctionOperation

insert into	#dmccSystemFunctionOperation
(	idfsSF_v6,
	strSF_v6,
	idfsOperation_v6,
	stOperation_v6,
	idfsSF_v7,
	strSF_v7,
	idfsOperation_v7,
	stOperation_v7
)
values

'

select	N'
  (10094040, N''Access to Security Policy'', 10059003, N''Read'', 10094554, N''​Access to System Preferences List'', 10059003, N''Read'')
, (10094040, N''Access to Security Policy'', 10059004, N''Write'', 10094554, N''​Access to System Preferences List'', 10059004, N''Write'')
, (10094033, N''Access to Outbreaks'', 10059001, N''Create'', 10094550, N''​Access to Veterinary Outbreak Contacts Data'', 10059001, N''Create'')
, (10094028, N''Access to Veterinary Cases Data'', 10059001, N''Create'', 10094550, N''​Access to Veterinary Outbreak Contacts Data'', 10059001, N''Create'')
, (10094033, N''Access to Outbreaks'', 10059002, N''Delete'', 10094550, N''​Access to Veterinary Outbreak Contacts Data'', 10059002, N''Delete'')
, (10094028, N''Access to Veterinary Cases Data'', 10059002, N''Delete'', 10094550, N''​Access to Veterinary Outbreak Contacts Data'', 10059002, N''Delete'')
, (10094033, N''Access to Outbreaks'', 10059003, N''Read'', 10094550, N''​Access to Veterinary Outbreak Contacts Data'', 10059003, N''Read'')
, (10094028, N''Access to Veterinary Cases Data'', 10059003, N''Read'', 10094550, N''​Access to Veterinary Outbreak Contacts Data'', 10059003, N''Read'')
, (10094033, N''Access to Outbreaks'', 10059004, N''Write'', 10094550, N''​Access to Veterinary Outbreak Contacts Data'', 10059004, N''Write'')
, (10094028, N''Access to Veterinary Cases Data'', 10059004, N''Write'', 10094550, N''​Access to Veterinary Outbreak Contacts Data'', 10059004, N''Write'')
, (10094028, N''Access to Veterinary Cases Data'', 10059002, N''Delete'', 10094526, N''​Can Execute Avian Disease Report Deduplication Function'', 10059005, N''Execute'')
, (10094028, N''Access to Veterinary Cases Data'', 10059002, N''Delete'', 10094527, N''​Can Execute Livestock Disease Report Deduplication Function'', 10059005, N''Execute'')
, (10094031, N''Access to EIDSS Sites List (Managing Data reception from Other Sites)'', 10059004, N''Write'', 10094528, N''​Can Manage Access to Neighboring Sites'', 10059005, N''Execute'')
, (10094034, N''Access to Replicate Data Command'', 10059005, N''Execute'', 10094530, N''​Can Manage Column Display in Grids'', 10059005, N''Execute'')
, (10094014, N''Can Manage Reference Tables'', 10059001, N''Create'', 10094532, N''​Can Manage References and Configurations'', 10059001, N''Create'')
, (10094014, N''Can Manage Reference Tables'', 10059002, N''Delete'', 10094532, N''​Can Manage References and Configurations'', 10059002, N''Delete'')
, (10094014, N''Can Manage Reference Tables'', 10059003, N''Read'', 10094532, N''​Can Manage References and Configurations'', 10059003, N''Read'')
, (10094014, N''Can Manage Reference Tables'', 10059004, N''Write'', 10094532, N''​Can Manage References and Configurations'', 10059004, N''Write'')
, (10094031, N''Access to EIDSS Sites List (Managing Data reception from Other Sites)'', 10059004, N''Write'', 10094504, N''​Can Manage Site Configurable Filtration'', 10059001, N''Create'')
, (10094031, N''Access to EIDSS Sites List (Managing Data reception from Other Sites)'', 10059004, N''Write'', 10094504, N''​Can Manage Site Configurable Filtration'', 10059002, N''Delete'')
, (10094031, N''Access to EIDSS Sites List (Managing Data reception from Other Sites)'', 10059003, N''Read'', 10094504, N''​Can Manage Site Configurable Filtration'', 10059003, N''Read'')
, (10094031, N''Access to EIDSS Sites List (Managing Data reception from Other Sites)'', 10059004, N''Write'', 10094504, N''​Can Manage Site Configurable Filtration'', 10059004, N''Write'')
, (10094029, N''Access to Laboratory Samples'', 10059004, N''Write'', 10094538, N''​Can Modify Autopopulated Dates Within the Lab Module'', 10059005, N''Execute'')
, (10094055, N''Can Reopen Closed Case'', 10059005, N''Execute'', 10094565, N''​Can Reopen Closed Veterinary Disease Report/Session'', 10059005, N''Execute'')
, (10094028, N''Access to Veterinary Cases Data'', 10059004, N''Write'', 10094565, N''​Can Reopen Closed Veterinary Disease Report/Session'', 10059005, N''Execute'')
, (10094039, N''Access to Security Log'', 10059003, N''Read'', 10094503, N''Access to Administrative Standard Reports'', 10059003, N''Read'')
, (10094018, N''Access to Reports'', 10059003, N''Read'', 10094502, N''Access to Human Aberration Analysis Reports'', 10059003, N''Read'')
, (10094027, N''Access to Human Cases Data'', 10059003, N''Read'', 10094502, N''Access to Human Aberration Analysis Reports'', 10059003, N''Read'')
, (10094027, N''Access to Human Cases Data'', 10059001, N''Create'', 10094505, N''Access to Human Active Surveillance Campaign'', 10059001, N''Create'')
, (10094027, N''Access to Human Cases Data'', 10059002, N''Delete'', 10094505, N''Access to Human Active Surveillance Campaign'', 10059002, N''Delete'')
, (10094027, N''Access to Human Cases Data'', 10059003, N''Read'', 10094505, N''Access to Human Active Surveillance Campaign'', 10059003, N''Read'')
, (10094027, N''Access to Human Cases Data'', 10059004, N''Write'', 10094505, N''Access to Human Active Surveillance Campaign'', 10059004, N''Write'')
, (10094027, N''Access to Human Cases Data'', 10059001, N''Create'', 10094506, N''Access to Human Active Surveillance Session'', 10059001, N''Create'')
, (10094027, N''Access to Human Cases Data'', 10059002, N''Delete'', 10094506, N''Access to Human Active Surveillance Session'', 10059002, N''Delete'')
, (10094027, N''Access to Human Cases Data'', 10059003, N''Read'', 10094506, N''Access to Human Active Surveillance Session'', 10059003, N''Read'')
, (10094027, N''Access to Human Cases Data'', 10059004, N''Write'', 10094506, N''Access to Human Active Surveillance Session'', 10059004, N''Write'')
, (10094027, N''Access to Human Cases Data'', 10059006, N''Access To Personal Data'', 10094510, N''Access to Human Disease Report Data'', 10059007, N''Access to gender and age data'')
, (10094027, N''Access to Human Cases Data'', 10059006, N''Access To Personal Data'', 10094510, N''Access to Human Disease Report Data'', 10059006, N''Access To Personal Data'')
, (10094027, N''Access to Human Cases Data'', 10059001, N''Create'', 10094510, N''Access to Human Disease Report Data'', 10059001, N''Create'')
, (10094027, N''Access to Human Cases Data'', 10059002, N''Delete'', 10094510, N''Access to Human Disease Report Data'', 10059002, N''Delete'')
, (10094027, N''Access to Human Cases Data'', 10059003, N''Read'', 10094510, N''Access to Human Disease Report Data'', 10059003, N''Read'')
, (10094027, N''Access to Human Cases Data'', 10059004, N''Write'', 10094510, N''Access to Human Disease Report Data'', 10059004, N''Write'')
, (10094033, N''Access to Outbreaks'', 10059001, N''Create'', 10094549, N''Access to Human Outbreak Contacts data'', 10059001, N''Create'')
, (10094027, N''Access to Human Cases Data'', 10059001, N''Create'', 10094549, N''Access to Human Outbreak Contacts data'', 10059001, N''Create'')
, (10094033, N''Access to Outbreaks'', 10059002, N''Delete'', 10094549, N''Access to Human Outbreak Contacts data'', 10059002, N''Delete'')
, (10094027, N''Access to Human Cases Data'', 10059002, N''Delete'', 10094549, N''Access to Human Outbreak Contacts data'', 10059002, N''Delete'')
, (10094033, N''Access to Outbreaks'', 10059003, N''Read'', 10094549, N''Access to Human Outbreak Contacts data'', 10059003, N''Read'')
, (10094027, N''Access to Human Cases Data'', 10059003, N''Read'', 10094549, N''Access to Human Outbreak Contacts data'', 10059003, N''Read'')
, (10094033, N''Access to Outbreaks'', 10059004, N''Write'', 10094549, N''Access to Human Outbreak Contacts data'', 10059004, N''Write'')
, (10094027, N''Access to Human Cases Data'', 10059004, N''Write'', 10094549, N''Access to Human Outbreak Contacts data'', 10059004, N''Write'')
, (10094018, N''Access to Reports'', 10059003, N''Read'', 10094514, N''Access to Human Standard Reports'', 10059003, N''Read'')
, (10094027, N''Access to Human Cases Data'', 10059003, N''Read'', 10094514, N''Access to Human Standard Reports'', 10059003, N''Read'')
, (10094018, N''Access to Reports'', 10059003, N''Read'', 10094557, N''Access to ILI Aberration Analysis Reports'', 10059003, N''Read'')
, (10094051, N''Access to Basic Syndromic Surveillance Module'', 10059001, N''Create'', 10094557, N''Access to ILI Aberration Analysis Reports'', 10059003, N''Read'')
, (10094051, N''Access to Basic Syndromic Surveillance Module'', 10059001, N''Create'', 10094546, N''Access to ILI Aggregate Form Data'', 10059001, N''Create'')
, (10094051, N''Access to Basic Syndromic Surveillance Module'', 10059002, N''Delete'', 10094546, N''Access to ILI Aggregate Form Data'', 10059002, N''Delete'')
, (10094051, N''Access to Basic Syndromic Surveillance Module'', 10059003, N''Read'', 10094546, N''Access to ILI Aggregate Form Data'', 10059003, N''Read'')
, (10094051, N''Access to Basic Syndromic Surveillance Module'', 10059004, N''Write'', 10094546, N''Access to ILI Aggregate Form Data'', 10059004, N''Write'')
, (10094016, N''Access to Flexible Forms Designer'', 10059003, N''Read'', 10094561, N''Access to Interface Editor'', 10059003, N''Read'')
, (10094016, N''Access to Flexible Forms Designer'', 10059004, N''Write'', 10094561, N''Access to Interface Editor'', 10059004, N''Write'')
, (10094045, N''Can Amend a Test'', 10059005, N''Execute'', 10094559, N''Access to Laboratory Approvals'', 10059003, N''Read'')
, (10094045, N''Can Amend a Test'', 10059005, N''Execute'', 10094559, N''Access to Laboratory Approvals'', 10059004, N''Write'')
, (10094030, N''Access to Laboratory Tests'', 10059001, N''Create'', 10094560, N''Access to Laboratory Batch Records'', 10059001, N''Create'')
, (10094030, N''Access to Laboratory Tests'', 10059002, N''Delete'', 10094560, N''Access to Laboratory Batch Records'', 10059002, N''Delete'')
, (10094030, N''Access to Laboratory Tests'', 10059003, N''Read'', 10094560, N''Access to Laboratory Batch Records'', 10059003, N''Read'')
, (10094030, N''Access to Laboratory Tests'', 10059004, N''Write'', 10094560, N''Access to Laboratory Batch Records'', 10059004, N''Write'')
, (10094018, N''Access to Reports'', 10059003, N''Read'', 10094516, N''Access to Laboratory Standard Reports'', 10059003, N''Read'')
, (10094029, N''Access to Laboratory Samples'', 10059003, N''Read'', 10094516, N''Access to Laboratory Standard Reports'', 10059003, N''Read'')
, (10094030, N''Access to Laboratory Tests'', 10059003, N''Read'', 10094516, N''Access to Laboratory Standard Reports'', 10059003, N''Read'')
, (10094010, N''Can Perform Sample Transfer'', 10059005, N''Execute'', 10094558, N''Access to Laboratory Transferred Samples'', 10059001, N''Create'')
, (10094010, N''Can Perform Sample Transfer'', 10059005, N''Execute'', 10094558, N''Access to Laboratory Transferred Samples'', 10059002, N''Delete'')
, (10094010, N''Can Perform Sample Transfer'', 10059005, N''Execute'', 10094558, N''Access to Laboratory Transferred Samples'', 10059003, N''Read'')
, (10094010, N''Can Perform Sample Transfer'', 10059005, N''Execute'', 10094558, N''Access to Laboratory Transferred Samples'', 10059004, N''Write'')
, (10094031, N''Access to EIDSS Sites List (Managing Data reception from Other Sites)'', 10059003, N''Read'', 10094517, N''Access to Neighboring Site Data'', 10059003, N''Read'')
, (10094031, N''Access to EIDSS Sites List (Managing Data reception from Other Sites)'', 10059004, N''Write'', 10094517, N''Access to Neighboring Site Data'', 10059004, N''Write'')
, (10094033, N''Access to Outbreaks'', 10059001, N''Create'', 10094547, N''Access to Outbreak Human Case Data'', 10059001, N''Create'')
, (10094027, N''Access to Human Cases Data'', 10059001, N''Create'', 10094547, N''Access to Outbreak Human Case Data'', 10059001, N''Create'')
, (10094033, N''Access to Outbreaks'', 10059002, N''Delete'', 10094547, N''Access to Outbreak Human Case Data'', 10059002, N''Delete'')
, (10094027, N''Access to Human Cases Data'', 10059002, N''Delete'', 10094547, N''Access to Outbreak Human Case Data'', 10059002, N''Delete'')
, (10094033, N''Access to Outbreaks'', 10059003, N''Read'', 10094547, N''Access to Outbreak Human Case Data'', 10059003, N''Read'')
, (10094027, N''Access to Human Cases Data'', 10059003, N''Read'', 10094547, N''Access to Outbreak Human Case Data'', 10059003, N''Read'')
, (10094033, N''Access to Outbreaks'', 10059004, N''Write'', 10094547, N''Access to Outbreak Human Case Data'', 10059004, N''Write'')
, (10094027, N''Access to Human Cases Data'', 10059004, N''Write'', 10094547, N''Access to Outbreak Human Case Data'', 10059004, N''Write'')
, (10094033, N''Access to Outbreaks'', 10059003, N''Read'', 10094552, N''Access to Outbreak Session Analysis'', 10059003, N''Read'')
, (10094033, N''Access to Outbreaks'', 10059004, N''Write'', 10094552, N''Access to Outbreak Session Analysis'', 10059004, N''Write'')
, (10094033, N''Access to Outbreaks'', 10059004, N''Write'', 10094551, N''Access to Outbreak Session Updates'', 10059001, N''Create'')
, (10094033, N''Access to Outbreaks'', 10059003, N''Read'', 10094551, N''Access to Outbreak Session Updates'', 10059003, N''Read'')
, (10094033, N''Access to Outbreaks'', 10059004, N''Write'', 10094551, N''Access to Outbreak Session Updates'', 10059004, N''Write'')
'
select	N'
, (10094033, N''Access to Outbreaks'', 10059001, N''Create'', 10094553, N''Access to Outbreak Vector Data'', 10059001, N''Create'')
, (10094044, N''Access to Vector Surveillance Session'', 10059001, N''Create'', 10094553, N''Access to Outbreak Vector Data'', 10059001, N''Create'')
, (10094033, N''Access to Outbreaks'', 10059002, N''Delete'', 10094553, N''Access to Outbreak Vector Data'', 10059002, N''Delete'')
, (10094044, N''Access to Vector Surveillance Session'', 10059002, N''Delete'', 10094553, N''Access to Outbreak Vector Data'', 10059002, N''Delete'')
, (10094033, N''Access to Outbreaks'', 10059003, N''Read'', 10094553, N''Access to Outbreak Vector Data'', 10059003, N''Read'')
, (10094044, N''Access to Vector Surveillance Session'', 10059003, N''Read'', 10094553, N''Access to Outbreak Vector Data'', 10059003, N''Read'')
, (10094033, N''Access to Outbreaks'', 10059004, N''Write'', 10094553, N''Access to Outbreak Vector Data'', 10059004, N''Write'')
, (10094044, N''Access to Vector Surveillance Session'', 10059004, N''Write'', 10094553, N''Access to Outbreak Vector Data'', 10059004, N''Write'')
, (10094033, N''Access to Outbreaks'', 10059001, N''Create'', 10094548, N''Access to Outbreak Veterinary Case Data'', 10059001, N''Create'')
, (10094028, N''Access to Veterinary Cases Data'', 10059001, N''Create'', 10094548, N''Access to Outbreak Veterinary Case Data'', 10059001, N''Create'')
, (10094033, N''Access to Outbreaks'', 10059002, N''Delete'', 10094548, N''Access to Outbreak Veterinary Case Data'', 10059002, N''Delete'')
, (10094028, N''Access to Veterinary Cases Data'', 10059002, N''Delete'', 10094548, N''Access to Outbreak Veterinary Case Data'', 10059002, N''Delete'')
, (10094033, N''Access to Outbreaks'', 10059003, N''Read'', 10094548, N''Access to Outbreak Veterinary Case Data'', 10059003, N''Read'')
, (10094028, N''Access to Veterinary Cases Data'', 10059003, N''Read'', 10094548, N''Access to Outbreak Veterinary Case Data'', 10059003, N''Read'')
, (10094033, N''Access to Outbreaks'', 10059004, N''Write'', 10094548, N''Access to Outbreak Veterinary Case Data'', 10059004, N''Write'')
, (10094028, N''Access to Veterinary Cases Data'', 10059004, N''Write'', 10094548, N''Access to Outbreak Veterinary Case Data'', 10059004, N''Write'')
, (10094018, N''Access to Reports'', 10059003, N''Read'', 10094562, N''Access to Paper Forms'', 10059003, N''Read'')
, (10094018, N''Access to Reports'', 10059003, N''Read'', 10094556, N''Access to Veterinary Aberration Analysis Reports'', 10059003, N''Read'')
, (10094028, N''Access to Veterinary Cases Data'', 10059003, N''Read'', 10094556, N''Access to Veterinary Aberration Analysis Reports'', 10059003, N''Read'')
, (10094018, N''Access to Reports'', 10059003, N''Read'', 10094519, N''Access to Veterinary Standard Reports'', 10059003, N''Read'')
, (10094028, N''Access to Veterinary Cases Data'', 10059003, N''Read'', 10094519, N''Access to Veterinary Standard Reports'', 10059003, N''Read'')
, (10094052, N''Access to Human Aggregate Cases'', 10059001, N''Create'', 10094555, N''Access to Weekly Reporting Form'', 10059001, N''Create'')
, (10094052, N''Access to Human Aggregate Cases'', 10059002, N''Delete'', 10094555, N''Access to Weekly Reporting Form'', 10059002, N''Delete'')
, (10094052, N''Access to Human Aggregate Cases'', 10059003, N''Read'', 10094555, N''Access to Weekly Reporting Form'', 10059003, N''Read'')
, (10094052, N''Access to Human Aggregate Cases'', 10059004, N''Write'', 10094555, N''Access to Weekly Reporting Form'', 10059004, N''Write'')
, (10094018, N''Access to Reports'', 10059003, N''Read'', 10094563, N''Access to Zoonotic Standard Reports'', 10059003, N''Read'')
, (10094027, N''Access to Human Cases Data'', 10059003, N''Read'', 10094563, N''Access to Zoonotic Standard Reports'', 10059003, N''Read'')
, (10094028, N''Access to Veterinary Cases Data'', 10059003, N''Read'', 10094563, N''Access to Zoonotic Standard Reports'', 10059003, N''Read'')
, (10094046, N''Can Add Test Results For a Case/Session'', 10059005, N''Execute'', 10094564, N''Can Add Test Results For a Veterinary Case/Session'', 10059005, N''Execute'')
, (10094028, N''Access to Veterinary Cases Data'', 10059004, N''Write'', 10094564, N''Can Add Test Results For a Veterinary Case/Session'', 10059005, N''Execute'')
, (10094010, N''Can Perform Sample Transfer'', 10059005, N''Execute'', 10094520, N''Can Edit Sample Transfer forms after Transfer is saved'', 10059005, N''Execute'')
, (10094056, N''Access to Farms Data'', 10059002, N''Delete'', 10094521, N''Can Execute Farm Record Deduplication Function'', 10059005, N''Execute'')
, (10094009, N''Access to Persons List'', 10059002, N''Delete'', 10094523, N''Can Execute Person Record Deduplication Function'', 10059005, N''Execute'')
, (10094043, N''Can Import/Export Data'', 10059005, N''Execute'', 10094544, N''Can Import/Export Data'', 10059005, N''Execute'')
, (10094005, N''Can Interpret Test Result'', 10059005, N''Execute'', 10094570, N''Can Interpret Veterinary Disease Test Result'', 10059005, N''Execute'')
, (10094028, N''Access to Veterinary Cases Data'', 10059004, N''Write'', 10094570, N''Can Interpret Veterinary Disease Test Result'', 10059005, N''Execute'')
, (10094031, N''Access to EIDSS Sites List (Managing Data reception from Other Sites)'', 10059004, N''Write'', 10094535, N''Can Manage EIDSS Sites'', 10059001, N''Create'')
, (10094031, N''Access to EIDSS Sites List (Managing Data reception from Other Sites)'', 10059004, N''Write'', 10094535, N''Can Manage EIDSS Sites'', 10059002, N''Delete'')
, (10094031, N''Access to EIDSS Sites List (Managing Data reception from Other Sites)'', 10059003, N''Read'', 10094535, N''Can Manage EIDSS Sites'', 10059003, N''Read'')
, (10094031, N''Access to EIDSS Sites List (Managing Data reception from Other Sites)'', 10059004, N''Write'', 10094535, N''Can Manage EIDSS Sites'', 10059004, N''Write'')
, (10094029, N''Access to Laboratory Samples'', 10059004, N''Write'', 10094537, N''Can Modify Accession Date after Save'', 10059005, N''Execute'')
, (10094003, N''Can Destroy Samples'', 10059005, N''Execute'', 10094540, N''Can modify status of rejected/deleted sample'', 10059005, N''Execute'')
, (10094055, N''Can Reopen Closed Case'', 10059005, N''Execute'', 10094568, N''Can Reopen Closed Outbreak Session'', 10059005, N''Execute'')
, (10094033, N''Access to Outbreaks'', 10059004, N''Write'', 10094568, N''Can Reopen Closed Outbreak Session'', 10059005, N''Execute'')
, (10094004, N''Can Validate Test Result Interpretation'', 10059005, N''Execute'', 10094566, N''Can Validate Veterinary Disease Test Result Interpretation'', 10059005, N''Execute'')
, (10094028, N''Access to Veterinary Cases Data'', 10059004, N''Write'', 10094566, N''Can Validate Veterinary Disease Test Result Interpretation'', 10059005, N''Execute'')
, (10094040, N''Access to Security Policy'', 10059003, N''Read'', 10094545, N''Data Archive Settings'', 10059003, N''Read'')
, (10094040, N''Access to Security Policy'', 10059004, N''Write'', 10094545, N''Data Archive Settings'', 10059004, N''Write'')
, (10094041, N''Access to Active Surveillance Campaign'', 10059001, N''Create'', 10094041, N''Access to Veterinary Active Surveillance Campaign'', 10059001, N''Create'')
, (10094041, N''Access to Active Surveillance Campaign'', 10059002, N''Delete'', 10094041, N''Access to Veterinary Active Surveillance Campaign'', 10059002, N''Delete'')
, (10094041, N''Access to Active Surveillance Campaign'', 10059003, N''Read'', 10094041, N''Access to Veterinary Active Surveillance Campaign'', 10059003, N''Read'')
, (10094041, N''Access to Active Surveillance Campaign'', 10059004, N''Write'', 10094041, N''Access to Veterinary Active Surveillance Campaign'', 10059004, N''Write'')
, (10094042, N''Access to Active Surveillance Session'', 10059001, N''Create'', 10094042, N''​Access to Veterinary Active Surveillance Session'', 10059001, N''Create'')
, (10094042, N''Access to Active Surveillance Session'', 10059002, N''Delete'', 10094042, N''​Access to Veterinary Active Surveillance Session'', 10059002, N''Delete'')
, (10094042, N''Access to Active Surveillance Session'', 10059003, N''Read'', 10094042, N''​Access to Veterinary Active Surveillance Session'', 10059003, N''Read'')
, (10094042, N''Access to Active Surveillance Session'', 10059004, N''Write'', 10094042, N''​Access to Veterinary Active Surveillance Session'', 10059004, N''Write'')
, (10094001, N''Access to Aggregate Settings'', 10059003, N''Read'', 10094001, N''Access to Aggregate Settings'', 10059003, N''Read'')
, (10094001, N''Access to Aggregate Settings'', 10059004, N''Write'', 10094001, N''Access to Aggregate Settings'', 10059004, N''Write'')
, (10094002, N''Access to Analysis, Visualization and Reporting Module (AVR)'', 10059001, N''Create'', 10094002, N''Access to AVR'', 10059001, N''Create'')
, (10094002, N''Access to Analysis, Visualization and Reporting Module (AVR)'', 10059002, N''Delete'', 10094002, N''Access to AVR'', 10059002, N''Delete'')
, (10094002, N''Access to Analysis, Visualization and Reporting Module (AVR)'', 10059003, N''Read'', 10094002, N''Access to AVR'', 10059003, N''Read'')
, (10094002, N''Access to Analysis, Visualization and Reporting Module (AVR)'', 10059004, N''Write'', 10094002, N''Access to AVR'', 10059004, N''Write'')
, (10094037, N''Access to AVR Administration'', 10059005, N''Execute'', 10094037, N''Access to AVR Administration'', 10059005, N''Execute'')
, (10094038, N''Access to Data Audit'', 10059003, N''Read'', 10094038, N''Access to Data Audit'', 10059003, N''Read'')
, (10094015, N''Access to Event Log'', 10059003, N''Read'', 10094015, N''Access to Event Log'', 10059003, N''Read'')
, (10094056, N''Access to Farms Data'', 10059001, N''Create'', 10094056, N''Access to Farms Data'', 10059001, N''Create'')
, (10094056, N''Access to Farms Data'', 10059002, N''Delete'', 10094056, N''Access to Farms Data'', 10059002, N''Delete'')
, (10094056, N''Access to Farms Data'', 10059003, N''Read'', 10094056, N''Access to Farms Data'', 10059003, N''Read'')
, (10094056, N''Access to Farms Data'', 10059004, N''Write'', 10094056, N''Access to Farms Data'', 10059004, N''Write'')
, (10094016, N''Access to Flexible Forms Designer'', 10059001, N''Create'', 10094016, N''Access to Flexible Forms Designer'', 10059001, N''Create'')
, (10094016, N''Access to Flexible Forms Designer'', 10059002, N''Delete'', 10094016, N''Access to Flexible Forms Designer'', 10059002, N''Delete'')
, (10094016, N''Access to Flexible Forms Designer'', 10059003, N''Read'', 10094016, N''Access to Flexible Forms Designer'', 10059003, N''Read'')
, (10094016, N''Access to Flexible Forms Designer'', 10059004, N''Write'', 10094016, N''Access to Flexible Forms Designer'', 10059004, N''Write'')
, (10094017, N''Access to GIS Module'', 10059003, N''Read'', 10094017, N''Access to GIS Module'', 10059003, N''Read'')
, (10094052, N''Access to Human Aggregate Cases'', 10059001, N''Create'', 10094052, N''Access to Human Aggregate Disease Report'', 10059001, N''Create'')
, (10094052, N''Access to Human Aggregate Cases'', 10059002, N''Delete'', 10094052, N''Access to Human Aggregate Disease Report'', 10059002, N''Delete'')
, (10094052, N''Access to Human Aggregate Cases'', 10059003, N''Read'', 10094052, N''Access to Human Aggregate Disease Report'', 10059003, N''Read'')
, (10094052, N''Access to Human Aggregate Cases'', 10059004, N''Write'', 10094052, N''Access to Human Aggregate Disease Report'', 10059004, N''Write'')
, (10094029, N''Access to Laboratory Samples'', 10059001, N''Create'', 10094029, N''Access to Laboratory Samples'', 10059001, N''Create'')
, (10094029, N''Access to Laboratory Samples'', 10059002, N''Delete'', 10094029, N''Access to Laboratory Samples'', 10059002, N''Delete'')
, (10094029, N''Access to Laboratory Samples'', 10059003, N''Read'', 10094029, N''Access to Laboratory Samples'', 10059003, N''Read'')
, (10094029, N''Access to Laboratory Samples'', 10059004, N''Write'', 10094029, N''Access to Laboratory Samples'', 10059004, N''Write'')
, (10094030, N''Access to Laboratory Tests'', 10059001, N''Create'', 10094030, N''Access to Laboratory Tests'', 10059001, N''Create'')
, (10094030, N''Access to Laboratory Tests'', 10059002, N''Delete'', 10094030, N''Access to Laboratory Tests'', 10059002, N''Delete'')
, (10094030, N''Access to Laboratory Tests'', 10059003, N''Read'', 10094030, N''Access to Laboratory Tests'', 10059003, N''Read'')
, (10094030, N''Access to Laboratory Tests'', 10059004, N''Write'', 10094030, N''Access to Laboratory Tests'', 10059004, N''Write'')
, (10094033, N''Access to Outbreaks'', 10059001, N''Create'', 10094033, N''Access to Outbreak Sessions'', 10059001, N''Create'')
, (10094033, N''Access to Outbreaks'', 10059002, N''Delete'', 10094033, N''Access to Outbreak Sessions'', 10059002, N''Delete'')
, (10094033, N''Access to Outbreaks'', 10059003, N''Read'', 10094033, N''Access to Outbreak Sessions'', 10059003, N''Read'')
, (10094033, N''Access to Outbreaks'', 10059004, N''Write'', 10094033, N''Access to Outbreak Sessions'', 10059004, N''Write'')
, (10094009, N''Access to Persons List'', 10059001, N''Create'', 10094009, N''Access to Persons List'', 10059001, N''Create'')
, (10094009, N''Access to Persons List'', 10059002, N''Delete'', 10094009, N''Access to Persons List'', 10059002, N''Delete'')
, (10094009, N''Access to Persons List'', 10059003, N''Read'', 10094009, N''Access to Persons List'', 10059003, N''Read'')
, (10094009, N''Access to Persons List'', 10059004, N''Write'', 10094009, N''Access to Persons List'', 10059004, N''Write'')
, (10094039, N''Access to Security Log'', 10059003, N''Read'', 10094039, N''Access to Security Log'', 10059003, N''Read'')
, (10094040, N''Access to Security Policy'', 10059003, N''Read'', 10094040, N''Access to Security Policy'', 10059003, N''Read'')
, (10094040, N''Access to Security Policy'', 10059004, N''Write'', 10094040, N''Access to Security Policy'', 10059004, N''Write'')
'
select	N'
, (10094011, N''Access to Statistics List'', 10059001, N''Create'', 10094011, N''Access to Statistics List'', 10059001, N''Create'')
, (10094011, N''Access to Statistics List'', 10059002, N''Delete'', 10094011, N''Access to Statistics List'', 10059002, N''Delete'')
, (10094011, N''Access to Statistics List'', 10059003, N''Read'', 10094011, N''Access to Statistics List'', 10059003, N''Read'')
, (10094011, N''Access to Statistics List'', 10059004, N''Write'', 10094011, N''Access to Statistics List'', 10059004, N''Write'')
, (10094012, N''Access to System Functions List'', 10059003, N''Read'', 10094012, N''Access to System Functions List'', 10059003, N''Read'')
, (10094012, N''Access to System Functions List'', 10059004, N''Write'', 10094012, N''Access to System Functions List'', 10059004, N''Write'')
, (10094044, N''Access to Vector Surveillance Session'', 10059001, N''Create'', 10094044, N''Access to Vector Surveillance Session'', 10059001, N''Create'')
, (10094044, N''Access to Vector Surveillance Session'', 10059002, N''Delete'', 10094044, N''Access to Vector Surveillance Session'', 10059002, N''Delete'')
, (10094044, N''Access to Vector Surveillance Session'', 10059003, N''Read'', 10094044, N''Access to Vector Surveillance Session'', 10059003, N''Read'')
, (10094044, N''Access to Vector Surveillance Session'', 10059004, N''Write'', 10094044, N''Access to Vector Surveillance Session'', 10059004, N''Write'')
, (10094054, N''Access to Veterinary Aggregate Actions'', 10059001, N''Create'', 10094054, N''Access to Veterinary Aggregate Actions'', 10059001, N''Create'')
, (10094054, N''Access to Veterinary Aggregate Actions'', 10059002, N''Delete'', 10094054, N''Access to Veterinary Aggregate Actions'', 10059002, N''Delete'')
, (10094054, N''Access to Veterinary Aggregate Actions'', 10059003, N''Read'', 10094054, N''Access to Veterinary Aggregate Actions'', 10059003, N''Read'')
, (10094054, N''Access to Veterinary Aggregate Actions'', 10059004, N''Write'', 10094054, N''Access to Veterinary Aggregate Actions'', 10059004, N''Write'')
, (10094053, N''Access to Veterinary Aggregate Cases'', 10059001, N''Create'', 10094053, N''Access to Veterinary Aggregate Diseases'', 10059001, N''Create'')
, (10094053, N''Access to Veterinary Aggregate Cases'', 10059002, N''Delete'', 10094053, N''Access to Veterinary Aggregate Diseases'', 10059002, N''Delete'')
, (10094053, N''Access to Veterinary Aggregate Cases'', 10059003, N''Read'', 10094053, N''Access to Veterinary Aggregate Diseases'', 10059003, N''Read'')
, (10094053, N''Access to Veterinary Aggregate Cases'', 10059004, N''Write'', 10094053, N''Access to Veterinary Aggregate Diseases'', 10059004, N''Write'')
, (10094028, N''Access to Veterinary Cases Data'', 10059006, N''Access To Personal Data'', 10094028, N''​Access to Veterinary Disease Reports Data'', 10059006, N''Access To Personal Data'')
, (10094028, N''Access to Veterinary Cases Data'', 10059001, N''Create'', 10094028, N''​Access to Veterinary Disease Reports Data'', 10059001, N''Create'')
, (10094028, N''Access to Veterinary Cases Data'', 10059002, N''Delete'', 10094028, N''​Access to Veterinary Disease Reports Data'', 10059002, N''Delete'')
, (10094028, N''Access to Veterinary Cases Data'', 10059003, N''Read'', 10094028, N''​Access to Veterinary Disease Reports Data'', 10059003, N''Read'')
, (10094028, N''Access to Veterinary Cases Data'', 10059004, N''Write'', 10094028, N''​Access to Veterinary Disease Reports Data'', 10059004, N''Write'')
, (10094023, N''Can Access Employees List (Without Managing Access Rights)'', 10059001, N''Create'', 10094023, N''Access to Employees List (Without Managing Access Rights)'', 10059001, N''Create'')
, (10094023, N''Can Access Employees List (Without Managing Access Rights)'', 10059002, N''Delete'', 10094023, N''Access to Employees List (Without Managing Access Rights)'', 10059002, N''Delete'')
, (10094023, N''Can Access Employees List (Without Managing Access Rights)'', 10059003, N''Read'', 10094023, N''Access to Employees List (Without Managing Access Rights)'', 10059003, N''Read'')
, (10094023, N''Can Access Employees List (Without Managing Access Rights)'', 10059004, N''Write'', 10094023, N''Access to Employees List (Without Managing Access Rights)'', 10059004, N''Write'')
, (10094021, N''Can Access Object Numbering Schema'', 10059003, N''Read'', 10094021, N''Access to Unique Numbering Schema'', 10059003, N''Read'')
, (10094021, N''Can Access Object Numbering Schema'', 10059004, N''Write'', 10094021, N''Access to Unique Numbering Schema'', 10059004, N''Write'')
, (10094022, N''Can Access Organizations List'', 10059001, N''Create'', 10094022, N''Access to Organizations List'', 10059001, N''Create'')
, (10094022, N''Can Access Organizations List'', 10059002, N''Delete'', 10094022, N''Access to Organizations List'', 10059002, N''Delete'')
, (10094022, N''Can Access Organizations List'', 10059003, N''Read'', 10094022, N''Access to Organizations List'', 10059003, N''Read'')
, (10094022, N''Can Access Organizations List'', 10059004, N''Write'', 10094022, N''Access to Organizations List'', 10059004, N''Write'')
, (10094046, N''Can Add Test Results For a Case/Session'', 10059005, N''Execute'', 10094046, N''Can Add Test Results For a Human Case/Session'', 10059005, N''Execute'')
, (10094027, N''Access to Human Cases Data'', 10059004, N''Write'', 10094046, N''Can Add Test Results For a Human Case/Session'', 10059005, N''Execute'')
, (10094045, N''Can Amend a Test'', 10059005, N''Execute'', 10094045, N''Can Amend a Test'', 10059005, N''Execute'')
, (10094003, N''Can Destroy Samples'', 10059005, N''Execute'', 10094003, N''Can Destroy Samples/Tests'', 10059005, N''Execute'')
, (10094007, N''Can Execute Human Case Deduplication Function'', 10059005, N''Execute'', 10094007, N''​Can Execute Human Disease Report Deduplication Function'', 10059005, N''Execute'')
, (10094057, N''Can Finalize Laboratory Test'', 10059005, N''Execute'', 10094057, N''Can Finalize Laboratory Test'', 10059005, N''Execute'')
, (10094005, N''Can Interpret Test Result'', 10059005, N''Execute'', 10094005, N''Can Interpret Human Disease Test Result'', 10059005, N''Execute'')
, (10094027, N''Access to Human Cases Data'', 10059004, N''Write'', 10094005, N''Can Interpret Human Disease Test Result'', 10059005, N''Execute'')
, (10094050, N''Can Manage GIS Reference Tables'', 10059001, N''Create'', 10094050, N''Can Manage GIS Reference Tables'', 10059001, N''Create'')
, (10094050, N''Can Manage GIS Reference Tables'', 10059002, N''Delete'', 10094050, N''Can Manage GIS Reference Tables'', 10059002, N''Delete'')
, (10094050, N''Can Manage GIS Reference Tables'', 10059003, N''Read'', 10094050, N''Can Manage GIS Reference Tables'', 10059003, N''Read'')
, (10094050, N''Can Manage GIS Reference Tables'', 10059004, N''Write'', 10094050, N''Can Manage GIS Reference Tables'', 10059004, N''Write'')
, (10094024, N''Can Manage Repository Schema'', 10059001, N''Create'', 10094024, N''Can Manage Repository Schema'', 10059001, N''Create'')
, (10094024, N''Can Manage Repository Schema'', 10059002, N''Delete'', 10094024, N''Can Manage Repository Schema'', 10059002, N''Delete'')
, (10094024, N''Can Manage Repository Schema'', 10059003, N''Read'', 10094024, N''Can Manage Repository Schema'', 10059003, N''Read'')
, (10094024, N''Can Manage Repository Schema'', 10059004, N''Write'', 10094024, N''Can Manage Repository Schema'', 10059004, N''Write'')
, (10094032, N''Can Manage Site Alerts Subscriptions'', 10059003, N''Read'', 10094032, N''Can Manage Site Alerts Subscriptions'', 10059003, N''Read'')
, (10094032, N''Can Manage Site Alerts Subscriptions'', 10059004, N''Write'', 10094032, N''Can Manage Site Alerts Subscriptions'', 10059004, N''Write'')
, (10094013, N''Can Manage User Accounts'', 10059001, N''Create'', 10094013, N''Can Manage User Accounts'', 10059001, N''Create'')
, (10094013, N''Can Manage User Accounts'', 10059002, N''Delete'', 10094013, N''Can Manage User Accounts'', 10059002, N''Delete'')
, (10094013, N''Can Manage User Accounts'', 10059003, N''Read'', 10094013, N''Can Manage User Accounts'', 10059003, N''Read'')
, (10094013, N''Can Manage User Accounts'', 10059004, N''Write'', 10094013, N''Can Manage User Accounts'', 10059004, N''Write'')
, (10094026, N''Can Manage User Groups'', 10059001, N''Create'', 10094026, N''Can Manage User Groups'', 10059001, N''Create'')
, (10094026, N''Can Manage User Groups'', 10059002, N''Delete'', 10094026, N''Can Manage User Groups'', 10059002, N''Delete'')
, (10094026, N''Can Manage User Groups'', 10059003, N''Read'', 10094026, N''Can Manage User Groups'', 10059003, N''Read'')
, (10094026, N''Can Manage User Groups'', 10059004, N''Write'', 10094026, N''Can Manage User Groups'', 10059004, N''Write'')
, (10094035, N''Can Perform Sample Accession In'', 10059005, N''Execute'', 10094035, N''Can Perform Sample Accession In'', 10059005, N''Execute'')
, (10094020, N''Can Print Barcodes'', 10059005, N''Execute'', 10094020, N''Can Print Barcodes'', 10059005, N''Execute'')
, (10094047, N''Can Read Archived Data'', 10059005, N''Execute'', 10094047, N''Can Read Archived Data'', 10059005, N''Execute'')
, (10094055, N''Can Reopen Closed Case'', 10059005, N''Execute'', 10094055, N''Can Reopen Closed Human Disease Report/Session'', 10059005, N''Execute'')
, (10094027, N''Access to Human Cases Data'', 10059004, N''Write'', 10094055, N''Can Reopen Closed Human Disease Report/Session'', 10059005, N''Execute'')
, (10094048, N''Can Restore Deleted Records'', 10059005, N''Execute'', 10094048, N''Can Restore Deleted Records'', 10059005, N''Execute'')
, (10094049, N''Can Sign Report'', 10059005, N''Execute'', 10094049, N''Can Sign Report'', 10059005, N''Execute'')
, (10094004, N''Can Validate Test Result Interpretation'', 10059005, N''Execute'', 10094004, N''Can Validate Human Disease Test Result Interpretation'', 10059005, N''Execute'')
, (10094027, N''Access to Human Cases Data'', 10059004, N''Write'', 10094004, N''Can Validate Human Disease Test Result Interpretation'', 10059005, N''Execute'')
, (10094025, N''Can Work With Access Rights Management'', 10059003, N''Read'', 10094025, N''Can Work With Access Rights Management'', 10059003, N''Read'')
, (10094025, N''Can Work With Access Rights Management'', 10059004, N''Write'', 10094025, N''Can Work With Access Rights Management'', 10059004, N''Write'')
'

select	N'

declare @now datetime
set @now = getutcdate()

/************************************************************
* Insert records - [LkupRoleMenuAccess]
************************************************************/
insert into [Giraffe].[dbo].[LkupRoleMenuAccess] 

(					  [idfEmployee]
					, [EIDSSMenuID]
					, [intRowStatus]
					, [AuditCreateUser]
					, [AuditCreateDTM]
					, [AuditUpdateUser]
					, [AuditUpdateDTM]
					, [SourceSystemNameID]
					, [SourceSystemKeyValue]
)
select distinct
					  tlbEmployee_v7.[idfEmployee]
					, LkupEIDSSMenu_v7.[EIDSSMenuID]
					, 0
					, N''system''
					, @now
					, N''system''
					, @now
					, 10519002 /*Record Source: EIDSS6.1*/
					, N''[{'' + N''"idfEmployee":'' + isnull(cast(tlbEmployee_v7.[idfEmployee] as nvarchar(20)), N''null'') + N'','' + N''"EIDSSMenuID":'' + isnull(cast(LkupEIDSSMenu_v7.[EIDSSMenuID] as nvarchar(20)), N''null'') + N''}]'' collate Cyrillic_General_CI_AS
from	[Giraffe].[dbo].[LkupEIDSSMenu] LkupEIDSSMenu_v7
inner join	[Giraffe].[dbo].[LkupEIDSSMenuToSystemFunction] LkupEIDSSMenuToSystemFunction_v7
on			LkupEIDSSMenuToSystemFunction_v7.[EIDSSMenuID] = LkupEIDSSMenu_v7.[EIDSSMenuID]
			and LkupEIDSSMenuToSystemFunction_v7.intRowStatus = 0
inner join	[Giraffe].[dbo].[LkupSystemFunctionToOperation] LkupSystemFunctionToOperation_v7
on			LkupSystemFunctionToOperation_v7.[SystemFunctionID] = LkupEIDSSMenuToSystemFunction_v7.[SystemFunctionID]
			and LkupSystemFunctionToOperation_v7.intRowStatus = 0
			and LkupSystemFunctionToOperation_v7.[SystemFunctionOperationID] in (10059003	/*Read*/, 10059005	/*Execute*/)--Enough to access menu
inner join	#dmccSystemFunctionOperation ccsfo
on			ccsfo.idfsSF_v7 = LkupEIDSSMenuToSystemFunction_v7.[SystemFunctionID]
			and ccsfo.idfsOperation_v7 = LkupSystemFunctionToOperation_v7.[SystemFunctionOperationID]

inner join	[Giraffe].[dbo].[tlbEmployee] tlbEmployee_v7
	left join	[Giraffe].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v7
		inner join	[Giraffe].[dbo].[_dmccCustomUserGroup] cug
		on			cug.idfEmployeeGroup_v7 = tlbEmployeeGroup_v7.idfEmployeeGroup
		inner join	[Falcon].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v6
		on			tlbEmployeeGroup_v6.idfEmployeeGroup = cug.idfEmployeeGroup_v6
	on			tlbEmployeeGroup_v7.idfEmployeeGroup = tlbEmployee_v7.idfEmployee
	left join	[Giraffe].[dbo].[tstUserTable] tstUserTable_v7
	on			tstUserTable_v7.idfPerson = tlbEmployee_v7.idfEmployee
on			tlbEmployee_v7.intRowStatus = 0

left join	[Giraffe].[dbo].[LkupRoleMenuAccess] LkupRoleMenuAccess_v7 
on			LkupRoleMenuAccess_v7.[idfEmployee] = tlbEmployee_v7.[idfEmployee] 
			and LkupRoleMenuAccess_v7.[EIDSSMenuID] = LkupEIDSSMenu_v7.[EIDSSMenuID]

where		(	tlbEmployeeGroup_v6.idfEmployeeGroup is not null
				or tstUserTable_v7.idfUserID is not null
			)
			and exists
				(	select	1
					from	[Falcon].[dbo].[tstObjectAccess] tstObjectAccess_v6
					where	tstObjectAccess_v6.[idfActor] = isnull(tlbEmployeeGroup_v6.idfEmployeeGroup, tlbEmployee_v7.idfEmployee)
							and tstObjectAccess_v6.[idfsObjectID] = ccsfo.idfsSF_v6
							and tstObjectAccess_v6.[idfsObjectOperation] = ccsfo.idfsOperation_v6
							--and tstObjectAccess_v6.idfsObjectType not in (10060001 /*Diagnosis*/, 10060011 /*Site*/)
							and tstObjectAccess_v6.[intPermission] = 2 /*Allow*/
							and tstObjectAccess_v6.intRowStatus = 0
				)
			and not exists
				(	select		1
					from		#dmccSystemFunctionOperation ccsfo_sameSFO_v7
					left join	[Falcon].[dbo].[tstObjectAccess] tstObjectAccess_v6
					on			tstObjectAccess_v6.[idfActor] = isnull(tlbEmployeeGroup_v6.idfEmployeeGroup, tlbEmployee_v7.idfEmployee)
								and tstObjectAccess_v6.[idfsObjectID] = ccsfo_sameSFO_v7.idfsSF_v6
								and tstObjectAccess_v6.[idfsObjectOperation] = ccsfo_sameSFO_v7.idfsOperation_v6
								--and tstObjectAccess_v6.idfsObjectType not in (10060001 /*Diagnosis*/, 10060011 /*Site*/)
								and tstObjectAccess_v6.[intPermission] = 2 /*Allow*/
								and tstObjectAccess_v6.intRowStatus = 0
					where		ccsfo_sameSFO_v7.idfsSF_v7 = ccsfo.idfsSF_v7
								and ccsfo_sameSFO_v7.idfsOperation_v7 = ccsfo.idfsOperation_v7
								and (	ccsfo_sameSFO_v7.idfsSF_v6 <> ccsfo.idfsSF_v6
										or ccsfo_sameSFO_v7.idfsOperation_v6 <> ccsfo.idfsOperation_v6
									)
								and tstObjectAccess_v6.idfObjectAccess is null
				)
			and LkupRoleMenuAccess_v7.[idfEmployee] is null
print N''Table [LkupRoleMenuAccess] - insert: '' + cast(@@rowcount as nvarchar(20))

'



select	N'
/************************************************************
* Insert records - [LkupRoleSystemFunctionAccess]
************************************************************/
insert into [Giraffe].[dbo].[LkupRoleSystemFunctionAccess] 

(					  [idfEmployee]
					, [SystemFunctionID]
					, [SystemFunctionOperationID]
					, [AccessPermissionID]
					, [intRowStatus]
					, [AuditCreateUser]
					, [AuditCreateDTM]
					, [AuditUpdateUser]
					, [AuditUpdateDTM]
					, [SourceSystemNameID]
					, [SourceSystemKeyValue]
					, [intRowStatusForSystemFunction]
)
select distinct 
					  tlbEmployee_v7.[idfEmployee]
					, trtBaseReference_v7.[idfsBaseReference]
					, LkupSystemFunctionToOperation_v7.[SystemFunctionOperationID]
					, null
					, 0
					, N''system''
					, @now
					, N''system''
					, @now
					, 10519002 /*Record Source: EIDSS6.1*/
					, N''[{'' + N''"idfEmployee":'' + isnull(cast(tlbEmployee_v7.[idfEmployee] as nvarchar(20)), N''null'') + N'','' + 
						N''"SystemFunctionID":'' + isnull(cast(trtBaseReference_v7.[idfsBaseReference] as nvarchar(20)), N''null'') + N'','' + 
						N''"SystemFunctionOperationID":'' + isnull(cast(LkupSystemFunctionToOperation_v7.[SystemFunctionOperationID] as nvarchar(20)), N''null'') + N''}]'' collate Cyrillic_General_CI_AS
					, 0

from	[Giraffe].[dbo].[trtBaseReference] trtBaseReference_v7
inner join	[Giraffe].[dbo].[LkupSystemFunctionToOperation] LkupSystemFunctionToOperation_v7
on			LkupSystemFunctionToOperation_v7.[SystemFunctionID] = trtBaseReference_v7.[idfsBaseReference]
			and LkupSystemFunctionToOperation_v7.intRowStatus = 0
inner join	#dmccSystemFunctionOperation ccsfo
on			ccsfo.idfsSF_v7 = LkupSystemFunctionToOperation_v7.[SystemFunctionID]
			and ccsfo.idfsOperation_v7 = LkupSystemFunctionToOperation_v7.[SystemFunctionOperationID]

inner join	[Giraffe].[dbo].[tlbEmployee] tlbEmployee_v7
	left join	[Giraffe].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v7
		inner join	[Giraffe].[dbo].[_dmccCustomUserGroup] cug
		on			cug.idfEmployeeGroup_v7 = tlbEmployeeGroup_v7.idfEmployeeGroup
		inner join	[Falcon].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v6
		on			tlbEmployeeGroup_v6.idfEmployeeGroup = cug.idfEmployeeGroup_v6
	on			tlbEmployeeGroup_v7.idfEmployeeGroup = tlbEmployee_v7.idfEmployee
	left join	[Giraffe].[dbo].[tstUserTable] tstUserTable_v7
	on			tstUserTable_v7.idfPerson = tlbEmployee_v7.idfEmployee
on			tlbEmployee_v7.intRowStatus = 0


left join	[Giraffe].[dbo].[LkupRoleSystemFunctionAccess] LkupRoleSystemFunctionAccess_v7 
on			LkupRoleSystemFunctionAccess_v7.[idfEmployee] = tlbEmployee_v7.[idfEmployee] 
			and LkupRoleSystemFunctionAccess_v7.[SystemFunctionID] = trtBaseReference_v7.[idfsBaseReference]
			and LkupRoleSystemFunctionAccess_v7.[SystemFunctionOperationID] = LkupSystemFunctionToOperation_v7.[SystemFunctionOperationID]

'
select	N'
where		trtBaseReference_v7.[idfsReferenceType] = 19000094 /*System Function*/
			and trtBaseReference_v7.intRowStatus = 0
			and (	tlbEmployeeGroup_v6.idfEmployeeGroup is not null
					or tstUserTable_v7.idfUserID is not null
				)
			and exists
				(	select	1
					from	[Falcon].[dbo].[tstObjectAccess] tstObjectAccess_v6
					where	tstObjectAccess_v6.[idfActor] = isnull(tlbEmployeeGroup_v6.idfEmployeeGroup, tlbEmployee_v7.idfEmployee)
							and tstObjectAccess_v6.[idfsObjectID] = ccsfo.idfsSF_v6
							and tstObjectAccess_v6.[idfsObjectOperation] = ccsfo.idfsOperation_v6
							--and tstObjectAccess_v6.idfsObjectType not in (10060001 /*Diagnosis*/, 10060011 /*Site*/)
							and tstObjectAccess_v6.[intPermission] = 2 /*Allow*/
							and tstObjectAccess_v6.intRowStatus = 0
				)
			and not exists
				(	select		1
					from		#dmccSystemFunctionOperation ccsfo_sameSFO_v7
					left join	[Falcon].[dbo].[tstObjectAccess] tstObjectAccess_v6
					on			tstObjectAccess_v6.[idfActor] = isnull(tlbEmployeeGroup_v6.idfEmployeeGroup, tlbEmployee_v7.idfEmployee)
								and tstObjectAccess_v6.[idfsObjectID] = ccsfo_sameSFO_v7.idfsSF_v6
								and tstObjectAccess_v6.[idfsObjectOperation] = ccsfo_sameSFO_v7.idfsOperation_v6
								--and tstObjectAccess_v6.idfsObjectType not in (10060001 /*Diagnosis*/, 10060011 /*Site*/)
								and tstObjectAccess_v6.[intPermission] = 2 /*Allow*/
								and tstObjectAccess_v6.intRowStatus = 0
					where		ccsfo_sameSFO_v7.idfsSF_v7 = ccsfo.idfsSF_v7
								and ccsfo_sameSFO_v7.idfsOperation_v7 = ccsfo.idfsOperation_v7
								and (	ccsfo_sameSFO_v7.idfsSF_v6 <> ccsfo.idfsSF_v6
										or ccsfo_sameSFO_v7.idfsOperation_v6 <> ccsfo.idfsOperation_v6
									)
								and tstObjectAccess_v6.idfObjectAccess is null
				)
			and LkupRoleSystemFunctionAccess_v7.[idfEmployee] is null
print N''Table [LkupRoleSystemFunctionAccess] - insert: '' + cast(@@rowcount as nvarchar(20))

'
--TODO: Configure LkupRoleDashboardObject when customizing Dashboards

select	N'
print N''''
print N''Insert records - Tables with administrative module data - part 3 - end''
print N''''
print N''''
/************************************************************
* Insert records - Tables with administrative module data - part 3 - end
************************************************************/

'




select	N'
/************************************************************
* Insert records - Tables with administrative module data - part 4 - start
************************************************************/
print N''''
print N''Insert records - Tables with administrative module data - part 4 - start''
print N''''
'

select	N'
/************************************************************
* Prepare data before insert - [' + [table_name] + N']
************************************************************/
' + strStatementBeforeInsert collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert2 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert3 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert4 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert5 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert6 collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @AdminPart4TableIdFirst and @AdminPart4TableIdLast
		and len(strStatementBeforeInsert) > 0 
order by idfId


select	N'
/************************************************************
* Insert records - [' + [table_name] + N']
************************************************************/
' + strInsertHeader + N'
' + strInsertColumns + N'
' + strSelectColumns + N'
' + strInsertFromHeader + N'
' + strInsertFromJoins + N'
' + strInsertWhereHeader + strInsertWhereConditions + N'
' + strInsertPrint + N'
' collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @AdminPart4TableIdFirst and @AdminPart4TableIdLast
order by idfId


select	N'
/************************************************************
* Update records with links to foreign key data - [' + [table_name] + N']
************************************************************/
' + strUpdateAfterInsert + N'
' collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @AdminPart4TableIdFirst and @AdminPart4TableIdLast
		and len(strUpdateAfterInsert) > 0 
order by idfId


select	N'
print N''''
print N''Insert records - Tables with administrative module data - part 4 - end''
print N''''
print N''''
/************************************************************
* Insert records - Tables with administrative module data - part 4 - end
************************************************************/
'



select	N'
/************************************************************
* Insert records - Tables with settings of configurable filtration - start
************************************************************/
print N''''
print N''Insert records - Tables with settings of configurable filtration - start''
print N''''
'

select	N'
/************************************************************
* Prepare data before insert - [' + [table_name] + N']
************************************************************/
' + strStatementBeforeInsert collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert2 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert3 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert4 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert5 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert6 collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @ConfigFiltrTableIdFirst and @ConfigFiltrTableIdLast
		and len(strStatementBeforeInsert) > 0 
order by idfId


select	N'
/************************************************************
* Insert records - [' + [table_name] + N']
************************************************************/
' + strInsertHeader + N'
' + strInsertColumns + N'
' + strSelectColumns + N'
' + strInsertFromHeader + N'
' + strInsertFromJoins + N'
' + strInsertWhereHeader + strInsertWhereConditions + N'
' + strInsertPrint + N'
' collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @ConfigFiltrTableIdFirst and @ConfigFiltrTableIdLast
order by idfId


select	N'
/************************************************************
* Update records with links to foreign key data - [' + [table_name] + N']
************************************************************/
' + strUpdateAfterInsert + N'
' collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @ConfigFiltrTableIdFirst and @ConfigFiltrTableIdLast
		and len(strUpdateAfterInsert) > 0 
order by idfId


select	N'
print N''''
print N''Insert records - Tables with settings of configurable filtration - end''
print N''''
print N''''
/************************************************************
* Insert records - Tables with settings of configurable filtration - end
************************************************************/
'



select	N'
/************************************************************
* Insert/Update records - Tables with global and local installation settings - start
************************************************************/
print N''''
print N''Insert/Update records - Tables with global and local installation settings - start''
print N''''


/************************************************************
* Insert/Update records - [tstGlobalSiteOptions]
************************************************************/
if not exists (select 1 from [Giraffe].[dbo].[tstGlobalSiteOptions] where [strName] = N''CustomizationPackage'' collate Cyrillic_General_CI_AS)
begin
	insert into	[Giraffe].[dbo].[tstGlobalSiteOptions]
	(	[strName],
		[strValue],
		[idfsSite],
		[intRowStatus],
		[SourceSystemNameID],
		[SourceSystemKeyValue],
		[AuditCreateUser],
		[AuditCreateDTM],
		[AuditUpdateUser],
		[AuditUpdateDTM]
	)
	values
	(	 N''CustomizationPackage''
		,cast(@idfCustomizationPackage as nvarchar(20))
		,null
		,0
		,10519002 /*Record Source: EIDSS6.1*/
		,N''[{"strName":"CustomizationPackage"}]'' collate Cyrillic_General_CI_AS
		,N''system''
		,GETUTCDATE()
		,N''system''
		,GETUTCDATE()
	)
	print N''Table [tstGlobalSiteOptions] - insert CustomizationPackage: '' + cast(@@rowcount as nvarchar(20))
end
else begin
	update	[Giraffe].[dbo].[tstGlobalSiteOptions]
	set	[strValue] = cast(@idfCustomizationPackage as nvarchar(20)),
		[intRowStatus] = 0,
		[idfsSite] = null,
		[SourceSystemNameID] = 10519002 /*Record Source: EIDSS6.1*/,
		[SourceSystemKeyValue] = N''[{"strName":"CustomizationPackage"}]'',
		[AuditUpdateUser] = N''system'',
		[AuditUpdateDTM] = GETUTCDATE()
	where [strName] = N''CustomizationPackage'' collate Cyrillic_General_CI_AS
	print N''Table [tstGlobalSiteOptions] - update CustomizationPackage: '' + cast(@@rowcount as nvarchar(20))
end

'

select	N'

if not exists (select 1 from [Giraffe].[dbo].[tstGlobalSiteOptions] where [strName] = N''CustomizationCountry'' collate Cyrillic_General_CI_AS)
begin
	insert into	[Giraffe].[dbo].[tstGlobalSiteOptions]
	(	[strName],
		[strValue],
		[idfsSite],
		[intRowStatus],
		[SourceSystemNameID],
		[SourceSystemKeyValue],
		[AuditCreateUser],
		[AuditCreateDTM],
		[AuditUpdateUser],
		[AuditUpdateDTM]
	)
	values
	(	 N''CustomizationCountry''
		,cast(@idfsCountry as nvarchar(20))
		,null
		,0
		,10519002 /*Record Source: EIDSS6.1*/
		,N''[{"strName":"CustomizationCountry"}]'' collate Cyrillic_General_CI_AS
		,N''system''
		,GETUTCDATE()
		,N''system''
		,GETUTCDATE()
	)
	print N''Table [tstGlobalSiteOptions] - insert CustomizationCountry: '' + cast(@@rowcount as nvarchar(20))
end
else begin
	update	[Giraffe].[dbo].[tstGlobalSiteOptions]
	set	[strValue] = cast(@idfsCountry as nvarchar(20)),
		[intRowStatus] = 0,
		[idfsSite] = null,
		[SourceSystemNameID] = 10519002 /*Record Source: EIDSS6.1*/,
		[SourceSystemKeyValue] = N''[{"strName":"CustomizationCountry"}]'',
		[AuditUpdateUser] = N''system'',
		[AuditUpdateDTM] = GETUTCDATE()
	where [strName] = N''CustomizationCountry'' collate Cyrillic_General_CI_AS
	print N''Table [tstGlobalSiteOptions] - update CustomizationCountry: '' + cast(@@rowcount as nvarchar(20))
end

'

select	N'

/************************************************************
* Insert/Update records - [tstLocalSiteOptions]
************************************************************/
if not exists (select 1 from [Giraffe].[dbo].[tstLocalSiteOptions] where [strName] = N''SiteID'' collate Cyrillic_General_CI_AS)
begin
	insert into	[Giraffe].[dbo].[tstLocalSiteOptions]
	(	[strName],
		[strValue],
		[SourceSystemNameID],
		[SourceSystemKeyValue],
		[AuditCreateUser],
		[AuditCreateDTM],
		[AuditUpdateUser],
		[AuditUpdateDTM]
	)
	values
	(	 N''SiteID''
		,cast(@CDRSite as nvarchar(20))
		,10519002 /*Record Source: EIDSS6.1*/
		,N''[{"strName":"SiteID"}]'' collate Cyrillic_General_CI_AS
		,N''system''
		,GETUTCDATE()
		,N''system''
		,GETUTCDATE()
	)
	print N''Table [tstLocalSiteOptions] - insert Site ID (CDR): '' + cast(@@rowcount as nvarchar(20))
end
else begin
	update	[Giraffe].[dbo].[tstLocalSiteOptions]
	set	[strValue] = cast(@CDRSite as nvarchar(20)),
		[SourceSystemNameID] = 10519002 /*Record Source: EIDSS6.1*/,
		[SourceSystemKeyValue] = N''[{"strName":"SiteID"}]'',
		[AuditUpdateUser] = N''system'',
		[AuditUpdateDTM] = GETUTCDATE()
	where [strName] = N''SiteID'' collate Cyrillic_General_CI_AS
	print N''Table [tstLocalSiteOptions] - update Site ID (CDR): '' + cast(@@rowcount as nvarchar(20))
end

'

select	N'

if not exists (select 1 from [Giraffe].[dbo].[tstLocalSiteOptions] where [strName] = N''SiteType'' collate Cyrillic_General_CI_AS)
begin
	insert into	[Giraffe].[dbo].[tstLocalSiteOptions]
	(	[strName],
		[strValue],
		[SourceSystemNameID],
		[SourceSystemKeyValue],
		[AuditCreateUser],
		[AuditCreateDTM],
		[AuditUpdateUser],
		[AuditUpdateDTM]
	)
	values
	(	 N''SiteType''
		,N''10085001''
		,10519002 /*Record Source: EIDSS6.1*/
		,N''[{"strName":"SiteType"}]'' collate Cyrillic_General_CI_AS
		,N''system''
		,GETUTCDATE()
		,N''system''
		,GETUTCDATE()
	)
	print N''Table [tstLocalSiteOptions] - insert Site Type (CDR): '' + cast(@@rowcount as nvarchar(20))
end
else begin
	update	[Giraffe].[dbo].[tstLocalSiteOptions]
	set	[strValue] = N''10085001'',
		[SourceSystemNameID] = 10519002 /*Record Source: EIDSS6.1*/,
		[SourceSystemKeyValue] = N''[{"strName":"SiteType"}]'',
		[AuditUpdateUser] = N''system'',
		[AuditUpdateDTM] = GETUTCDATE()
	where [strName] = N''SiteType'' collate Cyrillic_General_CI_AS
	print N''Table [tstLocalSiteOptions] - update Site Type (CDR): '' + cast(@@rowcount as nvarchar(20))
end

'

select	N'

if not exists (select 1 from [Giraffe].[dbo].[tstLocalSiteOptions] where [strName] = N''WebSiteMode'' collate Cyrillic_General_CI_AS)
begin
	insert into	[Giraffe].[dbo].[tstLocalSiteOptions]
	(	[strName],
		[strValue],
		[SourceSystemNameID],
		[SourceSystemKeyValue],
		[AuditCreateUser],
		[AuditCreateDTM],
		[AuditUpdateUser],
		[AuditUpdateDTM]
	)
	values
	(	 N''WebSiteMode''
		,N''1''
		,10519002 /*Record Source: EIDSS6.1*/
		,N''[{"strName":"WebSiteMode"}]'' collate Cyrillic_General_CI_AS
		,N''system''
		,GETUTCDATE()
		,N''system''
		,GETUTCDATE()
	)
	print N''Table [tstLocalSiteOptions] - insert Web Site Mode: '' + cast(@@rowcount as nvarchar(20))
end
else begin
	update	[Giraffe].[dbo].[tstLocalSiteOptions]
	set	[strValue] = N''1'',
		[SourceSystemNameID] = 10519002 /*Record Source: EIDSS6.1*/,
		[SourceSystemKeyValue] = N''[{"strName":"WebSiteMode"}]'',
		[AuditUpdateUser] = N''system'',
		[AuditUpdateDTM] = GETUTCDATE()
	where [strName] = N''WebSiteMode'' collate Cyrillic_General_CI_AS
	print N''Table [tstLocalSiteOptions] - update Web Site Mode: '' + cast(@@rowcount as nvarchar(20))
end


print N''''
print N''Insert/Update records - Tables with global and local installation settings - end''
print N''''
print N''''
/************************************************************
* Insert/Update records - Tables with global and local installation settings - end
************************************************************/

'


end
else if @GenerateOption = 2 /*Data Modules*/
begin


select	N'
/************************************************************
* Create concordance table for processing duplicated Farm IDs - start
************************************************************/


if object_id(N''_dmccFarmActual'') is null
create table _dmccFarmActual
(	idfFarmActual_v6 bigint not null,
	idfFarmActual_v7 bigint null,
	idfSeqNumber bigint not null default(0),
	strFarmCode_v6 nvarchar(200) collate Cyrillic_General_CI_AS null,
	strFarmCode_v7 nvarchar(200) collate Cyrillic_General_CI_AS null,
	intRowStatus int not null
)

/************************************************************
* Create concordance table for processing duplicated Farm IDs - end
************************************************************/

'


select	N'



/************************************************************
* Fill in concordance table for processing duplicated Farm IDs - start
************************************************************/
print N''Identify actual farms from v6.1 and ensure unique Farm ID code''
print N''''
insert into	 [Giraffe].[dbo]._dmccFarmActual
(	idfFarmActual_v6,
	idfFarmActual_v7,
	idfSeqNumber,
	strFarmCode_v6,
	strFarmCode_v7,
	intRowStatus
)
select		tlbFarmActual_v6.[idfFarmActual],
			tlbFarmActual_v7.[idfFarmActual],
			0,
			tlbFarmActual_v6.[strFarmCode],
			isnull(tlbFarmActual_v7.[strFarmCode], tlbFarmActual_v6.[strFarmCode]),
			isnull( tlbFarmActual_v7.[intRowStatus], tlbFarmActual_v6.[intRowStatus])
from		[Falcon].[dbo].tlbFarmActual tlbFarmActual_v6
left join	[Giraffe].[dbo].tlbFarmActual tlbFarmActual_v7
on			tlbFarmActual_v7.[idfFarmActual] = tlbFarmActual_v6.[idfFarmActual]
left join	[Giraffe].[dbo]._dmccFarmActual ccfa
on			ccfa.[idfFarmActual_v6] = tlbFarmActual_v6.[idfFarmActual]
where		ccfa.[idfFarmActual_v6] is null
print N''Actual Farms from v6.1: '' + cast(@@rowcount as nvarchar(20))

declare @ContinueRemovingFarmIDDuplicates int = 1
declare @IterationOfRemovingFarmIDDuplicates int = 0

while @ContinueRemovingFarmIDDuplicates > 0 and @IterationOfRemovingFarmIDDuplicates < 100
begin
	set @IterationOfRemovingFarmIDDuplicates = @IterationOfRemovingFarmIDDuplicates + 1

	update		ccfa
	set			ccfa.[idfSeqNumber] = isnull(fa_same_farm_code_cc.intCount, 0) + isnull(fa_same_farm_code_v7.intCount, 0)
	from		[Giraffe].[dbo]._dmccFarmActual ccfa
	outer apply
	(	select	count(ccfa_count.[idfFarmActual_v6]) intCount
		from	[Giraffe].[dbo]._dmccFarmActual ccfa_count
		where	ccfa_count.[strFarmCode_v7] = ccfa.[strFarmCode_v7] collate Cyrillic_General_CI_AS
				and (	ccfa_count.[idfFarmActual_v7] is not null
						or	(	ccfa_count.[idfFarmActual_v7] is null
								and (	ccfa_count.[intRowStatus] < ccfa.[intRowStatus]
										or	(	ccfa_count.[intRowStatus] = ccfa.[intRowStatus]
												and ccfa_count.[idfFarmActual_v6] < ccfa.[idfFarmActual_v6]
											)
									)
							)
					)
	) fa_same_farm_code_cc
	outer apply
	(	select		count(tlbFarmActual_v7.[idfFarmActual]) intCount
		from		[Giraffe].[dbo].tlbFarmActual tlbFarmActual_v7
		left join	[Giraffe].[dbo]._dmccFarmActual ccfa_not_exists
		on			ccfa_not_exists.[idfFarmActual_v7] = tlbFarmActual_v7.[idfFarmActual]
		where		tlbFarmActual_v7.[strFarmCode] = ccfa.[strFarmCode_v7] collate Cyrillic_General_CI_AS
					and ccfa_not_exists.[idfFarmActual_v6] is null
	) fa_same_farm_code_v7
	where		ccfa.[idfFarmActual_v7] is null
				and (	fa_same_farm_code_cc.intCount > 0
						or fa_same_farm_code_v7.intCount > 0
					)
	set	@ContinueRemovingFarmIDDuplicates = @@rowcount

	update		ccfa
	set			ccfa.[strFarmCode_v7] = ccfa.[strFarmCode_v7] + cast(ccfa.[idfSeqNumber] as nvarchar(20)),
				ccfa.idfSeqNumber = 0
	from		[Giraffe].[dbo]._dmccFarmActual ccfa
	where		ccfa.[idfFarmActual_v7] is null
				and ccfa.[idfSeqNumber] > 0
end

update		ccfa
set			ccfa.[idfSeqNumber] = 0
from		[Giraffe].[dbo]._dmccFarmActual ccfa
where		ccfa.[idfFarmActual_v7] is null
			and ccfa.[idfSeqNumber] > 0

/************************************************************
* Fill in concordance table for processing duplicated Farm IDs - end
************************************************************/

'



select	N'
/************************************************************
* Insert records - Tables with persons and farms catalogs data - start
************************************************************/
print N''''
print N''Insert records - Tables with persons and farms catalogs data - start''
print N''''
'

select	N'
/************************************************************
* Prepare data before insert - [' + [table_name] + N']
************************************************************/
' + strStatementBeforeInsert collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert2 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert3 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert4 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert5 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert6 collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @CommonCatalogTableIdFirst and @CommonCatalogTableIdLast
		and len(strStatementBeforeInsert) > 0 
order by idfId


select	N'
/************************************************************
* Insert records - [' + [table_name] + N']
************************************************************/
' + strInsertHeader + N'
' + strInsertColumns + N'
' + strSelectColumns + N'
' + strInsertFromHeader + N'
' + strInsertFromJoins + N'
' + strInsertWhereHeader + strInsertWhereConditions + N'
' + strInsertPrint + N'
' collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @CommonCatalogTableIdFirst and @CommonCatalogTableIdLast
order by idfId


select	N'
/************************************************************
* Update/insert records with links to foreign key data - [' + [table_name] + N']
************************************************************/
' + strUpdateAfterInsert collate Cyrillic_General_CI_AS, N'
' + strUpdateAfterInsert2 collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @CommonCatalogTableIdFirst and @CommonCatalogTableIdLast
		and len(strUpdateAfterInsert) > 0 
order by idfId


select	N'
print N''''
print N''Insert records - Tables with persons and farms catalogs data - end''
print N''''
print N''''
/************************************************************
* Insert records - Tables with persons and farms catalogs data - end
************************************************************/




'


--HC CC Table (add ids: idfHCnew, idfHumannew, idfCSObsnew, idfEpiObsnew, idfHCLocationnew, Relation ID)
--Record Id + orig HC Id + Diagnosis + Date? + CDH Id (if applicable) + strLegacyID + strCaseID (generate) + isInitial + isFinal + Comment
select	N'
/************************************************************
* Create concordance tables for HDR and VDR data - start
************************************************************/

if object_id(N''_dmccHumanCase'') is null
create table _dmccHumanCase
(	idfId bigint not null identity(1, 6) primary key,
	idfHumanCase_v6 bigint not null,
	idfsCurrentDiagnosis bigint null,
	idfsTentativeDiagnosis bigint null,
	datTentativeDiagnosisDate datetime null,
	idfsFinalDiagnosis bigint null,
	datFinalDiagnosisDate datetime null,
	strLegacyID_v6 nvarchar(200) collate Cyrillic_General_CI_AS null,
	idfSeqNumber bigint not null default(0),
	strCaseID_v7 nvarchar(200) collate Cyrillic_General_CI_AS null,
	strNote nvarchar(2000) collate Cyrillic_General_CI_AS null,

	idfsCaseProgressStatus_v7 bigint null,
	blnClinicalDiagBasis_v7 bit null,
	blnEpiDiagBasis_v7 bit null,
	blnLabDiagBasis_v7 bit null,
	idfsFinalCaseStatus_v7 bigint null,
	datFinalCaseClassificationDate_v7 datetime null,
	idfOutbreak_v7 bigint null,
	DiseaseReportTypeID_v7 bigint not null default(4578940000002) /*Passive*/,
	idfsCSTemplate_v7 bigint null,
	idfsEpiTemplate_v7 bigint null,

	idfHuman_v6 bigint not null,
	idfHumanActual_v6 bigint null,
	idfHumanCRAddress_v6 bigint null,
	idfHumanPRAddress_v6 bigint null,
	idfHumanEmpAddress_v6 bigint null,
	idfCSObservation_v6	bigint null,
	idfsCSTemplate_v6 bigint null,
	idfEpiObservation_v6 bigint null,
	idfsEpiTemplate_v6 bigint null,
	idfPointGeoLocation_v6 bigint null,
	idfOutbreak_v6 bigint null,
	idfDeduplicationResultCase_v6 bigint null,

	idfHumanCase_v7 bigint null,
	idfHuman_v7 bigint null,
	idfCSObservation_v7	bigint null,
	idfEpiObservation_v7 bigint null,
	idfPointGeoLocation_v7 bigint null,

	idfDeduplicationResultCase_v7 bigint null
)
'

--CCP CC Table (add ids: idfCCPnew, idfHumannew)
--Record Id + orig CCP Id + orig HC Id + orig Human Id + Record Ids from HC CC Table
select	N'

if object_id(N''_dmccContactedCasePerson'') is null
create table _dmccContactedCasePerson
(	idfId bigint not null identity(1, 2) primary key,
	idfHumanCaseId bigint not null,
	idfHumanCase_v6 bigint not null,
	idfContactedCasePerson_v6 bigint null,
	idfHuman_v6 bigint not null,
	idfHumanCase_v7 bigint not null,

	idfHumanActual_v6 bigint null,
	idfHumanCRAddress_v6 bigint null,
	idfHumanPRAddress_v6 bigint null,
	idfHumanEmpAddress_v6 bigint null,
	
	idfContactedCasePerson_v7 bigint null,
	idfHuman_v7 bigint null
)
'

--Antimicrobial Therapy CC Table (add ids: idfATnew)
--Record Id + orig HC Id + orig AT Id + Record Ids from HC CC Table
select	N'

if object_id(N''_dmccAntimicrobialTherapy'') is null
create table _dmccAntimicrobialTherapy
(	idfId bigint not null identity(1, 1) primary key,
	idfHumanCaseId bigint not null,
	idfHumanCase_v6 bigint not null,
	idfAntimicrobialTherapy_v6 bigint null,
	idfHumanCase_v7 bigint not null,
	
	idfAntimicrobialTherapy_v7 bigint null
)
'
/*
--TODO: remove
--VC CC Table (add ids: idfVCnew, idfFarmnew, idfObsnew)
--Record Id + orig VC Id + Diagnosis + Date? + strLegacyID + strCaseID (generate) + isInitial  + isInitial123 + isFinal
select	N'

if object_id(N''_dmccVetCase'') is null
create table _dmccVetCase
(	idfId bigint not null identity(1, 3) primary key,
	idfRootId bigint null,
	idfPreviousId bigint null,
	idfVetCase_v6 bigint not null,
	idfsDiagnosis bigint null,
	datDiagnosisDate datetime null,
	strLegacyID_v6 nvarchar(200) collate Cyrillic_General_CI_AS null,
	idfSeqNumber bigint not null default(0),
	strCaseID_v7 nvarchar(200) collate Cyrillic_General_CI_AS null,
	isInitialDiagnosis1 bit not null default(0),
	isInitialDiagnosis2 bit not null default(0),
	isInitialDiagnosis3 bit not null default(0),
	isFinalDiagnosis bit not null default(0),
	isInitial bit not null default(0),
	isFinal bit not null default(0),

	idfsCaseProgressStatus_v7 bigint null,
	idfsCaseClassification_v7 bigint null,
	idfsTemplate_v7 bigint null,
	idfOutbreak_v7 bigint null,

	idfFarm_v6 bigint not null,
	idfObservation_v6 bigint null,
	idfsTemplate_v6 bigint null,
	idfOutbreak_v6 bigint null,

	idfVetCase_v7 bigint null,
	idfFarm_v7 bigint null,
	idfObservation_v7 bigint null,

	idfRootVetCase_v7 bigint null,
	idfPreviousVetCase_v7 bigint null
)
'

-- VCLog  CC Table (add ids: idfVCLognew)
--Record Id + orig VC Id + orig VCLog Id + Record Ids from VC CC Table
select	N'

if object_id(N''_dmccVetCaseLog'') is null
create table _dmccVetCaseLog
(	idfId bigint not null identity(1, 1) primary key,
	idfVetCaseId bigint not null,
	idfVetCase_v6 bigint not null,
	idfVetCaseLog_v6 bigint null,
	idfVetCase_v7 bigint not null,
	
	idfVetCaseLog_v7 bigint null
)
'

-- Farm CC Table (add ids: idfFarmnew, idfFarmAddressNew, idfObsnew, idfHumannew)
-- Record Id + orig VC Id + orig Farm Id + orig Farm Owner Id + Record Ids from VC CC Table
select	N'

if object_id(N''_dmccFarm'') is null
create table _dmccFarm
(	idfId bigint not null identity(1, 4) primary key,
	idfVetCaseId bigint not null,
	idfVetCase_v6 bigint not null,
	idfFarm_v6 bigint null,
	idfVetCase_v7 bigint not null,

	idfFarmAddress_v6 bigint null,
	idfObservation_v6 bigint null,
	idfsTemplate_v6 bigint null,
	idfHuman_v6 bigint null,
	idfHumanActual_v6 bigint null,
	idfHumanCRAddress_v6 bigint null,
	idfHumanPRAddress_v6 bigint null,
	idfHumanEmpAddress_v6 bigint null,

	idfsTemplate_v7 bigint null,
	
	idfFarm_v7 bigint null,
	idfHuman_v7 bigint null,
	idfFarmAddress_v7 bigint null,
	idfObservation_v7 bigint null
)
'


-- Herd CC Table (add ids: idfHerdnew)
--Record Id + orig VC Id + orig Farm Id + orig Herd Id + Record Ids from VC CC Table + Record Ids from Farm CC Table
select	N'

if object_id(N''_dmccHerd'') is null
create table _dmccHerd
(	idfId bigint not null identity(1, 1) primary key,
	idfVetCaseId bigint not null,
	idfFarmId bigint not null,
	idfVetCase_v6 bigint not null,
	idfFarm_v6 bigint null,
	idfHerd_v6 bigint null,
	idfVetCase_v7 bigint not null,
	idfFarm_v7 bigint not null,
	
	idfHerd_v7 bigint null
)
'

-- Species CC Table (add ids: idfSpeciesnew, idfObsnew)
--Record Id + orig VC Id + orig Farm Id + orig Herd Id + orig Species Id + Record Ids from VC CC Table + Record Ids from Farm CC Table + Record Ids from Herd CC Table
select	N'

if object_id(N''_dmccSpecies'') is null
create table _dmccSpecies
(	idfId bigint not null identity(1, 2) primary key,
	idfVetCaseId bigint not null,
	idfFarmId bigint not null,
	idfHerdId bigint not null,
	idfVetCase_v6 bigint not null,
	idfFarm_v6 bigint null,
	idfHerd_v6 bigint null,
	idfSpecies_v6 bigint null,
	idfVetCase_v7 bigint not null,
	idfFarm_v7 bigint not null,
	idfHerd_v7 bigint not null,

	idfObservation_v6 bigint null,
	idfsTemplate_v6 bigint null,

	idfsTemplate_v7 bigint null,
	
	idfSpecies_v7 bigint null,
	idfObservation_v7 bigint null
)
'

-- Animal CC Table (add ids: idfAnimalnew, idfObsnew)
--Record Id + orig VC Id + orig Farm Id + orig Herd Id + orig Species Id + orig Animal Id + Record Ids from VC CC Table + Record Ids from Farm CC Table + Record Ids from Herd CC Table + Record Ids from Species CC Table
select	N'

if object_id(N''_dmccAnimal'') is null
create table _dmccAnimal
(	idfId bigint not null identity(1, 2) primary key,
	idfVetCaseId bigint not null,
	idfFarmId bigint not null,
	idfHerdId bigint not null,
	idfSpeciesId bigint not null,
	idfVetCase_v6 bigint not null,
	idfFarm_v6 bigint null,
	idfHerd_v6 bigint null,
	idfSpecies_v6 bigint null,
	idfAnimal_v6 bigint null,
	idfVetCase_v7 bigint not null,
	idfFarm_v7 bigint not null,
	idfHerd_v7 bigint not null,
	idfSpecies_v7 bigint not null,

	idfObservation_v6 bigint null,
	idfsTemplate_v6 bigint null,

	idfsTemplate_v7 bigint null,
	
	idfAnimal_v7 bigint null,
	idfObservation_v7 bigint null
)
'
*/
-- Human CC Table (add ids: idfHumannew, idfCRAnew, idfPRAnew, idfEmpAddrnew, idfAltAddrnew, idfSchAddrnew)
-- Record Id + orig idfHumanActual + orig Human Id + orig HC Id + orig CCP Id + orig Farm Id + isPatient + isContact + isFarmOwner + Record Ids from HC CC + Record Ids from CCP CC + Record Ids from Farm CC
select	N'

if object_id(N''_dmccHuman'') is null
create table _dmccHuman
(	idfId bigint not null identity(1, 6) primary key,
	idfHumanCaseId bigint null,
	idfCCPId bigint null,
	idfVetCaseId bigint null,
	idfFarmId bigint null,
	idfHumanCase_v6 bigint null,
	idfContactedCasePerson_v6 bigint null,
	idfVetCase_v6 bigint null,
	idfFarm_v6 bigint null,
	idfBSS_v6 bigint null,
	idfHuman_v6 bigint null,

	idfHumanCase_v7 bigint null,
	idfContactedCasePerson_v7 bigint null,
	idfVetCase_v7 bigint null,
	idfFarm_v7 bigint null,
	idfBSS_v7 bigint null,

	idfHumanActual_v6 bigint null,
	idfHumanCRAddress_v6 bigint null,
	idfHumanPRAddress_v6 bigint null,
	idfHumanEmpAddress_v6 bigint null,

	[intRowStatus] int not null,
	[IsEmployedID] bigint null,
	[EmployerPhoneNbr] nvarchar(200) collate Cyrillic_General_CI_AS null,
	[ContactPhoneNbr] nvarchar(200) collate Cyrillic_General_CI_AS null,
	
	idfHuman_v7 bigint null,
	idfHumanCRAddress_v7 bigint null,
	idfHumanPRAddress_v7 bigint null,
	idfHumanEmpAddress_v7 bigint null,
	idfHumanAltAddress_v7 bigint null,
	idfHumanSchAddress_v7 bigint null
)
'


-- GeoLocation CC Table (add ids: None)
--Record Id + orig GL Id + new GL Id
select	N'

if object_id(N''_dmccGeoLocation'') is null
create table _dmccGeoLocation
(	--idfId bigint not null identity(1, 1) primary key,
	idfGeoLocation_v6 bigint not null,
	idfGeoLocation_v7 bigint not null primary key
)
'


-- New GeoLocation Table (add ids: None)
--new idf GL not matching v6.1 GL
select	N'

if object_id(N''_dmccNewGeoLocation'') is null
create table _dmccNewGeoLocation
(	  idfGeoLocation_v7 bigint not null primary key
	, [idfsSite] bigint not null
	, [idfsGeoLocationType] bigint null
	, [idfsCountry] bigint null
	, [blnForeignAddress] bit not null default(0)
	, [intRowStatus] int not null default(0)
	, [SourceSystemNameID] bigint null
	, [SourceSystemKeyValue] nvarchar(max) collate Cyrillic_General_CI_AS null
	, [AuditCreateUser] nvarchar(200) collate Cyrillic_General_CI_AS null
	, [AuditCreateDTM] datetime null
	, [AuditUpdateUser] nvarchar(200) collate Cyrillic_General_CI_AS null
	, [AuditUpdateDTM] datetime null
	, [idfsLocation] bigint null
)
'

/*
--TODO: remove
-- Vaccination CC Table (add ids: idfVacnew) -- TODO: select by diagnosis?
--Record Id + orig VC Id + orig Farm Id + orig Herd Id + orig Species Id + orig Vaccination Id + Record Ids from VC CC Table + Record Ids from Farm CC Table + Record Ids from Herd CC Table + Record Ids from Species CC Table
select	N'

if object_id(N''_dmccVaccination'') is null
create table _dmccVaccination
(	idfId bigint not null identity(1, 1) primary key,
	idfVetCaseId bigint not null,
	idfFarmId bigint not null,
	idfHerdId bigint not null,
	idfSpeciesId bigint not null,
	idfVetCase_v6 bigint not null,
	idfFarm_v6 bigint null,
	idfHerd_v6 bigint null,
	idfSpecies_v6 bigint null,
	idfVaccination_v6 bigint null,
	idfVetCase_v7 bigint null,
	idfFarm_v7 bigint null,
	idfHerd_v7 bigint null,
	idfSpecies_v7 bigint null,

	idfsDiagnosis_v6 bigint null,
	
	idfVaccination_v7 bigint null
)
'
*/

-- Material CC Table (add ids: idfMaterialnew) -- TODO: connect original Material to Final HC or VC, recalculate Case ID and patient name/farm owner name for Materials
-- Record Id + orig Material Id + orig parent objects (HC/VC, Patient/Species/Animal) Id + orig root Material Id + orig parent Material Id + readonly_v7 + Record Ids fron parent objects CC Tables
select	N'

if object_id(N''_dmccMaterial'') is null
create table _dmccMaterial
(	idfId bigint not null identity(1, 1) primary key,
	idfParentMaterialId bigint null,
	
	idfHumanCaseId bigint null,
	
	idfVetCaseId bigint null,
	idfFarmId bigint null,
	idfHerdId bigint null,
	idfSpeciesId bigint null,
	idfAnimalId bigint null,

	idfHumanCase_v6 bigint null,
	idfHuman_v6 bigint null,

	idfVetCase_v6 bigint null,
	idfFarm_v6 bigint null,
	idfHerd_v6 bigint null,
	idfSpecies_v6 bigint null,
	idfAnimal_v6 bigint null,

	idfMaterial_v6 bigint null,
	idfParentMaterial_v6 bigint null,
	idfRootMaterial_v6 bigint null,
	blnReadOnly_v6 bit not null default(0),

	idfHumanCase_v7 bigint null,
	idfHuman_v7 bigint null,

	idfVetCase_v7 bigint null,
	idfFarm_v7 bigint null,
	idfHerd_v7 bigint null,
	idfSpecies_v7 bigint null,
	idfAnimal_v7 bigint null,

	strCalculatedCaseID_v7 nvarchar(200) collate Cyrillic_General_CI_AS null,
	strCalculatedHumanName_v7 nvarchar(200) collate Cyrillic_General_CI_AS null,

	idfParentMaterial_v7 bigint null,
	idfRootMaterial_v7 bigint null,
	blnReadOnly_v7 bit not null default(0),
	
	idfMaterial_v7 bigint null
)
'
/*
--TODO: remove
-- Penside Test CC Table (add ids: idfPensideTestnew)  -- select by diagnosis?
-- Record Id + orig Material Id + orig Penside Test Id + Record Ids from Material CC Table
select	N'

if object_id(N''_dmccPensideTest'') is null
create table _dmccPensideTest
(	idfId bigint not null identity(1, 1) primary key,
	idfMaterialId bigint not null,
	idfMaterial_v6 bigint not null,
	idfPensideTest_v6 bigint null,
	idfMaterial_v7 bigint not null,

	idfsDiagnosis_v6 bigint null,
	
	idfPensideTest_v7 bigint null
)
'
*/

-- Lab Test CC Table (add ids: idfTestnew, idfObsnew)  -- select by diagnosis?
-- Record Id + orig Material Id + orig Lab Test Id + readonly_v7 + Record Ids from Material CC Table
select	N'

if object_id(N''_dmccLabTest'') is null
create table _dmccLabTest
(	idfId bigint not null identity(1, 2) primary key,
	idfMaterialId bigint not null,
	idfMaterial_v6 bigint not null,
	idfTesting_v6 bigint null,
	idfMaterial_v7 bigint not null,

	idfHumanCase_v6 bigint null,
	idfVetCase_v6 bigint null,
	idfHumanCase_v7 bigint null,
	idfVetCase_v7 bigint null,

	idfsDiagnosis_v6 bigint null,
	idfObservation_v6 bigint null,
	idfsTemplate_v6 bigint null,
	blnReadOnly_v6 bit not null default(0),
	idfBatchTest_v6 bigint null,

	idfsTemplate_v7 bigint null,
	blnReadOnly_v7 bit not null default(0),
	idfBatchTest_v7 bigint null,--for copies, specify null; for original test records, specify original batch test
	
	idfTesting_v7 bigint null,
	idfObservation_v7 bigint null
)
'


-- Test Validation CC Table (add ids: idfTVnew)  -- select by diagnosis? , blnCaseCreated?
-- Record Id + orig Lab est Id + orig Test Validation Id + readonly_v7 + Record Ids from Lab Test CC Table
select	N'

if object_id(N''_dmccTestValidation'') is null
create table _dmccTestValidation
(	idfId bigint not null identity(1, 1) primary key,
	idfLabTestId bigint not null,
	idfTesting_v6 bigint not null,
	idfTestValidation_v6 bigint null,
	idfTesting_v7 bigint not null,

	idfsDiagnosis_v6 bigint null,
	blnReadOnly_v6 bit not null default(0),

	blnReadOnly_v7 bit not null default(0),
	
	idfTestValidation_v7 bigint null
)
'


-- Observation CC Table (add ids: None)
--Record Id + orig Obs Id + orig Template Id + new Obs Id + new Template Id
select	N'

if object_id(N''_dmccObservation'') is null
create table _dmccObservation
(	--idfId bigint not null identity(1, 1) primary key,
	idfObservation_v6 bigint not null,
	idfsTemplate_v6 bigint null,
	idfObservation_v7 bigint not null primary key,
	idfsTemplate_v7 bigint null
)
'


-- New Observation Table (add ids: None)
--new idf Obs not matching v6.1 Obs
select	N'

if object_id(N''_dmccNewObservation'') is null
create table _dmccNewObservation
(	  idfObservation_v7 bigint not null primary key
	, [idfsSite] bigint not null
	, [idfsFormTemplate] bigint null
	, [intRowStatus] int not null default(0)
	, [SourceSystemNameID] bigint null
	, [SourceSystemKeyValue] nvarchar(max) collate Cyrillic_General_CI_AS null
	, [AuditCreateUser] nvarchar(200) collate Cyrillic_General_CI_AS null
	, [AuditCreateDTM] datetime null
	, [AuditUpdateUser] nvarchar(200) collate Cyrillic_General_CI_AS null
	, [AuditUpdateDTM] datetime null
)
'


-- Activity Parameters CC Table (add ids: idfAPnew)
-- Record Id + orig Obs Id + orig AP Id + orig Row Id
select	N'

if object_id(N''_dmccActivityParameters'') is null
create table _dmccActivityParameters
(	idfId bigint not null identity(1, 1) primary key,
	idfObservation_v6 bigint not null,
	idfActivityParameters_v6 bigint not null,
	idfsParameter_v6 bigint not null,
	idfRow_v6 bigint null,
	varValue sql_variant null,
	intRowStatus int not null,
	idfObservation_v7 bigint not null,
	
	idfActivityParameters_v7 bigint null
)
'

-- Human Case Filtered CC Table (add ids: idfHCFnew) -- TODO: use tlfNewID to generate Ids, Reset tflNewID in advance 
--Record Id + orig HC Id + orig HCF Id + Record Ids from HC CC Table
select	N'

if object_id(N''_dmccHumanCaseFiltered'') is null
create table _dmccHumanCaseFiltered
(	idfId bigint not null identity(1, 1) primary key,
	idfHumanCaseId bigint not null,
	idfHumanCase_v6 bigint not null,
	idfHumanCaseFiltered_v6 bigint not null,
	idfSiteGroup_v6 bigint not null,
	idfHumanCase_v7 bigint not null,
	
	idfHumanCaseFiltered_v7 bigint null
)
'
/*
--TODO: remove
-- Vet Case Filtered CC Table (add ids: idfVCFnew) -- TODO: use tlfNewID to generate Ids, Reset tflNewID in advance 
--Record Id + orig VC Id + orig VCF Id + Record Ids from VC CC Table
select	N'

if object_id(N''_dmccVetCaseFiltered'') is null
create table _dmccVetCaseFiltered
(	idfId bigint not null identity(1, 1) primary key,
	idfVetCaseId bigint not null,
	idfVetCase_v6 bigint not null,
	idfVetCaseFiltered_v6 bigint not null,
	idfSiteGroup_v6 bigint not null,
	idfVetCase_v7 bigint not null,
	
	idfVetCaseFiltered_v7 bigint null
)
'
*/

select	N'
/************************************************************
* Create concordance tables for HDR and VDR data - end
************************************************************/
'




select	N'

/************************************************************
* Reset identifier seed value - start
************************************************************/

--declare	@sqlIdResetCmd				nvarchar(max)
set	@sqlIdResetCmd = N''''

set	@sqlIdResetCmd = N''

declare @TempIdentifierSeedValue bigint = '' + cast((@TempIdentifierSeedValue - case when db_name() like N''%_Archive'' collate Cyrillic_General_CI_AS then 1 else 0 end) as nvarchar(20)) + N''

declare	@max_value			bigint
set	@max_value = @TempIdentifierSeedValue

declare	@seed_value			bigint
set	@seed_value = null
declare	@increment_value	bigint
set	@increment_value = null

declare	@sqlCmd				nvarchar(max)
set	@sqlCmd = N''''''''

'' collate Cyrillic_General_CI_AS

select	@sqlIdResetCmd = @sqlIdResetCmd + N''
	-- dbo.'' + t.[name] + N'': '' + c_ic.[name] + N''
	if	exists	(
			select	1 
			from	[Falcon].[sys].[tables] t
			inner join	[Falcon].sys.objects o_t
			on			o_t.[object_id] = t.[object_id]
						and o_t.[type] = N''''U'''' collate Cyrillic_General_CI_AS
			inner join	[Falcon].sys.schemas s
			on			s.[schema_id] = t.[schema_id]
						and s.[name] = N''''dbo'''' collate Cyrillic_General_CI_AS			
			where		t.[name] = N'''''' + t.[name] + N'''''' collate Cyrillic_General_CI_AS
				)
	begin
		if	exists	(
				select	1
				from	[Falcon].[dbo].['' + t.[name] + N'']
				where	['' + c_ic.[name] + N''] >= @max_value
						and (['' + c_ic.[name] + ''] - @TempIdentifierSeedValue) % 10000000 = 0
					)
		begin
			select		@max_value = max('' + c_ic.[name] + N'') + 10000000
			from		[Falcon].[dbo].['' + t.[name] + N'']
			where		(['' + c_ic.[name] + ''] - @TempIdentifierSeedValue) % 10000000 = 0
		end
	end
''
from
-- Table
			[Falcon].sys.tables t
inner join	[Falcon].sys.objects o_t
on			o_t.[object_id] = t.[object_id]
			and o_t.[type] = N''U'' collate Cyrillic_General_CI_AS
			and o_t.[name] not like N''gis%'' collate Cyrillic_General_CI_AS
			and o_t.[name] not like N''tfl%'' collate Cyrillic_General_CI_AS
			and o_t.[name] not like N''Lkup%'' collate Cyrillic_General_CI_AS

inner join	[Falcon].sys.schemas s
on			s.[schema_id] = t.[schema_id]
			and s.[name] = N''dbo'' collate Cyrillic_General_CI_AS

-- PK
inner join	[Falcon].sys.indexes i
on			i.[object_id] = t.[object_id]
			and i.is_primary_key = 1

-- PK column
inner join	[Falcon].sys.index_columns ic
on			ic.[object_id] = i.[object_id]
			and ic.[index_id] = i.[index_id]
inner join	[Falcon].sys.columns c_ic
on			c_ic.[object_id] = ic.[object_id]
			and c_ic.[column_id] = ic.[column_id]
			and c_ic.[name] <> N''idfsLanguage''
			and c_ic.[system_type_id] in (127, 56)
where		not exists	(
					select	1
					from		[Falcon].sys.index_columns ic_second
					inner join	[Falcon].sys.columns c_ic_second
					on			c_ic_second.[object_id] = ic_second.[object_id]
								and c_ic_second.[column_id] = ic_second.[column_id]
								and c_ic_second.[name] <> N''idfsLanguage''
								and c_ic_second.[system_type_id]  in (127, 56)
								and	c_ic_second.[column_id] <> c_ic.[column_id]
					where		ic_second.[object_id] = i.[object_id]
								and ic_second.[index_id] = i.[index_id]
						)

'

select	N'
set	@sqlIdResetCmd = @sqlIdResetCmd + N''
-- Update initial ID in the table tstNewID

select		@seed_value = cast(seed_value as bigint),
			@increment_value = cast(increment_value as bigint)
from		[Giraffe].sys.identity_columns NewIDcol
inner join	[Giraffe].sys.columns col
on			col.[object_id] = NewIDcol.[object_id]
			and col.[column_id] = NewIDcol.[column_id]
			and col.[name] = NewIDcol.[name]
			and col.is_identity = 1
inner join	[Giraffe].dbo.sysobjects NewIDtable
on			NewIDtable.[id] = NewIDcol.[object_id]
where		NewIDtable.[id] = object_id(N''''[dbo].[tstNewID]'''') 
			and OBJECTPROPERTY(NewIDtable.[id], N''''IsUserTable'''') = 1
			and NewIDcol.[name] = N''''NewID''''

if	(@seed_value is null) or (@increment_value is null)
	or (@seed_value is not null and (@seed_value < @max_value) and ((isnull(@seed_value, 0) - @max_value) % 10000000 = 0))
	or (@seed_value is not null and ((isnull(@seed_value, 0) - @max_value) % 10000000 <> 0))
--			or (@increment_value <> 10000000)
begin
	set @sqlCmd = N''''
if	exists	(
select	1 
from	[Giraffe].[dbo].sysobjects 
where	id = object_id(N''''''''[dbo].[tstNewID]'''''''') 
		and OBJECTPROPERTY(id, N''''''''IsUserTable'''''''') = 1
	)
drop table [dbo].[tstNewID]

''''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''''
create table	[dbo].[tstNewID]
(	NewID		bigint IDENTITY('''' + cast(@max_value as nvarchar(20)) + N'''', 10000000) not null,
	idfTable	bigint null,
	idfKey1		bigint null,
	idfKey2		bigint null,
	strRowGuid	nvarchar(36) collate Cyrillic_General_CI_AS null,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[SourceSystemNameID] [bigint] NULL,
	[SourceSystemKeyValue] [nvarchar](max) NULL,
	[AuditCreateUser] [nvarchar](200) NULL,
	[AuditCreateDTM] [datetime] NULL,
	[AuditUpdateUser] [nvarchar](200) NULL,
	[AuditUpdateDTM] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
''''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''''
ALTER TABLE [dbo].[tstNewID] ADD  CONSTRAINT [DF_tstNewID_rowguid]  DEFAULT (newsequentialid()) FOR [rowguid]
''''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''''
ALTER TABLE [dbo].[tstNewID] ADD  CONSTRAINT [DF_tstNewID_CreateDTM]  DEFAULT (getdate()) FOR [AuditCreateDTM]
''''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''''
ALTER TABLE [dbo].[tstNewID]  WITH CHECK ADD  CONSTRAINT [FK_tstNewID_trtBaseReference_SourceSystemNameID] FOREIGN KEY([SourceSystemNameID])
REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
''''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''''
ALTER TABLE [dbo].[tstNewID] CHECK CONSTRAINT [FK_tstNewID_trtBaseReference_SourceSystemNameID]
''''
	execute sp_executesql @sqlCmd

	print	''''New consequent ID value in the table tstNewID: '''' + cast(@max_value as varchar(30))
end
else 
	print ''''Update of consequent ID value in the table tstNewID is not needed: '''' + cast(@seed_value as varchar(30))
''
exec [Giraffe].[sys].sp_executesql @sqlIdResetCmd
'

select	N'


set	@sqlIdResetCmd = N''

declare @TempIdentifierSeedValue bigint = '' + cast((@TempIdentifierSeedValue - case when db_name() like N''%_Archive'' collate Cyrillic_General_CI_AS then 1 else 0 end) as nvarchar(20)) + N''

declare	@max_value			bigint
set	@max_value = @TempIdentifierSeedValue

declare	@seed_value			bigint
set	@seed_value = null
declare	@increment_value	bigint
set	@increment_value = null

declare	@sqlCmd				nvarchar(max)
set	@sqlCmd = N''''''''


'' collate Cyrillic_General_CI_AS


select	@sqlIdResetCmd = @sqlIdResetCmd + N''
	-- dbo.'' + t.[name] + N'': '' + c_ic.[name] + N''
	if	exists	(
			select	1 
			from	[Falcon].[sys].[tables] t
			inner join	[Falcon].sys.objects o_t
			on			o_t.[object_id] = t.[object_id]
						and o_t.[type] = N''''U'''' collate Cyrillic_General_CI_AS
			inner join	[Falcon].sys.schemas s
			on			s.[schema_id] = t.[schema_id]
						and s.[name] = N''''dbo'''' collate Cyrillic_General_CI_AS			
			where		t.[name] = N'''''' + t.[name] + N'''''' collate Cyrillic_General_CI_AS
				)
	begin
		if	exists	(
				select	1
				from	[Falcon].[dbo].['' + t.[name] + N'']
				where	['' + c_ic.[name] + N''] >= @max_value
						and (['' + c_ic.[name] + ''] - @TempIdentifierSeedValue) % 10000000 = 0
					)
		begin
			select		@max_value = max('' + c_ic.[name] + N'') + 10000000
			from		[Falcon].[dbo].['' + t.[name] + N'']
			where		(['' + c_ic.[name] + ''] - @TempIdentifierSeedValue) % 10000000 = 0
		end
	end
''
from
-- Table
			[Falcon].sys.tables t
inner join	[Falcon].sys.objects o_t
on			o_t.[object_id] = t.[object_id]
			and o_t.[type] = N''U'' collate Cyrillic_General_CI_AS
			and o_t.[name] like N''tfl%'' collate Cyrillic_General_CI_AS

inner join	[Falcon].sys.schemas s
on			s.[schema_id] = t.[schema_id]
			and s.[name] = N''dbo'' collate Cyrillic_General_CI_AS

-- PK
inner join	[Falcon].sys.indexes i
on			i.[object_id] = t.[object_id]
			and i.is_primary_key = 1

-- PK column
inner join	[Falcon].sys.index_columns ic
on			ic.[object_id] = i.[object_id]
			and ic.[index_id] = i.[index_id]
inner join	[Falcon].sys.columns c_ic
on			c_ic.[object_id] = ic.[object_id]
			and c_ic.[column_id] = ic.[column_id]
			and c_ic.[name] <> N''idfsSite''
			and c_ic.[system_type_id] in (127, 56)
where		not exists	(
					select	1
					from		[Falcon].sys.index_columns ic_second
					inner join	[Falcon].sys.columns c_ic_second
					on			c_ic_second.[object_id] = ic_second.[object_id]
								and c_ic_second.[column_id] = ic_second.[column_id]
								and c_ic_second.[name] <> N''idfsLanguage''
								and c_ic_second.[system_type_id]  in (127, 56)
								and	c_ic_second.[column_id] <> c_ic.[column_id]
					where		ic_second.[object_id] = i.[object_id]
								and ic_second.[index_id] = i.[index_id]
						)

'

select	N'
set	@sqlIdResetCmd = @sqlIdResetCmd + N''
-- Update initial ID in the table tflNewID

select		@seed_value = cast(seed_value as bigint),
			@increment_value = cast(increment_value as bigint)
from		[Giraffe].sys.identity_columns NewIDcol
inner join	[Giraffe].sys.columns col
on			col.[object_id] = NewIDcol.[object_id]
			and col.[column_id] = NewIDcol.[column_id]
			and col.[name] = NewIDcol.[name]
			and col.is_identity = 1
inner join	[Giraffe].dbo.sysobjects NewIDtable
on			NewIDtable.[id] = NewIDcol.[object_id]
where		NewIDtable.[id] = object_id(N''''[dbo].[tflNewID]'''') 
			and OBJECTPROPERTY(NewIDtable.[id], N''''IsUserTable'''') = 1
			and NewIDcol.[name] = N''''NewID''''

if	(@seed_value is null) or (@increment_value is null)
	or (@seed_value is not null and (@seed_value < @max_value) and ((isnull(@seed_value, 0) - @max_value) % 10000000 = 0))
	or (@seed_value is not null and ((isnull(@seed_value, 0) - @max_value) % 10000000 <> 0))
--			or (@increment_value <> 10000000)
begin
	set @sqlCmd = N''''
if	exists	(
select	1 
from	[Giraffe].[dbo].sysobjects 
where	id = object_id(N''''''''[dbo].[tflNewID]'''''''') 
		and OBJECTPROPERTY(id, N''''''''IsUserTable'''''''') = 1
	)
drop table [dbo].[tflNewID]

''''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''''
create table	[dbo].[tflNewID]
(	NewID			bigint IDENTITY('''' + cast(@max_value as nvarchar(20)) + N'''', 10000000) not null,
	strTableName	sysname null,
	idfKey1			bigint null,
	idfKey2			bigint null,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[SourceSystemNameID] [bigint] NULL,
	[SourceSystemKeyValue] [nvarchar](max) NULL,
	[AuditCreateUser] [nvarchar](200) NULL,
	[AuditCreateDTM] [datetime] NULL,
	[AuditUpdateUser] [nvarchar](200) NULL,
	[AuditUpdateDTM] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
''''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''''
ALTER TABLE [dbo].[tflNewID] ADD  CONSTRAINT [DF_tflNewID_rowguid]  DEFAULT (newsequentialid()) FOR [rowguid]
''''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''''
ALTER TABLE [dbo].[tflNewID] ADD  CONSTRAINT [DEF_tflNewID_SourceSystemNameID]  DEFAULT ((10519001)) FOR [SourceSystemNameID]
''''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''''
ALTER TABLE [dbo].[tflNewID] ADD  CONSTRAINT [DF_tflNewID_CreateDTM]  DEFAULT (getdate()) FOR [AuditCreateDTM]
''''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''''
ALTER TABLE [dbo].[tflNewID]  WITH CHECK ADD  CONSTRAINT [FK_tflNewID_trtBaseReference_SourceSystemNameID] FOREIGN KEY([SourceSystemNameID])
REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
''''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''''
ALTER TABLE [dbo].[tflNewID] CHECK CONSTRAINT [FK_tflNewID_trtBaseReference_SourceSystemNameID]
''''
	execute sp_executesql @sqlCmd

	print	''''New consequent ID value in the table tflNewID: '''' + cast(@max_value as varchar(30))
end
else 
	print ''''Update of consequent ID value in the table tflNewID is not needed: '''' + cast(@seed_value as varchar(30))
''
exec [Giraffe].[sys].sp_executesql @sqlIdResetCmd

/************************************************************
* Reset identifier seed value - end
************************************************************/
'




select	N'



/************************************************************
* Fill in concordance tables for HDR and VDR data - start
************************************************************/

print N''Identify HDRs v7 based on Human Cases from v6.1''
print N''''
insert into [Giraffe].[dbo]._dmccHumanCase
(	idfHumanCase_v6,
	idfSeqNumber,
	idfsCurrentDiagnosis,
	idfsTentativeDiagnosis,
	datTentativeDiagnosisDate,
	idfsFinalDiagnosis,
	datFinalDiagnosisDate,
	strLegacyID_v6,
	strNote,

	idfsCaseProgressStatus_v7,
	blnClinicalDiagBasis_v7,
	blnEpiDiagBasis_v7,
	blnLabDiagBasis_v7,
	idfsFinalCaseStatus_v7,
	datFinalCaseClassificationDate_v7,
	idfOutbreak_v7,
	DiseaseReportTypeID_v7,
	idfsCSTemplate_v7,
	idfsEpiTemplate_v7,

	idfHuman_v6,
	idfHumanActual_v6,
	idfHumanCRAddress_v6,
	idfHumanPRAddress_v6,
	idfHumanEmpAddress_v6,
	idfCSObservation_v6,
	idfsCSTemplate_v6,
	idfEpiObservation_v6,
	idfsEpiTemplate_v6,
	idfPointGeoLocation_v6,
	idfOutbreak_v6,
	idfDeduplicationResultCase_v6,

	idfHumanCase_v7,
	idfHuman_v7,
	idfCSObservation_v7,
	idfEpiObservation_v7,
	idfPointGeoLocation_v7
)
select		tlbHumanCase_v6.[idfHumanCase],
			0,
			isnull(tlbHumanCase_v6.[idfsFinalDiagnosis], tlbHumanCase_v6.[idfsTentativeDiagnosis]),
			tlbHumanCase_v6.[idfsTentativeDiagnosis],
			tlbHumanCase_v6.[datTentativeDiagnosisDate],
			tlbHumanCase_v6.[idfsFinalDiagnosis],
			tlbHumanCase_v6.[datFinalDiagnosisDate],
			tlbHumanCase_v6.[strCaseID],
			tlbHumanCase_v6.[strNote],

			tlbHumanCase_v6.[idfsCaseProgressStatus],
			tlbHumanCase_v6.[blnClinicalDiagBasis],
			tlbHumanCase_v6.[blnEpiDiagBasis],
			tlbHumanCase_v6.[blnLabDiagBasis],
			tlbHumanCase_v6.[idfsFinalCaseStatus],
			tlbHumanCase_v6.[datFinalCaseClassificationDate],
			tlbHumanCase_v6.[idfOutbreak],
			4578940000002 /*Passive*/,
			tlbObservation_CS_v6.[idfsFormTemplate],
			tlbObservation_Epi_v6.[idfsFormTemplate],

			tlbHuman_v6.[idfHuman],
			tlbHuman_v6.[idfHumanActual],
			tlbHuman_v6.[idfCurrentResidenceAddress],
			tlbHuman_v6.[idfRegistrationAddress],
			tlbHuman_v6.[idfEmployerAddress],
			tlbHumanCase_v6.[idfCSObservation],
			tlbObservation_CS_v6.[idfsFormTemplate],
			tlbHumanCase_v6.[idfEpiObservation],
			tlbObservation_Epi_v6.[idfsFormTemplate],
			tlbHumanCase_v6.[idfPointGeoLocation],
			tlbHumanCase_v6.[idfOutbreak],
			tlbHumanCase_v6.[idfDeduplicationResultCase],

			tlbHumanCase_v6.[idfHumanCase],
			tlbHuman_v6.[idfHuman],
			tlbHumanCase_v6.[idfCSObservation],
			tlbHumanCase_v6.[idfEpiObservation],
			tlbHumanCase_v6.[idfPointGeoLocation]

from		[Falcon].[dbo].tlbHumanCase tlbHumanCase_v6
inner join	[Falcon].[dbo].tlbHuman tlbHuman_v6
on			tlbHuman_v6.[idfHuman] = tlbHumanCase_v6.[idfHuman]
left join	[Falcon].[dbo].[tlbObservation] tlbObservation_CS_v6
on			tlbObservation_CS_v6.[idfObservation] = tlbHumanCase_v6.[idfCSObservation]
left join	[Falcon].[dbo].[tlbObservation] tlbObservation_Epi_v6
on			tlbObservation_Epi_v6.[idfObservation] = tlbHumanCase_v6.[idfEpiObservation]
left join	[Giraffe].[dbo]._dmccHumanCase cchc
on			cchc.[idfHumanCase_v6] = tlbHumanCase_v6.[idfHumanCase]
where		cchc.[idfId] is null
print N''Not migrated Human Cases v6.1: '' + cast(@@rowcount as nvarchar(20))


--TODO: Update attributes of previously migrated human cases in the concordance table for further updates of HDR if needed 

print N''''
print N''''

'

select	N'

update		cchc
set			cchc.[idfsCSTemplate_v7] = 
				case
					when	cchc.[idfsCurrentDiagnosis] is null and cchc.[idfsCSTemplate_v7] is not null
						then	cchc.[idfsCSTemplate_v7]
					else	coalesce(template_by_diag.[idfsFormTemplate], template_uni.[idfsFormTemplate], cchc.[idfsCSTemplate_v7])
				end
from		[Giraffe].[dbo]._dmccHumanCase cchc
outer apply
(	select top 1
			ffFormTemplate_v6.[idfsFormTemplate]
	from	[Giraffe].[dbo].[ffDeterminantValue] ffDeterminantValue_v6
	join	[Giraffe].[dbo].[ffFormTemplate] ffFormTemplate_v6
	on		ffFormTemplate_v6.[idfsFormTemplate] = ffDeterminantValue_v6.[idfsFormTemplate]
			and ffFormTemplate_v6.[intRowStatus] = 0
			and ffFormTemplate_v6.[idfsFormType] = 10034010	/*Human Clinical Signs*/
	where	ffDeterminantValue_v6.[idfsBaseReference] = cchc.[idfsCurrentDiagnosis]
			and ffDeterminantValue_v6.[intRowStatus] = 0
) template_by_diag
outer apply
(	select top 1
			ffFormTemplate_v6.[idfsFormTemplate]
	from	[Giraffe].[dbo].[ffFormTemplate] ffFormTemplate_v6
	where	ffFormTemplate_v6.[idfsFormType] = 10034010	/*Human Clinical Signs*/
			and ffFormTemplate_v6.[intRowStatus] = 0
			and ffFormTemplate_v6.[blnUNI] = 1
) template_uni
'

select	N'
update		cchc
set			cchc.[idfsEpiTemplate_v7] =
				case
					when	cchc.[idfsCurrentDiagnosis] is null and cchc.[idfsEpiTemplate_v7] is not null
						then	cchc.[idfsEpiTemplate_v7]
					else	coalesce(template_by_diag.[idfsFormTemplate], template_uni.[idfsFormTemplate], cchc.[idfsEpiTemplate_v7])
				end
from		[Giraffe].[dbo]._dmccHumanCase cchc
outer apply
(	select top 1
			ffFormTemplate_v6.[idfsFormTemplate]
	from	[Giraffe].[dbo].[ffDeterminantValue] ffDeterminantValue_v6
	join	[Giraffe].[dbo].[ffFormTemplate] ffFormTemplate_v6
	on		ffFormTemplate_v6.[idfsFormTemplate] = ffDeterminantValue_v6.[idfsFormTemplate]
			and ffFormTemplate_v6.[intRowStatus] = 0
			and ffFormTemplate_v6.[idfsFormType] = 10034011	/*Human Epi Investigations*/
	where	ffDeterminantValue_v6.[idfsBaseReference] = cchc.[idfsCurrentDiagnosis]
			and ffDeterminantValue_v6.[intRowStatus] = 0
) template_by_diag
outer apply
(	select top 1
			ffFormTemplate_v6.[idfsFormTemplate]
	from	[Giraffe].[dbo].[ffFormTemplate] ffFormTemplate_v6
	where	ffFormTemplate_v6.[idfsFormType] = 10034011	/*Human Epi Investigations*/
			and ffFormTemplate_v6.[intRowStatus] = 0
			and ffFormTemplate_v6.[blnUNI] = 1
) template_uni


'

select	N'

-- Fix for the usage of the same copy of the location as Location of Exposure in different HDRs
update		cchc
set			cchc.[idfPointGeoLocation_v7] = null
from		[Giraffe].[dbo].[_dmccHumanCase] cchc
where		cchc.[idfPointGeoLocation_v7] is not null
			and exists
			(	select	1
				from	[Giraffe].[dbo].[_dmccHumanCase] cchc_less
				where	cchc_less.[idfPointGeoLocation_v7] = cchc.[idfPointGeoLocation_v7]
						and cchc_less.[idfId] < cchc.[idfId]
			)

'

select	N'

select	@NumberOfExistingMigratedRecords = count(tlbHumanCase_v7.[idfHumanCase])
from	[Giraffe].[dbo]._dmccHumanCase cchc
inner join	[Giraffe].[dbo].[tlbHumanCase] tlbHumanCase_v7
on	tlbHumanCase_v7.[idfHumanCase] = cchc.[idfHumanCase_v7]


update	cchc	
set		cchc.idfSeqNumber = -1
from	[Giraffe].[dbo]._dmccHumanCase cchc

update	cchc	
set		cchc.idfSeqNumber = -100
from	[Giraffe].[dbo]._dmccHumanCase cchc
where	not exists
		(	select		1
			from		[Giraffe].[dbo]._dmccHumanCase cchc_fully_migrated
			left join	[Giraffe].[dbo].[tlbHumanCase] tlbHumanCase_v7
			on			tlbHumanCase_v7.[idfHumanCase] = cchc_fully_migrated.[idfHumanCase_v7]
			where		cchc_fully_migrated.[idfHumanCase_v6] = cchc.[idfHumanCase_v6]
						and tlbHumanCase_v7.[idfHumanCase] is null
		)

update	cchc	
set		cchc.idfSeqNumber = isnull(cchc_init_hc_row_number.intNumber, 0)
from	[Giraffe].[dbo]._dmccHumanCase cchc
outer apply
(	select		count(cchc_prev.idfId) as intNumber
	from		[Giraffe].[dbo]._dmccHumanCase cchc_prev
	where		cchc_prev.idfSeqNumber = -1
				and (	cchc_prev.[strLegacyID_v6] < cchc.[strLegacyID_v6]
						or	(	cchc_prev.[strLegacyID_v6] = cchc.[strLegacyID_v6]
								and cchc_prev.[idfHumanCase_v6] < cchc.[idfHumanCase_v6]
							)
					)
) cchc_init_hc_row_number
where	cchc.idfSeqNumber = -1
		and cchc.[idfHumanCase_v6] = cchc.[idfHumanCase_v7]


declare @Step int = 0
declare @GoOn int = 1
while (@GoOn > 0) and (@Step < 100)
begin
	update		cchc
	set			cchc.[idfSeqNumber] = cchc_prev.[idfSeqNumber] + 1
	from		[Giraffe].[dbo]._dmccHumanCase cchc
	inner join	[Giraffe].[dbo]._dmccHumanCase cchc_prev
	on			cchc_prev.[idfHumanCase_v6] = cchc.[idfHumanCase_v6]
				and cchc_prev.[idfHumanCase_v7] < cchc.[idfHumanCase_v7]
				and cchc_prev.[idfSeqNumber] >= 0
				and not exists
					(	select	1
						from	[Giraffe].[dbo]._dmccHumanCase cchc_prev_greater
						where	cchc_prev.[idfHumanCase_v6] = cchc.[idfHumanCase_v6]
								and cchc_prev_greater.[idfHumanCase_v7] < cchc.[idfHumanCase_v7]
								and cchc_prev_greater.[idfSeqNumber] >= 0
								and cchc_prev_greater.[idfHumanCase_v7] > cchc_prev.[idfHumanCase_v7]
					)
	where		cchc.[idfSeqNumber] = -1

	set	@GoOn = @@rowcount
	set	@Step = @Step + 1
end


if db_name() like N''%_Archive'' collate Cyrillic_General_CI_AS and @IdMigrationPrefix not like N''%ARCH'' collate Cyrillic_General_CI_AS
	set	@IdMigrationPrefix = @IdMigrationPrefix + N''ARCH'' collate Cyrillic_General_CI_AS
update	cchc
set		cchc.[strCaseID_v7] = N''HUM'' + @IdMigrationPrefix + @YY + dbo.fnAlphaNumeric(@NumberOfExistingMigratedRecords + cchc.[idfSeqNumber], @IdGenerateDigitNumber)
from	[Giraffe].[dbo]._dmccHumanCase cchc
where	cchc.[strCaseID_v7] is null or cchc.[strCaseID_v7] = N'''' collate Cyrillic_General_CI_AS
		and cchc.[idfSeqNumber] >= 0

update		cchc
set			cchc.[idfDeduplicationResultCase_v7] = cchc_dedup_res.[idfHumanCase_v7]
from		[Giraffe].[dbo]._dmccHumanCase cchc
inner join	[Giraffe].[dbo]._dmccHumanCase cchc_dedup_res
on			cchc_dedup_res.[idfHumanCase_v6] = cchc.[idfDeduplicationResultCase_v6]
			and cchc_dedup_res.[idfHumanCase_v7] is not null
where		cchc.[idfDeduplicationResultCase_v6] is not null

'


select	N'

/************************************************************
* Generate Id records - _dmccHumanCase - start
************************************************************/
insert into	[Giraffe].[dbo].[tstNewID]
(	[idfTable],
	[idfKey1],
	[idfKey2],
	[strRowGuid]
)
select		75610000000	/*tlbHumanCase*/
			, cchc.idfId
			, cchc.idfHumanCase_v6
			, @TempIdentifierKey
from		[Giraffe].[dbo].[_dmccHumanCase] cchc
where		cchc.[idfHumanCase_v7] is null

insert into	[Giraffe].[dbo].[tstNewID]
(	[idfTable],
	[idfKey1],
	[idfKey2],
	[strRowGuid]
)
select		75600000000	/*tlbHuman*/
			, cchc.idfId + 1
			, cchc.idfHumanCase_v6
			, @TempIdentifierKey
from		[Giraffe].[dbo].[_dmccHumanCase] cchc
where		cchc.[idfHuman_v7] is null

insert into	[Giraffe].[dbo].[tstNewID]
(	[idfTable],
	[idfKey1],
	[idfKey2],
	[strRowGuid]
)
select		75640000000	/*tlbObservation*/
			, cchc.idfId + 2
			, cchc.idfHumanCase_v6
			, @TempIdentifierKey
from		[Giraffe].[dbo].[_dmccHumanCase] cchc
where		cchc.[idfCSObservation_v7] is null

insert into	[Giraffe].[dbo].[tstNewID]
(	[idfTable],
	[idfKey1],
	[idfKey2],
	[strRowGuid]
)
select		75640000000	/*tlbObservation*/
			, cchc.idfId + 3
			, cchc.idfHumanCase_v6
			, @TempIdentifierKey
from		[Giraffe].[dbo].[_dmccHumanCase] cchc
where		cchc.[idfEpiObservation_v7] is null

insert into	[Giraffe].[dbo].[tstNewID]
(	[idfTable],
	[idfKey1],
	[idfKey2],
	[strRowGuid]
)
select		75580000000	/*tlbGeoLocation*/
			, cchc.idfId + 4
			, cchc.idfHumanCase_v6
			, @TempIdentifierKey
from		[Giraffe].[dbo].[_dmccHumanCase] cchc
where		cchc.[idfPointGeoLocation_v7] is null

exec [Giraffe].sys.sp_executesql N''ALTER INDEX ALL ON dbo.tstNewID REBUILD''
'


select	N'

update		cchc
set			cchc.[idfHumanCase_v7] = nId.[NewID]
from		[Giraffe].[dbo].[_dmccHumanCase] cchc
join		[Giraffe].[dbo].[tstNewID] nId
on			nId.[idfTable] = 75610000000	/*tlbHumanCase*/
			and nId.[idfKey1] = cchc.[idfId]
			and nId.[idfKey2] = cchc.[idfHumanCase_v6]
			and nId.[strRowGuid] = @TempIdentifierKey collate Cyrillic_General_CI_AS
where		cchc.[idfHumanCase_v7] is null

update		cchc
set			cchc.[idfHuman_v7] = nId.[NewID]
from		[Giraffe].[dbo].[_dmccHumanCase] cchc
join		[Giraffe].[dbo].[tstNewID] nId
on			nId.[idfTable] = 75600000000	/*tlbHuman*/
			and nId.[idfKey1] = cchc.[idfId] + 1
			and nId.[idfKey2] = cchc.[idfHumanCase_v6]
			and nId.[strRowGuid] = @TempIdentifierKey collate Cyrillic_General_CI_AS
where		cchc.[idfHuman_v7] is null

update		cchc
set			cchc.[idfCSObservation_v7] = nId.[NewID]
from		[Giraffe].[dbo].[_dmccHumanCase] cchc
join		[Giraffe].[dbo].[tstNewID] nId
on			nId.[idfTable] = 75640000000	/*tlbObservation*/
			and nId.[idfKey1] = cchc.[idfId] + 2
			and nId.[idfKey2] = cchc.[idfHumanCase_v6]
			and nId.[strRowGuid] = @TempIdentifierKey collate Cyrillic_General_CI_AS
where		cchc.[idfCSObservation_v7] is null

update		cchc
set			cchc.[idfEpiObservation_v7] = nId.[NewID]
from		[Giraffe].[dbo].[_dmccHumanCase] cchc
join		[Giraffe].[dbo].[tstNewID] nId
on			nId.[idfTable] = 75640000000	/*tlbObservation*/
			and nId.[idfKey1] = cchc.[idfId] + 3
			and nId.[idfKey2] = cchc.[idfHumanCase_v6]
			and nId.[strRowGuid] = @TempIdentifierKey collate Cyrillic_General_CI_AS
where		cchc.[idfEpiObservation_v7] is null

update		cchc
set			cchc.[idfPointGeoLocation_v7] = nId.[NewID]
from		[Giraffe].[dbo].[_dmccHumanCase] cchc
join		[Giraffe].[dbo].[tstNewID] nId
on			nId.[idfTable] = 75580000000	/*tlbGeoLocation*/
			and nId.[idfKey1] = cchc.[idfId] + 4
			and nId.[idfKey2] = cchc.[idfHumanCase_v6]
			and nId.[strRowGuid] = @TempIdentifierKey collate Cyrillic_General_CI_AS
where		cchc.[idfPointGeoLocation_v7] is null

/************************************************************
* Generate Id records - _dmccHumanCase - end
************************************************************/

'




select	N'
print N''Determine copies of Contact records in HDRs v7 based on Conact records of Human Cases from v6.1''
print N''''

insert into [Giraffe].[dbo].[_dmccContactedCasePerson]
(	idfHumanCaseId,
	idfHumanCase_v6,
	idfContactedCasePerson_v6,
	idfHuman_v6,
	idfHumanCase_v7,

	idfHumanActual_v6,
	idfHumanCRAddress_v6,
	idfHumanPRAddress_v6,
	idfHumanEmpAddress_v6,
	
	idfContactedCasePerson_v7,
	idfHuman_v7
)
select		  cchc.[idfId]
			, cchc.[idfHumanCase_v6]
			, tlbContactedCasePerson_v6.[idfContactedCasePerson]
			, tlbContactedCasePerson_v6.[idfHuman]
			, cchc.[idfHumanCase_v7]
			, tlbHuman_v6.[idfHumanActual]
			, tlbHuman_v6.[idfCurrentResidenceAddress]
			, tlbHuman_v6.[idfRegistrationAddress]
			, tlbHuman_v6.[idfEmployerAddress]
			, case
				when	cchc.[idfHumanCase_v6] = cchc.[idfHumanCase_v7]
					then	tlbContactedCasePerson_v6.[idfContactedCasePerson]
				else	null
			  end
			, case
				when	cchc.[idfHumanCase_v6] = cchc.[idfHumanCase_v7]
					then	tlbContactedCasePerson_v6.[idfHuman]
				else	null
			  end
from		[Giraffe].[dbo].[_dmccHumanCase] cchc
inner join	[Falcon].[dbo].[tlbContactedCasePerson] tlbContactedCasePerson_v6
on			tlbContactedCasePerson_v6.[idfHumanCase] = cchc.[idfHumanCase_v6]
left join	[Falcon].[dbo].[tlbHuman] tlbHuman_v6
on			tlbHuman_v6.[idfHuman] = tlbContactedCasePerson_v6.[idfHuman]
left join	[Giraffe].[dbo].[_dmccContactedCasePerson] ccccp
on			ccccp.[idfHumanCase_v6] = cchc.[idfHumanCase_v6]
			and ccccp.[idfContactedCasePerson_v6] = tlbContactedCasePerson_v6.[idfContactedCasePerson]
			and ccccp.[idfHumanCase_v7] = cchc.[idfHumanCase_v7]
where		cchc.[idfHumanCase_v7] is not null
			and ccccp.[idfId] is null
print N''Copies of Contact records for HRDs v7 from Contact records of Human Cases v6.1: '' + cast(@@rowcount as nvarchar(20))
print N''''
print N''''

'

select	N'

/************************************************************
* Generate Id records - _dmccContactedCasePerson - start
************************************************************/
insert into	[Giraffe].[dbo].[tstNewID]
(	[idfTable],
	[idfKey1],
	[idfKey2],
	[strRowGuid]
)
select		75500000000	/*tlbContactedCasePerson*/
			, ccccp.idfId
			, ccccp.idfContactedCasePerson_v6
			, @TempIdentifierKey
from		[Giraffe].[dbo].[_dmccContactedCasePerson] ccccp
where		ccccp.[idfContactedCasePerson_v7] is null

insert into	[Giraffe].[dbo].[tstNewID]
(	[idfTable],
	[idfKey1],
	[idfKey2],
	[strRowGuid]
)
select		75600000000	/*tlbHuman*/
			, ccccp.idfId + 1
			, ccccp.idfContactedCasePerson_v6
			, @TempIdentifierKey
from		[Giraffe].[dbo].[_dmccContactedCasePerson] ccccp
where		ccccp.[idfHuman_v7] is null

exec [Giraffe].sys.sp_executesql N''ALTER INDEX ALL ON dbo.tstNewID REBUILD''

update		ccccp
set			ccccp.[idfContactedCasePerson_v7] = nId.[NewID]
from		[Giraffe].[dbo].[_dmccContactedCasePerson] ccccp
join		[Giraffe].[dbo].[tstNewID] nId
on			nId.[idfTable] = 75500000000	/*tlbContactedCasePerson*/
			and nId.[idfKey1] = ccccp.[idfId]
			and nId.[idfKey2] = ccccp.[idfContactedCasePerson_v6]
			and nId.[strRowGuid] = @TempIdentifierKey collate Cyrillic_General_CI_AS
where		ccccp.[idfContactedCasePerson_v7] is null

update		ccccp
set			ccccp.[idfHuman_v7] = nId.[NewID]
from		[Giraffe].[dbo].[_dmccContactedCasePerson] ccccp
join		[Giraffe].[dbo].[tstNewID] nId
on			nId.[idfTable] = 75600000000	/*tlbHuman*/
			and nId.[idfKey1] = ccccp.[idfId] + 1
			and nId.[idfKey2] = ccccp.[idfContactedCasePerson_v6]
			and nId.[strRowGuid] = @TempIdentifierKey collate Cyrillic_General_CI_AS
where		ccccp.[idfHuman_v7] is null

/************************************************************
* Generate Id records - _dmccContactedCasePerson - end
************************************************************/

'



select	N'
print N''Determine copies of Antibiotics in HDRs v7 based on Antibiotics of Human Cases from v6.1''
print N''''

insert into [Giraffe].[dbo].[_dmccAntimicrobialTherapy]
(	idfHumanCaseId,
	idfHumanCase_v6,
	idfAntimicrobialTherapy_v6,
	idfHumanCase_v7,
	
	idfAntimicrobialTherapy_v7
)
select		  cchc.[idfId]
			, cchc.[idfHumanCase_v6]
			, tlbAntimicrobialTherapy_v6.[idfAntimicrobialTherapy]
			, cchc.[idfHumanCase_v7]
			, case
				when	cchc.[idfHumanCase_v6] = cchc.[idfHumanCase_v7]
					then	tlbAntimicrobialTherapy_v6.[idfAntimicrobialTherapy]
				else	null
			  end
from		[Giraffe].[dbo].[_dmccHumanCase] cchc
inner join	[Falcon].[dbo].[tlbAntimicrobialTherapy] tlbAntimicrobialTherapy_v6
on			tlbAntimicrobialTherapy_v6.[idfHumanCase] = cchc.[idfHumanCase_v6]
left join	[Giraffe].[dbo].[_dmccAntimicrobialTherapy] ccat
on			ccat.[idfHumanCase_v6] = cchc.[idfHumanCase_v6]
			and ccat.[idfAntimicrobialTherapy_v6] = tlbAntimicrobialTherapy_v6.[idfAntimicrobialTherapy]
			and ccat.[idfHumanCase_v7] = cchc.[idfHumanCase_v7]
where		cchc.[idfHumanCase_v7] is not null
			and ccat.[idfId] is null
print N''Copies of Antibiotics for HRDs v7 from Antibiotics of Human Cases v6.1: '' + cast(@@rowcount as nvarchar(20))
print N''''
print N''''


/************************************************************
* Generate Id records - _dmccAntimicrobialTherapy - start
************************************************************/
insert into	[Giraffe].[dbo].[tstNewID]
(	[idfTable],
	[idfKey1],
	[idfKey2],
	[strRowGuid]
)
select		75470000000	/*tlbAntimicrobialTherapy*/
			, ccat.idfId
			, ccat.idfAntimicrobialTherapy_v6
			, @TempIdentifierKey
from		[Giraffe].[dbo].[_dmccAntimicrobialTherapy] ccat
where		ccat.[idfAntimicrobialTherapy_v7] is null

exec [Giraffe].sys.sp_executesql N''ALTER INDEX ALL ON dbo.tstNewID REBUILD''

update		ccat
set			ccat.[idfAntimicrobialTherapy_v7] = nId.[NewID]
from		[Giraffe].[dbo].[_dmccAntimicrobialTherapy] ccat
join		[Giraffe].[dbo].[tstNewID] nId
on			nId.[idfTable] = 75470000000	/*tlbAntimicrobialTherapy*/
			and nId.[idfKey1] = ccat.[idfId]
			and nId.[idfKey2] = ccat.[idfAntimicrobialTherapy_v6]
			and nId.[strRowGuid] = @TempIdentifierKey collate Cyrillic_General_CI_AS
where		ccat.[idfAntimicrobialTherapy_v7] is null

/************************************************************
* Generate Id records - _dmccAntimicrobialTherapy - end
************************************************************/

'
/*
--TODO: remove
select	N'


IF OBJECT_ID(''tempdb..#OrigVetCase'') IS NOT NULL
	exec sp_executesql N''drop table #OrigVetCase''

IF OBJECT_ID(''tempdb..#OrigVetCase'') IS NULL
create table #OrigVetCase
(	[idfVetCase_v6] bigint not null primary key,
	[idfsTentativeDiagnosis] bigint null,
	[datTentativeDiagnosisDate] datetime null,
	[idfsTentativeDiagnosis1] bigint null,
	[datTentativeDiagnosis1Date] datetime null,
	[idfsTentativeDiagnosis2] bigint null,
	[datTentativeDiagnosis2Date] datetime null,
	[idfsFinalDiagnosis] bigint null,
	[datFinalDiagnosisDate] datetime null,

	[strLegacyID_v6] nvarchar(200) collate Cyrillic_General_CI_AS null,
	[idfFarm_v6] bigint not null,
	[idfObservation_v6] bigint null,
	[idfsTemplate_v6] bigint null,
	[idfOutbreak_v6] bigint null
)

truncate table #OrigVetCase


IF OBJECT_ID(''tempdb..#OrigVetCaseDiagnosis'') IS NOT NULL
	exec sp_executesql N''drop table #OrigVetCaseDiagnosis''

IF OBJECT_ID(''tempdb..#OrigVetCaseDiagnosis'') IS NULL
create table #OrigVetCase
(	[idfVetCase_v6] bigint not null,
	[idfsDiagnosis] bigint not null,
	[datDiagnosisDate] datetime null,
	[intOrder] int not null default(0),
	[isinitial] bit null default(0),
	[isinitial1] bit null default(0),
	[isinitial2] bit null default(0),
	[isinitial3] bit null default(0),
	[isFinal] bit null default(0),
	primary key
	(	[idfVetCase_v6] asc,
		[idfsDiagnosis] asc
	)
)

truncate table #OrigVetCaseDiagnosis


insert into	#OrigVetCase
(	idfVetCase_v6,
	idfsTentativeDiagnosis,
	datTentativeDiagnosisDate,
	idfsTentativeDiagnosis1,
	datTentativeDiagnosis1Date,
	idfsTentativeDiagnosis2,
	datTentativeDiagnosis2Date,
	idfsFinalDiagnosis,
	datFinalDiagnosisDate,
	strLegacyID_v6,

	idfFarm_v6,
	idfObservation_v6,
	idfsTemplate_v6,
	idfOutbreak_v6
)
select		  tlbVetCase_v6.[idfVetCase]
			, tlbVetCase_v6.[idfsTentativeDiagnosis]
			, tlbVetCase_v6.[datTentativeDiagnosisDate]
			, tlbVetCase_v6.[idfsTentativeDiagnosis1]
			, tlbVetCase_v6.[datTentativeDiagnosis1Date]
			, tlbVetCase_v6.[idfsTentativeDiagnosis2]
			, tlbVetCase_v6.[datTentativeDiagnosis2Date]
			, tlbVetCase_v6.[idfsFinalDiagnosis]
			, tlbVetCase_v6.[datFinalDiagnosisDate]
			, tlbVetCase_v6.[strCaseID]
			, tlbVetCase_v6.[idfFarm]
			, tlbVetCase_v6.[idfObservation]
			, tlbObservation_v6.[idfsFormTemplate]
			, tlbVetCase_v6.[idfOutbreak]
from		[Falcon].[dbo].[tlbVetCase] tlbVetCase_v6
inner join	[Falcon].[dbo].[tlbFarm] tlbFarm_v6
on			tlbFarm_v6.[idfFarm] = tlbVetCase_v6.[idfFarm]
left join	[Falcon].[dbo].[tlbObservation] tlbObservation_v6
on			tlbObservation_v6.[idfObservation] = tlbVetCase_v6.[idfObservation]
left join	[Giraffe].[dbo].[_dmccVetCase] ccvc
on			ccvc.[idfVetCase_v6] = tlbVetCase_v6.[idfVetCase]
			and ccvc.[isInitial] = 1
where		ccvc.[idfId] is null

-- TODO: complete or comment
-- Determine distinct VC diagnoses and update appropriate their dates order
insert into	#OrigVetCaseDiagnosis
(	idfVetCase_v6,
	idfsDiagnosis,
	datDiagnosisDate,
	intDiagOrder,
	isInitial,
	isInitial1,
	isInitial2,
	isInitial3,
	isFinal
)
select		  ovc.[idfVetCase_v6]
			, coalesce(ovc.[idfsTentativeDiagnosis], ovc.[idfsTentativeDiagnosis1], ovc.[idfsTentativeDiagnosis2], ovc.[idfsFinalDiagnosis], -1)
			, case
				when	ovc.[idfsTentativeDiagnosis] is not null
					then	ovc.[datTentativeDiagnosisDate]
				when	ovc.[idfsTentativeDiagnosis] is null
						and ovc.[idfsTentativeDiagnosis1] is not null
					then	ovc.[datTentativeDiagnosis1Date]
				when	ovc.[idfsTentativeDiagnosis] is null
						and ovc.[idfsTentativeDiagnosis1] is null
						and ovc.[idfsTentativeDiagnosis2] is not null
					then	ovc.[datTentativeDiagnosis1Date]
				else	coalesce(ovc.[datFinalDiagnosisDate], ovc.[datTentativeDiagnosisDate], ovc.[datTentativeDiagnosis1Date]ovc.[datTentativeDiagnosis2Date])
			  end
			, 0
			, 
from		#OrigVetCase ovc
left join	#OrigVetCaseDiagnosis ovc_diag_dupl
on			ovc_diag_dupl.[idfVetCase_v6] = ovc.[idfVetCase_v6]
			and ovc_diag_dupl.[idfsDiagnosis] = coalesce(ovc.[idfsTentativeDiagnosis], ovc.[idfsTentativeDiagnosis1], ovc.[idfsTentativeDiagnosis2], ovc.[idfsFinalDiagnosis], -1)
where		ovc_diag_dupl.[idfVetCase_v6] is null

print N''Identify initial VDRs v7 based on Veterinary Cases from v6.1''
print N''''
insert into [Giraffe].[dbo].[_dmccVetCase]
(	--Upd--idfRootId,
	--Upd--idfPreviousId,
	idfVetCase_v6,
	idfsDiagnosis,
	datDiagnosisDate,
	strLegacyID_v6,
	--Upd--idfSeqNumber,
	--Upd--strCaseID_v7,
	isInitial,
	isFinal,

	idfsCaseProgressStatus_v7,
	idfsCaseClassification_v7,
	idfsTemplate_v7,
	idfOutbreak_v7,

	idfFarm_v6,
	idfObservation_v6,
	idfsTemplate_v6,
	idfOutbreak_v6,

	idfVetCase_v7,
	idfFarm_v7,
	idfObservation_v7

	--Upd--idfRootVetCase_v7,
	--Upd--idfPreviousVetCase_v7
)
select		  tlbVetCase_v6.[idfVetCase]
			, case
				when	(tlbVetCase_v6.[idfsTentativeDiagnosis] is null or tlbVetCase_v6.[idfsTentativeDiagnosis] = tlbVetCase_v6.[idfsFinalDiagnosis])
						and (tlbVetCase_v6.[idfsTentativeDiagnosis1] is null or tlbVetCase_v6.[idfsTentativeDiagnosis1] = tlbVetCase_v6.[idfsFinalDiagnosis])
						and (tlbVetCase_v6.[idfsTentativeDiagnosis2] is null or tlbVetCase_v6.[idfsTentativeDiagnosis2] = tlbVetCase_v6.[idfsFinalDiagnosis])
					then	tlbVetCase_v6.[idfsFinalDiagnosis]
				when	(	tlbVetCase_v6.[idfsTentativeDiagnosis] is not null
							and (	tlbVetCase_v6.[idfsTentativeDiagnosis] <> tlbVetCase_v6.[idfsFinalDiagnosis]
									or tlbVetCase_v6.[idfsFinalDiagnosis] is null
								)
						)
						and (	tlbVetCase_v6.[idfsTentativeDiagnosis1] is null 
								or tlbVetCase_v6.[idfsTentativeDiagnosis1] = tlbVetCase_v6.[idfsTentativeDiagnosis]
								or tlbVetCase_v6.[idfsTentativeDiagnosis1] = tlbVetCase_v6.[idfsFinalDiagnosis]
							)
						and (	tlbVetCase_v6.[idfsTentativeDiagnosis1] is null 
								or tlbVetCase_v6.[idfsTentativeDiagnosis1] = tlbVetCase_v6.[idfsTentativeDiagnosis]
								or tlbVetCase_v6.[idfsTentativeDiagnosis1] = tlbVetCase_v6.[idfsFinalDiagnosis]
							)
					then	
			  end
--TODO: replace "from" with  #OrigVetCaseDiagnosis
from		[Falcon].[dbo].[tlbVetCase] tlbVetCase_v6
inner join	[Falcon].[dbo].[tlbFarm] tlbFarm_v6
on			tlbFarm_v6.[idfFarm] = tlbVetCase_v6.[idfFarm]
left join	[Giraffe].[dbo].[_dmccVetCase] ccvc
on			ccvc.[idfVetCase_v6] = tlbVetCase_v6.[idfVetCase]
			and ccvc.[isInitial] = 1
where		ccvc.[idfId] is null
print N''Initial VDRs v7 based on Veterinary Cases from v6.1: '' + cast(@@rowcount as nvarchar(20))
print N''''


'

*/



select	N'
print N''Determine copies of Patients and Contact Persons in HDRs v7 based on Patients and Contact Persons of Human Cases from v6.1''
print N''''

insert into [Giraffe].[dbo].[_dmccHuman]
(	idfHumanCaseId,
	idfCCPId,
	--No need--idfVetCaseId,
	--No need--idfFarmId,

	idfHumanCase_v6,
	idfContactedCasePerson_v6,
	--No need--idfVetCase_v6,
	--No need--idfFarm_v6,
	idfHuman_v6,

	idfHumanCase_v7,
	idfContactedCasePerson_v7,
	--No need--idfVetCase_v7,
	--No need--idfFarm_v7,

	idfHumanActual_v6,
	idfHumanCRAddress_v6,
	idfHumanPRAddress_v6,
	idfHumanEmpAddress_v6,

	[intRowStatus],
	[IsEmployedID],
	[EmployerPhoneNbr],
	[ContactPhoneNbr],
	
	idfHuman_v7,
	idfHumanCRAddress_v7,
	idfHumanPRAddress_v7,
	idfHumanEmpAddress_v7,
	idfHumanAltAddress_v7,
	idfHumanSchAddress_v7
)
select		  cchc.[idfId]
			, null
			--No need--, null
			--No need--, null

			, cchc.[idfHumanCase_v6]
			, null
			--No need--, null
			--No need--, null
			, tlbHuman_v6.[idfHuman]

			, cchc.[idfHumanCase_v7]
			, null
			--No need--, null
			--No need--, null

			, tlbHuman_v6.[idfHumanActual]
			, tlbHuman_v6.[idfCurrentResidenceAddress]
			, tlbHuman_v6.[idfRegistrationAddress]
			, tlbHuman_v6.[idfEmployerAddress]

			, tlbHuman_v6.[intRowStatus]
			,  case
				when	(	tlbHuman_v6.strEmployerName is not null
							and ltrim(rtrim(tlbHuman_v6.strEmployerName)) <> N'''' collate Cyrillic_General_CI_AS
						)
						or	(	tlbGeoLocation_EmployerAddress_v6.blnForeignAddress = 1 
								or tlbGeoLocation_EmployerAddress_v6.idfsRegion is not null
							)
						or	(	tlbHuman_v6.strWorkPhone is not null
								and ltrim(rtrim(tlbHuman_v6.strWorkPhone)) <> N'''' collate Cyrillic_General_CI_AS
							)
					then 10100001 /*Yes*/
				else null
			  end
			, tlbHuman_v6.strWorkPhone
			, tlbHuman_v6.strHomePhone

			, cchc.[idfHuman_v7]
			, case
				when	cchc.[idfHumanCase_v6] = cchc.[idfHumanCase_v7]
					then	tlbHuman_v6.[idfCurrentResidenceAddress]
				else	null
			  end
			, case
				when	cchc.[idfHumanCase_v6] = cchc.[idfHumanCase_v7]
					then	tlbHuman_v6.[idfRegistrationAddress]
				else	null
			  end
			, case
				when	cchc.[idfHumanCase_v6] = cchc.[idfHumanCase_v7]
					then	tlbHuman_v6.[idfEmployerAddress]
				else	null
			  end
			, null
			, null
from		[Giraffe].[dbo].[_dmccHumanCase] cchc
inner join	[Falcon].[dbo].[tlbHuman] tlbHuman_v6
on			tlbHuman_v6.[idfHuman] = cchc.[idfHuman_v6]
left join	[Falcon].[dbo].[tlbGeoLocation] tlbGeoLocation_EmployerAddress_v6
on			tlbGeoLocation_EmployerAddress_v6.[idfGeoLocation] = tlbHuman_v6.[idfEmployerAddress]

left join	[Giraffe].[dbo].[_dmccHuman] cch_idfHuman_v7
on			cch_idfHuman_v7.[idfHuman_v7] = cchc.[idfHuman_v7]

where		cchc.[idfHuman_v7] is not null
			and cch_idfHuman_v7.[idfId] is null
print N''Copies of Patients of HRDs v7 from Patients of Human Cases v6.1: '' + cast(@@rowcount as nvarchar(20))

'


select	N'
insert into [Giraffe].[dbo].[_dmccHuman]
(	idfHumanCaseId,
	idfCCPId,
	--No need--idfVetCaseId,
	--No need--idfFarmId,

	idfHumanCase_v6,
	idfContactedCasePerson_v6,
	--No need--idfVetCase_v6,
	--No need--idfFarm_v6,
	idfHuman_v6,

	idfHumanCase_v7,
	idfContactedCasePerson_v7,
	--No need--idfVetCase_v7,
	--No need--idfFarm_v7,

	idfHumanActual_v6,
	idfHumanCRAddress_v6,
	idfHumanPRAddress_v6,
	idfHumanEmpAddress_v6,

	[intRowStatus],
	[IsEmployedID],
	[EmployerPhoneNbr],
	[ContactPhoneNbr],
	
	idfHuman_v7,
	idfHumanCRAddress_v7,
	idfHumanPRAddress_v7,
	idfHumanEmpAddress_v7,
	idfHumanAltAddress_v7,
	idfHumanSchAddress_v7
)
select		  ccccp.[idfHumanCaseId]
			, ccccp.[idfId]
			--No need--, null
			--No need--, null

			, ccccp.[idfHumanCase_v6]
			, ccccp.[idfContactedCasePerson_v6]
			--No need--, null
			--No need--, null
			, tlbHuman_v6.[idfHuman]

			, ccccp.[idfHumanCase_v7]
			, ccccp.[idfContactedCasePerson_v7]
			--No need--, null
			--No need--, null

			, tlbHuman_v6.[idfHumanActual]
			, tlbHuman_v6.[idfCurrentResidenceAddress]
			, tlbHuman_v6.[idfRegistrationAddress]
			, tlbHuman_v6.[idfEmployerAddress]

			, tlbHuman_v6.[intRowStatus]
			,  case
				when	(	tlbHuman_v6.strEmployerName is not null
							and ltrim(rtrim(tlbHuman_v6.strEmployerName)) <> N'''' collate Cyrillic_General_CI_AS
						)
						or	(	tlbGeoLocation_EmployerAddress_v6.blnForeignAddress = 1 
								or tlbGeoLocation_EmployerAddress_v6.idfsRegion is not null
							)
						or	(	tlbHuman_v6.strWorkPhone is not null
								and ltrim(rtrim(tlbHuman_v6.strWorkPhone)) <> N'''' collate Cyrillic_General_CI_AS
							)
					then 10100001 /*Yes*/
				else null
			  end
			, tlbHuman_v6.strWorkPhone
			, tlbHuman_v6.strHomePhone

			, ccccp.[idfHuman_v7]
			, case
				when	ccccp.[idfContactedCasePerson_v6] = ccccp.[idfContactedCasePerson_v7]
					then	tlbHuman_v6.[idfCurrentResidenceAddress]
				else	null
			  end
			, case
				when	ccccp.[idfContactedCasePerson_v6] = ccccp.[idfContactedCasePerson_v7]
					then	tlbHuman_v6.[idfRegistrationAddress]
				else	null
			  end
			, case
				when	ccccp.[idfContactedCasePerson_v6] = ccccp.[idfContactedCasePerson_v7]
					then	tlbHuman_v6.[idfEmployerAddress]
				else	null
			  end
			, null
			, null
from		[Giraffe].[dbo].[_dmccContactedCasePerson] ccccp
inner join	[Falcon].[dbo].[tlbHuman] tlbHuman_v6
on			tlbHuman_v6.[idfHuman] = ccccp.[idfHuman_v6]
left join	[Falcon].[dbo].[tlbGeoLocation] tlbGeoLocation_EmployerAddress_v6
on			tlbGeoLocation_EmployerAddress_v6.[idfGeoLocation] = tlbHuman_v6.[idfEmployerAddress]

left join	[Giraffe].[dbo].[_dmccHuman] cch_idfHuman_v7
on			cch_idfHuman_v7.[idfHuman_v7] = ccccp.[idfHuman_v7]

where		ccccp.[idfHuman_v7] is not null
			and cch_idfHuman_v7.[idfId] is null
print N''Copies of Contact Persons of HRDs v7 from Contact Persons of Human Cases v6.1: '' + cast(@@rowcount as nvarchar(20))
print N''''

'



select	N'
insert into [Giraffe].[dbo].[_dmccHuman]
(	--No need--idfHumanCaseId,
	--No need--idfCCPId,
	--No need--idfVetCaseId,
	--No need--idfFarmId,

	--No need--idfHumanCase_v6,
	--No need--idfContactedCasePerson_v6,
	--No need--idfVetCase_v6,
	idfFarm_v6,
	idfHuman_v6,

	--No need--idfHumanCase_v7,
	--No need--idfContactedCasePerson_v7,
	--No need--idfVetCase_v7,
	idfFarm_v7,

	idfHumanActual_v6,
	idfHumanCRAddress_v6,
	idfHumanPRAddress_v6,
	idfHumanEmpAddress_v6,

	[intRowStatus],
	[IsEmployedID],
	[EmployerPhoneNbr],
	[ContactPhoneNbr],
	
	idfHuman_v7,
	idfHumanCRAddress_v7,
	idfHumanPRAddress_v7,
	idfHumanEmpAddress_v7,
	idfHumanAltAddress_v7,
	idfHumanSchAddress_v7
)
select		--No need--  null
			--No need--, null
			--No need--, null
			--No need--, null

			--No need--, null
			--No need--, null
			--No need--, null
			  tlbFarm_v6.[idfFarm]
			, tlbHuman_v6.[idfHuman]

			--No need--, null
			--No need--, null
			--No need--, null
			, tlbFarm_v6.[idfFarm]

			, tlbHuman_v6.[idfHumanActual]
			, tlbHuman_v6.[idfCurrentResidenceAddress]
			, tlbHuman_v6.[idfRegistrationAddress]
			, tlbHuman_v6.[idfEmployerAddress]

			, tlbHuman_v6.[intRowStatus]
			,  case
				when	(	tlbHuman_v6.strEmployerName is not null
							and ltrim(rtrim(tlbHuman_v6.strEmployerName)) <> N'''' collate Cyrillic_General_CI_AS
						)
						or	(	tlbGeoLocation_EmployerAddress_v6.blnForeignAddress = 1 
								or tlbGeoLocation_EmployerAddress_v6.idfsRegion is not null
							)
						or	(	tlbHuman_v6.strWorkPhone is not null
								and ltrim(rtrim(tlbHuman_v6.strWorkPhone)) <> N'''' collate Cyrillic_General_CI_AS
							)
					then 10100001 /*Yes*/
				else null
			  end
			, tlbHuman_v6.strWorkPhone
			, tlbHuman_v6.strHomePhone

			, tlbHuman_v6.[idfHuman]
			, tlbHuman_v6.[idfCurrentResidenceAddress]
			, tlbHuman_v6.[idfRegistrationAddress]
			, tlbHuman_v6.[idfEmployerAddress]
			, null
			, null
from		[Falcon].[dbo].[tlbFarm] tlbFarm_v6
inner join	[Falcon].[dbo].[tlbHuman] tlbHuman_v6
on			tlbHuman_v6.[idfHuman] = tlbFarm_v6.[idfHuman]
left join	[Falcon].[dbo].[tlbGeoLocation] tlbGeoLocation_EmployerAddress_v6
on			tlbGeoLocation_EmployerAddress_v6.[idfGeoLocation] = tlbHuman_v6.[idfEmployerAddress]

left join	[Giraffe].[dbo].[_dmccHuman] cch_idfHuman_v7
on			cch_idfHuman_v7.[idfHuman_v7] = tlbHuman_v6.[idfHuman]

where		cch_idfHuman_v7.[idfId] is null
print N''Farm Owners v7 from Farm Owners v6.1: '' + cast(@@rowcount as nvarchar(20))
print N''''

'



select	N'
insert into [Giraffe].[dbo].[_dmccHuman]
(	--No need--idfHumanCaseId,
	--No need--idfCCPId,
	--No need--idfVetCaseId,
	--No need--idfFarmId,

	--No need--idfHumanCase_v6,
	--No need--idfContactedCasePerson_v6,
	--No need--idfVetCase_v6,
	--No need--idfFarm_v6,
	idfBSS_v6,
	idfHuman_v6,

	--No need--idfHumanCase_v7,
	--No need--idfContactedCasePerson_v7,
	--No need--idfVetCase_v7,
	--No need--idfFarm_v7,
	idfBSS_v7,

	idfHumanActual_v6,
	idfHumanCRAddress_v6,
	idfHumanPRAddress_v6,
	idfHumanEmpAddress_v6,

	[intRowStatus],
	[IsEmployedID],
	[EmployerPhoneNbr],
	[ContactPhoneNbr],
	
	idfHuman_v7,
	idfHumanCRAddress_v7,
	idfHumanPRAddress_v7,
	idfHumanEmpAddress_v7,
	idfHumanAltAddress_v7,
	idfHumanSchAddress_v7
)
select		--No need--  null
			--No need--, null
			--No need--, null
			--No need--, null

			--No need--, null
			--No need--, null
			--No need--, null
			--No need--, null
			  tlbBasicSyndromicSurveillance_v6.[idfBasicSyndromicSurveillance]
			, tlbHuman_v6.[idfHuman]

			--No need--, null
			--No need--, null
			--No need--, null
			--No need--, null
			, tlbBasicSyndromicSurveillance_v6.[idfBasicSyndromicSurveillance]

			, tlbHuman_v6.[idfHumanActual]
			, tlbHuman_v6.[idfCurrentResidenceAddress]
			, tlbHuman_v6.[idfRegistrationAddress]
			, tlbHuman_v6.[idfEmployerAddress]

			, tlbHuman_v6.[intRowStatus]
			,  case
				when	(	tlbHuman_v6.strEmployerName is not null
							and ltrim(rtrim(tlbHuman_v6.strEmployerName)) <> N'''' collate Cyrillic_General_CI_AS
						)
						or	(	tlbGeoLocation_EmployerAddress_v6.blnForeignAddress = 1 
								or tlbGeoLocation_EmployerAddress_v6.idfsRegion is not null
							)
						or	(	tlbHuman_v6.strWorkPhone is not null
								and ltrim(rtrim(tlbHuman_v6.strWorkPhone)) <> N'''' collate Cyrillic_General_CI_AS
							)
					then 10100001 /*Yes*/
				else null
			  end
			, tlbHuman_v6.strWorkPhone
			, tlbHuman_v6.strHomePhone

			, tlbHuman_v6.[idfHuman]
			, tlbHuman_v6.[idfCurrentResidenceAddress]
			, tlbHuman_v6.[idfRegistrationAddress]
			, tlbHuman_v6.[idfEmployerAddress]
			, null
			, null
from		[Falcon].[dbo].[tlbBasicSyndromicSurveillance] tlbBasicSyndromicSurveillance_v6
inner join	[Falcon].[dbo].[tlbHuman] tlbHuman_v6
on			tlbHuman_v6.[idfHuman] = tlbBasicSyndromicSurveillance_v6.[idfHuman]
left join	[Falcon].[dbo].[tlbGeoLocation] tlbGeoLocation_EmployerAddress_v6
on			tlbGeoLocation_EmployerAddress_v6.[idfGeoLocation] = tlbHuman_v6.[idfEmployerAddress]

left join	[Giraffe].[dbo].[_dmccHuman] cch_idfHuman_v7
on			cch_idfHuman_v7.[idfHuman_v7] = tlbHuman_v6.[idfHuman]

where		cch_idfHuman_v7.[idfId] is null
print N''Basic Syndromic Surveillance Patients v7 from Basic Syndromic Surveillance Patients v6.1: '' + cast(@@rowcount as nvarchar(20))
print N''''
print N''''

'

select	N'
-- Fix for the usage of the same copy of the person as farm owners in different farms
update		cch
set			cch.[idfHuman_v7] = null,
			cch.[idfHumanCRAddress_v7] = null,
			cch.[idfHumanPRAddress_v7] = null,
			cch.[idfHumanEmpAddress_v7] = null,
			cch.[idfHumanAltAddress_v7] = null,
			cch.[idfHumanSchAddress_v7] = null
from		[Giraffe].[dbo].[_dmccHuman] cch
where		exists
			(	select	1
				from	[Giraffe].[dbo].[_dmccHuman] cch_less
				where	cch_less.[idfHuman_v6] = cch.[idfHuman_v6]
						and cch_less.[idfHuman_v7] = cch.[idfHuman_v7]
						and cch_less.[idfId] < cch.[idfId]
			)

update		cch
set			cch.[idfHumanCRAddress_v7] = null
from		[Giraffe].[dbo].[_dmccHuman] cch
where		cch.[idfHumanCRAddress_v7] is not null
			and exists
			(	select	1
				from	[Giraffe].[dbo].[_dmccHuman] cch_less
				where	cch_less.[idfHumanCRAddress_v7] = cch.[idfHumanCRAddress_v7]
						and cch_less.[idfId] < cch.[idfId]
			)

update		cch
set			cch.[idfHumanPRAddress_v7] = null
from		[Giraffe].[dbo].[_dmccHuman] cch
where		cch.[idfHumanPRAddress_v7] is not null
			and exists
			(	select	1
				from	[Giraffe].[dbo].[_dmccHuman] cch_less
				where	cch_less.[idfHumanPRAddress_v7] = cch.[idfHumanPRAddress_v7]
						and cch_less.[idfId] < cch.[idfId]
			)

update		cch
set			cch.[idfHumanEmpAddress_v7] = null
from		[Giraffe].[dbo].[_dmccHuman] cch
where		cch.[idfHumanEmpAddress_v7] is not null
			and exists
			(	select	1
				from	[Giraffe].[dbo].[_dmccHuman] cch_less
				where	cch_less.[idfHumanEmpAddress_v7] = cch.[idfHumanEmpAddress_v7]
						and cch_less.[idfId] < cch.[idfId]
			)

'

select	N'

/************************************************************
* Generate Id records - _dmccHuman - start
************************************************************/
insert into	[Giraffe].[dbo].[tstNewID]
(	[idfTable],
	[idfKey1],
	[idfKey2],
	[strRowGuid]
)
select		75600000000	/*tlbHuman*/
			, cch.idfId
			, coalesce(cch.[idfContactedCasePerson_v7], cch.[idfHumanCase_v7], cch.[idfFarm_v7], cch.[idfBSS_v7])
			, @TempIdentifierKey
from		[Giraffe].[dbo].[_dmccHuman] cch
where		cch.[idfHuman_v7] is null

insert into	[Giraffe].[dbo].[tstNewID]
(	[idfTable],
	[idfKey1],
	[idfKey2],
	[strRowGuid]
)
select		75580000000	/*tlbGeoLocation*/
			, cch.idfId + 1
			, coalesce(cch.[idfContactedCasePerson_v7], cch.[idfHumanCase_v7], cch.[idfFarm_v7], cch.[idfBSS_v7])
			, @TempIdentifierKey
from		[Giraffe].[dbo].[_dmccHuman] cch
where		cch.[idfHumanCRAddress_v7] is null

insert into	[Giraffe].[dbo].[tstNewID]
(	[idfTable],
	[idfKey1],
	[idfKey2],
	[strRowGuid]
)
select		75580000000	/*tlbGeoLocation*/
			, cch.idfId + 2
			, coalesce(cch.[idfContactedCasePerson_v7], cch.[idfHumanCase_v7], cch.[idfFarm_v7], cch.[idfBSS_v7])
			, @TempIdentifierKey
from		[Giraffe].[dbo].[_dmccHuman] cch
where		cch.[idfHumanPRAddress_v7] is null

insert into	[Giraffe].[dbo].[tstNewID]
(	[idfTable],
	[idfKey1],
	[idfKey2],
	[strRowGuid]
)
select		75580000000	/*tlbGeoLocation*/
			, cch.idfId + 3
			, coalesce(cch.[idfContactedCasePerson_v7], cch.[idfHumanCase_v7], cch.[idfFarm_v7], cch.[idfBSS_v7])
			, @TempIdentifierKey
from		[Giraffe].[dbo].[_dmccHuman] cch
where		cch.[idfHumanEmpAddress_v7] is null

insert into	[Giraffe].[dbo].[tstNewID]
(	[idfTable],
	[idfKey1],
	[idfKey2],
	[strRowGuid]
)
select		75580000000	/*tlbGeoLocation*/
			, cch.idfId + 4
			, coalesce(cch.[idfContactedCasePerson_v7], cch.[idfHumanCase_v7], cch.[idfFarm_v7], cch.[idfBSS_v7])
			, @TempIdentifierKey
from		[Giraffe].[dbo].[_dmccHuman] cch
where		cch.[idfHumanAltAddress_v7] is null

insert into	[Giraffe].[dbo].[tstNewID]
(	[idfTable],
	[idfKey1],
	[idfKey2],
	[strRowGuid]
)
select		75580000000	/*tlbGeoLocation*/
			, cch.idfId + 5
			, coalesce(cch.[idfContactedCasePerson_v7], cch.[idfHumanCase_v7], cch.[idfFarm_v7], cch.[idfBSS_v7])
			, @TempIdentifierKey
from		[Giraffe].[dbo].[_dmccHuman] cch
where		cch.[idfHumanSchAddress_v7] is null


exec [Giraffe].sys.sp_executesql N''ALTER INDEX ALL ON dbo.tstNewID REBUILD''

update		cch
set			cch.[idfHuman_v7] = nId.[NewID]
from		[Giraffe].[dbo].[_dmccHuman] cch
join		[Giraffe].[dbo].[tstNewID] nId
on			nId.[idfTable] = 75600000000	/*tlbHuman*/
			and nId.[idfKey1] = cch.[idfId]
			and nId.[idfKey2] = coalesce(cch.[idfContactedCasePerson_v7], cch.[idfHumanCase_v7], cch.[idfFarm_v7], cch.[idfBSS_v7])
			and nId.[strRowGuid] = @TempIdentifierKey collate Cyrillic_General_CI_AS
where		cch.[idfHuman_v7] is null

update		cch
set			cch.[idfHumanCRAddress_v7] = nId.[NewID]
from		[Giraffe].[dbo].[_dmccHuman] cch
join		[Giraffe].[dbo].[tstNewID] nId
on			nId.[idfTable] = 75580000000	/*tlbGeoLocation*/
			and nId.[idfKey1] = cch.[idfId] + 1
			and nId.[idfKey2] = coalesce(cch.[idfContactedCasePerson_v7], cch.[idfHumanCase_v7], cch.[idfFarm_v7], cch.[idfBSS_v7])
			and nId.[strRowGuid] = @TempIdentifierKey collate Cyrillic_General_CI_AS
where		cch.[idfHumanCRAddress_v7] is null


update		cch
set			cch.[idfHumanPRAddress_v7] = nId.[NewID]
from		[Giraffe].[dbo].[_dmccHuman] cch
join		[Giraffe].[dbo].[tstNewID] nId
on			nId.[idfTable] = 75580000000	/*tlbGeoLocation*/
			and nId.[idfKey1] = cch.[idfId] + 2
			and nId.[idfKey2] = coalesce(cch.[idfContactedCasePerson_v7], cch.[idfHumanCase_v7], cch.[idfFarm_v7], cch.[idfBSS_v7])
			and nId.[strRowGuid] = @TempIdentifierKey collate Cyrillic_General_CI_AS
where		cch.[idfHumanPRAddress_v7] is null


'

select	N'

update		cch
set			cch.[idfHumanEmpAddress_v7] = nId.[NewID]
from		[Giraffe].[dbo].[_dmccHuman] cch
join		[Giraffe].[dbo].[tstNewID] nId
on			nId.[idfTable] = 75580000000	/*tlbGeoLocation*/
			and nId.[idfKey1] = cch.[idfId] + 3
			and nId.[idfKey2] = coalesce(cch.[idfContactedCasePerson_v7], cch.[idfHumanCase_v7], cch.[idfFarm_v7], cch.[idfBSS_v7])
			and nId.[strRowGuid] = @TempIdentifierKey collate Cyrillic_General_CI_AS
where		cch.[idfHumanEmpAddress_v7] is null


update		cch
set			cch.[idfHumanAltAddress_v7] = nId.[NewID]
from		[Giraffe].[dbo].[_dmccHuman] cch
join		[Giraffe].[dbo].[tstNewID] nId
on			nId.[idfTable] = 75580000000	/*tlbGeoLocation*/
			and nId.[idfKey1] = cch.[idfId] + 4
			and nId.[idfKey2] = coalesce(cch.[idfContactedCasePerson_v7], cch.[idfHumanCase_v7], cch.[idfFarm_v7], cch.[idfBSS_v7])
			and nId.[strRowGuid] = @TempIdentifierKey collate Cyrillic_General_CI_AS
where		cch.[idfHumanAltAddress_v7] is null


update		cch
set			cch.[idfHumanSchAddress_v7] = nId.[NewID]
from		[Giraffe].[dbo].[_dmccHuman] cch
join		[Giraffe].[dbo].[tstNewID] nId
on			nId.[idfTable] = 75580000000	/*tlbGeoLocation*/
			and nId.[idfKey1] = cch.[idfId] + 5
			and nId.[idfKey2] = coalesce(cch.[idfContactedCasePerson_v7], cch.[idfHumanCase_v7], cch.[idfFarm_v7], cch.[idfBSS_v7])
			and nId.[strRowGuid] = @TempIdentifierKey collate Cyrillic_General_CI_AS
where		cch.[idfHumanSchAddress_v7] is null


/************************************************************
* Generate Id records - _dmccHuman - end
************************************************************/

update		cchc
set			cchc.[idfHuman_v7] = cch.[idfHuman_v7]
from		[Giraffe].[dbo].[_dmccHumanCase] cchc
join		[Giraffe].[dbo].[_dmccHuman] cch
on			cch.[idfHumanCase_v7] = cchc.[idfHumanCase_v7]
			and cch.[idfHumanCase_v6] = cchc.[idfHumanCase_v6]
			and cch.[idfHuman_v6] = cchc.[idfHuman_v6]
where		cch.[idfHuman_v7] <> cchc.[idfHuman_v7]

update		ccccp
set			ccccp.[idfHuman_v7] = cch.[idfHuman_v7]
from		[Giraffe].[dbo].[_dmccContactedCasePerson] ccccp
join		[Giraffe].[dbo].[_dmccHuman] cch
on			cch.[idfContactedCasePerson_v7] = ccccp.[idfContactedCasePerson_v7]
			and cch.[idfContactedCasePerson_v6] = ccccp.[idfContactedCasePerson_v6]
			and cch.[idfHuman_v6] = ccccp.[idfHuman_v6]
where		cch.[idfHuman_v7] <> ccccp.[idfHuman_v7]

'


select	N'
print N''Determine copies of Samples for HDRs v7 based on Samples of Human Cases from v6.1''
print N''''

insert into [Giraffe].[dbo].[_dmccMaterial]
(	--Upd--idfParentMaterialId,
	
	idfHumanCaseId,
	
	--No need--idfVetCaseId,
	--No need--idfFarmId,
	--No need--idfHerdId,
	--No need--idfSpeciesId,
	--No need--idfAnimalId,

	idfHumanCase_v6,
	idfHuman_v6,

	--No need--idfVetCase_v6,
	--No need--idfFarm_v6,
	--No need--idfHerd_v6,
	--No need--idfSpecies_v6,
	--No need--idfAnimal_v6,

	idfMaterial_v6,
	idfParentMaterial_v6,
	idfRootMaterial_v6,
	blnReadOnly_v6,

	idfHumanCase_v7,
	idfHuman_v7,

	--No need--idfVetCase_v7,
	--No need--idfFarm_v7,
	--No need--idfHerd_v7,
	--No need--idfSpecies_v7,
	--No need--idfAnimal_v7,

	strCalculatedCaseID_v7,
	strCalculatedHumanName_v7,

	idfRootMaterial_v7,
	idfParentMaterial_v7,
	blnReadOnly_v7,
	
	idfMaterial_v7
)
select		cchc.[idfId]

			--No need--, null
			--No need--, null
			--No need--, null
			--No need--, null
			--No need--, null

			, cchc.[idfHumanCase_v6]
			, cchc.[idfHuman_v6]

			--No need--, null
			--No need--, null
			--No need--, null
			--No need--, null
			--No need--, null

			, tlbMaterial_v6.[idfMaterial]
			, tlbMaterial_v6.[idfParentMaterial]
			, tlbMaterial_v6.[idfRootMaterial]
			, tlbMaterial_v6.[blnReadOnly]

			, cchc.[idfHumanCase_v7]
			, cchc.[idfHuman_v7]

			--No need--, null
			--No need--, null
			--No need--, null
			--No need--, null
			--No need--, null

			, cchc.[strCaseID_v7]
			, dbo.fnConcatFullName(tlbHuman_v6.strLastName, tlbHuman_v6.strFirstName, tlbHuman_v6.strSecondName)

			, tlbMaterial_v6.[idfRootMaterial]
			, case
				when	cchc.[idfHumanCase_v6] = cchc.[idfHumanCase_v7]
					then	tlbMaterial_v6.[idfParentMaterial]
				else	null
			  end
			, case
				when	cchc.[idfHumanCase_v6] = cchc.[idfHumanCase_v7]
					then	tlbMaterial_v6.[blnReadOnly]
				else	1
			  end

			, case
				when	cchc.[idfHumanCase_v6] = cchc.[idfHumanCase_v7]
					then	tlbMaterial_v6.[idfMaterial]
				else	null
			  end

from		[Giraffe].[dbo].[_dmccHumanCase] cchc
inner join	[Falcon].[dbo].[tlbMaterial] tlbMaterial_v6
on			tlbMaterial_v6.[idfHumanCase] = cchc.[idfHumanCase_v6]
inner join	[Falcon].[dbo].[tlbHuman] tlbHuman_v6
on			tlbHuman_v6.[idfHuman] = cchc.[idfHuman_v6]
left join	[Giraffe].[dbo].[_dmccMaterial] ccm
on			ccm.[idfHumanCase_v6] = cchc.[idfHumanCase_v6]
			and ccm.[idfMaterial_v6] = tlbMaterial_v6.[idfMaterial]
			--and ccm.[idfHumanCaseId] = cchc.[idfId]
			and ccm.[idfHumanCase_v7] = cchc.[idfHumanCase_v7]
where		cchc.[idfHumanCase_v7] is not null
			and cchc.[idfHuman_v7] is not null
			and ccm.[idfId] is null
print N''Copies of Samples of HRDs v7 from Samples of Human Cases v6.1: '' + cast(@@rowcount as nvarchar(20))
print N''''
print N''''

'


select	N'

-- Update parent Meterial Id
update		ccm
set			ccm.[idfParentMaterialId] = ccm_parent.[idfId]
from		[Giraffe].[dbo].[_dmccHumanCase] cchc
inner join	[Falcon].[dbo].[tlbMaterial] tlbMaterial_v6
on			tlbMaterial_v6.[idfHumanCase] = cchc.[idfHumanCase_v6]
inner join	[Falcon].[dbo].[tlbHuman] tlbHuman_v6
on			tlbHuman_v6.[idfHuman] = cchc.[idfHuman_v6]
inner join	[Giraffe].[dbo].[_dmccMaterial] ccm
on			ccm.[idfHumanCase_v6] = cchc.[idfHumanCase_v6]
			and ccm.[idfMaterial_v6] = tlbMaterial_v6.[idfMaterial]
			and ccm.[idfHumanCase_v7] = cchc.[idfHumanCase_v7]

inner join	[Giraffe].[dbo].[_dmccMaterial] ccm_parent
on			ccm_parent.[idfHumanCase_v6] = cchc.[idfHumanCase_v6]
			and ccm_parent.[idfMaterial_v6] = tlbMaterial_v6.[idfParentMaterial]
			and ccm_parent.[idfHumanCase_v7] = cchc.[idfHumanCase_v7]

where		cchc.[idfHumanCase_v7] is not null
			and cchc.[idfHuman_v7] is not null
			and ccm.[idfParentMaterial_v6] is not null
			and ccm.[idfParentMaterialId] is null

/************************************************************
* Generate Id records - _dmccMaterial - start
************************************************************/
insert into	[Giraffe].[dbo].[tstNewID]
(	[idfTable],
	[idfKey1],
	[idfKey2],
	[strRowGuid]
)
select		75620000000	/*tlbMaterial*/
			, ccm.idfId
			, ccm.idfMaterial_v6
			, @TempIdentifierKey
from		[Giraffe].[dbo].[_dmccMaterial] ccm
where		ccm.[idfMaterial_v7] is null

exec [Giraffe].sys.sp_executesql N''ALTER INDEX ALL ON dbo.tstNewID REBUILD''

update		ccm
set			ccm.[idfMaterial_v7] = nId.[NewID]
from		[Giraffe].[dbo].[_dmccMaterial] ccm
join		[Giraffe].[dbo].[tstNewID] nId
on			nId.[idfTable] = 75620000000	/*tlbMaterial*/
			and nId.[idfKey1] = ccm.[idfId]
			and nId.[idfKey2] = ccm.[idfMaterial_v6]
			and nId.[strRowGuid] = @TempIdentifierKey collate Cyrillic_General_CI_AS
where		ccm.[idfMaterial_v7] is null

update		ccm
set			ccm.[idfParentMaterial_v7] = ccm_parent.[idfMaterial_v7]
from		[Giraffe].[dbo].[_dmccMaterial] ccm

inner join	[Giraffe].[dbo].[_dmccMaterial] ccm_parent
on			ccm_parent.[idfId] = ccm.[idfParentMaterialId]

where		ccm.[idfParentMaterial_v6] is not null
			and ccm.[idfParentMaterial_v7] is null

/************************************************************
* Generate Id records - _dmccMaterial - end
************************************************************/

'



select	N'
print N''Determine copies of Lab Tests in HDRs v7 based on Lab Tests of Human Cases from v6.1''
print N''''

insert into [Giraffe].[dbo].[_dmccLabTest]
(	idfMaterialId,
	idfMaterial_v6,
	idfTesting_v6,
	idfMaterial_v7,

	idfHumanCase_v6,
	--No need--idfVetCase_v6,
	idfHumanCase_v7,
	--No need--idfVetCase_v7,

	idfsDiagnosis_v6,
	idfObservation_v6,
	idfsTemplate_v6,
	blnReadOnly_v6,
	idfBatchTest_v6,

	idfsTemplate_v7,
	blnReadOnly_v7,
	idfBatchTest_v7,--for copies, specify null; for original test records, specify original batch test
	
	idfTesting_v7,
	idfObservation_v7
)
select		  ccm.[idfId]
			, ccm.[idfMaterial_v6]
			, tlbTesting_v6.[idfTesting]
			, ccm.[idfMaterial_v7]

			, ccm.[idfHumanCase_v6]
			--No need--, null
			, ccm.[idfHumanCase_v7]
			--No need--, null

			, tlbTesting_v6.[idfsDiagnosis]
			, tlbTesting_v6.[idfObservation]
			, tlbObservation_v6.[idfsFormTemplate]
			, tlbTesting_v6.[blnReadOnly]
			, tlbTesting_v6.[idfBatchTest]

			, tlbObservation_v6.[idfsFormTemplate]
			, case
				when	ccm.[idfMaterial_v6] = ccm.[idfMaterial_v7]
					then	tlbTesting_v6.[blnReadOnly]
				else	1
			  end
			, case
				when	ccm.[idfMaterial_v6] = ccm.[idfMaterial_v7]
					then	tlbTesting_v6.[idfBatchTest]
				else	null
			  end

			, case
				when	ccm.[idfMaterial_v6] = ccm.[idfMaterial_v7]
					then	tlbTesting_v6.[idfTesting]
				else	null
			  end

			, case
				when	ccm.[idfMaterial_v6] = ccm.[idfMaterial_v7]
					then	tlbTesting_v6.[idfObservation]
				else	null
			  end

from		[Giraffe].[dbo].[_dmccMaterial] ccm
inner join	[Falcon].[dbo].[tlbTesting] tlbTesting_v6
on			tlbTesting_v6.[idfMaterial] = ccm.[idfMaterial_v6]
left join	[Falcon].[dbo].[tlbObservation] tlbObservation_v6
on			tlbObservation_v6.[idfObservation] = tlbTesting_v6.[idfObservation]
left join	[Giraffe].[dbo].[_dmccLabTest] cct
on			cct.[idfMaterial_v6] = ccm.[idfMaterial_v6]
			and cct.[idfTesting_v6] = tlbTesting_v6.[idfTesting]
			--and cct.[idfMaterialId] = ccm.[idfId]
			and cct.[idfMaterial_v7] = ccm.[idfMaterial_v7]
where		ccm.[idfMaterial_v7] is not null
			and ccm.[idfHumanCase_v7] is not null -- Samples of Human Cases
			and cct.[idfId] is null
print N''Copies of Lab Tests for HRDs v7 from Lab Tests of Human Cases v6.1: '' + cast(@@rowcount as nvarchar(20))
print N''''
print N''''


/************************************************************
* Generate Id records - _dmccLabTest - start
************************************************************/
insert into	[Giraffe].[dbo].[tstNewID]
(	[idfTable],
	[idfKey1],
	[idfKey2],
	[strRowGuid]
)
select		75740000000	/*tlbTesting*/
			, cct.idfId
			, cct.idfTesting_v6
			, @TempIdentifierKey
from		[Giraffe].[dbo].[_dmccLabTest] cct
where		cct.[idfMaterial_v7] is not null
			and cct.[idfTesting_v7] is null

insert into	[Giraffe].[dbo].[tstNewID]
(	[idfTable],
	[idfKey1],
	[idfKey2],
	[strRowGuid]
)
select		75640000000	/*tlbObservation*/
			, cct.idfId + 1
			, cct.idfTesting_v6
			, @TempIdentifierKey
from		[Giraffe].[dbo].[_dmccLabTest] cct
where		cct.[idfMaterial_v7] is not null
			and cct.[idfObservation_v7] is null

exec [Giraffe].sys.sp_executesql N''ALTER INDEX ALL ON dbo.tstNewID REBUILD''

update		cct
set			cct.[idfTesting_v7] = nId.[NewID]
from		[Giraffe].[dbo].[_dmccLabTest] cct
join		[Giraffe].[dbo].[tstNewID] nId
on			nId.[idfTable] = 75740000000	/*tlbTesting*/
			and nId.[idfKey1] = cct.[idfId]
			and nId.[idfKey2] = cct.[idfTesting_v6]
			and nId.[strRowGuid] = @TempIdentifierKey collate Cyrillic_General_CI_AS
where		cct.[idfTesting_v7] is null

update		cct
set			cct.[idfObservation_v7] = nId.[NewID]
from		[Giraffe].[dbo].[_dmccLabTest] cct
join		[Giraffe].[dbo].[tstNewID] nId
on			nId.[idfTable] = 75640000000	/*tlbObservation*/
			and nId.[idfKey1] = cct.[idfId] + 1
			and nId.[idfKey2] = cct.[idfTesting_v6]
			and nId.[strRowGuid] = @TempIdentifierKey collate Cyrillic_General_CI_AS
where		cct.[idfObservation_v7] is null

/************************************************************
* Generate Id records - _dmccLabTest - end
************************************************************/

'



select	N'
print N''Determine copies of Test Interpretation records in HDRs v7 based on Test Interpretation records of Human Cases from v6.1''
print N''''

insert into [Giraffe].[dbo].[_dmccTestValidation]
(	idfLabTestId,
	idfTesting_v6,
	idfTestValidation_v6,
	idfTesting_v7,

	idfsDiagnosis_v6,
	blnReadOnly_v6,

	blnReadOnly_v7,
	
	idfTestValidation_v7
)
select		  cct.[idfId]
			, cct.[idfTesting_v6]
			, tlbTestValidation_v6.[idfTestValidation]
			, cct.[idfTesting_v7]

			, tlbTestValidation_v6.[idfsDiagnosis]
			, tlbTestValidation_v6.[blnReadOnly]

			, case
				when	cct.[idfTesting_v6] = cct.[idfTesting_v7]
					then	tlbTestValidation_v6.[blnReadOnly]
				else	1
			  end

			, case
				when	cct.[idfTesting_v6] = cct.[idfTesting_v7]
					then	tlbTestValidation_v6.[idfTestValidation]
				else	null
			  end
from		[Giraffe].[dbo].[_dmccLabTest] cct
inner join	[Falcon].[dbo].[tlbTestValidation] tlbTestValidation_v6
on			tlbTestValidation_v6.[idfTesting] = cct.[idfTesting_v6]
left join	[Giraffe].[dbo].[_dmccTestValidation] cctv
on			cctv.[idfTesting_v6] = cct.[idfTesting_v6]
			and cctv.[idfTestValidation_v6] = tlbTestValidation_v6.[idfTestValidation]
			--and cctv.[idfLabTestId] = cct.[idfId]
			and cctv.[idfTesting_v7] = cct.[idfTesting_v7]
where		cct.[idfTesting_v7] is not null
			and cctv.[idfId] is null
print N''Copies of Test Interpretation records for HRDs v7 from Test Interpretation records of Human Cases v6.1: '' + cast(@@rowcount as nvarchar(20))
print N''''
print N''''


/************************************************************
* Generate Id records - _dmccTestValidation - start
************************************************************/
insert into	[Giraffe].[dbo].[tstNewID]
(	[idfTable],
	[idfKey1],
	[idfKey2],
	[strRowGuid]
)
select		75750000000	/*tlbTestValidation*/
			, cctv.idfId
			, cctv.idfTestValidation_v6
			, @TempIdentifierKey
from		[Giraffe].[dbo].[_dmccTestValidation] cctv
where		cctv.[idfTestValidation_v7] is null

exec [Giraffe].sys.sp_executesql N''ALTER INDEX ALL ON dbo.tstNewID REBUILD''

update		cctv
set			cctv.[idfTestValidation_v7] = nId.[NewID]
from		[Giraffe].[dbo].[_dmccTestValidation] cctv
join		[Giraffe].[dbo].[tstNewID] nId
on			nId.[idfTable] = 75750000000	/*tlbTestValidation*/
			and nId.[idfKey1] = cctv.[idfId]
			and nId.[idfKey2] = cctv.[idfTestValidation_v6]
			and nId.[strRowGuid] = @TempIdentifierKey collate Cyrillic_General_CI_AS
where		cctv.[idfTestValidation_v7] is null

/************************************************************
* Generate Id records - _dmccTestValidation - end
************************************************************/

'



select	N'
print N''Determine copies of HDR Filtration Records in HDRs v7 based on Human Case Filtration Records of Human Cases from v6.1''
print N''''

insert into [Giraffe].[dbo].[_dmccHumanCaseFiltered]
(	idfHumanCaseId,
	idfHumanCase_v6,
	idfHumanCaseFiltered_v6,
	idfSiteGroup_v6,
	idfHumanCase_v7,
	
	idfHumanCaseFiltered_v7
)
select		  cchc.[idfId]
			, cchc.[idfHumanCase_v6]
			, tflHumanCaseFiltered_v6.[idfHumanCaseFiltered]

			, tflHumanCaseFiltered_v6.[idfSiteGroup]
			, cchc.[idfHumanCase_v7]
			, case
				when	cchc.[idfHumanCase_v6] = cchc.[idfHumanCase_v7]
					then	tflHumanCaseFiltered_v6.[idfHumanCaseFiltered]
				else	null
			  end

from		[Giraffe].[dbo].[_dmccHumanCase] cchc
inner join	[Falcon].[dbo].[tflHumanCaseFiltered] tflHumanCaseFiltered_v6
on			tflHumanCaseFiltered_v6.[idfHumanCase] = cchc.[idfHumanCase_v6]
left join	[Giraffe].[dbo].[_dmccHumanCaseFiltered] cchcf
on			cchcf.[idfHumanCase_v6] = cchc.[idfHumanCase_v6]
			and cchcf.[idfHumanCaseFiltered_v6] = tflHumanCaseFiltered_v6.[idfHumanCaseFiltered]
			and cchcf.[idfHumanCase_v7] = cchc.[idfHumanCase_v7]
where		cchc.[idfHumanCase_v7] is not null
			and cchcf.[idfId] is null
print N''Copies of Filtration Records for HRDs v7 from Filtration Records of Human Cases v6.1: '' + cast(@@rowcount as nvarchar(20))
print N''''
print N''''


/************************************************************
* Generate Id records - _dmccHumanCaseFiltered - start
************************************************************/
declare @tflHCFTempIdentifierKey nvarchar(128)
set @tflHCFTempIdentifierKey = N''tflHumanCaseFiltered'' + @TempIdentifierKey collate Cyrillic_General_CI_AS
insert into	[Giraffe].[dbo].[tflNewID]
(	[strTableName],
	[idfKey1],
	[idfKey2]
)
select		@tflHCFTempIdentifierKey
			, cchcf.idfId
			, cchcf.idfHumanCaseFiltered_v6
from		[Giraffe].[dbo].[_dmccHumanCaseFiltered] cchcf
where		cchcf.[idfHumanCaseFiltered_v7] is null

exec [Giraffe].sys.sp_executesql N''ALTER INDEX ALL ON dbo.tflNewID REBUILD''

update		cchcf
set			cchcf.[idfHumanCaseFiltered_v7] = nId.[NewID]
from		[Giraffe].[dbo].[_dmccHumanCaseFiltered] cchcf
join		[Giraffe].[dbo].[tflNewID] nId
on			nId.[strTableName] = @tflHCFTempIdentifierKey collate Cyrillic_General_CI_AS
			and nId.[idfKey1] = cchcf.[idfId]
			and nId.[idfKey2] = cchcf.[idfHumanCaseFiltered_v6]
where		cchcf.[idfHumanCaseFiltered_v7] is null

/************************************************************
* Generate Id records - _dmccHumanCaseFiltered - end
************************************************************/

'



select	N'
print N''Determine copies of Addresses/Locations of HDRs v7, their Patients and/or Contact Persons based on Addresses/Locations of Human Cases, their Patients and Contact Persons from v6.1''
print N''''

insert into [Giraffe].[dbo].[_dmccGeoLocation]
(	idfGeoLocation_v6,
	idfGeoLocation_v7
)
select		  cchc.[idfPointGeoLocation_v6]
			, cchc.[idfPointGeoLocation_v7]
from		[Giraffe].[dbo].[_dmccHumanCase] cchc

left join	[Giraffe].[dbo].[_dmccGeoLocation] ccgl_idfGeoLocation_v7
on			ccgl_idfGeoLocation_v7.[idfGeoLocation_v7] = cchc.[idfPointGeoLocation_v7]

where		cchc.[idfHumanCase_v7] is not null
			and cchc.[idfPointGeoLocation_v6] is not null
			and cchc.[idfPointGeoLocation_v7] is not null
			and ccgl_idfGeoLocation_v7.[idfGeoLocation_v7] is null
print N''Copies of Location of Exposure of HRDs v7 from Location of Exposure of Human Cases v6.1: '' + cast(@@rowcount as nvarchar(20))
print N''''

insert into [Giraffe].[dbo].[_dmccGeoLocation]
(	idfGeoLocation_v6,
	idfGeoLocation_v7
)
select		  cch.[idfHumanCRAddress_v6]
			, cch.[idfHumanCRAddress_v7]
from		[Giraffe].[dbo].[_dmccHuman] cch

left join	[Giraffe].[dbo].[_dmccGeoLocation] ccgl_idfGeoLocation_v7
on			ccgl_idfGeoLocation_v7.[idfGeoLocation_v7] = cch.[idfHumanCRAddress_v7]

where		cch.[idfHuman_v7] is not null
			and cch.[idfHumanCRAddress_v6] is not null
			and cch.[idfHumanCRAddress_v7] is not null
			and ccgl_idfGeoLocation_v7.[idfGeoLocation_v7] is null
print N''Copies of Persons Current Residence Addresses v7 from Persons Current Residence Addresses v6.1: '' + cast(@@rowcount as nvarchar(20))

insert into [Giraffe].[dbo].[_dmccGeoLocation]
(	idfGeoLocation_v6,
	idfGeoLocation_v7
)
select		  cch.[idfHumanPRAddress_v6]
			, cch.[idfHumanPRAddress_v7]
from		[Giraffe].[dbo].[_dmccHuman] cch

left join	[Giraffe].[dbo].[_dmccGeoLocation] ccgl_idfGeoLocation_v7
on			ccgl_idfGeoLocation_v7.[idfGeoLocation_v7] = cch.[idfHumanPRAddress_v7]

where		cch.[idfHuman_v7] is not null
			and cch.[idfHumanPRAddress_v6] is not null
			and cch.[idfHumanPRAddress_v7] is not null
			and ccgl_idfGeoLocation_v7.[idfGeoLocation_v7] is null
print N''Copies of Persons Permanent Residence Addresses v7 from Persons Permanent Residence Addresses v6.1: '' + cast(@@rowcount as nvarchar(20))

insert into [Giraffe].[dbo].[_dmccGeoLocation]
(	idfGeoLocation_v6,
	idfGeoLocation_v7
)
select		  cch.[idfHumanEmpAddress_v6]
			, cch.[idfHumanEmpAddress_v7]
from		[Giraffe].[dbo].[_dmccHuman] cch

left join	[Giraffe].[dbo].[_dmccGeoLocation] ccgl_idfGeoLocation_v7
on			ccgl_idfGeoLocation_v7.[idfGeoLocation_v7] = cch.[idfHumanEmpAddress_v7]

where		cch.[idfHuman_v7] is not null
			and cch.[idfHumanEmpAddress_v6] is not null
			and cch.[idfHumanEmpAddress_v7] is not null
			and ccgl_idfGeoLocation_v7.[idfGeoLocation_v7] is null
print N''Copies of Persons Employer Addresses v7 from Persons Employer Addresses v6.1: '' + cast(@@rowcount as nvarchar(20))
print N''''
print N''''

'

select	N'
print N''Determine new Addresses/Locations v7 that were missing in v6.1''
print N''''

insert into [Giraffe].[dbo].[_dmccNewGeoLocation] 
(	  [idfGeoLocation_v7]
	, [idfsSite]
	, [idfsGeoLocationType]
	, [idfsCountry]
	, [blnForeignAddress]
	, [intRowStatus]
	, [SourceSystemNameID]
	, [SourceSystemKeyValue]
	, [AuditCreateUser]
	, [AuditCreateDTM]
	, [AuditUpdateUser]
	, [AuditUpdateDTM]
	, [idfsLocation]
)
select		  cchc.[idfPointGeoLocation_v7]
			, @CDRSite
			, 10036003 /*Exact Point*/
			, @idfsCountry
			, 0
			, 0
			, 10519002 /*Record Source: EIDSS6.1*/
			, N''[{'' + N''"idfGeoLocation":'' + isnull(cast(cchc.[idfPointGeoLocation_v7] as nvarchar(20)), N''null'') + N''}]'' collate Cyrillic_General_CI_AS
			, N''system''
			, GETUTCDATE()
			, N''system''
			, GETUTCDATE()
			, @idfsCountry
from		[Giraffe].[dbo].[_dmccHumanCase] cchc
left join	[Falcon].[dbo].[tlbGeoLocation] tlbGeoLocation_v6
on			tlbGeoLocation_v6.[idfGeoLocation] = cchc.[idfPointGeoLocation_v6]
left join	[Giraffe].[dbo].[_dmccNewGeoLocation] ccngl
on			ccngl.[idfGeoLocation_v7] = cchc.[idfPointGeoLocation_v7]
where		cchc.[idfPointGeoLocation_v7] is not null
			and tlbGeoLocation_v6.[idfGeoLocation] is null 
			and ccngl.[idfGeoLocation_v7] is null
print N''New locations of exposure of HDRs v7 missing in matching Human Cases from v6.1: '' + cast(@@rowcount as nvarchar(20))
print N''''


insert into [Giraffe].[dbo].[_dmccNewGeoLocation] 
(	  [idfGeoLocation_v7]
	, [idfsSite]
	, [idfsGeoLocationType]
	, [idfsCountry]
	, [blnForeignAddress]
	, [intRowStatus]
	, [SourceSystemNameID]
	, [SourceSystemKeyValue]
	, [AuditCreateUser]
	, [AuditCreateDTM]
	, [AuditUpdateUser]
	, [AuditUpdateDTM]
	, [idfsLocation]
)
select		  cch.[idfHumanCRAddress_v7]
			, @CDRSite
			, 10036001 /*Address*/
			, @idfsCountry
			, 0
			, 0
			, 10519002 /*Record Source: EIDSS6.1*/
			, N''[{'' + N''"idfGeoLocation":'' + isnull(cast(cch.[idfHumanCRAddress_v7] as nvarchar(20)), N''null'') + N''}]'' collate Cyrillic_General_CI_AS
			, N''system''
			, GETUTCDATE()
			, N''system''
			, GETUTCDATE()
			, @idfsCountry
from		[Giraffe].[dbo].[_dmccHuman] cch
left join	[Falcon].[dbo].[tlbGeoLocation] tlbGeoLocation_v6
on			tlbGeoLocation_v6.[idfGeoLocation] = cch.[idfHumanCRAddress_v6]
left join	[Giraffe].[dbo].[_dmccNewGeoLocation] ccngl
on			ccngl.[idfGeoLocation_v7] = cch.[idfHumanCRAddress_v7]
where		cch.[idfHumanCRAddress_v7] is not null
			and tlbGeoLocation_v6.[idfGeoLocation] is null 
			and ccngl.[idfGeoLocation_v7] is null
print N''New current residence addresses of persons in v7 missing in matching persons from v6.1: '' + cast(@@rowcount as nvarchar(20))


insert into [Giraffe].[dbo].[_dmccNewGeoLocation] 
(	  [idfGeoLocation_v7]
	, [idfsSite]
	, [idfsGeoLocationType]
	, [idfsCountry]
	, [blnForeignAddress]
	, [intRowStatus]
	, [SourceSystemNameID]
	, [SourceSystemKeyValue]
	, [AuditCreateUser]
	, [AuditCreateDTM]
	, [AuditUpdateUser]
	, [AuditUpdateDTM]
	, [idfsLocation]
)
select		  cch.[idfHumanPRAddress_v7]
			, @CDRSite
			, 10036001 /*Address*/
			, @idfsCountry
			, 0
			, 0
			, 10519002 /*Record Source: EIDSS6.1*/
			, N''[{'' + N''"idfGeoLocation":'' + isnull(cast(cch.[idfHumanPRAddress_v7] as nvarchar(20)), N''null'') + N''}]'' collate Cyrillic_General_CI_AS
			, N''system''
			, GETUTCDATE()
			, N''system''
			, GETUTCDATE()
			, @idfsCountry
from		[Giraffe].[dbo].[_dmccHuman] cch
left join	[Falcon].[dbo].[tlbGeoLocation] tlbGeoLocation_v6
on			tlbGeoLocation_v6.[idfGeoLocation] = cch.[idfHumanPRAddress_v6]
left join	[Giraffe].[dbo].[_dmccNewGeoLocation] ccngl
on			ccngl.[idfGeoLocation_v7] = cch.[idfHumanPRAddress_v7]
where		cch.[idfHumanPRAddress_v7] is not null
			and tlbGeoLocation_v6.[idfGeoLocation] is null 
			and ccngl.[idfGeoLocation_v7] is null
print N''New permanent residence addresses of persons in v7 missing in matching persons from v6.1: '' + cast(@@rowcount as nvarchar(20))
'

select	N'


insert into [Giraffe].[dbo].[_dmccNewGeoLocation] 
(	  [idfGeoLocation_v7]
	, [idfsSite]
	, [idfsGeoLocationType]
	, [idfsCountry]
	, [blnForeignAddress]
	, [intRowStatus]
	, [SourceSystemNameID]
	, [SourceSystemKeyValue]
	, [AuditCreateUser]
	, [AuditCreateDTM]
	, [AuditUpdateUser]
	, [AuditUpdateDTM]
	, [idfsLocation]
)
select		  cch.[idfHumanEmpAddress_v7]
			, @CDRSite
			, 10036001 /*Address*/
			, @idfsCountry
			, 0
			, 0
			, 10519002 /*Record Source: EIDSS6.1*/
			, N''[{'' + N''"idfGeoLocation":'' + isnull(cast(cch.[idfHumanEmpAddress_v7] as nvarchar(20)), N''null'') + N''}]'' collate Cyrillic_General_CI_AS
			, N''system''
			, GETUTCDATE()
			, N''system''
			, GETUTCDATE()
			, @idfsCountry
from		[Giraffe].[dbo].[_dmccHuman] cch
left join	[Falcon].[dbo].[tlbGeoLocation] tlbGeoLocation_v6
on			tlbGeoLocation_v6.[idfGeoLocation] = cch.[idfHumanEmpAddress_v6]
left join	[Giraffe].[dbo].[_dmccNewGeoLocation] ccngl
on			ccngl.[idfGeoLocation_v7] = cch.[idfHumanEmpAddress_v7]
where		cch.[idfHumanEmpAddress_v7] is not null
			and tlbGeoLocation_v6.[idfGeoLocation] is null 
			and ccngl.[idfGeoLocation_v7] is null
print N''New employer addresses of persons in v7 missing in matching persons from v6.1: '' + cast(@@rowcount as nvarchar(20))


insert into [Giraffe].[dbo].[_dmccNewGeoLocation] 
(	  [idfGeoLocation_v7]
	, [idfsSite]
	, [idfsGeoLocationType]
	, [idfsCountry]
	, [blnForeignAddress]
	, [intRowStatus]
	, [SourceSystemNameID]
	, [SourceSystemKeyValue]
	, [AuditCreateUser]
	, [AuditCreateDTM]
	, [AuditUpdateUser]
	, [AuditUpdateDTM]
	, [idfsLocation]
)
select		  cch.[idfHumanAltAddress_v7]
			, @CDRSite
			, 10036001 /*Address*/
			, @idfsCountry
			, 0
			, 0
			, 10519002 /*Record Source: EIDSS6.1*/
			, N''[{'' + N''"idfGeoLocation":'' + isnull(cast(cch.[idfHumanAltAddress_v7] as nvarchar(20)), N''null'') + N''}]'' collate Cyrillic_General_CI_AS
			, N''system''
			, GETUTCDATE()
			, N''system''
			, GETUTCDATE()
			, @idfsCountry
from		[Giraffe].[dbo].[_dmccHuman] cch
left join	[Giraffe].[dbo].[_dmccNewGeoLocation] ccngl
on			ccngl.[idfGeoLocation_v7] = cch.[idfHumanAltAddress_v7]
where		cch.[idfHumanAltAddress_v7] is not null
			and ccngl.[idfGeoLocation_v7] is null
print N''New alternative addresses of persons in v7 missing in matching persons from v6.1: '' + cast(@@rowcount as nvarchar(20))


insert into [Giraffe].[dbo].[_dmccNewGeoLocation] 
(	  [idfGeoLocation_v7]
	, [idfsSite]
	, [idfsGeoLocationType]
	, [idfsCountry]
	, [blnForeignAddress]
	, [intRowStatus]
	, [SourceSystemNameID]
	, [SourceSystemKeyValue]
	, [AuditCreateUser]
	, [AuditCreateDTM]
	, [AuditUpdateUser]
	, [AuditUpdateDTM]
	, [idfsLocation]
)
select		  cch.[idfHumanSchAddress_v7]
			, @CDRSite
			, 10036001 /*Address*/
			, @idfsCountry
			, 0
			, 0
			, 10519002 /*Record Source: EIDSS6.1*/
			, N''[{'' + N''"idfGeoLocation":'' + isnull(cast(cch.[idfHumanSchAddress_v7] as nvarchar(20)), N''null'') + N''}]'' collate Cyrillic_General_CI_AS
			, N''system''
			, GETUTCDATE()
			, N''system''
			, GETUTCDATE()
			, @idfsCountry
from		[Giraffe].[dbo].[_dmccHuman] cch
left join	[Giraffe].[dbo].[_dmccNewGeoLocation] ccngl
on			ccngl.[idfGeoLocation_v7] = cch.[idfHumanSchAddress_v7]
where		cch.[idfHumanSchAddress_v7] is not null
			and ccngl.[idfGeoLocation_v7] is null
print N''New school addresses of persons in v7 missing in matching persons from v6.1: '' + cast(@@rowcount as nvarchar(20))
print N''''
print N''''


delete		ccgl
from		[Giraffe].[dbo].[_dmccGeoLocation] ccgl
left join	[Falcon].[dbo].[tlbGeoLocation] tlbGeoLocation_v6
on			tlbGeoLocation_v6.[idfGeoLocation] = ccgl.[idfGeoLocation_v6]
where		tlbGeoLocation_v6.[idfGeoLocation] is null

'



select	N'
print N''Determine copies of FF Instances of HDRs v7 (CS, EPI) and their Lab Tests based on FF Instances of Human Cases and their Lab Tests from v6.1''
print N''''

insert into [Giraffe].[dbo].[_dmccObservation]
(	idfObservation_v6,
	idfsTemplate_v6,
	idfObservation_v7,
	idfsTemplate_v7
)
select		  cchc.[idfCSObservation_v6]
			, cchc.[idfsCSTemplate_v6]
			, cchc.[idfCSObservation_v7]
			, cchc.[idfsCSTemplate_v7]
from		[Giraffe].[dbo].[_dmccHumanCase] cchc

left join	[Giraffe].[dbo].[_dmccObservation] ccobs_idfObservation_v7
on			ccobs_idfObservation_v7.[idfObservation_v7] = cchc.[idfCSObservation_v7]

where		cchc.[idfHumanCase_v7] is not null
			and cchc.[idfCSObservation_v6] is not null
			and cchc.[idfCSObservation_v7] is not null
			and ccobs_idfObservation_v7.[idfObservation_v7] is null
print N''Copies of CS FF Instances of HRDs v7 from CS FF Instances of Human Cases v6.1: '' + cast(@@rowcount as nvarchar(20))

insert into [Giraffe].[dbo].[_dmccObservation]
(	idfObservation_v6,
	idfsTemplate_v6,
	idfObservation_v7,
	idfsTemplate_v7
)
select		  cchc.[idfEpiObservation_v6]
			, cchc.[idfsEpiTemplate_v6]
			, cchc.[idfEpiObservation_v7]
			, cchc.[idfsEpiTemplate_v7]
from		[Giraffe].[dbo].[_dmccHumanCase] cchc

left join	[Giraffe].[dbo].[_dmccObservation] ccobs_idfObservation_v7
on			ccobs_idfObservation_v7.[idfObservation_v7] = cchc.[idfEpiObservation_v7]

where		cchc.[idfHumanCase_v7] is not null
			and cchc.[idfEpiObservation_v6] is not null
			and cchc.[idfEpiObservation_v7] is not null
			and ccobs_idfObservation_v7.[idfObservation_v7] is null
print N''Copies of EPI FF Instances of HRDs v7 from CS EPI Instances of Human Cases v6.1: '' + cast(@@rowcount as nvarchar(20))
print N''''

insert into [Giraffe].[dbo].[_dmccObservation]
(	idfObservation_v6,
	idfsTemplate_v6,
	idfObservation_v7,
	idfsTemplate_v7
)
select		  cct.[idfObservation_v6]
			, cct.[idfsTemplate_v6]
			, cct.[idfObservation_v7]
			, cct.[idfsTemplate_v7]
from		[Giraffe].[dbo].[_dmccLabTest] cct

left join	[Giraffe].[dbo].[_dmccObservation] ccobs_idfObservation_v7
on			ccobs_idfObservation_v7.[idfObservation_v7] = cct.[idfObservation_v7]

where		cct.[idfTesting_v7] is not null
			and cct.[idfObservation_v6] is not null
			and cct.[idfObservation_v7] is not null
			and ccobs_idfObservation_v7.[idfObservation_v7] is null
print N''Copies of FF Instances of Lab Tests v7 from FF Instances of Lab Tests v7 v6.1: '' + cast(@@rowcount as nvarchar(20))
print N''''
print N''''

'



select	N'
print N''Determine new FF Instances v7 that were missing in v6.1''
print N''''

insert into [Giraffe].[dbo].[_dmccNewObservation] 
(	  [idfObservation_v7]
	, [idfsSite]
	, [idfsFormTemplate]
	, [intRowStatus]
	, [SourceSystemNameID]
	, [SourceSystemKeyValue]
	, [AuditCreateUser]
	, [AuditCreateDTM]
	, [AuditUpdateUser]
	, [AuditUpdateDTM]
)
select		  cchc.[idfCSObservation_v7]
			, @CDRSite
			, cchc.[idfsCSTemplate_v7]
			, 0
			, 10519002 /*Record Source: EIDSS6.1*/
			, N''[{'' + N''"idfObservation":'' + isnull(cast(cchc.[idfCSObservation_v7] as nvarchar(20)), N''null'') + N''}]'' collate Cyrillic_General_CI_AS
			, N''system''
			, GETUTCDATE()
			, N''system''
			, GETUTCDATE()
from		[Giraffe].[dbo].[_dmccHumanCase] cchc
left join	[Falcon].[dbo].[tlbObservation] tlbObservation_v6
on			tlbObservation_v6.[idfObservation] = cchc.[idfCSObservation_v6]
left join	[Giraffe].[dbo].[_dmccNewObservation] ccnobs
on			ccnobs.[idfObservation_v7] = cchc.[idfCSObservation_v7]
where		cchc.[idfCSObservation_v7] is not null
			and tlbObservation_v6.[idfObservation] is null 
			and ccnobs.[idfObservation_v7] is null
print N''New CS FF Template Instances of HDRs v7 missing in matching Human Cases from v6.1: '' + cast(@@rowcount as nvarchar(20))

insert into [Giraffe].[dbo].[_dmccNewObservation] 
(	  [idfObservation_v7]
	, [idfsSite]
	, [idfsFormTemplate]
	, [intRowStatus]
	, [SourceSystemNameID]
	, [SourceSystemKeyValue]
	, [AuditCreateUser]
	, [AuditCreateDTM]
	, [AuditUpdateUser]
	, [AuditUpdateDTM]
)
select		  cchc.[idfEpiObservation_v7]
			, @CDRSite
			, cchc.[idfsEpiTemplate_v7]
			, 0
			, 10519002 /*Record Source: EIDSS6.1*/
			, N''[{'' + N''"idfObservation":'' + isnull(cast(cchc.[idfCSObservation_v7] as nvarchar(20)), N''null'') + N''}]'' collate Cyrillic_General_CI_AS
			, N''system''
			, GETUTCDATE()
			, N''system''
			, GETUTCDATE()
from		[Giraffe].[dbo].[_dmccHumanCase] cchc
left join	[Falcon].[dbo].[tlbObservation] tlbObservation_v6
on			tlbObservation_v6.[idfObservation] = cchc.[idfEpiObservation_v6]
left join	[Giraffe].[dbo].[_dmccNewObservation] ccnobs
on			ccnobs.[idfObservation_v7] = cchc.[idfEpiObservation_v7]
where		cchc.[idfEpiObservation_v7] is not null
			and tlbObservation_v6.[idfObservation] is null 
			and ccnobs.[idfObservation_v7] is null
print N''New EPI FF Template Instances of HDRs v7 missing in matching Human Cases from v6.1: '' + cast(@@rowcount as nvarchar(20))
print N''''

insert into [Giraffe].[dbo].[_dmccNewObservation] 
(	  [idfObservation_v7]
	, [idfsSite]
	, [idfsFormTemplate]
	, [intRowStatus]
	, [SourceSystemNameID]
	, [SourceSystemKeyValue]
	, [AuditCreateUser]
	, [AuditCreateDTM]
	, [AuditUpdateUser]
	, [AuditUpdateDTM]
)
select		  cct.[idfObservation_v7]
			, @CDRSite
			, cct.[idfsTemplate_v7]
			, 0
			, 10519002 /*Record Source: EIDSS6.1*/
			, N''[{'' + N''"idfObservation":'' + isnull(cast(cct.[idfObservation_v7] as nvarchar(20)), N''null'') + N''}]'' collate Cyrillic_General_CI_AS
			, N''system''
			, GETUTCDATE()
			, N''system''
			, GETUTCDATE()
from		[Giraffe].[dbo].[_dmccLabTest] cct
left join	[Falcon].[dbo].[tlbObservation] tlbObservation_v6
on			tlbObservation_v6.[idfObservation] = cct.[idfObservation_v6]
left join	[Giraffe].[dbo].[_dmccNewObservation] ccnobs
on			ccnobs.[idfObservation_v7] = cct.[idfObservation_v7]
where		cct.[idfObservation_v7] is not null
			and tlbObservation_v6.[idfObservation] is null 
			and ccnobs.[idfObservation_v7] is null
print N''New FF Template Instances of Lab Tests v7 missing in matching Lab Tests from v6.1: '' + cast(@@rowcount as nvarchar(20))
print N''''
print N''''


delete		ccobs
from		[Giraffe].[dbo].[_dmccObservation] ccobs
left join	[Falcon].[dbo].[tlbObservation] tlbObservation_v6
on			tlbObservation_v6.[idfObservation] = ccobs.[idfObservation_v6]
where		tlbObservation_v6.[idfObservation] is null

'




select	N'
print N''Determine copies of FF Values of HDRs v7 and their Lab Tests v7 based on FF Values of Human Cases and their Lab Tests from v6.1''
print N''''

insert into [Giraffe].[dbo].[_dmccActivityParameters]
(	idfObservation_v6,
	idfActivityParameters_v6,
	idfsParameter_v6,
	idfRow_v6,
	varValue,
	intRowStatus,
	idfObservation_v7,
	
	idfActivityParameters_v7
)
select		  ccobs.[idfObservation_v6]
			, tlbActivityParameters_v6.[idfActivityParameters]
			, tlbActivityParameters_v6.[idfsParameter]
			, tlbActivityParameters_v6.[idfRow]
			, tlbActivityParameters_v6.[varValue]
			, tlbActivityParameters_v6.[intRowStatus]
			, ccobs.[idfObservation_v7]
			, case
				when	ccobs.[idfObservation_v6] = ccobs.[idfObservation_v7]
					then	tlbActivityParameters_v6.[idfActivityParameters]
				else	null
			  end
from		[Giraffe].[dbo].[_dmccObservation] ccobs
inner join	[Falcon].[dbo].[tlbActivityParameters] tlbActivityParameters_v6
on			tlbActivityParameters_v6.[idfObservation] = ccobs.[idfObservation_v6]
left join	[Giraffe].[dbo].[_dmccActivityParameters] ccap
on			ccap.[idfObservation_v6] = ccobs.[idfObservation_v6]
			and ccap.[idfActivityParameters_v6] = tlbActivityParameters_v6.[idfActivityParameters]
			and ccap.[idfObservation_v7] = ccobs.[idfObservation_v7]
where		ccobs.[idfObservation_v7] is not null
			and ccap.[idfId] is null
print N''Copies of FF Values of HDRs v7 and their Lab Tests v7 from FF Values of Human Cases and their Lab Tests v6.1: '' + cast(@@rowcount as nvarchar(20))
print N''''
print N''''


/************************************************************
* Generate Id records - _dmccActivityParameters - start
************************************************************/
insert into	[Giraffe].[dbo].[tstNewID]
(	[idfTable],
	[idfKey1],
	[idfKey2],
	[strRowGuid]
)
select		75410000000	/*tlbActivityParameters*/
			, ccap.idfId
			, ccap.idfActivityParameters_v6
			, @TempIdentifierKey
from		[Giraffe].[dbo].[_dmccActivityParameters] ccap
where		ccap.[idfActivityParameters_v7] is null

exec [Giraffe].sys.sp_executesql N''ALTER INDEX ALL ON dbo.tstNewID REBUILD''

update		ccap
set			ccap.[idfActivityParameters_v7] = nId.[NewID]
from		[Giraffe].[dbo].[_dmccActivityParameters] ccap
join		[Giraffe].[dbo].[tstNewID] nId
on			nId.[idfTable] = 75410000000	/*tlbActivityParameters*/
			and nId.[idfKey1] = ccap.[idfId]
			and nId.[idfKey2] = ccap.[idfActivityParameters_v6]
			and nId.[strRowGuid] = @TempIdentifierKey collate Cyrillic_General_CI_AS
where		ccap.[idfActivityParameters_v7] is null

/************************************************************
* Generate Id records - _dmccActivityParameters - end
************************************************************/

'



select	N'

/*

--TODO: remove select script
select *
from	[Giraffe].[dbo]._dmccHumanCase cchc
order by	cchc.[idfHumanCase_v6], cchc.[datDiagnosisDate], cchc.idfId

select *
from	[Giraffe].[dbo]._dmccContactedCasePerson ccccp

select *
from [Giraffe].[dbo]._dmccAntimicrobialTherapy


-- TODO: add all remaning records related to farm owners to generate additional addresses
select *
from [Giraffe].[dbo]._dmccHuman


select *
from [Giraffe].[dbo]._dmccMaterial


select *
from [Giraffe].[dbo]._dmccLabTest



select *
from [Giraffe].[dbo]._dmccTestValidation


select *
from [Giraffe].[dbo]._dmccHumanCaseFiltered



select *
from [Giraffe].[dbo]._dmccGeoLocation

select *
from [Giraffe].[dbo]._dmccObservation

select *
from [Giraffe].[dbo]._dmccActivityParameters

*/

/************************************************************
* Fill in concordance tables for HDR and VDR data - end
************************************************************/
'




select	N'
/************************************************************
* Insert records - Tables with records related to data modules - start
************************************************************/
print N''''
print N''Insert records - Tables with records related to data modules - start''
print N''''
'

select	N'
/************************************************************
* Prepare data before insert - [' + [table_name] + N']
************************************************************/
' + strStatementBeforeInsert collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert2 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert3 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert4 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert5 collate Cyrillic_General_CI_AS, N'
' + strStatementBeforeInsert6 collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @DataModuleTableIdFirst and @DataModuleTableIdLast
		and len(strStatementBeforeInsert) > 0 
order by idfId


select	N'
/************************************************************
* Insert records - [' + [table_name] + N']
************************************************************/
' + strInsertHeader + N'
' + strInsertColumns + N'
' + strSelectColumns + N'
' + strInsertFromHeader + N'
' + strInsertFromJoins + N'
' + strInsertWhereHeader + strInsertWhereConditions + N'
' + strInsertPrint + N'
' collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @DataModuleTableIdFirst and @DataModuleTableIdLast
order by idfId


select	N'
/************************************************************
* Update/insert records with links to foreign key data - [' + [table_name] + N']
************************************************************/
' + strUpdateAfterInsert collate Cyrillic_General_CI_AS, N'
' + strUpdateAfterInsert2 collate Cyrillic_General_CI_AS
from	#TablesToMigrate
where	idfId between @DataModuleTableIdFirst and @DataModuleTableIdLast
		and len(strUpdateAfterInsert) > 0 
order by idfId


select	N'
print N''''
print N''Insert records - Tables with records related to data modules - end''
print N''''
print N''''
/************************************************************
* Insert records - Tables with records related to data modules - end
************************************************************/




'



select	N'

/************************************************************
* Reset identifier seed value - start
************************************************************/

--declare	@sqlIdResetCmd				nvarchar(max)
set	@sqlIdResetCmd = N''''

set	@sqlIdResetCmd = N''

declare @TempIdentifierSeedValue bigint = '' + cast(@CDRSite as nvarchar(20)) + N''

declare	@max_value			bigint
set	@max_value = @TempIdentifierSeedValue

declare	@seed_value			bigint
set	@seed_value = null
declare	@increment_value	bigint
set	@increment_value = null

declare	@sqlCmd				nvarchar(max)
set	@sqlCmd = N''''''''

'' collate Cyrillic_General_CI_AS

select	@sqlIdResetCmd = @sqlIdResetCmd + N''
	-- dbo.'' + t.[name] + N'': '' + c_ic.[name] + N''
	if	exists	(
			select	1 
			from	[Falcon].[sys].[tables] t
			inner join	[Falcon].sys.objects o_t
			on			o_t.[object_id] = t.[object_id]
						and o_t.[type] = N''''U'''' collate Cyrillic_General_CI_AS
			inner join	[Falcon].sys.schemas s
			on			s.[schema_id] = t.[schema_id]
						and s.[name] = N''''dbo'''' collate Cyrillic_General_CI_AS			
			where		t.[name] = N'''''' + t.[name] + N'''''' collate Cyrillic_General_CI_AS
				)
	begin
		if	exists	(
				select	1
				from	[Falcon].[dbo].['' + t.[name] + N'']
				where	['' + c_ic.[name] + N''] >= @max_value
						and (['' + c_ic.[name] + ''] - @TempIdentifierSeedValue) % 10000000 = 0
					)
		begin
			select		@max_value = max('' + c_ic.[name] + N'') + 10000000
			from		[Falcon].[dbo].['' + t.[name] + N'']
			where		(['' + c_ic.[name] + ''] - @TempIdentifierSeedValue) % 10000000 = 0
		end
	end
''
from
-- Table
			[Falcon].sys.tables t
inner join	[Falcon].sys.objects o_t
on			o_t.[object_id] = t.[object_id]
			and o_t.[type] = N''U'' collate Cyrillic_General_CI_AS
			and o_t.[name] not like N''gis%'' collate Cyrillic_General_CI_AS
			and o_t.[name] not like N''tfl%'' collate Cyrillic_General_CI_AS
			and o_t.[name] not like N''Lkup%'' collate Cyrillic_General_CI_AS

inner join	[Falcon].sys.schemas s
on			s.[schema_id] = t.[schema_id]
			and s.[name] = N''dbo'' collate Cyrillic_General_CI_AS

-- PK
inner join	[Falcon].sys.indexes i
on			i.[object_id] = t.[object_id]
			and i.is_primary_key = 1

-- PK column
inner join	[Falcon].sys.index_columns ic
on			ic.[object_id] = i.[object_id]
			and ic.[index_id] = i.[index_id]
inner join	[Falcon].sys.columns c_ic
on			c_ic.[object_id] = ic.[object_id]
			and c_ic.[column_id] = ic.[column_id]
			and c_ic.[name] <> N''idfsLanguage''
			and c_ic.[system_type_id] in (127, 56)
where		not exists	(
					select	1
					from		[Falcon].sys.index_columns ic_second
					inner join	[Falcon].sys.columns c_ic_second
					on			c_ic_second.[object_id] = ic_second.[object_id]
								and c_ic_second.[column_id] = ic_second.[column_id]
								and c_ic_second.[name] <> N''idfsLanguage''
								and c_ic_second.[system_type_id]  in (127, 56)
								and	c_ic_second.[column_id] <> c_ic.[column_id]
					where		ic_second.[object_id] = i.[object_id]
								and ic_second.[index_id] = i.[index_id]
						)

'

select	N'
set	@sqlIdResetCmd = @sqlIdResetCmd + N''
-- Update initial ID in the table tstNewID

select		@seed_value = cast(seed_value as bigint),
			@increment_value = cast(increment_value as bigint)
from		[Giraffe].sys.identity_columns NewIDcol
inner join	[Giraffe].sys.columns col
on			col.[object_id] = NewIDcol.[object_id]
			and col.[column_id] = NewIDcol.[column_id]
			and col.[name] = NewIDcol.[name]
			and col.is_identity = 1
inner join	[Giraffe].dbo.sysobjects NewIDtable
on			NewIDtable.[id] = NewIDcol.[object_id]
where		NewIDtable.[id] = object_id(N''''[dbo].[tstNewID]'''') 
			and OBJECTPROPERTY(NewIDtable.[id], N''''IsUserTable'''') = 1
			and NewIDcol.[name] = N''''NewID''''

if	(@seed_value is null) or (@increment_value is null)
	or (@seed_value is not null and (@seed_value < @max_value) and ((isnull(@seed_value, 0) - @max_value) % 10000000 = 0))
	or (@seed_value is not null and ((isnull(@seed_value, 0) - @max_value) % 10000000 <> 0))
--			or (@increment_value <> 10000000)
begin
	set @sqlCmd = N''''
if	exists	(
select	1 
from	[Giraffe].[dbo].sysobjects 
where	id = object_id(N''''''''[dbo].[tstNewID]'''''''') 
		and OBJECTPROPERTY(id, N''''''''IsUserTable'''''''') = 1
	)
drop table [dbo].[tstNewID]

''''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''''
create table	[dbo].[tstNewID]
(	NewID		bigint IDENTITY('''' + cast(@max_value as nvarchar(20)) + N'''', 10000000) not null,
	idfTable	bigint null,
	idfKey1		bigint null,
	idfKey2		bigint null,
	strRowGuid	nvarchar(36) collate Cyrillic_General_CI_AS null,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[SourceSystemNameID] [bigint] NULL,
	[SourceSystemKeyValue] [nvarchar](max) NULL,
	[AuditCreateUser] [nvarchar](200) NULL,
	[AuditCreateDTM] [datetime] NULL,
	[AuditUpdateUser] [nvarchar](200) NULL,
	[AuditUpdateDTM] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
''''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''''
ALTER TABLE [dbo].[tstNewID] ADD  CONSTRAINT [DF_tstNewID_rowguid]  DEFAULT (newsequentialid()) FOR [rowguid]
''''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''''
ALTER TABLE [dbo].[tstNewID] ADD  CONSTRAINT [DF_tstNewID_CreateDTM]  DEFAULT (getdate()) FOR [AuditCreateDTM]
''''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''''
ALTER TABLE [dbo].[tstNewID]  WITH CHECK ADD  CONSTRAINT [FK_tstNewID_trtBaseReference_SourceSystemNameID] FOREIGN KEY([SourceSystemNameID])
REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
''''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''''
ALTER TABLE [dbo].[tstNewID] CHECK CONSTRAINT [FK_tstNewID_trtBaseReference_SourceSystemNameID]
''''
	execute sp_executesql @sqlCmd

	print	''''New consequent ID value in the table tstNewID: '''' + cast(@max_value as varchar(30))
end
else 
	print ''''Update of consequent ID value in the table tstNewID is not needed: '''' + cast(@seed_value as varchar(30))
''
exec [Giraffe].[sys].sp_executesql @sqlIdResetCmd
'

select	N'


set	@sqlIdResetCmd = N''

declare @TempIdentifierSeedValue bigint = '' + cast(@CDRSite as nvarchar(20)) + N''

declare	@max_value			bigint
set	@max_value = @TempIdentifierSeedValue

declare	@seed_value			bigint
set	@seed_value = null
declare	@increment_value	bigint
set	@increment_value = null

declare	@sqlCmd				nvarchar(max)
set	@sqlCmd = N''''''''

'' collate Cyrillic_General_CI_AS


select	@sqlIdResetCmd = @sqlIdResetCmd + N''
	-- dbo.'' + t.[name] + N'': '' + c_ic.[name] + N''
	if	exists	(
			select	1 
			from	[Falcon].[sys].[tables] t
			inner join	[Falcon].sys.objects o_t
			on			o_t.[object_id] = t.[object_id]
						and o_t.[type] = N''''U'''' collate Cyrillic_General_CI_AS
			inner join	[Falcon].sys.schemas s
			on			s.[schema_id] = t.[schema_id]
						and s.[name] = N''''dbo'''' collate Cyrillic_General_CI_AS			
			where		t.[name] = N'''''' + t.[name] + N'''''' collate Cyrillic_General_CI_AS
				)
	begin
		if	exists	(
				select	1
				from	[Falcon].[dbo].['' + t.[name] + N'']
				where	['' + c_ic.[name] + N''] >= @max_value
						and (['' + c_ic.[name] + ''] - @TempIdentifierSeedValue) % 10000000 = 0
					)
		begin
			select		@max_value = max('' + c_ic.[name] + N'') + 10000000
			from		[Falcon].[dbo].['' + t.[name] + N'']
			where		(['' + c_ic.[name] + ''] - @TempIdentifierSeedValue) % 10000000 = 0
		end
	end
''
from
-- Table
			[Falcon].sys.tables t
inner join	[Falcon].sys.objects o_t
on			o_t.[object_id] = t.[object_id]
			and o_t.[type] = N''U'' collate Cyrillic_General_CI_AS
			and o_t.[name] like N''tfl%'' collate Cyrillic_General_CI_AS

inner join	[Falcon].sys.schemas s
on			s.[schema_id] = t.[schema_id]
			and s.[name] = N''dbo'' collate Cyrillic_General_CI_AS

-- PK
inner join	[Falcon].sys.indexes i
on			i.[object_id] = t.[object_id]
			and i.is_primary_key = 1

-- PK column
inner join	[Falcon].sys.index_columns ic
on			ic.[object_id] = i.[object_id]
			and ic.[index_id] = i.[index_id]
inner join	[Falcon].sys.columns c_ic
on			c_ic.[object_id] = ic.[object_id]
			and c_ic.[column_id] = ic.[column_id]
			and c_ic.[name] <> N''idfsSite''
			and c_ic.[system_type_id] in (127, 56)
where		not exists	(
					select	1
					from		[Falcon].sys.index_columns ic_second
					inner join	[Falcon].sys.columns c_ic_second
					on			c_ic_second.[object_id] = ic_second.[object_id]
								and c_ic_second.[column_id] = ic_second.[column_id]
								and c_ic_second.[name] <> N''idfsLanguage''
								and c_ic_second.[system_type_id]  in (127, 56)
								and	c_ic_second.[column_id] <> c_ic.[column_id]
					where		ic_second.[object_id] = i.[object_id]
								and ic_second.[index_id] = i.[index_id]
						)

'

select	N'
set	@sqlIdResetCmd = @sqlIdResetCmd + N''
-- Update initial ID in the table tflNewID

select		@seed_value = cast(seed_value as bigint),
			@increment_value = cast(increment_value as bigint)
from		[Giraffe].sys.identity_columns NewIDcol
inner join	[Giraffe].sys.columns col
on			col.[object_id] = NewIDcol.[object_id]
			and col.[column_id] = NewIDcol.[column_id]
			and col.[name] = NewIDcol.[name]
			and col.is_identity = 1
inner join	[Giraffe].dbo.sysobjects NewIDtable
on			NewIDtable.[id] = NewIDcol.[object_id]
where		NewIDtable.[id] = object_id(N''''[dbo].[tflNewID]'''') 
			and OBJECTPROPERTY(NewIDtable.[id], N''''IsUserTable'''') = 1
			and NewIDcol.[name] = N''''NewID''''

if	(@seed_value is null) or (@increment_value is null)
	or (@seed_value is not null and (@seed_value < @max_value) and ((isnull(@seed_value, 0) - @max_value) % 10000000 = 0))
	or (@seed_value is not null and ((isnull(@seed_value, 0) - @max_value) % 10000000 <> 0))
--			or (@increment_value <> 10000000)
begin
	set @sqlCmd = N''''
if	exists	(
select	1 
from	[Giraffe].[dbo].sysobjects 
where	id = object_id(N''''''''[dbo].[tflNewID]'''''''') 
		and OBJECTPROPERTY(id, N''''''''IsUserTable'''''''') = 1
	)
drop table [dbo].[tflNewID]

''''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''''
create table	[dbo].[tflNewID]
(	NewID			bigint IDENTITY('''' + cast(@max_value as nvarchar(20)) + N'''', 10000000) not null,
	strTableName	sysname null,
	idfKey1			bigint null,
	idfKey2			bigint null,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[SourceSystemNameID] [bigint] NULL,
	[SourceSystemKeyValue] [nvarchar](max) NULL,
	[AuditCreateUser] [nvarchar](200) NULL,
	[AuditCreateDTM] [datetime] NULL,
	[AuditUpdateUser] [nvarchar](200) NULL,
	[AuditUpdateDTM] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
''''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''''
ALTER TABLE [dbo].[tflNewID] ADD  CONSTRAINT [DF_tflNewID_rowguid]  DEFAULT (newsequentialid()) FOR [rowguid]
''''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''''
ALTER TABLE [dbo].[tflNewID] ADD  CONSTRAINT [DEF_tflNewID_SourceSystemNameID]  DEFAULT ((10519001)) FOR [SourceSystemNameID]
''''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''''
ALTER TABLE [dbo].[tflNewID] ADD  CONSTRAINT [DF_tflNewID_CreateDTM]  DEFAULT (getdate()) FOR [AuditCreateDTM]
''''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''''
ALTER TABLE [dbo].[tflNewID]  WITH CHECK ADD  CONSTRAINT [FK_tflNewID_trtBaseReference_SourceSystemNameID] FOREIGN KEY([SourceSystemNameID])
REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
''''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''''
ALTER TABLE [dbo].[tflNewID] CHECK CONSTRAINT [FK_tflNewID_trtBaseReference_SourceSystemNameID]
''''
	execute sp_executesql @sqlCmd

	print	''''New consequent ID value in the table tflNewID: '''' + cast(@max_value as varchar(30))
end
else 
	print ''''Update of consequent ID value in the table tflNewID is not needed: '''' + cast(@seed_value as varchar(30))
''
execute [Giraffe].[dbo].sp_executesql @sqlIdResetCmd
/************************************************************
* Reset identifier seed value - end
************************************************************/
'

end


--TODO: where for update?
--TODO: take care of tables with different PKs if any (at least show notification)


select	N'


END TRY
BEGIN CATCH
    set @Error = ERROR_NUMBER()
	set	@ErrorMsg = /*N''ErrorNumber: '' + CONVERT(NVARCHAR, ERROR_NUMBER()) 
		+*/ N'' ErrorSeverity: '' + CONVERT(NVARCHAR, ERROR_SEVERITY())
		+ N'' ErrorState: '' + CONVERT(NVARCHAR, ERROR_STATE())
		+ N'' ErrorProcedure: '' + ISNULL(ERROR_PROCEDURE(), N'''')
		+ N'' ErrorLine: '' +  CONVERT(NVARCHAR, ISNULL(ERROR_LINE(), N''''))
		+ N'' ErrorMessage: '' + ERROR_MESSAGE();
	
	if	@Error <> 0
	begin
			
		RAISERROR (N''Error %d: %s.'', -- Message text.
			   16, -- Severity,
			   1, -- State,
			   @Error,
			   @ErrorMsg) WITH SETERROR; -- Second argument.
	end
    
END CATCH;


IF @@ERROR <> 0
	ROLLBACK TRAN
ELSE
	COMMIT TRAN

SET NOCOUNT OFF 
SET XACT_ABORT OFF 
GO


/**************************************************************************************************************************************
* ClearContext
**************************************************************************************************************************************/
SET NOCOUNT ON 

DELETE FROM [Giraffe].dbo.tstLocalSiteOptions WHERE strName = ''Context'' collate Cyrillic_General_CI_AS and strValue = ''DataMigration'' collate Cyrillic_General_CI_AS

DELETE FROM [Giraffe].dbo.tstLocalConnectionContext WHERE strConnectionContext = ''DataMigration'' collate Cyrillic_General_CI_AS

SET NOCOUNT OFF 

'

select	N'
/**************************************************************************************************************************************
* Enable Triggers
**************************************************************************************************************************************/
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER	FUNCTION [dbo].[FN_GBL_TriggersWork] ()
RETURNS BIT
AS
BEGIN
RETURN 1
--RETURN 0
END

GO
'

set nocount off


