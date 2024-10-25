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
	( select N', [' + cast(eg.idfEmployeeGroup as nvarchar(20)) + N'] as N''' + 
		replace(coalesce(snt_en_egn.strTextString, br_egn.strDefault, eg.strName, cast(eg.idfEmployeeGroup as nvarchar(20))), N'''', N'''''') + N'''
' collate Cyrillic_General_CI_AS
	from	tlbEmployeeGroup eg
	left join trtBaseReference br_egn
	on br_egn.idfsBaseReference = eg.idfsEmployeeGroupName
	left join trtStringNameTranslation snt_en_egn
	on snt_en_egn.idfsBaseReference = br_egn.idfsBaseReference
		and snt_en_egn.idfsLanguage = @idfsLanguageEN
	outer apply
	(	select	ISNULL(
			(
				select		N', ' + ha_br_v7.strDefault
				from		[dbo].[trtHACodeList] ha_v7
				join		[trtBaseReference] ha_br_v7
				on			ha_br_v7.idfsBaseReference = ha_v7.idfsCodeName
				where		(	(br_egn.intHACode = 0 and ha_v7.intHACode = 0)
								or (	br_egn.intHACode > 0 and ha_v7.intHACode > 0
										and ha_v7.intHACode <> 510 /*All*/
										and ((br_egn.intHACode & ha_v7.intHACode) = ha_v7.intHACode)
									)
								or	(br_egn.intHACode is null and ha_v7.intHACode = 510 /*All*/)
							)
				order by	ha_v7.intHACode asc
				for xml path('')
			), N',') strCodeNames
	) haCodes_v7

	where eg.idfEmployeeGroup < -512
			and eg.intRowStatus = 0
	order by STUFF(isnull(haCodes_v7.strCodeNames, N','), 1, 1, N''), replace(coalesce(snt_en_egn.strTextString, br_egn.strDefault, eg.strName, cast(eg.idfEmployeeGroup as nvarchar(20))), N'''', N''''''), eg.idfEmployeeGroup
	for xml path('')
	), N'&#x0D;', N'')
	


	set @cmd = @cmd + N'
	from
	(
		select	t.LvlEIDSSMenuID as EIDSSMenuID, 
				isnull(t.StepEIDSSMenuPath, N'''') as strMenuPath,
				case when t.intRowStatus <> 0 then N''Marked as deleted?'' else N'''' end as strDelState,
				eg.idfEmployeeGroup,
				case when lrma.idfEmployee is not null then N''a'' else '''' end as toAggr
		from	##Temp t
		inner join	tlbEmployeeGroup eg
			left join trtBaseReference br_egn
			on br_egn.idfsBaseReference = eg.idfsEmployeeGroupName
			left join trtStringNameTranslation snt_en_egn
			on snt_en_egn.idfsBaseReference = br_egn.idfsBaseReference
				and snt_en_egn.idfsLanguage = ' + cast(@idfsLanguageEN as nvarchar(20)) + N' /*en-US*/
		on eg.idfEmployeeGroup < -512
			and eg.intRowStatus = 0
		left join [dbo].[LkupRoleMenuAccess] lrma
		on lrma.idfEmployee = eg.idfEmployeeGroup
			and lrma.[EIDSSMenuID] = t.LvlEIDSSMenuID
			and lrma.intRowStatus = 0
	) p
	pivot
	(	max(toAggr)
		for idfEmployeeGroup in (
' collate Cyrillic_General_CI_AS


	select	@cmd = @cmd + replace(STUFF(isnull(
	( select N', [' + cast(eg.idfEmployeeGroup as nvarchar(20)) + N']' collate Cyrillic_General_CI_AS
	from	tlbEmployeeGroup eg
	left join trtBaseReference br_egn
	on br_egn.idfsBaseReference = eg.idfsEmployeeGroupName
	left join trtStringNameTranslation snt_en_egn
	on snt_en_egn.idfsBaseReference = br_egn.idfsBaseReference
		and snt_en_egn.idfsLanguage = @idfsLanguageEN
	outer apply
	(	select	ISNULL(
			(
				select		N', ' + ha_br_v7.strDefault
				from		[dbo].[trtHACodeList] ha_v7
				join		[dbo].[trtBaseReference] ha_br_v7
				on			ha_br_v7.idfsBaseReference = ha_v7.idfsCodeName
				where		(	(br_egn.intHACode = 0 and ha_v7.intHACode = 0)
								or (	br_egn.intHACode > 0 and ha_v7.intHACode > 0
										and ha_v7.intHACode <> 510 /*All*/
										and ((br_egn.intHACode & ha_v7.intHACode) = ha_v7.intHACode)
									)
								or	(br_egn.intHACode is null and ha_v7.intHACode = 510 /*All*/)
							)
				order by	ha_v7.intHACode asc
				for xml path('')
			), N',') strCodeNames
	) haCodes_v7

	where eg.idfEmployeeGroup < -512
			and eg.intRowStatus = 0
	order by STUFF(isnull(haCodes_v7.strCodeNames, N','), 1, 1, N''), replace(coalesce(snt_en_egn.strTextString, br_egn.strDefault, eg.strName, cast(eg.idfEmployeeGroup as nvarchar(20))), N'''', N''''''), eg.idfEmployeeGroup
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
