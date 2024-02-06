


-- ================================================================================================
-- Name: USP_GBL_Resource_GETList		
-- 
-- Description: Returns a list of resources.
--
-- Revision History:
--		
-- Name				Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     02/23/2021 Initial release.
-- Stephen Long     07/17/2021 Changed over to base reference for language values.
-- Stephen Long     08/31/2021 Added table variable and group by to handle the national value, 
--                             and updated from en-US to get the startup language from the 
--                             preferences table.  Added check to exclude resources for the SSRS
--                             portion of the reports.
-- Mark Wilson      11/15/2021 added where intRowStatus = 0 to systemPreference.
-- Mike Kornegay	05/26/2022 Added join to first query to retrieve any startup language national
--							   that represent labels the user may have changed in interface editor.
-- ================================================================================================
CREATE     PROCEDURE [dbo].[USP_GBL_Resource_GETList] @CultureName NVARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @Resources AS TABLE (
			ResourceID BIGINT NOT NULL
			,LanguageID BIGINT NOT NULL
			,CultureName NVARCHAR(50) NOT NULL
			,ResourceKey VARCHAR(50) NOT NULL
			,ResourceValue NVARCHAR(MAX) NULL
			,ResourceIsHidden BIT NULL
			,ResourceIsRequired BIT NULL
			);
		DECLARE @StartupLanguage NVARCHAR(50) = (
				SELECT JSON_VALUE(PreferenceDetail, '$.StartupLanguage')
				FROM dbo.SystemPreference WHERE intRowStatus = 0
				);

		INSERT INTO @Resources
		SELECT r.idfsResource AS ResourceID
			,l.idfsBaseReference AS LanguageID
			,l.strBaseReferenceCode AS CultureName
			,(CONVERT(NVARCHAR, rsr.idfsResourceSet) + CONVERT(NVARCHAR, r.idfsResource) + CONVERT(NVARCHAR, r.idfsResourceType)) AS ResourceKey
			--,r.strResourceName AS ResourceValue
			,COALESCE(rt.strResourceString, r.strResourceName) AS ResourceValue
			,rsr.isHidden AS ResourceIsHidden
			,rsr.isRequired AS ResourceIsRequired
		FROM dbo.trtResource r
		INNER JOIN dbo.trtResourceSetToResource rsr ON rsr.idfsResource = r.idfsResource
			AND rsr.intRowStatus = 0
		LEFT JOIN dbo.trtResourceTranslation rt ON rt.idfsResource = r.idfsResource
			AND rt.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@StartupLanguage)
			AND rt.intRowStatus = 0
		INNER JOIN dbo.trtBaseReference resourceType ON resourceType.idfsBaseReference = r.idfsResourceType
		INNER JOIN dbo.trtBaseReference l ON l.strBaseReferenceCode = @StartupLanguage
		WHERE r.intRowStatus = 0 
			AND (rsr.idfsReportTextID = 0 OR rsr.idfsReportTextID IS NULL);


		INSERT INTO @Resources
		SELECT r.idfsResource AS ResourceID
			,rt.idfsLanguage AS LanguageID
			,l.strBaseReferenceCode AS CultureName
			,(CONVERT(NVARCHAR, rsr.idfsResourceSet) + CONVERT(NVARCHAR, r.idfsResource) + CONVERT(NVARCHAR, r.idfsResourceType)) AS ResourceKey
			,(
				CASE 
					WHEN rt.strResourceString IS NULL
						THEN r.strResourceName
					ELSE rt.strResourceString
					END
				) AS ResourceValue
			,rsr.isHidden AS ResourceIsHidden
			,rsr.isRequired AS ResourceIsRequired
		FROM dbo.trtResource r
		INNER JOIN dbo.trtResourceSetToResource rsr ON rsr.idfsResource = r.idfsResource
			AND rsr.intRowStatus = 0
		INNER JOIN dbo.trtResourceTranslation rt ON rt.idfsResource = r.idfsResource
																	  
			AND rt.intRowStatus = 0
		INNER JOIN dbo.trtBaseReference l ON l.idfsBaseReference = rt.idfsLanguage
		INNER JOIN dbo.trtBaseReference resourceType ON resourceType.idfsBaseReference = r.idfsResourceType
		WHERE r.intRowStatus = 0 
		AND		(
				l.strBaseReferenceCode = @CultureName
				OR @CultureName IS NULL
				)
			AND r.intRowStatus = 0
			AND (rsr.idfsReportTextID = 0 OR rsr.idfsReportTextID IS NULL);

		SELECT ResourceID
			,LanguageID
			,MAX(CultureName) AS CultureName
			,ResourceKey
			,MAX(ResourceValue) AS ResourceValue
			,ResourceIsHidden
			,ResourceIsRequired
		FROM @Resources
		GROUP BY ResourceKey
			,LanguageID
			,ResourceID
			,ResourceIsHidden
			,ResourceIsRequired
		ORDER BY ResourceKey;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
