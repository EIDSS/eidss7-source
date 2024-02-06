-- ================================================================================================
-- Name: USP_GBL_DISEASE_MTX_GET_BY_UsingType
--
-- Description: Retreives Entries For Human Aggregate Case Matrix By Using Type
--
-- Author: Lamont Mitchell
--
-- Revision History:
-- 	
-- Name              Date       Change Detail
-- ----------------- ---------- ------------------------------------------------------------------
-- Lamont Mitchell   06/15/2019 Initial Created
-- Stephen Long      12/22/2020 Replaced V6.1 function call with V7.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_GBL_DISEASE_MTX_GET_BY_UsingType] @UsingType BIGINT = NULL
	,@intHACode BIGINT = NULL
	,@strLanguageID VARCHAR(5) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SELECT D.idfsDiagnosis idfsBaseReference
			,DT.[name] strDefault
			,D.strIDC10
		FROM dbo.FN_GBL_Reference_GETList(@strLanguageID, 19000019) DT --Function to translate reference data
		INNER JOIN dbo.trtDiagnosis D ON D.idfsDiagnosis = DT.idfsReference
		WHERE (
				@intHACode = 0
				OR @intHACode IS NULL
				OR intHACode IS NULL
				OR CASE -- 1 = animal, 32 = liveStock , 64 = avian
					--below we assume that client will never pass animal bit without livestock or avian bits
					WHEN (intHACode & 97) > 1
						THEN (~ 1 & intHACode) & @intHACode -- if avian or livestock bits are set, clear animal bit in  b.intHA_Code
					WHEN (intHACode & 97) = 1
						THEN (~ 1 & intHACode | 96) & @intHACode --if only animal bit is set, clear clear animal bit and set both avian and livestock bits in  b.intHA_Code
					ELSE intHACode & @intHACode
					END > 0
				)
			AND (
				@UsingType IS NULL
				OR D.idfsDiagnosis IS NULL
				OR D.idfsUsingType = @UsingType
				)
		ORDER BY DT.[name] ASC;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
