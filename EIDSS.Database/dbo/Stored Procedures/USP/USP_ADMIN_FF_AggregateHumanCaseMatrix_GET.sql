

-- ================================================================================================
-- Name: USP_ADMIN_FF_AggregateHumanCaseMatrix_GET
-- Description: Selects data for AggregateHumanCaseMTXDetail form. 
--          
-- Revision History:
-- Name            Date			Change
-- --------------- ----------	--------------------------------------------------------------------
-- Kishore Kodru    1/2/2019	Initial release for new API.
-- Mark Wilson		10/01/2021	Cleaned and updated.
-- ================================================================================================

CREATE PROCEDURE [dbo].[USP_ADMIN_FF_AggregateHumanCaseMatrix_GET]
AS
BEGIN

	BEGIN TRY 
		SELECT	 
			mtx.idfAggrHumanCaseMTX AS idfHumanCaseMtx,
			ISNULL(amvh.idfVersion, 0) AS idfVersion,
			NULL AS idfDiagnosisRow,
			NULL AS idfIDCCodeRow,
			mtx.idfsDiagnosis,
			d.strIDC10,
			mtx.intNumRow

		FROM dbo.tlbAggrHumanCaseMTX mtx
		INNER JOIN dbo.trtDiagnosis d ON d.idfsDiagnosis = mtx.idfsDiagnosis
		INNER JOIN dbo.tlbAggrMatrixVersionHeader amvh ON amvh.intRowStatus = 0 AND amvh.idfVersion = mtx.idfVersion
		
		ORDER BY mtx.intNumRow

	END TRY
	BEGIN CATCH
		--IF @@TRANCOUNT > 0 
		--	ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END





