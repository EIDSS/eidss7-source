-- This script applies customization format to the list of flexible form parameter types 
-- with the lists of available values.
-- The script updates existing data by means of concordance table.
-- It should be executed on the database, for which customization format should be applied.
-- NB! It is assumed the check of source data (@ParameterTypeWithValues) has been already verified before applying the format.
-- Rules for filling the table @ParameterTypeWithValues are as follows:
-- 1) If parameter type is a system value (i.e. it should be included to the databases of all countries), 
--    the value of the column strCustomizationPackage should be 'ALL'.
-- 2) If parameter type doesn't have any specific value (e.g. String, Boolean, Diagnosis List, etc.),
--    the value of the column strParameterValue_EN should be 'No values'.


use [Giraffe]
GO



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
declare	@ParameterTypeWithValues	table
(	idfID								bigint not null identity(1, 2),
	idfsParameterType					bigint null,
	strParameterType_EN					nvarchar(200) collate database_default not null,
	strParameterType_National			nvarchar(200) collate database_default null,
	strParameterType_Second_National	nvarchar(200) collate database_default null,
	strParameterType_AM					nvarchar(200) collate database_default null,
	strParameterType_AZ					nvarchar(200) collate database_default null,
	strParameterType_GG					nvarchar(200) collate database_default null,
	strParameterType_KZ					nvarchar(200) collate database_default null,
	strParameterType_RU					nvarchar(200) collate database_default null,
	strParameterType_UA					nvarchar(200) collate database_default null,
	strParameterType_IQ					nvarchar(200) collate database_default null,
	strParameterType_TH					nvarchar(200) collate database_default null,
	idfsParameterValue					bigint null,
	strParameterValue_EN				nvarchar(200) collate database_default not null,-- 'No values' for parameter types without specific values
	strParameterValue_National			nvarchar(200) collate database_default null,	-- 'No values' for parameter types without specific values
	strParameterValue_Second_National	nvarchar(200) collate database_default null,	-- 'No values' for parameter types without specific values
	strParameterValue_AM				nvarchar(200) collate database_default null,
	strParameterValue_AZ				nvarchar(200) collate database_default null,
	strParameterValue_GG				nvarchar(200) collate database_default null,
	strParameterValue_KZ				nvarchar(200) collate database_default null,
	strParameterValue_RU				nvarchar(200) collate database_default null,
	strParameterValue_UA				nvarchar(200) collate database_default null,
	strParameterValue_IQ				nvarchar(200) collate database_default null,
	strParameterValue_TH				nvarchar(200) collate database_default null,
	strValueOrder						nvarchar(100) collate database_default null,
	intValueOrder						int null,
	strValueReferenceType				nvarchar(200) collate database_default null,
	idfsReferenceType					bigint null,
	strCustomizationPackage						nvarchar(200) collate database_default not null,	-- 'ALL' for all countries
	idfCustomizationPackage							bigint null,
	primary key	(
		strParameterType_EN asc,
		strParameterValue_EN asc,
		strCustomizationPackage asc
				)
)

declare	@TypeDeleteTable	table
(	idfsParameterType		bigint not null primary key
)

declare	@ValueDeleteTable	table
(	idfsParameterValue		bigint not null primary key,
	idfsParameterType		bigint not null
)

declare	@BRDeleteTable	table
(	idfsBaseReference		bigint not null primary key
)

declare	@BRCDeleteTable	table
(	idfsBaseReference		bigint not null,
	idfCustomizationPackage	bigint not null,
	primary key	(
		idfsBaseReference asc,
		idfCustomizationPackage asc
				)
)

declare	@CPToApply	table
(	idfCustomizationPackage	bigint not null primary key
)


declare	@CustomizationPackage		nvarchar(200)
declare	@idfCustomizationPackage	bigint

declare	@PerformDeletions	int

declare	@N					int

-- Set paremeters

set	@CustomizationPackage = N'Azerbaijan'	-- ALL

select	@idfCustomizationPackage = cp.idfCustomizationPackage
from	tstCustomizationPackage cp
where	cp.strCustomizationPackageName = @CustomizationPackage collate Cyrillic_General_CI_AS

set	@PerformDeletions = 0
--	0 - incorrect parameter types and values will be kept without changes
--	1 -	incorrect parameter types and values will be marked as deleted
--	2 -	incorrect parameter types and values will be deleted, 
--		as well as all incorrect flexible form values,
--		records, whose attributes with links to incorrect reference values aren't main for the record, will be cleared.

-- Fill table for deleting parameter types if necessary
-- Fill table for deleting parameter values if necessary


-- Fill parameter type and values table
insert into @ParameterTypeWithValues (idfsParameterType, idfsReferenceType, strParameterType_EN, strParameterType_GG, strParameterValue_EN, strParameterValue_GG, strValueReferenceType, strValueOrder, strCustomizationPackage) 
values
 (10071501, 19000160, N'Method of measurement', N'გაზომვის მეთოდი', N'No values', N'No values', N'Basic Syndromic Surveillance - Method of Measurement', N'0', N'Azerbaijan')
,(10071502, 19000064, N'Outcome', N'გამოსავალი', N'No values', N'No values', N'Case Outcome List', N'0', N'Azerbaijan')
,(10071503, 19000162, N'Lab Test Result', N'ლაბორატორიული ტესტის შედეგი', N'No values', N'No values', N'Basic Syndromic Surveillance - Test Result', N'0', N'Azerbaijan')



print	'Applying customization format for flexible form parameter types and their values'
print	''

-- Remove records related to not specified customization package
delete		ptv
from		@ParameterTypeWithValues ptv
where		IsNull(ptv.strCustomizationPackage, N'ALL') <> @CustomizationPackage collate Cyrillic_General_CI_AS
			and IsNull(ptv.strCustomizationPackage, N'ALL') <> N'ALL' collate Cyrillic_General_CI_AS
set	@N = @@rowcount
print	'Remove pairs of FF types and values from the format related to not specified cuatomization package: ' + cast(@N as varchar(20))
print	''

-- Update existing IDs

-- Update integer section orders
update		ptv
set			ptv.intValueOrder = cast(ptv.strValueOrder as integer)
from		@ParameterTypeWithValues ptv
where		IsNumeric(IsNull(ptv.strValueOrder, N'0')) = 1
			and ptv.strValueOrder is not null

-- Update existing values
update		ptv
			-- Country ID
set			ptv.idfCustomizationPackage = c.idfCustomizationPackage,
			-- Parameter Type ID
			ptv.idfsParameterType = 
				case	
					when	-- idfsBaseReference is not specified in the Reference Table
							ptv.idfsParameterType is null
							-- reference value with specified ID existed in the database with another reference type
							or	exists	(
									select	*
									from	trtBaseReference br_with_incorrect_type
									where	br_with_incorrect_type.idfsBaseReference = IsNull(ptv.idfsParameterType, 0)
											and br_with_incorrect_type.idfsReferenceType <> 19000071	-- Flexible Form Parameter Type
										)
							-- reference value with specified ID that has a link to another country
							or	(	c.idfCustomizationPackage is not null
									and	exists	(
											select		*
											from		trtBaseReference br_another_cp
											inner join	trtBaseReferenceToCP brc_another_cp
												inner join	tstCustomizationPackage cp_another_cp
												on			cp_another_cp.idfCustomizationPackage = brc_another_cp.idfCustomizationPackage
											on			brc_another_cp.idfsBaseReference = br_another_cp.idfsBaseReference
											where		br_another_cp.idfsBaseReference = IsNull(ptv.idfsParameterType, 0)
														and br_another_cp.idfsReferenceType = 19000071	-- Flexible Form Parameter Type
														and IsNull(cp_another_cp.idfCustomizationPackage, N'') <> c.idfCustomizationPackage
												)
								)
						then	br_type.idfsBaseReference
					else	ptv.idfsParameterType
				end,
			-- Parameter Value ID
			ptv.idfsParameterValue = 
				case	
					when	rtrim(ltrim(ptv.strParameterValue_EN)) = N'No values'
						then	null
					when	(	-- idfsBaseReference is not specified in the Reference Table
								ptv.idfsParameterValue is null
								-- reference value with specified ID existed in the database with another reference type
								or	exists	(
										select	*
										from	trtBaseReference br_with_incorrect_value_type
										where	br_with_incorrect_value_type.idfsBaseReference = IsNull(ptv.idfsParameterValue, 0)
												and br_with_incorrect_value_type.idfsReferenceType <> 19000069	-- Flexible Form Parameter Value
											)
								-- reference value with specified ID that has a link to another country
								or	(	c.idfCustomizationPackage is not null
										and	exists	(
												select		*
												from		trtBaseReference br_another_cp
												inner join	trtBaseReferenceToCP brc_another_cp
													inner join	tstCustomizationPackage c_another_cp
													on			c_another_cp.idfCustomizationPackage = brc_another_cp.idfCustomizationPackage
												on			brc_another_cp.idfsBaseReference = br_another_cp.idfsBaseReference
												where		br_another_cp.idfsBaseReference = IsNull(ptv.idfsParameterValue, 0)
															and br_another_cp.idfsReferenceType = 19000069	-- Flexible Form Parameter Value
															and IsNull(c_another_cp.idfCustomizationPackage, N'') <> c.idfCustomizationPackage
													)
									)
							)
							and rtrim(ltrim(ptv.strParameterValue_EN)) <> N'No values'
						then	br_value.idfsBaseReference
					else	ptv.idfsParameterValue
				end,
			ptv.idfsReferenceType =
				case	
					when	rtrim(ltrim(ptv.strParameterValue_EN)) <> N'No values'
						then	19000069	-- Flexible Form Parameter Value
					else	rt.idfsReferenceType
				end
			
from		@ParameterTypeWithValues ptv
-- Country
left join	tstCustomizationPackage c
	inner join	gisCountry cc
	on			cc.idfsCountry = c.idfsCountry
				and cc.intRowStatus = 0
on			c.strCustomizationPackageName = IsNull(ptv.strCustomizationPackage, N'ALL') collate Cyrillic_General_CI_AS
-- Existing Base References
-- Parameter Type
left join	trtBaseReference br_type
	left join	trtBaseReferenceToCP brc_type
	on			brc_type.idfsBaseReference = br_type.idfsBaseReference
on			IsNull(br_type.strDefault, N'') = ptv.strParameterType_EN collate Cyrillic_General_CI_AS
			and br_type.idfsReferenceType = 19000071	-- Flexible Form Parameter Type
			and br_type.intRowStatus = 0
			and (	(	brc_type.idfCustomizationPackage is not null 
						and c.idfCustomizationPackage is not null
						and brc_type.idfCustomizationPackage = c.idfCustomizationPackage
					)
					or	(	brc_type.idfCustomizationPackage is null 
							and c.idfCustomizationPackage is null
						)
				)
-- Parameter Value
left join	trtBaseReference br_value
	inner join	ffParameterFixedPresetValue pfpv
	on			pfpv.idfsParameterFixedPresetValue = br_value.idfsBaseReference
	left join	trtBaseReferenceToCP brc_value
	on			brc_value.idfsBaseReference = br_value.idfsBaseReference
