-- This script selects matrix with the access to menu items by custom user groups.
-- Script should be executed on the database of version 7, which contains user group menu access records that should be selected.
	
	use [Giraffe]
	
	declare @idfsLanguageEN bigint
	set @idfsLanguageEN = dbo.FN_GBL_LanguageCode_GET('en-US')


	IF OBJECT_ID('tempdb..##Temp') IS NOT NULL
	BEGIN
		exec sp_executesql N'drop table ##Temp'
	END

	IF OBJECT_ID('tempdb..##Temp') IS  NULL
	create table ##Temp
	( 
		LvlEIDSSMenuID bigint not null primary key,
		EIDSSMenuName_EN nvarchar(200) collate Cyrillic_General_CI_AS null,
		StepEIDSSMenuPath nvarchar(2000) collate Cyrillic_General_CI_AS null,
		intRowStatus int not null
	)
	truncate table ##Temp

;
 WITH cte
	(
        LvlEIDSSMenuID, intRowStatus, EIDSSMegaMenuID, StepParentEIDSSMenuID, StepParentIndex, EIDSSMenuName_EN, StepEIDSSMenuPath
    )
AS	(
		select m.EIDSSMenuID, m_br.intRowStatus, m.EIDSSMegaMenuID, case when m.EIDSSParentMenuID is null or m.EIDSSParentMenuID = m.EIDSSMenuID then cast(null as bigint) else m.EIDSSParentMenuID end, 0, isNull(m_br.strDefault, N''), cast(m_br.strDefault as nvarchar(2000))
		from LkupEIDSSMenu as m
		inner join	trtBaseReference m_br
		on m_br.idfsBaseReference = m.EIDSSMenuID
		where m.intRowStatus = 0

		union all
		select	cte.LvlEIDSSMenuID, cte.intRowStatus, cte.EIDSSMegaMenuID, case when stepParent.EIDSSParentMenuID is null or stepParent.EIDSSParentMenuID = stepParent.EIDSSMenuID then cast(null as bigint) else stepParent.EIDSSParentMenuID end, cte.StepParentIndex + 1, cte.EIDSSMenuName_EN, cast((isnull(stepParent_br.strDefault, N'') + N'>' + cte.StepEIDSSMenuPath) as nvarchar(2000))
		from	LkupEIDSSMenu as stepParent
		inner join	trtBaseReference stepParent_br
		on	stepParent_br.idfsBaseReference = stepParent.EIDSSMenuID
		inner join	cte
		on	cte.StepParentEIDSSMenuID = stepParent.EIDSSMenuID
	)

	insert into ##Temp (LvlEIDSSMenuID, intRowStatus, EIDSSMenuName_EN, StepEIDSSMenuPath)
	select LvlEIDSSMenuID, intRowStatus, EIDSSMenuName_EN, StepEIDSSMenuPath
	from cte
	where StepParentEIDSSMenuID is null
	order by  replace(StepEIDSSMenuPath, N'>', N'  ')

	declare @cmd nvarchar(max) = N'
	select  EIDSSMenuID as N''Menu Item (System Id)'', 
			strMenuPath as N''Menu Item Path'',
			strDelState as N''Menu Item Delete State''
