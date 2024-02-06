-- ================================================================================================
-- Author: Steven Verner
--
-- Create Date: 04.19.2019
-- 
-- Description:	Retrieves the ASPNet Users information along with all pertinent employee 
-- information
--
-- Revision History:
-- Name            Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Steven Verner   04/19/2019 Initial release
-- Stephen Long    12/26/2019 Changed to v7 function call on reference.
-- Stephen Long    03/25/2020 Added site type ID to support site filtration.
-- Stephen Long    11/24/2020 Added site group ID in the scenario a user's site is part of a group.
-- Steven Verner   01/15/2021 Added PasswordRequiresReset.
-- Mani			   01/25/2021 Added Organization Full Name
-- Mani			   01/26/2021 changed FN_GBL_ReferenceRepair('en', 19000046) from inner join to left join
-- Mani				10/07/2022 Added strHASCsiteID 
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ASPNetUser_GetDetail] @Id NVARCHAR(128)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT u.Id
		,ut.idfsSite
		,u.idfUserID
		,u.Email
		,u.LockoutEnd
		,u.LockoutEnabled
		,u.AccessFailedCount
		,u.UserName
		,ut.idfPerson
		,p.strFirstName
		,p.strSecondName
		,p.strFamilyName
		,o.idfOffice
		,o.idfOffice Institution
		,ISNULL(oa.Name, oa.strDefault) OfficeAbbreviation
		,ISNULL(oaf.Name, oaf.strDefault) OfficeFullName
		,gs.idfsRegion
		,gs.idfsRayon
		,s.idfsSiteType
		,sgs.idfSiteGroup AS SiteGroupID
		,u.PasswordResetRequired,
		s.strHASCsiteID
	FROM dbo.AspNetUsers u
	JOIN dbo.tstUserTable ut ON ut.idfUserID = u.idfUserID
	LEFT JOIN dbo.tflSiteToSiteGroup AS sgs ON sgs.idfsSite = ut.idfsSite
	JOIN dbo.tlbPerson p ON p.idfPerson = ut.idfPerson
	JOIN dbo.tlbOffice o ON o.idfOffice = p.idfInstitution
	LEFT JOIN dbo.tstSite s ON s.idfsSite = ut.idfsSite
		AND s.intRowStatus = 0
	JOIN dbo.FN_GBL_ReferenceRepair('en', 19000045) oa ON oa.idfsReference = o.idfsOfficeAbbreviation
	LEFT JOIN dbo.FN_GBL_ReferenceRepair('en', 19000046) oaf ON oaf.idfsReference = o.idfsOfficeName
	JOIN dbo.tlbGeoLocationShared gs ON gs.idfGeoLocationShared = o.idfLocation
	WHERE u.id = @Id;
END
