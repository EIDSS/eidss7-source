
/**************************************************************************************************************************************
* Check script of data migration results: FF Values of type HCS in Human Cases v6.1 and HDRs v7 with templates, determinants, 
* FF parameters in and out of templates, their section paths, names, tooltips, types and orders, FF grid row numbers, and FF values.
* Execute script on any database, e.g. master, on the server, where both databases of EIDSS v6.1 and v7 are located.
* By default, in the script EIDSSv6.1 database has the name Falcon, and EIDSSv7 database has the name Giraffe.
**************************************************************************************************************************************/

declare	@strNationalLng nvarchar(200)
set @strNationalLng = N'' -- Georgian - ka, Azerbaijani - az-L

declare	@intLngEn bigint
declare @intLngNat bigint

set @intLngEn = [Falcon].dbo.fnGetLanguageCode('en')
set @intLngNat = [Falcon].dbo.fnGetLanguageCode(@strNationalLng)

if @intLngNat is null
	set	@intLngNat = @intLngEn


declare	@FormTypeEN	nvarchar(2000)
set	@FormTypeEN = N'Human Clinical Signs'
declare	@idfsFormType bigint
select	@idfsFormType = r_ft_v6.[idfsReference]
from	[Falcon].dbo.fnReference('en', 19000034 /*Flexible Form Type*/) r_ft_v6
where	r_ft_v6.[name] = @FormTypeEN collate Cyrillic_General_CI_AS


declare	@AllSectionsV6	table
(	idfsSection			bigint not null primary key,
	idfsParentSection	bigint null,
	blnIsGrid			bit not null,
	strSectionEN		nvarchar(2000) collate Cyrillic_General_CI_AS not null,
	strSectionLng		nvarchar(2000) collate Cyrillic_General_CI_AS not null,
	intRowStatus		int not null
)

declare	@AllParametersV6	table
(	idfsParameter		bigint not null primary key,
	idfsFormType		bigint not null,
	idfsSection			bigint null,
	idfsRootGridSection	bigint null,
	idfsParameterType	bigint not null,
	idfsReferenceType	bigint null,
	FormType			nvarchar(300) collate Cyrillic_General_CI_AS not null,
	blnIsGrid			bit not null,
	ParameterNameEN		nvarchar(600) collate Cyrillic_General_CI_AS not null,
	ParameterNameLng	nvarchar(1000) collate Cyrillic_General_CI_AS not null,
	ParameterType		nvarchar(300) collate Cyrillic_General_CI_AS not null,
	ReferenceType		nvarchar(300) collate Cyrillic_General_CI_AS null,
	TooltipEN			nvarchar(600) collate Cyrillic_General_CI_AS not null,
	TooltipLng			nvarchar(1000) collate Cyrillic_General_CI_AS not null,
	SectionPathEN		nvarchar(1000) collate Cyrillic_General_CI_AS not null,
	SectionPathLng		nvarchar(1000) collate Cyrillic_General_CI_AS not null,
	SectionNameEN		nvarchar(300) collate Cyrillic_General_CI_AS not null,
	SectionNameLng		nvarchar(300) collate Cyrillic_General_CI_AS not null,
	Editor				nvarchar(100) collate Cyrillic_General_CI_AS not null,
	intRowStatus		int not null
)



declare	@SectionTableV6 table
(	idfsSection						bigint not null,
	intParentLevel					int not null,
	idfsLevelSection				bigint null,
	idfsLevelParentSection			bigint null,
	blnIsLevelSectionGrid			bit not null,
	blnIsSectionGrid				bit not null,
	strSectionEN					nvarchar(2000) collate Cyrillic_General_CI_AS not null,
	strSectionLng					nvarchar(2000) collate Cyrillic_General_CI_AS not null,
	strLevelSectionPathEN			nvarchar(MAX) collate Cyrillic_General_CI_AS not null,
	strLevelSectionPathLng			nvarchar(MAX) collate Cyrillic_General_CI_AS not null,
	intRowStatus					int not null,
	primary key
	(	idfsSection asc,
		intParentLevel asc
	)
)

declare	@ParametersTableV6	table
(	idfsParameter					bigint not null,
	idfsFormTemplate				bigint null,
	idfsFormType					bigint not null,
	idfsSection						bigint null,
	idfsRootGridSection				bigint null,
	idfsParameterType				bigint not null,
	idfsReferenceType				bigint null,
	FormType						nvarchar(300) collate Cyrillic_General_CI_AS not null,
	TemplateEN						nvarchar(300) collate Cyrillic_General_CI_AS not null,
	TemplateLng						nvarchar(300) collate Cyrillic_General_CI_AS not null,
	blnIsGrid						bit not null,
	ParameterOrderInTemplate		int not null,
	ParameterTop					int not null,
	FinalParameterOrderInTemplate	int not null,
	ParameterNameEN					nvarchar(600) collate Cyrillic_General_CI_AS not null,
	ParameterNameLng				nvarchar(1000) collate Cyrillic_General_CI_AS not null,
	ParameterType					nvarchar(300) collate Cyrillic_General_CI_AS not null,
	ReferenceType					nvarchar(300) collate Cyrillic_General_CI_AS null,
	TooltipEN						nvarchar(600) collate Cyrillic_General_CI_AS not null,
	TooltipLng						nvarchar(1000) collate Cyrillic_General_CI_AS not null,
	SectionPathEN					nvarchar(1000) collate Cyrillic_General_CI_AS not null,
	SectionPathLng					nvarchar(1000) collate Cyrillic_General_CI_AS not null,
	SectionNameEN					nvarchar(300) collate Cyrillic_General_CI_AS not null,
	SectionNameLng					nvarchar(300) collate Cyrillic_General_CI_AS not null,
	Editor							nvarchar(100) collate Cyrillic_General_CI_AS not null,
	Mode							nvarchar(100) collate Cyrillic_General_CI_AS not null,
	intRowStatus					int not null,
	primary key
	(	TemplateEN,
		ParameterOrderInTemplate,
		Parametertop
	)
)




declare	@AllSectionsV7	table
(	idfsSection			bigint not null primary key,
	idfsParentSection	bigint null,
	blnIsGrid			bit not null,
	strSectionEN		nvarchar(2000) collate Cyrillic_General_CI_AS not null,
	strSectionLng		nvarchar(2000) collate Cyrillic_General_CI_AS not null,
	intRowStatus		int not null
)

declare	@AllParametersV7	table
(	idfsParameter		bigint not null primary key,
	idfsFormType		bigint not null,
	idfsSection			bigint null,
	idfsRootGridSection	bigint null,
	idfsParameterType	bigint not null,
	idfsReferenceType	bigint null,
	FormType			nvarchar(300) collate Cyrillic_General_CI_AS not null,
	blnIsGrid			bit not null,
	ParameterNameEN		nvarchar(600) collate Cyrillic_General_CI_AS not null,
	ParameterNameLng	nvarchar(1000) collate Cyrillic_General_CI_AS not null,
	ParameterType		nvarchar(300) collate Cyrillic_General_CI_AS not null,
	ReferenceType		nvarchar(300) collate Cyrillic_General_CI_AS null,
	TooltipEN			nvarchar(600) collate Cyrillic_General_CI_AS not null,
	TooltipLng			nvarchar(1000) collate Cyrillic_General_CI_AS not null,
	SectionPathEN		nvarchar(1000) collate Cyrillic_General_CI_AS not null,
	SectionPathLng		nvarchar(1000) collate Cyrillic_General_CI_AS not null,
	SectionNameEN		nvarchar(300) collate Cyrillic_General_CI_AS not null,
	SectionNameLng		nvarchar(300) collate Cyrillic_General_CI_AS not null,
	Editor				nvarchar(100) collate Cyrillic_General_CI_AS not null,
	intRowStatus		int not null
)



declare	@SectionTableV7 table
(	idfsSection						bigint not null,
	intParentLevel					int not null,
	idfsLevelSection				bigint null,
	idfsLevelParentSection			bigint null,
	blnIsLevelSectionGrid			bit not null,
	blnIsSectionGrid				bit not null,
	strSectionEN					nvarchar(2000) collate Cyrillic_General_CI_AS not null,
	strSectionLng					nvarchar(2000) collate Cyrillic_General_CI_AS not null,
	strLevelSectionPathEN			nvarchar(MAX) collate Cyrillic_General_CI_AS not null,
	strLevelSectionPathLng			nvarchar(MAX) collate Cyrillic_General_CI_AS not null,
	intRowStatus					int not null,
	primary key
	(	idfsSection asc,
		intParentLevel asc
	)
)

declare	@ParametersTableV7	table
(	idfsParameter					bigint not null,
	idfsFormTemplate				bigint null,
	idfsFormType					bigint not null,
	idfsSection						bigint null,
	idfsRootGridSection				bigint null,
	idfsParameterType				bigint not null,
	idfsReferenceType				bigint null,
	FormType						nvarchar(300) collate Cyrillic_General_CI_AS not null,
	TemplateEN						nvarchar(300) collate Cyrillic_General_CI_AS not null,
	TemplateLng						nvarchar(300) collate Cyrillic_General_CI_AS not null,
	blnIsGrid						bit not null,
	ParameterOrderInTemplate		int not null,
	ParameterTop					int not null,
	FinalParameterOrderInTemplate	int not null,
	ParameterNameEN					nvarchar(600) collate Cyrillic_General_CI_AS not null,
	ParameterNameLng				nvarchar(1000) collate Cyrillic_General_CI_AS not null,
	ParameterType					nvarchar(300) collate Cyrillic_General_CI_AS not null,
	ReferenceType					nvarchar(300) collate Cyrillic_General_CI_AS null,
	TooltipEN						nvarchar(600) collate Cyrillic_General_CI_AS not null,
	TooltipLng						nvarchar(1000) collate Cyrillic_General_CI_AS not null,
	SectionPathEN					nvarchar(1000) collate Cyrillic_General_CI_AS not null,
	SectionPathLng					nvarchar(1000) collate Cyrillic_General_CI_AS not null,
	SectionNameEN					nvarchar(300) collate Cyrillic_General_CI_AS not null,
	SectionNameLng					nvarchar(300) collate Cyrillic_General_CI_AS not null,
	Editor							nvarchar(100) collate Cyrillic_General_CI_AS not null,
	Mode							nvarchar(100) collate Cyrillic_General_CI_AS not null,
	intRowStatus					int not null,
	primary key
	(	TemplateEN,
		ParameterOrderInTemplate,
		Parametertop
	)
)


declare	@Differences table
(	idfId int not null primary key,
	strDifference nvarchar(200) collate Cyrillic_General_CI_AS not null
)



insert into	@AllSectionsV6
(	idfsSection,
	idfsParentSection,
	blnIsGrid,
	strSectionEN,
	strSectionLng,
	intRowStatus
)
select		s_v6.idfsSection,
			s_parent_v6.idfsSection,
			IsNull(s_v6.blnGrid, 0),
			coalesce(s_en_v6.strTextString, sBR_v6.strDefault, N''),
			coalesce(s_lng_v6.strTextString, sBR_v6.strDefault, N''),
			s_v6.intRowStatus
from

-- Section
			[Falcon].[dbo].[ffSection] s_v6
left join	[Falcon].[dbo].[trtBaseReference] sBR_v6
on			sBR_v6.[idfsBaseReference] = s_v6.[idfsSection]
			and sBR_v6.[idfsReferenceType] = 19000101 /*Flexible Form Section*/
left join	[Falcon].[dbo].[trtStringNameTranslation] s_en_v6
on			s_en_v6.[idfsBaseReference] = s_v6.[idfsSection]
			and s_en_v6.[idfsLanguage] = @intLngEn
left join	[Falcon].[dbo].[trtStringNameTranslation] s_lng_v6
on			s_lng_v6.[idfsBaseReference] = s_v6.[idfsSection]
			and s_lng_v6.[idfsLanguage] = @intLngNat
			
-- Parent Section
left join	(
	[Falcon].[dbo].[ffSection] s_parent_v6

	left join	[Falcon].[dbo].[trtBaseReference] s_parentBR_v6
	on			s_parentBR_v6.[idfsBaseReference] = s_parent_v6.[idfsSection]
				and s_parentBR_v6.[idfsReferenceType] = 19000101 /*Flexible Form Section*/
	left join	[Falcon].[dbo].[trtStringNameTranslation] s_parent_en_v6
	on			s_parent_en_v6.[idfsBaseReference] = s_parent_v6.[idfsSection]
				and s_parent_en_v6.[idfsLanguage] = @intLngEn
	left join	[Falcon].[dbo].[trtStringNameTranslation] s_parent_lng_v6
	on			s_parent_lng_v6.[idfsBaseReference] = s_parent_v6.[idfsSection]
				and s_parent_lng_v6.[idfsLanguage] = @intLngNat
			)
on			s_parent_v6.[idfsSection] = s_v6.[idfsParentSection]


;
with	sectionTableV6	(
			idfsSection,
			intParentLevel,
			idfsLevelSection,
			idfsLevelParentSection,
			blnIsLevelSectionGrid,
			blnIsSectionGrid,
			strSectionEN,
			strSectionLng,
			strLevelSectionPathEN,
			strLevelSectionPathLng,
			intRowStatus
					)
as	(	select		s.idfsSection,
					0 as intParentLevel,
					s.idfsSection as idfsLevelSection,
					s.idfsParentSection as idfsLevelParentSection,
					s.blnIsGrid as blnIsLevelSectionGrid,
					s.blnIsGrid as blnIsSectionGrid,
					s.strSectionEN,
					s.strSectionLng,
					cast(s.strSectionEN as nvarchar(MAX)) as strLevelSectionPathEN,
					cast(s.strSectionLng as nvarchar(MAX)) as strLevelSectionPathLng,
					s.intRowStatus
		from		@AllSectionsV6 s
		union all
		select		sectionTableV6.idfsSection,
					sectionTableV6.intParentLevel + 1 as intParentLevel,
					s_all.idfsSection as idfsLevelSection,
					s_all.idfsParentSection as idfsLevelParentSection,
					s_all.blnIsGrid as blnIsLevelSectionGrid,
					sectionTableV6.blnIsSectionGrid,
					sectionTableV6.strSectionEN,
					sectionTableV6.strSectionLng,
					cast((s_all.strSectionEN + N'>' + sectionTableV6.strLevelSectionPathEN) as nvarchar(MAX)) as strLevelSectionPathEN,
					cast((s_all.strSectionLng + N'>' + sectionTableV6.strLevelSectionPathLng) as nvarchar(MAX)) as strLevelSectionPathLng,
					sectionTableV6.intRowStatus
		from		@AllSectionsV6 s_all
		inner join	sectionTableV6
		on			sectionTableV6.idfsLevelParentSection = s_all.idfsSection
	)

insert into	@SectionTableV6
(	idfsSection,
	intParentLevel,
	idfsLevelSection,
	idfsLevelParentSection,
	blnIsLevelSectionGrid,
	blnIsSectionGrid,
	strSectionEN,
	strSectionLng,
	strLevelSectionPathEN,
	strLevelSectionPathLng,
	intRowStatus
)
select		idfsSection,
			intParentLevel,
			idfsLevelSection,
			idfsLevelParentSection,
			blnIsLevelSectionGrid,
			blnIsSectionGrid,
			strSectionEN,
			strSectionLng,
			strLevelSectionPathEN,
			strLevelSectionPathLng,
			intRowStatus
from		sectionTableV6


insert into	@AllParametersV6
(	idfsParameter,
	idfsFormType,
	idfsSection,
	idfsRootGridSection,
	idfsParameterType,
	idfsReferenceType,
	FormType,
	blnIsGrid,
	ParameterNameEN,
	ParameterNameLng,
	ParameterType,
	ReferenceType,
	TooltipEN,
	TooltipLng,
	SectionPathEN,
	SectionPathLng,
	SectionNameEN,
	SectionNameLng,
	Editor,
	intRowStatus
)
select		p_v6.idfsParameter,
			@idfsFormType,
			p_v6.idfsSection,
			st_root_grid_v6.idfsLevelSection,
			p_v6.idfsParameterType,
			pt_v6.idfsReferenceType,
			@FormTypeEN as FormType,
			IsNull(st_max_v6.blnIsSectionGrid, 0), 
			coalesce(p_caption_en_v6.strTextString, p_captionBR_v6.strDefault, N'') as ParameterNameEN,
			coalesce(p_caption_lng_v6.strTextString, p_captionBR_v6.strDefault, N'') as ParameterNameLng,
			coalesce(pt_en_v6.strTextString, ptBR_v6.strDefault, N'') as ParameterType,
			coalesce(rt_en_v6.strTextString, rtBR_v6.strDefault, rt_v6.strReferenceTypeName, N'') as ReferenceType,
			coalesce(p_en_v6.strTextString, pBR_v6.strDefault, N'') as TooltipEN,
			coalesce(p_lng_v6.strTextString, pBR_v6.strDefault, N'') as TooltipLng,
			IsNull(st_max_v6.strLevelSectionPathEN, N'None') as SectionPathEN,
			IsNull(st_max_v6.strLevelSectionPathLng, N'None') as SectionPathLng,
			IsNull(st_max_v6.strSectionEN, N'None') as SectionNameEN,
			IsNull(st_max_v6.strSectionLng, N'None') as SectionNameLng,
			coalesce(p_editor_en_v6.strTextString, p_editorBR_v6.strDefault, N'None') as Editor,
			p_v6.[intRowStatus]
from		
-- Parameter
			[Falcon].[dbo].[ffParameter] p_v6

left join	[Falcon].[dbo].[trtBaseReference] pBR_v6
on			pBR_v6.[idfsBaseReference] = p_v6.[idfsParameter]
			and pBR_v6.[idfsReferenceType] = 19000066 /*Flexible Form Parameter Tooltip*/
left join	[Falcon].[dbo].[trtStringNameTranslation] p_en_v6
on			p_en_v6.[idfsBaseReference] = p_v6.[idfsParameter]
			and p_en_v6.[idfsLanguage] = @intLngEn
left join	[Falcon].[dbo].[trtStringNameTranslation] p_lng_v6
on			p_lng_v6.[idfsBaseReference] = p_v6.[idfsParameter]
			and p_lng_v6.[idfsLanguage] = @intLngNat


left join	[Falcon].[dbo].[trtBaseReference] p_captionBR_v6
on			p_captionBR_v6.[idfsBaseReference] = p_v6.[idfsParameterCaption]
			and p_captionBR_v6.[idfsReferenceType] = 19000070 /*Flexible Form Parameter Caption*/
left join	[Falcon].[dbo].[trtStringNameTranslation] p_caption_en_v6
on			p_caption_en_v6.[idfsBaseReference] = p_v6.[idfsParameterCaption]
			and p_caption_en_v6.[idfsLanguage] = @intLngEn
left join	[Falcon].[dbo].[trtStringNameTranslation] p_caption_lng_v6
on			p_caption_lng_v6.[idfsBaseReference] = p_v6.[idfsParameterCaption]
			and p_caption_lng_v6.[idfsLanguage] = @intLngNat


left join	[Falcon].[dbo].[ffParameterType] pt_v6
on			pt_v6.[idfsParameterType] = p_v6.[idfsParameterType]
left join	[Falcon].[dbo].[trtBaseReference] ptBR_v6
on			ptBR_v6.[idfsBaseReference] = p_v6.[idfsParameterType]
			and ptBR_v6.[idfsReferenceType] = 19000071 /*Flexible Form Parameter Type*/
left join	[Falcon].[dbo].[trtStringNameTranslation] pt_en_v6
on			pt_en_v6.[idfsBaseReference] = p_v6.[idfsParameterType]
			and pt_en_v6.[idfsLanguage] = @intLngEn
left join	[Falcon].[dbo].[trtStringNameTranslation] pt_lng_v6
on			pt_lng_v6.[idfsBaseReference] = p_v6.[idfsParameterType]
			and pt_lng_v6.[idfsLanguage] = @intLngNat

left join	[Falcon].[dbo].[trtReferenceType] rt_v6
on			rt_v6.[idfsReferenceType] = pt_v6.[idfsReferenceType]
left join	[Falcon].[dbo].[trtBaseReference] rtBR_v6
on			rtBR_v6.[idfsBaseReference] = pt_v6.[idfsReferenceType]
			and rtBR_v6.[idfsReferenceType] = 19000076 /*Reference Type Name*/
left join	[Falcon].[dbo].[trtStringNameTranslation] rt_en_v6
on			rt_en_v6.[idfsBaseReference] = pt_v6.[idfsReferenceType]
			and rt_en_v6.[idfsLanguage] = @intLngEn
left join	[Falcon].[dbo].[trtStringNameTranslation] rt_lng_v6
on			rt_lng_v6.[idfsBaseReference] = pt_v6.[idfsReferenceType]
			and rt_lng_v6.[idfsLanguage] = @intLngNat

-- Parameter attributes
left join	[Falcon].[dbo].[trtBaseReference] p_editorBR_v6
on			p_editorBR_v6.[idfsBaseReference] = p_v6.[idfsEditor]
			and p_editorBR_v6.[idfsReferenceType] = 19000067 /*Flexible Form Parameter Editor*/
left join	[Falcon].[dbo].[trtStringNameTranslation] p_editor_en_v6
on			p_editor_en_v6.[idfsBaseReference] = p_v6.[idfsEditor]
			and p_editor_en_v6.[idfsLanguage] = @intLngEn


left join	@SectionTableV6 st_max_v6
on			st_max_v6.[idfsSection] = p_v6.[idfsSection]
			and st_max_v6.[idfsLevelParentSection] is null
			and st_max_v6.[intRowStatus] = 0

left join	@SectionTableV6 st_root_grid_v6
on			st_root_grid_v6.[idfsSection] = p_v6.[idfsSection]
			and st_root_grid_v6.[blnIsLevelSectionGrid] = 1
			and st_root_grid_v6.[intRowStatus] = 0
			and not exists
					(	select	1
						from	@SectionTableV6 st_higherlevel_grid_v6
						where	st_higherlevel_grid_v6.[idfsSection] = st_root_grid_v6.idfsSection
								and st_higherlevel_grid_v6.[blnIsLevelSectionGrid] = 1
								and st_higherlevel_grid_v6.[intRowStatus] = 0
								and st_higherlevel_grid_v6.[intParentLevel] > st_root_grid_v6.[intParentLevel]
					)

where		p_v6.[idfsFormType] = @idfsFormType



insert into	@ParametersTableV6
(	idfsParameter,
	idfsFormTemplate,
	idfsFormType,
	idfsSection,
	idfsRootGridSection,
	idfsParameterType,
	idfsReferenceType,
	FormType,
	TemplateEN,
	TemplateLng,
	blnIsGrid,
	ParameterOrderInTemplate,
	ParameterTop,
	FinalParameterOrderInTemplate,
	ParameterNameEN,
	ParameterNameLng,
	ParameterType,
	ReferenceType,
	TooltipEN,
	TooltipLng,
	SectionPathEN,
	SectionPathLng,
	SectionNameEN,
	SectionNameLng,
	Editor,
	Mode,
	intRowStatus
)
select		p_v6.idfsParameter,
			t_v6.idfsFormTemplate,
			@idfsFormType,
			p_v6.idfsSection,
			st_root_grid_v6.idfsLevelSection,
			p_v6.idfsParameterType,
			pt_v6.idfsReferenceType,
			@FormTypeEN as FormType,
			coalesce(t_en_v6.strTextString, tBR_v6.strDefault, N'') as TemplateEN,
			coalesce(t_lng_v6.strTextString, tBR_v6.strDefault, N'') as TemplateLng,
			IsNull(st_max_v6.blnIsSectionGrid, 0), 
			coalesce(pdo_v6.intOrder, pdo_def_v6.intOrder, 0) as ParameterOrderInTemplate, 
			IsNull	(
				(	select		sum(IsNull(sdo_parent_v6.intTop, 0))
					from		@SectionTableV6 st_sdo_v6
					inner join	[Falcon].[dbo].[ffSectionDesignOption] sdo_parent_v6
					on			sdo_parent_v6.[idfsSection] = st_sdo_v6.[idfsLevelParentSection]
								and sdo_parent_v6.[idfsFormTemplate] = t_v6.[idfsFormTemplate]
								and sdo_parent_v6.idfsLanguage = @intLngEn
								and sdo_parent_v6.[intRowStatus] = 0
					where		st_sdo_v6.[idfsSection] = p_v6.[idfsSection]
				), 0
					) + IsNull(sdo_v6.intTop, 0) + (1 - IsNull(st_max_v6.blnIsSectionGrid, 0)) * coalesce(pdo_v6.intTop, pdo_def_v6.intTop, 0) as ParameterTop,
			0,
			coalesce(p_caption_en_v6.strTextString, p_captionBR_v6.strDefault, N'') as ParameterNameEN,
			coalesce(p_caption_lng_v6.strTextString, p_captionBR_v6.strDefault, N'') as ParameterNameLng,
			coalesce(pt_en_v6.strTextString, ptBR_v6.strDefault, N'') as ParameterType,
			coalesce(rt_en_v6.strTextString, rtBR_v6.strDefault, rt_v6.strReferenceTypeName, N'') as ReferenceType,
			coalesce(p_en_v6.strTextString, pBR_v6.strDefault, N'') as TooltipEN,
			coalesce(p_lng_v6.strTextString, pBR_v6.strDefault, N'') as TooltipLng,
			IsNull(st_max_v6.strLevelSectionPathEN, N'None') as SectionPathEN,
			IsNull(st_max_v6.strLevelSectionPathLng, N'None') as SectionPathLng,
			IsNull(st_max_v6.strSectionEN, N'None') as SectionNameEN,
			IsNull(st_max_v6.strSectionLng, N'None') as SectionNameLng,
			coalesce(p_editor_en_v6.strTextString, p_editorBR_v6.strDefault, N'None') as Editor,
			replace	(
				replace	(
					IsNull(cast(pft_v6.idfsEditMode as nvarchar(20)), N'None'),
					N'10068003',
					N'Mandatory'
						),
				N'10068001',
				N'Ordinary'
					) as Mode,
			p_v6.[intRowStatus]
from
-- Parameters in templates		
			[Falcon].[dbo].[ffParameter] p_v6
inner join	[Falcon].[dbo].[ffParameterforTemplate] pft_v6
on			pft_v6.[idfsParameter] = p_v6.[idfsParameter]
			and pft_v6.[intRowStatus] = 0
inner join	[Falcon].[dbo].[ffFormTemplate] t_v6
on			t_v6.[idfsFormTemplate] = pft_v6.[idfsFormTemplate]
			and t_v6.[intRowStatus] = 0

left join	[Falcon].[dbo].[trtBaseReference] tBR_v6
on			tBR_v6.[idfsBaseReference] = t_v6.[idfsFormTemplate]
			and tBR_v6.[idfsReferenceType] = 19000033 /*Flexible Form Template*/
left join	[Falcon].[dbo].[trtStringNameTranslation] t_en_v6
on			t_en_v6.[idfsBaseReference] = t_v6.[idfsFormTemplate]
			and t_en_v6.[idfsLanguage] = @intLngEn
left join	[Falcon].[dbo].[trtStringNameTranslation] t_lng_v6
on			t_lng_v6.[idfsBaseReference] = t_v6.[idfsFormTemplate]
			and t_lng_v6.[idfsLanguage] = @intLngNat

left join	[Falcon].[dbo].[trtBaseReference] pBR_v6
on			pBR_v6.[idfsBaseReference] = p_v6.[idfsParameter]
			and pBR_v6.[idfsReferenceType] = 19000066 /*Flexible Form Parameter Tooltip*/
left join	[Falcon].[dbo].[trtStringNameTranslation] p_en_v6
on			p_en_v6.[idfsBaseReference] = p_v6.[idfsParameter]
			and p_en_v6.[idfsLanguage] = @intLngEn
left join	[Falcon].[dbo].[trtStringNameTranslation] p_lng_v6
on			p_lng_v6.[idfsBaseReference] = p_v6.[idfsParameter]
			and p_lng_v6.[idfsLanguage] = @intLngNat


left join	[Falcon].[dbo].[trtBaseReference] p_captionBR_v6
on			p_captionBR_v6.[idfsBaseReference] = p_v6.[idfsParameterCaption]
			and p_captionBR_v6.[idfsReferenceType] = 19000070 /*Flexible Form Parameter Caption*/
left join	[Falcon].[dbo].[trtStringNameTranslation] p_caption_en_v6
on			p_caption_en_v6.[idfsBaseReference] = p_v6.[idfsParameterCaption]
			and p_caption_en_v6.[idfsLanguage] = @intLngEn
left join	[Falcon].[dbo].[trtStringNameTranslation] p_caption_lng_v6
on			p_caption_lng_v6.[idfsBaseReference] = p_v6.[idfsParameterCaption]
			and p_caption_lng_v6.[idfsLanguage] = @intLngNat


left join	[Falcon].[dbo].[ffParameterType] pt_v6
on			pt_v6.[idfsParameterType] = p_v6.[idfsParameterType]
left join	[Falcon].[dbo].[trtBaseReference] ptBR_v6
on			ptBR_v6.[idfsBaseReference] = p_v6.[idfsParameterType]
			and ptBR_v6.[idfsReferenceType] = 19000071 /*Flexible Form Parameter Type*/
left join	[Falcon].[dbo].[trtStringNameTranslation] pt_en_v6
on			pt_en_v6.[idfsBaseReference] = p_v6.[idfsParameterType]
			and pt_en_v6.[idfsLanguage] = @intLngEn
left join	[Falcon].[dbo].[trtStringNameTranslation] pt_lng_v6
on			pt_lng_v6.[idfsBaseReference] = p_v6.[idfsParameterType]
			and pt_lng_v6.[idfsLanguage] = @intLngNat

left join	[Falcon].[dbo].[trtReferenceType] rt_v6
on			rt_v6.[idfsReferenceType] = pt_v6.[idfsReferenceType]
left join	[Falcon].[dbo].[trtBaseReference] rtBR_v6
on			rtBR_v6.[idfsBaseReference] = pt_v6.[idfsReferenceType]
			and rtBR_v6.[idfsReferenceType] = 19000076 /*Reference Type Name*/
left join	[Falcon].[dbo].[trtStringNameTranslation] rt_en_v6
on			rt_en_v6.[idfsBaseReference] = pt_v6.[idfsReferenceType]
			and rt_en_v6.[idfsLanguage] = @intLngEn
left join	[Falcon].[dbo].[trtStringNameTranslation] rt_lng_v6
on			rt_lng_v6.[idfsBaseReference] = pt_v6.[idfsReferenceType]
			and rt_lng_v6.[idfsLanguage] = @intLngNat


-- Parameter attributes
left join	[Falcon].[dbo].[trtBaseReference] p_editorBR_v6
on			p_editorBR_v6.[idfsBaseReference] = p_v6.[idfsEditor]
			and p_editorBR_v6.[idfsReferenceType] = 19000067 /*Flexible Form Parameter Editor*/
left join	[Falcon].[dbo].[trtStringNameTranslation] p_editor_en_v6
on			p_editor_en_v6.[idfsBaseReference] = p_v6.[idfsEditor]
			and p_editor_en_v6.[idfsLanguage] = @intLngEn


left join	[Falcon].[dbo].[trtBaseReference] p_modeBR_v6
on			p_modeBR_v6.[idfsBaseReference] = pft_v6.[idfsEditMode]
			and p_modeBR_v6.[idfsReferenceType] = 19000068 /*Flexible Form Parameter Mode*/
left join	[Falcon].[dbo].[trtStringNameTranslation] p_mode_en_v6
on			p_mode_en_v6.[idfsBaseReference] = pft_v6.[idfsEditMode]
			and p_mode_en_v6.[idfsLanguage] = @intLngEn


-- Parameter sizes and location
left join	[Falcon].[dbo].[ffParameterDesignOption] pdo_v6
on			pdo_v6.[idfsParameter] = p_v6.[idfsParameter]
			and pdo_v6.[idfsFormTemplate] = t_v6.[idfsFormTemplate]
			and pdo_v6.[idfsLanguage] = @intLngEn
			and pdo_v6.[intRowStatus] = 0
left join	[Falcon].[dbo].[ffParameterDesignOption] pdo_def_v6
on			pdo_def_v6.[idfsParameter] = p_v6.[idfsParameter]
			and pdo_def_v6.[idfsFormTemplate] is null
			and pdo_def_v6.[idfsLanguage] = @intLngEn
			and pdo_def_v6.[intRowStatus] = 0


left join	@SectionTableV6 st_max_v6
on			st_max_v6.[idfsSection] = p_v6.[idfsSection]
			and st_max_v6.[idfsLevelParentSection] is null
			and st_max_v6.[intRowStatus] = 0

left join	@SectionTableV6 st_root_grid_v6
on			st_root_grid_v6.[idfsSection] = p_v6.[idfsSection]
			and st_root_grid_v6.[blnIsLevelSectionGrid] = 1
			and st_root_grid_v6.[intRowStatus] = 0
			and not exists
					(	select	1
						from	@SectionTableV6 st_higherlevel_grid_v6
						where	st_higherlevel_grid_v6.[idfsSection] = st_root_grid_v6.idfsSection
								and st_higherlevel_grid_v6.[blnIsLevelSectionGrid] = 1
								and st_higherlevel_grid_v6.[intRowStatus] = 0
								and st_higherlevel_grid_v6.[intParentLevel] > st_root_grid_v6.[intParentLevel]
					)

left join	[Falcon].[dbo].[ffSectionDesignOption] sdo_v6
on			sdo_v6.[idfsSection] = p_v6.[idfsSection]
			and sdo_v6.[idfsFormTemplate] = t_v6.[idfsFormTemplate]
			and sdo_v6.[idfsLanguage] = @intLngEn
			and sdo_v6.[intRowStatus] = 0

where		p_v6.[intRowStatus] = 0
			and p_v6.[idfsFormType] = @idfsFormType

update		p_v6
set			p_v6.FinalParameterOrderInTemplate = isnull(p_less_v6.intOrder, 0)
from		@ParametersTableV6 p_v6
outer apply
(	select	count(*) intOrder
	from	@ParametersTableV6 p_less_v6
	where	p_less_v6.idfsFormTemplate = p_v6.idfsFormTemplate
			and (	p_less_v6.ParameterTop < p_v6.ParameterTop
					or	(	p_less_v6.ParameterTop = p_v6.ParameterTop
							and p_less_v6.ParameterOrderInTemplate <= p_v6.ParameterOrderInTemplate
						)
				)
) p_less_v6



insert into	@AllSectionsV7
(	idfsSection,
	idfsParentSection,
	blnIsGrid,
	strSectionEN,
	strSectionLng,
	intRowStatus
)
select		s_v7.idfsSection,
			s_parent_v7.idfsSection,
			IsNull(s_v7.blnGrid, 0),
			coalesce(s_en_v7.strTextString, sBR_v7.strDefault, N''),
			coalesce(s_lng_v7.strTextString, sBR_v7.strDefault, N''),
			s_v7.intRowStatus
from

-- Section
			[Giraffe].[dbo].[ffSection] s_v7
left join	[Giraffe].[dbo].[trtBaseReference] sBR_v7
on			sBR_v7.[idfsBaseReference] = s_v7.[idfsSection]
			and sBR_v7.[idfsReferenceType] = 19000101 /*Flexible Form Section*/
left join	[Giraffe].[dbo].[trtStringNameTranslation] s_en_v7
on			s_en_v7.[idfsBaseReference] = s_v7.[idfsSection]
			and s_en_v7.[idfsLanguage] = @intLngEn
left join	[Giraffe].[dbo].[trtStringNameTranslation] s_lng_v7
on			s_lng_v7.[idfsBaseReference] = s_v7.[idfsSection]
			and s_lng_v7.[idfsLanguage] = @intLngNat
			
-- Parent Section
left join	(
	[Giraffe].[dbo].[ffSection] s_parent_v7

	left join	[Giraffe].[dbo].[trtBaseReference] s_parentBR_v7
	on			s_parentBR_v7.[idfsBaseReference] = s_parent_v7.[idfsSection]
				and s_parentBR_v7.[idfsReferenceType] = 19000101 /*Flexible Form Section*/
	left join	[Giraffe].[dbo].[trtStringNameTranslation] s_parent_en_v7
	on			s_parent_en_v7.[idfsBaseReference] = s_parent_v7.[idfsSection]
				and s_parent_en_v7.[idfsLanguage] = @intLngEn
	left join	[Giraffe].[dbo].[trtStringNameTranslation] s_parent_lng_v7
	on			s_parent_lng_v7.[idfsBaseReference] = s_parent_v7.[idfsSection]
				and s_parent_lng_v7.[idfsLanguage] = @intLngNat
			)
on			s_parent_v7.[idfsSection] = s_v7.[idfsParentSection]


;
with	sectionTableV7	(
			idfsSection,
			intParentLevel,
			idfsLevelSection,
			idfsLevelParentSection,
			blnIsLevelSectionGrid,
			blnIsSectionGrid,
			strSectionEN,
			strSectionLng,
			strLevelSectionPathEN,
			strLevelSectionPathLng,
			intRowStatus
					)
as	(	select		s.idfsSection,
					0 as intParentLevel,
					s.idfsSection as idfsLevelSection,
					s.idfsParentSection as idfsLevelParentSection,
					s.blnIsGrid as blnIsLevelSectionGrid,
					s.blnIsGrid as blnIsSectionGrid,
					s.strSectionEN,
					s.strSectionLng,
					cast(s.strSectionEN as nvarchar(MAX)) as strLevelSectionPathEN,
					cast(s.strSectionLng as nvarchar(MAX)) as strLevelSectionPathLng,
					s.intRowStatus
		from		@AllSectionsV7 s
		union all
		select		sectionTableV7.idfsSection,
					sectionTableV7.intParentLevel + 1 as intParentLevel,
					s_all.idfsSection as idfsLevelSection,
					s_all.idfsParentSection as idfsLevelParentSection,
					s_all.blnIsGrid as blnIsLevelSectionGrid,
					sectionTableV7.blnIsSectionGrid,
					sectionTableV7.strSectionEN,
					sectionTableV7.strSectionLng,
					cast((s_all.strSectionEN + N'>' + sectionTableV7.strLevelSectionPathEN) as nvarchar(MAX)) as strLevelSectionPathEN,
					cast((s_all.strSectionLng + N'>' + sectionTableV7.strLevelSectionPathLng) as nvarchar(MAX)) as strLevelSectionPathLng,
					sectionTableV7.intRowStatus
		from		@AllSectionsV7 s_all
		inner join	sectionTableV7
		on			sectionTableV7.idfsLevelParentSection = s_all.idfsSection
	)

insert into	@SectionTableV7
(	idfsSection,
	intParentLevel,
	idfsLevelSection,
	idfsLevelParentSection,
	blnIsLevelSectionGrid,
	blnIsSectionGrid,
	strSectionEN,
	strSectionLng,
	strLevelSectionPathEN,
	strLevelSectionPathLng,
	intRowStatus
)
select		idfsSection,
			intParentLevel,
			idfsLevelSection,
			idfsLevelParentSection,
			blnIsLevelSectionGrid,
			blnIsSectionGrid,
			strSectionEN,
			strSectionLng,
			strLevelSectionPathEN,
			strLevelSectionPathLng,
			intRowStatus
from		sectionTableV7


insert into	@AllParametersV7
(	idfsParameter,
	idfsFormType,
	idfsSection,
	idfsRootGridSection,
	idfsParameterType,
	idfsReferenceType,
	FormType,
	blnIsGrid,
	ParameterNameEN,
	ParameterNameLng,
	ParameterType,
	ReferenceType,
	TooltipEN,
	TooltipLng,
	SectionPathEN,
	SectionPathLng,
	SectionNameEN,
	SectionNameLng,
	Editor,
	intRowStatus
)
select		p_v7.idfsParameter,
			@idfsFormType,
			p_v7.idfsSection,
			st_root_grid_v7.idfsLevelSection,
			p_v7.idfsParameterType,
			pt_v7.idfsReferenceType,
			@FormTypeEN as FormType,
			IsNull(st_max_v7.blnIsSectionGrid, 0), 
			coalesce(p_caption_en_v7.strTextString, p_captionBR_v7.strDefault, N'') as ParameterNameEN,
			coalesce(p_caption_lng_v7.strTextString, p_captionBR_v7.strDefault, N'') as ParameterNameLng,
			coalesce(pt_en_v7.strTextString, ptBR_v7.strDefault, N'') as ParameterType,
			coalesce(rt_en_v7.strTextString, rtBR_v7.strDefault, rt_v7.strReferenceTypeName, N'') as ReferenceType,
			coalesce(p_en_v7.strTextString, pBR_v7.strDefault, N'') as TooltipEN,
			coalesce(p_lng_v7.strTextString, pBR_v7.strDefault, N'') as TooltipLng,
			IsNull(st_max_v7.strLevelSectionPathEN, N'None') as SectionPathEN,
			IsNull(st_max_v7.strLevelSectionPathLng, N'None') as SectionPathLng,
			IsNull(st_max_v7.strSectionEN, N'None') as SectionNameEN,
			IsNull(st_max_v7.strSectionLng, N'None') as SectionNameLng,
			coalesce(p_editor_en_v7.strTextString, p_editorBR_v7.strDefault, N'None') as Editor,
			p_v7.[intRowStatus]
