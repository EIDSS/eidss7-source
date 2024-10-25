-- Examples:
/*
	EXEC [dbo].[DF_VSS_Rule_All]
	EXEC [dbo].[DF_VSS_Rule_All] @UsePredefinedData=0,@StartDate='20240601',@FillSiteList=0
	EXEC [dbo].[DF_VSS_Rule_All] @UsePredefinedData=1,@FillSiteList=0
*/
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_VSS_Rule_All] 
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

exec [dbo].[DF_VSS_FillList] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@MaxNumberOfProcessedObjects=@MaxNumberOfProcessedObjects

-- Collected by Institution for a vector/pool linked to VSS
exec [dbo].[DF_VSS_Rule_Vector_idfCollectedByOffice] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Identified by Institution for a vector/pool linked to VSS
exec [dbo].[DF_VSS_Rule_Vector_idfIdentifiedByOffice] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Collected by Institution for a sample linked to VSS
exec [dbo].[DF_VSS_Rule_Sample_idfFieldCollectedByOffice] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Sent to Organization for a sample linked to VSS
exec [dbo].[DF_VSS_Rule_Sample_idfSendToOffice] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Organization where samples connected to VSS were transferred out
exec [dbo].[DF_VSS_Rule_Sample_TransferOut] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Tested by Institution for a field test linked to VSS
exec [dbo].[DF_VSS_Rule_FieldTest_idfTestedByOffice] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Site entered VSS
exec [dbo].[DF_VSS_Rule_idfsSite] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Rayon of the site, where VSS was created
exec [dbo].[DF_VSS_Rule_SiteAddress] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Rayon of the location of the VSS was created
exec [dbo].[DF_VSS_Rule_SessionLocation] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Rayon of the location of any vector from the Detailed Collection liked to the VSS
exec [dbo].[DF_VSS_Rule_VectorDetailLocation] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Rayon of the location of any record from the Aggregate Collection liked to the VSS
exec [dbo].[DF_VSS_Rule_VectorSummaryLocation] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate
