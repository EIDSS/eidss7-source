SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE or ALTER PROCEDURE [dbo].[USP_GBL_ORG_GETSearch]
(
    @LanguageID NVARCHAR(50),
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SortColumn NVARCHAR(30) = 'FullName',
    @SortOrder NVARCHAR(4) = 'ASC',
    @FilterValue NVARCHAR(100) = NULL,
    @AccessoryCode INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

	if @PageNumber is null or @PageNumber <= 0
		set @PageNumber = 1

	if @PageSize is null or @PageSize <= 0
		set @PageSize = 10

	declare @intStart int
		set	@intStart = (@PageNumber - 1) * @PageSize

	declare @intTotalRows int = 0

	declare @idfsLanguage bigint
	set	@idfsLanguage = dbo.FN_GBL_LanguageCode_Get(@LanguageID)

	declare @idfsLanguageEn bigint
	set	@idfsLanguageEn = dbo.FN_GBL_LanguageCode_Get(N'en-US')


	declare @idfsCountry bigint
	set @idfsCountry = dbo.FN_GBL_CURRENTCOUNTRY_GET()

	declare	@cmd nvarchar(MAX) = N''
	declare	@guid uniqueidentifier = newid()

	declare	@tableFilterValueListName nvarchar(100)
	declare	@tableFilterValueListInTempDb nvarchar(100)

	declare	@tableForFilteringName nvarchar(100)
	declare	@tableForFilteringNameInTempDb nvarchar(100)

	declare	@tableForFilteringFinalName nvarchar(100)
	declare	@tableForFilteringFinalNameInTempDb nvarchar(100)

	declare	@tableForSortingName nvarchar(100)
	declare	@tableForSortingNameInTempDb nvarchar(100)


	set	@tableFilterValueListName = N'##tableFilterValue_' + replace(CAST(@guid as nvarchar(36)), N'-', N'') collate Latin1_General_CI_AS
	set	@tableFilterValueListInTempDb = N'tempdb..' + @tableFilterValueListName collate Latin1_General_CI_AS
	set	@tableForFilteringName = N'##tableForFiltering_' + replace(CAST(@guid as nvarchar(36)), N'-', N'') collate Latin1_General_CI_AS
	set	@tableForFilteringNameInTempDb = N'tempdb..' + @tableForFilteringName collate Latin1_General_CI_AS
	set	@tableForFilteringFinalName = N'##tableForFilteringFinal_' + replace(CAST(@guid as nvarchar(36)), N'-', N'') collate Latin1_General_CI_AS
	set	@tableForFilteringFinalNameInTempDb = N'tempdb..' + @tableForFilteringFinalName collate Latin1_General_CI_AS
	set	@tableForSortingName = N'##tableForSorting_' + replace(CAST(@guid as nvarchar(36)), N'-', N'') collate Latin1_General_CI_AS
	set	@tableForSortingNameInTempDb = N'tempdb..' + @tableForSortingName collate Latin1_General_CI_AS

	declare	@columnTable table
	(	strColumnLowerCase	nvarchar(100) collate Latin1_General_CI_AS not null primary key,
		strColumnName		nvarchar(100) collate Latin1_General_CI_AS not null,
		strDbColumnName		nvarchar(200) collate Latin1_General_CI_AS not null
	)

	declare @DbSortColumn NVARCHAR(200)

	insert into	@columnTable (strColumnLowerCase, strColumnName, strDbColumnName)
	values
	 (N'fullname', N'FullName', N'coalesce(snt_abbr.strTextString, br_abbr.strDefault, N'''')')
	,(N'abbreviatedname', N'AbbreviatedName', N'coalesce(snt_name.strTextString, br_name.strDefault, N'''')')
	,(N'organizationid', N'OrganizationId', N'o.idfOffice')
	,(N'uniquekey', N'UniqueKey', N'o.strOrganizationID')


	declare @ApplyFilter bit = 0

	select	@DbSortColumn = ct.strDbColumnName 
	from	@columnTable ct
	where	ct.strColumnLowerCase = @SortColumn collate Latin1_General_CI_AS 
	
	if @DbSortColumn is null
		set @DbSortColumn = N'o.idfOffice'

	if @SortOrder is null
		set	@SortOrder = N'ASC'

	if OBJECT_ID(@tableFilterValueListInTempDb) is not null
	begin
		set @cmd = N'drop table ' + @tableFilterValueListName collate Latin1_General_CI_AS
		exec sp_executesql @cmd
	end

	if OBJECT_ID(@tableForFilteringNameInTempDb) is not null
	begin
		set @cmd = N'drop table ' + @tableForFilteringName collate Latin1_General_CI_AS
		exec sp_executesql @cmd
	end

	if OBJECT_ID(@tableForFilteringFinalNameInTempDb) is not null
	begin
		set @cmd = N'drop table ' + @tableForFilteringFinalName collate Latin1_General_CI_AS
		exec sp_executesql @cmd
	end

	if OBJECT_ID(@tableForSortingNameInTempDb) is not null
	begin
		set @cmd = N'drop table ' + @tableForSortingName collate Latin1_General_CI_AS
		exec sp_executesql @cmd
	end



	if OBJECT_ID(@tableFilterValueListInTempDb) is null
	begin
		set @cmd = N'create table ' + @tableFilterValueListName + N'
(	[id] int not null primary key,
	strFilterValue nvarchar(100) collate Latin1_General_CI_AS not null
)
		' collate Latin1_General_CI_AS
		exec sp_executesql @cmd
	end

	set	@cmd = N'truncate table ' + @tableFilterValueListName collate Latin1_General_CI_AS
	exec sp_executesql @cmd


	if OBJECT_ID(@tableForFilteringNameInTempDb) is null
	begin
		set @cmd = N'create table ' + @tableForFilteringName + N'
(	idfOffice bigint not null,
	idfFilterValue int not null,
	primary key
	(	idfOffice asc,
		idfFilterValue asc
	)
)
		' collate Latin1_General_CI_AS
		exec sp_executesql @cmd
	end

	set	@cmd = N'truncate table ' + @tableForFilteringName collate Latin1_General_CI_AS
	exec sp_executesql @cmd


	if OBJECT_ID(@tableForFilteringFinalNameInTempDb) is null
	begin
		set @cmd = N'create table ' + @tableForFilteringFinalName + N'
(	idfOffice bigint not null primary key
)
		' collate Latin1_General_CI_AS
		exec sp_executesql @cmd
	end

	set	@cmd = N'truncate table ' + @tableForFilteringFinalName collate Latin1_General_CI_AS
	exec sp_executesql @cmd

	if OBJECT_ID(@tableForSortingNameInTempDb) is null
	begin
		set @cmd = N'create table ' + @tableForSortingName + N'
(	OrganizationId bigint not null primary key,
	idfLocation	bigint null,
	UniqueKey nvarchar(200) collate Cyrillic_General_CI_AS null,
	FullName nvarchar(2000) collate Cyrillic_General_CI_AS null,
	AbbreviatedName nvarchar(2000) collate Cyrillic_General_CI_AS null,
	Address nvarchar(2000) collate Cyrillic_General_CI_AS null,
	intRowNumber int not null
)
		' collate Latin1_General_CI_AS
		exec sp_executesql @cmd
	end

	set	@cmd = N'truncate table ' + @tableForSortingName collate Latin1_General_CI_AS
	exec sp_executesql @cmd


	if @FilterValue is not null and @FilterValue <> N'' collate Cyrillic_General_CI_AS
	begin
		declare @FV nvarchar(100) = replace(replace(replace(@FilterValue, N'	', N' '), N',', N' '), N' - ', N' ')

		set	@cmd = N'
insert into ' + @tableFilterValueListName + N' ([id], strFilterValue)
select	s.num, cast(s.[Value] as nvarchar(100))
from	dbo.fnsysSplitList(@FilterValueIn, 0, N'' '') s

delete	t
from	' + @tableFilterValueListName + N' t
where exists (select 1 from ' + @tableFilterValueListName + N' t_dupl where t_dupl.strFilterValue = t.strFilterValue collate Cyrillic_General_CI_AS and t_dupl.[id] < t.[id]) 

if exists (select 1 from ' + @tableFilterValueListName + N')
	set	@ApplyFilterOut = 1
else
	set @ApplyFilterOut = 0
' collate Latin1_General_CI_AS
		exec sp_executesql @cmd, N'@FilterValueIn nvarchar(100), @ApplyFilterOut bit output', 
			@FilterValueIn = @FV, @ApplyFilterOut = @ApplyFilter output
	end


	if @ApplyFilter = 1
	begin
		set	@cmd = N'insert into ' + @tableForFilteringName + N' (idfOffice, idfFilterValue)
select	o.idfOffice, fv.[id]
from	dbo.tlbOffice o
join	' + @tableFilterValueListName + N' fv
on		o.strOrganizationID like N''%'' + fv.strFilterValue + N''%'' collate Cyrillic_General_CI_AS
where	o.intRowStatus = 0' +
	case when @AccessoryCode is null then N'' else N'
		and (o.intHACode is null or o.intHACode & @AccessoryCodeIn = @AccessoryCodeIn)' end + N'
' collate Latin1_General_CI_AS
		exec sp_executesql @cmd, N'@AccessoryCodeIn int', 
			@AccessoryCodeIn = @AccessoryCode

		set	@cmd = N'insert into ' + @tableForFilteringName + N' (idfOffice, idfFilterValue)
select	o.idfOffice, fv.[id]
from		dbo.tlbOffice o
join		dbo.trtBaseReference br_abbr
on			br_abbr.idfsBaseReference = o.idfsOfficeAbbreviation
left join	dbo.trtStringNameTranslation snt_abbr
on			snt_abbr.idfsBaseReference = o.idfsOfficeAbbreviation
			and snt_abbr.idfsLanguage = @idfsLanguageIn
join		' + @tableFilterValueListName + N' fv
on			(	snt_abbr.strTextString like N''%'' + fv.strFilterValue + N''%'' collate Cyrillic_General_CI_AS
				or	(	snt_abbr.strTextString is null
						and br_abbr.strDefault like N''%'' + fv.strFilterValue + N''%'' collate Cyrillic_General_CI_AS
					)
			)
where		o.intRowStatus = 0' +
	case when @AccessoryCode is null then N'' else N'
		and (o.intHACode is null or o.intHACode & @AccessoryCodeIn = @AccessoryCodeIn)' end + N'
		and not exists (select 1 from '+ @tableForFilteringName + N' o_filter where o_filter.idfOffice = o.idfOffice and o_filter.idfFilterValue = fv.[id])
' collate Latin1_General_CI_AS
		exec sp_executesql @cmd, N'@idfsLanguageIn bigint, @AccessoryCodeIn int', 
			@idfsLanguageIn = @idfsLanguage, @AccessoryCodeIn = @AccessoryCode

		set	@cmd = N'insert into ' + @tableForFilteringName + N' (idfOffice, idfFilterValue)
select	o.idfOffice, fv.[id]
from		dbo.tlbOffice o
join		dbo.trtBaseReference br_name
on			br_name.idfsBaseReference = o.idfsOfficeName
left join	dbo.trtStringNameTranslation snt_name
on			snt_name.idfsBaseReference = o.idfsOfficeName
			and snt_name.idfsLanguage = @idfsLanguageIn
join		' + @tableFilterValueListName + N' fv
on			(	snt_name.strTextString like N''%'' + fv.strFilterValue + N''%'' collate Cyrillic_General_CI_AS
				or	(	snt_name.strTextString is null
						and br_name.strDefault like N''%'' + fv.strFilterValue + N''%'' collate Cyrillic_General_CI_AS
					)
			)
where		o.intRowStatus = 0' +
	case when @AccessoryCode is null then N'' else N'
		and (o.intHACode is null or o.intHACode & @AccessoryCodeIn = @AccessoryCodeIn)' end + N'
		and not exists (select 1 from '+ @tableForFilteringName + N' o_filter where o_filter.idfOffice = o.idfOffice and o_filter.idfFilterValue = fv.[id])
' collate Latin1_General_CI_AS
		exec sp_executesql @cmd, N'@idfsLanguageIn bigint, @AccessoryCodeIn int', 
			@idfsLanguageIn = @idfsLanguage, @AccessoryCodeIn = @AccessoryCode

		set	@cmd = N'insert into ' + @tableForFilteringName + N' (idfOffice, idfFilterValue)
select	o.idfOffice, fv.[id]
from		dbo.tlbOffice o
join		dbo.tlbGeoLocationShared gls
on			gls.idfGeoLocationShared = o.idfLocation
left join	dbo.gisLocationDenormalized loc_en
on			loc_en.idfsLocation = gls.idfsLocation
			and loc_en.idfsLanguage = @idfsLanguageEnIn
left join	dbo.gisLocationDenormalized loc_lng
on			loc_lng.idfsLocation = gls.idfsLocation
			and loc_lng.idfsLanguage = @idfsLanguageIn
join		' + @tableFilterValueListName + N' fv
on			(	loc_lng.[Level1Name] like N''%'' + fv.strFilterValue + N''%'' collate Cyrillic_General_CI_AS
				or	(	loc_lng.[Level1Name] is null
						and loc_en.[Level1Name] like N''%'' + fv.strFilterValue + N''%'' collate Cyrillic_General_CI_AS
					)
				or	loc_lng.[Level2Name] like N''%'' + fv.strFilterValue + N''%'' collate Cyrillic_General_CI_AS
				or	(	loc_lng.[Level2Name] is null
						and loc_en.[Level2Name] like N''%'' + fv.strFilterValue + N''%'' collate Cyrillic_General_CI_AS
					)
				or	loc_lng.[Level3Name] like N''%'' + fv.strFilterValue + N''%'' collate Cyrillic_General_CI_AS
				or	(	loc_lng.[Level3Name] is null
						and loc_en.[Level3Name] like N''%'' + fv.strFilterValue + N''%'' collate Cyrillic_General_CI_AS
					)
				or	loc_lng.[Level4Name] like N''%'' + fv.strFilterValue + N''%'' collate Cyrillic_General_CI_AS
				or	(	loc_lng.[Level4Name] is null
						and loc_en.[Level4Name] like N''%'' + fv.strFilterValue + N''%'' collate Cyrillic_General_CI_AS
					)
			)

where		o.intRowStatus = 0' +
	case when @AccessoryCode is null then N'' else N'
		and (o.intHACode is null or o.intHACode & @AccessoryCodeIn = @AccessoryCodeIn)' end + N'
		and not exists (select 1 from '+ @tableForFilteringName + N' o_filter where o_filter.idfOffice = o.idfOffice and o_filter.idfFilterValue = fv.[id])
' collate Latin1_General_CI_AS
		exec sp_executesql @cmd, N'@idfsLanguageIn bigint, @idfsLanguageEnIn bigint, @AccessoryCodeIn int', 
			@idfsLanguageIn = @idfsLanguage, @idfsLanguageEnIn = @idfsLanguageEn, @AccessoryCodeIn = @AccessoryCode

		set	@cmd = N'insert into ' + @tableForFilteringName + N' (idfOffice, idfFilterValue)
select	o.idfOffice, fv.[id]
from		dbo.tlbOffice o
join		dbo.tlbGeoLocationShared gls
on			gls.idfGeoLocationShared = o.idfLocation
			and gls.blnForeignAddress = 0
join		dbo.gisSettlement stlm
on			stlm.idfsSettlement = gls.idfsLocation
left join	dbo.gisBaseReference gbr_stlm_type
on			gbr_stlm_type.idfsGISBaseReference = stlm.idfsSettlementType
left join	dbo.gisStringNameTranslation gsnt_stlm_type
on			gsnt_stlm_type.idfsGISBaseReference = stlm.idfsSettlementType
			and gsnt_stlm_type.idfsLanguage = @idfsLanguageIn
join		' + @tableFilterValueListName + N' fv
on			(	gls.strPostCode like N''%'' + fv.strFilterValue + N''%'' collate Cyrillic_General_CI_AS
				or gls.strStreetName like N''%'' + fv.strFilterValue + N''%'' collate Cyrillic_General_CI_AS
				or gls.strBuilding like N''%'' + fv.strFilterValue + N''%'' collate Cyrillic_General_CI_AS
				or gls.strApartment like N''%'' + fv.strFilterValue + N''%'' collate Cyrillic_General_CI_AS
				or gls.strHouse like N''%'' + fv.strFilterValue + N''%'' collate Cyrillic_General_CI_AS
				or gsnt_stlm_type.strTextString like N''%'' + fv.strFilterValue + N''%'' collate Cyrillic_General_CI_AS
				or	(	gsnt_stlm_type.strTextString is null
						and gbr_stlm_type.strDefault like N''%'' + fv.strFilterValue + N''%'' collate Cyrillic_General_CI_AS
					)
			)
where		o.intRowStatus = 0' +
	case when @AccessoryCode is null then N'' else N'
		and (o.intHACode is null or o.intHACode & @AccessoryCodeIn = @AccessoryCodeIn)' end + N'
		and not exists (select 1 from '+ @tableForFilteringName + N' o_filter where o_filter.idfOffice = o.idfOffice and o_filter.idfFilterValue = fv.[id])
' collate Latin1_General_CI_AS
		exec sp_executesql @cmd, N'@AccessoryCodeIn int, @idfsLanguageIn bigint', 
			@AccessoryCodeIn = @AccessoryCode, @idfsLanguageIn = @idfsLanguage

		set	@cmd = N'insert into ' + @tableForFilteringName + N' (idfOffice, idfFilterValue)
select	o.idfOffice, fv.[id]
from		dbo.tlbOffice o
join		dbo.tlbGeoLocationShared gls
on			gls.idfGeoLocationShared = o.idfLocation
			and gls.blnForeignAddress = 1
join		' + @tableFilterValueListName + N' fv
on			gls.strForeignAddress like N''%'' + fv.strFilterValue + N''%'' collate Cyrillic_General_CI_AS
where		o.intRowStatus = 0' +
	case when @AccessoryCode is null then N'' else N'
		and (o.intHACode is null or o.intHACode & @AccessoryCodeIn = @AccessoryCodeIn)' end + N'
		and not exists (select 1 from '+ @tableForFilteringName + N' o_filter where o_filter.idfOffice = o.idfOffice and o_filter.idfFilterValue = fv.[id])
' collate Latin1_General_CI_AS
		exec sp_executesql @cmd, N'@AccessoryCodeIn int', 
			@AccessoryCodeIn = @AccessoryCode


		set	@cmd = N'
declare @FilterValueCount int
select	@FilterValueCount = count(*)
from	' + @tableFilterValueListName + N' fv

insert into	' + @tableForFilteringFinalName + N' (idfOffice)
select		t.idfOffice
from		' + @tableForFilteringName + N' t
group by	t.idfOffice
having		count(distinct t.idfFilterValue) >= @FilterValueCount
' collate Latin1_General_CI_AS
		exec sp_executesql @cmd

	end
	else begin
		set	@cmd = N'insert into ' + @tableForFilteringFinalName + N' (idfOffice)
select	o.idfOffice
from	dbo.tlbOffice o
where	o.intRowStatus = 0' +
	case when @AccessoryCode is null then N'' else N'
		and (o.intHACode is null or o.intHACode & @AccessoryCodeIn = @AccessoryCodeIn)' end collate Latin1_General_CI_AS
		exec sp_executesql @cmd, N'@AccessoryCodeIn int', 
			@AccessoryCodeIn = @AccessoryCode
		
	end

	declare @strAddressStringFormat nvarchar(1000)--@PostCode, @Country, @Region, @Rayon, @SettlementType @Settlement, @Street @House - @Building - @Apartment
	declare	@strForeignAddressFormat nvarchar(1000)--@Country, @AddressString

	select	@strAddressStringFormat = glf.strAddressString,
			@strForeignAddressFormat = glf.strForeignAddress
	from	dbo.tstGeoLocationFormat glf
	where	glf.idfsCountry = @idfsCountry

	set	@cmd = N'insert into ' + @tableForSortingName + N'
(	OrganizationId,
	idfLocation,
	UniqueKey,
	FullName,
	AbbreviatedName,
	[Address],
	intRowNumber
)
select		o.idfOffice as OrganizationId,
			o.idfLocation,
			o.strOrganizationID as UniqueKey,
			coalesce(snt_name.strTextString, br_name.strDefault, N'''') as FullName,
			coalesce(snt_abbr.strTextString, br_abbr.strDefault, N'''') as AbbreviatedName,
			N'''' as [Address],
			row_number() over (order by ' + @DBSortColumn + N' ' + @SortOrder + N') as intRowNumber
from		dbo.tlbOffice o
inner join	 ' + @tableForFilteringFinalName + N' o_filter
on			o_filter.idfOffice = o.idfOffice
left join	dbo.trtBaseReference br_abbr
on			br_abbr.idfsBaseReference = o.idfsOfficeAbbreviation
left join	dbo.trtStringNameTranslation snt_abbr
on			snt_abbr.idfsBaseReference = br_abbr.idfsBaseReference
			and snt_abbr.idfsLanguage = @idfsLanguageIn
left join	dbo.trtBaseReference br_name
on			br_name.idfsBaseReference = o.idfsOfficeName
left join	dbo.trtStringNameTranslation snt_name
on			snt_name.idfsBaseReference = o.idfsOfficeName
			and snt_name.idfsLanguage = @idfsLanguageIn
' collate Latin1_General_CI_AS
	exec sp_executesql @cmd, N'@idfsLanguageIn bigint', 
			@idfsLanguageIn = @idfsLanguage

set	@cmd = N'
update		t
set			t.[Address] = 
				dbo.fnCreateAddressStringByTemplate(
					@strAddressStringFormatIn,
					@strForeignAddressFormatIn,
					coalesce(loc_lng.[Level1Name], loc_en.[Level1Name], N''''),
					coalesce(loc_lng.[Level2Name], loc_en.[Level2Name], N''''),
					coalesce(loc_lng.[Level3Name], loc_en.[Level3Name], N''''),
					isnull(gls.strPostCode, N''''),
					coalesce(gsnt_stlm_type.strTextString, gbr_stlm_type.strDefault, N''''),
					coalesce(loc_lng.[Level4Name], loc_en.[Level4Name], N''''),
					isnull(gls.strStreetName, N''''),
					isnull(gls.strHouse, N''''),
					isnull(gls.strBuilding, N''''),
					isnull(gls.strApartment, N''''),
					gls.blnForeignAddress,
					isnull(gls.strForeignAddress, N'''')
					)
from		' + @tableForSortingName + N' t
inner join	dbo.tlbGeoLocationShared gls
on			gls.idfGeoLocationShared = t.idfLocation
left join	dbo.gisLocationDenormalized loc_lng
on			loc_lng.idfsLocation = gls.idfsLocation
			and loc_lng.idfsLanguage = @idfsLanguageIn

left join	dbo.gisLocationDenormalized loc_en
on			loc_en.idfsLocation = gls.idfsLocation
			and loc_en.idfsLanguage = @idfsLanguageEnIn

left join	dbo.gisSettlement stlm
on			stlm.idfsSettlement = gls.idfsLocation
left join	dbo.gisBaseReference gbr_stlm_type
on			gbr_stlm_type.idfsGISBaseReference = stlm.idfsSettlementType
left join	dbo.gisStringNameTranslation gsnt_stlm_type
on			gsnt_stlm_type.idfsGISBaseReference = stlm.idfsSettlementType
			and gsnt_stlm_type.idfsLanguage = @idfsLanguageIn

where		t.intRowNumber > ' + cast(isnull(@intStart, 0) as nvarchar(20)) + N'
			and t.intRowNumber <= ' + cast(isnull(@intStart + @PageSize, 0) as nvarchar(20)) + N'
' collate Latin1_General_CI_AS
	exec sp_executesql @cmd, N'@idfsLanguageIn bigint, @idfsLanguageEnIn bigint, @strAddressStringFormatIn nvarchar(1000), @strForeignAddressFormatIn nvarchar(1000)', 
			@idfsLanguageIn = @idfsLanguage, @idfsLanguageEnIn = @idfsLanguageEn, 
			@strAddressStringFormatIn = @strAddressStringFormat, @strForeignAddressFormatIn = @strForeignAddressFormat


	set	@cmd = N'
		select	@intTotalRowsOut = count(*)
		from	' + @tableForSortingName collate Latin1_General_CI_AS
	exec sp_executesql @cmd, N'@intTotalRowsOut int output', 
			@intTotalRowsOut = @intTotalRows output

	set	@cmd = N'
		select	OrganizationId,
				UniqueKey,
				FullName,
				AbbreviatedName,
				[Address],
				@intTotalRowsIn as TotalRowCount
		from	' + @tableForSortingName + N'
		ORDER BY intRowNumber
		OFFSET ' + cast(isnull(@intStart, 0) as nvarchar(20)) + ' ROWS 
		FETCH NEXT ' + cast(isnull(@PageSize, 0) as nvarchar(20)) + ' ROWS ONLY
' collate Latin1_General_CI_AS
	exec sp_executesql @cmd, N'@intTotalRowsIn int', 
			@intTotalRowsIn = @intTotalRows


	if OBJECT_ID(@tableFilterValueListInTempDb) is not null
	begin
		set @cmd = N'drop table ' + @tableFilterValueListName collate Latin1_General_CI_AS
		exec sp_executesql @cmd
	end

	if OBJECT_ID(@tableForFilteringNameInTempDb) is not null
	begin
		set @cmd = N'drop table ' + @tableForFilteringName collate Latin1_General_CI_AS
		exec sp_executesql @cmd
	end

	if OBJECT_ID(@tableForFilteringFinalNameInTempDb) is not null
	begin
		set @cmd = N'drop table ' + @tableForFilteringFinalName collate Latin1_General_CI_AS
		exec sp_executesql @cmd
	end

	if OBJECT_ID(@tableForSortingNameInTempDb) is not null
	begin
		set @cmd = N'drop table ' + @tableForSortingName collate Latin1_General_CI_AS
		exec sp_executesql @cmd
	end

END
GO