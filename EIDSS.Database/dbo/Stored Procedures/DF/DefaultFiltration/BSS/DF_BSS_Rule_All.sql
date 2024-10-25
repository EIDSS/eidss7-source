-- Examples:
/*
	EXEC [dbo].[DF_BSS_Rule_All]
	EXEC [dbo].[DF_BSS_Rule_All] @UsePredefinedData=0,@StartDate='20240601',@FillSiteList=0
	EXEC [dbo].[DF_BSS_Rule_All] @UsePredefinedData=1,@FillSiteList=0
*/
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_BSS_Rule_All] 
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

exec [dbo].[DF_BSS_FillList] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@MaxNumberOfProcessedObjects=@MaxNumberOfProcessedObjects

-- Hospital
exec [dbo].[DF_BSS_Rule_idfHospital] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Site entered BSS Report
exec [dbo].[DF_BSS_Rule_idfsSite] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Rayon of the current residence address of the person
exec [dbo].[DF_BSS_Rule_CRAddress] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate
