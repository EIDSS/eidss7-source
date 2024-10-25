-- Examples:
/*
	EXEC [dbo].[DF_ActiveSurveillance_Rule_All]
	EXEC [dbo].[DF_ActiveSurveillance_Rule_All] @UsePredefinedData=0,@StartDate='20240601',@FillSiteList=0
	EXEC [dbo].[DF_ActiveSurveillance_Rule_All] @UsePredefinedData=1,@FillSiteList=0
*/
-- ************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[DF_ActiveSurveillance_Rule_All] 
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

exec [dbo].[DF_ActiveSurveillance_FillList] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@MaxNumberOfProcessedObjects=@MaxNumberOfProcessedObjects,@CalculateHumanData=@CalculateHumanData,@CalculateVetData=@CalculateVetData


-- Sent to Organization for a sample linked to Active Surveillance Session
exec [dbo].[DF_ActiveSurveillance_Rule_Sample_idfSendToOffice] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@CalculateHumanData=@CalculateHumanData,@CalculateVetData=@CalculateVetData

-- Organization where samples connected to Active Surveillance Session were transferred out
exec [dbo].[DF_ActiveSurveillance_Rule_Sample_TransferOut] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@CalculateHumanData=@CalculateHumanData,@CalculateVetData=@CalculateVetData

-- Site entered Active Surveillance Session
exec [dbo].[DF_ActiveSurveillance_Rule_idfsSite] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@CalculateHumanData=@CalculateHumanData,@CalculateVetData=@CalculateVetData

-- Rayon of the site, where Active Surveillance Session was created
exec [dbo].[DF_ActiveSurveillance_Rule_SiteAddress] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@CalculateHumanData=@CalculateHumanData,@CalculateVetData=@CalculateVetData

-- Rayon of the location of Active Surveillance Session
exec [dbo].[DF_ActiveSurveillance_Rule_SessionLocation] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate,@CalculateHumanData=@CalculateHumanData,@CalculateVetData=@CalculateVetData

-- Rayons of the addresses of persons, linked to Active Surveillance Session
if @CalculateHumanData = 1
	exec [dbo].[DF_ActiveSurveillance_Rule_CRAddress] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Rayons of the addresses of farms, linked to Active Surveillance Session
if @CalculateVetData = 1
	exec [dbo].[DF_ActiveSurveillance_Rule_FarmAddress] @UsePredefinedData=@UsePredefinedData,@StartDate=@StartDate

-- Active Surveillance data is always distributed across the sites, where the connected HDR(s), linked to the Active Surveillance Session, are available
if @CalculateHumanData = 1
	exec [dbo].[DF_ActiveSurveillance_Rule_HDR]

-- Active Surveillance data is always distributed across the sites, where the connected VDR(s), linked to the Active Surveillance Session, are available
if @CalculateVetData = 1
	exec [dbo].[DF_ActiveSurveillance_Rule_VDR]
