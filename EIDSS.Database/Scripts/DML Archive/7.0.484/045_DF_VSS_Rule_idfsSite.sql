-- Examples:
/*
	EXEC [dbo].[DF_VSS_Rule_idfsSite]
	EXEC [dbo].[DF_VSS_Rule_idfsSite] @UsePredefinedData=0,@StartDate='20240601'
	EXEC [dbo].[DF_VSS_Rule_idfsSite] @UsePredefinedData=1
*/
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_VSS_Rule_idfsSite] 
(
	@UsePredefinedData					bit = 0,
	@StartDate							datetime = null
)
AS

if Object_ID('tempdb..#cfrVSS') is null
create table	#cfrVSS
(	[idfVectorSurveillanceSession]	bigint not null primary key,
	[idfsSite]						bigint null,
	[idfOutbreak]					bigint null,
	[idfLocation]					bigint null,
	[idfsVSSRayon]					bigint null
)

if Object_ID('tempdb..#VSSFiltered') is null
create table	#VSSFiltered
(	[idfID]									bigint not null identity(1,1),
	[idfVectorSurveillanceSession]			bigint not null,
	[idfOutbreak]							bigint null,
	[idfSiteGroup]							bigint not null,
	[idfVectorSurveillanceSessionFiltered]	bigint null,
	primary key	(
		[idfVectorSurveillanceSession] asc,
		[idfSiteGroup] asc
				)
)

if Object_ID('tempdb..#SitesToCalculateFiltrationRecords') is null
create table	#SitesToCalculateFiltrationRecords
(	[idfID]			bigint not null identity(1,1),
	[strSiteID]		varchar(36) collate Cyrillic_General_CI_AS not null primary key,
	[idfsSite]		bigint null,
	[idfOffice]		bigint null,
	[idfsRayon]		bigint null,
	[idfSiteGroup]	bigint null
)


if @UsePredefinedData = 1 or @StartDate is not null
begin
	insert into	#VSSFiltered
	(	idfVectorSurveillanceSession,
		idfSiteGroup
	)
	select distinct
				vss.idfVectorSurveillanceSession,
				s.idfSiteGroup
	from		#cfrVSS vss
	inner join	#SitesToCalculateFiltrationRecords s
	on			s.idfsSite = vss.idfsSite
	left join	#VSSFiltered vssf_ex
	on			vssf_ex.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
				and vssf_ex.idfSiteGroup = s.idfSiteGroup
	where		vssf_ex.idfID is null
end
else begin
	insert into	#VSSFiltered
	(	idfVectorSurveillanceSession,
		idfSiteGroup
	)
	select distinct
				vss.idfVectorSurveillanceSession,
				s.idfSiteGroup
	from		dbo.tlbVectorSurveillanceSession vss with (nolock)
	inner join	#SitesToCalculateFiltrationRecords s
	on			s.idfsSite = vss.idfsSite
	left join	#VSSFiltered vssf_ex
	on			vssf_ex.idfVectorSurveillanceSession = vss.idfVectorSurveillanceSession
				and vssf_ex.idfSiteGroup = s.idfSiteGroup
	where		vssf_ex.idfID is null
end