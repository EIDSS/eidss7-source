

-- ================================================================================================
-- Name: USP_OMM_VET_SAMPLE_GETCount
--
-- Description:	Get sample list for the Outbreak Vet Case module use OMUC06.
--                      
-- Revision History:
-- Name             Date		Change Detail
-- ---------------- ----------	-------------------------------------------------------------------
-- Doug Albanese    12/12/2019	Initial release.
-- Doug Albanese	6/2/2020	Restructured for different process, outlined by BAs.
-- Doug Albanese	6/3/2020	Alterations again to get the data right
-- Doug Albanese	06/10/2020	Re-organized joins to pick up farm / owner connection
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_OMM_VET_SAMPLE_GETCount] (	
	@idfsDiagnosisOrDiagnosisGroup		BIGINT,
	@idfFarmActual						BIGINT,
	@strBarcode							NVARCHAR(200) = NULL,
	@strFieldBarcode					NVARCHAR(200) = NULL,
	@strMaterial						NVARCHAR(MAX) = NULL
)
AS
BEGIN
	DECLARE @ReturnCode		INT = 0;
	DECLARE @ReturnMessage	NVARCHAR(MAX) = 'SUCCESS';
	
	BEGIN TRY
		IF (@strMaterial = '.')
			BEGIN
				SET @strMaterial = ''
			END

		SELECT
			COUNT(m.idfMaterial) AS Records
		FROM
			tlbMaterial m
		INNER JOIN		tlbSpecies s
		ON				s.idfSpecies = m.idfSpecies
		INNER JOIN		tlbHuman h
		ON				h.idfHuman = m.idfHuman
		INNER JOIN		tlbFarmActual fa
		ON				fa.idfHumanActual = h.idfHumanActual
		
		WHERE
			fa.idfFarmActual = @idfFarmActual AND
			m.intRowStatus = 0 AND
			m.DiseaseID = @idfsDiagnosisOrDiagnosisGroup AND
			(
				(
					m.strFieldBarcode LIKE CASE ISNULL(@strFieldBarCode, '')
						WHEN ''
							THEN ''
						ELSE
							CONCAT('%', @strFieldBarCode, '%')
						END
				)
				OR 
				(
					m.strBarcode LIKE CASE ISNULL(@strBarCode, '')
						WHEN ''
							THEN ''
						ELSE
							CONCAT('%', @strBarCode, '%')
						END
				)
			)
			AND
			(
				m.idfMaterial NOT IN 
					(
						SELECT CAST([Value] AS BIGINT) FROM dbo.fnsysSplitList(@strMaterial, NULL, ',')
					) 
				OR @strMaterial IS NULL
			)

		SELECT @ReturnCode, @ReturnMessage
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT = 1 
			ROLLBACK;
		THROW;
	END CATCH
END
