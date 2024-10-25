
--

/**************************************************************************************************************************************
* Data Migration script from EIDSSv6.1 to EIDSSv7.
* Execute script on any database, e.g. master, on the server, where both databases of EIDSS v6.1 and v7 ("empty DB") are located.
* By default, in the script EIDSSv6.1 database has the name Falcon and EIDSSv7 database has the name Giraffe.
**************************************************************************************************************************************/

use [Giraffe]
GO


--

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



--


SET XACT_ABORT ON 
SET NOCOUNT ON 

declare @NewTempPassword nvarchar(100) = N'EIDss 2023$'	
declare @NewTempPwdHash nvarchar(max) = N'AQAAAAEAACcQAAAAEIvm12VITc96N39k6s7XDMYN3Nb63T3uPagwEE/lk+5uh3gz10qlliJV5N97SoAE3w=='
declare @NewTempSecurityStamp nvarchar(max) = N'6SCD5I2AKVRSE4QVA6JISRSMXQREY45R'
declare @PreferredNationalLanguage nvarchar(50) = 'ka'

declare @TempIdentifierSeedValue bigint = 99999989
declare @TempIdentifierKey nvarchar(36)
set @TempIdentifierKey = cast(newid() as nvarchar(36))

declare @IdMigrationPrefix nvarchar(4) = N'MIGR'
declare @IdGenerateDigitNumber int = 5
declare	@YY nvarchar(2)
set @YY = right(cast(year(getutcdate()) as nvarchar(10)), 2)

declare	@Error	int
set	@Error = 0

declare	@ErrorMsg	nvarchar(MAX)
set	@ErrorMsg = N''

declare	@cmd	nvarchar(4000)
set	@cmd = N''


BEGIN TRAN

BEGIN TRY


--

/**************************************************************************************************************************************
* SetContext
**************************************************************************************************************************************/
DECLARE @Context VARBINARY(128)
SET @Context = CAST('DataMigration' AS VARBINARY(128))
SET CONTEXT_INFO @Context

IF NOT EXISTS (SELECT 1 FROM [Giraffe].[dbo].tstLocalSiteOptions WHERE strName = 'Context' collate Cyrillic_General_CI_AS)
INSERT INTO [Giraffe].[dbo].tstLocalSiteOptions 
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

SELECT	@CountryPrefix = left(isnull(c.strHASC, N''), 2)
FROM	[Falcon].[dbo].gisCountry c
WHERE	c.idfsCountry = @idfsCountry

IF @CountryPrefix is null or @CountryPrefix = N'' collate Cyrillic_General_CI_AS
	SET @CountryPrefix = N'US'

SET @idfsPreferredNationalLanguage = [Falcon].dbo.fnGetLanguageCode(@PreferredNationalLanguage)

declare @NumberOfExistingMigratedRecords bigint = 0

select	@InitialDiagResource = coalesce(trtResourceTranslation_v7.[strResourceString], trtResource_v7.[strResourceName], N'Initial Diagnosis')
from	[Giraffe].[dbo].[trtResource] trtResource_v7
left join	[Giraffe].[dbo].[trtResourceTranslation] trtResourceTranslation_v7
on			trtResourceTranslation_v7.[idfsResource] = trtResource_v7.[idfsResource]
			and trtResourceTranslation_v7.[idfsLanguage] = @idfsPreferredNationalLanguage
where	trtResource_v7.[idfsResource] = 410 /*Initial Diagnosis*/


select	@FinalDiagResource = coalesce(trtResourceTranslation_v7.[strResourceString], trtResource_v7.[strResourceName], N'Final Diagnosis')
from	[Giraffe].[dbo].[trtResource] trtResource_v7
left join	[Giraffe].[dbo].[trtResourceTranslation] trtResourceTranslation_v7
on			trtResourceTranslation_v7.[idfsResource] = trtResource_v7.[idfsResource]
			and trtResourceTranslation_v7.[idfsLanguage] = @idfsPreferredNationalLanguage
where	trtResource_v7.[idfsResource] = 400 /*Final Diagnosis*/





--

/************************************************************
* Create concordance table for processing duplicated Farm IDs - start
************************************************************/


if object_id(N'_dmccFarmActual') is null
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

--



/************************************************************
* Fill in concordance table for processing duplicated Farm IDs - start
************************************************************/
print N'Identify actual farms from v6.1 and ensure unique Farm ID code'
print N''
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
print N'Actual Farms from v6.1: ' + cast(@@rowcount as nvarchar(20))

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

--

/************************************************************
* Insert records - Tables with persons and farms catalogs data - start
************************************************************/
print N''
print N'Insert records - Tables with persons and farms catalogs data - start'
print N''

   
--

/************************************************************
* Prepare data before insert - [tlbGeoLocationShared]
************************************************************/

/************************************************************
* Reset identifier seed value to the temporary one - start
************************************************************/

declare	@sqlIdResetCmd				nvarchar(max)
set	@sqlIdResetCmd = N''

set	@sqlIdResetCmd = N'

declare @TempIdentifierSeedValue bigint = ' + cast((@TempIdentifierSeedValue - case when db_name() like N'%_Archive' collate Cyrillic_General_CI_AS then 1 else 0 end) as nvarchar(20)) + N'

declare	@max_value			bigint
set	@max_value = @TempIdentifierSeedValue

declare	@seed_value			bigint
set	@seed_value = null
declare	@increment_value	bigint
set	@increment_value = null

declare	@sqlCmd				nvarchar(max)
set	@sqlCmd = N''''

' collate Cyrillic_General_CI_AS

select	@sqlIdResetCmd = @sqlIdResetCmd + N'
	-- dbo.' + t.[name] + N': ' + c_ic.[name] + N'
	if	exists	(
			select	1 
			from	[Falcon].[sys].[tables] t
			inner join	[Falcon].sys.objects o_t
			on			o_t.[object_id] = t.[object_id]
						and o_t.[type] = N''U'' collate Cyrillic_General_CI_AS
			inner join	[Falcon].sys.schemas s
			on			s.[schema_id] = t.[schema_id]
						and s.[name] = N''dbo'' collate Cyrillic_General_CI_AS			
			where		t.[name] = N''' + t.[name] + N''' collate Cyrillic_General_CI_AS
				)
	begin
		if	exists	(
				select	1
				from	[Falcon].[dbo].[' + t.[name] + N']
				where	[' + c_ic.[name] + N'] >= @max_value
						and ([' + c_ic.[name] + '] - @TempIdentifierSeedValue) % 10000000 = 0
					)
		begin
			select		@max_value = max(' + c_ic.[name] + N') + 10000000
			from		[Falcon].[dbo].[' + t.[name] + N']
			where		([' + c_ic.[name] + '] - @TempIdentifierSeedValue) % 10000000 = 0
		end
	end
'
from
-- Table
			[Falcon].sys.tables t
inner join	[Falcon].sys.objects o_t
on			o_t.[object_id] = t.[object_id]
			and o_t.[type] = N'U' collate Cyrillic_General_CI_AS
			and o_t.[name] not like N'gis%' collate Cyrillic_General_CI_AS
			and o_t.[name] not like N'tfl%' collate Cyrillic_General_CI_AS
			and o_t.[name] not like N'Lkup%' collate Cyrillic_General_CI_AS

inner join	[Falcon].sys.schemas s
on			s.[schema_id] = t.[schema_id]
			and s.[name] = N'dbo' collate Cyrillic_General_CI_AS

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
			and c_ic.[name] <> N'idfsLanguage'
			and c_ic.[system_type_id] in (127, 56)
where		not exists	(
					select	1
					from		[Falcon].sys.index_columns ic_second
					inner join	[Falcon].sys.columns c_ic_second
					on			c_ic_second.[object_id] = ic_second.[object_id]
								and c_ic_second.[column_id] = ic_second.[column_id]
								and c_ic_second.[name] <> N'idfsLanguage'
								and c_ic_second.[system_type_id]  in (127, 56)
								and	c_ic_second.[column_id] <> c_ic.[column_id]
					where		ic_second.[object_id] = i.[object_id]
								and ic_second.[index_id] = i.[index_id]
						)

    

set	@sqlIdResetCmd = @sqlIdResetCmd + N'
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
where		NewIDtable.[id] = object_id(N''[dbo].[tstNewID]'') 
			and OBJECTPROPERTY(NewIDtable.[id], N''IsUserTable'') = 1
			and NewIDcol.[name] = N''NewID''

if	(@seed_value is null) or (@increment_value is null)
	or (@seed_value is not null and (@seed_value < @max_value) and ((isnull(@seed_value, 0) - @max_value) % 10000000 = 0))
	or (@seed_value is not null and ((isnull(@seed_value, 0) - @max_value) % 10000000 <> 0))
--			or (@increment_value <> 10000000)
begin
	set @sqlCmd = N''
if	exists	(
select	1 
from	[Giraffe].[dbo].sysobjects 
where	id = object_id(N''''[dbo].[tstNewID]'''') 
		and OBJECTPROPERTY(id, N''''IsUserTable'''') = 1
	)
drop table [dbo].[tstNewID]

''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''
create table	[dbo].[tstNewID]
(	NewID		bigint IDENTITY('' + cast(@max_value as nvarchar(20)) + N'', 10000000) not null,
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
''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''
ALTER TABLE [dbo].[tstNewID] ADD  CONSTRAINT [DF_tstNewID_rowguid]  DEFAULT (newsequentialid()) FOR [rowguid]
''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''
ALTER TABLE [dbo].[tstNewID] ADD  CONSTRAINT [DF_tstNewID_CreateDTM]  DEFAULT (getdate()) FOR [AuditCreateDTM]
''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''
ALTER TABLE [dbo].[tstNewID]  WITH CHECK ADD  CONSTRAINT [FK_tstNewID_trtBaseReference_SourceSystemNameID] FOREIGN KEY([SourceSystemNameID])
REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''
ALTER TABLE [dbo].[tstNewID] CHECK CONSTRAINT [FK_tstNewID_trtBaseReference_SourceSystemNameID]
''
	execute sp_executesql @sqlCmd

	print	''New temporary consequent ID value in the table tstNewID: '' + cast(@max_value as varchar(30))
end
else 
	print ''Update of temporary consequent ID value in the table tstNewID is not needed: '' + cast(@seed_value as varchar(30))
'
exec [Giraffe].[sys].sp_executesql @sqlIdResetCmd
/************************************************************
* Reset identifier seed value to the temporary one - end
************************************************************/

declare @ArchiveCmd nvarchar(max) = N''

if DB_NAME() like N'%_Archive' collate Latin1_General_CI_AS
begin
	set @ArchiveCmd = N'
INSERT INTO [' + DB_NAME() + N'].[dbo].[tlbGeoLocationShared]
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

FROM	[' + left(DB_NAME(), len(DB_NAME()) - 8) + N'].[dbo].[tlbHumanActual] tlbHumanActual_v7_Actual
join	[Falcon].[dbo].[tlbHumanActual] tlbHumanActual_v6_Archive
on		tlbHumanActual_v6_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]
join	[' + left(DB_NAME(), len(DB_NAME()) - 8) + N'].[dbo].[HumanActualAddlInfo] HumanActualAddlInfo_v7_Actual
on		HumanActualAddlInfo_v7_Actual.[HumanActualAddlInfoUID] = tlbHumanActual_v7_Actual.[idfHumanActual]
join	[' + left(DB_NAME(), len(DB_NAME()) - 8) + N'].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v7_Actual
on		tlbGeoLocationShared_v7_Actual.[idfGeoLocationShared] = HumanActualAddlInfo_v7_Actual.[SchoolAddressID]
left join	[' + DB_NAME() + N'].[dbo].[tlbHumanActual] tlbHumanActual_v7_Archive
on		tlbHumanActual_v7_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]
left join	[' + DB_NAME() + N'].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v7_Archive
on		tlbGeoLocationShared_v7_Archive.[idfGeoLocationShared] = HumanActualAddlInfo_v7_Actual.[SchoolAddressID]

WHERE	tlbHumanActual_v7_Archive.[idfHumanActual] is null
		and tlbGeoLocationShared_v7_Archive.[idfGeoLocationShared] is null
print N''Table [tlbGeoLocationShared] - Insert school addresses of persons by copying from actual database: '' + cast(@@rowcount as nvarchar(20))
	
	'
	exec sp_executesql @ArchiveCmd
   


	set @ArchiveCmd = N'
INSERT INTO [' + DB_NAME() + N'].[dbo].[tlbGeoLocationShared]
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

FROM	[' + left(DB_NAME(), len(DB_NAME()) - 8) + N'].[dbo].[tlbHumanActual] tlbHumanActual_v7_Actual
join	[Falcon].[dbo].[tlbHumanActual] tlbHumanActual_v6_Archive
on		tlbHumanActual_v6_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]
join	[' + left(DB_NAME(), len(DB_NAME()) - 8) + N'].[dbo].[HumanActualAddlInfo] HumanActualAddlInfo_v7_Actual
on		HumanActualAddlInfo_v7_Actual.[HumanActualAddlInfoUID] = tlbHumanActual_v7_Actual.[idfHumanActual]
join	[' + left(DB_NAME(), len(DB_NAME()) - 8) + N'].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v7_Actual
on		tlbGeoLocationShared_v7_Actual.[idfGeoLocationShared] = HumanActualAddlInfo_v7_Actual.[AltAddressID]
left join	[' + DB_NAME() + N'].[dbo].[tlbHumanActual] tlbHumanActual_v7_Archive
on		tlbHumanActual_v7_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]
left join	[' + DB_NAME() + N'].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v7_Archive
on		tlbGeoLocationShared_v7_Archive.[idfGeoLocationShared] = HumanActualAddlInfo_v7_Actual.[AltAddressID]

WHERE	tlbHumanActual_v7_Archive.[idfHumanActual] is null
		and tlbGeoLocationShared_v7_Archive.[idfGeoLocationShared] is null
print N''Table [tlbGeoLocationShared] - Insert alternative addresses of persons by copying from actual database: '' + cast(@@rowcount as nvarchar(20))
	
	'
	exec sp_executesql @ArchiveCmd

	set @ArchiveCmd = N'
INSERT INTO [' + DB_NAME() + N'].[dbo].[tlbGeoLocationShared]
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

FROM	[' + left(DB_NAME(), len(DB_NAME()) - 8) + N'].[dbo].[tlbHumanActual] tlbHumanActual_v7_Actual
join	[Falcon].[dbo].[tlbHumanActual] tlbHumanActual_v6_Archive
on		tlbHumanActual_v6_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]
join	[' + left(DB_NAME(), len(DB_NAME()) - 8) + N'].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v7_Actual
on		tlbGeoLocationShared_v7_Actual.[idfGeoLocationShared] = tlbHumanActual_v7_Actual.[idfCurrentResidenceAddress]
left join	[' + DB_NAME() + N'].[dbo].[tlbHumanActual] tlbHumanActual_v7_Archive
on		tlbHumanActual_v7_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]
left join	[' + DB_NAME() + N'].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v7_Archive
on		tlbGeoLocationShared_v7_Archive.[idfGeoLocationShared] = tlbHumanActual_v7_Actual.[idfCurrentResidenceAddress]

WHERE	tlbHumanActual_v7_Archive.[idfHumanActual] is null
		and tlbGeoLocationShared_v7_Archive.[idfGeoLocationShared] is null
print N''Table [tlbGeoLocationShared] - Insert missing current residence addresses of persons by copying from actual database: '' + cast(@@rowcount as nvarchar(20))
	
	'
	exec sp_executesql @ArchiveCmd
          


	set @ArchiveCmd = N'
INSERT INTO [' + DB_NAME() + N'].[dbo].[tlbGeoLocationShared]
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

FROM	[' + left(DB_NAME(), len(DB_NAME()) - 8) + N'].[dbo].[tlbHumanActual] tlbHumanActual_v7_Actual
join	[Falcon].[dbo].[tlbHumanActual] tlbHumanActual_v6_Archive
on		tlbHumanActual_v6_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]
join	[' + left(DB_NAME(), len(DB_NAME()) - 8) + N'].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v7_Actual
on		tlbGeoLocationShared_v7_Actual.[idfGeoLocationShared] = tlbHumanActual_v7_Actual.[idfRegistrationAddress]
left join	[' + DB_NAME() + N'].[dbo].[tlbHumanActual] tlbHumanActual_v7_Archive
on		tlbHumanActual_v7_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]
left join	[' + DB_NAME() + N'].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v7_Archive
on		tlbGeoLocationShared_v7_Archive.[idfGeoLocationShared] = tlbHumanActual_v7_Actual.[idfRegistrationAddress]

WHERE	tlbHumanActual_v7_Archive.[idfHumanActual] is null
		and tlbGeoLocationShared_v7_Archive.[idfGeoLocationShared] is null
print N''Table [tlbGeoLocationShared] - Insert missing permanent residence addresses of persons by copying from actual database: '' + cast(@@rowcount as nvarchar(20))
	
	'
	exec sp_executesql @ArchiveCmd

	set @ArchiveCmd = N'
INSERT INTO [' + DB_NAME() + N'].[dbo].[tlbGeoLocationShared]
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

FROM	[' + left(DB_NAME(), len(DB_NAME()) - 8) + N'].[dbo].[tlbHumanActual] tlbHumanActual_v7_Actual
join	[Falcon].[dbo].[tlbHumanActual] tlbHumanActual_v6_Archive
on		tlbHumanActual_v6_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]
join	[' + left(DB_NAME(), len(DB_NAME()) - 8) + N'].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v7_Actual
on		tlbGeoLocationShared_v7_Actual.[idfGeoLocationShared] = tlbHumanActual_v7_Actual.[idfEmployerAddress]
left join	[' + DB_NAME() + N'].[dbo].[tlbHumanActual] tlbHumanActual_v7_Archive
on		tlbHumanActual_v7_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]
left join	[' + DB_NAME() + N'].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v7_Archive
on		tlbGeoLocationShared_v7_Archive.[idfGeoLocationShared] = tlbHumanActual_v7_Actual.[idfEmployerAddress]

WHERE	tlbHumanActual_v7_Archive.[idfHumanActual] is null
		and tlbGeoLocationShared_v7_Archive.[idfGeoLocationShared] is null
print N''Table [tlbGeoLocationShared] - Insert missing employer addresses of persons by copying from actual database: '' + cast(@@rowcount as nvarchar(20))
	
	'
	exec sp_executesql @ArchiveCmd
       


	set @ArchiveCmd = N'
INSERT INTO [' + DB_NAME() + N'].[dbo].[tlbHumanActual]
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

FROM	[' + left(DB_NAME(), len(DB_NAME()) - 8) + N'].[dbo].[tlbHumanActual] tlbHumanActual_v7_Actual
join	[Falcon].[dbo].[tlbHumanActual] tlbHumanActual_v6_Archive
on		tlbHumanActual_v6_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]
left join	[' + DB_NAME() + N'].[dbo].[tlbHumanActual] tlbHumanActual_v7_Archive
on		tlbHumanActual_v7_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]

WHERE	tlbHumanActual_v7_Archive.[idfHumanActual] is null
print N''Table [tlbHumanActual] - Insert persons by copying from actual database: '' + cast(@@rowcount as nvarchar(20))
	
	'
	exec sp_executesql @ArchiveCmd


	set @ArchiveCmd = N'
INSERT INTO [' + DB_NAME() + N'].[dbo].[HumanActualAddlInfo]
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

FROM	[' + left(DB_NAME(), len(DB_NAME()) - 8) + N'].[dbo].[tlbHumanActual] tlbHumanActual_v7_Actual
join	[Falcon].[dbo].[tlbHumanActual] tlbHumanActual_v6_Archive
on		tlbHumanActual_v6_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]
join	[' + left(DB_NAME(), len(DB_NAME()) - 8) + N'].[dbo].[HumanActualAddlInfo] HumanActualAddlInfo_v7_Actual
on		HumanActualAddlInfo_v7_Actual.[HumanActualAddlInfoUID] = tlbHumanActual_v7_Actual.[idfHumanActual]
join	[' + DB_NAME() + N'].[dbo].[tlbHumanActual] tlbHumanActual_v7_Archive
on		tlbHumanActual_v7_Archive.[idfHumanActual] = tlbHumanActual_v7_Actual.[idfHumanActual]
left join	[' + DB_NAME() + N'].[dbo].[HumanActualAddlInfo] HumanActualAddlInfo_v7_Archive
on		HumanActualAddlInfo_v7_Archive.[HumanActualAddlInfoUID] = tlbHumanActual_v7_Actual.[idfHumanActual]

WHERE	HumanActualAddlInfo_v7_Archive.[HumanActualAddlInfoUID] is null
print N''Table [HumanActualAddlInfo] - Insert persons details by copying from actual database: '' + cast(@@rowcount as nvarchar(20))
	
	'
	exec sp_executesql @ArchiveCmd

end
   


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

exec [Giraffe].sys.sp_executesql N'ALTER INDEX ALL ON dbo.tstNewID REBUILD'

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
			, N'[{' + N'"idfGeoLocationShared":' + isnull(cast(tstNewID_v7.[NewID] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS
			, N'system'
			, GETUTCDATE()
			, N'system'
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
print N'Table [tlbGeoLocationShared] - insert new alternative and school addresses of persons from the catalog: ' + cast(@@rowcount as nvarchar(20))


/************************************************************
* Prepare data before insert - [tlbFarmActual]
************************************************************/

if DB_NAME() like N'%_Archive' collate Latin1_General_CI_AS
begin
	set @ArchiveCmd = N'
INSERT INTO [' + DB_NAME() + N'].[dbo].[tlbGeoLocationShared]
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

FROM	[' + left(DB_NAME(), len(DB_NAME()) - 8) + N'].[dbo].[tlbFarmActual] tlbFarmActual_v7_Actual
join	[Falcon].[dbo].[tlbFarmActual] tlbFarmActual_v6_Archive
on		tlbFarmActual_v6_Archive.[idfFarmActual] = tlbFarmActual_v7_Actual.[idfFarmActual]
join	[' + left(DB_NAME(), len(DB_NAME()) - 8) + N'].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v7_Actual
on		tlbGeoLocationShared_v7_Actual.[idfGeoLocationShared] = tlbFarmActual_v7_Actual.[idfFarmAddress]
left join	[' + DB_NAME() + N'].[dbo].[tlbFarmActual] tlbFarmActual_v7_Archive
on		tlbFarmActual_v7_Archive.[idfFarmActual] = tlbFarmActual_v7_Actual.[idfFarmActual]
left join	[' + DB_NAME() + N'].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v7_Archive
on		tlbGeoLocationShared_v7_Archive.[idfGeoLocationShared] = tlbFarmActual_v7_Actual.[idfFarmAddress]

WHERE	tlbFarmActual_v7_Archive.[idfFarmActual] is null
		and tlbGeoLocationShared_v7_Archive.[idfGeoLocationShared] is null
print N''Table [tlbGeoLocationShared] - Insert missing farm addresses by copying from actual database: '' + cast(@@rowcount as nvarchar(20))
	
	'
	exec sp_executesql @ArchiveCmd
 


	set @ArchiveCmd = N'
INSERT INTO [' + DB_NAME() + N'].[dbo].[tlbFarmActual]
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

FROM	[' + left(DB_NAME(), len(DB_NAME()) - 8) + N'].[dbo].[tlbFarmActual] tlbFarmActual_v7_Actual
join	[Falcon].[dbo].[tlbFarmActual] tlbFarmActual_v6_Archive
on		tlbFarmActual_v6_Archive.[idfFarmActual] = tlbFarmActual_v7_Actual.[idfFarmActual]
left join	[' + DB_NAME() + N'].[dbo].[tlbFarmActual] tlbFarmActual_v7_Archive
on		tlbFarmActual_v7_Archive.[idfFarmActual] = tlbFarmActual_v7_Actual.[idfFarmActual]

WHERE	tlbFarmActual_v7_Archive.[idfFarmActual] is null
print N''Table [tlbFarmActual] - Insert farms by copying from actual database: '' + cast(@@rowcount as nvarchar(20))
	
	'
	exec sp_executesql @ArchiveCmd
end
   
  
  
  


--

/************************************************************
* Insert records - [tlbGeoLocationShared]
************************************************************/
insert into [Giraffe].[dbo].[tlbGeoLocationShared] 

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
from [Falcon].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v6 


					inner join	[Giraffe].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tlbGeoLocationShared_v6.[idfsSite] 

					left join	[Giraffe].[dbo].[gisCountry] j_gisCountry_idfsCountry_v7

		on	


					j_gisCountry_idfsCountry_v7.[idfsCountry] = tlbGeoLocationShared_v6.[idfsCountry] 

					left join	[Giraffe].[dbo].[gisRayon] j_gisRayon_idfsRayon_v7

		on	


					j_gisRayon_idfsRayon_v7.[idfsRayon] = tlbGeoLocationShared_v6.[idfsRayon] 

					left join	[Giraffe].[dbo].[gisRegion] j_gisRegion_idfsRegion_v7

		on	


					j_gisRegion_idfsRegion_v7.[idfsRegion] = tlbGeoLocationShared_v6.[idfsRegion] 

					left join	[Giraffe].[dbo].[gisSettlement] j_gisSettlement_idfsSettlement_v7

		on	


					j_gisSettlement_idfsSettlement_v7.[idfsSettlement] = tlbGeoLocationShared_v6.[idfsSettlement] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsResidentType_v7

		on	


					j_trtBaseReference_idfsResidentType_v7.[idfsBaseReference] = tlbGeoLocationShared_v6.[idfsResidentType] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsGroundType_v7

		on	


					j_trtBaseReference_idfsGroundType_v7.[idfsBaseReference] = tlbGeoLocationShared_v6.[idfsGroundType] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsGeoLocationType_v7

		on	


					j_trtBaseReference_idfsGeoLocationType_v7.[idfsBaseReference] = tlbGeoLocationShared_v6.[idfsGeoLocationType] 
left join	[Giraffe].[dbo].[tlbGeoLocationShared] tlbGeoLocationShared_v7 
on	

					tlbGeoLocationShared_v7.[idfGeoLocationShared] = tlbGeoLocationShared_v6.[idfGeoLocationShared] 
where tlbGeoLocationShared_v7.[idfGeoLocationShared] is null 
	and (	exists (select 1 from [Falcon].[dbo].[tlbHumanActual] tlbHumanActual_v6 where tlbHumanActual_v6.[idfCurrentResidenceAddress] = tlbGeoLocationShared_v6.[idfGeoLocationShared])
			or exists (select 1 from [Falcon].[dbo].[tlbHumanActual] tlbHumanActual_v6 where tlbHumanActual_v6.[idfEmployerAddress] = tlbGeoLocationShared_v6.[idfGeoLocationShared])
			or exists (select 1 from [Falcon].[dbo].[tlbHumanActual] tlbHumanActual_v6 where tlbHumanActual_v6.[idfRegistrationAddress] = tlbGeoLocationShared_v6.[idfGeoLocationShared])
			or exists (select 1 from [Falcon].[dbo].[tlbFarmActual] tlbFarmActual_v6 where tlbFarmActual_v6.[idfFarmAddress] = tlbGeoLocationShared_v6.[idfGeoLocationShared])
		)

print N'Table [tlbGeoLocationShared] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbStreet]
************************************************************/
insert into [Giraffe].[dbo].[tlbStreet] 

(

					[idfStreet]

					, [strStreetName]

					, [idfsSettlement]

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

					, [idfsLocation]
)
select 

					tlbStreet_v6.[idfStreet]

					, tlbStreet_v6.[strStreetName]

					, j_gisSettlement_idfsSettlement_v7.[idfsSettlement]

					, tlbStreet_v6.[intRowStatus]

					, tlbStreet_v6.[rowguid]

					, tlbStreet_v6.[strMaintenanceFlag]

					, tlbStreet_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfStreet":' + isnull(cast(tlbStreet_v6.[idfStreet] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()

					, j_gisSettlement_idfsSettlement_v7.[idfsSettlement] /*Rule for the new field in EIDSSv7: idfsLocation*/
from [Falcon].[dbo].[tlbStreet] tlbStreet_v6 


					left join	[Giraffe].[dbo].[gisSettlement] j_gisSettlement_idfsSettlement_v7

		on	


					j_gisSettlement_idfsSettlement_v7.[idfsSettlement] = tlbStreet_v6.[idfsSettlement] 
left join	[Giraffe].[dbo].[tlbStreet] tlbStreet_v7 
on	

					tlbStreet_v7.[idfStreet] = tlbStreet_v6.[idfStreet] 
where tlbStreet_v7.[idfStreet] is null 
	and not exists (select 1 from [Giraffe].[dbo].[tlbStreet] tlbStreet_v7_UK where tlbStreet_v7_UK.[idfsLocation] =  j_gisSettlement_idfsSettlement_v7.[idfsSettlement] and tlbStreet_v7_UK.[strStreetName] = tlbStreet_v6.[strStreetName] collate Cyrillic_General_CI_AS)

print N'Table [tlbStreet] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbPostalCode]
************************************************************/
insert into [Giraffe].[dbo].[tlbPostalCode] 

(

					[idfPostalCode]

					, [strPostCode]

					, [idfsSettlement]

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

					, [idfsLocation]
)
select 

					tlbPostalCode_v6.[idfPostalCode]

					, tlbPostalCode_v6.[strPostCode]

					, j_gisSettlement_idfsSettlement_v7.[idfsSettlement]

					, tlbPostalCode_v6.[intRowStatus]

					, tlbPostalCode_v6.[rowguid]

					, tlbPostalCode_v6.[strMaintenanceFlag]

					, tlbPostalCode_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfPostalCode":' + isnull(cast(tlbPostalCode_v6.[idfPostalCode] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()

					, j_gisSettlement_idfsSettlement_v7.[idfsSettlement] /*Rule for the new field in EIDSSv7: idfsLocation*/
from [Falcon].[dbo].[tlbPostalCode] tlbPostalCode_v6 


					left join	[Giraffe].[dbo].[gisSettlement] j_gisSettlement_idfsSettlement_v7

		on	


					j_gisSettlement_idfsSettlement_v7.[idfsSettlement] = tlbPostalCode_v6.[idfsSettlement] 
left join	[Giraffe].[dbo].[tlbPostalCode] tlbPostalCode_v7 
on	

					tlbPostalCode_v7.[idfPostalCode] = tlbPostalCode_v6.[idfPostalCode] 
where tlbPostalCode_v7.[idfPostalCode] is null 
	and not exists (select 1 from [Giraffe].[dbo].[tlbPostalCode] tlbPostalCode_v7_UK where tlbPostalCode_v7_UK.[idfsLocation] =  j_gisSettlement_idfsSettlement_v7.[idfsSettlement] and tlbPostalCode_v7_UK.[strPostCode] = tlbPostalCode_v6.[strPostCode] collate Cyrillic_General_CI_AS)

print N'Table [tlbPostalCode] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbHumanActual]
************************************************************/
insert into [Giraffe].[dbo].[tlbHumanActual] 

(

					[idfHumanActual]

					, [idfsOccupationType]

					, [idfsNationality]

					, [idfsHumanGender]

					, [idfCurrentResidenceAddress]

					, [idfEmployerAddress]

					, [idfRegistrationAddress]

					, [datDateofBirth]

					, [datDateOfDeath]

					, [strLastName]

					, [strSecondName]

					, [strFirstName]

					, [strRegistrationPhone]

					, [strEmployerName]

					, [strHomePhone]

					, [strWorkPhone]

					, [rowguid]

					, [intRowStatus]

					, [idfsPersonIDType]

					, [strPersonID]

					, [datEnteredDate]

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
select 

					tlbHumanActual_v6.[idfHumanActual]

					, j_trtBaseReference_idfsOccupationType_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsNationality_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsHumanGender_v7.[idfsBaseReference]

					, j_tlbGeoLocationShared_idfCurrentResidenceAddress_v7.[idfGeoLocationShared]

					, j_tlbGeoLocationShared_idfEmployerAddress_v7.[idfGeoLocationShared]

					, j_tlbGeoLocationShared_idfRegistrationAddress_v7.[idfGeoLocationShared]

					, tlbHumanActual_v6.[datDateofBirth]

					, tlbHumanActual_v6.[datDateOfDeath]

					, tlbHumanActual_v6.[strLastName]

					, tlbHumanActual_v6.[strSecondName]

					, tlbHumanActual_v6.[strFirstName]

					, tlbHumanActual_v6.[strRegistrationPhone]

					, tlbHumanActual_v6.[strEmployerName]

					, tlbHumanActual_v6.[strHomePhone]

					, tlbHumanActual_v6.[strWorkPhone]

					, tlbHumanActual_v6.[rowguid]

					, tlbHumanActual_v6.[intRowStatus]

					, j_trtBaseReference_idfsPersonIDType_v7.[idfsBaseReference]

					, tlbHumanActual_v6.[strPersonID]

					, tlbHumanActual_v6.[datEnteredDate]

					, tlbHumanActual_v6.[datModificationDate]

					, tlbHumanActual_v6.[strMaintenanceFlag]

					, tlbHumanActual_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfHumanActual":' + isnull(cast(tlbHumanActual_v6.[idfHumanActual] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbHumanActual] tlbHumanActual_v6 


					left join	[Giraffe].[dbo].[tlbGeoLocationShared] j_tlbGeoLocationShared_idfCurrentResidenceAddress_v7

		on	


					j_tlbGeoLocationShared_idfCurrentResidenceAddress_v7.[idfGeoLocationShared] = tlbHumanActual_v6.[idfCurrentResidenceAddress] 

					left join	[Giraffe].[dbo].[tlbGeoLocationShared] j_tlbGeoLocationShared_idfEmployerAddress_v7

		on	


					j_tlbGeoLocationShared_idfEmployerAddress_v7.[idfGeoLocationShared] = tlbHumanActual_v6.[idfEmployerAddress] 

					left join	[Giraffe].[dbo].[tlbGeoLocationShared] j_tlbGeoLocationShared_idfRegistrationAddress_v7

		on	


					j_tlbGeoLocationShared_idfRegistrationAddress_v7.[idfGeoLocationShared] = tlbHumanActual_v6.[idfRegistrationAddress] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsOccupationType_v7

		on	


					j_trtBaseReference_idfsOccupationType_v7.[idfsBaseReference] = tlbHumanActual_v6.[idfsOccupationType] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsNationality_v7

		on	


					j_trtBaseReference_idfsNationality_v7.[idfsBaseReference] = tlbHumanActual_v6.[idfsNationality] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsHumanGender_v7

		on	


					j_trtBaseReference_idfsHumanGender_v7.[idfsBaseReference] = tlbHumanActual_v6.[idfsHumanGender] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsPersonIDType_v7

		on	


					j_trtBaseReference_idfsPersonIDType_v7.[idfsBaseReference] = isnull(tlbHumanActual_v6.[idfsPersonIDType], 51577280000000 /*Unknown*/) 
left join	[Giraffe].[dbo].[tlbHumanActual] tlbHumanActual_v7 
on	

					tlbHumanActual_v7.[idfHumanActual] = tlbHumanActual_v6.[idfHumanActual] 
where tlbHumanActual_v7.[idfHumanActual] is null 
print N'Table [tlbHumanActual] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbFarmActual]
************************************************************/
insert into [Giraffe].[dbo].[tlbFarmActual] 

(

					[idfFarmActual]

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
select 

					tlbFarmActual_v6.[idfFarmActual]

					, j_trtBaseReference_idfsAvianFarmType_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsAvianProductionType_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsFarmCategory_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsOwnershipStructure_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsMovementPattern_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsIntendedUse_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsGrazingPattern_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsLivestockProductionType_v7.[idfsBaseReference]

					, j_tlbHumanActual_idfHumanActual_v7.[idfHumanActual]

					, j_tlbGeoLocationShared_idfFarmAddress_v7.[idfGeoLocationShared]

					, tlbFarmActual_v6.[strInternationalName]

					, tlbFarmActual_v6.[strNationalName]

					, isnull(ccfa.[strFarmCode_v7], tlbFarmActual_v6.[strFarmCode])

					, tlbFarmActual_v6.[strFax]

					, tlbFarmActual_v6.[strEmail]

					, tlbFarmActual_v6.[strContactPhone]

					, tlbFarmActual_v6.[intLivestockTotalAnimalQty]

					, tlbFarmActual_v6.[intAvianTotalAnimalQty]

					, tlbFarmActual_v6.[intLivestockSickAnimalQty]

					, tlbFarmActual_v6.[intAvianSickAnimalQty]

					, tlbFarmActual_v6.[intLivestockDeadAnimalQty]

					, tlbFarmActual_v6.[intAvianDeadAnimalQty]

					, tlbFarmActual_v6.[intBuidings]

					, tlbFarmActual_v6.[intBirdsPerBuilding]

					, tlbFarmActual_v6.[strNote]

					, tlbFarmActual_v6.[rowguid]

					, tlbFarmActual_v6.[intRowStatus]

					, tlbFarmActual_v6.[intHACode]

					, tlbFarmActual_v6.[datModificationDate]

					, tlbFarmActual_v6.[strMaintenanceFlag]

					, tlbFarmActual_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfFarmActual":' + isnull(cast(tlbFarmActual_v6.[idfFarmActual] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbFarmActual] tlbFarmActual_v6 
	left join	[Giraffe].[dbo].[_dmccFarmActual] ccfa
	on			ccfa.[idfFarmActual_v6] = tlbFarmActual_v6.[idfFarmActual]
				and ccfa.[idfFarmActual_v7] is null



					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsGrazingPattern_v7

		on	


					j_trtBaseReference_idfsGrazingPattern_v7.[idfsBaseReference] = tlbFarmActual_v6.[idfsGrazingPattern] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsLivestockProductionType_v7

		on	


					j_trtBaseReference_idfsLivestockProductionType_v7.[idfsBaseReference] = tlbFarmActual_v6.[idfsLivestockProductionType] 

					left join	[Giraffe].[dbo].[tlbHumanActual] j_tlbHumanActual_idfHumanActual_v7

		on	


					j_tlbHumanActual_idfHumanActual_v7.[idfHumanActual] = tlbFarmActual_v6.[idfHumanActual] 

					left join	[Giraffe].[dbo].[tlbGeoLocationShared] j_tlbGeoLocationShared_idfFarmAddress_v7

		on	


					j_tlbGeoLocationShared_idfFarmAddress_v7.[idfGeoLocationShared] = tlbFarmActual_v6.[idfFarmAddress] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsAvianFarmType_v7

		on	


					j_trtBaseReference_idfsAvianFarmType_v7.[idfsBaseReference] = tlbFarmActual_v6.[idfsAvianFarmType] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsAvianProductionType_v7

		on	


					j_trtBaseReference_idfsAvianProductionType_v7.[idfsBaseReference] = tlbFarmActual_v6.[idfsAvianProductionType] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsFarmCategory_v7

		on	


					j_trtBaseReference_idfsFarmCategory_v7.[idfsBaseReference] = tlbFarmActual_v6.[idfsFarmCategory] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsOwnershipStructure_v7

		on	


					j_trtBaseReference_idfsOwnershipStructure_v7.[idfsBaseReference] = tlbFarmActual_v6.[idfsOwnershipStructure] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsMovementPattern_v7

		on	


					j_trtBaseReference_idfsMovementPattern_v7.[idfsBaseReference] = tlbFarmActual_v6.[idfsMovementPattern] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsIntendedUse_v7

		on	


					j_trtBaseReference_idfsIntendedUse_v7.[idfsBaseReference] = tlbFarmActual_v6.[idfsIntendedUse] 
left join	[Giraffe].[dbo].[tlbFarmActual] tlbFarmActual_v7 
on	

					tlbFarmActual_v7.[idfFarmActual] = tlbFarmActual_v6.[idfFarmActual] 
where tlbFarmActual_v7.[idfFarmActual] is null 
print N'Table [tlbFarmActual] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbHerdActual]
************************************************************/
insert into [Giraffe].[dbo].[tlbHerdActual] 

(

					[idfHerdActual]

					, [idfFarmActual]

					, [strHerdCode]

					, [intSickAnimalQty]

					, [intTotalAnimalQty]

					, [intDeadAnimalQty]

					, [strNote]

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

					tlbHerdActual_v6.[idfHerdActual]

					, j_tlbFarmActual_idfFarmActual_v7.[idfFarmActual]

					, tlbHerdActual_v6.[strHerdCode]

					, tlbHerdActual_v6.[intSickAnimalQty]

					, tlbHerdActual_v6.[intTotalAnimalQty]

					, tlbHerdActual_v6.[intDeadAnimalQty]

					, tlbHerdActual_v6.[strNote]

					, tlbHerdActual_v6.[rowguid]

					, tlbHerdActual_v6.[intRowStatus]

					, tlbHerdActual_v6.[strMaintenanceFlag]

					, tlbHerdActual_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfHerdActual":' + isnull(cast(tlbHerdActual_v6.[idfHerdActual] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbHerdActual] tlbHerdActual_v6 


					left join	[Giraffe].[dbo].[tlbFarmActual] j_tlbFarmActual_idfFarmActual_v7

		on	


					j_tlbFarmActual_idfFarmActual_v7.[idfFarmActual] = tlbHerdActual_v6.[idfFarmActual] 
left join	[Giraffe].[dbo].[tlbHerdActual] tlbHerdActual_v7 
on	

					tlbHerdActual_v7.[idfHerdActual] = tlbHerdActual_v6.[idfHerdActual] 
where tlbHerdActual_v7.[idfHerdActual] is null 
print N'Table [tlbHerdActual] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbSpeciesActual]
************************************************************/
insert into [Giraffe].[dbo].[tlbSpeciesActual] 

(

					[idfSpeciesActual]

					, [idfsSpeciesType]

					, [idfHerdActual]

					, [datStartOfSignsDate]

					, [strAverageAge]

					, [intSickAnimalQty]

					, [intTotalAnimalQty]

					, [intDeadAnimalQty]

					, [strNote]

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

					tlbSpeciesActual_v6.[idfSpeciesActual]

					, j_trtSpeciesType_idfsSpeciesType_v7.[idfsSpeciesType]

					, j_tlbHerdActual_idfHerdActual_v7.[idfHerdActual]

					, tlbSpeciesActual_v6.[datStartOfSignsDate]

					, tlbSpeciesActual_v6.[strAverageAge]

					, tlbSpeciesActual_v6.[intSickAnimalQty]

					, tlbSpeciesActual_v6.[intTotalAnimalQty]

					, tlbSpeciesActual_v6.[intDeadAnimalQty]

					, tlbSpeciesActual_v6.[strNote]

					, tlbSpeciesActual_v6.[rowguid]

					, tlbSpeciesActual_v6.[intRowStatus]

					, tlbSpeciesActual_v6.[strMaintenanceFlag]

					, tlbSpeciesActual_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfSpeciesActual":' + isnull(cast(tlbSpeciesActual_v6.[idfSpeciesActual] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbSpeciesActual] tlbSpeciesActual_v6 


					inner join	[Giraffe].[dbo].[trtSpeciesType] j_trtSpeciesType_idfsSpeciesType_v7

		on	


					j_trtSpeciesType_idfsSpeciesType_v7.[idfsSpeciesType] = tlbSpeciesActual_v6.[idfsSpeciesType] 

					left join	[Giraffe].[dbo].[tlbHerdActual] j_tlbHerdActual_idfHerdActual_v7

		on	


					j_tlbHerdActual_idfHerdActual_v7.[idfHerdActual] = tlbSpeciesActual_v6.[idfHerdActual] 
left join	[Giraffe].[dbo].[tlbSpeciesActual] tlbSpeciesActual_v7 
on	

					tlbSpeciesActual_v7.[idfSpeciesActual] = tlbSpeciesActual_v6.[idfSpeciesActual] 
where tlbSpeciesActual_v7.[idfSpeciesActual] is null 
print N'Table [tlbSpeciesActual] - insert: ' + cast(@@rowcount as nvarchar(20))

    
--

/************************************************************
* Update/insert records with links to foreign key data - [tlbHumanActual]
************************************************************/


select	@NumberOfExistingMigratedRecords = count(tlbHumanActual_v6.[idfHumanActual])
from	[Falcon].[dbo].[tlbHumanActual] tlbHumanActual_v6
inner join	[Giraffe].[dbo].[tlbHumanActual] tlbHumanActual_v7
on	tlbHumanActual_v7.[idfHumanActual] = tlbHumanActual_v6.[idfHumanActual]
inner join	[Giraffe].[dbo].[HumanActualAddlInfo] HumanActualAddlInfo_v7
on	HumanActualAddlInfo_v7.[HumanActualAddlInfoUID] = tlbHumanActual_v6.[idfHumanActual]

IF OBJECT_ID('tempdb..#HumanActualAddlInfo') IS NOT NULL
	exec sp_executesql N'drop table #HumanActualAddlInfo'

IF OBJECT_ID('tempdb..#HumanActualAddlInfo') IS NULL
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
						and ltrim(rtrim(tlbHumanActual_v7.strEmployerName)) <> N'' collate Cyrillic_General_CI_AS
					)
					or	(	tlbGeoLocationShared_EmployerAddress_v7.blnForeignAddress = 1 
							or tlbGeoLocationShared_EmployerAddress_v7.idfsRegion is not null
						)
					or	(	tlbHumanActual_v7.strWorkPhone is not null
							and ltrim(rtrim(tlbHumanActual_v7.strWorkPhone)) <> N'' collate Cyrillic_General_CI_AS
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

             

if db_name() like N'%_Archive' collate Cyrillic_General_CI_AS and @IdMigrationPrefix not like N'%ARCH' collate Cyrillic_General_CI_AS
	set	@IdMigrationPrefix = @IdMigrationPrefix + N'ARCH' collate Cyrillic_General_CI_AS
update	temp
set		temp.[EIDSSPersonID] = N'PER' + @IdMigrationPrefix + @YY + dbo.fnAlphaNumeric(@NumberOfExistingMigratedRecords + temp.idfId, @IdGenerateDigitNumber)
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
		, 'system'
		, GETUTCDATE()
		, 'system'
		, GETUTCDATE()
		, 10519002 /*Record Source: EIDSS6.1*/
		, N'[{' + N'"HumanActualAddlInfoUID":' + isnull(cast(temp.[HumanActualAddlInfoUID] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS
from	#HumanActualAddlInfo temp
--left join	[Giraffe].[dbo].[HumanActualAddlInfo] HumanActualAddlInfo_v7
--on	HumanActualAddlInfo_v7.[HumanActualAddlInfoUID] = temp.[HumanActualAddlInfoUID]
--where	HumanActualAddlInfo_v7.[HumanActualAddlInfoUID] is null
print N'Table [HumanActualAddlInfo] - insert new detailed info for persons from the catalog: ' + cast(@@rowcount as nvarchar(20))

IF OBJECT_ID('tempdb..#HumanActualAddlInfo') IS NOT NULL
	exec sp_executesql N'drop table #HumanActualAddlInfo'

/************************************************************
* Update/insert records with links to foreign key data - [tlbFarmActual]
************************************************************/

update		ccfa
set			ccfa.[idfFarmActual_v7] = tlbFarmActual_v7.[idfFarmActual]
from		[Giraffe].[dbo].[_dmccFarmActual] ccfa
inner join	[Giraffe].[dbo].[tlbFarmActual] tlbFarmActual_v7
on			tlbFarmActual_v7.[idfFarmActual] = ccfa.[idfFarmActual_v6]
where		ccfa.[idfFarmActual_v7] is null
       


--

print N''
print N'Insert records - Tables with persons and farms catalogs data - end'
print N''
print N''
/************************************************************
* Insert records - Tables with persons and farms catalogs data - end
************************************************************/






 

/************************************************************
* Create concordance tables for HDR and VDR data - start
************************************************************/


if object_id(N'_dmccHumanCase') is null
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


 --


if object_id(N'_dmccContactedCasePerson') is null
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


--


if object_id(N'_dmccAntimicrobialTherapy') is null
create table _dmccAntimicrobialTherapy
(	idfId bigint not null identity(1, 1) primary key,
	idfHumanCaseId bigint not null,
	idfHumanCase_v6 bigint not null,
	idfAntimicrobialTherapy_v6 bigint null,
	idfHumanCase_v7 bigint not null,
	
	idfAntimicrobialTherapy_v7 bigint null
)


--


if object_id(N'_dmccHuman') is null
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


--


if object_id(N'_dmccGeoLocation') is null
create table _dmccGeoLocation
(	--idfId bigint not null identity(1, 1) primary key,
	idfGeoLocation_v6 bigint not null,
	idfGeoLocation_v7 bigint not null primary key
)


--


if object_id(N'_dmccNewGeoLocation') is null
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


--


if object_id(N'_dmccMaterial') is null
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


--


if object_id(N'_dmccLabTest') is null
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


--


if object_id(N'_dmccTestValidation') is null
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


--


if object_id(N'_dmccObservation') is null
create table _dmccObservation
(	--idfId bigint not null identity(1, 1) primary key,
	idfObservation_v6 bigint not null,
	idfsTemplate_v6 bigint null,
	idfObservation_v7 bigint not null primary key,
	idfsTemplate_v7 bigint null
)


--


if object_id(N'_dmccNewObservation') is null
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


--


if object_id(N'_dmccActivityParameters') is null
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


--


if object_id(N'_dmccHumanCaseFiltered') is null
create table _dmccHumanCaseFiltered
(	idfId bigint not null identity(1, 1) primary key,
	idfHumanCaseId bigint not null,
	idfHumanCase_v6 bigint not null,
	idfHumanCaseFiltered_v6 bigint not null,
	idfSiteGroup_v6 bigint not null,
	idfHumanCase_v7 bigint not null,
	
	idfHumanCaseFiltered_v7 bigint null
)


--

/************************************************************
* Create concordance tables for HDR and VDR data - end
************************************************************/


--


/************************************************************
* Reset identifier seed value - start
************************************************************/

--declare	@sqlIdResetCmd				nvarchar(max)
set	@sqlIdResetCmd = N''

set	@sqlIdResetCmd = N'

declare @TempIdentifierSeedValue bigint = ' + cast((@TempIdentifierSeedValue - case when db_name() like N'%_Archive' collate Cyrillic_General_CI_AS then 1 else 0 end) as nvarchar(20)) + N'

declare	@max_value			bigint
set	@max_value = @TempIdentifierSeedValue

declare	@seed_value			bigint
set	@seed_value = null
declare	@increment_value	bigint
set	@increment_value = null

declare	@sqlCmd				nvarchar(max)
set	@sqlCmd = N''''

