-- This script applies customization format to the reference table with type Diagnosis.
-- It should be executed on the database, for which customization format should be applied.
-- NB! It is assumed the check of source data (@ReferenceTable) has been already verified before applying the format.

use [Giraffe]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- select * from fnGetLanguageCode('en','rftCountry')

CREATE or ALTER          function [dbo].[fnGetLanguageCode](@LangID  nvarchar(50))
returns bigint
as
BEGIN
DECLARE @LanguageCode bigint
SET @LanguageCode = CASE @LangID WHEN N'az-L'	THEN 10049001
		WHEN N'ru'			THEN 10049006
		WHEN N'ka'			THEN 10049004
		WHEN N'kk'			THEN 10049005
		WHEN N'uz-C'		THEN 10049007
		WHEN N'uz-L'		THEN 10049008
		WHEN N'uk'			THEN 10049009
		WHEN N'CISID-AZ'	THEN 10049002
		WHEN N'hy'			THEN 10049010
		WHEN N'ar-IQ'		THEN 10049015
		WHEN N'ar'			THEN 10049011
		WHEN N'vi'			THEN 10049012
		WHEN N'lo'			THEN 10049013
		WHEN N'th'			THEN 10049014
		ELSE 10049003 END
return @LanguageCode
END

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- select * from fnReference('ru',19000040)

CREATE or ALTER          function [dbo].[fnReference](@LangID  nvarchar(50), @type bigint)
returns table
as
return(

select
			b.idfsBaseReference as idfsReference, 
			IsNull(c.strTextString, b.strDefault) as [name],
			b.idfsReferenceType, 
			b.intHACode, 
			b.strDefault, 
			IsNull(c.strTextString, b.strDefault) as LongName,
			b.intOrder

from		dbo.trtBaseReference as b with(index=IX_trtBaseReference_RR)
left join	dbo.trtStringNameTranslation as c with(index=IX_trtStringNameTranslation_BL)
on			b.idfsBaseReference = c.idfsBaseReference and c.idfsLanguage = dbo.fnGetLanguageCode(@LangID)

where		b.idfsReferenceType = @type and b.intRowStatus = 0 
)

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


set nocount on
set XACT_ABORT on

BEGIN TRAN

-- Variables
declare	@ReferenceType		nvarchar(200)
declare	@idfsReferenceType	bigint

declare	@ReferenceTable		table
(	idfID				bigint not null identity(1, 1),
	idfsBaseReference	bigint null,
	strName_EN			nvarchar(200) collate database_default not null,
	strUsingType		varchar(200) collate database_default not null,
	idfsUsingType		bigint null,
	strICD10			nvarchar(200) collate database_default null,
	strOIE				nvarchar(200) collate database_default null,
	strName_AM			nvarchar(200) collate database_default null,
	strName_AZ			nvarchar(200) collate database_default null,
	strName_GG			nvarchar(200) collate database_default null,
	strName_KZ			nvarchar(200) collate database_default null,
	strName_RU			nvarchar(200) collate database_default null,
	strName_UA			nvarchar(200) collate database_default null,
	strName_IQ			nvarchar(200) collate database_default null,
	strName_TH			nvarchar(200) collate database_default null,
	strHACode			varchar(200) collate database_default null,
	intOrder			int null,
	blnZoonotic			bit null default 0,
	blnSyndromic		bit null default 0,
	strCustomizationPackageName		nvarchar(200) collate database_default not null,
	primary key	(
		strName_EN asc,
		strUsingType asc,
		strCustomizationPackageName
				)
)

declare	@AccessoryCode	table
(	intHACode	int not null primary key,
	strHACode	nvarchar(200) collate database_default not null
)

declare	@ConcordanceTable	table
(	idfsBaseReference				bigint not null primary key,
	strReferenceResolution			nvarchar(200) collate database_default not null
)

declare	@PerformDeletions	int

declare	@N	int

-- Set paremeters
set	@ReferenceType = N'Disease'

set	@PerformDeletions = 0
--	0 - incorrect reference values will be kept without changes.
--
--	1 -	incorrect reference values will be marked as deleted according to the concordance table;
--		records of reference (not aggregate) matrixes, permissions, FF determinants and custom report contents 
--		linked to incorrect reference values will be deleted;
--		user objects (cases, samples, tests, etc.) linked to incorrect reference values will be left without changes.
--
--	2 -	incorrect reference values will be deleted, 
--		as well as all records, whose mandatory attributes have links to incorrect reference values;
--		optional attributes of records linked to incorrect reference values will be cleared.

-- Fill table with correct reference values
insert into @ReferenceTable (idfsBaseReference, strName_EN, strName_GG, strUsingType, strHACode, blnZoonotic, blnSyndromic, strICD10, strOIE, intOrder, strCustomizationPackageName) 
values
 (10019001, N'ILI', N'გრიპისმაგვარი დაავადება', N'Case-based', N'Human', 0, 1, N'', N'', N'0', N'Azerbaijan')
,(10019002, N'SARD', N'მძიმე მწვავე რესპირატორული დაავადება', N'Case-based', N'Human', 0, 1, N'', N'', N'0', N'Azerbaijan')


select	@N = count(*)	-- Number of rows in the reference table
from	@ReferenceTable

-- Fill table with accessory codes
insert into	@AccessoryCode (intHACode, strHACode)
values	(2, N'Human')
insert into	@AccessoryCode (intHACode, strHACode)
values	(32, N'Livestock')
insert into	@AccessoryCode (intHACode, strHACode)
values	(34, N'Human, Livestock')
insert into	@AccessoryCode (intHACode, strHACode)
values	(64, N'Avian')
insert into	@AccessoryCode (intHACode, strHACode)
values	(66, N'Human, Avian')
insert into	@AccessoryCode (intHACode, strHACode)
values	(96, N'Avian, Livestock')
insert into	@AccessoryCode (intHACode, strHACode)
values	(98, N'Human, Avian, Livestock')
insert into	@AccessoryCode (intHACode, strHACode)
values	(128, N'Vector')
insert into	@AccessoryCode (intHACode, strHACode)
values	(130, N'Human, Vector')
insert into	@AccessoryCode (intHACode, strHACode)
values	(160, N'Livestock, Vector')
insert into	@AccessoryCode (intHACode, strHACode)
values	(162, N'Human, Livestock, Vector')
insert into	@AccessoryCode (intHACode, strHACode)
values	(192, N'Avian, Vector')
insert into	@AccessoryCode (intHACode, strHACode)
values	(194, N'Human, Avian, Vector')
insert into	@AccessoryCode (intHACode, strHACode)
values	(224, N'Avian, Livestock, Vector')
insert into	@AccessoryCode (intHACode, strHACode)
values	(226, N'Human, Avian, Livestock, Vector')



