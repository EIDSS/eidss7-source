-- This script selects content of all FF templates with specified type.
-- Script should be executed on the database with FF that should be selected.
--
-- Parameters @NumberOfLanguages 
-- (number of languages: 1 = only English, 2 = English + one national language, 3 = English + two national languages), 
-- @LangID (national language), and @SecLangID (second national language), as well as @FormTypeEN (English name of FF Type) should be changed 
-- in the section "Set parameter values" to required values.
--
-- If second national language is not applicable for your country, you should set the same values to both parameters.
-- 'ar' - Arabic (Iraqi) language
-- 'az-L' - Azerbaijani language
-- 'hy' - Armenian language
-- 'ka' - Georgian language
-- 'kk' - Kazakh Language
-- 'ru' - Russian language
-- 'uk' - Ukrainian language

declare	@LangID		varchar(36)
declare	@SecLangID	varchar(36)
declare @NumberOfLanguages int
declare	@FormTypeEN	nvarchar(2000)

-- Set parameter values
set @NumberOfLanguages = 2 -- 1 = only English, 2 = English + one national language, 3 = English + two national languages
set	@LangID = 'ka'
set	@SecLangID = 'ru'

set	@FormTypeEN = 
-- N'Avian Farm EPI'
-- N'Avian Farm EPI'
-- N'Avian Species CS'
--N'Human Aggregate Case'
--N'Human Clinical Signs'
N'Human Epi Investigations'
-- N'Livestock Animal CS'
-- N'Livestock Control Measures'
-- N'Livestock Farm EPI'
-- N'Livestock Species CS'
-- N'Test Details'
-- N'Test Run'
-- N'Vector type specific data'
-- N'Vet Aggregate Case'
-- N'Diagnostic investigations'
-- N'Treatment-prophylactics and vaccination measures'
-- N'Veterinary-sanitary measures'

-- Impementation

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


declare	@NationalLng	nvarchar(100)
declare	@SecNationalLng	nvarchar(100)

select	@NationalLng = br.strDefault
from	trtBaseReference br
where	br.idfsBaseReference = dbo.fnGetLanguageCode(@LangID)

select	@SecNationalLng = br.strDefault
from	trtBaseReference br
where	br.idfsBaseReference = dbo.fnGetLanguageCode(@SecLangID)



declare	@SectionTable table
(	idfsSection					bigint not null,
	intParentLevel				int not null,
	idfsLevelParentSection		bigint null,
	blnIsGrid					bit not null,
	strLevelSectionPathEN		nvarchar(MAX) collate database_default not null,
	strLevelSectionPathLng		nvarchar(MAX) collate database_default not null,
	strLevelSectionPathSecLng	nvarchar(MAX) collate database_default not null,
	primary key
	(	idfsSection asc,
		intParentLevel asc
	)
)

declare	@AllSections	table
(	idfsSection			bigint not null primary key,
	idfsParentSection	bigint null,
	blnIsGrid			bit not null,
	strSectionEN		nvarchar(2000) collate database_default not null,
	strSectionLng		nvarchar(2000) collate database_default not null,
	strSectionSecLng	nvarchar(2000) collate database_default not null
)

insert into	@AllSections
(	idfsSection,
	idfsParentSection,
	blnIsGrid,
	strSectionEN,
	strSectionLng,
	strSectionSecLng
)
select		s.idfsSection,
			s_parent.idfsSection,
			IsNull(s.blnGrid, 0),
			r_s_en.[Name],
			r_s_lng.[Name],
			r_s_seclng.[Name]
from		
-- Sections
			ffSection s
inner join	fnReference('en', 19000101) r_s_en				-- Flexible Form Section
on			r_s_en.idfsReference = s.idfsSection

-- Link to country
left join	trtBaseReferenceToCP brc
on			brc.idfsBaseReference = s.idfsSection
			and brc.idfCustomizationPackage = @idfCustomizationPackage
			
-- Translations
left join	fnReference(@LangID, 19000101) r_s_lng			-- Flexible Form Section
on			r_s_lng.idfsReference = s.idfsSection
left join	fnReference(@SecLangID, 19000101) r_s_seclng	-- Flexible Form Section
on			r_s_seclng.idfsReference = s.idfsSection
-- Parent Sections
left join	(
	ffSection s_parent
	inner join	fnReference('en', 19000101) r_s_parent_en	-- Flexible Form Section
	on			r_s_parent_en.idfsReference = s_parent.idfsSection
			)
on			s_parent.idfsSection = s.idfsParentSection
			and s_parent.intRowStatus = 0
where		s.intRowStatus = 0
			and (	@idfCustomizationPackage is null
					or (	@idfCustomizationPackage is not null
							and	(	brc.idfsBaseReference is not null
									or (	brc.idfsBaseReference is null
											and not exists	(
														select		*
														from		trtBaseReferenceToCP brc_ex
														inner join	tstCustomizationPackage cp_ex
														on			cp_ex.idfCustomizationPackage = brc_ex.idfCustomizationPackage
														inner join	gisCountry c
														on			c.idfsCountry = brc_ex.idfCustomizationPackage
																	and c.intRowStatus = 0
														inner join	gisBaseReference br_c
														on			br_c.idfsGISBaseReference = c.idfsCountry
																	and br_c.intRowStatus = 0
														where		brc_ex.idfsBaseReference = s.idfsSection

															)
										)
								)
						)
				)

;
with	sectionTable	(
			idfsSection,
			intParentLevel,
			idfsLevelParentSection,
			blnIsGrid,
			strLevelSectionPathEN,
			strLevelSectionPathLng,
			strLevelSectionPathSecLng
					)
as	(	select		s.idfsSection,
					0 as intParentLevel,
					s.idfsParentSection as idfsLevelParentSection,
					s.blnIsGrid,
					cast(s.strSectionEN as nvarchar(MAX)) as strLevelSectionPathEN,
					cast(s.strSectionLng as nvarchar(MAX)) as strLevelSectionPathLng,
					cast(s.strSectionSecLng as nvarchar(MAX)) as strLevelSectionPathSecLng
		from		@AllSections s
		union all
		select		sectionTable.idfsSection,
					sectionTable.intParentLevel + 1 as intParentLevel,
					s_all.idfsParentSection as idfsLevelParentSection,
					sectionTable.blnIsGrid,
					cast((s_all.strSectionEN + N'>' + sectionTable.strLevelSectionPathEN) as nvarchar(MAX)) as strLevelSectionPathEN,
					cast((s_all.strSectionLng + N'>' + sectionTable.strLevelSectionPathLng) as nvarchar(MAX)) as strLevelSectionPathLng,
					cast((s_all.strSectionSecLng + N'>' + sectionTable.strLevelSectionPathSecLng) as nvarchar(MAX)) as strLevelSectionPathSecLng
		from		@AllSections s_all
		inner join	sectionTable
		on			sectionTable.idfsLevelParentSection = s_all.idfsSection
	)

