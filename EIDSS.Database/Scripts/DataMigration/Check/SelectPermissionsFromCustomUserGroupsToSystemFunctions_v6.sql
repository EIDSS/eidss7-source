-- This script selects matrix with user group permissions to system functions.
-- Script should be executed on the database of version 6.1, which contains user group permissions that should be selected.
--
-- Parameters:
--
-- @NumberOfLanguages 
-- (number of languages: 1 = only English, 2 = English + one national language, 3 = English + two national languages).
--
-- @LangID (national language), and @SecLangID (second national language) should be changed 
-- in the section "Set parameters' values" to required values.
--
-- If second national language is not applicable for your country, you should set the same values to both parameters.
-- 'ar' - Arabic (Iraqi) language
-- 'az-L' - Azerbaijani language
-- 'hy' - Armenian language
-- 'ka' - Georgian language
-- 'kk' - Kazakh Language
-- 'ru' - Russian language
-- 'th' - Thai language
-- 'uk' - Ukrainian language

use [Falcon]

set nocount on

-- Variables
DECLARE @LangID NVARCHAR (36)
DECLARE @SecLangID NVARCHAR(36)
DECLARE @NumberOfLanguages int 

-- Set parameters' values
set	@LangID = 'ka'
set	@SecLangID = 'az-L'
set @NumberOfLanguages = 1 -- 1 = only English, 2 = English + one national language, 3 = English + two national languages


-- Determine country
declare	@idfCustomizationPackage	bigint
set	@idfCustomizationPackage = null

select		@idfCustomizationPackage = CAST(gso.strValue as bigint)
from		tstGlobalSiteOptions gso
where		gso.strName = N'CustomizationPackage'
			and ISNUMERIC(gso.strValue) = 1

if	@idfCustomizationPackage is null
select		@idfCustomizationPackage = cp.idfCustomizationPackage
from		tstLocalSiteOptions lso
inner join	tstSite s
on			(cast(s.idfsSite as nvarchar(200)) = lso.strValue collate database_default)
			and s.intRowStatus = 0
inner join	tstCustomizationPackage cp
on			cp.idfCustomizationPackage = s.idfCustomizationPackage
inner join	gisCountry c
on			c.idfsCountry = cp.idfsCountry
			and c.intRowStatus = 0
inner join	gisBaseReference br_c
on			br_c.idfsGISBaseReference = c.idfsCountry
			and br_c.intRowStatus = 0
where		lso.strName = N'SiteID'


declare	@cmd_select nvarchar(max)
declare	@cmd_from nvarchar(max)
declare	@cmd_where nvarchar(max)
set	@cmd_select = N'select		sf_en.[name] as ''System Function'', oo_en.[name] as ''Operation'''


if @LangID = 'hy' and @NumberOfLanguages in (2, 3) 
begin

set @cmd_select = @cmd_select +
N',
		sf_lng.[name] as ''System Function (AM)'', oo_lng.[name] as ''Operation (AM)'''
end
else if @LangID = 'az-L' and @NumberOfLanguages in (2, 3) 
begin

set @cmd_select = @cmd_select +
N',
		sf_lng.[name] as ''System Function (AZ)'', oo_lng.[name] as ''Operation (AZ)'''
end
else if @LangID = 'ka' and @NumberOfLanguages in (2, 3) 
begin

set @cmd_select = @cmd_select +
N',
		sf_lng.[name] as ''System Function (GG)'', oo_lng.[name] as ''Operation (GG)'''
end
else if @LangID = 'kk' and @NumberOfLanguages in (2, 3) 
begin

set @cmd_select = @cmd_select +
N',
		sf_lng.[name] as ''System Function (KZ)'', oo_lng.[name] as ''Operation (KZ)'''
end
else if @LangID = 'ru' and @NumberOfLanguages in (2, 3) 
begin