print'Applying customization format for the reference values with type ' + @ReferenceType
print''

print'Number of correct references: ' + cast(@N as varchar(20))

-- Update existing values

-- Determine reference type ID
select		@idfsReferenceType = rt.idfsReferenceType
from		trtReferenceType rt
where		rt.intRowStatus = 0
			and rt.strReferenceTypeName = @ReferenceType collate Cyrillic_General_CI_AS

-- Update existing IDs
update		rt
set			-- Using Type
			rt.idfsUsingType = dut.idfsReference,
			-- Base Reference ID
			rt.idfsBaseReference = 
				case	
					when	-- idfsBaseReference is not specified in the Reference Table
							rt.idfsBaseReference is null
							-- reference value with specified ID existed in the database with another reference type
							or	exists	(
									select	*
									from	trtBaseReference br_with_incorrect_type
									where	br_with_incorrect_type.idfsBaseReference = IsNull(rt.idfsBaseReference, 0)
											and br_with_incorrect_type.idfsReferenceType <> IsNull(@idfsReferenceType, 0)
										)
							-- reference value with specified ID that has a link to another Customization Package
							or	exists	(
									select		*
									from		trtBaseReference br_another_CP
									inner join	trtBaseReferenceToCP brc_another_CP
										inner join	tstCustomizationPackage c_another_CP
										on			c_another_CP.idfCustomizationPackage = brc_another_CP.idfCustomizationPackage
									on			brc_another_CP.idfsBaseReference = br_another_CP.idfsBaseReference
									where		br_another_CP.idfsBaseReference = IsNull(rt.idfsBaseReference, 0)
												and br_another_CP.idfsReferenceType = IsNull(@idfsReferenceType, 0)
												and IsNull(c_another_CP.strCustomizationPackageName, N'') <> rt.strCustomizationPackageName collate Cyrillic_General_CI_AS
										)
						then	br.idfsBaseReference
					else	rt.idfsBaseReference
				end
			
from		@ReferenceTable rt

-- Using Type
left join	fnReference('en', 19000020) dut		-- Diagnosis Using Type
on			replace(replace(dut.[name], N'Standard Case', N'Case-based'), N'Aggregate Case', N'Aggregate') =
				rt.strUsingType collate Cyrillic_General_CI_AS

-- Existing Base Reference
left join	trtBaseReference br
	inner join	trtDiagnosis d
	on			d.idfsDiagnosis = br.idfsBaseReference
				and d.intRowStatus = 0
	-- Link to Customization Package
	inner join	trtBaseReferenceToCP brc
		inner join	tstCustomizationPackage c
		on			c.idfCustomizationPackage = brc.idfCustomizationPackage
	on			brc.idfsBaseReference = br.idfsBaseReference
on			IsNull(br.strDefault, N'') = rt.strName_EN collate Cyrillic_General_CI_AS
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and d.idfsUsingType = dut.idfsReference
			and IsNull(c.strCustomizationPackageName, N'') = rt.strCustomizationPackageName collate Cyrillic_General_CI_AS


-- Remove incorrect records and related reference information if necessary

-- Define table with references to delete
declare	@BRToDel table
(	idfsBaseReference	bigint not null primary key
)

-- Define table with links between references and Customization Packages to delete
declare	@BRCToDel table
(	idfsBaseReference	bigint not null,
	idfCustomizationPackage			bigint not null,
	primary key	(
		idfsBaseReference asc,
		idfCustomizationPackage asc
				)
)

-- Select references to delete
-- Select links between references and Customization Packages to delete
if @PerformDeletions = 1
begin

	insert into	@BRToDel (idfsBaseReference)
	select		br.idfsBaseReference
	from		@ConcordanceTable ct
	inner join	trtBaseReference br
	on			br.idfsBaseReference = ct.idfsBaseReference
				and br.idfsReferenceType = @idfsReferenceType
	where		(	ct.strReferenceResolution = 'Delete'
					or	ct.strReferenceResolution like N'%New English Name%'
					or	ct.strReferenceResolution like N'%Using Type%'
				)

	select	@N = count(*)
	from	@BRToDel
	print	'Number of references to mark as deleted according to concordance table: ' + cast(@N as varchar(20))
	print	''

end
else if @PerformDeletions = 2
begin
	declare	@CustomizationPackagesToCustomize	table
	(	idfCustomizationPackage	bigint not null primary key
	)

	insert into	@CustomizationPackagesToCustomize (idfCustomizationPackage)
	select distinct
				c.idfCustomizationPackage
	from		@ReferenceTable rt
	inner join	tstCustomizationPackage c
	on			IsNull(c.strCustomizationPackageName, N'') = rt.strCustomizationPackageName collate Cyrillic_General_CI_AS

	insert into	@BRToDel (idfsBaseReference)
	select		br.idfsBaseReference
	from		trtBaseReference br
	left join	@ReferenceTable rt
	on			rt.idfsBaseReference = br.idfsBaseReference
	where		br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
				and rt.idfsBaseReference is null
				and (	/*not exists	(
								select		*
								from		trtBaseReferenceToCP brcp_common
								where		brcp_common.idfsBaseReference = br.idfsBaseReference
									)
						or*/	(	exists	(
									select		*
									from		trtBaseReferenceToCP brcp_current
									inner join	@CustomizationPackagesToCustomize cpc_current
									on			cpc_current.idfCustomizationPackage = brcp_current.idfCustomizationPackage
									where		brcp_current.idfsBaseReference = br.idfsBaseReference
										)
								and not exists	(
											select		*
											from		trtBaseReferenceToCP brcp_another
											left join	@CustomizationPackagesToCustomize cpc_another
											on			cpc_another.idfCustomizationPackage = brcp_another.idfCustomizationPackage
											where		brcp_another.idfsBaseReference = br.idfsBaseReference
														and cpc_another.idfCustomizationPackage is null
												)
							)
					)

	insert into	@BRCToDel(idfsBaseReference, idfCustomizationPackage)
	select		br.idfsBaseReference, brc.idfCustomizationPackage
	from		trtBaseReference br
	inner join	trtBaseReferenceToCP brc
	on			brc.idfsBaseReference = br.idfsBaseReference
	inner join	@CustomizationPackagesToCustomize cpc
	on			cpc.idfCustomizationPackage = brc.idfCustomizationPackage
	left join	@ReferenceTable rt
		inner join	trtBaseReference br_rt
		on			br_rt.idfsBaseReference = rt.idfsBaseReference
					and br_rt.idfsReferenceType = IsNull(@idfsReferenceType, 0)
					and br_rt.intRowStatus = 0
		inner join	tstCustomizationPackage c
		on			IsNull(c.strCustomizationPackageName, N'') = rt.strCustomizationPackageName collate Cyrillic_General_CI_AS
	on			rt.idfsBaseReference = br.idfsBaseReference
				and c.idfCustomizationPackage = brc.idfCustomizationPackage
	where		br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
				and rt.idfID is null

	select	@N = count(*)
	from	@BRToDel
	print	'Number of references to delete: ' + cast(@N as varchar(20))

	select	@N = count(*)
	from	@BRCToDel
	print	'Number of links between references and Customization Packages to delete: ' + cast(@N as varchar(20))
	print	''
end

-- Perform deletions
if @PerformDeletions = 2
begin

	print'Delete incorrect references and incorrect links from correct references to Customization Packages'
	print''

	-- TODO: add actual scripts
	-- TODO: take all scripts from @PerformDeletions = 1 with delete statement
	-- TODO: add deletions from the tables trtBaseReferenceToCP and trtStringNameTranslation

	delete		oa
	from		tstObjectAccess oa
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = oa.idfsObjectID
	where		oa.idfsObjectType = 10060001	-- Diagnosis
	set	@N = @@rowcount
	print	'Delete permissions related to incorrect references (tstObjectAccess): ' + cast(@N as varchar(20))

	delete		dv
	from		ffDeterminantValue dv
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = dv.idfsBaseReference
	set	@N = @@rowcount
	print	'Delete determinants related to incorrect references (ffDeterminantValue): ' + cast(@N as varchar(20))

	delete		m_for_d_to_c
	from		trtMaterialForDisease m_for_d
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = m_for_d.idfsDiagnosis
	inner join	trtMaterialForDiseaseToCP m_for_d_to_c
	on			m_for_d_to_c.idfMaterialForDisease = m_for_d.idfMaterialForDisease
	set	@N = @@rowcount
	print'Delete links from diagnosis->sample type matrix rows to Customization Packages related to incorrect references (trtMaterialForDiseaseToCP): ' + cast(@N as varchar(20))

	delete		m_for_d
	from		trtMaterialForDisease m_for_d
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = m_for_d.idfsDiagnosis
	set	@N = @@rowcount
	print'Delete diagnosis->sample type matrix rows related to incorrect references (trtMaterialForDisease): ' + cast(@N as varchar(20))

	delete		t_for_d_to_c
	from		trtTestForDisease t_for_d
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = t_for_d.idfsDiagnosis
	inner join	trtTestForDiseaseToCP t_for_d_to_c
	on			t_for_d_to_c.idfTestForDisease = t_for_d.idfTestForDisease
	set	@N = @@rowcount
	print'Delete links from diagnosis->test name matrix rows to Customization Packages related to incorrect references (trtTestForDiseaseToCP): ' + cast(@N as varchar(20))

	delete		t_for_d
	from		trtTestForDisease t_for_d
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = t_for_d.idfsDiagnosis
	set	@N = @@rowcount
	print'Delete diagnosis->test name matrix rows related to incorrect references (trtTestForDisease): ' + cast(@N as varchar(20))

	delete		t_for_d_to_c
	from		trtPensideTestForDisease t_for_d
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = t_for_d.idfsDiagnosis
	inner join	dbo.trtPensideTestForDiseaseToCP t_for_d_to_c
	on			t_for_d_to_c.idfPensideTestForDisease = t_for_d.idfPensideTestForDisease
	set	@N = @@rowcount
	print'Delete links from diagnosis->penside test name matrix rows to Customization Packages related to incorrect references (trtPensideTestForDiseaseToCP): ' + cast(@N as varchar(20))

	delete		t_for_d
	from		trtPensideTestForDisease t_for_d
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = t_for_d.idfsDiagnosis
	set	@N = @@rowcount
	print'Delete diagnosis->penside test name matrix rows related to incorrect references (trtPensideTestForDisease): ' + cast(@N as varchar(20))

	delete		ag_to_d_to_c
	from		trtDiagnosisAgeGroupToDiagnosis ag_to_d
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = ag_to_d.idfsDiagnosis
	inner join	trtDiagnosisAgeGroupToDiagnosisToCP ag_to_d_to_c
	on			ag_to_d_to_c.idfDiagnosisAgeGroupToDiagnosis = ag_to_d.idfDiagnosisAgeGroupToDiagnosis
	set	@N = @@rowcount
	print'Delete links from diagnosis->age groups matrix rows to Customization Packages related to incorrect references (trtDiagnosisAgeGroupToDiagnosisToCP): ' + 
			cast(@N as varchar(20))

	delete		ag_to_d
	from		trtDiagnosisAgeGroupToDiagnosis ag_to_d
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = ag_to_d.idfsDiagnosis
	set	@N = @@rowcount
	print'Delete diagnosis->age groups matrix rows related to incorrect references (trtDiagnosisAgeGroupToDiagnosis): ' + cast(@N as varchar(20))

	delete		d_to_g_for_rt
	from		trtDiagnosisToGroupForReportType d_to_g_for_rt
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = d_to_g_for_rt.idfsDiagnosis
	set	@N = @@rowcount
	print'Delete links to report diagnoses groups from incorrect references (trtDiagnosisToGroupForReportType): ' + cast(@N as varchar(20))

	delete		d_to_dg_to_cp
	from		trtDiagnosisToDiagnosisGroupToCP d_to_dg_to_cp
	inner join trtDiagnosisToDiagnosisGroup d_to_dg
	on			d_to_dg.idfDiagnosisToDiagnosisGroup = d_to_dg_to_cp.idfDiagnosisToDiagnosisGroup
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = d_to_dg.idfsDiagnosis
	set	@N = @@rowcount
	print'Delete links to Customization Packages and diagnoses groups from incorrect references (trtDiagnosisToDiagnosisGroupToCP): ' + cast(@N as varchar(20))

	delete		d_to_gg
	from		trtDiagnosisToDiagnosisGroup d_to_gg
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = d_to_gg.idfsDiagnosis
	set	@N = @@rowcount
	print'Delete links to diagnoses groups from incorrect references (trtDiagnosisToDiagnosisGroup): ' + cast(@N as varchar(20))

	delete		p_to_d_for_cr
	from		trtFFObjectToDiagnosisForCustomReport p_to_d_for_cr
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = p_to_d_for_cr.idfsDiagnosis
	set	@N = @@rowcount
	print'Delete links from FF parameters utilized in custom reports to incorrect references (trtFFParameterToDiagnosisForCustomReport): ' + 
			cast(@N as varchar(20))

	delete		rr
	from		trtReportRows rr
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = rr.idfsDiagnosisOrReportDiagnosisGroup
	set	@N = @@rowcount
	print'Delete report rows related to incorrect references (trtReportRows): ' + cast(@N as varchar(20))

	delete		ada
	from		tlbAggrDiagnosticActionMTX ada
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = ada.idfsDiagnosis
	set	@N = @@rowcount
	print	'Delete vet diagnostic aggregate matrix rows related to incorrect references (tlbAggrDiagnosticActionMTX): ' + cast(@N as varchar(20))
	
	delete		ava
	from		tlbAggrVetCaseMTX ava
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = ava.idfsDiagnosis
	set	@N = @@rowcount
	print	'Delete vet case aggregate matrix rows related to incorrect references (tlbAggrVetCaseMTX): ' + cast(@N as varchar(20))
	
	delete		apa
	from		tlbAggrProphylacticActionMTX apa
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = apa.idfsDiagnosis
	set	@N = @@rowcount
	print	'Delete prophylactic aggregate matrix rows related to incorrect references (tlbAggrProphylacticActionMTX): ' + cast(@N as varchar(20))
		
	delete		aha
	from		tlbAggrHumanCaseMTX aha
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = aha.idfsDiagnosis
	set	@N = @@rowcount
	print	'Delete human case aggregate matrix rows related to incorrect references (tlbAggrHumanCaseMTX): ' + cast(@N as varchar(20))

	delete		d
	from		trtDiagnosis d
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = d.idfsDiagnosis
	set	@N = @@rowcount
	print'Delete diagnoses details of incorrect references as deleted (trtDiagnosis): ' + cast(@N as varchar(20))

	delete		snt_to_cp
	from		trtStringNameTranslationToCP snt_to_cp
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = snt_to_cp.idfsBaseReference
	set	@N = @@rowcount
	print	'Delete incorrect links to Customization Packages of translations of references (trtStringNameTranslationToCP): ' + cast(@N as varchar(20))
	print	'' 

	delete		snt
	from		trtStringNameTranslation snt
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = snt.idfsBaseReference
	set	@N = @@rowcount
	print	'Delete incorrect translations of references (trtStringNameTranslation): ' + cast(@N as varchar(20))
	print	'' 
	 
	delete		br_to_cp
	from		trtBaseReferenceToCP br_to_cp
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = br_to_cp.idfsBaseReference
	set	@N = @@rowcount
	print	'Delete incorrect links to Customization Packages of references (trtBaseReferenceToCP): ' + cast(@N as varchar(20))
	print	'' 
	 
	delete		br_to_cp
	from		trtBaseReferenceToCP br_to_cp
	inner join	@BRCToDel br_del
	on			br_del.idfsBaseReference = br_to_cp.idfsBaseReference
				and br_del.idfCustomizationPackage = br_to_cp.idfCustomizationPackage
	set	@N = @@rowcount
	print	'Delete incorrect links to Customization Packages of references (trtBaseReferenceToCP) (@BRCToDel): ' + cast(@N as varchar(20))	

	delete		br
	from		trtBaseReference br
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = br.idfsBaseReference
	set	@N = @@rowcount
	print	'Delete incorrect references as deleted (trtBaseReference): ' + cast(@N as varchar(20))
	print	''

	print	''
end

if @PerformDeletions = 1
begin

	print	'Mark incorrect references and incorrect links from correct references to Customization Packages as deleted according to concordance table'
	-- TODO: check if the records shall be deleted from the tables listed below.

	--delete		oa
	--from		tstObjectAccess oa
	--inner join	@BRToDel br_del
	--on			br_del.idfsBaseReference = oa.idfsObjectID
	--where		oa.idfsObjectType = 10060001	-- Diagnosis
	--set	@N = @@rowcount
	--print	'Delete permissions related to incorrect references (tstObjectAccess): ' + cast(@N as varchar(20))

	delete		dv
	from		ffDeterminantValue dv
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = dv.idfsBaseReference
	set	@N = @@rowcount
	print	'Delete determinants related to incorrect references (ffDeterminantValue): ' + cast(@N as varchar(20))

	delete		m_for_d_to_c
	from		trtMaterialForDisease m_for_d
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = m_for_d.idfsDiagnosis
	inner join	trtMaterialForDiseaseToCP m_for_d_to_c
	on			m_for_d_to_c.idfMaterialForDisease = m_for_d.idfMaterialForDisease
	set	@N = @@rowcount
	print'Delete links from diagnosis->sample type matrix rows to Customization Packages related to incorrect references (trtMaterialForDiseaseToCP): ' + cast(@N as varchar(20))

	delete		m_for_d
	from		trtMaterialForDisease m_for_d
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = m_for_d.idfsDiagnosis
	set	@N = @@rowcount
	print'Delete diagnosis->sample type matrix rows related to incorrect references (trtMaterialForDisease): ' + cast(@N as varchar(20))

	delete		t_for_d_to_c
	from		trtTestForDisease t_for_d
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = t_for_d.idfsDiagnosis
	inner join	trtTestForDiseaseToCP t_for_d_to_c
	on			t_for_d_to_c.idfTestForDisease = t_for_d.idfTestForDisease
	set	@N = @@rowcount
	print'Delete links from diagnosis->test name matrix rows to Customization Packages related to incorrect references (trtTestForDiseaseToCP): ' + cast(@N as varchar(20))

	delete		t_for_d
	from		trtTestForDisease t_for_d
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = t_for_d.idfsDiagnosis
	set	@N = @@rowcount
	print'Delete diagnosis->test name matrix rows related to incorrect references (trtTestForDisease): ' + cast(@N as varchar(20))

	delete		t_for_d_to_c
	from		trtPensideTestForDisease t_for_d
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = t_for_d.idfsDiagnosis
	inner join	dbo.trtPensideTestForDiseaseToCP t_for_d_to_c
	on			t_for_d_to_c.idfPensideTestForDisease = t_for_d.idfPensideTestForDisease
	set	@N = @@rowcount
	print'Delete links from diagnosis->penside test name matrix rows to Customization Packages related to incorrect references (trtPensideTestForDiseaseToCP): ' + cast(@N as varchar(20))

	delete		t_for_d
	from		trtPensideTestForDisease t_for_d
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = t_for_d.idfsDiagnosis
	set	@N = @@rowcount
	print'Delete diagnosis->penside test name matrix rows related to incorrect references (trtPensideTestForDisease): ' + cast(@N as varchar(20))

	--delete		ag_to_d_to_c
	--from		trtDiagnosisAgeGroupToDiagnosis ag_to_d
	--inner join	@BRToDel br_del
	--on			br_del.idfsBaseReference = ag_to_d.idfsDiagnosis
	--inner join	trtDiagnosisAgeGroupToDiagnosisToCP ag_to_d_to_c
	--on			ag_to_d_to_c.idfDiagnosisAgeGroupToDiagnosis = ag_to_d.idfDiagnosisAgeGroupToDiagnosis
	--set	@N = @@rowcount
	--print'Delete links from diagnosis->age groups matrix rows to Customization Packages related to incorrect references (trtDiagnosisAgeGroupToDiagnosisToCP): ' + 
	--		cast(@N as varchar(20))

	--delete		ag_to_d
	--from		trtDiagnosisAgeGroupToDiagnosis ag_to_d
	--inner join	@BRToDel br_del
	--on			br_del.idfsBaseReference = ag_to_d.idfsDiagnosis
	--set	@N = @@rowcount
	--print'Delete diagnosis->age groups matrix rows related to incorrect references (trtDiagnosisAgeGroupToDiagnosis): ' + cast(@N as varchar(20))

	--delete		d_to_g_for_rt
	--from		trtDiagnosisToGroupForReportType d_to_g_for_rt
	--inner join	@BRToDel br_del
	--on			br_del.idfsBaseReference = d_to_g_for_rt.idfsDiagnosis
	--set	@N = @@rowcount
	--print'Delete links to report diagnoses groups from incorrect references (trtDiagnosisToGroupForReportType): ' + cast(@N as varchar(20))

	--delete		d_to_dg_to_cp
	--from		trtDiagnosisToDiagnosisGroupToCP d_to_dg_to_cp
	--inner join trtDiagnosisToDiagnosisGroup d_to_dg
	--on			d_to_dg.idfDiagnosisToDiagnosisGroup = d_to_dg_to_cp.idfDiagnosisToDiagnosisGroup
	--inner join	@BRToDel br_del
	--on			br_del.idfsBaseReference = d_to_dg.idfsDiagnosis
	--set	@N = @@rowcount
	--print'Delete links to Customization Packages and diagnoses groups from incorrect references (trtDiagnosisToDiagnosisGroupToCP): ' + cast(@N as varchar(20))

	--delete		d_to_gg
	--from		trtDiagnosisToDiagnosisGroup d_to_gg
	--inner join	@BRToDel br_del
	--on			br_del.idfsBaseReference = d_to_gg.idfsDiagnosis
	--set	@N = @@rowcount
	--print'Delete links to diagnoses groups from incorrect references (trtDiagnosisToDiagnosisGroup): ' + cast(@N as varchar(20))

	--delete		p_to_d_for_cr
	--from		trtFFObjectToDiagnosisForCustomReport p_to_d_for_cr
	--inner join	@BRToDel br_del
	--on			br_del.idfsBaseReference = p_to_d_for_cr.idfsDiagnosis
	--set	@N = @@rowcount
	--print'Delete links from FF parameters utilized in custom reports to incorrect references (trtFFParameterToDiagnosisForCustomReport): ' + 
	--		cast(@N as varchar(20))

	--delete		rr
	--from		trtReportRows rr
	--inner join	@BRToDel br_del
	--on			br_del.idfsBaseReference = rr.idfsDiagnosisOrReportDiagnosisGroup
	--set	@N = @@rowcount
	--print'Delete report rows related to incorrect references (trtReportRows): ' + cast(@N as varchar(20))
	
	--delete		ada
	--from		tlbAggrDiagnosticActionMTX ada
	--inner join	@BRToDel br_del
	--on			br_del.idfsBaseReference = ada.idfsDiagnosis
	--set	@N = @@rowcount
	--print	'Delete vet diagnostic aggregate matrix rows related to incorrect references (tlbAggrDiagnosticActionMTX): ' + cast(@N as varchar(20))
	
	--delete		ava
	--from		tlbAggrVetCaseMTX ava
	--inner join	@BRToDel br_del
	--on			br_del.idfsBaseReference = ava.idfsDiagnosis
	--set	@N = @@rowcount
	--print	'Delete vet case aggregate matrix rows related to incorrect references (tlbAggrVetCaseMTX): ' + cast(@N as varchar(20))
	
	--delete		apa
	--from		tlbAggrProphylacticActionMTX apa
	--inner join	@BRToDel br_del
	--on			br_del.idfsBaseReference = apa.idfsDiagnosis
	--set	@N = @@rowcount
	--print	'Delete prophylactic aggregate matrix rows related to incorrect references (tlbAggrProphylacticActionMTX): ' + cast(@N as varchar(20))
		
	--delete		aha
	--from		tlbAggrHumanCaseMTX aha
	--inner join	@BRToDel br_del
	--on			br_del.idfsBaseReference = aha.idfsDiagnosis
	--set	@N = @@rowcount
	--print	'Delete human case aggregate matrix rows related to incorrect references (tlbAggrHumanCaseMTX): ' + cast(@N as varchar(20))
		

	update		d
	set			d.intRowStatus = 1
	from		trtDiagnosis d
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = d.idfsDiagnosis
	where		d.intRowStatus <> 1
	set	@N = @@rowcount
	print'Mark diagnoses details of incorrect references as deleted (trtDiagnosis): ' + cast(@N as varchar(20))

	update		br
	set			br.intRowStatus = 1
	from		trtBaseReference br
	inner join	@BRToDel br_del
	on			br_del.idfsBaseReference = br.idfsBaseReference
	where		br.intRowStatus <> 1
	set	@N = @@rowcount
	print'Mark incorrect references as deleted (trtBaseReference): ' + cast(@N as varchar(20))
	print''


	print''
