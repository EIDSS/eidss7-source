
--*************************************************************
-- Name 				: [FN_GBL_Institution]
-- Description			: The FUNCTION returns all the Institution details 
--          
-- Author               : Mandar Kulkarni
-- Revision History
--		Name		Date       Change Detail
--	JWJ				20180611	added OrganizationTypeID
--	RYM				20190619	added OwnershipForm, LegalForm, and MainFormofActivity 
--	RYM				20190913	added auditcreatedate field
--	Mark Wilson		20210923	Fixed almost everything.
--	Mark Wilson		20211008	updated joins.
--  Olga Mirnaya    20231010    Fixed join condition for LegalFormID 
-- Testing code:
/*

	SELECT * FROM dbo.FN_GBL_Institution('en-US') where idfOffice = 766570000000
	SELECT * FROM dbo.FN_GBL_Institution('az-Latn-AZ') where idfOffice = 49730000000

*/
--*************************************************************
CREATE or ALTER FUNCTION [dbo].[FN_GBL_Institution]
(
 @LangID  NVARCHAR(50)
)
RETURNS TABLE
AS
	RETURN( 

			SELECT			
				o.idfOffice, 
				ISNULL(EnglishFullName.[name], EnglishFullName.strDefault) AS EnglishFullName,
				ISNULL(EnglishAbbr.[name], EnglishAbbr.strDefault) AS EnglishName,
				ISNULL(OfficeName.[name], OfficeName.strDefault) AS FullName,
				ISNULL(OfficeAbbr.[name], OfficeAbbr.strDefault) AS [name],
				o.idfsOfficeName,
				o.idfsOfficeAbbreviation,
				o.idfLocation,
				o.strContactPhone,
				o.intHACode, 
				o.strOrganizationID,
				o.OrganizationTypeID,
				st.idfsSite,   
				o.intRowStatus,
				OfficeName.intOrder,
      			tgs.idfGeoLocationShared,
      			tgs.idfsResidentType,
      			tgs.idfsGroundType,
      			tgs.idfsGeoLocationType,
      			LF.AdminLevel1ID AS idfsCountry,
				LF.AdminLevel1Name AS Country,
      			LF.AdminLevel2ID AS idfsRegion,
				LF.AdminLevel2Name AS Region,
      			LF.AdminLevel3ID AS idfsRayon,
				LF.AdminLevel3Name AS Rayon,
      			LF.AdminLevel4ID AS idfsSettlement,
				LF.AdminLevel4Name AS Settlement,
      			tgs.strPostCode,
      			tgs.strStreetName,
      			tgs.strHouse,
      			tgs.strBuilding,
      			tgs.strApartment,
      			tgs.strDescription,
      			tgs.dblDistance,
      			tgs.dblLatitude,
      			tgs.dblLongitude,
      			tgs.dblAccuracy,
      			tgs.dblAlignment,
      			tgs.blnForeignAddress,
      			tgs.strForeignAddress,
      			tgs.strAddressString,
      			tgs.strShortAddressString,
				orgType.name AS strOrganizationType,
				o.OwnershipFormID,
				ownForm.name AS strOwnershipForm,
				o.LegalFormID,
				legForm.name AS strLegalForm,
				o.MainFormOfActivityID,
				NULL AS strMainFormOfActivity,
				o.AuditCreateDTM

			FROM dbo.tlbOffice o
			INNER JOIN dbo.FN_GBL_Reference_List_GET('en-US', 19000046) EnglishFullName ON EnglishFullName.idfsReference = o.idfsOfficeName
			INNER JOIN dbo.FN_GBL_Reference_List_GET('en-US', 19000045) EnglishAbbr ON EnglishAbbr.idfsReference = o.idfsOfficeAbbreviation
			LEFT JOIN dbo.FN_GBL_Reference_List_GET(@LangID, 19000046) OfficeName ON OfficeName.idfsReference = o.idfsOfficeName
			LEFT JOIN dbo.FN_GBL_Reference_List_GET(@LangID, 19000045) OfficeAbbr ON OfficeAbbr.idfsReference = o.idfsOfficeAbbreviation
			LEFT JOIN dbo.tstSite AS st ON st.idfsSite = o.idfsSite AND st.intRowStatus = 0
			LEFT JOIN dbo.tlbGeoLocationShared tgs ON	tgs.idfGeoLocationShared = o.idfLocation
			LEFT JOIN dbo.gisLocation L ON L.idfsLocation = tgs.idfsLocation
			LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) LF ON LF.idfsLocation = L.idfsLocation
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000504) orgType ON o.OrganizationTypeID = orgType.idfsReference			
			LEFT JOIN  dbo.FN_GBL_ReferenceRepair(@LangID, 19000521) ownForm ON o.OwnershipFormID = ownForm.idfsReference					
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000522) legForm ON o.LegalFormID = legForm.idfsReference					

		)

