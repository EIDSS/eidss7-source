
-- ================================================================================================
-- Name: USP_OMM_VET_SAMPLE_GETList
--
-- Description:	Get sample list for the Outbreak Vet Case module use case OMUC06.
--                      
-- Revision History:
-- Name             Date		Change Detail
-- ---------------- ----------	-------------------------------------------------------------------
-- Doug Albanese    12/12/2019	Initial release.
-- Doug Albanese	6/2/2020	Restructured for different process, outlined by BAs.
-- Doug Albanese	6/3/2020	Alterations again to get the data right
-- Doug Albanese	6/4/2020	Alterations again to include extra data to match up with the data
--								model used for the main sample listing in Vet
-- Doug Albanese	06/10/2020	Re-organized joins to pick up farm / owner connection
-- Doug Albanese	06/25/2020	Added ability to use wildcard search for both barcodes
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_OMM_VET_SAMPLE_GETList] (
	@LangId								NVARCHAR(50),
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
			m.idfMaterial								AS SampleID,
			SaTN.name									AS SampleTypeName,
			m.strBarcode,
			m.strFieldBarcode,
			SpTN.name									AS SpeciesTypeName,
			m.datFieldCollectionDate					AS CollectionDate,
			D.name										AS Diseasename,
			0											AS RowSelectionIndicator,
			m.idfsSampleType,
			m.strBarcode,
			m.strFieldBarcode,
			m.idfAnimal,
			m.idfSpecies,
			m.idfsBirdStatus,
			m.idfFieldCollectedByOffice,
			m.idfFieldCollectedByPerson,
			m.idfSendToOffice,
			m.strNote,
			BS.name										AS BirdStatus,
			O.name										AS FieldCollectedByOffice,
			P.name										AS FieldColectedByPerson,
			SO.name										AS SendToOffice
		FROM
			tlbMaterial m
		INNER JOIN		tlbSpecies s
		ON				s.idfSpecies = m.idfSpecies
		INNER JOIN		tlbHuman h
		ON				h.idfHuman = m.idfHuman
		INNER JOIN		tlbFarmActual fa
		ON				fa.idfHumanActual = h.idfHumanActual
		LEFT JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000087)  SaTN
		ON				SaTN.idfsReference = m.idfsSampleType
		LEFT JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000086)  SpTN
		ON				SpTN.idfsReference = s.idfsSpeciesType
		LEFT JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000019)  D
		ON				D.idfsReference = m.DiseaseID
		LEFT JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000006)  BS
		ON				BS.idfsReference = m.idfsBirdStatus
		LEFT JOIN		tlbOffice fcbo
		ON				fcbo.idfOffice = m.idfFieldCollectedByOffice
		LEFT JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000046) O
		ON				O.idfsReference = fcbo.idfsOfficeName
		LEFT JOIN		tlbPerson prb
		ON				prb.idfPerson = m.idfFieldCollectedByPerson
		LEFT JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000073) P
		ON				P.idfsReference = prb.idfsStaffPosition
		LEFT JOIN		tlbOffice sto
		ON				sto.idfOffice = m.idfSendToOffice
		LEFT JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000046) SO
		ON				SO.idfsReference = sto.idfsOfficeName
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