end

-- Generate new IDs
delete from	tstNewID
where	idfTable = 75820000000	-- trtBaseReference

insert into	tstNewID
(	idfTable,
	idfKey1,
	idfKey2
)
select		75820000000,		-- trtBaseReference
			rt.idfID,
			null
from		@ReferenceTable rt
where		rt.idfsBaseReference is null

update		rt
set			rt.idfsBaseReference = nID.[NewID]
from		@ReferenceTable rt
inner join	tstNewID nID
on			nID.idfTable = 75820000000	-- trtBaseReference
			and nID.idfKey1 = rt.idfID
			and nID.idfKey2 is null
where		rt.idfsBaseReference is null

set	@N = @@rowcount
print'Number of new IDs generated for correct references: ' + cast(@N as varchar(20))

delete from	tstNewID
where	idfTable = 75820000000	-- trtBaseReference


set	@N = 0
select		@N = count(*)
from		@ReferenceTable rt
inner join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsBaseReference
print'Number of existing correct references: ' + cast(@N as varchar(20))

set	@N = 0
select		@N = count(*)
from		@ReferenceTable rt
left join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsBaseReference
where		br.idfsBaseReference is null
print'Number of non-existing correct references: ' + cast(@N as varchar(20))
print''

-- Update & insert correct records in the database

