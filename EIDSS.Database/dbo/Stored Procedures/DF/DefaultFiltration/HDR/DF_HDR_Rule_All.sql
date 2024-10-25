-- Examples:
/*
	EXEC [dbo].[DF_HDR_Rule_All]
	EXEC [dbo].[DF_HDR_Rule_All] @UsePredefinedData=0,@StartDate='20240601',@FillSiteList=0
	EXEC [dbo].[DF_HDR_Rule_All] @UsePredefinedData=1,@FillSiteList=0
*/
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[DF_HDR_Rule_All] 
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

exec [dbo].[DF_HDR_FillList] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@MaxNumberOfProcessedObjects=@MaxNumberOfProcessedObjects


-- Organization, specified in the “Notification Sent by Facility” field
exec [dbo].[DF_HDR_Rule_idfSentByOffice] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Organization, specified in the “Notification Received by Facility” field
exec [dbo].[DF_HDR_Rule_idfReceivedByOffice] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Organization, specified in the “Investigating Organization” field
exec [dbo].[DF_HDR_Rule_idfInvestigatedByOffice] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Organization, specified in the “Facility patient first sought care” field
exec [dbo].[DF_HDR_Rule_idfSoughtCareFacility] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Organization, specified in the “Hospital name” field on the “Notification” tab
exec [dbo].[DF_HDR_Rule_idfHospital] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Organization, specified in the “Collected By Institution” field for any sample
exec [dbo].[DF_HDR_Rule_Sample_idfFieldCollectedByOffice] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Organization, specified in the “Sent to Organization” field for any sample
exec [dbo].[DF_HDR_Rule_Sample_idfSendToOffice] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Organization where HDR-connected samples were transferred out
exec [dbo].[DF_HDR_Rule_Sample_TransferOut] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Site entered HDR
exec [dbo].[DF_HDR_Rule_idfsSite] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Rayon of the site, where HDR was created
exec [dbo].[DF_HDR_Rule_SiteAddress] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Rayon of the current residence address
exec [dbo].[DF_HDR_Rule_CRAddress] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Rayon of the location of exposure, if corresponding field was filled in for HDR
exec [dbo].[DF_HDR_Rule_ExposureLocation] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- The Survivor HDR data is sent to the sites of all Superseded HDRs from its deduplication chain.
exec [dbo].[DF_HDR_Rule_DeduplicationChain]
