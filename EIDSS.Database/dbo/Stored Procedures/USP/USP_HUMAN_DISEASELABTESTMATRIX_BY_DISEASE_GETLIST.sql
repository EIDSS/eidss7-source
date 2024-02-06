-- ================================================================================================
-- Name: USP_CONF_DISEASELABTESTMATRIX_GETLIST
--
-- Description: Returns a list of Disease to lab test matrices given a language and Disease Name
--
-- Author: Ricky Moss
-- 
-- Revision History:
-- Name               Date       Description of Change
-- ------------------ ---------- -----------------------------------------------------------------
-- Ricky Moss         04/08/2019 Initial Release
-- Stephen Long       03/23/2020 Added order by and added procedure to TFS.
--Lamont Mitchell	11/05/2020 added idangosis filter
-- Testing Code:
-- EXEC [USP_HUMAN_DISEASELABTESTMATRIX_BY_DISEASE_GETLIST] 'en'
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_HUMAN_DISEASELABTESTMATRIX_BY_DISEASE_GETLIST] 
@langId NVARCHAR(10),
@idfsDiagnosis bigint = null,
@PaginationSet INT = 1,
@PageSize INT = 10,
@MaxPagesPerFetch INT = 10
AS
BEGIN
SET NOCOUNT ON;


  
	DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS',
		@ReturnCode BIGINT = 0;
	BEGIN TRY

	if(@idfsDiagnosis IS NOT NULL)
	begin
		SELECT distinct td.idfTestForDisease,
			td.idfsDiagnosis,
			dbr.name AS strDisease,
			td.idfsTestName,
			tbr.name AS strTestName,
			td.idfsTestCategory,
			tcbr.name AS strTestCategory,
			idfsSampleType,
			stbr.name AS strSampleType
		FROM dbo.trtTestForDisease td
		LEFT JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000019) dbr
			ON td.idfsDiagnosis = dbr.idfsReference
		LEFT JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000097) tbr
			ON td.idfsTestName = tbr.idfsReference
		LEFT JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000095) tcbr
			ON td.idfsTestCategory = tcbr.idfsReference
		LEFT JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000087) stbr
			ON td.idfsSampleType = stbr.idfsReference
		WHERE intRowStatus = 0 
	
		AND (idfsDiagnosis = @IdfsDiagnosis or @IdfsDiagnosis IS NULL)
		ORDER BY strTestName 
		--OFFSET(@PageSize * @MaxPagesPerFetch) * (@PaginationSet - 1) ROWS


		--FETCH NEXT (@PageSize * @MaxPagesPerFetch) ROWS ONLY;
		END
		ELSE
			BEGIN
			  Select 
				distinct td.idfTestForDisease,
				td.idfsDiagnosis,
				dbr.name AS strDisease,
				td.idfsTestName,
				tbr.name AS strTestName,
				td.idfsTestCategory,
				cast('' as nvarchar) as strTestCategory,
				cast(0 as bigint) as idfsSampleType,
				cast('' as nvarchar) as strSampleType
				FROM trtTestForDisease td
				JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000019) dbr
				ON td.idfsDiagnosis = dbr.idfsReference
				JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000097) tbr
				ON  td.idfsTestName = tbr.idfsReference
				ORDER BY strTestName 
			END
		--SELECT @ReturnCode,
			--@ReturnMessage;
	END TRY

	BEGIN CATCH
	--SET @ReturnCode = ERROR_NUMBER();
	--SET @ReturnMessage = ERROR_MESSAGE();

	--	SELECT @ReturnCode,
	--		@ReturnMessage;
		--THROW;
	END CATCH
END
