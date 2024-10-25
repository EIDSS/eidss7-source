-- Examples:
/*
	EXEC [dbo].[DF_InsertRecords_All]
*/
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_InsertRecords_All] 
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

print	''
print	'Insert newly calculated records'
print	''
print	''


declare	@CurrentMax	int = @MaxNumberOfNewFiltrationRecords
declare	@N	int = @MaxNumberOfNewFiltrationRecords
if @CalculateHumanData = 1 and @CurrentMax > 0
begin
	-- Insert filtration records for HDRs
	exec [dbo].[DF_InsertRecords_HDR] @MaxNumberOfNewFiltrationRecords=@N,@InsertedRecords=@N output
	set @CurrentMax = @CurrentMax - @N
end

if @CalculateBSSData = 1 and @CurrentMax > 0
begin
	-- Insert filtration records for Basic Surveillance Sessions
	exec [dbo].[DF_InsertRecords_BSS] @MaxNumberOfNewFiltrationRecords=@N,@InsertedRecords=@N output
	set @CurrentMax = @CurrentMax - @N

	if @CurrentMax > 0
	begin
	-- Insert filtration records for ILI Aggregate Forms
		exec [dbo].[DF_InsertRecords_BSSAggregate] @MaxNumberOfNewFiltrationRecords=@N,@InsertedRecords=@N output
		set @CurrentMax = @CurrentMax - @N
	end
end

if @CalculateVetData = 1 and @CurrentMax > 0
begin
	-- Insert filtration records for VDRs
	exec [dbo].[DF_InsertRecords_VDR] @MaxNumberOfNewFiltrationRecords=@N,@InsertedRecords=@N output
	set @CurrentMax = @CurrentMax - @N
end

if (@CalculateHumanData = 1 or @CalculateVetData = 1) and @CurrentMax > 0
begin
	-- Insert filtration records for Active Surveillance Sessions
	exec [dbo].[DF_InsertRecords_ActiveSurveillance] @MaxNumberOfNewFiltrationRecords=@N,@InsertedRecords=@N output
	set @CurrentMax = @CurrentMax - @N

	if @CurrentMax > 0
	begin
	-- Insert filtration records for Aggregate Reports and Actions
		exec [dbo].[DF_InsertRecords_Aggregate] @MaxNumberOfNewFiltrationRecords=@N,@InsertedRecords=@N output
		set @CurrentMax = @CurrentMax - @N
	end
end

if @CalculateVSSData = 1 and @CurrentMax > 0
begin
	-- Insert filtration records for Vector Surveillance Sessions
	exec [dbo].[DF_InsertRecords_VSS] @MaxNumberOfNewFiltrationRecords=@N,@InsertedRecords=@N output
	set @CurrentMax = @CurrentMax - @N
end

if (@CalculateHumanData = 1 or @CalculateVetData = 1 or @CalculateVSSData = 1) and @CurrentMax > 0
begin
	-- Insert filtration records for Batch Tests
	exec [dbo].[DF_InsertRecords_BatchTest] @MaxNumberOfNewFiltrationRecords=@N,@InsertedRecords=@N output
	set @CurrentMax = @CurrentMax - @N


	if @CurrentMax > 0
	begin
	-- Insert filtration records for Transfer Out Acts
		exec [dbo].[DF_InsertRecords_TransferOut] @MaxNumberOfNewFiltrationRecords=@N,@InsertedRecords=@N output
	end
end

set XACT_ABORT off
set nocount off
