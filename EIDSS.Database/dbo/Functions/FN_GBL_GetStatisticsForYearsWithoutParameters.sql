


--##SUMMARY Selects statistics values for:
--##SUMMARY 1) each administrative unit of the level associated with specified statistic data type
--##SUMMARY and 2) most recent years equal to or less than specified years correspondingly.
--##SUMMARY 
--##SUMMARY Calculates statistics for the upper-level administrative units 
--##SUMMARY as sum of statistics values of their child administrative units and corresponding year.
--##SUMMARY 
--##SUMMARY If there is child administrative units with unknown statistics, 
--##SUMMARY the upper-level administrative unit will be assigned with null value of the statistics.
--##SUMMARY 
--##SUMMARY Statistics Data Type shall be associated with Year period. 
--##SUMMARY Statistics Data Type shall not be associated with any reference type including Age Groups. 
--##SUMMARY Otherwise, no statistics will be selected/calculated.

--##REMARKS Author: Mirnaya O.
--##REMARKS Create date: 01.02.2018

--##RETURNS Returns a table with the integer values of statistics for all applicable administrative units and specified years


/*
--Example of a call of function:

declare	@idfsStatisticDataType	bigint
declare	@strYearList	varchar(500)
declare	@intMinYear	int

set	@idfsStatisticDataType = 39850000000
set	@strYearList = null--'2010,2011,2012,2013,2014,2015,2016,2017,2018'
set	@intMinYear = 2010

select	*
from	dbo.FN_GBL_GetStatisticsForYearsWithoutParameters(@idfsStatisticDataType, @strYearList, @intMinYear)

*/


CREATE	function	[dbo].[FN_GBL_GetStatisticsForYearsWithoutParameters]
(
	  @idfsStatisticDataType	bigint	 			--##PARAM @idfsStatisticDataType Identifier of the type of Statistics to select/calculate
													--##PARAM Type of Statistics shall be associated with Year period
													--##PARAM Type of Statistics shall not be associated with any reference type including Age Groups.
													--##PARAM Otherwise, no statistics will be selected/calculated.
	, @strYearList				varchar(500) = null	--##PARAM @strYearList List of years (up to 100 years) to select/calculate Statistics
													--##PARAM Years shall be represented in the form of four digits separated by comma
													--##PARAM If parameter is not specified, then all years from specified min Year up to current year
													--##PARAM will be taken 
	, @intMinYear				int = 2000			--##PARAM @intMinYear min Year to select/calculate Statistics
)
returns @Statistics	table
(	idfsAdminUnit			bigint not null,
	idfsGisReferenceType	bigint not null,
	intYear					int not null,
	intStatisticsValue		int null,
	primary key	(
		idfsAdminUnit asc,
		intYear	asc
				)
)


as
begin


	declare	@idfsCountry	bigint = dbo.FN_GBL_CurrentCountry_GET()

	if	exists	(	
			select		*
			from		tstLocalSiteOptions lso
			inner join	tstSite s
			on			cast(s.idfsSite as nvarchar(200)) = lso.strValue collate Cyrillic_General_CI_AS
						and	s.idfsSite = 1
			where		lso.strName = N'SiteID' collate Cyrillic_General_CI_AS
				)
	begin
		set	@idfsCountry = dbo.FN_GBL_CustomizationCountry()
	end

	declare		@YearsForStatistics	table
	(	intYear	int not null primary key
	)
	
	if isnull(@strYearList, N'') = N''
	begin
		declare	@yyyy	int = isnull(@intMinYear, 2000)
		declare	@curYear int = year(getdate())
		while (@yyyy <= @curYear)
		begin
			insert into @YearsForStatistics (intYear) values (@yyyy)
			set	@yyyy = @yyyy + 1
		end
	end
	else
		insert into	@YearsForStatistics
		(	intYear
		)
		select	top 100
					cast(cast(l.Value as varchar) as int)
		from		dbo.FN_GBL_SYS_SplitList(@strYearList, 0, ',') l
		where		isnumeric(cast(l.Value as varchar)) = 1
					and len(cast(l.Value as varchar)) = 4
					and cast(cast(l.Value as varchar) as int) >= isnull(@intMinYear, 1900)
					and cast(cast(l.Value as varchar) as int) <= year(getdate())
		order by	cast(cast(l.Value as varchar) as int) desc

	declare		@AdminUnitsForStatistics table
	(	idfsAdminUnit			bigint not null primary key,
		idfsGisReferenceType	bigint not null,
		idfsStatisticAreaType	bigint not null
	)
	

	-- Select all rayons of current country including those which are marked as deleted
	insert into	@AdminUnitsForStatistics
	(	idfsAdminUnit,
		idfsGisReferenceType,
		idfsStatisticAreaType
	)
	select		gbr.idfsGISBaseReference,
				gbr.idfsGISReferenceType,
				sdt.idfsStatisticAreaType
	from		trtStatisticDataType sdt
	inner join	gisBaseReference gbr
	on			gbr.idfsGISReferenceType = -- sdt.idfsStatisticAreaType + 8911000
				case	sdt.idfsStatisticAreaType
					when	10089001 /*Country*/
						then	19000001
					when	10089003 /*Region*/
						then	19000003
					when	10089002 /*Rayon*/
						then	19000002
					when	10089004 /*Settlement*/
						then	19000004
					else	-1
				end
	inner join	gisCountry c
	on			c.idfsCountry = @idfsCountry
	left join	gisRegion reg
	on			reg.idfsRegion = gbr.idfsGISBaseReference
				and reg.idfsCountry = c.idfsCountry
	left join	gisRayon ray
	on			ray.idfsRayon = gbr.idfsGISBaseReference
				and ray.idfsCountry = c.idfsCountry
	left join	gisSettlement s
	on			s.idfsSettlement = gbr.idfsGISBaseReference
				and s.idfsCountry = c.idfsCountry
	where		sdt.idfsStatisticDataType = @idfsStatisticDataType
				and sdt.idfsReferenceType is null -- There is no parameter for this type of statistical data
				and isnull(sdt.blnRelatedWithAgeGroup, 0) = 0 -- There is no connection to Age Groups for this type of statistical data
				and sdt.idfsStatisticPeriodType = 10091005 /*Year*/	-- This type of statistical data is collected by years
				and (	(sdt.idfsStatisticAreaType = 10089001 /*Country*/ and gbr.idfsGISBaseReference = c.idfsCountry)
						or	(sdt.idfsStatisticAreaType = 10089003 /*Region*/ and gbr.idfsGISBaseReference = reg.idfsRegion)
						or	(sdt.idfsStatisticAreaType = 10089002 /*Rayon*/ and gbr.idfsGISBaseReference = ray.idfsRayon)
						or	(sdt.idfsStatisticAreaType = 10089004 /*Settlement*/ and gbr.idfsGISBaseReference = s.idfsSettlement)
					)

	insert into	@Statistics
	(	idfsAdminUnit,
		idfsGisReferenceType,
		intYear,
		intStatisticsValue
	)
	select		au_for_s.idfsAdminUnit, 
				au_for_s.idfsGisReferenceType, 
				y_for_s.intYear, 
				stat.intValue
	from		(
		@AdminUnitsForStatistics au_for_s
		cross join @YearsForStatistics y_for_s
				)
	outer apply	(
		select top 1
					s.idfStatistic, cast(s.varValue as int) as intValue
		from		tlbStatistic s
		where		s.intRowStatus = 0
					and s.idfsStatisticDataType = @idfsStatisticDataType
					and s.idfsArea = au_for_s.idfsAdminUnit
					and year(s.datStatisticStartDate) <= y_for_s.intYear
					and sql_variant_property(s.varValue, 'BaseType') in ('bigint','decimal','float','int','numeric','real','smallint','tinyint')
		order by	year(s.datStatisticStartDate) desc
				) stat
	left join	@Statistics s_ex
	on			s_ex.idfsAdminUnit = au_for_s.idfsAdminUnit
				and s_ex.intYear = y_for_s.intYear
	where		s_ex.idfsAdminUnit is null

	-- Calculate statistics for Rayons using Settlement-level statistics
	insert into	@Statistics
	(	idfsAdminUnit,
		idfsGisReferenceType,
		intYear,
		intStatisticsValue
	)
	select		gbr.idfsGISBaseReference,
				gbr.idfsGISReferenceType,
				y_for_s.intYear,
				stat_for_rayon.intStatisticsValue
	from		trtStatisticDataType sdt
	inner join	gisCountry c
	on			c.idfsCountry = @idfsCountry
	inner join	gisBaseReference gbr
	on			gbr.idfsGISReferenceType = 19000002 /*Rayon*/
	inner join	gisRayon ray
	on			ray.idfsRayon = gbr.idfsGISBaseReference
				and ray.idfsCountry = c.idfsCountry
	inner join	@YearsForStatistics y_for_s
	on			y_for_s.intYear is not null
	outer apply	(
		select		sum(stat.intStatisticsValue) as intStatisticsValue
		from		@Statistics stat
		join		gisSettlement s
		on			s.idfsSettlement = stat.idfsAdminUnit
					and s.idfsRayon = ray.idfsRayon
		where		stat.intYear = y_for_s.intYear
					and stat.idfsGisReferenceType = 19000004 /*Settlement*/
					and not exists	(
								select top 1 1
								from		@Statistics stat_null_val
								join		gisSettlement s_null_val
								on			s_null_val.idfsSettlement = stat_null_val.idfsAdminUnit
											and s_null_val.idfsRayon = s.idfsRayon
								where		stat_null_val.intYear = stat.intYear
											and stat_null_val.idfsGisReferenceType = 19000004 /*Settlement*/
											and stat_null_val.intStatisticsValue is null
									)
				) stat_for_rayon
	where		sdt.idfsStatisticDataType = @idfsStatisticDataType
				and sdt.idfsReferenceType is null -- There is no parameter for this type of statistical data
				and isnull(sdt.blnRelatedWithAgeGroup, 0) = 0 -- There is no connection to Age Groups for this type of statistical data
				and sdt.idfsStatisticPeriodType = 10091005 /*Year*/	-- This type of statistical data is collected by years
				and sdt.idfsStatisticAreaType = 10089004 /*Settlement*/

	-- Calculate statistics for Regions using Rayon-level statistics
	insert into	@Statistics
	(	idfsAdminUnit,
		idfsGisReferenceType,
		intYear,
		intStatisticsValue
	)
	select		gbr.idfsGISBaseReference,
				gbr.idfsGISReferenceType,
				y_for_s.intYear,
				stat_for_region.intStatisticsValue
	from		trtStatisticDataType sdt
	inner join	gisCountry c
	on			c.idfsCountry = @idfsCountry
	inner join	gisBaseReference gbr
	on			gbr.idfsGISReferenceType = 19000003 /*Region*/
	inner join	gisRegion reg
	on			reg.idfsRegion = gbr.idfsGISBaseReference
				and reg.idfsCountry = c.idfsCountry
	inner join	@YearsForStatistics y_for_s
	on			y_for_s.intYear is not null
	outer apply	(
		select		sum(stat.intStatisticsValue) as intStatisticsValue
		from		@Statistics stat
		join		gisRayon ray
		on			ray.idfsRayon = stat.idfsAdminUnit
					and ray.idfsRegion = reg.idfsRegion
		where		stat.intYear = y_for_s.intYear
					and stat.idfsGisReferenceType = 19000002 /*Rayon*/
					and not exists	(
								select top 1 1
								from		@Statistics stat_null_val
								join		gisRayon ray_null_val
								on			ray_null_val.idfsRayon = stat_null_val.idfsAdminUnit
											and ray_null_val.idfsRegion = ray.idfsRegion
								where		stat_null_val.intYear = stat.intYear
											and stat_null_val.idfsGisReferenceType = 19000002 /*Rayon*/
											and stat_null_val.intStatisticsValue is null
									)
				) stat_for_region
	where		sdt.idfsStatisticDataType = @idfsStatisticDataType
				and sdt.idfsReferenceType is null -- There is no parameter for this type of statistical data
				and isnull(sdt.blnRelatedWithAgeGroup, 0) = 0 -- There is no connection to Age Groups for this type of statistical data
				and sdt.idfsStatisticPeriodType = 10091005 /*Year*/	-- This type of statistical data is collected by years
				and sdt.idfsStatisticAreaType in (10089004 /*Settlement*/, 10089002 /*Rayon*/)


	-- Calculate statistics for Regions using Rayon-level statistics
	insert into	@Statistics
	(	idfsAdminUnit,
		idfsGisReferenceType,
		intYear,
		intStatisticsValue
	)
	select		gbr.idfsGISBaseReference,
				gbr.idfsGISReferenceType,
				y_for_s.intYear,
				stat_for_country.intStatisticsValue
	from		trtStatisticDataType sdt
	inner join	gisCountry c
	on			c.idfsCountry = @idfsCountry
	inner join	gisBaseReference gbr
	on			gbr.idfsGISReferenceType = 19000001 /*Country*/
				and gbr.idfsGISBaseReference = c.idfsCountry
	inner join	@YearsForStatistics y_for_s
	on			y_for_s.intYear is not null
	outer apply	(
		select		sum(stat.intStatisticsValue) as intStatisticsValue
		from		@Statistics stat
		join		gisRegion reg
		on			reg.idfsRegion = stat.idfsAdminUnit
					and reg.idfsCountry = c.idfsCountry
		where		stat.intYear = y_for_s.intYear
					and stat.idfsGisReferenceType = 19000003 /*Region*/
					and not exists	(
								select top 1 1
								from		@Statistics stat_null_val
								join		gisRegion reg_null_val
								on			reg_null_val.idfsRegion = stat_null_val.idfsAdminUnit
											and reg_null_val.idfsCountry = reg.idfsCountry
								where		stat_null_val.intYear = stat.intYear
											and stat_null_val.idfsGisReferenceType = 19000003 /*Region*/
											and stat_null_val.intStatisticsValue is null
									)
				) stat_for_country
	where		sdt.idfsStatisticDataType = @idfsStatisticDataType
				and sdt.idfsReferenceType is null -- There is no parameter for this type of statistical data
				and isnull(sdt.blnRelatedWithAgeGroup, 0) = 0 -- There is no connection to Age Groups for this type of statistical data
				and sdt.idfsStatisticPeriodType = 10091005 /*Year*/	-- This type of statistical data is collected by years
				and sdt.idfsStatisticAreaType in (10089004 /*Settlement*/, 10089002 /*Rayon*/, 10089003 /*Region*/)

	return

end

