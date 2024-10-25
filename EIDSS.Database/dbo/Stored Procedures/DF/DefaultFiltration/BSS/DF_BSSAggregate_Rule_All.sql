-- Examples:
/*
	EXEC [dbo].[DF_BSSAggregate_Rule_All]
	EXEC [dbo].[DF_BSSAggregate_Rule_All] @UsePredefinedData=0,@StartDate='20240601',@FillSiteList=0
	EXEC [dbo].[DF_BSSAggregate_Rule_All] @UsePredefinedData=1,@FillSiteList=0
*/
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_BSSAggregate_Rule_All] 
(
	@UsePredefinedData					bit = 0,
	@StartDate							datetime = null,
	@MaxNumberOfProcessedObjects		int = 1000000,
	@FillSiteList						bit = 0
)
AS

if @FillSiteList = 1
	EXEC [dbo].[DF_FillSiteList] @UsePredefinedData=@UsePredefinedData

if @MaxNumberOfProcessedObjects is null or @MaxNumberOfProcessedObjects < 0
	set	@MaxNumberOfProcessedObjects = 1000000

exec [dbo].[DF_BSSAggregate_FillList] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@MaxNumberOfProcessedObjects=@MaxNumberOfProcessedObjects

-- Hospital in any of the table records linked to ILI Aggregate Form
exec [dbo].[DF_BSSAggregate_Rule_idfHospital] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Site entered ILI Aggregate Form
exec [dbo].[DF_BSSAggregate_Rule_idfsSite] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate
