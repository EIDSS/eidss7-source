-- Examples:
/*
	EXEC [dbo].[DF_Aggregate_Rule_All]
	EXEC [dbo].[DF_Aggregate_Rule_All] @UsePredefinedData=0,@StartDate='20240601',@FillSiteList=0
	EXEC [dbo].[DF_Aggregate_Rule_All] @UsePredefinedData=1,@FillSiteList=0
*/
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_Aggregate_Rule_All] 
(
	@UsePredefinedData					bit = 0,
	@StartDate							datetime = null,
	@MaxNumberOfProcessedObjects		int = 1000000,
	@FillSiteList						bit = 0,
	@CalculateHumanData					bit = 1,
	@CalculateVetData					bit = 1
)
AS

if @FillSiteList = 1
	EXEC [dbo].[DF_FillSiteList] @UsePredefinedData=@UsePredefinedData

if @MaxNumberOfProcessedObjects is null or @MaxNumberOfProcessedObjects < 0
	set	@MaxNumberOfProcessedObjects = 1000000

exec [dbo].[DF_Aggregate_FillList] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@MaxNumberOfProcessedObjects=@MaxNumberOfProcessedObjects,@CalculateHumanData=@CalculateHumanData,@CalculateVetData=@CalculateVetData


-- Notification Sent by: Institution
exec [dbo].[DF_Aggregate_Rule_idfSentByOffice] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@CalculateHumanData=@CalculateHumanData,@CalculateVetData=@CalculateVetData

-- Notification Received by: Institution
exec [dbo].[DF_Aggregate_Rule_idfReceivedByOffice] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@CalculateHumanData=@CalculateHumanData,@CalculateVetData=@CalculateVetData

-- Notification Entered by: Institution
exec [dbo].[DF_Aggregate_Rule_idfEnteredByOffice] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@CalculateHumanData=@CalculateHumanData,@CalculateVetData=@CalculateVetData

-- Site entered Aggregate Report
exec [dbo].[DF_Aggregate_Rule_idfsSite] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@CalculateHumanData=@CalculateHumanData,@CalculateVetData=@CalculateVetData

-- General Info: Rayon OR rayon of General Info: Settlement of Aggregate Report
exec [dbo].[DF_Aggregate_Rule_AdministrativeUnit] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@CalculateHumanData=@CalculateHumanData,@CalculateVetData=@CalculateVetData