set @cmd_select = @cmd_select +
N',
		sf_lng.[name] as ''System Function (RU)'', oo_lng.[name] as ''Operation (RU)'''
end
else if @LangID = 'uk' and @NumberOfLanguages in (2, 3) 
begin

set @cmd_select = @cmd_select +
N',
		sf_lng.[name] as ''System Function (UA)'', oo_lng.[name] as ''Operation (UA)'''
end
else if @LangID = 'ar' and @NumberOfLanguages in (2, 3) 
begin

set @cmd_select = @cmd_select +
N',
		sf_lng.[name] as ''System Function (IQ)'', oo_lng.[name] as ''Operation (IQ)'''
end
else if @LangID = 'th' and @NumberOfLanguages in (2, 3) 
begin

set @cmd_select = @cmd_select +
N',
		sf_lng.[name] as ''System Function (TH)'', oo_lng.[name] as ''Operation (TH)'''
end


if @SecLangID = 'hy' and @NumberOfLanguages = 3
begin

set @cmd_select = @cmd_select +
N',
		sf_seclng.[name] as ''System Function (AM)'', oo_seclng.[name] as ''Operation (AM)'''
end
else if @SecLangID = 'az-L' and @NumberOfLanguages = 3 
begin

set @cmd_select = @cmd_select +
N',
		sf_seclng.[name] as ''System Function (AZ)'', oo_seclng.[name] as ''Operation (AZ)'''
end
else if @SecLangID = 'ka' and @NumberOfLanguages = 3
begin

set @cmd_select = @cmd_select +
N',
		sf_seclng.[name] as ''System Function (GG)'', oo_seclng.[name] as ''Operation (GG)'''
end
else if @SecLangID = 'kk' and @NumberOfLanguages = 3
begin

set @cmd_select = @cmd_select +
N',
		sf_seclng.[name] as ''System Function (KZ)'', oo_seclng.[name] as ''Operation (KZ)'''
end
else if @SecLangID = 'ru' and @NumberOfLanguages = 3
begin

set @cmd_select = @cmd_select +
N',
		sf_seclng.[name] as ''System Function (RU)'', oo_seclng.[name] as ''Operation (RU)'''
end
else if @SecLangID = 'uk' and @NumberOfLanguages = 3
begin

set @cmd_select = @cmd_select +
N',
		sf_seclng.[name] as ''System Function (UA)'', oo_seclng.[name] as ''Operation (UA)'''
end
else if @SecLangID = 'ar' and @NumberOfLanguages = 3
begin

set @cmd_select = @cmd_select +
N',
		sf_seclng.[name] as ''System Function (IQ)'', oo_seclng.[name] as ''Operation (IQ)'''
end
else if @SecLangID = 'th' and @NumberOfLanguages = 3
begin

set @cmd_select = @cmd_select +
N',
		sf_seclng.[name] as ''System Function (TH)'', oo_seclng.[name] as ''Operation (TH)'''
end



set	@cmd_from = N'
from		trtSystemFunction sf
inner join	trtBaseReference br
on			br.idfsBaseReference = sf.idfsSystemFunction
			and br.idfsReferenceType = 19000094		-- System Function
			and br.intRowStatus = 0