' collate Cyrillic_General_CI_AS

select	@sqlIdResetCmd = @sqlIdResetCmd + N'
	-- dbo.' + t.[name] + N': ' + c_ic.[name] + N'
	if	exists	(
			select	1 
			from	[Falcon].[sys].[tables] t
			inner join	[Falcon].sys.objects o_t
			on			o_t.[object_id] = t.[object_id]
						and o_t.[type] = N''U'' collate Cyrillic_General_CI_AS
			inner join	[Falcon].sys.schemas s
			on			s.[schema_id] = t.[schema_id]
						and s.[name] = N''dbo'' collate Cyrillic_General_CI_AS			
			where		t.[name] = N''' + t.[name] + N''' collate Cyrillic_General_CI_AS
				)
	begin
		if	exists	(
				select	1
				from	[Falcon].[dbo].[' + t.[name] + N']
				where	[' + c_ic.[name] + N'] >= @max_value
						and ([' + c_ic.[name] + '] - @TempIdentifierSeedValue) % 10000000 = 0
					)
		begin
			select		@max_value = max(' + c_ic.[name] + N') + 10000000
			from		[Falcon].[dbo].[' + t.[name] + N']
			where		([' + c_ic.[name] + '] - @TempIdentifierSeedValue) % 10000000 = 0
		end
	end
'
from
-- Table
			[Falcon].sys.tables t
inner join	[Falcon].sys.objects o_t
on			o_t.[object_id] = t.[object_id]
			and o_t.[type] = N'U' collate Cyrillic_General_CI_AS
			and o_t.[name] not like N'gis%' collate Cyrillic_General_CI_AS
			and o_t.[name] not like N'tfl%' collate Cyrillic_General_CI_AS
			and o_t.[name] not like N'Lkup%' collate Cyrillic_General_CI_AS

inner join	[Falcon].sys.schemas s
on			s.[schema_id] = t.[schema_id]
			and s.[name] = N'dbo' collate Cyrillic_General_CI_AS

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
			and c_ic.[name] <> N'idfsLanguage'
			and c_ic.[system_type_id] in (127, 56)
where		not exists	(
					select	1
					from		[Falcon].sys.index_columns ic_second
					inner join	[Falcon].sys.columns c_ic_second
					on			c_ic_second.[object_id] = ic_second.[object_id]
								and c_ic_second.[column_id] = ic_second.[column_id]
								and c_ic_second.[name] <> N'idfsLanguage'
								and c_ic_second.[system_type_id]  in (127, 56)
								and	c_ic_second.[column_id] <> c_ic.[column_id]
					where		ic_second.[object_id] = i.[object_id]
								and ic_second.[index_id] = i.[index_id]
						)



--

set	@sqlIdResetCmd = @sqlIdResetCmd + N'
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
where		NewIDtable.[id] = object_id(N''[dbo].[tstNewID]'') 
			and OBJECTPROPERTY(NewIDtable.[id], N''IsUserTable'') = 1
			and NewIDcol.[name] = N''NewID''

if	(@seed_value is null) or (@increment_value is null)
	or (@seed_value is not null and (@seed_value < @max_value) and ((isnull(@seed_value, 0) - @max_value) % 10000000 = 0))
	or (@seed_value is not null and ((isnull(@seed_value, 0) - @max_value) % 10000000 <> 0))
--			or (@increment_value <> 10000000)
begin
	set @sqlCmd = N''
if	exists	(
select	1 
from	[Giraffe].[dbo].sysobjects 
where	id = object_id(N''''[dbo].[tstNewID]'''') 
		and OBJECTPROPERTY(id, N''''IsUserTable'''') = 1
	)
drop table [dbo].[tstNewID]

''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''
create table	[dbo].[tstNewID]
(	NewID		bigint IDENTITY('' + cast(@max_value as nvarchar(20)) + N'', 10000000) not null,
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
''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''
ALTER TABLE [dbo].[tstNewID] ADD  CONSTRAINT [DF_tstNewID_rowguid]  DEFAULT (newsequentialid()) FOR [rowguid]
''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''
ALTER TABLE [dbo].[tstNewID] ADD  CONSTRAINT [DF_tstNewID_CreateDTM]  DEFAULT (getdate()) FOR [AuditCreateDTM]
''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''
ALTER TABLE [dbo].[tstNewID]  WITH CHECK ADD  CONSTRAINT [FK_tstNewID_trtBaseReference_SourceSystemNameID] FOREIGN KEY([SourceSystemNameID])
REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''
ALTER TABLE [dbo].[tstNewID] CHECK CONSTRAINT [FK_tstNewID_trtBaseReference_SourceSystemNameID]
''
	execute sp_executesql @sqlCmd

	print	''New consequent ID value in the table tstNewID: '' + cast(@max_value as varchar(30))
end
else 
	print ''Update of consequent ID value in the table tstNewID is not needed: '' + cast(@seed_value as varchar(30))
'
exec [Giraffe].[sys].sp_executesql @sqlIdResetCmd


--



set	@sqlIdResetCmd = N'

declare @TempIdentifierSeedValue bigint = ' + cast((@TempIdentifierSeedValue - case when db_name() like N'%_Archive' collate Cyrillic_General_CI_AS then 1 else 0 end) as nvarchar(20)) + N'

declare	@max_value			bigint
set	@max_value = @TempIdentifierSeedValue

declare	@seed_value			bigint
set	@seed_value = null
declare	@increment_value	bigint
set	@increment_value = null

declare	@sqlCmd				nvarchar(max)
set	@sqlCmd = N''''


' collate Cyrillic_General_CI_AS


select	@sqlIdResetCmd = @sqlIdResetCmd + N'
	-- dbo.' + t.[name] + N': ' + c_ic.[name] + N'
	if	exists	(
			select	1 
			from	[Falcon].[sys].[tables] t
			inner join	[Falcon].sys.objects o_t
			on			o_t.[object_id] = t.[object_id]
						and o_t.[type] = N''U'' collate Cyrillic_General_CI_AS
			inner join	[Falcon].sys.schemas s
			on			s.[schema_id] = t.[schema_id]
						and s.[name] = N''dbo'' collate Cyrillic_General_CI_AS			
			where		t.[name] = N''' + t.[name] + N''' collate Cyrillic_General_CI_AS
				)
	begin
		if	exists	(
				select	1
				from	[Falcon].[dbo].[' + t.[name] + N']
				where	[' + c_ic.[name] + N'] >= @max_value
						and ([' + c_ic.[name] + '] - @TempIdentifierSeedValue) % 10000000 = 0
					)
		begin
			select		@max_value = max(' + c_ic.[name] + N') + 10000000
			from		[Falcon].[dbo].[' + t.[name] + N']
			where		([' + c_ic.[name] + '] - @TempIdentifierSeedValue) % 10000000 = 0
		end
	end
'
from
-- Table
			[Falcon].sys.tables t
inner join	[Falcon].sys.objects o_t
on			o_t.[object_id] = t.[object_id]
			and o_t.[type] = N'U' collate Cyrillic_General_CI_AS
			and o_t.[name] like N'tfl%' collate Cyrillic_General_CI_AS

inner join	[Falcon].sys.schemas s
on			s.[schema_id] = t.[schema_id]
			and s.[name] = N'dbo' collate Cyrillic_General_CI_AS

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
			and c_ic.[name] <> N'idfsSite'
			and c_ic.[system_type_id] in (127, 56)
where		not exists	(
					select	1
					from		[Falcon].sys.index_columns ic_second
					inner join	[Falcon].sys.columns c_ic_second
					on			c_ic_second.[object_id] = ic_second.[object_id]
								and c_ic_second.[column_id] = ic_second.[column_id]
								and c_ic_second.[name] <> N'idfsLanguage'
								and c_ic_second.[system_type_id]  in (127, 56)
								and	c_ic_second.[column_id] <> c_ic.[column_id]
					where		ic_second.[object_id] = i.[object_id]
								and ic_second.[index_id] = i.[index_id]
						)



--

set	@sqlIdResetCmd = @sqlIdResetCmd + N'
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
where		NewIDtable.[id] = object_id(N''[dbo].[tflNewID]'') 
			and OBJECTPROPERTY(NewIDtable.[id], N''IsUserTable'') = 1
			and NewIDcol.[name] = N''NewID''

if	(@seed_value is null) or (@increment_value is null)
	or (@seed_value is not null and (@seed_value < @max_value) and ((isnull(@seed_value, 0) - @max_value) % 10000000 = 0))
	or (@seed_value is not null and ((isnull(@seed_value, 0) - @max_value) % 10000000 <> 0))
--			or (@increment_value <> 10000000)
begin
	set @sqlCmd = N''
if	exists	(
select	1 
from	[Giraffe].[dbo].sysobjects 
where	id = object_id(N''''[dbo].[tflNewID]'''') 
		and OBJECTPROPERTY(id, N''''IsUserTable'''') = 1
	)
drop table [dbo].[tflNewID]

''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''
create table	[dbo].[tflNewID]
(	NewID			bigint IDENTITY('' + cast(@max_value as nvarchar(20)) + N'', 10000000) not null,
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
''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''
ALTER TABLE [dbo].[tflNewID] ADD  CONSTRAINT [DF_tflNewID_rowguid]  DEFAULT (newsequentialid()) FOR [rowguid]
''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''
ALTER TABLE [dbo].[tflNewID] ADD  CONSTRAINT [DEF_tflNewID_SourceSystemNameID]  DEFAULT ((10519001)) FOR [SourceSystemNameID]
''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''
ALTER TABLE [dbo].[tflNewID] ADD  CONSTRAINT [DF_tflNewID_CreateDTM]  DEFAULT (getdate()) FOR [AuditCreateDTM]
''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''
ALTER TABLE [dbo].[tflNewID]  WITH CHECK ADD  CONSTRAINT [FK_tflNewID_trtBaseReference_SourceSystemNameID] FOREIGN KEY([SourceSystemNameID])
REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''
ALTER TABLE [dbo].[tflNewID] CHECK CONSTRAINT [FK_tflNewID_trtBaseReference_SourceSystemNameID]
''
	execute sp_executesql @sqlCmd

	print	''New consequent ID value in the table tflNewID: '' + cast(@max_value as varchar(30))
end
else 
	print ''Update of consequent ID value in the table tflNewID is not needed: '' + cast(@seed_value as varchar(30))
'
exec [Giraffe].[sys].sp_executesql @sqlIdResetCmd

/************************************************************
* Reset identifier seed value - end
************************************************************/


 --




/************************************************************
* Fill in concordance tables for HDR and VDR data - start
************************************************************/

print N'Identify HDRs v7 based on Human Cases from v6.1'
print N''
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
print N'Not migrated Human Cases v6.1: ' + cast(@@rowcount as nvarchar(20))


--TODO: Update attributes of previously migrated human cases in the concordance table for further updates of HDR if needed 

print N''
print N''


--


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


--

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

--


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


if db_name() like N'%_Archive' collate Cyrillic_General_CI_AS and @IdMigrationPrefix not like N'%ARCH' collate Cyrillic_General_CI_AS
	set	@IdMigrationPrefix = @IdMigrationPrefix + N'ARCH' collate Cyrillic_General_CI_AS
update	cchc
set		cchc.[strCaseID_v7] = N'HUM' + @IdMigrationPrefix + @YY + dbo.fnAlphaNumeric(@NumberOfExistingMigratedRecords + cchc.[idfSeqNumber], @IdGenerateDigitNumber)
from	[Giraffe].[dbo]._dmccHumanCase cchc
where	cchc.[strCaseID_v7] is null or cchc.[strCaseID_v7] = N'' collate Cyrillic_General_CI_AS
		and cchc.[idfSeqNumber] >= 0

update		cchc
set			cchc.[idfDeduplicationResultCase_v7] = cchc_dedup_res.[idfHumanCase_v7]
from		[Giraffe].[dbo]._dmccHumanCase cchc
inner join	[Giraffe].[dbo]._dmccHumanCase cchc_dedup_res
on			cchc_dedup_res.[idfHumanCase_v6] = cchc.[idfDeduplicationResultCase_v6]
			and cchc_dedup_res.[idfHumanCase_v7] is not null
where		cchc.[idfDeduplicationResultCase_v6] is not null



 --


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

exec [Giraffe].sys.sp_executesql N'ALTER INDEX ALL ON dbo.tstNewID REBUILD'


--


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



--

print N'Determine copies of Contact records in HDRs v7 based on Conact records of Human Cases from v6.1'
print N''

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
print N'Copies of Contact records for HRDs v7 from Contact records of Human Cases v6.1: ' + cast(@@rowcount as nvarchar(20))
print N''
print N''



--


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

exec [Giraffe].sys.sp_executesql N'ALTER INDEX ALL ON dbo.tstNewID REBUILD'

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



--

print N'Determine copies of Antibiotics in HDRs v7 based on Antibiotics of Human Cases from v6.1'
print N''

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
print N'Copies of Antibiotics for HRDs v7 from Antibiotics of Human Cases v6.1: ' + cast(@@rowcount as nvarchar(20))
print N''
print N''


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

exec [Giraffe].sys.sp_executesql N'ALTER INDEX ALL ON dbo.tstNewID REBUILD'

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



 --

print N'Determine copies of Patients and Contact Persons in HDRs v7 based on Patients and Contact Persons of Human Cases from v6.1'
print N''

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
							and ltrim(rtrim(tlbHuman_v6.strEmployerName)) <> N'' collate Cyrillic_General_CI_AS
						)
						or	(	tlbGeoLocation_EmployerAddress_v6.blnForeignAddress = 1 
								or tlbGeoLocation_EmployerAddress_v6.idfsRegion is not null
							)
						or	(	tlbHuman_v6.strWorkPhone is not null
								and ltrim(rtrim(tlbHuman_v6.strWorkPhone)) <> N'' collate Cyrillic_General_CI_AS
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
print N'Copies of Patients of HRDs v7 from Patients of Human Cases v6.1: ' + cast(@@rowcount as nvarchar(20))



--

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
							and ltrim(rtrim(tlbHuman_v6.strEmployerName)) <> N'' collate Cyrillic_General_CI_AS
						)
						or	(	tlbGeoLocation_EmployerAddress_v6.blnForeignAddress = 1 
								or tlbGeoLocation_EmployerAddress_v6.idfsRegion is not null
							)
						or	(	tlbHuman_v6.strWorkPhone is not null
								and ltrim(rtrim(tlbHuman_v6.strWorkPhone)) <> N'' collate Cyrillic_General_CI_AS
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
print N'Copies of Contact Persons of HRDs v7 from Contact Persons of Human Cases v6.1: ' + cast(@@rowcount as nvarchar(20))
print N''



 --

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
							and ltrim(rtrim(tlbHuman_v6.strEmployerName)) <> N'' collate Cyrillic_General_CI_AS
						)
						or	(	tlbGeoLocation_EmployerAddress_v6.blnForeignAddress = 1 
								or tlbGeoLocation_EmployerAddress_v6.idfsRegion is not null
							)
						or	(	tlbHuman_v6.strWorkPhone is not null
								and ltrim(rtrim(tlbHuman_v6.strWorkPhone)) <> N'' collate Cyrillic_General_CI_AS
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
print N'Farm Owners v7 from Farm Owners v6.1: ' + cast(@@rowcount as nvarchar(20))
print N''



--

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
							and ltrim(rtrim(tlbHuman_v6.strEmployerName)) <> N'' collate Cyrillic_General_CI_AS
						)
						or	(	tlbGeoLocation_EmployerAddress_v6.blnForeignAddress = 1 
								or tlbGeoLocation_EmployerAddress_v6.idfsRegion is not null
							)
						or	(	tlbHuman_v6.strWorkPhone is not null
								and ltrim(rtrim(tlbHuman_v6.strWorkPhone)) <> N'' collate Cyrillic_General_CI_AS
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
print N'Basic Syndromic Surveillance Patients v7 from Basic Syndromic Surveillance Patients v6.1: ' + cast(@@rowcount as nvarchar(20))
print N''
print N''



 --

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



--


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


exec [Giraffe].sys.sp_executesql N'ALTER INDEX ALL ON dbo.tstNewID REBUILD'

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




--


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



--

print N'Determine copies of Samples for HDRs v7 based on Samples of Human Cases from v6.1'
print N''

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
print N'Copies of Samples of HRDs v7 from Samples of Human Cases v6.1: ' + cast(@@rowcount as nvarchar(20))
print N''
print N''



 --


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

exec [Giraffe].sys.sp_executesql N'ALTER INDEX ALL ON dbo.tstNewID REBUILD'

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



--

print N'Determine copies of Lab Tests in HDRs v7 based on Lab Tests of Human Cases from v6.1'
print N''

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
print N'Copies of Lab Tests for HRDs v7 from Lab Tests of Human Cases v6.1: ' + cast(@@rowcount as nvarchar(20))
print N''
print N''


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

exec [Giraffe].sys.sp_executesql N'ALTER INDEX ALL ON dbo.tstNewID REBUILD'

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



--

print N'Determine copies of Test Interpretation records in HDRs v7 based on Test Interpretation records of Human Cases from v6.1'
print N''

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
print N'Copies of Test Interpretation records for HRDs v7 from Test Interpretation records of Human Cases v6.1: ' + cast(@@rowcount as nvarchar(20))
print N''
print N''


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

exec [Giraffe].sys.sp_executesql N'ALTER INDEX ALL ON dbo.tstNewID REBUILD'

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



--

print N'Determine copies of HDR Filtration Records in HDRs v7 based on Human Case Filtration Records of Human Cases from v6.1'
print N''

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
print N'Copies of Filtration Records for HRDs v7 from Filtration Records of Human Cases v6.1: ' + cast(@@rowcount as nvarchar(20))
print N''
print N''


/************************************************************
* Generate Id records - _dmccHumanCaseFiltered - start
************************************************************/
declare @tflHCFTempIdentifierKey nvarchar(128)
set @tflHCFTempIdentifierKey = N'tflHumanCaseFiltered' + @TempIdentifierKey collate Cyrillic_General_CI_AS
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

exec [Giraffe].sys.sp_executesql N'ALTER INDEX ALL ON dbo.tflNewID REBUILD'

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



--

print N'Determine copies of Addresses/Locations of HDRs v7, their Patients and/or Contact Persons based on Addresses/Locations of Human Cases, their Patients and Contact Persons from v6.1'
print N''

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
print N'Copies of Location of Exposure of HRDs v7 from Location of Exposure of Human Cases v6.1: ' + cast(@@rowcount as nvarchar(20))
print N''

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
print N'Copies of Persons Current Residence Addresses v7 from Persons Current Residence Addresses v6.1: ' + cast(@@rowcount as nvarchar(20))

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
print N'Copies of Persons Permanent Residence Addresses v7 from Persons Permanent Residence Addresses v6.1: ' + cast(@@rowcount as nvarchar(20))

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
print N'Copies of Persons Employer Addresses v7 from Persons Employer Addresses v6.1: ' + cast(@@rowcount as nvarchar(20))
print N''
print N''



--

print N'Determine new Addresses/Locations v7 that were missing in v6.1'
print N''

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
			, N'[{' + N'"idfGeoLocation":' + isnull(cast(cchc.[idfPointGeoLocation_v7] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS
			, N'system'
			, GETUTCDATE()
			, N'system'
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
print N'New locations of exposure of HDRs v7 missing in matching Human Cases from v6.1: ' + cast(@@rowcount as nvarchar(20))
print N''


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
			, N'[{' + N'"idfGeoLocation":' + isnull(cast(cch.[idfHumanCRAddress_v7] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS
			, N'system'
			, GETUTCDATE()
			, N'system'
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
print N'New current residence addresses of persons in v7 missing in matching persons from v6.1: ' + cast(@@rowcount as nvarchar(20))


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
			, N'[{' + N'"idfGeoLocation":' + isnull(cast(cch.[idfHumanPRAddress_v7] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS
			, N'system'
			, GETUTCDATE()
			, N'system'
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
print N'New permanent residence addresses of persons in v7 missing in matching persons from v6.1: ' + cast(@@rowcount as nvarchar(20))


 --



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
			, N'[{' + N'"idfGeoLocation":' + isnull(cast(cch.[idfHumanEmpAddress_v7] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS
			, N'system'
			, GETUTCDATE()
			, N'system'
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
print N'New employer addresses of persons in v7 missing in matching persons from v6.1: ' + cast(@@rowcount as nvarchar(20))


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
			, N'[{' + N'"idfGeoLocation":' + isnull(cast(cch.[idfHumanAltAddress_v7] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS
			, N'system'
			, GETUTCDATE()
			, N'system'
			, GETUTCDATE()
			, @idfsCountry
from		[Giraffe].[dbo].[_dmccHuman] cch
left join	[Giraffe].[dbo].[_dmccNewGeoLocation] ccngl
on			ccngl.[idfGeoLocation_v7] = cch.[idfHumanAltAddress_v7]
where		cch.[idfHumanAltAddress_v7] is not null
			and ccngl.[idfGeoLocation_v7] is null
print N'New alternative addresses of persons in v7 missing in matching persons from v6.1: ' + cast(@@rowcount as nvarchar(20))


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
			, N'[{' + N'"idfGeoLocation":' + isnull(cast(cch.[idfHumanSchAddress_v7] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS
			, N'system'
			, GETUTCDATE()
			, N'system'
			, GETUTCDATE()
			, @idfsCountry
from		[Giraffe].[dbo].[_dmccHuman] cch
left join	[Giraffe].[dbo].[_dmccNewGeoLocation] ccngl
on			ccngl.[idfGeoLocation_v7] = cch.[idfHumanSchAddress_v7]
where		cch.[idfHumanSchAddress_v7] is not null
			and ccngl.[idfGeoLocation_v7] is null
print N'New school addresses of persons in v7 missing in matching persons from v6.1: ' + cast(@@rowcount as nvarchar(20))
print N''
print N''


delete		ccgl
from		[Giraffe].[dbo].[_dmccGeoLocation] ccgl
left join	[Falcon].[dbo].[tlbGeoLocation] tlbGeoLocation_v6
on			tlbGeoLocation_v6.[idfGeoLocation] = ccgl.[idfGeoLocation_v6]
where		tlbGeoLocation_v6.[idfGeoLocation] is null



--

print N'Determine copies of FF Instances of HDRs v7 (CS, EPI) and their Lab Tests based on FF Instances of Human Cases and their Lab Tests from v6.1'
print N''

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
print N'Copies of CS FF Instances of HRDs v7 from CS FF Instances of Human Cases v6.1: ' + cast(@@rowcount as nvarchar(20))

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
print N'Copies of EPI FF Instances of HRDs v7 from CS EPI Instances of Human Cases v6.1: ' + cast(@@rowcount as nvarchar(20))
print N''

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
print N'Copies of FF Instances of Lab Tests v7 from FF Instances of Lab Tests v7 v6.1: ' + cast(@@rowcount as nvarchar(20))
print N''
print N''



 --

print N'Determine new FF Instances v7 that were missing in v6.1'
print N''

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
			, N'[{' + N'"idfObservation":' + isnull(cast(cchc.[idfCSObservation_v7] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS
			, N'system'
			, GETUTCDATE()
			, N'system'
			, GETUTCDATE()
from		[Giraffe].[dbo].[_dmccHumanCase] cchc
left join	[Falcon].[dbo].[tlbObservation] tlbObservation_v6
on			tlbObservation_v6.[idfObservation] = cchc.[idfCSObservation_v6]
left join	[Giraffe].[dbo].[_dmccNewObservation] ccnobs
on			ccnobs.[idfObservation_v7] = cchc.[idfCSObservation_v7]
where		cchc.[idfCSObservation_v7] is not null
			and tlbObservation_v6.[idfObservation] is null 
			and ccnobs.[idfObservation_v7] is null
print N'New CS FF Template Instances of HDRs v7 missing in matching Human Cases from v6.1: ' + cast(@@rowcount as nvarchar(20))

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
			, N'[{' + N'"idfObservation":' + isnull(cast(cchc.[idfCSObservation_v7] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS
			, N'system'
			, GETUTCDATE()
			, N'system'
			, GETUTCDATE()
from		[Giraffe].[dbo].[_dmccHumanCase] cchc
left join	[Falcon].[dbo].[tlbObservation] tlbObservation_v6
on			tlbObservation_v6.[idfObservation] = cchc.[idfEpiObservation_v6]
left join	[Giraffe].[dbo].[_dmccNewObservation] ccnobs
on			ccnobs.[idfObservation_v7] = cchc.[idfEpiObservation_v7]
where		cchc.[idfEpiObservation_v7] is not null
			and tlbObservation_v6.[idfObservation] is null 
			and ccnobs.[idfObservation_v7] is null
print N'New EPI FF Template Instances of HDRs v7 missing in matching Human Cases from v6.1: ' + cast(@@rowcount as nvarchar(20))
print N''

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
			, N'[{' + N'"idfObservation":' + isnull(cast(cct.[idfObservation_v7] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS
			, N'system'
			, GETUTCDATE()
			, N'system'
			, GETUTCDATE()
from		[Giraffe].[dbo].[_dmccLabTest] cct
left join	[Falcon].[dbo].[tlbObservation] tlbObservation_v6
on			tlbObservation_v6.[idfObservation] = cct.[idfObservation_v6]
left join	[Giraffe].[dbo].[_dmccNewObservation] ccnobs
on			ccnobs.[idfObservation_v7] = cct.[idfObservation_v7]
where		cct.[idfObservation_v7] is not null
			and tlbObservation_v6.[idfObservation] is null 
			and ccnobs.[idfObservation_v7] is null
print N'New FF Template Instances of Lab Tests v7 missing in matching Lab Tests from v6.1: ' + cast(@@rowcount as nvarchar(20))
print N''
print N''


delete		ccobs
from		[Giraffe].[dbo].[_dmccObservation] ccobs
left join	[Falcon].[dbo].[tlbObservation] tlbObservation_v6
on			tlbObservation_v6.[idfObservation] = ccobs.[idfObservation_v6]
where		tlbObservation_v6.[idfObservation] is null



--

print N'Determine copies of FF Values of HDRs v7 and their Lab Tests v7 based on FF Values of Human Cases and their Lab Tests from v6.1'
print N''

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
print N'Copies of FF Values of HDRs v7 and their Lab Tests v7 from FF Values of Human Cases and their Lab Tests v6.1: ' + cast(@@rowcount as nvarchar(20))
print N''
print N''


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

exec [Giraffe].sys.sp_executesql N'ALTER INDEX ALL ON dbo.tstNewID REBUILD'

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



 --


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


--

/************************************************************
* Insert records - Tables with records related to data modules - start
************************************************************/
print N''
print N'Insert records - Tables with records related to data modules - start'
print N''

   
--

/************************************************************
* Prepare data before insert - [tlbObservation]
************************************************************/

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
print N'Table [tlbObservation] - insert new FF instances that were missing in v6.1: ' + cast(@@rowcount as nvarchar(20))

    
  
  
  
  

/************************************************************
* Prepare data before insert - [tlbGeoLocation]
************************************************************/

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
print N'Table [tlbGeoLocation] - insert new Addresses/Locations that were missing in v6.1: ' + cast(@@rowcount as nvarchar(20))

 
  
  
  
  


--

/************************************************************
* Insert records - [tlbObservation]
************************************************************/
insert into [Giraffe].[dbo].[tlbObservation] 

(

					[idfObservation]

					, [idfsFormTemplate]

					, [intRowStatus]

					, [rowguid]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [idfsSite]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					isnull(ccobs.idfObservation_v7, tlbObservation_v6.[idfObservation])

					, j_ffFormTemplate_idfsFormTemplate_v7.[idfsFormTemplate]

					, tlbObservation_v6.[intRowStatus]

					, tlbObservation_v6.[rowguid]

					, tlbObservation_v6.[strMaintenanceFlag]

					, tlbObservation_v6.[strReservedAttribute]

					, j_tstSite_idfsSite_v7.[idfsSite]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfObservation":' + isnull(cast(isnull(ccobs.idfObservation_v7, tlbObservation_v6.[idfObservation]) as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbObservation] tlbObservation_v6
left join	[Giraffe].[dbo].[_dmccObservation] ccobs
on			ccobs.idfObservation_v6 = tlbObservation_v6.[idfObservation] 


					inner join	[Giraffe].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tlbObservation_v6.[idfsSite] 

					left join	[Giraffe].[dbo].[ffFormTemplate] j_ffFormTemplate_idfsFormTemplate_v7

		on	


					j_ffFormTemplate_idfsFormTemplate_v7.[idfsFormTemplate] = isnull(ccobs.idfsTemplate_v7, tlbObservation_v6.[idfsFormTemplate]) 
left join	[Giraffe].[dbo].[tlbObservation] tlbObservation_v7 
on	

					tlbObservation_v7.[idfObservation] = isnull(ccobs.idfObservation_v7, tlbObservation_v6.[idfObservation]) 
where tlbObservation_v7.[idfObservation] is null 
print N'Table [tlbObservation] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbActivityParameters]
************************************************************/
insert into [Giraffe].[dbo].[tlbActivityParameters] 

(

					[idfActivityParameters]

					, [idfsParameter]

					, [idfObservation]

					, [idfRow]

					, [varValue]

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

					isnull(ccap.idfActivityParameters_v7, tlbActivityParameters_v6.[idfActivityParameters])

					, j_ffParameter_idfsParameter_v7.[idfsParameter]

					, j_tlbObservation_idfObservation_v7.[idfObservation]

					, tlbActivityParameters_v6.[idfRow]

					, tlbActivityParameters_v6.[varValue]

					, tlbActivityParameters_v6.[intRowStatus]

					, tlbActivityParameters_v6.[rowguid]

					, tlbActivityParameters_v6.[strMaintenanceFlag]

					, tlbActivityParameters_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfActivityParameters":' + isnull(cast(isnull(ccap.idfActivityParameters_v7, tlbActivityParameters_v6.[idfActivityParameters]) as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbActivityParameters] tlbActivityParameters_v6
left join	[Giraffe].[dbo].[_dmccActivityParameters] ccap
on			ccap.idfActivityParameters_v6 = tlbActivityParameters_v6.[idfActivityParameters] 


					inner join	[Giraffe].[dbo].[ffParameter] j_ffParameter_idfsParameter_v7

		on	


					j_ffParameter_idfsParameter_v7.[idfsParameter] = tlbActivityParameters_v6.[idfsParameter] 

					inner join	[Giraffe].[dbo].[tlbObservation] j_tlbObservation_idfObservation_v7

		on	


					j_tlbObservation_idfObservation_v7.[idfObservation] = isnull(ccap.idfObservation_v7, tlbActivityParameters_v6.[idfObservation]) 
left join	[Giraffe].[dbo].[tlbActivityParameters] tlbActivityParameters_v7 
on	

					tlbActivityParameters_v7.[idfActivityParameters] = isnull(ccap.idfActivityParameters_v7, tlbActivityParameters_v6.[idfActivityParameters]) 
where tlbActivityParameters_v7.[idfActivityParameters] is null 
print N'Table [tlbActivityParameters] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbGeoLocation]
************************************************************/
insert into [Giraffe].[dbo].[tlbGeoLocation] 

(

					[idfGeoLocation]

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

					, [datModificationForArchiveDate]

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

					isnull(ccgl.idfGeoLocation_v7, tlbGeoLocation_v6.[idfGeoLocation])

					, j_trtBaseReference_idfsResidentType_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsGroundType_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsGeoLocationType_v7.[idfsBaseReference]

					, j_gisCountry_idfsCountry_v7.[idfsCountry]

					, j_gisRegion_idfsRegion_v7.[idfsRegion]

					, j_gisRayon_idfsRayon_v7.[idfsRayon]

					, j_gisSettlement_idfsSettlement_v7.[idfsSettlement]

					, j_tstSite_idfsSite_v7.[idfsSite]

					, tlbGeoLocation_v6.[strPostCode]

					, tlbGeoLocation_v6.[strStreetName]

					, tlbGeoLocation_v6.[strHouse]

					, tlbGeoLocation_v6.[strBuilding]

					, tlbGeoLocation_v6.[strApartment]

					, tlbGeoLocation_v6.[strDescription]

					, tlbGeoLocation_v6.[dblDistance]

					, tlbGeoLocation_v6.[dblLatitude]

					, tlbGeoLocation_v6.[dblLongitude]

					, tlbGeoLocation_v6.[dblAccuracy]

					, tlbGeoLocation_v6.[dblAlignment]

					, tlbGeoLocation_v6.[intRowStatus]

					, tlbGeoLocation_v6.[rowguid]

					, tlbGeoLocation_v6.[blnForeignAddress]

					, tlbGeoLocation_v6.[strForeignAddress]

					, tlbGeoLocation_v6.[strAddressString]

					, tlbGeoLocation_v6.[strShortAddressString]

					, tlbGeoLocation_v6.[datModificationForArchiveDate]

					, tlbGeoLocation_v6.[strMaintenanceFlag]

					, tlbGeoLocation_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfGeoLocation":' + isnull(cast(isnull(ccgl.idfGeoLocation_v7, tlbGeoLocation_v6.[idfGeoLocation]) as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()

					, null /*TODO: Check the rule for the new field in EIDSSv7: dblElevation*/

					, coalesce(j_gisSettlement_idfsSettlement_v7.[idfsSettlement], j_gisRayon_idfsRayon_v7.[idfsRayon], j_gisRegion_idfsRegion_v7.[idfsRegion], j_gisCountry_idfsCountry_v7.[idfsCountry]) /*Rule for the new field in EIDSSv7: idfsLocation*/
from [Falcon].[dbo].[tlbGeoLocation] tlbGeoLocation_v6
left join	[Giraffe].[dbo].[_dmccGeoLocation] ccgl
on			ccgl.idfGeoLocation_v6 = tlbGeoLocation_v6.[idfGeoLocation] 


					inner join	[Giraffe].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tlbGeoLocation_v6.[idfsSite] 

					left join	[Giraffe].[dbo].[gisCountry] j_gisCountry_idfsCountry_v7

		on	


					j_gisCountry_idfsCountry_v7.[idfsCountry] = tlbGeoLocation_v6.[idfsCountry] 

					left join	[Giraffe].[dbo].[gisRayon] j_gisRayon_idfsRayon_v7

		on	


					j_gisRayon_idfsRayon_v7.[idfsRayon] = tlbGeoLocation_v6.[idfsRayon] 

					left join	[Giraffe].[dbo].[gisRegion] j_gisRegion_idfsRegion_v7

		on	


					j_gisRegion_idfsRegion_v7.[idfsRegion] = tlbGeoLocation_v6.[idfsRegion] 

					left join	[Giraffe].[dbo].[gisSettlement] j_gisSettlement_idfsSettlement_v7

		on	


					j_gisSettlement_idfsSettlement_v7.[idfsSettlement] = tlbGeoLocation_v6.[idfsSettlement] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsResidentType_v7

		on	


					j_trtBaseReference_idfsResidentType_v7.[idfsBaseReference] = tlbGeoLocation_v6.[idfsResidentType] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsGroundType_v7

		on	


					j_trtBaseReference_idfsGroundType_v7.[idfsBaseReference] = tlbGeoLocation_v6.[idfsGroundType] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsGeoLocationType_v7

		on	


					j_trtBaseReference_idfsGeoLocationType_v7.[idfsBaseReference] = tlbGeoLocation_v6.[idfsGeoLocationType] 
left join	[Giraffe].[dbo].[tlbGeoLocation] tlbGeoLocation_v7 
on	

					tlbGeoLocation_v7.[idfGeoLocation] = isnull(ccgl.idfGeoLocation_v7, tlbGeoLocation_v6.[idfGeoLocation]) 
where tlbGeoLocation_v7.[idfGeoLocation] is null 
print N'Table [tlbGeoLocation] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbHuman]
************************************************************/
insert into [Giraffe].[dbo].[tlbHuman] 

(

					[idfHuman]

					, [idfHumanActual]

					, [idfsOccupationType]

					, [idfsNationality]

					, [idfsHumanGender]

					, [idfCurrentResidenceAddress]

					, [idfEmployerAddress]

					, [idfRegistrationAddress]

					, [datDateofBirth]

					, [datDateOfDeath]

					, [strLastName]

					, [strSecondName]

					, [strFirstName]

					, [strRegistrationPhone]

					, [strEmployerName]

					, [strHomePhone]

					, [strWorkPhone]

					, [rowguid]

					, [intRowStatus]

					, [idfsPersonIDType]

					, [strPersonID]

					, [blnPermantentAddressAsCurrent]

					, [datEnteredDate]

					, [datModificationDate]

					, [datModificationForArchiveDate]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [idfsSite]

					, [idfMonitoringSession]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					cch.idfHuman_v7

					, j_tlbHumanActual_idfHumanActual_v7.[idfHumanActual]

					, j_trtBaseReference_idfsOccupationType_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsNationality_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsHumanGender_v7.[idfsBaseReference]

					, j_tlbGeoLocation_idfCurrentResidenceAddress_v7.[idfGeoLocation]

					, j_tlbGeoLocation_idfEmployerAddress_v7.[idfGeoLocation]

					, j_tlbGeoLocation_idfRegistrationAddress_v7.[idfGeoLocation]

					, tlbHuman_v6.[datDateofBirth]

					, tlbHuman_v6.[datDateOfDeath]

					, tlbHuman_v6.[strLastName]

					, tlbHuman_v6.[strSecondName]

					, tlbHuman_v6.[strFirstName]

					, tlbHuman_v6.[strRegistrationPhone]

					, tlbHuman_v6.[strEmployerName]

					, tlbHuman_v6.[strHomePhone]

					, tlbHuman_v6.[strWorkPhone]

					, tlbHuman_v6.[rowguid]

					, tlbHuman_v6.[intRowStatus]

					, j_trtBaseReference_idfsPersonIDType_v7.[idfsBaseReference]

					, tlbHuman_v6.[strPersonID]

					, tlbHuman_v6.[blnPermantentAddressAsCurrent]

					, tlbHuman_v6.[datEnteredDate]

					, tlbHuman_v6.[datModificationDate]

					, tlbHuman_v6.[datModificationForArchiveDate]

					, tlbHuman_v6.[strMaintenanceFlag]

					, tlbHuman_v6.[strReservedAttribute]

					, j_tstSite_idfsSite_v7.[idfsSite]

					, null /*TODO: Check the rule for the new field in EIDSSv7: idfMonitoringSession*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfHuman":' + isnull(cast(cch.idfHuman_v7 as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbHuman] tlbHuman_v6
inner join	[Giraffe].[dbo].[_dmccHuman] cch
on			cch.idfHuman_v6 = tlbHuman_v6.[idfHuman] 


					inner join	[Giraffe].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tlbHuman_v6.[idfsSite] 

					left join	[Giraffe].[dbo].[tlbGeoLocation] j_tlbGeoLocation_idfCurrentResidenceAddress_v7

		on	


					j_tlbGeoLocation_idfCurrentResidenceAddress_v7.[idfGeoLocation] = cch.[idfHumanCRAddress_v7] 

					left join	[Giraffe].[dbo].[tlbGeoLocation] j_tlbGeoLocation_idfEmployerAddress_v7

		on	


					j_tlbGeoLocation_idfEmployerAddress_v7.[idfGeoLocation] = cch.[idfHumanEmpAddress_v7] 

					left join	[Giraffe].[dbo].[tlbGeoLocation] j_tlbGeoLocation_idfRegistrationAddress_v7

		on	


					j_tlbGeoLocation_idfRegistrationAddress_v7.[idfGeoLocation] = cch.[idfHumanPRAddress_v7] 

					left join	[Giraffe].[dbo].[tlbHumanActual] j_tlbHumanActual_idfHumanActual_v7

		on	


					j_tlbHumanActual_idfHumanActual_v7.[idfHumanActual] = tlbHuman_v6.[idfHumanActual] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsOccupationType_v7

		on	


					j_trtBaseReference_idfsOccupationType_v7.[idfsBaseReference] = tlbHuman_v6.[idfsOccupationType] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsNationality_v7

		on	


					j_trtBaseReference_idfsNationality_v7.[idfsBaseReference] = tlbHuman_v6.[idfsNationality] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsHumanGender_v7

		on	


					j_trtBaseReference_idfsHumanGender_v7.[idfsBaseReference] = tlbHuman_v6.[idfsHumanGender] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsPersonIDType_v7

		on	


					j_trtBaseReference_idfsPersonIDType_v7.[idfsBaseReference] = tlbHuman_v6.[idfsPersonIDType] 
left join	[Giraffe].[dbo].[tlbHuman] tlbHuman_v7 
on	

					tlbHuman_v7.[idfHuman] = cch.[idfHuman_v7] 
where tlbHuman_v7.[idfHuman] is null 
print N'Table [tlbHuman] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbFarm]
************************************************************/
insert into [Giraffe].[dbo].[tlbFarm] 

(

					[idfFarm]

					, [idfFarmActual]

					, [idfMonitoringSession]

					, [idfsAvianFarmType]

					, [idfsAvianProductionType]

					, [idfsFarmCategory]

					, [idfsOwnershipStructure]

					, [idfsMovementPattern]

					, [idfsIntendedUse]

					, [idfsGrazingPattern]

					, [idfsLivestockProductionType]

					, [idfHuman]

					, [idfFarmAddress]

					, [idfObservation]

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

					, [datModificationForArchiveDate]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [idfsSite]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tlbFarm_v6.[idfFarm]

					, j_tlbFarmActual_idfFarmActual_v7.[idfFarmActual]

					, j_tlbMonitoringSession_idfMonitoringSession_v7.[idfMonitoringSession]

					, j_trtBaseReference_idfsAvianFarmType_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsAvianProductionType_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsFarmCategory_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsOwnershipStructure_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsMovementPattern_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsIntendedUse_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsGrazingPattern_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsLivestockProductionType_v7.[idfsBaseReference]

					, j_tlbHuman_idfHuman_v7.[idfHuman]

					, j_tlbGeoLocation_idfFarmAddress_v7.[idfGeoLocation]

					, j_tlbObservation_idfObservation_v7.[idfObservation]

					, tlbFarm_v6.[strInternationalName]

					, tlbFarm_v6.[strNationalName]

					, isnull(j_tlbFarmActual_idfFarmActual_v7.[strFarmCode], tlbFarm_v6.[strFarmCode])

					, tlbFarm_v6.[strFax]

					, tlbFarm_v6.[strEmail]

					, tlbFarm_v6.[strContactPhone]

					, tlbFarm_v6.[intLivestockTotalAnimalQty]

					, tlbFarm_v6.[intAvianTotalAnimalQty]

					, tlbFarm_v6.[intLivestockSickAnimalQty]

					, tlbFarm_v6.[intAvianSickAnimalQty]

					, tlbFarm_v6.[intLivestockDeadAnimalQty]

					, tlbFarm_v6.[intAvianDeadAnimalQty]

					, tlbFarm_v6.[intBuidings]

					, tlbFarm_v6.[intBirdsPerBuilding]

					, tlbFarm_v6.[strNote]

					, tlbFarm_v6.[rowguid]

					, tlbFarm_v6.[intRowStatus]

					, tlbFarm_v6.[intHACode]

					, tlbFarm_v6.[datModificationDate]

					, tlbFarm_v6.[datModificationForArchiveDate]

					, tlbFarm_v6.[strMaintenanceFlag]

					, tlbFarm_v6.[strReservedAttribute]

					, j_tstSite_idfsSite_v7.[idfsSite]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfFarm":' + isnull(cast(tlbFarm_v6.[idfFarm] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbFarm] tlbFarm_v6 


					inner join	[Giraffe].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tlbFarm_v6.[idfsSite] 

					left join	[Giraffe].[dbo].[tlbFarmActual] j_tlbFarmActual_idfFarmActual_v7

		on	


					j_tlbFarmActual_idfFarmActual_v7.[idfFarmActual] = tlbFarm_v6.[idfFarmActual] 

					left join	[Giraffe].[dbo].[tlbMonitoringSession] j_tlbMonitoringSession_idfMonitoringSession_v7

		on	


					j_tlbMonitoringSession_idfMonitoringSession_v7.[idfMonitoringSession] = tlbFarm_v6.[idfMonitoringSession] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsAvianFarmType_v7

		on	


					j_trtBaseReference_idfsAvianFarmType_v7.[idfsBaseReference] = tlbFarm_v6.[idfsAvianFarmType] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsAvianProductionType_v7

		on	


					j_trtBaseReference_idfsAvianProductionType_v7.[idfsBaseReference] = tlbFarm_v6.[idfsAvianProductionType] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsFarmCategory_v7

		on	


					j_trtBaseReference_idfsFarmCategory_v7.[idfsBaseReference] = tlbFarm_v6.[idfsFarmCategory] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsOwnershipStructure_v7

		on	


					j_trtBaseReference_idfsOwnershipStructure_v7.[idfsBaseReference] = tlbFarm_v6.[idfsOwnershipStructure] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsMovementPattern_v7

		on	


					j_trtBaseReference_idfsMovementPattern_v7.[idfsBaseReference] = tlbFarm_v6.[idfsMovementPattern] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsIntendedUse_v7

		on	


					j_trtBaseReference_idfsIntendedUse_v7.[idfsBaseReference] = tlbFarm_v6.[idfsIntendedUse] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsGrazingPattern_v7

		on	


					j_trtBaseReference_idfsGrazingPattern_v7.[idfsBaseReference] = tlbFarm_v6.[idfsGrazingPattern] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsLivestockProductionType_v7

		on	


					j_trtBaseReference_idfsLivestockProductionType_v7.[idfsBaseReference] = tlbFarm_v6.[idfsLivestockProductionType] 

					left join	[Giraffe].[dbo].[_dmccHuman] cch
						inner join	[Giraffe].[dbo].[tlbHuman] j_tlbHuman_idfHuman_v7
						on	j_tlbHuman_idfHuman_v7.[idfHuman] = cch.[idfHuman_v7]

		on	


					cch.[idfHuman_V6] = tlbFarm_v6.[idfHuman] and cch.[idfFarm_v6] = tlbFarm_v6.[idfFarm] and cch.[idfFarm_v7] = tlbFarm_v6.[idfFarm] 

					left join	[Giraffe].[dbo].[tlbGeoLocation] j_tlbGeoLocation_idfFarmAddress_v7

		on	


					j_tlbGeoLocation_idfFarmAddress_v7.[idfGeoLocation] = tlbFarm_v6.[idfFarmAddress] 

					left join	[Giraffe].[dbo].[tlbObservation] j_tlbObservation_idfObservation_v7

		on	


					j_tlbObservation_idfObservation_v7.[idfObservation] = tlbFarm_v6.[idfObservation] 
left join	[Giraffe].[dbo].[tlbFarm] tlbFarm_v7 
on	

					tlbFarm_v7.[idfFarm] = tlbFarm_v6.[idfFarm] 
where tlbFarm_v7.[idfFarm] is null 
print N'Table [tlbFarm] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbHerd]
************************************************************/
insert into [Giraffe].[dbo].[tlbHerd] 

(

					[idfHerd]

					, [idfHerdActual]

					, [idfFarm]

					, [strHerdCode]

					, [intSickAnimalQty]

					, [intTotalAnimalQty]

					, [intDeadAnimalQty]

					, [strNote]

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

					tlbHerd_v6.[idfHerd]

					, j_tlbHerdActual_idfHerdActual_v7.[idfHerdActual]

					, j_tlbFarm_idfFarm_v7.[idfFarm]

					, tlbHerd_v6.[strHerdCode]

					, tlbHerd_v6.[intSickAnimalQty]

					, tlbHerd_v6.[intTotalAnimalQty]

					, tlbHerd_v6.[intDeadAnimalQty]

					, tlbHerd_v6.[strNote]

					, tlbHerd_v6.[rowguid]

					, tlbHerd_v6.[intRowStatus]

					, tlbHerd_v6.[strMaintenanceFlag]

					, tlbHerd_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfHerd":' + isnull(cast(tlbHerd_v6.[idfHerd] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbHerd] tlbHerd_v6 


					left join	[Giraffe].[dbo].[tlbFarm] j_tlbFarm_idfFarm_v7

		on	


					j_tlbFarm_idfFarm_v7.[idfFarm] = tlbHerd_v6.[idfFarm] 

					left join	[Giraffe].[dbo].[tlbHerdActual] j_tlbHerdActual_idfHerdActual_v7

		on	


					j_tlbHerdActual_idfHerdActual_v7.[idfHerdActual] = tlbHerd_v6.[idfHerdActual] 
left join	[Giraffe].[dbo].[tlbHerd] tlbHerd_v7 
on	

					tlbHerd_v7.[idfHerd] = tlbHerd_v6.[idfHerd] 
where tlbHerd_v7.[idfHerd] is null 
print N'Table [tlbHerd] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbSpecies]
************************************************************/
insert into [Giraffe].[dbo].[tlbSpecies] 

(

					[idfSpecies]

					, [idfSpeciesActual]

					, [idfsSpeciesType]

					, [idfHerd]

					, [idfObservation]

					, [datStartOfSignsDate]

					, [strAverageAge]

					, [intSickAnimalQty]

					, [intTotalAnimalQty]

					, [intDeadAnimalQty]

					, [strNote]

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

					, [idfsOutbreakCaseStatus]
)
select 

					tlbSpecies_v6.[idfSpecies]

					, j_tlbSpeciesActual_idfSpeciesActual_v7.[idfSpeciesActual]

					, j_trtSpeciesType_idfsSpeciesType_v7.[idfsSpeciesType]

					, j_tlbHerd_idfHerd_v7.[idfHerd]

					, j_tlbObservation_idfObservation_v7.[idfObservation]

					, tlbSpecies_v6.[datStartOfSignsDate]

					, tlbSpecies_v6.[strAverageAge]

					, tlbSpecies_v6.[intSickAnimalQty]

					, tlbSpecies_v6.[intTotalAnimalQty]

					, tlbSpecies_v6.[intDeadAnimalQty]

					, tlbSpecies_v6.[strNote]

					, tlbSpecies_v6.[rowguid]

					, tlbSpecies_v6.[intRowStatus]

					, tlbSpecies_v6.[strMaintenanceFlag]

					, tlbSpecies_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfSpecies":' + isnull(cast(tlbSpecies_v6.[idfSpecies] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()

					, null /*TODO: Check the rule for the new field in EIDSSv7: idfsOutbreakCaseStatus*/
from [Falcon].[dbo].[tlbSpecies] tlbSpecies_v6 


					inner join	[Giraffe].[dbo].[trtSpeciesType] j_trtSpeciesType_idfsSpeciesType_v7

		on	


					j_trtSpeciesType_idfsSpeciesType_v7.[idfsSpeciesType] = tlbSpecies_v6.[idfsSpeciesType] 

					left join	[Giraffe].[dbo].[tlbHerd] j_tlbHerd_idfHerd_v7

		on	


					j_tlbHerd_idfHerd_v7.[idfHerd] = tlbSpecies_v6.[idfHerd] 

					left join	[Giraffe].[dbo].[tlbObservation] j_tlbObservation_idfObservation_v7

		on	


					j_tlbObservation_idfObservation_v7.[idfObservation] = tlbSpecies_v6.[idfObservation] 

					left join	[Giraffe].[dbo].[tlbSpeciesActual] j_tlbSpeciesActual_idfSpeciesActual_v7

		on	


					j_tlbSpeciesActual_idfSpeciesActual_v7.[idfSpeciesActual] = tlbSpecies_v6.[idfSpeciesActual] 
left join	[Giraffe].[dbo].[tlbSpecies] tlbSpecies_v7 
on	

					tlbSpecies_v7.[idfSpecies] = tlbSpecies_v6.[idfSpecies] 
where tlbSpecies_v7.[idfSpecies] is null 
print N'Table [tlbSpecies] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbAnimal]
************************************************************/
insert into [Giraffe].[dbo].[tlbAnimal] 

(

					[idfAnimal]

					, [idfsAnimalGender]

					, [idfsAnimalCondition]

					, [idfsAnimalAge]

					, [idfSpecies]

					, [idfObservation]

					, [strDescription]

					, [strAnimalCode]

					, [strName]

					, [strColor]

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

					, [idfsYNClinicalSigns]
)
select 

					tlbAnimal_v6.[idfAnimal]

					, j_trtBaseReference_idfsAnimalGender_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsAnimalCondition_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsAnimalAge_v7.[idfsBaseReference]

					, j_tlbSpecies_idfSpecies_v7.[idfSpecies]

					, j_tlbObservation_idfObservation_v7.[idfObservation]

					, tlbAnimal_v6.[strDescription]

					, tlbAnimal_v6.[strAnimalCode]

					, tlbAnimal_v6.[strName]

					, tlbAnimal_v6.[strColor]

					, tlbAnimal_v6.[rowguid]

					, tlbAnimal_v6.[intRowStatus]

					, tlbAnimal_v6.[strMaintenanceFlag]

					, tlbAnimal_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfAnimal":' + isnull(cast(tlbAnimal_v6.[idfAnimal] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()

					, null /*TODO: Check the rule for the new field in EIDSSv7: idfsYNClinicalSigns*/
from [Falcon].[dbo].[tlbAnimal] tlbAnimal_v6 


					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsAnimalGender_v7

		on	


					j_trtBaseReference_idfsAnimalGender_v7.[idfsBaseReference] = tlbAnimal_v6.[idfsAnimalGender] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsAnimalCondition_v7

		on	


					j_trtBaseReference_idfsAnimalCondition_v7.[idfsBaseReference] = tlbAnimal_v6.[idfsAnimalCondition] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsAnimalAge_v7

		on	


					j_trtBaseReference_idfsAnimalAge_v7.[idfsBaseReference] = tlbAnimal_v6.[idfsAnimalAge] 

					left join	[Giraffe].[dbo].[tlbSpecies] j_tlbSpecies_idfSpecies_v7

		on	


					j_tlbSpecies_idfSpecies_v7.[idfSpecies] = tlbAnimal_v6.[idfSpecies] 

					left join	[Giraffe].[dbo].[tlbObservation] j_tlbObservation_idfObservation_v7

		on	


					j_tlbObservation_idfObservation_v7.[idfObservation] = tlbAnimal_v6.[idfObservation] 
left join	[Giraffe].[dbo].[tlbAnimal] tlbAnimal_v7 
on	

					tlbAnimal_v7.[idfAnimal] = tlbAnimal_v6.[idfAnimal] 
where tlbAnimal_v7.[idfAnimal] is null 
print N'Table [tlbAnimal] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbCampaign]
************************************************************/
insert into [Giraffe].[dbo].[tlbCampaign] 

(

					[idfCampaign]

					, [idfsCampaignType]

					, [idfsCampaignStatus]

					, [datCampaignDateStart]

					, [datCampaignDateEnd]

					, [strCampaignID]

					, [strCampaignName]

					, [strCampaignAdministrator]

					, [strComments]

					, [strConclusion]

					, [intRowStatus]

					, [rowguid]

					, [datModificationForArchiveDate]

					, [idfsSite]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [CampaignCategoryID]

					, [LegacyCampaignID]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tlbCampaign_v6.[idfCampaign]

					, j_trtBaseReference_idfsCampaignType_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsCampaignStatus_v7.[idfsBaseReference]

					, tlbCampaign_v6.[datCampaignDateStart]

					, tlbCampaign_v6.[datCampaignDateEnd]

					, tlbCampaign_v6.[strCampaignID]

					, tlbCampaign_v6.[strCampaignName]

					, tlbCampaign_v6.[strCampaignAdministrator]

					, tlbCampaign_v6.[strComments]

					, tlbCampaign_v6.[strConclusion]

					, tlbCampaign_v6.[intRowStatus]

					, tlbCampaign_v6.[rowguid]

					, tlbCampaign_v6.[datModificationForArchiveDate]

					, j_tstSite_idfsSite_v7.[idfsSite]

					, tlbCampaign_v6.[strMaintenanceFlag]

					, tlbCampaign_v6.[strReservedAttribute]

					, 10501002 /*Rule for the new field in EIDSSv7: CampaignCategoryID - default value [Veterinary Active Surveillance Campaign]*/

					, tlbCampaign_v6.strCampaignID /*Rule for the new field in EIDSSv7: LegacyCampaignID*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfCampaign":' + isnull(cast(tlbCampaign_v6.[idfCampaign] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbCampaign] tlbCampaign_v6 


					inner join	[Giraffe].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tlbCampaign_v6.[idfsSite] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsCampaignStatus_v7

		on	


					j_trtBaseReference_idfsCampaignStatus_v7.[idfsBaseReference] = tlbCampaign_v6.[idfsCampaignStatus] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsCampaignType_v7

		on	


					j_trtBaseReference_idfsCampaignType_v7.[idfsBaseReference] = tlbCampaign_v6.[idfsCampaignType] 
left join	[Giraffe].[dbo].[tlbCampaign] tlbCampaign_v7 
on	

					tlbCampaign_v7.[idfCampaign] = tlbCampaign_v6.[idfCampaign] 
where tlbCampaign_v7.[idfCampaign] is null 
print N'Table [tlbCampaign] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbCampaignToDiagnosis]
************************************************************/
insert into [Giraffe].[dbo].[tlbCampaignToDiagnosis] 

(

					[idfCampaignToDiagnosis]

					, [idfCampaign]

					, [idfsDiagnosis]

					, [intOrder]

					, [intRowStatus]

					, [rowguid]

					, [intPlannedNumber]

					, [idfsSpeciesType]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [idfsSampleType]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]

					, [Comments]
)
select 

					tlbCampaignToDiagnosis_v6.[idfCampaignToDiagnosis]

					, j_tlbCampaign_idfCampaign_v7.[idfCampaign]

					, j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis]

					, tlbCampaignToDiagnosis_v6.[intOrder]

					, tlbCampaignToDiagnosis_v6.[intRowStatus]

					, tlbCampaignToDiagnosis_v6.[rowguid]

					, tlbCampaignToDiagnosis_v6.[intPlannedNumber]

					, j_trtSpeciesType_idfsSpeciesType_v7.[idfsSpeciesType]

					, tlbCampaignToDiagnosis_v6.[strMaintenanceFlag]

					, tlbCampaignToDiagnosis_v6.[strReservedAttribute]

					, j_trtSampleType_idfsSampleType_v7.[idfsSampleType]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfCampaignToDiagnosis":' + isnull(cast(tlbCampaignToDiagnosis_v6.[idfCampaignToDiagnosis] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()

					, null /*TODO: Check the rule for the new field in EIDSSv7: Comments*/
from [Falcon].[dbo].[tlbCampaignToDiagnosis] tlbCampaignToDiagnosis_v6 


					inner join	[Giraffe].[dbo].[tlbCampaign] j_tlbCampaign_idfCampaign_v7

		on	


					j_tlbCampaign_idfCampaign_v7.[idfCampaign] = tlbCampaignToDiagnosis_v6.[idfCampaign] 

					inner join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsDiagnosis_v7

		on	


					j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis] = tlbCampaignToDiagnosis_v6.[idfsDiagnosis] 

					left join	[Giraffe].[dbo].[trtSpeciesType] j_trtSpeciesType_idfsSpeciesType_v7

		on	


					j_trtSpeciesType_idfsSpeciesType_v7.[idfsSpeciesType] = tlbCampaignToDiagnosis_v6.[idfsSpeciesType] 

					left join	[Giraffe].[dbo].[trtSampleType] j_trtSampleType_idfsSampleType_v7

		on	


					j_trtSampleType_idfsSampleType_v7.[idfsSampleType] = tlbCampaignToDiagnosis_v6.[idfsSampleType] 
left join	[Giraffe].[dbo].[tlbCampaignToDiagnosis] tlbCampaignToDiagnosis_v7 
on	

					tlbCampaignToDiagnosis_v7.[idfCampaignToDiagnosis] = tlbCampaignToDiagnosis_v6.[idfCampaignToDiagnosis] 
where tlbCampaignToDiagnosis_v7.[idfCampaignToDiagnosis] is null 
print N'Table [tlbCampaignToDiagnosis] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbFreezer]
************************************************************/
insert into [Giraffe].[dbo].[tlbFreezer] 

(

					[idfFreezer]

					, [idfsStorageType]

					, [idfsSite]

					, [strFreezerName]

					, [strNote]

					, [strBarcode]

					, [intRowStatus]

					, [rowguid]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [LocBuildingName]

					, [LocRoom]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tlbFreezer_v6.[idfFreezer]

					, j_trtBaseReference_idfsStorageType_v7.[idfsBaseReference]

					, j_tstSite_idfsSite_v7.[idfsSite]

					, tlbFreezer_v6.[strFreezerName]

					, tlbFreezer_v6.[strNote]

					, tlbFreezer_v6.[strBarcode]

					, tlbFreezer_v6.[intRowStatus]

					, tlbFreezer_v6.[rowguid]

					, tlbFreezer_v6.[strMaintenanceFlag]

					, tlbFreezer_v6.[strReservedAttribute]

					, null /*TODO: Check the rule for the new field in EIDSSv7: LocBuildingName*/

					, null /*TODO: Check the rule for the new field in EIDSSv7: LocRoom*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfFreezer":' + isnull(cast(tlbFreezer_v6.[idfFreezer] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbFreezer] tlbFreezer_v6 


					inner join	[Giraffe].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tlbFreezer_v6.[idfsSite] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsStorageType_v7

		on	


					j_trtBaseReference_idfsStorageType_v7.[idfsBaseReference] = tlbFreezer_v6.[idfsStorageType] 
left join	[Giraffe].[dbo].[tlbFreezer] tlbFreezer_v7 
on	

					tlbFreezer_v7.[idfFreezer] = tlbFreezer_v6.[idfFreezer] 
where tlbFreezer_v7.[idfFreezer] is null 
print N'Table [tlbFreezer] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbFreezerSubdivision]
************************************************************/
insert into [Giraffe].[dbo].[tlbFreezerSubdivision] 

(

					[idfSubdivision]

					, [idfsSubdivisionType]

					, [idfFreezer]

					, [idfParentSubdivision]

					, [idfsSite]

					, [strBarcode]

					, [strNameChars]

					, [strNote]

					, [intCapacity]

					, [intRowStatus]

					, [rowguid]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [BoxSizeID]

					, [BoxPlaceAvailability]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tlbFreezerSubdivision_v6.[idfSubdivision]

					, j_trtBaseReference_idfsSubdivisionType_v7.[idfsBaseReference]

					, j_tlbFreezer_idfFreezer_v7.[idfFreezer]

					, null /*Will be updated below when foreign key data is available*/

					, j_tstSite_idfsSite_v7.[idfsSite]

					, tlbFreezerSubdivision_v6.[strBarcode]

					, tlbFreezerSubdivision_v6.[strNameChars]

					, tlbFreezerSubdivision_v6.[strNote]

					, tlbFreezerSubdivision_v6.[intCapacity]

					, tlbFreezerSubdivision_v6.[intRowStatus]

					, tlbFreezerSubdivision_v6.[rowguid]

					, tlbFreezerSubdivision_v6.[strMaintenanceFlag]

					, tlbFreezerSubdivision_v6.[strReservedAttribute]

					, null /*TODO: Check the rule for the new field in EIDSSv7: BoxSizeID*/

					, null /*TODO: Check the rule for the new field in EIDSSv7: BoxPlaceAvailability*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfSubdivision":' + isnull(cast(tlbFreezerSubdivision_v6.[idfSubdivision] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbFreezerSubdivision] tlbFreezerSubdivision_v6 


					inner join	[Giraffe].[dbo].[tlbFreezer] j_tlbFreezer_idfFreezer_v7

		on	


					j_tlbFreezer_idfFreezer_v7.[idfFreezer] = tlbFreezerSubdivision_v6.[idfFreezer] 

					inner join	[Giraffe].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tlbFreezerSubdivision_v6.[idfsSite] 

					left join	[Giraffe].[dbo].[tlbFreezerSubdivision] j_tlbFreezerSubdivision_idfParentSubdivision_v7

		on	


					j_tlbFreezerSubdivision_idfParentSubdivision_v7.[idfSubdivision] = tlbFreezerSubdivision_v6.[idfParentSubdivision] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsSubdivisionType_v7

		on	


					j_trtBaseReference_idfsSubdivisionType_v7.[idfsBaseReference] = tlbFreezerSubdivision_v6.[idfsSubdivisionType] 
left join	[Giraffe].[dbo].[tlbFreezerSubdivision] tlbFreezerSubdivision_v7 
on	

					tlbFreezerSubdivision_v7.[idfSubdivision] = tlbFreezerSubdivision_v6.[idfSubdivision] 
where tlbFreezerSubdivision_v7.[idfSubdivision] is null 
print N'Table [tlbFreezerSubdivision] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbOutbreak]
************************************************************/
insert into [Giraffe].[dbo].[tlbOutbreak] 

(

					[idfOutbreak]

					, [idfsDiagnosisOrDiagnosisGroup]

					, [idfsOutbreakStatus]

					, [idfGeoLocation]

					, [datStartDate]

					, [datFinishDate]

					, [strOutbreakID]

					, [strDescription]

					, [intRowStatus]

					, [rowguid]

					, [datModificationForArchiveDate]

					, [idfPrimaryCaseOrSession]

					, [idfsSite]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [OutbreakTypeID]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]

					, [idfsLocation]
)
select 

					tlbOutbreak_v6.[idfOutbreak]

					, j_trtBaseReference_idfsDiagnosisOrDiagnosisGroup_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsOutbreakStatus_v7.[idfsBaseReference]

					, j_tlbGeoLocation_idfGeoLocation_v7.[idfGeoLocation]

					, tlbOutbreak_v6.[datStartDate]

					, tlbOutbreak_v6.[datFinishDate]

					, tlbOutbreak_v6.[strOutbreakID]

					, tlbOutbreak_v6.[strDescription]

					, tlbOutbreak_v6.[intRowStatus]

					, tlbOutbreak_v6.[rowguid]

					, tlbOutbreak_v6.[datModificationForArchiveDate]

					, null /*Will be updated below when foreign key data is available*/

					, j_tstSite_idfsSite_v7.[idfsSite]

					, tlbOutbreak_v6.[strMaintenanceFlag]

					, tlbOutbreak_v6.[strReservedAttribute]

					, 

					  case

						when	vc_count.intCount = 0 and hc_count.intCount > 0

							then	10513001 /*Human*/

						when	vc_count.intCount > 0 and hc_count.intCount = 0

							then	10513001 /*Veterinary*/

						else	10513003 /*Zoonotic*/

					  end /*Rule for the new field in EIDSSv7: OutbreakTypeID*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfOutbreak":' + isnull(cast(tlbOutbreak_v6.[idfOutbreak] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()

					, j_tlbGeoLocation_idfGeoLocation_v7.[idfsLocation] /*Rule for the new field in EIDSSv7: idfsLocation*/
from [Falcon].[dbo].[tlbOutbreak] tlbOutbreak_v6
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
 


					inner join	[Giraffe].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tlbOutbreak_v6.[idfsSite] 

					left join	[Giraffe].[dbo].[tlbGeoLocation] j_tlbGeoLocation_idfGeoLocation_v7

		on	


					j_tlbGeoLocation_idfGeoLocation_v7.[idfGeoLocation] = tlbOutbreak_v6.[idfGeoLocation] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsDiagnosisOrDiagnosisGroup_v7

		on	


					j_trtBaseReference_idfsDiagnosisOrDiagnosisGroup_v7.[idfsBaseReference] = tlbOutbreak_v6.[idfsDiagnosisOrDiagnosisGroup] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsOutbreakStatus_v7

		on	


					(	(j_trtBaseReference_idfsOutbreakStatus_v7.[idfsBaseReference] = 10063503 /*Not an Outbreak*/ and tlbOutbreak_v6.[idfsOutbreakStatus] = 53418740000000 /*Not an Outbreak*/)
		or (j_trtBaseReference_idfsOutbreakStatus_v7.[idfsBaseReference] = 10063501 /*In Progress*/ and (tlbOutbreak_v6.[idfsOutbreakStatus] is null or tlbOutbreak_v6.[idfsOutbreakStatus] <> 53418740000000 /*Not an Outbreak*/) and tlbOutbreak_v6.[datFinishDate] is null)
		or (j_trtBaseReference_idfsOutbreakStatus_v7.[idfsBaseReference] = 10063502 /*Closed*/ and (tlbOutbreak_v6.[idfsOutbreakStatus] is null or tlbOutbreak_v6.[idfsOutbreakStatus] <> 53418740000000 /*Not an Outbreak*/) and tlbOutbreak_v6.[datFinishDate] is not null)) 
left join	[Giraffe].[dbo].[tlbOutbreak] tlbOutbreak_v7 
on	

					tlbOutbreak_v7.[idfOutbreak] = tlbOutbreak_v6.[idfOutbreak] 
where tlbOutbreak_v7.[idfOutbreak] is null 
print N'Table [tlbOutbreak] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbOutbreakNote]
************************************************************/
insert into [Giraffe].[dbo].[tlbOutbreakNote] 

(

					[idfOutbreakNote]

					, [idfOutbreak]

					, [strNote]

					, [datNoteDate]

					, [idfPerson]

					, [intRowStatus]

					, [rowguid]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [UpdatePriorityID]

					, [UpdateRecordTitle]

					, [UploadFileName]

					, [UploadFileDescription]

					, [UploadFileObject]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]

					, [DocumentContentType]
)
select 

					tlbOutbreakNote_v6.[idfOutbreakNote]

					, j_tlbOutbreak_idfOutbreak_v7.[idfOutbreak]

					, tlbOutbreakNote_v6.[strNote]

					, tlbOutbreakNote_v6.[datNoteDate]

					, j_tlbPerson_idfPerson_v7.[idfPerson]

					, tlbOutbreakNote_v6.[intRowStatus]

					, tlbOutbreakNote_v6.[rowguid]

					, tlbOutbreakNote_v6.[strMaintenanceFlag]

					, tlbOutbreakNote_v6.[strReservedAttribute]

					, null /*TODO: Check the rule for the new field in EIDSSv7: UpdatePriorityID*/

					, null /*TODO: Check the rule for the new field in EIDSSv7: UpdateRecordTitle*/

					, null /*TODO: Check the rule for the new field in EIDSSv7: UploadFileName*/

					, null /*TODO: Check the rule for the new field in EIDSSv7: UploadFileDescription*/

					, null /*TODO: Check the rule for the new field in EIDSSv7: UploadFileObject*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfOutbreakNote":' + isnull(cast(tlbOutbreakNote_v6.[idfOutbreakNote] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()

					, null /*TODO: Check the rule for the new field in EIDSSv7: DocumentContentType*/
from [Falcon].[dbo].[tlbOutbreakNote] tlbOutbreakNote_v6 


					inner join	[Giraffe].[dbo].[tlbOutbreak] j_tlbOutbreak_idfOutbreak_v7

		on	


					j_tlbOutbreak_idfOutbreak_v7.[idfOutbreak] = tlbOutbreakNote_v6.[idfOutbreak] 

					inner join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfPerson_v7

		on	


					j_tlbPerson_idfPerson_v7.[idfPerson] = tlbOutbreakNote_v6.[idfPerson] 
left join	[Giraffe].[dbo].[tlbOutbreakNote] tlbOutbreakNote_v7 
on	

					tlbOutbreakNote_v7.[idfOutbreakNote] = tlbOutbreakNote_v6.[idfOutbreakNote] 
where tlbOutbreakNote_v7.[idfOutbreakNote] is null 
print N'Table [tlbOutbreakNote] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tflOutbreakFiltered]
************************************************************/
insert into [Giraffe].[dbo].[tflOutbreakFiltered] 

(

					[idfOutbreakFiltered]

					, [idfOutbreak]

					, [idfSiteGroup]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tflOutbreakFiltered_v6.[idfOutbreakFiltered]

					, j_tlbOutbreak_idfOutbreak_v7.[idfOutbreak]

					, j_tflSiteGroup_idfSiteGroup_v7.[idfSiteGroup]

					, tflOutbreakFiltered_v6.[rowguid]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfOutbreakFiltered":' + isnull(cast(tflOutbreakFiltered_v6.[idfOutbreakFiltered] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tflOutbreakFiltered] tflOutbreakFiltered_v6 


					inner join	[Giraffe].[dbo].[tlbOutbreak] j_tlbOutbreak_idfOutbreak_v7

		on	


					j_tlbOutbreak_idfOutbreak_v7.[idfOutbreak] = tflOutbreakFiltered_v6.[idfOutbreak] 

					inner join	[Giraffe].[dbo].[tflSiteGroup] j_tflSiteGroup_idfSiteGroup_v7

		on	


					j_tflSiteGroup_idfSiteGroup_v7.[idfSiteGroup] = tflOutbreakFiltered_v6.[idfSiteGroup] 
left join	[Giraffe].[dbo].[tflOutbreakFiltered] tflOutbreakFiltered_v7 
on	

					tflOutbreakFiltered_v7.[idfOutbreakFiltered] = tflOutbreakFiltered_v6.[idfOutbreakFiltered] 
where tflOutbreakFiltered_v7.[idfOutbreakFiltered] is null 
print N'Table [tflOutbreakFiltered] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbAggrCase]
************************************************************/
insert into [Giraffe].[dbo].[tlbAggrCase] 

(

					[idfAggrCase]

					, [idfsAggrCaseType]

					, [idfsAdministrativeUnit]

					, [idfReceivedByOffice]

					, [idfReceivedByPerson]

					, [idfSentByOffice]

					, [idfSentByPerson]

					, [idfEnteredByOffice]

					, [idfEnteredByPerson]

					, [idfCaseObservation]

					, [idfDiagnosticObservation]

					, [idfProphylacticObservation]

					, [idfSanitaryObservation]

					, [idfVersion]

					, [idfDiagnosticVersion]

					, [idfProphylacticVersion]

					, [idfSanitaryVersion]

					, [datReceivedByDate]

					, [datSentByDate]

					, [datEnteredByDate]

					, [datStartDate]

					, [datFinishDate]

					, [strCaseID]

					, [intRowStatus]

					, [rowguid]

					, [datModificationForArchiveDate]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [idfsSite]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]

					, [idfOffice]
)
select 

					tlbAggrCase_v6.[idfAggrCase]

					, j_trtBaseReference_idfsAggrCaseType_v7.[idfsBaseReference]

					, j_gisBaseReference_idfsAdministrativeUnit_v7.[idfsGISBaseReference]

					, j_tlbOffice_idfReceivedByOffice_v7.[idfOffice]

					, j_tlbPerson_idfReceivedByPerson_v7.[idfPerson]

					, j_tlbOffice_idfSentByOffice_v7.[idfOffice]

					, j_tlbPerson_idfSentByPerson_v7.[idfPerson]

					, j_tlbOffice_idfEnteredByOffice_v7.[idfOffice]

					, j_tlbPerson_idfEnteredByPerson_v7.[idfPerson]

					, j_tlbObservation_idfCaseObservation_v7.[idfObservation]

					, j_tlbObservation_idfDiagnosticObservation_v7.[idfObservation]

					, j_tlbObservation_idfProphylacticObservation_v7.[idfObservation]

					, j_tlbObservation_idfSanitaryObservation_v7.[idfObservation]

					, j_tlbAggrMatrixVersionHeader_idfVersion_v7.[idfVersion]

					, j_tlbAggrMatrixVersionHeader_idfDiagnosticVersion_v7.[idfVersion]

					, j_tlbAggrMatrixVersionHeader_idfProphylacticVersion_v7.[idfVersion]

					, j_tlbAggrMatrixVersionHeader_idfSanitaryVersion_v7.[idfVersion]

					, tlbAggrCase_v6.[datReceivedByDate]

					, tlbAggrCase_v6.[datSentByDate]

					, tlbAggrCase_v6.[datEnteredByDate]

					, tlbAggrCase_v6.[datStartDate]

					, tlbAggrCase_v6.[datFinishDate]

					, tlbAggrCase_v6.[strCaseID]

					, tlbAggrCase_v6.[intRowStatus]

					, tlbAggrCase_v6.[rowguid]

					, tlbAggrCase_v6.[datModificationForArchiveDate]

					, tlbAggrCase_v6.[strMaintenanceFlag]

					, tlbAggrCase_v6.[strReservedAttribute]

					, j_tstSite_idfsSite_v7.[idfsSite]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfAggrCase":' + isnull(cast(tlbAggrCase_v6.[idfAggrCase] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()

					, null /*TODO: Check the rule for the new field in EIDSSv7: idfOffice*/
from [Falcon].[dbo].[tlbAggrCase] tlbAggrCase_v6 


					inner join	[Giraffe].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tlbAggrCase_v6.[idfsSite] 

					inner join	[Giraffe].[dbo].[gisBaseReference] j_gisBaseReference_idfsAdministrativeUnit_v7

		on	


					j_gisBaseReference_idfsAdministrativeUnit_v7.[idfsGISBaseReference] = tlbAggrCase_v6.[idfsAdministrativeUnit] 

					inner join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsAggrCaseType_v7

		on	


					j_trtBaseReference_idfsAggrCaseType_v7.[idfsBaseReference] = tlbAggrCase_v6.[idfsAggrCaseType] 

					inner join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfSentByOffice_v7

		on	


					j_tlbOffice_idfSentByOffice_v7.[idfOffice] = tlbAggrCase_v6.[idfSentByOffice] 

					inner join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfSentByPerson_v7

		on	


					j_tlbPerson_idfSentByPerson_v7.[idfPerson] = tlbAggrCase_v6.[idfSentByPerson] 

					inner join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfEnteredByOffice_v7

		on	


					j_tlbOffice_idfEnteredByOffice_v7.[idfOffice] = tlbAggrCase_v6.[idfEnteredByOffice] 

					inner join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfEnteredByPerson_v7

		on	


					j_tlbPerson_idfEnteredByPerson_v7.[idfPerson] = tlbAggrCase_v6.[idfEnteredByPerson] 

					left join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfReceivedByOffice_v7

		on	


					j_tlbOffice_idfReceivedByOffice_v7.[idfOffice] = tlbAggrCase_v6.[idfReceivedByOffice] 

					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfReceivedByPerson_v7

		on	


					j_tlbPerson_idfReceivedByPerson_v7.[idfPerson] = tlbAggrCase_v6.[idfReceivedByPerson] 

					left join	[Giraffe].[dbo].[tlbObservation] j_tlbObservation_idfCaseObservation_v7

		on	


					j_tlbObservation_idfCaseObservation_v7.[idfObservation] = tlbAggrCase_v6.[idfCaseObservation] 

					left join	[Giraffe].[dbo].[tlbObservation] j_tlbObservation_idfDiagnosticObservation_v7

		on	


					j_tlbObservation_idfDiagnosticObservation_v7.[idfObservation] = tlbAggrCase_v6.[idfDiagnosticObservation] 

					left join	[Giraffe].[dbo].[tlbObservation] j_tlbObservation_idfProphylacticObservation_v7

		on	


					j_tlbObservation_idfProphylacticObservation_v7.[idfObservation] = tlbAggrCase_v6.[idfProphylacticObservation] 

					left join	[Giraffe].[dbo].[tlbObservation] j_tlbObservation_idfSanitaryObservation_v7

		on	


					j_tlbObservation_idfSanitaryObservation_v7.[idfObservation] = tlbAggrCase_v6.[idfSanitaryObservation] 

					left join	[Giraffe].[dbo].[tlbAggrMatrixVersionHeader] j_tlbAggrMatrixVersionHeader_idfVersion_v7

		on	


					j_tlbAggrMatrixVersionHeader_idfVersion_v7.[idfVersion] = tlbAggrCase_v6.[idfVersion] 

					left join	[Giraffe].[dbo].[tlbAggrMatrixVersionHeader] j_tlbAggrMatrixVersionHeader_idfDiagnosticVersion_v7

		on	


					j_tlbAggrMatrixVersionHeader_idfDiagnosticVersion_v7.[idfVersion] = tlbAggrCase_v6.[idfDiagnosticVersion] 

					left join	[Giraffe].[dbo].[tlbAggrMatrixVersionHeader] j_tlbAggrMatrixVersionHeader_idfProphylacticVersion_v7

		on	


					j_tlbAggrMatrixVersionHeader_idfProphylacticVersion_v7.[idfVersion] = tlbAggrCase_v6.[idfProphylacticVersion] 

					left join	[Giraffe].[dbo].[tlbAggrMatrixVersionHeader] j_tlbAggrMatrixVersionHeader_idfSanitaryVersion_v7

		on	


					j_tlbAggrMatrixVersionHeader_idfSanitaryVersion_v7.[idfVersion] = tlbAggrCase_v6.[idfSanitaryVersion] 
left join	[Giraffe].[dbo].[tlbAggrCase] tlbAggrCase_v7 
on	

					tlbAggrCase_v7.[idfAggrCase] = tlbAggrCase_v6.[idfAggrCase] 
where tlbAggrCase_v7.[idfAggrCase] is null 
print N'Table [tlbAggrCase] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tflAggregateCaseFiltered]
************************************************************/








/************************************************************
* Insert records - [tlbVectorSurveillanceSession]
************************************************************/
insert into [Giraffe].[dbo].[tlbVectorSurveillanceSession] 

(

					[idfVectorSurveillanceSession]

					, [strSessionID]

					, [strFieldSessionID]

					, [idfsVectorSurveillanceStatus]

					, [datStartDate]

					, [datCloseDate]

					, [idfLocation]

					, [idfOutbreak]

					, [strDescription]

					, [idfsSite]

					, [intRowStatus]

					, [rowguid]

					, [datModificationForArchiveDate]

					, [intCollectionEffort]

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

					tlbVectorSurveillanceSession_v6.[idfVectorSurveillanceSession]

					, tlbVectorSurveillanceSession_v6.[strSessionID]

					, tlbVectorSurveillanceSession_v6.[strFieldSessionID]

					, j_trtBaseReference_idfsVectorSurveillanceStatus_v7.[idfsBaseReference]

					, tlbVectorSurveillanceSession_v6.[datStartDate]

					, tlbVectorSurveillanceSession_v6.[datCloseDate]

					, j_tlbGeoLocation_idfLocation_v7.[idfGeoLocation]

					, j_tlbOutbreak_idfOutbreak_v7.[idfOutbreak]

					, tlbVectorSurveillanceSession_v6.[strDescription]

					, j_tstSite_idfsSite_v7.[idfsSite]

					, tlbVectorSurveillanceSession_v6.[intRowStatus]

					, tlbVectorSurveillanceSession_v6.[rowguid]

					, tlbVectorSurveillanceSession_v6.[datModificationForArchiveDate]

					, tlbVectorSurveillanceSession_v6.[intCollectionEffort]

					, tlbVectorSurveillanceSession_v6.[strMaintenanceFlag]

					, tlbVectorSurveillanceSession_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfVectorSurveillanceSession":' + isnull(cast(tlbVectorSurveillanceSession_v6.[idfVectorSurveillanceSession] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbVectorSurveillanceSession] tlbVectorSurveillanceSession_v6 


					inner join	[Giraffe].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tlbVectorSurveillanceSession_v6.[idfsSite] 

					inner join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsVectorSurveillanceStatus_v7

		on	


					j_trtBaseReference_idfsVectorSurveillanceStatus_v7.[idfsBaseReference] = tlbVectorSurveillanceSession_v6.[idfsVectorSurveillanceStatus] 

					left join	[Giraffe].[dbo].[tlbGeoLocation] j_tlbGeoLocation_idfLocation_v7

		on	


					j_tlbGeoLocation_idfLocation_v7.[idfGeoLocation] = tlbVectorSurveillanceSession_v6.[idfLocation] 

					left join	[Giraffe].[dbo].[tlbOutbreak] j_tlbOutbreak_idfOutbreak_v7

		on	


					j_tlbOutbreak_idfOutbreak_v7.[idfOutbreak] = tlbVectorSurveillanceSession_v6.[idfOutbreak] 
left join	[Giraffe].[dbo].[tlbVectorSurveillanceSession] tlbVectorSurveillanceSession_v7 
on	

					tlbVectorSurveillanceSession_v7.[idfVectorSurveillanceSession] = tlbVectorSurveillanceSession_v6.[idfVectorSurveillanceSession] 
where tlbVectorSurveillanceSession_v7.[idfVectorSurveillanceSession] is null 
print N'Table [tlbVectorSurveillanceSession] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbVector]
************************************************************/
insert into [Giraffe].[dbo].[tlbVector] 

(

					[idfVector]

					, [idfVectorSurveillanceSession]

					, [idfHostVector]

					, [strVectorID]

					, [strFieldVectorID]

					, [idfLocation]

					, [intElevation]

					, [idfsSurrounding]

					, [strGEOReferenceSources]

					, [idfCollectedByOffice]

					, [idfCollectedByPerson]

					, [datCollectionDateTime]

					, [idfsCollectionMethod]

					, [idfsBasisOfRecord]

					, [idfsVectorType]

					, [idfsVectorSubType]

					, [intQuantity]

					, [idfsSex]

					, [idfIdentifiedByOffice]

					, [idfIdentifiedByPerson]

					, [datIdentifiedDateTime]

					, [idfsIdentificationMethod]

					, [idfObservation]

					, [intRowStatus]

					, [rowguid]

					, [idfsDayPeriod]

					, [strComment]

					, [idfsEctoparasitesCollected]

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

					tlbVector_v6.[idfVector]

					, j_tlbVectorSurveillanceSession_idfVectorSurveillanceSession_v7.[idfVectorSurveillanceSession]

					, null /*Will be updated below when foreign key data is available*/

					, tlbVector_v6.[strVectorID]

					, tlbVector_v6.[strFieldVectorID]

					, j_tlbGeoLocation_idfLocation_v7.[idfGeoLocation]

					, tlbVector_v6.[intElevation]

					, j_trtBaseReference_idfsSurrounding_v7.[idfsBaseReference]

					, tlbVector_v6.[strGEOReferenceSources]

					, j_tlbOffice_idfCollectedByOffice_v7.[idfOffice]

					, j_tlbPerson_idfCollectedByPerson_v7.[idfPerson]

					, tlbVector_v6.[datCollectionDateTime]

					, j_trtBaseReference_idfsCollectionMethod_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsBasisOfRecord_v7.[idfsBaseReference]

					, j_trtVectorType_idfsVectorType_v7.[idfsVectorType]

					, j_trtVectorSubType_idfsVectorSubType_v7.[idfsVectorSubType]

					, tlbVector_v6.[intQuantity]

					, j_trtBaseReference_idfsSex_v7.[idfsBaseReference]

					, j_tlbOffice_idfIdentifiedByOffice_v7.[idfOffice]

					, j_tlbPerson_idfIdentifiedByPerson_v7.[idfPerson]

					, tlbVector_v6.[datIdentifiedDateTime]

					, j_trtBaseReference_idfsIdentificationMethod_v7.[idfsBaseReference]

					, j_tlbObservation_idfObservation_v7.[idfObservation]

					, tlbVector_v6.[intRowStatus]

					, tlbVector_v6.[rowguid]

					, j_trtBaseReference_idfsDayPeriod_v7.[idfsBaseReference]

					, tlbVector_v6.[strComment]

					, j_trtBaseReference_idfsEctoparasitesCollected_v7.[idfsBaseReference]

					, tlbVector_v6.[strMaintenanceFlag]

					, tlbVector_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfVector":' + isnull(cast(tlbVector_v6.[idfVector] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbVector] tlbVector_v6 


					inner join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfCollectedByOffice_v7

		on	


					j_tlbOffice_idfCollectedByOffice_v7.[idfOffice] = tlbVector_v6.[idfCollectedByOffice] 

					inner join	[Giraffe].[dbo].[trtVectorType] j_trtVectorType_idfsVectorType_v7

		on	


					j_trtVectorType_idfsVectorType_v7.[idfsVectorType] = tlbVector_v6.[idfsVectorType] 

					inner join	[Giraffe].[dbo].[trtVectorSubType] j_trtVectorSubType_idfsVectorSubType_v7

		on	


					j_trtVectorSubType_idfsVectorSubType_v7.[idfsVectorSubType] = tlbVector_v6.[idfsVectorSubType] 

					left join	[Giraffe].[dbo].[tlbVectorSurveillanceSession] j_tlbVectorSurveillanceSession_idfVectorSurveillanceSession_v7

		on	


					j_tlbVectorSurveillanceSession_idfVectorSurveillanceSession_v7.[idfVectorSurveillanceSession] = tlbVector_v6.[idfVectorSurveillanceSession] 

					left join	[Giraffe].[dbo].[tlbGeoLocation] j_tlbGeoLocation_idfLocation_v7

		on	


					j_tlbGeoLocation_idfLocation_v7.[idfGeoLocation] = tlbVector_v6.[idfLocation] 

					left join	[Giraffe].[dbo].[tlbObservation] j_tlbObservation_idfObservation_v7

		on	


					j_tlbObservation_idfObservation_v7.[idfObservation] = tlbVector_v6.[idfObservation] 

					left join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfIdentifiedByOffice_v7

		on	


					j_tlbOffice_idfIdentifiedByOffice_v7.[idfOffice] = tlbVector_v6.[idfIdentifiedByOffice] 

					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfCollectedByPerson_v7

		on	


					j_tlbPerson_idfCollectedByPerson_v7.[idfPerson] = tlbVector_v6.[idfCollectedByPerson] 

					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfIdentifiedByPerson_v7

		on	


					j_tlbPerson_idfIdentifiedByPerson_v7.[idfPerson] = tlbVector_v6.[idfIdentifiedByPerson] 

					left join	[Giraffe].[dbo].[tlbVector] j_tlbVector_idfHostVector_v7

		on	


					j_tlbVector_idfHostVector_v7.[idfVector] = tlbVector_v6.[idfHostVector] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsSurrounding_v7

		on	


					j_trtBaseReference_idfsSurrounding_v7.[idfsBaseReference] = tlbVector_v6.[idfsSurrounding] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsCollectionMethod_v7

		on	


					j_trtBaseReference_idfsCollectionMethod_v7.[idfsBaseReference] = tlbVector_v6.[idfsCollectionMethod] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsBasisOfRecord_v7

		on	


					j_trtBaseReference_idfsBasisOfRecord_v7.[idfsBaseReference] = tlbVector_v6.[idfsBasisOfRecord] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsSex_v7

		on	


					j_trtBaseReference_idfsSex_v7.[idfsBaseReference] = tlbVector_v6.[idfsSex] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsIdentificationMethod_v7

		on	


					j_trtBaseReference_idfsIdentificationMethod_v7.[idfsBaseReference] = tlbVector_v6.[idfsIdentificationMethod] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsDayPeriod_v7

		on	


					j_trtBaseReference_idfsDayPeriod_v7.[idfsBaseReference] = tlbVector_v6.[idfsDayPeriod] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsEctoparasitesCollected_v7

		on	


					j_trtBaseReference_idfsEctoparasitesCollected_v7.[idfsBaseReference] = tlbVector_v6.[idfsEctoparasitesCollected] 
left join	[Giraffe].[dbo].[tlbVector] tlbVector_v7 
on	

					tlbVector_v7.[idfVector] = tlbVector_v6.[idfVector] 
where tlbVector_v7.[idfVector] is null 
print N'Table [tlbVector] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbVectorSurveillanceSessionSummary]
************************************************************/
insert into [Giraffe].[dbo].[tlbVectorSurveillanceSessionSummary] 

(

					[idfsVSSessionSummary]

					, [idfVectorSurveillanceSession]

					, [strVSSessionSummaryID]

					, [idfGeoLocation]

					, [datCollectionDateTime]

					, [idfsVectorSubType]

					, [idfsSex]

					, [intQuantity]

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

					tlbVectorSurveillanceSessionSummary_v6.[idfsVSSessionSummary]

					, j_tlbVectorSurveillanceSession_idfVectorSurveillanceSession_v7.[idfVectorSurveillanceSession]

					, tlbVectorSurveillanceSessionSummary_v6.[strVSSessionSummaryID]

					, j_tlbGeoLocation_idfGeoLocation_v7.[idfGeoLocation]

					, tlbVectorSurveillanceSessionSummary_v6.[datCollectionDateTime]

					, j_trtVectorSubType_idfsVectorSubType_v7.[idfsVectorSubType]

					, tlbVectorSurveillanceSessionSummary_v6.[idfsSex]

					, tlbVectorSurveillanceSessionSummary_v6.[intQuantity]

					, tlbVectorSurveillanceSessionSummary_v6.[intRowStatus]

					, tlbVectorSurveillanceSessionSummary_v6.[rowguid]

					, tlbVectorSurveillanceSessionSummary_v6.[strMaintenanceFlag]

					, tlbVectorSurveillanceSessionSummary_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsVSSessionSummary":' + isnull(cast(tlbVectorSurveillanceSessionSummary_v6.[idfsVSSessionSummary] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbVectorSurveillanceSessionSummary] tlbVectorSurveillanceSessionSummary_v6 


					inner join	[Giraffe].[dbo].[tlbGeoLocation] j_tlbGeoLocation_idfGeoLocation_v7

		on	


					j_tlbGeoLocation_idfGeoLocation_v7.[idfGeoLocation] = tlbVectorSurveillanceSessionSummary_v6.[idfGeoLocation] 

					inner join	[Giraffe].[dbo].[tlbVectorSurveillanceSession] j_tlbVectorSurveillanceSession_idfVectorSurveillanceSession_v7

		on	


					j_tlbVectorSurveillanceSession_idfVectorSurveillanceSession_v7.[idfVectorSurveillanceSession] = tlbVectorSurveillanceSessionSummary_v6.[idfVectorSurveillanceSession] 

					inner join	[Giraffe].[dbo].[trtVectorSubType] j_trtVectorSubType_idfsVectorSubType_v7

		on	


					j_trtVectorSubType_idfsVectorSubType_v7.[idfsVectorSubType] = tlbVectorSurveillanceSessionSummary_v6.[idfsVectorSubType] 
left join	[Giraffe].[dbo].[tlbVectorSurveillanceSessionSummary] tlbVectorSurveillanceSessionSummary_v7 
on	

					tlbVectorSurveillanceSessionSummary_v7.[idfsVSSessionSummary] = tlbVectorSurveillanceSessionSummary_v6.[idfsVSSessionSummary] 
where tlbVectorSurveillanceSessionSummary_v7.[idfsVSSessionSummary] is null 
print N'Table [tlbVectorSurveillanceSessionSummary] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbVectorSurveillanceSessionSummaryDiagnosis]
************************************************************/
insert into [Giraffe].[dbo].[tlbVectorSurveillanceSessionSummaryDiagnosis] 

(

					[idfsVSSessionSummaryDiagnosis]

					, [idfsVSSessionSummary]

					, [idfsDiagnosis]

					, [intPositiveQuantity]

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

					tlbVectorSurveillanceSessionSummaryDiagnosis_v6.[idfsVSSessionSummaryDiagnosis]

					, j_tlbVectorSurveillanceSessionSummary_idfsVSSessionSummary_v7.[idfsVSSessionSummary]

					, j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis]

					, tlbVectorSurveillanceSessionSummaryDiagnosis_v6.[intPositiveQuantity]

					, tlbVectorSurveillanceSessionSummaryDiagnosis_v6.[intRowStatus]

					, tlbVectorSurveillanceSessionSummaryDiagnosis_v6.[rowguid]

					, tlbVectorSurveillanceSessionSummaryDiagnosis_v6.[strMaintenanceFlag]

					, tlbVectorSurveillanceSessionSummaryDiagnosis_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfsVSSessionSummaryDiagnosis":' + isnull(cast(tlbVectorSurveillanceSessionSummaryDiagnosis_v6.[idfsVSSessionSummaryDiagnosis] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbVectorSurveillanceSessionSummaryDiagnosis] tlbVectorSurveillanceSessionSummaryDiagnosis_v6 


					inner join	[Giraffe].[dbo].[tlbVectorSurveillanceSessionSummary] j_tlbVectorSurveillanceSessionSummary_idfsVSSessionSummary_v7

		on	


					j_tlbVectorSurveillanceSessionSummary_idfsVSSessionSummary_v7.[idfsVSSessionSummary] = tlbVectorSurveillanceSessionSummaryDiagnosis_v6.[idfsVSSessionSummary] 

					inner join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsDiagnosis_v7

		on	


					j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis] = tlbVectorSurveillanceSessionSummaryDiagnosis_v6.[idfsDiagnosis] 
left join	[Giraffe].[dbo].[tlbVectorSurveillanceSessionSummaryDiagnosis] tlbVectorSurveillanceSessionSummaryDiagnosis_v7 
on	

					tlbVectorSurveillanceSessionSummaryDiagnosis_v7.[idfsVSSessionSummaryDiagnosis] = tlbVectorSurveillanceSessionSummaryDiagnosis_v6.[idfsVSSessionSummaryDiagnosis] 
where tlbVectorSurveillanceSessionSummaryDiagnosis_v7.[idfsVSSessionSummaryDiagnosis] is null 
print N'Table [tlbVectorSurveillanceSessionSummaryDiagnosis] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tflVectorSurveillanceSessionFiltered]
************************************************************/
insert into [Giraffe].[dbo].[tflVectorSurveillanceSessionFiltered] 

(

					[idfVectorSurveillanceSessionFiltered]

					, [idfVectorSurveillanceSession]

					, [idfSiteGroup]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tflVectorSurveillanceSessionFiltered_v6.[idfVectorSurveillanceSessionFiltered]

					, j_tlbVectorSurveillanceSession_idfVectorSurveillanceSession_v7.[idfVectorSurveillanceSession]

					, j_tflSiteGroup_idfSiteGroup_v7.[idfSiteGroup]

					, tflVectorSurveillanceSessionFiltered_v6.[rowguid]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfVectorSurveillanceSessionFiltered":' + isnull(cast(tflVectorSurveillanceSessionFiltered_v6.[idfVectorSurveillanceSessionFiltered] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tflVectorSurveillanceSessionFiltered] tflVectorSurveillanceSessionFiltered_v6 


					inner join	[Giraffe].[dbo].[tflSiteGroup] j_tflSiteGroup_idfSiteGroup_v7

		on	


					j_tflSiteGroup_idfSiteGroup_v7.[idfSiteGroup] = tflVectorSurveillanceSessionFiltered_v6.[idfSiteGroup] 

					inner join	[Giraffe].[dbo].[tlbVectorSurveillanceSession] j_tlbVectorSurveillanceSession_idfVectorSurveillanceSession_v7

		on	


					j_tlbVectorSurveillanceSession_idfVectorSurveillanceSession_v7.[idfVectorSurveillanceSession] = tflVectorSurveillanceSessionFiltered_v6.[idfVectorSurveillanceSession] 
left join	[Giraffe].[dbo].[tflVectorSurveillanceSessionFiltered] tflVectorSurveillanceSessionFiltered_v7 
on	

					tflVectorSurveillanceSessionFiltered_v7.[idfVectorSurveillanceSessionFiltered] = tflVectorSurveillanceSessionFiltered_v6.[idfVectorSurveillanceSessionFiltered] 
where tflVectorSurveillanceSessionFiltered_v7.[idfVectorSurveillanceSessionFiltered] is null 
print N'Table [tflVectorSurveillanceSessionFiltered] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbMonitoringSession]
************************************************************/
insert into [Giraffe].[dbo].[tlbMonitoringSession] 

(

					[idfMonitoringSession]

					, [idfsMonitoringSessionStatus]

					, [idfsCountry]

					, [idfsRegion]

					, [idfsRayon]

					, [idfsSettlement]

					, [idfPersonEnteredBy]

					, [idfCampaign]

					, [idfsSite]

					, [datEnteredDate]

					, [strMonitoringSessionID]

					, [intRowStatus]

					, [rowguid]

					, [datModificationForArchiveDate]

					, [datStartDate]

					, [datEndDate]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [SessionCategoryID]

					, [LegacySessionID]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]

					, [idfsLocation]

					, [idfsMonitoringSessionSpeciesType]
)
select 

					tlbMonitoringSession_v6.[idfMonitoringSession]

					, j_trtBaseReference_idfsMonitoringSessionStatus_v7.[idfsBaseReference]

					, j_gisCountry_idfsCountry_v7.[idfsCountry]

					, j_gisRegion_idfsRegion_v7.[idfsRegion]

					, j_gisRayon_idfsRayon_v7.[idfsRayon]

					, j_gisSettlement_idfsSettlement_v7.[idfsSettlement]

					, j_tlbPerson_idfPersonEnteredBy_v7.[idfPerson]

					, j_tlbCampaign_idfCampaign_v7.[idfCampaign]

					, j_tstSite_idfsSite_v7.[idfsSite]

					, tlbMonitoringSession_v6.[datEnteredDate]

					, tlbMonitoringSession_v6.[strMonitoringSessionID]

					, tlbMonitoringSession_v6.[intRowStatus]

					, tlbMonitoringSession_v6.[rowguid]

					, tlbMonitoringSession_v6.[datModificationForArchiveDate]

					, tlbMonitoringSession_v6.[datStartDate]

					, tlbMonitoringSession_v6.[datEndDate]

					, tlbMonitoringSession_v6.[strMaintenanceFlag]

					, tlbMonitoringSession_v6.[strReservedAttribute]

					, null /*TODO: Check the rule for the new field in EIDSSv7: SessionCategoryID*/

					, tlbMonitoringSession_v6.strMonitoringSessionID /*Rule for the new field in EIDSSv7: LegacySessionID*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfMonitoringSession":' + isnull(cast(tlbMonitoringSession_v6.[idfMonitoringSession] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()

					, coalesce(j_gisSettlement_idfsSettlement_v7.[idfsSettlement], j_gisRayon_idfsRayon_v7.[idfsRayon], j_gisRegion_idfsRegion_v7.[idfsRegion], j_gisCountry_idfsCountry_v7.[idfsCountry]) /*Rule for the new field in EIDSSv7: idfsLocation*/

					, null /*TODO: Check the rule for the new field in EIDSSv7: idfsMonitoringSessionSpeciesType*/
from [Falcon].[dbo].[tlbMonitoringSession] tlbMonitoringSession_v6 


					inner join	[Giraffe].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tlbMonitoringSession_v6.[idfsSite] 

					left join	[Giraffe].[dbo].[gisCountry] j_gisCountry_idfsCountry_v7

		on	


					j_gisCountry_idfsCountry_v7.[idfsCountry] = tlbMonitoringSession_v6.[idfsCountry] 

					left join	[Giraffe].[dbo].[gisRayon] j_gisRayon_idfsRayon_v7

		on	


					j_gisRayon_idfsRayon_v7.[idfsRayon] = tlbMonitoringSession_v6.[idfsRayon] 

					left join	[Giraffe].[dbo].[gisRegion] j_gisRegion_idfsRegion_v7

		on	


					j_gisRegion_idfsRegion_v7.[idfsRegion] = tlbMonitoringSession_v6.[idfsRegion] 

					left join	[Giraffe].[dbo].[gisSettlement] j_gisSettlement_idfsSettlement_v7

		on	


					j_gisSettlement_idfsSettlement_v7.[idfsSettlement] = tlbMonitoringSession_v6.[idfsSettlement] 

					left join	[Giraffe].[dbo].[tlbCampaign] j_tlbCampaign_idfCampaign_v7

		on	


					j_tlbCampaign_idfCampaign_v7.[idfCampaign] = tlbMonitoringSession_v6.[idfCampaign] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsMonitoringSessionStatus_v7

		on	


					j_trtBaseReference_idfsMonitoringSessionStatus_v7.[idfsBaseReference] = tlbMonitoringSession_v6.[idfsMonitoringSessionStatus] 

					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfPersonEnteredBy_v7

		on	


					j_tlbPerson_idfPersonEnteredBy_v7.[idfPerson] = tlbMonitoringSession_v6.[idfPersonEnteredBy] 
left join	[Giraffe].[dbo].[tlbMonitoringSession] tlbMonitoringSession_v7 
on	

					tlbMonitoringSession_v7.[idfMonitoringSession] = tlbMonitoringSession_v6.[idfMonitoringSession] 
where tlbMonitoringSession_v7.[idfMonitoringSession] is null 
print N'Table [tlbMonitoringSession] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbMonitoringSessionToDiagnosis]
************************************************************/
insert into [Giraffe].[dbo].[tlbMonitoringSessionToDiagnosis] 

(

					[idfMonitoringSessionToDiagnosis]

					, [idfsDiagnosis]

					, [idfMonitoringSession]

					, [intOrder]

					, [intRowStatus]

					, [rowguid]

					, [idfsSpeciesType]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [idfsSampleType]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]

					, [Comments]
)
select 

					tlbMonitoringSessionToDiagnosis_v6.[idfMonitoringSessionToDiagnosis]

					, j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis]

					, j_tlbMonitoringSession_idfMonitoringSession_v7.[idfMonitoringSession]

					, tlbMonitoringSessionToDiagnosis_v6.[intOrder]

					, tlbMonitoringSessionToDiagnosis_v6.[intRowStatus]

					, tlbMonitoringSessionToDiagnosis_v6.[rowguid]

					, j_trtSpeciesType_idfsSpeciesType_v7.[idfsSpeciesType]

					, tlbMonitoringSessionToDiagnosis_v6.[strMaintenanceFlag]

					, tlbMonitoringSessionToDiagnosis_v6.[strReservedAttribute]

					, j_trtSampleType_idfsSampleType_v7.[idfsSampleType]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfMonitoringSessionToDiagnosis":' + isnull(cast(tlbMonitoringSessionToDiagnosis_v6.[idfMonitoringSessionToDiagnosis] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()

					, null /*TODO: Check the rule for the new field in EIDSSv7: Comments*/
from [Falcon].[dbo].[tlbMonitoringSessionToDiagnosis] tlbMonitoringSessionToDiagnosis_v6 


					inner join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsDiagnosis_v7

		on	


					j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis] = tlbMonitoringSessionToDiagnosis_v6.[idfsDiagnosis] 

					inner join	[Giraffe].[dbo].[tlbMonitoringSession] j_tlbMonitoringSession_idfMonitoringSession_v7

		on	


					j_tlbMonitoringSession_idfMonitoringSession_v7.[idfMonitoringSession] = tlbMonitoringSessionToDiagnosis_v6.[idfMonitoringSession] 

					left join	[Giraffe].[dbo].[trtSpeciesType] j_trtSpeciesType_idfsSpeciesType_v7

		on	


					j_trtSpeciesType_idfsSpeciesType_v7.[idfsSpeciesType] = tlbMonitoringSessionToDiagnosis_v6.[idfsSpeciesType] 

					left join	[Giraffe].[dbo].[trtSampleType] j_trtSampleType_idfsSampleType_v7

		on	


					j_trtSampleType_idfsSampleType_v7.[idfsSampleType] = tlbMonitoringSessionToDiagnosis_v6.[idfsSampleType] 
left join	[Giraffe].[dbo].[tlbMonitoringSessionToDiagnosis] tlbMonitoringSessionToDiagnosis_v7 
on	

					tlbMonitoringSessionToDiagnosis_v7.[idfMonitoringSessionToDiagnosis] = tlbMonitoringSessionToDiagnosis_v6.[idfMonitoringSessionToDiagnosis] 
where tlbMonitoringSessionToDiagnosis_v7.[idfMonitoringSessionToDiagnosis] is null 
print N'Table [tlbMonitoringSessionToDiagnosis] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbMonitoringSessionAction]
************************************************************/
insert into [Giraffe].[dbo].[tlbMonitoringSessionAction] 

(

					[idfMonitoringSessionAction]

					, [idfMonitoringSession]

					, [idfPersonEnteredBy]

					, [idfsMonitoringSessionActionType]

					, [idfsMonitoringSessionActionStatus]

					, [datActionDate]

					, [strComments]

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

					tlbMonitoringSessionAction_v6.[idfMonitoringSessionAction]

					, j_tlbMonitoringSession_idfMonitoringSession_v7.[idfMonitoringSession]

					, j_tlbPerson_idfPersonEnteredBy_v7.[idfPerson]

					, j_trtBaseReference_idfsMonitoringSessionActionType_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsMonitoringSessionActionStatus_v7.[idfsBaseReference]

					, tlbMonitoringSessionAction_v6.[datActionDate]

					, tlbMonitoringSessionAction_v6.[strComments]

					, tlbMonitoringSessionAction_v6.[intRowStatus]

					, tlbMonitoringSessionAction_v6.[rowguid]

					, tlbMonitoringSessionAction_v6.[strMaintenanceFlag]

					, tlbMonitoringSessionAction_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfMonitoringSessionAction":' + isnull(cast(tlbMonitoringSessionAction_v6.[idfMonitoringSessionAction] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbMonitoringSessionAction] tlbMonitoringSessionAction_v6 


					inner join	[Giraffe].[dbo].[tlbMonitoringSession] j_tlbMonitoringSession_idfMonitoringSession_v7

		on	


					j_tlbMonitoringSession_idfMonitoringSession_v7.[idfMonitoringSession] = tlbMonitoringSessionAction_v6.[idfMonitoringSession] 

					inner join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfPersonEnteredBy_v7

		on	


					j_tlbPerson_idfPersonEnteredBy_v7.[idfPerson] = tlbMonitoringSessionAction_v6.[idfPersonEnteredBy] 

					inner join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsMonitoringSessionActionType_v7

		on	


					j_trtBaseReference_idfsMonitoringSessionActionType_v7.[idfsBaseReference] = tlbMonitoringSessionAction_v6.[idfsMonitoringSessionActionType] 

					inner join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsMonitoringSessionActionStatus_v7

		on	


					j_trtBaseReference_idfsMonitoringSessionActionStatus_v7.[idfsBaseReference] = tlbMonitoringSessionAction_v6.[idfsMonitoringSessionActionStatus] 
left join	[Giraffe].[dbo].[tlbMonitoringSessionAction] tlbMonitoringSessionAction_v7 
on	

					tlbMonitoringSessionAction_v7.[idfMonitoringSessionAction] = tlbMonitoringSessionAction_v6.[idfMonitoringSessionAction] 
where tlbMonitoringSessionAction_v7.[idfMonitoringSessionAction] is null 
print N'Table [tlbMonitoringSessionAction] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbMonitoringSessionSummary]
************************************************************/
insert into [Giraffe].[dbo].[tlbMonitoringSessionSummary] 

(

					[idfMonitoringSessionSummary]

					, [idfMonitoringSession]

					, [idfFarm]

					, [idfSpecies]

					, [idfsAnimalSex]

					, [intSampledAnimalsQty]

					, [intSamplesQty]

					, [datCollectionDate]

					, [intPositiveAnimalsQty]

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

					tlbMonitoringSessionSummary_v6.[idfMonitoringSessionSummary]

					, j_tlbMonitoringSession_idfMonitoringSession_v7.[idfMonitoringSession]

					, j_tlbFarm_idfFarm_v7.[idfFarm]

					, j_tlbSpecies_idfSpecies_v7.[idfSpecies]

					, j_trtBaseReference_idfsAnimalSex_v7.[idfsBaseReference]

					, tlbMonitoringSessionSummary_v6.[intSampledAnimalsQty]

					, tlbMonitoringSessionSummary_v6.[intSamplesQty]

					, tlbMonitoringSessionSummary_v6.[datCollectionDate]

					, tlbMonitoringSessionSummary_v6.[intPositiveAnimalsQty]

					, tlbMonitoringSessionSummary_v6.[intRowStatus]

					, tlbMonitoringSessionSummary_v6.[rowguid]

					, tlbMonitoringSessionSummary_v6.[strMaintenanceFlag]

					, tlbMonitoringSessionSummary_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfMonitoringSessionSummary":' + isnull(cast(tlbMonitoringSessionSummary_v6.[idfMonitoringSessionSummary] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbMonitoringSessionSummary] tlbMonitoringSessionSummary_v6 


					inner join	[Giraffe].[dbo].[tlbFarm] j_tlbFarm_idfFarm_v7

		on	


					j_tlbFarm_idfFarm_v7.[idfFarm] = tlbMonitoringSessionSummary_v6.[idfFarm] 

					inner join	[Giraffe].[dbo].[tlbMonitoringSession] j_tlbMonitoringSession_idfMonitoringSession_v7

		on	


					j_tlbMonitoringSession_idfMonitoringSession_v7.[idfMonitoringSession] = tlbMonitoringSessionSummary_v6.[idfMonitoringSession] 

					left join	[Giraffe].[dbo].[tlbSpecies] j_tlbSpecies_idfSpecies_v7

		on	


					j_tlbSpecies_idfSpecies_v7.[idfSpecies] = tlbMonitoringSessionSummary_v6.[idfSpecies] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsAnimalSex_v7

		on	


					j_trtBaseReference_idfsAnimalSex_v7.[idfsBaseReference] = tlbMonitoringSessionSummary_v6.[idfsAnimalSex] 
left join	[Giraffe].[dbo].[tlbMonitoringSessionSummary] tlbMonitoringSessionSummary_v7 
on	

					tlbMonitoringSessionSummary_v7.[idfMonitoringSessionSummary] = tlbMonitoringSessionSummary_v6.[idfMonitoringSessionSummary] 
where tlbMonitoringSessionSummary_v7.[idfMonitoringSessionSummary] is null 
print N'Table [tlbMonitoringSessionSummary] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbMonitoringSessionSummaryDiagnosis]
************************************************************/
insert into [Giraffe].[dbo].[tlbMonitoringSessionSummaryDiagnosis] 

(

					[idfMonitoringSessionSummary]

					, [idfsDiagnosis]

					, [intRowStatus]

					, [rowguid]

					, [blnChecked]

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

					j_tlbMonitoringSessionSummary_idfMonitoringSessionSummary_v7.[idfMonitoringSessionSummary]

					, j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis]

					, tlbMonitoringSessionSummaryDiagnosis_v6.[intRowStatus]

					, tlbMonitoringSessionSummaryDiagnosis_v6.[rowguid]

					, tlbMonitoringSessionSummaryDiagnosis_v6.[blnChecked]

					, tlbMonitoringSessionSummaryDiagnosis_v6.[strMaintenanceFlag]

					, tlbMonitoringSessionSummaryDiagnosis_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfMonitoringSessionSummary":' + isnull(cast(tlbMonitoringSessionSummaryDiagnosis_v6.[idfMonitoringSessionSummary] as nvarchar(20)), N'null') + N',' + N'"idfsDiagnosis":' + isnull(cast(tlbMonitoringSessionSummaryDiagnosis_v6.[idfsDiagnosis] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbMonitoringSessionSummaryDiagnosis] tlbMonitoringSessionSummaryDiagnosis_v6 


					inner join	[Giraffe].[dbo].[tlbMonitoringSessionSummary] j_tlbMonitoringSessionSummary_idfMonitoringSessionSummary_v7

		on	


					j_tlbMonitoringSessionSummary_idfMonitoringSessionSummary_v7.[idfMonitoringSessionSummary] = tlbMonitoringSessionSummaryDiagnosis_v6.[idfMonitoringSessionSummary] 

					inner join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsDiagnosis_v7

		on	


					j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis] = tlbMonitoringSessionSummaryDiagnosis_v6.[idfsDiagnosis] 
left join	[Giraffe].[dbo].[tlbMonitoringSessionSummaryDiagnosis] tlbMonitoringSessionSummaryDiagnosis_v7 
on	

					tlbMonitoringSessionSummaryDiagnosis_v7.[idfMonitoringSessionSummary] = tlbMonitoringSessionSummaryDiagnosis_v6.[idfMonitoringSessionSummary] 

					and tlbMonitoringSessionSummaryDiagnosis_v7.[idfsDiagnosis] = tlbMonitoringSessionSummaryDiagnosis_v6.[idfsDiagnosis] 
where tlbMonitoringSessionSummaryDiagnosis_v7.[idfMonitoringSessionSummary] is null 
print N'Table [tlbMonitoringSessionSummaryDiagnosis] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbMonitoringSessionSummarySample]
************************************************************/
insert into [Giraffe].[dbo].[tlbMonitoringSessionSummarySample] 

(

					[idfMonitoringSessionSummary]

					, [idfsSampleType]

					, [intRowStatus]

					, [rowguid]

					, [blnChecked]

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

					j_tlbMonitoringSessionSummary_idfMonitoringSessionSummary_v7.[idfMonitoringSessionSummary]

					, j_trtSampleType_idfsSampleType_v7.[idfsSampleType]

					, tlbMonitoringSessionSummarySample_v6.[intRowStatus]

					, tlbMonitoringSessionSummarySample_v6.[rowguid]

					, tlbMonitoringSessionSummarySample_v6.[blnChecked]

					, tlbMonitoringSessionSummarySample_v6.[strMaintenanceFlag]

					, tlbMonitoringSessionSummarySample_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfMonitoringSessionSummary":' + isnull(cast(tlbMonitoringSessionSummarySample_v6.[idfMonitoringSessionSummary] as nvarchar(20)), N'null') + N',' + N'"idfsSampleType":' + isnull(cast(tlbMonitoringSessionSummarySample_v6.[idfsSampleType] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbMonitoringSessionSummarySample] tlbMonitoringSessionSummarySample_v6 


					inner join	[Giraffe].[dbo].[tlbMonitoringSessionSummary] j_tlbMonitoringSessionSummary_idfMonitoringSessionSummary_v7

		on	


					j_tlbMonitoringSessionSummary_idfMonitoringSessionSummary_v7.[idfMonitoringSessionSummary] = tlbMonitoringSessionSummarySample_v6.[idfMonitoringSessionSummary] 

					inner join	[Giraffe].[dbo].[trtSampleType] j_trtSampleType_idfsSampleType_v7

		on	


					j_trtSampleType_idfsSampleType_v7.[idfsSampleType] = tlbMonitoringSessionSummarySample_v6.[idfsSampleType] 
left join	[Giraffe].[dbo].[tlbMonitoringSessionSummarySample] tlbMonitoringSessionSummarySample_v7 
on	

					tlbMonitoringSessionSummarySample_v7.[idfMonitoringSessionSummary] = tlbMonitoringSessionSummarySample_v6.[idfMonitoringSessionSummary] 

					and tlbMonitoringSessionSummarySample_v7.[idfsSampleType] = tlbMonitoringSessionSummarySample_v6.[idfsSampleType] 
where tlbMonitoringSessionSummarySample_v7.[idfMonitoringSessionSummary] is null 
print N'Table [tlbMonitoringSessionSummarySample] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tflMonitoringSessionFiltered]
************************************************************/
insert into [Giraffe].[dbo].[tflMonitoringSessionFiltered] 

(

					[idfMonitoringSessionFiltered]

					, [idfMonitoringSession]

					, [idfSiteGroup]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tflMonitoringSessionFiltered_v6.[idfMonitoringSessionFiltered]

					, j_tlbMonitoringSession_idfMonitoringSession_v7.[idfMonitoringSession]

					, j_tflSiteGroup_idfSiteGroup_v7.[idfSiteGroup]

					, tflMonitoringSessionFiltered_v6.[rowguid]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfMonitoringSessionFiltered":' + isnull(cast(tflMonitoringSessionFiltered_v6.[idfMonitoringSessionFiltered] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tflMonitoringSessionFiltered] tflMonitoringSessionFiltered_v6 


					inner join	[Giraffe].[dbo].[tlbMonitoringSession] j_tlbMonitoringSession_idfMonitoringSession_v7

		on	


					j_tlbMonitoringSession_idfMonitoringSession_v7.[idfMonitoringSession] = tflMonitoringSessionFiltered_v6.[idfMonitoringSession] 

					inner join	[Giraffe].[dbo].[tflSiteGroup] j_tflSiteGroup_idfSiteGroup_v7

		on	


					j_tflSiteGroup_idfSiteGroup_v7.[idfSiteGroup] = tflMonitoringSessionFiltered_v6.[idfSiteGroup] 
left join	[Giraffe].[dbo].[tflMonitoringSessionFiltered] tflMonitoringSessionFiltered_v7 
on	

					tflMonitoringSessionFiltered_v7.[idfMonitoringSessionFiltered] = tflMonitoringSessionFiltered_v6.[idfMonitoringSessionFiltered] 
where tflMonitoringSessionFiltered_v7.[idfMonitoringSessionFiltered] is null 
print N'Table [tflMonitoringSessionFiltered] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbHumanCase]
************************************************************/
insert into [Giraffe].[dbo].[tlbHumanCase] 

(

					[idfHumanCase]

					, [idfHuman]

					, [idfsFinalState]

					, [idfsHospitalizationStatus]

					, [idfsHumanAgeType]

					, [idfsYNAntimicrobialTherapy]

					, [idfsYNHospitalization]

					, [idfsYNSpecimenCollected]

					, [idfsYNRelatedToOutbreak]

					, [idfsOutcome]

					, [idfsTentativeDiagnosis]

					, [idfsFinalDiagnosis]

					, [idfsInitialCaseStatus]

					, [idfsFinalCaseStatus]

					, [idfSentByOffice]

					, [idfReceivedByOffice]

					, [idfInvestigatedByOffice]

					, [idfPointGeoLocation]

					, [idfEpiObservation]

					, [idfCSObservation]

					, [idfDeduplicationResultCase]

					, [datNotificationDate]

					, [datCompletionPaperFormDate]

					, [datFirstSoughtCareDate]

					, [datModificationDate]

					, [datHospitalizationDate]

					, [datFacilityLastVisit]

					, [datExposureDate]

					, [datDischargeDate]

					, [datOnSetDate]

					, [datInvestigationStartDate]

					, [datTentativeDiagnosisDate]

					, [datFinalDiagnosisDate]

					, [strNote]

					, [strCurrentLocation]

					, [strHospitalizationPlace]

					, [strLocalIdentifier]

					, [strSoughtCareFacility]

					, [strSentByFirstName]

					, [strSentByPatronymicName]

					, [strSentByLastName]

					, [strReceivedByFirstName]

					, [strReceivedByPatronymicName]

					, [strReceivedByLastName]

					, [strEpidemiologistsName]

					, [strNotCollectedReason]

					, [strClinicalDiagnosis]

					, [strClinicalNotes]

					, [strSummaryNotes]

					, [intPatientAge]

					, [blnClinicalDiagBasis]

					, [blnLabDiagBasis]

					, [blnEpiDiagBasis]

					, [rowguid]

					, [idfPersonEnteredBy]

					, [idfSentByPerson]

					, [idfReceivedByPerson]

					, [idfInvestigatedByPerson]

					, [idfsYNTestsConducted]

					, [intRowStatus]

					, [idfSoughtCareFacility]

					, [idfsNonNotifiableDiagnosis]

					, [idfsNotCollectedReason]

					, [idfOutbreak]

					, [datEnteredDate]

					, [strCaseID]

					, [idfsCaseProgressStatus]

					, [idfsSite]

					, [strSampleNotes]

					, [datModificationForArchiveDate]

					, [uidOfflineCaseID]

					, [datFinalCaseClassificationDate]

					, [idfHospital]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [idfsYNSpecificVaccinationAdministered]

					, [idfsYNPreviouslySoughtCare]

					, [idfsYNExposureLocationKnown]

					, [LegacyCaseID]

					, [DiseaseReportTypeID]

					, [idfParentMonitoringSession]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					cchc.idfHumanCase_v7

					, j_tlbHuman_idfHuman_v7.[idfHuman]

					, j_trtBaseReference_idfsFinalState_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsHospitalizationStatus_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsHumanAgeType_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsYNAntimicrobialTherapy_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsYNHospitalization_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsYNSpecimenCollected_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsYNRelatedToOutbreak_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsOutcome_v7.[idfsBaseReference]

					, j_trtDiagnosis_idfsTentativeDiagnosis_v7.[idfsDiagnosis]

					, j_trtDiagnosis_idfsFinalDiagnosis_v7.[idfsDiagnosis]

					, j_trtBaseReference_idfsInitialCaseStatus_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsFinalCaseStatus_v7.[idfsBaseReference]

					, j_tlbOffice_idfSentByOffice_v7.[idfOffice]

					, j_tlbOffice_idfReceivedByOffice_v7.[idfOffice]

					, j_tlbOffice_idfInvestigatedByOffice_v7.[idfOffice]

					, j_tlbGeoLocation_idfPointGeoLocation_v7.[idfGeoLocation]

					, j_tlbObservation_idfEpiObservation_v7.[idfObservation]

					, j_tlbObservation_idfCSObservation_v7.[idfObservation]

					, null /*Will be updated below when foreign key data is available*/

					, tlbHumanCase_v6.[datNotificationDate]

					, tlbHumanCase_v6.[datCompletionPaperFormDate]

					, tlbHumanCase_v6.[datFirstSoughtCareDate]

					, tlbHumanCase_v6.[datModificationDate]

					, tlbHumanCase_v6.[datHospitalizationDate]

					, tlbHumanCase_v6.[datFacilityLastVisit]

					, tlbHumanCase_v6.[datExposureDate]

					, tlbHumanCase_v6.[datDischargeDate]

					, tlbHumanCase_v6.[datOnSetDate]

					, tlbHumanCase_v6.[datInvestigationStartDate]

					, cchc.[datTentativeDiagnosisDate]

					, cchc.[datFinalDiagnosisDate]

					, cchc.[strNote]

					, tlbHumanCase_v6.[strCurrentLocation]

					, tlbHumanCase_v6.[strHospitalizationPlace]

					, tlbHumanCase_v6.[strLocalIdentifier]

					, tlbHumanCase_v6.[strSoughtCareFacility]

					, tlbHumanCase_v6.[strSentByFirstName]

					, tlbHumanCase_v6.[strSentByPatronymicName]

					, tlbHumanCase_v6.[strSentByLastName]

					, tlbHumanCase_v6.[strReceivedByFirstName]

					, tlbHumanCase_v6.[strReceivedByPatronymicName]

					, tlbHumanCase_v6.[strReceivedByLastName]

					, tlbHumanCase_v6.[strEpidemiologistsName]

					, tlbHumanCase_v6.[strNotCollectedReason]

					, tlbHumanCase_v6.[strClinicalDiagnosis]

					, tlbHumanCase_v6.[strClinicalNotes]

					, tlbHumanCase_v6.[strSummaryNotes]

					, tlbHumanCase_v6.[intPatientAge]

					, cchc.[blnClinicalDiagBasis_v7]

					, cchc.[blnLabDiagBasis_v7]

					, cchc.[blnEpiDiagBasis_v7]

					, tlbHumanCase_v6.[rowguid]

					, j_tlbPerson_idfPersonEnteredBy_v7.[idfPerson]

					, j_tlbPerson_idfSentByPerson_v7.[idfPerson]

					, j_tlbPerson_idfReceivedByPerson_v7.[idfPerson]

					, j_tlbPerson_idfInvestigatedByPerson_v7.[idfPerson]

					, j_trtBaseReference_idfsYNTestsConducted_v7.[idfsBaseReference]

					, tlbHumanCase_v6.[intRowStatus]

					, j_tlbOffice_idfSoughtCareFacility_v7.[idfOffice]

					, j_trtBaseReference_idfsNonNotifiableDiagnosis_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsNotCollectedReason_v7.[idfsBaseReference]

					, j_tlbOutbreak_idfOutbreak_v7.[idfOutbreak]

					, tlbHumanCase_v6.[datEnteredDate]

					, cchc.[strCaseID_v7]

					, j_trtBaseReference_idfsCaseProgressStatus_v7.[idfsBaseReference]

					, j_tstSite_idfsSite_v7.[idfsSite]

					, tlbHumanCase_v6.[strSampleNotes]

					, tlbHumanCase_v6.[datModificationForArchiveDate]

					, tlbHumanCase_v6.[uidOfflineCaseID]

					, cchc.[datFinalCaseClassificationDate_v7]

					, j_tlbOffice_idfHospital_v7.[idfOffice]

					, tlbHumanCase_v6.[strMaintenanceFlag]

					, tlbHumanCase_v6.[strReservedAttribute]

					, null /*TODO: Check the rule for the new field in EIDSSv7: idfsYNSpecificVaccinationAdministered*/

					, case when j_tlbOffice_idfSoughtCareFacility_v7.[idfOffice] is not null or tlbHumanCase_v6.[datFirstSoughtCareDate] is not null or j_trtBaseReference_idfsNonNotifiableDiagnosis_v7.[idfsBaseReference] is not null then 10100001 /*Yes*/ else null end /*Rule for the new field in EIDSSv7: idfsYNPreviouslySoughtCare*/

					, case when (j_tlbGeoLocation_idfPointGeoLocation_v7.[idfsLocation] is not null and j_tlbGeoLocation_idfPointGeoLocation_v7.[idfsLocation] <> @idfsCountry) or j_tlbGeoLocation_idfPointGeoLocation_v7.[blnForeignAddress] = 1 or tlbHumanCase_v6.[datExposureDate] is not null then 10100001 /*Yes*/ else null end /*Rule for the new field in EIDSSv7: idfsYNExposureLocationKnown*/

					, cchc.strLegacyID_v6 /*Rule for the new field in EIDSSv7: LegacyCaseID*/

					, cchc.DiseaseReportTypeID_v7 /*Rule for the new field in EIDSSv7: DiseaseReportTypeID*/

					, null /*TODO: Check the rule for the new field in EIDSSv7: idfParentMonitoringSession*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfHumanCase":' + isnull(cast(cchc.idfHumanCase_v7 as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbHumanCase] tlbHumanCase_v6
inner join	[Giraffe].[dbo].[_dmccHumanCase] cchc
on			cchc.idfHumanCase_v6 = tlbHumanCase_v6.[idfHumanCase] 


					inner join	[Giraffe].[dbo].[tlbHuman] j_tlbHuman_idfHuman_v7

		on	


					j_tlbHuman_idfHuman_v7.[idfHuman] = cchc.[idfHuman_v7] 

					inner join	[Giraffe].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tlbHumanCase_v6.[idfsSite] 

					left join	[Giraffe].[dbo].[tlbGeoLocation] j_tlbGeoLocation_idfPointGeoLocation_v7

		on	


					j_tlbGeoLocation_idfPointGeoLocation_v7.[idfGeoLocation] = cchc.[idfPointGeoLocation_v7] 

					left join	[Giraffe].[dbo].[tlbHumanCase] j_tlbHumanCase_idfDeduplicationResultCase_v7

		on	


					j_tlbHumanCase_idfDeduplicationResultCase_v7.[idfHumanCase] = tlbHumanCase_v6.[idfDeduplicationResultCase] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsFinalState_v7

		on	


					j_trtBaseReference_idfsFinalState_v7.[idfsBaseReference] = tlbHumanCase_v6.[idfsFinalState] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsHospitalizationStatus_v7

		on	


					j_trtBaseReference_idfsHospitalizationStatus_v7.[idfsBaseReference] = tlbHumanCase_v6.[idfsHospitalizationStatus] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsHumanAgeType_v7

		on	


					j_trtBaseReference_idfsHumanAgeType_v7.[idfsBaseReference] = tlbHumanCase_v6.[idfsHumanAgeType] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsYNAntimicrobialTherapy_v7

		on	


					j_trtBaseReference_idfsYNAntimicrobialTherapy_v7.[idfsBaseReference] = tlbHumanCase_v6.[idfsYNAntimicrobialTherapy] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsYNHospitalization_v7

		on	


					j_trtBaseReference_idfsYNHospitalization_v7.[idfsBaseReference] = tlbHumanCase_v6.[idfsYNHospitalization] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsYNSpecimenCollected_v7

		on	


					j_trtBaseReference_idfsYNSpecimenCollected_v7.[idfsBaseReference] = tlbHumanCase_v6.[idfsYNSpecimenCollected] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsYNRelatedToOutbreak_v7

		on	


					j_trtBaseReference_idfsYNRelatedToOutbreak_v7.[idfsBaseReference] = tlbHumanCase_v6.[idfsYNRelatedToOutbreak] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsOutcome_v7

		on	


					j_trtBaseReference_idfsOutcome_v7.[idfsBaseReference] = tlbHumanCase_v6.[idfsOutcome] 

					left join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsTentativeDiagnosis_v7

		on	


					j_trtDiagnosis_idfsTentativeDiagnosis_v7.[idfsDiagnosis] = cchc.[idfsTentativeDiagnosis] 

					left join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsFinalDiagnosis_v7

		on	


					j_trtDiagnosis_idfsFinalDiagnosis_v7.[idfsDiagnosis] = cchc.[idfsFinalDiagnosis] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsInitialCaseStatus_v7

		on	


					j_trtBaseReference_idfsInitialCaseStatus_v7.[idfsBaseReference] = tlbHumanCase_v6.[idfsInitialCaseStatus] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsFinalCaseStatus_v7

		on	


					j_trtBaseReference_idfsFinalCaseStatus_v7.[idfsBaseReference] = cchc.[idfsFinalCaseStatus_v7] 

					left join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfSentByOffice_v7

		on	


					j_tlbOffice_idfSentByOffice_v7.[idfOffice] = tlbHumanCase_v6.[idfSentByOffice] 

					left join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfReceivedByOffice_v7

		on	


					j_tlbOffice_idfReceivedByOffice_v7.[idfOffice] = tlbHumanCase_v6.[idfReceivedByOffice] 

					left join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfInvestigatedByOffice_v7

		on	


					j_tlbOffice_idfInvestigatedByOffice_v7.[idfOffice] = tlbHumanCase_v6.[idfInvestigatedByOffice] 

					left join	[Giraffe].[dbo].[tlbObservation] j_tlbObservation_idfEpiObservation_v7

		on	


					j_tlbObservation_idfEpiObservation_v7.[idfObservation] = cchc.[idfEpiObservation_v7] 

					left join	[Giraffe].[dbo].[tlbObservation] j_tlbObservation_idfCSObservation_v7

		on	


					j_tlbObservation_idfCSObservation_v7.[idfObservation] = cchc.[idfCSObservation_v7] 

					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfPersonEnteredBy_v7

		on	


					j_tlbPerson_idfPersonEnteredBy_v7.[idfPerson] = tlbHumanCase_v6.[idfPersonEnteredBy] 

					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfSentByPerson_v7

		on	


					j_tlbPerson_idfSentByPerson_v7.[idfPerson] = tlbHumanCase_v6.[idfSentByPerson] 

					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfReceivedByPerson_v7

		on	


					j_tlbPerson_idfReceivedByPerson_v7.[idfPerson] = tlbHumanCase_v6.[idfReceivedByPerson] 

					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfInvestigatedByPerson_v7

		on	


					j_tlbPerson_idfInvestigatedByPerson_v7.[idfPerson] = tlbHumanCase_v6.[idfInvestigatedByPerson] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsYNTestsConducted_v7

		on	


					j_trtBaseReference_idfsYNTestsConducted_v7.[idfsBaseReference] = tlbHumanCase_v6.[idfsYNTestsConducted] 

					left join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfSoughtCareFacility_v7

		on	


					j_tlbOffice_idfSoughtCareFacility_v7.[idfOffice] = tlbHumanCase_v6.[idfSoughtCareFacility] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsNonNotifiableDiagnosis_v7

		on	


					j_trtBaseReference_idfsNonNotifiableDiagnosis_v7.[idfsBaseReference] = tlbHumanCase_v6.[idfsNonNotifiableDiagnosis] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsNotCollectedReason_v7

		on	


					j_trtBaseReference_idfsNotCollectedReason_v7.[idfsBaseReference] = tlbHumanCase_v6.[idfsNotCollectedReason] 

					left join	[Giraffe].[dbo].[tlbOutbreak] j_tlbOutbreak_idfOutbreak_v7

		on	


					j_tlbOutbreak_idfOutbreak_v7.[idfOutbreak] = cchc.[idfOutbreak_v7] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsCaseProgressStatus_v7

		on	


					j_trtBaseReference_idfsCaseProgressStatus_v7.[idfsBaseReference] = cchc.[idfsCaseProgressStatus_v7] 

					left join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfHospital_v7

		on	


					j_tlbOffice_idfHospital_v7.[idfOffice] = tlbHumanCase_v6.[idfHospital] 
left join	[Giraffe].[dbo].[tlbHumanCase] tlbHumanCase_v7 
on	

					tlbHumanCase_v7.[idfHumanCase] = cchc.idfHumanCase_v7 
where tlbHumanCase_v7.[idfHumanCase] is null 
print N'Table [tlbHumanCase] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbAntimicrobialTherapy]
************************************************************/
insert into [Giraffe].[dbo].[tlbAntimicrobialTherapy] 

(

					[idfAntimicrobialTherapy]

					, [idfHumanCase]

					, [datFirstAdministeredDate]

					, [strAntimicrobialTherapyName]

					, [strDosage]

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

					isnull(ccat.idfAntimicrobialTherapy_v7, tlbAntimicrobialTherapy_v6.[idfAntimicrobialTherapy])

					, j_tlbHumanCase_idfHumanCase_v7.[idfHumanCase]

					, tlbAntimicrobialTherapy_v6.[datFirstAdministeredDate]

					, tlbAntimicrobialTherapy_v6.[strAntimicrobialTherapyName]

					, tlbAntimicrobialTherapy_v6.[strDosage]

					, tlbAntimicrobialTherapy_v6.[intRowStatus]

					, tlbAntimicrobialTherapy_v6.[rowguid]

					, tlbAntimicrobialTherapy_v6.[strMaintenanceFlag]

					, tlbAntimicrobialTherapy_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfAntimicrobialTherapy":' + isnull(cast(isnull(ccat.idfAntimicrobialTherapy_v7, tlbAntimicrobialTherapy_v6.[idfAntimicrobialTherapy]) as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbAntimicrobialTherapy] tlbAntimicrobialTherapy_v6
inner join	[Giraffe].[dbo].[_dmccAntimicrobialTherapy] ccat
on			ccat.idfAntimicrobialTherapy_v6 = tlbAntimicrobialTherapy_v6.[idfAntimicrobialTherapy] 


					inner join	[Giraffe].[dbo].[tlbHumanCase] j_tlbHumanCase_idfHumanCase_v7

		on	


					j_tlbHumanCase_idfHumanCase_v7.[idfHumanCase] = ccat.idfHumanCase_v7 
left join	[Giraffe].[dbo].[tlbAntimicrobialTherapy] tlbAntimicrobialTherapy_v7 
on	

					tlbAntimicrobialTherapy_v7.[idfAntimicrobialTherapy] = isnull(ccat.idfAntimicrobialTherapy_v7, tlbAntimicrobialTherapy_v6.[idfAntimicrobialTherapy]) 
where tlbAntimicrobialTherapy_v7.[idfAntimicrobialTherapy] is null 
print N'Table [tlbAntimicrobialTherapy] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbChangeDiagnosisHistory]
************************************************************/
insert into [Giraffe].[dbo].[tlbChangeDiagnosisHistory] 

(

					[idfChangeDiagnosisHistory]

					, [idfHumanCase]

					, [idfsPreviousDiagnosis]

					, [idfsCurrentDiagnosis]

					, [datChangedDate]

					, [strReason]

					, [intRowStatus]

					, [rowguid]

					, [idfsChangeDiagnosisReason]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [idfPerson]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tlbChangeDiagnosisHistory_v6.[idfChangeDiagnosisHistory]

					, j_tlbHumanCase_idfHumanCase_v7.[idfHumanCase]

					, j_trtDiagnosis_idfsPreviousDiagnosis_v7.[idfsDiagnosis]

					, j_trtDiagnosis_idfsCurrentDiagnosis_v7.[idfsDiagnosis]

					, tlbChangeDiagnosisHistory_v6.[datChangedDate]

					, tlbChangeDiagnosisHistory_v6.[strReason]

					, tlbChangeDiagnosisHistory_v6.[intRowStatus]

					, tlbChangeDiagnosisHistory_v6.[rowguid]

					, j_trtBaseReference_idfsChangeDiagnosisReason_v7.[idfsBaseReference]

					, tlbChangeDiagnosisHistory_v6.[strMaintenanceFlag]

					, tlbChangeDiagnosisHistory_v6.[strReservedAttribute]

					, j_tlbPerson_idfPerson_v7.[idfPerson]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfChangeDiagnosisHistory":' + isnull(cast(tlbChangeDiagnosisHistory_v6.[idfChangeDiagnosisHistory] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbChangeDiagnosisHistory] tlbChangeDiagnosisHistory_v6 


					inner join	[Giraffe].[dbo].[tlbHumanCase] j_tlbHumanCase_idfHumanCase_v7

		on	


					j_tlbHumanCase_idfHumanCase_v7.[idfHumanCase] = tlbChangeDiagnosisHistory_v6.[idfHumanCase] 

					inner join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfPerson_v7

		on	


					j_tlbPerson_idfPerson_v7.[idfPerson] = tlbChangeDiagnosisHistory_v6.[idfPerson] 

					left join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsPreviousDiagnosis_v7

		on	


					j_trtDiagnosis_idfsPreviousDiagnosis_v7.[idfsDiagnosis] = tlbChangeDiagnosisHistory_v6.[idfsPreviousDiagnosis] 

					left join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsCurrentDiagnosis_v7

		on	


					j_trtDiagnosis_idfsCurrentDiagnosis_v7.[idfsDiagnosis] = tlbChangeDiagnosisHistory_v6.[idfsCurrentDiagnosis] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsChangeDiagnosisReason_v7

		on	


					j_trtBaseReference_idfsChangeDiagnosisReason_v7.[idfsBaseReference] = tlbChangeDiagnosisHistory_v6.[idfsChangeDiagnosisReason] 
left join	[Giraffe].[dbo].[tlbChangeDiagnosisHistory] tlbChangeDiagnosisHistory_v7 
on	

					tlbChangeDiagnosisHistory_v7.[idfChangeDiagnosisHistory] = tlbChangeDiagnosisHistory_v6.[idfChangeDiagnosisHistory] 
where tlbChangeDiagnosisHistory_v7.[idfChangeDiagnosisHistory] is null 
print N'Table [tlbChangeDiagnosisHistory] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbContactedCasePerson]
************************************************************/
insert into [Giraffe].[dbo].[tlbContactedCasePerson] 

(

					[idfContactedCasePerson]

					, [idfsPersonContactType]

					, [idfHuman]

					, [idfHumanCase]

					, [datDateOfLastContact]

					, [strPlaceInfo]

					, [intRowStatus]

					, [rowguid]

					, [strComments]

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

					isnull(ccccp.idfContactedCasePerson_v7, tlbContactedCasePerson_v6.[idfContactedCasePerson])

					, j_trtBaseReference_idfsPersonContactType_v7.[idfsBaseReference]

					, j_tlbHuman_idfHuman_v7.[idfHuman]

					, j_tlbHumanCase_idfHumanCase_v7.[idfHumanCase]

					, tlbContactedCasePerson_v6.[datDateOfLastContact]

					, tlbContactedCasePerson_v6.[strPlaceInfo]

					, tlbContactedCasePerson_v6.[intRowStatus]

					, tlbContactedCasePerson_v6.[rowguid]

					, tlbContactedCasePerson_v6.[strComments]

					, tlbContactedCasePerson_v6.[strMaintenanceFlag]

					, tlbContactedCasePerson_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfContactedCasePerson":' + isnull(cast(isnull(ccccp.idfContactedCasePerson_v7, tlbContactedCasePerson_v6.[idfContactedCasePerson]) as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbContactedCasePerson] tlbContactedCasePerson_v6
inner join	[Giraffe].[dbo].[_dmccContactedCasePerson] ccccp
on			ccccp.idfContactedCasePerson_v6 = tlbContactedCasePerson_v6.[idfContactedCasePerson] 


					inner join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsPersonContactType_v7

		on	


					j_trtBaseReference_idfsPersonContactType_v7.[idfsBaseReference] = tlbContactedCasePerson_v6.[idfsPersonContactType] 

					inner join	[Giraffe].[dbo].[tlbHuman] j_tlbHuman_idfHuman_v7

		on	


					j_tlbHuman_idfHuman_v7.[idfHuman] = ccccp.idfHuman_v7 

					inner join	[Giraffe].[dbo].[tlbHumanCase] j_tlbHumanCase_idfHumanCase_v7

		on	


					j_tlbHumanCase_idfHumanCase_v7.[idfHumanCase] = ccccp.idfHumanCase_v7 
left join	[Giraffe].[dbo].[tlbContactedCasePerson] tlbContactedCasePerson_v7 
on	

					tlbContactedCasePerson_v7.[idfContactedCasePerson] = ccccp.idfContactedCasePerson_v7 
where tlbContactedCasePerson_v7.[idfContactedCasePerson] is null 
print N'Table [tlbContactedCasePerson] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tflHumanCaseFilitered]
************************************************************/








/************************************************************
* Insert records - [tlbVetCase]
************************************************************/
insert into [Giraffe].[dbo].[tlbVetCase] 

(

					[idfVetCase]

					, [idfFarm]

					, [idfsTentativeDiagnosis]

					, [idfsTentativeDiagnosis1]

					, [idfsTentativeDiagnosis2]

					, [idfsFinalDiagnosis]

					, [idfPersonEnteredBy]

					, [idfPersonReportedBy]

					, [idfPersonInvestigatedBy]

					, [idfObservation]

					, [idfsSite]

					, [datReportDate]

					, [datAssignedDate]

					, [datInvestigationDate]

					, [datTentativeDiagnosisDate]

					, [datTentativeDiagnosis1Date]

					, [datTentativeDiagnosis2Date]

					, [datFinalDiagnosisDate]

					, [strTestNotes]

					, [strSummaryNotes]

					, [strClinicalNotes]

					, [strFieldAccessionID]

					, [rowguid]

					, [idfsYNTestsConducted]

					, [intRowStatus]

					, [idfReportedByOffice]

					, [idfInvestigatedByOffice]

					, [idfsCaseReportType]

					, [strDefaultDisplayDiagnosis]

					, [idfsCaseClassification]

					, [idfOutbreak]

					, [datEnteredDate]

					, [strCaseID]

					, [idfsCaseProgressStatus]

					, [strSampleNotes]

					, [datModificationForArchiveDate]

					, [idfParentMonitoringSession]

					, [uidOfflineCaseID]

					, [idfsCaseType]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [LegacyCaseID]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]

					, [idfReceivedByOffice]

					, [idfReceivedByPerson]
)
select 

					tlbVetCase_v6.[idfVetCase]

					, j_tlbFarm_idfFarm_v7.[idfFarm]

					, j_trtDiagnosis_idfsTentativeDiagnosis_v7.[idfsDiagnosis]

					, j_trtDiagnosis_idfsTentativeDiagnosis1_v7.[idfsDiagnosis]

					, j_trtDiagnosis_idfsTentativeDiagnosis2_v7.[idfsDiagnosis]

					, j_trtDiagnosis_idfsFinalDiagnosis_v7.[idfsDiagnosis]

					, j_tlbPerson_idfPersonEnteredBy_v7.[idfPerson]

					, j_tlbPerson_idfPersonReportedBy_v7.[idfPerson]

					, j_tlbPerson_idfPersonInvestigatedBy_v7.[idfPerson]

					, j_tlbObservation_idfObservation_v7.[idfObservation]

					, j_tstSite_idfsSite_v7.[idfsSite]

					, tlbVetCase_v6.[datReportDate]

					, tlbVetCase_v6.[datAssignedDate]

					, tlbVetCase_v6.[datInvestigationDate]

					, tlbVetCase_v6.[datTentativeDiagnosisDate]

					, tlbVetCase_v6.[datTentativeDiagnosis1Date]

					, tlbVetCase_v6.[datTentativeDiagnosis2Date]

					, case
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
					  end /*Rule for the field in EIDSSv7: datFinalDiagnosisDate*/

					, tlbVetCase_v6.[strTestNotes]

					, isnull(@InitialDiagResource + N' 1: ' + 
							isnull(j_trtStringNameTranslation_idfsTentativeDiagnosis_v7.[strTextString], j_trtBaseReference_idfsTentativeDiagnosis_v7.[strDefault]) + 
							isnull(N' ' + convert(nvarchar, tlbVetCase_v6.[datTentativeDiagnosisDate], 103) collate Cyrillic_General_CI_AS, N'') + N'
						' collate Cyrillic_General_CI_AS, N'') +
					  isnull(@InitialDiagResource + N' 2: ' + 
							isnull(j_trtStringNameTranslation_idfsTentativeDiagnosis1_v7.[strTextString], j_trtBaseReference_idfsTentativeDiagnosis1_v7.[strDefault]) + 
							isnull(N' ' + convert(nvarchar, tlbVetCase_v6.[datTentativeDiagnosis1Date], 103) collate Cyrillic_General_CI_AS, N'') + N'
						' collate Cyrillic_General_CI_AS, N'') +
					  isnull(@InitialDiagResource + N' 3: ' + 
							isnull(j_trtStringNameTranslation_idfsTentativeDiagnosis2_v7.[strTextString], j_trtBaseReference_idfsTentativeDiagnosis2_v7.[strDefault]) + 
							isnull(N' ' + convert(nvarchar, tlbVetCase_v6.[datTentativeDiagnosis2Date], 103) collate Cyrillic_General_CI_AS, N'') + N'
						' collate Cyrillic_General_CI_AS, N'')
					  collate Cyrillic_General_CI_AS /*Rule for the field in EIDSSv7: strSummaryNotes*/

					, tlbVetCase_v6.[strClinicalNotes]

					, tlbVetCase_v6.[strFieldAccessionID]

					, tlbVetCase_v6.[rowguid]

					, j_trtBaseReference_idfsYNTestsConducted_v7.[idfsBaseReference]

					, tlbVetCase_v6.[intRowStatus]

					, j_tlbOffice_idfReportedByOffice_v7.[idfOffice]

					, j_tlbOffice_idfInvestigatedByOffice_v7.[idfOffice]

					, j_trtBaseReference_idfsCaseReportType_v7.[idfsBaseReference]

					, tlbVetCase_v6.[strDefaultDisplayDiagnosis]

					, j_trtBaseReference_idfsCaseClassification_v7.[idfsBaseReference]

					, j_tlbOutbreak_idfOutbreak_v7.[idfOutbreak]

					, tlbVetCase_v6.[datEnteredDate]

					, tlbVetCase_v6.[strCaseID]

					, j_trtBaseReference_idfsCaseProgressStatus_v7.[idfsBaseReference]

					, tlbVetCase_v6.[strSampleNotes]

					, tlbVetCase_v6.[datModificationForArchiveDate]

					, j_tlbMonitoringSession_idfParentMonitoringSession_v7.[idfMonitoringSession]

					, tlbVetCase_v6.[uidOfflineCaseID]

					, j_trtBaseReference_idfsCaseType_v7.[idfsBaseReference]

					, tlbVetCase_v6.[strMaintenanceFlag]

					, tlbVetCase_v6.[strReservedAttribute]

					, tlbVetCase_v6.strCaseID /*Rule for the new field in EIDSSv7: LegacyCaseID*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfVetCase":' + isnull(cast(tlbVetCase_v6.[idfVetCase] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()

					, null /*TODO: Check the rule for the new field in EIDSSv7: idfReceivedByOffice*/

					, null /*TODO: Check the rule for the new field in EIDSSv7: idfReceivedByPerson*/
from [Falcon].[dbo].[tlbVetCase] tlbVetCase_v6 


					inner join	[Giraffe].[dbo].[tlbFarm] j_tlbFarm_idfFarm_v7

		on	


					j_tlbFarm_idfFarm_v7.[idfFarm] = tlbVetCase_v6.[idfFarm] 

					inner join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsCaseType_v7

		on	


					j_trtBaseReference_idfsCaseType_v7.[idfsBaseReference] = tlbVetCase_v6.[idfsCaseType] 

					inner join	[Giraffe].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tlbVetCase_v6.[idfsSite] 

					left join	[Giraffe].[dbo].[tlbMonitoringSession] j_tlbMonitoringSession_idfParentMonitoringSession_v7

		on	


					j_tlbMonitoringSession_idfParentMonitoringSession_v7.[idfMonitoringSession] = tlbVetCase_v6.[idfParentMonitoringSession] 

					left join	[Giraffe].[dbo].[tlbObservation] j_tlbObservation_idfObservation_v7

		on	


					j_tlbObservation_idfObservation_v7.[idfObservation] = tlbVetCase_v6.[idfObservation] 

					left join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfInvestigatedByOffice_v7

		on	


					j_tlbOffice_idfInvestigatedByOffice_v7.[idfOffice] = tlbVetCase_v6.[idfInvestigatedByOffice] 

					left join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfReportedByOffice_v7

		on	


					j_tlbOffice_idfReportedByOffice_v7.[idfOffice] = tlbVetCase_v6.[idfReportedByOffice] 

					left join	[Giraffe].[dbo].[tlbOutbreak] j_tlbOutbreak_idfOutbreak_v7

		on	


					j_tlbOutbreak_idfOutbreak_v7.[idfOutbreak] = tlbVetCase_v6.[idfOutbreak] 

					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfPersonEnteredBy_v7

		on	


					j_tlbPerson_idfPersonEnteredBy_v7.[idfPerson] = tlbVetCase_v6.[idfPersonEnteredBy] 

					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfPersonInvestigatedBy_v7

		on	


					j_tlbPerson_idfPersonInvestigatedBy_v7.[idfPerson] = tlbVetCase_v6.[idfPersonInvestigatedBy] 

					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfPersonReportedBy_v7

		on	


					j_tlbPerson_idfPersonReportedBy_v7.[idfPerson] = tlbVetCase_v6.[idfPersonReportedBy] 

					left join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsTentativeDiagnosis_v7
		left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsTentativeDiagnosis_v7
		on	j_trtBaseReference_idfsTentativeDiagnosis_v7.[idfsBaseReference] = j_trtDiagnosis_idfsTentativeDiagnosis_v7.[idfsDiagnosis]
		left join	[Giraffe].[dbo].[trtStringNameTranslation] j_trtStringNameTranslation_idfsTentativeDiagnosis_v7
		on	j_trtStringNameTranslation_idfsTentativeDiagnosis_v7.[idfsBaseReference] = j_trtDiagnosis_idfsTentativeDiagnosis_v7.[idfsDiagnosis]
			and j_trtStringNameTranslation_idfsTentativeDiagnosis_v7.[idfsLanguage] = @idfsPreferredNationalLanguage

		on	


					j_trtDiagnosis_idfsTentativeDiagnosis_v7.[idfsDiagnosis] = tlbVetCase_v6.[idfsTentativeDiagnosis] 

					left join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsTentativeDiagnosis1_v7
		left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsTentativeDiagnosis1_v7
		on	j_trtBaseReference_idfsTentativeDiagnosis1_v7.[idfsBaseReference] = j_trtDiagnosis_idfsTentativeDiagnosis1_v7.[idfsDiagnosis]
		left join	[Giraffe].[dbo].[trtStringNameTranslation] j_trtStringNameTranslation_idfsTentativeDiagnosis1_v7
		on	j_trtStringNameTranslation_idfsTentativeDiagnosis1_v7.[idfsBaseReference] = j_trtDiagnosis_idfsTentativeDiagnosis1_v7.[idfsDiagnosis]
			and j_trtStringNameTranslation_idfsTentativeDiagnosis1_v7.[idfsLanguage] = @idfsPreferredNationalLanguage

		on	


					j_trtDiagnosis_idfsTentativeDiagnosis1_v7.[idfsDiagnosis] = tlbVetCase_v6.[idfsTentativeDiagnosis1] 

					left join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsTentativeDiagnosis2_v7
		left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsTentativeDiagnosis2_v7
		on	j_trtBaseReference_idfsTentativeDiagnosis2_v7.[idfsBaseReference] = j_trtDiagnosis_idfsTentativeDiagnosis2_v7.[idfsDiagnosis]
		left join	[Giraffe].[dbo].[trtStringNameTranslation] j_trtStringNameTranslation_idfsTentativeDiagnosis2_v7
		on	j_trtStringNameTranslation_idfsTentativeDiagnosis2_v7.[idfsBaseReference] = j_trtDiagnosis_idfsTentativeDiagnosis2_v7.[idfsDiagnosis]
			and j_trtStringNameTranslation_idfsTentativeDiagnosis2_v7.[idfsLanguage] = @idfsPreferredNationalLanguage

		on	


					j_trtDiagnosis_idfsTentativeDiagnosis2_v7.[idfsDiagnosis] = tlbVetCase_v6.[idfsTentativeDiagnosis2] 

					left join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsFinalDiagnosis_v7

		on	


					j_trtDiagnosis_idfsFinalDiagnosis_v7.[idfsDiagnosis] = tlbVetCase_v6.[idfsShowDiagnosis] /*Rule for the field in EIDSSv7: idfsFinalDiagnosis*/ 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsYNTestsConducted_v7

		on	


					j_trtBaseReference_idfsYNTestsConducted_v7.[idfsBaseReference] = tlbVetCase_v6.[idfsYNTestsConducted] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsCaseReportType_v7

		on	


					j_trtBaseReference_idfsCaseReportType_v7.[idfsBaseReference] = tlbVetCase_v6.[idfsCaseReportType] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsCaseClassification_v7

		on	


					j_trtBaseReference_idfsCaseClassification_v7.[idfsBaseReference] = tlbVetCase_v6.[idfsCaseClassification] 

					left join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsShowDiagnosis_v7

		on	


					j_trtDiagnosis_idfsShowDiagnosis_v7.[idfsDiagnosis] = tlbVetCase_v6.[idfsShowDiagnosis] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsCaseProgressStatus_v7

		on	


					j_trtBaseReference_idfsCaseProgressStatus_v7.[idfsBaseReference] = tlbVetCase_v6.[idfsCaseProgressStatus] 
left join	[Giraffe].[dbo].[tlbVetCase] tlbVetCase_v7 
on	

					tlbVetCase_v7.[idfVetCase] = tlbVetCase_v6.[idfVetCase] 
where tlbVetCase_v7.[idfVetCase] is null 
print N'Table [tlbVetCase] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbVaccination]
************************************************************/
insert into [Giraffe].[dbo].[tlbVaccination] 

(

					[idfVaccination]

					, [idfVetCase]

					, [idfSpecies]

					, [idfsVaccinationType]

					, [idfsVaccinationRoute]

					, [idfsDiagnosis]

					, [datVaccinationDate]

					, [strManufacturer]

					, [strLotNumber]

					, [intNumberVaccinated]

					, [strNote]

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

					tlbVaccination_v6.[idfVaccination]

					, j_tlbVetCase_idfVetCase_v7.[idfVetCase]

					, j_tlbSpecies_idfSpecies_v7.[idfSpecies]

					, j_trtBaseReference_idfsVaccinationType_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsVaccinationRoute_v7.[idfsBaseReference]

					, j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis]

					, tlbVaccination_v6.[datVaccinationDate]

					, tlbVaccination_v6.[strManufacturer]

					, tlbVaccination_v6.[strLotNumber]

					, tlbVaccination_v6.[intNumberVaccinated]

					, tlbVaccination_v6.[strNote]

					, tlbVaccination_v6.[intRowStatus]

					, tlbVaccination_v6.[rowguid]

					, tlbVaccination_v6.[strMaintenanceFlag]

					, tlbVaccination_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfVaccination":' + isnull(cast(tlbVaccination_v6.[idfVaccination] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbVaccination] tlbVaccination_v6 


					left join	[Giraffe].[dbo].[tlbSpecies] j_tlbSpecies_idfSpecies_v7

		on	


					j_tlbSpecies_idfSpecies_v7.[idfSpecies] = tlbVaccination_v6.[idfSpecies] 

					left join	[Giraffe].[dbo].[tlbVetCase] j_tlbVetCase_idfVetCase_v7

		on	


					j_tlbVetCase_idfVetCase_v7.[idfVetCase] = tlbVaccination_v6.[idfVetCase] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsVaccinationType_v7

		on	


					j_trtBaseReference_idfsVaccinationType_v7.[idfsBaseReference] = tlbVaccination_v6.[idfsVaccinationType] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsVaccinationRoute_v7

		on	


					j_trtBaseReference_idfsVaccinationRoute_v7.[idfsBaseReference] = tlbVaccination_v6.[idfsVaccinationRoute] 

					left join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsDiagnosis_v7

		on	


					j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis] = tlbVaccination_v6.[idfsDiagnosis] 
left join	[Giraffe].[dbo].[tlbVaccination] tlbVaccination_v7 
on	

					tlbVaccination_v7.[idfVaccination] = tlbVaccination_v6.[idfVaccination] 
where tlbVaccination_v7.[idfVaccination] is null 
print N'Table [tlbVaccination] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbVetCaseLog]
************************************************************/
insert into [Giraffe].[dbo].[tlbVetCaseLog] 

(

					[idfVetCaseLog]

					, [idfsCaseLogStatus]

					, [idfVetCase]

					, [idfPerson]

					, [datCaseLogDate]

					, [strActionRequired]

					, [strNote]

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

					tlbVetCaseLog_v6.[idfVetCaseLog]

					, j_trtBaseReference_idfsCaseLogStatus_v7.[idfsBaseReference]

					, j_tlbVetCase_idfVetCase_v7.[idfVetCase]

					, j_tlbPerson_idfPerson_v7.[idfPerson]

					, tlbVetCaseLog_v6.[datCaseLogDate]

					, tlbVetCaseLog_v6.[strActionRequired]

					, tlbVetCaseLog_v6.[strNote]

					, tlbVetCaseLog_v6.[intRowStatus]

					, tlbVetCaseLog_v6.[rowguid]

					, tlbVetCaseLog_v6.[strMaintenanceFlag]

					, tlbVetCaseLog_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfVetCaseLog":' + isnull(cast(tlbVetCaseLog_v6.[idfVetCaseLog] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbVetCaseLog] tlbVetCaseLog_v6 


					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfPerson_v7

		on	


					j_tlbPerson_idfPerson_v7.[idfPerson] = tlbVetCaseLog_v6.[idfPerson] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsCaseLogStatus_v7

		on	


					j_trtBaseReference_idfsCaseLogStatus_v7.[idfsBaseReference] = tlbVetCaseLog_v6.[idfsCaseLogStatus] 

					left join	[Giraffe].[dbo].[tlbVetCase] j_tlbVetCase_idfVetCase_v7

		on	


					j_tlbVetCase_idfVetCase_v7.[idfVetCase] = tlbVetCaseLog_v6.[idfVetCase] 
left join	[Giraffe].[dbo].[tlbVetCaseLog] tlbVetCaseLog_v7 
on	

					tlbVetCaseLog_v7.[idfVetCaseLog] = tlbVetCaseLog_v6.[idfVetCaseLog] 
where tlbVetCaseLog_v7.[idfVetCaseLog] is null 
print N'Table [tlbVetCaseLog] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tflVetCaseFiltered]
************************************************************/
insert into [Giraffe].[dbo].[tflVetCaseFiltered] 

(

					[idfVetCaseFiltered]

					, [idfVetCase]

					, [idfSiteGroup]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tflVetCaseFiltered_v6.[idfVetCaseFiltered]

					, j_tlbVetCase_idfVetCase_v7.[idfVetCase]

					, j_tflSiteGroup_idfSiteGroup_v7.[idfSiteGroup]

					, tflVetCaseFiltered_v6.[rowguid]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfVetCaseFiltered":' + isnull(cast(tflVetCaseFiltered_v6.[idfVetCaseFiltered] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tflVetCaseFiltered] tflVetCaseFiltered_v6 


					inner join	[Giraffe].[dbo].[tflSiteGroup] j_tflSiteGroup_idfSiteGroup_v7

		on	


					j_tflSiteGroup_idfSiteGroup_v7.[idfSiteGroup] = tflVetCaseFiltered_v6.[idfSiteGroup] 

					inner join	[Giraffe].[dbo].[tlbVetCase] j_tlbVetCase_idfVetCase_v7

		on	


					j_tlbVetCase_idfVetCase_v7.[idfVetCase] = tflVetCaseFiltered_v6.[idfVetCase] 
left join	[Giraffe].[dbo].[tflVetCaseFiltered] tflVetCaseFiltered_v7 
on	

					tflVetCaseFiltered_v7.[idfVetCaseFiltered] = tflVetCaseFiltered_v6.[idfVetCaseFiltered] 
where tflVetCaseFiltered_v7.[idfVetCaseFiltered] is null 
print N'Table [tflVetCaseFiltered] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbMaterial]
************************************************************/
insert into [Giraffe].[dbo].[tlbMaterial] 

(

					[idfMaterial]

					, [idfsSampleType]

					, [idfRootMaterial]

					, [idfParentMaterial]

					, [idfHuman]

					, [idfSpecies]

					, [idfAnimal]

					, [idfMonitoringSession]

					, [idfFieldCollectedByPerson]

					, [idfFieldCollectedByOffice]

					, [idfMainTest]

					, [datFieldCollectionDate]

					, [datFieldSentDate]

					, [strFieldBarcode]

					, [strCalculatedCaseID]

					, [strCalculatedHumanName]

					, [idfVectorSurveillanceSession]

					, [idfVector]

					, [idfSubdivision]

					, [idfsSampleStatus]

					, [idfInDepartment]

					, [idfDestroyedByPerson]

					, [datEnteringDate]

					, [datDestructionDate]

					, [strBarcode]

					, [strNote]

					, [idfsSite]

					, [intRowStatus]

					, [rowguid]

					, [idfSendToOffice]

					, [blnReadOnly]

					, [idfsBirdStatus]

					, [idfHumanCase]

					, [idfVetCase]

					, [datAccession]

					, [idfsAccessionCondition]

					, [strCondition]

					, [idfAccesionByPerson]

					, [idfsDestructionMethod]

					, [idfsCurrentSite]

					, [idfsSampleKind]

					, [idfMarkedForDispositionByPerson]

					, [datOutOfRepositoryDate]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [StorageBoxPlace]

					, [PreviousSampleStatusID]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [DiseaseID]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]

					, [LabModuleSourceIndicator]

					, [TestUnassignedIndicator]

					, [TestCompletedIndicator]

					, [TransferIndicator]
)
select 

					isnull(ccm.idfMaterial_v7, tlbMaterial_v6.[idfMaterial])

					, j_trtSampleType_idfsSampleType_v7.[idfsSampleType]

					, null /*Will be updated below when foreign key data is available*/

					, null /*Will be updated below when foreign key data is available*/

					, j_tlbHuman_idfHuman_v7.[idfHuman]

					, j_tlbSpecies_idfSpecies_v7.[idfSpecies]

					, j_tlbAnimal_idfAnimal_v7.[idfAnimal]

					, j_tlbMonitoringSession_idfMonitoringSession_v7.[idfMonitoringSession]

					, j_tlbPerson_idfFieldCollectedByPerson_v7.[idfPerson]

					, j_tlbOffice_idfFieldCollectedByOffice_v7.[idfOffice]

					, null /*Will be updated below when foreign key data is available*/

					, tlbMaterial_v6.[datFieldCollectionDate]

					, tlbMaterial_v6.[datFieldSentDate]

					, tlbMaterial_v6.[strFieldBarcode]

					, isnull(ccm.[strCalculatedCaseID_v7], tlbMaterial_v6.[strCalculatedCaseID])

					, isnull(ccm.[strCalculatedHumanName_v7], tlbMaterial_v6.[strCalculatedHumanName])

					, j_tlbVectorSurveillanceSession_idfVectorSurveillanceSession_v7.[idfVectorSurveillanceSession]

					, j_tlbVector_idfVector_v7.[idfVector]

					, j_tlbFreezerSubdivision_idfSubdivision_v7.[idfSubdivision]

					, j_trtBaseReference_idfsSampleStatus_v7.[idfsBaseReference]

					, j_tlbDepartment_idfInDepartment_v7.[idfDepartment]

					, j_tlbPerson_idfDestroyedByPerson_v7.[idfPerson]

					, tlbMaterial_v6.[datEnteringDate]

					, tlbMaterial_v6.[datDestructionDate]

					, tlbMaterial_v6.[strBarcode]

					, tlbMaterial_v6.[strNote]

					, j_tstSite_idfsSite_v7.[idfsSite]

					, tlbMaterial_v6.[intRowStatus]

					, tlbMaterial_v6.[rowguid]

					, j_tlbOffice_idfSendToOffice_v7.[idfOffice]

					, isnull(ccm.[blnReadOnly_v7], tlbMaterial_v6.[blnReadOnly])

					, j_trtBaseReference_idfsBirdStatus_v7.[idfsBaseReference]

					, j_tlbHumanCase_idfHumanCase_v7.[idfHumanCase]

					, j_tlbVetCase_idfVetCase_v7.[idfVetCase]

					, tlbMaterial_v6.[datAccession]

					, j_trtBaseReference_idfsAccessionCondition_v7.[idfsBaseReference]

					, tlbMaterial_v6.[strCondition]

					, j_tlbPerson_idfAccesionByPerson_v7.[idfPerson]

					, j_trtBaseReference_idfsDestructionMethod_v7.[idfsBaseReference]

					, j_tstSite_idfsCurrentSite_v7.[idfsSite]

					, j_trtBaseReference_idfsSampleKind_v7.[idfsBaseReference]

					, j_tlbPerson_idfMarkedForDispositionByPerson_v7.[idfPerson]

					, tlbMaterial_v6.[datOutOfRepositoryDate]

					, tlbMaterial_v6.[strMaintenanceFlag]

					, tlbMaterial_v6.[strReservedAttribute]

					, null /*TODO: Check the rule for the new field in EIDSSv7: StorageBoxPlace*/

					, null /*TODO: Check the rule for the new field in EIDSSv7: PreviousSampleStatusID*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfMaterial":' + isnull(cast(isnull(ccm.idfMaterial_v7, tlbMaterial_v6.[idfMaterial]) as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, coalesce(j_tlbHumanCase_idfHumanCase_v7.[idfsFinalDiagnosis], j_tlbHumanCase_idfHumanCase_v7.[idfsTentativeDiagnosis], j_tlbVetCase_idfVetCase_v7.[idfsFinalDiagnosis]) /*Rule for the new field in EIDSSv7: DiseaseID*/

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()

					, 0 /*Rule for the new field in EIDSSv7: LabModuleSourceIndicator*/

					, 0 /*Rule for the new field in EIDSSv7: TestUnassignedIndicator*/

					, 0 /*Rule for the new field in EIDSSv7: TestCompletedIndicator*/

					, 0 /*Rule for the new field in EIDSSv7: TransferIndicator*/
from [Falcon].[dbo].[tlbMaterial] tlbMaterial_v6
left join	[Giraffe].[dbo].[_dmccMaterial] ccm
on			ccm.idfMaterial_v6 = tlbMaterial_v6.[idfMaterial] 


					inner join	[Giraffe].[dbo].[trtSampleType] j_trtSampleType_idfsSampleType_v7

		on	


					j_trtSampleType_idfsSampleType_v7.[idfsSampleType] = tlbMaterial_v6.[idfsSampleType] 

					inner join	[Giraffe].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tlbMaterial_v6.[idfsSite] 

					left join	[Giraffe].[dbo].[tlbAnimal] j_tlbAnimal_idfAnimal_v7

		on	


					j_tlbAnimal_idfAnimal_v7.[idfAnimal] = tlbMaterial_v6.[idfAnimal] 

					left join	[Giraffe].[dbo].[tlbDepartment] j_tlbDepartment_idfInDepartment_v7

		on	


					j_tlbDepartment_idfInDepartment_v7.[idfDepartment] = tlbMaterial_v6.[idfInDepartment] 

					left join	[Giraffe].[dbo].[tlbFreezerSubdivision] j_tlbFreezerSubdivision_idfSubdivision_v7

		on	


					j_tlbFreezerSubdivision_idfSubdivision_v7.[idfSubdivision] = tlbMaterial_v6.[idfSubdivision] 

					left join	[Giraffe].[dbo].[tlbHumanCase] j_tlbHumanCase_idfHumanCase_v7

		on	


					j_tlbHumanCase_idfHumanCase_v7.[idfHumanCase] = ccm.idfHumanCase_v7 

					left join	[Giraffe].[dbo].[tlbHuman] j_tlbHuman_idfHuman_v7

		on	


					j_tlbHuman_idfHuman_v7.[idfHuman] = ccm.idfHuman_v7 

					left join	[Giraffe].[dbo].[tlbMaterial] j_tlbMaterial_idfParentMaterial_v7

		on	


					j_tlbMaterial_idfParentMaterial_v7.[idfMaterial] = tlbMaterial_v6.[idfParentMaterial] 

					left join	[Giraffe].[dbo].[tlbMaterial] j_tlbMaterial_idfRootMaterial_v7

		on	


					j_tlbMaterial_idfRootMaterial_v7.[idfMaterial] = tlbMaterial_v6.[idfRootMaterial] 

					left join	[Giraffe].[dbo].[tlbSpecies] j_tlbSpecies_idfSpecies_v7

		on	


					j_tlbSpecies_idfSpecies_v7.[idfSpecies] = tlbMaterial_v6.[idfSpecies] 

					left join	[Giraffe].[dbo].[tlbMonitoringSession] j_tlbMonitoringSession_idfMonitoringSession_v7

		on	


					j_tlbMonitoringSession_idfMonitoringSession_v7.[idfMonitoringSession] = tlbMaterial_v6.[idfMonitoringSession] 

					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfFieldCollectedByPerson_v7

		on	


					j_tlbPerson_idfFieldCollectedByPerson_v7.[idfPerson] = tlbMaterial_v6.[idfFieldCollectedByPerson] 

					left join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfFieldCollectedByOffice_v7

		on	


					j_tlbOffice_idfFieldCollectedByOffice_v7.[idfOffice] = tlbMaterial_v6.[idfFieldCollectedByOffice] 

					left join	[Giraffe].[dbo].[tlbTesting] j_tlbTesting_idfMainTest_v7

		on	


					j_tlbTesting_idfMainTest_v7.[idfTesting] = tlbMaterial_v6.[idfMainTest] 

					left join	[Giraffe].[dbo].[tlbVectorSurveillanceSession] j_tlbVectorSurveillanceSession_idfVectorSurveillanceSession_v7

		on	


					j_tlbVectorSurveillanceSession_idfVectorSurveillanceSession_v7.[idfVectorSurveillanceSession] = tlbMaterial_v6.[idfVectorSurveillanceSession] 

					left join	[Giraffe].[dbo].[tlbVector] j_tlbVector_idfVector_v7

		on	


					j_tlbVector_idfVector_v7.[idfVector] = tlbMaterial_v6.[idfVector] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsSampleStatus_v7

		on	


					j_trtBaseReference_idfsSampleStatus_v7.[idfsBaseReference] = tlbMaterial_v6.[idfsSampleStatus] 

					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfDestroyedByPerson_v7

		on	


					j_tlbPerson_idfDestroyedByPerson_v7.[idfPerson] = tlbMaterial_v6.[idfDestroyedByPerson] 

					left join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfSendToOffice_v7

		on	


					j_tlbOffice_idfSendToOffice_v7.[idfOffice] = tlbMaterial_v6.[idfSendToOffice] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsBirdStatus_v7

		on	


					j_trtBaseReference_idfsBirdStatus_v7.[idfsBaseReference] = tlbMaterial_v6.[idfsBirdStatus] 

					left join	[Giraffe].[dbo].[tlbVetCase] j_tlbVetCase_idfVetCase_v7

		on	


					j_tlbVetCase_idfVetCase_v7.[idfVetCase] = tlbMaterial_v6.[idfVetCase] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsAccessionCondition_v7

		on	


					j_trtBaseReference_idfsAccessionCondition_v7.[idfsBaseReference] = tlbMaterial_v6.[idfsAccessionCondition] 

					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfAccesionByPerson_v7

		on	


					j_tlbPerson_idfAccesionByPerson_v7.[idfPerson] = tlbMaterial_v6.[idfAccesionByPerson] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsDestructionMethod_v7

		on	


					j_trtBaseReference_idfsDestructionMethod_v7.[idfsBaseReference] = tlbMaterial_v6.[idfsDestructionMethod] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsSampleKind_v7

		on	


					j_trtBaseReference_idfsSampleKind_v7.[idfsBaseReference] = tlbMaterial_v6.[idfsSampleKind] 

					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfMarkedForDispositionByPerson_v7

		on	


					j_tlbPerson_idfMarkedForDispositionByPerson_v7.[idfPerson] = tlbMaterial_v6.[idfMarkedForDispositionByPerson] 

					left join	[Giraffe].[dbo].[tstSite] j_tstSite_idfsCurrentSite_v7

		on	


					j_tstSite_idfsCurrentSite_v7.[idfsSite] = tlbMaterial_v6.[idfsCurrentSite] 
left join	[Giraffe].[dbo].[tlbMaterial] tlbMaterial_v7 
on	

					tlbMaterial_v7.[idfMaterial] = isnull(ccm.idfMaterial_v7, tlbMaterial_v6.[idfMaterial]) 
where tlbMaterial_v7.[idfMaterial] is null 
print N'Table [tlbMaterial] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbTransferOUT]
************************************************************/
insert into [Giraffe].[dbo].[tlbTransferOUT] 

(

					[idfTransferOut]

					, [idfsTransferStatus]

					, [idfSendFromOffice]

					, [idfSendToOffice]

					, [idfSendByPerson]

					, [datSendDate]

					, [strNote]

					, [strBarcode]

					, [intRowStatus]

					, [rowguid]

					, [idfsSite]

					, [datModificationForArchiveDate]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [TestRequested]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tlbTransferOUT_v6.[idfTransferOut]

					, j_trtBaseReference_idfsTransferStatus_v7.[idfsBaseReference]

					, j_tlbOffice_idfSendFromOffice_v7.[idfOffice]

					, j_tlbOffice_idfSendToOffice_v7.[idfOffice]

					, j_tlbPerson_idfSendByPerson_v7.[idfPerson]

					, tlbTransferOUT_v6.[datSendDate]

					, tlbTransferOUT_v6.[strNote]

					, tlbTransferOUT_v6.[strBarcode]

					, tlbTransferOUT_v6.[intRowStatus]

					, tlbTransferOUT_v6.[rowguid]

					, j_tstSite_idfsSite_v7.[idfsSite]

					, tlbTransferOUT_v6.[datModificationForArchiveDate]

					, tlbTransferOUT_v6.[strMaintenanceFlag]

					, tlbTransferOUT_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfTransferOut":' + isnull(cast(tlbTransferOUT_v6.[idfTransferOut] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, null /*TODO: Check the rule for the new field in EIDSSv7: TestRequested*/

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbTransferOUT] tlbTransferOUT_v6 


					inner join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsTransferStatus_v7

		on	


					j_trtBaseReference_idfsTransferStatus_v7.[idfsBaseReference] = tlbTransferOUT_v6.[idfsTransferStatus] 

					inner join	[Giraffe].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tlbTransferOUT_v6.[idfsSite] 

					left join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfSendFromOffice_v7

		on	


					j_tlbOffice_idfSendFromOffice_v7.[idfOffice] = tlbTransferOUT_v6.[idfSendFromOffice] 

					left join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfSendToOffice_v7

		on	


					j_tlbOffice_idfSendToOffice_v7.[idfOffice] = tlbTransferOUT_v6.[idfSendToOffice] 

					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfSendByPerson_v7

		on	


					j_tlbPerson_idfSendByPerson_v7.[idfPerson] = tlbTransferOUT_v6.[idfSendByPerson] 
left join	[Giraffe].[dbo].[tlbTransferOUT] tlbTransferOUT_v7 
on	

					tlbTransferOUT_v7.[idfTransferOut] = tlbTransferOUT_v6.[idfTransferOut] 
where tlbTransferOUT_v7.[idfTransferOut] is null 
print N'Table [tlbTransferOUT] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tflTransferOutFiltered]
************************************************************/
insert into [Giraffe].[dbo].[tflTransferOutFiltered] 

(

					[idfTransferOutFiltered]

					, [idfTransferOut]

					, [idfSiteGroup]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tflTransferOutFiltered_v6.[idfTransferOutFiltered]

					, j_tlbTransferOUT_idfTransferOut_v7.[idfTransferOut]

					, j_tflSiteGroup_idfSiteGroup_v7.[idfSiteGroup]

					, tflTransferOutFiltered_v6.[rowguid]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfTransferOutFiltered":' + isnull(cast(tflTransferOutFiltered_v6.[idfTransferOutFiltered] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tflTransferOutFiltered] tflTransferOutFiltered_v6 


					inner join	[Giraffe].[dbo].[tflSiteGroup] j_tflSiteGroup_idfSiteGroup_v7

		on	


					j_tflSiteGroup_idfSiteGroup_v7.[idfSiteGroup] = tflTransferOutFiltered_v6.[idfSiteGroup] 

					inner join	[Giraffe].[dbo].[tlbTransferOUT] j_tlbTransferOUT_idfTransferOut_v7

		on	


					j_tlbTransferOUT_idfTransferOut_v7.[idfTransferOut] = tflTransferOutFiltered_v6.[idfTransferOut] 
left join	[Giraffe].[dbo].[tflTransferOutFiltered] tflTransferOutFiltered_v7 
on	

					tflTransferOutFiltered_v7.[idfTransferOutFiltered] = tflTransferOutFiltered_v6.[idfTransferOutFiltered] 
where tflTransferOutFiltered_v7.[idfTransferOutFiltered] is null 
print N'Table [tflTransferOutFiltered] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbTransferOutMaterial]
************************************************************/
insert into [Giraffe].[dbo].[tlbTransferOutMaterial] 

(

					[idfMaterial]

					, [idfTransferOut]

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

					j_tlbMaterial_idfMaterial_v7.[idfMaterial]

					, j_tlbTransferOUT_idfTransferOut_v7.[idfTransferOut]

					, tlbTransferOutMaterial_v6.[intRowStatus]

					, tlbTransferOutMaterial_v6.[rowguid]

					, tlbTransferOutMaterial_v6.[strMaintenanceFlag]

					, tlbTransferOutMaterial_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfMaterial":' + isnull(cast(tlbTransferOutMaterial_v6.[idfMaterial] as nvarchar(20)), N'null') + N',' + N'"idfTransferOut":' + isnull(cast(tlbTransferOutMaterial_v6.[idfTransferOut] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbTransferOutMaterial] tlbTransferOutMaterial_v6 


					inner join	[Giraffe].[dbo].[tlbMaterial] j_tlbMaterial_idfMaterial_v7

		on	


					j_tlbMaterial_idfMaterial_v7.[idfMaterial] = tlbTransferOutMaterial_v6.[idfMaterial] 

					inner join	[Giraffe].[dbo].[tlbTransferOUT] j_tlbTransferOUT_idfTransferOut_v7

		on	


					j_tlbTransferOUT_idfTransferOut_v7.[idfTransferOut] = tlbTransferOutMaterial_v6.[idfTransferOut] 
left join	[Giraffe].[dbo].[tlbTransferOutMaterial] tlbTransferOutMaterial_v7 
on	

					tlbTransferOutMaterial_v7.[idfMaterial] = tlbTransferOutMaterial_v6.[idfMaterial] 

					and tlbTransferOutMaterial_v7.[idfTransferOut] = tlbTransferOutMaterial_v6.[idfTransferOut] 
where tlbTransferOutMaterial_v7.[idfMaterial] is null 
print N'Table [tlbTransferOutMaterial] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbPensideTest]
************************************************************/
insert into [Giraffe].[dbo].[tlbPensideTest] 

(

					[idfPensideTest]

					, [idfMaterial]

					, [idfsPensideTestResult]

					, [idfsPensideTestName]

					, [intRowStatus]

					, [rowguid]

					, [idfTestedByPerson]

					, [idfTestedByOffice]

					, [idfsDiagnosis]

					, [datTestDate]

					, [idfsPensideTestCategory]

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

					tlbPensideTest_v6.[idfPensideTest]

					, j_tlbMaterial_idfMaterial_v7.[idfMaterial]

					, j_trtBaseReference_idfsPensideTestResult_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsPensideTestName_v7.[idfsBaseReference]

					, tlbPensideTest_v6.[intRowStatus]

					, tlbPensideTest_v6.[rowguid]

					, j_tlbPerson_idfTestedByPerson_v7.[idfPerson]

					, j_tlbOffice_idfTestedByOffice_v7.[idfOffice]

					, j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis]

					, tlbPensideTest_v6.[datTestDate]

					, j_trtBaseReference_idfsPensideTestCategory_v7.[idfsBaseReference]

					, tlbPensideTest_v6.[strMaintenanceFlag]

					, tlbPensideTest_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfPensideTest":' + isnull(cast(tlbPensideTest_v6.[idfPensideTest] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbPensideTest] tlbPensideTest_v6 


					inner join	[Giraffe].[dbo].[tlbMaterial] j_tlbMaterial_idfMaterial_v7

		on	


					j_tlbMaterial_idfMaterial_v7.[idfMaterial] = tlbPensideTest_v6.[idfMaterial] 

					left join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfTestedByOffice_v7

		on	


					j_tlbOffice_idfTestedByOffice_v7.[idfOffice] = tlbPensideTest_v6.[idfTestedByOffice] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsPensideTestResult_v7

		on	


					j_trtBaseReference_idfsPensideTestResult_v7.[idfsBaseReference] = tlbPensideTest_v6.[idfsPensideTestResult] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsPensideTestName_v7

		on	


					j_trtBaseReference_idfsPensideTestName_v7.[idfsBaseReference] = tlbPensideTest_v6.[idfsPensideTestName] 

					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfTestedByPerson_v7

		on	


					j_tlbPerson_idfTestedByPerson_v7.[idfPerson] = tlbPensideTest_v6.[idfTestedByPerson] 

					left join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsDiagnosis_v7

		on	


					j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis] = tlbPensideTest_v6.[idfsDiagnosis] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsPensideTestCategory_v7

		on	


					j_trtBaseReference_idfsPensideTestCategory_v7.[idfsBaseReference] = tlbPensideTest_v6.[idfsPensideTestCategory] 
left join	[Giraffe].[dbo].[tlbPensideTest] tlbPensideTest_v7 
on	

					tlbPensideTest_v7.[idfPensideTest] = tlbPensideTest_v6.[idfPensideTest] 
where tlbPensideTest_v7.[idfPensideTest] is null 
print N'Table [tlbPensideTest] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbBatchTest]
************************************************************/
insert into [Giraffe].[dbo].[tlbBatchTest] 

(

					[idfBatchTest]

					, [idfsTestName]

					, [idfsBatchStatus]

					, [idfPerformedByOffice]

					, [idfPerformedByPerson]

					, [idfValidatedByOffice]

					, [idfValidatedByPerson]

					, [idfObservation]

					, [idfsSite]

					, [datPerformedDate]

					, [datValidatedDate]

					, [strBarcode]

					, [intRowStatus]

					, [rowguid]

					, [idfResultEnteredByPerson]

					, [idfResultEnteredByOffice]

					, [datModificationForArchiveDate]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [TestRequested]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tlbBatchTest_v6.[idfBatchTest]

					, j_trtBaseReference_idfsTestName_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsBatchStatus_v7.[idfsBaseReference]

					, j_tlbOffice_idfPerformedByOffice_v7.[idfOffice]

					, j_tlbPerson_idfPerformedByPerson_v7.[idfPerson]

					, j_tlbOffice_idfValidatedByOffice_v7.[idfOffice]

					, j_tlbPerson_idfValidatedByPerson_v7.[idfPerson]

					, j_tlbObservation_idfObservation_v7.[idfObservation]

					, j_tstSite_idfsSite_v7.[idfsSite]

					, tlbBatchTest_v6.[datPerformedDate]

					, tlbBatchTest_v6.[datValidatedDate]

					, tlbBatchTest_v6.[strBarcode]

					, tlbBatchTest_v6.[intRowStatus]

					, tlbBatchTest_v6.[rowguid]

					, j_tlbPerson_idfResultEnteredByPerson_v7.[idfPerson]

					, j_tlbOffice_idfResultEnteredByOffice_v7.[idfOffice]

					, tlbBatchTest_v6.[datModificationForArchiveDate]

					, tlbBatchTest_v6.[strMaintenanceFlag]

					, tlbBatchTest_v6.[strReservedAttribute]

					, null /*TODO: Check the rule for the new field in EIDSSv7: TestRequested*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfBatchTest":' + isnull(cast(tlbBatchTest_v6.[idfBatchTest] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbBatchTest] tlbBatchTest_v6 


					inner join	[Giraffe].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tlbBatchTest_v6.[idfsSite] 

					inner join	[Giraffe].[dbo].[tlbObservation] j_tlbObservation_idfObservation_v7

		on	


					j_tlbObservation_idfObservation_v7.[idfObservation] = tlbBatchTest_v6.[idfObservation] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsTestName_v7

		on	


					j_trtBaseReference_idfsTestName_v7.[idfsBaseReference] = tlbBatchTest_v6.[idfsTestName] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsBatchStatus_v7

		on	


					j_trtBaseReference_idfsBatchStatus_v7.[idfsBaseReference] = tlbBatchTest_v6.[idfsBatchStatus] 

					left join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfPerformedByOffice_v7

		on	


					j_tlbOffice_idfPerformedByOffice_v7.[idfOffice] = tlbBatchTest_v6.[idfPerformedByOffice] 

					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfPerformedByPerson_v7

		on	


					j_tlbPerson_idfPerformedByPerson_v7.[idfPerson] = tlbBatchTest_v6.[idfPerformedByPerson] 

					left join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfValidatedByOffice_v7

		on	


					j_tlbOffice_idfValidatedByOffice_v7.[idfOffice] = tlbBatchTest_v6.[idfValidatedByOffice] 

					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfValidatedByPerson_v7

		on	


					j_tlbPerson_idfValidatedByPerson_v7.[idfPerson] = tlbBatchTest_v6.[idfValidatedByPerson] 

					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfResultEnteredByPerson_v7

		on	


					j_tlbPerson_idfResultEnteredByPerson_v7.[idfPerson] = tlbBatchTest_v6.[idfResultEnteredByPerson] 

					left join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfResultEnteredByOffice_v7

		on	


					j_tlbOffice_idfResultEnteredByOffice_v7.[idfOffice] = tlbBatchTest_v6.[idfResultEnteredByOffice] 
left join	[Giraffe].[dbo].[tlbBatchTest] tlbBatchTest_v7 
on	

					tlbBatchTest_v7.[idfBatchTest] = tlbBatchTest_v6.[idfBatchTest] 
where tlbBatchTest_v7.[idfBatchTest] is null 
print N'Table [tlbBatchTest] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tflBatchTestFiltered]
************************************************************/
insert into [Giraffe].[dbo].[tflBatchTestFiltered] 

(

					[idfBatchTestFiltered]

					, [idfBatchTest]

					, [idfSiteGroup]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tflBatchTestFiltered_v6.[idfBatchTestFiltered]

					, j_tlbBatchTest_idfBatchTest_v7.[idfBatchTest]

					, j_tflSiteGroup_idfSiteGroup_v7.[idfSiteGroup]

					, tflBatchTestFiltered_v6.[rowguid]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfBatchTestFiltered":' + isnull(cast(tflBatchTestFiltered_v6.[idfBatchTestFiltered] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tflBatchTestFiltered] tflBatchTestFiltered_v6 


					inner join	[Giraffe].[dbo].[tlbBatchTest] j_tlbBatchTest_idfBatchTest_v7

		on	


					j_tlbBatchTest_idfBatchTest_v7.[idfBatchTest] = tflBatchTestFiltered_v6.[idfBatchTest] 

					inner join	[Giraffe].[dbo].[tflSiteGroup] j_tflSiteGroup_idfSiteGroup_v7

		on	


					j_tflSiteGroup_idfSiteGroup_v7.[idfSiteGroup] = tflBatchTestFiltered_v6.[idfSiteGroup] 
left join	[Giraffe].[dbo].[tflBatchTestFiltered] tflBatchTestFiltered_v7 
on	

					tflBatchTestFiltered_v7.[idfBatchTestFiltered] = tflBatchTestFiltered_v6.[idfBatchTestFiltered] 
where tflBatchTestFiltered_v7.[idfBatchTestFiltered] is null 
print N'Table [tflBatchTestFiltered] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbTesting]
************************************************************/
insert into [Giraffe].[dbo].[tlbTesting] 

(

					[idfTesting]

					, [idfsTestName]

					, [idfsTestCategory]

					, [idfsTestResult]

					, [idfsTestStatus]

					, [idfsDiagnosis]

					, [idfMaterial]

					, [idfBatchTest]

					, [idfObservation]

					, [intTestNumber]

					, [strNote]

					, [intRowStatus]

					, [rowguid]

					, [datStartedDate]

					, [datConcludedDate]

					, [idfTestedByOffice]

					, [idfTestedByPerson]

					, [idfResultEnteredByOffice]

					, [idfResultEnteredByPerson]

					, [idfValidatedByOffice]

					, [idfValidatedByPerson]

					, [blnReadOnly]

					, [blnNonLaboratoryTest]

					, [blnExternalTest]

					, [idfPerformedByOffice]

					, [datReceivedDate]

					, [strContactPerson]

					, [strMaintenanceFlag]

					, [strReservedAttribute]

					, [PreviousTestStatusID]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]

					, [idfMonitoringSession]

					, [idfHumanCase]

					, [idfVetCase]

					, [idfVector]
)
select 

					isnull(cct.idfTesting_v7, tlbTesting_v6.[idfTesting])

					, j_trtBaseReference_idfsTestName_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsTestCategory_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsTestResult_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsTestStatus_v7.[idfsBaseReference]

					, j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis]

					, j_tlbMaterial_idfMaterial_v7.[idfMaterial]

					, j_tlbBatchTest_idfBatchTest_v7.[idfBatchTest]

					, isnull(cct.[idfObservation_v7], tlbTesting_v6.[idfObservation])

					, tlbTesting_v6.[intTestNumber]

					, tlbTesting_v6.[strNote]

					, tlbTesting_v6.[intRowStatus]

					, tlbTesting_v6.[rowguid]

					, tlbTesting_v6.[datStartedDate]

					, tlbTesting_v6.[datConcludedDate]

					, j_tlbOffice_idfTestedByOffice_v7.[idfOffice]

					, j_tlbPerson_idfTestedByPerson_v7.[idfPerson]

					, j_tlbOffice_idfResultEnteredByOffice_v7.[idfOffice]

					, j_tlbPerson_idfResultEnteredByPerson_v7.[idfPerson]

					, j_tlbOffice_idfValidatedByOffice_v7.[idfOffice]

					, j_tlbPerson_idfValidatedByPerson_v7.[idfPerson]

					, isnull(cct.[blnReadOnly_v7], tlbTesting_v6.[blnReadOnly])

					, tlbTesting_v6.[blnNonLaboratoryTest]

					, tlbTesting_v6.[blnExternalTest]

					, j_tlbOffice_idfPerformedByOffice_v7.[idfOffice]

					, tlbTesting_v6.[datReceivedDate]

					, tlbTesting_v6.[strContactPerson]

					, tlbTesting_v6.[strMaintenanceFlag]

					, tlbTesting_v6.[strReservedAttribute]

					, null /*TODO: Check the rule for the new field in EIDSSv7: PreviousTestStatusID*/

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfTesting":' + isnull(cast(isnull(cct.idfTesting_v7, tlbTesting_v6.[idfTesting]) as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()

					, j_tlbMaterial_idfMaterial_v7.[idfMonitoringSession] /*Rule for the new field in EIDSSv7: idfMonitoringSession*/

					, j_tlbMaterial_idfMaterial_v7.[idfHumanCase] /*Rule for the new field in EIDSSv7: idfHumanCase*/

					, j_tlbMaterial_idfMaterial_v7.[idfVetCase] /*Rule for the new field in EIDSSv7: idfVetCase*/

					, j_tlbMaterial_idfMaterial_v7.[idfVector] /*Rule for the new field in EIDSSv7: idfVector*/
from [Falcon].[dbo].[tlbTesting] tlbTesting_v6
left join	[Giraffe].[dbo].[_dmccLabTest] cct
on			cct.idfTesting_v6 = tlbTesting_v6.[idfTesting] 


					inner join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsTestStatus_v7

		on	


					j_trtBaseReference_idfsTestStatus_v7.[idfsBaseReference] = tlbTesting_v6.[idfsTestStatus] 

					inner join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsDiagnosis_v7

		on	


					j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis] = tlbTesting_v6.[idfsDiagnosis] 

					left join	[Giraffe].[dbo].[tlbBatchTest] j_tlbBatchTest_idfBatchTest_v7

		on	


					((j_tlbBatchTest_idfBatchTest_v7.[idfBatchTest] = cct.[idfBatchTest_v7] and cct.[idfTesting_v7] is not null) or (j_tlbBatchTest_idfBatchTest_v7.[idfBatchTest] = tlbTesting_v6.[idfBatchTest] and cct.[idfTesting_v7] is null)) 

					left join	[Giraffe].[dbo].[tlbMaterial] j_tlbMaterial_idfMaterial_v7

		on	


					j_tlbMaterial_idfMaterial_v7.[idfMaterial] = isnull(cct.idfMaterial_v7, tlbTesting_v6.[idfMaterial]) 

					left join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfPerformedByOffice_v7

		on	


					j_tlbOffice_idfPerformedByOffice_v7.[idfOffice] = tlbTesting_v6.[idfPerformedByOffice] 

					left join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfResultEnteredByOffice_v7

		on	


					j_tlbOffice_idfResultEnteredByOffice_v7.[idfOffice] = tlbTesting_v6.[idfResultEnteredByOffice] 

					left join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfTestedByOffice_v7

		on	


					j_tlbOffice_idfTestedByOffice_v7.[idfOffice] = tlbTesting_v6.[idfTestedByOffice] 

					left join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfValidatedByOffice_v7

		on	


					j_tlbOffice_idfValidatedByOffice_v7.[idfOffice] = tlbTesting_v6.[idfValidatedByOffice] 

					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfResultEnteredByPerson_v7

		on	


					j_tlbPerson_idfResultEnteredByPerson_v7.[idfPerson] = tlbTesting_v6.[idfResultEnteredByPerson] 

					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfTestedByPerson_v7

		on	


					j_tlbPerson_idfTestedByPerson_v7.[idfPerson] = tlbTesting_v6.[idfTestedByPerson] 

					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfValidatedByPerson_v7

		on	


					j_tlbPerson_idfValidatedByPerson_v7.[idfPerson] = tlbTesting_v6.[idfValidatedByPerson] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsTestName_v7

		on	


					j_trtBaseReference_idfsTestName_v7.[idfsBaseReference] = tlbTesting_v6.[idfsTestName] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsTestCategory_v7

		on	


					j_trtBaseReference_idfsTestCategory_v7.[idfsBaseReference] = tlbTesting_v6.[idfsTestCategory] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsTestResult_v7

		on	


					j_trtBaseReference_idfsTestResult_v7.[idfsBaseReference] = tlbTesting_v6.[idfsTestResult] 
left join	[Giraffe].[dbo].[tlbTesting] tlbTesting_v7 
on	

					tlbTesting_v7.[idfTesting] = isnull(cct.idfTesting_v7, tlbTesting_v6.[idfTesting]) 
where tlbTesting_v7.[idfTesting] is null 
print N'Table [tlbTesting] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbTestAmendmentHistory]
************************************************************/
insert into [Giraffe].[dbo].[tlbTestAmendmentHistory] 

(

					[idfTestAmendmentHistory]

					, [idfTesting]

					, [idfAmendByOffice]

					, [idfAmendByPerson]

					, [datAmendmentDate]

					, [idfsOldTestResult]

					, [idfsNewTestResult]

					, [strOldNote]

					, [strNewNote]

					, [strReason]

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

					tlbTestAmendmentHistory_v6.[idfTestAmendmentHistory]

					, j_tlbTesting_idfTesting_v7.[idfTesting]

					, j_tlbOffice_idfAmendByOffice_v7.[idfOffice]

					, j_tlbPerson_idfAmendByPerson_v7.[idfPerson]

					, tlbTestAmendmentHistory_v6.[datAmendmentDate]

					, j_trtBaseReference_idfsOldTestResult_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsNewTestResult_v7.[idfsBaseReference]

					, tlbTestAmendmentHistory_v6.[strOldNote]

					, tlbTestAmendmentHistory_v6.[strNewNote]

					, tlbTestAmendmentHistory_v6.[strReason]

					, tlbTestAmendmentHistory_v6.[intRowStatus]

					, tlbTestAmendmentHistory_v6.[rowguid]

					, tlbTestAmendmentHistory_v6.[strMaintenanceFlag]

					, tlbTestAmendmentHistory_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfTestAmendmentHistory":' + isnull(cast(tlbTestAmendmentHistory_v6.[idfTestAmendmentHistory] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbTestAmendmentHistory] tlbTestAmendmentHistory_v6 


					inner join	[Giraffe].[dbo].[tlbTesting] j_tlbTesting_idfTesting_v7

		on	


					j_tlbTesting_idfTesting_v7.[idfTesting] = tlbTestAmendmentHistory_v6.[idfTesting] 

					left join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfAmendByOffice_v7

		on	


					j_tlbOffice_idfAmendByOffice_v7.[idfOffice] = tlbTestAmendmentHistory_v6.[idfAmendByOffice] 

					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfAmendByPerson_v7

		on	


					j_tlbPerson_idfAmendByPerson_v7.[idfPerson] = tlbTestAmendmentHistory_v6.[idfAmendByPerson] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsOldTestResult_v7

		on	


					j_trtBaseReference_idfsOldTestResult_v7.[idfsBaseReference] = tlbTestAmendmentHistory_v6.[idfsOldTestResult] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsNewTestResult_v7

		on	


					j_trtBaseReference_idfsNewTestResult_v7.[idfsBaseReference] = tlbTestAmendmentHistory_v6.[idfsNewTestResult] 
left join	[Giraffe].[dbo].[tlbTestAmendmentHistory] tlbTestAmendmentHistory_v7 
on	

					tlbTestAmendmentHistory_v7.[idfTestAmendmentHistory] = tlbTestAmendmentHistory_v6.[idfTestAmendmentHistory] 
where tlbTestAmendmentHistory_v7.[idfTestAmendmentHistory] is null 
print N'Table [tlbTestAmendmentHistory] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbTestValidation]
************************************************************/
insert into [Giraffe].[dbo].[tlbTestValidation] 

(

					[idfTestValidation]

					, [idfsDiagnosis]

					, [idfsInterpretedStatus]

					, [idfValidatedByOffice]

					, [idfValidatedByPerson]

					, [idfInterpretedByOffice]

					, [idfInterpretedByPerson]

					, [idfTesting]

					, [blnValidateStatus]

					, [blnCaseCreated]

					, [strValidateComment]

					, [strInterpretedComment]

					, [datValidationDate]

					, [datInterpretationDate]

					, [intRowStatus]

					, [rowguid]

					, [blnReadOnly]

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

					isnull(cctv.idfTestValidation_v7, tlbTestValidation_v6.[idfTestValidation])

					, j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis]

					, j_trtBaseReference_idfsInterpretedStatus_v7.[idfsBaseReference]

					, j_tlbOffice_idfValidatedByOffice_v7.[idfOffice]

					, j_tlbPerson_idfValidatedByPerson_v7.[idfPerson]

					, j_tlbOffice_idfInterpretedByOffice_v7.[idfOffice]

					, j_tlbPerson_idfInterpretedByPerson_v7.[idfPerson]

					, j_tlbTesting_idfTesting_v7.[idfTesting]

					, tlbTestValidation_v6.[blnValidateStatus]

					, tlbTestValidation_v6.[blnCaseCreated]

					, tlbTestValidation_v6.[strValidateComment]

					, tlbTestValidation_v6.[strInterpretedComment]

					, tlbTestValidation_v6.[datValidationDate]

					, tlbTestValidation_v6.[datInterpretationDate]

					, tlbTestValidation_v6.[intRowStatus]

					, tlbTestValidation_v6.[rowguid]

					, isnull(cctv.[blnReadOnly_v7], tlbTestValidation_v6.[blnReadOnly])

					, tlbTestValidation_v6.[strMaintenanceFlag]

					, tlbTestValidation_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfTestValidation":' + isnull(cast(isnull(cctv.idfTestValidation_v7, tlbTestValidation_v6.[idfTestValidation]) as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbTestValidation] tlbTestValidation_v6
left join	[Giraffe].[dbo].[_dmccTestValidation] cctv
on			cctv.idfTestValidation_v6 = tlbTestValidation_v6.[idfTestValidation] 


					inner join	[Giraffe].[dbo].[tlbTesting] j_tlbTesting_idfTesting_v7

		on	


					j_tlbTesting_idfTesting_v7.[idfTesting] = isnull(cctv.idfTesting_v7, tlbTestValidation_v6.[idfTesting]) 

					left join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfInterpretedByOffice_v7

		on	


					j_tlbOffice_idfInterpretedByOffice_v7.[idfOffice] = tlbTestValidation_v6.[idfInterpretedByOffice] 

					left join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfValidatedByOffice_v7

		on	


					j_tlbOffice_idfValidatedByOffice_v7.[idfOffice] = tlbTestValidation_v6.[idfValidatedByOffice] 

					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfInterpretedByPerson_v7

		on	


					j_tlbPerson_idfInterpretedByPerson_v7.[idfPerson] = tlbTestValidation_v6.[idfInterpretedByPerson] 

					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfValidatedByPerson_v7

		on	


					j_tlbPerson_idfValidatedByPerson_v7.[idfPerson] = tlbTestValidation_v6.[idfValidatedByPerson] 

					left join	[Giraffe].[dbo].[trtDiagnosis] j_trtDiagnosis_idfsDiagnosis_v7

		on	


					j_trtDiagnosis_idfsDiagnosis_v7.[idfsDiagnosis] = tlbTestValidation_v6.[idfsDiagnosis] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsInterpretedStatus_v7

		on	


					j_trtBaseReference_idfsInterpretedStatus_v7.[idfsBaseReference] = tlbTestValidation_v6.[idfsInterpretedStatus] 
left join	[Giraffe].[dbo].[tlbTestValidation] tlbTestValidation_v7 
on	

					tlbTestValidation_v7.[idfTestValidation] = isnull(cctv.idfTestValidation_v7, tlbTestValidation_v6.[idfTestValidation]) 
where tlbTestValidation_v7.[idfTestValidation] is null 
print N'Table [tlbTestValidation] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbBasicSyndromicSurveillanceAggregateHeader]
************************************************************/
insert into [Giraffe].[dbo].[tlbBasicSyndromicSurveillanceAggregateHeader] 

(

					[idfAggregateHeader]

					, [strFormID]

					, [datDateEntered]

					, [datDateLastSaved]

					, [idfEnteredBy]

					, [idfsSite]

					, [intYear]

					, [intWeek]

					, [datStartDate]

					, [datFinishDate]

					, [datModificationForArchiveDate]

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

					, [LegacyFormID]
)
select 

					tlbBasicSyndromicSurveillanceAggregateHeader_v6.[idfAggregateHeader]

					, tlbBasicSyndromicSurveillanceAggregateHeader_v6.[strFormID]

					, tlbBasicSyndromicSurveillanceAggregateHeader_v6.[datDateEntered]

					, tlbBasicSyndromicSurveillanceAggregateHeader_v6.[datDateLastSaved]

					, j_tlbPerson_idfEnteredBy_v7.[idfPerson]

					, j_tstSite_idfsSite_v7.[idfsSite]

					, tlbBasicSyndromicSurveillanceAggregateHeader_v6.[intYear]

					, tlbBasicSyndromicSurveillanceAggregateHeader_v6.[intWeek]

					, tlbBasicSyndromicSurveillanceAggregateHeader_v6.[datStartDate]

					, tlbBasicSyndromicSurveillanceAggregateHeader_v6.[datFinishDate]

					, tlbBasicSyndromicSurveillanceAggregateHeader_v6.[datModificationForArchiveDate]

					, tlbBasicSyndromicSurveillanceAggregateHeader_v6.[intRowStatus]

					, tlbBasicSyndromicSurveillanceAggregateHeader_v6.[rowguid]

					, tlbBasicSyndromicSurveillanceAggregateHeader_v6.[strMaintenanceFlag]

					, tlbBasicSyndromicSurveillanceAggregateHeader_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfAggregateHeader":' + isnull(cast(tlbBasicSyndromicSurveillanceAggregateHeader_v6.[idfAggregateHeader] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()

					, tlbBasicSyndromicSurveillanceAggregateHeader_v6.[strFormID] /*Rule for the new field in EIDSSv7: LegacyFormID*/
from [Falcon].[dbo].[tlbBasicSyndromicSurveillanceAggregateHeader] tlbBasicSyndromicSurveillanceAggregateHeader_v6 


					left join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfEnteredBy_v7

		on	


					j_tlbPerson_idfEnteredBy_v7.[idfPerson] = tlbBasicSyndromicSurveillanceAggregateHeader_v6.[idfEnteredBy] 

					left join	[Giraffe].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tlbBasicSyndromicSurveillanceAggregateHeader_v6.[idfsSite] 
left join	[Giraffe].[dbo].[tlbBasicSyndromicSurveillanceAggregateHeader] tlbBasicSyndromicSurveillanceAggregateHeader_v7 
on	

					tlbBasicSyndromicSurveillanceAggregateHeader_v7.[idfAggregateHeader] = tlbBasicSyndromicSurveillanceAggregateHeader_v6.[idfAggregateHeader] 
where tlbBasicSyndromicSurveillanceAggregateHeader_v7.[idfAggregateHeader] is null 
print N'Table [tlbBasicSyndromicSurveillanceAggregateHeader] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbBasicSyndromicSurveillanceAggregateDetail]
************************************************************/
insert into [Giraffe].[dbo].[tlbBasicSyndromicSurveillanceAggregateDetail] 

(

					[idfAggregateDetail]

					, [idfAggregateHeader]

					, [idfHospital]

					, [intAge0_4]

					, [intAge5_14]

					, [intAge15_29]

					, [intAge30_64]

					, [intAge65]

					, [inTotalILI]

					, [intTotalAdmissions]

					, [intILISamples]

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

					tlbBasicSyndromicSurveillanceAggregateDetail_v6.[idfAggregateDetail]

					, j_tlbBasicSyndromicSurveillanceAggregateHeader_idfAggregateHeader_v7.[idfAggregateHeader]

					, j_tlbOffice_idfHospital_v7.[idfOffice]

					, tlbBasicSyndromicSurveillanceAggregateDetail_v6.[intAge0_4]

					, tlbBasicSyndromicSurveillanceAggregateDetail_v6.[intAge5_14]

					, tlbBasicSyndromicSurveillanceAggregateDetail_v6.[intAge15_29]

					, tlbBasicSyndromicSurveillanceAggregateDetail_v6.[intAge30_64]

					, tlbBasicSyndromicSurveillanceAggregateDetail_v6.[intAge65]

					, tlbBasicSyndromicSurveillanceAggregateDetail_v6.[inTotalILI]

					, tlbBasicSyndromicSurveillanceAggregateDetail_v6.[intTotalAdmissions]

					, tlbBasicSyndromicSurveillanceAggregateDetail_v6.[intILISamples]

					, tlbBasicSyndromicSurveillanceAggregateDetail_v6.[intRowStatus]

					, tlbBasicSyndromicSurveillanceAggregateDetail_v6.[rowguid]

					, tlbBasicSyndromicSurveillanceAggregateDetail_v6.[strMaintenanceFlag]

					, tlbBasicSyndromicSurveillanceAggregateDetail_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfAggregateDetail":' + isnull(cast(tlbBasicSyndromicSurveillanceAggregateDetail_v6.[idfAggregateDetail] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbBasicSyndromicSurveillanceAggregateDetail] tlbBasicSyndromicSurveillanceAggregateDetail_v6 


					inner join	[Giraffe].[dbo].[tlbBasicSyndromicSurveillanceAggregateHeader] j_tlbBasicSyndromicSurveillanceAggregateHeader_idfAggregateHeader_v7

		on	


					j_tlbBasicSyndromicSurveillanceAggregateHeader_idfAggregateHeader_v7.[idfAggregateHeader] = tlbBasicSyndromicSurveillanceAggregateDetail_v6.[idfAggregateHeader] 

					inner join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfHospital_v7

		on	


					j_tlbOffice_idfHospital_v7.[idfOffice] = tlbBasicSyndromicSurveillanceAggregateDetail_v6.[idfHospital] 
left join	[Giraffe].[dbo].[tlbBasicSyndromicSurveillanceAggregateDetail] tlbBasicSyndromicSurveillanceAggregateDetail_v7 
on	

					tlbBasicSyndromicSurveillanceAggregateDetail_v7.[idfAggregateDetail] = tlbBasicSyndromicSurveillanceAggregateDetail_v6.[idfAggregateDetail] 
where tlbBasicSyndromicSurveillanceAggregateDetail_v7.[idfAggregateDetail] is null 
print N'Table [tlbBasicSyndromicSurveillanceAggregateDetail] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tflBasicSyndromicSurveillanceAggregateHeaderFiltered]
************************************************************/
insert into [Giraffe].[dbo].[tflBasicSyndromicSurveillanceAggregateHeaderFiltered] 

(

					[idfBasicSyndromicSurveillanceAggregateHeaderFiltered]

					, [idfAggregateHeader]

					, [idfSiteGroup]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tflBasicSyndromicSurveillanceAggregateHeaderFiltered_v6.[idfBasicSyndromicSurveillanceAggregateHeaderFiltered]

					, j_tlbBasicSyndromicSurveillanceAggregateHeader_idfAggregateHeader_v7.[idfAggregateHeader]

					, j_tflSiteGroup_idfSiteGroup_v7.[idfSiteGroup]

					, tflBasicSyndromicSurveillanceAggregateHeaderFiltered_v6.[rowguid]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfBasicSyndromicSurveillanceAggregateHeaderFiltered":' + isnull(cast(tflBasicSyndromicSurveillanceAggregateHeaderFiltered_v6.[idfBasicSyndromicSurveillanceAggregateHeaderFiltered] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tflBasicSyndromicSurveillanceAggregateHeaderFiltered] tflBasicSyndromicSurveillanceAggregateHeaderFiltered_v6 


					inner join	[Giraffe].[dbo].[tlbBasicSyndromicSurveillanceAggregateHeader] j_tlbBasicSyndromicSurveillanceAggregateHeader_idfAggregateHeader_v7

		on	


					j_tlbBasicSyndromicSurveillanceAggregateHeader_idfAggregateHeader_v7.[idfAggregateHeader] = tflBasicSyndromicSurveillanceAggregateHeaderFiltered_v6.[idfAggregateHeader] 

					inner join	[Giraffe].[dbo].[tflSiteGroup] j_tflSiteGroup_idfSiteGroup_v7

		on	


					j_tflSiteGroup_idfSiteGroup_v7.[idfSiteGroup] = tflBasicSyndromicSurveillanceAggregateHeaderFiltered_v6.[idfSiteGroup] 
left join	[Giraffe].[dbo].[tflBasicSyndromicSurveillanceAggregateHeaderFiltered] tflBasicSyndromicSurveillanceAggregateHeaderFiltered_v7 
on	

					tflBasicSyndromicSurveillanceAggregateHeaderFiltered_v7.[idfBasicSyndromicSurveillanceAggregateHeaderFiltered] = tflBasicSyndromicSurveillanceAggregateHeaderFiltered_v6.[idfBasicSyndromicSurveillanceAggregateHeaderFiltered] 
where tflBasicSyndromicSurveillanceAggregateHeaderFiltered_v7.[idfBasicSyndromicSurveillanceAggregateHeaderFiltered] is null 
print N'Table [tflBasicSyndromicSurveillanceAggregateHeaderFiltered] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tlbBasicSyndromicSurveillance]
************************************************************/
insert into [Giraffe].[dbo].[tlbBasicSyndromicSurveillance] 

(

					[idfBasicSyndromicSurveillance]

					, [strFormID]

					, [datDateEntered]

					, [datDateLastSaved]

					, [idfEnteredBy]

					, [idfsSite]

					, [idfsBasicSyndromicSurveillanceType]

					, [idfHospital]

					, [datReportDate]

					, [intAgeYear]

					, [intAgeMonth]

					, [strPersonalID]

					, [idfsYNPregnant]

					, [idfsYNPostpartumPeriod]

					, [datDateOfSymptomsOnset]

					, [idfsYNFever]

					, [idfsMethodOfMeasurement]

					, [strMethod]

					, [idfsYNCough]

					, [idfsYNShortnessOfBreath]

					, [idfsYNSeasonalFluVaccine]

					, [datDateOfCare]

					, [idfsYNPatientWasHospitalized]

					, [idfsOutcome]

					, [idfsYNPatientWasInER]

					, [idfsYNTreatment]

					, [idfsYNAdministratedAntiviralMedication]

					, [strNameOfMedication]

					, [datDateReceivedAntiviralMedication]

					, [blnRespiratorySystem]

					, [blnAsthma]

					, [blnDiabetes]

					, [blnCardiovascular]

					, [blnObesity]

					, [blnRenal]

					, [blnLiver]

					, [blnNeurological]

					, [blnImmunodeficiency]

					, [blnUnknownEtiology]

					, [datSampleCollectionDate]

					, [strSampleID]

					, [idfsTestResult]

					, [datTestResultDate]

					, [idfHuman]

					, [datModificationForArchiveDate]

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

					tlbBasicSyndromicSurveillance_v6.[idfBasicSyndromicSurveillance]

					, tlbBasicSyndromicSurveillance_v6.[strFormID]

					, tlbBasicSyndromicSurveillance_v6.[datDateEntered]

					, tlbBasicSyndromicSurveillance_v6.[datDateLastSaved]

					, j_tlbPerson_idfEnteredBy_v7.[idfPerson]

					, j_tstSite_idfsSite_v7.[idfsSite]

					, j_trtBaseReference_idfsBasicSyndromicSurveillanceType_v7.[idfsBaseReference]

					, j_tlbOffice_idfHospital_v7.[idfOffice]

					, tlbBasicSyndromicSurveillance_v6.[datReportDate]

					, tlbBasicSyndromicSurveillance_v6.[intAgeYear]

					, tlbBasicSyndromicSurveillance_v6.[intAgeMonth]

					, tlbBasicSyndromicSurveillance_v6.[strPersonalID]

					, j_trtBaseReference_idfsYNPregnant_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsYNPostpartumPeriod_v7.[idfsBaseReference]

					, tlbBasicSyndromicSurveillance_v6.[datDateOfSymptomsOnset]

					, j_trtBaseReference_idfsYNFever_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsMethodOfMeasurement_v7.[idfsBaseReference]

					, tlbBasicSyndromicSurveillance_v6.[strMethod]

					, j_trtBaseReference_idfsYNCough_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsYNShortnessOfBreath_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsYNSeasonalFluVaccine_v7.[idfsBaseReference]

					, tlbBasicSyndromicSurveillance_v6.[datDateOfCare]

					, j_trtBaseReference_idfsYNPatientWasHospitalized_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsOutcome_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsYNPatientWasInER_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsYNTreatment_v7.[idfsBaseReference]

					, j_trtBaseReference_idfsYNAdministratedAntiviralMedication_v7.[idfsBaseReference]

					, tlbBasicSyndromicSurveillance_v6.[strNameOfMedication]

					, tlbBasicSyndromicSurveillance_v6.[datDateReceivedAntiviralMedication]

					, tlbBasicSyndromicSurveillance_v6.[blnRespiratorySystem]

					, tlbBasicSyndromicSurveillance_v6.[blnAsthma]

					, tlbBasicSyndromicSurveillance_v6.[blnDiabetes]

					, tlbBasicSyndromicSurveillance_v6.[blnCardiovascular]

					, tlbBasicSyndromicSurveillance_v6.[blnObesity]

					, tlbBasicSyndromicSurveillance_v6.[blnRenal]

					, tlbBasicSyndromicSurveillance_v6.[blnLiver]

					, tlbBasicSyndromicSurveillance_v6.[blnNeurological]

					, tlbBasicSyndromicSurveillance_v6.[blnImmunodeficiency]

					, tlbBasicSyndromicSurveillance_v6.[blnUnknownEtiology]

					, tlbBasicSyndromicSurveillance_v6.[datSampleCollectionDate]

					, tlbBasicSyndromicSurveillance_v6.[strSampleID]

					, j_trtBaseReference_idfsTestResult_v7.[idfsBaseReference]

					, tlbBasicSyndromicSurveillance_v6.[datTestResultDate]

					, j_tlbHuman_idfHuman_v7.[idfHuman]

					, tlbBasicSyndromicSurveillance_v6.[datModificationForArchiveDate]

					, tlbBasicSyndromicSurveillance_v6.[intRowStatus]

					, tlbBasicSyndromicSurveillance_v6.[rowguid]

					, tlbBasicSyndromicSurveillance_v6.[strMaintenanceFlag]

					, tlbBasicSyndromicSurveillance_v6.[strReservedAttribute]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfBasicSyndromicSurveillance":' + isnull(cast(tlbBasicSyndromicSurveillance_v6.[idfBasicSyndromicSurveillance] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tlbBasicSyndromicSurveillance] tlbBasicSyndromicSurveillance_v6 


					inner join	[Giraffe].[dbo].[tlbPerson] j_tlbPerson_idfEnteredBy_v7

		on	


					j_tlbPerson_idfEnteredBy_v7.[idfPerson] = tlbBasicSyndromicSurveillance_v6.[idfEnteredBy] 

					inner join	[Giraffe].[dbo].[tstSite] j_tstSite_idfsSite_v7

		on	


					j_tstSite_idfsSite_v7.[idfsSite] = tlbBasicSyndromicSurveillance_v6.[idfsSite] 

					inner join	[Giraffe].[dbo].[tlbHuman] j_tlbHuman_idfHuman_v7

		on	


					j_tlbHuman_idfHuman_v7.[idfHuman] = tlbBasicSyndromicSurveillance_v6.[idfHuman] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsBasicSyndromicSurveillanceType_v7

		on	


					j_trtBaseReference_idfsBasicSyndromicSurveillanceType_v7.[idfsBaseReference] = tlbBasicSyndromicSurveillance_v6.[idfsBasicSyndromicSurveillanceType] 

					left join	[Giraffe].[dbo].[tlbOffice] j_tlbOffice_idfHospital_v7

		on	


					j_tlbOffice_idfHospital_v7.[idfOffice] = tlbBasicSyndromicSurveillance_v6.[idfHospital] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsYNPregnant_v7

		on	


					j_trtBaseReference_idfsYNPregnant_v7.[idfsBaseReference] = tlbBasicSyndromicSurveillance_v6.[idfsYNPregnant] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsYNPostpartumPeriod_v7

		on	


					j_trtBaseReference_idfsYNPostpartumPeriod_v7.[idfsBaseReference] = tlbBasicSyndromicSurveillance_v6.[idfsYNPostpartumPeriod] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsYNFever_v7

		on	


					j_trtBaseReference_idfsYNFever_v7.[idfsBaseReference] = tlbBasicSyndromicSurveillance_v6.[idfsYNFever] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsMethodOfMeasurement_v7

		on	


					j_trtBaseReference_idfsMethodOfMeasurement_v7.[idfsBaseReference] = tlbBasicSyndromicSurveillance_v6.[idfsMethodOfMeasurement] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsYNCough_v7

		on	


					j_trtBaseReference_idfsYNCough_v7.[idfsBaseReference] = tlbBasicSyndromicSurveillance_v6.[idfsYNCough] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsYNShortnessOfBreath_v7

		on	


					j_trtBaseReference_idfsYNShortnessOfBreath_v7.[idfsBaseReference] = tlbBasicSyndromicSurveillance_v6.[idfsYNShortnessOfBreath] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsYNSeasonalFluVaccine_v7

		on	


					j_trtBaseReference_idfsYNSeasonalFluVaccine_v7.[idfsBaseReference] = tlbBasicSyndromicSurveillance_v6.[idfsYNSeasonalFluVaccine] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsYNPatientWasHospitalized_v7

		on	


					j_trtBaseReference_idfsYNPatientWasHospitalized_v7.[idfsBaseReference] = tlbBasicSyndromicSurveillance_v6.[idfsYNPatientWasHospitalized] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsOutcome_v7

		on	


					j_trtBaseReference_idfsOutcome_v7.[idfsBaseReference] = tlbBasicSyndromicSurveillance_v6.[idfsOutcome] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsYNPatientWasInER_v7

		on	


					j_trtBaseReference_idfsYNPatientWasInER_v7.[idfsBaseReference] = tlbBasicSyndromicSurveillance_v6.[idfsYNPatientWasInER] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsYNTreatment_v7

		on	


					j_trtBaseReference_idfsYNTreatment_v7.[idfsBaseReference] = tlbBasicSyndromicSurveillance_v6.[idfsYNTreatment] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsYNAdministratedAntiviralMedication_v7

		on	


					j_trtBaseReference_idfsYNAdministratedAntiviralMedication_v7.[idfsBaseReference] = tlbBasicSyndromicSurveillance_v6.[idfsYNAdministratedAntiviralMedication] 

					left join	[Giraffe].[dbo].[trtBaseReference] j_trtBaseReference_idfsTestResult_v7

		on	


					j_trtBaseReference_idfsTestResult_v7.[idfsBaseReference] = tlbBasicSyndromicSurveillance_v6.[idfsTestResult] 
left join	[Giraffe].[dbo].[tlbBasicSyndromicSurveillance] tlbBasicSyndromicSurveillance_v7 
on	

					tlbBasicSyndromicSurveillance_v7.[idfBasicSyndromicSurveillance] = tlbBasicSyndromicSurveillance_v6.[idfBasicSyndromicSurveillance] 
where tlbBasicSyndromicSurveillance_v7.[idfBasicSyndromicSurveillance] is null 
print N'Table [tlbBasicSyndromicSurveillance] - insert: ' + cast(@@rowcount as nvarchar(20))

/************************************************************
* Insert records - [tflBasicSyndromicSurveillanceFiltered]
************************************************************/
insert into [Giraffe].[dbo].[tflBasicSyndromicSurveillanceFiltered] 

(

					[idfBasicSyndromicSurveillanceFiltered]

					, [idfBasicSyndromicSurveillance]

					, [idfSiteGroup]

					, [rowguid]

					, [SourceSystemNameID]

					, [SourceSystemKeyValue]

					, [AuditCreateUser]

					, [AuditCreateDTM]

					, [AuditUpdateUser]

					, [AuditUpdateDTM]
)
select 

					tflBasicSyndromicSurveillanceFiltered_v6.[idfBasicSyndromicSurveillanceFiltered]

					, j_tlbBasicSyndromicSurveillance_idfBasicSyndromicSurveillance_v7.[idfBasicSyndromicSurveillance]

					, j_tflSiteGroup_idfSiteGroup_v7.[idfSiteGroup]

					, tflBasicSyndromicSurveillanceFiltered_v6.[rowguid]

					, 10519002 /*Record Source: EIDSS6.1*/

					, N'[{' + N'"idfBasicSyndromicSurveillanceFiltered":' + isnull(cast(tflBasicSyndromicSurveillanceFiltered_v6.[idfBasicSyndromicSurveillanceFiltered] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS

					, N'system'

					, GETUTCDATE()

					, N'system'

					, GETUTCDATE()
from [Falcon].[dbo].[tflBasicSyndromicSurveillanceFiltered] tflBasicSyndromicSurveillanceFiltered_v6 


					inner join	[Giraffe].[dbo].[tlbBasicSyndromicSurveillance] j_tlbBasicSyndromicSurveillance_idfBasicSyndromicSurveillance_v7

		on	


					j_tlbBasicSyndromicSurveillance_idfBasicSyndromicSurveillance_v7.[idfBasicSyndromicSurveillance] = tflBasicSyndromicSurveillanceFiltered_v6.[idfBasicSyndromicSurveillance] 

					inner join	[Giraffe].[dbo].[tflSiteGroup] j_tflSiteGroup_idfSiteGroup_v7

		on	


					j_tflSiteGroup_idfSiteGroup_v7.[idfSiteGroup] = tflBasicSyndromicSurveillanceFiltered_v6.[idfSiteGroup] 
left join	[Giraffe].[dbo].[tflBasicSyndromicSurveillanceFiltered] tflBasicSyndromicSurveillanceFiltered_v7 
on	

					tflBasicSyndromicSurveillanceFiltered_v7.[idfBasicSyndromicSurveillanceFiltered] = tflBasicSyndromicSurveillanceFiltered_v6.[idfBasicSyndromicSurveillanceFiltered] 
where tflBasicSyndromicSurveillanceFiltered_v7.[idfBasicSyndromicSurveillanceFiltered] is null 
print N'Table [tflBasicSyndromicSurveillanceFiltered] - insert: ' + cast(@@rowcount as nvarchar(20))

    
--

/************************************************************
* Update/insert records with links to foreign key data - [tlbHuman]
************************************************************/

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
		, 'system'
		, GETUTCDATE()
		, 'system'
		, GETUTCDATE()
		, 10519002 /*Record Source: EIDSS6.1*/
		, N'[{' + N'"HumanAdditionalInfo":' + isnull(cast(cch.[idfHuman_v7] as nvarchar(20)), N'null') + N'}]' collate Cyrillic_General_CI_AS
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
print N'Table [HumanAddlInfo] - insert new detailed info (including reported Age) for copies of the persons: ' + cast(@@rowcount as nvarchar(20))

      

/************************************************************
* Update/insert records with links to foreign key data - [tlbFreezerSubdivision]
************************************************************/

update		tlbFreezerSubdivision_v7
set			tlbFreezerSubdivision_v7.idfParentSubdivision = tlbFreezerSubdivision_parent_v7.idfSubdivision
from		[Giraffe].[dbo].[tlbFreezerSubdivision] tlbFreezerSubdivision_v7
inner join	[Falcon].[dbo].[tlbFreezerSubdivision] tlbFreezerSubdivision_v6
on			tlbFreezerSubdivision_v6.idfSubdivision = tlbFreezerSubdivision_v7.idfSubdivision
inner join	[Giraffe].[dbo].[tlbFreezerSubdivision] tlbFreezerSubdivision_parent_v7
on			tlbFreezerSubdivision_parent_v7.idfSubdivision = tlbFreezerSubdivision_v6.idfParentSubdivision
where		tlbFreezerSubdivision_V7.idfParentSubdivision is null
print	N'Table [tlbFreezerSubdivision] - update link to the parent subdivision from migrated subdivisions: ' + cast(@@rowcount as nvarchar(20))

           

/************************************************************
* Update/insert records with links to foreign key data - [tlbOutbreak]
************************************************************/

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
print	N'Table [tlbOutbreak] - update link to the primary case/session from migrated outbreaks: ' + cast(@@rowcount as nvarchar(20))

      

/************************************************************
* Update/insert records with links to foreign key data - [tlbVector]
************************************************************/

update		tlbVector_v7
set			tlbVector_v7.idfHostVector = tlbVector_host_v7.idfVector
from		[Giraffe].[dbo].[tlbVector] tlbVector_v7
inner join	[Falcon].[dbo].[tlbVector] tlbVector_v6
on			tlbVector_v6.idfVector = tlbVector_v7.idfVector
inner join	[Giraffe].[dbo].[tlbVector] tlbVector_host_v7
on			tlbVector_host_v7.idfVector = tlbVector_v6.idfHostVector
where		tlbVector_V7.idfHostVector is null
print	N'Table [tlbVector] - update link to the host Vector from migrated vectors: ' + cast(@@rowcount as nvarchar(20))

  

/************************************************************
* Update/insert records with links to foreign key data - [tlbMonitoringSession]
************************************************************/

update		tlbFarm_v7
set			tlbFarm_v7.[idfMonitoringSession] = tlbMonitoringSession_v7.[idfMonitoringSession]
from		[Giraffe].[dbo].[tlbFarm] tlbFarm_v7
inner join	[Falcon].[dbo].[tlbFarm] tlbFarm_v6
on			tlbFarm_v6.[idfFarm] = tlbFarm_v7.[idfFarm]
inner join	[Giraffe].[dbo].[tlbMonitoringSession] tlbMonitoringSession_v7
on			tlbMonitoringSession_v7.[idfMonitoringSession] = tlbFarm_v6.[idfMonitoringSession]
where		tlbFarm_v7.[idfMonitoringSession] is null
print	N'Table [tlbFarm] - update link to the AS Session from migrated copies of farms: ' + cast(@@rowcount as nvarchar(20))

     

/************************************************************
* Update/insert records with links to foreign key data - [tlbHumanCase]
************************************************************/

update		tlbHumanCase_v7
set			tlbHumanCase_v7.[idfDeduplicationResultCase] = tlbHumanCase_dedupl_v7.[idfHumanCase]
from		[Giraffe].[dbo].[tlbHumanCase] tlbHumanCase_v7
inner join	[Giraffe].[dbo].[_dmccHumanCase] cchc
on			cchc.[idfHumanCase_v7] = tlbHumanCase_v7.[idfHumanCase]
inner join	[Giraffe].[dbo].[tlbHumanCase] tlbHumanCase_dedupl_v7
on			tlbHumanCase_dedupl_v7.[idfHumanCase] = cchc.[idfDeduplicationResultCase_v7]
where		tlbHumanCase_v7.[idfDeduplicationResultCase] is null
print	N'Table [tlbHumanCase] - update link to the deduplication case survivor from migrated HDRs: ' + cast(@@rowcount as nvarchar(20))
  

/************************************************************
* Update/insert records with links to foreign key data - [tlbMaterial]
************************************************************/

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
print	N'Table [tlbMaterial] - update link to the parent sample from migrated samples: ' + cast(@@rowcount as nvarchar(20))

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
print	N'Table [tlbMaterial] - update link to the root sample from migrated samples: ' + cast(@@rowcount as nvarchar(20))

  

/************************************************************
* Update/insert records with links to foreign key data - [tlbTesting]
************************************************************/

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
print	N'Table [tlbMaterial] - update link to the main test from migrated samples: ' + cast(@@rowcount as nvarchar(20))



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
print	N'Table [tlbMaterial] - update Test Unassigned Indicator for migrated samples: ' + cast(@@rowcount as nvarchar(20))
            


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
print	N'Table [tlbMaterial] - update Test Completed Indicator for migrated samples: ' + cast(@@rowcount as nvarchar(20))

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
print	N'Table [tlbMaterial] - update Transfer Indicator for migrated samples: ' + cast(@@rowcount as nvarchar(20))




--

print N''
print N'Insert records - Tables with records related to data modules - end'
print N''
print N''
/************************************************************
* Insert records - Tables with records related to data modules - end
************************************************************/






--


/************************************************************
* Reset identifier seed value - start
************************************************************/

--declare	@sqlIdResetCmd				nvarchar(max)
set	@sqlIdResetCmd = N''

set	@sqlIdResetCmd = N'

declare @TempIdentifierSeedValue bigint = ' + cast(@CDRSite as nvarchar(20)) + N'

declare	@max_value			bigint
set	@max_value = @TempIdentifierSeedValue

declare	@seed_value			bigint
set	@seed_value = null
declare	@increment_value	bigint
set	@increment_value = null

declare	@sqlCmd				nvarchar(max)
set	@sqlCmd = N''''

' collate Cyrillic_General_CI_AS

select	@sqlIdResetCmd = @sqlIdResetCmd + N'
	-- dbo.' + t.[name] + N': ' + c_ic.[name] + N'
	if	exists	(
			select	1 
			from	[Falcon].[sys].[tables] t
			inner join	[Falcon].sys.objects o_t
			on			o_t.[object_id] = t.[object_id]
						and o_t.[type] = N''U'' collate Cyrillic_General_CI_AS
			inner join	[Falcon].sys.schemas s
			on			s.[schema_id] = t.[schema_id]
						and s.[name] = N''dbo'' collate Cyrillic_General_CI_AS			
			where		t.[name] = N''' + t.[name] + N''' collate Cyrillic_General_CI_AS
				)
	begin
		if	exists	(
				select	1
				from	[Falcon].[dbo].[' + t.[name] + N']
				where	[' + c_ic.[name] + N'] >= @max_value
						and ([' + c_ic.[name] + '] - @TempIdentifierSeedValue) % 10000000 = 0
					)
		begin
			select		@max_value = max(' + c_ic.[name] + N') + 10000000
			from		[Falcon].[dbo].[' + t.[name] + N']
			where		([' + c_ic.[name] + '] - @TempIdentifierSeedValue) % 10000000 = 0
		end
	end
'
from
-- Table
			[Falcon].sys.tables t
inner join	[Falcon].sys.objects o_t
on			o_t.[object_id] = t.[object_id]
			and o_t.[type] = N'U' collate Cyrillic_General_CI_AS
			and o_t.[name] not like N'gis%' collate Cyrillic_General_CI_AS
			and o_t.[name] not like N'tfl%' collate Cyrillic_General_CI_AS
			and o_t.[name] not like N'Lkup%' collate Cyrillic_General_CI_AS

inner join	[Falcon].sys.schemas s
on			s.[schema_id] = t.[schema_id]
			and s.[name] = N'dbo' collate Cyrillic_General_CI_AS

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
			and c_ic.[name] <> N'idfsLanguage'
			and c_ic.[system_type_id] in (127, 56)
where		not exists	(
					select	1
					from		[Falcon].sys.index_columns ic_second
					inner join	[Falcon].sys.columns c_ic_second
					on			c_ic_second.[object_id] = ic_second.[object_id]
								and c_ic_second.[column_id] = ic_second.[column_id]
								and c_ic_second.[name] <> N'idfsLanguage'
								and c_ic_second.[system_type_id]  in (127, 56)
								and	c_ic_second.[column_id] <> c_ic.[column_id]
					where		ic_second.[object_id] = i.[object_id]
								and ic_second.[index_id] = i.[index_id]
						)



--

set	@sqlIdResetCmd = @sqlIdResetCmd + N'
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
where		NewIDtable.[id] = object_id(N''[dbo].[tstNewID]'') 
			and OBJECTPROPERTY(NewIDtable.[id], N''IsUserTable'') = 1
			and NewIDcol.[name] = N''NewID''

if	(@seed_value is null) or (@increment_value is null)
	or (@seed_value is not null and (@seed_value < @max_value) and ((isnull(@seed_value, 0) - @max_value) % 10000000 = 0))
	or (@seed_value is not null and ((isnull(@seed_value, 0) - @max_value) % 10000000 <> 0))
--			or (@increment_value <> 10000000)
begin
	set @sqlCmd = N''
if	exists	(
select	1 
from	[Giraffe].[dbo].sysobjects 
where	id = object_id(N''''[dbo].[tstNewID]'''') 
		and OBJECTPROPERTY(id, N''''IsUserTable'''') = 1
	)
drop table [dbo].[tstNewID]

''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''
create table	[dbo].[tstNewID]
(	NewID		bigint IDENTITY('' + cast(@max_value as nvarchar(20)) + N'', 10000000) not null,
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
''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''
ALTER TABLE [dbo].[tstNewID] ADD  CONSTRAINT [DF_tstNewID_rowguid]  DEFAULT (newsequentialid()) FOR [rowguid]
''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''
ALTER TABLE [dbo].[tstNewID] ADD  CONSTRAINT [DF_tstNewID_CreateDTM]  DEFAULT (getdate()) FOR [AuditCreateDTM]
''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''
ALTER TABLE [dbo].[tstNewID]  WITH CHECK ADD  CONSTRAINT [FK_tstNewID_trtBaseReference_SourceSystemNameID] FOREIGN KEY([SourceSystemNameID])
REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''
ALTER TABLE [dbo].[tstNewID] CHECK CONSTRAINT [FK_tstNewID_trtBaseReference_SourceSystemNameID]
''
	execute sp_executesql @sqlCmd

	print	''New consequent ID value in the table tstNewID: '' + cast(@max_value as varchar(30))
end
else 
	print ''Update of consequent ID value in the table tstNewID is not needed: '' + cast(@seed_value as varchar(30))
'
exec [Giraffe].[sys].sp_executesql @sqlIdResetCmd


--



set	@sqlIdResetCmd = N'

declare @TempIdentifierSeedValue bigint = ' + cast(@CDRSite as nvarchar(20)) + N'

declare	@max_value			bigint
set	@max_value = @TempIdentifierSeedValue

declare	@seed_value			bigint
set	@seed_value = null
declare	@increment_value	bigint
set	@increment_value = null

declare	@sqlCmd				nvarchar(max)
set	@sqlCmd = N''''

' collate Cyrillic_General_CI_AS


select	@sqlIdResetCmd = @sqlIdResetCmd + N'
	-- dbo.' + t.[name] + N': ' + c_ic.[name] + N'
	if	exists	(
			select	1 
			from	[Falcon].[sys].[tables] t
			inner join	[Falcon].sys.objects o_t
			on			o_t.[object_id] = t.[object_id]
						and o_t.[type] = N''U'' collate Cyrillic_General_CI_AS
			inner join	[Falcon].sys.schemas s
			on			s.[schema_id] = t.[schema_id]
						and s.[name] = N''dbo'' collate Cyrillic_General_CI_AS			
			where		t.[name] = N''' + t.[name] + N''' collate Cyrillic_General_CI_AS
				)
	begin
		if	exists	(
				select	1
				from	[Falcon].[dbo].[' + t.[name] + N']
				where	[' + c_ic.[name] + N'] >= @max_value
						and ([' + c_ic.[name] + '] - @TempIdentifierSeedValue) % 10000000 = 0
					)
		begin
			select		@max_value = max(' + c_ic.[name] + N') + 10000000
			from		[Falcon].[dbo].[' + t.[name] + N']
			where		([' + c_ic.[name] + '] - @TempIdentifierSeedValue) % 10000000 = 0
		end
	end
'
from
-- Table
			[Falcon].sys.tables t
inner join	[Falcon].sys.objects o_t
on			o_t.[object_id] = t.[object_id]
			and o_t.[type] = N'U' collate Cyrillic_General_CI_AS
			and o_t.[name] like N'tfl%' collate Cyrillic_General_CI_AS

inner join	[Falcon].sys.schemas s
on			s.[schema_id] = t.[schema_id]
			and s.[name] = N'dbo' collate Cyrillic_General_CI_AS

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
			and c_ic.[name] <> N'idfsSite'
			and c_ic.[system_type_id] in (127, 56)
where		not exists	(
					select	1
					from		[Falcon].sys.index_columns ic_second
					inner join	[Falcon].sys.columns c_ic_second
					on			c_ic_second.[object_id] = ic_second.[object_id]
								and c_ic_second.[column_id] = ic_second.[column_id]
								and c_ic_second.[name] <> N'idfsLanguage'
								and c_ic_second.[system_type_id]  in (127, 56)
								and	c_ic_second.[column_id] <> c_ic.[column_id]
					where		ic_second.[object_id] = i.[object_id]
								and ic_second.[index_id] = i.[index_id]
						)



--

set	@sqlIdResetCmd = @sqlIdResetCmd + N'
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
where		NewIDtable.[id] = object_id(N''[dbo].[tflNewID]'') 
			and OBJECTPROPERTY(NewIDtable.[id], N''IsUserTable'') = 1
			and NewIDcol.[name] = N''NewID''

if	(@seed_value is null) or (@increment_value is null)
	or (@seed_value is not null and (@seed_value < @max_value) and ((isnull(@seed_value, 0) - @max_value) % 10000000 = 0))
	or (@seed_value is not null and ((isnull(@seed_value, 0) - @max_value) % 10000000 <> 0))
--			or (@increment_value <> 10000000)
begin
	set @sqlCmd = N''
if	exists	(
select	1 
from	[Giraffe].[dbo].sysobjects 
where	id = object_id(N''''[dbo].[tflNewID]'''') 
		and OBJECTPROPERTY(id, N''''IsUserTable'''') = 1
	)
drop table [dbo].[tflNewID]

''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''
create table	[dbo].[tflNewID]
(	NewID			bigint IDENTITY('' + cast(@max_value as nvarchar(20)) + N'', 10000000) not null,
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
''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''
ALTER TABLE [dbo].[tflNewID] ADD  CONSTRAINT [DF_tflNewID_rowguid]  DEFAULT (newsequentialid()) FOR [rowguid]
''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''
ALTER TABLE [dbo].[tflNewID] ADD  CONSTRAINT [DEF_tflNewID_SourceSystemNameID]  DEFAULT ((10519001)) FOR [SourceSystemNameID]
''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''
ALTER TABLE [dbo].[tflNewID] ADD  CONSTRAINT [DF_tflNewID_CreateDTM]  DEFAULT (getdate()) FOR [AuditCreateDTM]
''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''
ALTER TABLE [dbo].[tflNewID]  WITH CHECK ADD  CONSTRAINT [FK_tflNewID_trtBaseReference_SourceSystemNameID] FOREIGN KEY([SourceSystemNameID])
REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
''
	execute sp_executesql @sqlCmd

	set	@sqlCmd = N''
ALTER TABLE [dbo].[tflNewID] CHECK CONSTRAINT [FK_tflNewID_trtBaseReference_SourceSystemNameID]
''
	execute sp_executesql @sqlCmd

	print	''New consequent ID value in the table tflNewID: '' + cast(@max_value as varchar(30))
end
else 
	print ''Update of consequent ID value in the table tflNewID is not needed: '' + cast(@seed_value as varchar(30))
'
execute [Giraffe].[dbo].sp_executesql @sqlIdResetCmd
/************************************************************
* Reset identifier seed value - end
************************************************************/


--



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

DELETE FROM [Giraffe].dbo.tstLocalSiteOptions WHERE strName = 'Context' collate Cyrillic_General_CI_AS and strValue = 'DataMigration' collate Cyrillic_General_CI_AS

DELETE FROM [Giraffe].dbo.tstLocalConnectionContext WHERE strConnectionContext = 'DataMigration' collate Cyrillic_General_CI_AS

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