insert into	@SectionTable
(	idfsSection,
	intParentLevel,
	idfsLevelParentSection,
	blnIsGrid,
	strLevelSectionPathEN,
	strLevelSectionPathLng,
	strLevelSectionPathSecLng
)
select		idfsSection,
			intParentLevel,
			idfsLevelParentSection,
			blnIsGrid,
			strLevelSectionPathEN,
			strLevelSectionPathLng,
			strLevelSectionPathSecLng
from		sectionTable


declare	@ParametersTable	table
(	FormType					nvarchar(300) collate database_default not null,
	Template					nvarchar(300) collate database_default not null,
	blnIsGrid					bit not null,
	ParameterOrderInTemplate	int not null,
	ParameterTop				int not null,
	ParameterNameEN				nvarchar(600) collate database_default not null,
	ParameterType				nvarchar(300) collate database_default not null,
	TooltipEN					nvarchar(600) collate database_default not null,
	SectionPathEN				nvarchar(1000) collate database_default not null,
	SectionNameEN				nvarchar(300) collate database_default not null,
	Editor						nvarchar(100) collate database_default not null,
	Mode						nvarchar(100) collate database_default not null,
	ParameterNameLng			nvarchar(1000) collate database_default null,
	ParameterNameSecLng			nvarchar(1000) collate database_default null,
	TooltipLng					nvarchar(1000) collate database_default null,
	TooltipSecLng				nvarchar(1000) collate database_default null,
	ParameterID					nvarchar(20) collate database_default not null,
	TemplateID					bigint null,
	primary key
	(	Template,
		ParameterOrderInTemplate,
		Parametertop
	)
)

-- Parameters
insert into	@ParametersTable
(	FormType,
	Template,
	blnIsGrid,
	ParameterOrderInTemplate,
	ParameterTop,
	ParameterNameEN,
	ParameterType,
	TooltipEN,
	SectionPathEN,
	SectionNameEN,
	Editor,
	Mode,
	ParameterNameLng,
	ParameterNameSecLng,
	TooltipLng,
	TooltipSecLng,
	ParameterID,
	TemplateID
)
select		replace	(
				replace	(
					replace	(
						r_ft.[name], 
						N'Vet Epizootic Action Diagnosis Inv',
						N'Diagnostic investigations'
							),
					N'Vet Epizootic Action Treatment',
					N'Treatment-prophylactics and vaccination measures'
						),
				N'Vet Epizootic Action', 
				N'Veterinary-sanitary measures'
					) as FormType,
			r_t.[Name] + 
				case
					when t_same_name_number.intNumber > 0 
						then N' - ' + cast((t_same_name_number.intNumber+1) as nvarchar) collate Cyrillic_General_CI_AS
					else N''
				end collate Cyrillic_General_CI_AS as Template,
			IsNull(st_min.blnIsGrid, 0), 
			IsNull(pdo.intOrder, pdo_def.intOrder) as ParameterOrderInTemplate, 
			IsNull	(
				(	select		sum(IsNull(sdo_parent.intTop, 0))
					from		@SectionTable st_sdo
--					inner join	ffSectionForTemplate sft_sdo
--					on			sft_sdo.idfsSection = st_sdo.idfsLevelParentSection
--								and sft_sdo.idfsFormTemplate = t.idfsFormTemplate
--								and sft_sdo.intRowStatus = 0
					inner join	ffSectionDesignOption sdo_parent
					on			sdo_parent.idfsSection = st_sdo.idfsLevelParentSection
								and sdo_parent.idfsFormTemplate = t.idfsFormTemplate
								and sdo_parent.idfsLanguage = dbo.fnGetLanguageCode('en')
								and sdo_parent.intRowStatus = 0
					where		st_sdo.idfsSection = st_min.idfsSection
				), 0
					) + IsNull(sdo.intTop, 0) + (1 - IsNull(st_min.blnIsGrid, 0)) * IsNull(pdo.intTop, pdo_def.intTop) as ParameterTop,
			r_pc.[Name] as ParameterNameEN,
			r_pt.[Name] as ParameterType,
			r_p.[Name] as TooltipEN,
			IsNull(st_max.strLevelSectionPathEN, N'None') as SectionPathEN,
			IsNull(st_min.strLevelSectionPathEN, N'None') as SectionNameEN,
			IsNull(r_editor.[Name], N'None') as Editor,
			replace	(
				replace	(
					IsNull(cast(r_mode.idfsReference as nvarchar(20)), N'None'),
					N'10068003',
					N'Mandatory'
						),
				N'10068001',
				N'Ordinary'
					) as Mode,
			r_pc_lng.[Name] as ParameterNameLng,
			r_pc_sec_lng.[Name] as ParameterNameSecLng,
			r_p_lng.[Name] as TooltipLng,
			r_p_sec_lng.[Name] as TooltipSecLng,
			cast(p.idfsParameter as nvarchar(20)) as ParameterID,
			t.idfsFormTemplate as TemplateID
from
-- Parameters in templates		
			ffParameter p
inner join	ffParameterforTemplate pft
on			pft.idfsParameter = p.idfsParameter
			and pft.intRowStatus = 0
inner join	ffFormTemplate t
on			t.idfsFormTemplate = pft.idfsFormTemplate
			and t.intRowStatus = 0
inner join	fnReference('en', 19000033) r_t					-- Flexible Form Template
on			r_t.idfsReference = t.idfsFormTemplate
inner join	fnReference('en', 19000066) r_p					-- Flexible Form Parameter
on			r_p.idfsReference = p.idfsParameter
inner join	fnReference('en', 19000034) r_ft				-- Flexible Form Type
on			r_ft.idfsReference = p.idfsFormType
outer apply
(	select	count(distinct t_same_name.idfsFormTemplate) as intNumber
	from	ffFormTemplate t_same_name
	join	fnReference('en', 19000033) r_t_same_name		-- Flexible Form Template
	on		r_t_same_name.idfsReference = t_same_name.idfsFormTemplate
	where	t_same_name.idfsFormType = t.idfsFormType
			and t_same_name.intRowStatus = 0
			and r_t_same_name.[name] = r_t.[name] collate Cyrillic_General_CI_AS
			and t_same_name.idfsFormTemplate < t.idfsFormTemplate
) t_same_name_number

-- Link to country
left join	trtBaseReferenceToCP brc
on			brc.idfsBaseReference = p.idfsParameter
			and brc.idfCustomizationPackage = @idfCustomizationPackage

-- Translations
left join	fnReference(@LangID, 19000033) r_t_lng			-- Flexible Form Template
on			r_t_lng.idfsReference = t.idfsFormTemplate
left join	fnReference(@SecLangID, 19000033) r_t_sec_lng	-- Flexible Form Template
on			r_t_sec_lng.idfsReference = t.idfsFormTemplate
left join	fnReference(@LangID, 19000066) r_p_lng			-- Flexible Form Parameter
on			r_p_lng.idfsReference = p.idfsParameter
left join	fnReference(@SecLangID, 19000066) r_p_sec_lng	-- Flexible Form Parameter
on			r_p_sec_lng.idfsReference = p.idfsParameter

-- Parameter nullable attributes
left join	fnReference('en', 19000068) r_mode				-- Flexible Form Parameter Mode
on			r_mode.idfsReference = pft.idfsEditMode
left join	fnReference('en', 19000067)	r_editor			-- Flexible Form Parameter Editor
on			r_editor.idfsReference = p.idfsEditor

-- Parameter sizes and location
left join	ffParameterDesignOption pdo
on			pdo.idfsParameter = p.idfsParameter
			and pdo.idfsFormTemplate = t.idfsFormTemplate
			and pdo.idfsLanguage = dbo.fnGetLanguageCode('en')
			and pdo.intRowStatus = 0
left join	ffParameterDesignOption pdo_def
on			pdo_def.idfsParameter = p.idfsParameter
			and pdo_def.idfsFormTemplate is null
			and pdo_def.idfsLanguage = dbo.fnGetLanguageCode('en')
			and pdo_def.intRowStatus = 0

-- Parameter captions (names) with translations
left join	fnReference('en', 19000070) r_pc				-- Flexible Form Parameter Tooltip
on			r_pc.idfsReference = p.idfsParameterCaption
left join	fnReference(@LangID, 19000070) r_pc_lng			-- Flexible Form Parameter Tooltip
on			r_pc_lng.idfsReference = p.idfsParameterCaption
left join	fnReference(@SecLangID, 19000070) r_pc_sec_lng	-- Flexible Form Parameter Tooltip
on			r_pc_sec_lng.idfsReference = p.idfsParameterCaption

-- Parameter types
left join	(
	ffParameterType pt
	inner join	fnReference('en', 19000071) r_pt			-- Flexible Form Parameter Type
	on			r_pt.idfsReference = pt.idfsParameterType
			)
on			pt.idfsParameterType = p.idfsParameterType
			and pt.intRowStatus = 0

-- Parameter sections with their sizes and location
--left join	(
--	ffSection s
--	inner join	fnReference('en', 19000101) r_s		-- Flexible Form Section
--	on			r_s.idfsReference = s.idfsSection
--			)
--on			s.idfsSection = p.idfsSection
--			and s.intRowStatus = 0
left join	@SectionTable st_min
on			st_min.idfsSection = p.idfsSection
			and st_min.intParentLevel = 0
left join	@SectionTable st_max
on			st_max.idfsSection = p.idfsSection
			and st_max.idfsLevelParentSection is null
left join	ffSectionDesignOption sdo
on			sdo.idfsSection = st_min.idfsSection
			and sdo.idfsFormTemplate = t.idfsFormTemplate
			and sdo.idfsLanguage = dbo.fnGetLanguageCode('en')
			and sdo.intRowStatus = 0
where		p.intRowStatus = 0
			and replace	(
					replace	(
						replace	(
							r_ft.[name], 
							N'Vet Epizootic Action Diagnosis Inv',
							N'Diagnostic investigations'
								),
						N'Vet Epizootic Action Treatment',
						N'Treatment-prophylactics and vaccination measures'
							),
					N'Vet Epizootic Action', 
					N'Veterinary-sanitary measures'
						) = @FormTypeEN
			and (	@idfCustomizationPackage is null
					or (	@idfCustomizationPackage is not null
							and	(	brc.idfsBaseReference is not null
									or (	brc.idfsBaseReference is null
											and not exists	(
														select		*
														from		trtBaseReferenceToCP brc_ex
														inner join	tstCustomizationPackage cp_ex
														on			cp_ex.idfCustomizationPackage = brc_ex.idfCustomizationPackage
														inner join	gisCountry c
														on			c.idfsCountry = brc_ex.idfCustomizationPackage
																	and c.intRowStatus = 0
														inner join	gisBaseReference br_c
														on			br_c.idfsGISBaseReference = c.idfsCountry
																	and br_c.intRowStatus = 0
														where		brc_ex.idfsBaseReference = p.idfsParameter

															)
										)
								)
						)
				)
			
union all
-- Labels
select		replace	(
				replace	(
					replace	(
						r_ft.[name], 
						N'Vet Epizootic Action Diagnosis Inv',
						N'Diagnostic investigations'
							),
					N'Vet Epizootic Action Treatment',
					N'Treatment-prophylactics and vaccination measures'
						),
				N'Vet Epizootic Action', 
				N'Veterinary-sanitary measures'
					) as FormType,
			r_t.[Name] + 
				case
					when t_same_name_number.intNumber > 0 
						then N' - ' + cast((t_same_name_number.intNumber+1) as nvarchar) collate Cyrillic_General_CI_AS
					else N''
				end collate Cyrillic_General_CI_AS as Template,
			0 as blnIsGrid, 
			IsNull	(
				(	select		max(IsNull(pdo.intOrder, pdo_def.intOrder)) + 1
					from		ffParameter p
					inner join	ffParameterforTemplate pft_p
					on			pft_p.idfsParameter = p.idfsParameter
								and pft_p.intRowStatus = 0
					inner join	ffFormTemplate t_p
					on			t_p.idfsFormTemplate = pft_p.idfsFormTemplate
								and t_p.intRowStatus = 0
					inner join	fnReference('en', 19000033) r_t_p					-- Flexible Form Template
					on			r_t_p.idfsReference = t.idfsFormTemplate
					inner join	fnReference('en', 19000066) r_p					-- Flexible Form Parameter
					on			r_p.idfsReference = p.idfsParameter
					inner join	fnReference('en', 19000034) r_ft_p				-- Flexible Form Type
					on			r_ft_p.idfsReference = p.idfsFormType
					left join	ffParameterDesignOption pdo
					on			pdo.idfsParameter = p.idfsParameter
								and pdo.idfsFormTemplate = t_p.idfsFormTemplate
								and pdo.idfsLanguage = dbo.fnGetLanguageCode('en')
								and pdo.intRowStatus = 0
					left join	ffParameterDesignOption pdo_def
					on			pdo_def.idfsParameter = p.idfsParameter
								and pdo_def.idfsFormTemplate is null
								and pdo_def.idfsLanguage = dbo.fnGetLanguageCode('en')
								and pdo_def.intRowStatus = 0
					where		p.intRowStatus = 0
								and t_p.idfsFormTemplate = t.idfsFormTemplate
								and	(	p.idfsSection = st_min.idfsSection
										or	(	p.idfsSection is null
												and st_min.idfsSection is null
											)
									)
								and IsNull(pdo.intTop, pdo_def.intTop) < det.intTop
				),
				IsNull	(
					(	select	/*	IsNull	(
										(	select		max(IsNull(pdo_s.intOrder + 1, pdo_def_s.intOrder + 1))
											from		ffParameter p_s
											inner join	ffParameterforTemplate pft_p_s
											on			pft_p_s.idfsParameter = p_s.idfsParameter
														and pft_p_s.intRowStatus = 0
											inner join	fnReference('en', 19000066) r_p_s					-- Flexible Form Parameter
											on			r_p_s.idfsReference = p_s.idfsParameter
											inner join	fnReference('en', 19000034) r_ft_p_s				-- Flexible Form Type
											on			r_ft_p_s.idfsReference = p_s.idfsFormType
											left join	ffParameterDesignOption pdo_s
											on			pdo_s.idfsParameter = p_s.idfsParameter
														and pdo_s.idfsFormTemplate = pft_p_s.idfsFormTemplate
														and pdo_s.idfsLanguage = dbo.fnGetLanguageCode('en')
														and pdo_s.intRowStatus = 0
											left join	ffParameterDesignOption pdo_def_s
											on			pdo_def_s.idfsParameter = p_s.idfsParameter
														and pdo_def_s.idfsFormTemplate is null
														and pdo_def_s.idfsLanguage = dbo.fnGetLanguageCode('en')
														and pdo_def_s.intRowStatus = 0
											where		pft_p_s.idfsFormTemplate = t.idfsFormTemplate
														and p_s.idfsSection = st_prev.idfsSection
														and p_s.intRowStatus = 0
														and (	pdo_s.idfParameterDesignOption is not null
																or pdo_def_s.idfParameterDesignOption is not null
															)
										)
											), sdo_prev.intOrder + 1)
									*/
									IsNull(pdo_s.intOrder + 1, IsNull(pdo_def_s.intOrder + 1, sdo_prev.intOrder + 1))
						from		@SectionTable st_prev
						inner join	ffSectionForTemplate sft_prev
						on			sft_prev.idfsSection = st_prev.idfsSection
									and sft_prev.idfsFormTemplate = t.idfsFormTemplate
									and sft_prev.intRowStatus = 0
						inner join	ffSectionDesignOption sdo_prev
						on			sdo_prev.idfsSection = st_prev.idfsSection
									and sdo_prev.idfsFormTemplate = t.idfsFormTemplate
									and sdo_prev.idfsLanguage = dbo.fnGetLanguageCode('en')
									and sdo_prev.intRowStatus = 0
						left join	(
							ffParameter p_s
							inner join	ffParameterforTemplate pft_p_s
							on			pft_p_s.idfsParameter = p_s.idfsParameter
										and pft_p_s.intRowStatus = 0
							inner join	fnReference('en', 19000066) r_p_s					-- Flexible Form Parameter
							on			r_p_s.idfsReference = p_s.idfsParameter
							inner join	fnReference('en', 19000034) r_ft_p_s				-- Flexible Form Type
							on			r_ft_p_s.idfsReference = p_s.idfsFormType
							left join	ffParameterDesignOption pdo_s
							on			pdo_s.idfsParameter = p_s.idfsParameter
										and pdo_s.idfsFormTemplate = pft_p_s.idfsFormTemplate
										and pdo_s.idfsLanguage = dbo.fnGetLanguageCode('en')
										and pdo_s.intRowStatus = 0
							left join	ffParameterDesignOption pdo_def_s
							on			pdo_def_s.idfsParameter = p_s.idfsParameter
										and pdo_def_s.idfsFormTemplate is null
										and pdo_def_s.idfsLanguage = dbo.fnGetLanguageCode('en')
										and pdo_def_s.intRowStatus = 0
									)
						on			pft_p_s.idfsFormTemplate = t.idfsFormTemplate
									and p_s.idfsSection = st_prev.idfsSection
									and p_s.intRowStatus = 0
									and (	pdo_s.idfParameterDesignOption is not null
											or pdo_def_s.idfParameterDesignOption is not null
										)
						left join	(
							ffParameter p_s_max
							inner join	ffParameterforTemplate pft_p_s_max
							on			pft_p_s_max.idfsParameter = p_s_max.idfsParameter
										and pft_p_s_max.intRowStatus = 0
							inner join	fnReference('en', 19000066) r_p_s_max				-- Flexible Form Parameter
							on			r_p_s_max.idfsReference = p_s_max.idfsParameter
							inner join	fnReference('en', 19000034) r_ft_p_s_max			-- Flexible Form Type
							on			r_ft_p_s_max.idfsReference = p_s_max.idfsFormType
							left join	ffParameterDesignOption pdo_s_max
							on			pdo_s_max.idfsParameter = p_s_max.idfsParameter
										and pdo_s_max.idfsFormTemplate = pft_p_s_max.idfsFormTemplate
										and pdo_s_max.idfsLanguage = dbo.fnGetLanguageCode('en')
										and pdo_s_max.intRowStatus = 0
							left join	ffParameterDesignOption pdo_def_s_max
							on			pdo_def_s_max.idfsParameter = p_s_max.idfsParameter
										and pdo_def_s_max.idfsFormTemplate is null
										and pdo_def_s_max.idfsLanguage = dbo.fnGetLanguageCode('en')
										and pdo_def_s_max.intRowStatus = 0
									)
						on			pft_p_s_max.idfsFormTemplate = t.idfsFormTemplate
									and p_s_max.idfsSection = st_prev.idfsSection
									and (	pdo_s_max.idfParameterDesignOption is not null
											or pdo_def_s_max.idfParameterDesignOption is not null
										)
									and (	IsNull(pdo_s_max.intOrder, pdo_def_s_max.intOrder)>
											IsNull(pdo_s.intOrder, pdo_def_s.intOrder)
											or	(	IsNull(pdo_s_max.intOrder, pdo_def_s_max.intOrder) =
													IsNull(pdo_s.intOrder, pdo_def_s.intOrder)
													and IsNull(	pdo_s_max.idfParameterDesignOption,
																pdo_def_s_max.idfParameterDesignOption)>
														IsNull(	pdo_s.idfParameterDesignOption,
																pdo_def_s.idfParameterDesignOption)
														
												)
										)
									and p_s_max.intRowStatus = 0
						left join	(
							@SectionTable st_prev_max
							inner join	ffSectionForTemplate sft_prev_max
							on			sft_prev_max.idfsSection = st_prev_max.idfsSection
										and sft_prev_max.intRowStatus = 0
							inner join	ffSectionDesignOption sdo_prev_max
							on			sdo_prev_max.idfsSection = st_prev_max.idfsSection
										and sdo_prev_max.idfsLanguage = dbo.fnGetLanguageCode('en')
										and sdo_prev_max.intRowStatus = 0
									)
						on			sdo_prev_max.idfsFormTemplate = t.idfsFormTemplate
									and (	st_prev_max.idfsLevelParentSection = st_min.idfsSection
											or	(	st_prev_max.idfsLevelParentSection is null
													and st_min.idfsSection is null
												)
										)
									and sdo_prev_max.intTop < det.intTop
									and (	sdo_prev_max.intTop>sdo_prev.intTop
											or	(	sdo_prev_max.intTop = sdo_prev.intTop
													and sdo_prev_max.idfSectionDesignOption>
														sdo_prev.idfSectionDesignOption
												)
										)
						where		(	st_prev.idfsLevelParentSection = st_min.idfsSection
										or	(	st_prev.idfsLevelParentSection is null
												and st_min.idfsSection is null
											)
									)
									and sdo_prev.intTop < det.intTop
									and sdo_prev_max.idfSectionDesignOption is null
									and p_s_max.idfsParameter is null
					),
					IsNull(sdo.intOrder + 1, 0)
						)
			) as ParameterOrderInTemplate,
			IsNull	(
				(	select		sum(IsNull(sdo_parent.intTop, 0))
					from		@SectionTable st_sdo
--					inner join	ffSectionForTemplate sft_sdo
--					on			sft_sdo.idfsSection = st_sdo.idfsLevelParentSection
--								and sft_sdo.idfsFormTemplate = t.idfsFormTemplate
--								and sft_sdo.intRowStatus = 0
					inner join	ffSectionDesignOption sdo_parent
					on			sdo_parent.idfsSection = st_sdo.idfsLevelParentSection
								and sdo_parent.idfsFormTemplate = t.idfsFormTemplate
								and sdo_parent.idfsLanguage = dbo.fnGetLanguageCode('en')
								and sdo_parent.intRowStatus = 0
					where		st_sdo.idfsSection = st_min.idfsSection
				), 0
					) + IsNull(sdo.intTop, 0) + det.intTop as ParameterTop,
			r_l_en.[Name] as ParameterNameEN,
			N'Label' as ParameterType,
			N'' as TooltipEN,
			IsNull(st_max.strLevelSectionPathEN, N'None') as SectionPathEN,
			IsNull(st_min.strLevelSectionPathEN, N'None') as SectionNameEN,
			N'' as Editor,
			N'' as Mode,
			r_l_lng.[Name] as ParameterNameLng,
			r_l_seclng.[Name] as ParameterNameSecLng,
			N'' as TooltipLng,
			N'' as TooltipSecLng,
			N'' as ParameterID,
			null as TemplateID