-- Base Reference
update		br
set			br.strDefault = rt.strName_EN,
			br.intHACode = ac.intHACode,
			br.intOrder = IsNull(rt.intOrder, 0),
			br.blnSystem = 0,
			br.intRowStatus = 0
from		trtBaseReference br
inner join	@ReferenceTable rt
on			rt.idfsBaseReference = br.idfsBaseReference
inner join	@AccessoryCode ac
on			ac.strHACode = rt.strHACode
where		(	IsNull(br.strDefault, N'') <> rt.strName_EN collate Cyrillic_General_CI_AS
				or	IsNull(br.intHACode, -1) <> ac.intHACode
				or	IsNull(br.intOrder, -1) <> IsNull(rt.intOrder, 0)
				or	br.intRowStatus <> 0
			)
set	@N = @@rowcount
print'Updated rows (trtBaseReference): ' + cast(@N as varchar(20))

insert into	trtBaseReference
(	idfsBaseReference,
	idfsReferenceType,
	strBaseReferenceCode,
	strDefault,
	intHACode,
	intOrder,
	blnSystem,
	intRowStatus
)
select		rt.idfsBaseReference,
			@idfsReferenceType,
			null,
			rt.strName_EN,
			ac.intHACode,
			IsNull(rt.intOrder, 0),
			0,
			0
from		@ReferenceTable rt
inner join	@AccessoryCode ac
on			ac.strHACode = rt.strHACode
left join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsBaseReference
where		br.idfsBaseReference is null
set	@N = @@rowcount
print'Inserted rows (trtBaseReference): ' + cast(@N as varchar(20))
print''

