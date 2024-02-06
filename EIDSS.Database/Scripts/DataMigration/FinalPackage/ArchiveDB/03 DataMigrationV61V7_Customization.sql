
-----------------------

/**************************************************************************************************************************************
* Data Migration script from EIDSSv6.1 to EIDSSv7.
* Execute script on any database, e.g. master, on the server, where both databases of EIDSS v6.1 and v7 ("empty DB") are located.
* By default, in the script EIDSSv6.1 database has the name Falcon_Archive and EIDSSv7 database has the name Giraffe_Archive.
**************************************************************************************************************************************/

use [Giraffe_Archive]
GO


-----

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



----------------------------


SET XACT_ABORT ON 
SET NOCOUNT ON 

declare @NewTempPassword nvarchar(100) = N'EIDss 2023$'	
declare @NewTempPwdHash nvarchar(max) = N'AQAAAAEAACcQAAAAEIvm12VITc96N39k6s7XDMYN3Nb63T3uPagwEE/lk+5uh3gz10qlliJV5N97SoAE3w=='
declare @NewTempSecurityStamp nvarchar(max) = N'6SCD5I2AKVRSE4QVA6JISRSMXQREY45R'
declare @PreferredNationalLanguage nvarchar(50) = 'ka'

declare	@Error	int
set	@Error = 0

declare	@ErrorMsg	nvarchar(MAX)
set	@ErrorMsg = N''

declare	@cmd	nvarchar(4000)
set	@cmd = N''


BEGIN TRAN

BEGIN TRY


---------------

/**************************************************************************************************************************************
* SetContext
**************************************************************************************************************************************/
DECLARE @Context VARBINARY(128)
SET @Context = CAST('DataMigration' AS VARBINARY(128))
SET CONTEXT_INFO @Context

IF NOT EXISTS (SELECT * FROM [Giraffe_Archive].[dbo].tstLocalSiteOptions WHERE strName = 'Context' collate Cyrillic_General_CI_AS)
INSERT INTO [Giraffe_Archive].[dbo].tstLocalSiteOptions 
(strName, strValue)
VALUES
('Context', 'DataMigration')

/**************************************************************************************************************************************
* Insert records to the tables
**************************************************************************************************************************************/


DECLARE @idfCustomizationPackage BIGINT
	, @idfsCountry BIGINT
	, @CDRSite BIGINT
	, @CountryPrefix NVARCHAR(2)
	, @idfsPreferredNationalLanguage BIGINT

SELECT @idfCustomizationPackage = [Falcon_Archive].[dbo].fnCustomizationPackage()
SELECT @idfsCountry = [Falcon_Archive].[dbo].fnCustomizationCountry()
SELECT 
	@CDRSite = ts.idfsSite
FROM	[Falcon_Archive].[dbo].tstSite ts
WHERE	ts.intRowStatus = 0
		and ts.idfCustomizationPackage = @idfCustomizationPackage
		and ts.idfsSiteType = 10085001 /*CDR*/

SELECT	@CountryPrefix = left(isnull(c.strHASC, N''), 2)
FROM	[Falcon_Archive].[dbo].gisCountry c
WHERE	c.idfsCountry = @idfsCountry

IF @CountryPrefix is null or @CountryPrefix = N'' collate Cyrillic_General_CI_AS
	SET @CountryPrefix = N'US'

SET @idfsPreferredNationalLanguage = [Falcon_Archive].dbo.fnGetLanguageCode( @PreferredNationalLanguage)



--


----------------------------------------------

/************************************************************
* Insert records - Base Reference table with user-defined values - start
************************************************************/
print N''
print N'Insert records - Base Reference table with user-defined values - start'
print N''


--

/************************************************************
* Insert records - [trtBaseReference]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtBaseReference] 

(

					[idfsBaseReference]

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
select 

					trtBaseReference_v6.[idfsBaseReference]

					, j_trtReferenceType_idfsReferenceType_v7.[idfsReferenceType]

					, trtBaseReference_v6.[strBaseReferenceCode]

					, trtBaseReference_v6.[strDefault]

					, trtBaseReference_v6.[intHACode]

					, trtBaseReference_v6.[intOrder]

					, trtBaseReference_v6.[blnSystem]

					, trtBaseReference_v6.[intRowStatus]

					, trtBaseReference_v6.[rowguid]

					, trtBaseReference_v6.[strMaintenanceFlag]

					, trtBaseReference_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsBaseReference":' + isnull(cast(trtBaseReference_v6.[idfsBaseReference] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtBaseReference] trtBaseReference_v6 


					inner join	[Giraffe_Archive].[dbo].[trtReferenceType] j_trtReferenceType_idfsReferenceType_v7

		on	


					j_trtReferenceType_idfsReferenceType_v7.[idfsReferenceType] = trtBaseReference_v6.[idfsReferenceType] 
left join	[Giraffe_Archive].[dbo].[trtBaseReference] trtBaseReference_v7 
on	

					trtBaseReference_v7.[idfsBaseReference] = trtBaseReference_v6.[idfsBaseReference] 
where trtBaseReference_v7.[idfsBaseReference] is null 
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

print N'Table [trtBaseReference] - insert: ' + cast(@@rowcount as nvarchar(20))


-----------------------------------------------------

print N''
print N'Insert records - Base Reference table with user-defined values - end'
print N''
print N''
/************************************************************
* Insert records - Base Reference table with user-defined values - end
************************************************************/


---------------------------------------------

/************************************************************
* Insert records - Reference tables - start
************************************************************/
print N''
print N'Insert records - Reference tables - start'
print N''


--

/************************************************************
* Insert records - [trtBssAggregateColumns]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtBssAggregateColumns] 

(

					[idfsBssAggregateColumn]

					, [idfColumn]

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
select 

					j_trtBaseReference_idfsBssAggregateColumn_v7.[idfsBaseReference]

					, j_tauColumn_idfColumn_v7.[idfColumn]

					, trtBssAggregateColumns_v6.[intRowStatus]

					, trtBssAggregateColumns_v6.[rowguid]

					, trtBssAggregateColumns_v6.[strMaintenanceFlag]

					, trtBssAggregateColumns_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsBssAggregateColumn":' + isnull(cast(trtBssAggregateColumns_v6.[idfsBssAggregateColumn] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtBssAggregateColumns] trtBssAggregateColumns_v6 


					inner join	[Giraffe_Archive].[dbo].[tauColumn] j_tauColumn_idfColumn_v7

		on	


					j_tauColumn_idfColumn_v7.[idfColumn] = trtBssAggregateColumns_v6.[idfColumn] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsBssAggregateColumn_v7

		on	


					j_trtBaseReference_idfsBssAggregateColumn_v7.[idfsBaseReference] = trtBssAggregateColumns_v6.[idfsBssAggregateColumn] 
left join	[Giraffe_Archive].[dbo].[trtBssAggregateColumns] trtBssAggregateColumns_v7 
on	

					trtBssAggregateColumns_v7.[idfsBssAggregateColumn] = trtBssAggregateColumns_v6.[idfsBssAggregateColumn] 
where trtBssAggregateColumns_v7.[idfsBssAggregateColumn] is null 
print N'Table [trtBssAggregateColumns] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtCaseClassification]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtCaseClassification] 

(

					[idfsCaseClassification]

					, [blnInitialHumanCaseClassification]

					, [rowguid]

					, [intRowStatus]

					, [blnFinalHumanCaseClassification]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_trtBaseReference_idfsCaseClassification_v7.[idfsBaseReference]

					, trtCaseClassification_v6.[blnInitialHumanCaseClassification]

					, trtCaseClassification_v6.[rowguid]

					, trtCaseClassification_v6.[intRowStatus]

					, trtCaseClassification_v6.[blnFinalHumanCaseClassification]

					, trtCaseClassification_v6.[strMaintenanceFlag]

					, trtCaseClassification_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsCaseClassification":' + isnull(cast(trtCaseClassification_v6.[idfsCaseClassification] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtCaseClassification] trtCaseClassification_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsCaseClassification_v7

		on	


					j_trtBaseReference_idfsCaseClassification_v7.[idfsBaseReference] = trtCaseClassification_v6.[idfsCaseClassification] 
left join	[Giraffe_Archive].[dbo].[trtCaseClassification] trtCaseClassification_v7 
on	

					trtCaseClassification_v7.[idfsCaseClassification] = trtCaseClassification_v6.[idfsCaseClassification] 
where trtCaseClassification_v7.[idfsCaseClassification] is null 
print N'Table [trtCaseClassification] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtDiagnosis]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtDiagnosis] 

(

					[idfsDiagnosis]

					, [idfsUsingType]

					, [strIDC10]

					, [strOIECode]

					, [intRowStatus]

					, [rowguid]

					, [blnZoonotic]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [blnSyndrome]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_trtBaseReference_idfsDiagnosis_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsUsingType_v7.[idfsBaseReference]

					, trtDiagnosis_v6.[strIDC10]

					, trtDiagnosis_v6.[strOIECode]

					, trtDiagnosis_v6.[intRowStatus]

					, trtDiagnosis_v6.[rowguid]

					, trtDiagnosis_v6.[blnZoonotic]

					, trtDiagnosis_v6.[strMaintenanceFlag]

					, trtDiagnosis_v6.[strReservedAttribute]

					, 0 /*Rule for the new field in EIDSSv7: blnSyndrome*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsDiagnosis":' + isnull(cast(trtDiagnosis_v6.[idfsDiagnosis] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtDiagnosis] trtDiagnosis_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsDiagnosis_v7

		on	


					j_trtBaseReference_idfsDiagnosis_v7.[idfsBaseReference] = trtDiagnosis_v6.[idfsDiagnosis] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsUsingType_v7

		on	


					j_trtBaseReference_idfsUsingType_v7.[idfsBaseReference] = trtDiagnosis_v6.[idfsUsingType] 
left join	[Giraffe_Archive].[dbo].[trtDiagnosis] trtDiagnosis_v7 
on	

					trtDiagnosis_v7.[idfsDiagnosis] = trtDiagnosis_v6.[idfsDiagnosis] 
where trtDiagnosis_v7.[idfsDiagnosis] is null 
print N'Table [trtDiagnosis] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtMatrixType]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtMatrixType] 

(

					[idfsMatrixType]

					, [idfsFormType]

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
select 

					j_trtBaseReference_idfsMatrixType_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsFormType_v7.[idfsBaseReference]

					, trtMatrixType_v6.[intRowStatus]

					, trtMatrixType_v6.[rowguid]

					, trtMatrixType_v6.[strMaintenanceFlag]

					, trtMatrixType_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsMatrixType":' + isnull(cast(trtMatrixType_v6.[idfsMatrixType] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtMatrixType] trtMatrixType_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsFormType_v7

		on	


					j_trtBaseReference_idfsFormType_v7.[idfsBaseReference] = trtMatrixType_v6.[idfsFormType] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsMatrixType_v7

		on	


					j_trtBaseReference_idfsMatrixType_v7.[idfsBaseReference] = trtMatrixType_v6.[idfsMatrixType] 
left join	[Giraffe_Archive].[dbo].[trtMatrixType] trtMatrixType_v7 
on	

					trtMatrixType_v7.[idfsMatrixType] = trtMatrixType_v6.[idfsMatrixType] 
where trtMatrixType_v7.[idfsMatrixType] is null 
print N'Table [trtMatrixType] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtMatrixColumn]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtMatrixColumn] 

(

					[idfsMatrixColumn]

					, [idfsMatrixType]

					, [intColumnOrder]

					, [intWidth]

					, [idfsParameterType]

					, [idfsEditor]

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
select 

					j_trtBaseReference_idfsMatrixColumn_v7.[idfsBaseReference]

					, j_trtMatrixType_idfsMatrixType_v7.[idfsMatrixType]

					, trtMatrixColumn_v6.[intColumnOrder]

					, trtMatrixColumn_v6.[intWidth]

					, j_trtBaseReference_idfsParameterType_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsEditor_v7.[idfsBaseReference]

					, trtMatrixColumn_v6.[intRowStatus]

					, trtMatrixColumn_v6.[rowguid]

					, trtMatrixColumn_v6.[strMaintenanceFlag]

					, trtMatrixColumn_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsMatrixColumn":' + isnull(cast(trtMatrixColumn_v6.[idfsMatrixColumn] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtMatrixColumn] trtMatrixColumn_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsEditor_v7

		on	


					j_trtBaseReference_idfsEditor_v7.[idfsBaseReference] = trtMatrixColumn_v6.[idfsEditor] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsMatrixColumn_v7

		on	


					j_trtBaseReference_idfsMatrixColumn_v7.[idfsBaseReference] = trtMatrixColumn_v6.[idfsMatrixColumn] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsParameterType_v7

		on	


					j_trtBaseReference_idfsParameterType_v7.[idfsBaseReference] = trtMatrixColumn_v6.[idfsParameterType] 

					inner join	[Giraffe_Archive].[dbo].[trtMatrixType] j_trtMatrixType_idfsMatrixType_v7

		on	


					j_trtMatrixType_idfsMatrixType_v7.[idfsMatrixType] = trtMatrixColumn_v6.[idfsMatrixType] 
left join	[Giraffe_Archive].[dbo].[trtMatrixColumn] trtMatrixColumn_v7 
on	

					trtMatrixColumn_v7.[idfsMatrixColumn] = trtMatrixColumn_v6.[idfsMatrixColumn] 
where trtMatrixColumn_v7.[idfsMatrixColumn] is null 
print N'Table [trtMatrixColumn] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtProphilacticAction]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtProphilacticAction] 

(

					[idfsProphilacticAction]

					, [strActionCode]

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
select 

					j_trtBaseReference_idfsProphilacticAction_v7.[idfsBaseReference]

					, trtProphilacticAction_v6.[strActionCode]

					, trtProphilacticAction_v6.[intRowStatus]

					, trtProphilacticAction_v6.[rowguid]

					, trtProphilacticAction_v6.[strMaintenanceFlag]

					, trtProphilacticAction_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsProphilacticAction":' + isnull(cast(trtProphilacticAction_v6.[idfsProphilacticAction] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtProphilacticAction] trtProphilacticAction_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsProphilacticAction_v7

		on	


					j_trtBaseReference_idfsProphilacticAction_v7.[idfsBaseReference] = trtProphilacticAction_v6.[idfsProphilacticAction] 
left join	[Giraffe_Archive].[dbo].[trtProphilacticAction] trtProphilacticAction_v7 
on	

					trtProphilacticAction_v7.[idfsProphilacticAction] = trtProphilacticAction_v6.[idfsProphilacticAction] 
where trtProphilacticAction_v7.[idfsProphilacticAction] is null 
print N'Table [trtProphilacticAction] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtSanitaryAction]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtSanitaryAction] 

(

					[idfsSanitaryAction]

					, [strActionCode]

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
select 

					j_trtBaseReference_idfsSanitaryAction_v7.[idfsBaseReference]

					, trtSanitaryAction_v6.[strActionCode]

					, trtSanitaryAction_v6.[intRowStatus]

					, trtSanitaryAction_v6.[rowguid]

					, trtSanitaryAction_v6.[strMaintenanceFlag]

					, trtSanitaryAction_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsSanitaryAction":' + isnull(cast(trtSanitaryAction_v6.[idfsSanitaryAction] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtSanitaryAction] trtSanitaryAction_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsSanitaryAction_v7

		on	


					j_trtBaseReference_idfsSanitaryAction_v7.[idfsBaseReference] = trtSanitaryAction_v6.[idfsSanitaryAction] 
left join	[Giraffe_Archive].[dbo].[trtSanitaryAction] trtSanitaryAction_v7 
on	

					trtSanitaryAction_v7.[idfsSanitaryAction] = trtSanitaryAction_v6.[idfsSanitaryAction] 
where trtSanitaryAction_v7.[idfsSanitaryAction] is null 
print N'Table [trtSanitaryAction] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtDiagnosisAgeGroup]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtDiagnosisAgeGroup] 

(

					[idfsDiagnosisAgeGroup]

					, [intLowerBoundary]

					, [intUpperBoundary]

					, [idfsAgeType]

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
select 

					j_trtBaseReference_idfsDiagnosisAgeGroup_v7.[idfsBaseReference]

					, trtDiagnosisAgeGroup_v6.[intLowerBoundary]

					, trtDiagnosisAgeGroup_v6.[intUpperBoundary]

					, j_trtBaseReference_idfsAgeType_v7.[idfsBaseReference]

					, trtDiagnosisAgeGroup_v6.[intRowStatus]

					, trtDiagnosisAgeGroup_v6.[rowguid]

					, trtDiagnosisAgeGroup_v6.[strMaintenanceFlag]

					, trtDiagnosisAgeGroup_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsDiagnosisAgeGroup":' + isnull(cast(trtDiagnosisAgeGroup_v6.[idfsDiagnosisAgeGroup] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtDiagnosisAgeGroup] trtDiagnosisAgeGroup_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsAgeType_v7

		on	


					j_trtBaseReference_idfsAgeType_v7.[idfsBaseReference] = trtDiagnosisAgeGroup_v6.[idfsAgeType] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsDiagnosisAgeGroup_v7

		on	


					j_trtBaseReference_idfsDiagnosisAgeGroup_v7.[idfsBaseReference] = trtDiagnosisAgeGroup_v6.[idfsDiagnosisAgeGroup] 
left join	[Giraffe_Archive].[dbo].[trtDiagnosisAgeGroup] trtDiagnosisAgeGroup_v7 
on	

					trtDiagnosisAgeGroup_v7.[idfsDiagnosisAgeGroup] = trtDiagnosisAgeGroup_v6.[idfsDiagnosisAgeGroup] 
where trtDiagnosisAgeGroup_v7.[idfsDiagnosisAgeGroup] is null 
print N'Table [trtDiagnosisAgeGroup] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtReportDiagnosisGroup]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtReportDiagnosisGroup] 

(

					[idfsReportDiagnosisGroup]

					, [strCode]

					, [intRowStatus]

					, [strDiagnosisGroupAlias]

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
select 

					j_trtBaseReference_idfsReportDiagnosisGroup_v7.[idfsBaseReference]

					, trtReportDiagnosisGroup_v6.[strCode]

					, trtReportDiagnosisGroup_v6.[intRowStatus]

					, trtReportDiagnosisGroup_v6.[strDiagnosisGroupAlias]

					, trtReportDiagnosisGroup_v6.[rowguid]

					, trtReportDiagnosisGroup_v6.[strMaintenanceFlag]

					, trtReportDiagnosisGroup_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsReportDiagnosisGroup":' + isnull(cast(trtReportDiagnosisGroup_v6.[idfsReportDiagnosisGroup] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtReportDiagnosisGroup] trtReportDiagnosisGroup_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsReportDiagnosisGroup_v7

		on	


					j_trtBaseReference_idfsReportDiagnosisGroup_v7.[idfsBaseReference] = trtReportDiagnosisGroup_v6.[idfsReportDiagnosisGroup] 
left join	[Giraffe_Archive].[dbo].[trtReportDiagnosisGroup] trtReportDiagnosisGroup_v7 
on	

					trtReportDiagnosisGroup_v7.[idfsReportDiagnosisGroup] = trtReportDiagnosisGroup_v6.[idfsReportDiagnosisGroup] 
where trtReportDiagnosisGroup_v7.[idfsReportDiagnosisGroup] is null 
print N'Table [trtReportDiagnosisGroup] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtSampleType]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtSampleType] 

(

					[idfsSampleType]

					, [strSampleCode]

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
select 

					j_trtBaseReference_idfsSampleType_v7.[idfsBaseReference]

					, trtSampleType_v6.[strSampleCode]

					, trtSampleType_v6.[intRowStatus]

					, trtSampleType_v6.[rowguid]

					, trtSampleType_v6.[strMaintenanceFlag]

					, trtSampleType_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsSampleType":' + isnull(cast(trtSampleType_v6.[idfsSampleType] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtSampleType] trtSampleType_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsSampleType_v7

		on	


					j_trtBaseReference_idfsSampleType_v7.[idfsBaseReference] = trtSampleType_v6.[idfsSampleType] 
left join	[Giraffe_Archive].[dbo].[trtSampleType] trtSampleType_v7 
on	

					trtSampleType_v7.[idfsSampleType] = trtSampleType_v6.[idfsSampleType] 
where trtSampleType_v7.[idfsSampleType] is null 
print N'Table [trtSampleType] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtSpeciesType]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtSpeciesType] 

(

					[idfsSpeciesType]

					, [strCode]

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
select 

					j_trtBaseReference_idfsSpeciesType_v7.[idfsBaseReference]

					, trtSpeciesType_v6.[strCode]

					, trtSpeciesType_v6.[intRowStatus]

					, trtSpeciesType_v6.[rowguid]

					, trtSpeciesType_v6.[strMaintenanceFlag]

					, trtSpeciesType_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsSpeciesType":' + isnull(cast(trtSpeciesType_v6.[idfsSpeciesType] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtSpeciesType] trtSpeciesType_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsSpeciesType_v7

		on	


					j_trtBaseReference_idfsSpeciesType_v7.[idfsBaseReference] = trtSpeciesType_v6.[idfsSpeciesType] 
left join	[Giraffe_Archive].[dbo].[trtSpeciesType] trtSpeciesType_v7 
on	

					trtSpeciesType_v7.[idfsSpeciesType] = trtSpeciesType_v6.[idfsSpeciesType] 
where trtSpeciesType_v7.[idfsSpeciesType] is null 
print N'Table [trtSpeciesType] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtSpeciesGroup]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtSpeciesGroup] 

(

					[idfsSpeciesGroup]

					, [strSpeciesGroupAlias]

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
select 

					j_trtBaseReference_idfsSpeciesGroup_v7.[idfsBaseReference]

					, trtSpeciesGroup_v6.[strSpeciesGroupAlias]

					, trtSpeciesGroup_v6.[intRowStatus]

					, trtSpeciesGroup_v6.[rowguid]

					, trtSpeciesGroup_v6.[strMaintenanceFlag]

					, trtSpeciesGroup_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsSpeciesGroup":' + isnull(cast(trtSpeciesGroup_v6.[idfsSpeciesGroup] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtSpeciesGroup] trtSpeciesGroup_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsSpeciesGroup_v7

		on	


					j_trtBaseReference_idfsSpeciesGroup_v7.[idfsBaseReference] = trtSpeciesGroup_v6.[idfsSpeciesGroup] 
left join	[Giraffe_Archive].[dbo].[trtSpeciesGroup] trtSpeciesGroup_v7 
on	

					trtSpeciesGroup_v7.[idfsSpeciesGroup] = trtSpeciesGroup_v6.[idfsSpeciesGroup] 
where trtSpeciesGroup_v7.[idfsSpeciesGroup] is null 
print N'Table [trtSpeciesGroup] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtStatisticDataType]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtStatisticDataType] 

(

					[idfsStatisticDataType]

					, [idfsReferenceType]

					, [idfsStatisticAreaType]

					, [idfsStatisticPeriodType]

					, [intRowStatus]

					, [rowguid]

					, [blnRelatedWithAgeGroup]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_trtBaseReference_idfsStatisticDataType_v7.[idfsBaseReference]

					, j_trtReferenceType_idfsReferenceType_v7.[idfsReferenceType]

					, j_trtBaseReference_idfsStatisticAreaType_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsStatisticPeriodType_v7.[idfsBaseReference]

					, trtStatisticDataType_v6.[intRowStatus]

					, trtStatisticDataType_v6.[rowguid]

					, trtStatisticDataType_v6.[blnRelatedWithAgeGroup]

					, trtStatisticDataType_v6.[strMaintenanceFlag]

					, trtStatisticDataType_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsStatisticDataType":' + isnull(cast(trtStatisticDataType_v6.[idfsStatisticDataType] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtStatisticDataType] trtStatisticDataType_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsStatisticAreaType_v7

		on	


					j_trtBaseReference_idfsStatisticAreaType_v7.[idfsBaseReference] = trtStatisticDataType_v6.[idfsStatisticAreaType] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsStatisticDataType_v7

		on	


					j_trtBaseReference_idfsStatisticDataType_v7.[idfsBaseReference] = trtStatisticDataType_v6.[idfsStatisticDataType] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsStatisticPeriodType_v7

		on	


					j_trtBaseReference_idfsStatisticPeriodType_v7.[idfsBaseReference] = trtStatisticDataType_v6.[idfsStatisticPeriodType] 

					left join	[Giraffe_Archive].[dbo].[trtReferenceType] j_trtReferenceType_idfsReferenceType_v7

		on	


					j_trtReferenceType_idfsReferenceType_v7.[idfsReferenceType] = trtStatisticDataType_v6.[idfsReferenceType] 
left join	[Giraffe_Archive].[dbo].[trtStatisticDataType] trtStatisticDataType_v7 
on	

					trtStatisticDataType_v7.[idfsStatisticDataType] = trtStatisticDataType_v6.[idfsStatisticDataType] 
where trtStatisticDataType_v7.[idfsStatisticDataType] is null 
print N'Table [trtStatisticDataType] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtVectorType]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtVectorType] 

(

					[idfsVectorType]

					, [strCode]

					, [bitCollectionByPool]

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
select 

					j_trtBaseReference_idfsVectorType_v7.[idfsBaseReference]

					, trtVectorType_v6.[strCode]

					, trtVectorType_v6.[bitCollectionByPool]

					, trtVectorType_v6.[intRowStatus]

					, trtVectorType_v6.[rowguid]

					, trtVectorType_v6.[strMaintenanceFlag]

					, trtVectorType_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsVectorType":' + isnull(cast(trtVectorType_v6.[idfsVectorType] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtVectorType] trtVectorType_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsVectorType_v7

		on	


					j_trtBaseReference_idfsVectorType_v7.[idfsBaseReference] = trtVectorType_v6.[idfsVectorType] 
left join	[Giraffe_Archive].[dbo].[trtVectorType] trtVectorType_v7 
on	

					trtVectorType_v7.[idfsVectorType] = trtVectorType_v6.[idfsVectorType] 
where trtVectorType_v7.[idfsVectorType] is null 
print N'Table [trtVectorType] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtVectorSubType]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtVectorSubType] 

(

					[idfsVectorSubType]

					, [idfsVectorType]

					, [strCode]

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
select 

					j_trtBaseReference_idfsVectorSubType_v7.[idfsBaseReference]

					, j_trtVectorType_idfsVectorType_v7.[idfsVectorType]

					, trtVectorSubType_v6.[strCode]

					, trtVectorSubType_v6.[intRowStatus]

					, trtVectorSubType_v6.[rowguid]

					, trtVectorSubType_v6.[strMaintenanceFlag]

					, trtVectorSubType_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsVectorSubType":' + isnull(cast(trtVectorSubType_v6.[idfsVectorSubType] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtVectorSubType] trtVectorSubType_v6 


					inner join	[Giraffe_Archive].[dbo].[trtVectorType] j_trtVectorType_idfsVectorType_v7

		on	


					j_trtVectorType_idfsVectorType_v7.[idfsVectorType] = trtVectorSubType_v6.[idfsVectorType] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsVectorSubType_v7

		on	


					j_trtBaseReference_idfsVectorSubType_v7.[idfsBaseReference] = trtVectorSubType_v6.[idfsVectorSubType] 
left join	[Giraffe_Archive].[dbo].[trtVectorSubType] trtVectorSubType_v7 
on	

					trtVectorSubType_v7.[idfsVectorSubType] = trtVectorSubType_v6.[idfsVectorSubType] 
where trtVectorSubType_v7.[idfsVectorSubType] is null 
print N'Table [trtVectorSubType] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtStringNameTranslation]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtStringNameTranslation] 

(

					[idfsBaseReference]

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
select 

					j_trtBaseReference_idfsBaseReference_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsLanguage_v7.[idfsBaseReference]

					, trtStringNameTranslation_v6.[strTextString]

					, trtStringNameTranslation_v6.[intRowStatus]

					, trtStringNameTranslation_v6.[rowguid]

					, trtStringNameTranslation_v6.[strMaintenanceFlag]

					, trtStringNameTranslation_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsBaseReference":' + isnull(cast(trtStringNameTranslation_v6.[idfsBaseReference] as nvarchar(20)), N'null') + N',' + N'"idfsLanguage":' + isnull(cast(trtStringNameTranslation_v6.[idfsLanguage] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtStringNameTranslation] trtStringNameTranslation_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsBaseReference_v7

		on	


					j_trtBaseReference_idfsBaseReference_v7.[idfsBaseReference] = trtStringNameTranslation_v6.[idfsBaseReference] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsLanguage_v7

		on	


					j_trtBaseReference_idfsLanguage_v7.[idfsBaseReference] = trtStringNameTranslation_v6.[idfsLanguage] 
left join	[Giraffe_Archive].[dbo].[trtStringNameTranslation] trtStringNameTranslation_v7 
on	

					trtStringNameTranslation_v7.[idfsBaseReference] = trtStringNameTranslation_v6.[idfsBaseReference] 

					and trtStringNameTranslation_v7.[idfsLanguage] = trtStringNameTranslation_v6.[idfsLanguage] 
where trtStringNameTranslation_v7.[idfsBaseReference] is null 
print N'Table [trtStringNameTranslation] - insert: ' + cast(@@rowcount as nvarchar(20))


----------------------------------------------------

print N''
print N'Insert records - Reference tables - end'
print N''
print N''
/************************************************************
* Insert records - Reference tables - end
************************************************************/


-----------------------------------------------------

/************************************************************
* Insert records - GIS Reference tables - start
************************************************************/
print N''
print N'Insert records - GIS Reference tables - start'
print N''


--

/************************************************************
* Insert records - [gisReferenceType]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisReferenceType] 

(

					[idfsGISReferenceType]

					, [strGISReferenceTypeCode]

					, [strGISReferenceTypeName]

					, [rowguid]

					, [intRowStatus]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					gisReferenceType_v6.[idfsGISReferenceType]

					, gisReferenceType_v6.[strGISReferenceTypeCode]

					, gisReferenceType_v6.[strGISReferenceTypeName]

					, gisReferenceType_v6.[rowguid]

					, gisReferenceType_v6.[intRowStatus]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsGISReferenceType":' + isnull(cast(gisReferenceType_v6.[idfsGISReferenceType] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisReferenceType] gisReferenceType_v6 

left join	[Giraffe_Archive].[dbo].[gisReferenceType] gisReferenceType_v7 
on	

					gisReferenceType_v7.[idfsGISReferenceType] = gisReferenceType_v6.[idfsGISReferenceType] 
where gisReferenceType_v7.[idfsGISReferenceType] is null 
print N'Table [gisReferenceType] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisBaseReference]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisBaseReference] 

(

					[idfsGISBaseReference]

					, [idfsGISReferenceType]

					, [strBaseReferenceCode]

					, [strDefault]

					, [intOrder]

					, [rowguid]

					, [intRowStatus]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					gisBaseReference_v6.[idfsGISBaseReference]

					, j_gisReferenceType_idfsGISReferenceType_v7.[idfsGISReferenceType]

					, gisBaseReference_v6.[strBaseReferenceCode]

					, gisBaseReference_v6.[strDefault]

					, gisBaseReference_v6.[intOrder]

					, gisBaseReference_v6.[rowguid]

					, gisBaseReference_v6.[intRowStatus]

					, gisBaseReference_v6.[strMaintenanceFlag]

					, gisBaseReference_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsGISBaseReference":' + isnull(cast(gisBaseReference_v6.[idfsGISBaseReference] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisBaseReference] gisBaseReference_v6 


					inner join	[Giraffe_Archive].[dbo].[gisReferenceType] j_gisReferenceType_idfsGISReferenceType_v7

		on	


					j_gisReferenceType_idfsGISReferenceType_v7.[idfsGISReferenceType] = gisBaseReference_v6.[idfsGISReferenceType] 
left join	[Giraffe_Archive].[dbo].[gisBaseReference] gisBaseReference_v7 
on	

					gisBaseReference_v7.[idfsGISBaseReference] = gisBaseReference_v6.[idfsGISBaseReference] 
where gisBaseReference_v7.[idfsGISBaseReference] is null 
print N'Table [gisBaseReference] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisOtherBaseReference]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisOtherBaseReference] 

(

					[idfsGISOtherBaseReference]

					, [idfsGISReferenceType]

					, [strDefault]

					, [intOrder]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					gisOtherBaseReference_v6.[idfsGISOtherBaseReference]

					, j_gisReferenceType_idfsGISReferenceType_v7.[idfsGISReferenceType]

					, gisOtherBaseReference_v6.[strDefault]

					, gisOtherBaseReference_v6.[intOrder]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsGISOtherBaseReference":' + isnull(cast(gisOtherBaseReference_v6.[idfsGISOtherBaseReference] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisOtherBaseReference] gisOtherBaseReference_v6 


					inner join	[Giraffe_Archive].[dbo].[gisReferenceType] j_gisReferenceType_idfsGISReferenceType_v7

		on	


					j_gisReferenceType_idfsGISReferenceType_v7.[idfsGISReferenceType] = gisOtherBaseReference_v6.[idfsGISReferenceType] 
left join	[Giraffe_Archive].[dbo].[gisOtherBaseReference] gisOtherBaseReference_v7 
on	

					gisOtherBaseReference_v7.[idfsGISOtherBaseReference] = gisOtherBaseReference_v6.[idfsGISOtherBaseReference] 
where gisOtherBaseReference_v7.[idfsGISOtherBaseReference] is null 
print N'Table [gisOtherBaseReference] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisCountry]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisCountry] 

(

					[idfsCountry]

					, [strHASC]

					, [strCode]

					, [rowguid]

					, [intRowStatus]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_gisBaseReference_idfsCountry_v7.[idfsGISBaseReference]

					, gisCountry_v6.[strHASC]

					, gisCountry_v6.[strCode]

					, gisCountry_v6.[rowguid]

					, gisCountry_v6.[intRowStatus]

					, gisCountry_v6.[strMaintenanceFlag]

					, gisCountry_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsCountry":' + isnull(cast(gisCountry_v6.[idfsCountry] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisCountry] gisCountry_v6 


					inner join	[Giraffe_Archive].[dbo].[gisBaseReference] j_gisBaseReference_idfsCountry_v7

		on	


					j_gisBaseReference_idfsCountry_v7.[idfsGISBaseReference] = gisCountry_v6.[idfsCountry] 
left join	[Giraffe_Archive].[dbo].[gisCountry] gisCountry_v7 
on	

					gisCountry_v7.[idfsCountry] = gisCountry_v6.[idfsCountry] 
where gisCountry_v7.[idfsCountry] is null 
print N'Table [gisCountry] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisRegion]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisRegion] 

(

					[idfsRegion]

					, [idfsCountry]

					, [strHASC]

					, [strCode]

					, [rowguid]

					, [intRowStatus]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]

					, [dblLongitude]

					, [dblLatitude]

					, [intElevation]
)
select 

					j_gisBaseReference_idfsRegion_v7.[idfsGISBaseReference]

					, j_gisCountry_idfsCountry_v7.[idfsCountry]

					, gisRegion_v6.[strHASC]

					, gisRegion_v6.[strCode]

					, gisRegion_v6.[rowguid]

					, gisRegion_v6.[intRowStatus]

					, gisRegion_v6.[strMaintenanceFlag]

					, gisRegion_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsRegion":' + isnull(cast(gisRegion_v6.[idfsRegion] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()

					, null /*TODO: Check the rule for the new field in EIDSSv7: dblLongitude*/

					, null /*TODO: Check the rule for the new field in EIDSSv7: dblLatitude*/

					, null /*TODO: Check the rule for the new field in EIDSSv7: intElevation*/
from [Falcon_Archive].[dbo].[gisRegion] gisRegion_v6 


					inner join	[Giraffe_Archive].[dbo].[gisBaseReference] j_gisBaseReference_idfsRegion_v7

		on	


					j_gisBaseReference_idfsRegion_v7.[idfsGISBaseReference] = gisRegion_v6.[idfsRegion] 

					inner join	[Giraffe_Archive].[dbo].[gisCountry] j_gisCountry_idfsCountry_v7

		on	


					j_gisCountry_idfsCountry_v7.[idfsCountry] = gisRegion_v6.[idfsCountry] 
left join	[Giraffe_Archive].[dbo].[gisRegion] gisRegion_v7 
on	

					gisRegion_v7.[idfsRegion] = gisRegion_v6.[idfsRegion] 
where gisRegion_v7.[idfsRegion] is null 
print N'Table [gisRegion] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisRayon]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisRayon] 

(

					[idfsRayon]

					, [idfsRegion]

					, [idfsCountry]

					, [strHASC]

					, [strCode]

					, [rowguid]

					, [intRowStatus]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]

					, [dblLongitude]

					, [dblLatitude]

					, [intElevation]
)
select 

					j_gisBaseReference_idfsRayon_v7.[idfsGISBaseReference]

					, j_gisRegion_idfsRegion_v7.[idfsRegion]

					, j_gisCountry_idfsCountry_v7.[idfsCountry]

					, gisRayon_v6.[strHASC]

					, gisRayon_v6.[strCode]

					, gisRayon_v6.[rowguid]

					, gisRayon_v6.[intRowStatus]

					, gisRayon_v6.[strMaintenanceFlag]

					, gisRayon_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsRayon":' + isnull(cast(gisRayon_v6.[idfsRayon] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()

					, null /*TODO: Check the rule for the new field in EIDSSv7: dblLongitude*/

					, null /*TODO: Check the rule for the new field in EIDSSv7: dblLatitude*/

					, null /*TODO: Check the rule for the new field in EIDSSv7: intElevation*/
from [Falcon_Archive].[dbo].[gisRayon] gisRayon_v6 


					inner join	[Giraffe_Archive].[dbo].[gisBaseReference] j_gisBaseReference_idfsRayon_v7

		on	


					j_gisBaseReference_idfsRayon_v7.[idfsGISBaseReference] = gisRayon_v6.[idfsRayon] 

					inner join	[Giraffe_Archive].[dbo].[gisCountry] j_gisCountry_idfsCountry_v7

		on	


					j_gisCountry_idfsCountry_v7.[idfsCountry] = gisRayon_v6.[idfsCountry] 

					inner join	[Giraffe_Archive].[dbo].[gisRegion] j_gisRegion_idfsRegion_v7

		on	


					j_gisRegion_idfsRegion_v7.[idfsRegion] = gisRayon_v6.[idfsRegion] 
left join	[Giraffe_Archive].[dbo].[gisRayon] gisRayon_v7 
on	

					gisRayon_v7.[idfsRayon] = gisRayon_v6.[idfsRayon] 
where gisRayon_v7.[idfsRayon] is null 
print N'Table [gisRayon] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisSettlement]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisSettlement] 

(

					[idfsSettlement]

					, [idfsSettlementType]

					, [idfsCountry]

					, [idfsRegion]

					, [idfsRayon]

					, [strSettlementCode]

					, [dblLongitude]

					, [dblLatitude]

					, [blnIsCustomSettlement]

					, [rowguid]

					, [intRowStatus]

					, [intElevation]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_gisBaseReference_idfsSettlement_v7.[idfsGISBaseReference]

					, j_gisBaseReference_idfsSettlementType_v7.[idfsGISBaseReference]

					, j_gisCountry_idfsCountry_v7.[idfsCountry]

					, j_gisRegion_idfsRegion_v7.[idfsRegion]

					, j_gisRayon_idfsRayon_v7.[idfsRayon]

					, gisSettlement_v6.[strSettlementCode]

					, gisSettlement_v6.[dblLongitude]

					, gisSettlement_v6.[dblLatitude]

					, gisSettlement_v6.[blnIsCustomSettlement]

					, gisSettlement_v6.[rowguid]

					, gisSettlement_v6.[intRowStatus]

					, gisSettlement_v6.[intElevation]

					, gisSettlement_v6.[strMaintenanceFlag]

					, gisSettlement_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsSettlement":' + isnull(cast(gisSettlement_v6.[idfsSettlement] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisSettlement] gisSettlement_v6 


					inner join	[Giraffe_Archive].[dbo].[gisBaseReference] j_gisBaseReference_idfsSettlement_v7

		on	


					j_gisBaseReference_idfsSettlement_v7.[idfsGISBaseReference] = gisSettlement_v6.[idfsSettlement] 

					inner join	[Giraffe_Archive].[dbo].[gisBaseReference] j_gisBaseReference_idfsSettlementType_v7

		on	


					j_gisBaseReference_idfsSettlementType_v7.[idfsGISBaseReference] = gisSettlement_v6.[idfsSettlementType] 

					inner join	[Giraffe_Archive].[dbo].[gisCountry] j_gisCountry_idfsCountry_v7

		on	


					j_gisCountry_idfsCountry_v7.[idfsCountry] = gisSettlement_v6.[idfsCountry] 

					inner join	[Giraffe_Archive].[dbo].[gisRayon] j_gisRayon_idfsRayon_v7

		on	


					j_gisRayon_idfsRayon_v7.[idfsRayon] = gisSettlement_v6.[idfsRayon] 

					inner join	[Giraffe_Archive].[dbo].[gisRegion] j_gisRegion_idfsRegion_v7

		on	


					j_gisRegion_idfsRegion_v7.[idfsRegion] = gisSettlement_v6.[idfsRegion] 
left join	[Giraffe_Archive].[dbo].[gisSettlement] gisSettlement_v7 
on	

					gisSettlement_v7.[idfsSettlement] = gisSettlement_v6.[idfsSettlement] 
where gisSettlement_v7.[idfsSettlement] is null 
print N'Table [gisSettlement] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisDistrictSubdistrict]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisDistrictSubdistrict] 

(

					[idfsGeoObject]

					, [idfsParent]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_gisRayon_idfsGeoObject_v7.[idfsRayon]

					, j_gisRayon_idfsParent_v7.[idfsRayon]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsGeoObject":' + isnull(cast(gisDistrictSubdistrict_v6.[idfsGeoObject] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisDistrictSubdistrict] gisDistrictSubdistrict_v6 


					inner join	[Giraffe_Archive].[dbo].[gisRayon] j_gisRayon_idfsGeoObject_v7

		on	


					j_gisRayon_idfsGeoObject_v7.[idfsRayon] = gisDistrictSubdistrict_v6.[idfsGeoObject] 

					left join	[Giraffe_Archive].[dbo].[gisRayon] j_gisRayon_idfsParent_v7

		on	


					j_gisRayon_idfsParent_v7.[idfsRayon] = gisDistrictSubdistrict_v6.[idfsParent] 
left join	[Giraffe_Archive].[dbo].[gisDistrictSubdistrict] gisDistrictSubdistrict_v7 
on	

					gisDistrictSubdistrict_v7.[idfsGeoObject] = gisDistrictSubdistrict_v6.[idfsGeoObject] 
where gisDistrictSubdistrict_v7.[idfsGeoObject] is null 
print N'Table [gisDistrictSubdistrict] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisMainCityForRayon]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisMainCityForRayon] 

(

					[idfsRayon]

					, [idfsMainSettlement]

					, [rowguid]

					, [intRowStatus]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_gisRayon_idfsRayon_v7.[idfsRayon]

					, j_gisSettlement_idfsMainSettlement_v7.[idfsSettlement]

					, newid() /*rowguid column*/

					, 0 /*Rule for the new field in EIDSSv7: intRowStatus*/

					, null /*TODO: Check the rule for the new field in EIDSSv7: strMaintenanceFlag*/

					, null /*TODO: Check the rule for the new field in EIDSSv7: strReservedAttribute*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsRayon":' + isnull(cast(gisMainCityForRayon_v6.[idfsRayon] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisMainCityForRayon] gisMainCityForRayon_v6 


					inner join	[Giraffe_Archive].[dbo].[gisRayon] j_gisRayon_idfsRayon_v7

		on	


					j_gisRayon_idfsRayon_v7.[idfsRayon] = gisMainCityForRayon_v6.[idfsRayon] 

					left join	[Giraffe_Archive].[dbo].[gisSettlement] j_gisSettlement_idfsMainSettlement_v7

		on	


					j_gisSettlement_idfsMainSettlement_v7.[idfsSettlement] = gisMainCityForRayon_v6.[idfsMainSettlement] 
left join	[Giraffe_Archive].[dbo].[gisMainCityForRayon] gisMainCityForRayon_v7 
on	

					gisMainCityForRayon_v7.[idfsRayon] = gisMainCityForRayon_v6.[idfsRayon] 
where gisMainCityForRayon_v7.[idfsRayon] is null 
print N'Table [gisMainCityForRayon] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisMetadata]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisMetadata] 

(

					[strLayer]

					, [strLayerType]

					, [strProjection]

					, [intFeatureCount]

					, [intLayerClass]

					, [strAlias]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					gisMetadata_v6.[strLayer]

					, gisMetadata_v6.[strLayerType]

					, gisMetadata_v6.[strProjection]

					, gisMetadata_v6.[intFeatureCount]

					, gisMetadata_v6.[intLayerClass]

					, gisMetadata_v6.[strAlias]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"strLayer":' + isnull(N'"' + gisMetadata_v6.[strLayer] + N'"' collate Cyrillic_General_CI_AS, N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisMetadata] gisMetadata_v6 

left join	[Giraffe_Archive].[dbo].[gisMetadata] gisMetadata_v7 
on	

					gisMetadata_v7.[strLayer] = gisMetadata_v6.[strLayer]  collate Cyrillic_General_CI_AS
where gisMetadata_v7.[strLayer] is null 
print N'Table [gisMetadata] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisLegendSymbol]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisLegendSymbol] 

(

					[idfLegendSymbol]

					, [binLegendSymbol]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					gisLegendSymbol_v6.[idfLegendSymbol]

					, gisLegendSymbol_v6.[binLegendSymbol]

					, gisLegendSymbol_v6.[rowguid]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfLegendSymbol":' + isnull(cast(gisLegendSymbol_v6.[idfLegendSymbol] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisLegendSymbol] gisLegendSymbol_v6 

left join	[Giraffe_Archive].[dbo].[gisLegendSymbol] gisLegendSymbol_v7 
on	

					gisLegendSymbol_v7.[idfLegendSymbol] = gisLegendSymbol_v6.[idfLegendSymbol] 
where gisLegendSymbol_v7.[idfLegendSymbol] is null 
print N'Table [gisLegendSymbol] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisWKBCountry]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisWKBCountry] 

(

					[idfsGeoObject]

					, [geomShape]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_gisCountry_idfsGeoObject_v7.[idfsCountry]

					, gisWKBCountry_v6.[geomShape]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsGeoObject":' + isnull(cast(gisWKBCountry_v6.[idfsGeoObject] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisWKBCountry] gisWKBCountry_v6 


					inner join	[Giraffe_Archive].[dbo].[gisCountry] j_gisCountry_idfsGeoObject_v7

		on	


					j_gisCountry_idfsGeoObject_v7.[idfsCountry] = gisWKBCountry_v6.[idfsGeoObject] 
left join	[Giraffe_Archive].[dbo].[gisWKBCountry] gisWKBCountry_v7 
on	

					gisWKBCountry_v7.[idfsGeoObject] = gisWKBCountry_v6.[idfsGeoObject] 
where gisWKBCountry_v7.[idfsGeoObject] is null 
print N'Table [gisWKBCountry] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisWKBRegion]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisWKBRegion] 

(

					[idfsGeoObject]

					, [HumanPopulation]

					, [HumanPopulationDensity]

					, [Sheep]

					, [Goat]

					, [Horse]

					, [Donkey]

					, [Pig]

					, [Dog]

					, [Poultry]

					, [SheepAndGoat]

					, [HeavyCatt]

					, [LiveStock]

					, [Area]

					, [geomShape]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_gisRegion_idfsGeoObject_v7.[idfsRegion]

					, gisWKBRegion_v6.[HumanPopulation]

					, gisWKBRegion_v6.[HumanPopulationDensity]

					, gisWKBRegion_v6.[Sheep]

					, gisWKBRegion_v6.[Goat]

					, gisWKBRegion_v6.[Horse]

					, gisWKBRegion_v6.[Donkey]

					, gisWKBRegion_v6.[Pig]

					, gisWKBRegion_v6.[Dog]

					, gisWKBRegion_v6.[Poultry]

					, gisWKBRegion_v6.[SheepAndGoat]

					, gisWKBRegion_v6.[HeavyCatt]

					, gisWKBRegion_v6.[LiveStock]

					, gisWKBRegion_v6.[Area]

					, gisWKBRegion_v6.[geomShape]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsGeoObject":' + isnull(cast(gisWKBRegion_v6.[idfsGeoObject] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisWKBRegion] gisWKBRegion_v6 


					inner join	[Giraffe_Archive].[dbo].[gisRegion] j_gisRegion_idfsGeoObject_v7

		on	


					j_gisRegion_idfsGeoObject_v7.[idfsRegion] = gisWKBRegion_v6.[idfsGeoObject] 
left join	[Giraffe_Archive].[dbo].[gisWKBRegion] gisWKBRegion_v7 
on	

					gisWKBRegion_v7.[idfsGeoObject] = gisWKBRegion_v6.[idfsGeoObject] 
where gisWKBRegion_v7.[idfsGeoObject] is null 
print N'Table [gisWKBRegion] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisWKBRayon]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisWKBRayon] 

(

					[idfsGeoObject]

					, [HumanPopulation]

					, [HumanPopulationDensity]

					, [Sheep]

					, [Goat]

					, [Horse]

					, [Donkey]

					, [Pig]

					, [Dog]

					, [Poultry]

					, [LiveStock]

					, [Area]

					, [geomShape]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_gisRayon_idfsGeoObject_v7.[idfsRayon]

					, gisWKBRayon_v6.[HumanPopulation]

					, gisWKBRayon_v6.[HumanPopulationDensity]

					, gisWKBRayon_v6.[Sheep]

					, gisWKBRayon_v6.[Goat]

					, gisWKBRayon_v6.[Horse]

					, gisWKBRayon_v6.[Donkey]

					, gisWKBRayon_v6.[Pig]

					, gisWKBRayon_v6.[Dog]

					, gisWKBRayon_v6.[Poultry]

					, gisWKBRayon_v6.[LiveStock]

					, gisWKBRayon_v6.[Area]

					, gisWKBRayon_v6.[geomShape]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsGeoObject":' + isnull(cast(gisWKBRayon_v6.[idfsGeoObject] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisWKBRayon] gisWKBRayon_v6 


					inner join	[Giraffe_Archive].[dbo].[gisRayon] j_gisRayon_idfsGeoObject_v7

		on	


					j_gisRayon_idfsGeoObject_v7.[idfsRayon] = gisWKBRayon_v6.[idfsGeoObject] 
left join	[Giraffe_Archive].[dbo].[gisWKBRayon] gisWKBRayon_v7 
on	

					gisWKBRayon_v7.[idfsGeoObject] = gisWKBRayon_v6.[idfsGeoObject] 
where gisWKBRayon_v7.[idfsGeoObject] is null 
print N'Table [gisWKBRayon] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisWKBDistrict]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisWKBDistrict] 

(

					[idfsGeoObject]

					, [name_en]

					, [name_th]

					, [geomShape]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_gisBaseReference_idfsGeoObject_v7.[idfsGISBaseReference]

					, gisWKBDistrict_v6.[name_en]

					, gisWKBDistrict_v6.[name_th]

					, gisWKBDistrict_v6.[geomShape]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsGeoObject":' + isnull(cast(gisWKBDistrict_v6.[idfsGeoObject] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisWKBDistrict] gisWKBDistrict_v6 


					inner join	[Giraffe_Archive].[dbo].[gisBaseReference] j_gisBaseReference_idfsGeoObject_v7

		on	


					j_gisBaseReference_idfsGeoObject_v7.[idfsGISBaseReference] = gisWKBDistrict_v6.[idfsGeoObject] 
left join	[Giraffe_Archive].[dbo].[gisWKBDistrict] gisWKBDistrict_v7 
on	

					gisWKBDistrict_v7.[idfsGeoObject] = gisWKBDistrict_v6.[idfsGeoObject] 
where gisWKBDistrict_v7.[idfsGeoObject] is null 
print N'Table [gisWKBDistrict] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisWKBSettlement]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisWKBSettlement] 

(

					[idfsGeoObject]

					, [population]

					, [admstatus]

					, [HumanPopulation]

					, [geomShape]

					, [intElevation]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_gisSettlement_idfsGeoObject_v7.[idfsSettlement]

					, gisWKBSettlement_v6.[population]

					, gisWKBSettlement_v6.[admstatus]

					, gisWKBSettlement_v6.[HumanPopulation]

					, gisWKBSettlement_v6.[geomShape]

					, gisWKBSettlement_v6.[intElevation]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsGeoObject":' + isnull(cast(gisWKBSettlement_v6.[idfsGeoObject] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisWKBSettlement] gisWKBSettlement_v6 


					inner join	[Giraffe_Archive].[dbo].[gisSettlement] j_gisSettlement_idfsGeoObject_v7

		on	


					j_gisSettlement_idfsGeoObject_v7.[idfsSettlement] = gisWKBSettlement_v6.[idfsGeoObject] 
left join	[Giraffe_Archive].[dbo].[gisWKBSettlement] gisWKBSettlement_v7 
on	

					gisWKBSettlement_v7.[idfsGeoObject] = gisWKBSettlement_v6.[idfsGeoObject] 
where gisWKBSettlement_v7.[idfsGeoObject] is null 
print N'Table [gisWKBSettlement] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisWKBEarthRoad]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisWKBEarthRoad] 

(

					[idfsGeoObject]

					, [strCode]

					, [NameEng]

					, [NameRu]

					, [Type]

					, [Code]

					, [idfsCountry]

					, [geomShape]

					, [NameLoc]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_gisOtherBaseReference_idfsGeoObject_v7.[idfsGISOtherBaseReference]

					, gisWKBEarthRoad_v6.[strCode]

					, gisWKBEarthRoad_v6.[NameEng]

					, gisWKBEarthRoad_v6.[NameRu]

					, gisWKBEarthRoad_v6.[Type]

					, gisWKBEarthRoad_v6.[Code]

					, j_gisCountry_idfsCountry_v7.[idfsCountry]

					, gisWKBEarthRoad_v6.[geomShape]

					, gisWKBEarthRoad_v6.[NameLoc]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsGeoObject":' + isnull(cast(gisWKBEarthRoad_v6.[idfsGeoObject] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisWKBEarthRoad] gisWKBEarthRoad_v6 


					inner join	[Giraffe_Archive].[dbo].[gisOtherBaseReference] j_gisOtherBaseReference_idfsGeoObject_v7

		on	


					j_gisOtherBaseReference_idfsGeoObject_v7.[idfsGISOtherBaseReference] = gisWKBEarthRoad_v6.[idfsGeoObject] 

					left join	[Giraffe_Archive].[dbo].[gisCountry] j_gisCountry_idfsCountry_v7

		on	


					j_gisCountry_idfsCountry_v7.[idfsCountry] = gisWKBEarthRoad_v6.[idfsCountry] 
left join	[Giraffe_Archive].[dbo].[gisWKBEarthRoad] gisWKBEarthRoad_v7 
on	

					gisWKBEarthRoad_v7.[idfsGeoObject] = gisWKBEarthRoad_v6.[idfsGeoObject] 
where gisWKBEarthRoad_v7.[idfsGeoObject] is null 
print N'Table [gisWKBEarthRoad] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisWKBForest]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisWKBForest] 

(

					[idfsGeoObject]

					, [geomShape]

					, [idfsCountry]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_gisOtherBaseReference_idfsGeoObject_v7.[idfsGISOtherBaseReference]

					, gisWKBForest_v6.[geomShape]

					, j_gisCountry_idfsCountry_v7.[idfsCountry]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsGeoObject":' + isnull(cast(gisWKBForest_v6.[idfsGeoObject] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisWKBForest] gisWKBForest_v6 


					inner join	[Giraffe_Archive].[dbo].[gisOtherBaseReference] j_gisOtherBaseReference_idfsGeoObject_v7

		on	


					j_gisOtherBaseReference_idfsGeoObject_v7.[idfsGISOtherBaseReference] = gisWKBForest_v6.[idfsGeoObject] 

					left join	[Giraffe_Archive].[dbo].[gisCountry] j_gisCountry_idfsCountry_v7

		on	


					j_gisCountry_idfsCountry_v7.[idfsCountry] = gisWKBForest_v6.[idfsCountry] 
left join	[Giraffe_Archive].[dbo].[gisWKBForest] gisWKBForest_v7 
on	

					gisWKBForest_v7.[idfsGeoObject] = gisWKBForest_v6.[idfsGeoObject] 
where gisWKBForest_v7.[idfsGeoObject] is null 
print N'Table [gisWKBForest] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisWKBHighway]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisWKBHighway] 

(

					[idfsGeoObject]

					, [strCode]

					, [NameEng]

					, [NameRu]

					, [Type]

					, [Code]

					, [idfsCountry]

					, [geomShape]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_gisOtherBaseReference_idfsGeoObject_v7.[idfsGISOtherBaseReference]

					, gisWKBHighway_v6.[strCode]

					, gisWKBHighway_v6.[NameEng]

					, gisWKBHighway_v6.[NameRu]

					, gisWKBHighway_v6.[Type]

					, gisWKBHighway_v6.[Code]

					, j_gisCountry_idfsCountry_v7.[idfsCountry]

					, gisWKBHighway_v6.[geomShape]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsGeoObject":' + isnull(cast(gisWKBHighway_v6.[idfsGeoObject] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisWKBHighway] gisWKBHighway_v6 


					inner join	[Giraffe_Archive].[dbo].[gisOtherBaseReference] j_gisOtherBaseReference_idfsGeoObject_v7

		on	


					j_gisOtherBaseReference_idfsGeoObject_v7.[idfsGISOtherBaseReference] = gisWKBHighway_v6.[idfsGeoObject] 

					left join	[Giraffe_Archive].[dbo].[gisCountry] j_gisCountry_idfsCountry_v7

		on	


					j_gisCountry_idfsCountry_v7.[idfsCountry] = gisWKBHighway_v6.[idfsCountry] 
left join	[Giraffe_Archive].[dbo].[gisWKBHighway] gisWKBHighway_v7 
on	

					gisWKBHighway_v7.[idfsGeoObject] = gisWKBHighway_v6.[idfsGeoObject] 
where gisWKBHighway_v7.[idfsGeoObject] is null 
print N'Table [gisWKBHighway] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisWKBInlandWater]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisWKBInlandWater] 

(

					[idfsGeoObject]

					, [geomShape]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					gisWKBInlandWater_v6.[idfsGeoObject]

					, gisWKBInlandWater_v6.[geomShape]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsGeoObject":' + isnull(cast(gisWKBInlandWater_v6.[idfsGeoObject] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisWKBInlandWater] gisWKBInlandWater_v6 

left join	[Giraffe_Archive].[dbo].[gisWKBInlandWater] gisWKBInlandWater_v7 
on	

					gisWKBInlandWater_v7.[idfsGeoObject] = gisWKBInlandWater_v6.[idfsGeoObject] 
where gisWKBInlandWater_v7.[idfsGeoObject] is null 
print N'Table [gisWKBInlandWater] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisWKBLake]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisWKBLake] 

(

					[idfsGeoObject]

					, [strCode]

					, [NameEng]

					, [NameRu]

					, [Type]

					, [idfsCountry]

					, [geomShape]

					, [NameLoc]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_gisOtherBaseReference_idfsGeoObject_v7.[idfsGISOtherBaseReference]

					, gisWKBLake_v6.[strCode]

					, gisWKBLake_v6.[NameEng]

					, gisWKBLake_v6.[NameRu]

					, gisWKBLake_v6.[Type]

					, j_gisCountry_idfsCountry_v7.[idfsCountry]

					, gisWKBLake_v6.[geomShape]

					, gisWKBLake_v6.[NameLoc]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsGeoObject":' + isnull(cast(gisWKBLake_v6.[idfsGeoObject] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisWKBLake] gisWKBLake_v6 


					inner join	[Giraffe_Archive].[dbo].[gisOtherBaseReference] j_gisOtherBaseReference_idfsGeoObject_v7

		on	


					j_gisOtherBaseReference_idfsGeoObject_v7.[idfsGISOtherBaseReference] = gisWKBLake_v6.[idfsGeoObject] 

					left join	[Giraffe_Archive].[dbo].[gisCountry] j_gisCountry_idfsCountry_v7

		on	


					j_gisCountry_idfsCountry_v7.[idfsCountry] = gisWKBLake_v6.[idfsCountry] 
left join	[Giraffe_Archive].[dbo].[gisWKBLake] gisWKBLake_v7 
on	

					gisWKBLake_v7.[idfsGeoObject] = gisWKBLake_v6.[idfsGeoObject] 
where gisWKBLake_v7.[idfsGeoObject] is null 
print N'Table [gisWKBLake] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisWKBLanduse]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisWKBLanduse] 

(

					[idfsGeoObject]

					, [geomShape]

					, [idfsCountry]

					, [strLanduse]

					, [SubType]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_gisOtherBaseReference_idfsGeoObject_v7.[idfsGISOtherBaseReference]

					, gisWKBLanduse_v6.[geomShape]

					, j_gisCountry_idfsCountry_v7.[idfsCountry]

					, gisWKBLanduse_v6.[strLanduse]

					, gisWKBLanduse_v6.[SubType]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsGeoObject":' + isnull(cast(gisWKBLanduse_v6.[idfsGeoObject] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisWKBLanduse] gisWKBLanduse_v6 


					inner join	[Giraffe_Archive].[dbo].[gisOtherBaseReference] j_gisOtherBaseReference_idfsGeoObject_v7

		on	


					j_gisOtherBaseReference_idfsGeoObject_v7.[idfsGISOtherBaseReference] = gisWKBLanduse_v6.[idfsGeoObject] 

					left join	[Giraffe_Archive].[dbo].[gisCountry] j_gisCountry_idfsCountry_v7

		on	


					j_gisCountry_idfsCountry_v7.[idfsCountry] = gisWKBLanduse_v6.[idfsCountry] 
left join	[Giraffe_Archive].[dbo].[gisWKBLanduse] gisWKBLanduse_v7 
on	

					gisWKBLanduse_v7.[idfsGeoObject] = gisWKBLanduse_v6.[idfsGeoObject] 
where gisWKBLanduse_v7.[idfsGeoObject] is null 
print N'Table [gisWKBLanduse] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisWKBMainRiver]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisWKBMainRiver] 

(

					[idfsGeoObject]

					, [strCode]

					, [NameEng]

					, [NameRu]

					, [Type]

					, [idfsCountry]

					, [geomShape]

					, [NameLoc]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_gisOtherBaseReference_idfsGeoObject_v7.[idfsGISOtherBaseReference]

					, gisWKBMainRiver_v6.[strCode]

					, gisWKBMainRiver_v6.[NameEng]

					, gisWKBMainRiver_v6.[NameRu]

					, gisWKBMainRiver_v6.[Type]

					, j_gisCountry_idfsCountry_v7.[idfsCountry]

					, gisWKBMainRiver_v6.[geomShape]

					, gisWKBMainRiver_v6.[NameLoc]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsGeoObject":' + isnull(cast(gisWKBMainRiver_v6.[idfsGeoObject] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisWKBMainRiver] gisWKBMainRiver_v6 


					inner join	[Giraffe_Archive].[dbo].[gisOtherBaseReference] j_gisOtherBaseReference_idfsGeoObject_v7

		on	


					j_gisOtherBaseReference_idfsGeoObject_v7.[idfsGISOtherBaseReference] = gisWKBMainRiver_v6.[idfsGeoObject] 

					left join	[Giraffe_Archive].[dbo].[gisCountry] j_gisCountry_idfsCountry_v7

		on	


					j_gisCountry_idfsCountry_v7.[idfsCountry] = gisWKBMainRiver_v6.[idfsCountry] 
left join	[Giraffe_Archive].[dbo].[gisWKBMainRiver] gisWKBMainRiver_v7 
on	

					gisWKBMainRiver_v7.[idfsGeoObject] = gisWKBMainRiver_v6.[idfsGeoObject] 
where gisWKBMainRiver_v7.[idfsGeoObject] is null 
print N'Table [gisWKBMainRiver] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisWKBMajorRoad]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisWKBMajorRoad] 

(

					[idfsGeoObject]

					, [strCode]

					, [NameEng]

					, [NameRu]

					, [Type]

					, [Code]

					, [idfsCountry]

					, [geomShape]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_gisOtherBaseReference_idfsGeoObject_v7.[idfsGISOtherBaseReference]

					, gisWKBMajorRoad_v6.[strCode]

					, gisWKBMajorRoad_v6.[NameEng]

					, gisWKBMajorRoad_v6.[NameRu]

					, gisWKBMajorRoad_v6.[Type]

					, gisWKBMajorRoad_v6.[Code]

					, j_gisCountry_idfsCountry_v7.[idfsCountry]

					, gisWKBMajorRoad_v6.[geomShape]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsGeoObject":' + isnull(cast(gisWKBMajorRoad_v6.[idfsGeoObject] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisWKBMajorRoad] gisWKBMajorRoad_v6 


					inner join	[Giraffe_Archive].[dbo].[gisOtherBaseReference] j_gisOtherBaseReference_idfsGeoObject_v7

		on	


					j_gisOtherBaseReference_idfsGeoObject_v7.[idfsGISOtherBaseReference] = gisWKBMajorRoad_v6.[idfsGeoObject] 

					left join	[Giraffe_Archive].[dbo].[gisCountry] j_gisCountry_idfsCountry_v7

		on	


					j_gisCountry_idfsCountry_v7.[idfsCountry] = gisWKBMajorRoad_v6.[idfsCountry] 
left join	[Giraffe_Archive].[dbo].[gisWKBMajorRoad] gisWKBMajorRoad_v7 
on	

					gisWKBMajorRoad_v7.[idfsGeoObject] = gisWKBMajorRoad_v6.[idfsGeoObject] 
where gisWKBMajorRoad_v7.[idfsGeoObject] is null 
print N'Table [gisWKBMajorRoad] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisWKBPath]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisWKBPath] 

(

					[idfsGeoObject]

					, [strCode]

					, [NameEng]

					, [NameRu]

					, [Type]

					, [Code]

					, [idfsCountry]

					, [geomShape]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_gisOtherBaseReference_idfsGeoObject_v7.[idfsGISOtherBaseReference]

					, gisWKBPath_v6.[strCode]

					, gisWKBPath_v6.[NameEng]

					, gisWKBPath_v6.[NameRu]

					, gisWKBPath_v6.[Type]

					, gisWKBPath_v6.[Code]

					, j_gisCountry_idfsCountry_v7.[idfsCountry]

					, gisWKBPath_v6.[geomShape]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsGeoObject":' + isnull(cast(gisWKBPath_v6.[idfsGeoObject] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisWKBPath] gisWKBPath_v6 


					inner join	[Giraffe_Archive].[dbo].[gisOtherBaseReference] j_gisOtherBaseReference_idfsGeoObject_v7

		on	


					j_gisOtherBaseReference_idfsGeoObject_v7.[idfsGISOtherBaseReference] = gisWKBPath_v6.[idfsGeoObject] 

					left join	[Giraffe_Archive].[dbo].[gisCountry] j_gisCountry_idfsCountry_v7

		on	


					j_gisCountry_idfsCountry_v7.[idfsCountry] = gisWKBPath_v6.[idfsCountry] 
left join	[Giraffe_Archive].[dbo].[gisWKBPath] gisWKBPath_v7 
on	

					gisWKBPath_v7.[idfsGeoObject] = gisWKBPath_v6.[idfsGeoObject] 
where gisWKBPath_v7.[idfsGeoObject] is null 
print N'Table [gisWKBPath] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisWKBRailroad]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisWKBRailroad] 

(

					[idfsGeoObject]

					, [strCode]

					, [NameEng]

					, [NameRu]

					, [Type]

					, [idfsCountry]

					, [geomShape]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_gisOtherBaseReference_idfsGeoObject_v7.[idfsGISOtherBaseReference]

					, gisWKBRailroad_v6.[strCode]

					, gisWKBRailroad_v6.[NameEng]

					, gisWKBRailroad_v6.[NameRu]

					, gisWKBRailroad_v6.[Type]

					, j_gisCountry_idfsCountry_v7.[idfsCountry]

					, gisWKBRailroad_v6.[geomShape]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsGeoObject":' + isnull(cast(gisWKBRailroad_v6.[idfsGeoObject] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisWKBRailroad] gisWKBRailroad_v6 


					inner join	[Giraffe_Archive].[dbo].[gisOtherBaseReference] j_gisOtherBaseReference_idfsGeoObject_v7

		on	


					j_gisOtherBaseReference_idfsGeoObject_v7.[idfsGISOtherBaseReference] = gisWKBRailroad_v6.[idfsGeoObject] 

					left join	[Giraffe_Archive].[dbo].[gisCountry] j_gisCountry_idfsCountry_v7

		on	


					j_gisCountry_idfsCountry_v7.[idfsCountry] = gisWKBRailroad_v6.[idfsCountry] 
left join	[Giraffe_Archive].[dbo].[gisWKBRailroad] gisWKBRailroad_v7 
on	

					gisWKBRailroad_v7.[idfsGeoObject] = gisWKBRailroad_v6.[idfsGeoObject] 
where gisWKBRailroad_v7.[idfsGeoObject] is null 
print N'Table [gisWKBRailroad] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisWKBRiver]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisWKBRiver] 

(

					[idfsGeoObject]

					, [strCode]

					, [NameEng]

					, [NameRu]

					, [Type]

					, [idfsCountry]

					, [geomShape]

					, [NameLoc]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_gisOtherBaseReference_idfsGeoObject_v7.[idfsGISOtherBaseReference]

					, gisWKBRiver_v6.[strCode]

					, gisWKBRiver_v6.[NameEng]

					, gisWKBRiver_v6.[NameRu]

					, gisWKBRiver_v6.[Type]

					, j_gisCountry_idfsCountry_v7.[idfsCountry]

					, gisWKBRiver_v6.[geomShape]

					, gisWKBRiver_v6.[NameLoc]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsGeoObject":' + isnull(cast(gisWKBRiver_v6.[idfsGeoObject] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisWKBRiver] gisWKBRiver_v6 


					inner join	[Giraffe_Archive].[dbo].[gisOtherBaseReference] j_gisOtherBaseReference_idfsGeoObject_v7

		on	


					j_gisOtherBaseReference_idfsGeoObject_v7.[idfsGISOtherBaseReference] = gisWKBRiver_v6.[idfsGeoObject] 

					left join	[Giraffe_Archive].[dbo].[gisCountry] j_gisCountry_idfsCountry_v7

		on	


					j_gisCountry_idfsCountry_v7.[idfsCountry] = gisWKBRiver_v6.[idfsCountry] 
left join	[Giraffe_Archive].[dbo].[gisWKBRiver] gisWKBRiver_v7 
on	

					gisWKBRiver_v7.[idfsGeoObject] = gisWKBRiver_v6.[idfsGeoObject] 
where gisWKBRiver_v7.[idfsGeoObject] is null 
print N'Table [gisWKBRiver] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisWKBRiverPolygon]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisWKBRiverPolygon] 

(

					[idfsGeoObject]

					, [strCode]

					, [NameEng]

					, [NameRu]

					, [Type]

					, [idfsCountry]

					, [geomShape]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_gisOtherBaseReference_idfsGeoObject_v7.[idfsGISOtherBaseReference]

					, gisWKBRiverPolygon_v6.[strCode]

					, gisWKBRiverPolygon_v6.[NameEng]

					, gisWKBRiverPolygon_v6.[NameRu]

					, gisWKBRiverPolygon_v6.[Type]

					, j_gisCountry_idfsCountry_v7.[idfsCountry]

					, gisWKBRiverPolygon_v6.[geomShape]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsGeoObject":' + isnull(cast(gisWKBRiverPolygon_v6.[idfsGeoObject] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisWKBRiverPolygon] gisWKBRiverPolygon_v6 


					inner join	[Giraffe_Archive].[dbo].[gisOtherBaseReference] j_gisOtherBaseReference_idfsGeoObject_v7

		on	


					j_gisOtherBaseReference_idfsGeoObject_v7.[idfsGISOtherBaseReference] = gisWKBRiverPolygon_v6.[idfsGeoObject] 

					left join	[Giraffe_Archive].[dbo].[gisCountry] j_gisCountry_idfsCountry_v7

		on	


					j_gisCountry_idfsCountry_v7.[idfsCountry] = gisWKBRiverPolygon_v6.[idfsCountry] 
left join	[Giraffe_Archive].[dbo].[gisWKBRiverPolygon] gisWKBRiverPolygon_v7 
on	

					gisWKBRiverPolygon_v7.[idfsGeoObject] = gisWKBRiverPolygon_v6.[idfsGeoObject] 
where gisWKBRiverPolygon_v7.[idfsGeoObject] is null 
print N'Table [gisWKBRiverPolygon] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisWKBRuralDistrict]
************************************************************/








/************************************************************
* Insert records - [gisWKBSea]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisWKBSea] 

(

					[idfsGeoObject]

					, [strCode]

					, [NameEng]

					, [NameRu]

					, [geomShape]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_gisOtherBaseReference_idfsGeoObject_v7.[idfsGISOtherBaseReference]

					, gisWKBSea_v6.[strCode]

					, gisWKBSea_v6.[NameEng]

					, gisWKBSea_v6.[NameRu]

					, gisWKBSea_v6.[geomShape]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsGeoObject":' + isnull(cast(gisWKBSea_v6.[idfsGeoObject] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisWKBSea] gisWKBSea_v6 


					inner join	[Giraffe_Archive].[dbo].[gisOtherBaseReference] j_gisOtherBaseReference_idfsGeoObject_v7

		on	


					j_gisOtherBaseReference_idfsGeoObject_v7.[idfsGISOtherBaseReference] = gisWKBSea_v6.[idfsGeoObject] 
left join	[Giraffe_Archive].[dbo].[gisWKBSea] gisWKBSea_v7 
on	

					gisWKBSea_v7.[idfsGeoObject] = gisWKBSea_v6.[idfsGeoObject] 
where gisWKBSea_v7.[idfsGeoObject] is null 
print N'Table [gisWKBSea] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisWKBSmallRiver]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisWKBSmallRiver] 

(

					[idfsGeoObject]

					, [strCode]

					, [NameEng]

					, [NameRu]

					, [Type]

					, [idfsCountry]

					, [geomShape]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_gisOtherBaseReference_idfsGeoObject_v7.[idfsGISOtherBaseReference]

					, gisWKBSmallRiver_v6.[strCode]

					, gisWKBSmallRiver_v6.[NameEng]

					, gisWKBSmallRiver_v6.[NameRu]

					, gisWKBSmallRiver_v6.[Type]

					, j_gisCountry_idfsCountry_v7.[idfsCountry]

					, gisWKBSmallRiver_v6.[geomShape]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsGeoObject":' + isnull(cast(gisWKBSmallRiver_v6.[idfsGeoObject] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisWKBSmallRiver] gisWKBSmallRiver_v6 


					inner join	[Giraffe_Archive].[dbo].[gisOtherBaseReference] j_gisOtherBaseReference_idfsGeoObject_v7

		on	


					j_gisOtherBaseReference_idfsGeoObject_v7.[idfsGISOtherBaseReference] = gisWKBSmallRiver_v6.[idfsGeoObject] 

					left join	[Giraffe_Archive].[dbo].[gisCountry] j_gisCountry_idfsCountry_v7

		on	


					j_gisCountry_idfsCountry_v7.[idfsCountry] = gisWKBSmallRiver_v6.[idfsCountry] 
left join	[Giraffe_Archive].[dbo].[gisWKBSmallRiver] gisWKBSmallRiver_v7 
on	

					gisWKBSmallRiver_v7.[idfsGeoObject] = gisWKBSmallRiver_v6.[idfsGeoObject] 
where gisWKBSmallRiver_v7.[idfsGeoObject] is null 
print N'Table [gisWKBSmallRiver] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisWKBRegionReady]
************************************************************/

SET IDENTITY_INSERT [Giraffe_Archive].[dbo].[gisWKBRegionReady]  ON

insert into [Giraffe_Archive].[dbo].[gisWKBRegionReady] 

(

					[oid]

					, [idfsGeoObject]

					, [Ratio]

					, [geomShape_3857]

					, [geomShape_4326]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					gisWKBRegionReady_v6.[oid]

					, gisWKBRegionReady_v6.[idfsGeoObject]

					, gisWKBRegionReady_v6.[Ratio]

					, gisWKBRegionReady_v6.[geomShape_3857]

					, gisWKBRegionReady_v6.[geomShape_4326]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"oid":' + isnull(cast(gisWKBRegionReady_v6.[oid] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisWKBRegionReady] gisWKBRegionReady_v6 

left join	[Giraffe_Archive].[dbo].[gisWKBRegionReady] gisWKBRegionReady_v7 
on	

					gisWKBRegionReady_v7.[oid] = gisWKBRegionReady_v6.[oid] 
where gisWKBRegionReady_v7.[oid] is null 
SET IDENTITY_INSERT [Giraffe_Archive].[dbo].[gisWKBRegionReady]  OFF


print N'Table [gisWKBRegionReady] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisWKBRayonReady]
************************************************************/

SET IDENTITY_INSERT [Giraffe_Archive].[dbo].[gisWKBRayonReady]  ON

insert into [Giraffe_Archive].[dbo].[gisWKBRayonReady] 

(

					[oid]

					, [idfsGeoObject]

					, [Ratio]

					, [geomShape_3857]

					, [geomShape_4326]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					gisWKBRayonReady_v6.[oid]

					, gisWKBRayonReady_v6.[idfsGeoObject]

					, gisWKBRayonReady_v6.[Ratio]

					, gisWKBRayonReady_v6.[geomShape_3857]

					, gisWKBRayonReady_v6.[geomShape_4326]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"oid":' + isnull(cast(gisWKBRayonReady_v6.[oid] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisWKBRayonReady] gisWKBRayonReady_v6 

left join	[Giraffe_Archive].[dbo].[gisWKBRayonReady] gisWKBRayonReady_v7 
on	

					gisWKBRayonReady_v7.[oid] = gisWKBRayonReady_v6.[oid] 
where gisWKBRayonReady_v7.[oid] is null 
SET IDENTITY_INSERT [Giraffe_Archive].[dbo].[gisWKBRayonReady]  OFF


print N'Table [gisWKBRayonReady] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisWKBDistrictReady]
************************************************************/

SET IDENTITY_INSERT [Giraffe_Archive].[dbo].[gisWKBDistrictReady]  ON

insert into [Giraffe_Archive].[dbo].[gisWKBDistrictReady] 

(

					[oid]

					, [idfsGeoObject]

					, [Ratio]

					, [geomShape_3857]

					, [geomShape_4326]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					gisWKBDistrictReady_v6.[oid]

					, gisWKBDistrictReady_v6.[idfsGeoObject]

					, gisWKBDistrictReady_v6.[Ratio]

					, gisWKBDistrictReady_v6.[geomShape_3857]

					, gisWKBDistrictReady_v6.[geomShape_4326]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"oid":' + isnull(cast(gisWKBDistrictReady_v6.[oid] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisWKBDistrictReady] gisWKBDistrictReady_v6 

left join	[Giraffe_Archive].[dbo].[gisWKBDistrictReady] gisWKBDistrictReady_v7 
on	

					gisWKBDistrictReady_v7.[oid] = gisWKBDistrictReady_v6.[oid] 
where gisWKBDistrictReady_v7.[oid] is null 
SET IDENTITY_INSERT [Giraffe_Archive].[dbo].[gisWKBDistrictReady]  OFF


print N'Table [gisWKBDistrictReady] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisWKBSettlementReady]
************************************************************/

SET IDENTITY_INSERT [Giraffe_Archive].[dbo].[gisWKBSettlementReady]  ON

insert into [Giraffe_Archive].[dbo].[gisWKBSettlementReady] 

(

					[oid]

					, [idfsGeoObject]

					, [Ratio]

					, [geomShape_3857]

					, [geomShape_4326]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					gisWKBSettlementReady_v6.[oid]

					, gisWKBSettlementReady_v6.[idfsGeoObject]

					, gisWKBSettlementReady_v6.[Ratio]

					, gisWKBSettlementReady_v6.[geomShape_3857]

					, gisWKBSettlementReady_v6.[geomShape_4326]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"oid":' + isnull(cast(gisWKBSettlementReady_v6.[oid] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisWKBSettlementReady] gisWKBSettlementReady_v6 

left join	[Giraffe_Archive].[dbo].[gisWKBSettlementReady] gisWKBSettlementReady_v7 
on	

					gisWKBSettlementReady_v7.[oid] = gisWKBSettlementReady_v6.[oid] 
where gisWKBSettlementReady_v7.[oid] is null 
SET IDENTITY_INSERT [Giraffe_Archive].[dbo].[gisWKBSettlementReady]  OFF


print N'Table [gisWKBSettlementReady] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisOtherStringNameTranslation]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisOtherStringNameTranslation] 

(

					[idfsGISOtherBaseReference]

					, [idfsLanguage]

					, [strTextString]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_gisOtherBaseReference_idfsGISOtherBaseReference_v7.[idfsGISOtherBaseReference]

					, j_gisBaseReference_idfsLanguage_v7.[idfsGISBaseReference]

					, gisOtherStringNameTranslation_v6.[strTextString]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsGISOtherBaseReference":' + isnull(cast(gisOtherStringNameTranslation_v6.[idfsGISOtherBaseReference] as nvarchar(20)), N'null') + N',' + N'"idfsLanguage":' + isnull(cast(gisOtherStringNameTranslation_v6.[idfsLanguage] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisOtherStringNameTranslation] gisOtherStringNameTranslation_v6 


					inner join	[Giraffe_Archive].[dbo].[gisBaseReference] j_gisBaseReference_idfsLanguage_v7

		on	


					j_gisBaseReference_idfsLanguage_v7.[idfsGISBaseReference] = gisOtherStringNameTranslation_v6.[idfsLanguage] 

					inner join	[Giraffe_Archive].[dbo].[gisOtherBaseReference] j_gisOtherBaseReference_idfsGISOtherBaseReference_v7

		on	


					j_gisOtherBaseReference_idfsGISOtherBaseReference_v7.[idfsGISOtherBaseReference] = gisOtherStringNameTranslation_v6.[idfsGISOtherBaseReference] 
left join	[Giraffe_Archive].[dbo].[gisOtherStringNameTranslation] gisOtherStringNameTranslation_v7 
on	

					gisOtherStringNameTranslation_v7.[idfsGISOtherBaseReference] = gisOtherStringNameTranslation_v6.[idfsGISOtherBaseReference] 

					and gisOtherStringNameTranslation_v7.[idfsLanguage] = gisOtherStringNameTranslation_v6.[idfsLanguage] 
where gisOtherStringNameTranslation_v7.[idfsGISOtherBaseReference] is null 
print N'Table [gisOtherStringNameTranslation] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [gisStringNameTranslation]
************************************************************/
insert into [Giraffe_Archive].[dbo].[gisStringNameTranslation] 

(

					[idfsGISBaseReference]

					, [idfsLanguage]

					, [strTextString]

					, [rowguid]

					, [intRowStatus]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_gisBaseReference_idfsGISBaseReference_v7.[idfsGISBaseReference]

					, j_gisBaseReference_idfsLanguage_v7.[idfsGISBaseReference]

					, gisStringNameTranslation_v6.[strTextString]

					, gisStringNameTranslation_v6.[rowguid]

					, gisStringNameTranslation_v6.[intRowStatus]

					, gisStringNameTranslation_v6.[strMaintenanceFlag]

					, gisStringNameTranslation_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsGISBaseReference":' + isnull(cast(gisStringNameTranslation_v6.[idfsGISBaseReference] as nvarchar(20)), N'null') + N',' + N'"idfsLanguage":' + isnull(cast(gisStringNameTranslation_v6.[idfsLanguage] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[gisStringNameTranslation] gisStringNameTranslation_v6 


					inner join	[Giraffe_Archive].[dbo].[gisBaseReference] j_gisBaseReference_idfsGISBaseReference_v7

		on	


					j_gisBaseReference_idfsGISBaseReference_v7.[idfsGISBaseReference] = gisStringNameTranslation_v6.[idfsGISBaseReference] 

					inner join	[Giraffe_Archive].[dbo].[gisBaseReference] j_gisBaseReference_idfsLanguage_v7

		on	


					j_gisBaseReference_idfsLanguage_v7.[idfsGISBaseReference] = gisStringNameTranslation_v6.[idfsLanguage] 
left join	[Giraffe_Archive].[dbo].[gisStringNameTranslation] gisStringNameTranslation_v7 
on	

					gisStringNameTranslation_v7.[idfsGISBaseReference] = gisStringNameTranslation_v6.[idfsGISBaseReference] 

					and gisStringNameTranslation_v7.[idfsLanguage] = gisStringNameTranslation_v6.[idfsLanguage] 
where gisStringNameTranslation_v7.[idfsGISBaseReference] is null 
print N'Table [gisStringNameTranslation] - insert: ' + cast(@@rowcount as nvarchar(20))


--------------

print N''
print N''
print N''

/************************************************************
* Calculate records in EIDSSv7 - [gisLocation] - start
************************************************************/
print N'Calculate records in EIDSSv7 - [gisLocation] - start'

insert into	[Giraffe_Archive].[dbo].[gisLocation]
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
		N'/' + cast((isnull(lev_last_ex.intLastLevelValue, 0) + lev_num.intLevelSeqNumber) as nvarchar(20)) + N'/' collate Cyrillic_General_CI_AS,
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
		N'[{' + N'"idfsLocation":' + isnull(cast(lev.idfsCountry as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS,
		N'system',
		GETUTCDATE(),
		N'system',
		GETUTCDATE()
from	[Giraffe_Archive].[dbo].[gisCountry] lev
join	[Giraffe_Archive].[dbo].gisBaseReference br_lev
on	br_lev.idfsGISBaseReference = lev.idfsCountry
left join	[Giraffe_Archive].[dbo].[gisLocation] loc_ex
on	loc_ex.idfsLocation = lev.idfsCountry
outer apply
(	select	max(cast(replace(cast(loc_last.[node] as nvarchar(200)), N'/', N'') as bigint)) as intLastLevelValue
	from	[Giraffe_Archive].[dbo].[gisLocation] loc_last
	where	loc_last.[node].GetLevel() = 1
) lev_last_ex
outer apply
(	select	count(lev_count.idfsCountry) as intLevelSeqNumber
	from	[Giraffe_Archive].[dbo].[gisCountry] lev_count
	join	[Giraffe_Archive].[dbo].gisBaseReference br_lev_count
	on	br_lev_count.idfsGISBaseReference = lev_count.idfsCountry
	left join	[Giraffe_Archive].[dbo].[gisLocation] loc_ex_count
	on	loc_ex_count.idfsLocation = lev_count.idfsCountry
	where	loc_ex_count.idfsLocation is null
			and lev_count.idfsCountry <= lev.idfsCountry
) lev_num
where	loc_ex.idfsLocation is null
print N'Table [gisLocation] - insert calculated records from gisCountry (level 1): ' + cast(@@rowcount as nvarchar(20))


------------------------------------------------------

insert into	[Giraffe_Archive].[dbo].[gisLocation]
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
		cast(lev_up.[node] as nvarchar(200)) + cast((isnull(lev_last_ex.intLastLevelValue, 0) + lev_num.intLevelSeqNumber) as nvarchar(20)) + N'/' collate Cyrillic_General_CI_AS,
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
		N'[{' + N'"idfsLocation":' + isnull(cast(lev.idfsRegion as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS,
		N'system',
		GETUTCDATE(),
		N'system',
		GETUTCDATE()
from	[Giraffe_Archive].[dbo].[gisRegion] lev
join	[Giraffe_Archive].[dbo].gisBaseReference br_lev
on	br_lev.idfsGISBaseReference = lev.idfsRegion
join	[Giraffe_Archive].[dbo].[gisLocation] lev_up
on		lev_up.idfsLocation = lev.idfsCountry
left join	[Giraffe_Archive].[dbo].[gisLocation] loc_ex
on	loc_ex.idfsLocation = lev.idfsRegion
outer apply
(	select	max(cast(replace(RIGHT(cast(loc_last.[node] as nvarchar(200)), LEN(cast(loc_last.[node] as nvarchar(200))) - [Falcon_Archive].[dbo].fnGetLastCharIndexOfSubstringInNonTrimString(left(cast(loc_last.[node] as nvarchar(200)), LEN(cast(loc_last.[node] as nvarchar(200))) - 1), N'/', 0) + 1), N'/', N'') as bigint)) as intLastLevelValue
	from	[Giraffe_Archive].[dbo].[gisLocation] loc_last
	where	loc_last.[node].GetLevel() = 2
) lev_last_ex
outer apply
(	select	count(lev_count.idfsRegion) as intLevelSeqNumber
	from	[Giraffe_Archive].[dbo].[gisRegion] lev_count
	join	[Giraffe_Archive].[dbo].gisBaseReference br_lev_count
	on	br_lev_count.idfsGISBaseReference = lev_count.idfsRegion
	join	[Giraffe_Archive].[dbo].[gisLocation] lev_up
	on		lev_up.idfsLocation = lev.idfsCountry
	left join	[Giraffe_Archive].[dbo].[gisLocation] loc_ex_count
	on	loc_ex_count.idfsLocation = lev_count.idfsRegion
	where	loc_ex_count.idfsLocation is null
			and lev_count.idfsRegion <= lev.idfsRegion
) lev_num
where	loc_ex.idfsLocation is null
print N'Table [gisLocation] - insert calculated records from gisRegion (level 2): ' + cast(@@rowcount as nvarchar(20))


----------------------------------------

insert into	[Giraffe_Archive].[dbo].[gisLocation]
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
		cast(lev_up.[node] as nvarchar(200)) + cast((isnull(lev_last_ex.intLastLevelValue, 0) + lev_num.intLevelSeqNumber) as nvarchar(20)) + N'/' collate Cyrillic_General_CI_AS,
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
		N'[{' + N'"idfsLocation":' + isnull(cast(lev.idfsRayon as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS,
		N'system',
		GETUTCDATE(),
		N'system',
		GETUTCDATE()
from	[Giraffe_Archive].[dbo].[gisRayon] lev
join	[Giraffe_Archive].[dbo].gisBaseReference br_lev
on	br_lev.idfsGISBaseReference = lev.idfsRayon
join	[Giraffe_Archive].[dbo].[gisLocation] lev_up
on		lev_up.idfsLocation = lev.idfsRegion
left join	[Giraffe_Archive].[dbo].[gisLocation] loc_ex
on	loc_ex.idfsLocation = lev.idfsRayon
outer apply
(	select	max(cast(replace(RIGHT(cast(loc_last.[node] as nvarchar(200)), LEN(cast(loc_last.[node] as nvarchar(200))) - [Falcon_Archive].[dbo].fnGetLastCharIndexOfSubstringInNonTrimString(left(cast(loc_last.[node] as nvarchar(200)), LEN(cast(loc_last.[node] as nvarchar(200))) - 1), N'/', 0) + 1), N'/', N'') as bigint)) as intLastLevelValue
	from	[Giraffe_Archive].[dbo].[gisLocation] loc_last
	where	loc_last.[node].GetLevel() = 3
) lev_last_ex
outer apply
(	select	count(lev_count.idfsRayon) as intLevelSeqNumber
	from	[Giraffe_Archive].[dbo].[gisRayon] lev_count
	join	[Giraffe_Archive].[dbo].gisBaseReference br_lev_count
	on	br_lev_count.idfsGISBaseReference = lev_count.idfsRayon
	join	[Giraffe_Archive].[dbo].[gisLocation] lev_up
	on		lev_up.idfsLocation = lev.idfsRegion
	left join	[Giraffe_Archive].[dbo].[gisLocation] loc_ex_count
	on	loc_ex_count.idfsLocation = lev_count.idfsRayon
	where	loc_ex_count.idfsLocation is null
			and lev_count.idfsRayon <= lev.idfsRayon
) lev_num
where	loc_ex.idfsLocation is null
print N'Table [gisLocation] - insert calculated records from gisRayon (level 3): ' + cast(@@rowcount as nvarchar(20))


--

insert into	[Giraffe_Archive].[dbo].[gisLocation]
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
		cast(lev_up.[node] as nvarchar(200)) + cast((isnull(lev_last_ex.intLastLevelValue, 0) + lev_num.intLevelSeqNumber) as nvarchar(20)) + N'/' collate Cyrillic_General_CI_AS,
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
		N'[{' + N'"idfsLocation":' + isnull(cast(lev.idfsSettlement as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS,
		N'system',
		GETUTCDATE(),
		N'system',
		GETUTCDATE()
from	[Giraffe_Archive].[dbo].[gisSettlement] lev
join	[Giraffe_Archive].[dbo].gisBaseReference br_lev
on	br_lev.idfsGISBaseReference = lev.idfsSettlement
join	[Giraffe_Archive].[dbo].[gisLocation] lev_up
on		lev_up.idfsLocation = lev.idfsRayon
left join	[Giraffe_Archive].[dbo].[gisLocation] loc_ex
on	loc_ex.idfsLocation = lev.idfsSettlement
outer apply
(	select	max(cast(replace(RIGHT(cast(loc_last.[node] as nvarchar(200)), LEN(cast(loc_last.[node] as nvarchar(200))) - [Falcon_Archive].[dbo].fnGetLastCharIndexOfSubstringInNonTrimString(left(cast(loc_last.[node] as nvarchar(200)), LEN(cast(loc_last.[node] as nvarchar(200))) - 1), N'/', 0) + 1), N'/', N'') as bigint)) as intLastLevelValue
	from	[Giraffe_Archive].[dbo].[gisLocation] loc_last
	where	loc_last.[node].GetLevel() = 4
) lev_last_ex
outer apply
(	select	count(lev_count.idfsSettlement) as intLevelSeqNumber
	from	[Giraffe_Archive].[dbo].[gisSettlement] lev_count
	join	[Giraffe_Archive].[dbo].gisBaseReference br_lev_count
	on	br_lev_count.idfsGISBaseReference = lev_count.idfsSettlement
	join	[Giraffe_Archive].[dbo].[gisLocation] lev_up
	on		lev_up.idfsLocation = lev.idfsRayon
	left join	[Giraffe_Archive].[dbo].[gisLocation] loc_ex_count
	on	loc_ex_count.idfsLocation = lev_count.idfsSettlement
	where	loc_ex_count.idfsLocation is null
			and lev_count.idfsSettlement <= lev.idfsSettlement
) lev_num
where	loc_ex.idfsLocation is null
print N'Table [gisLocation] - insert calculated records from gisSettlement (level 4): ' + cast(@@rowcount as nvarchar(20))

print N'Calculate records in EIDSSv7 - [gisLocation] - end'
/************************************************************
* Calculate records in EIDSSv7 - [gisLocation] - end
************************************************************/

print N''
print N''
print N''



-----------------------------

/************************************************************
* Calculate records in EIDSSv7 - [gisLocationDenormalized] - start
************************************************************/
print N'Calculate records in EIDSSv7 - [gisLocationDenormalized] - start'

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

from	[Giraffe_Archive].[dbo].[gisLocation] loc
left join	[Giraffe_Archive].[dbo].[gisBaseReference] gbr
on	gbr.idfsGISBaseReference = loc.idfsLocation
left join	[Giraffe_Archive].[dbo].[gisReferenceType] grt
on	grt.idfsGISReferenceType = gbr.idfsGISReferenceType

join	[Falcon_Archive].[dbo].[trtLanguageToCP] lang_cp
on	lang_cp.idfCustomizationPackage = @idfCustomizationPackage
join	[Giraffe_Archive].[dbo].[trtBaseReference] lang
on	lang.idfsBaseReference = lang_cp.idfsLanguage

left join	[Giraffe_Archive].[dbo].[gisStringNameTranslation] gsnt
on	gsnt.idfsGISBaseReference = gbr.idfsGISBaseReference
	and gsnt.idfsLanguage = lang.idfsBaseReference

join	[Giraffe_Archive].[dbo].[gisLocationDenormalized] gld_ex
on	gld_ex.idfsLocation = loc.idfsLocation
	and gld_ex.idfsLanguage = lang.idfsBaseReference

where	loc.[node].GetLevel() = 1
print N'Table [gisLocationDenormalized] - update calculated records from gisLocation (level 1): ' + cast(@@rowcount as nvarchar(20))



-------------------

insert into	[Giraffe_Archive].[dbo].[gisLocationDenormalized]
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

from	[Giraffe_Archive].[dbo].[gisLocation] loc
join	[Giraffe_Archive].[dbo].[gisBaseReference] gbr
on	gbr.idfsGISBaseReference = loc.idfsLocation
join	[Giraffe_Archive].[dbo].[gisReferenceType] grt
on	grt.idfsGISReferenceType = gbr.idfsGISReferenceType

join	[Falcon_Archive].[dbo].[trtLanguageToCP] lang_cp
on	lang_cp.idfCustomizationPackage = @idfCustomizationPackage
join	[Giraffe_Archive].[dbo].[trtBaseReference] lang
on	lang.idfsBaseReference = lang_cp.idfsLanguage

left join	[Giraffe_Archive].[dbo].[gisStringNameTranslation] gsnt
on	gsnt.idfsGISBaseReference = gbr.idfsGISBaseReference
	and gsnt.idfsLanguage = lang.idfsBaseReference

left join	[Giraffe_Archive].[dbo].[gisLocationDenormalized] gld_ex
on	gld_ex.idfsLocation = loc.idfsLocation
	and gld_ex.idfsLanguage = lang.idfsBaseReference

where	loc.[node].GetLevel() = 1
		and gld_ex.idfsLocation is null
print N'Table [gisLocationDenormalized] - insert calculated records from gisLocation (level 1): ' + cast(@@rowcount as nvarchar(20))



-------------------------------------

update	gld_child
set		gld_child.[Level1ID] = loc.idfsLocation,
		gld_child.[Level1Name] = coalesce(gsnt.strTextString, gbr.strDefault, gld_ex.[Level1Name])
from	[Giraffe_Archive].[dbo].[gisLocation] loc
join	[Giraffe_Archive].[dbo].[gisBaseReference] gbr
on	gbr.idfsGISBaseReference = loc.idfsLocation
join	[Giraffe_Archive].[dbo].[gisReferenceType] grt
on	grt.idfsGISReferenceType = gbr.idfsGISReferenceType

join	[Falcon_Archive].[dbo].[trtLanguageToCP] lang_cp
on	lang_cp.idfCustomizationPackage = @idfCustomizationPackage
join	[Giraffe_Archive].[dbo].[trtBaseReference] lang
on	lang.idfsBaseReference = lang_cp.idfsLanguage

left join	[Giraffe_Archive].[dbo].[gisStringNameTranslation] gsnt
on	gsnt.idfsGISBaseReference = gbr.idfsGISBaseReference
	and gsnt.idfsLanguage = lang.idfsBaseReference

join	[Giraffe_Archive].[dbo].[gisLocationDenormalized] gld_ex
on	gld_ex.idfsLocation = loc.idfsLocation
	and gld_ex.idfsLanguage = lang.idfsBaseReference

join	[Giraffe_Archive].[dbo].[gisLocationDenormalized] gld_child
on	gld_child.[Node].IsDescendantOf(gld_ex.[Node]) = 1
	and gld_child.idfsLanguage = lang.idfsBaseReference
	and gld_child.[Node].GetLevel() > 1

where	loc.[node].GetLevel() = 1
print N'Table [gisLocationDenormalized] - update calculated records from gisLocation (descendants of level 1): ' + cast(@@rowcount as nvarchar(20))
print N''



---------

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

from	[Giraffe_Archive].[dbo].[gisLocation] loc
left join	[Giraffe_Archive].[dbo].[gisBaseReference] gbr
on	gbr.idfsGISBaseReference = loc.idfsLocation
left join	[Giraffe_Archive].[dbo].[gisReferenceType] grt
on	grt.idfsGISReferenceType = gbr.idfsGISReferenceType

join	[Falcon_Archive].[dbo].[trtLanguageToCP] lang_cp
on	lang_cp.idfCustomizationPackage = @idfCustomizationPackage
join	[Giraffe_Archive].[dbo].[trtBaseReference] lang
on	lang.idfsBaseReference = lang_cp.idfsLanguage

left join	[Giraffe_Archive].[dbo].[gisStringNameTranslation] gsnt
on	gsnt.idfsGISBaseReference = gbr.idfsGISBaseReference
	and gsnt.idfsLanguage = lang.idfsBaseReference

join	[Giraffe_Archive].[dbo].[gisLocationDenormalized] gld_ex
on	gld_ex.idfsLocation = loc.idfsLocation
	and gld_ex.idfsLanguage = lang.idfsBaseReference

where	loc.[node].GetLevel() = 2
print N'Table [gisLocationDenormalized] - update calculated records from gisLocation (level 2): ' + cast(@@rowcount as nvarchar(20))




---------------------

insert into	[Giraffe_Archive].[dbo].[gisLocationDenormalized]
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

from	[Giraffe_Archive].[dbo].[gisLocation] loc
join	[Giraffe_Archive].[dbo].[gisBaseReference] gbr
on	gbr.idfsGISBaseReference = loc.idfsLocation
join	[Giraffe_Archive].[dbo].[gisReferenceType] grt
on	grt.idfsGISReferenceType = gbr.idfsGISReferenceType

join	[Falcon_Archive].[dbo].[trtLanguageToCP] lang_cp
on	lang_cp.idfCustomizationPackage = @idfCustomizationPackage
join	[Giraffe_Archive].[dbo].[trtBaseReference] lang
on	lang.idfsBaseReference = lang_cp.idfsLanguage

left join	[Giraffe_Archive].[dbo].[gisStringNameTranslation] gsnt
on	gsnt.idfsGISBaseReference = gbr.idfsGISBaseReference
	and gsnt.idfsLanguage = lang.idfsBaseReference

left join	[Giraffe_Archive].[dbo].[gisLocationDenormalized] gld_lev_up
on	gld_lev_up.[Node] = loc.[node].GetAncestor(1)
	and gld_lev_up.idfsLanguage = lang.idfsBaseReference

left join	[Giraffe_Archive].[dbo].[gisLocationDenormalized] gld_ex
on	gld_ex.idfsLocation = loc.idfsLocation
	and gld_ex.idfsLanguage = lang.idfsBaseReference

where	loc.[node].GetLevel() = 2
		and gld_ex.idfsLocation is null
print N'Table [gisLocationDenormalized] - insert calculated records from gisLocation (level 2): ' + cast(@@rowcount as nvarchar(20))



-------------------------------------

update	gld_child
set		gld_child.[Level2ID] = loc.idfsLocation,
		gld_child.[Level2Name] = coalesce(gsnt.strTextString, gbr.strDefault, gld_ex.[Level2Name])
from	[Giraffe_Archive].[dbo].[gisLocation] loc
join	[Giraffe_Archive].[dbo].[gisBaseReference] gbr
on	gbr.idfsGISBaseReference = loc.idfsLocation
join	[Giraffe_Archive].[dbo].[gisReferenceType] grt
on	grt.idfsGISReferenceType = gbr.idfsGISReferenceType

join	[Falcon_Archive].[dbo].[trtLanguageToCP] lang_cp
on	lang_cp.idfCustomizationPackage = @idfCustomizationPackage
join	[Giraffe_Archive].[dbo].[trtBaseReference] lang
on	lang.idfsBaseReference = lang_cp.idfsLanguage

left join	[Giraffe_Archive].[dbo].[gisStringNameTranslation] gsnt
on	gsnt.idfsGISBaseReference = gbr.idfsGISBaseReference
	and gsnt.idfsLanguage = lang.idfsBaseReference

join	[Giraffe_Archive].[dbo].[gisLocationDenormalized] gld_ex
on	gld_ex.idfsLocation = loc.idfsLocation
	and gld_ex.idfsLanguage = lang.idfsBaseReference

join	[Giraffe_Archive].[dbo].[gisLocationDenormalized] gld_child
on	gld_child.[Node].IsDescendantOf(gld_ex.[Node]) = 1
	and gld_child.idfsLanguage = lang.idfsBaseReference
	and gld_child.[Node].GetLevel() > 2

where	loc.[node].GetLevel() = 2
print N'Table [gisLocationDenormalized] - update calculated records from gisLocation (descendants of level 2): ' + cast(@@rowcount as nvarchar(20))
print N''



-----------------------------------------

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

from	[Giraffe_Archive].[dbo].[gisLocation] loc
left join	[Giraffe_Archive].[dbo].[gisBaseReference] gbr
on	gbr.idfsGISBaseReference = loc.idfsLocation
left join	[Giraffe_Archive].[dbo].[gisReferenceType] grt
on	grt.idfsGISReferenceType = gbr.idfsGISReferenceType

join	[Falcon_Archive].[dbo].[trtLanguageToCP] lang_cp
on	lang_cp.idfCustomizationPackage = @idfCustomizationPackage
join	[Giraffe_Archive].[dbo].[trtBaseReference] lang
on	lang.idfsBaseReference = lang_cp.idfsLanguage

left join	[Giraffe_Archive].[dbo].[gisStringNameTranslation] gsnt
on	gsnt.idfsGISBaseReference = gbr.idfsGISBaseReference
	and gsnt.idfsLanguage = lang.idfsBaseReference

join	[Giraffe_Archive].[dbo].[gisLocationDenormalized] gld_ex
on	gld_ex.idfsLocation = loc.idfsLocation
	and gld_ex.idfsLanguage = lang.idfsBaseReference

where	loc.[node].GetLevel() = 3
print N'Table [gisLocationDenormalized] - update calculated records from gisLocation (level 3): ' + cast(@@rowcount as nvarchar(20))




--

insert into	[Giraffe_Archive].[dbo].[gisLocationDenormalized]
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

from	[Giraffe_Archive].[dbo].[gisLocation] loc
join	[Giraffe_Archive].[dbo].[gisBaseReference] gbr
on	gbr.idfsGISBaseReference = loc.idfsLocation
join	[Giraffe_Archive].[dbo].[gisReferenceType] grt
on	grt.idfsGISReferenceType = gbr.idfsGISReferenceType

join	[Falcon_Archive].[dbo].[trtLanguageToCP] lang_cp
on	lang_cp.idfCustomizationPackage = @idfCustomizationPackage
join	[Giraffe_Archive].[dbo].[trtBaseReference] lang
on	lang.idfsBaseReference = lang_cp.idfsLanguage

left join	[Giraffe_Archive].[dbo].[gisStringNameTranslation] gsnt
on	gsnt.idfsGISBaseReference = gbr.idfsGISBaseReference
	and gsnt.idfsLanguage = lang.idfsBaseReference

left join	[Giraffe_Archive].[dbo].[gisLocationDenormalized] gld_lev_up
on	gld_lev_up.[Node] = loc.[node].GetAncestor(1)
	and gld_lev_up.idfsLanguage = lang.idfsBaseReference

left join	[Giraffe_Archive].[dbo].[gisLocationDenormalized] gld_ex
on	gld_ex.idfsLocation = loc.idfsLocation
	and gld_ex.idfsLanguage = lang.idfsBaseReference

where	loc.[node].GetLevel() = 3
		and gld_ex.idfsLocation is null
print N'Table [gisLocationDenormalized] - insert calculated records from gisLocation (level 3): ' + cast(@@rowcount as nvarchar(20))



--

update	gld_child
set		gld_child.[Level3ID] = loc.idfsLocation,
		gld_child.[Level3Name] = coalesce(gsnt.strTextString, gbr.strDefault, gld_ex.[Level3Name])
from	[Giraffe_Archive].[dbo].[gisLocation] loc
join	[Giraffe_Archive].[dbo].[gisBaseReference] gbr
on	gbr.idfsGISBaseReference = loc.idfsLocation
join	[Giraffe_Archive].[dbo].[gisReferenceType] grt
on	grt.idfsGISReferenceType = gbr.idfsGISReferenceType

join	[Falcon_Archive].[dbo].[trtLanguageToCP] lang_cp
on	lang_cp.idfCustomizationPackage = @idfCustomizationPackage
join	[Giraffe_Archive].[dbo].[trtBaseReference] lang
on	lang.idfsBaseReference = lang_cp.idfsLanguage

left join	[Giraffe_Archive].[dbo].[gisStringNameTranslation] gsnt
on	gsnt.idfsGISBaseReference = gbr.idfsGISBaseReference
	and gsnt.idfsLanguage = lang.idfsBaseReference

join	[Giraffe_Archive].[dbo].[gisLocationDenormalized] gld_ex
on	gld_ex.idfsLocation = loc.idfsLocation
	and gld_ex.idfsLanguage = lang.idfsBaseReference

join	[Giraffe_Archive].[dbo].[gisLocationDenormalized] gld_child
on	gld_child.[Node].IsDescendantOf(gld_ex.[Node]) = 1
	and gld_child.idfsLanguage = lang.idfsBaseReference
	and gld_child.[Node].GetLevel() > 3

where	loc.[node].GetLevel() = 3
print N'Table [gisLocationDenormalized] - update calculated records from gisLocation (descendants of level 3): ' + cast(@@rowcount as nvarchar(20))
print N''




------------------------------------

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

from	[Giraffe_Archive].[dbo].[gisLocation] loc
left join	[Giraffe_Archive].[dbo].[gisBaseReference] gbr
on	gbr.idfsGISBaseReference = loc.idfsLocation
left join	[Giraffe_Archive].[dbo].[gisReferenceType] grt
on	grt.idfsGISReferenceType = gbr.idfsGISReferenceType

join	[Falcon_Archive].[dbo].[trtLanguageToCP] lang_cp
on	lang_cp.idfCustomizationPackage = @idfCustomizationPackage
join	[Giraffe_Archive].[dbo].[trtBaseReference] lang
on	lang.idfsBaseReference = lang_cp.idfsLanguage

left join	[Giraffe_Archive].[dbo].[gisStringNameTranslation] gsnt
on	gsnt.idfsGISBaseReference = gbr.idfsGISBaseReference
	and gsnt.idfsLanguage = lang.idfsBaseReference

join	[Giraffe_Archive].[dbo].[gisLocationDenormalized] gld_ex
on	gld_ex.idfsLocation = loc.idfsLocation
	and gld_ex.idfsLanguage = lang.idfsBaseReference

where	loc.[node].GetLevel() = 4
print N'Table [gisLocationDenormalized] - update calculated records from gisLocation (level 4): ' + cast(@@rowcount as nvarchar(20))




-------------------------------------------

insert into	[Giraffe_Archive].[dbo].[gisLocationDenormalized]
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

from	[Giraffe_Archive].[dbo].[gisLocation] loc
join	[Giraffe_Archive].[dbo].[gisBaseReference] gbr
on	gbr.idfsGISBaseReference = loc.idfsLocation
join	[Giraffe_Archive].[dbo].[gisReferenceType] grt
on	grt.idfsGISReferenceType = gbr.idfsGISReferenceType

join	[Falcon_Archive].[dbo].[trtLanguageToCP] lang_cp
on	lang_cp.idfCustomizationPackage = @idfCustomizationPackage
join	[Giraffe_Archive].[dbo].[trtBaseReference] lang
on	lang.idfsBaseReference = lang_cp.idfsLanguage

left join	[Giraffe_Archive].[dbo].[gisStringNameTranslation] gsnt
on	gsnt.idfsGISBaseReference = gbr.idfsGISBaseReference
	and gsnt.idfsLanguage = lang.idfsBaseReference

left join	[Giraffe_Archive].[dbo].[gisLocationDenormalized] gld_lev_up
on	gld_lev_up.[Node] = loc.[node].GetAncestor(1)
	and gld_lev_up.idfsLanguage = lang.idfsBaseReference

left join	[Giraffe_Archive].[dbo].[gisLocationDenormalized] gld_ex
on	gld_ex.idfsLocation = loc.idfsLocation
	and gld_ex.idfsLanguage = lang.idfsBaseReference

where	loc.[node].GetLevel() = 4
		and gld_ex.idfsLocation is null
print N'Table [gisLocationDenormalized] - insert calculated records from gisLocation (level 4): ' + cast(@@rowcount as nvarchar(20))



--------------------------------------------------------

update	gld_child
set		gld_child.[Level4ID] = loc.idfsLocation,
		gld_child.[Level4Name] = coalesce(gsnt.strTextString, gbr.strDefault, gld_ex.[Level4Name])
from	[Giraffe_Archive].[dbo].[gisLocation] loc
join	[Giraffe_Archive].[dbo].[gisBaseReference] gbr
on	gbr.idfsGISBaseReference = loc.idfsLocation
join	[Giraffe_Archive].[dbo].[gisReferenceType] grt
on	grt.idfsGISReferenceType = gbr.idfsGISReferenceType

join	[Falcon_Archive].[dbo].[trtLanguageToCP] lang_cp
on	lang_cp.idfCustomizationPackage = @idfCustomizationPackage
join	[Giraffe_Archive].[dbo].[trtBaseReference] lang
on	lang.idfsBaseReference = lang_cp.idfsLanguage

left join	[Giraffe_Archive].[dbo].[gisStringNameTranslation] gsnt
on	gsnt.idfsGISBaseReference = gbr.idfsGISBaseReference
	and gsnt.idfsLanguage = lang.idfsBaseReference

join	[Giraffe_Archive].[dbo].[gisLocationDenormalized] gld_ex
on	gld_ex.idfsLocation = loc.idfsLocation
	and gld_ex.idfsLanguage = lang.idfsBaseReference

join	[Giraffe_Archive].[dbo].[gisLocationDenormalized] gld_child
on	gld_child.[Node].IsDescendantOf(gld_ex.[Node]) = 1
	and gld_child.idfsLanguage = lang.idfsBaseReference
	and gld_child.[Node].GetLevel() > 4

where	loc.[node].GetLevel() = 4
print N'Table [gisLocationDenormalized] - update calculated records from gisLocation (descendants of level 4): ' + cast(@@rowcount as nvarchar(20))
print N''




print N'Calculate records in EIDSSv7 - [gisLocationDenormalized] - end'
/************************************************************
* Calculate records in EIDSSv7 - [gisLocationDenormalized] - end
************************************************************/

print N''
print N''
print N''



---

print N''
print N'Insert records - GIS Reference tables - end'
print N''
print N''
/************************************************************
* Insert records - GIS Reference tables - end
************************************************************/


-------------------------------------------------------

/************************************************************
* Insert records - Flexible Forms tables - start
************************************************************/
print N''
print N'Insert records - Flexible Forms tables - start'
print N''


--

/************************************************************
* Insert records - [ffParameterType]
************************************************************/
insert into [Giraffe_Archive].[dbo].[ffParameterType] 

(

					[idfsParameterType]

					, [idfsReferenceType]

					, [intRowStatus]

					, [rowguid]

					, [strMaintenanceFlag]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_trtBaseReference_idfsParameterType_v7.[idfsBaseReference]

					, j_trtReferenceType_idfsReferenceType_v7.[idfsReferenceType]

					, ffParameterType_v6.[intRowStatus]

					, ffParameterType_v6.[rowguid]

					, ffParameterType_v6.[strMaintenanceFlag]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsParameterType":' + isnull(cast(ffParameterType_v6.[idfsParameterType] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[ffParameterType] ffParameterType_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsParameterType_v7

		on	


					j_trtBaseReference_idfsParameterType_v7.[idfsBaseReference] = ffParameterType_v6.[idfsParameterType] 

					left join	[Giraffe_Archive].[dbo].[trtReferenceType] j_trtReferenceType_idfsReferenceType_v7

		on	


					j_trtReferenceType_idfsReferenceType_v7.[idfsReferenceType] = ffParameterType_v6.[idfsReferenceType] 
left join	[Giraffe_Archive].[dbo].[ffParameterType] ffParameterType_v7 
on	

					ffParameterType_v7.[idfsParameterType] = ffParameterType_v6.[idfsParameterType] 
where ffParameterType_v7.[idfsParameterType] is null 
print N'Table [ffParameterType] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [ffFormTemplate]
************************************************************/
insert into [Giraffe_Archive].[dbo].[ffFormTemplate] 

(

					[idfsFormTemplate]

					, [idfsFormType]

					, [blnUNI]

					, [strNote]

					, [intRowStatus]

					, [rowguid]

					, [strMaintenanceFlag]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_trtBaseReference_idfsFormTemplate_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsFormType_v7.[idfsBaseReference]

					, ffFormTemplate_v6.[blnUNI]

					, ffFormTemplate_v6.[strNote]

					, ffFormTemplate_v6.[intRowStatus]

					, ffFormTemplate_v6.[rowguid]

					, ffFormTemplate_v6.[strMaintenanceFlag]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsFormTemplate":' + isnull(cast(ffFormTemplate_v6.[idfsFormTemplate] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[ffFormTemplate] ffFormTemplate_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsFormTemplate_v7

		on	


					j_trtBaseReference_idfsFormTemplate_v7.[idfsBaseReference] = ffFormTemplate_v6.[idfsFormTemplate] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsFormType_v7

		on	


					j_trtBaseReference_idfsFormType_v7.[idfsBaseReference] = ffFormTemplate_v6.[idfsFormType] 
left join	[Giraffe_Archive].[dbo].[ffFormTemplate] ffFormTemplate_v7 
on	

					ffFormTemplate_v7.[idfsFormTemplate] = ffFormTemplate_v6.[idfsFormTemplate] 
where ffFormTemplate_v7.[idfsFormTemplate] is null 
print N'Table [ffFormTemplate] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [ffParameterFixedPresetValue]
************************************************************/
insert into [Giraffe_Archive].[dbo].[ffParameterFixedPresetValue] 

(

					[idfsParameterFixedPresetValue]

					, [idfsParameterType]

					, [intRowStatus]

					, [rowguid]

					, [strMaintenanceFlag]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_trtBaseReference_idfsParameterFixedPresetValue_v7.[idfsBaseReference]

					, j_ffParameterType_idfsParameterType_v7.[idfsParameterType]

					, ffParameterFixedPresetValue_v6.[intRowStatus]

					, ffParameterFixedPresetValue_v6.[rowguid]

					, ffParameterFixedPresetValue_v6.[strMaintenanceFlag]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsParameterFixedPresetValue":' + isnull(cast(ffParameterFixedPresetValue_v6.[idfsParameterFixedPresetValue] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[ffParameterFixedPresetValue] ffParameterFixedPresetValue_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsParameterFixedPresetValue_v7

		on	


					j_trtBaseReference_idfsParameterFixedPresetValue_v7.[idfsBaseReference] = ffParameterFixedPresetValue_v6.[idfsParameterFixedPresetValue] 

					left join	[Giraffe_Archive].[dbo].[ffParameterType] j_ffParameterType_idfsParameterType_v7

		on	


					j_ffParameterType_idfsParameterType_v7.[idfsParameterType] = ffParameterFixedPresetValue_v6.[idfsParameterType] 
left join	[Giraffe_Archive].[dbo].[ffParameterFixedPresetValue] ffParameterFixedPresetValue_v7 
on	

					ffParameterFixedPresetValue_v7.[idfsParameterFixedPresetValue] = ffParameterFixedPresetValue_v6.[idfsParameterFixedPresetValue] 
where ffParameterFixedPresetValue_v7.[idfsParameterFixedPresetValue] is null 
print N'Table [ffParameterFixedPresetValue] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [ffSection]
************************************************************/
insert into [Giraffe_Archive].[dbo].[ffSection] 

(

					[idfsSection]

					, [idfsParentSection]

					, [idfsFormType]

					, [intOrder]

					, [blnGrid]

					, [blnFixedRowSet]

					, [intRowStatus]

					, [rowguid]

					, [idfsMatrixType]

					, [strMaintenanceFlag]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_trtBaseReference_idfsSection_v7.[idfsBaseReference]

					, ffSection_v6.[idfsParentSection]

					, j_trtBaseReference_idfsFormType_v7.[idfsBaseReference]

					, ffSection_v6.[intOrder]

					, ffSection_v6.[blnGrid]

					, ffSection_v6.[blnFixedRowSet]

					, ffSection_v6.[intRowStatus]

					, ffSection_v6.[rowguid]

					, j_trtMatrixType_idfsMatrixType_v7.[idfsMatrixType]

					, ffSection_v6.[strMaintenanceFlag]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsSection":' + isnull(cast(ffSection_v6.[idfsSection] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[ffSection] ffSection_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsSection_v7

		on	


					j_trtBaseReference_idfsSection_v7.[idfsBaseReference] = ffSection_v6.[idfsSection] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsFormType_v7

		on	


					j_trtBaseReference_idfsFormType_v7.[idfsBaseReference] = ffSection_v6.[idfsFormType] 

					left join	[Giraffe_Archive].[dbo].[ffSection] j_ffSection_idfsParentSection_v7

		on	


					j_ffSection_idfsParentSection_v7.[idfsSection] = ffSection_v6.[idfsParentSection] 

					left join	[Giraffe_Archive].[dbo].[trtMatrixType] j_trtMatrixType_idfsMatrixType_v7

		on	


					j_trtMatrixType_idfsMatrixType_v7.[idfsMatrixType] = ffSection_v6.[idfsMatrixType] 
left join	[Giraffe_Archive].[dbo].[ffSection] ffSection_v7 
on	

					ffSection_v7.[idfsSection] = ffSection_v6.[idfsSection] 
where ffSection_v7.[idfsSection] is null 
print N'Table [ffSection] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [ffParameter]
************************************************************/
insert into [Giraffe_Archive].[dbo].[ffParameter] 

(

					[idfsParameter]

					, [idfsSection]

					, [idfsParameterCaption]

					, [idfsParameterType]

					, [idfsFormType]

					, [idfsEditor]

					, [strNote]

					, [intOrder]

					, [intHACode]

					, [intRowStatus]

					, [rowguid]

					, [strMaintenanceFlag]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_trtBaseReference_idfsParameter_v7.[idfsBaseReference]

					, j_ffSection_idfsSection_v7.[idfsSection]

					, j_trtBaseReference_idfsParameterCaption_v7.[idfsBaseReference]

					, j_ffParameterType_idfsParameterType_v7.[idfsParameterType]

					, j_trtBaseReference_idfsFormType_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsEditor_v7.[idfsBaseReference]

					, ffParameter_v6.[strNote]

					, ffParameter_v6.[intOrder]

					, ffParameter_v6.[intHACode]

					, ffParameter_v6.[intRowStatus]

					, ffParameter_v6.[rowguid]

					, ffParameter_v6.[strMaintenanceFlag]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsParameter":' + isnull(cast(ffParameter_v6.[idfsParameter] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[ffParameter] ffParameter_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsParameter_v7

		on	


					j_trtBaseReference_idfsParameter_v7.[idfsBaseReference] = ffParameter_v6.[idfsParameter] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsFormType_v7

		on	


					j_trtBaseReference_idfsFormType_v7.[idfsBaseReference] = ffParameter_v6.[idfsFormType] 

					left join	[Giraffe_Archive].[dbo].[ffParameterType] j_ffParameterType_idfsParameterType_v7

		on	


					j_ffParameterType_idfsParameterType_v7.[idfsParameterType] = ffParameter_v6.[idfsParameterType] 

					left join	[Giraffe_Archive].[dbo].[ffSection] j_ffSection_idfsSection_v7

		on	


					j_ffSection_idfsSection_v7.[idfsSection] = ffParameter_v6.[idfsSection] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsParameterCaption_v7

		on	


					j_trtBaseReference_idfsParameterCaption_v7.[idfsBaseReference] = ffParameter_v6.[idfsParameterCaption] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsEditor_v7

		on	


					j_trtBaseReference_idfsEditor_v7.[idfsBaseReference] = ffParameter_v6.[idfsEditor] 
left join	[Giraffe_Archive].[dbo].[ffParameter] ffParameter_v7 
on	

					ffParameter_v7.[idfsParameter] = ffParameter_v6.[idfsParameter] 
where ffParameter_v7.[idfsParameter] is null 
print N'Table [ffParameter] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [ffDecorElement]
************************************************************/
insert into [Giraffe_Archive].[dbo].[ffDecorElement] 

(

					[idfDecorElement]

					, [idfsDecorElementType]

					, [idfsLanguage]

					, [idfsFormTemplate]

					, [idfsSection]

					, [intRowStatus]

					, [rowguid]

					, [strMaintenanceFlag]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					ffDecorElement_v6.[idfDecorElement]

					, j_trtBaseReference_idfsDecorElementType_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsLanguage_v7.[idfsBaseReference]

					, j_ffFormTemplate_idfsFormTemplate_v7.[idfsFormTemplate]

					, j_ffSection_idfsSection_v7.[idfsSection]

					, ffDecorElement_v6.[intRowStatus]

					, ffDecorElement_v6.[rowguid]

					, ffDecorElement_v6.[strMaintenanceFlag]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfDecorElement":' + isnull(cast(ffDecorElement_v6.[idfDecorElement] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[ffDecorElement] ffDecorElement_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsDecorElementType_v7

		on	


					j_trtBaseReference_idfsDecorElementType_v7.[idfsBaseReference] = ffDecorElement_v6.[idfsDecorElementType] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsLanguage_v7

		on	


					j_trtBaseReference_idfsLanguage_v7.[idfsBaseReference] = ffDecorElement_v6.[idfsLanguage] 

					inner join	[Giraffe_Archive].[dbo].[ffFormTemplate] j_ffFormTemplate_idfsFormTemplate_v7

		on	


					j_ffFormTemplate_idfsFormTemplate_v7.[idfsFormTemplate] = ffDecorElement_v6.[idfsFormTemplate] 

					left join	[Giraffe_Archive].[dbo].[ffSection] j_ffSection_idfsSection_v7

		on	


					j_ffSection_idfsSection_v7.[idfsSection] = ffDecorElement_v6.[idfsSection] 
left join	[Giraffe_Archive].[dbo].[ffDecorElement] ffDecorElement_v7 
on	

					ffDecorElement_v7.[idfDecorElement] = ffDecorElement_v6.[idfDecorElement] 
where ffDecorElement_v7.[idfDecorElement] is null 
print N'Table [ffDecorElement] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [ffDecorElementLine]
************************************************************/
insert into [Giraffe_Archive].[dbo].[ffDecorElementLine] 

(

					[idfDecorElement]

					, [intLeft]

					, [intTop]

					, [intWidth]

					, [intHeight]

					, [intColor]

					, [blnOrientation]

					, [intRowStatus]

					, [rowguid]

					, [strMaintenanceFlag]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_ffDecorElement_idfDecorElement_v7.[idfDecorElement]

					, ffDecorElementLine_v6.[intLeft]

					, ffDecorElementLine_v6.[intTop]

					, ffDecorElementLine_v6.[intWidth]

					, ffDecorElementLine_v6.[intHeight]

					, ffDecorElementLine_v6.[intColor]

					, ffDecorElementLine_v6.[blnOrientation]

					, ffDecorElementLine_v6.[intRowStatus]

					, ffDecorElementLine_v6.[rowguid]

					, ffDecorElementLine_v6.[strMaintenanceFlag]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfDecorElement":' + isnull(cast(ffDecorElementLine_v6.[idfDecorElement] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[ffDecorElementLine] ffDecorElementLine_v6 


					inner join	[Giraffe_Archive].[dbo].[ffDecorElement] j_ffDecorElement_idfDecorElement_v7

		on	


					j_ffDecorElement_idfDecorElement_v7.[idfDecorElement] = ffDecorElementLine_v6.[idfDecorElement] 
left join	[Giraffe_Archive].[dbo].[ffDecorElementLine] ffDecorElementLine_v7 
on	

					ffDecorElementLine_v7.[idfDecorElement] = ffDecorElementLine_v6.[idfDecorElement] 
where ffDecorElementLine_v7.[idfDecorElement] is null 
print N'Table [ffDecorElementLine] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [ffDecorElementText]
************************************************************/
insert into [Giraffe_Archive].[dbo].[ffDecorElementText] 

(

					[idfDecorElement]

					, [idfsBaseReference]

					, [intFontSize]

					, [intFontStyle]

					, [intColor]

					, [intLeft]

					, [intTop]

					, [intWidth]

					, [intHeight]

					, [intRowStatus]

					, [rowguid]

					, [strMaintenanceFlag]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_ffDecorElement_idfDecorElement_v7.[idfDecorElement]

					, j_trtBaseReference_idfsBaseReference_v7.[idfsBaseReference]

					, ffDecorElementText_v6.[intFontSize]

					, ffDecorElementText_v6.[intFontStyle]

					, ffDecorElementText_v6.[intColor]

					, ffDecorElementText_v6.[intLeft]

					, ffDecorElementText_v6.[intTop]

					, ffDecorElementText_v6.[intWidth]

					, ffDecorElementText_v6.[intHeight]

					, ffDecorElementText_v6.[intRowStatus]

					, ffDecorElementText_v6.[rowguid]

					, ffDecorElementText_v6.[strMaintenanceFlag]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfDecorElement":' + isnull(cast(ffDecorElementText_v6.[idfDecorElement] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[ffDecorElementText] ffDecorElementText_v6 


					inner join	[Giraffe_Archive].[dbo].[ffDecorElement] j_ffDecorElement_idfDecorElement_v7

		on	


					j_ffDecorElement_idfDecorElement_v7.[idfDecorElement] = ffDecorElementText_v6.[idfDecorElement] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsBaseReference_v7

		on	


					j_trtBaseReference_idfsBaseReference_v7.[idfsBaseReference] = ffDecorElementText_v6.[idfsBaseReference] 
left join	[Giraffe_Archive].[dbo].[ffDecorElementText] ffDecorElementText_v7 
on	

					ffDecorElementText_v7.[idfDecorElement] = ffDecorElementText_v6.[idfDecorElement] 
where ffDecorElementText_v7.[idfDecorElement] is null 
print N'Table [ffDecorElementText] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [ffParameterForTemplate]
************************************************************/
insert into [Giraffe_Archive].[dbo].[ffParameterForTemplate] 

(

					[idfsParameter]

					, [idfsFormTemplate]

					, [idfsEditMode]

					, [blnFreeze]

					, [intRowStatus]

					, [rowguid]

					, [strMaintenanceFlag]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_ffParameter_idfsParameter_v7.[idfsParameter]

					, j_ffFormTemplate_idfsFormTemplate_v7.[idfsFormTemplate]

					, j_trtBaseReference_idfsEditMode_v7.[idfsBaseReference]

					, ffParameterForTemplate_v6.[blnFreeze]

					, ffParameterForTemplate_v6.[intRowStatus]

					, ffParameterForTemplate_v6.[rowguid]

					, ffParameterForTemplate_v6.[strMaintenanceFlag]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsParameter":' + isnull(cast(ffParameterForTemplate_v6.[idfsParameter] as nvarchar(20)), N'null') + N',' + N'"idfsFormTemplate":' + isnull(cast(ffParameterForTemplate_v6.[idfsFormTemplate] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[ffParameterForTemplate] ffParameterForTemplate_v6 


					inner join	[Giraffe_Archive].[dbo].[ffFormTemplate] j_ffFormTemplate_idfsFormTemplate_v7

		on	


					j_ffFormTemplate_idfsFormTemplate_v7.[idfsFormTemplate] = ffParameterForTemplate_v6.[idfsFormTemplate] 

					inner join	[Giraffe_Archive].[dbo].[ffParameter] j_ffParameter_idfsParameter_v7

		on	


					j_ffParameter_idfsParameter_v7.[idfsParameter] = ffParameterForTemplate_v6.[idfsParameter] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsEditMode_v7

		on	


					j_trtBaseReference_idfsEditMode_v7.[idfsBaseReference] = ffParameterForTemplate_v6.[idfsEditMode] 
left join	[Giraffe_Archive].[dbo].[ffParameterForTemplate] ffParameterForTemplate_v7 
on	

					ffParameterForTemplate_v7.[idfsParameter] = ffParameterForTemplate_v6.[idfsParameter] 

					and ffParameterForTemplate_v7.[idfsFormTemplate] = ffParameterForTemplate_v6.[idfsFormTemplate] 
where ffParameterForTemplate_v7.[idfsParameter] is null 
print N'Table [ffParameterForTemplate] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [ffParameterDesignOption]
************************************************************/
insert into [Giraffe_Archive].[dbo].[ffParameterDesignOption] 

(

					[idfParameterDesignOption]

					, [idfsParameter]

					, [idfsLanguage]

					, [idfsFormTemplate]

					, [intLeft]

					, [intTop]

					, [intWidth]

					, [intHeight]

					, [intScheme]

					, [intLabelSize]

					, [intOrder]

					, [intRowStatus]

					, [rowguid]

					, [strMaintenanceFlag]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					ffParameterDesignOption_v6.[idfParameterDesignOption]

					, j_ffParameter_idfsParameter_v7.[idfsParameter]

					, j_trtBaseReference_idfsLanguage_v7.[idfsBaseReference]

					, j_ffFormTemplate_idfsFormTemplate_v7.[idfsFormTemplate]

					, ffParameterDesignOption_v6.[intLeft]

					, ffParameterDesignOption_v6.[intTop]

					, ffParameterDesignOption_v6.[intWidth]

					, ffParameterDesignOption_v6.[intHeight]

					, ffParameterDesignOption_v6.[intScheme]

					, ffParameterDesignOption_v6.[intLabelSize]

					, ffParameterDesignOption_v6.[intOrder]

					, ffParameterDesignOption_v6.[intRowStatus]

					, ffParameterDesignOption_v6.[rowguid]

					, ffParameterDesignOption_v6.[strMaintenanceFlag]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfParameterDesignOption":' + isnull(cast(ffParameterDesignOption_v6.[idfParameterDesignOption] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[ffParameterDesignOption] ffParameterDesignOption_v6 


					inner join	[Giraffe_Archive].[dbo].[ffParameter] j_ffParameter_idfsParameter_v7

		on	


					j_ffParameter_idfsParameter_v7.[idfsParameter] = ffParameterDesignOption_v6.[idfsParameter] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsLanguage_v7

		on	


					j_trtBaseReference_idfsLanguage_v7.[idfsBaseReference] = ffParameterDesignOption_v6.[idfsLanguage] 

					left join	[Giraffe_Archive].[dbo].[ffFormTemplate] j_ffFormTemplate_idfsFormTemplate_v7

		on	


					j_ffFormTemplate_idfsFormTemplate_v7.[idfsFormTemplate] = ffParameterDesignOption_v6.[idfsFormTemplate] 
left join	[Giraffe_Archive].[dbo].[ffParameterDesignOption] ffParameterDesignOption_v7 
on	

					ffParameterDesignOption_v7.[idfParameterDesignOption] = ffParameterDesignOption_v6.[idfParameterDesignOption] 
where ffParameterDesignOption_v7.[idfParameterDesignOption] is null 
print N'Table [ffParameterDesignOption] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [ffRuleFunction]
************************************************************/
insert into [Giraffe_Archive].[dbo].[ffRuleFunction] 

(

					[idfsRuleFunction]

					, [intNumberOfParameters]

					, [strMask]

					, [rowguid]

					, [strMaintenanceFlag]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_trtBaseReference_idfsRuleFunction_v7.[idfsBaseReference]

					, ffRuleFunction_v6.[intNumberOfParameters]

					, ffRuleFunction_v6.[strMask]

					, ffRuleFunction_v6.[rowguid]

					, ffRuleFunction_v6.[strMaintenanceFlag]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsRuleFunction":' + isnull(cast(ffRuleFunction_v6.[idfsRuleFunction] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[ffRuleFunction] ffRuleFunction_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsRuleFunction_v7

		on	


					j_trtBaseReference_idfsRuleFunction_v7.[idfsBaseReference] = ffRuleFunction_v6.[idfsRuleFunction] 
left join	[Giraffe_Archive].[dbo].[ffRuleFunction] ffRuleFunction_v7 
on	

					ffRuleFunction_v7.[idfsRuleFunction] = ffRuleFunction_v6.[idfsRuleFunction] 
where ffRuleFunction_v7.[idfsRuleFunction] is null 
print N'Table [ffRuleFunction] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [ffRule]
************************************************************/
insert into [Giraffe_Archive].[dbo].[ffRule] 

(

					[idfsRule]

					, [idfsFormTemplate]

					, [idfsCheckPoint]

					, [idfsRuleMessage]

					, [idfsRuleFunction]

					, [blnNot]

					, [intRowStatus]

					, [rowguid]

					, [strMaintenanceFlag]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_trtBaseReference_idfsRule_v7.[idfsBaseReference]

					, j_ffFormTemplate_idfsFormTemplate_v7.[idfsFormTemplate]

					, j_trtBaseReference_idfsCheckPoint_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsRuleMessage_v7.[idfsBaseReference]

					, j_ffRuleFunction_idfsRuleFunction_v7.[idfsRuleFunction]

					, ffRule_v6.[blnNot]

					, ffRule_v6.[intRowStatus]

					, ffRule_v6.[rowguid]

					, ffRule_v6.[strMaintenanceFlag]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsRule":' + isnull(cast(ffRule_v6.[idfsRule] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[ffRule] ffRule_v6 


					inner join	[Giraffe_Archive].[dbo].[ffFormTemplate] j_ffFormTemplate_idfsFormTemplate_v7

		on	


					j_ffFormTemplate_idfsFormTemplate_v7.[idfsFormTemplate] = ffRule_v6.[idfsFormTemplate] 

					inner join	[Giraffe_Archive].[dbo].[ffRuleFunction] j_ffRuleFunction_idfsRuleFunction_v7

		on	


					j_ffRuleFunction_idfsRuleFunction_v7.[idfsRuleFunction] = ffRule_v6.[idfsRuleFunction] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsRule_v7

		on	


					j_trtBaseReference_idfsRule_v7.[idfsBaseReference] = ffRule_v6.[idfsRule] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsCheckPoint_v7

		on	


					j_trtBaseReference_idfsCheckPoint_v7.[idfsBaseReference] = ffRule_v6.[idfsCheckPoint] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsRuleMessage_v7

		on	


					j_trtBaseReference_idfsRuleMessage_v7.[idfsBaseReference] = ffRule_v6.[idfsRuleMessage] 
left join	[Giraffe_Archive].[dbo].[ffRule] ffRule_v7 
on	

					ffRule_v7.[idfsRule] = ffRule_v6.[idfsRule] 
where ffRule_v7.[idfsRule] is null 
print N'Table [ffRule] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [ffRuleConstant]
************************************************************/
insert into [Giraffe_Archive].[dbo].[ffRuleConstant] 

(

					[idfRuleConstant]

					, [idfsRule]

					, [varConstant]

					, [intRowStatus]

					, [rowguid]

					, [strMaintenanceFlag]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					ffRuleConstant_v6.[idfRuleConstant]

					, j_ffRule_idfsRule_v7.[idfsRule]

					, ffRuleConstant_v6.[varConstant]

					, ffRuleConstant_v6.[intRowStatus]

					, ffRuleConstant_v6.[rowguid]

					, ffRuleConstant_v6.[strMaintenanceFlag]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfRuleConstant":' + isnull(cast(ffRuleConstant_v6.[idfRuleConstant] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[ffRuleConstant] ffRuleConstant_v6 


					inner join	[Giraffe_Archive].[dbo].[ffRule] j_ffRule_idfsRule_v7

		on	


					j_ffRule_idfsRule_v7.[idfsRule] = ffRuleConstant_v6.[idfsRule] 
left join	[Giraffe_Archive].[dbo].[ffRuleConstant] ffRuleConstant_v7 
on	

					ffRuleConstant_v7.[idfRuleConstant] = ffRuleConstant_v6.[idfRuleConstant] 
where ffRuleConstant_v7.[idfRuleConstant] is null 
print N'Table [ffRuleConstant] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [ffParameterForFunction]
************************************************************/
insert into [Giraffe_Archive].[dbo].[ffParameterForFunction] 

(

					[idfParameterForFunction]

					, [idfsParameter]

					, [idfsFormTemplate]

					, [idfsRule]

					, [intOrder]

					, [intRowStatus]

					, [rowguid]

					, [strMaintenanceFlag]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]

					, [strCompareValue]
)
select 

					ffParameterForFunction_v6.[idfParameterForFunction]

					, j_ffParameterForTemplate_idfsParameter_idfsFormTemplate_v7.[idfsParameter]

					, j_ffParameterForTemplate_idfsParameter_idfsFormTemplate_v7.[idfsFormTemplate]

					, j_ffRule_idfsRule_v7.[idfsRule]

					, ffParameterForFunction_v6.[intOrder]

					, ffParameterForFunction_v6.[intRowStatus]

					, ffParameterForFunction_v6.[rowguid]

					, ffParameterForFunction_v6.[strMaintenanceFlag]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfParameterForFunction":' + isnull(cast(ffParameterForFunction_v6.[idfParameterForFunction] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()

					, null /*TODO: Check the rule for the new field in EIDSSv7: strCompareValue*/
from [Falcon_Archive].[dbo].[ffParameterForFunction] ffParameterForFunction_v6 


					inner join	[Giraffe_Archive].[dbo].[ffParameterForTemplate] j_ffParameterForTemplate_idfsParameter_idfsFormTemplate_v7

		on	


					j_ffParameterForTemplate_idfsParameter_idfsFormTemplate_v7.[idfsParameter] = ffParameterForFunction_v6.[idfsParameter] 


					and j_ffParameterForTemplate_idfsParameter_idfsFormTemplate_v7.[idfsFormTemplate] = ffParameterForFunction_v6.[idfsFormTemplate] 

					inner join	[Giraffe_Archive].[dbo].[ffRule] j_ffRule_idfsRule_v7

		on	


					j_ffRule_idfsRule_v7.[idfsRule] = ffParameterForFunction_v6.[idfsRule] 
left join	[Giraffe_Archive].[dbo].[ffParameterForFunction] ffParameterForFunction_v7 
on	

					ffParameterForFunction_v7.[idfParameterForFunction] = ffParameterForFunction_v6.[idfParameterForFunction] 
where ffParameterForFunction_v7.[idfParameterForFunction] is null 
print N'Table [ffParameterForFunction] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [ffParameterForAction]
************************************************************/
insert into [Giraffe_Archive].[dbo].[ffParameterForAction] 

(

					[idfParameterForAction]

					, [idfsParameter]

					, [idfsFormTemplate]

					, [idfsRuleAction]

					, [idfsRule]

					, [intRowStatus]

					, [rowguid]

					, [strMaintenanceFlag]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]

					, [strFillValue]
)
select 

					ffParameterForAction_v6.[idfParameterForAction]

					, j_ffParameterForTemplate_idfsParameter_idfsFormTemplate_v7.[idfsParameter]

					, j_ffParameterForTemplate_idfsParameter_idfsFormTemplate_v7.[idfsFormTemplate]

					, j_trtBaseReference_idfsRuleAction_v7.[idfsBaseReference]

					, j_ffRule_idfsRule_v7.[idfsRule]

					, ffParameterForAction_v6.[intRowStatus]

					, ffParameterForAction_v6.[rowguid]

					, ffParameterForAction_v6.[strMaintenanceFlag]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfParameterForAction":' + isnull(cast(ffParameterForAction_v6.[idfParameterForAction] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()

					, null /*TODO: Check the rule for the new field in EIDSSv7: strFillValue*/
from [Falcon_Archive].[dbo].[ffParameterForAction] ffParameterForAction_v6 


					inner join	[Giraffe_Archive].[dbo].[ffParameterForTemplate] j_ffParameterForTemplate_idfsParameter_idfsFormTemplate_v7

		on	


					j_ffParameterForTemplate_idfsParameter_idfsFormTemplate_v7.[idfsParameter] = ffParameterForAction_v6.[idfsParameter] 


					and j_ffParameterForTemplate_idfsParameter_idfsFormTemplate_v7.[idfsFormTemplate] = ffParameterForAction_v6.[idfsFormTemplate] 

					inner join	[Giraffe_Archive].[dbo].[ffRule] j_ffRule_idfsRule_v7

		on	


					j_ffRule_idfsRule_v7.[idfsRule] = ffParameterForAction_v6.[idfsRule] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsRuleAction_v7

		on	


					j_trtBaseReference_idfsRuleAction_v7.[idfsBaseReference] = ffParameterForAction_v6.[idfsRuleAction] 
left join	[Giraffe_Archive].[dbo].[ffParameterForAction] ffParameterForAction_v7 
on	

					ffParameterForAction_v7.[idfParameterForAction] = ffParameterForAction_v6.[idfParameterForAction] 
where ffParameterForAction_v7.[idfParameterForAction] is null 
print N'Table [ffParameterForAction] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [ffSectionForTemplate]
************************************************************/
insert into [Giraffe_Archive].[dbo].[ffSectionForTemplate] 

(

					[idfsFormTemplate]

					, [idfsSection]

					, [blnFreeze]

					, [intRowStatus]

					, [rowguid]

					, [strMaintenanceFlag]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_ffFormTemplate_idfsFormTemplate_v7.[idfsFormTemplate]

					, j_ffSection_idfsSection_v7.[idfsSection]

					, ffSectionForTemplate_v6.[blnFreeze]

					, ffSectionForTemplate_v6.[intRowStatus]

					, ffSectionForTemplate_v6.[rowguid]

					, ffSectionForTemplate_v6.[strMaintenanceFlag]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsFormTemplate":' + isnull(cast(ffSectionForTemplate_v6.[idfsFormTemplate] as nvarchar(20)), N'null') + N',' + N'"idfsSection":' + isnull(cast(ffSectionForTemplate_v6.[idfsSection] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[ffSectionForTemplate] ffSectionForTemplate_v6 


					inner join	[Giraffe_Archive].[dbo].[ffFormTemplate] j_ffFormTemplate_idfsFormTemplate_v7

		on	


					j_ffFormTemplate_idfsFormTemplate_v7.[idfsFormTemplate] = ffSectionForTemplate_v6.[idfsFormTemplate] 

					inner join	[Giraffe_Archive].[dbo].[ffSection] j_ffSection_idfsSection_v7

		on	


					j_ffSection_idfsSection_v7.[idfsSection] = ffSectionForTemplate_v6.[idfsSection] 
left join	[Giraffe_Archive].[dbo].[ffSectionForTemplate] ffSectionForTemplate_v7 
on	

					ffSectionForTemplate_v7.[idfsFormTemplate] = ffSectionForTemplate_v6.[idfsFormTemplate] 

					and ffSectionForTemplate_v7.[idfsSection] = ffSectionForTemplate_v6.[idfsSection] 
where ffSectionForTemplate_v7.[idfsFormTemplate] is null 
print N'Table [ffSectionForTemplate] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [ffSectionDesignOption]
************************************************************/
insert into [Giraffe_Archive].[dbo].[ffSectionDesignOption] 

(

					[idfSectionDesignOption]

					, [idfsLanguage]

					, [idfsFormTemplate]

					, [idfsSection]

					, [intLeft]

					, [intTop]

					, [intWidth]

					, [intHeight]

					, [intOrder]

					, [intRowStatus]

					, [rowguid]

					, [intCaptionHeight]

					, [strMaintenanceFlag]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					ffSectionDesignOption_v6.[idfSectionDesignOption]

					, j_trtBaseReference_idfsLanguage_v7.[idfsBaseReference]

					, j_ffSectionForTemplate_idfsFormTemplate_idfsSection_v7.[idfsFormTemplate]

					, j_ffSectionForTemplate_idfsFormTemplate_idfsSection_v7.[idfsSection]

					, ffSectionDesignOption_v6.[intLeft]

					, ffSectionDesignOption_v6.[intTop]

					, ffSectionDesignOption_v6.[intWidth]

					, ffSectionDesignOption_v6.[intHeight]

					, ffSectionDesignOption_v6.[intOrder]

					, ffSectionDesignOption_v6.[intRowStatus]

					, ffSectionDesignOption_v6.[rowguid]

					, ffSectionDesignOption_v6.[intCaptionHeight]

					, ffSectionDesignOption_v6.[strMaintenanceFlag]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfSectionDesignOption":' + isnull(cast(ffSectionDesignOption_v6.[idfSectionDesignOption] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[ffSectionDesignOption] ffSectionDesignOption_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsLanguage_v7

		on	


					j_trtBaseReference_idfsLanguage_v7.[idfsBaseReference] = ffSectionDesignOption_v6.[idfsLanguage] 

					inner join	[Giraffe_Archive].[dbo].[ffSectionForTemplate] j_ffSectionForTemplate_idfsFormTemplate_idfsSection_v7

		on	


					j_ffSectionForTemplate_idfsFormTemplate_idfsSection_v7.[idfsFormTemplate] = ffSectionDesignOption_v6.[idfsFormTemplate] 


					and j_ffSectionForTemplate_idfsFormTemplate_idfsSection_v7.[idfsSection] = ffSectionDesignOption_v6.[idfsSection] 
left join	[Giraffe_Archive].[dbo].[ffSectionDesignOption] ffSectionDesignOption_v7 
on	

					ffSectionDesignOption_v7.[idfSectionDesignOption] = ffSectionDesignOption_v6.[idfSectionDesignOption] 
where ffSectionDesignOption_v7.[idfSectionDesignOption] is null 
print N'Table [ffSectionDesignOption] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [ffSectionForAction]
************************************************************/
insert into [Giraffe_Archive].[dbo].[ffSectionForAction] 

(

					[idfSectionForAction]

					, [idfsFormTemplate]

					, [idfsRuleAction]

					, [idfsRule]

					, [idfsSection]

					, [intRowStatus]

					, [rowguid]

					, [strMaintenanceFlag]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					ffSectionForAction_v6.[idfSectionForAction]

					, j_ffSectionForTemplate_idfsFormTemplate_idfsSection_v7.[idfsFormTemplate]

					, j_trtBaseReference_idfsRuleAction_v7.[idfsBaseReference]

					, j_ffRule_idfsRule_v7.[idfsRule]

					, j_ffSectionForTemplate_idfsFormTemplate_idfsSection_v7.[idfsSection]

					, ffSectionForAction_v6.[intRowStatus]

					, ffSectionForAction_v6.[rowguid]

					, ffSectionForAction_v6.[strMaintenanceFlag]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfSectionForAction":' + isnull(cast(ffSectionForAction_v6.[idfSectionForAction] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[ffSectionForAction] ffSectionForAction_v6 


					inner join	[Giraffe_Archive].[dbo].[ffSectionForTemplate] j_ffSectionForTemplate_idfsFormTemplate_idfsSection_v7

		on	


					j_ffSectionForTemplate_idfsFormTemplate_idfsSection_v7.[idfsFormTemplate] = ffSectionForAction_v6.[idfsFormTemplate] 


					and j_ffSectionForTemplate_idfsFormTemplate_idfsSection_v7.[idfsSection] = ffSectionForAction_v6.[idfsSection] 

					left join	[Giraffe_Archive].[dbo].[ffRule] j_ffRule_idfsRule_v7

		on	


					j_ffRule_idfsRule_v7.[idfsRule] = ffSectionForAction_v6.[idfsRule] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsRuleAction_v7

		on	


					j_trtBaseReference_idfsRuleAction_v7.[idfsBaseReference] = ffSectionForAction_v6.[idfsRuleAction] 
left join	[Giraffe_Archive].[dbo].[ffSectionForAction] ffSectionForAction_v7 
on	

					ffSectionForAction_v7.[idfSectionForAction] = ffSectionForAction_v6.[idfSectionForAction] 
where ffSectionForAction_v7.[idfSectionForAction] is null 
print N'Table [ffSectionForAction] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [ffDeterminantType]
************************************************************/
insert into [Giraffe_Archive].[dbo].[ffDeterminantType] 

(

					[idfDeterminantType]

					, [idfsReferenceType]

					, [idfsGISReferenceType]

					, [idfsFormType]

					, [intOrder]

					, [rowguid]

					, [strMaintenanceFlag]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					ffDeterminantType_v6.[idfDeterminantType]

					, j_trtReferenceType_idfsReferenceType_v7.[idfsReferenceType]

					, j_gisReferenceType_idfsGISReferenceType_v7.[idfsGISReferenceType]

					, j_trtBaseReference_idfsFormType_v7.[idfsBaseReference]

					, ffDeterminantType_v6.[intOrder]

					, ffDeterminantType_v6.[rowguid]

					, ffDeterminantType_v6.[strMaintenanceFlag]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfDeterminantType":' + isnull(cast(ffDeterminantType_v6.[idfDeterminantType] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[ffDeterminantType] ffDeterminantType_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsFormType_v7

		on	


					j_trtBaseReference_idfsFormType_v7.[idfsBaseReference] = ffDeterminantType_v6.[idfsFormType] 

					left join	[Giraffe_Archive].[dbo].[trtReferenceType] j_trtReferenceType_idfsReferenceType_v7

		on	


					j_trtReferenceType_idfsReferenceType_v7.[idfsReferenceType] = ffDeterminantType_v6.[idfsReferenceType] 

					left join	[Giraffe_Archive].[dbo].[gisReferenceType] j_gisReferenceType_idfsGISReferenceType_v7

		on	


					j_gisReferenceType_idfsGISReferenceType_v7.[idfsGISReferenceType] = ffDeterminantType_v6.[idfsGISReferenceType] 
left join	[Giraffe_Archive].[dbo].[ffDeterminantType] ffDeterminantType_v7 
on	

					ffDeterminantType_v7.[idfDeterminantType] = ffDeterminantType_v6.[idfDeterminantType] 
where ffDeterminantType_v7.[idfDeterminantType] is null 
print N'Table [ffDeterminantType] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [ffDeterminantValue]
************************************************************/
insert into [Giraffe_Archive].[dbo].[ffDeterminantValue] 

(

					[idfDeterminantValue]

					, [idfsFormTemplate]

					, [idfsBaseReference]

					, [idfsGISBaseReference]

					, [intRowStatus]

					, [rowguid]

					, [strMaintenanceFlag]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					ffDeterminantValue_v6.[idfDeterminantValue]

					, j_ffFormTemplate_idfsFormTemplate_v7.[idfsFormTemplate]

					, j_trtBaseReference_idfsBaseReference_v7.[idfsBaseReference]

					, j_gisBaseReference_idfsGISBaseReference_v7.[idfsGISBaseReference]

					, ffDeterminantValue_v6.[intRowStatus]

					, ffDeterminantValue_v6.[rowguid]

					, ffDeterminantValue_v6.[strMaintenanceFlag]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfDeterminantValue":' + isnull(cast(ffDeterminantValue_v6.[idfDeterminantValue] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[ffDeterminantValue] ffDeterminantValue_v6 


					inner join	[Giraffe_Archive].[dbo].[ffFormTemplate] j_ffFormTemplate_idfsFormTemplate_v7

		on	


					j_ffFormTemplate_idfsFormTemplate_v7.[idfsFormTemplate] = ffDeterminantValue_v6.[idfsFormTemplate] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsBaseReference_v7

		on	


					j_trtBaseReference_idfsBaseReference_v7.[idfsBaseReference] = ffDeterminantValue_v6.[idfsBaseReference] 

					left join	[Giraffe_Archive].[dbo].[gisBaseReference] j_gisBaseReference_idfsGISBaseReference_v7

		on	


					j_gisBaseReference_idfsGISBaseReference_v7.[idfsGISBaseReference] = ffDeterminantValue_v6.[idfsGISBaseReference] 
left join	[Giraffe_Archive].[dbo].[ffDeterminantValue] ffDeterminantValue_v7 
on	

					ffDeterminantValue_v7.[idfDeterminantValue] = ffDeterminantValue_v6.[idfDeterminantValue] 
where ffDeterminantValue_v7.[idfDeterminantValue] is null 
print N'Table [ffDeterminantValue] - insert: ' + cast(@@rowcount as nvarchar(20))


-----

print N''
print N'Insert records - Flexible Forms tables - end'
print N''
print N''
/************************************************************
* Insert records - Flexible Forms tables - end
************************************************************/


------

/************************************************************
* Insert records - Reference Matrices tables - start
************************************************************/
print N''
print N'Insert records - Reference Matrices tables - start'
print N''


--

/************************************************************
* Insert records - [trtCollectionMethodForVectorType]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtCollectionMethodForVectorType] 

(

					[idfCollectionMethodForVectorType]

					, [idfsCollectionMethod]

					, [idfsVectorType]

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
select 

					trtCollectionMethodForVectorType_v6.[idfCollectionMethodForVectorType]

					, j_trtBaseReference_idfsCollectionMethod_v7.[idfsBaseReference]

					, j_trtVectorType_idfsVectorType_v7.[idfsVectorType]

					, trtCollectionMethodForVectorType_v6.[intRowStatus]

					, trtCollectionMethodForVectorType_v6.[rowguid]

					, trtCollectionMethodForVectorType_v6.[strMaintenanceFlag]

					, trtCollectionMethodForVectorType_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfCollectionMethodForVectorType":' + isnull(cast(trtCollectionMethodForVectorType_v6.[idfCollectionMethodForVectorType] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtCollectionMethodForVectorType] trtCollectionMethodForVectorType_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsCollectionMethod_v7

		on	


					j_trtBaseReference_idfsCollectionMethod_v7.[idfsBaseReference] = trtCollectionMethodForVectorType_v6.[idfsCollectionMethod] 

					inner join	[Giraffe_Archive].[dbo].[trtVectorType] j_trtVectorType_idfsVectorType_v7

		on	


					j_trtVectorType_idfsVectorType_v7.[idfsVectorType] = trtCollectionMethodForVectorType_v6.[idfsVectorType] 
left join	[Giraffe_Archive].[dbo].[trtCollectionMethodForVectorType] trtCollectionMethodForVectorType_v7 
on	

					trtCollectionMethodForVectorType_v7.[idfCollectionMethodForVectorType] = trtCollectionMethodForVectorType_v6.[idfCollectionMethodForVectorType] 
where trtCollectionMethodForVectorType_v7.[idfCollectionMethodForVectorType] is null 
print N'Table [trtCollectionMethodForVectorType] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtDerivativeForSampleType]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtDerivativeForSampleType] 

(

					[idfDerivativeForSampleType]

					, [idfsSampleType]

					, [idfsDerivativeType]

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
select 

					trtDerivativeForSampleType_v6.[idfDerivativeForSampleType]

					, j_trtSampleType_idfsSampleType_v7.[idfsSampleType]

					, j_trtBaseReference_idfsDerivativeType_v7.[idfsBaseReference]

					, trtDerivativeForSampleType_v6.[intRowStatus]

					, trtDerivativeForSampleType_v6.[rowguid]

					, trtDerivativeForSampleType_v6.[strMaintenanceFlag]

					, trtDerivativeForSampleType_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfDerivativeForSampleType":' + isnull(cast(trtDerivativeForSampleType_v6.[idfDerivativeForSampleType] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtDerivativeForSampleType] trtDerivativeForSampleType_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsDerivativeType_v7

		on	


					j_trtBaseReference_idfsDerivativeType_v7.[idfsBaseReference] = trtDerivativeForSampleType_v6.[idfsDerivativeType] 

					inner join	[Giraffe_Archive].[dbo].[trtSampleType] j_trtSampleType_idfsSampleType_v7

		on	


					j_trtSampleType_idfsSampleType_v7.[idfsSampleType] = trtDerivativeForSampleType_v6.[idfsSampleType] 
left join	[Giraffe_Archive].[dbo].[trtDerivativeForSampleType] trtDerivativeForSampleType_v7 
on	

					trtDerivativeForSampleType_v7.[idfDerivativeForSampleType] = trtDerivativeForSampleType_v6.[idfDerivativeForSampleType] 
where trtDerivativeForSampleType_v7.[idfDerivativeForSampleType] is null 
print N'Table [trtDerivativeForSampleType] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtDiagnosisAgeGroupToStatisticalAgeGroup]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtDiagnosisAgeGroupToStatisticalAgeGroup] 

(

					[idfDiagnosisAgeGroupToStatisticalAgeGroup]

					, [idfsDiagnosisAgeGroup]

					, [idfsStatisticalAgeGroup]

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
select 

					trtDiagnosisAgeGroupToStatisticalAgeGroup_v6.[idfDiagnosisAgeGroupToStatisticalAgeGroup]

					, j_trtDiagnosisAgeGroup_idfsDiagnosisAgeGroup_v7.[idfsDiagnosisAgeGroup]

					, j_trtBaseReference_idfsStatisticalAgeGroup_v7.[idfsBaseReference]

					, trtDiagnosisAgeGroupToStatisticalAgeGroup_v6.[intRowStatus]

					, trtDiagnosisAgeGroupToStatisticalAgeGroup_v6.[rowguid]

					, trtDiagnosisAgeGroupToStatisticalAgeGroup_v6.[strMaintenanceFlag]

					, trtDiagnosisAgeGroupToStatisticalAgeGroup_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfDiagnosisAgeGroupToStatisticalAgeGroup":' + isnull(cast(trtDiagnosisAgeGroupToStatisticalAgeGroup_v6.[idfDiagnosisAgeGroupToStatisticalAgeGroup] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtDiagnosisAgeGroupToStatisticalAgeGroup] trtDiagnosisAgeGroupToStatisticalAgeGroup_v6 


					inner join	[Giraffe_Archive].[dbo].[trtDiagnosisAgeGroup] j_trtDiagnosisAgeGroup_idfsDiagnosisAgeGroup_v7

		on	


					j_trtDiagnosisAgeGroup_idfsDiagnosisAgeGroup_v7.[idfsDiagnosisAgeGroup] = trtDiagnosisAgeGroupToStatisticalAgeGroup_v6.[idfsDiagnosisAgeGroup] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsStatisticalAgeGroup_v7

		on	


					j_trtBaseReference_idfsStatisticalAgeGroup_v7.[idfsBaseReference] = trtDiagnosisAgeGroupToStatisticalAgeGroup_v6.[idfsStatisticalAgeGroup] 
left join	[Giraffe_Archive].[dbo].[trtDiagnosisAgeGroupToStatisticalAgeGroup] trtDiagnosisAgeGroupToStatisticalAgeGroup_v7 
on	

					trtDiagnosisAgeGroupToStatisticalAgeGroup_v7.[idfDiagnosisAgeGroupToStatisticalAgeGroup] = trtDiagnosisAgeGroupToStatisticalAgeGroup_v6.[idfDiagnosisAgeGroupToStatisticalAgeGroup] 
where trtDiagnosisAgeGroupToStatisticalAgeGroup_v7.[idfDiagnosisAgeGroupToStatisticalAgeGroup] is null 
print N'Table [trtDiagnosisAgeGroupToStatisticalAgeGroup] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtDiagnosisAgeGroupToDiagnosis]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtDiagnosisAgeGroupToDiagnosis] 

(

					[idfDiagnosisAgeGroupToDiagnosis]

					, [idfsDiagnosis]

					, [idfsDiagnosisAgeGroup]

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
select 

					trtDiagnosisAgeGroupToDiagnosis_v6.[idfDiagnosisAgeGroupToDiagnosis]

					, j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis]

					, j_trtDiagnosisAgeGroup_idfsDiagnosisAgeGroup_v7.[idfsDiagnosisAgeGroup]

					, trtDiagnosisAgeGroupToDiagnosis_v6.[intRowStatus]

					, trtDiagnosisAgeGroupToDiagnosis_v6.[rowguid]

					, trtDiagnosisAgeGroupToDiagnosis_v6.[strMaintenanceFlag]

					, trtDiagnosisAgeGroupToDiagnosis_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfDiagnosisAgeGroupToDiagnosis":' + isnull(cast(trtDiagnosisAgeGroupToDiagnosis_v6.[idfDiagnosisAgeGroupToDiagnosis] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtDiagnosisAgeGroupToDiagnosis] trtDiagnosisAgeGroupToDiagnosis_v6 


					inner join	[Giraffe_Archive].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsDiagnosis_v7

		on	


					j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis] = trtDiagnosisAgeGroupToDiagnosis_v6.[idfsDiagnosis] 

					left join	[Giraffe_Archive].[dbo].[trtDiagnosisAgeGroup] j_trtDiagnosisAgeGroup_idfsDiagnosisAgeGroup_v7

		on	


					j_trtDiagnosisAgeGroup_idfsDiagnosisAgeGroup_v7.[idfsDiagnosisAgeGroup] = trtDiagnosisAgeGroupToDiagnosis_v6.[idfsDiagnosisAgeGroup] 
left join	[Giraffe_Archive].[dbo].[trtDiagnosisAgeGroupToDiagnosis] trtDiagnosisAgeGroupToDiagnosis_v7 
on	

					trtDiagnosisAgeGroupToDiagnosis_v7.[idfDiagnosisAgeGroupToDiagnosis] = trtDiagnosisAgeGroupToDiagnosis_v6.[idfDiagnosisAgeGroupToDiagnosis] 
where trtDiagnosisAgeGroupToDiagnosis_v7.[idfDiagnosisAgeGroupToDiagnosis] is null 
print N'Table [trtDiagnosisAgeGroupToDiagnosis] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtDiagnosisToDiagnosisGroup]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtDiagnosisToDiagnosisGroup] 

(

					[idfDiagnosisToDiagnosisGroup]

					, [idfsDiagnosisGroup]

					, [idfsDiagnosis]

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
select 

					trtDiagnosisToDiagnosisGroup_v6.[idfDiagnosisToDiagnosisGroup]

					, j_trtBaseReference_idfsDiagnosisGroup_v7.[idfsBaseReference]

					, j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis]

					, trtDiagnosisToDiagnosisGroup_v6.[intRowStatus]

					, trtDiagnosisToDiagnosisGroup_v6.[rowguid]

					, trtDiagnosisToDiagnosisGroup_v6.[strMaintenanceFlag]

					, trtDiagnosisToDiagnosisGroup_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfDiagnosisToDiagnosisGroup":' + isnull(cast(trtDiagnosisToDiagnosisGroup_v6.[idfDiagnosisToDiagnosisGroup] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtDiagnosisToDiagnosisGroup] trtDiagnosisToDiagnosisGroup_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsDiagnosisGroup_v7

		on	


					j_trtBaseReference_idfsDiagnosisGroup_v7.[idfsBaseReference] = trtDiagnosisToDiagnosisGroup_v6.[idfsDiagnosisGroup] 

					inner join	[Giraffe_Archive].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsDiagnosis_v7

		on	


					j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis] = trtDiagnosisToDiagnosisGroup_v6.[idfsDiagnosis] 
left join	[Giraffe_Archive].[dbo].[trtDiagnosisToDiagnosisGroup] trtDiagnosisToDiagnosisGroup_v7 
on	

					trtDiagnosisToDiagnosisGroup_v7.[idfDiagnosisToDiagnosisGroup] = trtDiagnosisToDiagnosisGroup_v6.[idfDiagnosisToDiagnosisGroup] 
where trtDiagnosisToDiagnosisGroup_v7.[idfDiagnosisToDiagnosisGroup] is null 
print N'Table [trtDiagnosisToDiagnosisGroup] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtDiagnosisToGroupForReportType]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtDiagnosisToGroupForReportType] 

(

					[idfsCustomReportType]

					, [idfsReportDiagnosisGroup]

					, [idfsDiagnosis]

					, [rowguid]

					, [idfDiagnosisToGroupForReportType]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [intRowStatus]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_trtBaseReference_idfsCustomReportType_v7.[idfsBaseReference]

					, j_trtReportDiagnosisGroup_idfsReportDiagnosisGroup_v7.[idfsReportDiagnosisGroup]

					, j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis]

					, trtDiagnosisToGroupForReportType_v6.[rowguid]

					, trtDiagnosisToGroupForReportType_v6.[idfDiagnosisToGroupForReportType]

					, trtDiagnosisToGroupForReportType_v6.[strMaintenanceFlag]

					, trtDiagnosisToGroupForReportType_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfDiagnosisToGroupForReportType":' + isnull(cast(trtDiagnosisToGroupForReportType_v6.[idfDiagnosisToGroupForReportType] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, 0 /*Rule for the new field in EIDSSv7: intRowStatus*/

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtDiagnosisToGroupForReportType] trtDiagnosisToGroupForReportType_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsCustomReportType_v7

		on	


					j_trtBaseReference_idfsCustomReportType_v7.[idfsBaseReference] = trtDiagnosisToGroupForReportType_v6.[idfsCustomReportType] 

					inner join	[Giraffe_Archive].[dbo].[trtReportDiagnosisGroup] j_trtReportDiagnosisGroup_idfsReportDiagnosisGroup_v7

		on	


					j_trtReportDiagnosisGroup_idfsReportDiagnosisGroup_v7.[idfsReportDiagnosisGroup] = trtDiagnosisToGroupForReportType_v6.[idfsReportDiagnosisGroup] 

					inner join	[Giraffe_Archive].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsDiagnosis_v7

		on	


					j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis] = trtDiagnosisToGroupForReportType_v6.[idfsDiagnosis] 
left join	[Giraffe_Archive].[dbo].[trtDiagnosisToGroupForReportType] trtDiagnosisToGroupForReportType_v7 
on	

					trtDiagnosisToGroupForReportType_v7.[idfDiagnosisToGroupForReportType] = trtDiagnosisToGroupForReportType_v6.[idfDiagnosisToGroupForReportType] 
where trtDiagnosisToGroupForReportType_v7.[idfDiagnosisToGroupForReportType] is null 
print N'Table [trtDiagnosisToGroupForReportType] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtFFObjectForCustomReport]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtFFObjectForCustomReport] 

(

					[idfFFObjectForCustomReport]

					, [idfsCustomReportType]

					, [strFFObjectAlias]

					, [idfsFFObject]

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
select 

					trtFFObjectForCustomReport_v6.[idfFFObjectForCustomReport]

					, j_trtBaseReference_idfsCustomReportType_v7.[idfsBaseReference]

					, trtFFObjectForCustomReport_v6.[strFFObjectAlias]

					, trtFFObjectForCustomReport_v6.[idfsFFObject]

					, trtFFObjectForCustomReport_v6.[intRowStatus]

					, trtFFObjectForCustomReport_v6.[rowguid]

					, trtFFObjectForCustomReport_v6.[strMaintenanceFlag]

					, trtFFObjectForCustomReport_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfFFObjectForCustomReport":' + isnull(cast(trtFFObjectForCustomReport_v6.[idfFFObjectForCustomReport] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtFFObjectForCustomReport] trtFFObjectForCustomReport_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsCustomReportType_v7

		on	


					j_trtBaseReference_idfsCustomReportType_v7.[idfsBaseReference] = trtFFObjectForCustomReport_v6.[idfsCustomReportType] 
left join	[Giraffe_Archive].[dbo].[trtFFObjectForCustomReport] trtFFObjectForCustomReport_v7 
on	

					trtFFObjectForCustomReport_v7.[idfFFObjectForCustomReport] = trtFFObjectForCustomReport_v6.[idfFFObjectForCustomReport] 
where trtFFObjectForCustomReport_v7.[idfFFObjectForCustomReport] is null 
print N'Table [trtFFObjectForCustomReport] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtFFObjectToDiagnosisForCustomReport]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtFFObjectToDiagnosisForCustomReport] 

(

					[idfFFObjectToDiagnosisForCustomReport]

					, [idfsDiagnosis]

					, [idfFFObjectForCustomReport]

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
select 

					trtFFObjectToDiagnosisForCustomReport_v6.[idfFFObjectToDiagnosisForCustomReport]

					, j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis]

					, j_trtFFObjectForCustomReport_idfFFObjectForCustomReport_v7.[idfFFObjectForCustomReport]

					, trtFFObjectToDiagnosisForCustomReport_v6.[intRowStatus]

					, trtFFObjectToDiagnosisForCustomReport_v6.[rowguid]

					, trtFFObjectToDiagnosisForCustomReport_v6.[strMaintenanceFlag]

					, trtFFObjectToDiagnosisForCustomReport_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfFFObjectToDiagnosisForCustomReport":' + isnull(cast(trtFFObjectToDiagnosisForCustomReport_v6.[idfFFObjectToDiagnosisForCustomReport] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtFFObjectToDiagnosisForCustomReport] trtFFObjectToDiagnosisForCustomReport_v6 


					inner join	[Giraffe_Archive].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsDiagnosis_v7

		on	


					j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis] = trtFFObjectToDiagnosisForCustomReport_v6.[idfsDiagnosis] 

					inner join	[Giraffe_Archive].[dbo].[trtFFObjectForCustomReport] j_trtFFObjectForCustomReport_idfFFObjectForCustomReport_v7

		on	


					j_trtFFObjectForCustomReport_idfFFObjectForCustomReport_v7.[idfFFObjectForCustomReport] = trtFFObjectToDiagnosisForCustomReport_v6.[idfFFObjectForCustomReport] 
left join	[Giraffe_Archive].[dbo].[trtFFObjectToDiagnosisForCustomReport] trtFFObjectToDiagnosisForCustomReport_v7 
on	

					trtFFObjectToDiagnosisForCustomReport_v7.[idfFFObjectToDiagnosisForCustomReport] = trtFFObjectToDiagnosisForCustomReport_v6.[idfFFObjectToDiagnosisForCustomReport] 
where trtFFObjectToDiagnosisForCustomReport_v7.[idfFFObjectToDiagnosisForCustomReport] is null 
print N'Table [trtFFObjectToDiagnosisForCustomReport] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtMaterialForDisease]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtMaterialForDisease] 

(

					[idfMaterialForDisease]

					, [idfsSampleType]

					, [idfsDiagnosis]

					, [intRecommendedQty]

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
select 

					trtMaterialForDisease_v6.[idfMaterialForDisease]

					, j_trtSampleType_idfsSampleType_v7.[idfsSampleType]

					, j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis]

					, trtMaterialForDisease_v6.[intRecommendedQty]

					, trtMaterialForDisease_v6.[intRowStatus]

					, trtMaterialForDisease_v6.[rowguid]

					, trtMaterialForDisease_v6.[strMaintenanceFlag]

					, trtMaterialForDisease_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfMaterialForDisease":' + isnull(cast(trtMaterialForDisease_v6.[idfMaterialForDisease] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtMaterialForDisease] trtMaterialForDisease_v6 


					inner join	[Giraffe_Archive].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsDiagnosis_v7

		on	


					j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis] = trtMaterialForDisease_v6.[idfsDiagnosis] 

					left join	[Giraffe_Archive].[dbo].[trtSampleType] j_trtSampleType_idfsSampleType_v7

		on	


					j_trtSampleType_idfsSampleType_v7.[idfsSampleType] = trtMaterialForDisease_v6.[idfsSampleType] 
left join	[Giraffe_Archive].[dbo].[trtMaterialForDisease] trtMaterialForDisease_v7 
on	

					trtMaterialForDisease_v7.[idfMaterialForDisease] = trtMaterialForDisease_v6.[idfMaterialForDisease] 
where trtMaterialForDisease_v7.[idfMaterialForDisease] is null 
print N'Table [trtMaterialForDisease] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtObjectTypeToObjectOperation]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtObjectTypeToObjectOperation] 

(

					[idfsObjectType]

					, [idfsObjectOperation]

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
select 

					j_trtBaseReference_idfsObjectType_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsObjectOperation_v7.[idfsBaseReference]

					, trtObjectTypeToObjectOperation_v6.[rowguid]

					, trtObjectTypeToObjectOperation_v6.[strMaintenanceFlag]

					, trtObjectTypeToObjectOperation_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsObjectType":' + isnull(cast(trtObjectTypeToObjectOperation_v6.[idfsObjectType] as nvarchar(20)), N'null') + N',' + N'"idfsObjectOperation":' + isnull(cast(trtObjectTypeToObjectOperation_v6.[idfsObjectOperation] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtObjectTypeToObjectOperation] trtObjectTypeToObjectOperation_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsObjectOperation_v7

		on	


					j_trtBaseReference_idfsObjectOperation_v7.[idfsBaseReference] = trtObjectTypeToObjectOperation_v6.[idfsObjectOperation] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsObjectType_v7

		on	


					j_trtBaseReference_idfsObjectType_v7.[idfsBaseReference] = trtObjectTypeToObjectOperation_v6.[idfsObjectType] 
left join	[Giraffe_Archive].[dbo].[trtObjectTypeToObjectOperation] trtObjectTypeToObjectOperation_v7 
on	

					trtObjectTypeToObjectOperation_v7.[idfsObjectType] = trtObjectTypeToObjectOperation_v6.[idfsObjectType] 

					and trtObjectTypeToObjectOperation_v7.[idfsObjectOperation] = trtObjectTypeToObjectOperation_v6.[idfsObjectOperation] 
where trtObjectTypeToObjectOperation_v7.[idfsObjectType] is null 
print N'Table [trtObjectTypeToObjectOperation] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtObjectTypeToObjectType]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtObjectTypeToObjectType] 

(

					[idfsParentObjectType]

					, [idfsRelatedObjectType]

					, [idfsStatus]

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
select 

					j_trtBaseReference_idfsParentObjectType_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsRelatedObjectType_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsStatus_v7.[idfsBaseReference]

					, trtObjectTypeToObjectType_v6.[rowguid]

					, trtObjectTypeToObjectType_v6.[strMaintenanceFlag]

					, trtObjectTypeToObjectType_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsParentObjectType":' + isnull(cast(trtObjectTypeToObjectType_v6.[idfsParentObjectType] as nvarchar(20)), N'null') + N',' + N'"idfsRelatedObjectType":' + isnull(cast(trtObjectTypeToObjectType_v6.[idfsRelatedObjectType] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtObjectTypeToObjectType] trtObjectTypeToObjectType_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsParentObjectType_v7

		on	


					j_trtBaseReference_idfsParentObjectType_v7.[idfsBaseReference] = trtObjectTypeToObjectType_v6.[idfsParentObjectType] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsRelatedObjectType_v7

		on	


					j_trtBaseReference_idfsRelatedObjectType_v7.[idfsBaseReference] = trtObjectTypeToObjectType_v6.[idfsRelatedObjectType] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsStatus_v7

		on	


					j_trtBaseReference_idfsStatus_v7.[idfsBaseReference] = trtObjectTypeToObjectType_v6.[idfsStatus] 
left join	[Giraffe_Archive].[dbo].[trtObjectTypeToObjectType] trtObjectTypeToObjectType_v7 
on	

					trtObjectTypeToObjectType_v7.[idfsParentObjectType] = trtObjectTypeToObjectType_v6.[idfsParentObjectType] 

					and trtObjectTypeToObjectType_v7.[idfsRelatedObjectType] = trtObjectTypeToObjectType_v6.[idfsRelatedObjectType] 
where trtObjectTypeToObjectType_v7.[idfsParentObjectType] is null 
print N'Table [trtObjectTypeToObjectType] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtPensideTestForDisease]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtPensideTestForDisease] 

(

					[idfPensideTestForDisease]

					, [idfsPensideTestName]

					, [idfsDiagnosis]

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
select 

					trtPensideTestForDisease_v6.[idfPensideTestForDisease]

					, j_trtBaseReference_idfsPensideTestName_v7.[idfsBaseReference]

					, j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis]

					, trtPensideTestForDisease_v6.[intRowStatus]

					, trtPensideTestForDisease_v6.[rowguid]

					, trtPensideTestForDisease_v6.[strMaintenanceFlag]

					, trtPensideTestForDisease_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfPensideTestForDisease":' + isnull(cast(trtPensideTestForDisease_v6.[idfPensideTestForDisease] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtPensideTestForDisease] trtPensideTestForDisease_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsPensideTestName_v7

		on	


					j_trtBaseReference_idfsPensideTestName_v7.[idfsBaseReference] = trtPensideTestForDisease_v6.[idfsPensideTestName] 

					inner join	[Giraffe_Archive].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsDiagnosis_v7

		on	


					j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis] = trtPensideTestForDisease_v6.[idfsDiagnosis] 
left join	[Giraffe_Archive].[dbo].[trtPensideTestForDisease] trtPensideTestForDisease_v7 
on	

					trtPensideTestForDisease_v7.[idfPensideTestForDisease] = trtPensideTestForDisease_v6.[idfPensideTestForDisease] 
where trtPensideTestForDisease_v7.[idfPensideTestForDisease] is null 
print N'Table [trtPensideTestForDisease] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtPensideTestTypeForVectorType]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtPensideTestTypeForVectorType] 

(

					[idfPensideTestTypeForVectorType]

					, [idfsPensideTestName]

					, [idfsVectorType]

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
select 

					trtPensideTestTypeForVectorType_v6.[idfPensideTestTypeForVectorType]

					, j_trtBaseReference_idfsPensideTestName_v7.[idfsBaseReference]

					, j_trtVectorType_idfsVectorType_v7.[idfsVectorType]

					, trtPensideTestTypeForVectorType_v6.[intRowStatus]

					, trtPensideTestTypeForVectorType_v6.[rowguid]

					, trtPensideTestTypeForVectorType_v6.[strMaintenanceFlag]

					, trtPensideTestTypeForVectorType_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfPensideTestTypeForVectorType":' + isnull(cast(trtPensideTestTypeForVectorType_v6.[idfPensideTestTypeForVectorType] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtPensideTestTypeForVectorType] trtPensideTestTypeForVectorType_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsPensideTestName_v7

		on	


					j_trtBaseReference_idfsPensideTestName_v7.[idfsBaseReference] = trtPensideTestTypeForVectorType_v6.[idfsPensideTestName] 

					inner join	[Giraffe_Archive].[dbo].[trtVectorType] j_trtVectorType_idfsVectorType_v7

		on	


					j_trtVectorType_idfsVectorType_v7.[idfsVectorType] = trtPensideTestTypeForVectorType_v6.[idfsVectorType] 
left join	[Giraffe_Archive].[dbo].[trtPensideTestTypeForVectorType] trtPensideTestTypeForVectorType_v7 
on	

					trtPensideTestTypeForVectorType_v7.[idfPensideTestTypeForVectorType] = trtPensideTestTypeForVectorType_v6.[idfPensideTestTypeForVectorType] 
where trtPensideTestTypeForVectorType_v7.[idfPensideTestTypeForVectorType] is null 
print N'Table [trtPensideTestTypeForVectorType] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtPensideTestTypeToTestResult]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtPensideTestTypeToTestResult] 

(

					[idfsPensideTestName]

					, [idfsPensideTestResult]

					, [intRowStatus]

					, [rowguid]

					, [blnIndicative]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_trtBaseReference_idfsPensideTestName_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsPensideTestResult_v7.[idfsBaseReference]

					, trtPensideTestTypeToTestResult_v6.[intRowStatus]

					, trtPensideTestTypeToTestResult_v6.[rowguid]

					, trtPensideTestTypeToTestResult_v6.[blnIndicative]

					, trtPensideTestTypeToTestResult_v6.[strMaintenanceFlag]

					, trtPensideTestTypeToTestResult_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsPensideTestName":' + isnull(cast(trtPensideTestTypeToTestResult_v6.[idfsPensideTestName] as nvarchar(20)), N'null') + N',' + N'"idfsPensideTestResult":' + isnull(cast(trtPensideTestTypeToTestResult_v6.[idfsPensideTestResult] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtPensideTestTypeToTestResult] trtPensideTestTypeToTestResult_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsPensideTestName_v7

		on	


					j_trtBaseReference_idfsPensideTestName_v7.[idfsBaseReference] = trtPensideTestTypeToTestResult_v6.[idfsPensideTestName] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsPensideTestResult_v7

		on	


					j_trtBaseReference_idfsPensideTestResult_v7.[idfsBaseReference] = trtPensideTestTypeToTestResult_v6.[idfsPensideTestResult] 
left join	[Giraffe_Archive].[dbo].[trtPensideTestTypeToTestResult] trtPensideTestTypeToTestResult_v7 
on	

					trtPensideTestTypeToTestResult_v7.[idfsPensideTestName] = trtPensideTestTypeToTestResult_v6.[idfsPensideTestName] 

					and trtPensideTestTypeToTestResult_v7.[idfsPensideTestResult] = trtPensideTestTypeToTestResult_v6.[idfsPensideTestResult] 
where trtPensideTestTypeToTestResult_v7.[idfsPensideTestName] is null 
print N'Table [trtPensideTestTypeToTestResult] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtReportRows]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtReportRows] 

(

					[idfsCustomReportType]

					, [idfsDiagnosisOrReportDiagnosisGroup]

					, [intRowOrder]

					, [intRowStatus]

					, [rowguid]

					, [idfsReportAdditionalText]

					, [idfsICDReportAdditionalText]

					, [intNullValueInsteadZero]

					, [idfReportRows]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_trtBaseReference_idfsCustomReportType_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsDiagnosisOrReportDiagnosisGroup_v7.[idfsBaseReference]

					, trtReportRows_v6.[intRowOrder]

					, trtReportRows_v6.[intRowStatus]

					, trtReportRows_v6.[rowguid]

					, j_trtBaseReference_idfsReportAdditionalText_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsICDReportAdditionalText_v7.[idfsBaseReference]

					, trtReportRows_v6.[intNullValueInsteadZero]

					, trtReportRows_v6.[idfReportRows]

					, trtReportRows_v6.[strMaintenanceFlag]

					, trtReportRows_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfReportRows":' + isnull(cast(trtReportRows_v6.[idfReportRows] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtReportRows] trtReportRows_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsCustomReportType_v7

		on	


					j_trtBaseReference_idfsCustomReportType_v7.[idfsBaseReference] = trtReportRows_v6.[idfsCustomReportType] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsDiagnosisOrReportDiagnosisGroup_v7

		on	


					j_trtBaseReference_idfsDiagnosisOrReportDiagnosisGroup_v7.[idfsBaseReference] = trtReportRows_v6.[idfsDiagnosisOrReportDiagnosisGroup] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsICDReportAdditionalText_v7

		on	


					j_trtBaseReference_idfsICDReportAdditionalText_v7.[idfsBaseReference] = trtReportRows_v6.[idfsICDReportAdditionalText] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsReportAdditionalText_v7

		on	


					j_trtBaseReference_idfsReportAdditionalText_v7.[idfsBaseReference] = trtReportRows_v6.[idfsReportAdditionalText] 
left join	[Giraffe_Archive].[dbo].[trtReportRows] trtReportRows_v7 
on	

					trtReportRows_v7.[idfReportRows] = trtReportRows_v6.[idfReportRows] 
where trtReportRows_v7.[idfReportRows] is null 
print N'Table [trtReportRows] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtSampleTypeForVectorType]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtSampleTypeForVectorType] 

(

					[idfSampleTypeForVectorType]

					, [idfsSampleType]

					, [idfsVectorType]

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
select 

					trtSampleTypeForVectorType_v6.[idfSampleTypeForVectorType]

					, j_trtSampleType_idfsSampleType_v7.[idfsSampleType]

					, j_trtVectorType_idfsVectorType_v7.[idfsVectorType]

					, trtSampleTypeForVectorType_v6.[intRowStatus]

					, trtSampleTypeForVectorType_v6.[rowguid]

					, trtSampleTypeForVectorType_v6.[strMaintenanceFlag]

					, trtSampleTypeForVectorType_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfSampleTypeForVectorType":' + isnull(cast(trtSampleTypeForVectorType_v6.[idfSampleTypeForVectorType] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtSampleTypeForVectorType] trtSampleTypeForVectorType_v6 


					inner join	[Giraffe_Archive].[dbo].[trtSampleType] j_trtSampleType_idfsSampleType_v7

		on	


					j_trtSampleType_idfsSampleType_v7.[idfsSampleType] = trtSampleTypeForVectorType_v6.[idfsSampleType] 

					inner join	[Giraffe_Archive].[dbo].[trtVectorType] j_trtVectorType_idfsVectorType_v7

		on	


					j_trtVectorType_idfsVectorType_v7.[idfsVectorType] = trtSampleTypeForVectorType_v6.[idfsVectorType] 
left join	[Giraffe_Archive].[dbo].[trtSampleTypeForVectorType] trtSampleTypeForVectorType_v7 
on	

					trtSampleTypeForVectorType_v7.[idfSampleTypeForVectorType] = trtSampleTypeForVectorType_v6.[idfSampleTypeForVectorType] 
where trtSampleTypeForVectorType_v7.[idfSampleTypeForVectorType] is null 
print N'Table [trtSampleTypeForVectorType] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtSpeciesContentInCustomReport]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtSpeciesContentInCustomReport] 

(

					[idfSpeciesContentInCustomReport]

					, [idfsCustomReportType]

					, [idfsSpeciesOrSpeciesGroup]

					, [idfsReportAdditionalText]

					, [intItemOrder]

					, [intNullValueInsteadZero]

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
select 

					trtSpeciesContentInCustomReport_v6.[idfSpeciesContentInCustomReport]

					, j_trtBaseReference_idfsCustomReportType_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsSpeciesOrSpeciesGroup_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsReportAdditionalText_v7.[idfsBaseReference]

					, trtSpeciesContentInCustomReport_v6.[intItemOrder]

					, trtSpeciesContentInCustomReport_v6.[intNullValueInsteadZero]

					, trtSpeciesContentInCustomReport_v6.[intRowStatus]

					, trtSpeciesContentInCustomReport_v6.[rowguid]

					, trtSpeciesContentInCustomReport_v6.[strMaintenanceFlag]

					, trtSpeciesContentInCustomReport_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfSpeciesContentInCustomReport":' + isnull(cast(trtSpeciesContentInCustomReport_v6.[idfSpeciesContentInCustomReport] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtSpeciesContentInCustomReport] trtSpeciesContentInCustomReport_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsCustomReportType_v7

		on	


					j_trtBaseReference_idfsCustomReportType_v7.[idfsBaseReference] = trtSpeciesContentInCustomReport_v6.[idfsCustomReportType] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsSpeciesOrSpeciesGroup_v7

		on	


					j_trtBaseReference_idfsSpeciesOrSpeciesGroup_v7.[idfsBaseReference] = trtSpeciesContentInCustomReport_v6.[idfsSpeciesOrSpeciesGroup] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsReportAdditionalText_v7

		on	


					j_trtBaseReference_idfsReportAdditionalText_v7.[idfsBaseReference] = trtSpeciesContentInCustomReport_v6.[idfsReportAdditionalText] 
left join	[Giraffe_Archive].[dbo].[trtSpeciesContentInCustomReport] trtSpeciesContentInCustomReport_v7 
on	

					trtSpeciesContentInCustomReport_v7.[idfSpeciesContentInCustomReport] = trtSpeciesContentInCustomReport_v6.[idfSpeciesContentInCustomReport] 
where trtSpeciesContentInCustomReport_v7.[idfSpeciesContentInCustomReport] is null 
print N'Table [trtSpeciesContentInCustomReport] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtSpeciesToGroupForCustomReport]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtSpeciesToGroupForCustomReport] 

(

					[idfSpeciesToGroupForCustomReport]

					, [idfsCustomReportType]

					, [idfsSpeciesGroup]

					, [idfsSpeciesType]

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
select 

					trtSpeciesToGroupForCustomReport_v6.[idfSpeciesToGroupForCustomReport]

					, j_trtBaseReference_idfsCustomReportType_v7.[idfsBaseReference]

					, j_trtSpeciesGroup_idfsSpeciesGroup_v7.[idfsSpeciesGroup]

					, j_trtSpeciesType_idfsSpeciesType_v7.[idfsSpeciesType]

					, trtSpeciesToGroupForCustomReport_v6.[intRowStatus]

					, trtSpeciesToGroupForCustomReport_v6.[rowguid]

					, trtSpeciesToGroupForCustomReport_v6.[strMaintenanceFlag]

					, trtSpeciesToGroupForCustomReport_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfSpeciesToGroupForCustomReport":' + isnull(cast(trtSpeciesToGroupForCustomReport_v6.[idfSpeciesToGroupForCustomReport] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtSpeciesToGroupForCustomReport] trtSpeciesToGroupForCustomReport_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsCustomReportType_v7

		on	


					j_trtBaseReference_idfsCustomReportType_v7.[idfsBaseReference] = trtSpeciesToGroupForCustomReport_v6.[idfsCustomReportType] 

					inner join	[Giraffe_Archive].[dbo].[trtSpeciesGroup] j_trtSpeciesGroup_idfsSpeciesGroup_v7

		on	


					j_trtSpeciesGroup_idfsSpeciesGroup_v7.[idfsSpeciesGroup] = trtSpeciesToGroupForCustomReport_v6.[idfsSpeciesGroup] 

					inner join	[Giraffe_Archive].[dbo].[trtSpeciesType] j_trtSpeciesType_idfsSpeciesType_v7

		on	


					j_trtSpeciesType_idfsSpeciesType_v7.[idfsSpeciesType] = trtSpeciesToGroupForCustomReport_v6.[idfsSpeciesType] 
left join	[Giraffe_Archive].[dbo].[trtSpeciesToGroupForCustomReport] trtSpeciesToGroupForCustomReport_v7 
on	

					trtSpeciesToGroupForCustomReport_v7.[idfSpeciesToGroupForCustomReport] = trtSpeciesToGroupForCustomReport_v6.[idfSpeciesToGroupForCustomReport] 
where trtSpeciesToGroupForCustomReport_v7.[idfSpeciesToGroupForCustomReport] is null 
print N'Table [trtSpeciesToGroupForCustomReport] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtSpeciesTypeToAnimalAge]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtSpeciesTypeToAnimalAge] 

(

					[idfSpeciesTypeToAnimalAge]

					, [idfsSpeciesType]

					, [idfsAnimalAge]

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
select 

					trtSpeciesTypeToAnimalAge_v6.[idfSpeciesTypeToAnimalAge]

					, j_trtSpeciesType_idfsSpeciesType_v7.[idfsSpeciesType]

					, j_trtBaseReference_idfsAnimalAge_v7.[idfsBaseReference]

					, trtSpeciesTypeToAnimalAge_v6.[intRowStatus]

					, trtSpeciesTypeToAnimalAge_v6.[rowguid]

					, trtSpeciesTypeToAnimalAge_v6.[strMaintenanceFlag]

					, trtSpeciesTypeToAnimalAge_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfSpeciesTypeToAnimalAge":' + isnull(cast(trtSpeciesTypeToAnimalAge_v6.[idfSpeciesTypeToAnimalAge] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtSpeciesTypeToAnimalAge] trtSpeciesTypeToAnimalAge_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsAnimalAge_v7

		on	


					j_trtBaseReference_idfsAnimalAge_v7.[idfsBaseReference] = trtSpeciesTypeToAnimalAge_v6.[idfsAnimalAge] 

					inner join	[Giraffe_Archive].[dbo].[trtSpeciesType] j_trtSpeciesType_idfsSpeciesType_v7

		on	


					j_trtSpeciesType_idfsSpeciesType_v7.[idfsSpeciesType] = trtSpeciesTypeToAnimalAge_v6.[idfsSpeciesType] 
left join	[Giraffe_Archive].[dbo].[trtSpeciesTypeToAnimalAge] trtSpeciesTypeToAnimalAge_v7 
on	

					trtSpeciesTypeToAnimalAge_v7.[idfSpeciesTypeToAnimalAge] = trtSpeciesTypeToAnimalAge_v6.[idfSpeciesTypeToAnimalAge] 
where trtSpeciesTypeToAnimalAge_v7.[idfSpeciesTypeToAnimalAge] is null 
print N'Table [trtSpeciesTypeToAnimalAge] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtTestForDisease]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtTestForDisease] 

(

					[idfTestForDisease]

					, [idfsTestCategory]

					, [idfsTestName]

					, [idfsSampleType]

					, [idfsDiagnosis]

					, [intRecommendedQty]

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
select 

					trtTestForDisease_v6.[idfTestForDisease]

					, j_trtBaseReference_idfsTestCategory_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsTestName_v7.[idfsBaseReference]

					, j_trtSampleType_idfsSampleType_v7.[idfsSampleType]

					, j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis]

					, trtTestForDisease_v6.[intRecommendedQty]

					, trtTestForDisease_v6.[intRowStatus]

					, trtTestForDisease_v6.[rowguid]

					, trtTestForDisease_v6.[strMaintenanceFlag]

					, trtTestForDisease_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfTestForDisease":' + isnull(cast(trtTestForDisease_v6.[idfTestForDisease] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtTestForDisease] trtTestForDisease_v6 


					inner join	[Giraffe_Archive].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsDiagnosis_v7

		on	


					j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis] = trtTestForDisease_v6.[idfsDiagnosis] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsTestCategory_v7

		on	


					j_trtBaseReference_idfsTestCategory_v7.[idfsBaseReference] = trtTestForDisease_v6.[idfsTestCategory] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsTestName_v7

		on	


					j_trtBaseReference_idfsTestName_v7.[idfsBaseReference] = trtTestForDisease_v6.[idfsTestName] 

					left join	[Giraffe_Archive].[dbo].[trtSampleType] j_trtSampleType_idfsSampleType_v7

		on	


					j_trtSampleType_idfsSampleType_v7.[idfsSampleType] = trtTestForDisease_v6.[idfsSampleType] 
left join	[Giraffe_Archive].[dbo].[trtTestForDisease] trtTestForDisease_v7 
on	

					trtTestForDisease_v7.[idfTestForDisease] = trtTestForDisease_v6.[idfTestForDisease] 
where trtTestForDisease_v7.[idfTestForDisease] is null 
print N'Table [trtTestForDisease] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtTestTypeForCustomReport]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtTestTypeForCustomReport] 

(

					[idfTestTypeForCustomReport]

					, [idfsCustomReportType]

					, [idfsTestName]

					, [intRowOrder]

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
select 

					trtTestTypeForCustomReport_v6.[idfTestTypeForCustomReport]

					, j_trtBaseReference_idfsCustomReportType_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsTestName_v7.[idfsBaseReference]

					, trtTestTypeForCustomReport_v6.[intRowOrder]

					, trtTestTypeForCustomReport_v6.[intRowStatus]

					, trtTestTypeForCustomReport_v6.[rowguid]

					, trtTestTypeForCustomReport_v6.[strMaintenanceFlag]

					, trtTestTypeForCustomReport_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfTestTypeForCustomReport":' + isnull(cast(trtTestTypeForCustomReport_v6.[idfTestTypeForCustomReport] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtTestTypeForCustomReport] trtTestTypeForCustomReport_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsCustomReportType_v7

		on	


					j_trtBaseReference_idfsCustomReportType_v7.[idfsBaseReference] = trtTestTypeForCustomReport_v6.[idfsCustomReportType] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsTestName_v7

		on	


					j_trtBaseReference_idfsTestName_v7.[idfsBaseReference] = trtTestTypeForCustomReport_v6.[idfsTestName] 
left join	[Giraffe_Archive].[dbo].[trtTestTypeForCustomReport] trtTestTypeForCustomReport_v7 
on	

					trtTestTypeForCustomReport_v7.[idfTestTypeForCustomReport] = trtTestTypeForCustomReport_v6.[idfTestTypeForCustomReport] 
where trtTestTypeForCustomReport_v7.[idfTestTypeForCustomReport] is null 
print N'Table [trtTestTypeForCustomReport] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtTestTypeToTestResult]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtTestTypeToTestResult] 

(

					[idfsTestName]

					, [idfsTestResult]

					, [intRowStatus]

					, [rowguid]

					, [blnIndicative]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_trtBaseReference_idfsTestName_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsTestResult_v7.[idfsBaseReference]

					, trtTestTypeToTestResult_v6.[intRowStatus]

					, trtTestTypeToTestResult_v6.[rowguid]

					, trtTestTypeToTestResult_v6.[blnIndicative]

					, trtTestTypeToTestResult_v6.[strMaintenanceFlag]

					, trtTestTypeToTestResult_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsTestName":' + isnull(cast(trtTestTypeToTestResult_v6.[idfsTestName] as nvarchar(20)), N'null') + N',' + N'"idfsTestResult":' + isnull(cast(trtTestTypeToTestResult_v6.[idfsTestResult] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtTestTypeToTestResult] trtTestTypeToTestResult_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsTestName_v7

		on	


					j_trtBaseReference_idfsTestName_v7.[idfsBaseReference] = trtTestTypeToTestResult_v6.[idfsTestName] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsTestResult_v7

		on	


					j_trtBaseReference_idfsTestResult_v7.[idfsBaseReference] = trtTestTypeToTestResult_v6.[idfsTestResult] 
left join	[Giraffe_Archive].[dbo].[trtTestTypeToTestResult] trtTestTypeToTestResult_v7 
on	

					trtTestTypeToTestResult_v7.[idfsTestName] = trtTestTypeToTestResult_v6.[idfsTestName] 

					and trtTestTypeToTestResult_v7.[idfsTestResult] = trtTestTypeToTestResult_v6.[idfsTestResult] 
where trtTestTypeToTestResult_v7.[idfsTestName] is null 
print N'Table [trtTestTypeToTestResult] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtGISObjectForCustomReport]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtGISObjectForCustomReport] 

(

					[idfGISObjectForCustomReport]

					, [idfsCustomReportType]

					, [idfsGISBaseReference]

					, [strGISObjectAlias]

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
select 

					trtGISObjectForCustomReport_v6.[idfGISObjectForCustomReport]

					, j_trtBaseReference_idfsCustomReportType_v7.[idfsBaseReference]

					, j_gisBaseReference_idfsGISBaseReference_v7.[idfsGISBaseReference]

					, trtGISObjectForCustomReport_v6.[strGISObjectAlias]

					, trtGISObjectForCustomReport_v6.[intRowStatus]

					, trtGISObjectForCustomReport_v6.[rowguid]

					, trtGISObjectForCustomReport_v6.[strMaintenanceFlag]

					, trtGISObjectForCustomReport_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfGISObjectForCustomReport":' + isnull(cast(trtGISObjectForCustomReport_v6.[idfGISObjectForCustomReport] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtGISObjectForCustomReport] trtGISObjectForCustomReport_v6 


					inner join	[Giraffe_Archive].[dbo].[gisBaseReference] j_gisBaseReference_idfsGISBaseReference_v7

		on	


					j_gisBaseReference_idfsGISBaseReference_v7.[idfsGISBaseReference] = trtGISObjectForCustomReport_v6.[idfsGISBaseReference] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsCustomReportType_v7

		on	


					j_trtBaseReference_idfsCustomReportType_v7.[idfsBaseReference] = trtGISObjectForCustomReport_v6.[idfsCustomReportType] 
left join	[Giraffe_Archive].[dbo].[trtGISObjectForCustomReport] trtGISObjectForCustomReport_v7 
on	

					trtGISObjectForCustomReport_v7.[idfGISObjectForCustomReport] = trtGISObjectForCustomReport_v6.[idfGISObjectForCustomReport] 
where trtGISObjectForCustomReport_v7.[idfGISObjectForCustomReport] is null 
print N'Table [trtGISObjectForCustomReport] - insert: ' + cast(@@rowcount as nvarchar(20))


-------------

print N''
print N'Insert records - Reference Matrices tables - end'
print N''
print N''
/************************************************************
* Insert records - Reference Matrices tables - end
************************************************************/


------------------------------------

/************************************************************
* Insert records - Customization Package Information tables - start
************************************************************/
print N''
print N'Insert records - Customization Package Information tables - start'
print N''


--

/************************************************************
* Insert records - [tstCustomizationPackage]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tstCustomizationPackage] 

(

					[idfCustomizationPackage]

					, [idfsCountry]

					, [strCustomizationPackageName]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tstCustomizationPackage_v6.[idfCustomizationPackage]

					, j_gisCountry_idfsCountry_v7.[idfsCountry]

					, tstCustomizationPackage_v6.[strCustomizationPackageName]

					, tstCustomizationPackage_v6.[rowguid]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfCustomizationPackage":' + isnull(cast(tstCustomizationPackage_v6.[idfCustomizationPackage] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[tstCustomizationPackage] tstCustomizationPackage_v6 


					inner join	[Giraffe_Archive].[dbo].[gisCountry] j_gisCountry_idfsCountry_v7

		on	


					j_gisCountry_idfsCountry_v7.[idfsCountry] = tstCustomizationPackage_v6.[idfsCountry] 
left join	[Giraffe_Archive].[dbo].[tstCustomizationPackage] tstCustomizationPackage_v7 
on	

					tstCustomizationPackage_v7.[idfCustomizationPackage] = tstCustomizationPackage_v6.[idfCustomizationPackage] 
where tstCustomizationPackage_v7.[idfCustomizationPackage] is null 
print N'Table [tstCustomizationPackage] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tstCustomizationPackageSettings]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tstCustomizationPackageSettings] 

(

					[idfCustomizationPackage]

					, [intFirstDayOfWeek]

					, [intCalendarWeekRule]

					, [intForcedReplicationPeriodSlvl]

					, [intForcedReplicationPeriodTlvl]

					, [intForcedReplicationExpirationPeriodCdr]

					, [intForcedReplicationExpirationPeriodSlvl]

					, [intForcedReplicationExpirationPeriodTlvl]

					, [intWhoReportPeriod]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tstCustomizationPackageSettings_v6.[idfCustomizationPackage]

					, tstCustomizationPackageSettings_v6.[intFirstDayOfWeek]

					, tstCustomizationPackageSettings_v6.[intCalendarWeekRule]

					, tstCustomizationPackageSettings_v6.[intForcedReplicationPeriodSlvl]

					, tstCustomizationPackageSettings_v6.[intForcedReplicationPeriodTlvl]

					, tstCustomizationPackageSettings_v6.[intForcedReplicationExpirationPeriodCdr]

					, tstCustomizationPackageSettings_v6.[intForcedReplicationExpirationPeriodSlvl]

					, tstCustomizationPackageSettings_v6.[intForcedReplicationExpirationPeriodTlvl]

					, tstCustomizationPackageSettings_v6.[intWhoReportPeriod]

					, newid() /*rowguid column*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfCustomizationPackage":' + isnull(cast(tstCustomizationPackageSettings_v6.[idfCustomizationPackage] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[tstCustomizationPackageSettings] tstCustomizationPackageSettings_v6 

left join	[Giraffe_Archive].[dbo].[tstCustomizationPackageSettings] tstCustomizationPackageSettings_v7 
on	

					tstCustomizationPackageSettings_v7.[idfCustomizationPackage] = tstCustomizationPackageSettings_v6.[idfCustomizationPackage] 
where tstCustomizationPackageSettings_v7.[idfCustomizationPackage] is null 
print N'Table [tstCustomizationPackageSettings] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tstGeoLocationFormat]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tstGeoLocationFormat] 

(

					[idfsCountry]

					, [strAddressString]

					, [strExactPointString]

					, [strRelativePointString]

					, [strForeignAddress]

					, [strShortAddress]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_gisLocation_idfsCountry_v7.[idfsLocation]

					, tstGeoLocationFormat_v6.[strAddressString]

					, tstGeoLocationFormat_v6.[strExactPointString]

					, tstGeoLocationFormat_v6.[strRelativePointString]

					, tstGeoLocationFormat_v6.[strForeignAddress]

					, tstGeoLocationFormat_v6.[strShortAddress]

					, tstGeoLocationFormat_v6.[rowguid]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsCountry":' + isnull(cast(tstGeoLocationFormat_v6.[idfsCountry] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[tstGeoLocationFormat] tstGeoLocationFormat_v6 


					inner join	[Giraffe_Archive].[dbo].[gisLocation] j_gisLocation_idfsCountry_v7

		on	


					j_gisLocation_idfsCountry_v7.[idfsLocation] = tstGeoLocationFormat_v6.[idfsCountry] 
left join	[Giraffe_Archive].[dbo].[tstGeoLocationFormat] tstGeoLocationFormat_v7 
on	

					tstGeoLocationFormat_v7.[idfsCountry] = tstGeoLocationFormat_v6.[idfsCountry] 
where tstGeoLocationFormat_v7.[idfsCountry] is null 
print N'Table [tstGeoLocationFormat] - insert: ' + cast(@@rowcount as nvarchar(20))


-------------------------------------------

print N''
print N'Insert records - Customization Package Information tables - end'
print N''
print N''
/************************************************************
* Insert records - Customization Package Information tables - end
************************************************************/


------------------

/************************************************************
* Insert records - GIS/Reference Attributes tables - start
************************************************************/
print N''
print N'Insert records - GIS/Reference Attributes tables - start'
print N''


--

/************************************************************
* Insert records - [trtAttributeType]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtAttributeType] 

(

					[idfAttributeType]

					, [strAttributeTypeName]

					, [rowguid]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]

					, [intRowStatus]
)
select 

					trtAttributeType_v6.[idfAttributeType]

					, trtAttributeType_v6.[strAttributeTypeName]

					, trtAttributeType_v6.[rowguid]

					, trtAttributeType_v6.[strMaintenanceFlag]

					, trtAttributeType_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfAttributeType":' + isnull(cast(trtAttributeType_v6.[idfAttributeType] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()

					, 0 /*Rule for the new field in EIDSSv7: intRowStatus*/
from [Falcon_Archive].[dbo].[trtAttributeType] trtAttributeType_v6 

left join	[Giraffe_Archive].[dbo].[trtAttributeType] trtAttributeType_v7 
on	

					trtAttributeType_v7.[idfAttributeType] = trtAttributeType_v6.[idfAttributeType] 
where trtAttributeType_v7.[idfAttributeType] is null 
print N'Table [trtAttributeType] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtGISBaseReferenceAttribute]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtGISBaseReferenceAttribute] 

(

					[idfGISBaseReferenceAttribute]

					, [idfsGISBaseReference]

					, [idfAttributeType]

					, [varValue]

					, [rowguid]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [strAttributeItem]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					trtGISBaseReferenceAttribute_v6.[idfGISBaseReferenceAttribute]

					, j_gisBaseReference_idfsGISBaseReference_v7.[idfsGISBaseReference]

					, j_trtAttributeType_idfAttributeType_v7.[idfAttributeType]

					, trtGISBaseReferenceAttribute_v6.[varValue]

					, trtGISBaseReferenceAttribute_v6.[rowguid]

					, trtGISBaseReferenceAttribute_v6.[strMaintenanceFlag]

					, trtGISBaseReferenceAttribute_v6.[strReservedAttribute]

					, trtGISBaseReferenceAttribute_v6.[strAttributeItem]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfGISBaseReferenceAttribute":' + isnull(cast(trtGISBaseReferenceAttribute_v6.[idfGISBaseReferenceAttribute] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtGISBaseReferenceAttribute] trtGISBaseReferenceAttribute_v6 


					inner join	[Giraffe_Archive].[dbo].[gisBaseReference] j_gisBaseReference_idfsGISBaseReference_v7

		on	


					j_gisBaseReference_idfsGISBaseReference_v7.[idfsGISBaseReference] = trtGISBaseReferenceAttribute_v6.[idfsGISBaseReference] 

					inner join	[Giraffe_Archive].[dbo].[trtAttributeType] j_trtAttributeType_idfAttributeType_v7

		on	


					j_trtAttributeType_idfAttributeType_v7.[idfAttributeType] = trtGISBaseReferenceAttribute_v6.[idfAttributeType] 
left join	[Giraffe_Archive].[dbo].[trtGISBaseReferenceAttribute] trtGISBaseReferenceAttribute_v7 
on	

					trtGISBaseReferenceAttribute_v7.[idfGISBaseReferenceAttribute] = trtGISBaseReferenceAttribute_v6.[idfGISBaseReferenceAttribute] 
where trtGISBaseReferenceAttribute_v7.[idfGISBaseReferenceAttribute] is null 
print N'Table [trtGISBaseReferenceAttribute] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtBaseReferenceAttribute]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtBaseReferenceAttribute] 

(

					[idfBaseReferenceAttribute]

					, [idfsBaseReference]

					, [idfAttributeType]

					, [varValue]

					, [rowguid]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [strAttributeItem]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					trtBaseReferenceAttribute_v6.[idfBaseReferenceAttribute]

					, j_trtBaseReference_idfsBaseReference_v7.[idfsBaseReference]

					, j_trtAttributeType_idfAttributeType_v7.[idfAttributeType]

					, trtBaseReferenceAttribute_v6.[varValue]

					, trtBaseReferenceAttribute_v6.[rowguid]

					, trtBaseReferenceAttribute_v6.[strMaintenanceFlag]

					, trtBaseReferenceAttribute_v6.[strReservedAttribute]

					, trtBaseReferenceAttribute_v6.[strAttributeItem]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfBaseReferenceAttribute":' + isnull(cast(trtBaseReferenceAttribute_v6.[idfBaseReferenceAttribute] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtBaseReferenceAttribute] trtBaseReferenceAttribute_v6 


					inner join	[Giraffe_Archive].[dbo].[trtAttributeType] j_trtAttributeType_idfAttributeType_v7

		on	


					j_trtAttributeType_idfAttributeType_v7.[idfAttributeType] = trtBaseReferenceAttribute_v6.[idfAttributeType] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsBaseReference_v7

		on	


					j_trtBaseReference_idfsBaseReference_v7.[idfsBaseReference] = trtBaseReferenceAttribute_v6.[idfsBaseReference] 
left join	[Giraffe_Archive].[dbo].[trtBaseReferenceAttribute] trtBaseReferenceAttribute_v7 
on	

					trtBaseReferenceAttribute_v7.[idfBaseReferenceAttribute] = trtBaseReferenceAttribute_v6.[idfBaseReferenceAttribute] 
where trtBaseReferenceAttribute_v7.[idfBaseReferenceAttribute] is null 
print N'Table [trtBaseReferenceAttribute] - insert: ' + cast(@@rowcount as nvarchar(20))


-------------------------

print N''
print N'Insert records - GIS/Reference Attributes tables - end'
print N''
print N''
/************************************************************
* Insert records - GIS/Reference Attributes tables - end
************************************************************/


-------------------------------------------------------

/************************************************************
* Insert records - Tables with links from reference and matrices tables to Customization Package - start
************************************************************/
print N''
print N'Insert records - Tables with links from reference and matrices tables to Customization Package - start'
print N''


--

/************************************************************
* Insert records - [trtBaseReferenceToCP]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtBaseReferenceToCP] 

(

					[idfsBaseReference]

					, [idfCustomizationPackage]

					, [intHACode]

					, [intOrder]

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
select 

					j_trtBaseReference_idfsBaseReference_v7.[idfsBaseReference]

					, j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage]

					, trtBaseReferenceToCP_v6.[intHACode]

					, trtBaseReferenceToCP_v6.[intOrder]

					, trtBaseReferenceToCP_v6.[rowguid]

					, trtBaseReferenceToCP_v6.[strMaintenanceFlag]

					, trtBaseReferenceToCP_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsBaseReference":' + isnull(cast(trtBaseReferenceToCP_v6.[idfsBaseReference] as nvarchar(20)), N'null') + N',' + N'"idfCustomizationPackage":' + isnull(cast(trtBaseReferenceToCP_v6.[idfCustomizationPackage] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtBaseReferenceToCP] trtBaseReferenceToCP_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsBaseReference_v7

		on	


					j_trtBaseReference_idfsBaseReference_v7.[idfsBaseReference] = trtBaseReferenceToCP_v6.[idfsBaseReference] 

					inner join	[Giraffe_Archive].[dbo].[tstCustomizationPackage] j_tstCustomizationPackage_idfCustomizationPackage_v7

		on	


					j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage] = trtBaseReferenceToCP_v6.[idfCustomizationPackage] 
left join	[Giraffe_Archive].[dbo].[trtBaseReferenceToCP] trtBaseReferenceToCP_v7 
on	

					trtBaseReferenceToCP_v7.[idfsBaseReference] = trtBaseReferenceToCP_v6.[idfsBaseReference] 

					and trtBaseReferenceToCP_v7.[idfCustomizationPackage] = trtBaseReferenceToCP_v6.[idfCustomizationPackage] 
where trtBaseReferenceToCP_v7.[idfsBaseReference] is null 
print N'Table [trtBaseReferenceToCP] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtLanguageToCP]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtLanguageToCP] 

(

					[idfsLanguage]

					, [idfCustomizationPackage]

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
select 

					j_trtBaseReference_idfsLanguage_v7.[idfsBaseReference]

					, j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage]

					, trtLanguageToCP_v6.[rowguid]

					, trtLanguageToCP_v6.[strMaintenanceFlag]

					, trtLanguageToCP_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsLanguage":' + isnull(cast(trtLanguageToCP_v6.[idfsLanguage] as nvarchar(20)), N'null') + N',' + N'"idfCustomizationPackage":' + isnull(cast(trtLanguageToCP_v6.[idfCustomizationPackage] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtLanguageToCP] trtLanguageToCP_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsLanguage_v7

		on	


					j_trtBaseReference_idfsLanguage_v7.[idfsBaseReference] = trtLanguageToCP_v6.[idfsLanguage] 

					inner join	[Giraffe_Archive].[dbo].[tstCustomizationPackage] j_tstCustomizationPackage_idfCustomizationPackage_v7

		on	


					j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage] = trtLanguageToCP_v6.[idfCustomizationPackage] 
left join	[Giraffe_Archive].[dbo].[trtLanguageToCP] trtLanguageToCP_v7 
on	

					trtLanguageToCP_v7.[idfsLanguage] = trtLanguageToCP_v6.[idfsLanguage] 

					and trtLanguageToCP_v7.[idfCustomizationPackage] = trtLanguageToCP_v6.[idfCustomizationPackage] 
where trtLanguageToCP_v7.[idfsLanguage] is null 
print N'Table [trtLanguageToCP] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtStringNameTranslationToCP]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtStringNameTranslationToCP] 

(

					[idfsBaseReference]

					, [idfsLanguage]

					, [idfCustomizationPackage]

					, [strTextString]

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
select 

					j_trtStringNameTranslation_idfsBaseReference_idfsLanguage_v7.[idfsBaseReference]

					, j_trtStringNameTranslation_idfsBaseReference_idfsLanguage_v7.[idfsLanguage]

					, j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage]

					, trtStringNameTranslationToCP_v6.[strTextString]

					, trtStringNameTranslationToCP_v6.[rowguid]

					, trtStringNameTranslationToCP_v6.[strMaintenanceFlag]

					, trtStringNameTranslationToCP_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsBaseReference":' + isnull(cast(trtStringNameTranslationToCP_v6.[idfsBaseReference] as nvarchar(20)), N'null') + N',' + N'"idfsLanguage":' + isnull(cast(trtStringNameTranslationToCP_v6.[idfsLanguage] as nvarchar(20)), N'null') + N',' + N'"idfCustomizationPackage":' + isnull(cast(trtStringNameTranslationToCP_v6.[idfCustomizationPackage] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtStringNameTranslationToCP] trtStringNameTranslationToCP_v6 


					inner join	[Giraffe_Archive].[dbo].[trtStringNameTranslation] j_trtStringNameTranslation_idfsBaseReference_idfsLanguage_v7

		on	


					j_trtStringNameTranslation_idfsBaseReference_idfsLanguage_v7.[idfsBaseReference] = trtStringNameTranslationToCP_v6.[idfsBaseReference] 


					and j_trtStringNameTranslation_idfsBaseReference_idfsLanguage_v7.[idfsLanguage] = trtStringNameTranslationToCP_v6.[idfsLanguage] 

					inner join	[Giraffe_Archive].[dbo].[tstCustomizationPackage] j_tstCustomizationPackage_idfCustomizationPackage_v7

		on	


					j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage] = trtStringNameTranslationToCP_v6.[idfCustomizationPackage] 
left join	[Giraffe_Archive].[dbo].[trtStringNameTranslationToCP] trtStringNameTranslationToCP_v7 
on	

					trtStringNameTranslationToCP_v7.[idfsBaseReference] = trtStringNameTranslationToCP_v6.[idfsBaseReference] 

					and trtStringNameTranslationToCP_v7.[idfsLanguage] = trtStringNameTranslationToCP_v6.[idfsLanguage] 

					and trtStringNameTranslationToCP_v7.[idfCustomizationPackage] = trtStringNameTranslationToCP_v6.[idfCustomizationPackage] 
where trtStringNameTranslationToCP_v7.[idfsBaseReference] is null 
print N'Table [trtStringNameTranslationToCP] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtBaseReferenceAttributeToCP]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtBaseReferenceAttributeToCP] 

(

					[idfBaseReferenceAttribute]

					, [idfCustomizationPackage]

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
select 

					j_trtBaseReferenceAttribute_idfBaseReferenceAttribute_v7.[idfBaseReferenceAttribute]

					, j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage]

					, trtBaseReferenceAttributeToCP_v6.[rowguid]

					, trtBaseReferenceAttributeToCP_v6.[strMaintenanceFlag]

					, trtBaseReferenceAttributeToCP_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfBaseReferenceAttribute":' + isnull(cast(trtBaseReferenceAttributeToCP_v6.[idfBaseReferenceAttribute] as nvarchar(20)), N'null') + N',' + N'"idfCustomizationPackage":' + isnull(cast(trtBaseReferenceAttributeToCP_v6.[idfCustomizationPackage] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtBaseReferenceAttributeToCP] trtBaseReferenceAttributeToCP_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReferenceAttribute] j_trtBaseReferenceAttribute_idfBaseReferenceAttribute_v7

		on	


					j_trtBaseReferenceAttribute_idfBaseReferenceAttribute_v7.[idfBaseReferenceAttribute] = trtBaseReferenceAttributeToCP_v6.[idfBaseReferenceAttribute] 

					inner join	[Giraffe_Archive].[dbo].[tstCustomizationPackage] j_tstCustomizationPackage_idfCustomizationPackage_v7

		on	


					j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage] = trtBaseReferenceAttributeToCP_v6.[idfCustomizationPackage] 
left join	[Giraffe_Archive].[dbo].[trtBaseReferenceAttributeToCP] trtBaseReferenceAttributeToCP_v7 
on	

					trtBaseReferenceAttributeToCP_v7.[idfBaseReferenceAttribute] = trtBaseReferenceAttributeToCP_v6.[idfBaseReferenceAttribute] 

					and trtBaseReferenceAttributeToCP_v7.[idfCustomizationPackage] = trtBaseReferenceAttributeToCP_v6.[idfCustomizationPackage] 
where trtBaseReferenceAttributeToCP_v7.[idfBaseReferenceAttribute] is null 
print N'Table [trtBaseReferenceAttributeToCP] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtCollectionMethodForVectorTypeToCP]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtCollectionMethodForVectorTypeToCP] 

(

					[idfCollectionMethodForVectorType]

					, [idfCustomizationPackage]

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
select 

					j_trtCollectionMethodForVectorType_idfCollectionMethodForVectorType_v7.[idfCollectionMethodForVectorType]

					, j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage]

					, trtCollectionMethodForVectorTypeToCP_v6.[rowguid]

					, trtCollectionMethodForVectorTypeToCP_v6.[strMaintenanceFlag]

					, trtCollectionMethodForVectorTypeToCP_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfCollectionMethodForVectorType":' + isnull(cast(trtCollectionMethodForVectorTypeToCP_v6.[idfCollectionMethodForVectorType] as nvarchar(20)), N'null') + N',' + N'"idfCustomizationPackage":' + isnull(cast(trtCollectionMethodForVectorTypeToCP_v6.[idfCustomizationPackage] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtCollectionMethodForVectorTypeToCP] trtCollectionMethodForVectorTypeToCP_v6 


					inner join	[Giraffe_Archive].[dbo].[trtCollectionMethodForVectorType] j_trtCollectionMethodForVectorType_idfCollectionMethodForVectorType_v7

		on	


					j_trtCollectionMethodForVectorType_idfCollectionMethodForVectorType_v7.[idfCollectionMethodForVectorType] = trtCollectionMethodForVectorTypeToCP_v6.[idfCollectionMethodForVectorType] 

					inner join	[Giraffe_Archive].[dbo].[tstCustomizationPackage] j_tstCustomizationPackage_idfCustomizationPackage_v7

		on	


					j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage] = trtCollectionMethodForVectorTypeToCP_v6.[idfCustomizationPackage] 
left join	[Giraffe_Archive].[dbo].[trtCollectionMethodForVectorTypeToCP] trtCollectionMethodForVectorTypeToCP_v7 
on	

					trtCollectionMethodForVectorTypeToCP_v7.[idfCollectionMethodForVectorType] = trtCollectionMethodForVectorTypeToCP_v6.[idfCollectionMethodForVectorType] 

					and trtCollectionMethodForVectorTypeToCP_v7.[idfCustomizationPackage] = trtCollectionMethodForVectorTypeToCP_v6.[idfCustomizationPackage] 
where trtCollectionMethodForVectorTypeToCP_v7.[idfCollectionMethodForVectorType] is null 
print N'Table [trtCollectionMethodForVectorTypeToCP] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtDerivativeForSampleTypeToCP]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtDerivativeForSampleTypeToCP] 

(

					[idfDerivativeForSampleType]

					, [idfCustomizationPackage]

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
select 

					j_trtDerivativeForSampleType_idfDerivativeForSampleType_v7.[idfDerivativeForSampleType]

					, j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage]

					, trtDerivativeForSampleTypeToCP_v6.[rowguid]

					, trtDerivativeForSampleTypeToCP_v6.[strMaintenanceFlag]

					, trtDerivativeForSampleTypeToCP_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfDerivativeForSampleType":' + isnull(cast(trtDerivativeForSampleTypeToCP_v6.[idfDerivativeForSampleType] as nvarchar(20)), N'null') + N',' + N'"idfCustomizationPackage":' + isnull(cast(trtDerivativeForSampleTypeToCP_v6.[idfCustomizationPackage] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtDerivativeForSampleTypeToCP] trtDerivativeForSampleTypeToCP_v6 


					inner join	[Giraffe_Archive].[dbo].[trtDerivativeForSampleType] j_trtDerivativeForSampleType_idfDerivativeForSampleType_v7

		on	


					j_trtDerivativeForSampleType_idfDerivativeForSampleType_v7.[idfDerivativeForSampleType] = trtDerivativeForSampleTypeToCP_v6.[idfDerivativeForSampleType] 

					inner join	[Giraffe_Archive].[dbo].[tstCustomizationPackage] j_tstCustomizationPackage_idfCustomizationPackage_v7

		on	


					j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage] = trtDerivativeForSampleTypeToCP_v6.[idfCustomizationPackage] 
left join	[Giraffe_Archive].[dbo].[trtDerivativeForSampleTypeToCP] trtDerivativeForSampleTypeToCP_v7 
on	

					trtDerivativeForSampleTypeToCP_v7.[idfDerivativeForSampleType] = trtDerivativeForSampleTypeToCP_v6.[idfDerivativeForSampleType] 

					and trtDerivativeForSampleTypeToCP_v7.[idfCustomizationPackage] = trtDerivativeForSampleTypeToCP_v6.[idfCustomizationPackage] 
where trtDerivativeForSampleTypeToCP_v7.[idfDerivativeForSampleType] is null 
print N'Table [trtDerivativeForSampleTypeToCP] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtDiagnosisAgeGroupToDiagnosisToCP]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtDiagnosisAgeGroupToDiagnosisToCP] 

(

					[idfDiagnosisAgeGroupToDiagnosis]

					, [idfCustomizationPackage]

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
select 

					j_trtDiagnosisAgeGroupToDiagnosis_idfDiagnosisAgeGroupToDiagnosis_v7.[idfDiagnosisAgeGroupToDiagnosis]

					, j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage]

					, trtDiagnosisAgeGroupToDiagnosisToCP_v6.[rowguid]

					, trtDiagnosisAgeGroupToDiagnosisToCP_v6.[strMaintenanceFlag]

					, trtDiagnosisAgeGroupToDiagnosisToCP_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfDiagnosisAgeGroupToDiagnosis":' + isnull(cast(trtDiagnosisAgeGroupToDiagnosisToCP_v6.[idfDiagnosisAgeGroupToDiagnosis] as nvarchar(20)), N'null') + N',' + N'"idfCustomizationPackage":' + isnull(cast(trtDiagnosisAgeGroupToDiagnosisToCP_v6.[idfCustomizationPackage] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtDiagnosisAgeGroupToDiagnosisToCP] trtDiagnosisAgeGroupToDiagnosisToCP_v6 


					inner join	[Giraffe_Archive].[dbo].[trtDiagnosisAgeGroupToDiagnosis] j_trtDiagnosisAgeGroupToDiagnosis_idfDiagnosisAgeGroupToDiagnosis_v7

		on	


					j_trtDiagnosisAgeGroupToDiagnosis_idfDiagnosisAgeGroupToDiagnosis_v7.[idfDiagnosisAgeGroupToDiagnosis] = trtDiagnosisAgeGroupToDiagnosisToCP_v6.[idfDiagnosisAgeGroupToDiagnosis] 

					inner join	[Giraffe_Archive].[dbo].[tstCustomizationPackage] j_tstCustomizationPackage_idfCustomizationPackage_v7

		on	


					j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage] = trtDiagnosisAgeGroupToDiagnosisToCP_v6.[idfCustomizationPackage] 
left join	[Giraffe_Archive].[dbo].[trtDiagnosisAgeGroupToDiagnosisToCP] trtDiagnosisAgeGroupToDiagnosisToCP_v7 
on	

					trtDiagnosisAgeGroupToDiagnosisToCP_v7.[idfDiagnosisAgeGroupToDiagnosis] = trtDiagnosisAgeGroupToDiagnosisToCP_v6.[idfDiagnosisAgeGroupToDiagnosis] 

					and trtDiagnosisAgeGroupToDiagnosisToCP_v7.[idfCustomizationPackage] = trtDiagnosisAgeGroupToDiagnosisToCP_v6.[idfCustomizationPackage] 
where trtDiagnosisAgeGroupToDiagnosisToCP_v7.[idfDiagnosisAgeGroupToDiagnosis] is null 
print N'Table [trtDiagnosisAgeGroupToDiagnosisToCP] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtDiagnosisAgeGroupToStatisticalAgeGroupToCP]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtDiagnosisAgeGroupToStatisticalAgeGroupToCP] 

(

					[idfDiagnosisAgeGroupToStatisticalAgeGroup]

					, [idfCustomizationPackage]

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
select 

					j_trtDiagnosisAgeGroupToStatisticalAgeGroup_idfDiagnosisAgeGroupToStatisticalAgeGroup_v7.[idfDiagnosisAgeGroupToStatisticalAgeGroup]

					, j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage]

					, trtDiagnosisAgeGroupToStatisticalAgeGroupToCP_v6.[rowguid]

					, trtDiagnosisAgeGroupToStatisticalAgeGroupToCP_v6.[strMaintenanceFlag]

					, trtDiagnosisAgeGroupToStatisticalAgeGroupToCP_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfDiagnosisAgeGroupToStatisticalAgeGroup":' + isnull(cast(trtDiagnosisAgeGroupToStatisticalAgeGroupToCP_v6.[idfDiagnosisAgeGroupToStatisticalAgeGroup] as nvarchar(20)), N'null') + N',' + N'"idfCustomizationPackage":' + isnull(cast(trtDiagnosisAgeGroupToStatisticalAgeGroupToCP_v6.[idfCustomizationPackage] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtDiagnosisAgeGroupToStatisticalAgeGroupToCP] trtDiagnosisAgeGroupToStatisticalAgeGroupToCP_v6 


					inner join	[Giraffe_Archive].[dbo].[trtDiagnosisAgeGroupToStatisticalAgeGroup] j_trtDiagnosisAgeGroupToStatisticalAgeGroup_idfDiagnosisAgeGroupToStatisticalAgeGroup_v7

		on	


					j_trtDiagnosisAgeGroupToStatisticalAgeGroup_idfDiagnosisAgeGroupToStatisticalAgeGroup_v7.[idfDiagnosisAgeGroupToStatisticalAgeGroup] = trtDiagnosisAgeGroupToStatisticalAgeGroupToCP_v6.[idfDiagnosisAgeGroupToStatisticalAgeGroup] 

					inner join	[Giraffe_Archive].[dbo].[tstCustomizationPackage] j_tstCustomizationPackage_idfCustomizationPackage_v7

		on	


					j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage] = trtDiagnosisAgeGroupToStatisticalAgeGroupToCP_v6.[idfCustomizationPackage] 
left join	[Giraffe_Archive].[dbo].[trtDiagnosisAgeGroupToStatisticalAgeGroupToCP] trtDiagnosisAgeGroupToStatisticalAgeGroupToCP_v7 
on	

					trtDiagnosisAgeGroupToStatisticalAgeGroupToCP_v7.[idfDiagnosisAgeGroupToStatisticalAgeGroup] = trtDiagnosisAgeGroupToStatisticalAgeGroupToCP_v6.[idfDiagnosisAgeGroupToStatisticalAgeGroup] 

					and trtDiagnosisAgeGroupToStatisticalAgeGroupToCP_v7.[idfCustomizationPackage] = trtDiagnosisAgeGroupToStatisticalAgeGroupToCP_v6.[idfCustomizationPackage] 
where trtDiagnosisAgeGroupToStatisticalAgeGroupToCP_v7.[idfDiagnosisAgeGroupToStatisticalAgeGroup] is null 
print N'Table [trtDiagnosisAgeGroupToStatisticalAgeGroupToCP] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtDiagnosisToDiagnosisGroupToCP]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtDiagnosisToDiagnosisGroupToCP] 

(

					[idfDiagnosisToDiagnosisGroup]

					, [idfCustomizationPackage]

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
select 

					j_trtDiagnosisToDiagnosisGroup_idfDiagnosisToDiagnosisGroup_v7.[idfDiagnosisToDiagnosisGroup]

					, j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage]

					, trtDiagnosisToDiagnosisGroupToCP_v6.[rowguid]

					, trtDiagnosisToDiagnosisGroupToCP_v6.[strMaintenanceFlag]

					, trtDiagnosisToDiagnosisGroupToCP_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfDiagnosisToDiagnosisGroup":' + isnull(cast(trtDiagnosisToDiagnosisGroupToCP_v6.[idfDiagnosisToDiagnosisGroup] as nvarchar(20)), N'null') + N',' + N'"idfCustomizationPackage":' + isnull(cast(trtDiagnosisToDiagnosisGroupToCP_v6.[idfCustomizationPackage] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtDiagnosisToDiagnosisGroupToCP] trtDiagnosisToDiagnosisGroupToCP_v6 


					inner join	[Giraffe_Archive].[dbo].[trtDiagnosisToDiagnosisGroup] j_trtDiagnosisToDiagnosisGroup_idfDiagnosisToDiagnosisGroup_v7

		on	


					j_trtDiagnosisToDiagnosisGroup_idfDiagnosisToDiagnosisGroup_v7.[idfDiagnosisToDiagnosisGroup] = trtDiagnosisToDiagnosisGroupToCP_v6.[idfDiagnosisToDiagnosisGroup] 

					inner join	[Giraffe_Archive].[dbo].[tstCustomizationPackage] j_tstCustomizationPackage_idfCustomizationPackage_v7

		on	


					j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage] = trtDiagnosisToDiagnosisGroupToCP_v6.[idfCustomizationPackage] 
left join	[Giraffe_Archive].[dbo].[trtDiagnosisToDiagnosisGroupToCP] trtDiagnosisToDiagnosisGroupToCP_v7 
on	

					trtDiagnosisToDiagnosisGroupToCP_v7.[idfDiagnosisToDiagnosisGroup] = trtDiagnosisToDiagnosisGroupToCP_v6.[idfDiagnosisToDiagnosisGroup] 

					and trtDiagnosisToDiagnosisGroupToCP_v7.[idfCustomizationPackage] = trtDiagnosisToDiagnosisGroupToCP_v6.[idfCustomizationPackage] 
where trtDiagnosisToDiagnosisGroupToCP_v7.[idfDiagnosisToDiagnosisGroup] is null 
print N'Table [trtDiagnosisToDiagnosisGroupToCP] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtMaterialForDiseaseToCP]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtMaterialForDiseaseToCP] 

(

					[idfMaterialForDisease]

					, [idfCustomizationPackage]

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
select 

					j_trtMaterialForDisease_idfMaterialForDisease_v7.[idfMaterialForDisease]

					, j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage]

					, trtMaterialForDiseaseToCP_v6.[rowguid]

					, trtMaterialForDiseaseToCP_v6.[strMaintenanceFlag]

					, trtMaterialForDiseaseToCP_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfMaterialForDisease":' + isnull(cast(trtMaterialForDiseaseToCP_v6.[idfMaterialForDisease] as nvarchar(20)), N'null') + N',' + N'"idfCustomizationPackage":' + isnull(cast(trtMaterialForDiseaseToCP_v6.[idfCustomizationPackage] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtMaterialForDiseaseToCP] trtMaterialForDiseaseToCP_v6 


					inner join	[Giraffe_Archive].[dbo].[trtMaterialForDisease] j_trtMaterialForDisease_idfMaterialForDisease_v7

		on	


					j_trtMaterialForDisease_idfMaterialForDisease_v7.[idfMaterialForDisease] = trtMaterialForDiseaseToCP_v6.[idfMaterialForDisease] 

					inner join	[Giraffe_Archive].[dbo].[tstCustomizationPackage] j_tstCustomizationPackage_idfCustomizationPackage_v7

		on	


					j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage] = trtMaterialForDiseaseToCP_v6.[idfCustomizationPackage] 
left join	[Giraffe_Archive].[dbo].[trtMaterialForDiseaseToCP] trtMaterialForDiseaseToCP_v7 
on	

					trtMaterialForDiseaseToCP_v7.[idfMaterialForDisease] = trtMaterialForDiseaseToCP_v6.[idfMaterialForDisease] 

					and trtMaterialForDiseaseToCP_v7.[idfCustomizationPackage] = trtMaterialForDiseaseToCP_v6.[idfCustomizationPackage] 
where trtMaterialForDiseaseToCP_v7.[idfMaterialForDisease] is null 
print N'Table [trtMaterialForDiseaseToCP] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtPensideTestForDiseaseToCP]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtPensideTestForDiseaseToCP] 

(

					[idfPensideTestForDisease]

					, [idfCustomizationPackage]

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
select 

					j_trtPensideTestForDisease_idfPensideTestForDisease_v7.[idfPensideTestForDisease]

					, j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage]

					, trtPensideTestForDiseaseToCP_v6.[rowguid]

					, trtPensideTestForDiseaseToCP_v6.[strMaintenanceFlag]

					, trtPensideTestForDiseaseToCP_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfPensideTestForDisease":' + isnull(cast(trtPensideTestForDiseaseToCP_v6.[idfPensideTestForDisease] as nvarchar(20)), N'null') + N',' + N'"idfCustomizationPackage":' + isnull(cast(trtPensideTestForDiseaseToCP_v6.[idfCustomizationPackage] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtPensideTestForDiseaseToCP] trtPensideTestForDiseaseToCP_v6 


					inner join	[Giraffe_Archive].[dbo].[trtPensideTestForDisease] j_trtPensideTestForDisease_idfPensideTestForDisease_v7

		on	


					j_trtPensideTestForDisease_idfPensideTestForDisease_v7.[idfPensideTestForDisease] = trtPensideTestForDiseaseToCP_v6.[idfPensideTestForDisease] 

					inner join	[Giraffe_Archive].[dbo].[tstCustomizationPackage] j_tstCustomizationPackage_idfCustomizationPackage_v7

		on	


					j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage] = trtPensideTestForDiseaseToCP_v6.[idfCustomizationPackage] 
left join	[Giraffe_Archive].[dbo].[trtPensideTestForDiseaseToCP] trtPensideTestForDiseaseToCP_v7 
on	

					trtPensideTestForDiseaseToCP_v7.[idfPensideTestForDisease] = trtPensideTestForDiseaseToCP_v6.[idfPensideTestForDisease] 

					and trtPensideTestForDiseaseToCP_v7.[idfCustomizationPackage] = trtPensideTestForDiseaseToCP_v6.[idfCustomizationPackage] 
where trtPensideTestForDiseaseToCP_v7.[idfPensideTestForDisease] is null 
print N'Table [trtPensideTestForDiseaseToCP] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtPensideTestTypeForVectorTypeToCP]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtPensideTestTypeForVectorTypeToCP] 

(

					[idfPensideTestTypeForVectorType]

					, [idfCustomizationPackage]

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
select 

					j_trtPensideTestTypeForVectorType_idfPensideTestTypeForVectorType_v7.[idfPensideTestTypeForVectorType]

					, j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage]

					, trtPensideTestTypeForVectorTypeToCP_v6.[rowguid]

					, trtPensideTestTypeForVectorTypeToCP_v6.[strMaintenanceFlag]

					, trtPensideTestTypeForVectorTypeToCP_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfPensideTestTypeForVectorType":' + isnull(cast(trtPensideTestTypeForVectorTypeToCP_v6.[idfPensideTestTypeForVectorType] as nvarchar(20)), N'null') + N',' + N'"idfCustomizationPackage":' + isnull(cast(trtPensideTestTypeForVectorTypeToCP_v6.[idfCustomizationPackage] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtPensideTestTypeForVectorTypeToCP] trtPensideTestTypeForVectorTypeToCP_v6 


					inner join	[Giraffe_Archive].[dbo].[trtPensideTestTypeForVectorType] j_trtPensideTestTypeForVectorType_idfPensideTestTypeForVectorType_v7

		on	


					j_trtPensideTestTypeForVectorType_idfPensideTestTypeForVectorType_v7.[idfPensideTestTypeForVectorType] = trtPensideTestTypeForVectorTypeToCP_v6.[idfPensideTestTypeForVectorType] 

					inner join	[Giraffe_Archive].[dbo].[tstCustomizationPackage] j_tstCustomizationPackage_idfCustomizationPackage_v7

		on	


					j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage] = trtPensideTestTypeForVectorTypeToCP_v6.[idfCustomizationPackage] 
left join	[Giraffe_Archive].[dbo].[trtPensideTestTypeForVectorTypeToCP] trtPensideTestTypeForVectorTypeToCP_v7 
on	

					trtPensideTestTypeForVectorTypeToCP_v7.[idfPensideTestTypeForVectorType] = trtPensideTestTypeForVectorTypeToCP_v6.[idfPensideTestTypeForVectorType] 

					and trtPensideTestTypeForVectorTypeToCP_v7.[idfCustomizationPackage] = trtPensideTestTypeForVectorTypeToCP_v6.[idfCustomizationPackage] 
where trtPensideTestTypeForVectorTypeToCP_v7.[idfPensideTestTypeForVectorType] is null 
print N'Table [trtPensideTestTypeForVectorTypeToCP] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtPensideTestTypeToTestResultToCP]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtPensideTestTypeToTestResultToCP] 

(

					[idfsPensideTestName]

					, [idfsPensideTestResult]

					, [idfCustomizationPackage]

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
select 

					j_trtPensideTestTypeToTestResult_idfsPensideTestName_idfsPensideTestResult_v7.[idfsPensideTestName]

					, j_trtPensideTestTypeToTestResult_idfsPensideTestName_idfsPensideTestResult_v7.[idfsPensideTestResult]

					, j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage]

					, trtPensideTestTypeToTestResultToCP_v6.[rowguid]

					, trtPensideTestTypeToTestResultToCP_v6.[strMaintenanceFlag]

					, trtPensideTestTypeToTestResultToCP_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsPensideTestName":' + isnull(cast(trtPensideTestTypeToTestResultToCP_v6.[idfsPensideTestName] as nvarchar(20)), N'null') + N',' + N'"idfsPensideTestResult":' + isnull(cast(trtPensideTestTypeToTestResultToCP_v6.[idfsPensideTestResult] as nvarchar(20)), N'null') + N',' + N'"idfCustomizationPackage":' + isnull(cast(trtPensideTestTypeToTestResultToCP_v6.[idfCustomizationPackage] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtPensideTestTypeToTestResultToCP] trtPensideTestTypeToTestResultToCP_v6 


					inner join	[Giraffe_Archive].[dbo].[trtPensideTestTypeToTestResult] j_trtPensideTestTypeToTestResult_idfsPensideTestName_idfsPensideTestResult_v7

		on	


					j_trtPensideTestTypeToTestResult_idfsPensideTestName_idfsPensideTestResult_v7.[idfsPensideTestName] = trtPensideTestTypeToTestResultToCP_v6.[idfsPensideTestName] 


					and j_trtPensideTestTypeToTestResult_idfsPensideTestName_idfsPensideTestResult_v7.[idfsPensideTestResult] = trtPensideTestTypeToTestResultToCP_v6.[idfsPensideTestResult] 

					inner join	[Giraffe_Archive].[dbo].[tstCustomizationPackage] j_tstCustomizationPackage_idfCustomizationPackage_v7

		on	


					j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage] = trtPensideTestTypeToTestResultToCP_v6.[idfCustomizationPackage] 
left join	[Giraffe_Archive].[dbo].[trtPensideTestTypeToTestResultToCP] trtPensideTestTypeToTestResultToCP_v7 
on	

					trtPensideTestTypeToTestResultToCP_v7.[idfsPensideTestName] = trtPensideTestTypeToTestResultToCP_v6.[idfsPensideTestName] 

					and trtPensideTestTypeToTestResultToCP_v7.[idfsPensideTestResult] = trtPensideTestTypeToTestResultToCP_v6.[idfsPensideTestResult] 

					and trtPensideTestTypeToTestResultToCP_v7.[idfCustomizationPackage] = trtPensideTestTypeToTestResultToCP_v6.[idfCustomizationPackage] 
where trtPensideTestTypeToTestResultToCP_v7.[idfsPensideTestName] is null 
print N'Table [trtPensideTestTypeToTestResultToCP] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtSampleTypeForVectorTypeToCP]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtSampleTypeForVectorTypeToCP] 

(

					[idfSampleTypeForVectorType]

					, [idfCustomizationPackage]

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
select 

					j_trtSampleTypeForVectorType_idfSampleTypeForVectorType_v7.[idfSampleTypeForVectorType]

					, j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage]

					, trtSampleTypeForVectorTypeToCP_v6.[rowguid]

					, trtSampleTypeForVectorTypeToCP_v6.[strMaintenanceFlag]

					, trtSampleTypeForVectorTypeToCP_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfSampleTypeForVectorType":' + isnull(cast(trtSampleTypeForVectorTypeToCP_v6.[idfSampleTypeForVectorType] as nvarchar(20)), N'null') + N',' + N'"idfCustomizationPackage":' + isnull(cast(trtSampleTypeForVectorTypeToCP_v6.[idfCustomizationPackage] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtSampleTypeForVectorTypeToCP] trtSampleTypeForVectorTypeToCP_v6 


					inner join	[Giraffe_Archive].[dbo].[trtSampleTypeForVectorType] j_trtSampleTypeForVectorType_idfSampleTypeForVectorType_v7

		on	


					j_trtSampleTypeForVectorType_idfSampleTypeForVectorType_v7.[idfSampleTypeForVectorType] = trtSampleTypeForVectorTypeToCP_v6.[idfSampleTypeForVectorType] 

					inner join	[Giraffe_Archive].[dbo].[tstCustomizationPackage] j_tstCustomizationPackage_idfCustomizationPackage_v7

		on	


					j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage] = trtSampleTypeForVectorTypeToCP_v6.[idfCustomizationPackage] 
left join	[Giraffe_Archive].[dbo].[trtSampleTypeForVectorTypeToCP] trtSampleTypeForVectorTypeToCP_v7 
on	

					trtSampleTypeForVectorTypeToCP_v7.[idfSampleTypeForVectorType] = trtSampleTypeForVectorTypeToCP_v6.[idfSampleTypeForVectorType] 

					and trtSampleTypeForVectorTypeToCP_v7.[idfCustomizationPackage] = trtSampleTypeForVectorTypeToCP_v6.[idfCustomizationPackage] 
where trtSampleTypeForVectorTypeToCP_v7.[idfSampleTypeForVectorType] is null 
print N'Table [trtSampleTypeForVectorTypeToCP] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtSpeciesTypeToAnimalAgeToCP]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtSpeciesTypeToAnimalAgeToCP] 

(

					[idfSpeciesTypeToAnimalAge]

					, [idfCustomizationPackage]

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
select 

					j_trtSpeciesTypeToAnimalAge_idfSpeciesTypeToAnimalAge_v7.[idfSpeciesTypeToAnimalAge]

					, j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage]

					, trtSpeciesTypeToAnimalAgeToCP_v6.[rowguid]

					, trtSpeciesTypeToAnimalAgeToCP_v6.[strMaintenanceFlag]

					, trtSpeciesTypeToAnimalAgeToCP_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfSpeciesTypeToAnimalAge":' + isnull(cast(trtSpeciesTypeToAnimalAgeToCP_v6.[idfSpeciesTypeToAnimalAge] as nvarchar(20)), N'null') + N',' + N'"idfCustomizationPackage":' + isnull(cast(trtSpeciesTypeToAnimalAgeToCP_v6.[idfCustomizationPackage] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtSpeciesTypeToAnimalAgeToCP] trtSpeciesTypeToAnimalAgeToCP_v6 


					inner join	[Giraffe_Archive].[dbo].[trtSpeciesTypeToAnimalAge] j_trtSpeciesTypeToAnimalAge_idfSpeciesTypeToAnimalAge_v7

		on	


					j_trtSpeciesTypeToAnimalAge_idfSpeciesTypeToAnimalAge_v7.[idfSpeciesTypeToAnimalAge] = trtSpeciesTypeToAnimalAgeToCP_v6.[idfSpeciesTypeToAnimalAge] 

					inner join	[Giraffe_Archive].[dbo].[tstCustomizationPackage] j_tstCustomizationPackage_idfCustomizationPackage_v7

		on	


					j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage] = trtSpeciesTypeToAnimalAgeToCP_v6.[idfCustomizationPackage] 
left join	[Giraffe_Archive].[dbo].[trtSpeciesTypeToAnimalAgeToCP] trtSpeciesTypeToAnimalAgeToCP_v7 
on	

					trtSpeciesTypeToAnimalAgeToCP_v7.[idfSpeciesTypeToAnimalAge] = trtSpeciesTypeToAnimalAgeToCP_v6.[idfSpeciesTypeToAnimalAge] 

					and trtSpeciesTypeToAnimalAgeToCP_v7.[idfCustomizationPackage] = trtSpeciesTypeToAnimalAgeToCP_v6.[idfCustomizationPackage] 
where trtSpeciesTypeToAnimalAgeToCP_v7.[idfSpeciesTypeToAnimalAge] is null 
print N'Table [trtSpeciesTypeToAnimalAgeToCP] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtTestForDiseaseToCP]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtTestForDiseaseToCP] 

(

					[idfTestForDisease]

					, [idfCustomizationPackage]

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
select 

					j_trtTestForDisease_idfTestForDisease_v7.[idfTestForDisease]

					, j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage]

					, trtTestForDiseaseToCP_v6.[rowguid]

					, trtTestForDiseaseToCP_v6.[strMaintenanceFlag]

					, trtTestForDiseaseToCP_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfTestForDisease":' + isnull(cast(trtTestForDiseaseToCP_v6.[idfTestForDisease] as nvarchar(20)), N'null') + N',' + N'"idfCustomizationPackage":' + isnull(cast(trtTestForDiseaseToCP_v6.[idfCustomizationPackage] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtTestForDiseaseToCP] trtTestForDiseaseToCP_v6 


					inner join	[Giraffe_Archive].[dbo].[trtTestForDisease] j_trtTestForDisease_idfTestForDisease_v7

		on	


					j_trtTestForDisease_idfTestForDisease_v7.[idfTestForDisease] = trtTestForDiseaseToCP_v6.[idfTestForDisease] 

					inner join	[Giraffe_Archive].[dbo].[tstCustomizationPackage] j_tstCustomizationPackage_idfCustomizationPackage_v7

		on	


					j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage] = trtTestForDiseaseToCP_v6.[idfCustomizationPackage] 
left join	[Giraffe_Archive].[dbo].[trtTestForDiseaseToCP] trtTestForDiseaseToCP_v7 
on	

					trtTestForDiseaseToCP_v7.[idfTestForDisease] = trtTestForDiseaseToCP_v6.[idfTestForDisease] 

					and trtTestForDiseaseToCP_v7.[idfCustomizationPackage] = trtTestForDiseaseToCP_v6.[idfCustomizationPackage] 
where trtTestForDiseaseToCP_v7.[idfTestForDisease] is null 
print N'Table [trtTestForDiseaseToCP] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [trtTestTypeToTestResultToCP]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtTestTypeToTestResultToCP] 

(

					[idfsTestName]

					, [idfsTestResult]

					, [idfCustomizationPackage]

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
select 

					j_trtTestTypeToTestResult_idfsTestName_idfsTestResult_v7.[idfsTestName]

					, j_trtTestTypeToTestResult_idfsTestName_idfsTestResult_v7.[idfsTestResult]

					, j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage]

					, trtTestTypeToTestResultToCP_v6.[rowguid]

					, trtTestTypeToTestResultToCP_v6.[strMaintenanceFlag]

					, trtTestTypeToTestResultToCP_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsTestName":' + isnull(cast(trtTestTypeToTestResultToCP_v6.[idfsTestName] as nvarchar(20)), N'null') + N',' + N'"idfsTestResult":' + isnull(cast(trtTestTypeToTestResultToCP_v6.[idfsTestResult] as nvarchar(20)), N'null') + N',' + N'"idfCustomizationPackage":' + isnull(cast(trtTestTypeToTestResultToCP_v6.[idfCustomizationPackage] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[trtTestTypeToTestResultToCP] trtTestTypeToTestResultToCP_v6 


					inner join	[Giraffe_Archive].[dbo].[trtTestTypeToTestResult] j_trtTestTypeToTestResult_idfsTestName_idfsTestResult_v7

		on	


					j_trtTestTypeToTestResult_idfsTestName_idfsTestResult_v7.[idfsTestName] = trtTestTypeToTestResultToCP_v6.[idfsTestName] 


					and j_trtTestTypeToTestResult_idfsTestName_idfsTestResult_v7.[idfsTestResult] = trtTestTypeToTestResultToCP_v6.[idfsTestResult] 

					inner join	[Giraffe_Archive].[dbo].[tstCustomizationPackage] j_tstCustomizationPackage_idfCustomizationPackage_v7

		on	


					j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage] = trtTestTypeToTestResultToCP_v6.[idfCustomizationPackage] 
left join	[Giraffe_Archive].[dbo].[trtTestTypeToTestResultToCP] trtTestTypeToTestResultToCP_v7 
on	

					trtTestTypeToTestResultToCP_v7.[idfsTestName] = trtTestTypeToTestResultToCP_v6.[idfsTestName] 

					and trtTestTypeToTestResultToCP_v7.[idfsTestResult] = trtTestTypeToTestResultToCP_v6.[idfsTestResult] 

					and trtTestTypeToTestResultToCP_v7.[idfCustomizationPackage] = trtTestTypeToTestResultToCP_v6.[idfCustomizationPackage] 
where trtTestTypeToTestResultToCP_v7.[idfsTestName] is null 
print N'Table [trtTestTypeToTestResultToCP] - insert: ' + cast(@@rowcount as nvarchar(20))


-------

print N''
print N'Insert records - Tables with links from reference and matrices tables to Customization Package - end'
print N''
print N''
/************************************************************
* Insert records - Tables with links from reference and matrices tables to Customization Package - end
************************************************************/


--------------------------------

/************************************************************
* Insert records - Tables with rows of aggregate matrices - start
************************************************************/
print N''
print N'Insert records - Tables with rows of aggregate matrices - start'
print N''


--

/************************************************************
* Insert records - [tlbAggrMatrixVersionHeader]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tlbAggrMatrixVersionHeader] 

(

					[idfVersion]

					, [idfsMatrixType]

					, [MatrixName]

					, [datStartDate]

					, [blnIsActive]

					, [intRowStatus]

					, [rowguid]

					, [blnIsDefault]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tlbAggrMatrixVersionHeader_v6.[idfVersion]

					, j_trtBaseReference_idfsMatrixType_v7.[idfsBaseReference]

					, tlbAggrMatrixVersionHeader_v6.[MatrixName]

					, tlbAggrMatrixVersionHeader_v6.[datStartDate]

					, tlbAggrMatrixVersionHeader_v6.[blnIsActive]

					, tlbAggrMatrixVersionHeader_v6.[intRowStatus]

					, tlbAggrMatrixVersionHeader_v6.[rowguid]

					, tlbAggrMatrixVersionHeader_v6.[blnIsDefault]

					, tlbAggrMatrixVersionHeader_v6.[strMaintenanceFlag]

					, tlbAggrMatrixVersionHeader_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfVersion":' + isnull(cast(tlbAggrMatrixVersionHeader_v6.[idfVersion] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[tlbAggrMatrixVersionHeader] tlbAggrMatrixVersionHeader_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsMatrixType_v7

		on	


					j_trtBaseReference_idfsMatrixType_v7.[idfsBaseReference] = tlbAggrMatrixVersionHeader_v6.[idfsMatrixType] 
left join	[Giraffe_Archive].[dbo].[tlbAggrMatrixVersionHeader] tlbAggrMatrixVersionHeader_v7 
on	

					tlbAggrMatrixVersionHeader_v7.[idfVersion] = tlbAggrMatrixVersionHeader_v6.[idfVersion] 
where tlbAggrMatrixVersionHeader_v7.[idfVersion] is null 
print N'Table [tlbAggrMatrixVersionHeader] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbAggrHumanCaseMTX]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tlbAggrHumanCaseMTX] 

(

					[idfAggrHumanCaseMTX]

					, [idfVersion]

					, [idfsDiagnosis]

					, [intNumRow]

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
select 

					tlbAggrHumanCaseMTX_v6.[idfAggrHumanCaseMTX]

					, j_tlbAggrMatrixVersionHeader_idfVersion_v7.[idfVersion]

					, j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis]

					, tlbAggrHumanCaseMTX_v6.[intNumRow]

					, tlbAggrHumanCaseMTX_v6.[intRowStatus]

					, tlbAggrHumanCaseMTX_v6.[rowguid]

					, tlbAggrHumanCaseMTX_v6.[strMaintenanceFlag]

					, tlbAggrHumanCaseMTX_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfAggrHumanCaseMTX":' + isnull(cast(tlbAggrHumanCaseMTX_v6.[idfAggrHumanCaseMTX] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[tlbAggrHumanCaseMTX] tlbAggrHumanCaseMTX_v6 


					inner join	[Giraffe_Archive].[dbo].[tlbAggrMatrixVersionHeader] j_tlbAggrMatrixVersionHeader_idfVersion_v7

		on	


					j_tlbAggrMatrixVersionHeader_idfVersion_v7.[idfVersion] = tlbAggrHumanCaseMTX_v6.[idfVersion] 

					inner join	[Giraffe_Archive].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsDiagnosis_v7

		on	


					j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis] = tlbAggrHumanCaseMTX_v6.[idfsDiagnosis] 
left join	[Giraffe_Archive].[dbo].[tlbAggrHumanCaseMTX] tlbAggrHumanCaseMTX_v7 
on	

					tlbAggrHumanCaseMTX_v7.[idfAggrHumanCaseMTX] = tlbAggrHumanCaseMTX_v6.[idfAggrHumanCaseMTX] 
where tlbAggrHumanCaseMTX_v7.[idfAggrHumanCaseMTX] is null 
print N'Table [tlbAggrHumanCaseMTX] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbAggrVetCaseMTX]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tlbAggrVetCaseMTX] 

(

					[idfAggrVetCaseMTX]

					, [idfsSpeciesType]

					, [idfsDiagnosis]

					, [intRowStatus]

					, [rowguid]

					, [idfVersion]

					, [intNumRow]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tlbAggrVetCaseMTX_v6.[idfAggrVetCaseMTX]

					, j_trtSpeciesType_idfsSpeciesType_v7.[idfsSpeciesType]

					, j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis]

					, tlbAggrVetCaseMTX_v6.[intRowStatus]

					, tlbAggrVetCaseMTX_v6.[rowguid]

					, j_tlbAggrMatrixVersionHeader_idfVersion_v7.[idfVersion]

					, tlbAggrVetCaseMTX_v6.[intNumRow]

					, tlbAggrVetCaseMTX_v6.[strMaintenanceFlag]

					, tlbAggrVetCaseMTX_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfAggrVetCaseMTX":' + isnull(cast(tlbAggrVetCaseMTX_v6.[idfAggrVetCaseMTX] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[tlbAggrVetCaseMTX] tlbAggrVetCaseMTX_v6 


					inner join	[Giraffe_Archive].[dbo].[tlbAggrMatrixVersionHeader] j_tlbAggrMatrixVersionHeader_idfVersion_v7

		on	


					j_tlbAggrMatrixVersionHeader_idfVersion_v7.[idfVersion] = tlbAggrVetCaseMTX_v6.[idfVersion] 

					inner join	[Giraffe_Archive].[dbo].[trtSpeciesType] j_trtSpeciesType_idfsSpeciesType_v7

		on	


					j_trtSpeciesType_idfsSpeciesType_v7.[idfsSpeciesType] = tlbAggrVetCaseMTX_v6.[idfsSpeciesType] 

					inner join	[Giraffe_Archive].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsDiagnosis_v7

		on	


					j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis] = tlbAggrVetCaseMTX_v6.[idfsDiagnosis] 
left join	[Giraffe_Archive].[dbo].[tlbAggrVetCaseMTX] tlbAggrVetCaseMTX_v7 
on	

					tlbAggrVetCaseMTX_v7.[idfAggrVetCaseMTX] = tlbAggrVetCaseMTX_v6.[idfAggrVetCaseMTX] 
where tlbAggrVetCaseMTX_v7.[idfAggrVetCaseMTX] is null 
print N'Table [tlbAggrVetCaseMTX] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbAggrDiagnosticActionMTX]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tlbAggrDiagnosticActionMTX] 

(

					[idfAggrDiagnosticActionMTX]

					, [idfsSpeciesType]

					, [idfsDiagnosis]

					, [idfsDiagnosticAction]

					, [intRowStatus]

					, [rowguid]

					, [idfVersion]

					, [intNumRow]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tlbAggrDiagnosticActionMTX_v6.[idfAggrDiagnosticActionMTX]

					, j_trtSpeciesType_idfsSpeciesType_v7.[idfsSpeciesType]

					, j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis]

					, j_trtBaseReference_idfsDiagnosticAction_v7.[idfsBaseReference]

					, tlbAggrDiagnosticActionMTX_v6.[intRowStatus]

					, tlbAggrDiagnosticActionMTX_v6.[rowguid]

					, j_tlbAggrMatrixVersionHeader_idfVersion_v7.[idfVersion]

					, tlbAggrDiagnosticActionMTX_v6.[intNumRow]

					, tlbAggrDiagnosticActionMTX_v6.[strMaintenanceFlag]

					, tlbAggrDiagnosticActionMTX_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfAggrDiagnosticActionMTX":' + isnull(cast(tlbAggrDiagnosticActionMTX_v6.[idfAggrDiagnosticActionMTX] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[tlbAggrDiagnosticActionMTX] tlbAggrDiagnosticActionMTX_v6 


					inner join	[Giraffe_Archive].[dbo].[trtSpeciesType] j_trtSpeciesType_idfsSpeciesType_v7

		on	


					j_trtSpeciesType_idfsSpeciesType_v7.[idfsSpeciesType] = tlbAggrDiagnosticActionMTX_v6.[idfsSpeciesType] 

					inner join	[Giraffe_Archive].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsDiagnosis_v7

		on	


					j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis] = tlbAggrDiagnosticActionMTX_v6.[idfsDiagnosis] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsDiagnosticAction_v7

		on	


					j_trtBaseReference_idfsDiagnosticAction_v7.[idfsBaseReference] = tlbAggrDiagnosticActionMTX_v6.[idfsDiagnosticAction] 

					inner join	[Giraffe_Archive].[dbo].[tlbAggrMatrixVersionHeader] j_tlbAggrMatrixVersionHeader_idfVersion_v7

		on	


					j_tlbAggrMatrixVersionHeader_idfVersion_v7.[idfVersion] = tlbAggrDiagnosticActionMTX_v6.[idfVersion] 
left join	[Giraffe_Archive].[dbo].[tlbAggrDiagnosticActionMTX] tlbAggrDiagnosticActionMTX_v7 
on	

					tlbAggrDiagnosticActionMTX_v7.[idfAggrDiagnosticActionMTX] = tlbAggrDiagnosticActionMTX_v6.[idfAggrDiagnosticActionMTX] 
where tlbAggrDiagnosticActionMTX_v7.[idfAggrDiagnosticActionMTX] is null 
print N'Table [tlbAggrDiagnosticActionMTX] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbAggrProphylacticActionMTX]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tlbAggrProphylacticActionMTX] 

(

					[idfAggrProphylacticActionMTX]

					, [idfsSpeciesType]

					, [idfsDiagnosis]

					, [idfsProphilacticAction]

					, [intRowStatus]

					, [rowguid]

					, [idfVersion]

					, [intNumRow]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tlbAggrProphylacticActionMTX_v6.[idfAggrProphylacticActionMTX]

					, j_trtSpeciesType_idfsSpeciesType_v7.[idfsSpeciesType]

					, j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis]

					, j_trtProphilacticAction_idfsProphilacticAction_v7.[idfsProphilacticAction]

					, tlbAggrProphylacticActionMTX_v6.[intRowStatus]

					, tlbAggrProphylacticActionMTX_v6.[rowguid]

					, j_tlbAggrMatrixVersionHeader_idfVersion_v7.[idfVersion]

					, tlbAggrProphylacticActionMTX_v6.[intNumRow]

					, tlbAggrProphylacticActionMTX_v6.[strMaintenanceFlag]

					, tlbAggrProphylacticActionMTX_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfAggrProphylacticActionMTX":' + isnull(cast(tlbAggrProphylacticActionMTX_v6.[idfAggrProphylacticActionMTX] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[tlbAggrProphylacticActionMTX] tlbAggrProphylacticActionMTX_v6 


					inner join	[Giraffe_Archive].[dbo].[tlbAggrMatrixVersionHeader] j_tlbAggrMatrixVersionHeader_idfVersion_v7

		on	


					j_tlbAggrMatrixVersionHeader_idfVersion_v7.[idfVersion] = tlbAggrProphylacticActionMTX_v6.[idfVersion] 

					inner join	[Giraffe_Archive].[dbo].[trtSpeciesType] j_trtSpeciesType_idfsSpeciesType_v7

		on	


					j_trtSpeciesType_idfsSpeciesType_v7.[idfsSpeciesType] = tlbAggrProphylacticActionMTX_v6.[idfsSpeciesType] 

					inner join	[Giraffe_Archive].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsDiagnosis_v7

		on	


					j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis] = tlbAggrProphylacticActionMTX_v6.[idfsDiagnosis] 

					inner join	[Giraffe_Archive].[dbo].[trtProphilacticAction] j_trtProphilacticAction_idfsProphilacticAction_v7

		on	


					j_trtProphilacticAction_idfsProphilacticAction_v7.[idfsProphilacticAction] = tlbAggrProphylacticActionMTX_v6.[idfsProphilacticAction] 
left join	[Giraffe_Archive].[dbo].[tlbAggrProphylacticActionMTX] tlbAggrProphylacticActionMTX_v7 
on	

					tlbAggrProphylacticActionMTX_v7.[idfAggrProphylacticActionMTX] = tlbAggrProphylacticActionMTX_v6.[idfAggrProphylacticActionMTX] 
where tlbAggrProphylacticActionMTX_v7.[idfAggrProphylacticActionMTX] is null 
print N'Table [tlbAggrProphylacticActionMTX] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbAggrSanitaryActionMTX]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tlbAggrSanitaryActionMTX] 

(

					[idfAggrSanitaryActionMTX]

					, [idfVersion]

					, [idfsSanitaryAction]

					, [intNumRow]

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
select 

					tlbAggrSanitaryActionMTX_v6.[idfAggrSanitaryActionMTX]

					, j_tlbAggrMatrixVersionHeader_idfVersion_v7.[idfVersion]

					, j_trtSanitaryAction_idfsSanitaryAction_v7.[idfsSanitaryAction]

					, tlbAggrSanitaryActionMTX_v6.[intNumRow]

					, tlbAggrSanitaryActionMTX_v6.[intRowStatus]

					, tlbAggrSanitaryActionMTX_v6.[rowguid]

					, tlbAggrSanitaryActionMTX_v6.[strMaintenanceFlag]

					, tlbAggrSanitaryActionMTX_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfAggrSanitaryActionMTX":' + isnull(cast(tlbAggrSanitaryActionMTX_v6.[idfAggrSanitaryActionMTX] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[tlbAggrSanitaryActionMTX] tlbAggrSanitaryActionMTX_v6 


					inner join	[Giraffe_Archive].[dbo].[tlbAggrMatrixVersionHeader] j_tlbAggrMatrixVersionHeader_idfVersion_v7

		on	


					j_tlbAggrMatrixVersionHeader_idfVersion_v7.[idfVersion] = tlbAggrSanitaryActionMTX_v6.[idfVersion] 

					inner join	[Giraffe_Archive].[dbo].[trtSanitaryAction] j_trtSanitaryAction_idfsSanitaryAction_v7

		on	


					j_trtSanitaryAction_idfsSanitaryAction_v7.[idfsSanitaryAction] = tlbAggrSanitaryActionMTX_v6.[idfsSanitaryAction] 
left join	[Giraffe_Archive].[dbo].[tlbAggrSanitaryActionMTX] tlbAggrSanitaryActionMTX_v7 
on	

					tlbAggrSanitaryActionMTX_v7.[idfAggrSanitaryActionMTX] = tlbAggrSanitaryActionMTX_v6.[idfAggrSanitaryActionMTX] 
where tlbAggrSanitaryActionMTX_v7.[idfAggrSanitaryActionMTX] is null 
print N'Table [tlbAggrSanitaryActionMTX] - insert: ' + cast(@@rowcount as nvarchar(20))


---------------------------------------

print N''
print N'Insert records - Tables with rows of aggregate matrices - end'
print N''
print N''
/************************************************************
* Insert records - Tables with rows of aggregate matrices - end
************************************************************/


--------------------------------------------------

/************************************************************
* Insert records - Tables with administrative module data - part 1 - start
************************************************************/
print N''
print N'Insert records - Tables with administrative module data - part 1 - start'
print N''

                               
-- -- --


--

/************************************************************
* Insert records - [tstSite]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tstSite] 

(

					[idfsSite]

					, [idfsSiteType]

					, [idfCustomizationPackage]

					, [idfOffice]

					, [strSiteName]

					, [strServerName]

					, [strHASCsiteID]

					, [strSiteID]

					, [intRowStatus]

					, [rowguid]

					, [intFlags]

					, [blnIsWEB]

					, [idfsParentSite]

					, [strMaintenanceFlag]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tstSite_v6.[idfsSite]

					, j_trtBaseReference_idfsSiteType_v7.[idfsBaseReference]

					, j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage]

					, null /*Will be updated below when foreign key data is available*/

					, tstSite_v6.[strSiteName]

					, tstSite_v6.[strServerName]

					, tstSite_v6.[strHASCsiteID]

					, tstSite_v6.[strSiteID]

					, tstSite_v6.[intRowStatus]

					, tstSite_v6.[rowguid]

					, tstSite_v6.[intFlags]

					, tstSite_v6.[blnIsWEB]

					, null /*Will be updated below when foreign key data is available*/

					, tstSite_v6.[strMaintenanceFlag]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsSite":' + isnull(cast(tstSite_v6.[idfsSite] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[tstSite] tstSite_v6 


					inner join	[Giraffe_Archive].[dbo].[tstCustomizationPackage] j_tstCustomizationPackage_idfCustomizationPackage_v7

		on	


					j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage] = tstSite_v6.[idfCustomizationPackage] 

					left join	[Giraffe_Archive].[dbo].[tlbOffice] j_tlbOffice_idfOffice_v7

		on	


					j_tlbOffice_idfOffice_v7.[idfOffice] = tstSite_v6.[idfOffice] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsSiteType_v7

		on	


					j_trtBaseReference_idfsSiteType_v7.[idfsBaseReference] = tstSite_v6.[idfsSiteType] 

					left join	[Giraffe_Archive].[dbo].[tstSite] j_tstSite_idfsParentSite_v7

		on	


					j_tstSite_idfsParentSite_v7.[idfsSite] = tstSite_v6.[idfsParentSite] 
left join	[Giraffe_Archive].[dbo].[tstSite] tstSite_v7 
on	

					tstSite_v7.[idfsSite] = tstSite_v6.[idfsSite] 
where tstSite_v7.[idfsSite] is null 
print N'Table [tstSite] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tstSecurityConfigurationAlphabet]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tstSecurityConfigurationAlphabet] 

(

					[idfsSecurityConfigurationAlphabet]

					, [strAlphabet]

					, [intRowStatus]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tstSecurityConfigurationAlphabet_v6.[idfsSecurityConfigurationAlphabet]

					, tstSecurityConfigurationAlphabet_v6.[strAlphabet]

					, tstSecurityConfigurationAlphabet_v6.[intRowStatus]

					, tstSecurityConfigurationAlphabet_v6.[rowguid]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsSecurityConfigurationAlphabet":' + isnull(cast(tstSecurityConfigurationAlphabet_v6.[idfsSecurityConfigurationAlphabet] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[tstSecurityConfigurationAlphabet] tstSecurityConfigurationAlphabet_v6 

left join	[Giraffe_Archive].[dbo].[tstSecurityConfigurationAlphabet] tstSecurityConfigurationAlphabet_v7 
on	

					tstSecurityConfigurationAlphabet_v7.[idfsSecurityConfigurationAlphabet] = tstSecurityConfigurationAlphabet_v6.[idfsSecurityConfigurationAlphabet] 
where tstSecurityConfigurationAlphabet_v7.[idfsSecurityConfigurationAlphabet] is null 
print N'Table [tstSecurityConfigurationAlphabet] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tstSecurityConfiguration]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tstSecurityConfiguration] 

(

					[idfSecurityConfiguration]

					, [idfParentSecurityConfiguration]

					, [idfsSecurityLevel]

					, [intAccountLockTimeout]

					, [intAccountTryCount]

					, [intInactivityTimeout]

					, [intPasswordAge]

					, [intPasswordHistoryLength]

					, [intPasswordMinimalLength]

					, [intAlphabetCount]

					, [intForcePasswordComplexity]

					, [blnPredefined]

					, [intRowStatus]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tstSecurityConfiguration_v6.[idfSecurityConfiguration]

					, tstSecurityConfiguration_v6.[idfParentSecurityConfiguration]

					, j_trtBaseReference_idfsSecurityLevel_v7.[idfsBaseReference]

					, tstSecurityConfiguration_v6.[intAccountLockTimeout]

					, tstSecurityConfiguration_v6.[intAccountTryCount]

					, tstSecurityConfiguration_v6.[intInactivityTimeout]

					, tstSecurityConfiguration_v6.[intPasswordAge]

					, tstSecurityConfiguration_v6.[intPasswordHistoryLength]

					, tstSecurityConfiguration_v6.[intPasswordMinimalLength]

					, tstSecurityConfiguration_v6.[intAlphabetCount]

					, tstSecurityConfiguration_v6.[intForcePasswordComplexity]

					, tstSecurityConfiguration_v6.[blnPredefined]

					, tstSecurityConfiguration_v6.[intRowStatus]

					, tstSecurityConfiguration_v6.[rowguid]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfSecurityConfiguration":' + isnull(cast(tstSecurityConfiguration_v6.[idfSecurityConfiguration] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[tstSecurityConfiguration] tstSecurityConfiguration_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsSecurityLevel_v7

		on	


					j_trtBaseReference_idfsSecurityLevel_v7.[idfsBaseReference] = tstSecurityConfiguration_v6.[idfsSecurityLevel] 

					left join	[Giraffe_Archive].[dbo].[tstSecurityConfiguration] j_tstSecurityConfiguration_idfParentSecurityConfiguration_v7

		on	


					j_tstSecurityConfiguration_idfParentSecurityConfiguration_v7.[idfSecurityConfiguration] = tstSecurityConfiguration_v6.[idfParentSecurityConfiguration] 
left join	[Giraffe_Archive].[dbo].[tstSecurityConfiguration] tstSecurityConfiguration_v7 
on	

					tstSecurityConfiguration_v7.[idfSecurityConfiguration] = tstSecurityConfiguration_v6.[idfSecurityConfiguration] 
where tstSecurityConfiguration_v7.[idfSecurityConfiguration] is null 
print N'Table [tstSecurityConfiguration] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tstSecurityConfigurationAlphabetParticipation]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tstSecurityConfigurationAlphabetParticipation] 

(

					[idfSecurityConfiguration]

					, [idfsSecurityConfigurationAlphabet]

					, [intRowStatus]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_tstSecurityConfiguration_idfSecurityConfiguration_v7.[idfSecurityConfiguration]

					, j_tstSecurityConfigurationAlphabet_idfsSecurityConfigurationAlphabet_v7.[idfsSecurityConfigurationAlphabet]

					, tstSecurityConfigurationAlphabetParticipation_v6.[intRowStatus]

					, tstSecurityConfigurationAlphabetParticipation_v6.[rowguid]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfSecurityConfiguration":' + isnull(cast(tstSecurityConfigurationAlphabetParticipation_v6.[idfSecurityConfiguration] as nvarchar(20)), N'null') + N',' + N'"idfsSecurityConfigurationAlphabet":' + isnull(cast(tstSecurityConfigurationAlphabetParticipation_v6.[idfsSecurityConfigurationAlphabet] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[tstSecurityConfigurationAlphabetParticipation] tstSecurityConfigurationAlphabetParticipation_v6 


					inner join	[Giraffe_Archive].[dbo].[tstSecurityConfiguration] j_tstSecurityConfiguration_idfSecurityConfiguration_v7

		on	


					j_tstSecurityConfiguration_idfSecurityConfiguration_v7.[idfSecurityConfiguration] = tstSecurityConfigurationAlphabetParticipation_v6.[idfSecurityConfiguration] 

					inner join	[Giraffe_Archive].[dbo].[tstSecurityConfigurationAlphabet] j_tstSecurityConfigurationAlphabet_idfsSecurityConfigurationAlphabet_v7

		on	


					j_tstSecurityConfigurationAlphabet_idfsSecurityConfigurationAlphabet_v7.[idfsSecurityConfigurationAlphabet] = tstSecurityConfigurationAlphabetParticipation_v6.[idfsSecurityConfigurationAlphabet] 
left join	[Giraffe_Archive].[dbo].[tstSecurityConfigurationAlphabetParticipation] tstSecurityConfigurationAlphabetParticipation_v7 
on	

					tstSecurityConfigurationAlphabetParticipation_v7.[idfSecurityConfiguration] = tstSecurityConfigurationAlphabetParticipation_v6.[idfSecurityConfiguration] 

					and tstSecurityConfigurationAlphabetParticipation_v7.[idfsSecurityConfigurationAlphabet] = tstSecurityConfigurationAlphabetParticipation_v6.[idfsSecurityConfigurationAlphabet] 
where tstSecurityConfigurationAlphabetParticipation_v7.[idfSecurityConfiguration] is null 
print N'Table [tstSecurityConfigurationAlphabetParticipation] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbGeoLocationShared]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tlbGeoLocationShared] 

(

					[idfGeoLocationShared]

					, [idfsResidentType]

					, [idfsGroundType]

					, [idfsGeoLocationType]

					, [idfsCountry]

					, [idfsRegion]

					, [idfsRayon]

					, [idfsSettlement]

					, [idfsSite]

					, [strPostCode]

					, [strStreetName]

					, [strHouse]

					, [strBuilding]

					, [strApartment]

					, [strDescription]

					, [dblDistance]

					, [dblLatitude]

					, [dblLongitude]

					, [dblAccuracy]

					, [dblAlignment]

					, [intRowStatus]

					, [rowguid]

					, [blnForeignAddress]

					, [strForeignAddress]

					, [strAddressString]

					, [strShortAddressString]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]

					, [dblElevation]

					, [idfsLocation]
)
select 

					tlbGeoLocationShared_v6.[idfGeoLocationShared]

					, j_trtBaseReference_idfsResidentType_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsGroundType_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsGeoLocationType_v7.[idfsBaseReference]

					, j_gisCountry_idfsCountry_v7.[idfsCountry]

					, j_gisRegion_idfsRegion_v7.[idfsRegion]

					, j_gisRayon_idfsRayon_v7.[idfsRayon]

					, j_gisSettlement_idfsSettlement_v7.[idfsSettlement]

					, j_tstSite_idfsSite_v7.[idfsSite]

					, tlbGeoLocationShared_v6.[strPostCode]

					, tlbGeoLocationShared_v6.[strStreetName]

					, tlbGeoLocationShared_v6.[strHouse]

					, tlbGeoLocationShared_v6.[strBuilding]

					, tlbGeoLocationShared_v6.[strApartment]

					, tlbGeoLocationShared_v6.[strDescription]

					, tlbGeoLocationShared_v6.[dblDistance]

					, tlbGeoLocationShared_v6.[dblLatitude]

					, tlbGeoLocationShared_v6.[dblLongitude]

					, tlbGeoLocationShared_v6.[dblAccuracy]

					, tlbGeoLocationShared_v6.[dblAlignment]

					, tlbGeoLocationShared_v6.[intRowStatus]

					, tlbGeoLocationShared_v6.[rowguid]

					, tlbGeoLocationShared_v6.[blnForeignAddress]

					, tlbGeoLocationShared_v6.[strForeignAddress]

					, tlbGeoLocationShared_v6.[strAddressString]

					, tlbGeoLocationShared_v6.[strShortAddressString]

					, tlbGeoLocationShared_v6.[strMaintenanceFlag]

					, tlbGeoLocationShared_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfGeoLocationShared":' + isnull(cast(tlbGeoLocationShared_v6.[idfGeoLocationShared] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()

					, null /*TODO: Check the rule for the new field in EIDSSv7: dblElevation*/

					, coalesce(j_gisSettlement_idfsSettlement_v7.[idfsSettlement], j_gisRayon_idfsRayon_v7.[idfsRayon], j_gisRegion_idfsRegion_v7.[idfsRegion], j_gisCountry_idfsCountry_v7.[idfsCountry]) /*Rule for the new field in EIDSSv7: idfsLocation*/
from [Falcon_Archive].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v6 


					inner join	[Giraffe_Archive].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tlbGeoLocationShared_v6.[idfsSite] 

					left join	[Giraffe_Archive].[dbo].[gisCountry] j_gisCountry_idfsCountry_v7

		on	


					j_gisCountry_idfsCountry_v7.[idfsCountry] = tlbGeoLocationShared_v6.[idfsCountry] 

					left join	[Giraffe_Archive].[dbo].[gisRayon] j_gisRayon_idfsRayon_v7

		on	


					j_gisRayon_idfsRayon_v7.[idfsRayon] = tlbGeoLocationShared_v6.[idfsRayon] 

					left join	[Giraffe_Archive].[dbo].[gisRegion] j_gisRegion_idfsRegion_v7

		on	


					j_gisRegion_idfsRegion_v7.[idfsRegion] = tlbGeoLocationShared_v6.[idfsRegion] 

					left join	[Giraffe_Archive].[dbo].[gisSettlement] j_gisSettlement_idfsSettlement_v7

		on	


					j_gisSettlement_idfsSettlement_v7.[idfsSettlement] = tlbGeoLocationShared_v6.[idfsSettlement] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsResidentType_v7

		on	


					j_trtBaseReference_idfsResidentType_v7.[idfsBaseReference] = tlbGeoLocationShared_v6.[idfsResidentType] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsGroundType_v7

		on	


					j_trtBaseReference_idfsGroundType_v7.[idfsBaseReference] = tlbGeoLocationShared_v6.[idfsGroundType] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsGeoLocationType_v7

		on	


					j_trtBaseReference_idfsGeoLocationType_v7.[idfsBaseReference] = tlbGeoLocationShared_v6.[idfsGeoLocationType] 
left join	[Giraffe_Archive].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v7 
on	

					tlbGeoLocationShared_v7.[idfGeoLocationShared] = tlbGeoLocationShared_v6.[idfGeoLocationShared] 
where tlbGeoLocationShared_v7.[idfGeoLocationShared] is null 
print N'Table [tlbGeoLocationShared] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbOffice]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tlbOffice] 

(

					[idfOffice]

					, [idfsOfficeName]

					, [idfsOfficeAbbreviation]

					, [idfCustomizationPackage]

					, [idfLocation]

					, [idfsSite]

					, [strContactPhone]

					, [intRowStatus]

					, [rowguid]

					, [intHACode]

					, [strOrganizationID]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [OrganizationTypeID]

					, [OwnershipFormID]

					, [LegalFormID]

					, [MainFormOfActivityID]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tlbOffice_v6.[idfOffice]

					, j_trtBaseReference_idfsOfficeName_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsOfficeAbbreviation_v7.[idfsBaseReference]

					, j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage]

					, j_tlbGeoLocationShared_idfLocation_v7.[idfGeoLocationShared]

					, j_tstSite_idfsSite_v7.[idfsSite]

					, tlbOffice_v6.[strContactPhone]

					, tlbOffice_v6.[intRowStatus]

					, tlbOffice_v6.[rowguid]

					, tlbOffice_v6.[intHACode]

					, tlbOffice_v6.[strOrganizationID]

					, tlbOffice_v6.[strMaintenanceFlag]

					, tlbOffice_v6.[strReservedAttribute]

					, null /*TODO: Check the rule for the new field in EIDSSv7: OrganizationTypeID*/

					, null /*TODO: Check the rule for the new field in EIDSSv7: OwnershipFormID*/

					, null /*TODO: Check the rule for the new field in EIDSSv7: LegalFormID*/

					, null /*TODO: Check the rule for the new field in EIDSSv7: MainFormOfActivityID*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfOffice":' + isnull(cast(tlbOffice_v6.[idfOffice] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[tlbOffice] tlbOffice_v6 


					inner join	[Giraffe_Archive].[dbo].[tstCustomizationPackage] j_tstCustomizationPackage_idfCustomizationPackage_v7

		on	


					j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage] = tlbOffice_v6.[idfCustomizationPackage] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsOfficeName_v7

		on	


					j_trtBaseReference_idfsOfficeName_v7.[idfsBaseReference] = tlbOffice_v6.[idfsOfficeName] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsOfficeAbbreviation_v7

		on	


					j_trtBaseReference_idfsOfficeAbbreviation_v7.[idfsBaseReference] = tlbOffice_v6.[idfsOfficeAbbreviation] 

					left join	[Giraffe_Archive].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tlbOffice_v6.[idfsSite] 

					left join	[Giraffe_Archive].[dbo].[tlbGeoLocationShared] j_tlbGeoLocationShared_idfLocation_v7

		on	


					j_tlbGeoLocationShared_idfLocation_v7.[idfGeoLocationShared] = tlbOffice_v6.[idfLocation] 
left join	[Giraffe_Archive].[dbo].[tlbOffice] tlbOffice_v7 
on	

					tlbOffice_v7.[idfOffice] = tlbOffice_v6.[idfOffice] 
where tlbOffice_v7.[idfOffice] is null 
print N'Table [tlbOffice] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbDepartment]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tlbDepartment] 

(

					[idfDepartment]

					, [idfsDepartmentName]

					, [idfOrganization]

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
select 

					tlbDepartment_v6.[idfDepartment]

					, j_trtBaseReference_idfsDepartmentName_v7.[idfsBaseReference]

					, j_tlbOffice_idfOrganization_v7.[idfOffice]

					, tlbDepartment_v6.[intRowStatus]

					, tlbDepartment_v6.[rowguid]

					, tlbDepartment_v6.[strMaintenanceFlag]

					, tlbDepartment_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfDepartment":' + isnull(cast(tlbDepartment_v6.[idfDepartment] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[tlbDepartment] tlbDepartment_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsDepartmentName_v7

		on	


					j_trtBaseReference_idfsDepartmentName_v7.[idfsBaseReference] = tlbDepartment_v6.[idfsDepartmentName] 

					inner join	[Giraffe_Archive].[dbo].[tlbOffice] j_tlbOffice_idfOrganization_v7

		on	


					j_tlbOffice_idfOrganization_v7.[idfOffice] = tlbDepartment_v6.[idfOrganization] 
left join	[Giraffe_Archive].[dbo].[tlbDepartment] tlbDepartment_v7 
on	

					tlbDepartment_v7.[idfDepartment] = tlbDepartment_v6.[idfDepartment] 
where tlbDepartment_v7.[idfDepartment] is null 
print N'Table [tlbDepartment] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbStatistic]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tlbStatistic] 

(

					[idfStatistic]

					, [idfsStatisticDataType]

					, [idfsMainBaseReference]

					, [idfsStatisticAreaType]

					, [idfsStatisticPeriodType]

					, [idfsArea]

					, [datStatisticStartDate]

					, [datStatisticFinishDate]

					, [varValue]

					, [intRowStatus]

					, [rowguid]

					, [idfsStatisticalAgeGroup]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tlbStatistic_v6.[idfStatistic]

					, j_trtStatisticDataType_idfsStatisticDataType_v7.[idfsStatisticDataType]

					, j_trtBaseReference_idfsMainBaseReference_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsStatisticAreaType_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsStatisticPeriodType_v7.[idfsBaseReference]

					, j_gisBaseReference_idfsArea_v7.[idfsGISBaseReference]

					, tlbStatistic_v6.[datStatisticStartDate]

					, tlbStatistic_v6.[datStatisticFinishDate]

					, tlbStatistic_v6.[varValue]

					, tlbStatistic_v6.[intRowStatus]

					, tlbStatistic_v6.[rowguid]

					, j_trtBaseReference_idfsStatisticalAgeGroup_v7.[idfsBaseReference]

					, tlbStatistic_v6.[strMaintenanceFlag]

					, tlbStatistic_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfStatistic":' + isnull(cast(tlbStatistic_v6.[idfStatistic] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[tlbStatistic] tlbStatistic_v6 


					inner join	[Giraffe_Archive].[dbo].[gisBaseReference] j_gisBaseReference_idfsArea_v7

		on	


					j_gisBaseReference_idfsArea_v7.[idfsGISBaseReference] = tlbStatistic_v6.[idfsArea] 

					inner join	[Giraffe_Archive].[dbo].[trtStatisticDataType] j_trtStatisticDataType_idfsStatisticDataType_v7

		on	


					j_trtStatisticDataType_idfsStatisticDataType_v7.[idfsStatisticDataType] = tlbStatistic_v6.[idfsStatisticDataType] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsMainBaseReference_v7

		on	


					j_trtBaseReference_idfsMainBaseReference_v7.[idfsBaseReference] = tlbStatistic_v6.[idfsMainBaseReference] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsStatisticAreaType_v7

		on	


					j_trtBaseReference_idfsStatisticAreaType_v7.[idfsBaseReference] = tlbStatistic_v6.[idfsStatisticAreaType] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsStatisticPeriodType_v7

		on	


					j_trtBaseReference_idfsStatisticPeriodType_v7.[idfsBaseReference] = tlbStatistic_v6.[idfsStatisticPeriodType] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsStatisticalAgeGroup_v7

		on	


					j_trtBaseReference_idfsStatisticalAgeGroup_v7.[idfsBaseReference] = tlbStatistic_v6.[idfsStatisticalAgeGroup] 
left join	[Giraffe_Archive].[dbo].[tlbStatistic] tlbStatistic_v7 
on	

					tlbStatistic_v7.[idfStatistic] = tlbStatistic_v6.[idfStatistic] 
where tlbStatistic_v7.[idfStatistic] is null 
print N'Table [tlbStatistic] - insert: ' + cast(@@rowcount as nvarchar(20))


--

/************************************************************
* Update records with links to foreign key data - [tstSite]
************************************************************/

update		tstSite_v7
set			tstSite_v7.idfsParentSite = tstSite_parent_v7.idfsSite
from		[Giraffe_Archive].[dbo].[tstSite] tstSite_v7
inner join	[Falcon_Archive].[dbo].[tstSite] tstSite_v6
on			tstSite_v6.idfsSite = tstSite_v7.idfsSite
inner join	[Giraffe_Archive].[dbo].[tstSite] tstSite_parent_v7
on			tstSite_parent_v7.idfsSite = tstSite_v6.idfsParentSite
where		tstSite_V7.idfsParentSite is null
print	N'Table [tstSite] - update link to the parent site from migrated sites: ' + cast(@@rowcount as nvarchar(20))

update		tstSite_v7
set			tstSite_v7.idfOffice = tlbOffice_v7.idfOffice
from		[Giraffe_Archive].[dbo].[tstSite] tstSite_v7
inner join	[Falcon_Archive].[dbo].[tstSite] tstSite_v6
on			tstSite_v6.idfsSite = tstSite_v7.idfsSite
inner join	[Giraffe_Archive].[dbo].[tlbOffice] tlbOffice_v7
on			tlbOffice_v7.idfOffice = tstSite_v6.idfOffice
where		tstSite_V7.idfOffice is null
print	N'Table [tstSite] - update link to organization: ' + cast(@@rowcount as nvarchar(20))



/************************************************************
* Update records with links to foreign key data - [tstSecurityConfiguration]
************************************************************/

update		tstSecurityConfiguration_v7
set			tstSecurityConfiguration_v7.idfParentSecurityConfiguration = tstSecurityConfiguration_parent_v7.idfSecurityConfiguration
from		[Giraffe_Archive].[dbo].[tstSecurityConfiguration] tstSecurityConfiguration_v7
inner join	[Falcon_Archive].[dbo].[tstSecurityConfiguration] tstSecurityConfiguration_v6
on			tstSecurityConfiguration_v6.idfSecurityConfiguration = tstSecurityConfiguration_v7.idfSecurityConfiguration
inner join	[Giraffe_Archive].[dbo].[tstSecurityConfiguration] tstSecurityConfiguration_parent_v7
on			tstSecurityConfiguration_parent_v7.idfSecurityConfiguration = tstSecurityConfiguration_v6.idfParentSecurityConfiguration
where		tstSecurityConfiguration_V7.idfParentSecurityConfiguration is null
print	N'Table [tstSecurityConfiguration] - update link to the parent security configuration from migrated configurations: ' + cast(@@rowcount as nvarchar(20))

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
from		[Giraffe_Archive].[dbo].[SecurityPolicyConfiguration] SecurityPolicyConfiguration_v7
inner join	[Falcon_Archive].[dbo].[tstSecurityConfiguration] tstSecurityConfiguration_v6
on			tstSecurityConfiguration_v6.idfSecurityConfiguration = 708190000000 /*Default Security Configuration in v6.1*/
where		SecurityPolicyConfiguration_v7.SecurityPolicyConfigurationUID = 1 /*Default Security Configuration in v7*/
print	N'Table [SecurityPolicyConfiguration] - update applicable settings from migrated default configuration: ' + cast(@@rowcount as nvarchar(20))




--

print N''
print N'Insert records - Tables with administrative module data - part 1 - end'
print N''
print N''
/************************************************************
* Insert records - Tables with administrative module data - part 1 - end
************************************************************/


--------------------------------------------------

/************************************************************
* Insert records - Tables with administrative module data - part 2 - start
************************************************************/
print N''
print N'Insert records - Tables with administrative module data - part 2 - start'
print N''

                               
-- -- --

/************************************************************
* Prepare data before insert - [tlbEmployee]
************************************************************/

if object_id(N'_dmccCustomUserGroup') is null
create table _dmccCustomUserGroup
(	idfEmployeeGroup_v6	bigint not null primary key,
	idfsEmployeeGroupName_v6 bigint null,
	idfEmployeeGroup_v7 bigint not null,
	idfsEmployeeGroupName_v7 bigint null,
	intIncrement int not null default(0)
)


insert into [Giraffe_Archive].[dbo].[_dmccCustomUserGroup]
(	idfEmployeeGroup_v6,
	idfsEmployeeGroupName_v6,
	idfEmployeeGroup_v7,
	idfsEmployeeGroupName_v7

)
select		tlbEmployeeGroup_v6.idfEmployeeGroup,
			tlbEmployeeGroup_v6.idfsEmployeeGroupName,
			isnull(tlbEmployee_v7.idfEmployee, tlbEmployeeGroup_v6.idfEmployeeGroup),
			tlbEmployeeGroup_v7.idfsEmployeeGroupName
from		[Falcon_Archive].[dbo].[tlbEmployee] tlbEmployee_v6
inner join	[Falcon_Archive].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v6
on			tlbEmployeeGroup_v6.idfEmployeeGroup = tlbEmployee_v6.idfEmployee
left join	[Giraffe_Archive].[dbo].[tlbEmployee] tlbEmployee_v7
	inner join	[Giraffe_Archive].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v7
	on			tlbEmployeeGroup_v7.idfEmployeeGroup = tlbEmployee_v7.idfEmployee
on			tlbEmployee_v7.idfEmployee = tlbEmployee_v6.idfEmployee
			and tlbEmployee_v7.idfsEmployeeType = 10023001 /*User Group*/
left join	[Giraffe_Archive].[dbo].[_dmccCustomUserGroup] cug
on			cug.[idfEmployeeGroup_v6] = tlbEmployeeGroup_v6.idfEmployeeGroup
where		tlbEmployee_v6.idfsEmployeeType = 10023001 /*User Group*/
			and cug.[idfEmployeeGroup_v6] is null

update		cug
set			cug.intIncrement = id_increment.intValue
from		[Giraffe_Archive].[dbo].[_dmccCustomUserGroup] cug
cross apply
(	select	count(cug_count.idfEmployeeGroup_v6) as intValue
	from	[Giraffe_Archive].[dbo].[_dmccCustomUserGroup] cug_count
	where	cug_count.idfEmployeeGroup_v7 = cug_count.idfEmployeeGroup_v6
			and cug_count.idfEmployeeGroup_v7 >= 0
			and cug_count.idfEmployeeGroup_v6 <= cug.idfEmployeeGroup_v6
) id_increment
where		cug.idfEmployeeGroup_v7 = cug.idfEmployeeGroup_v6
			and cug.idfEmployeeGroup_v7 >= 0

declare	@MinGroupId bigint

select	@MinGroupId = min(tlbEmployeeGroup_v7.idfEmployeeGroup)
from	[Giraffe_Archive].[dbo].[tlbEmployee] tlbEmployee_v7
inner join	[Giraffe_Archive].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v7
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
from		[Giraffe_Archive].[dbo].[_dmccCustomUserGroup] cug
where		cug.idfEmployeeGroup_v7 = cug.idfEmployeeGroup_v6
			and cug.idfEmployeeGroup_v7 >= 0

/************************************************************
* Insert records - Names of user-defined (custom) user groups - start
************************************************************/
print N''
print N'Insert records - Names of user-defined (custom) user groups - start'
print N''
         

/************************************************************
* Insert records - [trtBaseReference]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtBaseReference] 

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
					,  @CountryPrefix + replace(replace(replace(replace(replace(replace(isnull(trtBaseReference_v6.[strDefault], N''), N' ', N''), N'(', N''), N')', N''), N'''', N''), N'№', N'N'), N'"', N'')
					, trtBaseReference_v6.[strDefault]
					, trtBaseReference_v6.[intHACode]
					, trtBaseReference_v6.[intOrder]
					, trtBaseReference_v6.[blnSystem]
					, trtBaseReference_v6.[intRowStatus]
					, trtBaseReference_v6.[rowguid]
					, trtBaseReference_v6.[strMaintenanceFlag]
					, trtBaseReference_v6.[strReservedAttribute]
					, 10519002 /*Record Source: EIDSS6.1*/
					, N'[{' + N'"idfsBaseReference":' + isnull(cast(cug.idfsEmployeeGroupName_v7 as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS
					, N'system'
					, GETUTCDATE()
					, N'system'
					, GETUTCDATE()

from		[Falcon_Archive].[dbo].[tlbEmployee] tlbEmployee_v6
inner join	[Falcon_Archive].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v6
on			tlbEmployeeGroup_v6.idfEmployeeGroup = tlbEmployee_v6.idfEmployee
inner join	[Giraffe_Archive].[dbo].[_dmccCustomUserGroup] cug
on			cug.idfEmployeeGroup_v6 = tlbEmployeeGroup_v6.idfEmployeeGroup
inner join	[Falcon_Archive].[dbo].[trtBaseReference] trtBaseReference_v6
on			trtBaseReference_v6.idfsBaseReference = tlbEmployeeGroup_v6.idfsEmployeeGroupName
left join	[Giraffe_Archive].[dbo].[trtBaseReference] trtBaseReference_v7 
on			trtBaseReference_v7.[idfsBaseReference] = cug.idfsEmployeeGroupName_v7
where		tlbEmployee_v6.idfsEmployeeType = 10023001 /*User Group*/
			and cug.idfsEmployeeGroupName_v7 is not null
			and trtBaseReference_v7.[idfsBaseReference] is null 
print N'Table [trtBaseReference] - insert: ' + cast(@@rowcount as nvarchar(20))
                  


/************************************************************
* Insert records - [trtStringNameTranslation]
************************************************************/
insert into [Giraffe_Archive].[dbo].[trtStringNameTranslation] 

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
					, N'[{' + N'"idfsBaseReference":' + isnull(cast(cug.idfsEmployeeGroupName_v7 as nvarchar(20)), N'null') + N',' + N'"idfsLanguage":' + isnull(cast(trtStringNameTranslation_v6.[idfsLanguage] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS
					, N'system'
					, GETUTCDATE()
					, N'system'
					, GETUTCDATE()

from		[Falcon_Archive].[dbo].[tlbEmployee] tlbEmployee_v6
inner join	[Falcon_Archive].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v6
on			tlbEmployeeGroup_v6.idfEmployeeGroup = tlbEmployee_v6.idfEmployee
inner join	[Giraffe_Archive].[dbo].[_dmccCustomUserGroup] cug
on			cug.idfEmployeeGroup_v6 = tlbEmployeeGroup_v6.idfEmployeeGroup
inner join	[Falcon_Archive].[dbo].[trtBaseReference] trtBaseReference_v6
on			trtBaseReference_v6.idfsBaseReference = tlbEmployeeGroup_v6.idfsEmployeeGroupName
inner join	[Falcon_Archive].[dbo].[trtStringNameTranslation] trtStringNameTranslation_v6
on			trtStringNameTranslation_v6.idfsBaseReference = tlbEmployeeGroup_v6.idfsEmployeeGroupName

inner join	[Giraffe_Archive].[dbo].[trtBaseReference] trtBaseReference_v7 
on			trtBaseReference_v7.[idfsBaseReference] = cug.idfsEmployeeGroupName_v7
inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsLanguage_v7
on			j_trtBaseReference_idfsLanguage_v7.[idfsBaseReference] = trtStringNameTranslation_v6.[idfsLanguage] 

left join	[Giraffe_Archive].[dbo].[trtStringNameTranslation] trtStringNameTranslation_v7 
on			trtStringNameTranslation_v7.[idfsBaseReference] = cug.idfsEmployeeGroupName_v7 
			and trtStringNameTranslation_v7.[idfsLanguage] = trtStringNameTranslation_v6.[idfsLanguage] 

where		tlbEmployee_v6.idfsEmployeeType = 10023001 /*User Group*/
			and cug.idfsEmployeeGroupName_v7 is not null
			and trtStringNameTranslation_v7.[idfsBaseReference] is null 
print N'Table [trtStringNameTranslation] - insert: ' + cast(@@rowcount as nvarchar(20))


print N''
print N'Insert records - Names of user-defined (custom) user groups - end'
print N''
print N''
/************************************************************
* Insert records - Names of user-defined (custom) user groups - end
************************************************************/



--

/************************************************************
* Insert records - [tlbEmployee]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tlbEmployee] 

(

					[idfEmployee]

					, [idfsEmployeeType]

					, [idfsSite]

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

					, [idfsEmployeeCategory]
)
select 

					isnull(cug.idfEmployeeGroup_v7, tlbEmployee_v6.[idfEmployee])

					, j_trtBaseReference_idfsEmployeeType_v7.[idfsBaseReference]

					, j_tstSite_idfsSite_v7.[idfsSite]

					, case when sysadm_v6.[idfUserID] is not null then 1 else tlbEmployee_v6.[intRowStatus] end

					, tlbEmployee_v6.[rowguid]

					, tlbEmployee_v6.[strMaintenanceFlag]

					, tlbEmployee_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfEmployee":' + isnull(cast(isnull(cug.idfEmployeeGroup_v7, tlbEmployee_v6.[idfEmployee]) as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()

					, (10023002 - tlbEmployee_v6.[idfsEmployeeType] /*1 when Employee Group, otherwise 0*/) * 10526002 /*Non-User*/ + (tlbEmployee_v6.[idfsEmployeeType] - 10023001 /*1 when Person, otherwise 0*/) * 10526001 /*User*/
from [Falcon_Archive].[dbo].[tlbEmployee] tlbEmployee_v6
left join	[Giraffe_Archive].[dbo].[_dmccCustomUserGroup] cug
on			cug.idfEmployeeGroup_v6 = tlbEmployee_v6.idfEmployee
outer apply
(	select	top 1 ut_sysadm_v6.[idfUserID], ut_sysadm_v6.[idfPerson]
	from	[Falcon_Archive].[dbo].[tstUserTable] ut_sysadm_v6
	join	[Falcon_Archive].[dbo].[tlbPerson] p_sysadm_v6
	on		p_sysadm_v6.[idfPerson] = ut_sysadm_v6.[idfPerson]
			and p_sysadm_v6.[strFamilyName] like N'% Administrator' collate Cyrillic_General_CI_AS
	where	ut_sysadm_v6.[idfPerson] = tlbEmployee_v6.[idfEmployee]
			and ut_sysadm_v6.[strAccountName] like N'% Administrator' collate Cyrillic_General_CI_AS
) sysadm_v6 


					inner join	[Giraffe_Archive].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tlbEmployee_v6.[idfsSite] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsEmployeeType_v7

		on	


					j_trtBaseReference_idfsEmployeeType_v7.[idfsBaseReference] = tlbEmployee_v6.[idfsEmployeeType] 
left join	[Giraffe_Archive].[dbo].[tlbEmployee] tlbEmployee_v7 
on	

					tlbEmployee_v7.[idfEmployee] = isnull(cug.idfEmployeeGroup_v7, tlbEmployee_v6.[idfEmployee]) 
where tlbEmployee_v7.[idfEmployee] is null 
print N'Table [tlbEmployee] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbEmployeeGroup]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tlbEmployeeGroup] 

(

					[idfEmployeeGroup]

					, [idfsEmployeeGroupName]

					, [idfsSite]

					, [strName]

					, [strDescription]

					, [rowguid]

					, [intRowStatus]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_tlbEmployee_idfEmployeeGroup_v7.[idfEmployee]

					, j_trtBaseReference_idfsEmployeeGroupName_v7.[idfsBaseReference]

					, j_tstSite_idfsSite_v7.[idfsSite]

					, tlbEmployeeGroup_v6.[strName]

					, tlbEmployeeGroup_v6.[strDescription]

					, tlbEmployeeGroup_v6.[rowguid]

					, tlbEmployeeGroup_v6.[intRowStatus]

					, tlbEmployeeGroup_v6.[strMaintenanceFlag]

					, tlbEmployeeGroup_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfEmployeeGroup":' + isnull(cast(isnull(cug.idfEmployeeGroup_v7, tlbEmployeeGroup_v6.[idfEmployeeGroup]) as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v6
left join	[Giraffe_Archive].[dbo].[_dmccCustomUserGroup] cug
on			cug.idfEmployeeGroup_v6 = tlbEmployeeGroup_v6.idfEmployeeGroup 


					inner join	[Giraffe_Archive].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tlbEmployeeGroup_v6.[idfsSite] 

					inner join	[Giraffe_Archive].[dbo].[tlbEmployee] j_tlbEmployee_idfEmployeeGroup_v7

		on	


					j_tlbEmployee_idfEmployeeGroup_v7.[idfEmployee] = isnull(cug.idfsEmployeeGroupName_v7, tlbEmployeeGroup_v6.[idfsEmployeeGroupName]) 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsEmployeeGroupName_v7

		on	


					j_trtBaseReference_idfsEmployeeGroupName_v7.[idfsBaseReference] = isnull(cug.idfsEmployeeGroupName_v7, tlbEmployeeGroup_v6.[idfsEmployeeGroupName]) 
left join	[Giraffe_Archive].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v7 
on	

					tlbEmployeeGroup_v7.[idfEmployeeGroup] = isnull(cug.idfEmployeeGroup_v7, tlbEmployeeGroup_v6.[idfEmployeeGroup]) 
where tlbEmployeeGroup_v7.[idfEmployeeGroup] is null 
print N'Table [tlbEmployeeGroup] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbPerson]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tlbPerson] 

(

					[idfPerson]

					, [idfsStaffPosition]

					, [idfInstitution]

					, [idfDepartment]

					, [strFamilyName]

					, [strFirstName]

					, [strSecondName]

					, [strContactPhone]

					, [strBarcode]

					, [rowguid]

					, [intRowStatus]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [PersonalIDValue]

					, [PersonalIDTypeID]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_tlbEmployee_idfPerson_v7.[idfEmployee]

					, j_trtBaseReference_idfsStaffPosition_v7.[idfsBaseReference]

					, j_tlbOffice_idfInstitution_v7.[idfOffice]

					, j_tlbDepartment_idfDepartment_v7.[idfDepartment]

					, tlbPerson_v6.[strFamilyName]

					, tlbPerson_v6.[strFirstName]

					, tlbPerson_v6.[strSecondName]

					, tlbPerson_v6.[strContactPhone]

					, tlbPerson_v6.[strBarcode]

					, tlbPerson_v6.[rowguid]

					, case when sysadm_v6.[idfUserID] is not null then 1 else tlbPerson_v6.[intRowStatus] end

					, tlbPerson_v6.[strMaintenanceFlag]

					, tlbPerson_v6.[strReservedAttribute]

					, null /*TODO: Check the rule for the new field in EIDSSv7: PersonalIDValue*/

					, pIdType_v7.[idfsBaseReference] /*Rule for the new field in EIDSSv7: PersonalIDTypeID*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfPerson":' + isnull(cast(tlbPerson_v6.[idfPerson] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[tlbPerson] tlbPerson_v6
outer apply
(	select	top 1 ut_sysadm_v6.[idfUserID], ut_sysadm_v6.[idfPerson]
	from	[Falcon_Archive].[dbo].[tstUserTable] ut_sysadm_v6
	where	ut_sysadm_v6.[idfPerson] = tlbPerson_v6.[idfPerson]
			and tlbPerson_v6.[strFamilyName] like N'% Administrator' collate Cyrillic_General_CI_AS
			and ut_sysadm_v6.[strAccountName] like N'% Administrator' collate Cyrillic_General_CI_AS
) sysadm_v6
left join	[Giraffe_Archive].[dbo].[trtBaseReference] pIdType_v7
on			pIdType_v7.[idfsBaseReference] = 51577280000000 /*Unknown Personal ID Type*/
 


					inner join	[Giraffe_Archive].[dbo].[tlbEmployee] j_tlbEmployee_idfPerson_v7

		on	


					j_tlbEmployee_idfPerson_v7.[idfEmployee] = tlbPerson_v6.[idfPerson] 

					left join	[Giraffe_Archive].[dbo].[tlbDepartment] j_tlbDepartment_idfDepartment_v7

		on	


					j_tlbDepartment_idfDepartment_v7.[idfDepartment] = tlbPerson_v6.[idfDepartment] 

					left join	[Giraffe_Archive].[dbo].[tlbOffice] j_tlbOffice_idfInstitution_v7

		on	


					j_tlbOffice_idfInstitution_v7.[idfOffice] = tlbPerson_v6.[idfInstitution] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsStaffPosition_v7

		on	


					j_trtBaseReference_idfsStaffPosition_v7.[idfsBaseReference] = tlbPerson_v6.[idfsStaffPosition] 
left join	[Giraffe_Archive].[dbo].[tlbPerson] tlbPerson_v7 
on	

					tlbPerson_v7.[idfPerson] = tlbPerson_v6.[idfPerson] 
where tlbPerson_v7.[idfPerson] is null 
print N'Table [tlbPerson] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbEmployeeGroupMember]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tlbEmployeeGroupMember] 

(

					[idfEmployeeGroup]

					, [idfEmployee]

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
select 

					j_tlbEmployeeGroup_idfEmployeeGroup_v7.[idfEmployeeGroup]

					, j_tlbEmployee_idfEmployee_v7.[idfEmployee]

					, tlbEmployeeGroupMember_v6.[intRowStatus]

					, tlbEmployeeGroupMember_v6.[rowguid]

					, tlbEmployeeGroupMember_v6.[strMaintenanceFlag]

					, tlbEmployeeGroupMember_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfEmployeeGroup":' + isnull(cast(isnull(cug_Parent.idfEmployeeGroup_v7, tlbEmployeeGroupMember_v6.[idfEmployeeGroup]) as nvarchar(20)), N'null') + N',' + N'"idfEmployee":' + isnull(cast(isnull(cug_Child.idfEmployeeGroup_v7,  tlbEmployeeGroupMember_v6.[idfEmployee]) as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[tlbEmployeeGroupMember] tlbEmployeeGroupMember_v6
left join	[Giraffe_Archive].[dbo].[_dmccCustomUserGroup] cug_Parent
on			cug_Parent.idfEmployeeGroup_v6 = tlbEmployeeGroupMember_v6.idfEmployeeGroup
left join	[Giraffe_Archive].[dbo].[_dmccCustomUserGroup] cug_Child
on			cug_Child.idfEmployeeGroup_v6 = tlbEmployeeGroupMember_v6.idfEmployee 


					inner join	[Giraffe_Archive].[dbo].[tlbEmployeeGroup] j_tlbEmployeeGroup_idfEmployeeGroup_v7

		on	


					j_tlbEmployeeGroup_idfEmployeeGroup_v7.[idfEmployeeGroup] = isnull(cug_Parent.idfEmployeeGroup_v7, tlbEmployeeGroupMember_v6.[idfEmployeeGroup]) 

					inner join	[Giraffe_Archive].[dbo].[tlbEmployee] j_tlbEmployee_idfEmployee_v7

		on	


					j_tlbEmployee_idfEmployee_v7.[idfEmployee] = isnull(cug_Child.idfEmployeeGroup_v7,  tlbEmployeeGroupMember_v6.[idfEmployee]) 
left join	[Giraffe_Archive].[dbo].[tlbEmployeeGroupMember] tlbEmployeeGroupMember_v7 
on	

					tlbEmployeeGroupMember_v7.[idfEmployeeGroup] = isnull(cug_Parent.idfEmployeeGroup_v7, tlbEmployeeGroupMember_v6.[idfEmployeeGroup]) 

					and tlbEmployeeGroupMember_v7.[idfEmployee] = isnull(cug_Child.idfEmployeeGroup_v7,  tlbEmployeeGroupMember_v6.[idfEmployee]) 
where tlbEmployeeGroupMember_v7.[idfEmployeeGroup] is null 
print N'Table [tlbEmployeeGroupMember] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tstUserTable]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tstUserTable] 

(

					[idfUserID]

					, [idfPerson]

					, [idfsSite]

					, [datTryDate]

					, [datPasswordSet]

					, [strAccountName]

					, [binPassword]

					, [intTry]

					, [intRowStatus]

					, [rowguid]

					, [strMaintenanceFlag]

					, [blnDisabled]

					, [PreferredLanguageID]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [EmailAddress]

					, [EmailConfirmedFlag]

					, [PasswordHash]

					, [TwoFactorEnabledFlag]

					, [LockoutEnabledFlag]

					, [LockoutEndDTM]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tstUserTable_v6.[idfUserID]

					, j_tlbPerson_idfPerson_v7.[idfPerson]

					, j_tstSite_idfsSite_v7.[idfsSite]

					, null

					, GETUTCDATE()

					, tstUserTable_v6.[strAccountName]

					, HASHBYTES(N'SHA1', cast(@NewTempPassword as nvarchar(500)))

					, null

					, case when j_tlbPerson_idfPerson_v7.[strFamilyName] like N'% Administrator' collate Cyrillic_General_CI_AS and tstUserTable_v6.[strAccountName] like N'% Administrator' collate Cyrillic_General_CI_AS then 1 else tstUserTable_v6.[intRowStatus] end

					, tstUserTable_v6.[rowguid]

					, tstUserTable_v6.[strMaintenanceFlag]

					, case when j_tlbPerson_idfPerson_v7.[strFamilyName] like N'% Administrator' collate Cyrillic_General_CI_AS and tstUserTable_v6.[strAccountName] like N'% Administrator' collate Cyrillic_General_CI_AS then 1 else tstUserTable_v6.[blnDisabled] end

					, @idfsPreferredNationalLanguage /*Rule for the new field in EIDSSv7: PreferredLanguageID*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfUserID":' + isnull(cast(tstUserTable_v6.[idfUserID] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, null /*TODO: Check the rule for the new field in EIDSSv7: EmailAddress*/

					, null /*TODO: Check the rule for the new field in EIDSSv7: EmailConfirmedFlag*/

					, null /*TODO: Check the rule for the new field in EIDSSv7: PasswordHash*/

					, null /*TODO: Check the rule for the new field in EIDSSv7: TwoFactorEnabledFlag*/

					, null /*TODO: Check the rule for the new field in EIDSSv7: LockoutEnabledFlag*/

					, null /*TODO: Check the rule for the new field in EIDSSv7: LockoutEndDTM*/

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[tstUserTable] tstUserTable_v6 


					inner join	[Giraffe_Archive].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tstUserTable_v6.[idfsSite] 

					left join	[Giraffe_Archive].[dbo].[tlbPerson] j_tlbPerson_idfPerson_v7

		on	


					j_tlbPerson_idfPerson_v7.[idfPerson] = tstUserTable_v6.[idfPerson] 
left join	[Giraffe_Archive].[dbo].[tstUserTable] tstUserTable_v7 
on	

					tstUserTable_v7.[idfUserID] = tstUserTable_v6.[idfUserID] 
where tstUserTable_v7.[idfUserID] is null 
print N'Table [tstUserTable] - insert: ' + cast(@@rowcount as nvarchar(20))


--


--

print N''
print N'Insert records - Tables with administrative module data - part 2 - end'
print N''
print N''
/************************************************************
* Insert records - Tables with administrative module data - part 2 - end
************************************************************/


---------------

/************************************************************
* Insert records - New tables with user account information - start
************************************************************/
print N''
print N'Insert records - New tables with user account information - start'
print N''

declare @ArchiveCmd nvarchar(max) = N''

if DB_NAME() like N'%_Archive' collate Latin1_General_CI_AS
begin
	set @ArchiveCmd = N'
INSERT INTO [' + DB_NAME() + N'].[dbo].[AspNetUsers]
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

FROM	[' + left(DB_NAME(), len(DB_NAME()) - 8) + N'].[dbo].[AspNetUsers] AspNetUsers_v7_Actual
join	[' + DB_NAME() + N'].[dbo].[tstUserTable] tstUserTable_v7_Archive
on		tstUserTable_v7_Archive.[idfUserID] = AspNetUsers_v7_Actual.[idfUserID] 
WHERE	not exists
		(	select	1
			from	[' + DB_NAME() + N'].[dbo].[AspNetUsers] AspNetUsers_v7_Archive
			where	AspNetUsers_v7_Archive.[idfUserID] = AspNetUsers_v7_Actual.[idfUserID] 
		)
		and tstUserTable_v7_Archive.intRowStatus = 0
print N''Table [AspNetUsers] - Insert user accounts not marked as deleted by copying from actual database: '' + cast(@@rowcount as nvarchar(20))
	
	'
	exec sp_executesql @ArchiveCmd
end


------------------------

else begin
INSERT INTO [Giraffe_Archive].[dbo].[AspNetUsers]
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
		,replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(tstUserTable_v7.[strAccountName], N' ', N''), N'''', N''), N'(', N''), N')', N''), N'#', N'N'), N'№', N'N'), N'?', N''), N'*', N''), N'%', N''), N'@', N''), N'&', N''), N'$', N''), N'[', N''), N']', N''), N'^', N''), N'`', N''), N'~', N'') +
			N'@dummyemail.com' collate Cyrillic_General_CI_AS
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
		,case when tstUserTable_v7.[blnDisabled] = 1 then N'Disabled by Administartor' else N'' end
		,GETUTCDATE()
		,1
		,UPPER(tstUserTable_v7.[strAccountName])
		,null
		,UPPER(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(tstUserTable_v7.[strAccountName], N' ', N''), N'''', N''), N'(', N''), N')', N''), N'#', N'N'), N'№', N'N'), N'?', N''), N'*', N''), N'%', N''), N'@', N''), N'&', N''), N'$', N''), N'[', N''), N']', N''), N'^', N''), N'`', N''), N'~', N'') +
			N'@dummyemail.com' collate Cyrillic_General_CI_AS)
		,case when tstUserTable_v7.[blnDisabled] = 1 then GETUTCDATE() else null end

FROM	[Giraffe_Archive].[dbo].[tstUserTable] tstUserTable_v7
join	[Giraffe_Archive].[dbo].[tlbPerson] tlbPerson_v7
on		tlbPerson_v7.idfPerson = tstUserTable_v7.idfPerson
WHERE	not exists
		(	select	1
			from	[Giraffe_Archive].[dbo].[AspNetUsers] AspNetUsers_v7
			where	AspNetUsers_v7.[idfUserID] = tstUserTable_v7.[idfUserID]
		)
		and tstUserTable_v7.intRowStatus = 0
		-- Avoid users with same account name
		and not exists
			(	select	1
				from	[Giraffe_Archive].[dbo].[tstUserTable] tstUserTable_v7_other
				where	tstUserTable_v7_other.strAccountName = tstUserTable_v7.[strAccountName] collate Cyrillic_General_CI_AS
						and tstUserTable_v7_other.intRowStatus = 0
						and tstUserTable_v7_other.idfUserID < tstUserTable_v7.[idfUserID]
			)
print N'Table [AspNetUsers] - insert user accounts not marked as deleted: ' + cast(@@rowcount as nvarchar(20))
end
print N''


----------------------------------------


declare	@LastId bigint = 0
select	@LastId = max(EmployeeToInstitution_v7.EmployeeToInstitution)
from	[Giraffe_Archive].[dbo].[EmployeeToInstitution] EmployeeToInstitution_v7

if @LastID is null
	set @LastId = 0

INSERT INTO [Giraffe_Archive].[dbo].[EmployeeToInstitution]
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
		,N'[{' + N'"EmployeeToInstitution":' + isnull(cast((@LastId + id_increment.intIncrement) as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS
		,N'system'
		,GETUTCDATE()
		,N'system'
		,GETUTCDATE()
		,cast((1-cast(aspNetU_v7.[blnDisabled] as int)) as bit)

FROM	[Giraffe_Archive].[dbo].[tstUserTable] tstUserTable_v7
join	[Giraffe_Archive].[dbo].[tlbPerson] tlbPerson_v7
on		tlbPerson_v7.[idfPerson] = tstUserTable_v7.[idfPerson]
cross apply
(	select	top 1 AspNetUsers_v7.[Id] as [aspNetUserId], AspNetUsers_v7.[blnDisabled]
	from	[Giraffe_Archive].[dbo].[AspNetUsers] AspNetUsers_v7
	where	AspNetUsers_v7.[idfUserID] = tstUserTable_v7.[idfUserID]
) aspNetU_v7
outer apply
(	select	count(tstUserTable_v7_count.[idfUserID]) as intIncrement
	from	[Giraffe_Archive].[dbo].[tstUserTable] tstUserTable_v7_count
	join	[Giraffe_Archive].[dbo].[tlbPerson] tlbPerson_v7_count
	on		tlbPerson_v7_count.idfPerson = tstUserTable_v7_count.idfPerson
	where	tstUserTable_v7_count.intRowStatus = 0
			and tlbPerson_v7_count.[idfInstitution] is not null
			and not exists
				(	select	1
					from	[Giraffe_Archive].[dbo].[EmployeeToInstitution] EmployeeToInstitution_v7_count
					where	EmployeeToInstitution_v7_count.[idfUserId] = tstUserTable_v7_count.[idfUserID]
				)
			and exists
				(	select	1
					from	[Giraffe_Archive].[dbo].[AspNetUsers] AspNetUsers_v7_count
					where	AspNetUsers_v7_count.[idfUserID] = tstUserTable_v7_count.[idfUserID]
				)
			and tstUserTable_v7_count.[idfUserID] <= tstUserTable_v7.[idfUserID]
) id_increment
where	tstUserTable_v7.intRowStatus = 0
		and tlbPerson_v7.[idfInstitution] is not null
		and not exists
			(	select	1
				from	[Giraffe_Archive].[dbo].[EmployeeToInstitution] EmployeeToInstitution_v7
				where	EmployeeToInstitution_v7.[idfUserId] = tstUserTable_v7.[idfUserID]
			)
print N'Table [EmployeeToInstitution] - insert links from user accounts not marked as deleted to default organizations: ' + cast(@@rowcount as nvarchar(20))
print N''


-------------------------------------------

print N''
print N'Insert records - New tables with user account information - end'
print N''
print N''
/************************************************************
* Insert records - New tables with user account information - end
************************************************************/


--------------------------------------------------

/************************************************************
* Insert records - Tables with administrative module data - part 3 - start
************************************************************/
print N''
print N'Insert records - Tables with administrative module data - part 3 - start'
print N''

                               
-- -- --


--

/************************************************************
* Insert records - [tstObjectAccess]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tstObjectAccess] 

(

					[idfObjectAccess]

					, [idfsObjectOperation]

					, [idfsObjectType]

					, [idfsObjectID]

					, [idfActor]

					, [idfsOnSite]

					, [intPermission]

					, [intRowStatus]

					, [rowguid]

					, [strMaintenanceFlag]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]
)
select 

					tstObjectAccess_v6.[idfObjectAccess]

					, j_trtBaseReference_idfsObjectOperation_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsObjectType_v7.[idfsBaseReference]

					, tstObjectAccess_v6.[idfsObjectID]

					, j_tlbEmployee_idfActor_v7.[idfEmployee]

					, j_tstSite_idfsOnSite_v7.[idfsSite]

					, tstObjectAccess_v6.[intPermission]

					, tstObjectAccess_v6.[intRowStatus]

					, tstObjectAccess_v6.[rowguid]

					, tstObjectAccess_v6.[strMaintenanceFlag]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfObjectAccess":' + isnull(cast(tstObjectAccess_v6.[idfObjectAccess] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS
from [Falcon_Archive].[dbo].[tstObjectAccess] tstObjectAccess_v6
left join	[Giraffe_Archive].[dbo].[_dmccCustomUserGroup] cug
on			cug.idfEmployeeGroup_v6 = tstObjectAccess_v6.[idfActor]
left join	[Giraffe_Archive].[dbo].trtDiagnosis trtDiagnosis_v7_PermissionTo
on			trtDiagnosis_v7_PermissionTo.[idfsDiagnosis] = tstObjectAccess_v6.[idfsObjectID]
			and tstObjectAccess_v6.[idfsObjectType] = 10060001 /*Diagnosis*/
left join	[Giraffe_Archive].[dbo].tstSite tstSite_v7_PermissionTo
on			tstSite_v7_PermissionTo.[idfsSite] = tstObjectAccess_v6.[idfsObjectID]
			and tstObjectAccess_v6.[idfsObjectType] = 10060011 /*Site*/ 


					inner join	[Giraffe_Archive].[dbo].[tlbEmployee] j_tlbEmployee_idfActor_v7

		on	


					j_tlbEmployee_idfActor_v7.[idfEmployee] = isnull(cug.idfEmployeeGroup_v7, tstObjectAccess_v6.[idfActor]) 

					left join	[Giraffe_Archive].[dbo].[tstSite] j_tstSite_idfsOnSite_v7

		on	


					j_tstSite_idfsOnSite_v7.[idfsSite] = tstObjectAccess_v6.[idfsOnSite] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsObjectOperation_v7

		on	


					j_trtBaseReference_idfsObjectOperation_v7.[idfsBaseReference] = tstObjectAccess_v6.[idfsObjectOperation] 

					left join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsObjectType_v7

		on	


					j_trtBaseReference_idfsObjectType_v7.[idfsBaseReference] = tstObjectAccess_v6.[idfsObjectType] 
left join	[Giraffe_Archive].[dbo].[tstObjectAccess] tstObjectAccess_v7 
on	

					tstObjectAccess_v7.[idfObjectAccess] = tstObjectAccess_v6.[idfObjectAccess] 
where tstObjectAccess_v7.[idfObjectAccess] is null 
	and	(	trtDiagnosis_v7_PermissionTo.[idfsDiagnosis] is not null
			or	 tstSite_v7_PermissionTo.[idfsSite] is not null
		)

print N'Table [tstObjectAccess] - insert: ' + cast(@@rowcount as nvarchar(20))


--


-----------------------------

/************************************************************
* Create concordance table of system functions and operations - #dmccSystemFunctionOperation
************************************************************/

if object_id(N'tempdb..#dmccSystemFunctionOperation') is not null
exec sp_executesql N'drop table #dmccSystemFunctionOperation'

if object_id(N'tempdb..#dmccSystemFunctionOperation') is null
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



--

  (10094040, N'Access to Security Policy', 10059003, N'Read', 10094554, N'​Access to System Preferences List', 10059003, N'Read')
, (10094040, N'Access to Security Policy', 10059004, N'Write', 10094554, N'​Access to System Preferences List', 10059004, N'Write')
, (10094033, N'Access to Outbreaks', 10059001, N'Create', 10094550, N'​Access to Veterinary Outbreak Contacts Data', 10059001, N'Create')
, (10094028, N'Access to Veterinary Cases Data', 10059001, N'Create', 10094550, N'​Access to Veterinary Outbreak Contacts Data', 10059001, N'Create')
, (10094033, N'Access to Outbreaks', 10059002, N'Delete', 10094550, N'​Access to Veterinary Outbreak Contacts Data', 10059002, N'Delete')
, (10094028, N'Access to Veterinary Cases Data', 10059002, N'Delete', 10094550, N'​Access to Veterinary Outbreak Contacts Data', 10059002, N'Delete')
, (10094033, N'Access to Outbreaks', 10059003, N'Read', 10094550, N'​Access to Veterinary Outbreak Contacts Data', 10059003, N'Read')
, (10094028, N'Access to Veterinary Cases Data', 10059003, N'Read', 10094550, N'​Access to Veterinary Outbreak Contacts Data', 10059003, N'Read')
, (10094033, N'Access to Outbreaks', 10059004, N'Write', 10094550, N'​Access to Veterinary Outbreak Contacts Data', 10059004, N'Write')
, (10094028, N'Access to Veterinary Cases Data', 10059004, N'Write', 10094550, N'​Access to Veterinary Outbreak Contacts Data', 10059004, N'Write')
, (10094028, N'Access to Veterinary Cases Data', 10059002, N'Delete', 10094526, N'​Can Execute Avian Disease Report Deduplication Function', 10059005, N'Execute')
, (10094028, N'Access to Veterinary Cases Data', 10059002, N'Delete', 10094527, N'​Can Execute Livestock Disease Report Deduplication Function', 10059005, N'Execute')
, (10094031, N'Access to EIDSS Sites List (Managing Data reception from Other Sites)', 10059004, N'Write', 10094528, N'​Can Manage Access to Neighboring Sites', 10059005, N'Execute')
, (10094034, N'Access to Replicate Data Command', 10059005, N'Execute', 10094530, N'​Can Manage Column Display in Grids', 10059005, N'Execute')
, (10094014, N'Can Manage Reference Tables', 10059001, N'Create', 10094532, N'​Can Manage References and Configurations', 10059001, N'Create')
, (10094014, N'Can Manage Reference Tables', 10059002, N'Delete', 10094532, N'​Can Manage References and Configurations', 10059002, N'Delete')
, (10094014, N'Can Manage Reference Tables', 10059003, N'Read', 10094532, N'​Can Manage References and Configurations', 10059003, N'Read')
, (10094014, N'Can Manage Reference Tables', 10059004, N'Write', 10094532, N'​Can Manage References and Configurations', 10059004, N'Write')
, (10094031, N'Access to EIDSS Sites List (Managing Data reception from Other Sites)', 10059004, N'Write', 10094504, N'​Can Manage Site Configurable Filtration', 10059001, N'Create')
, (10094031, N'Access to EIDSS Sites List (Managing Data reception from Other Sites)', 10059004, N'Write', 10094504, N'​Can Manage Site Configurable Filtration', 10059002, N'Delete')
, (10094031, N'Access to EIDSS Sites List (Managing Data reception from Other Sites)', 10059003, N'Read', 10094504, N'​Can Manage Site Configurable Filtration', 10059003, N'Read')
, (10094031, N'Access to EIDSS Sites List (Managing Data reception from Other Sites)', 10059004, N'Write', 10094504, N'​Can Manage Site Configurable Filtration', 10059004, N'Write')
, (10094029, N'Access to Laboratory Samples', 10059004, N'Write', 10094538, N'​Can Modify Autopopulated Dates Within the Lab Module', 10059005, N'Execute')
, (10094055, N'Can Reopen Closed Case', 10059005, N'Execute', 10094565, N'​Can Reopen Closed Veterinary Disease Report/Session', 10059005, N'Execute')
, (10094028, N'Access to Veterinary Cases Data', 10059004, N'Write', 10094565, N'​Can Reopen Closed Veterinary Disease Report/Session', 10059005, N'Execute')
, (10094039, N'Access to Security Log', 10059003, N'Read', 10094503, N'Access to Administrative Standard Reports', 10059003, N'Read')
, (10094018, N'Access to Reports', 10059003, N'Read', 10094502, N'Access to Human Aberration Analysis Reports', 10059003, N'Read')
, (10094027, N'Access to Human Cases Data', 10059003, N'Read', 10094502, N'Access to Human Aberration Analysis Reports', 10059003, N'Read')
, (10094027, N'Access to Human Cases Data', 10059001, N'Create', 10094505, N'Access to Human Active Surveillance Campaign', 10059001, N'Create')
, (10094027, N'Access to Human Cases Data', 10059002, N'Delete', 10094505, N'Access to Human Active Surveillance Campaign', 10059002, N'Delete')
, (10094027, N'Access to Human Cases Data', 10059003, N'Read', 10094505, N'Access to Human Active Surveillance Campaign', 10059003, N'Read')
, (10094027, N'Access to Human Cases Data', 10059004, N'Write', 10094505, N'Access to Human Active Surveillance Campaign', 10059004, N'Write')
, (10094027, N'Access to Human Cases Data', 10059001, N'Create', 10094506, N'Access to Human Active Surveillance Session', 10059001, N'Create')
, (10094027, N'Access to Human Cases Data', 10059002, N'Delete', 10094506, N'Access to Human Active Surveillance Session', 10059002, N'Delete')
, (10094027, N'Access to Human Cases Data', 10059003, N'Read', 10094506, N'Access to Human Active Surveillance Session', 10059003, N'Read')
, (10094027, N'Access to Human Cases Data', 10059004, N'Write', 10094506, N'Access to Human Active Surveillance Session', 10059004, N'Write')
, (10094027, N'Access to Human Cases Data', 10059006, N'Access To Personal Data', 10094510, N'Access to Human Disease Report Data', 10059007, N'Access to gender and age data')
, (10094027, N'Access to Human Cases Data', 10059006, N'Access To Personal Data', 10094510, N'Access to Human Disease Report Data', 10059006, N'Access To Personal Data')
, (10094027, N'Access to Human Cases Data', 10059001, N'Create', 10094510, N'Access to Human Disease Report Data', 10059001, N'Create')
, (10094027, N'Access to Human Cases Data', 10059002, N'Delete', 10094510, N'Access to Human Disease Report Data', 10059002, N'Delete')
, (10094027, N'Access to Human Cases Data', 10059003, N'Read', 10094510, N'Access to Human Disease Report Data', 10059003, N'Read')
, (10094027, N'Access to Human Cases Data', 10059004, N'Write', 10094510, N'Access to Human Disease Report Data', 10059004, N'Write')
, (10094033, N'Access to Outbreaks', 10059001, N'Create', 10094549, N'Access to Human Outbreak Contacts data', 10059001, N'Create')
, (10094027, N'Access to Human Cases Data', 10059001, N'Create', 10094549, N'Access to Human Outbreak Contacts data', 10059001, N'Create')
, (10094033, N'Access to Outbreaks', 10059002, N'Delete', 10094549, N'Access to Human Outbreak Contacts data', 10059002, N'Delete')
, (10094027, N'Access to Human Cases Data', 10059002, N'Delete', 10094549, N'Access to Human Outbreak Contacts data', 10059002, N'Delete')
, (10094033, N'Access to Outbreaks', 10059003, N'Read', 10094549, N'Access to Human Outbreak Contacts data', 10059003, N'Read')
, (10094027, N'Access to Human Cases Data', 10059003, N'Read', 10094549, N'Access to Human Outbreak Contacts data', 10059003, N'Read')
, (10094033, N'Access to Outbreaks', 10059004, N'Write', 10094549, N'Access to Human Outbreak Contacts data', 10059004, N'Write')
, (10094027, N'Access to Human Cases Data', 10059004, N'Write', 10094549, N'Access to Human Outbreak Contacts data', 10059004, N'Write')
, (10094018, N'Access to Reports', 10059003, N'Read', 10094514, N'Access to Human Standard Reports', 10059003, N'Read')
, (10094027, N'Access to Human Cases Data', 10059003, N'Read', 10094514, N'Access to Human Standard Reports', 10059003, N'Read')
, (10094018, N'Access to Reports', 10059003, N'Read', 10094557, N'Access to ILI Aberration Analysis Reports', 10059003, N'Read')
, (10094051, N'Access to Basic Syndromic Surveillance Module', 10059001, N'Create', 10094557, N'Access to ILI Aberration Analysis Reports', 10059003, N'Read')
, (10094051, N'Access to Basic Syndromic Surveillance Module', 10059001, N'Create', 10094546, N'Access to ILI Aggregate Form Data', 10059001, N'Create')
, (10094051, N'Access to Basic Syndromic Surveillance Module', 10059002, N'Delete', 10094546, N'Access to ILI Aggregate Form Data', 10059002, N'Delete')
, (10094051, N'Access to Basic Syndromic Surveillance Module', 10059003, N'Read', 10094546, N'Access to ILI Aggregate Form Data', 10059003, N'Read')
, (10094051, N'Access to Basic Syndromic Surveillance Module', 10059004, N'Write', 10094546, N'Access to ILI Aggregate Form Data', 10059004, N'Write')
, (10094016, N'Access to Flexible Forms Designer', 10059003, N'Read', 10094561, N'Access to Interface Editor', 10059003, N'Read')
, (10094016, N'Access to Flexible Forms Designer', 10059004, N'Write', 10094561, N'Access to Interface Editor', 10059004, N'Write')
, (10094045, N'Can Amend a Test', 10059005, N'Execute', 10094559, N'Access to Laboratory Approvals', 10059003, N'Read')
, (10094045, N'Can Amend a Test', 10059005, N'Execute', 10094559, N'Access to Laboratory Approvals', 10059004, N'Write')
, (10094030, N'Access to Laboratory Tests', 10059001, N'Create', 10094560, N'Access to Laboratory Batch Records', 10059001, N'Create')
, (10094030, N'Access to Laboratory Tests', 10059002, N'Delete', 10094560, N'Access to Laboratory Batch Records', 10059002, N'Delete')
, (10094030, N'Access to Laboratory Tests', 10059003, N'Read', 10094560, N'Access to Laboratory Batch Records', 10059003, N'Read')
, (10094030, N'Access to Laboratory Tests', 10059004, N'Write', 10094560, N'Access to Laboratory Batch Records', 10059004, N'Write')
, (10094018, N'Access to Reports', 10059003, N'Read', 10094516, N'Access to Laboratory Standard Reports', 10059003, N'Read')
, (10094029, N'Access to Laboratory Samples', 10059003, N'Read', 10094516, N'Access to Laboratory Standard Reports', 10059003, N'Read')
, (10094030, N'Access to Laboratory Tests', 10059003, N'Read', 10094516, N'Access to Laboratory Standard Reports', 10059003, N'Read')
, (10094010, N'Can Perform Sample Transfer', 10059005, N'Execute', 10094558, N'Access to Laboratory Transferred Samples', 10059001, N'Create')
, (10094010, N'Can Perform Sample Transfer', 10059005, N'Execute', 10094558, N'Access to Laboratory Transferred Samples', 10059002, N'Delete')
, (10094010, N'Can Perform Sample Transfer', 10059005, N'Execute', 10094558, N'Access to Laboratory Transferred Samples', 10059003, N'Read')
, (10094010, N'Can Perform Sample Transfer', 10059005, N'Execute', 10094558, N'Access to Laboratory Transferred Samples', 10059004, N'Write')
, (10094031, N'Access to EIDSS Sites List (Managing Data reception from Other Sites)', 10059003, N'Read', 10094517, N'Access to Neighboring Site Data', 10059003, N'Read')
, (10094031, N'Access to EIDSS Sites List (Managing Data reception from Other Sites)', 10059004, N'Write', 10094517, N'Access to Neighboring Site Data', 10059004, N'Write')
, (10094033, N'Access to Outbreaks', 10059001, N'Create', 10094547, N'Access to Outbreak Human Case Data', 10059001, N'Create')
, (10094027, N'Access to Human Cases Data', 10059001, N'Create', 10094547, N'Access to Outbreak Human Case Data', 10059001, N'Create')
, (10094033, N'Access to Outbreaks', 10059002, N'Delete', 10094547, N'Access to Outbreak Human Case Data', 10059002, N'Delete')
, (10094027, N'Access to Human Cases Data', 10059002, N'Delete', 10094547, N'Access to Outbreak Human Case Data', 10059002, N'Delete')
, (10094033, N'Access to Outbreaks', 10059003, N'Read', 10094547, N'Access to Outbreak Human Case Data', 10059003, N'Read')
, (10094027, N'Access to Human Cases Data', 10059003, N'Read', 10094547, N'Access to Outbreak Human Case Data', 10059003, N'Read')
, (10094033, N'Access to Outbreaks', 10059004, N'Write', 10094547, N'Access to Outbreak Human Case Data', 10059004, N'Write')
, (10094027, N'Access to Human Cases Data', 10059004, N'Write', 10094547, N'Access to Outbreak Human Case Data', 10059004, N'Write')
, (10094033, N'Access to Outbreaks', 10059003, N'Read', 10094552, N'Access to Outbreak Session Analysis', 10059003, N'Read')
, (10094033, N'Access to Outbreaks', 10059004, N'Write', 10094552, N'Access to Outbreak Session Analysis', 10059004, N'Write')
, (10094033, N'Access to Outbreaks', 10059004, N'Write', 10094551, N'Access to Outbreak Session Updates', 10059001, N'Create')
, (10094033, N'Access to Outbreaks', 10059003, N'Read', 10094551, N'Access to Outbreak Session Updates', 10059003, N'Read')
, (10094033, N'Access to Outbreaks', 10059004, N'Write', 10094551, N'Access to Outbreak Session Updates', 10059004, N'Write')


--

, (10094033, N'Access to Outbreaks', 10059001, N'Create', 10094553, N'Access to Outbreak Vector Data', 10059001, N'Create')
, (10094044, N'Access to Vector Surveillance Session', 10059001, N'Create', 10094553, N'Access to Outbreak Vector Data', 10059001, N'Create')
, (10094033, N'Access to Outbreaks', 10059002, N'Delete', 10094553, N'Access to Outbreak Vector Data', 10059002, N'Delete')
, (10094044, N'Access to Vector Surveillance Session', 10059002, N'Delete', 10094553, N'Access to Outbreak Vector Data', 10059002, N'Delete')
, (10094033, N'Access to Outbreaks', 10059003, N'Read', 10094553, N'Access to Outbreak Vector Data', 10059003, N'Read')
, (10094044, N'Access to Vector Surveillance Session', 10059003, N'Read', 10094553, N'Access to Outbreak Vector Data', 10059003, N'Read')
, (10094033, N'Access to Outbreaks', 10059004, N'Write', 10094553, N'Access to Outbreak Vector Data', 10059004, N'Write')
, (10094044, N'Access to Vector Surveillance Session', 10059004, N'Write', 10094553, N'Access to Outbreak Vector Data', 10059004, N'Write')
, (10094033, N'Access to Outbreaks', 10059001, N'Create', 10094548, N'Access to Outbreak Veterinary Case Data', 10059001, N'Create')
, (10094028, N'Access to Veterinary Cases Data', 10059001, N'Create', 10094548, N'Access to Outbreak Veterinary Case Data', 10059001, N'Create')
, (10094033, N'Access to Outbreaks', 10059002, N'Delete', 10094548, N'Access to Outbreak Veterinary Case Data', 10059002, N'Delete')
, (10094028, N'Access to Veterinary Cases Data', 10059002, N'Delete', 10094548, N'Access to Outbreak Veterinary Case Data', 10059002, N'Delete')
, (10094033, N'Access to Outbreaks', 10059003, N'Read', 10094548, N'Access to Outbreak Veterinary Case Data', 10059003, N'Read')
, (10094028, N'Access to Veterinary Cases Data', 10059003, N'Read', 10094548, N'Access to Outbreak Veterinary Case Data', 10059003, N'Read')
, (10094033, N'Access to Outbreaks', 10059004, N'Write', 10094548, N'Access to Outbreak Veterinary Case Data', 10059004, N'Write')
, (10094028, N'Access to Veterinary Cases Data', 10059004, N'Write', 10094548, N'Access to Outbreak Veterinary Case Data', 10059004, N'Write')
, (10094018, N'Access to Reports', 10059003, N'Read', 10094562, N'Access to Paper Forms', 10059003, N'Read')
, (10094018, N'Access to Reports', 10059003, N'Read', 10094556, N'Access to Veterinary Aberration Analysis Reports', 10059003, N'Read')
, (10094028, N'Access to Veterinary Cases Data', 10059003, N'Read', 10094556, N'Access to Veterinary Aberration Analysis Reports', 10059003, N'Read')
, (10094018, N'Access to Reports', 10059003, N'Read', 10094519, N'Access to Veterinary Standard Reports', 10059003, N'Read')
, (10094028, N'Access to Veterinary Cases Data', 10059003, N'Read', 10094519, N'Access to Veterinary Standard Reports', 10059003, N'Read')
, (10094052, N'Access to Human Aggregate Cases', 10059001, N'Create', 10094555, N'Access to Weekly Reporting Form', 10059001, N'Create')
, (10094052, N'Access to Human Aggregate Cases', 10059002, N'Delete', 10094555, N'Access to Weekly Reporting Form', 10059002, N'Delete')
, (10094052, N'Access to Human Aggregate Cases', 10059003, N'Read', 10094555, N'Access to Weekly Reporting Form', 10059003, N'Read')
, (10094052, N'Access to Human Aggregate Cases', 10059004, N'Write', 10094555, N'Access to Weekly Reporting Form', 10059004, N'Write')
, (10094018, N'Access to Reports', 10059003, N'Read', 10094563, N'Access to Zoonotic Standard Reports', 10059003, N'Read')
, (10094027, N'Access to Human Cases Data', 10059003, N'Read', 10094563, N'Access to Zoonotic Standard Reports', 10059003, N'Read')
, (10094028, N'Access to Veterinary Cases Data', 10059003, N'Read', 10094563, N'Access to Zoonotic Standard Reports', 10059003, N'Read')
, (10094046, N'Can Add Test Results For a Case/Session', 10059005, N'Execute', 10094564, N'Can Add Test Results For a Veterinary Case/Session', 10059005, N'Execute')
, (10094028, N'Access to Veterinary Cases Data', 10059004, N'Write', 10094564, N'Can Add Test Results For a Veterinary Case/Session', 10059005, N'Execute')
, (10094010, N'Can Perform Sample Transfer', 10059005, N'Execute', 10094520, N'Can Edit Sample Transfer forms after Transfer is saved', 10059005, N'Execute')
, (10094056, N'Access to Farms Data', 10059002, N'Delete', 10094521, N'Can Execute Farm Record Deduplication Function', 10059005, N'Execute')
, (10094009, N'Access to Persons List', 10059002, N'Delete', 10094523, N'Can Execute Person Record Deduplication Function', 10059005, N'Execute')
, (10094043, N'Can Import/Export Data', 10059005, N'Execute', 10094544, N'Can Import/Export Data', 10059005, N'Execute')
, (10094005, N'Can Interpret Test Result', 10059005, N'Execute', 10094570, N'Can Interpret Veterinary Disease Test Result', 10059005, N'Execute')
, (10094028, N'Access to Veterinary Cases Data', 10059004, N'Write', 10094570, N'Can Interpret Veterinary Disease Test Result', 10059005, N'Execute')
, (10094031, N'Access to EIDSS Sites List (Managing Data reception from Other Sites)', 10059004, N'Write', 10094535, N'Can Manage EIDSS Sites', 10059001, N'Create')
, (10094031, N'Access to EIDSS Sites List (Managing Data reception from Other Sites)', 10059004, N'Write', 10094535, N'Can Manage EIDSS Sites', 10059002, N'Delete')
, (10094031, N'Access to EIDSS Sites List (Managing Data reception from Other Sites)', 10059003, N'Read', 10094535, N'Can Manage EIDSS Sites', 10059003, N'Read')
, (10094031, N'Access to EIDSS Sites List (Managing Data reception from Other Sites)', 10059004, N'Write', 10094535, N'Can Manage EIDSS Sites', 10059004, N'Write')
, (10094029, N'Access to Laboratory Samples', 10059004, N'Write', 10094537, N'Can Modify Accession Date after Save', 10059005, N'Execute')
, (10094003, N'Can Destroy Samples', 10059005, N'Execute', 10094540, N'Can modify status of rejected/deleted sample', 10059005, N'Execute')
, (10094055, N'Can Reopen Closed Case', 10059005, N'Execute', 10094568, N'Can Reopen Closed Outbreak Session', 10059005, N'Execute')
, (10094033, N'Access to Outbreaks', 10059004, N'Write', 10094568, N'Can Reopen Closed Outbreak Session', 10059005, N'Execute')
, (10094004, N'Can Validate Test Result Interpretation', 10059005, N'Execute', 10094566, N'Can Validate Veterinary Disease Test Result Interpretation', 10059005, N'Execute')
, (10094028, N'Access to Veterinary Cases Data', 10059004, N'Write', 10094566, N'Can Validate Veterinary Disease Test Result Interpretation', 10059005, N'Execute')
, (10094040, N'Access to Security Policy', 10059003, N'Read', 10094545, N'Data Archive Settings', 10059003, N'Read')
, (10094040, N'Access to Security Policy', 10059004, N'Write', 10094545, N'Data Archive Settings', 10059004, N'Write')
, (10094041, N'Access to Active Surveillance Campaign', 10059001, N'Create', 10094041, N'Access to Veterinary Active Surveillance Campaign', 10059001, N'Create')
, (10094041, N'Access to Active Surveillance Campaign', 10059002, N'Delete', 10094041, N'Access to Veterinary Active Surveillance Campaign', 10059002, N'Delete')
, (10094041, N'Access to Active Surveillance Campaign', 10059003, N'Read', 10094041, N'Access to Veterinary Active Surveillance Campaign', 10059003, N'Read')
, (10094041, N'Access to Active Surveillance Campaign', 10059004, N'Write', 10094041, N'Access to Veterinary Active Surveillance Campaign', 10059004, N'Write')
, (10094042, N'Access to Active Surveillance Session', 10059001, N'Create', 10094042, N'​Access to Veterinary Active Surveillance Session', 10059001, N'Create')
, (10094042, N'Access to Active Surveillance Session', 10059002, N'Delete', 10094042, N'​Access to Veterinary Active Surveillance Session', 10059002, N'Delete')
, (10094042, N'Access to Active Surveillance Session', 10059003, N'Read', 10094042, N'​Access to Veterinary Active Surveillance Session', 10059003, N'Read')
, (10094042, N'Access to Active Surveillance Session', 10059004, N'Write', 10094042, N'​Access to Veterinary Active Surveillance Session', 10059004, N'Write')
, (10094001, N'Access to Aggregate Settings', 10059003, N'Read', 10094001, N'Access to Aggregate Settings', 10059003, N'Read')
, (10094001, N'Access to Aggregate Settings', 10059004, N'Write', 10094001, N'Access to Aggregate Settings', 10059004, N'Write')
, (10094002, N'Access to Analysis, Visualization and Reporting Module (AVR)', 10059001, N'Create', 10094002, N'Access to AVR', 10059001, N'Create')
, (10094002, N'Access to Analysis, Visualization and Reporting Module (AVR)', 10059002, N'Delete', 10094002, N'Access to AVR', 10059002, N'Delete')
, (10094002, N'Access to Analysis, Visualization and Reporting Module (AVR)', 10059003, N'Read', 10094002, N'Access to AVR', 10059003, N'Read')
, (10094002, N'Access to Analysis, Visualization and Reporting Module (AVR)', 10059004, N'Write', 10094002, N'Access to AVR', 10059004, N'Write')
, (10094037, N'Access to AVR Administration', 10059005, N'Execute', 10094037, N'Access to AVR Administration', 10059005, N'Execute')
, (10094038, N'Access to Data Audit', 10059003, N'Read', 10094038, N'Access to Data Audit', 10059003, N'Read')
, (10094015, N'Access to Event Log', 10059003, N'Read', 10094015, N'Access to Event Log', 10059003, N'Read')
, (10094056, N'Access to Farms Data', 10059001, N'Create', 10094056, N'Access to Farms Data', 10059001, N'Create')
, (10094056, N'Access to Farms Data', 10059002, N'Delete', 10094056, N'Access to Farms Data', 10059002, N'Delete')
, (10094056, N'Access to Farms Data', 10059003, N'Read', 10094056, N'Access to Farms Data', 10059003, N'Read')
, (10094056, N'Access to Farms Data', 10059004, N'Write', 10094056, N'Access to Farms Data', 10059004, N'Write')
, (10094016, N'Access to Flexible Forms Designer', 10059001, N'Create', 10094016, N'Access to Flexible Forms Designer', 10059001, N'Create')
, (10094016, N'Access to Flexible Forms Designer', 10059002, N'Delete', 10094016, N'Access to Flexible Forms Designer', 10059002, N'Delete')
, (10094016, N'Access to Flexible Forms Designer', 10059003, N'Read', 10094016, N'Access to Flexible Forms Designer', 10059003, N'Read')
, (10094016, N'Access to Flexible Forms Designer', 10059004, N'Write', 10094016, N'Access to Flexible Forms Designer', 10059004, N'Write')
, (10094017, N'Access to GIS Module', 10059003, N'Read', 10094017, N'Access to GIS Module', 10059003, N'Read')
, (10094052, N'Access to Human Aggregate Cases', 10059001, N'Create', 10094052, N'Access to Human Aggregate Disease Report', 10059001, N'Create')
, (10094052, N'Access to Human Aggregate Cases', 10059002, N'Delete', 10094052, N'Access to Human Aggregate Disease Report', 10059002, N'Delete')
, (10094052, N'Access to Human Aggregate Cases', 10059003, N'Read', 10094052, N'Access to Human Aggregate Disease Report', 10059003, N'Read')
, (10094052, N'Access to Human Aggregate Cases', 10059004, N'Write', 10094052, N'Access to Human Aggregate Disease Report', 10059004, N'Write')
, (10094029, N'Access to Laboratory Samples', 10059001, N'Create', 10094029, N'Access to Laboratory Samples', 10059001, N'Create')
, (10094029, N'Access to Laboratory Samples', 10059002, N'Delete', 10094029, N'Access to Laboratory Samples', 10059002, N'Delete')
, (10094029, N'Access to Laboratory Samples', 10059003, N'Read', 10094029, N'Access to Laboratory Samples', 10059003, N'Read')
, (10094029, N'Access to Laboratory Samples', 10059004, N'Write', 10094029, N'Access to Laboratory Samples', 10059004, N'Write')
, (10094030, N'Access to Laboratory Tests', 10059001, N'Create', 10094030, N'Access to Laboratory Tests', 10059001, N'Create')
, (10094030, N'Access to Laboratory Tests', 10059002, N'Delete', 10094030, N'Access to Laboratory Tests', 10059002, N'Delete')
, (10094030, N'Access to Laboratory Tests', 10059003, N'Read', 10094030, N'Access to Laboratory Tests', 10059003, N'Read')
, (10094030, N'Access to Laboratory Tests', 10059004, N'Write', 10094030, N'Access to Laboratory Tests', 10059004, N'Write')
, (10094033, N'Access to Outbreaks', 10059001, N'Create', 10094033, N'Access to Outbreak Sessions', 10059001, N'Create')
, (10094033, N'Access to Outbreaks', 10059002, N'Delete', 10094033, N'Access to Outbreak Sessions', 10059002, N'Delete')
, (10094033, N'Access to Outbreaks', 10059003, N'Read', 10094033, N'Access to Outbreak Sessions', 10059003, N'Read')
, (10094033, N'Access to Outbreaks', 10059004, N'Write', 10094033, N'Access to Outbreak Sessions', 10059004, N'Write')
, (10094009, N'Access to Persons List', 10059001, N'Create', 10094009, N'Access to Persons List', 10059001, N'Create')
, (10094009, N'Access to Persons List', 10059002, N'Delete', 10094009, N'Access to Persons List', 10059002, N'Delete')
, (10094009, N'Access to Persons List', 10059003, N'Read', 10094009, N'Access to Persons List', 10059003, N'Read')
, (10094009, N'Access to Persons List', 10059004, N'Write', 10094009, N'Access to Persons List', 10059004, N'Write')
, (10094039, N'Access to Security Log', 10059003, N'Read', 10094039, N'Access to Security Log', 10059003, N'Read')
, (10094040, N'Access to Security Policy', 10059003, N'Read', 10094040, N'Access to Security Policy', 10059003, N'Read')
, (10094040, N'Access to Security Policy', 10059004, N'Write', 10094040, N'Access to Security Policy', 10059004, N'Write')


--

, (10094011, N'Access to Statistics List', 10059001, N'Create', 10094011, N'Access to Statistics List', 10059001, N'Create')
, (10094011, N'Access to Statistics List', 10059002, N'Delete', 10094011, N'Access to Statistics List', 10059002, N'Delete')
, (10094011, N'Access to Statistics List', 10059003, N'Read', 10094011, N'Access to Statistics List', 10059003, N'Read')
, (10094011, N'Access to Statistics List', 10059004, N'Write', 10094011, N'Access to Statistics List', 10059004, N'Write')
, (10094012, N'Access to System Functions List', 10059003, N'Read', 10094012, N'Access to System Functions List', 10059003, N'Read')
, (10094012, N'Access to System Functions List', 10059004, N'Write', 10094012, N'Access to System Functions List', 10059004, N'Write')
, (10094044, N'Access to Vector Surveillance Session', 10059001, N'Create', 10094044, N'Access to Vector Surveillance Session', 10059001, N'Create')
, (10094044, N'Access to Vector Surveillance Session', 10059002, N'Delete', 10094044, N'Access to Vector Surveillance Session', 10059002, N'Delete')
, (10094044, N'Access to Vector Surveillance Session', 10059003, N'Read', 10094044, N'Access to Vector Surveillance Session', 10059003, N'Read')
, (10094044, N'Access to Vector Surveillance Session', 10059004, N'Write', 10094044, N'Access to Vector Surveillance Session', 10059004, N'Write')
, (10094054, N'Access to Veterinary Aggregate Actions', 10059001, N'Create', 10094054, N'Access to Veterinary Aggregate Actions', 10059001, N'Create')
, (10094054, N'Access to Veterinary Aggregate Actions', 10059002, N'Delete', 10094054, N'Access to Veterinary Aggregate Actions', 10059002, N'Delete')
, (10094054, N'Access to Veterinary Aggregate Actions', 10059003, N'Read', 10094054, N'Access to Veterinary Aggregate Actions', 10059003, N'Read')
, (10094054, N'Access to Veterinary Aggregate Actions', 10059004, N'Write', 10094054, N'Access to Veterinary Aggregate Actions', 10059004, N'Write')
, (10094053, N'Access to Veterinary Aggregate Cases', 10059001, N'Create', 10094053, N'Access to Veterinary Aggregate Diseases', 10059001, N'Create')
, (10094053, N'Access to Veterinary Aggregate Cases', 10059002, N'Delete', 10094053, N'Access to Veterinary Aggregate Diseases', 10059002, N'Delete')
, (10094053, N'Access to Veterinary Aggregate Cases', 10059003, N'Read', 10094053, N'Access to Veterinary Aggregate Diseases', 10059003, N'Read')
, (10094053, N'Access to Veterinary Aggregate Cases', 10059004, N'Write', 10094053, N'Access to Veterinary Aggregate Diseases', 10059004, N'Write')
, (10094028, N'Access to Veterinary Cases Data', 10059006, N'Access To Personal Data', 10094028, N'​Access to Veterinary Disease Reports Data', 10059006, N'Access To Personal Data')
, (10094028, N'Access to Veterinary Cases Data', 10059001, N'Create', 10094028, N'​Access to Veterinary Disease Reports Data', 10059001, N'Create')
, (10094028, N'Access to Veterinary Cases Data', 10059002, N'Delete', 10094028, N'​Access to Veterinary Disease Reports Data', 10059002, N'Delete')
, (10094028, N'Access to Veterinary Cases Data', 10059003, N'Read', 10094028, N'​Access to Veterinary Disease Reports Data', 10059003, N'Read')
, (10094028, N'Access to Veterinary Cases Data', 10059004, N'Write', 10094028, N'​Access to Veterinary Disease Reports Data', 10059004, N'Write')
, (10094023, N'Can Access Employees List (Without Managing Access Rights)', 10059001, N'Create', 10094023, N'Access to Employees List (Without Managing Access Rights)', 10059001, N'Create')
, (10094023, N'Can Access Employees List (Without Managing Access Rights)', 10059002, N'Delete', 10094023, N'Access to Employees List (Without Managing Access Rights)', 10059002, N'Delete')
, (10094023, N'Can Access Employees List (Without Managing Access Rights)', 10059003, N'Read', 10094023, N'Access to Employees List (Without Managing Access Rights)', 10059003, N'Read')
, (10094023, N'Can Access Employees List (Without Managing Access Rights)', 10059004, N'Write', 10094023, N'Access to Employees List (Without Managing Access Rights)', 10059004, N'Write')
, (10094021, N'Can Access Object Numbering Schema', 10059003, N'Read', 10094021, N'Access to Unique Numbering Schema', 10059003, N'Read')
, (10094021, N'Can Access Object Numbering Schema', 10059004, N'Write', 10094021, N'Access to Unique Numbering Schema', 10059004, N'Write')
, (10094022, N'Can Access Organizations List', 10059001, N'Create', 10094022, N'Access to Organizations List', 10059001, N'Create')
, (10094022, N'Can Access Organizations List', 10059002, N'Delete', 10094022, N'Access to Organizations List', 10059002, N'Delete')
, (10094022, N'Can Access Organizations List', 10059003, N'Read', 10094022, N'Access to Organizations List', 10059003, N'Read')
, (10094022, N'Can Access Organizations List', 10059004, N'Write', 10094022, N'Access to Organizations List', 10059004, N'Write')
, (10094046, N'Can Add Test Results For a Case/Session', 10059005, N'Execute', 10094046, N'Can Add Test Results For a Human Case/Session', 10059005, N'Execute')
, (10094027, N'Access to Human Cases Data', 10059004, N'Write', 10094046, N'Can Add Test Results For a Human Case/Session', 10059005, N'Execute')
, (10094045, N'Can Amend a Test', 10059005, N'Execute', 10094045, N'Can Amend a Test', 10059005, N'Execute')
, (10094003, N'Can Destroy Samples', 10059005, N'Execute', 10094003, N'Can Destroy Samples/Tests', 10059005, N'Execute')
, (10094007, N'Can Execute Human Case Deduplication Function', 10059005, N'Execute', 10094007, N'​Can Execute Human Disease Report Deduplication Function', 10059005, N'Execute')
, (10094057, N'Can Finalize Laboratory Test', 10059005, N'Execute', 10094057, N'Can Finalize Laboratory Test', 10059005, N'Execute')
, (10094005, N'Can Interpret Test Result', 10059005, N'Execute', 10094005, N'Can Interpret Human Disease Test Result', 10059005, N'Execute')
, (10094027, N'Access to Human Cases Data', 10059004, N'Write', 10094005, N'Can Interpret Human Disease Test Result', 10059005, N'Execute')
, (10094050, N'Can Manage GIS Reference Tables', 10059001, N'Create', 10094050, N'Can Manage GIS Reference Tables', 10059001, N'Create')
, (10094050, N'Can Manage GIS Reference Tables', 10059002, N'Delete', 10094050, N'Can Manage GIS Reference Tables', 10059002, N'Delete')
, (10094050, N'Can Manage GIS Reference Tables', 10059003, N'Read', 10094050, N'Can Manage GIS Reference Tables', 10059003, N'Read')
, (10094050, N'Can Manage GIS Reference Tables', 10059004, N'Write', 10094050, N'Can Manage GIS Reference Tables', 10059004, N'Write')
, (10094024, N'Can Manage Repository Schema', 10059001, N'Create', 10094024, N'Can Manage Repository Schema', 10059001, N'Create')
, (10094024, N'Can Manage Repository Schema', 10059002, N'Delete', 10094024, N'Can Manage Repository Schema', 10059002, N'Delete')
, (10094024, N'Can Manage Repository Schema', 10059003, N'Read', 10094024, N'Can Manage Repository Schema', 10059003, N'Read')
, (10094024, N'Can Manage Repository Schema', 10059004, N'Write', 10094024, N'Can Manage Repository Schema', 10059004, N'Write')
, (10094032, N'Can Manage Site Alerts Subscriptions', 10059003, N'Read', 10094032, N'Can Manage Site Alerts Subscriptions', 10059003, N'Read')
, (10094032, N'Can Manage Site Alerts Subscriptions', 10059004, N'Write', 10094032, N'Can Manage Site Alerts Subscriptions', 10059004, N'Write')
, (10094013, N'Can Manage User Accounts', 10059001, N'Create', 10094013, N'Can Manage User Accounts', 10059001, N'Create')
, (10094013, N'Can Manage User Accounts', 10059002, N'Delete', 10094013, N'Can Manage User Accounts', 10059002, N'Delete')
, (10094013, N'Can Manage User Accounts', 10059003, N'Read', 10094013, N'Can Manage User Accounts', 10059003, N'Read')
, (10094013, N'Can Manage User Accounts', 10059004, N'Write', 10094013, N'Can Manage User Accounts', 10059004, N'Write')
, (10094026, N'Can Manage User Groups', 10059001, N'Create', 10094026, N'Can Manage User Groups', 10059001, N'Create')
, (10094026, N'Can Manage User Groups', 10059002, N'Delete', 10094026, N'Can Manage User Groups', 10059002, N'Delete')
, (10094026, N'Can Manage User Groups', 10059003, N'Read', 10094026, N'Can Manage User Groups', 10059003, N'Read')
, (10094026, N'Can Manage User Groups', 10059004, N'Write', 10094026, N'Can Manage User Groups', 10059004, N'Write')
, (10094035, N'Can Perform Sample Accession In', 10059005, N'Execute', 10094035, N'Can Perform Sample Accession In', 10059005, N'Execute')
, (10094020, N'Can Print Barcodes', 10059005, N'Execute', 10094020, N'Can Print Barcodes', 10059005, N'Execute')
, (10094047, N'Can Read Archived Data', 10059005, N'Execute', 10094047, N'Can Read Archived Data', 10059005, N'Execute')
, (10094055, N'Can Reopen Closed Case', 10059005, N'Execute', 10094055, N'Can Reopen Closed Human Disease Report/Session', 10059005, N'Execute')
, (10094027, N'Access to Human Cases Data', 10059004, N'Write', 10094055, N'Can Reopen Closed Human Disease Report/Session', 10059005, N'Execute')
, (10094048, N'Can Restore Deleted Records', 10059005, N'Execute', 10094048, N'Can Restore Deleted Records', 10059005, N'Execute')
, (10094049, N'Can Sign Report', 10059005, N'Execute', 10094049, N'Can Sign Report', 10059005, N'Execute')
, (10094004, N'Can Validate Test Result Interpretation', 10059005, N'Execute', 10094004, N'Can Validate Human Disease Test Result Interpretation', 10059005, N'Execute')
, (10094027, N'Access to Human Cases Data', 10059004, N'Write', 10094004, N'Can Validate Human Disease Test Result Interpretation', 10059005, N'Execute')
, (10094025, N'Can Work With Access Rights Management', 10059003, N'Read', 10094025, N'Can Work With Access Rights Management', 10059003, N'Read')
, (10094025, N'Can Work With Access Rights Management', 10059004, N'Write', 10094025, N'Can Work With Access Rights Management', 10059004, N'Write')


--


declare @now datetime
set @now = getutcdate()

/************************************************************
* Insert records - [LkupRoleMenuAccess]
************************************************************/
insert into [Giraffe_Archive].[dbo].[LkupRoleMenuAccess] 

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
					, N'system'
					, @now
					, N'system'
					, @now
					, 10519002 /*Record Source: EIDSS6.1*/
					, N'[{' + N'"idfEmployee":' + isnull(cast(tlbEmployee_v7.[idfEmployee] as nvarchar(20)), N'null') + N',' + N'"EIDSSMenuID":' + isnull(cast(LkupEIDSSMenu_v7.[EIDSSMenuID] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS
from	[Giraffe_Archive].[dbo].[LkupEIDSSMenu] LkupEIDSSMenu_v7
inner join	[Giraffe_Archive].[dbo].[LkupEIDSSMenuToSystemFunction] LkupEIDSSMenuToSystemFunction_v7
on			LkupEIDSSMenuToSystemFunction_v7.[EIDSSMenuID] = LkupEIDSSMenu_v7.[EIDSSMenuID]
			and LkupEIDSSMenuToSystemFunction_v7.intRowStatus = 0
inner join	[Giraffe_Archive].[dbo].[LkupSystemFunctionToOperation] LkupSystemFunctionToOperation_v7
on			LkupSystemFunctionToOperation_v7.[SystemFunctionID] = LkupEIDSSMenuToSystemFunction_v7.[SystemFunctionID]
			and LkupSystemFunctionToOperation_v7.intRowStatus = 0
			and LkupSystemFunctionToOperation_v7.[SystemFunctionOperationID] in (10059003	/*Read*/, 10059005	/*Execute*/)--Enough to access menu
inner join	#dmccSystemFunctionOperation ccsfo
on			ccsfo.idfsSF_v7 = LkupEIDSSMenuToSystemFunction_v7.[SystemFunctionID]
			and ccsfo.idfsOperation_v7 = LkupSystemFunctionToOperation_v7.[SystemFunctionOperationID]

inner join	[Giraffe_Archive].[dbo].[tlbEmployee] tlbEmployee_v7
	left join	[Giraffe_Archive].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v7
		inner join	[Giraffe_Archive].[dbo].[_dmccCustomUserGroup] cug
		on			cug.idfEmployeeGroup_v7 = tlbEmployeeGroup_v7.idfEmployeeGroup
		inner join	[Falcon_Archive].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v6
		on			tlbEmployeeGroup_v6.idfEmployeeGroup = cug.idfEmployeeGroup_v6
	on			tlbEmployeeGroup_v7.idfEmployeeGroup = tlbEmployee_v7.idfEmployee
	left join	[Giraffe_Archive].[dbo].[tstUserTable] tstUserTable_v7
	on			tstUserTable_v7.idfPerson = tlbEmployee_v7.idfEmployee
on			tlbEmployee_v7.intRowStatus = 0

left join	[Giraffe_Archive].[dbo].[LkupRoleMenuAccess] LkupRoleMenuAccess_v7 
on			LkupRoleMenuAccess_v7.[idfEmployee] = tlbEmployee_v7.[idfEmployee] 
			and LkupRoleMenuAccess_v7.[EIDSSMenuID] = LkupEIDSSMenu_v7.[EIDSSMenuID]

where		(	tlbEmployeeGroup_v6.idfEmployeeGroup is not null
				or tstUserTable_v7.idfUserID is not null
			)
			and exists
				(	select	1
					from	[Falcon_Archive].[dbo].[tstObjectAccess] tstObjectAccess_v6
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
					left join	[Falcon_Archive].[dbo].[tstObjectAccess] tstObjectAccess_v6
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
print N'Table [LkupRoleMenuAccess] - insert: ' + cast(@@rowcount as nvarchar(20))



----------------------

/************************************************************
* Insert records - [LkupRoleSystemFunctionAccess]
************************************************************/
insert into [Giraffe_Archive].[dbo].[LkupRoleSystemFunctionAccess] 

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
					, N'system'
					, @now
					, N'system'
					, @now
					, 10519002 /*Record Source: EIDSS6.1*/
					, N'[{' + N'"idfEmployee":' + isnull(cast(tlbEmployee_v7.[idfEmployee] as nvarchar(20)), N'null') + N',' + 
						N'"SystemFunctionID":' + isnull(cast(trtBaseReference_v7.[idfsBaseReference] as nvarchar(20)), N'null') + N',' + 
						N'"SystemFunctionOperationID":' + isnull(cast(LkupSystemFunctionToOperation_v7.[SystemFunctionOperationID] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS
					, 0

from	[Giraffe_Archive].[dbo].[trtBaseReference] trtBaseReference_v7
inner join	[Giraffe_Archive].[dbo].[LkupSystemFunctionToOperation] LkupSystemFunctionToOperation_v7
on			LkupSystemFunctionToOperation_v7.[SystemFunctionID] = trtBaseReference_v7.[idfsBaseReference]
			and LkupSystemFunctionToOperation_v7.intRowStatus = 0
inner join	#dmccSystemFunctionOperation ccsfo
on			ccsfo.idfsSF_v7 = LkupSystemFunctionToOperation_v7.[SystemFunctionID]
			and ccsfo.idfsOperation_v7 = LkupSystemFunctionToOperation_v7.[SystemFunctionOperationID]

inner join	[Giraffe_Archive].[dbo].[tlbEmployee] tlbEmployee_v7
	left join	[Giraffe_Archive].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v7
		inner join	[Giraffe_Archive].[dbo].[_dmccCustomUserGroup] cug
		on			cug.idfEmployeeGroup_v7 = tlbEmployeeGroup_v7.idfEmployeeGroup
		inner join	[Falcon_Archive].[dbo].[tlbEmployeeGroup] tlbEmployeeGroup_v6
		on			tlbEmployeeGroup_v6.idfEmployeeGroup = cug.idfEmployeeGroup_v6
	on			tlbEmployeeGroup_v7.idfEmployeeGroup = tlbEmployee_v7.idfEmployee
	left join	[Giraffe_Archive].[dbo].[tstUserTable] tstUserTable_v7
	on			tstUserTable_v7.idfPerson = tlbEmployee_v7.idfEmployee
on			tlbEmployee_v7.intRowStatus = 0


left join	[Giraffe_Archive].[dbo].[LkupRoleSystemFunctionAccess] LkupRoleSystemFunctionAccess_v7 
on			LkupRoleSystemFunctionAccess_v7.[idfEmployee] = tlbEmployee_v7.[idfEmployee] 
			and LkupRoleSystemFunctionAccess_v7.[SystemFunctionID] = trtBaseReference_v7.[idfsBaseReference]
			and LkupRoleSystemFunctionAccess_v7.[SystemFunctionOperationID] = LkupSystemFunctionToOperation_v7.[SystemFunctionOperationID]



-------------------------

where		trtBaseReference_v7.[idfsReferenceType] = 19000094 /*System Function*/
			and trtBaseReference_v7.intRowStatus = 0
			and (	tlbEmployeeGroup_v6.idfEmployeeGroup is not null
					or tstUserTable_v7.idfUserID is not null
				)
			and exists
				(	select	1
					from	[Falcon_Archive].[dbo].[tstObjectAccess] tstObjectAccess_v6
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
					left join	[Falcon_Archive].[dbo].[tstObjectAccess] tstObjectAccess_v6
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
print N'Table [LkupRoleSystemFunctionAccess] - insert: ' + cast(@@rowcount as nvarchar(20))



----

print N''
print N'Insert records - Tables with administrative module data - part 3 - end'
print N''
print N''
/************************************************************
* Insert records - Tables with administrative module data - part 3 - end
************************************************************/



--------------------------------------------------

/************************************************************
* Insert records - Tables with administrative module data - part 4 - start
************************************************************/
print N''
print N'Insert records - Tables with administrative module data - part 4 - start'
print N''

                               
-- -- --


--

/************************************************************
* Insert records - [tstRayonToReportSite]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tstRayonToReportSite] 

(

					[idfRayonToReportSite]

					, [idfsRayon]

					, [idfsSite]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tstRayonToReportSite_v6.[idfRayonToReportSite]

					, j_gisRayon_idfsRayon_v7.[idfsRayon]

					, j_tstSite_idfsSite_v7.[idfsSite]

					, tstRayonToReportSite_v6.[rowguid]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfRayonToReportSite":' + isnull(cast(tstRayonToReportSite_v6.[idfRayonToReportSite] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[tstRayonToReportSite] tstRayonToReportSite_v6 


					inner join	[Giraffe_Archive].[dbo].[gisRayon] j_gisRayon_idfsRayon_v7

		on	


					j_gisRayon_idfsRayon_v7.[idfsRayon] = tstRayonToReportSite_v6.[idfsRayon] 

					inner join	[Giraffe_Archive].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tstRayonToReportSite_v6.[idfsSite] 
left join	[Giraffe_Archive].[dbo].[tstRayonToReportSite] tstRayonToReportSite_v7 
on	

					tstRayonToReportSite_v7.[idfRayonToReportSite] = tstRayonToReportSite_v6.[idfRayonToReportSite] 
where tstRayonToReportSite_v7.[idfRayonToReportSite] is null 
print N'Table [tstRayonToReportSite] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tstAggrSetting]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tstAggrSetting] 

(

					[idfsAggrCaseType]

					, [idfCustomizationPackage]

					, [idfsStatisticAreaType]

					, [idfsStatisticPeriodType]

					, [strValue]

					, [intRowStatus]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]

					, [idfsSite]
)
select 

					j_trtBaseReference_idfsAggrCaseType_v7.[idfsBaseReference]

					, j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage]

					, j_trtBaseReference_idfsStatisticAreaType_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsStatisticPeriodType_v7.[idfsBaseReference]

					, tstAggrSetting_v6.[strValue]

					, tstAggrSetting_v6.[intRowStatus]

					, tstAggrSetting_v6.[rowguid]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsAggrCaseType":' + isnull(cast(tstAggrSetting_v6.[idfsAggrCaseType] as nvarchar(20)), N'null') + N',' + N'"idfCustomizationPackage":' + isnull(cast(tstAggrSetting_v6.[idfCustomizationPackage] as nvarchar(20)), N'null') + N',' + N'"idfsSite":' + isnull(cast(@CDRSite as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()

					, @CDRSite /*Rule for the new field in EIDSSv7: idfsSite*/
from [Falcon_Archive].[dbo].[tstAggrSetting] tstAggrSetting_v6 


					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsAggrCaseType_v7

		on	


					j_trtBaseReference_idfsAggrCaseType_v7.[idfsBaseReference] = tstAggrSetting_v6.[idfsAggrCaseType] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsStatisticAreaType_v7

		on	


					j_trtBaseReference_idfsStatisticAreaType_v7.[idfsBaseReference] = tstAggrSetting_v6.[idfsStatisticAreaType] 

					inner join	[Giraffe_Archive].[dbo].[trtBaseReference] j_trtBaseReference_idfsStatisticPeriodType_v7

		on	


					j_trtBaseReference_idfsStatisticPeriodType_v7.[idfsBaseReference] = tstAggrSetting_v6.[idfsStatisticPeriodType] 

					inner join	[Giraffe_Archive].[dbo].[tstCustomizationPackage] j_tstCustomizationPackage_idfCustomizationPackage_v7

		on	


					j_tstCustomizationPackage_idfCustomizationPackage_v7.[idfCustomizationPackage] = tstAggrSetting_v6.[idfCustomizationPackage] 
left join	[Giraffe_Archive].[dbo].[tstAggrSetting] tstAggrSetting_v7 
on	

					tstAggrSetting_v7.[idfsAggrCaseType] = tstAggrSetting_v6.[idfsAggrCaseType] 

					and tstAggrSetting_v7.[idfCustomizationPackage] = tstAggrSetting_v6.[idfCustomizationPackage] 

					and tstAggrSetting_v7.[idfsSite] = @CDRSite 
where tstAggrSetting_v7.[idfsAggrCaseType] is null 
print N'Table [tstAggrSetting] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tstGlobalSiteOptions]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tstGlobalSiteOptions] 

(

					[strName]

					, [strValue]

					, [idfsSite]

					, [rowguid]

					, [intRowStatus]

					, [strMaintenanceFlag]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tstGlobalSiteOptions_v6.[strName]

					, tstGlobalSiteOptions_v6.[strValue]

					, j_tstSite_idfsSite_v7.[idfsSite]

					, tstGlobalSiteOptions_v6.[rowguid]

					, tstGlobalSiteOptions_v6.[intRowStatus]

					, tstGlobalSiteOptions_v6.[strMaintenanceFlag]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"strName":' + isnull(N'"' + tstGlobalSiteOptions_v6.[strName] + N'"' collate Cyrillic_General_CI_AS, N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[tstGlobalSiteOptions] tstGlobalSiteOptions_v6 


					left join	[Giraffe_Archive].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tstGlobalSiteOptions_v6.[idfsSite] 
left join	[Giraffe_Archive].[dbo].[tstGlobalSiteOptions] tstGlobalSiteOptions_v7 
on	

					tstGlobalSiteOptions_v7.[strName] = tstGlobalSiteOptions_v6.[strName]  collate Cyrillic_General_CI_AS
where tstGlobalSiteOptions_v7.[strName] is null 
print N'Table [tstGlobalSiteOptions] - insert: ' + cast(@@rowcount as nvarchar(20))


--


--

print N''
print N'Insert records - Tables with administrative module data - part 4 - end'
print N''
print N''
/************************************************************
* Insert records - Tables with administrative module data - part 4 - end
************************************************************/


--------------------------------------------------

/************************************************************
* Insert records - Tables with settings of configurable filtration - start
************************************************************/
print N''
print N'Insert records - Tables with settings of configurable filtration - start'
print N''

                               
-- -- --


--

/************************************************************
* Insert records - [tflSite]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tflSite] 

(

					[idfsSite]

					, [strSiteID]

					, [intRowStatus]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					j_tstSite_idfsSite_v7.[idfsSite]

					, tflSite_v6.[strSiteID]

					, tflSite_v6.[intRowStatus]

					, tflSite_v6.[rowguid]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsSite":' + isnull(cast(tflSite_v6.[idfsSite] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[tflSite] tflSite_v6 


					inner join	[Giraffe_Archive].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tflSite_v6.[idfsSite] 
left join	[Giraffe_Archive].[dbo].[tflSite] tflSite_v7 
on	

					tflSite_v7.[idfsSite] = tflSite_v6.[idfsSite] 
where tflSite_v7.[idfsSite] is null 
print N'Table [tflSite] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tflSiteGroup]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tflSiteGroup] 

(

					[idfSiteGroup]

					, [idfsRayon]

					, [strSiteGroupName]

					, [idfsCentralSite]

					, [intRowStatus]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]

					, [idfsSiteGroupType]

					, [strSiteGroupDescription]

					, [idfsLocation]
)
select 

					tflSiteGroup_v6.[idfSiteGroup]

					, j_gisRayon_idfsRayon_v7.[idfsRayon]

					, tflSiteGroup_v6.[strSiteGroupName]

					, j_tstSite_idfsCentralSite_v7.[idfsSite]

					, tflSiteGroup_v6.[intRowStatus]

					, tflSiteGroup_v6.[rowguid]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfSiteGroup":' + isnull(cast(tflSiteGroup_v6.[idfSiteGroup] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()

					, null /*TODO: Check the rule for the new field in EIDSSv7: idfsSiteGroupType*/

					, null /*TODO: Check the rule for the new field in EIDSSv7: strSiteGroupDescription*/

					, null /*TODO: Check the rule for the new field in EIDSSv7: idfsLocation*/
from [Falcon_Archive].[dbo].[tflSiteGroup] tflSiteGroup_v6 


					left join	[Giraffe_Archive].[dbo].[gisRayon] j_gisRayon_idfsRayon_v7

		on	


					j_gisRayon_idfsRayon_v7.[idfsRayon] = tflSiteGroup_v6.[idfsRayon] 

					left join	[Giraffe_Archive].[dbo].[tstSite] j_tstSite_idfsCentralSite_v7

		on	


					j_tstSite_idfsCentralSite_v7.[idfsSite] = tflSiteGroup_v6.[idfsCentralSite] 
left join	[Giraffe_Archive].[dbo].[tflSiteGroup] tflSiteGroup_v7 
on	

					tflSiteGroup_v7.[idfSiteGroup] = tflSiteGroup_v6.[idfSiteGroup] 
where tflSiteGroup_v7.[idfSiteGroup] is null 
print N'Table [tflSiteGroup] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tflSiteGroupRelation]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tflSiteGroupRelation] 

(

					[idfSiteGroupRelation]

					, [idfSenderSiteGroup]

					, [idfReceiverSiteGroup]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tflSiteGroupRelation_v6.[idfSiteGroupRelation]

					, j_tflSiteGroup_idfSenderSiteGroup_v7.[idfSiteGroup]

					, j_tflSiteGroup_idfReceiverSiteGroup_v7.[idfSiteGroup]

					, tflSiteGroupRelation_v6.[rowguid]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfSiteGroupRelation":' + isnull(cast(tflSiteGroupRelation_v6.[idfSiteGroupRelation] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[tflSiteGroupRelation] tflSiteGroupRelation_v6 


					inner join	[Giraffe_Archive].[dbo].[tflSiteGroup] j_tflSiteGroup_idfSenderSiteGroup_v7

		on	


					j_tflSiteGroup_idfSenderSiteGroup_v7.[idfSiteGroup] = tflSiteGroupRelation_v6.[idfSenderSiteGroup] 

					inner join	[Giraffe_Archive].[dbo].[tflSiteGroup] j_tflSiteGroup_idfReceiverSiteGroup_v7

		on	


					j_tflSiteGroup_idfReceiverSiteGroup_v7.[idfSiteGroup] = tflSiteGroupRelation_v6.[idfReceiverSiteGroup] 
left join	[Giraffe_Archive].[dbo].[tflSiteGroupRelation] tflSiteGroupRelation_v7 
on	

					tflSiteGroupRelation_v7.[idfSiteGroupRelation] = tflSiteGroupRelation_v6.[idfSiteGroupRelation] 
where tflSiteGroupRelation_v7.[idfSiteGroupRelation] is null 
print N'Table [tflSiteGroupRelation] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tflSiteToSiteGroup]
************************************************************/
insert into [Giraffe_Archive].[dbo].[tflSiteToSiteGroup] 

(

					[idfSiteToSiteGroup]

					, [idfSiteGroup]

					, [idfsSite]

					, [strSiteID]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tflSiteToSiteGroup_v6.[idfSiteToSiteGroup]

					, j_tflSiteGroup_idfSiteGroup_v7.[idfSiteGroup]

					, j_tstSite_idfsSite_v7.[idfsSite]

					, tflSiteToSiteGroup_v6.[strSiteID]

					, tflSiteToSiteGroup_v6.[rowguid]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfSiteToSiteGroup":' + isnull(cast(tflSiteToSiteGroup_v6.[idfSiteToSiteGroup] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon_Archive].[dbo].[tflSiteToSiteGroup] tflSiteToSiteGroup_v6 


					inner join	[Giraffe_Archive].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tflSiteToSiteGroup_v6.[idfsSite] 

					inner join	[Giraffe_Archive].[dbo].[tflSiteGroup] j_tflSiteGroup_idfSiteGroup_v7

		on	


					j_tflSiteGroup_idfSiteGroup_v7.[idfSiteGroup] = tflSiteToSiteGroup_v6.[idfSiteGroup] 
left join	[Giraffe_Archive].[dbo].[tflSiteToSiteGroup] tflSiteToSiteGroup_v7 
on	

					tflSiteToSiteGroup_v7.[idfSiteToSiteGroup] = tflSiteToSiteGroup_v6.[idfSiteToSiteGroup] 
where tflSiteToSiteGroup_v7.[idfSiteToSiteGroup] is null 
print N'Table [tflSiteToSiteGroup] - insert: ' + cast(@@rowcount as nvarchar(20))


--


--

print N''
print N'Insert records - Tables with settings of configurable filtration - end'
print N''
print N''
/************************************************************
* Insert records - Tables with settings of configurable filtration - end
************************************************************/


----------



END TRY
BEGIN CATCH
    set @Error = ERROR_NUMBER()
	set	@ErrorMsg = /*N'ErrorNumber: ' + CONVERT(NVARCHAR, ERROR_NUMBER()) 
		+*/ N' ErrorSeverity: ' + CONVERT(NVARCHAR, ERROR_SEVERITY())
		+ N' ErrorState: ' + CONVERT(NVARCHAR, ERROR_STATE())
		+ N' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), N'')
		+ N' ErrorLine: ' +  CONVERT(NVARCHAR, ISNULL(ERROR_LINE(), N''))
		+ N' ErrorMessage: ' + ERROR_MESSAGE();
	
	if	@Error <> 0
	begin
			
		RAISERROR (N'Error %d: %s.', -- Message text.
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

DELETE FROM [Giraffe_Archive].dbo.tstLocalSiteOptions WHERE strName = 'Context' collate Cyrillic_General_CI_AS and strValue = 'DataMigration' collate Cyrillic_General_CI_AS

DELETE FROM [Giraffe_Archive].dbo.tstLocalConnectionContext WHERE strConnectionContext = 'DataMigration' collate Cyrillic_General_CI_AS

SET NOCOUNT OFF 



--

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


