-- This script applies customization format to the reference table with type Flexible Form.
-- The script updates existing data by means of concordance table.
-- It should be executed on the database, for which customization format should be applied.
-- NB! It is assumed the check of source data (@TemplateTable) has been already verified before applying the format.


use [Giraffe_Archive]
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

--Declare template table
declare	@TemplateTable	table
(	idfID							bigint not null identity (1, 1) primary key,
	FormType_EN						nvarchar(500) collate database_default not null,
	FormTemplate_EN					nvarchar(500) collate database_default not null,
	FormTemplate_AM					nvarchar(500) collate database_default null,
	FormTemplate_AZ					nvarchar(500) collate database_default null,
	FormTemplate_GG					nvarchar(500) collate database_default null,
	FormTemplate_KZ					nvarchar(500) collate database_default null,
	FormTemplate_RU					nvarchar(500) collate database_default null,
	FormTemplate_UA					nvarchar(500) collate database_default null,
	FormTemplate_IQ					nvarchar(500) collate database_default null,
	FormTemplate_TH					nvarchar(500) collate database_default null,
	strUNI							nvarchar(100) collate database_default null,
	blnUNI							bit null,
	strCustomizationPackage			nvarchar(500) collate database_default null,
	idfsFormType					bigint not null,
	idfsFormTemplate				bigint null,
	idfCustomizationPackage			bigint null,
	strNote							nvarchar(200) collate database_default null
)

declare	@DeterminantTable	table
(	idfID							bigint not null identity (1, 2) primary key,
	idfDeterminantValue				bigint null,
	FormType_EN						nvarchar(500) collate database_default null,
	FormTemplate_AM					nvarchar(500) collate database_default null,
	FormTemplate_AZ					nvarchar(500) collate database_default null,
	FormTemplate_GG					nvarchar(500) collate database_default null,
	FormTemplate_KZ					nvarchar(500) collate database_default null,
	FormTemplate_RU					nvarchar(500) collate database_default null,
	FormTemplate_UA					nvarchar(500) collate database_default null,
	FormTemplate_IQ					nvarchar(500) collate database_default null,
	FormTemplate_TH					nvarchar(500) collate database_default null,
	FormTemplate_EN					nvarchar(500) collate database_default not null,
	strUNI							nvarchar(100) collate database_default null,
	strDiagnosis_EN					nvarchar(500) collate database_default null,
	strTestName_EN					nvarchar(500) collate database_default null,
	strVectorType_EN				nvarchar(500) collate database_default null,
	strCustomizationPackage			nvarchar(500) collate database_default null,
	idfsFormType					bigint null,
	idfsFormTemplate				bigint null,
	blnUNI							bit null,
	idfsDiagnosis					bigint null,
	idfsTestName					bigint null,
	idfsVectorType					bigint null,
	idfCustomizationPackage			bigint null,
	strNote							nvarchar(200) collate database_default null
)

declare	@TemplateConcordanceTable	table
(	old_idfsFormTemplate	bigint not null primary key,
	FormType_EN				nvarchar(500) collate database_default null,
	Old_FormTemplate_EN		nvarchar(500) collate database_default null,
	New_FormTemplate_EN		nvarchar(500) collate database_default null
)

declare	@BRDeleteTable	table
(	idfsBaseReference bigint not null primary key
)

declare	@CPToApply	table
(	idfCustomizationPackage	bigint not null primary key
)


declare	@CustomizationPackage	nvarchar(20)
declare	@idfCustomizationPackage		bigint

declare	@PerformDeletions	int

declare	@N	int

-- Set paremeters
set	@ReferenceType = N'Flexible Form Template'

-- Country for which specific changes should be applied
set	@CustomizationPackage = N'Azerbaijan' -- ALL

select	@idfCustomizationPackage = cp.idfCustomizationPackage
from	tstCustomizationPackage cp
where	cp.strCustomizationPackageName = @CustomizationPackage collate Cyrillic_General_CI_AS


set	@PerformDeletions = 0
--	0 - incorrect reference values will be kept without changes
--	1 -	incorrect reference values will be marked as deleted
--	2 -	incorrect reference values will be deleted, 
--		as well as all records, whose key attributes have links to incorrect reference values,
--		records, whose attributes with links to incorrect reference values aren't main for the record, will be cleared.


-- Fill concordance table


-- Fill determinant table
insert into @DeterminantTable (idfDeterminantValue, idfsFormTemplate, FormType_EN, FormTemplate_EN, FormTemplate_GG, strUNI, strNote, strDiagnosis_EN, strTestName_EN, strVectorType_EN, strCustomizationPackage) 
values 
 (1, 10033501, N'Human Clinical Signs', N'HCS ILI', N'HCS გმდ', N'No', N'', N'ILI', N'', N'', N'Azerbaijan')
,(2, 10033502, N'Human Clinical Signs', N'HCS SARD', N'HCS SARD', N'No', N'', N'SARD', N'', N'', N'Azerbaijan')

,(null, 10033503, N'Outbreak Human CQ', N'Outbreak Human CQ UNI', N'Outbreak Human CQ UNI', N' Default Template For Outbreak Use', N'Yes', N'', N'', N'', N'Azerbaijan')
,(null, 10033504, N'Outbreak Livestock CQ', N'Outbreak Livestock CQ UNI', N'Outbreak Livestock CQ UNI', N' Default Template For Outbreak Use', N'Yes', N'', N'', N'', N'Azerbaijan')
,(null, 10033505, N'Outbreak Avian CQ', N'Outbreak Avian CQ UNI', N'Outbreak Avian CQ UNI', N' Default Template For Outbreak Use', N'Yes', N'', N'', N'', N'Azerbaijan')
,(null, 10033506, N'Outbreak Human Case CM', N'Outbreak Human Case CM UNI', N'Outbreak Human Case CM UNI', N' Default Template For Outbreak Use', N'Yes', N'', N'', N'', N'Azerbaijan')
,(null, 10033507, N'Outbreak Livestock Case CM', N'Outbreak Livestock Case CM UNI', N'Outbreak Livestock Case CM UNI', N' Default Template For Outbreak Use', N'Yes', N'', N'', N'', N'Azerbaijan')
,(null, 10033508, N'Outbreak Avian Case CM', N'Outbreak Avian Case CM UNI', N'Outbreak Avian Case CM UNI', N' Default Template For Outbreak Use', N'Yes', N'', N'', N'', N'Azerbaijan')
,(null, 10033509, N'Outbreak Human Contact CT', N'Outbreak Human Contact CT UNI', N'Outbreak Human Contact CT UNI', N' Default Template For Outbreak Use', N'Yes', N'', N'', N'', N'Azerbaijan')
,(null, 10033510, N'Outbreak Farm (Livestock) Contact CT', N'Outbreak Farm (Livestock) Contact CT UNI', N'Outbreak Farm (Livestock) Contact CT UNI', N' Default Template For Outbreak Use', N'Yes', N'', N'', N'', N'Azerbaijan')
,(null, 10033511, N'Outbreak Farm (Avian) CT', N'Outbreak Farm (Avian) CT UNI', N'Outbreak Farm (Avian) CT UNI', N' Default Template For Outbreak Use', N'Yes', N'', N'', N'', N'Azerbaijan')



print	'Applying customization format for the reference values with type ' + @ReferenceType
print	''



-- Remove records related to not specified customization package
delete		dt
from		@DeterminantTable dt
where		IsNull(dt.strCustomizationPackage, N'ALL') <> @CustomizationPackage collate Cyrillic_General_CI_AS
			and IsNull(dt.strCustomizationPackage, N'ALL') <> N'ALL' collate Cyrillic_General_CI_AS
set	@N = @@rowcount
print	'Remove combinations of FF templates and their determinants from the format related to not specified cuatomization package: ' + cast(@N as varchar(20))
print	''


-- Update existing values

-- Determine reference type ID
select		@idfsReferenceType = rt.idfsReferenceType
from		trtReferenceType rt
inner join	fnReference('en', 19000076) r_rt	-- Reference Type Name
on			r_rt.idfsReference = rt.idfsReferenceType
			and r_rt.[name] = @ReferenceType
where		rt.intRowStatus = 0


-- Update IDs in determinant table
update		dt
set			dt.idfsFormType = r_ft.idfsReference,
			dt.idfsFormTemplate =
				case	
					when	-- idfsBaseReference is not specified in the Reference Table
							dt.idfsFormTemplate is null
							-- reference value with specified ID existed in the database with another reference type
							or	exists	(
									select	*
									from	trtBaseReference br_with_incorrect_type
									where	br_with_incorrect_type.idfsBaseReference = IsNull(dt.idfsFormTemplate, 0)
											and br_with_incorrect_type.idfsReferenceType <> IsNull(@idfsReferenceType, 0)
										)
							-- reference value with specified ID that has a link to another country
							or	exists	(
									select		*
									from		trtBaseReference br_another_country
									inner join	trtBaseReferenceToCP brc_another_country
										inner join	tstCustomizationPackage c_another_country
										on			c_another_country.idfCustomizationPackage = 
														brc_another_country.idfCustomizationPackage
									on			brc_another_country.idfsBaseReference = br_another_country.idfsBaseReference
									where		br_another_country.idfsBaseReference = IsNull(dt.idfsFormTemplate, 0)
												and br_another_country.idfsReferenceType = IsNull(@idfsReferenceType, 0)
												and IsNull(c_another_country.strCustomizationPackageName, N'') <> 
														dt.strCustomizationPackage collate Cyrillic_General_CI_AS
										)
						then	t.idfsFormTemplate
					else	dt.idfsFormTemplate
				end,
			dt.idfsDiagnosis = d.idfsDiagnosis,
			dt.idfsTestName = br_tn.idfsBaseReference,
			dt.idfsVectorType = br_vt.idfsBaseReference,
			dt.idfCustomizationPackage = c.idfCustomizationPackage,
			dt.blnUNI = 
				case	IsNull(dt.strUNI, N'No')
					when	N'Yes'
						then	1
					else	0
				end
from		@DeterminantTable dt
inner join	fnReference('en', 19000034) r_ft	-- Flexible Form Type
on			r_ft.[name] = IsNull(dt.FormType_EN, N'') collate Cyrillic_General_CI_AS
inner join	tstCustomizationPackage c
on			IsNull(c.strCustomizationPackageName, N'') = 
				IsNull(dt.strCustomizationPackage, N'Not specified') collate Cyrillic_General_CI_AS
left join	ffFormTemplate t
	inner join	trtBaseReference br_t
	on			br_t.idfsBaseReference = t.idfsFormTemplate
				and br_t.idfsReferenceType = 19000033	-- Flexible Form Template
	left join	trtBaseReferenceToCP brc_t
	on			brc_t.idfsBaseReference = t.idfsFormTemplate
on			t.idfsFormType = r_ft.idfsReference
			and IsNull(br_t.strDefault, N'') = IsNull(dt.FormTemplate_EN, N'Not specified') collate Cyrillic_General_CI_AS
			and (brc_t.idfCustomizationPackage is null or brc_t.idfCustomizationPackage = c.idfCustomizationPackage)
left join	trtDiagnosis d
	inner join	trtBaseReference br_d
	on			br_d.idfsBaseReference = d.idfsDiagnosis
				and br_d.idfsReferenceType = 19000019	-- Diagnosis
	left join	trtBaseReferenceToCP brc_d
	on			brc_d.idfsBaseReference = d.idfsDiagnosis
on			d.idfsUsingType = 10020001	-- Case-based
			and IsNull(br_d.strDefault, N'') = IsNull(dt.strDiagnosis_EN, N'Not specified') collate Cyrillic_General_CI_AS
			and (brc_d.idfCustomizationPackage is null or brc_d.idfCustomizationPackage = c.idfCustomizationPackage)
left join	trtBaseReference br_vt
	left join	trtBaseReferenceToCP brc_vt
	on			brc_vt.idfsBaseReference = br_vt.idfsBaseReference
on			IsNull(br_vt.strDefault, N'') = IsNull(dt.strVectorType_EN, N'Not specified') collate Cyrillic_General_CI_AS
			and br_vt.idfsReferenceType = 19000140	-- Vector type
			and (brc_vt.idfCustomizationPackage is null or brc_vt.idfCustomizationPackage = c.idfCustomizationPackage)
left join	trtBaseReference br_tn
	left join	trtBaseReferenceToCP brc_tn
	on			brc_tn.idfsBaseReference = br_tn.idfsBaseReference
on			IsNull(br_tn.strDefault, N'') = IsNull(dt.strTestName_EN, N'Not specified') collate Cyrillic_General_CI_AS
			and br_tn.idfsReferenceType = 19000097	-- Test Name
			and (brc_tn.idfCustomizationPackage is null or brc_tn.idfCustomizationPackage = c.idfCustomizationPackage)

-- Fill template table from determinant table
insert into	@TemplateTable
(	FormType_EN,
	FormTemplate_EN,
	FormTemplate_AM,
	FormTemplate_AZ,
	FormTemplate_GG,
	FormTemplate_KZ,
	FormTemplate_RU,
	FormTemplate_UA,
	FormTemplate_IQ,
	FormTemplate_TH,
	strUNI,
	blnUNI,
	strCustomizationPackage,
	idfsFormType,
	idfsFormTemplate,
	idfCustomizationPackage
)
select distinct
		FormType_EN,
		FormTemplate_EN,
		FormTemplate_AM,
		FormTemplate_AZ,
		FormTemplate_GG,
		FormTemplate_KZ,
		FormTemplate_RU,
		FormTemplate_UA,
		FormTemplate_IQ,
		FormTemplate_TH,
		strUNI,
		blnUNI,
		strCustomizationPackage,
		idfsFormType,
		idfsFormTemplate,
		idfCustomizationPackage
from	@DeterminantTable


 
-- Remove incorrect records and related reference information if necessary
-- Mark records as deleted
if @PerformDeletions = 1
begin

	print	'Mark incorrect references and incorrect links from correct references to countries as deleted according to concordance table'
	print	''
	-- TODO: check if the records shall be deleted from the tables listed below.

	update		dv
	set			dv.intRowStatus = 1
	from		ffDeterminantValue dv
	inner join	@TemplateConcordanceTable ct
	on			ct.old_idfsFormTemplate = dv.idfsFormTemplate
	left join	@TemplateTable tt
	on			tt.FormType_EN = ct.FormType_EN
				and tt.FormTemplate_EN = ct.New_FormTemplate_EN
				and (	@idfCustomizationPackage is null or tt.idfCustomizationPackage is null
						or	(	@idfCustomizationPackage is not null and tt.idfCustomizationPackage is not null
								and tt.idfCustomizationPackage = @idfCustomizationPackage
							)
					)
	where		dv.intRowStatus <> 1
				and tt.idfID is null
	set	@N = @@rowcount
	print	'Determinants of the obsolete templates (ffDeterminantValue) - mark as deleted: ' + cast(@N as varchar(20))

	-- Labels' text to delete
	insert into	@BRDeleteTable (idfsBaseReference)
	select		det.idfsBaseReference
	from		ffDecorElementText det
	inner join	ffDecorElement de
	on			de.idfDecorElement = det.idfDecorElement
	inner join	@TemplateConcordanceTable ct
	on			ct.old_idfsFormTemplate = de.idfsFormTemplate
	left join	@TemplateTable tt
	on			tt.FormType_EN = ct.FormType_EN
				and tt.FormTemplate_EN = ct.New_FormTemplate_EN
				and (	@idfCustomizationPackage is null or tt.idfCustomizationPackage is null
						or	(	@idfCustomizationPackage is not null and tt.idfCustomizationPackage is not null
								and tt.idfCustomizationPackage = @idfCustomizationPackage
							)
					)
	where		tt.idfID is null


	update		del
	set			del.intRowStatus = 1
	from		ffDecorElementLine del
	inner join	ffDecorElement de
	on			de.idfDecorElement = del.idfDecorElement
	inner join	@TemplateConcordanceTable ct
	on			ct.old_idfsFormTemplate = de.idfsFormTemplate
	left join	@TemplateTable tt
	on			tt.FormType_EN = ct.FormType_EN
				and tt.FormTemplate_EN = ct.New_FormTemplate_EN
				and (	@idfCustomizationPackage is null or tt.idfCustomizationPackage is null
						or	(	@idfCustomizationPackage is not null and tt.idfCustomizationPackage is not null
								and tt.idfCustomizationPackage = @idfCustomizationPackage
							)
					)
	where		del.intRowStatus <> 1
				and tt.idfID is null
	set	@N = @@rowcount
	print	'Lines on the obsolete templates (ffDecorElementLine) - mark as deleted: ' + cast(@N as varchar(20))

	update		det
	set			det.intRowStatus = 1
	from		ffDecorElementText det
	inner join	ffDecorElement de
	on			de.idfDecorElement = det.idfDecorElement
	inner join	@TemplateConcordanceTable ct
	on			ct.old_idfsFormTemplate = de.idfsFormTemplate
	left join	@TemplateTable tt
	on			tt.FormType_EN = ct.FormType_EN
				and tt.FormTemplate_EN = ct.New_FormTemplate_EN
				and (	@idfCustomizationPackage is null or tt.idfCustomizationPackage is null
						or	(	@idfCustomizationPackage is not null and tt.idfCustomizationPackage is not null
								and tt.idfCustomizationPackage = @idfCustomizationPackage
							)
					)
	where		det.intRowStatus <> 1
				and tt.idfID is null
	set	@N = @@rowcount
	print	'Labels on the obsolete templates (ffDecorElementText) - mark as deleted: ' + cast(@N as varchar(20))

	update		de
	set			de.intRowStatus = 1
	from		ffDecorElement de
	inner join	@TemplateConcordanceTable ct
	on			ct.old_idfsFormTemplate = de.idfsFormTemplate
	left join	@TemplateTable tt
	on			tt.FormType_EN = ct.FormType_EN
				and tt.FormTemplate_EN = ct.New_FormTemplate_EN
				and (	@idfCustomizationPackage is null or tt.idfCustomizationPackage is null
						or	(	@idfCustomizationPackage is not null and tt.idfCustomizationPackage is not null
								and tt.idfCustomizationPackage = @idfCustomizationPackage
							)
					)
	where		de.intRowStatus <> 1
				and tt.idfID is null
	set	@N = @@rowcount
	print	'Labels and lines on the obsolete templates (ffDecorElement) - mark as deleted: ' + cast(@N as varchar(20))

	update		pdo
	set			pdo.intRowStatus = 1
	from		ffParameterDesignOption pdo
	inner join	@TemplateConcordanceTable ct
	on			ct.old_idfsFormTemplate = pdo.idfsFormTemplate
	left join	@TemplateTable tt
	on			tt.FormType_EN = ct.FormType_EN
				and tt.FormTemplate_EN = ct.New_FormTemplate_EN
				and (	@idfCustomizationPackage is null or tt.idfCustomizationPackage is null
						or	(	@idfCustomizationPackage is not null and tt.idfCustomizationPackage is not null
								and tt.idfCustomizationPackage = @idfCustomizationPackage
							)
					)
	where		pdo.intRowStatus <> 1
				and tt.idfID is null
	set	@N = @@rowcount
	print	'Design options of parameters on the obsolete templates (ffParameterDesignOption) - mark as deleted: ' + cast(@N as varchar(20))

	update		pfa
	set			pfa.intRowStatus = 1
	from		ffParameterForAction pfa
	inner join	@TemplateConcordanceTable ct
	on			ct.old_idfsFormTemplate = pfa.idfsFormTemplate
	left join	@TemplateTable tt
	on			tt.FormType_EN = ct.FormType_EN
				and tt.FormTemplate_EN = ct.New_FormTemplate_EN
				and (	@idfCustomizationPackage is null or tt.idfCustomizationPackage is null
						or	(	@idfCustomizationPackage is not null and tt.idfCustomizationPackage is not null
								and tt.idfCustomizationPackage = @idfCustomizationPackage
							)
					)
	where		pfa.intRowStatus <> 1
				and tt.idfID is null
	set	@N = @@rowcount
	print	'Actions with parameters on the obsolete templates (ffParameterForAction) - mark as deleted: ' + cast(@N as varchar(20))

	update		pfa
	set			pfa.intRowStatus = 1
	from		ffParameterForAction pfa
	inner join	ffRule r
	on			r.idfsRule = pfa.idfsRule
	inner join	@TemplateConcordanceTable ct
	on			ct.old_idfsFormTemplate = r.idfsFormTemplate
	left join	@TemplateTable tt
	on			tt.FormType_EN = ct.FormType_EN
				and tt.FormTemplate_EN = ct.New_FormTemplate_EN
				and (	@idfCustomizationPackage is null or tt.idfCustomizationPackage is null
						or	(	@idfCustomizationPackage is not null and tt.idfCustomizationPackage is not null
								and tt.idfCustomizationPackage = @idfCustomizationPackage
							)
					)
	where		pfa.intRowStatus <> 1
				and tt.idfID is null
	set	@N = @@rowcount
	print	'Actions with parameters for the rules of the obsolete templates (ffParameterForAction) - mark as deleted: ' + cast(@N as varchar(20))

	update		pff
	set			pff.intRowStatus = 1
	from		ffParameterForFunction pff
	inner join	@TemplateConcordanceTable ct
	on			ct.old_idfsFormTemplate = pff.idfsFormTemplate
	left join	@TemplateTable tt
	on			tt.FormType_EN = ct.FormType_EN
				and tt.FormTemplate_EN = ct.New_FormTemplate_EN
				and (	@idfCustomizationPackage is null or tt.idfCustomizationPackage is null
						or	(	@idfCustomizationPackage is not null and tt.idfCustomizationPackage is not null
								and tt.idfCustomizationPackage = @idfCustomizationPackage
							)
					)
	where		pff.intRowStatus <> 1
				and tt.idfID is null
	set	@N = @@rowcount
	print	'Variables of rules'' functions as parameters on the obsolete templates (ffParameterForFunction) - mark as deleted: ' + cast(@N as varchar(20))

	update		pff
	set			pff.intRowStatus = 1
	from		ffParameterForFunction pff
	inner join	ffRule r
	on			r.idfsRule = pff.idfsRule
	inner join	@TemplateConcordanceTable ct
	on			ct.old_idfsFormTemplate = r.idfsFormTemplate
	left join	@TemplateTable tt
	on			tt.FormType_EN = ct.FormType_EN
				and tt.FormTemplate_EN = ct.New_FormTemplate_EN
				and (	@idfCustomizationPackage is null or tt.idfCustomizationPackage is null
						or	(	@idfCustomizationPackage is not null and tt.idfCustomizationPackage is not null
								and tt.idfCustomizationPackage = @idfCustomizationPackage
							)
					)
	where		pff.intRowStatus <> 1
				and tt.idfID is null
	set	@N = @@rowcount
	print	'Variables of the functions of the rules of the obsolete templates (ffParameterForFunction) - mark as deleted: ' + cast(@N as varchar(20))

	update		rc
	set			rc.intRowStatus = 1
	from		ffRuleConstant rc
	inner join	ffRule r
	on			r.idfsRule = rc.idfsRule
	inner join	@TemplateConcordanceTable ct
	on			ct.old_idfsFormTemplate = r.idfsFormTemplate
	left join	@TemplateTable tt
	on			tt.FormType_EN = ct.FormType_EN
				and tt.FormTemplate_EN = ct.New_FormTemplate_EN
				and (	@idfCustomizationPackage is null or tt.idfCustomizationPackage is null
						or	(	@idfCustomizationPackage is not null and tt.idfCustomizationPackage is not null
								and tt.idfCustomizationPackage = @idfCustomizationPackage
							)
					)
	where		rc.intRowStatus <> 1
				and tt.idfID is null
	set	@N = @@rowcount
	print	'Constants utilized in the rules of the obsolete templates (ffRuleConstant) - mark as deleted: ' + cast(@N as varchar(20))

	update		sfa
	set			sfa.intRowStatus = 1
	from		ffSectionForAction sfa
	inner join	@TemplateConcordanceTable ct
	on			ct.old_idfsFormTemplate = sfa.idfsFormTemplate
	left join	@TemplateTable tt
	on			tt.FormType_EN = ct.FormType_EN
				and tt.FormTemplate_EN = ct.New_FormTemplate_EN
				and (	@idfCustomizationPackage is null or tt.idfCustomizationPackage is null
						or	(	@idfCustomizationPackage is not null and tt.idfCustomizationPackage is not null
								and tt.idfCustomizationPackage = @idfCustomizationPackage
							)
					)
	where		sfa.intRowStatus <> 1
				and tt.idfID is null
	set	@N = @@rowcount
	print	'Actions with sections on the obsolete templates (ffSectionForAction) - mark as deleted: ' + cast(@N as varchar(20))

	update		sfa
	set			sfa.intRowStatus = 1
	from		ffSectionForAction sfa
	inner join	ffRule r
	on			r.idfsRule = sfa.idfsRule
	inner join	@TemplateConcordanceTable ct
	on			ct.old_idfsFormTemplate = r.idfsFormTemplate
	left join	@TemplateTable tt
	on			tt.FormType_EN = ct.FormType_EN
				and tt.FormTemplate_EN = ct.New_FormTemplate_EN
				and (	@idfCustomizationPackage is null or tt.idfCustomizationPackage is null
						or	(	@idfCustomizationPackage is not null and tt.idfCustomizationPackage is not null
								and tt.idfCustomizationPackage = @idfCustomizationPackage
							)
					)
	where		sfa.intRowStatus <> 1
				and tt.idfID is null
	set	@N = @@rowcount
	print	'Actions with sections for the rules of the obsolete templates (ffSectionForAction) - mark as deleted: ' + cast(@N as varchar(20))

	-- Rules' messages to delete
	insert into	@BRDeleteTable (idfsBaseReference)
	select		r.idfsRuleMessage
	from		ffRule r
	inner join	@TemplateConcordanceTable ct
	on			ct.old_idfsFormTemplate = r.idfsFormTemplate
	left join	@TemplateTable tt
	on			tt.FormType_EN = ct.FormType_EN
				and tt.FormTemplate_EN = ct.New_FormTemplate_EN
				and (	@idfCustomizationPackage is null or tt.idfCustomizationPackage is null
						or	(	@idfCustomizationPackage is not null and tt.idfCustomizationPackage is not null
								and tt.idfCustomizationPackage = @idfCustomizationPackage
							)
					)
	where		tt.idfID is null

	-- Rules to delete
	insert into	@BRDeleteTable (idfsBaseReference)
	select		r.idfsRule
	from		ffRule r
	inner join	@TemplateConcordanceTable ct
	on			ct.old_idfsFormTemplate = r.idfsFormTemplate
	left join	@TemplateTable tt
	on			tt.FormType_EN = ct.FormType_EN
				and tt.FormTemplate_EN = ct.New_FormTemplate_EN
				and (	@idfCustomizationPackage is null or tt.idfCustomizationPackage is null
						or	(	@idfCustomizationPackage is not null and tt.idfCustomizationPackage is not null
								and tt.idfCustomizationPackage = @idfCustomizationPackage
							)
					)
	where		tt.idfID is null

	update		r
	set			r.intRowStatus = 1
	from		ffRule r
	inner join	@TemplateConcordanceTable ct
	on			ct.old_idfsFormTemplate = r.idfsFormTemplate
	left join	@TemplateTable tt
	on			tt.FormType_EN = ct.FormType_EN
				and tt.FormTemplate_EN = ct.New_FormTemplate_EN
				and (	@idfCustomizationPackage is null or tt.idfCustomizationPackage is null
						or	(	@idfCustomizationPackage is not null and tt.idfCustomizationPackage is not null
								and tt.idfCustomizationPackage = @idfCustomizationPackage
							)
					)
	where		r.intRowStatus <> 1
				and tt.idfID is null
	set	@N = @@rowcount
	print	'Rules of the obsolete templates (ffRule) - mark as deleted: ' + cast(@N as varchar(20))

	update		pft
	set			pft.intRowStatus = 1
	from		ffParameterForTemplate pft
	inner join	@TemplateConcordanceTable ct
	on			ct.old_idfsFormTemplate = pft.idfsFormTemplate
	left join	@TemplateTable tt
	on			tt.FormType_EN = ct.FormType_EN
				and tt.FormTemplate_EN = ct.New_FormTemplate_EN
				and (	@idfCustomizationPackage is null or tt.idfCustomizationPackage is null
						or	(	@idfCustomizationPackage is not null and tt.idfCustomizationPackage is not null
								and tt.idfCustomizationPackage = @idfCustomizationPackage
							)
					)
	where		pft.intRowStatus <> 1
				and tt.idfID is null
	set	@N = @@rowcount
	print	'Presence of parameters on the obsolete templates (ffParameterForTemplate) - mark as deleted: ' + cast(@N as varchar(20))

	update		sdo
	set			sdo.intRowStatus = 1
	from		ffSectionDesignOption sdo
	inner join	@TemplateConcordanceTable ct
	on			ct.old_idfsFormTemplate = sdo.idfsFormTemplate
	left join	@TemplateTable tt
	on			tt.FormType_EN = ct.FormType_EN
				and tt.FormTemplate_EN = ct.New_FormTemplate_EN
				and (	@idfCustomizationPackage is null or tt.idfCustomizationPackage is null
						or	(	@idfCustomizationPackage is not null and tt.idfCustomizationPackage is not null
								and tt.idfCustomizationPackage = @idfCustomizationPackage
							)
					)
	where		sdo.intRowStatus <> 1
				and tt.idfID is null
	set	@N = @@rowcount
	print	'Design options of sections on the obsolete templates (ffSectionDesignOption) - mark as deleted: ' + cast(@N as varchar(20))

	update		sft
	set			sft.intRowStatus = 1
	from		ffSectionForTemplate sft
	inner join	@TemplateConcordanceTable ct
	on			ct.old_idfsFormTemplate = sft.idfsFormTemplate
	left join	@TemplateTable tt
	on			tt.FormType_EN = ct.FormType_EN
				and tt.FormTemplate_EN = ct.New_FormTemplate_EN
				and (	@idfCustomizationPackage is null or tt.idfCustomizationPackage is null
						or	(	@idfCustomizationPackage is not null and tt.idfCustomizationPackage is not null
								and tt.idfCustomizationPackage = @idfCustomizationPackage
							)
					)
	where		sft.intRowStatus <> 1
				and tt.idfID is null
	set	@N = @@rowcount
	print	'Presence of sections on the obsolete templates (ffSectionForTemplate) - mark as deleted: ' + cast(@N as varchar(20))

	-- Templates to delete
	insert into	@BRDeleteTable (idfsBaseReference)
	select		c.idfsFormTemplate
	from		ffFormTemplate c
	inner join	@TemplateConcordanceTable ct
	on			ct.old_idfsFormTemplate = c.idfsFormTemplate
	left join	@TemplateTable tt
	on			tt.FormType_EN = ct.FormType_EN
				and tt.FormTemplate_EN = ct.New_FormTemplate_EN
				and (	@idfCustomizationPackage is null or tt.idfCustomizationPackage is null
						or	(	@idfCustomizationPackage is not null and tt.idfCustomizationPackage is not null
								and tt.idfCustomizationPackage = @idfCustomizationPackage
							)
					)
	where		tt.idfID is null

	update		c
	set			c.intRowStatus = 1
	from		ffFormTemplate c
	inner join	@TemplateConcordanceTable ct
	on			ct.old_idfsFormTemplate = c.idfsFormTemplate
	left join	@TemplateTable tt
	on			tt.FormType_EN = ct.FormType_EN
				and tt.FormTemplate_EN = ct.New_FormTemplate_EN
				and (	@idfCustomizationPackage is null or tt.idfCustomizationPackage is null
						or	(	@idfCustomizationPackage is not null and tt.idfCustomizationPackage is not null
								and tt.idfCustomizationPackage = @idfCustomizationPackage
							)
					)
	where		c.intRowStatus <> 1
				and tt.idfID is null
	set	@N = @@rowcount
	print	'Obsolete templates (ffFormTemplate) - mark as deleted: ' + cast(@N as varchar(20))

	-- Delete related permissions
	delete		oa
	from		tstObjectAccess oa
	inner join	@BRDeleteTable br_del
	on			br_del.idfsBaseReference = oa.idfsObjectID
	set	@N = @@rowcount
	print	'Permissions to the references marked as deleted (tstObjectAccess) - delete: ' + cast(@N as varchar(20))

	-- Mark references as deleted
	update		br
	set			br.intRowStatus = 1
	from		trtBaseReference br
	inner join	@BRDeleteTable br_del
	on			br_del.idfsBaseReference = br.idfsBaseReference
	where		br.intRowStatus <> 1
	set	@N = @@rowcount
	print	'References (trtBaseReference) - marked as deleted: ' + cast(@N as varchar(20))
	print	''