-- Translations
update		snt
set			snt.strTextString = rt.strName_EN,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
inner join	@ReferenceTable rt
on			rt.idfsBaseReference = br.idfsBaseReference
where		snt.idfsLanguage = dbo.fnGetLanguageCode('en')
			and	(	IsNull(snt.strTextString, N'') <> rt.strName_EN collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
set	@N = @@rowcount
print'Updated EN translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('en'),
			rt.strName_EN,
			0
from		@ReferenceTable rt
inner join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsBaseReference
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('en')
where		snt.idfsBaseReference is null
set	@N = @@rowcount
print'Inserted EN translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = rt.strName_AM,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
inner join	@ReferenceTable rt
on			rt.idfsBaseReference = br.idfsBaseReference
			and IsNull(rt.strName_AM, N'') <> N''
where		snt.idfsLanguage = dbo.fnGetLanguageCode('hy')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(rt.strName_AM, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
set	@N = @@rowcount
print'Updated AM translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('hy'),
			rt.strName_AM,
			0
from		@ReferenceTable rt
inner join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsBaseReference
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('hy')
where		IsNull(rt.strName_AM, N'') <> N''
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print'Inserted AM translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = rt.strName_AZ,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
inner join	@ReferenceTable rt
on			rt.idfsBaseReference = br.idfsBaseReference
			and IsNull(rt.strName_AZ, N'') <> N''
where		snt.idfsLanguage = dbo.fnGetLanguageCode('az-L')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(rt.strName_AZ, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
set	@N = @@rowcount
print'Updated AJ translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('az-L'),
			rt.strName_AZ,
			0
from		@ReferenceTable rt
inner join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsBaseReference
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('az-L')
where		IsNull(rt.strName_AZ, N'') <> N''
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print'Inserted AJ translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = rt.strName_GG,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
inner join	@ReferenceTable rt
on			rt.idfsBaseReference = br.idfsBaseReference
			and IsNull(rt.strName_GG, N'') <> N''
where		snt.idfsLanguage = dbo.fnGetLanguageCode('ka')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(rt.strName_GG, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
set	@N = @@rowcount
print'Updated GG translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('ka'),
			rt.strName_GG,
			0
from		@ReferenceTable rt
inner join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsBaseReference
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('ka')
where		IsNull(rt.strName_GG, N'') <> N''
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print'Inserted GG translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = rt.strName_KZ,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
inner join	@ReferenceTable rt
on			rt.idfsBaseReference = br.idfsBaseReference
			and IsNull(rt.strName_KZ, N'') <> N''
where		snt.idfsLanguage = dbo.fnGetLanguageCode('kk')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(rt.strName_KZ, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
set	@N = @@rowcount
print'Updated KZ translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('kk'),
			rt.strName_KZ,
			0
from		@ReferenceTable rt
inner join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsBaseReference
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('kk')
where		IsNull(rt.strName_KZ, N'') <> N''
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print'Inserted KZ translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = rt.strName_RU,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
inner join	@ReferenceTable rt
on			rt.idfsBaseReference = br.idfsBaseReference
			and IsNull(rt.strName_RU, N'') <> N''
where		snt.idfsLanguage = dbo.fnGetLanguageCode('ru')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(rt.strName_RU, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
set	@N = @@rowcount
print'Updated RU translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('ru'),
			rt.strName_RU,
			0
from		@ReferenceTable rt
inner join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsBaseReference
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('ru')
where		IsNull(rt.strName_RU, N'') <> N''
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print'Inserted RU translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = rt.strName_UA,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
inner join	@ReferenceTable rt
on			rt.idfsBaseReference = br.idfsBaseReference
			and IsNull(rt.strName_UA, N'') <> N''
where		snt.idfsLanguage = dbo.fnGetLanguageCode('uk')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(rt.strName_UA, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
set	@N = @@rowcount
print'Updated UA translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('uk'),
			rt.strName_UA,
			0
from		@ReferenceTable rt
inner join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsBaseReference
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('uk')
where		IsNull(rt.strName_UA, N'') <> N''
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print'Inserted UA translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = rt.strName_IQ,
		snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
		and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
		and br.intRowStatus = 0
inner join	@ReferenceTable rt
on			rt.idfsBaseReference = br.idfsBaseReference
		and IsNull(rt.strName_IQ, N'') <> N''
where		snt.idfsLanguage = dbo.fnGetLanguageCode('ar')
		and	(	IsNull(snt.strTextString, N'') <> IsNull(rt.strName_IQ, N'') collate Cyrillic_General_CI_AS
				or	snt.intRowStatus <> 0
			)
set	@N = @@rowcount
print	'Updated IQ translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
idfsLanguage,
strTextString,
intRowStatus
)
select		br.idfsBaseReference,
		dbo.fnGetLanguageCode('ar'),
		rt.strName_IQ,
		0
from		@ReferenceTable rt
inner join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsBaseReference
		and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
		and br.intRowStatus = 0
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
		and snt.idfsLanguage = dbo.fnGetLanguageCode('ar')
where		IsNull(rt.strName_IQ, N'') <> N''
		and snt.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted IQ translations (trtStringNameTranslation): ' + cast(@N as varchar(20))
print	''

update		snt
set			snt.strTextString = rt.strName_TH,
		snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
		and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
		and br.intRowStatus = 0
inner join	@ReferenceTable rt
on			rt.idfsBaseReference = br.idfsBaseReference
		and IsNull(rt.strName_TH, N'') <> N''
where		snt.idfsLanguage = dbo.fnGetLanguageCode('th')
		and	(	IsNull(snt.strTextString, N'') <> IsNull(rt.strName_TH, N'') collate Cyrillic_General_CI_AS
				or	snt.intRowStatus <> 0
			)
set	@N = @@rowcount
print	'Updated TH translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
idfsLanguage,
strTextString,
intRowStatus
)
select		br.idfsBaseReference,
		dbo.fnGetLanguageCode('th'),
		rt.strName_TH,
		0
from		@ReferenceTable rt
inner join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsBaseReference
		and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
		and br.intRowStatus = 0
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
		and snt.idfsLanguage = dbo.fnGetLanguageCode('th')
where		IsNull(rt.strName_TH, N'') <> N''
		and snt.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted TH translations (trtStringNameTranslation): ' + cast(@N as varchar(20))
print	''

-- Links to Customization Packages
update		brc
set			brc.intHACode = ac.intHACode,
			brc.intOrder = IsNull(rt.intOrder, 0)
from		trtBaseReferenceToCP brc
inner join	trtBaseReference br
on			br.idfsBaseReference = brc.idfsBaseReference
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
inner join	@ReferenceTable rt
on			rt.idfsBaseReference = br.idfsBaseReference
inner join	@AccessoryCode ac
on			ac.strHACode = rt.strHACode
-- Link to Customization Package
inner join	tstCustomizationPackage c
on			c.idfCustomizationPackage = brc.idfCustomizationPackage
 			and IsNull(c.strCustomizationPackageName, N'') = rt.strCustomizationPackageName collate Cyrillic_General_CI_AS
where		(	IsNull(brc.intHACode, -1) <> ac.intHACode
				or	IsNull(brc.intOrder, -1) <> IsNull(rt.intOrder, 0)
			)
set	@N = @@rowcount
print'Updated links to Customization Package (trtBaseReferenceToCP): ' + cast(@N as varchar(20))

insert into	trtBaseReferenceToCP
(	idfsBaseReference,
	idfCustomizationPackage,
	intHACode,
	intOrder
)
select		br.idfsBaseReference,
			c.idfCustomizationPackage,
			ac.intHACode,
			IsNull(rt.intOrder, 0)
from		@ReferenceTable rt
inner join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsBaseReference
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
inner join	@AccessoryCode ac
on			ac.strHACode = rt.strHACode
-- Link to Customization Package
inner join	tstCustomizationPackage c
on			IsNull(c.strCustomizationPackageName, N'') = rt.strCustomizationPackageName collate Cyrillic_General_CI_AS
left join	trtBaseReferenceToCP brc
on			brc.idfsBaseReference = rt.idfsBaseReference
 			and brc.idfCustomizationPackage = c.idfCustomizationPackage			
where		brc.idfsBaseReference is null
set	@N = @@rowcount
print'Inserted links to Customization Package (trtBaseReferenceToCP): ' + cast(@N as varchar(20))
print''

-- trtDiagnosis - child table of trtBaseReference
update		c
set			c.idfsUsingType = rt.idfsUsingType,
			c.strIDC10 = rt.strICD10,
			c.strOIECode = rt.strOIE,
			c.blnZoonotic = rt.blnZoonotic,
			c.intRowStatus = 0
from		trtDiagnosis c
inner join	trtBaseReference br
on			br.idfsBaseReference = c.idfsDiagnosis
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
inner join	@ReferenceTable rt
on			rt.idfsBaseReference = br.idfsBaseReference
where		(	c.idfsUsingType <> IsNull(rt.idfsUsingType, -1)
				or	IsNull(c.strIDC10, N'') <> IsNull(rt.strICD10, N'') collate Cyrillic_General_CI_AS
				or	IsNull(c.strOIECode, N'') <> IsNull(rt.strOIE, N'') collate Cyrillic_General_CI_AS
				or	IsNull(c.blnZoonotic, 0) <> IsNull(rt.blnZoonotic, 0)
				or	c.intRowStatus <> 0
			)
set	@N = @@rowcount
print'Updated child table records (trtDiagnosis): ' + cast(@N as varchar(20))

insert into	trtDiagnosis
(	idfsDiagnosis,
	idfsUsingType,
	strIDC10,
	strOIECode,
	blnZoonotic,
	blnSyndrome,
	intRowStatus
)
select		br.idfsBaseReference,
			rt.idfsUsingType,
			rt.strICD10,
			rt.strOIE,
			rt.blnZoonotic,
			rt.blnSyndromic,
			0
from		@ReferenceTable rt
inner join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsBaseReference
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
left join	trtDiagnosis c
on			c.idfsDiagnosis = br.idfsBaseReference
where		c.idfsDiagnosis is null
set	@N = @@rowcount
print'Inserted child table records (trtDiagnosis): ' + cast(@N as varchar(20))
print''

/*
-- Generate script to fill reference table
print'Script for filling @ReferenceTable with correct reference values'
print''

select		N'
insert into @ReferenceTable
(	idfsBaseReference, strName_EN, strUsingType, idfsUsingType, strICD10, strOIE,
	strName_AM, strName_AZ, strName_GG, strName_KZ, strName_RU, strName_UA, strName_IQ, 
	strName_TH, strHACode, intOrder, blnZoonotic, strCustomizationPackageName) 
values (' + cast(br.idfsBaseReference as varchar(20)) + N', ' + 
N'N''' + replace(IsNull(snt_EN.strTextString, br.strDefault), N'''', N'''''') + N''', ' +
replace(replace(dut.[name], N'Standard Case', N'''Case-based'''), N'Aggregate Case', N'''Aggregate''') + N', ' +
cast(d.idfsUsingType as nvarchar(20)) + N', 
' + 
IsNull(N'N''' + replace(d.strIDC10, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(d.strOIECode, N'''', N'''''') + N'''', N'null')+ N', ' +
IsNull(N'N''' + replace(snt_AM.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_AZ.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_GG.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_KZ.strTextString, N'''', N'''''') + N'''', N'null')+ N', ' +
IsNull(N'N''' + replace(snt_RU.strTextString, N'''', N'''''') + N'''', N'null')+ N', ' +
IsNull(N'N''' + replace(snt_UA.strTextString, N'''', N'''''') + N'''', N'null')+ N', ' +
IsNull(N'N''' + replace(snt_IQ.strTextString, N'''', N'''''') + N'''', N'null')+ N', ' +			
IsNull(N'N''' + replace(snt_TH.strTextString, N'''', N'''''') + N'''', N'null')+ N', ' +			
IsNull(N'N''' + replace(ac.strHACode, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(cast(IsNull(brc.intOrder, br.intOrder) as varchar(20)), N'null') + N', ' + 
IsNull(cast(IsNull(d.blnZoonotic, 0) as varchar(20)), N'null') + N', ' + 
IsNull(N'N''' + replace(c.strCustomizationPackageName, N'''', N'''''') + N'''', N'null') + N')
'

from
-- Base References
			trtBaseReference br
inner join	trtDiagnosis d
on			d.idfsDiagnosis = br.idfsBaseReference
			and d.intRowStatus = 0
inner join	fnReference('en', 19000020) dut		-- Diagnosis Using Type
on			dut.idfsReference = d.idfsUsingType
inner join	@ReferenceTable rt
on			rt.idfsBaseReference = br.idfsBaseReference

-- Translations
left join	trtStringNameTranslation snt_EN
on			snt_EN.idfsBaseReference = br.idfsBaseReference
			and snt_EN.idfsLanguage = dbo.fnGetLanguageCode('en')
			and snt_EN.intRowStatus = 0
left join	trtStringNameTranslation snt_AM
on			snt_AM.idfsBaseReference = br.idfsBaseReference
			and snt_AM.idfsLanguage = dbo.fnGetLanguageCode('hy')
			and snt_AM.intRowStatus = 0
left join	trtStringNameTranslation snt_AZ
on			snt_AZ.idfsBaseReference = br.idfsBaseReference
			and snt_AZ.idfsLanguage = dbo.fnGetLanguageCode('az-L')
			and snt_AZ.intRowStatus = 0
left join	trtStringNameTranslation snt_GG
on			snt_GG.idfsBaseReference = br.idfsBaseReference
			and snt_GG.idfsLanguage = dbo.fnGetLanguageCode('ka')
			and snt_GG.intRowStatus = 0
left join	trtStringNameTranslation snt_KZ
on			snt_KZ.idfsBaseReference = br.idfsBaseReference
			and snt_KZ.idfsLanguage = dbo.fnGetLanguageCode('kk')
			and snt_KZ.intRowStatus = 0
left join	trtStringNameTranslation snt_RU
on			snt_RU.idfsBaseReference = br.idfsBaseReference
			and snt_RU.idfsLanguage = dbo.fnGetLanguageCode('ru')
			and snt_RU.intRowStatus = 0
left join	trtStringNameTranslation snt_UA
on			snt_UA.idfsBaseReference = br.idfsBaseReference
			and snt_UA.idfsLanguage = dbo.fnGetLanguageCode('uk')
			and snt_UA.intRowStatus = 0
left join	trtStringNameTranslation snt_IQ
on			snt_IQ.idfsBaseReference = br.idfsBaseReference
			and snt_IQ.idfsLanguage = dbo.fnGetLanguageCode('ar')
			and snt_IQ.intRowStatus = 0
left join	trtStringNameTranslation snt_TH
on			snt_TH.idfsBaseReference = br.idfsBaseReference
 			and snt_TH.idfsLanguage = dbo.fnGetLanguageCode('th')
 			and snt_TH.intRowStatus = 0
			
-- Links to Customization Package
left join	trtBaseReferenceToCP brc
	inner join	tstCustomizationPackage c
	on			c.idfCustomizationPackage = brc.idfCustomizationPackage
on			brc.idfsBaseReference = br.idfsBaseReference
			and IsNull(c.strCustomizationPackageName, N'') = rt.strCustomizationPackageName collate Cyrillic_General_CI_AS

-- Accessory Code Names
left join	@AccessoryCode ac
on			ac.intHACode = IsNull(brc.intHACode, br.intHACode)

where		br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
*/

IF @@ERROR <> 0
	ROLLBACK TRAN
ELSE
	COMMIT TRAN

set XACT_ABORT off
set nocount off


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
