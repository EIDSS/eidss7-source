	declare @idfsLanguageEN bigint
	set @idfsLanguageEN = dbo.FN_GBL_LanguageCode_GET('en-US')


	declare @cmd nvarchar(max) = N'
	select  idfsEventTypeID as N''Event Type (System Id)'',
			idfsEventSubscription as N''Event Subscription Name (System Id)'',
			strDel as N''Event Type Deletion State'', 
			strEventSubscriptionNameEN as N''Event Subscription Name (EN)''
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
		select	evt.idfsEventTypeID, evt.idfsEventSubscription, 
				replace(replace(cast(evt.intRowStatus as nvarchar(2)), N''0'', N''''), N''1'', N''Marked as deleted ?'') as strDel, 
				coalesce(evs_snt_EN.strTextString, evs_br.strDefault, N'''') as strEventSubscriptionNameEN,
				eg.idfEmployeeGroup,
				N'''' as toAggr
		from	trtEventType evt
		inner join	trtBaseReference evt_br
		on			evt_br.idfsBaseReference = evt.idfsEventTypeID
		inner join	trtBaseReference evs_br
		on			evs_br.idfsBaseReference = evt.idfsEventSubscription
					and evs_br.intRowStatus = 0
		left join trtStringNameTranslation evs_snt_EN
		on evs_snt_EN.idfsBaseReference = evt.idfsEventSubscription and evs_snt_EN.idfsLanguage = ' + cast(@idfsLanguageEN as nvarchar(20)) + N' /*en-US*/ and evs_snt_EN.intRowStatus = 0
		inner join	tlbEmployeeGroup eg
			left join trtBaseReference br_egn
			on br_egn.idfsBaseReference = eg.idfsEmployeeGroupName
			left join trtStringNameTranslation snt_en_egn
			on snt_en_egn.idfsBaseReference = br_egn.idfsBaseReference
				and snt_en_egn.idfsLanguage = ' + cast(@idfsLanguageEN as nvarchar(20)) + N' /*en-US*/
		on eg.idfEmployeeGroup < -512
			and eg.intRowStatus = 0
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
	order by strEventSubscriptionNameEN, idfsEventSubscription, idfsEventTypeID
	'

	exec sp_executesql @cmd