inner join	fnReference(''en'', 19000094) sf_en
on			sf_en.idfsReference = sf.idfsSystemFunction
' +
isnull('
left join	fnReference(''' + @LangID + N''', 19000094) sf_lng
on			sf_lng.idfsReference = sf.idfsSystemFunction
', N'') +
isnull(
'left join	fnReference(''' + @SecLangID + N''', 19000094) sf_seclng
on			sf_seclng.idfsReference = sf.idfsSystemFunction
', N'') +
'
inner join	trtObjectTypeToObjectOperation ot_to_oo
on			ot_to_oo.idfsObjectType = sf.idfsObjectType
inner join	trtBaseReference oo
on			oo.idfsBaseReference = ot_to_oo.idfsObjectOperation
			and oo.idfsReferenceType = 19000059		-- Object Operation Type
			and oo.intRowStatus = 0
inner join	fnReference(''en'', 19000059) oo_en
on			oo_en.idfsReference = ot_to_oo.idfsObjectOperation
' +
isnull('
left join	fnReference(''' + @LangID + N''', 19000059) oo_lng
on			oo_lng.idfsReference = ot_to_oo.idfsObjectOperation
', N'') +
isnull('
left join	fnReference(''' + @SecLangID + N''', 19000059) oo_seclng
on			oo_seclng.idfsReference = ot_to_oo.idfsObjectOperation
', N'')


set @cmd_where = N'
where		sf.intRowStatus = 0
order by	coalesce(sf.intNumber, br.intOrder, 0), sf_en.[name], sf.idfsSystemFunction, isnull(oo.intOrder, 0), oo_en.[name], oo.idfsBaseReference
'

select		@cmd_select = @cmd_select + N', replace(replace(cast(isnull(oa' + cast(eg.idfEmployeeGroup as nvarchar(20)) + N'.intPermission, 1) as nvarchar(10)), ''1'', ''''), ''2'', ''a'') as N''' + replace(r_eg_en.[name], N'''', N'''''') + N'''',
			@cmd_from = @cmd_from + N'
left join	tstObjectAccess oa' + cast(eg.idfEmployeeGroup as nvarchar(20)) + N'
on			oa' + cast(eg.idfEmployeeGroup as nvarchar(20)) + N'.idfActor = ' + cast(eg.idfEmployeeGroup as nvarchar(20)) + N'
			and oa' + cast(eg.idfEmployeeGroup as nvarchar(20)) + N'.intRowStatus = 0
			and oa' + cast(eg.idfEmployeeGroup as nvarchar(20)) + N'.idfsOnSite = 1
			and oa' + cast(eg.idfEmployeeGroup as nvarchar(20)) + N'.idfsObjectID = sf.idfsSystemFunction
			and oa' + cast(eg.idfEmployeeGroup as nvarchar(20)) + N'.idfsObjectOperation = oo.idfsBaseReference'
FROM dbo.tlbEmployeeGroup eg
 INNER JOIN
 dbo.tlbEmployee e
 ON e.idfEmployee = eg.idfEmployeeGroup
LEFT JOIN
 fnReference ('en', 19000022) r_eg_en
ON r_eg_en.idfsReference = eg.idfsEmployeeGroupName
 -- Link To Country
 LEFT JOIN
trtBaseReferenceToCP brc
 ON brc.idfsBaseReference = eg.idfsEmployeeGroupName
AND brc.idfCustomizationPackage = @idfCustomizationPackage
 WHERE e.intRowStatus = 0
	and e.idfEmployee <> -1
 AND (@idfCustomizationPackage IS NULL
OR (@idfCustomizationPackage IS NOT NULL
AND (brc.idfsBaseReference IS NOT NULL
 OR NOT EXISTS
(SELECT *
 FROM trtBaseReferenceToCP brc_ex
 INNER JOIN	
 tstCustomizationPackage cp_ex
 ON	cp_ex.idfCustomizationPackage = brc_ex.idfCustomizationPackage
 INNER JOIN
gisCountry c_ex
 ON c_ex.idfsCountry = brc_ex.idfCustomizationPackage
AND c_ex.intRowStatus = 0
INNER JOIN
 gisBaseReference br_c_ex
ON br_c_ex.idfsGISBaseReference =
c_ex.idfsCountry
 AND br_c_ex.intRowStatus = 0
WHERE brc_ex.idfsBaseReference =
 eg.idfsEmployeeGroupName))))

declare	@cmd nvarchar(max)
set @cmd = @cmd_select + N'
' + @cmd_from + N'
' + @cmd_where

--print @cmd
exec sp_executesql @cmd

set nocount off
