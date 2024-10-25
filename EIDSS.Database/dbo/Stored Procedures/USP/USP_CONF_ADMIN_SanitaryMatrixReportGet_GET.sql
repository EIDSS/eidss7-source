

CREATE PROCEDURE [dbo].[USP_CONF_ADMIN_SanitaryMatrixReportGet_GET] 

/*******************************************************
NAME						: [USP_CONF_ADMIN_SanitaryMatrixReportGet_GET]		


Description					: Retreives List of Vet Sanitary Diagnosisis  Matrix  by version

Author						: Lamont Mitchell

Revision History
		
	Name					Date				Change Detail
	Lamont Mitchell			03/4/19				Initial Created
	Mark Wilson				10/27/2021			Added @LangID and join to FN_GBL_Reference

/* Test Code

DECLARE	@return_value int

EXEC	@return_value = [dbo].[USP_CONF_ADMIN_SanitaryMatrixReportGet_GET]
		@LangID = N'en-US',
		@idfVersion = 115299280001054

SELECT	'Return Value' = @return_value

*/

*******************************************************/
(
	@LangID NVARCHAR(100),
	@idfVersion BIGINT
)
AS
BEGIN

	BEGIN TRY 
		SELECT	 
			mtx.intNumRow,
			mtx.idfAggrSanitaryActionMTX AS idfAggrSanitaryActionMTX,
			mtx.idfsSanitaryAction,
			S.[name] AS strSanitaryAction,
			sa.strActionCode

		FROM dbo.tlbAggrSanitaryActionMTX mtx
		INNER JOIN dbo.trtSanitaryAction sa ON sa.idfsSanitaryAction = mtx.idfsSanitaryAction
		INNER JOIN dbo.tlbAggrMatrixVersionHeader  amvh ON amvh.intRowStatus = 0 AND amvh.idfVersion = mtx.idfVersion
		INNER JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000079) S ON S.idfsReference = mtx.idfsSanitaryAction AND S.intRowStatus = 0
		WHERE mtx.intRowStatus = 0 AND  mtx.idfVersion = @idfVersion
		ORDER BY mtx.intNumRow ASC
		 

	END TRY
	BEGIN CATCH
			THROW;
	END CATCH
END
