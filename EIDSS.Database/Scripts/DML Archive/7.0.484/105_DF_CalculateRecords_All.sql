-- Examples:
/*
	EXEC [dbo].[DF_CalculateRecords_All] @StartDate=null,@CalculateHumanData=1
	EXEC [dbo].[DF_CalculateRecords_All] @StartDate='20240101'

*/
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_CalculateRecords_All] 
(
	@UsePredefinedData					bit = 0,
	@StartDate							datetime = null,
	@MaxNumberOfProcessedObjects		int = 1000000,
	@MaxNumberOfNewFiltrationRecords	int = 1000000,
	@CalculateHumanData					bit = 1,
	@CalculateVetData					bit = 1,
	@CalculateVSSData					bit = 1,
	@CalculateBSSData					bit = 1,
	@ApplyCFRules						bit = 1
)
AS
set nocount on
set XACT_ABORT on

if @MaxNumberOfProcessedObjects is null or @MaxNumberOfProcessedObjects < 0
	set	@MaxNumberOfProcessedObjects = 1000000

if @MaxNumberOfNewFiltrationRecords is null or @MaxNumberOfNewFiltrationRecords < 0
	set	@MaxNumberOfNewFiltrationRecords = 1000000

if @StartDate is not null
	set @StartDate = cast(@StartDate as date)

if Object_ID('tempdb..#SitesToCalculateFiltrationRecords') is null
create table	#SitesToCalculateFiltrationRecords
(	[idfID]			bigint not null identity(1,1),
	[strSiteID]		varchar(36) collate Cyrillic_General_CI_AS not null primary key,
	[idfsSite]		bigint null,
	[idfOffice]		bigint null,
	[idfsRayon]		bigint null,
	[idfSiteGroup]	bigint null
)

-- Create temporary tables and truncate them if needed
exec [dbo].[DF_CreateTempTables] @UsePredefinedData=@UsePredefinedData

-- Fill in sites to calculate filtration records
EXEC [dbo].[DF_FillSiteList] @UsePredefinedData=@UsePredefinedData


-- Print specified criteria
print	'Criteria specified for the script:'
print	''

if @MaxNumberOfNewFiltrationRecords is null
	set	@MaxNumberOfNewFiltrationRecords = 1000000
print	'Maximum number of new filtration records to be inserted during execution of the script: ' + cast(@MaxNumberOfNewFiltrationRecords as varchar(20))

if @MaxNumberOfProcessedObjects is null
	set	@MaxNumberOfProcessedObjects = 1000000
print	'Maximum number of the objects from any module to be processed during execution of the script: ' + cast(@MaxNumberOfProcessedObjects as varchar(20))
print	''

print	'Start Date of the interval for added or modified data that shall fall under calculation of the filtration records: ' + left(isnull(convert(nvarchar, @StartDate, 20), N'None'), 10)
print	''

print	'Filtration records for human data: ' + case when @CalculateHumanData = 1 then N'Calculate' else N'Skip' end
print	'Filtration records for veterinary data: ' + case when @CalculateVetData = 1 then N'Calculate' else N'Skip' end
print	'Filtration records for vector surveillance data: ' + case when @CalculateVSSData = 1 then N'Calculate' else N'Skip' end
print	'Filtration records for basic syndromic surveillance data: ' + case when @CalculateBSSData = 1 then N'Calculate' else N'Skip' end
print	''

print	'Apply Configurable Filtration Rules: ' + case when @ApplyCFRules = 1 then 'Yes' else N'No' end
print	''

declare	@N	int
select	@N = count(idfID)
from	#SitesToCalculateFiltrationRecords
print	'Sites of third level with configured bidirectional group to calculate filtration records found in the database: ' + cast(@N as varchar(20))
print	''

if @CalculateHumanData = 1
begin
	-- Calculate filtration records for HDRs
	exec [dbo].[DF_HDR_Rule_All] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@MaxNumberOfProcessedObjects=@MaxNumberOfProcessedObjects,@FillSiteList=0
