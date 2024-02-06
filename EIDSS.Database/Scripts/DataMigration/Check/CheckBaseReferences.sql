
/**************************************************************************************************************************************
* Check script of data migration results: Base References.
* Execute script on any database, e.g. master, on the server, where both databases of EIDSS v6.1 and v7 ("empty DB") are located.
* By default, in the script EIDSSv6.1 database has the name Falcon and EIDSSv7 database has the name Giraffe.
* Specify abbreviations of national and second national languages if applicale
**************************************************************************************************************************************/


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

declare	@Differences table
(	idfId int not null primary key,
	strDifference nvarchar(200) collate Cyrillic_General_CI_AS not null
)

insert into @Differences (idfId, strDifference) values
 (1, N'New value in v7')
,(2, N'Not transferred from v6')
,(3, N'Reference Type Change')
,(4, N'Default Name Change')
,(5, N'English Name Change')
,(6, N'HA Code Change')
,(7, N'Order Change')
,(8, N'Is System Change')
,(9, N'Is Deleted Change')
,(10, N'National Name 1 Change')
,(11, N'National Name 2 Change')

select	
		STUFF(diff.strDifferences, 1, 1, N'') as 'Detected difference',
		isnull(cast(br_v7.idfsBaseReference as varchar(20)), N'') as 'System Identifier v7', 
		isnull(rt_v7.strReferenceTypeName, N'') as 'Reference Type v7', 
		isnull(br_v7.strDefault, N'') as 'Default Name v7', 
		coalesce(snt_en_v7.strTextString, br_v7.strDefault, N'') as 'English Name v7',
		STUFF(isnull(haCodes_v7.strCodeNames, N','), 1, 1, N'') as 'HA Code v7', 
		isnull(cast(br_v7.intOrder as varchar(20)), case when br_v7.idfsBaseReference is null then N'' else N'0' end) as 'Order v7',
		replace(replace(cast(isnull(br_v7.blnSystem, 0) as varchar(1)), N'0', N''), N'1', N'System') as 'Is System v7',
		case
			when	br_v7.intRowStatus = 0 or br_v7.intRowStatus is null
				then	N''
			else	N'Deleted'
		end as 'Is Deleted v7',
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
		isnull(cast(br_v6.idfsBaseReference as varchar(20)), N'') as 'System Identifier v6', 
		isnull(rt_v6.strReferenceTypeName, N'') as 'Reference Type v6', 
		isnull(br_v6.strDefault, N'') as 'Default Name v6', 
		coalesce(snt_en_v6.strTextString, br_v6.strDefault, N'') as 'English Name v6',
		STUFF(isnull(haCodes_v6.strCodeNames, N','), 1, 1, N'') as 'HA Code v6', 
		isnull(cast(br_v6.intOrder as varchar(20)), case when br_v6.idfsBaseReference is null then N'' else N'0' end) as 'Order v6',
		replace(replace(cast(isnull(br_v6.blnSystem, 0) as varchar(1)), N'0', N''), N'1', N'System') as 'Is System v6',
		case
			when	br_v6.intRowStatus = 0 or br_v6.intRowStatus is null
				then	N''
			else	N'Deleted'
		end as 'Is Deleted v6',
		case
			when	@intLngNat1 is not null
				then	coalesce(snt_lng_nat1_v6.strTextString, br_v6.strDefault, N'')
			else	N''
		end as 'National Name v6 - 1',
		case
			when	@intLngNat2 is not null
				then	coalesce(snt_lng_nat2_v6.strTextString, br_v6.strDefault, N'')
			else	N''
		end as 'National Name v6 - 2'
from	(
	[Giraffe].[dbo].[trtBaseReference] br_v7
	join	[Giraffe].[dbo].[trtReferenceType] rt_v7
	on		rt_v7.idfsReferenceType = br_v7.idfsReferenceType
	left join	[Giraffe].[dbo].[trtStringNameTranslation] snt_en_v7
	on			snt_en_v7.idfsBaseReference = br_v7.idfsBaseReference
				and snt_en_v7.idfsLanguage = @intLngEn
	left join	[Giraffe].[dbo].[trtStringNameTranslation] snt_lng_nat1_v7
	on			snt_lng_nat1_v7.idfsBaseReference = br_v7.idfsBaseReference
				and snt_lng_nat1_v7.idfsLanguage = @intLngNat1
	left join	[Giraffe].[dbo].[trtStringNameTranslation] snt_lng_nat2_v7
	on			snt_lng_nat2_v7.idfsBaseReference = br_v7.idfsBaseReference
				and snt_lng_nat2_v7.idfsLanguage = @intLngNat2
	outer apply
	(	select	ISNULL(
			(
				select		N', ' + ha_br_v7.strDefault
				from		[Giraffe].[dbo].[trtHACodeList] ha_v7
				join		[Giraffe].[dbo].[trtBaseReference] ha_br_v7
				on			ha_br_v7.idfsBaseReference = ha_v7.idfsCodeName
				where		(	(br_v7.intHACode = 0 and ha_v7.intHACode = 0)
								or (	br_v7.intHACode > 0 and ha_v7.intHACode > 0
										and ha_v7.intHACode <> 510 /*All*/
										and ((br_v7.intHACode & ha_v7.intHACode) = ha_v7.intHACode)
									)
								or	(br_v7.intHACode is null and ha_v7.intHACode = 510 /*All*/)
							)
				order by	ha_v7.intHACode asc
				for xml path('')
			), N',') strCodeNames
	) haCodes_v7
		)