from
-- Labels
		ffDecorElementText det
inner join	ffDecorElement de
on			de.idfDecorElement = det.idfDecorElement
			and de.idfsDecorElementType = 10106001	-- Label
			and de.idfsLanguage = dbo.fnGetLanguageCode('en')
			and de.intRowStatus = 0
inner join	ffFormTemplate t
on			t.idfsFormTemplate = de.idfsFormTemplate
			and t.intRowStatus = 0
inner join	fnReference('en', 19000033) r_t					-- Flexible Form Template
on			r_t.idfsReference = t.idfsFormTemplate
inner join	fnReference('en', 19000034) r_ft				-- Flexible Form Type
on			r_ft.idfsReference = t.idfsFormType
inner join	fnReference('en', 19000131) r_l_en				-- Flexible Form Label Text
on			r_l_en.idfsReference = det.idfsBaseReference
outer apply
(	select	count(distinct t_same_name.idfsFormTemplate) as intNumber
	from	ffFormTemplate t_same_name
	join	fnReference('en', 19000033) r_t_same_name		-- Flexible Form Template
	on		r_t_same_name.idfsReference = t_same_name.idfsFormTemplate
	where	t_same_name.idfsFormType = t.idfsFormType
			and t_same_name.intRowStatus = 0
			and r_t_same_name.[name] = r_t.[name] collate Cyrillic_General_CI_AS
			and t_same_name.idfsFormTemplate < t.idfsFormTemplate
) t_same_name_number

