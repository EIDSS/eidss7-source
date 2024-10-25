declare	@strNationalLng nvarchar(200) = N'ka'
declare	@strSecondNationalLng nvarchar(200) = N'ru'


declare	@intLngEn bigint
declare @intLngNat1 bigint
declare @intLngNat2 bigint

set @intLngEn = [Falcon].dbo.fnGetLanguageCode('en')
set @intLngNat1 = [Falcon].dbo.fnGetLanguageCode(@strNationalLng)
if @intLngNat1 = @intLngEn
	set	@intLngNat1 = null
set @intLngNat2 = [Falcon].dbo.fnGetLanguageCode(@strSecondNationalLng)
if @intLngNat2 = @intLngEn
	set	@intLngNat2 = null


DECLARE @idfCustomizationPackage BIGINT
	, @idfsCountry BIGINT

SELECT @idfCustomizationPackage = [Falcon].[dbo].fnCustomizationPackage()
SELECT @idfsCountry = [Falcon].[dbo].fnCustomizationCountry()

DECLARE @CountryNode HIERARCHYID
SELECT @CountryNode = [node] FROM [Giraffe].[dbo].gisLocation WHERE idfsLocation = @idfsCountry



declare	@Differences table
(	idfId int not null primary key,
	strDifference nvarchar(200) collate Cyrillic_General_CI_AS not null
)

insert into @Differences (idfId, strDifference) values
(1, N'New value in v7')
,(2, N'Not transferred from v6')
,(3, N'GIS Reference Type Change')
,(4, N'Default Name Change')
,(5, N'English Name Change')
,(6, N'Level Change')
,(7, N'Path Change')
,(8, N'HASC Change')
,(9, N'Code Change')
,(10, N'Settlement Type Change')
,(11, N'Settlement Longitude Change')
,(12, N'Settlement Latitude Change')
,(13, N'Settlement Elevation Change')
,(14, N'National Name 1 Change')
,(15, N'National Name 2 Change')



SELECT	STUFF(diff.strDifferences, 1, 1, N'') as 'Detected difference',
		isnull(cast(br_v7.idfsGISBaseReference as varchar(20)), N'') as 'System Identifier v7', 
		isnull(cast(l_v7.[node].GetLevel() as varchar(10)), N'') as 'Level v7',
		isnull(rt_v7.strGISReferenceTypeName, N'') as 'GIS Reference Type v7', 
		isnull(br_v7.strDefault, N'') as 'Default Name v7', 
		coalesce(snt_en_v7.strTextString, br_v7.strDefault, N'') as 'English Name v7',
		case
			when	@intLngNat1 is not null
				then	coalesce(snt_lng_nat1_v7.strTextString, br_v7.strDefault, N'')
			else	N''
		end as 'National Name v7 - 1',
		case
			when	@intLngNat2 is not null
				then	coalesce(snt_lng_nat2_v7.strTextString, br_v7.strDefault, N'')
			else	N''
		end as 'National Name v7 - 2',
		isnull(ld_en_v7.Level1Name, N'') + 
			isnull(N'>' + ld_en_v7.Level2Name, N'') + 
			isnull(N'>' + ld_en_v7.Level3Name, N'') + 
			isnull(N'>' + ld_en_v7.Level4Name, N'') collate Cyrillic_General_CI_AS as 'English Location Path v7',
		--isnull(ld_lng_nat1_v7.Level1Name, N'') + 
		--	isnull(N'>' + ld_lng_nat1_v7.Level2Name, N'') + 
		--	isnull(N'>' + ld_lng_nat1_v7.Level3Name, N'') + 
		--	isnull(N'>' + ld_lng_nat1_v7.Level4Name, N'') collate Cyrillic_General_CI_AS as 'National Location Path v7 - 1',
		--isnull(ld_lng_nat2_v7.Level1Name, N'') + 
		--	isnull(N'>' + ld_lng_nat2_v7.Level2Name, N'') + 
		--	isnull(N'>' + ld_lng_nat2_v7.Level3Name, N'') + 
		--	isnull(N'>' + ld_lng_nat2_v7.Level4Name, N'') collate Cyrillic_General_CI_AS as 'National Location Path v7 - 2',
		isnull(l_v7.strHASC, N'') as N'HASC v7',
		isnull(l_v7.strCode, N'') as N'Code v7',
		coalesce(stlm_type_snt_en_v7.strTextString, stlm_type_v7.strDefault, N'') as N'Settlement Type v7',
		isnull(cast(l_v7.dblLongitude as nvarchar(100)), N'') as N'Settlement Longitude v7',
		isnull(cast(l_v7.dblLatitude as nvarchar(100)), N'') as N'Settlement Latitude v7',
		isnull(cast(l_v7.intElevation as nvarchar(20)), N'') as N'Settlement Elevation v7',


		isnull(cast(l_v6.idfsGISBaseReference as varchar(20)), N'') as 'System Identifier v6', 
		isnull(cast(l_v6.intLevel as varchar(10)), N'') as 'Level v6',
		isnull(l_v6.strGISReferenceTypeName, N'') as 'GIS Reference Type v6', 
		isnull(l_v6.strDefault, N'') as 'Default Name v6', 
		coalesce(l_v6.strEnText, l_v6.strDefault, N'') as 'English Name v6',
		case
			when	@intLngNat1 is not null
				then	coalesce(l_v6.strNat1Text, l_v6.strDefault, N'')
			else	N''
		end as 'National Name v6 - 1',
		case
			when	@intLngNat2 is not null
				then	coalesce(l_v6.strNat2Text, l_v6.strDefault, N'')
			else	N''
		end as 'National Name v6 - 2',
		isnull(l_v6.strEnPathV6, N'') as 'English Location Path v6',
		isnull(l_v6.strHASC, N'') as N'HASC v6',
		isnull(l_v6.strCode, N'') as N'Code v6',
		isnull(l_v6.strStlmType, N'') as N'Settlement Type v6',
		isnull(cast(l_v6.dblLongitude as nvarchar(100)), N'') as N'Settlement Longitude v6',
		isnull(cast(l_v6.dblLatitude as nvarchar(100)), N'') as N'Settlement Latitude v6',
		isnull(cast(l_v6.intElevation as nvarchar(20)), N'') as N'Settlement Elevation v6'

FROM	(	[Giraffe].[dbo].gisBaseReference AS br_v7 
			join	[Giraffe].[dbo].gisLocation l_v7
			on	l_v7.idfsLocation = br_v7.idfsGISBaseReference
				and l_v7.[node].IsDescendantOf(@CountryNode) = 1 and br_v7.intRowStatus=0
			join	[Giraffe].[dbo].[gisReferenceType] rt_v7
			on	rt_v7.idfsGISReferenceType = br_v7.idfsGISReferenceType
				and rt_v7.intRowStatus = 0
			left join	[Giraffe].[dbo].[gisStringNameTranslation] snt_en_v7
			on	snt_en_v7.idfsGISBaseReference = br_v7.idfsGISBaseReference
				and snt_en_v7.idfsLanguage = @intLngEn
			left join	[Giraffe].[dbo].[gisStringNameTranslation] snt_lng_nat1_v7
			on	snt_lng_nat1_v7.idfsGISBaseReference = br_v7.idfsGISBaseReference
				and snt_lng_nat1_v7.idfsLanguage = @intLngNat1
			left join	[Giraffe].[dbo].[gisStringNameTranslation] snt_lng_nat2_v7
			on	snt_lng_nat2_v7.idfsGISBaseReference = br_v7.idfsGISBaseReference
				and snt_lng_nat2_v7.idfsLanguage = @intLngNat2

			left join	[Giraffe].[dbo].[gisBaseReference] stlm_type_v7
			on	stlm_type_v7.idfsGISBaseReference = l_v7.idfsType
			left join	[Giraffe].[dbo].[gisStringNameTranslation] stlm_type_snt_en_v7
			on	stlm_type_snt_en_v7.idfsGISBaseReference = l_v7.idfsType
				and stlm_type_snt_en_v7.idfsLanguage = @intLngEn

			left join	[Giraffe].[dbo].[gisLocationDenormalized] ld_en_v7
			on			ld_en_v7.idfsLocation = l_v7.idfsLocation
						and ld_en_v7.idfsLanguage = @intLngEn
			--left join	[Giraffe].[dbo].[gisLocationDenormalized] ld_lng_nat1_v7
			--on			ld_lng_nat1_v7.idfsLocation = l_v7.idfsLocation
			--			and ld_lng_nat1_v7.idfsLanguage = @intLngNat1
			--left join	[Giraffe].[dbo].[gisLocationDenormalized] ld_lng_nat2_v7
			--on			ld_lng_nat2_v7.idfsLocation = l_v7.idfsLocation
			--			and ld_lng_nat2_v7.idfsLanguage = @intLngNat2

		)
full join
	(	select	br_v6.idfsGISBaseReference,
				CAST(1 as int) as intLevel,
				rt_v6.strGISReferenceTypeName,
				br_v6.strDefault,
				snt_en_v6.strTextString as strEnText,
				snt_lng_nat1_v6.strTextString as strNat1Text,
				snt_lng_nat2_v6.strTextString as strNat2Text,
				snt_en_v6.strTextString as strEnPathV6,
				t_v6.strHASC,
				t_v6.strCode,
				cast(N'' as nvarchar(200)) as strStlmType,
				cast(null as float) as dblLongitude,
				cast(null as float) as dblLatitude,
				cast(null as int) as intElevation
		from	[Falcon].[dbo].gisBaseReference AS br_v6
		join	[Falcon].[dbo].gisCountry t_v6
		on	t_v6.idfsCountry = br_v6.idfsGISBaseReference
			and t_v6.idfsCountry = @idfsCountry and br_v6.intRowStatus=0
		join	[Falcon].[dbo].[gisReferenceType] rt_v6
		on	rt_v6.idfsGISReferenceType = br_v6.idfsGISReferenceType
			and rt_v6.intRowStatus = 0
		left join	[Falcon].[dbo].[gisStringNameTranslation] snt_en_v6
		on	snt_en_v6.idfsGISBaseReference = br_v6.idfsGISBaseReference
			and snt_en_v6.idfsLanguage = @intLngEn
		left join	[Falcon].[dbo].[gisStringNameTranslation] snt_lng_nat1_v6
		on	snt_lng_nat1_v6.idfsGISBaseReference = br_v6.idfsGISBaseReference
			and snt_lng_nat1_v6.idfsLanguage = @intLngNat1
		left join	[Falcon].[dbo].[gisStringNameTranslation] snt_lng_nat2_v6
		on	snt_lng_nat2_v6.idfsGISBaseReference = br_v6.idfsGISBaseReference
			and snt_lng_nat2_v6.idfsLanguage = @intLngNat2

		union all

		select	br_v6.idfsGISBaseReference,
				CAST(2 as int) as intLevel,
				rt_v6.strGISReferenceTypeName,
				br_v6.strDefault,
				snt_en_v6.strTextString as strEnText,
				snt_lng_nat1_v6.strTextString as strNat1Text,
				snt_lng_nat2_v6.strTextString as strNat2Text,
				isnull(c_v6.[name] + N'>', N'') + 
					snt_en_v6.strTextString as strEnPathV6,
				t_v6.strHASC,
				t_v6.strCode,
				cast(N'' as nvarchar(200)) as strStlmType,
				cast(null as float) as dblLongitude,
				cast(null as float) as dblLatitude,
				cast(null as int) as intElevation
		from	[Falcon].[dbo].gisBaseReference AS br_v6
		join	[Falcon].[dbo].gisRegion t_v6
		on	t_v6.idfsRegion = br_v6.idfsGISBaseReference
			and t_v6.idfsCountry = @idfsCountry and br_v6.intRowStatus=0
		join	[Falcon].[dbo].[gisReferenceType] rt_v6
		on	rt_v6.idfsGISReferenceType = br_v6.idfsGISReferenceType
			and rt_v6.intRowStatus = 0
		left join	[Falcon].[dbo].[gisStringNameTranslation] snt_en_v6
		on	snt_en_v6.idfsGISBaseReference = br_v6.idfsGISBaseReference
			and snt_en_v6.idfsLanguage = @intLngEn
		left join	[Falcon].[dbo].[gisStringNameTranslation] snt_lng_nat1_v6
		on	snt_lng_nat1_v6.idfsGISBaseReference = br_v6.idfsGISBaseReference
			and snt_lng_nat1_v6.idfsLanguage = @intLngNat1
		left join	[Falcon].[dbo].[gisStringNameTranslation] snt_lng_nat2_v6
		on	snt_lng_nat2_v6.idfsGISBaseReference = br_v6.idfsGISBaseReference
			and snt_lng_nat2_v6.idfsLanguage = @intLngNat2
		join	[Falcon].[dbo].fnGisReferenceRepair(@intLngEn, 19000001 /*Country*/) c_v6
		on	c_v6.idfsReference = t_v6.idfsCountry

		union all

		select	br_v6.idfsGISBaseReference,
				CAST(3 as int) as intLevel,
				rt_v6.strGISReferenceTypeName,
				br_v6.strDefault,
				snt_en_v6.strTextString as strEnText,
				snt_lng_nat1_v6.strTextString as strNat1Text,
				snt_lng_nat2_v6.strTextString as strNat2Text,
				isnull(c_v6.[name] + N'>', N'') + 
					isnull(reg_v6.[name] + N'>', N'') + 
					snt_en_v6.strTextString as strEnPathV6,
				t_v6.strHASC,
				t_v6.strCode,
				cast(N'' as nvarchar(200)) as strStlmType,
				cast(null as float) as dblLongitude,
				cast(null as float) as dblLatitude,
				cast(null as int) as intElevation
		from	[Falcon].[dbo].gisBaseReference AS br_v6
		join	[Falcon].[dbo].gisRayon t_v6
		on	t_v6.idfsRayon = br_v6.idfsGISBaseReference
			and t_v6.idfsCountry = @idfsCountry and br_v6.intRowStatus=0
		join	[Falcon].[dbo].[gisReferenceType] rt_v6
		on	rt_v6.idfsGISReferenceType = br_v6.idfsGISReferenceType
			and rt_v6.intRowStatus = 0
		left join	[Falcon].[dbo].[gisStringNameTranslation] snt_en_v6
		on	snt_en_v6.idfsGISBaseReference = br_v6.idfsGISBaseReference
			and snt_en_v6.idfsLanguage = @intLngEn
		left join	[Falcon].[dbo].[gisStringNameTranslation] snt_lng_nat1_v6
		on	snt_lng_nat1_v6.idfsGISBaseReference = br_v6.idfsGISBaseReference
			and snt_lng_nat1_v6.idfsLanguage = @intLngNat1
		left join	[Falcon].[dbo].[gisStringNameTranslation] snt_lng_nat2_v6
		on	snt_lng_nat2_v6.idfsGISBaseReference = br_v6.idfsGISBaseReference
			and snt_lng_nat2_v6.idfsLanguage = @intLngNat2
		join	[Falcon].[dbo].fnGisReferenceRepair(@intLngEn, 19000001 /*Country*/) c_v6
		on	c_v6.idfsReference = t_v6.idfsCountry
		join	[Falcon].[dbo].fnGisReferenceRepair(@intLngEn, 19000003 /*Region*/) reg_v6
		on	reg_v6.idfsReference = t_v6.idfsRegion

		union all

		select	br_v6.idfsGISBaseReference,
				CAST(4 as int) as intLevel,
				rt_v6.strGISReferenceTypeName,
				br_v6.strDefault,
				snt_en_v6.strTextString as strEnText,
				snt_lng_nat1_v6.strTextString as strNat1Text,
				snt_lng_nat2_v6.strTextString as strNat2Text,
				isnull(c_v6.[name] + N'>', N'') + 
					isnull(reg_v6.[name] + N'>', N'') + 
					isnull(ray_v6.[name] + N'>', N'') + 
					snt_en_v6.strTextString as strEnPathV6,
				N'',
				t_v6.strSettlementCode,
				isnull(stlm_type_v6.[name], N'') as strStlmType,
				t_v6.dblLongitude as dblLongitude,
				t_v6.dblLatitude as dblLatitude,
				t_v6.intElevation as intElevation
		from	[Falcon].[dbo].gisBaseReference AS br_v6
		join	[Falcon].[dbo].gisSettlement t_v6
		on	t_v6.idfsSettlement = br_v6.idfsGISBaseReference
			and t_v6.idfsCountry = @idfsCountry and br_v6.intRowStatus=0
		join	[Falcon].[dbo].[gisReferenceType] rt_v6
		on	rt_v6.idfsGISReferenceType = br_v6.idfsGISReferenceType
			and rt_v6.intRowStatus = 0
		left join	[Falcon].[dbo].[gisStringNameTranslation] snt_en_v6
		on	snt_en_v6.idfsGISBaseReference = br_v6.idfsGISBaseReference
			and snt_en_v6.idfsLanguage = @intLngEn
		left join	[Falcon].[dbo].[gisStringNameTranslation] snt_lng_nat1_v6
		on	snt_lng_nat1_v6.idfsGISBaseReference = br_v6.idfsGISBaseReference
			and snt_lng_nat1_v6.idfsLanguage = @intLngNat1
		left join	[Falcon].[dbo].[gisStringNameTranslation] snt_lng_nat2_v6
		on	snt_lng_nat2_v6.idfsGISBaseReference = br_v6.idfsGISBaseReference
			and snt_lng_nat2_v6.idfsLanguage = @intLngNat2
		join	[Falcon].[dbo].fnGisReferenceRepair(@intLngEn, 19000001 /*Country*/) c_v6
		on	c_v6.idfsReference = t_v6.idfsCountry
		join	[Falcon].[dbo].fnGisReferenceRepair(@intLngEn, 19000003 /*Region*/) reg_v6
		on	reg_v6.idfsReference = t_v6.idfsRegion
		join	[Falcon].[dbo].fnGisReferenceRepair(@intLngEn, 19000002 /*Rayon*/) ray_v6
		on	ray_v6.idfsReference = t_v6.idfsRayon
		left join	[Falcon].[dbo].fnGisReferenceRepair(@intLngEn, 19000005 /*Settlement Type*/) stlm_type_v6
		on	stlm_type_v6.idfsReference = t_v6.idfsSettlementType
	) l_v6
	on l_v6.idfsGISBaseReference = br_v7.idfsGISBaseReference


outer apply
(	select	ISNULL(
		(
			select		N', ' + d.strDifference
			from		@Differences d
			where		(	(l_v6.idfsGISBaseReference is null and d.idfId = 1)
							or	(br_v7.idfsGISBaseReference is null and d.idfId = 2)
							or	(	l_v6.idfsGISBaseReference is not null and br_v7.idfsGISBaseReference is not null 
									and (isnull(rt_v7.strGISReferenceTypeName, N'') <> isnull(l_v6.strGISReferenceTypeName, N'') collate Cyrillic_General_CI_AS)
									and d.idfId = 3
								)
							or	(	l_v6.idfsGISBaseReference is not null and br_v7.idfsGISBaseReference is not null 
									and (rtrim(isnull(br_v7.strDefault, N'')) <> rtrim(isnull(l_v6.strDefault, N'')) collate Cyrillic_General_CI_AS)
									and d.idfId = 4
								)
							or	(	l_v6.idfsGISBaseReference is not null and br_v7.idfsGISBaseReference is not null 
									and (rtrim(coalesce(snt_en_v7.strTextString, br_v7.strDefault, N'')) <> rtrim(coalesce(l_v6.strEnText, l_v6.strDefault, N'')) collate Cyrillic_General_CI_AS)
									and d.idfId = 5
								)
							or	(	l_v6.idfsGISBaseReference is not null and br_v7.idfsGISBaseReference is not null 
									and (ISNULL(l_v7.[node].GetLevel(), -100) <> ISNULL(l_v6.intLevel, -100))
									and d.idfId = 6
								)
							or	(	l_v6.idfsGISBaseReference is not null and br_v7.idfsGISBaseReference is not null 
									and (rtrim(isnull(ld_en_v7.Level1Name, N'') + 
												isnull(N'>' + ld_en_v7.Level2Name, N'') + 
												isnull(N'>' + ld_en_v7.Level3Name, N'') + 
												isnull(N'>' + ld_en_v7.Level4Name, N'')) <> 
											rtrim(isnull(l_v6.strEnPathV6, N'')) collate Cyrillic_General_CI_AS)
									and d.idfId = 7
								)
							or	(	l_v6.idfsGISBaseReference is not null and br_v7.idfsGISBaseReference is not null 
									and (rtrim(isnull(l_v7.strHASC, N'')) <> rtrim(isnull(l_v6.strHASC, N'')) collate Cyrillic_General_CI_AS)
									and d.idfId = 8
								)
							or	(	l_v6.idfsGISBaseReference is not null and br_v7.idfsGISBaseReference is not null 
									and (rtrim(isnull(l_v7.strCode, N'')) <> rtrim(isnull(l_v6.strCode, N'')) collate Cyrillic_General_CI_AS)
									and d.idfId = 9
								)
							or	(	l_v6.idfsGISBaseReference is not null and br_v7.idfsGISBaseReference is not null 
									and (rtrim(coalesce(stlm_type_snt_en_v7.strTextString, stlm_type_v7.strDefault, N'')) <> rtrim(isnull(l_v6.strStlmType, N'')) collate Cyrillic_General_CI_AS)
									and d.idfId = 10
								)
							or	(	l_v6.idfsGISBaseReference is not null and br_v7.idfsGISBaseReference is not null 
									and (ISNULL(l_v7.dblLongitude, -100.0) <> ISNULL(l_v6.dblLongitude, -100.0))
									and d.idfId = 11
								)
							or	(	l_v6.idfsGISBaseReference is not null and br_v7.idfsGISBaseReference is not null 
									and (ISNULL(l_v7.dblLatitude, -100.0) <> ISNULL(l_v6.dblLatitude, -100.0))
									and d.idfId = 12
								)
							or	(	l_v6.idfsGISBaseReference is not null and br_v7.idfsGISBaseReference is not null 
									and (ISNULL(l_v7.intElevation, -100) <> ISNULL(l_v6.intElevation, -100))
									and d.idfId = 13
								)
							or	(	l_v6.idfsGISBaseReference is not null and br_v7.idfsGISBaseReference is not null 
									and @intLngNat1 is not null
									and (rtrim(coalesce(snt_lng_nat1_v7.strTextString, br_v7.strDefault, N'')) <> rtrim(coalesce(l_v6.strNat1Text, l_v6.strDefault, N'')) collate Cyrillic_General_CI_AS)
									and d.idfId = 14
								)
							or	(	l_v6.idfsGISBaseReference is not null and br_v7.idfsGISBaseReference is not null 
									and @intLngNat2 is not null
									and (rtrim(coalesce(snt_lng_nat2_v7.strTextString, br_v7.strDefault, N'')) <> rtrim(coalesce(l_v6.strNat2Text, l_v6.strDefault, N'')) collate Cyrillic_General_CI_AS)
									and d.idfId = 15
								)
						)
			order by	d.idfId asc
			for xml path('')
		), N',') strDifferences
) diff
where	diff.strDifferences <> N',' collate Cyrillic_General_CI_AS


order by l_v7.[node].GetLevel(), rt_v7.strGISReferenceTypeName, ld_en_v7.Level1Name, ld_en_v7.Level2Name, ld_en_v7.Level3Name, ld_en_v7.Level4Name, br_v7.idfsGISBaseReference,
			l_v6.intLevel, l_v6.strGISReferenceTypeName, l_v6.strEnPathV6, l_v6.idfsGISBaseReference

