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
--declare	@idfCustomizationPackage	bigint
--set	@idfCustomizationPackage = null

--select		@idfCustomizationPackage = CAST(gso.strValue as bigint)
--from		tstGlobalSiteOptions gso
--where		gso.strName = N'CustomizationPackage'
--			and ISNUMERIC(gso.strValue) = 1

--if	@idfCustomizationPackage is null
--select		@idfCustomizationPackage = cp.idfCustomizationPackage
--from		tstLocalSiteOptions lso
--inner join	tstSite s
--on			(cast(s.idfsSite as nvarchar(200)) = lso.strValue collate database_default)
--			and s.intRowStatus = 0
--inner join	tstCustomizationPackage cp
--on			cp.idfCustomizationPackage = s.idfCustomizationPackage
--inner join	gisCountry c
--on			c.idfsCountry = cp.idfsCountry
--			and c.intRowStatus = 0
--inner join	gisBaseReference br_c
--on			br_c.idfsGISBaseReference = c.idfsCountry
--			and br_c.intRowStatus = 0
--where		lso.strName = N'SiteID'


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

select		@cmd_select = @cmd_select + N', replace(replace(cast(isnull(oa' + cast(p.idfPerson as nvarchar(20)) + N'.intPermission, 1) as nvarchar(10)), ''1'', ''''), ''2'', ''a'') as N''' + replace(dbo.fnConcatFullName(p.strFamilyName, p.strFirstName, p.strSecondName) + N'(account: ' + user_info.strAccountName + N')' collate Cyrillic_General_CI_AS, N'''', N'''''') + N'''',
			@cmd_from = @cmd_from + N'
outer apply	
( 
select top 1 oa' + cast(p.idfPerson as nvarchar(20)) + N'_perm.intPermission
from tstObjectAccess oa' + cast(p.idfPerson as nvarchar(20)) + N'_perm
where		oa' + cast(p.idfPerson as nvarchar(20)) + N'_perm.idfActor = ' + cast(p.idfPerson as nvarchar(20)) + N'
			and oa' + cast(p.idfPerson as nvarchar(20)) + N'_perm.intRowStatus = 0
			--and oa' + cast(p.idfPerson as nvarchar(20)) + N'_perm.idfsOnSite = 1
			and oa' + cast(p.idfPerson as nvarchar(20)) + N'_perm.idfsObjectID = sf.idfsSystemFunction
			and oa' + cast(p.idfPerson as nvarchar(20)) + N'_perm.idfsObjectOperation = oo.idfsBaseReference
order by	oa' + cast(p.idfPerson as nvarchar(20)) + N'_perm.idfsOnSite, oa' + cast(p.idfPerson as nvarchar(20)) + N'_perm.idfObjectAccess
) oa' + cast(p.idfPerson as nvarchar(20))
FROM dbo.tlbPerson p
 INNER JOIN
 dbo.tlbEmployee e
 ON e.idfEmployee = p.idfPerson
	and e.intRowStatus = 0
cross apply
(	select	top 1 ut.idfUserID, ut.strAccountName
	from	tstUserTable ut 
	join	tstSite s 
	on		s.idfsSite = ut.idfsSite 
	where	ut.idfPerson = p.idfPerson 
			and s.idfOffice = p.idfInstitution 
			and ut.intRowStatus = 0 
			and ut.strAccountName not like N'% Administrator' collate Cyrillic_General_CI_AS
			and ut.strAccountName <> N'SentByEmployee' collate Cyrillic_General_CI_AS
) user_info
 where p.intRowStatus = 0
		and exists (select 1 from tstObjectAccess oa where oa.idfActor = p.idfPerson /*and oa.idfsOnSite = 1*/ and oa.intPermission = 2 and oa.intRowStatus = 0)
		--and exists (select 1 from tstUserTable ut join tstSite s on s.idfsSite = ut.idfsSite where ut.idfPerson = p.idfPerson and s.idfOffice = p.idfInstitution and ut.intRowStatus = 0 and ut.strAccountName not like N'% Administrator' collate Cyrillic_General_CI_AS)

declare	@cmd nvarchar(max)
set @cmd = @cmd_select + N'
' + @cmd_from + N'
' + @cmd_where

--print @cmd
exec sp_executesql @cmd

set nocount off