-- Translations
left join	fnReference(@LangID, 19000033) r_t_lng			-- Flexible Form Template
on			r_t_lng.idfsReference = t.idfsFormTemplate
left join	fnReference(@SecLangID, 19000033) r_t_sec_lng	-- Flexible Form Template
on			r_t_sec_lng.idfsReference = t.idfsFormTemplate
left join	fnReference(@LangID, 19000131) r_l_lng			-- Flexible Form Label Text
on			r_l_lng.idfsReference = det.idfsBaseReference
left join	fnReference(@SecLangID, 19000131) r_l_seclng	-- Flexible Form Label Text
on			r_l_seclng.idfsReference = det.idfsBaseReference

-- Link to country
left join	trtBaseReferenceToCP brc
on			brc.idfsBaseReference = r_l_en.idfsReference
			and brc.idfCustomizationPackage = @idfCustomizationPackage

-- Label sections with sizes and location
left join	@SectionTable st_min
on			st_min.idfsSection = de.idfsSection
			and st_min.intParentLevel = 0
left join	@SectionTable st_max
on			st_max.idfsSection = de.idfsSection
			and st_max.idfsLevelParentSection is null
left join	ffSectionDesignOption sdo
on			sdo.idfsSection = st_min.idfsSection
			and sdo.idfsFormTemplate = t.idfsFormTemplate
			and sdo.idfsLanguage = dbo.fnGetLanguageCode('en')
			and sdo.intRowStatus = 0
where		det.intRowStatus = 0
			and replace	(
					replace	(
						replace	(
							r_ft.[name], 
							N'Vet Epizootic Action Diagnosis Inv',
							N'Diagnostic investigations'
								),
						N'Vet Epizootic Action Treatment',
						N'Treatment-prophylactics and vaccination measures'
							),
					N'Vet Epizootic Action', 
					N'Veterinary-sanitary measures'
						) = @FormTypeEN
			and (	@idfCustomizationPackage is null
					or (	@idfCustomizationPackage is not null
							and	(	brc.idfsBaseReference is not null
									or (	brc.idfsBaseReference is null
											and not exists	(
														select		*
														from		trtBaseReferenceToCP brc_ex
														inner join	tstCustomizationPackage cp_ex
														on			cp_ex.idfCustomizationPackage = brc_ex.idfCustomizationPackage
														inner join	gisCountry c
														on			c.idfsCountry = brc_ex.idfCustomizationPackage
																	and c.intRowStatus = 0
														inner join	gisBaseReference br_c
														on			br_c.idfsGISBaseReference = c.idfsCountry
																	and br_c.intRowStatus = 0
														where		brc_ex.idfsBaseReference = r_l_en.idfsReference

															)
										)
								)
						)
				)
order by	Template, ParameterOrderInTemplate--, ParameterTop

declare	@SectionsOrderTable	table
(	idfsFormTemplate			bigint not null,
	idfsSection					bigint not null,
	intParentLevel				int not null,
	idfsLevelParentSection		bigint null,
	blnIsGrid					bit not null,
	strLevelSectionPathEN		nvarchar(1000) collate database_default not null,
	strLevelSectionPathLng		nvarchar(1000) collate database_default null,
	strLevelSectionPathSecLng	nvarchar(1000) collate database_default null,
	intOrderInParentSection		int not null default(0),
	intCountOfChildSections		int not null default(0),
	intOrderInTemplate			int null default(0),
	primary key
	(	idfsFormTemplate asc,
		idfsSection asc,
		intParentLevel asc
	)
)

insert into	@SectionsOrderTable
(	idfsFormTemplate,
	idfsSection,
	intParentLevel,
	idfsLevelParentSection,
	blnIsGrid,
	strLevelSectionPathEN,
	strLevelSectionPathLng,
	strLevelSectionPathSecLng,
	intOrderInParentSection,
	intCountOfChildSections,
	intOrderInTemplate
)
select		t.idfsFormTemplate,
			st.idfsSection,
			st.intParentLevel,
			st.idfsLevelParentSection,
			st.blnIsGrid,
			st.strLevelSectionPathEN,
			st.strLevelSectionPathLng,
			st.strLevelSectionPathSecLng,
			0,
			0,
			0
from		@SectionTable st
inner join	ffSection s
on			s.idfsSection = st.idfsSection
inner join	fnReference('en', 19000034) r_ft				-- Flexible Form Type
on			r_ft.idfsReference = s.idfsFormType
			and r_ft.[Name] = @FormTypeEN
inner join	ffSectionForTemplate sft
on			sft.idfsSection = s.idfsSection
			and sft.intRowStatus = 0
inner join	ffFormTemplate t
on			t.idfsFormTemplate = sft.idfsFormTemplate
			and t.idfsFormType = s.idfsFormType
			and t.intRowStatus = 0


update		sot
set			sot.intOrderInParentSection = coalesce(Section_Order_in_ParentSection.intOrder, sdo.intOrder, 0)
from		@SectionsOrderTable sot
left join	ffSectionDesignOption sdo
on			sdo.idfsSection = sot.idfsSection
			and sdo.idfsFormTemplate = sot.idfsFormTemplate
			and sdo.idfsLanguage = dbo.fnGetLanguageCode('en')
			and sdo.intRowStatus = 0
outer apply
(	select		count(distinct s_same_Order_in_Template.idfsSection) as intOrder
	from		ffSection s_same_Order_in_Template
	join		ffSectionForTemplate sft_same_Order_in_Template
	on			sft_same_Order_in_Template.idfsSection = s_same_Order_in_Template.idfsSection
				and sft_same_Order_in_Template.intRowStatus = 0
				and sft_same_Order_in_Template.idfsFormTemplate = sot.idfsFormTemplate
	join		ffSectionDesignOption sdo_same_Order_in_Template
	on			sdo_same_Order_in_Template.idfsSection = s_same_Order_in_Template.idfsSection
				and sdo_same_Order_in_Template.idfsFormTemplate = sot.idfsFormTemplate
				and sdo_same_Order_in_Template.idfsLanguage = dbo.fnGetLanguageCode('en')
				and sdo_same_Order_in_Template.intRowStatus = 0
	where		s_same_Order_in_Template.intRowStatus = 0
				and (	(	s_same_Order_in_Template.idfsParentSection is null
							and sot.idfsLevelParentSection is null
						)
						or	s_same_Order_in_Template.idfsParentSection = sot.idfsLevelParentSection
					)
				and (	sdo_same_Order_in_Template.intTop < sdo.intTop
						or	(	sdo_same_Order_in_Template.intTop = sdo.intTop
								and sdo_same_Order_in_Template.intLeft < sdo.intLeft
							)
						or	(	sdo_same_Order_in_Template.intTop = sdo.intTop
								and sdo_same_Order_in_Template.intLeft = sdo.intLeft
								and sdo_same_Order_in_Template.idfSectionDesignOption < sdo.idfSectionDesignOption
							)
					)
) Section_Order_in_ParentSection
where		sot.intParentLevel = 0

