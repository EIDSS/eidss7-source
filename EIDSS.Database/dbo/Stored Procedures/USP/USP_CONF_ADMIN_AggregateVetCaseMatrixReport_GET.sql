
CREATE PROCEDURE [dbo].[USP_CONF_ADMIN_AggregateVetCaseMatrixReport_GET] 
/*******************************************************
NAME						: [USP_CONF_ADMIN_AggregateVetCaseMatrixReport_GET]		


Description					: Retreives List of Diseases For Vet Aggregate Case Matrix Version by version

Author						: Lamont Mitchell

Revision History
		
Name					Date				Change Detail
Lamont Mitchell			03/4/19				Initial Created
Mark Wilson				04/13/21			Added Translation
Mark Wilson				10/28/21			Added test code
Ann Xiong				10/04/22			Changed parameter @idfVersion BIGINT to @versionList NVARCHAR(MAX)

/* Test code

DECLARE	@return_value int

EXEC	@return_value = [dbo].[USP_CONF_ADMIN_AggregateVetCaseMatrixReport_GET]
		@idfVersion = 115299280001056,
		@LangID = N'en-US'

SELECT	'Return Value' = @return_value

*/*******************************************************/
(
	@versionList NVARCHAR(MAX),
	--@idfVersion BIGINT,
	@LangID NVARCHAR(24)
)
AS

BEGIN

	BEGIN TRY 
		SELECT	 
				mtx.intNumRow,
				mtx.idfAggrVetCaseMTX AS idfAggrVetCaseMTX,
				mtx.idfsDiagnosis,
				mtx.idfsSpeciesType,
				D.[Name],
				D.strOIECode

		FROM dbo.tlbAggrVetCaseMTX mtx
		INNER JOIN dbo.FN_GBL_DiagnosisRepair(@LangID, 96, 10020002) D ON D.idfsDiagnosis = mtx.idfsDiagnosis  -- 2 = Human, use 10020002 for Aggregate cases

		--WHERE mtx.intRowStatus = 0 AND  mtx.idfVersion = @idfVersion
		WHERE mtx.intRowStatus = 0 AND  mtx.idfVersion IN (SELECT * FROM STRING_SPLIT(@versionList, ','))
		ORDER BY mtx.intNumRow ASC
		 

	END TRY

	BEGIN CATCH

			THROW;

	END CATCH

END

