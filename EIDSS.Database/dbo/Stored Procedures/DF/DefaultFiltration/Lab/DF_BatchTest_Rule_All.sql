-- Examples:
/*
	EXEC [dbo].[DF_BatchTest_Rule_All]
	EXEC [dbo].[DF_BatchTest_Rule_All] @UsePredefinedData=0,@StartDate='20240601',@FillSiteList=0
	EXEC [dbo].[DF_BatchTest_Rule_All] @UsePredefinedData=1,@FillSiteList=0
*/
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_BatchTest_Rule_All] 
(
	@UsePredefinedData					bit = 0,
	@StartDate							datetime = null,
	@MaxNumberOfProcessedObjects		int = 1000000,
	@FillSiteList						bit = 0,
	@CalculateHumanData					bit = 1,
	@CalculateVetData					bit = 1,
	@CalculateVSSData					bit = 1
)
AS

if @FillSiteList = 1
	EXEC [dbo].[DF_FillSiteList] @UsePredefinedData=@UsePredefinedData

if @MaxNumberOfProcessedObjects is null or @MaxNumberOfProcessedObjects < 0
	set	@MaxNumberOfProcessedObjects = 1000000

exec [dbo].[DF_BatchTest_FillList] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@MaxNumberOfProcessedObjects=@MaxNumberOfProcessedObjects,@CalculateHumanData=@CalculateHumanData,@CalculateVetData=@CalculateVetData,@CalculateVSSData=@CalculateVSSData

-- Batch Test data is available at all sites, where all connected Tests linked to HDRs are available.
exec [dbo].[DF_BatchTest_Rule_HDR] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Batch Test data is available at all sites, where all connected Tests linked to VDRs are available.
exec [dbo].[DF_BatchTest_Rule_VDR] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Batch Test data is available at all sites, where all connected Tests linked to Active Surveillance Sessions are available.
exec [dbo].[DF_BatchTest_Rule_ActiveSurveillance] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Batch Test data is available at all sites, where all connected Tests linked to Vector Surveillance Sessions are available.
exec [dbo].[DF_BatchTest_Rule_VSS] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Site entered Batch Test
exec [dbo].[DF_BatchTest_Rule_idfsSite] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate
