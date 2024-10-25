-- Examples:
/*
	EXEC [dbo].[DF_TransferOut_Rule_idfSendToOffice]
	EXEC [dbo].[DF_TransferOut_Rule_idfSendToOffice] @UsePredefinedData=0,@StartDate='20240601'
	EXEC [dbo].[DF_TransferOut_Rule_idfSendToOffice] @UsePredefinedData=1
*/
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_TransferOut_Rule_idfSendToOffice] 
(
	@UsePredefinedData					bit = 0,
	@StartDate							datetime = null,
	@CalculateHumanData					bit = 1,
	@CalculateVetData					bit = 1
)
AS

if Object_ID('tempdb..#cfrTransferOut') is null
create table	#cfrTransferOut
(	[idfTransferOut]				bigint not null primary key,
	[idfsSite]						bigint null,
	[idfSendFromOffice]				bigint null,
	[idfSendToOffice]				bigint null
)

if Object_ID('tempdb..#TransferOutFiltered') is null
create table	#TransferOutFiltered
(	[idfID]						bigint not null identity(1,1),
	[idfTransferOut]			bigint not null,
	[idfSiteGroup]				bigint not null,
	[idfTransferOutFiltered]	bigint null,
	primary key	(
		[idfTransferOut] asc,
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
	insert into	#TransferOutFiltered
	(	idfTransferOut,
		idfSiteGroup
	)
	select distinct
				tOut.idfTransferOut,
				s.idfSiteGroup
	from		#cfrTransferOut tOut
	inner join	#SitesToCalculateFiltrationRecords s
	on			s.idfOffice = tOut.idfSendToOffice
	left join	#TransferOutFiltered tOutf_ex
	on			tOutf_ex.idfTransferOut = tOut.idfTransferOut
				and tOutf_ex.idfSiteGroup = s.idfSiteGroup
	where		tOutf_ex.idfID is null
end
else begin
	insert into	#TransferOutFiltered
	(	idfTransferOut,
		idfSiteGroup
	)
	select distinct
				tOut.idfTransferOut,
				s.idfSiteGroup
	from		dbo.tlbTransferOUT tOut with (nolock)
	inner join	#SitesToCalculateFiltrationRecords s
	on			s.idfOffice = tOut.idfSendToOffice
	left join	#TransferOutFiltered tOutf_ex
	on			tOutf_ex.idfTransferOut = tOut.idfTransferOut
				and tOutf_ex.idfSiteGroup = s.idfSiteGroup
	where		tOutf_ex.idfID is null
end