update		sot
set			sot.intCountOfChildSections = isnull(childSections.intCount, 0)
from		@SectionsOrderTable sot
cross apply
(	select	count(distinct sot_level.idfsSection) intCount
	from	@SectionsOrderTable sot_level			
	where	sot_level.idfsFormTemplate = sot.idfsFormTemplate
			and sot_level.idfsLevelParentSection = sot.idfsSection
				and sot_level.idfsSection <> sot_level.idfsLevelParentSection
	
) childSections
where		sot.intParentLevel = 0

declare @SectionLevel int = 0
while @SectionLevel < 20
begin

	update		sot
	set			sot.intOrderInTemplate = 1 +
					isnull(sot_parent.intOrderInTemplate, 0) + 
					isnull(prev_sections_same_parent.intCountSameLevelSections, 0) + 
					isnull(prev_sections_same_parent.intCountOfChildSections, 0)
	from		@SectionsOrderTable sot
	inner join	@SectionsOrderTable sot_level
	on			sot_level.idfsFormTemplate = sot_level.idfsFormTemplate
				and sot_level.idfsSection = sot.idfsSection
				and sot_level.intParentLevel = @SectionLevel
				and sot_level.idfsLevelParentSection is null
	left join	@SectionsOrderTable sot_parent
	on			sot_parent.idfsFormTemplate = sot.idfsFormTemplate
				and sot_parent.idfsSection = sot.idfsLevelParentSection
				and sot_parent.intParentLevel = 0
	cross apply
	(	select	sum(sot_same_parent.intCountOfChildSections) as intCountOfChildSections,
				count(sot_same_parent.idfsSection) as intCountSameLevelSections
		from	@SectionsOrderTable sot_same_parent
		where	sot_same_parent.idfsFormTemplate = sot.idfsFormTemplate
				and	(	(sot_same_parent.idfsLevelParentSection is null and sot.idfsLevelParentSection is null)
						or sot_same_parent.idfsLevelParentSection = sot.idfsLevelParentSection
					)
				and sot_same_parent.intOrderInParentSection < sot.intOrderInParentSection
				and sot_same_parent.intParentLevel = 0
	
	) prev_sections_same_parent
	where		sot.intParentLevel = 0
				
	set @SectionLevel = @SectionLevel + 1
end

update		sot
set			sot.intOrderInTemplate = sot_level0.intOrderInTemplate,
			sot.intOrderInParentSection = sot_level0.intOrderInParentSection,
			sot.intCountOfChildSections = sot_level0.intCountOfChildSections
from		@SectionsOrderTable sot
inner join	@SectionsOrderTable sot_level0
on			sot_level0.idfsFormTemplate = sot.idfsFormTemplate
			and sot_level0.idfsSection = sot.idfsSection
			and sot_level0.intParentLevel = 0
where		sot.intParentLevel > 0


declare	@SectionsTable	table
(	FormType			nvarchar(300) collate database_default not null,
	Template			nvarchar(300) collate database_default not null,
	OrderInTemplate		int not null,
	SectionPathEN		nvarchar(1000) collate database_default not null,
	SectionNameEN		nvarchar(300) collate database_default not null,
	SectionType			varchar(50) collate database_default not null,
	ParentSectionEN		nvarchar(300) collate database_default not null,
	SectionNameLng		nvarchar(600) collate database_default null,
	SectionNameSecLng	nvarchar(600) collate database_default null,
	primary key
	(	Template,
		OrderInTemplate
	)
)

insert into	@SectionsTable
(	FormType,
	Template,
	OrderInTemplate,
	SectionPathEN,
	SectionNameEN,
	SectionType,
	ParentSectionEN,
	SectionNameLng,
	SectionNameSecLng
)
select		r_ft.[Name] as FormType,
			r_t.[Name] + 
				case
					when t_same_name_number.intNumber > 0 
						then N' - ' + cast((t_same_name_number.intNumber+1) as nvarchar) collate Cyrillic_General_CI_AS
					else N''
				end collate Cyrillic_General_CI_AS as Template,
			sot.intOrderInTemplate as OrderInTemplate,
			sot.strLevelSectionPathEN as SectionPathEN,
			st_min.strLevelSectionPathEN as SectionNameEN,
			case	IsNull(s.blnGrid, 0)
				when	0
					then	'Default'
				when	1
					then	'Table'
			end as SectionType,
			IsNull(	left(	st_parent.strLevelSectionPathEN, 
							len(st_parent.strLevelSectionPathEN) - len(st_min.strLevelSectionPathEN) - 1
						), 
					N'None') as ParentSectionEN,
			st_min.strLevelSectionPathLng as SectionNameLng,
			st_min.strLevelSectionPathSecLng as SectionNameSecLng

from		@SectionsOrderTable sot
inner join	ffSection s
on			s.idfsSection = sot.idfsSection
inner join	fnReference('en', 19000034) r_ft				-- Flexible Form Type
on			r_ft.idfsReference = s.idfsFormType
			and r_ft.[Name] = @FormTypeEN
inner join	fnReference('en', 19000033) r_t					-- Flexible Form Template
on			r_t.idfsReference = sot.idfsFormTemplate
outer apply
(	select	count(distinct t_same_name.idfsFormTemplate) as intNumber
	from	ffFormTemplate t_same_name
	join	fnReference('en', 19000033) r_t_same_name		-- Flexible Form Template
	on		r_t_same_name.idfsReference = t_same_name.idfsFormTemplate
	where	t_same_name.idfsFormType = s.idfsFormType
			and t_same_name.intRowStatus = 0
			and r_t_same_name.[name] = r_t.[name] collate Cyrillic_General_CI_AS
			and t_same_name.idfsFormTemplate < sot.idfsFormTemplate
) t_same_name_number
left join	fnReference(@LangID, 19000033) r_t_lng			-- Flexible Form Template
on			r_t_lng.idfsReference = sot.idfsFormTemplate
left join	fnReference(@SecLangID, 19000033) r_t_sec_lng	-- Flexible Form Template
on			r_t_sec_lng.idfsReference = sot.idfsFormTemplate
left join	@SectionTable st_min
on			st_min.idfsSection = sot.idfsSection
			and st_min.intParentLevel = 0
