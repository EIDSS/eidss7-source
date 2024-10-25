-- Examples:
/*
	EXEC [dbo].[DF_DropTempTables]
	EXEC [dbo].[DF_DropTempTables] @UsePredefinedData=0
	EXEC [dbo].[DF_DropTempTables] @UsePredefinedData=1
*/
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_DropTempTables] 
(
	@UsePredefinedData		bit = 0
)
AS

declare	@drop_cmd	nvarchar(4000)

if @UsePredefinedData = 0 and Object_ID('tempdb..#cfrHC') is not null
begin
	set	@drop_cmd = N'drop table #cfrHC'
	execute sp_executesql @drop_cmd
end

if @UsePredefinedData = 0 and Object_ID('tempdb..#cfrHCDeduplicationChain') is not null
begin
	set	@drop_cmd = N'drop table #cfrHCDeduplicationChain'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#HCFiltered') is not null
begin
	set	@drop_cmd = N'drop table #HCFiltered'
	execute sp_executesql @drop_cmd
end

if @UsePredefinedData = 0 and Object_ID('tempdb..#cfrVC') is not null
begin
	set	@drop_cmd = N'drop table #cfrVC'
	execute sp_executesql @drop_cmd
end

if @UsePredefinedData = 0 and Object_ID('tempdb..#cfrVCConnectedChain') is not null
begin
	set	@drop_cmd = N'drop table #cfrVCConnectedChain'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#VCFiltered') is not null
begin
	set	@drop_cmd = N'drop table #VCFiltered'
	execute sp_executesql @drop_cmd
end

if @UsePredefinedData = 0 and Object_ID('tempdb..#cfrMS') is not null
begin
	set	@drop_cmd = N'drop table #cfrMS'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#MSFiltered') is not null
begin
	set	@drop_cmd = N'drop table #MSFiltered'
	execute sp_executesql @drop_cmd
end

if @UsePredefinedData = 0 and Object_ID('tempdb..#cfrVSS') is not null
begin
	set	@drop_cmd = N'drop table #cfrVSS'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#VSSFiltered') is not null
begin
	set	@drop_cmd = N'drop table #VSSFiltered'
	execute sp_executesql @drop_cmd
end

if @UsePredefinedData = 0 and Object_ID('tempdb..#cfrOutbreak') is not null
begin
	set	@drop_cmd = N'drop table #cfrOutbreak'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#OutbreakFiltered') is not null
begin
	set	@drop_cmd = N'drop table #OutbreakFiltered'
	execute sp_executesql @drop_cmd
end

if @UsePredefinedData = 0 and Object_ID('tempdb..#cfrAggrCase') is not null
begin
	set	@drop_cmd = N'drop table #cfrAggrCase'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#AggrCaseFiltered') is not null
begin
	set	@drop_cmd = N'drop table #AggrCaseFiltered'
	execute sp_executesql @drop_cmd
end

if @UsePredefinedData = 0 and Object_ID('tempdb..#cfrTransferOut') is not null
begin
	set	@drop_cmd = N'drop table #cfrTransferOut'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#TransferOutFiltered') is not null
begin
	set	@drop_cmd = N'drop table #TransferOutFiltered'
	execute sp_executesql @drop_cmd
end

if @UsePredefinedData = 0 and Object_ID('tempdb..#cfrBatchTest') is not null
begin
	set	@drop_cmd = N'drop table #cfrBatchTest'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#BatchTestFiltered') is not null
begin
	set	@drop_cmd = N'drop table #BatchTestFiltered'
	execute sp_executesql @drop_cmd
end

if @UsePredefinedData = 0 and Object_ID('tempdb..#cfrBSS') is not null
begin
	set	@drop_cmd = N'drop table #cfrBSS'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#BSSFiltered') is not null
begin
	set	@drop_cmd = N'drop table #BSSFiltered'
	execute sp_executesql @drop_cmd
end

if @UsePredefinedData = 0 and Object_ID('tempdb..#cfrBSSAggr') is not null
begin
	set	@drop_cmd = N'drop table #cfrBSSAggr'
	execute sp_executesql @drop_cmd
end

if Object_ID('tempdb..#BSSAggrFiltered') is not null
begin
	set	@drop_cmd = N'drop table #BSSAggrFiltered'
	execute sp_executesql @drop_cmd
end

if @UsePredefinedData = 0 and Object_ID('tempdb..#SitesToCalculateFiltrationRecords') is not null
begin
	set	@drop_cmd = N'drop table #SitesToCalculateFiltrationRecords'
	execute sp_executesql @drop_cmd
end