from		
-- Parameter
			[Giraffe].[dbo].[ffParameter] p_v7

left join	[Giraffe].[dbo].[trtBaseReference] pBR_v7
on			pBR_v7.[idfsBaseReference] = p_v7.[idfsParameter]
			and pBR_v7.[idfsReferenceType] = 19000066 /*Flexible Form Parameter Tooltip*/
left join	[Giraffe].[dbo].[trtStringNameTranslation] p_en_v7
on			p_en_v7.[idfsBaseReference] = p_v7.[idfsParameter]
			and p_en_v7.[idfsLanguage] = @intLngEn
left join	[Giraffe].[dbo].[trtStringNameTranslation] p_lng_v7
on			p_lng_v7.[idfsBaseReference] = p_v7.[idfsParameter]
			and p_lng_v7.[idfsLanguage] = @intLngNat


left join	[Giraffe].[dbo].[trtBaseReference] p_captionBR_v7
on			p_captionBR_v7.[idfsBaseReference] = p_v7.[idfsParameterCaption]
			and p_captionBR_v7.[idfsReferenceType] = 19000070 /*Flexible Form Parameter Caption*/
left join	[Giraffe].[dbo].[trtStringNameTranslation] p_caption_en_v7
on			p_caption_en_v7.[idfsBaseReference] = p_v7.[idfsParameterCaption]
			and p_caption_en_v7.[idfsLanguage] = @intLngEn
left join	[Giraffe].[dbo].[trtStringNameTranslation] p_caption_lng_v7
on			p_caption_lng_v7.[idfsBaseReference] = p_v7.[idfsParameterCaption]
			and p_caption_lng_v7.[idfsLanguage] = @intLngNat


left join	[Giraffe].[dbo].[ffParameterType] pt_v7
on			pt_v7.[idfsParameterType] = p_v7.[idfsParameterType]
left join	[Giraffe].[dbo].[trtBaseReference] ptBR_v7
on			ptBR_v7.[idfsBaseReference] = p_v7.[idfsParameterType]
			and ptBR_v7.[idfsReferenceType] = 19000071 /*Flexible Form Parameter Type*/
left join	[Giraffe].[dbo].[trtStringNameTranslation] pt_en_v7
on			pt_en_v7.[idfsBaseReference] = p_v7.[idfsParameterType]
			and pt_en_v7.[idfsLanguage] = @intLngEn
left join	[Giraffe].[dbo].[trtStringNameTranslation] pt_lng_v7
on			pt_lng_v7.[idfsBaseReference] = p_v7.[idfsParameterType]
			and pt_lng_v7.[idfsLanguage] = @intLngNat

left join	[Giraffe].[dbo].[trtReferenceType] rt_v7
on			rt_v7.[idfsReferenceType] = pt_v7.[idfsReferenceType]
left join	[Giraffe].[dbo].[trtBaseReference] rtBR_v7
on			rtBR_v7.[idfsBaseReference] = pt_v7.[idfsReferenceType]
			and rtBR_v7.[idfsReferenceType] = 19000076 /*Reference Type Name*/
left join	[Giraffe].[dbo].[trtStringNameTranslation] rt_en_v7
on			rt_en_v7.[idfsBaseReference] = pt_v7.[idfsReferenceType]
			and rt_en_v7.[idfsLanguage] = @intLngEn
left join	[Giraffe].[dbo].[trtStringNameTranslation] rt_lng_v7
on			rt_lng_v7.[idfsBaseReference] = pt_v7.[idfsReferenceType]
			and rt_lng_v7.[idfsLanguage] = @intLngNat

-- Parameter attributes
left join	[Giraffe].[dbo].[trtBaseReference] p_editorBR_v7
on			p_editorBR_v7.[idfsBaseReference] = p_v7.[idfsEditor]
			and p_editorBR_v7.[idfsReferenceType] = 19000067 /*Flexible Form Parameter Editor*/
left join	[Giraffe].[dbo].[trtStringNameTranslation] p_editor_en_v7
on			p_editor_en_v7.[idfsBaseReference] = p_v7.[idfsEditor]
			and p_editor_en_v7.[idfsLanguage] = @intLngEn


left join	@SectionTableV7 st_max_v7
on			st_max_v7.[idfsSection] = p_v7.[idfsSection]
			and st_max_v7.[idfsLevelParentSection] is null
			and st_max_v7.[intRowStatus] = 0

left join	@SectionTableV7 st_root_grid_v7
on			st_root_grid_v7.[idfsSection] = p_v7.[idfsSection]
			and st_root_grid_v7.[blnIsLevelSectionGrid] = 1
			and st_root_grid_v7.[intRowStatus] = 0
			and not exists
					(	select	1
						from	@SectionTableV7 st_higherlevel_grid_v7
						where	st_higherlevel_grid_v7.[idfsSection] = st_root_grid_v7.idfsSection
								and st_higherlevel_grid_v7.[blnIsLevelSectionGrid] = 1
								and st_higherlevel_grid_v7.[intRowStatus] = 0
								and st_higherlevel_grid_v7.[intParentLevel] > st_root_grid_v7.[intParentLevel]
					)

where		p_v7.[idfsFormType] = @idfsFormType



insert into	@ParametersTableV7
(	idfsParameter,
	idfsFormTemplate,
	idfsFormType,
	idfsSection,
	idfsRootGridSection,
	idfsParameterType,
	idfsReferenceType,
	FormType,
	TemplateEN,
	TemplateLng,
	blnIsGrid,
	ParameterOrderInTemplate,
	ParameterTop,
	FinalParameterOrderInTemplate,
	ParameterNameEN,
	ParameterNameLng,
	ParameterType,
	ReferenceType,
	TooltipEN,
	TooltipLng,
	SectionPathEN,
	SectionPathLng,
	SectionNameEN,
	SectionNameLng,
	Editor,
	Mode,
	intRowStatus
)
select		p_v7.idfsParameter,
			t_v7.idfsFormTemplate,
			@idfsFormType,
			p_v7.idfsSection,
			st_root_grid_v7.idfsLevelSection,
			p_v7.idfsParameterType,
			pt_v7.idfsReferenceType,
			@FormTypeEN as FormType,
			coalesce(t_en_v7.strTextString, tBR_v7.strDefault, N'') as TemplateEN,
			coalesce(t_lng_v7.strTextString, tBR_v7.strDefault, N'') as TemplateLng,
			IsNull(st_max_v7.blnIsSectionGrid, 0), 
			coalesce(pdo_v7.intOrder, pdo_def_v7.intOrder, 0) as ParameterOrderInTemplate, 
			IsNull	(
				(	select		sum(IsNull(sdo_parent_v7.intTop, 0))
					from		@SectionTableV7 st_sdo_v7
					inner join	[Giraffe].[dbo].[ffSectionDesignOption] sdo_parent_v7
					on			sdo_parent_v7.[idfsSection] = st_sdo_v7.[idfsLevelParentSection]
								and sdo_parent_v7.[idfsFormTemplate] = t_v7.[idfsFormTemplate]
								and sdo_parent_v7.idfsLanguage = @intLngEn
								and sdo_parent_v7.[intRowStatus] = 0
					where		st_sdo_v7.[idfsSection] = p_v7.[idfsSection]
				), 0
					) + IsNull(sdo_v7.intTop, 0) + (1 - IsNull(st_max_v7.blnIsSectionGrid, 0)) * coalesce(pdo_v7.intTop, pdo_def_v7.intTop, 0) as ParameterTop,
			0,
			coalesce(p_caption_en_v7.strTextString, p_captionBR_v7.strDefault, N'') as ParameterNameEN,
			coalesce(p_caption_lng_v7.strTextString, p_captionBR_v7.strDefault, N'') as ParameterNameLng,
			coalesce(pt_en_v7.strTextString, ptBR_v7.strDefault, N'') as ParameterType,
			coalesce(rt_en_v7.strTextString, rtBR_v7.strDefault, rt_v7.strReferenceTypeName, N'') as ReferenceType,
			coalesce(p_en_v7.strTextString, pBR_v7.strDefault, N'') as TooltipEN,
			coalesce(p_lng_v7.strTextString, pBR_v7.strDefault, N'') as TooltipLng,
			IsNull(st_max_v7.strLevelSectionPathEN, N'None') as SectionPathEN,
			IsNull(st_max_v7.strLevelSectionPathLng, N'None') as SectionPathLng,
			IsNull(st_max_v7.strSectionEN, N'None') as SectionNameEN,
			IsNull(st_max_v7.strSectionLng, N'None') as SectionNameLng,
			coalesce(p_editor_en_v7.strTextString, p_editorBR_v7.strDefault, N'None') as Editor,
			replace	(
				replace	(
					IsNull(cast(pft_v7.idfsEditMode as nvarchar(20)), N'None'),
					N'10068003',
					N'Mandatory'
						),
				N'10068001',
				N'Ordinary'
					) as Mode,
			p_v7.[intRowStatus]
from
-- Parameters in templates		
			[Giraffe].[dbo].[ffParameter] p_v7
inner join	[Giraffe].[dbo].[ffParameterforTemplate] pft_v7
on			pft_v7.[idfsParameter] = p_v7.[idfsParameter]
			and pft_v7.[intRowStatus] = 0
inner join	[Giraffe].[dbo].[ffFormTemplate] t_v7
on			t_v7.[idfsFormTemplate] = pft_v7.[idfsFormTemplate]
			and t_v7.[intRowStatus] = 0

left join	[Giraffe].[dbo].[trtBaseReference] tBR_v7
on			tBR_v7.[idfsBaseReference] = t_v7.[idfsFormTemplate]
			and tBR_v7.[idfsReferenceType] = 19000033 /*Flexible Form Template*/
left join	[Giraffe].[dbo].[trtStringNameTranslation] t_en_v7
on			t_en_v7.[idfsBaseReference] = t_v7.[idfsFormTemplate]
			and t_en_v7.[idfsLanguage] = @intLngEn
left join	[Giraffe].[dbo].[trtStringNameTranslation] t_lng_v7
on			t_lng_v7.[idfsBaseReference] = t_v7.[idfsFormTemplate]
			and t_lng_v7.[idfsLanguage] = @intLngNat

left join	[Giraffe].[dbo].[trtBaseReference] pBR_v7
on			pBR_v7.[idfsBaseReference] = p_v7.[idfsParameter]
			and pBR_v7.[idfsReferenceType] = 19000066 /*Flexible Form Parameter Tooltip*/
left join	[Giraffe].[dbo].[trtStringNameTranslation] p_en_v7
on			p_en_v7.[idfsBaseReference] = p_v7.[idfsParameter]
			and p_en_v7.[idfsLanguage] = @intLngEn
left join	[Giraffe].[dbo].[trtStringNameTranslation] p_lng_v7
on			p_lng_v7.[idfsBaseReference] = p_v7.[idfsParameter]
			and p_lng_v7.[idfsLanguage] = @intLngNat


left join	[Giraffe].[dbo].[trtBaseReference] p_captionBR_v7
on			p_captionBR_v7.[idfsBaseReference] = p_v7.[idfsParameterCaption]
			and p_captionBR_v7.[idfsReferenceType] = 19000070 /*Flexible Form Parameter Caption*/
left join	[Giraffe].[dbo].[trtStringNameTranslation] p_caption_en_v7
on			p_caption_en_v7.[idfsBaseReference] = p_v7.[idfsParameterCaption]
			and p_caption_en_v7.[idfsLanguage] = @intLngEn
left join	[Giraffe].[dbo].[trtStringNameTranslation] p_caption_lng_v7
on			p_caption_lng_v7.[idfsBaseReference] = p_v7.[idfsParameterCaption]
			and p_caption_lng_v7.[idfsLanguage] = @intLngNat


left join	[Giraffe].[dbo].[ffParameterType] pt_v7
on			pt_v7.[idfsParameterType] = p_v7.[idfsParameterType]
left join	[Giraffe].[dbo].[trtBaseReference] ptBR_v7
on			ptBR_v7.[idfsBaseReference] = p_v7.[idfsParameterType]
			and ptBR_v7.[idfsReferenceType] = 19000071 /*Flexible Form Parameter Type*/
left join	[Giraffe].[dbo].[trtStringNameTranslation] pt_en_v7
on			pt_en_v7.[idfsBaseReference] = p_v7.[idfsParameterType]
			and pt_en_v7.[idfsLanguage] = @intLngEn
left join	[Giraffe].[dbo].[trtStringNameTranslation] pt_lng_v7
on			pt_lng_v7.[idfsBaseReference] = p_v7.[idfsParameterType]
			and pt_lng_v7.[idfsLanguage] = @intLngNat

left join	[Giraffe].[dbo].[trtReferenceType] rt_v7
on			rt_v7.[idfsReferenceType] = pt_v7.[idfsReferenceType]
left join	[Giraffe].[dbo].[trtBaseReference] rtBR_v7
on			rtBR_v7.[idfsBaseReference] = pt_v7.[idfsReferenceType]
			and rtBR_v7.[idfsReferenceType] = 19000076 /*Reference Type Name*/
left join	[Giraffe].[dbo].[trtStringNameTranslation] rt_en_v7
on			rt_en_v7.[idfsBaseReference] = pt_v7.[idfsReferenceType]
			and rt_en_v7.[idfsLanguage] = @intLngEn
left join	[Giraffe].[dbo].[trtStringNameTranslation] rt_lng_v7
on			rt_lng_v7.[idfsBaseReference] = pt_v7.[idfsReferenceType]
			and rt_lng_v7.[idfsLanguage] = @intLngNat


-- Parameter attributes
left join	[Giraffe].[dbo].[trtBaseReference] p_editorBR_v7
on			p_editorBR_v7.[idfsBaseReference] = p_v7.[idfsEditor]
			and p_editorBR_v7.[idfsReferenceType] = 19000067 /*Flexible Form Parameter Editor*/
left join	[Giraffe].[dbo].[trtStringNameTranslation] p_editor_en_v7
on			p_editor_en_v7.[idfsBaseReference] = p_v7.[idfsEditor]
			and p_editor_en_v7.[idfsLanguage] = @intLngEn


left join	[Giraffe].[dbo].[trtBaseReference] p_modeBR_v7
on			p_modeBR_v7.[idfsBaseReference] = pft_v7.[idfsEditMode]
			and p_modeBR_v7.[idfsReferenceType] = 19000068 /*Flexible Form Parameter Mode*/
left join	[Giraffe].[dbo].[trtStringNameTranslation] p_mode_en_v7
on			p_mode_en_v7.[idfsBaseReference] = pft_v7.[idfsEditMode]
			and p_mode_en_v7.[idfsLanguage] = @intLngEn


-- Parameter sizes and location
left join	[Giraffe].[dbo].[ffParameterDesignOption] pdo_v7
on			pdo_v7.[idfsParameter] = p_v7.[idfsParameter]
			and pdo_v7.[idfsFormTemplate] = t_v7.[idfsFormTemplate]
			and pdo_v7.[idfsLanguage] = @intLngEn
			and pdo_v7.[intRowStatus] = 0
left join	[Giraffe].[dbo].[ffParameterDesignOption] pdo_def_v7
on			pdo_def_v7.[idfsParameter] = p_v7.[idfsParameter]
			and pdo_def_v7.[idfsFormTemplate] is null
			and pdo_def_v7.[idfsLanguage] = @intLngEn
			and pdo_def_v7.[intRowStatus] = 0


left join	@SectionTableV7 st_max_v7
on			st_max_v7.[idfsSection] = p_v7.[idfsSection]
			and st_max_v7.[idfsLevelParentSection] is null
			and st_max_v7.[intRowStatus] = 0

left join	@SectionTableV7 st_root_grid_v7
on			st_root_grid_v7.[idfsSection] = p_v7.[idfsSection]
			and st_root_grid_v7.[blnIsLevelSectionGrid] = 1
			and st_root_grid_v7.[intRowStatus] = 0
			and not exists
					(	select	1
						from	@SectionTableV7 st_higherlevel_grid_v7
						where	st_higherlevel_grid_v7.[idfsSection] = st_root_grid_v7.idfsSection
								and st_higherlevel_grid_v7.[blnIsLevelSectionGrid] = 1
								and st_higherlevel_grid_v7.[intRowStatus] = 0
								and st_higherlevel_grid_v7.[intParentLevel] > st_root_grid_v7.[intParentLevel]
					)

left join	[Giraffe].[dbo].[ffSectionDesignOption] sdo_v7
on			sdo_v7.[idfsSection] = p_v7.[idfsSection]
			and sdo_v7.[idfsFormTemplate] = t_v7.[idfsFormTemplate]
			and sdo_v7.[idfsLanguage] = @intLngEn
			and sdo_v7.[intRowStatus] = 0

where		p_v7.[intRowStatus] = 0
			and p_v7.[idfsFormType] = @idfsFormType

update		p_v7
set			p_v7.FinalParameterOrderInTemplate = isnull(p_less_v7.intOrder, 0)
from		@ParametersTableV7 p_v7
outer apply
(	select	count(*) intOrder
	from	@ParametersTableV7 p_less_v7
	where	p_less_v7.idfsFormTemplate = p_v7.idfsFormTemplate
			and (	p_less_v7.ParameterTop < p_v7.ParameterTop
					or	(	p_less_v7.ParameterTop = p_v7.ParameterTop
							and p_less_v7.ParameterOrderInTemplate <= p_v7.ParameterOrderInTemplate
						)
				)
) p_less_v7

select			isnull(cast(tlbHumanCase_v6.idfHumanCase as varchar(20)), N'') as 'HDR System Identifier v6',
				isnull(cast(tlbHumanCase_v7.idfHumanCase as varchar(20)), N'') as 'HDR System Identifier v7',
				
				isnull(cast(tlbActivityParameters_v6.idfActivityParameters as varchar(20)), N'') as 'FF Value System Identifier v6',
				isnull(cast(tlbActivityParameters_v7.idfActivityParameters as varchar(20)), N'') as 'FF Value System Identifier v7',
				
				isnull(tlbHumanCase_v6.strCaseID, N'') as 'Case ID v6',
				isnull(tlbHumanCase_v7.LegacyCaseID, N'') as 'Legacy Case ID v7',
				isnull(tlbHumanCase_v7.strCaseID, N'') as 'Report ID v7',

				coalesce(tentative_diag_en_v6.strTextString, tentative_diag_v6.strDefault, N'') as 'Diagnosis v6',
				coalesce(final_diag_en_v6.strTextString, final_diag_v6.strDefault, N'') as 'Changed Diagnosis v6',
				coalesce(final_diag_en_v6.strTextString, final_diag_v6.strDefault, tentative_diag_en_v6.strTextString, tentative_diag_v6.strDefault, N'') as 'Current Diagnosis v6',
				coalesce(tentative_diag_en_v7.strTextString, tentative_diag_v7.strDefault, N'') as 'Diagnosis v7',
				coalesce(final_diag_en_v7.strTextString, final_diag_v7.strDefault, N'') as 'Changed Diagnosis v7',
				coalesce(final_diag_en_v7.strTextString, final_diag_v7.strDefault, tentative_diag_en_v7.strTextString, tentative_diag_v7.strDefault, N'') as 'Current Diagnosis v7',
				
				isnull(@FormTypeEN, N'') as N'FF Type',

				coalesce(template_en_v6.strTextString, templateBR_v6.strDefault, N'') as 'FF Template v6',
				coalesce(template_en_v7.strTextString, templateBR_v7.strDefault, N'') as 'FF Template v7',
				case when template_v6.blnUNI = 1 then 'Yes' else N'' end as 'FF Template - Is UNI v6',
				case when template_v7.blnUNI = 1 then 'Yes' else N'' end as 'FF Template - Is UNI v7',
				isnull(det_v6.strDeterminants, N'') as 'FF Template - Determinants v6',
				isnull(det_v7.strDeterminants, N'') as 'FF Template - Determinants v7',
				isnull(p_v6.TooltipEN, N'') as 'FF Parameter Tooltip v6',
				isnull(p_v7.TooltipEN, N'') as 'FF Parameter Tooltip v7',
				case when p_v6.idfsParameter is not null and pft_v6.idfsFormTemplate is null then N'Does not belong to Template v6' else N'' end as 'FF Parameter - Is Out of Template v6',
				case when p_v7.idfsParameter is not null and pft_v7.idfsFormTemplate is null then N'Does not belong to Template v7' else N'' end as 'FF Parameter - Is Out of Template v7',
				replace(cast(isnull(pft_v6.FinalParameterOrderInTemplate, 100000) as nvarchar(20)), N'100000', N'') as 'FF Parameter Order In Template v6',
				replace(cast(isnull(pft_v7.FinalParameterOrderInTemplate, 100000) as nvarchar(20)), N'100000', N'') as 'FF Parameter Order In Template v7',
				isnull(p_v6.SectionPathEN, N'') as 'FF Parameter Section Path v6',
				isnull(p_v6.ParameterNameEN, N'') as 'FF Parameter Name v6',
				isnull(p_v7.SectionPathEN, N'') as 'FF Parameter Section Path v7',
				isnull(p_v7.ParameterNameEN, N'') as 'FF Parameter Name v7',
				case when p_v6.intRowStatus = 0 or p_v6.intRowStatus is null then N'' else N'Deleted' end as 'FF Parameter Deletion Sign v6',
				case when p_v7.intRowStatus = 0 or p_v7.intRowStatus is null then N'' else N'Deleted' end as 'FF Parameter Deletion Sign v7',
				isnull(p_v6.ParameterType, N'') as 'FF Parameter Type v6',
				case
					when	p_v6.idfsReferenceType = 19000069 /*Flexible Form Parameter Value*/
						then	N'Custom FF Values: ' + p_v6.ParameterType
					when	p_v6.idfsReferenceType is not null
							and p_v6.idfsReferenceType <> 19000069 /*Flexible Form Parameter Value*/
						then	N'Standard BRef Values: ' + p_v6.ReferenceType
					else N''
				end as 'FF Parameter Drop-Down Values v6',
				isnull(p_v7.ParameterType, N'') as 'FF Parameter Type v7',
				case
					when	p_v7.idfsReferenceType = 19000069 /*Flexible Form Parameter Value*/
						then	N'Custom FF Values: ' + p_v7.ParameterType
					when	p_v7.idfsReferenceType is not null
							and p_v7.idfsReferenceType <> 19000069 /*Flexible Form Parameter Value*/
						then	N'Standard BRef Values: ' + p_v7.ReferenceType
					else N''
				end as 'FF Parameter Drop-Down Values v7',
				case when p_v6.blnIsGrid = 1 then isnull(cast(ffRow_v6.intRowNum as nvarchar(20)), N'') else N'' end as 'FF Grid Row # v6',
				case when p_v7.blnIsGrid = 1 then isnull(cast(ffRow_v7.intRowNum as nvarchar(20)), N'') else N'' end as 'FF Grid Row # v7',
				case
					when	tlbActivityParameters_v6.varValue is null
						then	N''
					when	p_v6.idfsReferenceType is not null
							and ffValBR_v6.idfsBaseReference is not null
						then	coalesce(ffValBR_en_v6.strTextString, ffValBR_v6.strDefault, N'')
					when	SQL_VARIANT_PROPERTY(tlbActivityParameters_v6.varValue, N'BaseType') = 'datetime'
						then	CONVERT(nvarchar, cast(tlbActivityParameters_v6.varValue as datetime), 121)
					when	SQL_VARIANT_PROPERTY(tlbActivityParameters_v6.varValue, N'BaseType') = 'smalldatetime'
						then	CONVERT(nvarchar, cast(cast(tlbActivityParameters_v6.varValue as smalldatetime) as datetime), 121)
					when	SQL_VARIANT_PROPERTY(tlbActivityParameters_v6.varValue, N'BaseType') = 'datetime2'
						then	CONVERT(nvarchar, cast(tlbActivityParameters_v6.varValue as datetime2), 121)
					when	SQL_VARIANT_PROPERTY(tlbActivityParameters_v6.varValue, N'BaseType') = 'datetimeoffset'
						then	CONVERT(nvarchar, CONVERT(datetime2, cast(tlbActivityParameters_v6.varValue as datetimeoffset), 1), 121)
					when	SQL_VARIANT_PROPERTY(tlbActivityParameters_v6.varValue, N'BaseType') = 'date'
						then	CONVERT(nvarchar, cast(tlbActivityParameters_v6.varValue as date), 23)
					when	SQL_VARIANT_PROPERTY(tlbActivityParameters_v6.varValue, N'BaseType') = 'time'
						then	CONVERT(nvarchar, cast(tlbActivityParameters_v6.varValue as time), 114)
					when	SQL_VARIANT_PROPERTY(tlbActivityParameters_v6.varValue, N'BaseType') = 'bit'
						then	replace(replace(cast(tlbActivityParameters_v6.varValue as nvarchar), N'1', N'v'), N'0', 'x')
					else	cast(tlbActivityParameters_v6.varValue as nvarchar)
				end as 'FF Value v6',
				case
					when	tlbActivityParameters_v7.varValue is null
						then	N''
					when	p_v7.idfsReferenceType is not null
							and ffValBR_v7.idfsBaseReference is not null
						then	coalesce(ffValBR_en_v7.strTextString, ffValBR_v7.strDefault, N'')
					when	SQL_VARIANT_PROPERTY(tlbActivityParameters_v7.varValue, N'BaseType') = 'datetime'
						then	CONVERT(nvarchar, cast(tlbActivityParameters_v7.varValue as datetime), 121)
					when	SQL_VARIANT_PROPERTY(tlbActivityParameters_v7.varValue, N'BaseType') = 'smalldatetime'
						then	CONVERT(nvarchar, cast(cast(tlbActivityParameters_v7.varValue as smalldatetime) as datetime), 121)
					when	SQL_VARIANT_PROPERTY(tlbActivityParameters_v7.varValue, N'BaseType') = 'datetime2'
						then	CONVERT(nvarchar, cast(tlbActivityParameters_v7.varValue as datetime2), 121)
					when	SQL_VARIANT_PROPERTY(tlbActivityParameters_v7.varValue, N'BaseType') = 'datetimeoffset'
						then	CONVERT(nvarchar, CONVERT(datetime2, cast(tlbActivityParameters_v7.varValue as datetimeoffset), 1), 121)
					when	SQL_VARIANT_PROPERTY(tlbActivityParameters_v7.varValue, N'BaseType') = 'date'
						then	CONVERT(nvarchar, cast(tlbActivityParameters_v7.varValue as date), 23)
					when	SQL_VARIANT_PROPERTY(tlbActivityParameters_v7.varValue, N'BaseType') = 'time'
						then	CONVERT(nvarchar, cast(tlbActivityParameters_v7.varValue as time), 114)
					when	SQL_VARIANT_PROPERTY(tlbActivityParameters_v7.varValue, N'BaseType') = 'bit'
						then	replace(replace(cast(tlbActivityParameters_v7.varValue as nvarchar), N'1', N'v'), N'0', 'x')
					else	cast(tlbActivityParameters_v7.varValue as nvarchar)
				end as 'FF Value v7'