on			IsNull(br_value.strDefault, N'') = ptv.strParameterValue_EN collate Cyrillic_General_CI_AS
			and br_value.idfsReferenceType = 19000069	-- Flexible Form Parameter Value
			and br_value.intRowStatus = 0
			and (	(	brc_value.idfCustomizationPackage is not null 
						and c.idfCustomizationPackage is not null
						and brc_value.idfCustomizationPackage = c.idfCustomizationPackage
					)
					or	(	brc_value.idfCustomizationPackage is null 
							and c.idfCustomizationPackage is null
						)
				)
			and	(	(	(	-- idfsBaseReference is not specified in the Reference Table
							ptv.idfsParameterType is null
							-- reference value with specified ID existed in the database with another reference type
							or	exists	(
									select	*
									from	trtBaseReference br_with_incorrect_type
									where	br_with_incorrect_type.idfsBaseReference = IsNull(ptv.idfsParameterType, 0)
											and br_with_incorrect_type.idfsReferenceType <> 19000071	-- Flexible Form Parameter Type
										)
							-- reference value with specified ID that has a link to another country
							or	(	c.idfCustomizationPackage is not null
									and	exists	(
											select		*
											from		trtBaseReference br_another_cp
											inner join	trtBaseReferenceToCP brc_another_cp
												inner join	tstCustomizationPackage c_another_cp
												on			c_another_cp.idfCustomizationPackage = brc_another_cp.idfCustomizationPackage
											on			brc_another_cp.idfsBaseReference = br_another_cp.idfsBaseReference
											where		br_another_cp.idfsBaseReference = IsNull(ptv.idfsParameterType, 0)
														and br_another_cp.idfsReferenceType = 19000071	-- Flexible Form Parameter Type
														and IsNull(c_another_cp.idfCustomizationPackage, N'') <> c.idfCustomizationPackage
												)
								)
						)
						and pfpv.idfsParameterType = br_type.idfsBaseReference
					)
					or	(	-- idfsBaseReference is specified in the Reference Table
							ptv.idfsParameterType is not null
							-- reference value with specified ID existed in the database with another reference type
							and	not exists	(
										select	*
										from	trtBaseReference br_with_incorrect_type
										where	br_with_incorrect_type.idfsBaseReference = IsNull(ptv.idfsParameterType, 0)
												and br_with_incorrect_type.idfsReferenceType <> 19000071	-- Flexible Form Parameter Type
											)
							-- reference value with specified ID that has a link to another country
							and	(	c.idfCustomizationPackage is null
									or	(	c.idfCustomizationPackage is not null
											and	not exists	(
														select		*
														from		trtBaseReference br_another_cp
														inner join	trtBaseReferenceToCP brc_another_cp
															inner join	tstCustomizationPackage c_another_cp
															on			c_another_cp.idfCustomizationPackage = brc_another_cp.idfCustomizationPackage
														on			brc_another_cp.idfsBaseReference = br_another_cp.idfsBaseReference
														where		br_another_cp.idfsBaseReference = IsNull(ptv.idfsParameterType, 0)
																	and br_another_cp.idfsReferenceType = 19000071	-- Flexible Form Parameter Type
																	and IsNull(c_another_cp.idfCustomizationPackage, N'') <> c.idfCustomizationPackage
															)
										)
								)
							and pfpv.idfsParameterType = ptv.idfsParameterType
						)
				)


-- Parameter Reference Type
left join	trtReferenceType rt
on			rt.strReferenceTypeName = ptv.strValueReferenceType collate Cyrillic_General_CI_AS
			and	rt.intRowStatus = 0


insert into	@CPToApply(idfCustomizationPackage)
select distinct
			idfCustomizationPackage
from		@ParameterTypeWithValues
where		idfCustomizationPackage is not null


-- Remove incorrect records and related reference information if necessary
if	@PerformDeletions = 2
begin
	insert into	@TypeDeleteTable	(idfsParameterType)
	select		pt.idfsParameterType
	from		ffParameterType pt
	left join	@ParameterTypeWithValues ptv
	on			ptv.idfsParameterType = pt.idfsParameterType
	left join	@TypeDeleteTable tdt_ex
	on			tdt_ex.idfsParameterType = pt.idfsParameterType
	where		(	exists	(
						select		*
						from		trtBaseReferenceToCP brcp
						inner join	@CPToApply cpa
						on			cpa.idfCustomizationPackage = brcp.idfCustomizationPackage
						where		brcp.idfsBaseReference = pt.idfsParameterType
							)
				)
				and ptv.idfID is null
				and tdt_ex.idfsParameterType is null

	insert into	@ValueDeleteTable	(idfsParameterType, idfsParameterValue)
	select		pfpv.idfsParameterType,
				pfpv.idfsParameterFixedPresetValue
	from		ffParameterFixedPresetValue pfpv
	left join	@ParameterTypeWithValues ptv
	on			ptv.idfsParameterValue = pfpv.idfsParameterFixedPresetValue
	left join	@ValueDeleteTable vdt_ex
	on			vdt_ex.idfsParameterValue = pfpv.idfsParameterFixedPresetValue
	where		(	exists	(
						select		*
						from		trtBaseReferenceToCP brcp
						inner join	@CPToApply cpa
						on			cpa.idfCustomizationPackage = brcp.idfCustomizationPackage
						where		brcp.idfsBaseReference = pfpv.idfsParameterFixedPresetValue
							)
				)
				and ptv.idfID is null
				and vdt_ex.idfsParameterValue is null
end

if	@PerformDeletions >= 1
begin

	insert into	@BRDeleteTable	(idfsBaseReference)
	select		tdt.idfsParameterType
	from		@TypeDeleteTable tdt
	inner join	ffParameterType pt
	on			pt.idfsParameterType = tdt.idfsParameterType
	-- There is no parameters from another customization package
	left join	ffParameter p
	on			p.idfsParameterType = pt.idfsParameterType
				and p.intRowStatus = 0
				and exists	(
						select		*
						from		trtBaseReferenceToCP brcp_p
						left join	@CPToApply cpa_p
						on			cpa_p.idfCustomizationPackage = brcp_p.idfCustomizationPackage
						where		cpa_p.idfCustomizationPackage is null
							)
	where		p.idfsParameter is null
				and (	not exists	(
								select		*
								from		trtBaseReferenceToCP brcp_common
								where		brcp_common.idfsBaseReference = tdt.idfsParameterType
									)
						or	(	exists	(
									select		*
									from		trtBaseReferenceToCP brcp_current
									inner join	@CPToApply cpa_current
									on			cpa_current.idfCustomizationPackage = brcp_current.idfCustomizationPackage
									where		brcp_current.idfsBaseReference = tdt.idfsParameterType
										)
								and not exists	(
											select		*
											from		trtBaseReferenceToCP brcp_another
											left join	@CPToApply cpa_another
											on			cpa_another.idfCustomizationPackage = brcp_another.idfCustomizationPackage
											where		brcp_another.idfsBaseReference = tdt.idfsParameterType
														and cpa_another.idfCustomizationPackage is null
												)
							)
					)

	insert into	@BRCDeleteTable	(idfsBaseReference, idfCustomizationPackage)
	select		tdt.idfsParameterType,
				brcp_current.idfCustomizationPackage
	from		@TypeDeleteTable tdt
	inner join	ffParameterType pt
	on			pt.idfsParameterType = tdt.idfsParameterType
	inner join	trtBaseReferenceToCP brcp_current
		inner join	@CPToApply cpa_current
		on			cpa_current.idfCustomizationPackage = brcp_current.idfCustomizationPackage
	on			brcp_current.idfsBaseReference = tdt.idfsParameterType
	left join	@BRDeleteTable brdt
	on			brdt.idfsBaseReference = tdt.idfsParameterType
	where		brdt.idfsBaseReference is null

	insert into	@BRDeleteTable	(idfsBaseReference)
	select		pfpv.idfsParameterFixedPresetValue
	from		ffParameterFixedPresetValue pfpv
	inner join	@BRDeleteTable brdt_pt
	on			brdt_pt.idfsBaseReference = pfpv.idfsParameterType
	left join	@BRDeleteTable brdt_ex
	on			brdt_ex.idfsBaseReference = pfpv.idfsParameterFixedPresetValue
	where		brdt_ex.idfsBaseReference is null

	insert into	@BRCDeleteTable	(idfsBaseReference, idfCustomizationPackage)
	select		pfpv.idfsParameterFixedPresetValue,
				brcdt_pt.idfCustomizationPackage
	from		ffParameterFixedPresetValue pfpv
	inner join	@BRCDeleteTable brcdt_pt
	on			brcdt_pt.idfsBaseReference = pfpv.idfsParameterType
	left join	@BRCDeleteTable brcdt_ex
	on			brcdt_ex.idfsBaseReference = pfpv.idfsParameterFixedPresetValue
				and brcdt_ex.idfCustomizationPackage = brcdt_pt.idfCustomizationPackage
	where		brcdt_ex.idfsBaseReference is null

	insert into	@BRDeleteTable	(idfsBaseReference)
	select		vdt.idfsParameterValue
	from		@ValueDeleteTable vdt
	inner join	ffParameterFixedPresetValue pfpv
	on			pfpv.idfsParameterFixedPresetValue = vdt.idfsParameterValue
	left join	@BRDeleteTable brdt_ex
	on			brdt_ex.idfsBaseReference = vdt.idfsParameterValue
	where		brdt_ex.idfsBaseReference is null
				and (	not exists	(
								select		*
								from		trtBaseReferenceToCP brcp_common
								where		brcp_common.idfsBaseReference = vdt.idfsParameterValue
									)
						or	(	exists	(
									select		*
									from		trtBaseReferenceToCP brcp_current
									inner join	@CPToApply cpa_current
									on			cpa_current.idfCustomizationPackage = brcp_current.idfCustomizationPackage
									where		brcp_current.idfsBaseReference = vdt.idfsParameterValue
										)
								and not exists	(
											select		*
											from		trtBaseReferenceToCP brcp_another
											left join	@CPToApply cpa_another
											on			cpa_another.idfCustomizationPackage = brcp_another.idfCustomizationPackage
											where		brcp_another.idfsBaseReference = vdt.idfsParameterValue
														and cpa_another.idfCustomizationPackage is null
												)
							)
					)
	

	insert into	@BRCDeleteTable	(idfsBaseReference, idfCustomizationPackage)
	select		vdt.idfsParameterValue,
				brcp_current.idfCustomizationPackage
	from		@ValueDeleteTable vdt
	inner join	ffParameterFixedPresetValue pfpv
	on			pfpv.idfsParameterFixedPresetValue = vdt.idfsParameterValue
	inner join	trtBaseReferenceToCP brcp_current
		inner join	@CPToApply cpa_current
		on			cpa_current.idfCustomizationPackage = brcp_current.idfCustomizationPackage
	on			brcp_current.idfsBaseReference = vdt.idfsParameterValue
	left join	@BRDeleteTable brdt
	on			brdt.idfsBaseReference = vdt.idfsParameterValue
	left join	@BRCDeleteTable brcdt_ex
	on			brcdt_ex.idfsBaseReference = vdt.idfsParameterValue
				and brcdt_ex.idfCustomizationPackage = brcp_current.idfCustomizationPackage
	where		brdt.idfsBaseReference is null
				and brcdt_ex.idfsBaseReference is null
end