'

	select	@cmd = @cmd + replace(
	( select N', [' + cast(p.idfPerson as nvarchar(20)) + N'] as N''' + 
		isnull(replace(dbo.fnConcatFullName(p.strFamilyName, p.strFirstName, p.strSecondName) + N'(account: ' + user_info.strAccountName + N')' collate Cyrillic_General_CI_AS, N'''', N''''''), cast(p.idfPerson as nvarchar(20))) + N'''
' collate Cyrillic_General_CI_AS
FROM dbo.tlbPerson p
 INNER JOIN [Falcon].dbo.tlbPerson p_v6
 on p_v6.idfPerson = p.idfPerson
 INNER JOIN
 dbo.tlbEmployee e
 ON e.idfEmployee = p.idfPerson
	and e.intRowStatus = 0
cross apply
(	select	top 1 aspNetU.[Id] as AspNetUserId, ut.idfUserID, aspNetU.UserName as strAccountName
	from	tstUserTable ut 
	join	[Falcon].dbo.tstUserTable ut_v6
	on		ut_v6.idfUserID = ut.idfUserID
			and ut_v6.idfPerson = p_v6.idfPerson
	join	tstSite s 
	on		s.idfsSite = ut.idfsSite
	join	AspNetUsers aspNetU
	on		aspNetU.idfUserID = ut.idfUserID
	join	EmployeeToInstitution ei
	on		ei.aspNetUserId = aspNetU.[Id]
			and ei.idfUserId = ut.idfUserID
			and ei.idfInstitution = p.idfInstitution
			and ei.intRowStatus = 0
			and ei.IsDefault = 1
	where	ut.idfPerson = p.idfPerson 
			and ut.intRowStatus = 0
			and aspNetU.UserName <> N'SentByEmployee' collate Cyrillic_General_CI_AS
) user_info
 where p.intRowStatus = 0
		and exists (select 1 from LkupRoleMenuAccess oa where oa.idfEmployee = p.idfPerson and oa.intRowStatus = 0)
	order by user_info.strAccountName, p.idfPerson
	for xml path('')
	), N'&#x0D;', N'')
	


	set @cmd = @cmd + N'
	from
	(
		select	t.LvlEIDSSMenuID as EIDSSMenuID, 
				isnull(t.StepEIDSSMenuPath, N'''') as strMenuPath,
				case when t.intRowStatus <> 0 then N''Marked as deleted?'' else N'''' end as strDelState,
				p.idfPerson,
				case when lrma.idfEmployee is not null then N''a'' else '''' end as toAggr
		from	##Temp t
		inner join dbo.tlbPerson p
			 INNER JOIN [Falcon].dbo.tlbPerson p_v6
			 on p_v6.idfPerson = p.idfPerson
			 INNER JOIN
			 dbo.tlbEmployee e
			 ON e.idfEmployee = p.idfPerson
				and e.intRowStatus = 0
' + N'
			cross apply
			(	select	top 1 aspNetU.[Id] as AspNetUserId, ut.idfUserID, aspNetU.UserName as strAccountName
				from	tstUserTable ut 
				join	[Falcon].dbo.tstUserTable ut_v6
				on		ut_v6.idfUserID = ut.idfUserID
						and ut_v6.idfPerson = p_v6.idfPerson
				join	tstSite s 
				on		s.idfsSite = ut.idfsSite
				join	AspNetUsers aspNetU
				on		aspNetU.idfUserID = ut.idfUserID
				join	EmployeeToInstitution ei
				on		ei.aspNetUserId = aspNetU.[Id]
						and ei.idfUserId = ut.idfUserID
						and ei.idfInstitution = p.idfInstitution
						and ei.intRowStatus = 0
						and ei.IsDefault = 1
				where	ut.idfPerson = p.idfPerson 
						and ut.intRowStatus = 0
						and aspNetU.UserName <> N''SentByEmployee'' collate Cyrillic_General_CI_AS
			) user_info
		 on p.intRowStatus = 0
			and exists (select 1 from LkupRoleMenuAccess oa where oa.idfEmployee = p.idfPerson and oa.intRowStatus = 0)
		left join [dbo].[LkupRoleMenuAccess] lrma
		on lrma.idfEmployee = p.idfPerson
			and lrma.[EIDSSMenuID] = t.LvlEIDSSMenuID
			and lrma.intRowStatus = 0
	) p
	pivot
	(	max(toAggr)
		for idfPerson in (
' collate Cyrillic_General_CI_AS


	select	@cmd = @cmd + replace(STUFF(isnull(
	( select N', [' + cast(p.idfPerson as nvarchar(20)) + N']' collate Cyrillic_General_CI_AS
FROM dbo.tlbPerson p
 INNER JOIN [Falcon].dbo.tlbPerson p_v6
 on p_v6.idfPerson = p.idfPerson
 INNER JOIN
 dbo.tlbEmployee e
 ON e.idfEmployee = p.idfPerson
	and e.intRowStatus = 0
cross apply
(	select	top 1 aspNetU.[Id] as AspNetUserId, ut.idfUserID, aspNetU.UserName as strAccountName
	from	tstUserTable ut 
	join	[Falcon].dbo.tstUserTable ut_v6
	on		ut_v6.idfUserID = ut.idfUserID
			and ut_v6.idfPerson = p_v6.idfPerson
	join	tstSite s 
	on		s.idfsSite = ut.idfsSite
	join	AspNetUsers aspNetU
	on		aspNetU.idfUserID = ut.idfUserID
	join	EmployeeToInstitution ei
	on		ei.aspNetUserId = aspNetU.[Id]
			and ei.idfUserId = ut.idfUserID
			and ei.idfInstitution = p.idfInstitution
			and ei.intRowStatus = 0
			and ei.IsDefault = 1
	where	ut.idfPerson = p.idfPerson 
			and ut.intRowStatus = 0
			and aspNetU.UserName <> N'SentByEmployee' collate Cyrillic_General_CI_AS
) user_info
 where p.intRowStatus = 0
		and exists (select 1 from LkupRoleMenuAccess oa where oa.idfEmployee = p.idfPerson and oa.intRowStatus = 0)
	order by user_info.strAccountName, p.idfPerson
	for xml path('')
	), N''), 1, 1, N''), N'&#x0D;', N'')


	set @cmd = @cmd + N'
		)
	) as pvt
	order by strMenuPath, EIDSSMenuID
	'

	exec sp_executesql @cmd



	IF OBJECT_ID('tempdb..##Temp') IS NOT NULL
	BEGIN
		exec sp_executesql N'drop table ##Temp'
	END
