
--=================================================================================================
-- Name: USP_GBL_LKUP_REFERENCETYPE_GETLIST
--
-- Description: Returns a list of base reference types
--
-- Author: Ricky Moss
--
-- Revision History:
-- Name				Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		06/20/2019 Initial Release
-- Stephen Long     12/26/2019 Replaced 'en' with @LangID on reference call.
-- Doug Albanese	9/4/2020	Added field to obtain language translation
-- EXEC USP_GBL_LKUP_REFERENCETYPE_GETLIST 'en'
--=================================================================================================
CREATE PROCEDURE [dbo].[USP_GBL_LKUP_REFERENCETYPE_GETLIST] (@LangId NVARCHAR(50))
AS
BEGIN
	BEGIN TRY
		SELECT br.idfsReference AS idfsBaseReference,
			br.idfsReferenceType,
			strDefault,
			br.name AS strName,
			intHACode,
			intOrder
		FROM dbo.FN_GBL_ReferenceRepair(@LangId, 19000076) br
		INNER JOIN dbo.trtReferenceType
			ON trtReferenceType.idfsReferenceType = br.idfsReference
		WHERE (intStandard & 4) <> 0
			AND trtReferenceType.intRowStatus = 0
		ORDER BY strReferenceTypeName;
	END TRY

	BEGIN CATCH
		THROW
	END CATCH;
END
