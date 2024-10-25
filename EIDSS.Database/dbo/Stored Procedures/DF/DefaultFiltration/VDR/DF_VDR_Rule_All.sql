-- Examples:
/*
	EXEC [dbo].[DF_VDR_Rule_All]
	EXEC [dbo].[DF_VDR_Rule_All] @UsePredefinedData=0,@StartDate='20240601',@FillSiteList=0
	EXEC [dbo].[DF_VDR_Rule_All] @UsePredefinedData=1,@FillSiteList=0
*/
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_VDR_Rule_All] 
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

exec [dbo].[DF_VDR_FillList] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@MaxNumberOfProcessedObjects=@MaxNumberOfProcessedObjects


-- Old rule of V6.1: Organization of the employee, specified in the “Received By” field
exec [dbo].[DF_VDR_Rule_idfReceivedByOffice] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Notification Organization
exec [dbo].[DF_VDR_Rule_idfReportedByOffice] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Investigation Organization
exec [dbo].[DF_VDR_Rule_idfInvestigatedByOffice] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Collected by Institution for a sample linked to VDR
exec [dbo].[DF_VDR_Rule_Sample_idfFieldCollectedByOffice] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Sent to Organization for a sample linked to VDR
exec [dbo].[DF_VDR_Rule_Sample_idfSendToOffice] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Organization where VDR-connected samples were transferred out
exec [dbo].[DF_VDR_Rule_Sample_TransferOut] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Site entered VDR
exec [dbo].[DF_VDR_Rule_idfsSite] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Rayon of the site, where VDR was created
exec [dbo].[DF_VDR_Rule_SiteAddress] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Rayon of the farm address
exec [dbo].[DF_VDR_Rule_FarmAddress] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- VDR data is always distributed across the sites, where the connected VDR(s) are available
exec [dbo].[DF_VDR_Rule_ConnectedChain]