-- Mark records as deleted
if @PerformDeletions = 1
begin

	print	'Mark incorrect references as deleted according to concordance table'
	print	''

	--update		p
	--set			p.idfsParameterType = 10071045	-- String
	--from		ffParameter p
	--inner join	@BRDeleteTable brdt
	--on			brdt.idfsBaseReference = p.idfsParameterType
	--where		IsNull(p.idfsParameterType, -1) <> 10071045	-- String
	--set	@N = @@rowcount
	--print	'Replace types of parameters from the types, which shall be deleted, to the type "String" (ffParameter) - update: ' + cast(@N as varchar(20))


	update		pfpv
	set			pfpv.intRowStatus = 1
	from		ffParameterFixedPresetValue pfpv
	inner join	@BRDeleteTable brdt
	on			brdt.idfsBaseReference = pfpv.idfsParameterFixedPresetValue
	where		pfpv.intRowStatus <> 1
	set	@N = @@rowcount
	print	'FF parameters'' values to delete (ffParameterFixedPresetValue) - mark as deleted: ' + cast(@N as varchar(20))

	update		pt
	set			pt.intRowStatus = 1
	from		ffParameterType pt
	inner join	@BRDeleteTable brdt
	on			brdt.idfsBaseReference = pt.idfsParameterType
	where		pt.intRowStatus <> 1
	set	@N = @@rowcount
	print	'FF parameters'' types to delete (ffParameterType) - mark as deleted: ' + cast(@N as varchar(20))

	-- Delete related permissions
	delete		oa
	from		tstObjectAccess oa
	inner join	@BRDeleteTable br_del
	on			br_del.idfsBaseReference = oa.idfsObjectID
	set	@N = @@rowcount
	print	'Permissions to the references marked as deleted (tstObjectAccess) - delete: ' + cast(@N as varchar(20))

	-- Delete incorrect links to country
	delete		brcp
	from		trtBaseReferenceToCP brcp
	inner join	@BRCDeleteTable brc_del
	on			brc_del.idfsBaseReference = brcp.idfsBaseReference
				and brc_del.idfCustomizationPackage = brcp.idfCustomizationPackage
	set	@N = @@rowcount
	print	'Delete incorrect links to Customization Packages of references (trtBaseReferenceToCP) (@BRCDeleteTable): ' + cast(@N as varchar(20))	

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

	update		p
	set			p.idfsParameterType = 10071045	-- String
	from		ffParameter p
	inner join	@BRDeleteTable brdt
	on			brdt.idfsBaseReference = p.idfsParameterType
	where		IsNull(p.idfsParameterType, -1) <> 10071045	-- String
	set	@N = @@rowcount
	print	'Replace types of parameters from the types, which shall be deleted, to the type "String" (ffParameter) - update: ' + cast(@N as varchar(20))


	delete		pfpv
	from		ffParameterFixedPresetValue pfpv
	inner join	@BRDeleteTable brdt
	on			brdt.idfsBaseReference = pfpv.idfsParameterFixedPresetValue
	set	@N = @@rowcount
	print	'Delete FF parameters'' values (ffParameterFixedPresetValue): ' + cast(@N as varchar(20))

	delete		pt
	from		ffParameterType pt
	inner join	@BRDeleteTable brdt
	on			brdt.idfsBaseReference = pt.idfsParameterType
	set	@N = @@rowcount
	print	'Delete incorrect FF parameters'' types (ffParameterType): ' + cast(@N as varchar(20))

	-- Delete related permissions
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
	 
	delete		br_to_cp
	from		trtBaseReferenceToCP br_to_cp
	inner join	@BRCDeleteTable br_del
	on			br_del.idfsBaseReference = br_to_cp.idfsBaseReference
				and br_del.idfCustomizationPackage = br_to_cp.idfCustomizationPackage
	set	@N = @@rowcount
	print	'Delete incorrect links to Customization Packages of references (trtBaseReferenceToCP) (@BRCDeleteTable): ' + cast(@N as varchar(20))	
	
	delete		br
	from		trtBaseReference br
	inner join	@BRDeleteTable br_del
	on			br_del.idfsBaseReference = br.idfsBaseReference
	set	@N = @@rowcount
	print	'Delete incorrect references (trtBaseReference): ' + cast(@N as varchar(20))
	print	''
	print	''

end


set	@N = 0
select		@N = count(*)
from		@ParameterTypeWithValues ptv
where		(	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
				or	(	ptv.idfCustomizationPackage is not null 
						and @idfCustomizationPackage is not null
						and ptv.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
print	'Number of correct rows with parameter types and their values: ' + cast(@N as varchar(20))


print	''
print	'Update/insert parameter types and their values'
print	''
print	''

-- Generate new IDs
print	'Generate IDs for the new parameter types and their values'
print	''
delete from	tstNewID
where	idfTable = 75820000000	-- trtBaseReference

insert into	tstNewID
(	idfTable,
	idfKey1,
	idfKey2
)
select		75820000000,		-- trtBaseReference
			ptv.idfID,
			null
from		@ParameterTypeWithValues ptv
left join	@ParameterTypeWithValues ptv_first_value
on			ptv_first_value.strParameterType_EN = ptv.strParameterType_EN
			and	ptv_first_value.strCustomizationPackage = ptv.strCustomizationPackage
			and ((ptv_first_value.strCustomizationPackage < ptv.strCustomizationPackage) or (ptv_first_value.strCustomizationPackage = ptv.strCustomizationPackage and ptv_first_value.strParameterValue_EN < ptv.strParameterValue_EN))
where		ptv.idfsParameterType is null
			and (	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
					or	(	ptv.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
			and ptv_first_value.strParameterType_EN is null

insert into	tstNewID
(	idfTable,
	idfKey1,
	idfKey2
)
select		75820000000,		-- trtBaseReference
			ptv.idfID + 1,
			null
from		@ParameterTypeWithValues ptv
where		ptv.idfsParameterValue is null
			and rtrim(ltrim(ptv.strParameterValue_EN)) <> N'No values'
			and (	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
					or	(	ptv.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv.idfCustomizationPackage = @idfCustomizationPackage
						)
				)


update		ptv
set			ptv.idfsParameterType = nID.[NewID]
from		@ParameterTypeWithValues ptv
inner join	tstNewID nID
on			nID.idfTable = 75820000000	-- trtBaseReference
			and nID.idfKey1 = ptv.idfID
			and nID.idfKey2 is null
where		ptv.idfsParameterType is null
			and (	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
					or	(	ptv.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
set	@N = @@rowcount
print	'Number of IDs generated for new parameter types: ' + cast(@N as varchar(20))

update		ptv
set			ptv.idfsParameterType = ptv_ID.idfsParameterType
from		@ParameterTypeWithValues ptv
inner join	@ParameterTypeWithValues ptv_ID
on			ptv_ID.strParameterType_EN = ptv.strParameterType_EN
			and	ptv_ID.strCustomizationPackage = ptv.strCustomizationPackage
			and ptv_ID.idfsParameterType is not null
left join	@ParameterTypeWithValues ptv_first_value
on			ptv_first_value.strParameterType_EN = ptv.strParameterType_EN
			and	ptv_first_value.strCustomizationPackage = ptv.strCustomizationPackage
			and ptv_first_value.strParameterValue_EN < ptv_ID.strParameterValue_EN
			and ptv_first_value.idfsParameterType is not null
where		IsNull(ptv.idfsParameterType, -100000) <> ptv_ID.idfsParameterType
			and (	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
					or	(	ptv.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
			and ptv_first_value.strParameterType_EN is null

update		ptv
set			ptv.idfsParameterValue = nID.[NewID]
from		@ParameterTypeWithValues ptv
inner join	tstNewID nID
on			nID.idfTable = 75820000000	-- trtBaseReference
			and nID.idfKey1 = ptv.idfID + 1
			and nID.idfKey2 is null
where		ptv.idfsParameterValue is null
			and rtrim(ltrim(ptv.strParameterValue_EN)) <> N'No values'
			and (	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
					or	(	ptv.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
set	@N = @@rowcount
print	'Number of IDs generated for new parameter values: ' + cast(@N as varchar(20))

delete from	tstNewID
where	idfTable = 75820000000	-- trtBaseReference

set	@N = 0
select		@N = count(*)
from		@ParameterTypeWithValues ptv
inner join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterType
print	'Number of rows with existing correct parameter types: ' + cast(@N as varchar(20))

set	@N = 0
select		@N = count(*)
from		@ParameterTypeWithValues ptv
inner join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterValue
print	'Number of rows with existing correct parameter values: ' + cast(@N as varchar(20))

set	@N = 0
select		@N = count(*)
from		@ParameterTypeWithValues ptv
left join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterType
where		br.idfsBaseReference is null
print	'Number of non-existing correct parameter types: ' + cast(@N as varchar(20))

set	@N = 0
select		@N = count(*)
from		@ParameterTypeWithValues ptv
left join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterValue
where		br.idfsBaseReference is null
print	'Number of non-existing correct parameter values: ' + cast(@N as varchar(20))
print	''




-- Update & insert correct records in the database

-- Base Reference
-- Parameter Type
update		br
set			br.strDefault = ptv.strParameterType_EN,
			br.intHACode = 226,
			br.intOrder = 0,
			br.blnSystem = 0,
			br.intRowStatus = 0
from		trtBaseReference br
inner join	@ParameterTypeWithValues ptv
on			ptv.idfsParameterType = br.idfsBaseReference
left join	@ParameterTypeWithValues ptv_first_value
on			ptv_first_value.idfsParameterType = ptv.idfsParameterType
			and (	@idfCustomizationPackage is null or ptv_first_value.idfCustomizationPackage is null 
					or	(	ptv_first_value.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv_first_value.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
			and ((ptv_first_value.strCustomizationPackage < ptv.strCustomizationPackage) or (ptv_first_value.strCustomizationPackage = ptv.strCustomizationPackage and ptv_first_value.strParameterValue_EN < ptv.strParameterValue_EN))
where		(	IsNull(br.strDefault, N'') <> ptv.strParameterType_EN collate Cyrillic_General_CI_AS
				or	IsNull(br.intHACode, -1) <> 226
				or	IsNull(br.intOrder, 0) <> 0
				or	br.intRowStatus <> 0
			)
			and (	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
					or	(	ptv.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
			and ptv_first_value.strParameterType_EN is null
set	@N = @@rowcount
print	'Updated rows (trtBaseReference - Parameter Type): ' + cast(@N as varchar(20))

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
select		ptv.idfsParameterType,
			19000071,	-- Flexible Form Parameter Type
			null,
			ptv.strParameterType_EN,
			226,
			0,
			0,
			0
from		@ParameterTypeWithValues ptv
left join	@ParameterTypeWithValues ptv_first_value
on			ptv_first_value.idfsParameterType = ptv.idfsParameterType
			and (	@idfCustomizationPackage is null or ptv_first_value.idfCustomizationPackage is null 
					or	(	ptv_first_value.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv_first_value.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
			and ((ptv_first_value.strCustomizationPackage < ptv.strCustomizationPackage) or (ptv_first_value.strCustomizationPackage = ptv.strCustomizationPackage and ptv_first_value.strParameterValue_EN < ptv.strParameterValue_EN))
left join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterType
where		(	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
				or	(	ptv.idfCustomizationPackage is not null 
						and @idfCustomizationPackage is not null
						and ptv.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and ptv_first_value.strParameterType_EN is null
			and	br.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted rows (trtBaseReference - Parameter Type): ' + cast(@N as varchar(20))

-- Parameter Value
update		br
set			br.strDefault = ptv.strParameterValue_EN,
			br.intHACode = 226,
			br.intOrder = IsNull(ptv.intValueOrder, 0),
			br.blnSystem = 0,
			br.intRowStatus = 0
from		trtBaseReference br
inner join	@ParameterTypeWithValues ptv
on			IsNull(ptv.idfsParameterValue, -100000) = br.idfsBaseReference
where		(	IsNull(br.strDefault, N'') <> ptv.strParameterValue_EN collate Cyrillic_General_CI_AS
				or	IsNull(br.intHACode, -1) <> 226
				or	IsNull(br.intOrder, -100000) <> IsNull(ptv.intValueOrder, 0)
				or	br.intRowStatus <> 0
			)
			and (	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
					or	(	ptv.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
set	@N = @@rowcount
print	'Updated rows (trtBaseReference - Parameter Value): ' + cast(@N as varchar(20))

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
select		ptv.idfsParameterValue,
			19000069,	-- Flexible Form Parameter Value
			null,
			ptv.strParameterValue_EN,
			226,
			IsNull(ptv.intValueOrder, 0),
			0,
			0
from		@ParameterTypeWithValues ptv
left join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterValue
where		(	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
				or	(	ptv.idfCustomizationPackage is not null 
						and @idfCustomizationPackage is not null
						and ptv.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and ptv.idfsParameterValue is not null
			and	br.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted rows (trtBaseReference - Parameter Value): ' + cast(@N as varchar(20))
print	''

-- Translations
-- Parameter Value
update		snt
set			snt.strTextString = ptv.strParameterType_EN,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = 19000071	-- Flexible Form Parameter Type
			and br.intRowStatus = 0
inner join	@ParameterTypeWithValues ptv
on			ptv.idfsParameterType = br.idfsBaseReference
			and (	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
					or	(	ptv.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
left join	@ParameterTypeWithValues ptv_first_value
on			ptv_first_value.idfsParameterType = ptv.idfsParameterType
			and (	@idfCustomizationPackage is null or ptv_first_value.idfCustomizationPackage is null 
					or	(	ptv_first_value.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv_first_value.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
			and ((ptv_first_value.strCustomizationPackage < ptv.strCustomizationPackage) or (ptv_first_value.strCustomizationPackage = ptv.strCustomizationPackage and ptv_first_value.strParameterValue_EN < ptv.strParameterValue_EN))
where		snt.idfsLanguage = dbo.fnGetLanguageCode('en')
			and	(	IsNull(snt.strTextString, N'') <> ptv.strParameterType_EN collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
			and ptv_first_value.strParameterType_EN is null
set	@N = @@rowcount
print	'Updated EN translations (trtStringNameTranslation - Parameter Type): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('en'),
			ptv.strParameterType_EN,
			0
from		@ParameterTypeWithValues ptv
inner join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterType
			and br.idfsReferenceType = 19000071	-- Flexible Form Parameter Type
			and br.intRowStatus = 0
left join	@ParameterTypeWithValues ptv_first_value
on			ptv_first_value.idfsParameterType = ptv.idfsParameterType
			and (	@idfCustomizationPackage is null or ptv_first_value.idfCustomizationPackage is null 
					or	(	ptv_first_value.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv_first_value.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
			and ((ptv_first_value.strCustomizationPackage < ptv.strCustomizationPackage) or (ptv_first_value.strCustomizationPackage = ptv.strCustomizationPackage and ptv_first_value.strParameterValue_EN < ptv.strParameterValue_EN))
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('en')
where		(	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
				or	(	ptv.idfCustomizationPackage is not null 
						and @idfCustomizationPackage is not null
						and ptv.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and ptv_first_value.strParameterType_EN is null
			and	snt.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted EN translations (trtStringNameTranslation - Parameter Type): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = ptv.strParameterType_AM,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = 19000071	-- Flexible Form Parameter Type
			and br.intRowStatus = 0
inner join	@ParameterTypeWithValues ptv
on			ptv.idfsParameterType = br.idfsBaseReference
			and IsNull(ptv.strParameterType_AM, N'') <> N''
			and (	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
					or	(	ptv.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
left join	@ParameterTypeWithValues ptv_first_value
on			ptv_first_value.idfsParameterType = ptv.idfsParameterType
			and (	@idfCustomizationPackage is null or ptv_first_value.idfCustomizationPackage is null 
					or	(	ptv_first_value.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv_first_value.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
			and IsNull(ptv_first_value.strParameterType_AM, N'') <> N''
			and ((ptv_first_value.strCustomizationPackage < ptv.strCustomizationPackage) or (ptv_first_value.strCustomizationPackage = ptv.strCustomizationPackage and ptv_first_value.strParameterValue_EN < ptv.strParameterValue_EN))
where		snt.idfsLanguage = dbo.fnGetLanguageCode('hy')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(ptv.strParameterType_AM, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
			and ptv_first_value.strParameterType_EN is null
set	@N = @@rowcount
print	'Updated AM translations (trtStringNameTranslation - Parameter Type): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('hy'),
			ptv.strParameterType_AM,
			0
from		@ParameterTypeWithValues ptv
inner join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterType
			and br.idfsReferenceType = 19000071	-- Flexible Form Parameter Type
			and br.intRowStatus = 0
left join	@ParameterTypeWithValues ptv_first_value
on			ptv_first_value.idfsParameterType = ptv.idfsParameterType
			and (	@idfCustomizationPackage is null or ptv_first_value.idfCustomizationPackage is null 
					or	(	ptv_first_value.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv_first_value.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
			and IsNull(ptv_first_value.strParameterType_AM, N'') <> N''
			and ((ptv_first_value.strCustomizationPackage < ptv.strCustomizationPackage) or (ptv_first_value.strCustomizationPackage = ptv.strCustomizationPackage and ptv_first_value.strParameterValue_EN < ptv.strParameterValue_EN))
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('hy')
where		(	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
				or	(	ptv.idfCustomizationPackage is not null 
						and @idfCustomizationPackage is not null
						and ptv.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	IsNull(ptv.strParameterType_AM, N'') <> N''
			and snt.idfsBaseReference is null
			and ptv_first_value.strParameterType_EN is null
set	@N = @@rowcount
print	'Inserted AM translations (trtStringNameTranslation - Parameter Type): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = ptv.strParameterType_AZ,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = 19000071	-- Flexible Form Parameter Type
			and br.intRowStatus = 0
inner join	@ParameterTypeWithValues ptv
on			ptv.idfsParameterType = br.idfsBaseReference
			and IsNull(ptv.strParameterType_AZ, N'') <> N''
			and (	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
					or	(	ptv.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
left join	@ParameterTypeWithValues ptv_first_value
on			ptv_first_value.idfsParameterType = ptv.idfsParameterType
			and (	@idfCustomizationPackage is null or ptv_first_value.idfCustomizationPackage is null 
					or	(	ptv_first_value.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv_first_value.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
			and IsNull(ptv_first_value.strParameterType_AZ, N'') <> N''
			and ((ptv_first_value.strCustomizationPackage < ptv.strCustomizationPackage) or (ptv_first_value.strCustomizationPackage = ptv.strCustomizationPackage and ptv_first_value.strParameterValue_EN < ptv.strParameterValue_EN))
where		snt.idfsLanguage = dbo.fnGetLanguageCode('az-L')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(ptv.strParameterType_AZ, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
			and ptv_first_value.strParameterType_EN is null
set	@N = @@rowcount
print	'Updated AJ translations (trtStringNameTranslation - Parameter Type): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('az-L'),
			ptv.strParameterType_AZ,
			0
from		@ParameterTypeWithValues ptv
inner join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterType
			and br.idfsReferenceType = 19000071	-- Flexible Form Parameter Type
			and br.intRowStatus = 0
left join	@ParameterTypeWithValues ptv_first_value
on			ptv_first_value.idfsParameterType = ptv.idfsParameterType
			and (	@idfCustomizationPackage is null or ptv_first_value.idfCustomizationPackage is null 
					or	(	ptv_first_value.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv_first_value.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
			and IsNull(ptv_first_value.strParameterType_AZ, N'') <> N''
			and ((ptv_first_value.strCustomizationPackage < ptv.strCustomizationPackage) or (ptv_first_value.strCustomizationPackage = ptv.strCustomizationPackage and ptv_first_value.strParameterValue_EN < ptv.strParameterValue_EN))
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('az-L')
where		(	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
				or	(	ptv.idfCustomizationPackage is not null 
						and @idfCustomizationPackage is not null
						and ptv.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	IsNull(ptv.strParameterType_AZ, N'') <> N''
			and snt.idfsBaseReference is null
			and ptv_first_value.strParameterType_EN is null
set	@N = @@rowcount
print	'Inserted AJ translations (trtStringNameTranslation - Parameter Type): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = ptv.strParameterType_GG,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = 19000071	-- Flexible Form Parameter Type
			and br.intRowStatus = 0
inner join	@ParameterTypeWithValues ptv
on			ptv.idfsParameterType = br.idfsBaseReference
			and IsNull(ptv.strParameterType_GG, N'') <> N''
			and (	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
					or	(	ptv.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
left join	@ParameterTypeWithValues ptv_first_value
on			ptv_first_value.idfsParameterType = ptv.idfsParameterType
			and (	@idfCustomizationPackage is null or ptv_first_value.idfCustomizationPackage is null 
					or	(	ptv_first_value.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv_first_value.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
			and IsNull(ptv_first_value.strParameterType_GG, N'') <> N''
			and ((ptv_first_value.strCustomizationPackage < ptv.strCustomizationPackage) or (ptv_first_value.strCustomizationPackage = ptv.strCustomizationPackage and ptv_first_value.strParameterValue_EN < ptv.strParameterValue_EN))
where		snt.idfsLanguage = dbo.fnGetLanguageCode('ka')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(ptv.strParameterType_GG, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
			and ptv_first_value.strParameterType_EN is null
set	@N = @@rowcount
print	'Updated GG translations (trtStringNameTranslation - Parameter Type): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('ka'),
			ptv.strParameterType_GG,
			0
from		@ParameterTypeWithValues ptv
inner join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterType
			and br.idfsReferenceType = 19000071	-- Flexible Form Parameter Type
			and br.intRowStatus = 0
left join	@ParameterTypeWithValues ptv_first_value
on			ptv_first_value.idfsParameterType = ptv.idfsParameterType
			and (	@idfCustomizationPackage is null or ptv_first_value.idfCustomizationPackage is null 
					or	(	ptv_first_value.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv_first_value.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
			and IsNull(ptv_first_value.strParameterType_GG, N'') <> N''
			and ((ptv_first_value.strCustomizationPackage < ptv.strCustomizationPackage) or (ptv_first_value.strCustomizationPackage = ptv.strCustomizationPackage and ptv_first_value.strParameterValue_EN < ptv.strParameterValue_EN))
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('ka')
where		(	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
				or	(	ptv.idfCustomizationPackage is not null 
						and @idfCustomizationPackage is not null
						and ptv.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	IsNull(ptv.strParameterType_GG, N'') <> N''
			and ptv_first_value.strParameterType_EN is null
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted GG translations (trtStringNameTranslation - Parameter Type): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = ptv.strParameterType_KZ,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = 19000071	-- Flexible Form Parameter Type
			and br.intRowStatus = 0
inner join	@ParameterTypeWithValues ptv
on			ptv.idfsParameterType = br.idfsBaseReference
			and IsNull(ptv.strParameterType_KZ, N'') <> N''
			and (	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
					or	(	ptv.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
left join	@ParameterTypeWithValues ptv_first_value
on			ptv_first_value.idfsParameterType = ptv.idfsParameterType
			and (	@idfCustomizationPackage is null or ptv_first_value.idfCustomizationPackage is null 
					or	(	ptv_first_value.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv_first_value.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
			and IsNull(ptv_first_value.strParameterType_KZ, N'') <> N''
			and ((ptv_first_value.strCustomizationPackage < ptv.strCustomizationPackage) or (ptv_first_value.strCustomizationPackage = ptv.strCustomizationPackage and ptv_first_value.strParameterValue_EN < ptv.strParameterValue_EN))
where		snt.idfsLanguage = dbo.fnGetLanguageCode('kk')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(ptv.strParameterType_KZ, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
			and ptv_first_value.strParameterType_EN is null
set	@N = @@rowcount
print	'Updated KZ translations (trtStringNameTranslation - Parameter Type): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('kk'),
			ptv.strParameterType_KZ,
			0
from		@ParameterTypeWithValues ptv
inner join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterType
			and br.idfsReferenceType = 19000071	-- Flexible Form Parameter Type
			and br.intRowStatus = 0
left join	@ParameterTypeWithValues ptv_first_value
on			ptv_first_value.idfsParameterType = ptv.idfsParameterType
			and (	@idfCustomizationPackage is null or ptv_first_value.idfCustomizationPackage is null 
					or	(	ptv_first_value.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv_first_value.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
			and IsNull(ptv_first_value.strParameterType_KZ, N'') <> N''
			and ((ptv_first_value.strCustomizationPackage < ptv.strCustomizationPackage) or (ptv_first_value.strCustomizationPackage = ptv.strCustomizationPackage and ptv_first_value.strParameterValue_EN < ptv.strParameterValue_EN))
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('kk')
where		(	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
				or	(	ptv.idfCustomizationPackage is not null 
						and @idfCustomizationPackage is not null
						and ptv.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	IsNull(ptv.strParameterType_KZ, N'') <> N''
			and ptv_first_value.strParameterType_EN is null
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted KZ translations (trtStringNameTranslation - Parameter Type): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = ptv.strParameterType_RU,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = 19000071	-- Flexible Form Parameter Type
			and br.intRowStatus = 0
inner join	@ParameterTypeWithValues ptv
on			ptv.idfsParameterType = br.idfsBaseReference
			and IsNull(ptv.strParameterType_RU, N'') <> N''
			and (	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
					or	(	ptv.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
left join	@ParameterTypeWithValues ptv_first_value
on			ptv_first_value.idfsParameterType = ptv.idfsParameterType
			and (	@idfCustomizationPackage is null or ptv_first_value.idfCustomizationPackage is null 
					or	(	ptv_first_value.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv_first_value.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
			and IsNull(ptv_first_value.strParameterType_RU, N'') <> N''
			and ((ptv_first_value.strCustomizationPackage < ptv.strCustomizationPackage) or (ptv_first_value.strCustomizationPackage = ptv.strCustomizationPackage and ptv_first_value.strParameterValue_EN < ptv.strParameterValue_EN))
where		snt.idfsLanguage = dbo.fnGetLanguageCode('ru')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(ptv.strParameterType_RU, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
			and ptv_first_value.strParameterType_EN is null
set	@N = @@rowcount
print	'Updated RU translations (trtStringNameTranslation - Parameter Type): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('ru'),
			ptv.strParameterType_RU,
			0
from		@ParameterTypeWithValues ptv
inner join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterType
			and br.idfsReferenceType = 19000071	-- Flexible Form Parameter Type
			and br.intRowStatus = 0
left join	@ParameterTypeWithValues ptv_first_value
on			ptv_first_value.idfsParameterType = ptv.idfsParameterType
			and (	@idfCustomizationPackage is null or ptv_first_value.idfCustomizationPackage is null 
					or	(	ptv_first_value.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv_first_value.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
			and IsNull(ptv_first_value.strParameterType_RU, N'') <> N''
			and ((ptv_first_value.strCustomizationPackage < ptv.strCustomizationPackage) or (ptv_first_value.strCustomizationPackage = ptv.strCustomizationPackage and ptv_first_value.strParameterValue_EN < ptv.strParameterValue_EN))
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('ru')
where		(	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
				or	(	ptv.idfCustomizationPackage is not null 
						and @idfCustomizationPackage is not null
						and ptv.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	IsNull(ptv.strParameterType_RU, N'') <> N''
			and ptv_first_value.strParameterType_EN is null
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted RU translations (trtStringNameTranslation - Parameter Type): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = ptv.strParameterType_UA,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = 19000071	-- Flexible Form Parameter Type
			and br.intRowStatus = 0
inner join	@ParameterTypeWithValues ptv
on			ptv.idfsParameterType = br.idfsBaseReference
			and IsNull(ptv.strParameterType_UA, N'') <> N''
			and (	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
					or	(	ptv.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
left join	@ParameterTypeWithValues ptv_first_value
on			ptv_first_value.idfsParameterType = ptv.idfsParameterType
			and (	@idfCustomizationPackage is null or ptv_first_value.idfCustomizationPackage is null 
					or	(	ptv_first_value.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv_first_value.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
			and IsNull(ptv_first_value.strParameterType_UA, N'') <> N''
			and ((ptv_first_value.strCustomizationPackage < ptv.strCustomizationPackage) or (ptv_first_value.strCustomizationPackage = ptv.strCustomizationPackage and ptv_first_value.strParameterValue_EN < ptv.strParameterValue_EN))
where		snt.idfsLanguage = dbo.fnGetLanguageCode('uk')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(ptv.strParameterType_UA, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
			and ptv_first_value.strParameterType_EN is null
set	@N = @@rowcount
print	'Updated UA translations (trtStringNameTranslation - Parameter Type): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('uk'),
			ptv.strParameterType_UA,
			0
from		@ParameterTypeWithValues ptv
inner join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterType
			and br.idfsReferenceType = 19000071	-- Flexible Form Parameter Type
			and br.intRowStatus = 0
left join	@ParameterTypeWithValues ptv_first_value
on			ptv_first_value.idfsParameterType = ptv.idfsParameterType
			and (	@idfCustomizationPackage is null or ptv_first_value.idfCustomizationPackage is null 
					or	(	ptv_first_value.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv_first_value.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
			and IsNull(ptv_first_value.strParameterType_UA, N'') <> N''
			and ((ptv_first_value.strCustomizationPackage < ptv.strCustomizationPackage) or (ptv_first_value.strCustomizationPackage = ptv.strCustomizationPackage and ptv_first_value.strParameterValue_EN < ptv.strParameterValue_EN))
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('uk')
where		(	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
				or	(	ptv.idfCustomizationPackage is not null 
						and @idfCustomizationPackage is not null
						and ptv.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	IsNull(ptv.strParameterType_UA, N'') <> N''
			and ptv_first_value.strParameterType_EN is null
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted UA translations (trtStringNameTranslation - Parameter Type): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = ptv.strParameterType_IQ,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = 19000071	-- Flexible Form Parameter Type
			and br.intRowStatus = 0
inner join	@ParameterTypeWithValues ptv
on			ptv.idfsParameterType = br.idfsBaseReference
			and IsNull(ptv.strParameterType_IQ, N'') <> N''
			and (	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
					or	(	ptv.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
left join	@ParameterTypeWithValues ptv_first_value
on			ptv_first_value.idfsParameterType = ptv.idfsParameterType
			and (	@idfCustomizationPackage is null or ptv_first_value.idfCustomizationPackage is null 
					or	(	ptv_first_value.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv_first_value.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
			and IsNull(ptv_first_value.strParameterType_IQ, N'') <> N''
			and ((ptv_first_value.strCustomizationPackage < ptv.strCustomizationPackage) or (ptv_first_value.strCustomizationPackage = ptv.strCustomizationPackage and ptv_first_value.strParameterValue_EN < ptv.strParameterValue_EN))
where		snt.idfsLanguage = dbo.fnGetLanguageCode('ar')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(ptv.strParameterType_IQ, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
			and ptv_first_value.strParameterType_EN is null
set	@N = @@rowcount
print	'Updated IQ translations (trtStringNameTranslation - Parameter Type): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('ar'),
			ptv.strParameterType_IQ,
			0
from		@ParameterTypeWithValues ptv
inner join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterType
			and br.idfsReferenceType = 19000071	-- Flexible Form Parameter Type
			and br.intRowStatus = 0
left join	@ParameterTypeWithValues ptv_first_value
on			ptv_first_value.idfsParameterType = ptv.idfsParameterType
			and (	@idfCustomizationPackage is null or ptv_first_value.idfCustomizationPackage is null 
					or	(	ptv_first_value.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv_first_value.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
			and IsNull(ptv_first_value.strParameterType_IQ, N'') <> N''
			and ((ptv_first_value.strCustomizationPackage < ptv.strCustomizationPackage) or (ptv_first_value.strCustomizationPackage = ptv.strCustomizationPackage and ptv_first_value.strParameterValue_EN < ptv.strParameterValue_EN))
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('ar')
where		(	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
				or	(	ptv.idfCustomizationPackage is not null 
						and @idfCustomizationPackage is not null
						and ptv.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	IsNull(ptv.strParameterType_IQ, N'') <> N''
			and ptv_first_value.strParameterType_EN is null
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted IQ translations (trtStringNameTranslation - Parameter Type): ' + cast(@N as varchar(20))
print	''

update		snt
set			snt.strTextString = ptv.strParameterType_TH,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = 19000071	-- Flexible Form Parameter Type
			and br.intRowStatus = 0
inner join	@ParameterTypeWithValues ptv
on			ptv.idfsParameterType = br.idfsBaseReference
			and IsNull(ptv.strParameterType_TH, N'') <> N''
			and (	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
					or	(	ptv.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
left join	@ParameterTypeWithValues ptv_first_value
on			ptv_first_value.idfsParameterType = ptv.idfsParameterType
			and (	@idfCustomizationPackage is null or ptv_first_value.idfCustomizationPackage is null 
					or	(	ptv_first_value.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv_first_value.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
			and IsNull(ptv_first_value.strParameterType_TH, N'') <> N''
			and ((ptv_first_value.strCustomizationPackage < ptv.strCustomizationPackage) or (ptv_first_value.strCustomizationPackage = ptv.strCustomizationPackage and ptv_first_value.strParameterValue_EN < ptv.strParameterValue_EN))
where		snt.idfsLanguage = dbo.fnGetLanguageCode('th')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(ptv.strParameterType_TH, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
			and ptv_first_value.strParameterType_EN is null
set	@N = @@rowcount
print	'Updated TH translations (trtStringNameTranslation - Parameter Type): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('th'),
			ptv.strParameterType_TH,
			0
from		@ParameterTypeWithValues ptv
inner join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterType
			and br.idfsReferenceType = 19000071	-- Flexible Form Parameter Type
			and br.intRowStatus = 0
left join	@ParameterTypeWithValues ptv_first_value
on			ptv_first_value.idfsParameterType = ptv.idfsParameterType
			and (	@idfCustomizationPackage is null or ptv_first_value.idfCustomizationPackage is null 
					or	(	ptv_first_value.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv_first_value.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
			and IsNull(ptv_first_value.strParameterType_TH, N'') <> N''
			and ((ptv_first_value.strCustomizationPackage < ptv.strCustomizationPackage) or (ptv_first_value.strCustomizationPackage = ptv.strCustomizationPackage and ptv_first_value.strParameterValue_EN < ptv.strParameterValue_EN))
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('th')
where		(	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
				or	(	ptv.idfCustomizationPackage is not null 
						and @idfCustomizationPackage is not null
						and ptv.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	IsNull(ptv.strParameterType_TH, N'') <> N''
			and ptv_first_value.strParameterType_EN is null
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted TH translations (trtStringNameTranslation - Parameter Type): ' + cast(@N as varchar(20))
print	''

-- Parameter Value
update		snt
set			snt.strTextString = ptv.strParameterValue_EN,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = 19000069	-- Flexible Form Parameter Value
			and br.intRowStatus = 0
inner join	@ParameterTypeWithValues ptv
on			ptv.idfsParameterValue = br.idfsBaseReference
			and (	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
					or	(	ptv.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
where		snt.idfsLanguage = dbo.fnGetLanguageCode('en')
			and	(	IsNull(snt.strTextString, N'') <> ptv.strParameterValue_EN collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
set	@N = @@rowcount
print	'Updated EN translations (trtStringNameTranslation - Parameter Value): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('en'),
			ptv.strParameterValue_EN,
			0
from		@ParameterTypeWithValues ptv
inner join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterValue
			and br.idfsReferenceType = 19000069	-- Flexible Form Parameter Value
			and br.intRowStatus = 0
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('en')
where		(	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
				or	(	ptv.idfCustomizationPackage is not null 
						and @idfCustomizationPackage is not null
						and ptv.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	snt.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted EN translations (trtStringNameTranslation - Parameter Value): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = ptv.strParameterValue_AM,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = 19000069	-- Flexible Form Parameter Value
			and br.intRowStatus = 0
inner join	@ParameterTypeWithValues ptv
on			ptv.idfsParameterValue = br.idfsBaseReference
			and IsNull(ptv.strParameterValue_AM, N'') <> N''
			and (	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
					or	(	ptv.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
where		snt.idfsLanguage = dbo.fnGetLanguageCode('hy')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(ptv.strParameterValue_AM, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
set	@N = @@rowcount
print	'Updated AM translations (trtStringNameTranslation - Parameter Value): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('hy'),
			ptv.strParameterValue_AM,
			0
from		@ParameterTypeWithValues ptv
inner join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterValue
			and br.idfsReferenceType = 19000069	-- Flexible Form Parameter Value
			and br.intRowStatus = 0
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('hy')
where		(	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
				or	(	ptv.idfCustomizationPackage is not null 
						and @idfCustomizationPackage is not null
						and ptv.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	IsNull(ptv.strParameterValue_AM, N'') <> N''
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted AM translations (trtStringNameTranslation - Parameter Value): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = ptv.strParameterValue_AZ,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = 19000069	-- Flexible Form Parameter Value
			and br.intRowStatus = 0
inner join	@ParameterTypeWithValues ptv
on			ptv.idfsParameterValue = br.idfsBaseReference
			and IsNull(ptv.strParameterValue_AZ, N'') <> N''
			and (	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
					or	(	ptv.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
where		snt.idfsLanguage = dbo.fnGetLanguageCode('az-L')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(ptv.strParameterValue_AZ, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
set	@N = @@rowcount
print	'Updated AJ translations (trtStringNameTranslation - Parameter Value): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('az-L'),
			ptv.strParameterValue_AZ,
			0
from		@ParameterTypeWithValues ptv
inner join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterValue
			and br.idfsReferenceType = 19000069	-- Flexible Form Parameter Value
			and br.intRowStatus = 0
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('az-L')
where		(	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
				or	(	ptv.idfCustomizationPackage is not null 
						and @idfCustomizationPackage is not null
						and ptv.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	IsNull(ptv.strParameterValue_AZ, N'') <> N''
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted AJ translations (trtStringNameTranslation - Parameter Value): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = ptv.strParameterValue_GG,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = 19000069	-- Flexible Form Parameter Value
			and br.intRowStatus = 0
inner join	@ParameterTypeWithValues ptv
on			ptv.idfsParameterValue = br.idfsBaseReference
			and IsNull(ptv.strParameterValue_GG, N'') <> N''
			and (	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
					or	(	ptv.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
where		snt.idfsLanguage = dbo.fnGetLanguageCode('ka')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(ptv.strParameterValue_GG, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
set	@N = @@rowcount
print	'Updated GG translations (trtStringNameTranslation - Parameter Value): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('ka'),
			ptv.strParameterValue_GG,
			0
from		@ParameterTypeWithValues ptv
inner join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterValue
			and br.idfsReferenceType = 19000069	-- Flexible Form Parameter Value
			and br.intRowStatus = 0
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('ka')
where		(	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
				or	(	ptv.idfCustomizationPackage is not null 
						and @idfCustomizationPackage is not null
						and ptv.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	IsNull(ptv.strParameterValue_GG, N'') <> N''
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted GG translations (trtStringNameTranslation - Parameter Value): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = ptv.strParameterValue_KZ,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = 19000069	-- Flexible Form Parameter Value
			and br.intRowStatus = 0
inner join	@ParameterTypeWithValues ptv
on			ptv.idfsParameterValue = br.idfsBaseReference
			and IsNull(ptv.strParameterValue_KZ, N'') <> N''
			and (	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
					or	(	ptv.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
where		snt.idfsLanguage = dbo.fnGetLanguageCode('kk')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(ptv.strParameterValue_KZ, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
set	@N = @@rowcount
print	'Updated KZ translations (trtStringNameTranslation - Parameter Value): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('kk'),
			ptv.strParameterValue_KZ,
			0
from		@ParameterTypeWithValues ptv
inner join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterValue
			and br.idfsReferenceType = 19000069	-- Flexible Form Parameter Value
			and br.intRowStatus = 0
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('kk')
where		(	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
				or	(	ptv.idfCustomizationPackage is not null 
						and @idfCustomizationPackage is not null
						and ptv.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	IsNull(ptv.strParameterValue_KZ, N'') <> N''
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted KZ translations (trtStringNameTranslation - Parameter Value): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = ptv.strParameterValue_RU,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = 19000069	-- Flexible Form Parameter Value
			and br.intRowStatus = 0
inner join	@ParameterTypeWithValues ptv
on			ptv.idfsParameterValue = br.idfsBaseReference
			and IsNull(ptv.strParameterValue_RU, N'') <> N''
			and (	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
					or	(	ptv.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
where		snt.idfsLanguage = dbo.fnGetLanguageCode('ru')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(ptv.strParameterValue_RU, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
set	@N = @@rowcount
print	'Updated RU translations (trtStringNameTranslation - Parameter Value): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('ru'),
			ptv.strParameterValue_RU,
			0
from		@ParameterTypeWithValues ptv
inner join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterValue
			and br.idfsReferenceType = 19000069	-- Flexible Form Parameter Value
			and br.intRowStatus = 0
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('ru')
where		(	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
				or	(	ptv.idfCustomizationPackage is not null 
						and @idfCustomizationPackage is not null
						and ptv.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	IsNull(ptv.strParameterValue_RU, N'') <> N''
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted RU translations (trtStringNameTranslation - Parameter Value): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = ptv.strParameterValue_UA,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = 19000069	-- Flexible Form Parameter Value
			and br.intRowStatus = 0
inner join	@ParameterTypeWithValues ptv
on			ptv.idfsParameterValue = br.idfsBaseReference
			and IsNull(ptv.strParameterValue_UA, N'') <> N''
			and (	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
					or	(	ptv.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
where		snt.idfsLanguage = dbo.fnGetLanguageCode('uk')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(ptv.strParameterValue_UA, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
set	@N = @@rowcount
print	'Updated UA translations (trtStringNameTranslation - Parameter Value): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('uk'),
			ptv.strParameterValue_UA,
			0
from		@ParameterTypeWithValues ptv
inner join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterValue
			and br.idfsReferenceType = 19000069	-- Flexible Form Parameter Value
			and br.intRowStatus = 0
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('uk')
where		(	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
				or	(	ptv.idfCustomizationPackage is not null 
						and @idfCustomizationPackage is not null
						and ptv.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	IsNull(ptv.strParameterValue_UA, N'') <> N''
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted UA translations (trtStringNameTranslation - Parameter Value): ' + cast(@N as varchar(20))

update		snt
set			snt.strTextString = ptv.strParameterValue_IQ,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = 19000069	-- Flexible Form Parameter Value
			and br.intRowStatus = 0
inner join	@ParameterTypeWithValues ptv
on			ptv.idfsParameterValue = br.idfsBaseReference
			and IsNull(ptv.strParameterValue_IQ, N'') <> N''
			and (	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
					or	(	ptv.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
where		snt.idfsLanguage = dbo.fnGetLanguageCode('ar')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(ptv.strParameterValue_IQ, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
set	@N = @@rowcount
print	'Updated IQ translations (trtStringNameTranslation - Parameter Value): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('ar'),
			ptv.strParameterValue_IQ,
			0
from		@ParameterTypeWithValues ptv
inner join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterValue
			and br.idfsReferenceType = 19000069	-- Flexible Form Parameter Value
			and br.intRowStatus = 0
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('ar')
where		(	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
				or	(	ptv.idfCustomizationPackage is not null 
						and @idfCustomizationPackage is not null
						and ptv.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	IsNull(ptv.strParameterValue_IQ, N'') <> N''
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted IQ translations (trtStringNameTranslation - Parameter Value): ' + cast(@N as varchar(20))
print	''

update		snt
set			snt.strTextString = ptv.strParameterValue_TH,
			snt.intRowStatus = 0
from		trtStringNameTranslation snt
inner join	trtBaseReference br
on			br.idfsBaseReference = snt.idfsBaseReference
			and br.idfsReferenceType = 19000069	-- Flexible Form Parameter Value
			and br.intRowStatus = 0
inner join	@ParameterTypeWithValues ptv
on			ptv.idfsParameterValue = br.idfsBaseReference
			and IsNull(ptv.strParameterValue_TH, N'') <> N''
			and (	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
					or	(	ptv.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
where		snt.idfsLanguage = dbo.fnGetLanguageCode('th')
			and	(	IsNull(snt.strTextString, N'') <> IsNull(ptv.strParameterValue_TH, N'') collate Cyrillic_General_CI_AS
					or	snt.intRowStatus <> 0
				)
set	@N = @@rowcount
print	'Updated TH translations (trtStringNameTranslation - Parameter Value): ' + cast(@N as varchar(20))

insert into	trtStringNameTranslation
(	idfsBaseReference,
	idfsLanguage,
	strTextString,
	intRowStatus
)
select		br.idfsBaseReference,
			dbo.fnGetLanguageCode('th'),
			ptv.strParameterValue_TH,
			0
from		@ParameterTypeWithValues ptv
inner join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterValue
			and br.idfsReferenceType = 19000069	-- Flexible Form Parameter Value
			and br.intRowStatus = 0
left join	trtStringNameTranslation snt
on			snt.idfsBaseReference = br.idfsBaseReference
			and snt.idfsLanguage = dbo.fnGetLanguageCode('th')
where		(	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
				or	(	ptv.idfCustomizationPackage is not null 
						and @idfCustomizationPackage is not null
						and ptv.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	IsNull(ptv.strParameterValue_TH, N'') <> N''
			and snt.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted TH translations (trtStringNameTranslation - Parameter Value): ' + cast(@N as varchar(20))
print	''

-- Links to countries
-- Parameter Type
if	@PerformDeletions > 0
begin

	delete		brc
	from		trtBaseReferenceToCP brc
	inner join	trtBaseReference br
	on			br.idfsBaseReference = brc.idfsBaseReference
				and br.idfsReferenceType = 19000071	-- Flexible Form Parameter Type
				and br.intRowStatus = 0
	inner join	@ParameterTypeWithValues ptv
	on			ptv.idfsParameterType = br.idfsBaseReference
	left join	@ParameterTypeWithValues ptv_first
	on			ptv_first.idfsParameterType = ptv.idfsParameterType
				and (	IsNull(ptv_first.idfCustomizationPackage, 0) < IsNull(ptv.idfCustomizationPackage, 0)
						or	(	IsNull(ptv_first.idfCustomizationPackage, 0) = IsNull(ptv.idfCustomizationPackage, 0)
								and ptv_first.strParameterValue_EN < ptv.strParameterValue_EN
							)
					)
	left join	@ParameterTypeWithValues ptv_cp
	on			ptv_cp.idfsParameterType = br.idfsBaseReference
				and IsNull(ptv_cp.idfCustomizationPackage, 0) = brc.idfCustomizationPackage
	where		ptv_first.strParameterType_EN is null
				and ptv_cp.strParameterType_EN is null
	set	@N = @@rowcount
	print	'Deleted links to countries (trtBaseReferenceToCP - Parameter Type): ' + cast(@N as varchar(20))
	
end

update		brc
set			brc.intHACode = br.intHACode,
			brc.intOrder = IsNull(br.intOrder, 0)
from		trtBaseReferenceToCP brc
inner join	trtBaseReference br
on			br.idfsBaseReference = brc.idfsBaseReference
			and br.idfsReferenceType = 19000071	-- Flexible Form Parameter Type
			and br.intRowStatus = 0
inner join	@ParameterTypeWithValues ptv
on			ptv.idfsParameterType = br.idfsBaseReference
			and IsNull(ptv.idfCustomizationPackage, 0) = brc.idfCustomizationPackage
left join	@ParameterTypeWithValues ptv_first_value
on			ptv_first_value.idfsParameterType = ptv.idfsParameterType
			and IsNull(ptv_first_value.idfCustomizationPackage, 0) = brc.idfCustomizationPackage
			and ((ptv_first_value.strCustomizationPackage < ptv.strCustomizationPackage) or (ptv_first_value.strCustomizationPackage = ptv.strCustomizationPackage and ptv_first_value.strParameterValue_EN < ptv.strParameterValue_EN))
where		(	IsNull(brc.intHACode, -1) <> IsNull(br.intHACode, -1)
				or	IsNull(brc.intOrder, -100000) <> IsNull(br.intOrder, 0)
			)
			and ptv_first_value.strParameterType_EN is null
set	@N = @@rowcount
print	'Updated links to countries (trtBaseReferenceToCP - Parameter Type): ' + cast(@N as varchar(20))

insert into	trtBaseReferenceToCP
(	idfsBaseReference,
	idfCustomizationPackage,
	intHACode,
	intOrder
)
select		br.idfsBaseReference,
			ptv.idfCustomizationPackage,
			br.intHACode,
			IsNull(br.intOrder, 0)
from		@ParameterTypeWithValues ptv
inner join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterType
			and br.idfsReferenceType = 19000071	-- Flexible Form Parameter Type
			and br.intRowStatus = 0
left join	@ParameterTypeWithValues ptv_first_value
on			ptv_first_value.idfsParameterType = ptv.idfsParameterType
			and IsNull(ptv_first_value.idfCustomizationPackage, 0) = ptv.idfCustomizationPackage
			and ((ptv_first_value.strCustomizationPackage < ptv.strCustomizationPackage) or (ptv_first_value.strCustomizationPackage = ptv.strCustomizationPackage and ptv_first_value.strParameterValue_EN < ptv.strParameterValue_EN))
left join	trtBaseReferenceToCP brc
on			brc.idfsBaseReference = ptv.idfsParameterType
			and brc.idfCustomizationPackage = ptv.idfCustomizationPackage
where		ptv.idfCustomizationPackage is not null
			and ptv_first_value.strParameterType_EN is null
			and brc.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted links to countries (trtBaseReferenceToCP - Parameter Type): ' + cast(@N as varchar(20))

-- idfsParameterValue
if	@PerformDeletions > 0
begin

	delete		brc
	from		trtBaseReferenceToCP brc
	inner join	trtBaseReference br
	on			br.idfsBaseReference = brc.idfsBaseReference
				and br.idfsReferenceType = 19000069	-- Flexible Form Parameter Value
				and br.intRowStatus = 0
	inner join	@ParameterTypeWithValues ptv
	on			ptv.idfsParameterValue = br.idfsBaseReference
	left join	@ParameterTypeWithValues ptv_cp
	on			ptv_cp.idfsParameterValue = br.idfsBaseReference
				and IsNull(ptv_cp.idfCustomizationPackage, 0) = brc.idfCustomizationPackage
	where		ptv_cp.strParameterType_EN is null
	set	@N = @@rowcount
	print	'Deleted links to countries (trtBaseReferenceToCP - Parameter Value): ' + cast(@N as varchar(20))
	
end

update		brc
set			brc.intHACode = br.intHACode,
			brc.intOrder = IsNull(br.intOrder, 0)
from		trtBaseReferenceToCP brc
inner join	trtBaseReference br
on			br.idfsBaseReference = brc.idfsBaseReference
			and br.idfsReferenceType = 19000069	-- Flexible Form Parameter Value
			and br.intRowStatus = 0
inner join	@ParameterTypeWithValues ptv
on			ptv.idfsParameterValue = br.idfsBaseReference
			and IsNull(ptv.idfCustomizationPackage, 0) = brc.idfCustomizationPackage
where		(	IsNull(brc.intHACode, -1) <> IsNull(br.intHACode, -1)
				or	IsNull(brc.intOrder, -100000) <> IsNull(br.intOrder, 0)
			)
			set	@N = @@rowcount
print	'Updated links to countries (trtBaseReferenceToCP - Parameter Value): ' + cast(@N as varchar(20))

insert into	trtBaseReferenceToCP
(	idfsBaseReference,
	idfCustomizationPackage,
	intHACode,
	intOrder
)
select		br.idfsBaseReference,
			ptv.idfCustomizationPackage,
			br.intHACode,
			IsNull(br.intOrder, 0)
from		@ParameterTypeWithValues ptv
inner join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterValue
			and br.idfsReferenceType = 19000069	-- Flexible Form Parameter Value
			and br.intRowStatus = 0
left join	trtBaseReferenceToCP brc
on			brc.idfsBaseReference = ptv.idfsParameterValue
			and brc.idfCustomizationPackage = ptv.idfCustomizationPackage
where		ptv.idfCustomizationPackage is not null
			and brc.idfsBaseReference is null
set	@N = @@rowcount
print	'Inserted links to countries (trtBaseReferenceToCP - Parameter Value): ' + cast(@N as varchar(20))
print	''

-- Update & insert for child table of trtBaseReference
-- Parameter Type
update		pt
set			pt.idfsReferenceType = ptv.idfsReferenceType,
			pt.intRowStatus = 0
from		ffParameterType pt
inner join	trtBaseReference br
on			br.idfsBaseReference = pt.idfsParameterType
			and br.idfsReferenceType = 19000071	-- Flexible Form Parameter Type
			and br.intRowStatus = 0
inner join	@ParameterTypeWithValues ptv
on			ptv.idfsParameterType = br.idfsBaseReference
			and (	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
					or	(	ptv.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
left join	@ParameterTypeWithValues ptv_first_value
on			ptv_first_value.idfsParameterType = ptv.idfsParameterType
			and (	@idfCustomizationPackage is null or ptv_first_value.idfCustomizationPackage is null 
					or	(	ptv_first_value.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv_first_value.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
			and ((ptv_first_value.strCustomizationPackage < ptv.strCustomizationPackage) or (ptv_first_value.strCustomizationPackage = ptv.strCustomizationPackage and ptv_first_value.strParameterValue_EN < ptv.strParameterValue_EN))
where		(	IsNull(pt.idfsReferenceType, -100000) <> IsNull(ptv.idfsReferenceType, -100000)
				or	pt.intRowStatus <> 0
			)
			and ptv_first_value.strParameterType_EN is null
set	@N = @@rowcount
print	'Updated parameter types (ffParameterType): ' + cast(@N as varchar(20))

insert into	ffParameterType
(	idfsParameterType,
	idfsReferenceType,
	intRowStatus
)
select		br.idfsBaseReference,
			ptv.idfsReferenceType,
			0
from		@ParameterTypeWithValues ptv
inner join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterType
			and br.idfsReferenceType = 19000071	-- Flexible Form Parameter Type
			and br.intRowStatus = 0
left join	@ParameterTypeWithValues ptv_first_value
on			ptv_first_value.idfsParameterType = ptv.idfsParameterType
			and (	@idfCustomizationPackage is null or ptv_first_value.idfCustomizationPackage is null 
					or	(	ptv_first_value.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv_first_value.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
			and ((ptv_first_value.strCustomizationPackage < ptv.strCustomizationPackage) or (ptv_first_value.strCustomizationPackage = ptv.strCustomizationPackage and ptv_first_value.strParameterValue_EN < ptv.strParameterValue_EN))
left join	ffParameterType pt
on			pt.idfsParameterType = ptv.idfsParameterType
where		(	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
				or	(	ptv.idfCustomizationPackage is not null 
						and @idfCustomizationPackage is not null
						and ptv.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and ptv_first_value.strParameterType_EN is null
			and pt.idfsParameterType is null
set	@N = @@rowcount
print	'Inserted parameter types (ffParameterType): ' + cast(@N as varchar(20))
print	''

-- Parameter Value
update		pfpv
set			pfpv.idfsParameterType = pt.idfsParameterType,
			pfpv.intRowStatus = 0
from		ffParameterFixedPresetValue pfpv
inner join	trtBaseReference br
on			br.idfsBaseReference = pfpv.idfsParameterFixedPresetValue
			and br.idfsReferenceType = 19000069	-- Flexible Form Parameter Value
			and br.intRowStatus = 0
inner join	@ParameterTypeWithValues ptv
on			ptv.idfsParameterValue = br.idfsBaseReference
			and (	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
					or	(	ptv.idfCustomizationPackage is not null 
							and @idfCustomizationPackage is not null
							and ptv.idfCustomizationPackage = @idfCustomizationPackage
						)
				)
inner join	ffParameterType pt
on			pt.idfsParameterType = ptv.idfsParameterType
			and pt.intRowStatus = 0
where		(	IsNull(pfpv.idfsParameterType, -100000) <> pt.idfsParameterType
				or	pfpv.intRowStatus <> 0
			)
set	@N = @@rowcount
print	'Updated parameter values (ffParameterFixedPresetValue): ' + cast(@N as varchar(20))

insert into	ffParameterFixedPresetValue
(	idfsParameterFixedPresetValue,
	idfsParameterType,
	intRowStatus
)
select		br.idfsBaseReference,
			pt.idfsParameterType,
			0
from		@ParameterTypeWithValues ptv
inner join	trtBaseReference br
on			br.idfsBaseReference = ptv.idfsParameterValue
			and br.idfsReferenceType = 19000069	-- Flexible Form Parameter Value
			and br.intRowStatus = 0
inner join	ffParameterType pt
on			pt.idfsParameterType = ptv.idfsParameterType
			and pt.intRowStatus = 0
left join	ffParameterFixedPresetValue pfpv
on			pfpv.idfsParameterFixedPresetValue = ptv.idfsParameterValue
where		(	@idfCustomizationPackage is null or ptv.idfCustomizationPackage is null 
				or	(	ptv.idfCustomizationPackage is not null 
						and @idfCustomizationPackage is not null
						and ptv.idfCustomizationPackage = @idfCustomizationPackage
					)
			)
			and	pfpv.idfsParameterFixedPresetValue is null
set	@N = @@rowcount
print	'Inserted parameter values (ffParameterFixedPresetValue): ' + cast(@N as varchar(20))
print	''

/*
-- Generate script to fill reference table
print	''
print	''
print	'Script for filling @ParameterTypeWithValues with correct reference values'
print	''

select		N'
insert into @ParameterTypeWithValues (
idfsParameterType, strParameterType_EN, strParameterType_AM, strParameterType_AZ, strParameterType_GG, strParameterType_KZ, strParameterType_RU, strParameterType_IQ, strParameterType_UA, strParameterType_TH,
idfsParameterValue, strParameterValue_EN, strParameterValue_AM, strParameterValue_AZ, strParameterValue_GG, strParameterValue_KZ, strParameterValue_RU, strParameterValue_IQ, strParameterValue_UA, strParameterValue_TH,
strValueOrder, intValueOrder, strValueReferenceType, idfsReferenceType,
strCustomizationPackage, idfCustomizationPackage)
values	(' + cast(br_type.idfsBaseReference as varchar(20)) + N', ' +
IsNull(N'N''' + replace(IsNull(snt_type_EN.strTextString, br_type.strDefault), N'''', N'''''') + N'''', N'N''') + N', ' + 
IsNull(N'N''' + replace(snt_type_AM.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_type_AZ.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_type_GG.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_type_KZ.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_type_RU.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_type_IQ.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_type_UA.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_type_TH.strTextString, N'''', N'''''') + N'''', N'null') + N', 
' + IsNull(cast(br_value.idfsBaseReference as varchar(20)), N'null') + N', ' +
IsNull(N'N''' + replace(IsNull(snt_value_EN.strTextString, IsNull(br_value.strDefault, N'No values')), N'''', N'''''') + N'''', N'N''') + N', ' + 
IsNull(N'N''' + replace(snt_value_AM.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_value_AZ.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_value_GG.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_value_KZ.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_value_RU.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_value_IQ.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_value_UA.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(N'N''' + replace(snt_value_TH.strTextString, N'''', N'''''') + N'''', N'null') + N', ' +
N'N''' + cast(IsNull(br_value.intOrder, 0) as varchar(20)) + N''', 
' + cast(IsNull(br_value.intOrder, 0) as varchar(20)) + N', ' +
IsNull(N'N''' + replace(r_rt.[name], N'''', N'''''') + N'''', N'null') + N', ' +
IsNull(cast(rt.idfsReferenceType as varchar(20)), N'null') + N', 
' + IsNull(N'N''' + replace(c.strCustomizationPackageName, N'''', N'''''') + N'''', N'N''ALL''') + N', ' + 
IsNull(cast(brc.idfCustomizationPackage as varchar(20)), N'null') + N')
'

from
-- Base References
			ffParameterType pt
inner join	trtBaseReference br_type
on			br_type.idfsBaseReference = pt.idfsParameterType
			and br_type.idfsReferenceType = 19000071		-- Flexible Form Parameter Type
			and br_type.intRowStatus = 0
left join	ffParameterFixedPresetValue pfpv
	inner join	trtBaseReference br_value
	on			br_value.idfsBaseReference = pfpv.idfsParameterFixedPresetValue
				and br_value.idfsReferenceType = 19000069	-- Flexible Form Parameter Value
				and br_value.intRowStatus = 0
on			pfpv.idfsParameterType = pt.idfsParameterType
			and pfpv.intRowStatus = 0
left join	@ParameterTypeWithValues ptv
on			ptv.idfsParameterType = br_type.idfsBaseReference
			and IsNull(ptv.idfsParameterValue, -100000) = IsNull(br_value.idfsBaseReference, -100000)

-- Translations
-- Parameter Type
left join	trtStringNameTranslation snt_type_EN
on			snt_type_EN.idfsBaseReference = br_type.idfsBaseReference
			and snt_type_EN.idfsLanguage = dbo.fnGetLanguageCode('en')
			and snt_type_EN.intRowStatus = 0
left join	trtStringNameTranslation snt_type_AM
on			snt_type_AM.idfsBaseReference = br_type.idfsBaseReference
			and snt_type_AM.idfsLanguage = dbo.fnGetLanguageCode('hy')
			and snt_type_AM.intRowStatus = 0
left join	trtStringNameTranslation snt_type_AZ
on			snt_type_AZ.idfsBaseReference = br_type.idfsBaseReference
			and snt_type_AZ.idfsLanguage = dbo.fnGetLanguageCode('az-L')
			and snt_type_AZ.intRowStatus = 0
left join	trtStringNameTranslation snt_type_GG
on			snt_type_GG.idfsBaseReference = br_type.idfsBaseReference
			and snt_type_GG.idfsLanguage = dbo.fnGetLanguageCode('ka')
			and snt_type_GG.intRowStatus = 0
left join	trtStringNameTranslation snt_type_KZ
on			snt_type_KZ.idfsBaseReference = br_type.idfsBaseReference
			and snt_type_KZ.idfsLanguage = dbo.fnGetLanguageCode('kk')
			and snt_type_KZ.intRowStatus = 0
left join	trtStringNameTranslation snt_type_RU
on			snt_type_RU.idfsBaseReference = br_type.idfsBaseReference
			and snt_type_RU.idfsLanguage = dbo.fnGetLanguageCode('ru')
			and snt_type_RU.intRowStatus = 0
left join	trtStringNameTranslation snt_type_IQ
on			snt_type_IQ.idfsBaseReference = br_type.idfsBaseReference
			and snt_type_IQ.idfsLanguage = dbo.fnGetLanguageCode('ar')
			and snt_type_IQ.intRowStatus = 0
left join	trtStringNameTranslation snt_type_UA
on			snt_type_UA.idfsBaseReference = br_type.idfsBaseReference
			and snt_type_UA.idfsLanguage = dbo.fnGetLanguageCode('uk')
			and snt_type_UA.intRowStatus = 0
left join	trtStringNameTranslation snt_type_TH
on			snt_type_TH.idfsBaseReference = br_type.idfsBaseReference
			and snt_type_TH.idfsLanguage = dbo.fnGetLanguageCode('th')
			and snt_type_TH.intRowStatus = 0

-- Parameter Value
left join	trtStringNameTranslation snt_value_EN
on			snt_value_EN.idfsBaseReference = br_value.idfsBaseReference
			and snt_value_EN.idfsLanguage = dbo.fnGetLanguageCode('en')
			and snt_value_EN.intRowStatus = 0
left join	trtStringNameTranslation snt_value_AM
on			snt_value_AM.idfsBaseReference = br_value.idfsBaseReference
			and snt_value_AM.idfsLanguage = dbo.fnGetLanguageCode('hy')
			and snt_value_AM.intRowStatus = 0
left join	trtStringNameTranslation snt_value_AZ
on			snt_value_AZ.idfsBaseReference = br_value.idfsBaseReference
			and snt_value_AZ.idfsLanguage = dbo.fnGetLanguageCode('az-L')
			and snt_value_AZ.intRowStatus = 0
left join	trtStringNameTranslation snt_value_GG
on			snt_value_GG.idfsBaseReference = br_value.idfsBaseReference
			and snt_value_GG.idfsLanguage = dbo.fnGetLanguageCode('ka')
			and snt_value_GG.intRowStatus = 0
left join	trtStringNameTranslation snt_value_KZ
on			snt_value_KZ.idfsBaseReference = br_value.idfsBaseReference
			and snt_value_KZ.idfsLanguage = dbo.fnGetLanguageCode('kk')
			and snt_value_KZ.intRowStatus = 0
left join	trtStringNameTranslation snt_value_RU
on			snt_value_RU.idfsBaseReference = br_value.idfsBaseReference
			and snt_value_RU.idfsLanguage = dbo.fnGetLanguageCode('ru')
			and snt_value_RU.intRowStatus = 0
left join	trtStringNameTranslation snt_value_IQ
on			snt_value_IQ.idfsBaseReference = br_value.idfsBaseReference
			and snt_value_IQ.idfsLanguage = dbo.fnGetLanguageCode('ar')
			and snt_value_IQ.intRowStatus = 0
left join	trtStringNameTranslation snt_value_UA
on			snt_value_UA.idfsBaseReference = br_value.idfsBaseReference
			and snt_value_UA.idfsLanguage = dbo.fnGetLanguageCode('uk')
			and snt_value_UA.intRowStatus = 0
left join	trtStringNameTranslation snt_value_TH
on			snt_value_TH.idfsBaseReference = br_value.idfsBaseReference
			and snt_value_TH.idfsLanguage = dbo.fnGetLanguageCode('th')
			and snt_value_TH.intRowStatus = 0

-- Links to countries
left join	trtBaseReferenceToCP brc
	inner join	tstCustomizationPackage c
	on			c.idfCustomizationPackage = brc.idfCustomizationPackage
on			brc.idfsBaseReference = br_type.idfsBaseReference
			and brc.idfCustomizationPackage = IsNull(@idfCustomizationPackage, 0)

-- Value Reference Type
left join	trtReferenceType rt
	inner join	fnReference('en', 19000076)	r_rt	-- Reference Type Name
	on			r_rt.idfsReference = rt.idfsReferenceType
on			rt.idfsReferenceType = pt.idfsReferenceType
			and rt.intRowStatus = 0
			
where		(	@idfCustomizationPackage is null
				or	(	@idfCustomizationPackage is not null
						and (	brc.idfsBaseReference is not null
								or	(	brc.idfsBaseReference is null
										and not exists	(
													select		*
													from		trtBaseReferenceToCP brc_other
													inner join	tstCustomizationPackage c_other
													on			c_other.idfCustomizationPackage = brc_other.idfCustomizationPackage
													where		brc_other.idfsBaseReference = br_type.idfsBaseReference
														)
									)
							)
					)
			)
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
