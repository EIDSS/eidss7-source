-- ================================================================================================
-- Name: USP_ADMIN_ORG_GETDetail
--
-- Created by:				Mandar Kulkarni
--
-- Description:				Gets an organization record's details.
--
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Mandar Kulkarni            Initial release.
-- Mark Wilson     12/30/2020 Updated to use FN_GBL_InstitionRepair.
-- Stephen Long    04/23/2021 Updated for location hierarchy.
-- Stephen Long    06/18/2021 Corrected typo on schema for gisLocation and added additional 
--                            fields.
-- Stephen Long    06/23/2021 Added accessory code IDs and names comma-delimeted strings.
-- Stephen Long    07/29/2021 Added street and postal code ID's and joins.
-- Stephen Long    03/08/2023 Fixed reference type ID for main form of activity type.
--
-- Testing Code:
--
-- DECLARE @idfOffice bigint
-- EXECUTE USP_ADMIN_ORG_GETDetail 49860000000, 'ru'
-- EXECUTE USP_ADMIN_ORG_GETDetail NULL, 'en'
-- EXECUTE USP_ADMIN_ORG_GETDetail 77233290000792, 'az-l'
--=================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_ORG_GETDetail] (
	@LanguageID AS NVARCHAR(50)
	,@OrganizationKey AS BIGINT
	)
AS
BEGIN
	BEGIN TRY
		SELECT o.idfOffice AS OrganizationKey
			,o.strOrganizationID AS OrganizationID
			,o.OrganizationTypeID
			,organizationType.name AS OrganizationTypeName
			,o.idfsOfficeAbbreviation AS AbbreviatedNameReferenceID
			,b2.strDefault AS AbbreviatedNameDefaultValue
			,o.idfsOfficeName AS FullNameReferenceID
			,b1.strDefault AS FullNameDefaultValue
			,ISNULL(s2.strTextString, b2.strDefault) AS AbbreviatedNameNationalValue
			,ISNULL(s1.strTextString, b1.strDefault) AS FullNameNationalValue
			,adminLevel0.idfsReference AS CountryID
			,adminLevel1.idfsReference AS AdministrativeLevel1ID
			,adminLevel1.name AS AdministrativeLevel1Name
			,adminLevel2.idfsReference AS AdministrativeLevel2ID
			,adminLevel2.name AS AdministrativeLevel2Name
			,NULL AS AdministrativeLevel3ID
			,NULL AS AdministrativeLevel3Name
			,settlement.idfsReference AS SettlementID
			,settlement.name AS SettlementName
			,pc.idfPostalCode AS PostalCodeID 
			,gls.strPostCode AS PostalCode
			,st.idfStreet AS StreetID 
			,gls.strStreetName AS StreetName
			,gls.strHouse AS House
			,gls.strBuilding AS Building
			,gls.strApartment AS Apartment
			,gls.blnForeignAddress AS ForeignAddressIndicator
			,gls.strForeignAddress AS ForeignAddressString
			,o.idfLocation AS AddressID
			,gls.strAddressString AS AddressString
			,o.strContactPhone AS ContactPhone
			,o.OwnershipFormID AS OwnershipFormTypeID
			,ownershipFormType.name AS OwnershipFormTypeName
			,o.LegalFormID AS LegalFormTypeID
			,legalFormType.name AS LegalFormTypeName
			,o.MainFormOfActivityID AS MainFormOfActivityTypeID
			,mainFormOfActivityType.name AS MainFormOfActivityTypeName
			,dbo.FN_GBL_HACode_ToCSV(@LanguageID, o.intHACode) AS AccessoryCodeIDsString
			,dbo.FN_GBL_HACodeNames_ToCSV(@LanguageID, o.intHACode) AS AccessoryCodeNamesString
			,o.intHACode AS AccessoryCode
			,b2.intOrder AS [Order]
			,o.idfsSite AS SiteID
			,o.intRowStatus AS RowStatus
		FROM dbo.tlbOffice o
		LEFT JOIN dbo.tlbGeoLocationShared gls ON gls.idfGeoLocationShared = o.idfLocation
		LEFT JOIN dbo.gisLocation g ON g.idfsLocation = gls.idfsLocation
		LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LanguageID, 19000001) adminLevel0 ON adminLevel0.node = g.node.GetAncestor(dbo.FN_GIS_Location_GetLevel0Ancestor(g.node.GetLevel()))
		LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LanguageID, 19000003) adminLevel1 ON adminLevel1.node = g.node.GetAncestor(dbo.FN_GIS_Location_GetLevel1Ancestor(g.node.GetLevel()))
		LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LanguageID, 19000002) adminLevel2 ON adminLevel2.node = g.node.GetAncestor(dbo.FN_GIS_Location_GetLevel2Ancestor(g.node.GetLevel()))
		LEFT JOIN dbo.FN_GBL_GIS_REFERENCE(@LanguageID, 19000004) settlement ON settlement.idfsReference = gls.idfsLocation
		LEFT OUTER JOIN dbo.trtBaseReference AS b1 ON o.idfsOfficeName = b1.idfsBaseReference
		LEFT JOIN dbo.trtStringNameTranslation AS s1 ON b1.idfsBaseReference = s1.idfsBaseReference
			AND s1.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
		LEFT OUTER JOIN dbo.trtBaseReference AS b2 ON o.idfsOfficeAbbreviation = b2.idfsBaseReference
		LEFT JOIN dbo.trtStringNameTranslation AS s2 ON b2.idfsBaseReference = s2.idfsBaseReference
			AND s2.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000504) organizationType ON o.OrganizationTypeID = organizationType.idfsReference
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000523) mainFormOfActivityType ON o.MainFormOfActivityID = mainFormOfActivityType.idfsReference
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000521) ownershipFormType ON o.OwnershipFormID = ownershipFormType.idfsReference
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000522) legalFormType ON o.LegalFormID = legalFormType.idfsReference
		LEFT JOIN dbo.tlbStreet st ON st.idfsLocation = gls.idfsLocation AND st.strStreetName = gls.strStreetName
		LEFT JOIN dbo.tlbPostalCode pc ON pc.idfsLocation = gls.idfsLocation AND pc.strPostCode = gls.strPostCode
		WHERE o.idfOffice = @OrganizationKey;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
