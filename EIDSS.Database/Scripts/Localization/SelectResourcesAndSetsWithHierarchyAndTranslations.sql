
IF OBJECT_ID('tempdb..#Hierarchy') IS NOT NULL
BEGIN
	exec sp_executesql N'drop table #Hierarchy'
END


IF OBJECT_ID('tempdb..#Hierarchy') IS  NULL
create table #Hierarchy
(	idfHierarchy bigint not null primary key,
	Lvl hierarchyid not null, 
	SelectedRootLvl hierarchyid not null, 
	StepParentLvl hierarchyid null, 
	StepParentIndex int not null, 
	idfsResourceSet bigint not null, 
	strResourceSet nvarchar(200) collate Cyrillic_General_CI_AS null, 
	strResourceSetUnique nvarchar(200) collate Cyrillic_General_CI_AS null, 
	StepResourceSetPath nvarchar(2000) collate Cyrillic_General_CI_AS null, 
	IncludeSelf bit not null default(0)
)
truncate table #Hierarchy


IF OBJECT_ID('tempdb..#Root') IS NOT NULL
BEGIN
	exec sp_executesql N'drop table #Root'
END


IF OBJECT_ID('tempdb..#Root') IS  NULL
create table #Root
( rootHId hierarchyid
)
truncate table #Root


insert into #Root (rootHId)
select t.ResourceSetNode
from trtResourceSetHierarchy t
where t.idfResourceHierarchy between 1 and 9

declare @IncludeSelf bit = 1


;
 WITH cte
	(
        idfHierarchy, Lvl, SelectedRootLvl, StepParentLvl, StepParentIndex, idfsResourceSet, strResourceSet, strResourceSetUnique, StepResourceSetPath, IncludeSelf
    )
