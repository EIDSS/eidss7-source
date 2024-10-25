
-- ================================================================================================
-- Name: [USP_AS_CAMPAIGN_TO_DIAGNOSIS_SPECIES_SAMPLE_TYPE_GETList]
--
-- Description:	Get active surveillance campaign to diagnosis, species sample type list for the human/vet  module active 
-- surveillance campaign edit/set up use cases.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Mani Govindarajan     02/28/2922 Initial release
-- Mani Govindarajan     09/22/2022 Added HACode ,idfsSpecies in the output
-- Mani Govindarajan     09/30/2022 idfsSpecies as NUll in the temp table
/*

DECLARE	@return_value INT

EXEC	@return_value = [dbo].[USP_AS_CAMPAIGN_TO_DIAGNOSIS_SPECIES_SAMPLE_TYPE_GETList]
		@LanguageID = N'en-US',
		@CampaignID = 127

SELECT	'Return Value' = @return_value

GO

*/
-- ============================================================================
CREATE PROCEDURE [dbo].[USP_AS_CAMPAIGN_TO_DIAGNOSIS_SPECIES_SAMPLE_TYPE_GETList] 
(
	@LanguageID NVARCHAR(50),
	@CampaignID BIGINT = NULL,
	@pageNo INT = 1,
	@pageSize INT = 10,
	@sortColumn NVARCHAR(30) = 'strName',
	@sortOrder NVARCHAR(4) = 'asc'
)
AS
BEGIN
	BEGIN TRY

		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE
		( 
			idfCampaignToDiagnosis BIGINT NULL, 
			idfCampaign BIGINT NOT NULL, 
			idfsDiagnosis BIGINT NULL,
			Disease NVARCHAR(300) NULL,
			idfsSampleType BIGINT NULL,
			SampleTypeName NVARCHAR(300) NULL,
			idfsSpeciesType BIGINT NULL,
			SpeciesTypeName NVARCHAR(300) NULL,
			intOrder NVARCHAR(2000) NULL, 
			Comments NVARCHAR(2000) NULL,
			intPlannedNumber INT NULL,
			RowAction NVARCHAR(12) NOT NULL,
			HACode INT NULL,
			idfsSpecies BIGINT NULL

		)
		
		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)
		
		INSERT INTO @T

		SELECT 
			CD.idfCampaignToDiagnosis,
			CD.idfCampaign,
			CD.idfsDiagnosis,
			d.[name] AS Disease,
			CD.idfsSampleType,
			sampleType.[name] AS SampleTypeName,
			CD.idfsSpeciesType,
			speciesType.[name] AS SpeciesTypeName,
			CD.intOrder,
			CD.Comments,
			CD.intPlannedNumber,

			'R' AS RowAction,
			speciesType.intHACode As HACode,
			speciesType.idfsReference AS idfsSpecies


		FROM dbo.tlbCampaign C 
		INNER JOIN dbo.tlbCampaignToDiagnosis CD ON CD.idfCampaign = C.idfCampaign AND CD.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000087) AS sampleType ON sampleType.idfsReference = CD.idfsSampleType
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) as d on d.idfsReference = CD.idfsDiagnosis
		LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000086) AS speciesType ON speciesType.idfsReference = cd.idfsSpeciesType
		WHERE C.idfCampaign = @CampaignID
		AND CD.intRowStatus = 0;

		WITH cteResults AS
		(
			SELECT ROW_NUMBER() OVER 
			( ORDER BY 
				CASE WHEN @sortColumn = 'idfCampaignToDiagnosis' AND @SortOrder = 'asc' THEN idfCampaignToDiagnosis END ASC,
				CASE WHEN @sortColumn = 'idfCampaignToDiagnosis' AND @SortOrder = 'desc' THEN idfCampaignToDiagnosis END DESC,
				CASE WHEN @sortColumn = 'idfCampaign' AND @SortOrder = 'asc' THEN idfCampaign END ASC,
				CASE WHEN @sortColumn = 'idfCampaign' AND @SortOrder = 'desc' THEN idfCampaign END DESC,
				CASE WHEN @sortColumn = 'idfsDiagnosis' AND @SortOrder = 'asc' THEN idfsDiagnosis END ASC,
				CASE WHEN @sortColumn = 'idfsDiagnosis' AND @SortOrder = 'desc' THEN idfsDiagnosis END DESC,
				CASE WHEN @sortColumn = 'Disease' AND @SortOrder = 'asc' THEN Disease END ASC,
				CASE WHEN @sortColumn = 'Disease' AND @SortOrder = 'desc' THEN Disease END DESC,
				CASE WHEN @sortColumn = 'idfsSampleType' AND @SortOrder = 'asc' THEN idfsSampleType END ASC,
				CASE WHEN @sortColumn = 'idfsSampleType' AND @SortOrder = 'desc' THEN idfsSampleType END DESC,
				CASE WHEN @sortColumn = 'SampleTypeName' AND @SortOrder = 'asc' THEN SampleTypeName END ASC,
				CASE WHEN @sortColumn = 'SampleTypeName' AND @SortOrder = 'desc' THEN SampleTypeName END DESC,
				CASE WHEN @sortColumn = 'intPlannedNumber' AND @SortOrder = 'asc' THEN intPlannedNumber END ASC,
				CASE WHEN @sortColumn = 'intPlannedNumber' AND @SortOrder = 'desc' THEN intPlannedNumber END DESC,
				CASE WHEN @sortColumn = 'intOrder' AND @SortOrder = 'asc' THEN intOrder END ASC,
				CASE WHEN @sortColumn = 'intOrder' AND @SortOrder = 'desc' THEN intOrder END DESC,
				CASE WHEN @sortColumn = 'idfsSpeciesType' AND @SortOrder = 'asc' THEN intOrder END ASC,
				CASE WHEN @sortColumn = 'idfsSpeciesType' AND @SortOrder = 'desc' THEN intOrder END DESC,
				CASE WHEN @sortColumn = 'SpeciesTypeName' AND @SortOrder = 'asc' THEN intOrder END ASC,
				CASE WHEN @sortColumn = 'SpeciesTypeName' AND @SortOrder = 'desc' THEN intOrder END DESC
			) AS ROWNUM,		
		COUNT(*) OVER () AS 
				TotalRowCount,
				idfCampaignToDiagnosis, 
				idfCampaign,
				idfsDiagnosis,
				Disease,
				idfsSampleType, 
				SampleTypeName,
				idfsSpeciesType,
				SpeciesTypeName,
				intPlannedNumber, 
				Comments,			
				intOrder,
				HACode,
				idfsSpecies
			FROM @T
		)

			SELECT 
				TotalRowCount,
				idfCampaignToDiagnosis,
				idfCampaign,
				idfsDiagnosis,
				Disease,
				idfsSampleType,
				SampleTypeName,
				idfsSpeciesType,
				SpeciesTypeName,
				intPlannedNumber,
				Comments,
				intOrder,
				HACode,
				idfsSpecies,
				TotalPages = (TotalRowCount/@pageSize) + IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo

			FROM cteResults
			WHERE RowNum > @firstRec
			AND RowNum < @lastRec

	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
