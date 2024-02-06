--*************************************************************
-- exec USP_ADMIN_ORG_GETList_Test 'en', null, NULL, NULL, null, null, null, null, null, null, null
--*************************************************************
CREATE      PROCEDURE [dbo].[USP_ADMIN_ORG_GETList_TEST]
(
	@LangId				NVARCHAR(50), --##PARAM 'en' - language ID
	@idfOrgID			BIGINT			= NULL, --##PARAM @ID - organization ID, if not NULL only record with this organization IS selected
	@strOrganizationID	NVARCHAR(100)	= NULL,
	@strOrgName			NVARCHAR(100)	= NULL,
	@strOrgFullName		NVARCHAR(100)	= NULL,
	@intHACode			INT				= NULL,
	@idfsSite			BIGINT			= NULL,
	@idfsRegion			BIGINT			= NULL,
	@idfsRayon			BIGINT			= NULL,
	@idfsSettlement		BIGINT			= NULL,
	@OrganizationTypeID	BIGINT			= NULL,
	@pageSize			INT				= 10, -- Indicates the number of rows that make up a grid page of data.  This value must default to 10 rows per grid page.
	@maxPagesPerFetch	INT				= 10, --Determines the maximum number of pages to return in a single call.  This variable must be defaulted to 10 pages per fetch.
	@paginationSet		INT				= 1 --Specifies the set of data to return.  A set is the maximum pages per fetch (@maxPagesPerFetch) * the page size (@pageSize).  This must default to pagination set 1; so, by default we’ll retrieve the 1st set of data; which is equal to 100 rows.
)
AS
BEGIN
	BEGIN TRY

	IF((@pageSize = 0) AND (@maxPagesPerFetch = 0) AND (@paginationSet = 0))
	BEGIN
		SELECT  idfOffice as idfInstitution, 
								EnglishName,
								[name], 
								EnglishFullName,
								FullName, 
								idfsOfficeName, 
								idfsOfficeAbbreviation, 
								CAST(CASE WHEN (intHACode & 2)>0 THEN 1 ELSE 0 END AS BIT) AS blnHuman,
								CAST(CASE WHEN (intHACode & 96)>0 THEN 1 ELSE 0 END AS BIT) AS blnVet,
								CAST(CASE WHEN (intHACode & 32)>0 THEN 1 ELSE 0 END AS BIT) AS blnLivestock,
								CAST(CASE WHEN (intHACode & 64)>0 THEN 1 ELSE 0 END AS BIT) AS blnAvian,
								CAST(CASE WHEN (intHACode & 128)>0 THEN 1 ELSE 0 END AS BIT) AS blnVector,
								CAST(CASE WHEN (intHACode & 256)>0 THEN 1 ELSE 0 END AS BIT) AS blnSyndromic,
								intHACode,
								idfsSite,
								strOrganizationID,
								intRowStatus,
								intOrder,
								idfLocation,
      							idfGeoLocationShared,
      							idfsResidentType,
      							idfsGroundType,
      							idfsGeoLocationType,
      							idfsCountry,
								Country,
      							idfsRegion,
								Region,
      							idfsRayon,
								Rayon,
      							idfsSettlement,
								Settlement,
      							strPostCode,
      							strStreetName,
      							strHouse,
      							strBuilding,
      							strApartment,
      							strDescription,
      							dblDistance,
      							dblLatitude,
      							dblLongitude,
      							dblAccuracy,
      							dblAlignment,
      							blnForeignAddress,
      							strForeignAddress,
      							strAddressString,
      							strShortAddressString,
								OrganizationTypeID,
								strOrganizationType,
								OwnershipFormID,
								strOwnershipForm,
								LegalFormID,
								strLegalForm,
								MainFormOfActivityID,
								strMainFormOfActivity
						FROM 	dbo.FN_GBL_INSTITUTION(@LangId)
						WHERE	intRowStatus = 0 AND

			ISNULL(idfOffice, '') = IIF(@idfOrgID IS NOT NULL, @idfOrgId, ISNULL(idfOffice, '')) AND
			ISNULL(strOrganizationID, '') LIKE IIF(@strOrganizationID IS NOT NULL,'%' + @strOrganizationID + '%',ISNULL(strOrganizationID,'')) AND
			ISNULL([name], '') LIKE IIF(@strOrgName IS NOT NULL,'%' + @strOrgName + '%',ISNULL([name],''))  AND
			ISNULL(FullName, '') LIKE IIF(@strOrgFullName IS NOT NULL,'%' + @strOrgFullName + '%',ISNULL([FullName],'')) AND
			ISNULL(intHACode, '') = IIF(@intHACode IS NOT NULL, @intHACode, ISNULL(intHACode,'')) AND
			ISNULL(idfsSite, '') = IIF(@idfsSite IS NOT NULL, @idfsSite, ISNULL(idfsSite,'')) AND
			ISNULL(idfsRegion, '') = IIF(@idfsRegion IS NOT NULL, @idfsRegion, ISNULL(idfsRegion,'')) AND
			ISNULL(idfsRayon, '') = IIF(@idfsRayon IS NOT NULL, @idfsRayon, ISNULL(idfsRayon,'')) AND
			ISNULL(idfsSettlement, '') = IIF(@idfsSettlement IS NOT NULL, @idfsSettlement, ISNULL(idfsSettlement,'')) AND
			ISNULL(OrganizationTypeID, '') = IIF(@OrganizationTypeID IS NOT NULL, @OrganizationTypeID, ISNULL(OrganizationTypeID,''))
	END
	ELSE
	BEGIN
		SELECT  idfOffice as idfInstitution,  
								EnglishName,
								[name], 
								EnglishFullName,
								FullName, 
								idfsOfficeName, 
								idfsOfficeAbbreviation, 
								CAST(CASE WHEN (intHACode & 2)>0 THEN 1 ELSE 0 END AS BIT) AS blnHuman,
								CAST(CASE WHEN (intHACode & 96)>0 THEN 1 ELSE 0 END AS BIT) AS blnVet,
								CAST(CASE WHEN (intHACode & 32)>0 THEN 1 ELSE 0 END AS BIT) AS blnLivestock,
								CAST(CASE WHEN (intHACode & 64)>0 THEN 1 ELSE 0 END AS BIT) AS blnAvian,
								CAST(CASE WHEN (intHACode & 128)>0 THEN 1 ELSE 0 END AS BIT) AS blnVector,
								CAST(CASE WHEN (intHACode & 256)>0 THEN 1 ELSE 0 END AS BIT) AS blnSyndromic,
								intHACode,
								idfsSite,
								strOrganizationID,
								intRowStatus,
								intOrder,
								idfLocation,
      							idfGeoLocationShared,
      							idfsResidentType,
      							idfsGroundType,
      							idfsGeoLocationType,
      							idfsCountry,
								Country,
      							idfsRegion,
								Region,
      							idfsRayon,
								Rayon,
      							idfsSettlement,
								Settlement,
      							strPostCode,
      							strStreetName,
      							strHouse,
      							strBuilding,
      							strApartment,
      							strDescription,
      							dblDistance,
      							dblLatitude,
      							dblLongitude,
      							dblAccuracy,
      							dblAlignment,
      							blnForeignAddress,
      							strForeignAddress,
      							strAddressString,
      							strShortAddressString,
								OrganizationTypeID,
								strOrganizationType,
								OwnershipFormID,
								strOwnershipForm,
								LegalFormID,
								strLegalForm,
								MainFormOfActivityID,
								strMainFormOfActivity
						FROM 	dbo.FN_GBL_INSTITUTION(@LangId)
						WHERE	intRowStatus = 0 AND

			ISNULL(idfOffice, '') = IIF(@idfOrgID IS NOT NULL, @idfOrgId, ISNULL(idfOffice, '')) AND
			ISNULL(strOrganizationID, '') LIKE IIF(@strOrganizationID IS NOT NULL,'%' + @strOrganizationID + '%',ISNULL(strOrganizationID,'')) AND
			ISNULL([name], '') LIKE IIF(@strOrgName IS NOT NULL,'%' + @strOrgName + '%',ISNULL([name],''))  AND
			ISNULL(FullName, '') LIKE IIF(@strOrgFullName IS NOT NULL,'%' + @strOrgFullName + '%',ISNULL([FullName],'')) AND
			--((
			--		@intHACode IN (
			--			SELECT intHACode
			--			FROM dbo.FN_GBL_SplitHACode(intHACode, 510)
			--			))
			--	OR (@intHACode IS  NULL)
			--	)AND 
			--ISNULL(@intHACode, '') IN (IIF(intHACode IS NOT NULL, (SELECT intHACode FROM FN_GBL_SplitHACode(@intHACode, 510)), ISNULL(intHACode, '')))  AND
			ISNULL(intHACode, '') = IIF(@intHACode IS NOT NULL, @intHACode, ISNULL(intHACode,'')) AND
			ISNULL(idfsSite, '') = IIF(@idfsSite IS NOT NULL, @idfsSite, ISNULL(idfsSite,'')) AND
			ISNULL(idfsRegion, '') = IIF(@idfsRegion IS NOT NULL, @idfsRegion, ISNULL(idfsRegion,'')) AND
			ISNULL(idfsRayon, '') = IIF(@idfsRayon IS NOT NULL, @idfsRayon, ISNULL(idfsRayon,'')) AND
			ISNULL(idfsSettlement, '') = IIF(@idfsSettlement IS NOT NULL, @idfsSettlement, ISNULL(idfsSettlement,'')) AND
			ISNULL(OrganizationTypeID, '') = IIF(@OrganizationTypeID IS NOT NULL, @OrganizationTypeID, ISNULL(OrganizationTypeID,''))

		ORDER BY AuditCreateDTM DESC OFFSET (@pageSize * @maxPagesPerFetch) * (@paginationSet -1) ROWS
		FETCH NEXT (@pageSize * @maxPagesPerFetch) ROWS ONLY
	END
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
