

-- ================================================================================================
-- Name: USP_HAS_MONITORING_SESSION_TO_SAMPLE_TYPE_GETList
--
-- Description:	Get active surveillance monitoring session to sample type list for the human 
-- module active surveillance edit/set up use cases.
--                      
-- Revision History:
--	Name            Date		Change Detail
--	--------------	----------	-------------------------------------------------------------------
--	Stephen Long    07/06/2019	Initial release
--	Mark Wilson		08/17/2021	Changed to get from tlbMonitoringSessionToDiagnosis
--	Doug Albanese	12/22/2021	Refactored for Filtering and Paging
--	Doug Albanese	02/04/2022	Added missing First/Last record number for page content
--	Doug Albanese	05/25/2022	Corrected mismatched idfMonitoringSessionToDiagnosis with MonitoringSessionToSampleType
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_HAS_MONITORING_SESSION_TO_SAMPLE_TYPE_GETList] (
	@LanguageID NVARCHAR(50),
	@MonitoringSessionID BIGINT = NULL,
	@advancedSearch			NVARCHAR(100) = NULL,
	@pageNo					INT = 1,
	@pageSize				INT = 10 ,
	@sortColumn				NVARCHAR(30) = 'SampleTypeName',
	@sortOrder				NVARCHAR(4) = 'DESC'
	)
AS
BEGIN
	BEGIN TRY
		DECLARE @firstRec INT
		DECLARE @lastRec INT

		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)

		DECLARE @Results TABLE (
			MonitoringSessionToSampleType				BIGINT,
			MonitoringSessionToDiagnosisID				BIGINT,
			MonitoringSessionID							BIGINT,
			SampleTypeID								BIGINT,
			SampleTypeName								NVARCHAR(200),
			OrderNumber									INT,
			RowStatus									INT,
			RowAction									NVARCHAR(1)
		)
		INSERT INTO @Results
		SELECT 
			mst.MonitoringSessionToSampleType AS MonitoringSessionToSampleType,
			MSD.idfMonitoringSessionToDiagnosis AS MonitoringSessionToDiagnosisID,
			MSD.idfMonitoringSession AS MonitoringSessionID,
			MSD.idfsSampleType AS SampleTypeID,
			sampleType.name AS SampleTypeName,
			MSD.intOrder AS OrderNumber,
			MSD.intRowStatus AS RowStatus,
			'R' AS RowAction
		FROM dbo.tlbMonitoringSessionToDiagnosis MSD
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000087) AS sampleType
			ON sampleType.idfsReference = MSD.idfsSampleType
		LEFT JOIN MonitoringSessionToSampleType MST
			ON MST.idfMonitoringSession = MSD.idfMonitoringSession
		WHERE mst.idfMonitoringSession = @MonitoringSessionID
			AND mst.intRowStatus = 0;

		-- ========================================================================================
		-- FINAL QUERY, PAGINATION AND COUNTS
		-- ========================================================================================
		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @SortColumn = 'SampleTypeName' AND @SortOrder = 'ASC' THEN SampleTypeName END ASC
				,CASE WHEN @SortColumn = 'SampleTypeName' AND @SortOrder = 'DESC' THEN SampleTypeName END DESC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount,
				MonitoringSessionToSampleType,
				MonitoringSessionToDiagnosisID,
				MonitoringSessionID,
				SampleTypeID,
				SampleTypeName,
				OrderNumber,
				RowStatus,
				RowAction
			FROM @Results
		)
		SELECT
				TotalRowCount,
				MonitoringSessionToSampleType,
				MonitoringSessionToDiagnosisID,
				MonitoringSessionID,
				SampleTypeID,
				SampleTypeName,
				OrderNumber,
				RowStatus,
				RowAction,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