left join	@SectionTable st_parent
on			st_parent.idfsSection = sot.idfsSection
			and st_parent.intParentLevel = 1
where		sot.idfsLevelParentSection is null
order by	r_t.[Name], sot.intOrderInTemplate, sot.strLevelSectionPathEN, s.idfsSection


if @NumberOfLanguages = 3
begin
select		st.FormType as N'Form Type (EN)',
			st.Template as N'Form Template (EN)',
			(	select	count(*)
				from	@SectionsTable st_less
				where	st_less.Template = st.Template
						and st_less.OrderInTemplate <= st.OrderInTemplate
			) as 'Order In Template',
			st.SectionPathEN as N'Section Full Path',
			st.SectionNameEN as N'Section Name (EN)',
			st.SectionNameLng as N'Section Name (National)',
			st.SectionNameSecLng as N'Section Name (Second National)',
			st.SectionType as N'Section Type',
			st.ParentSectionEN as N'Parent Section'
from		@SectionsTable st
order by	st.Template, 'Order In Template'

select		pt.FormType as N'Form Type (EN)',
			pt.Template as N'Form Template (EN)',
			(	select	count(*)
				from	@ParametersTable pt_less
				where	pt_less.Template = pt.Template
						and (	pt_less.ParameterTop < pt.ParameterTop
								or	(	pt_less.ParameterTop = pt.ParameterTop
										and pt_less.ParameterOrderInTemplate <= pt.ParameterOrderInTemplate
									)
							)
			) as 'Order In Template',
			pt.ParameterNameEN as N'Parameter Name (EN)',
			pt.ParameterNameLng as N'Parameter Name (National)',
			pt.ParameterNameSecLng as N'Parameter Name (Second National)',
			pt.ParameterType as N'Parameter Type',
			pt.TooltipEN as N'Tooltip (EN)',
			pt.TooltipLng as N'Tooltip (National)',
			pt.TooltipSecLng as N'Tooltip (Second National)',
			pt.SectionPathEN as N'Section Full Path',
			pt.SectionNameEN as N'Section Name',
			pt.Editor,
			pt.Mode,
			pt.ParameterID as N'Parameter ID',
			isnull(cast(pt.TemplateID as nvarchar), N'') as N'Template ID'
from		@ParametersTable pt
order by	pt.Template, 'Order In Template'
end

if @NumberOfLanguages = 2
begin
select		st.FormType as N'Form Type (EN)',
			st.Template as N'Form Template (EN)',
			(	select	count(*)
				from	@SectionsTable st_less
				where	st_less.Template = st.Template
						and st_less.OrderInTemplate <= st.OrderInTemplate
			) as 'Order In Template',
			st.SectionPathEN as N'Section Full Path',
			st.SectionNameEN as N'Section Name (EN)',
			st.SectionNameLng as N'Section Name (National)',
			st.SectionType as N'Section Type',
			st.ParentSectionEN as N'Parent Section'
from		@SectionsTable st
order by	st.Template, 'Order In Template'

select		pt.FormType as N'Form Type (EN)',
			pt.Template as N'Form Template (EN)',
			(	select	count(*)
				from	@ParametersTable pt_less
				where	pt_less.Template = pt.Template
						and (	pt_less.ParameterTop < pt.ParameterTop
								or	(	pt_less.ParameterTop = pt.ParameterTop
										and pt_less.ParameterOrderInTemplate <= pt.ParameterOrderInTemplate
									)
							)
			) as 'Order In Template',
			pt.ParameterNameEN as N'Parameter Name (EN)',
			pt.ParameterNameLng as N'Parameter Name (National)',
			pt.ParameterType as N'Parameter Type',
			pt.TooltipEN as N'Tooltip (EN)',
			pt.TooltipLng as N'Tooltip (National)',
			pt.SectionPathEN as N'Section Full Path',
			pt.SectionNameEN as N'Section Name',
			pt.Editor,
			pt.Mode,
			pt.ParameterID as N'Parameter ID',
			isnull(cast(pt.TemplateID as nvarchar), N'') as N'Template ID'
from		@ParametersTable pt
order by	pt.Template, 'Order In Template'
end

if @NumberOfLanguages = 1
begin
select		st.FormType as N'Form Type (EN)',
			st.Template as N'Form Template (EN)',
			(	select	count(*)
				from	@SectionsTable st_less
				where	st_less.Template = st.Template
						and st_less.OrderInTemplate <= st.OrderInTemplate
			) as 'Order In Template',
			st.SectionPathEN as N'Section Full Path',
			st.SectionNameEN as N'Section Name (EN)',
			st.SectionType as N'Section Type',
			st.ParentSectionEN as N'Parent Section'
from		@SectionsTable st
order by	st.Template, 'Order In Template'

select		pt.FormType as N'Form Type (EN)',
			pt.Template as N'Form Template (EN)',
			(	select	count(*)
				from	@ParametersTable pt_less
				where	pt_less.Template = pt.Template
						and (	pt_less.ParameterTop < pt.ParameterTop
								or	(	pt_less.ParameterTop = pt.ParameterTop
										and pt_less.ParameterOrderInTemplate <= pt.ParameterOrderInTemplate
									)
							)
			) as 'Order In Template',
			pt.ParameterNameEN as N'Parameter Name (EN)',
			pt.ParameterType as N'Parameter Type',
			pt.TooltipEN as N'Tooltip (EN)',
			pt.SectionPathEN as N'Section Full Path',
			pt.SectionNameEN as N'Section Name',
			pt.Editor,
			pt.Mode,
			pt.ParameterID as N'Parameter ID',
			isnull(cast(pt.TemplateID as nvarchar), N'') as N'Template ID'
from		@ParametersTable pt
order by	pt.Template, 'Order In Template'
end
