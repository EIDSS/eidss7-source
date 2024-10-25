-- Examples:
/*
	EXEC [dbo].[DF_CFRule_All]
*/
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_CFRule_All] 
(
	@MaxNumberOfNewFiltrationRecords	int = 1000000,
	@CalculateHumanData					bit = 1,
	@CalculateVetData					bit = 1,
	@CalculateVSSData					bit = 1,
	@CalculateBSSData					bit = 1
)
AS
set nocount on
set XACT_ABORT on

if @MaxNumberOfNewFiltrationRecords is null or @MaxNumberOfNewFiltrationRecords < 0
	set	@MaxNumberOfNewFiltrationRecords = 1000000

if @CalculateHumanData = 1
begin
	-- Calculate configurable filtration records for HDRs
	exec [dbo].[DF_CFRule_HDR] @MaxNumberOfNewFiltrationRecords=@MaxNumberOfNewFiltrationRecords
end

if @CalculateBSSData = 1
begin
	-- Calculate configurable filtration records for Basic Surveillance Sessions
	exec [dbo].[DF_CFRule_BSS] @MaxNumberOfNewFiltrationRecords=@MaxNumberOfNewFiltrationRecords

	-- Calculate configurable filtration records for ILI Aggregate Forms
	exec [dbo].[DF_CFRule_BSSAggregate] @MaxNumberOfNewFiltrationRecords=@MaxNumberOfNewFiltrationRecords
end

if @CalculateVetData = 1
begin
	-- Calculate configurable filtration records for VDRs
	exec [dbo].[DF_CFRule_VDR] @MaxNumberOfNewFiltrationRecords=@MaxNumberOfNewFiltrationRecords
end

if @CalculateHumanData = 1 or @CalculateVetData = 1
begin
	-- Calculate configurable filtration records for Active Surveillance Sessions
	exec [dbo].[DF_CFRule_ActiveSurveillance] @MaxNumberOfNewFiltrationRecords=@MaxNumberOfNewFiltrationRecords

	-- Calculate configurable filtration records for Aggregate Reports and Actions
	exec [dbo].[DF_CFRule_Aggregate] @MaxNumberOfNewFiltrationRecords=@MaxNumberOfNewFiltrationRecords
end

if @CalculateVSSData = 1
begin
	-- Calculate configurable filtration records for Vector Surveillance Sessions
	exec [dbo].[DF_CFRule_VSS] @MaxNumberOfNewFiltrationRecords=@MaxNumberOfNewFiltrationRecords
end

if @CalculateHumanData = 1 or @CalculateVetData = 1 or @CalculateVSSData = 1
begin
	-- Calculate configurable filtration records for Batch Tests
	exec [dbo].[DF_CFRule_BatchTest] @MaxNumberOfNewFiltrationRecords=@MaxNumberOfNewFiltrationRecords

	-- Calculate configurable filtration records for Transfer Out Acts
	exec [dbo].[DF_CFRule_TransferOut] @MaxNumberOfNewFiltrationRecords=@MaxNumberOfNewFiltrationRecords
end

set XACT_ABORT off
set nocount off
