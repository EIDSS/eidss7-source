	declare @idfsLanguageEN bigint
	declare @idfsLanguageAZ bigint
	declare @idfsLanguageGG bigint
	declare @idfsLanguageRU bigint
	set @idfsLanguageEN = dbo.FN_GBL_LanguageCode_GET('en-US')
	set @idfsLanguageAZ = dbo.FN_GBL_LanguageCode_GET('az-Latn-AZ')
	set @idfsLanguageGG = dbo.FN_GBL_LanguageCode_GET('ka-GE')
	set @idfsLanguageRU = dbo.FN_GBL_LanguageCode_GET('ru-RU')

	IF OBJECT_ID('tempdb..#Temp') IS NOT NULL
	BEGIN
		exec sp_executesql N'drop table #Temp'
	END

	IF OBJECT_ID('tempdb..#Temp') IS  NULL
	create table #Temp
	( 
		LvlEIDSSMenuID bigint not null primary key,
		EIDSSMenuName_EN nvarchar(200) collate Cyrillic_General_CI_AS null,
		StepEIDSSMenuPath nvarchar(2000) collate Cyrillic_General_CI_AS null
	)
	truncate table #Temp

;
 WITH cte
	(
        LvlEIDSSMenuID, EIDSSMegaMenuID, StepParentEIDSSMenuID, StepParentIndex, EIDSSMenuName_EN, StepEIDSSMenuPath
    )
AS	(
		select m.EIDSSMenuID, m.EIDSSMegaMenuID, case when m.EIDSSParentMenuID is null or m.EIDSSParentMenuID = m.EIDSSMenuID then cast(null as bigint) else m.EIDSSParentMenuID end, 0, isNull(m_br.strDefault, N''), cast(m_br.strDefault as nvarchar(2000))
		from LkupEIDSSMenu as m
		inner join	trtBaseReference m_br
		on m_br.idfsBaseReference = m.EIDSSMenuID

		union all
		select	cte.LvlEIDSSMenuID, cte.EIDSSMegaMenuID, case when stepParent.EIDSSParentMenuID is null or stepParent.EIDSSParentMenuID = stepParent.EIDSSMenuID then cast(null as bigint) else stepParent.EIDSSParentMenuID end, cte.StepParentIndex + 1, cte.EIDSSMenuName_EN, cast((isnull(stepParent_br.strDefault, N'') + N'>' + cte.StepEIDSSMenuPath) as nvarchar(2000))
		from	LkupEIDSSMenu as stepParent
		inner join	trtBaseReference stepParent_br
		on	stepParent_br.idfsBaseReference = stepParent.EIDSSMenuID
		inner join	cte
		on	cte.StepParentEIDSSMenuID = stepParent.EIDSSMenuID
	)

	insert into #Temp (LvlEIDSSMenuID, EIDSSMenuName_EN, StepEIDSSMenuPath)
	select LvlEIDSSMenuID, EIDSSMenuName_EN, StepEIDSSMenuPath
	from cte
	where StepParentEIDSSMenuID is null
	order by  replace(StepEIDSSMenuPath, N'>', N'  ')

	select	LvlEIDSSMenuID as N'Menu Item (System Id)', 
			StepEIDSSMenuPath as N'Menu Item Path', 
			coalesce(snt_EN.strTextString, EIDSSMenuName_EN, N'') as N'Menu Item Name (EN)', 
			isnull(snt_GG.strTextString, N'') as N'Menu Item Translation (GG)',
			case when snt_GG.intRowStatus <> 0 then N'Marked as deleted' else N'' end as N'Translation Status (GG)',
			isnull(snt_AZ.strTextString, N'') as N'Menu Item Translation (AZ)',
			case when snt_AZ.intRowStatus <> 0 then N'Marked as deleted' else N'' end as N'Translation Status (AZ)', 
			isnull(snt_RU.strTextString, N'') as N'Menu Item Translation (RU)',
			case when snt_RU.intRowStatus <> 0 then N'Marked as deleted' else N'' end as N'Translation Status (RU)' 
	from #Temp t
		left join trtStringNameTranslation snt_EN
	on snt_EN.idfsBaseReference = t.LvlEIDSSMenuID and snt_EN.idfsLanguage = @idfsLanguageEN and snt_EN.intRowStatus = 0
		left join trtStringNameTranslation snt_AZ
	on snt_AZ.idfsBaseReference = t.LvlEIDSSMenuID and snt_AZ.idfsLanguage = @idfsLanguageAZ
		left join trtStringNameTranslation snt_GG
	on snt_GG.idfsBaseReference = t.LvlEIDSSMenuID and snt_GG.idfsLanguage = @idfsLanguageGG
		left join trtStringNameTranslation snt_RU
	on snt_RU.idfsBaseReference = t.LvlEIDSSMenuID and snt_RU.idfsLanguage = @idfsLanguageRU

	select	appobj.AppObjectNameID as N'App Object (System Id)', 
			ISNULL(appobj_type.strDefault, N'') as N'App Object Type', 
			coalesce(snt_EN.strTextString, appobj_br.strDefault, N'') as N'App Object Name (EN)', 
			isnull(t.StepEIDSSMenuPath, N'') as N'Related Menu Item Path',
			isnull(snt_GG.strTextString, N'') as N'App Object Translation (GG)',
			case when snt_GG.intRowStatus <> 0 then N'Marked as deleted' else N'' end as N'Translation Status (GG)',
			isnull(snt_AZ.strTextString, N'') as N'App Object Translation (AZ)',
			case when snt_AZ.intRowStatus <> 0 then N'Marked as deleted' else N'' end as N'Translation Status (AZ)', 
			isnull(snt_RU.strTextString, N'') as N'App Object Translation (RU)',
			case when snt_RU.intRowStatus <> 0 then N'Marked as deleted' else N'' end as N'Translation Status (RU)',
			appobj.PageLink as N'Page Link'
	from	LkupEIDSSAppObject appobj
	inner join	trtBaseReference appobj_br
	on			appobj_br.idfsBaseReference = appobj.AppObjectNameID
	left join	#Temp t
	on		t.LvlEIDSSMenuID = appobj.RelatedEIDSSMenuID
	left join trtBaseReference appobj_type
	on appobj_type.idfsBaseReference = appobj.AppObjectTypeID
	left join trtStringNameTranslation snt_EN
	on snt_EN.idfsBaseReference = appobj.AppObjectNameID and snt_EN.idfsLanguage = @idfsLanguageEN and snt_EN.intRowStatus = 0
		left join trtStringNameTranslation snt_AZ
	on snt_AZ.idfsBaseReference = appobj.AppObjectNameID and snt_AZ.idfsLanguage = @idfsLanguageAZ
		left join trtStringNameTranslation snt_GG
	on snt_GG.idfsBaseReference = appobj.AppObjectNameID and snt_GG.idfsLanguage = @idfsLanguageGG
		left join trtStringNameTranslation snt_RU
	on snt_RU.idfsBaseReference = appobj.AppObjectNameID and snt_RU.idfsLanguage = @idfsLanguageRU
	where	appobj.intRowStatus = 0