from
(
	[Giraffe].[dbo].[tlbHumanCase] tlbHumanCase_v7
	inner join	[Giraffe].[dbo].[_dmccHumanCase] cchc
	on			cchc.idfHumanCase_v7 = tlbHumanCase_v7.idfHumanCase
				and not exists (select 1 from [Giraffe].[dbo].[_dmccHumanCase] cchc_other where cchc_other.idfHumanCase_v7 = tlbHumanCase_v7.idfHumanCase and cchc_other.idfId < cchc.idfId)
	inner join	[Falcon].[dbo].tlbHumanCase tlbHumanCase_v6
	on			tlbHumanCase_v6.idfHumanCase = cchc.idfHumanCase_v6


	left join	[Giraffe].[dbo].[trtBaseReference] tentative_diag_v7
	on			tentative_diag_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsTentativeDiagnosis]
	left join	[Giraffe].[dbo].[trtStringNameTranslation] tentative_diag_en_v7
	on			tentative_diag_en_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsTentativeDiagnosis]
				and tentative_diag_en_v7.[idfsLanguage] = @intLngEn
	left join	[Giraffe].[dbo].[trtStringNameTranslation] tentative_diag_lng_v7
	on			tentative_diag_lng_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsTentativeDiagnosis]
				and tentative_diag_lng_v7.[idfsLanguage] = @intLngNat

	left join	[Giraffe].[dbo].[trtBaseReference] final_diag_v7
	on			final_diag_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsFinalDiagnosis]
	left join	[Giraffe].[dbo].[trtStringNameTranslation] final_diag_en_v7
	on			final_diag_en_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsFinalDiagnosis]
				and final_diag_en_v7.[idfsLanguage] = @intLngEn
	left join	[Giraffe].[dbo].[trtStringNameTranslation] final_diag_lng_v7
	on			final_diag_lng_v7.[idfsBaseReference] = tlbHumanCase_v7.[idfsFinalDiagnosis]
				and final_diag_lng_v7.[idfsLanguage] = @intLngNat


	left join	[Falcon].[dbo].[trtBaseReference] tentative_diag_v6
	on			tentative_diag_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsTentativeDiagnosis]
	left join	[Falcon].[dbo].[trtStringNameTranslation] tentative_diag_en_v6
	on			tentative_diag_en_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsTentativeDiagnosis]
				and tentative_diag_en_v6.[idfsLanguage] = @intLngEn
	left join	[Falcon].[dbo].[trtStringNameTranslation] tentative_diag_lng_v6
	on			tentative_diag_lng_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsTentativeDiagnosis]
				and tentative_diag_lng_v6.[idfsLanguage] = @intLngNat

	left join	[Falcon].[dbo].[trtBaseReference] final_diag_v6
	on			final_diag_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsFinalDiagnosis]
	left join	[Falcon].[dbo].[trtStringNameTranslation] final_diag_en_v6
	on			final_diag_en_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsFinalDiagnosis]
				and final_diag_en_v6.[idfsLanguage] = @intLngEn
	left join	[Falcon].[dbo].[trtStringNameTranslation] final_diag_lng_v6
	on			final_diag_lng_v6.[idfsBaseReference] = tlbHumanCase_v6.[idfsFinalDiagnosis]
				and final_diag_lng_v6.[idfsLanguage] = @intLngNat


	left join	[Giraffe].[dbo].[tlbObservation] tlbObservation_v7
	on			tlbObservation_v7.[idfObservation] = tlbHumanCase_v7.[idfCSObservation]

	left join	[Giraffe].[dbo].[ffFormTemplate] template_v7
	on			template_v7.[idfsFormTemplate] = tlbObservation_v7.[idfsFormTemplate]
	left join	[Giraffe].[dbo].[trtBaseReference] templateBR_v7
	on			templateBR_v7.[idfsBaseReference] = tlbObservation_v7.[idfsFormTemplate]
	left join	[Giraffe].[dbo].[trtStringNameTranslation] template_en_v7
	on			template_en_v7.[idfsBaseReference] = tlbObservation_v7.[idfsFormTemplate]
				and template_en_v7.[idfsLanguage] = @intLngEn
	left join	[Giraffe].[dbo].[trtStringNameTranslation] template_lng_v7
	on			template_lng_v7.[idfsBaseReference] = tlbObservation_v7.[idfsFormTemplate]
				and template_lng_v7.[idfsLanguage] = @intLngNat


	left join	[Falcon].[dbo].[tlbObservation] tlbObservation_v6
	on			tlbObservation_v6.[idfObservation] = tlbHumanCase_v6.[idfCSObservation]

	left join	[Falcon].[dbo].[ffFormTemplate] template_v6
	on			template_v6.[idfsFormTemplate] = tlbObservation_v6.[idfsFormTemplate]
	left join	[Falcon].[dbo].[trtBaseReference] templateBR_v6
	on			templateBR_v6.[idfsBaseReference] = tlbObservation_v6.[idfsFormTemplate]
	left join	[Falcon].[dbo].[trtStringNameTranslation] template_en_v6
	on			template_en_v6.[idfsBaseReference] = tlbObservation_v6.[idfsFormTemplate]
				and template_en_v6.[idfsLanguage] = @intLngEn
	left join	[Falcon].[dbo].[trtStringNameTranslation] template_lng_v6
	on			template_lng_v6.[idfsBaseReference] = tlbObservation_v6.[idfsFormTemplate]
				and template_lng_v6.[idfsLanguage] = @intLngNat

	outer apply
	(	select		STRING_AGG(coalesce(determinantBR_en_v7.strTextString, determinantBR_v7.strDefault, N''), N', ') as strDeterminants
		from		[Giraffe].[dbo].[ffDeterminantValue] ffDeterminantValue_v7

		inner join	[Giraffe].[dbo].[trtBaseReference] determinantBR_v7
		on			determinantBR_v7.[idfsBaseReference] = ffDeterminantValue_v7.[idfsBaseReference]
		left join	[Giraffe].[dbo].[trtStringNameTranslation] determinantBR_en_v7
		on			determinantBR_en_v7.[idfsBaseReference] = ffDeterminantValue_v7.[idfsBaseReference]
					and determinantBR_en_v7.[idfsLanguage] = @intLngEn
		left join	[Giraffe].[dbo].[trtStringNameTranslation] determinantBR_lng_v7
		on			determinantBR_lng_v7.[idfsBaseReference] = ffDeterminantValue_v7.[idfsBaseReference]
					and determinantBR_lng_v7.[idfsLanguage] = @intLngNat

		where		ffDeterminantValue_v7.[idfsFormTemplate] = template_v7.[idfsFormTemplate]
					and ffDeterminantValue_v7.[intRowStatus] <= template_v7.[intRowStatus]
	) det_v7

	outer apply
	(	select		STRING_AGG(coalesce(determinantBR_en_v6.strTextString, determinantBR_v6.strDefault, N''), N', ') as strDeterminants
		from		[Falcon].[dbo].[ffDeterminantValue] ffDeterminantValue_v6

		inner join	[Falcon].[dbo].[trtBaseReference] determinantBR_v6
		on			determinantBR_v6.[idfsBaseReference] = ffDeterminantValue_v6.[idfsBaseReference]
		left join	[Falcon].[dbo].[trtStringNameTranslation] determinantBR_en_v6
		on			determinantBR_en_v6.[idfsBaseReference] = ffDeterminantValue_v6.[idfsBaseReference]
					and determinantBR_en_v6.[idfsLanguage] = @intLngEn
		left join	[Falcon].[dbo].[trtStringNameTranslation] determinantBR_lng_v6
		on			determinantBR_lng_v6.[idfsBaseReference] = ffDeterminantValue_v6.[idfsBaseReference]
					and determinantBR_lng_v6.[idfsLanguage] = @intLngNat

		where		ffDeterminantValue_v6.[idfsFormTemplate] = template_v6.[idfsFormTemplate]
					and ffDeterminantValue_v6.[intRowStatus] <= template_v6.[intRowStatus]
	) det_v6

)


left join	[Falcon].[dbo].[tlbActivityParameters] tlbActivityParameters_v6
	inner join	@AllParametersV6 p_v6
	on			p_v6.[idfsParameter] = tlbActivityParameters_v6.[idfsParameter]
on			tlbActivityParameters_v6.[idfObservation] = tlbHumanCase_v6.[idfCSObservation]
				and tlbActivityParameters_v6.[intRowStatus] <= tlbHumanCase_v6.[intRowStatus]
				and tlbActivityParameters_v6.varValue is not null

left join	@ParametersTableV6 pft_v6
on			pft_v6.[idfsParameter] = tlbActivityParameters_v6.[idfsParameter]
			and pft_v6.[idfsFormTemplate] = tlbObservation_v6.[idfsFormTemplate]

left join	[Falcon].[dbo].[trtBaseReference] ffValBR_v6
on			ffValBR_v6.idfsReferenceType = p_v6.idfsReferenceType
			and cast(ffValBR_v6.idfsBaseReference as nvarchar(20)) = CAST(tlbActivityParameters_v6.varValue as nvarchar)
left join	[Falcon].[dbo].[trtStringNameTranslation] ffValBR_en_v6
on			ffValBR_en_v6.idfsBaseReference = ffValBR_v6.idfsBaseReference
			and ffValBR_en_v6.idfsLanguage = @intLngEn
left join	[Falcon].[dbo].[trtStringNameTranslation] ffValBR_lng_v6
on			ffValBR_lng_v6.idfsBaseReference = ffValBR_v6.idfsBaseReference
			and ffValBR_lng_v6.idfsLanguage = @intLngNat

outer apply
(	select		count(distinct tlbActivityParameters_prev_rows_v6.idfRow) as intRowNum
	from		[Falcon].[dbo].[tlbActivityParameters] tlbActivityParameters_prev_rows_v6
	inner join	@AllParametersV6 p_same_grid_v6
	on			p_same_grid_v6.[idfsParameter] = tlbActivityParameters_prev_rows_v6.[idfsParameter]
				and p_same_grid_v6.[blnIsGrid] = 1
				and p_same_grid_v6.[idfsRootGridSection] = p_v6.[idfsRootGridSection]
	where		tlbActivityParameters_prev_rows_v6.[idfObservation] = tlbHumanCase_v6.[idfCSObservation]
				and tlbActivityParameters_prev_rows_v6.[intRowStatus] <= tlbHumanCase_v6.[intRowStatus]
				and tlbActivityParameters_prev_rows_v6.[idfRow] <= tlbActivityParameters_v6.[idfRow]
				and p_v6.[blnIsGrid] = 1
) ffRow_v6



left join	[Giraffe].[dbo].[tlbActivityParameters] tlbActivityParameters_v7
	inner join	@AllParametersV7 p_v7
	on			p_v7.[idfsParameter] = tlbActivityParameters_v7.[idfsParameter]
on			tlbActivityParameters_v7.[idfObservation] = tlbHumanCase_v7.[idfCSObservation]
				and tlbActivityParameters_v7.[intRowStatus] <= tlbHumanCase_v7.[intRowStatus]
				and tlbActivityParameters_v7.varValue is not null

left join	@ParametersTableV7 pft_v7
on			pft_v7.[idfsParameter] = tlbActivityParameters_v7.[idfsParameter]
			and pft_v7.[idfsFormTemplate] = tlbObservation_v7.[idfsFormTemplate]

left join	[Giraffe].[dbo].[trtBaseReference] ffValBR_v7
on			ffValBR_v7.idfsReferenceType = p_v7.idfsReferenceType
			and cast(ffValBR_v7.idfsBaseReference as nvarchar(20)) = CAST(tlbActivityParameters_v7.varValue as nvarchar)
left join	[Giraffe].[dbo].[trtStringNameTranslation] ffValBR_en_v7
on			ffValBR_en_v7.idfsBaseReference = ffValBR_v7.idfsBaseReference
			and ffValBR_en_v7.idfsLanguage = @intLngEn
left join	[Giraffe].[dbo].[trtStringNameTranslation] ffValBR_lng_v7
on			ffValBR_lng_v7.idfsBaseReference = ffValBR_v7.idfsBaseReference
			and ffValBR_lng_v7.idfsLanguage = @intLngNat

outer apply
(	select		count(distinct tlbActivityParameters_prev_rows_v7.idfRow) as intRowNum
	from		[Giraffe].[dbo].[tlbActivityParameters] tlbActivityParameters_prev_rows_v7
	inner join	@AllParametersV7 p_same_grid_v7
	on			p_same_grid_v7.[idfsParameter] = tlbActivityParameters_prev_rows_v7.[idfsParameter]
				and p_same_grid_v7.[blnIsGrid] = 1
				and p_same_grid_v7.[idfsRootGridSection] = p_v7.[idfsRootGridSection]
	where		tlbActivityParameters_prev_rows_v7.[idfObservation] = tlbHumanCase_v7.[idfCSObservation]
				and tlbActivityParameters_prev_rows_v7.[intRowStatus] <= tlbHumanCase_v7.[intRowStatus]
				and tlbActivityParameters_prev_rows_v7.[idfRow] <= tlbActivityParameters_v7.[idfRow]
				and p_v7.[blnIsGrid] = 1
) ffRow_v7

where	(tlbActivityParameters_v6.idfActivityParameters is not null and (tlbActivityParameters_v7.idfActivityParameters is null or (tlbActivityParameters_v6.idfActivityParameters = tlbActivityParameters_v7.idfActivityParameters)))
		or (tlbActivityParameters_v6.idfActivityParameters is null)