end

if @CalculateBSSData = 1
begin
	-- Calculate filtration records for Basic Surveillance Sessions
	exec [dbo].[DF_BSS_Rule_All] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@MaxNumberOfProcessedObjects=@MaxNumberOfProcessedObjects,@FillSiteList=0

	-- Calculate filtration records for ILI Aggregate Forms
	exec [dbo].[DF_BSSAggregate_Rule_All] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@MaxNumberOfProcessedObjects=@MaxNumberOfProcessedObjects,@FillSiteList=0
end

if @CalculateVetData = 1
begin
	-- Calculate filtration records for VDRs
	exec [dbo].[DF_VDR_Rule_All] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@MaxNumberOfProcessedObjects=@MaxNumberOfProcessedObjects,@FillSiteList=0
end

if @CalculateHumanData = 1 or @CalculateVetData = 1
begin
	-- Calculate filtration records for Active Surveillance Sessions
	exec [dbo].[DF_ActiveSurveillance_Rule_All] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@MaxNumberOfProcessedObjects=@MaxNumberOfProcessedObjects,@FillSiteList=0,@CalculateHumanData=@CalculateHumanData,@CalculateVetData=@CalculateVetData

	-- Calculate filtration records for Aggregate Reports and Actions
	exec [dbo].[DF_Aggregate_Rule_All] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@MaxNumberOfProcessedObjects=@MaxNumberOfProcessedObjects,@FillSiteList=0,@CalculateHumanData=@CalculateHumanData,@CalculateVetData=@CalculateVetData
end

if @CalculateVSSData = 1
begin
	-- Calculate filtration records for Vector Surveillance Sessions
	exec [dbo].[DF_VSS_Rule_All] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@MaxNumberOfProcessedObjects=@MaxNumberOfProcessedObjects,@FillSiteList=0
end

if @CalculateHumanData = 1 or @CalculateVetData = 1 or @CalculateVSSData = 1
begin
	-- Calculate filtration records for Batch Tests
	exec [dbo].[DF_BatchTest_Rule_All] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@MaxNumberOfProcessedObjects=@MaxNumberOfProcessedObjects,@FillSiteList=0,@CalculateHumanData=@CalculateHumanData,@CalculateVetData=@CalculateVetData,@CalculateVSSData=@CalculateVSSData

	-- Calculate filtration records for Transfer Out Acts
	exec [dbo].[DF_TransferOut_Rule_All] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@MaxNumberOfProcessedObjects=@MaxNumberOfProcessedObjects,@FillSiteList=0,@CalculateHumanData=@CalculateHumanData,@CalculateVetData=@CalculateVetData,@CalculateVSSData=@CalculateVSSData
end


if @CalculateHumanData = 1 or @CalculateVetData = 1 or @CalculateVSSData = 1 or @CalculateBSSData = 1
begin
	-- Calculate configurable filtration rules for all objects
	if @ApplyCFRules = 1
		exec [dbo].[DF_CFRule_All] @MaxNumberOfNewFiltrationRecords=@MaxNumberOfNewFiltrationRecords,@CalculateHumanData=@CalculateHumanData,@CalculateVetData=@CalculateVetData,@CalculateVSSData=@CalculateVSSData,@CalculateBSSData=@CalculateBSSData

	-- Insert newly calculated filtration records
	exec [dbo].[DF_InsertRecords_All] @MaxNumberOfNewFiltrationRecords=@MaxNumberOfNewFiltrationRecords,@CalculateHumanData=@CalculateHumanData,@CalculateVetData=@CalculateVetData,@CalculateVSSData=@CalculateVSSData,@CalculateBSSData=@CalculateBSSData
end


-- Drop temporary tables
exec [dbo].[DF_DropTempTables] @UsePredefinedData=@UsePredefinedData

set XACT_ABORT off
set nocount off
