-- ================================================================================================
-- Name: USP_GBL_Language_GETList		
-- 
-- Description: Returns a list of languages.
--
-- Revision History:
--		
-- Name				Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     03/02/2021 Initial release.
-- Stephen Long     07/16/2021 Changed over to the base reference table and excluded WHO export.
-- Stephen Long     09/01/2021 Added intRowStatus check to the preference detail select on country 
--                             and startup language.
-- Stephen Long     05/15/2023 Added customization package to only list languages needed by the 
--                             installation.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_GBL_Languages_GETList] (@LanguageID AS NVARCHAR(50))
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @StartupLanguage NVARCHAR(50) = (
				SELECT JSON_VALUE(PreferenceDetail, '$.StartupLanguage')
				FROM dbo.SystemPreference WHERE intRowStatus = 0
				);

		SELECT b.idfsBaseReference AS LanguageID
			,(
				SELECT JSON_VALUE(PreferenceDetail, '$.Country')
				FROM dbo.SystemPreference WHERE intRowStatus = 0
				) AS Country
			,strBaseReferenceCode AS CultureName
			,ISNULL(c.strTextString, b.strDefault) AS DisplayName
			,CONVERT(BIT, (
					CASE 
						WHEN @StartupLanguage = b.strBaseReferenceCode
							THEN 1
						ELSE 0
						END
					)) IsDefaultLanguage
		FROM dbo.trtBaseReference b
		LEFT JOIN dbo.trtStringNameTranslation c ON b.idfsBaseReference = c.idfsBaseReference
			AND c.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
		JOIN dbo.trtLanguageToCP ltc ON	c.idfsBaseReference = ltc.idfsLanguage
		WHERE b.idfsReferenceType = 19000049
			AND b.intRowStatus = 0
			AND ltc.idfCustomizationPackage = dbo.FN_GBL_CustomizationPackage_GET()
			AND b.idfsBaseReference <> 10049002;-- WHO Export
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