AS	(
		select child.idfResourceHierarchy, child.ResourceSetNode, selectedRoot.ResourceSetNode, child.ResourceSetNode.GetAncestor(1), 0, s_child.idfsResourceSet, s_child.strResourceSet, s_child.strResourceSetUnique, cast(isnull(s_child.strResourceSetUnique, s_child.strResourceSet) as nvarchar(2000)), @IncludeSelf
		from trtResourceSetHierarchy as selectedRoot
		inner join #Root as rootItem
		on rootItem.rootHId = selectedRoot.ResourceSetNode
		inner join trtResourceSetHierarchy as child
		   on child.ResourceSetNode.IsDescendantOf(
			   selectedRoot.ResourceSetNode
		   ) = 1
		inner join trtResourceSet s_child
		on s_child.idfsResourceSet = child.idfsResourceSet
		where (@IncludeSelf = 1 or (child.ResourceSetNode <> selectedRoot.ResourceSetNode)) and child.intRowStatus = 0
		union all
		select	cte.idfHierarchy, cte.Lvl, cte.SelectedRootLvl, stepParent.ResourceSetNode.GetAncestor(1), cte.StepParentIndex + 1, cte.idfsResourceSet, cte.strResourceSet, cte.strResourceSetUnique, cast((isnull(s_stepParent.strResourceSet, s_stepParent.strResourceSet) + N'>' + cte.StepResourceSetPath) as nvarchar(2000)), cte.IncludeSelf
		from	trtResourceSetHierarchy as stepParent
		inner join trtResourceSet s_stepParent
		on s_stepParent.idfsResourceSet = stepParent.idfsResourceSet
		inner join	cte
		on	cte.StepParentLvl = stepParent.ResourceSetNode
		where stepParent.intRowStatus = 0
	)


	insert into #Hierarchy (idfHierarchy, Lvl, SelectedRootLvl, StepParentLvl, StepParentIndex, idfsResourceSet, strResourceSet, strResourceSetUnique, StepResourceSetPath, IncludeSelf)
	select idfHierarchy, Lvl, SelectedRootLvl, StepParentLvl, StepParentIndex, idfsResourceSet, strResourceSet, strResourceSetUnique, StepResourceSetPath, IncludeSelf
	from cte
	where StepParentLvl = '/'
	order by Lvl

	-- Declare lanhuages
	declare @idfsLanguageGG bigint
	set @idfsLanguageGG = dbo.FN_GBL_LanguageCode_GET('ka-GE')

	declare @idfsLanguageAZ bigint
	set @idfsLanguageAZ = dbo.FN_GBL_LanguageCode_GET('az-Latn-AZ')

	declare @idfsLanguageRU bigint
	set @idfsLanguageRU = dbo.FN_GBL_LanguageCode_GET('ru-RU')

	select		rs.idfsResourceSet as 'Resource Set (System Id) - No Merge',
				case
					when	h_rownumber.intRowNum <= 1
						then	cast(rs.idfsResourceSet as varchar(20))
					else	''
				end as 'Resource Set (System Id)',
				isnull(cast(h.idfHierarchy as varchar(20)), 'N/A') as 'Hierarchy Item (System Id)',
				case
					when	h_rownumber.intRowNum >= 1
						then isnull(cast(h_rownumber.intRowNum as varchar(20)), '')
					else	N'N/A'
				end as 'Hierarchy Item Number',
				case
					when	h_rownumber.intRowNum >= 1
						then	ISNULL(h.StepResourceSetPath, N'')
					else	N'N/A'
				end as 'Hierarchy Path',
				case
					when	h_rownumber.intRowNum <= 1
						then	coalesce(rs.strResourceSetUnique, rs.strResourceSet, N'')
					else	N''
				end as 'Resource Set Unique Name (EN)',
				case
					when	h_rownumber.intRowNum <= 1 and (rs.strResourceSetUnique is null or rs.strResourceSet <> rs.strResourceSetUnique collate Cyrillic_General_CI_AS)
						then	ISNULL(rs.strResourceSet, N'')
					else	N''
				end as 'Resource Set Name (EN)',
				case
					when	h_rownumber.intRowNum <= 1
						then	ISNULL(rst_gg.strTextString, N'')
					else	N''
				end as 'Resource Set Name Translation (GE)',
				case
					when	h_rownumber.intRowNum <= 1 and rst_gg.intRowStatus <> 0
						then	N'Marked as deleted'
					else	N''
				end as 'Translation Status (GE)',
				case
					when	h_rownumber.intRowNum <= 1
						then	ISNULL(rst_az.strTextString, N'')
					else	N''
				end as 'Resource Set Name Translation (AZ)',
				case
					when	h_rownumber.intRowNum <= 1 and rst_az.intRowStatus <> 0
						then	N'Marked as deleted'
					else	N''
				end as 'Translation Status (AZ)',
				case
					when	h_rownumber.intRowNum <= 1
						then	ISNULL(rst_ru.strTextString, N'')
					else	N''
				end as 'Resource Set Name Translation (RU)',
				case
					when	h_rownumber.intRowNum <= 1 and rst_ru.intRowStatus <> 0
						then	N'Marked as deleted'
					else	N''
				end as 'Translation Status (RU)'
	from		trtResourceSet rs
	left join	#Hierarchy h
	on			h.idfsResourceSet = rs.idfsResourceSet
	outer apply
	(	select		COUNT(h_count.Lvl) as intRowNum
		from		#Hierarchy h_count
		where		h_count.idfsResourceSet = h.idfsResourceSet
					and h_count.idfHierarchy <= h.idfHierarchy
	) h_rownumber
	left join	trtResourceSetTranslation rst_gg
	on			rst_gg.idfsResourceSet = rs.idfsResourceSet
				and rst_gg.idfsLanguage = @idfsLanguageGG
	left join	trtResourceSetTranslation rst_az
	on			rst_az.idfsResourceSet = rs.idfsResourceSet
				and rst_az.idfsLanguage = @idfsLanguageAZ
	left join	trtResourceSetTranslation rst_ru
	on			rst_ru.idfsResourceSet = rs.idfsResourceSet
				and rst_ru.idfsLanguage = @idfsLanguageRU
	where		rs.intRowStatus = 0
	order by	rs.idfsResourceSet, h_rownumber.intRowNum

	--select *
	--from trtResourceSet rs
	--left join #Hierarchy h
	--on h.idfsResourceSet = rs.idfsResourceSet
	--where h.idfsResourceSet is null

	--select *
	--from trtResourceSet rs
	--left join trtResourceSetHierarchy h
	--on h.idfsResourceSet = rs.idfsResourceSet
	--where h.idfsResourceSet is null

	select		r.idfsResource as 'Resource (System Id) - No Merge',
				case
					when	h_rownumber.intRowNum <= 1
						then	cast(r.idfsResource as varchar(20))
					else	''
				end as 'Resource (System Id)',
				case
					when	h_rownumber.intRowNum >= 1
						then isnull(cast(h_rownumber.intRowNum as varchar(20)), '')
					else	N'N/A'
				end as 'Hierarchy Item Number',
				case
					when	h_rownumber.intRowNum >= 1
						then	coalesce(h.StepResourceSetPath, rs.strResourceSetUnique, rs.strResourceSet, N'')
					else	N'N/A'
				end as 'Resource Set Hierarchy Path',
				case
					when	h_rownumber.intRowNum <= 1
						then	ISNULL(r_type.strDefault, N'')
					else	N''
				end as 'Resource Type',
				case
					when	h_rownumber.intRowNum <= 1
						then	ISNULL(r.strResourceName, N'')
					else	N''
				end as 'Resource Name (EN)',
				case
					when	h_rownumber.intRowNum >= 1
						then	replace(replace(isnull(CAST(rs_to_r.isHidden as nvarchar(20)), N''), N'0', N''), N'1', N'Hidden')
					else	N'N/A'
				end as 'Hidden in the Resource Set',
				case
					when	h_rownumber.intRowNum >= 1
						then	replace(replace(isnull(CAST(rs_to_r.isRequired as nvarchar(20)), N''), N'0', N''), N'1', N'Mandatory')
					else	N'N/A'
				end as 'Mandatory in the Resource Set',
				case
					when	h_rownumber.intRowNum >= 1
						then	replace(replace(isnull(CAST(rs_to_r.canEdit as nvarchar(20)), N''), N'1', N''), N'0', N'Not Editable')
					else	N'N/A'
				end as 'Editable in the Resource Set',
				case
					when	h_rownumber.intRowNum <= 1
						then	ISNULL(rt_gg.strResourceString, N'')
					else	N''
				end as 'Resource Name Translation (GE)',
				case
					when	h_rownumber.intRowNum <= 1 and rt_gg.intRowStatus <> 0
						then	N'Marked as deleted'
					else	N''
				end as 'Translation Status (GE)',
				case
					when	h_rownumber.intRowNum <= 1
						then	ISNULL(rt_az.strResourceString, N'')
					else	N''
				end as 'Resource Name Translation (AZ)',
				case
					when	h_rownumber.intRowNum <= 1 and rt_az.intRowStatus <> 0
						then	N'Marked as deleted'
					else	N''
				end as 'Translation Status (AZ)',
				case
					when	h_rownumber.intRowNum <= 1
						then	ISNULL(rt_ru.strResourceString, N'')
					else	N''
				end as 'Resource Name Translation (RU)',
				case
					when	h_rownumber.intRowNum <= 1 and rt_ru.intRowStatus <> 0
						then	N'Marked as deleted'
					else	N''
				end as 'Translation Status (RU)'
	from		trtResource r
	left join	trtBaseReference r_type
	on			r_type.idfsBaseReference = r.idfsResourceType
	left join	trtResourceTranslation rt_gg
	on			rt_gg.idfsResource = r.idfsResource
				and rt_gg.idfsLanguage = @idfsLanguageGG
	left join	trtResourceTranslation rt_az
	on			rt_az.idfsResource = r.idfsResource
				and rt_az.idfsLanguage = @idfsLanguageAZ
	left join	trtResourceTranslation rt_ru
	on			rt_ru.idfsResource = r.idfsResource
				and rt_ru.idfsLanguage = @idfsLanguageRU
	left join	trtResourceSetToResource rs_to_r
		inner join	trtResourceSet rs
		on			rs.idfsResourceSet = rs_to_r.idfsResourceSet
					and rs.intRowStatus = 0
		left join	#Hierarchy h
		on			h.idfsResourceSet = rs.idfsResourceSet
	on			rs_to_r.idfsResource = r.idfsResource
				and rs_to_r.intRowStatus = 0
	outer apply
	(	select	count(*) as intRowNum
		from	trtResourceSetToResource rs_to_r_count
		inner join	trtResourceSet rs_count
		on			rs_count.idfsResourceSet = rs_to_r_count.idfsResourceSet
					and rs_count.intRowStatus = 0
		left join	#Hierarchy h_count
		on			h_count.idfsResourceSet = rs_count.idfsResourceSet
		where	rs_to_r_count.intRowStatus = 0
				and rs_to_r_count.idfsResource = r.idfsResource
				and (	rs_to_r_count.idfsResourceSet < rs_to_r.idfsResourceSet
						or	(	rs_to_r_count.idfsResourceSet = rs_to_r.idfsResourceSet
								and	(	(h_count.idfHierarchy is null and h.idfHierarchy is null)
										or h_count.idfHierarchy <= h.idfHierarchy
									)
							)
					)
	) h_rownumber
	where		r.intRowStatus = 0
	order by	r.idfsResource, h_rownumber.intRowNum	