full join	(
	[Falcon].[dbo].[trtBaseReference] br_v6
	join	[Falcon].[dbo].[trtReferenceType] rt_v6
	on		rt_v6.idfsReferenceType = br_v6.idfsReferenceType
	left join	[Falcon].[dbo].[trtStringNameTranslation] snt_en_v6
	on			snt_en_v6.idfsBaseReference = br_v6.idfsBaseReference
				and snt_en_v6.idfsLanguage = @intLngEn
	left join	[Falcon].[dbo].[trtStringNameTranslation] snt_lng_nat1_v6
	on			snt_lng_nat1_v6.idfsBaseReference = br_v6.idfsBaseReference
				and snt_lng_nat1_v6.idfsLanguage = @intLngNat1
	left join	[Falcon].[dbo].[trtStringNameTranslation] snt_lng_nat2_v6
	on			snt_lng_nat2_v6.idfsBaseReference = br_v6.idfsBaseReference
				and snt_lng_nat2_v6.idfsLanguage = @intLngNat2
	outer apply
	(	select	ISNULL(
			(
				select		N', ' + ha_br_v6.strDefault
				from		[Falcon].[dbo].[trtHACodeList] ha_v6
				join		[Falcon].[dbo].[trtBaseReference] ha_br_v6
				on			ha_br_v6.idfsBaseReference = ha_v6.idfsCodeName
				where		(	(br_v6.intHACode = 0 and ha_v6.intHACode = 0)
								or (	br_v6.intHACode > 0 and ha_v6.intHACode > 0
										and ha_v6.intHACode <> 510 /*All*/
										and ((br_v6.intHACode & ha_v6.intHACode) = ha_v6.intHACode)
									)
								or	(br_v6.intHACode is null and ha_v6.intHACode = 510 /*All*/)
							)
				order by	ha_v6.intHACode asc
				for xml path('')
			), N',') strCodeNames
	) haCodes_v6
		)
on	br_v6.idfsBaseReference = br_v7.idfsBaseReference
outer apply
(	select	ISNULL(
		(
			select		N', ' + d.strDifference
			from		@Differences d
			where		(	(br_v6.idfsBaseReference is null and d.idfId = 1)
							or	(br_v7.idfsBaseReference is null and d.idfId = 2)
							or	(	br_v6.idfsBaseReference is not null and br_v7.idfsBaseReference is not null
									and (isnull(rt_v7.strReferenceTypeName, N'') <> isnull(rt_v6.strReferenceTypeName, N'') collate Cyrillic_General_CI_AS)
									and d.idfId = 3
								)
							or	(	br_v6.idfsBaseReference is not null and br_v7.idfsBaseReference is not null
									and (rtrim(isnull(br_v7.strDefault, N'')) <> rtrim(isnull(br_v6.strDefault, N'')) collate Cyrillic_General_CI_AS)
									and d.idfId = 4
								)
							or	(	br_v6.idfsBaseReference is not null and br_v7.idfsBaseReference is not null
									and (rtrim(coalesce(snt_en_v7.strTextString, br_v7.strDefault, N'')) <> rtrim(coalesce(snt_en_v6.strTextString, br_v6.strDefault, N'')) collate Cyrillic_General_CI_AS)
									and d.idfId = 5
								)
							or	(	br_v6.idfsBaseReference is not null and br_v7.idfsBaseReference is not null
									and (ISNULL(br_v7.intHACode, -100) <> ISNULL(br_v6.intHACode, -100))
									and d.idfId = 6
								)
							or	(	br_v6.idfsBaseReference is not null and br_v7.idfsBaseReference is not null
									and (ISNULL(br_v7.intOrder, -100) <> ISNULL(br_v6.intOrder, -100))
									and d.idfId = 7
								)
							or	(	br_v6.idfsBaseReference is not null and br_v7.idfsBaseReference is not null
									and (ISNULL(br_v7.blnSystem, 0) <> ISNULL(br_v6.blnSystem, 0))
									and d.idfId = 8
								)
							or	(	br_v6.idfsBaseReference is not null and br_v7.idfsBaseReference is not null
									and (ISNULL(br_v7.intRowStatus, -100) <> ISNULL(br_v6.intRowStatus, -100))
									and d.idfId = 9
								)
							or	(	br_v6.idfsBaseReference is not null and br_v7.idfsBaseReference is not null
									and @intLngNat1 is not null
									and (rtrim(coalesce(snt_lng_nat1_v7.strTextString, br_v7.strDefault, N'')) <> rtrim(coalesce(snt_lng_nat1_v6.strTextString, br_v6.strDefault, N'')) collate Cyrillic_General_CI_AS)
									and d.idfId = 10
								)
							or	(	br_v6.idfsBaseReference is not null and br_v7.idfsBaseReference is not null
									and @intLngNat2 is not null
									and (rtrim(coalesce(snt_lng_nat2_v7.strTextString, br_v7.strDefault, N'')) <> rtrim(coalesce(snt_lng_nat2_v6.strTextString, br_v6.strDefault, N'')) collate Cyrillic_General_CI_AS)
									and d.idfId = 11
								)
						)
			order by	d.idfId asc
			for xml path('')
		), N',') strDifferences
) diff
where	diff.strDifferences <> N',' collate Cyrillic_General_CI_AS

order by	rt_v7.strReferenceTypeName, br_v7.intOrder, br_v7.strDefault, br_v7.idfsBaseReference, rt_v6.strReferenceTypeName, br_v6.intOrder, br_v6.strDefault, br_v6.idfsBaseReference