end

-- Perform deletions
if @PerformDeletions = 2
begin

	print	'Delete incorrect references and incorrect links from correct references to countries'
	print	''

	insert into	@CPToApply(idfCustomizationPackage)
	select distinct
				idfCustomizationPackage
	from		@TemplateTable
	where		idfCustomizationPackage is not null


	insert into	@BRDeleteTable	(idfsBaseReference)
	select		ft.idfsFormTemplate
	from		ffFormTemplate ft
	left join	@TemplateTable tt
	on			tt.idfsFormTemplate = ft.idfsFormTemplate
	where		tt.idfID is null
				and	exists	(
						select		*
						from		trtBaseReferenceToCP brcp
						inner join	@CPToApply cpa
						on			cpa.idfCustomizationPackage = brcp.idfCustomizationPackage
						where		brcp.idfCustomizationPackage = ft.idfsFormTemplate
							)
	

	delete		dv
	from		ffDeterminantValue dv
	inner join	@BRDeleteTable brdt
	on			brdt.idfsBaseReference = dv.idfsFormTemplate
	set	@N = @@rowcount
	print	'Delete determinants of the templates to delete (ffDeterminantValue): ' + cast(@N as varchar(20))

	-- Labels' text to delete
	insert into	@BRDeleteTable (idfsBaseReference)
	select		det.idfsBaseReference
	from		ffDecorElementText det
	inner join	ffDecorElement de
	on			de.idfDecorElement = det.idfDecorElement
	inner join	@BRDeleteTable brdt
	on			brdt.idfsBaseReference = de.idfsFormTemplate


	delete		del
	from		ffDecorElementLine del
	inner join	ffDecorElement de
	on			de.idfDecorElement = del.idfDecorElement
	inner join	@BRDeleteTable brdt
	on			brdt.idfsBaseReference = de.idfsFormTemplate
	set	@N = @@rowcount
	print	'Delete Lines on the templates to delete (ffDecorElementLine): ' + cast(@N as varchar(20))

	delete		det
	from		ffDecorElementText det
	inner join	ffDecorElement de
	on			de.idfDecorElement = det.idfDecorElement
	inner join	@TemplateConcordanceTable ct
	on			ct.old_idfsFormTemplate = de.idfsFormTemplate
	inner join	@BRDeleteTable brdt
	on			brdt.idfsBaseReference = de.idfsFormTemplate
	set	@N = @@rowcount
	print	'Delete labels on the templates to delete (ffDecorElementText): ' + cast(@N as varchar(20))

	delete		de
	from		ffDecorElement de
	inner join	@BRDeleteTable brdt
	on			brdt.idfsBaseReference = de.idfsFormTemplate
	set	@N = @@rowcount
	print	'Delete labels and lines on the templates to delete (ffDecorElement): ' + cast(@N as varchar(20))

	delete		pdo
	from		ffParameterDesignOption pdo
	inner join	@BRDeleteTable brdt
	on			brdt.idfsBaseReference = pdo.idfsFormTemplate
	set	@N = @@rowcount
	print	'Delete design options of parameters on the templates to delete (ffParameterDesignOption): ' + cast(@N as varchar(20))

	delete		pfa
	from		ffParameterForAction pfa
	inner join	@BRDeleteTable brdt
	on			brdt.idfsBaseReference = pfa.idfsFormTemplate
	set	@N = @@rowcount
	print	'Delete actions with parameters on the templates to delete (ffParameterForAction): ' + cast(@N as varchar(20))

	delete		pfa
	from		ffParameterForAction pfa
	inner join	ffRule r
	on			r.idfsRule = pfa.idfsRule
	inner join	@BRDeleteTable brdt
	on			brdt.idfsBaseReference = r.idfsFormTemplate
	set	@N = @@rowcount
	print	'Delete actions with parameters for the rules of the templates to delete (ffParameterForAction): ' + cast(@N as varchar(20))

	delete		pff
	from		ffParameterForFunction pff
	inner join	@BRDeleteTable brdt
	on			brdt.idfsBaseReference = pff.idfsFormTemplate
	set	@N = @@rowcount
	print	'Delete variables of rules'' functions as parameters on the templates to delete (ffParameterForFunction): ' + cast(@N as varchar(20))

	delete		pff
	from		ffParameterForFunction pff
	inner join	ffRule r
	on			r.idfsRule = pff.idfsRule
	inner join	@BRDeleteTable brdt
	on			brdt.idfsBaseReference = r.idfsFormTemplate
	set	@N = @@rowcount
	print	'Delete variables of the functions of the rules of the templates to delete (ffParameterForFunction): ' + cast(@N as varchar(20))

	delete		rc
	from		ffRuleConstant rc
	inner join	ffRule r
	on			r.idfsRule = rc.idfsRule
	inner join	@BRDeleteTable brdt
	on			brdt.idfsBaseReference = r.idfsFormTemplate
	set	@N = @@rowcount
	print	'Delete constants utilized in the rules of the templates to delete (ffRuleConstant): ' + cast(@N as varchar(20))

	delete		sfa
	from		ffSectionForAction sfa
	inner join	@BRDeleteTable brdt
	on			brdt.idfsBaseReference = sfa.idfsFormTemplate
	set	@N = @@rowcount
	print	'Delete actions with sections on the templates to delete (ffSectionForAction): ' + cast(@N as varchar(20))

	delete		sfa
	from		ffSectionForAction sfa
	inner join	ffRule r
	on			r.idfsRule = sfa.idfsRule
	inner join	@BRDeleteTable brdt
	on			brdt.idfsBaseReference = r.idfsFormTemplate
	set	@N = @@rowcount
	print	'Delete actions with sections for the rules of the templates to delete (ffSectionForAction): ' + cast(@N as varchar(20))

	-- Rules' messages to delete
	insert into	@BRDeleteTable (idfsBaseReference)
	select		r.idfsRuleMessage
	from		ffRule r
	inner join	@BRDeleteTable brdt
	on			brdt.idfsBaseReference = r.idfsFormTemplate

	-- Rules to delete
	insert into	@BRDeleteTable (idfsBaseReference)
	select		r.idfsRule
	from		ffRule r
	inner join	@BRDeleteTable brdt
	on			brdt.idfsBaseReference = r.idfsFormTemplate

	delete		r
	from		ffRule r
	inner join	@BRDeleteTable brdt
	on			brdt.idfsBaseReference = r.idfsFormTemplate
	set	@N = @@rowcount
	print	'Delete rules of the templates to delete (ffRule): ' + cast(@N as varchar(20))

	delete		pft
	from		ffParameterForTemplate pft
	inner join	@BRDeleteTable brdt
	on			brdt.idfsBaseReference = pft.idfsFormTemplate
	set	@N = @@rowcount
	print	'Delete presence of parameters on the templates to delete (ffParameterForTemplate): ' + cast(@N as varchar(20))

	delete		sdo
	from		ffSectionDesignOption sdo
	inner join	@BRDeleteTable brdt
	on			brdt.idfsBaseReference = sdo.idfsFormTemplate
	set	@N = @@rowcount
	print	'Delete design options of sections on the templates to delete (ffSectionDesignOption): ' + cast(@N as varchar(20))

	delete		sft
	from		ffSectionForTemplate sft
	inner join	@BRDeleteTable brdt
	on			brdt.idfsBaseReference = sft.idfsFormTemplate
	set	@N = @@rowcount
	print	'Delete resence of sections on the templates to delete (ffSectionForTemplate): ' + cast(@N as varchar(20))

	delete		c
	from		ffFormTemplate c
	inner join	@BRDeleteTable brdt
	on			brdt.idfsBaseReference = c.idfsFormTemplate
	set	@N = @@rowcount
	print	'Delete templates (ffFormTemplate): ' + cast(@N as varchar(20))

	
	delete		oa
	from		tstObjectAccess oa
	inner join	@BRDeleteTable br_del
	on			br_del.idfsBaseReference = oa.idfsObjectID
	set	@N = @@rowcount
	print	'Delete permissions to references to delete (tstObjectAccess): ' + cast(@N as varchar(20))


	delete		snt
	from		trtStringNameTranslation snt
	inner join	@BRDeleteTable br_del
	on			br_del.idfsBaseReference = snt.idfsBaseReference
	set	@N = @@rowcount
	print	'Delete translations of references to delete (trtStringNameTranslation): ' + cast(@N as varchar(20))
	print	'' 
	 
	delete		br_to_cp
	from		trtBaseReferenceToCP br_to_cp
	inner join	@BRDeleteTable br_del
	on			br_del.idfsBaseReference = br_to_cp.idfsBaseReference
	set	@N = @@rowcount
	print	'Delete links to Customization Packages of references to delete (trtBaseReferenceToCP): ' + cast(@N as varchar(20))
	print	'' 
	
	delete		br
	from		trtBaseReference br
	inner join	@BRDeleteTable br_del
	on			br_del.idfsBaseReference = br.idfsBaseReference
	set	@N = @@rowcount
	print	'Delete incorrect references (trtBaseReference): ' + cast(@N as varchar(20))
	print	''

end

print	''
print	'Update/insert templates'
print	''
print	''

-- Generate new IDs
print	'Generate IDs for the new templates'
print	''

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
from		@TemplateTable rt
where		(	@idfCustomizationPackage is null or rt.idfCustomizationPackage is null
				or	(	@idfCustomizationPackage is not null and rt.idfCustomizationPackage is not null
						and rt.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	rt.idfsFormTemplate is null

update		rt
set			rt.idfsFormTemplate = nID.[NewID]
from		@TemplateTable rt
inner join	tstNewID nID
on			nID.idfTable = 75820000000	-- trtBaseReference
			and nID.idfKey1 = rt.idfID
			and nID.idfKey2 is null
where		(	@idfCustomizationPackage is null or rt.idfCustomizationPackage is null
				or	(	@idfCustomizationPackage is not null and rt.idfCustomizationPackage is not null
						and rt.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	rt.idfsFormTemplate is null

set	@N = @@rowcount
print	'Number of new IDs generated for correct references: ' + cast(@N as varchar(20))

delete from	tstNewID
where	idfTable = 75820000000	-- trtBaseReference

set	@N = 0
select		@N = count(*)
from		@TemplateTable rt
inner join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsFormTemplate
print	'Number of existing correct references: ' + cast(@N as varchar(20))

set	@N = 0
select		@N = count(*)
from		@TemplateTable rt
left join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsFormTemplate
where		br.idfsBaseReference is null
print	'Number of non-existing correct references: ' + cast(@N as varchar(20))
print	''

-- Update & insert correct records in the database

-- Base Reference
update		br
set			br.strDefault = rt.FormTemplate_EN,
			br.intHACode = 226,
			br.intOrder = 0,
			br.blnSystem = 0,
			br.intRowStatus = 0
from		trtBaseReference br
inner join	@TemplateTable rt
on			rt.idfsFormTemplate = br.idfsBaseReference
			and	(	@idfCustomizationPackage is null or rt.idfCustomizationPackage is null
					or	(	@idfCustomizationPackage is not null and rt.idfCustomizationPackage is not null
							and rt.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
where		(	IsNull(br.strDefault, N'') <> rt.FormTemplate_EN collate Cyrillic_General_CI_AS
				or	IsNull(br.intHACode, -1) <> 226
				or	IsNull(br.intOrder, -100000) <> 0
				or	br.intRowStatus <> 0
			)
set	@N = @@rowcount
print	'Updated rows (trtBaseReference): ' + cast(@N as varchar(20))

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
select		rt.idfsFormTemplate,
			@idfsReferenceType,
			null,
			rt.FormTemplate_EN,
			226,
			0,
			0,
			0
from		@TemplateTable rt
left join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsFormTemplate
where		(	@idfCustomizationPackage is null or rt.idfCustomizationPackage is null
				or	(	@idfCustomizationPackage is not null and rt.idfCustomizationPackage is not null
						and rt.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	br.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted rows (trtBaseReference): ' + cast(@N as varchar(20))
print	''

-- Translations
update		snt
set			snt.strTextString = rt.FormTemplate_EN,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
inner join	@TemplateTable rt
on			rt.idfsFormTemplate = br.idfsBaseReference
			and	(	@idfCustomizationPackage is null or rt.idfCustomizationPackage is null
					or	(	@idfCustomizationPackage is not null and rt.idfCustomizationPackage is not null
							and rt.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
where		snt.idfsLanguage = dbo.fnGetLanguageCode('en')
			and	(	IsNull(snt.strTextString, N'') <> rt.FormTemplate_EN collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
set	@N = @@rowcount
print	'Updated EN translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('en'),
			rt.FormTemplate_EN,
			0
from		@TemplateTable rt
inner join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsFormTemplate
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('en')
where		(	@idfCustomizationPackage is null or rt.idfCustomizationPackage is null
				or	(	@idfCustomizationPackage is not null and rt.idfCustomizationPackage is not null
						and rt.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	snt.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted EN translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = rt.FormTemplate_AM,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
inner join	@TemplateTable rt
on			rt.idfsFormTemplate = br.idfsBaseReference
			and IsNull(rt.FormTemplate_AM, N'') <> N''
			and	(	@idfCustomizationPackage is null or rt.idfCustomizationPackage is null
					or	(	@idfCustomizationPackage is not null and rt.idfCustomizationPackage is not null
							and rt.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
where		snt.idfsLanguage = dbo.fnGetLanguageCode('hy')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(rt.FormTemplate_AM, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
set	@N = @@rowcount
print	'Updated AM translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('hy'),
			rt.FormTemplate_AM,
			0
from		@TemplateTable rt
inner join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsFormTemplate
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('hy')
where		(	@idfCustomizationPackage is null or rt.idfCustomizationPackage is null
				or	(	@idfCustomizationPackage is not null and rt.idfCustomizationPackage is not null
						and rt.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	IsNull(rt.FormTemplate_AM, N'') <> N''
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted AM translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = rt.FormTemplate_AZ,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
inner join	@TemplateTable rt
on			rt.idfsFormTemplate = br.idfsBaseReference
			and IsNull(rt.FormTemplate_AZ, N'') <> N''
			and	(	@idfCustomizationPackage is null or rt.idfCustomizationPackage is null
					or	(	@idfCustomizationPackage is not null and rt.idfCustomizationPackage is not null
							and rt.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
where		snt.idfsLanguage = dbo.fnGetLanguageCode('az-L')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(rt.FormTemplate_AZ, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
set	@N = @@rowcount
print	'Updated AJ translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('az-L'),
			rt.FormTemplate_AZ,
			0
from		@TemplateTable rt
inner join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsFormTemplate
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('az-L')
where		(	@idfCustomizationPackage is null or rt.idfCustomizationPackage is null
				or	(	@idfCustomizationPackage is not null and rt.idfCustomizationPackage is not null
						and rt.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	IsNull(rt.FormTemplate_AZ, N'') <> N''
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted AJ translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = rt.FormTemplate_GG,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
inner join	@TemplateTable rt
on			rt.idfsFormTemplate = br.idfsBaseReference
			and IsNull(rt.FormTemplate_GG, N'') <> N''
			and	(	@idfCustomizationPackage is null or rt.idfCustomizationPackage is null
					or	(	@idfCustomizationPackage is not null and rt.idfCustomizationPackage is not null
							and rt.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
where		snt.idfsLanguage = dbo.fnGetLanguageCode('ka')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(rt.FormTemplate_GG, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
set	@N = @@rowcount
print	'Updated GG translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('ka'),
			rt.FormTemplate_GG,
			0
from		@TemplateTable rt
inner join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsFormTemplate
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('ka')
where		(	@idfCustomizationPackage is null or rt.idfCustomizationPackage is null
				or	(	@idfCustomizationPackage is not null and rt.idfCustomizationPackage is not null
						and rt.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	IsNull(rt.FormTemplate_GG, N'') <> N''
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted GG translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = rt.FormTemplate_KZ,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
inner join	@TemplateTable rt
on			rt.idfsFormTemplate = br.idfsBaseReference
			and IsNull(rt.FormTemplate_KZ, N'') <> N''
			and	(	@idfCustomizationPackage is null or rt.idfCustomizationPackage is null
					or	(	@idfCustomizationPackage is not null and rt.idfCustomizationPackage is not null
							and rt.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
where		snt.idfsLanguage = dbo.fnGetLanguageCode('kk')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(rt.FormTemplate_KZ, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
set	@N = @@rowcount
print	'Updated KZ translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('kk'),
			rt.FormTemplate_KZ,
			0
from		@TemplateTable rt
inner join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsFormTemplate
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('kk')
where		(	@idfCustomizationPackage is null or rt.idfCustomizationPackage is null
				or	(	@idfCustomizationPackage is not null and rt.idfCustomizationPackage is not null
						and rt.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	IsNull(rt.FormTemplate_KZ, N'') <> N''
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted KZ translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = rt.FormTemplate_RU,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
inner join	@TemplateTable rt
on			rt.idfsFormTemplate = br.idfsBaseReference
			and IsNull(rt.FormTemplate_RU, N'') <> N''
			and	(	@idfCustomizationPackage is null or rt.idfCustomizationPackage is null
					or	(	@idfCustomizationPackage is not null and rt.idfCustomizationPackage is not null
							and rt.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
where		snt.idfsLanguage = dbo.fnGetLanguageCode('ru')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(rt.FormTemplate_RU, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
set	@N = @@rowcount
print	'Updated RU translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('ru'),
			rt.FormTemplate_RU,
			0
from		@TemplateTable rt
inner join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsFormTemplate
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('ru')
where		(	@idfCustomizationPackage is null or rt.idfCustomizationPackage is null
				or	(	@idfCustomizationPackage is not null and rt.idfCustomizationPackage is not null
						and rt.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	IsNull(rt.FormTemplate_RU, N'') <> N''
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted RU translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = rt.FormTemplate_UA,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
inner join	@TemplateTable rt
on			rt.idfsFormTemplate = br.idfsBaseReference
			and IsNull(rt.FormTemplate_UA, N'') <> N''
			and	(	@idfCustomizationPackage is null or rt.idfCustomizationPackage is null
					or	(	@idfCustomizationPackage is not null and rt.idfCustomizationPackage is not null
							and rt.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
where		snt.idfsLanguage = dbo.fnGetLanguageCode('uk')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(rt.FormTemplate_UA, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
set	@N = @@rowcount
print	'Updated UA translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('uk'),
			rt.FormTemplate_UA,
			0
from		@TemplateTable rt
inner join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsFormTemplate
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('uk')
where		(	@idfCustomizationPackage is null or rt.idfCustomizationPackage is null
				or	(	@idfCustomizationPackage is not null and rt.idfCustomizationPackage is not null
						and rt.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	IsNull(rt.FormTemplate_UA, N'') <> N''
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted UA translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = rt.FormTemplate_IQ,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
inner join	@TemplateTable rt
on			rt.idfsFormTemplate = br.idfsBaseReference
			and IsNull(rt.FormTemplate_IQ, N'') <> N''
			and	(	@idfCustomizationPackage is null or rt.idfCustomizationPackage is null
					or	(	@idfCustomizationPackage is not null and rt.idfCustomizationPackage is not null
							and rt.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
where		snt.idfsLanguage = dbo.fnGetLanguageCode('ar')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(rt.FormTemplate_IQ, N'') collate Cyrillic_General_CI_AS
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
			rt.FormTemplate_IQ,
			0
from		@TemplateTable rt
inner join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsFormTemplate
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('ar')
where		(	@idfCustomizationPackage is null or rt.idfCustomizationPackage is null
				or	(	@idfCustomizationPackage is not null and rt.idfCustomizationPackage is not null
						and rt.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	IsNull(rt.FormTemplate_IQ, N'') <> N''
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted IQ translations (trtStringNameTranslation): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = rt.FormTemplate_TH,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
inner join	@TemplateTable rt
on			rt.idfsFormTemplate = br.idfsBaseReference
			and IsNull(rt.FormTemplate_TH, N'') <> N''
			and	(	@idfCustomizationPackage is null or rt.idfCustomizationPackage is null
					or	(	@idfCustomizationPackage is not null and rt.idfCustomizationPackage is not null
							and rt.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
where		snt.idfsLanguage = dbo.fnGetLanguageCode('th')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(rt.FormTemplate_TH, N'') collate Cyrillic_General_CI_AS
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
			rt.FormTemplate_TH,
			0
from		@TemplateTable rt
inner join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsFormTemplate
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('th')
where		(	@idfCustomizationPackage is null or rt.idfCustomizationPackage is null
				or	(	@idfCustomizationPackage is not null and rt.idfCustomizationPackage is not null
						and rt.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	IsNull(rt.FormTemplate_TH, N'') <> N''
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted TH translations (trtStringNameTranslation): ' + cast(@N as varchar(20))
print	''

-- Links to countries
update		brc
set			brc.intHACode = br.intHACode,
			brc.intOrder = 0
from		trtBaseReferenceToCP brc
inner join	trtBaseReference br
on			br.idfsBaseReference = brc.idfsBaseReference
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
inner join	@TemplateTable rt
on			rt.idfsFormTemplate = br.idfsBaseReference
			and IsNull(rt.idfCustomizationPackage, 0) = brc.idfCustomizationPackage
			and	(	@idfCustomizationPackage is null or rt.idfCustomizationPackage is null
					or	(	@idfCustomizationPackage is not null and rt.idfCustomizationPackage is not null
							and rt.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
where		(	IsNull(brc.intHACode, -1) <> IsNull(br.intHACode, -1)
				or	IsNull(brc.intOrder, -100000) <> 0
			)
set	@N = @@rowcount
print	'Updated links to country (trtBaseReferenceToCP): ' + cast(@N as varchar(20))

insert into	trtBaseReferenceToCP
(	idfsBaseReference,
	idfCustomizationPackage,
	intHACode,
	intOrder
)
select		br.idfsBaseReference,
			rt.idfCustomizationPackage,
			br.intHACode,
			0
from		@TemplateTable rt
inner join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsFormTemplate
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
left join	trtBaseReferenceToCP brc
on			brc.idfsBaseReference = rt.idfsFormTemplate
			and brc.idfCustomizationPackage = rt.idfCustomizationPackage
where		rt.idfCustomizationPackage is not null
			and (	@idfCustomizationPackage is null
				or	(	@idfCustomizationPackage is not null
						and rt.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	brc.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted links to country (trtBaseReferenceToCP): ' + cast(@N as varchar(20))
print	''

-- ffFormTemplate - child table of trtBaseReference
update		c
set			c.idfsFormType = rt.idfsFormType,
			c.blnUNI = IsNull(rt.blnUNI, 0),
			c.intRowStatus = 0
from		ffFormTemplate c
inner join	trtBaseReference br
on			br.idfsBaseReference = c.idfsFormTemplate
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
inner join	@TemplateTable rt
on			rt.idfsFormTemplate = br.idfsBaseReference
			and	(	@idfCustomizationPackage is null or rt.idfCustomizationPackage is null
					or	(	@idfCustomizationPackage is not null and rt.idfCustomizationPackage is not null
							and rt.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
where		(	c.idfsFormType <> IsNull(rt.idfsFormType, -1)
				or	IsNull(c.blnUNI, 1) <> IsNull(rt.blnUNI, 0)
				or	c.intRowStatus <> 0
			)
set	@N = @@rowcount
print	'Updated child table records (ffFormTemplate): ' + cast(@N as varchar(20))

insert into	ffFormTemplate
(	idfsFormTemplate,
	idfsFormType,
	blnUNI,
	intRowStatus
)
select		br.idfsBaseReference,
			rt.idfsFormType,
			IsNull(rt.blnUNI, 0),
			0
from		@TemplateTable rt
inner join	trtBaseReference br
on			br.idfsBaseReference = rt.idfsFormTemplate
			and br.idfsReferenceType = IsNull(@idfsReferenceType, 0)
			and br.intRowStatus = 0
left join	ffFormTemplate c
on			c.idfsFormTemplate = br.idfsBaseReference
where		(	@idfCustomizationPackage is null or rt.idfCustomizationPackage is null
				or	(	@idfCustomizationPackage is not null and rt.idfCustomizationPackage is not null
						and rt.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	c.idfsFormTemplate is null
set	@N = @@rowcount
print	'Inserted child table records (ffFormTemplate): ' + cast(@N as varchar(20))
print	''


-- Update existing IDs in the determinant table
print	''
print	'Insert templates'' determinants'
print	''
print	''

update		dt
set			dt.idfsFormTemplate = t.idfsFormTemplate
from		@DeterminantTable dt
inner join	fnReference('en', 19000034) r_ft	-- Flexible Form Type
on			r_ft.[name] = IsNull(dt.FormType_EN, N'') collate Cyrillic_General_CI_AS
inner join	tstCustomizationPackage c
on			IsNull(c.strCustomizationPackageName, N'') = 
				IsNull(dt.strCustomizationPackage, N'Not specified') collate Cyrillic_General_CI_AS
left join	ffFormTemplate t
	inner join	trtBaseReference br_t
	on			br_t.idfsBaseReference = t.idfsFormTemplate
				and br_t.idfsReferenceType = 19000033	-- Flexible Form Template
	left join	trtBaseReferenceToCP brc_t
	on			brc_t.idfsBaseReference = t.idfsFormTemplate
on			t.idfsFormType = r_ft.idfsReference
			and IsNull(br_t.strDefault, N'') = IsNull(dt.FormTemplate_EN, N'Not specified') collate Cyrillic_General_CI_AS
			and (brc_t.idfCustomizationPackage is null or brc_t.idfCustomizationPackage = c.idfCustomizationPackage)

delete		dt
from		@DeterminantTable dt
where		dt.idfsFormTemplate is null

update		dt
set			dt.idfDeterminantValue = dv.idfDeterminantValue
from		@DeterminantTable dt
inner join	ffDeterminantValue dv
on			dv.idfsFormTemplate = dt.idfsFormTemplate
			and dv.idfsBaseReference = IsNull(dt.idfsDiagnosis, -100000)
			and dv.intRowStatus = 0

update		dt
set			dt.idfDeterminantValue = dv.idfDeterminantValue
from		@DeterminantTable dt
inner join	ffDeterminantValue dv
on			dv.idfsFormTemplate = dt.idfsFormTemplate
			and dv.idfsBaseReference = IsNull(dt.idfsTestName, -100000)
			and dv.intRowStatus = 0

update		dt
set			dt.idfDeterminantValue = dv.idfDeterminantValue
from		@DeterminantTable dt
inner join	ffDeterminantValue dv
on			dv.idfsFormTemplate = dt.idfsFormTemplate
			and dv.idfsBaseReference = IsNull(dt.idfsVectorType, -100000)
			and dv.intRowStatus = 0


-- Generate new IDs
print	'Generate IDs for the new templates'' determinants'
print	''

delete from	tstNewID
where	idfTable = 74840000000	-- ffDeterminantValue

insert into	tstNewID
(	idfTable,
	idfKey1,
	idfKey2
)
select		74840000000,	-- ffDeterminantValue
			dt.idfID,
			null
from		@DeterminantTable dt
where		(dt.idfsDiagnosis is not null or dt.idfsTestName is not null or dt.idfsVectorType is not null)
			and dt.idfDeterminantValue is null

update		dt
set			dt.idfDeterminantValue = nID.[NewID]
from		@DeterminantTable dt
inner join	tstNewID nID
on			nID.idfTable = 74840000000	-- ffDeterminantValue
			and nID.idfKey1 = dt.idfID
			and nID.idfKey2 is null
where		(dt.idfsDiagnosis is not null or dt.idfsTestName is not null or dt.idfsVectorType is not null)
			and dt.idfDeterminantValue is null
set	@N = @@rowcount
print	'Number of new IDs generated for determinant values: ' + cast(@N as varchar(20))

delete from	tstNewID
where	idfTable = 74840000000	-- ffDeterminantValue

delete	dt
from	@DeterminantTable dt
where	dt.idfDeterminantValue is null

insert into	ffDeterminantValue
(	idfDeterminantValue,
	idfsFormTemplate,
	idfsBaseReference,
	intRowStatus
)
select	dt.idfDeterminantValue,
		dt.idfsFormTemplate,
		dt.idfsDiagnosis,
		0
from	@DeterminantTable dt
left join	ffDeterminantValue dv
on			dv.idfDeterminantValue = dt.idfDeterminantValue
where		dt.idfsDiagnosis is not null
			and dv.idfDeterminantValue is null
set	@N = @@rowcount
print	'Inserted diagnosis determinants: ' + cast(@N as varchar(20))

insert into	ffDeterminantValue
(	idfDeterminantValue,
	idfsFormTemplate,
	idfsBaseReference,
	intRowStatus
)
select	dt.idfDeterminantValue,
		dt.idfsFormTemplate,
		dt.idfsTestName,
		0
from	@DeterminantTable dt
left join	ffDeterminantValue dv
on			dv.idfDeterminantValue = dt.idfDeterminantValue
where		dt.idfsTestName is not null
			and dv.idfDeterminantValue is null
set	@N = @@rowcount
print	'Inserted test name determinants: ' + cast(@N as varchar(20))

insert into	ffDeterminantValue
(	idfDeterminantValue,
	idfsFormTemplate,
	idfsBaseReference,
	intRowStatus
)
select	dt.idfDeterminantValue,
		dt.idfsFormTemplate,
		dt.idfsVectorType,
		0
from	@DeterminantTable dt
left join	ffDeterminantValue dv
on			dv.idfDeterminantValue = dt.idfDeterminantValue
where		dt.idfsVectorType is not null
			and dv.idfDeterminantValue is null
set	@N = @@rowcount
print	'Inserted vector type determinants: ' + cast(@N as varchar(20))


if	@PerformDeletions = 1
begin

	update		dv
	set			dv.intRowStatus = 1
	from		ffDeterminantValue dv
	inner join	@TemplateTable tt
	on			tt.idfsFormTemplate = dv.idfsFormTemplate
				and	(	@idfCustomizationPackage is null or tt.idfCustomizationPackage is null
						or	(	@idfCustomizationPackage is not null and tt.idfCustomizationPackage is not null
								and tt.idfCustomizationPackage = @idfCustomizationPackage
							)
					)
	left join	@DeterminantTable dt_d
	on			dt_d.idfsFormTemplate = dv.idfsFormTemplate
				and IsNull(dt_d.idfsDiagnosis, -100) = IsNull(dv.idfsBaseReference, -1)
	left join	@DeterminantTable dt_tn
	on			dt_tn.idfsFormTemplate = dv.idfsFormTemplate
				and IsNull(dt_tn.idfsTestName, -100) = IsNull(dv.idfsBaseReference, -1)
	left join	@DeterminantTable dt_vt
	on			dt_vt.idfsFormTemplate = dv.idfsFormTemplate
				and IsNull(dt_vt.idfsVectorType, -100) = IsNull(dv.idfsBaseReference, -1)
	where		dv.idfsBaseReference is not null
				and dv.intRowStatus <> 1
				and dt_d.idfID is null
				and dt_tn.idfID is null
				and dt_vt.idfID is null
	set	@N = @@rowcount
	print	'Mark incorrect diagnosis, test name, and vector type determinants of correct templates as deleted: ' + cast(@N as varchar(20))
	print	''

end

if	@PerformDeletions = 2
begin

	delete		dv
	from		ffDeterminantValue dv
	inner join	@TemplateTable tt
	on			tt.idfsFormTemplate = dv.idfsFormTemplate
				and	(	@idfCustomizationPackage is null or tt.idfCustomizationPackage is null
						or	(	@idfCustomizationPackage is not null and tt.idfCustomizationPackage is not null
								and tt.idfCustomizationPackage = @idfCustomizationPackage
							)
					)
	left join	@DeterminantTable dt_d
	on			dt_d.idfsFormTemplate = dv.idfsFormTemplate
				and IsNull(dt_d.idfsDiagnosis, -100) = IsNull(dv.idfsBaseReference, -1)
	left join	@DeterminantTable dt_tn
	on			dt_tn.idfsFormTemplate = dv.idfsFormTemplate
				and IsNull(dt_tn.idfsTestName, -100) = IsNull(dv.idfsBaseReference, -1)
	left join	@DeterminantTable dt_vt
	on			dt_vt.idfsFormTemplate = dv.idfsFormTemplate
				and IsNull(dt_vt.idfsVectorType, -100) = IsNull(dv.idfsBaseReference, -1)
	where		dv.idfsBaseReference is not null
				and dt_d.idfID is null
				and dt_tn.idfID is null
				and dt_vt.idfID is null
	set	@N = @@rowcount
	print	'Deleted incorrect diagnosis, test name, and vector type determinants of correct templates: ' + cast(@N as varchar(20))
	print	''
	
end


/*
-- Generate script to fill reference table
print	'Script for filling @DeterminantTable with correct reference values'
print	''

select
N'
insert into @DeterminantTable (idfDeterminantValue, idfsFormType, idfsFormTemplate, strUNI, blnUNI, FormType_EN,
FormTemplate_EN, FormTemplate_AM, FormTemplate_AZ, FormTemplate_GG, FormTemplate_KZ, FormTemplate_RU, FormTemplate_IQ, FormTemplate_UA, FormTemplate_TH, ',
N'
' + N'idfsDiagnosis, strDiagnosis_EN, idfsTestName, strTestName_EN, idfsVectorType, strVectorType_EN, idfCustomizationPackage, strCustomizationPackage)
values	(' + IsNull(cast(dv.idfDeterminantValue as varchar(20)), N'null') + N', ' +
cast(t.idfsFormType as nvarchar(20)) + N', ' + 
cast(br.idfsBaseReference as varchar(20)) + N', ' + 
replace(replace(cast(IsNull(t.blnUNI, 0) as nvarchar(1)), N'0', N'N''No'''), N'1', N'N''Yes''') + N', ' + 
cast(IsNull(t.blnUNI, 0) as nvarchar(1)) + N', ' + 
IsNull(N'N''' + replace(ft.[name], N'''', N'''''') + N'''', N'null') + N', 
' + 
IsNull(N'N''' + replace(IsNull(snt_EN.strTextString, br.strDefault), N'''', N'''''') + N'''', N'N''') + N', ' + 
IsNull(N'N''' + replace(snt_AM.strTextString, N'''', N'''''') + N'''', N'null') + N', ' + 
IsNull(N'N''' + replace(snt_AZ.strTextString, N'''', N'''''') + N'''', N'null') + N', ' + 
IsNull(N'N''' + replace(snt_GG.strTextString, N'''', N'''''') + N'''', N'null') + N', ' + 
IsNull(N'N''' + replace(snt_KZ.strTextString, N'''', N'''''') + N'''', N'null') + N', ' + 
IsNull(N'N''' + replace(snt_RU.strTextString, N'''', N'''''') + N'''', N'null') + N', ' + 
IsNull(N'N''' + replace(snt_IQ.strTextString, N'''', N'''''') + N'''', N'null') + N', ' + 
IsNull(N'N''' + replace(snt_UA.strTextString, N'''', N'''''') + N'''', N'null') + N', ' + 
IsNull(N'N''' + replace(snt_TH.strTextString, N'''', N'''''') + N'''', N'null') + N', 
' + 
IsNull(cast(r_d.idfsReference as varchar(20)), N'null') + N', ' +
IsNull(N'N''' + replace(r_d.[name], N'''', N'''''') + N'''', N'N''''') + N', ' +
IsNull(cast(r_tt.idfsReference as varchar(20)), N'null') + N', ' +
IsNull(N'N''' + replace(r_tt.[name], N'''', N'''''') + N'''', N'N''''') + N', ' +
IsNull(cast(r_vt.idfsReference as varchar(20)), N'null') + N', ' +
IsNull(N'N''' + replace(r_vt.[name], N'''', N'''''') + N'''', N'N''''') + N', ' +
IsNull(cast(brc.idfCustomizationPackage as varchar(20)), N'null') + N', ' + 
IsNull(N'N''' + replace(c.strCustomizationPackageName, N'''', N'''''') + N'''', N'null') + N')
'
from
-- Base References
			trtBaseReference br
inner join	ffFormTemplate t
on			t.idfsFormTemplate = br.idfsBaseReference
			and t.intRowStatus = 0
inner join	fnReference('en', 19000034) ft		-- Flexible Form Type
on			ft.idfsReference = t.idfsFormType
inner join	@TemplateTable rt
on			rt.idfsFormTemplate = br.idfsBaseReference

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
left join	trtStringNameTranslation snt_IQ
on			snt_IQ.idfsBaseReference = br.idfsBaseReference
			and snt_IQ.idfsLanguage = dbo.fnGetLanguageCode('ar')
			and snt_IQ.intRowStatus = 0
left join	trtStringNameTranslation snt_UA
on			snt_UA.idfsBaseReference = br.idfsBaseReference
			and snt_UA.idfsLanguage = dbo.fnGetLanguageCode('uk')
			and snt_UA.intRowStatus = 0
left join	trtStringNameTranslation snt_TH
on			snt_TH.idfsBaseReference = br.idfsBaseReference
			and snt_TH.idfsLanguage = dbo.fnGetLanguageCode('th')
			and snt_TH.intRowStatus = 0

-- Links to countries
left join	trtBaseReferenceToCP brc
	inner join	tstCustomizationPackage c
	on			c.idfCustomizationPackage = brc.idfCustomizationPackage
on			brc.idfsBaseReference = br.idfsBaseReference
			and brc.idfCustomizationPackage = IsNull(@idfCustomizationPackage, c.idfCustomizationPackage)

-- Specific determinant values
left join	ffDeterminantType dt
on			dt.idfsFormType = t.idfsFormType
			and dt.idfsReferenceType is not null

left join	ffDeterminantValue dv
on			dv.idfsFormTemplate = t.idfsFormTemplate
			and dv.idfsBaseReference is not null
			and dv.intRowStatus = 0

left join	fnReference('en', 19000019) r_d		-- Diagnosis
	inner join	trtDiagnosis d
	on			d.idfsDiagnosis = r_d.idfsReference
				and d.idfsUsingType = 10020001	-- Case-based
				and d.intRowStatus = 0
on			r_d.idfsReference = dv.idfsBaseReference
			and dt.idfsReferenceType = 19000019	-- Diagnosis

left join	fnReference('en', 19000097) r_tt	-- Test Type
on			r_tt.idfsReference = dv.idfsBaseReference
			and dt.idfsReferenceType = 19000097	-- Test Type

left join	fnReference('en', 19000140) r_vt	-- Vector Type
	inner join	trtVectorType vt
	on			vt.idfsVectorType = r_vt.idfsReference
				and vt.intRowStatus = 0
on			r_vt.idfsReference = dv.idfsBaseReference
			and dt.idfsReferenceType = 19000140	-- Vector Type

left join	@DeterminantTable det
on			det.idfsFormTemplate = br.idfsBaseReference
			and det.idfsDiagnosis = IsNull(r_d.idfsReference, 0)
			and det.idfsTestName = IsNull(r_tt.idfsReference, 0)
			and det.idfsVectorType = IsNull(r_vt.idfsReference, 0)
			and det.idfCustomizationPackage = IsNull(c.idfCustomizationPackage, 0)

where		br.idfsReferenceType = 19000033	-- Flexible Form Template
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

