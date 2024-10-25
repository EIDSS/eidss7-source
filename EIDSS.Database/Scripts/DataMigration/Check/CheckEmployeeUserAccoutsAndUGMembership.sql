-- This script compares list of users with logins and membership in user groups between v6.1 and v7.


set nocount on


declare	@idfCustomizationPackage	bigint
set	@idfCustomizationPackage = null

select		@idfCustomizationPackage = CAST(gso.strValue as bigint)
from		[Falcon].[dbo].tstGlobalSiteOptions gso
where		gso.strName = N'CustomizationPackage'
			and ISNUMERIC(gso.strValue) = 1

if	@idfCustomizationPackage is null
select		@idfCustomizationPackage = cp.idfCustomizationPackage
from		[Falcon].[dbo].tstLocalSiteOptions lso
inner join	[Falcon].[dbo].tstSite s
on			(cast(s.idfsSite as nvarchar(200)) = lso.strValue collate database_default)
			and s.intRowStatus = 0
inner join	[Falcon].[dbo].tstCustomizationPackage cp
on			cp.idfCustomizationPackage = s.idfCustomizationPackage
inner join	[Falcon].[dbo].gisCountry c
on			c.idfsCountry = cp.idfsCountry
			and c.intRowStatus = 0
inner join	[Falcon].[dbo].gisBaseReference br_c
on			br_c.idfsGISBaseReference = c.idfsCountry
			and br_c.intRowStatus = 0
where		lso.strName = N'SiteID'



select		IsNull(Organization_v7.[name], N'Not migrated') as N'Organization Abbreviation v7',
			IsNull(tlbPerson_v7.strFamilyName, N'') as N'Last Name v7',
			IsNull(tlbPerson_v7.strFirstName, N'') as N'First Name v7',
			IsNull(tlbPerson_v7.strSecondName, N'') as N'Patronymic v7',
			IsNull(pidtype_v7.strDefault, N'') as N'Personal ID Type v7',
			isnull(STUFF(users_v7.strAccountList, 1, 2, N''), N'Not migrated') as N'User Accounts for Organizations v7',
			isnull(STUFF(groups_v7.strGroupList, 1, 2, N''), N'') as N'Member in User Groups v7',
			IsNull(Organization_v6.[name], N'New in v7') as N'Organization Abbreviation v6.1',
			IsNull(tlbPerson_v6.strFamilyName, N'') as N'Last Name v6.1',
			IsNull(tlbPerson_v6.strFirstName, N'') as N'First Name v6.1',
			IsNull(tlbPerson_v6.strSecondName, N'') as N'Patronymic v6.1',
			isnull(users_v6.strAccount, N'New in v7') as N'User Account v6.1',
			isnull(STUFF(groups_v6.strGroupList, 1, 2, N''), N'') as N'Member in User Groups v6.1'
from		(
	[Falcon].[dbo].[tlbEmployee] tlbEmployee_v6
	inner join	[Falcon].[dbo].[tlbPerson] tlbPerson_v6
	on			tlbPerson_v6.idfPerson = tlbEmployee_v6.idfEmployee
				and tlbPerson_v6.intRowStatus = 0
				and tlbEmployee_v6.intRowStatus = 0
	inner join	[Falcon].[dbo].[tlbOffice] tlbOffice_v6
	on			tlbOffice_v6.idfOffice = tlbPerson_v6.idfInstitution
				and tlbOffice_v6.idfCustomizationPackage = @idfCustomizationPackage
				and tlbOffice_v6.intRowStatus = 0
				and exists (select 1 from [Falcon].[dbo].[tstSite] s where s.idfOffice = tlbOffice_v6.idfOffice and s.intRowStatus = 0)
	inner join	[Falcon].[dbo].fnInstitution('en') Organization_v6
	on			Organization_v6.idfOffice = tlbPerson_v6.idfInstitution

	cross apply
	(	select	top 1 isnull(Organization_v6.[name] + N' (default): ', N'') + ut_v6.strAccountName + case when ut_v6.blnDisabled = 1 then N' (disabled)' else N'' end collate Cyrillic_General_CI_AS as strAccount
		from	[Falcon].[dbo].tstUserTable ut_v6
		join	[Falcon].[dbo].tstSite s_v6
		on		s_v6.idfsSite = ut_v6.idfsSite
				and s_v6.intRowStatus = 0
		join	[Falcon].[dbo].tlbOffice o_v6
		on		o_v6.idfOffice = s_v6.idfOffice
				and o_v6.intRowStatus = 0
		where	ut_v6.idfPerson = tlbPerson_v6.idfPerson
				and ut_v6.intRowStatus = 0
				and ut_v6.strAccountName not like N'% Administrator' collate Cyrillic_General_CI_AS
				and ut_v6.strAccountName <> N'SentByEmployee' collate Cyrillic_General_CI_AS
	) users_v6
	outer apply
	(	select	IsNull ( cast( ( select  '; ' + egName_v6.[Name]
            from  [Falcon].[dbo].tlbEmployeeGroupMember egm_v6
            inner join [Falcon].[dbo].tlbEmployeeGroup eg_v6
            on   eg_v6.idfEmployeeGroup = egm_v6.idfEmployeeGroup
            inner join [Falcon].[dbo].tlbEmployee e_eg_v6
            on   e_eg_v6.idfEmployee = eg_v6.idfEmployeeGroup
               and e_eg_v6.intRowStatus = 0
            left join [Falcon].[dbo].fnReference('en', 19000022) egName_v6 -- Employee Group Name
            on   egName_v6.idfsReference = eg_v6.idfsEmployeeGroupName
            where  egm_v6.intRowStatus = 0
               and egm_v6.idfEmployee = tlbPerson_v6.idfPerson
            order by egName_v6.[Name], eg_v6.idfEmployeeGroup
              for xml path('')  
           ) as nvarchar(max)
          ),
         N'; None'
        ) as strGroupList
	) groups_v6
			)

full join	
(	
	[Giraffe].[dbo].[tlbEmployee] tlbEmployee_v7
	inner join	[Giraffe].[dbo].[tlbPerson] tlbPerson_v7
	on			tlbPerson_v7.idfPerson = tlbEmployee_v7.idfEmployee
				and tlbPerson_v7.intRowStatus = 0
				and tlbEmployee_v7.intRowStatus = 0
				and exists 
					(	select 1
						from	[Giraffe].[dbo].tstUserTable ut_v7
						--join	[Giraffe].[dbo].tstSite s_v7
						--on		s_v7.idfsSite = ut_v7.idfsSite
						--		and s_v7.intRowStatus = 0
						join	[Giraffe].[dbo].AspNetUsers AspNetUsers_v7
						on		AspNetUsers_v7.idfUserID = ut_v7.idfUserID
						join	[Giraffe].[dbo].EmployeeToInstitution ei_v7
						on		ei_v7.aspNetUserId = AspNetUsers_v7.[Id]
								and ei_v7.idfUserId = ut_v7.idfUserID
								and ei_v7.intRowStatus = 0
						join	[Giraffe].[dbo].fnInstitution('en') loginOrg_v7
						on		loginOrg_v7.idfOffice = ei_v7.idfInstitution

						where	ut_v7.idfPerson = tlbPerson_v7.idfPerson
								and ut_v7.intRowStatus = 0
								and AspNetUsers_v7.UserName not like N'% Administrator' collate Cyrillic_General_CI_AS
								and AspNetUsers_v7.UserName <> N'SentByEmployee' collate Cyrillic_General_CI_AS
					)
	inner join	[Giraffe].[dbo].[tlbOffice] tlbOffice_v7
	on			tlbOffice_v7.idfOffice = tlbPerson_v7.idfInstitution
				and tlbOffice_v7.idfCustomizationPackage = @idfCustomizationPackage
				and tlbOffice_v7.intRowStatus = 0
				and exists (select 1 from [Giraffe].[dbo].[tstSite] s where s.idfOffice = tlbOffice_v7.idfOffice and s.intRowStatus = 0)
	inner join	[Giraffe].[dbo].fnInstitution('en') Organization_v7
	on			Organization_v7.idfOffice = tlbPerson_v7.idfInstitution
	left join	[Giraffe].[dbo].trtBaseReference pidtype_v7
	on			pidtype_v7.idfsBaseReference = tlbPerson_v7.PersonalIDTypeID

	cross apply
	(	select	replace(IsNull ( cast( ( select	'; ' + isnull(loginOrg_v7.[name] + case when ei_v7.IsDefault = 1 then N' (default)' else N'' end, N'') + N': ' + AspNetUsers_v7.UserName + case when AspNetUsers_v7.blnDisabled = 1 then N' (disabled)' else N'' end collate Cyrillic_General_CI_AS
			from	[Giraffe].[dbo].tstUserTable ut_v7
			--join	[Giraffe].[dbo].tstSite s_v7
			--on		s_v7.idfsSite = ut_v7.idfsSite
			--		and s_v7.intRowStatus = 0
			join	[Giraffe].[dbo].AspNetUsers AspNetUsers_v7
			on		AspNetUsers_v7.idfUserID = ut_v7.idfUserID
			join	[Giraffe].[dbo].EmployeeToInstitution ei_v7
			on		ei_v7.aspNetUserId = AspNetUsers_v7.[Id]
					and ei_v7.idfUserId = ut_v7.idfUserID
					and ei_v7.intRowStatus = 0
			join	[Giraffe].[dbo].fnInstitution('en') loginOrg_v7
			on		loginOrg_v7.idfOffice = ei_v7.idfInstitution

			where	ut_v7.idfPerson = tlbPerson_v7.idfPerson
					and ut_v7.intRowStatus = 0
					and AspNetUsers_v7.UserName not like N'% Administrator' collate Cyrillic_General_CI_AS
					and AspNetUsers_v7.UserName <> N'SentByOffice' collate Cyrillic_General_CI_AS
			order by	ei_v7.IsDefault desc, loginOrg_v7.[name] asc, ei_v7.idfInstitution, AspNetUsers_v7.UserName, AspNetUsers_v7.[Id]
              for xml path('')  
           ) as nvarchar(max)
          ),
         N'; '
        ), N'&amp;', N'&') as strAccountList	
	) users_v7


	outer apply
	(	select	IsNull ( cast( ( select  '; ' + egName_v7.[Name]
            from  [Giraffe].[dbo].tlbEmployeeGroupMember egm_v7
            inner join [Giraffe].[dbo].tlbEmployeeGroup eg_v7
            on   eg_v7.idfEmployeeGroup = egm_v7.idfEmployeeGroup
            inner join [Giraffe].[dbo].tlbEmployee e_eg_v7
            on   e_eg_v7.idfEmployee = eg_v7.idfEmployeeGroup
               and e_eg_v7.intRowStatus = 0
            left join [Giraffe].[dbo].fnReference('en', 19000022) egName_v7 -- Employee Group Name
            on   egName_v7.idfsReference = eg_v7.idfsEmployeeGroupName
            where  egm_v7.intRowStatus = 0
               and egm_v7.idfEmployee = tlbPerson_v7.idfPerson
            order by egName_v7.[Name], eg_v7.idfEmployeeGroup
              for xml path('')  
           ) as nvarchar(max)
          ),
         N'; None'
        ) as strGroupList
	) groups_v7
)
on tlbPerson_v6.idfPerson = tlbPerson_v7.idfPerson
order by [Organization_v7].[name], tlbPerson_v7.strFamilyName, tlbPerson_v7.strFirstName, users_v7.strAccountList, tlbPerson_v7.idfPerson,
			[Organization_v6].[name], tlbPerson_v6.strFamilyName, tlbPerson_v6.strFirstName, users_v6.strAccount, tlbPerson_v6.idfPerson

set nocount off

