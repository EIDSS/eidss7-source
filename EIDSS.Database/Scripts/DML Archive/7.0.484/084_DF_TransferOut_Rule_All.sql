-- Examples:
/*
	EXEC [dbo].[DF_TransferOut_Rule_All]
	EXEC [dbo].[DF_TransferOut_Rule_All] @UsePredefinedData=0,@StartDate='20240601',@FillSiteList=0
	EXEC [dbo].[DF_TransferOut_Rule_All] @UsePredefinedData=1,@FillSiteList=0
*/
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_TransferOut_Rule_All] 
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

exec [dbo].[DF_TransferOut_FillList] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@MaxNumberOfProcessedObjects=@MaxNumberOfProcessedObjects,@CalculateHumanData=@CalculateHumanData,@CalculateVetData=@CalculateVetData,@CalculateVSSData=@CalculateVSSData

-- Transfer To
exec [dbo].[DF_TransferOut_Rule_idfSendToOffice] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Transfer From
exec [dbo].[DF_TransferOut_Rule_idfSendFromOffice] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Site entered Transfer Out Act
exec [dbo].[DF_TransferOut_Rule_idfsSite] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate
