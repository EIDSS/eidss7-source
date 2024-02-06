
-- ================================================================================================
-- Name: USP_HAS_MONITORING_SESSION_ACTION_GETList
--
-- Description:	Get monitoring session action list for the human module monitoring session 
-- edit/enter use cases.
--                      
-- Revision History:
-- Name             Date		Change Detail
-- ---------------- ----------	-------------------------------------------------------------------
-- Stephen Long     07/06/2019	Initial release
-- Doug Albanese	12/22/2021	Refactored for Paging and Filtering
-- Doug Albanese	01/28/2022	Added missing page filtering for first and last record of page
-- EXEC USP_HAS_MONITORING_SESSION_ACTION_GETList @LanguageId='en', @MonitoringSessionID = 404
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_HAS_MONITORING_SESSION_ACTION_GETList] (
	@LanguageID				NVARCHAR(50),
	@MonitoringSessionID	BIGINT = NULL,
	@advancedSearch			NVARCHAR(100) = NULL,
	@pageNo					INT = 1,
	@pageSize				INT = 10 ,
	@sortColumn				NVARCHAR(30) = 'ActionDate',
	@sortOrder				NVARCHAR(4) = 'DESC'
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @firstRec INT
		DECLARE @lastRec INT

		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)

		DECLARE @Results TABLE (
			MonitoringSessionActionID				BIGINT,
			MonitoringSessionID						BIGINT,
			EnteredByPersonID						BIGINT,
			EnteredByPersonName						NVARCHAR(200),
			MonitoringSessionActionTypeID			BIGINT,
			MonitoringSessionActionTypeName			NVARCHAR(200),
			MonitoringSessionActionStatusTypeID		BIGINT,
			MonitoringSessionActionStatusTypeName	NVARCHAR(200),
			ActionDate								DATETIME,
			Comments								NVARCHAR(MAX),
			RowStatus								INT,
			RowAction								NVARCHAR(1)
		)

		INSERT INTO @Results
		SELECT msa.idfMonitoringSessionAction AS MonitoringSessionActionID,
			msa.idfMonitoringSession AS MonitoringSessionID,
			msa.idfPersonEnteredBy AS EnteredByPersonID,
			ISNULL(p.strFamilyName, N'') + ISNULL(' ' + p.strFirstName, '') + ISNULL(' ' + p.strSecondName, '') AS EnteredByPersonName,
			msa.idfsMonitoringSessionActionType AS MonitoringSessionActionTypeID,
			monitoringSessionActionType.name AS MonitoringSessionActionTypeName,
			msa.idfsMonitoringSessionActionStatus AS MonitoringSessionActionStatusTypeID,
			monitoringSessionActionStatus.name AS MonitoringSessionActionStatusTypeName,
			msa.datActionDate AS ActionDate,
			msa.strComments AS Comments,
			msa.intRowStatus AS RowStatus,
			'R' AS RowAction
		FROM dbo.tlbMonitoringSessionAction msa
		LEFT JOIN dbo.tlbPerson AS p
			ON p.idfPerson = msa.idfPersonEnteredBy
				AND p.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000127) AS monitoringSessionActionType
			ON monitoringSessionActionType.idfsReference = msa.idfsMonitoringSessionActionType
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000128) AS monitoringSessionActionStatus
			ON monitoringSessionActionStatus.idfsReference = msa.idfsMonitoringSessionActionStatus
		WHERE (
				(msa.idfMonitoringSession = @MonitoringSessionID)
				OR (@MonitoringSessionID IS NULL)
				)
			AND msa.intRowStatus = 0;

		-- ========================================================================================
		-- FINAL QUERY, PAGINATION AND COUNTS
		-- ========================================================================================
		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @SortColumn = 'MonitoringSessionID' AND @SortOrder = 'ASC' THEN MonitoringSessionID END ASC
				,CASE WHEN @SortColumn = 'MonitoringSessionID' AND @SortOrder = 'DESC' THEN MonitoringSessionID END DESC
				,CASE WHEN @SortColumn = 'EnteredByPersonName' AND @SortOrder = 'ASC' THEN EnteredByPersonName END ASC
				,CASE WHEN @SortColumn = 'EnteredByPersonName' AND @SortOrder = 'DESC' THEN EnteredByPersonName END DESC
				,CASE WHEN @SortColumn = 'MonitoringSessionActionTypeName' AND @SortOrder = 'ASC' THEN MonitoringSessionActionTypeName END ASC
				,CASE WHEN @SortColumn = 'MonitoringSessionActionTypeName' AND @SortOrder = 'DESC' THEN MonitoringSessionActionTypeName END DESC
				,CASE WHEN @SortColumn = 'MonitoringSessionActionStatusTypeName' AND @SortOrder = 'ASC' THEN MonitoringSessionActionStatusTypeName END ASC
				,CASE WHEN @SortColumn = 'MonitoringSessionActionStatusTypeName' AND @SortOrder = 'DESC' THEN MonitoringSessionActionStatusTypeName END DESC
				,CASE WHEN @SortColumn = 'ActionDate' AND @SortOrder = 'ASC' THEN ActionDate END ASC
				,CASE WHEN @SortColumn = 'ActionDate' AND @SortOrder = 'DESC' THEN ActionDate END DESC
				,CASE WHEN @SortColumn = 'Comments' AND @SortOrder = 'ASC' THEN Comments END ASC
				,CASE WHEN @SortColumn = 'Comments' AND @SortOrder = 'DESC' THEN Comments END DESC
		) AS ROWNUM,
			COUNT(*) OVER () AS 
				TotalRowCount, 
				MonitoringSessionActionID,
				MonitoringSessionID,
				EnteredByPersonID,
				EnteredByPersonName,
				MonitoringSessionActionTypeID,
				MonitoringSessionActionTypeName,
				MonitoringSessionActionStatusTypeID,
				MonitoringSessionActionStatusTypeName,
				ActionDate,
				Comments,
				RowStatus,
				RowAction
			FROM @Results
		)
		SELECT
			ROWNUM,
				TotalRowCount, 
				MonitoringSessionActionID,
				MonitoringSessionID,
				EnteredByPersonID,
				EnteredByPersonName,
				MonitoringSessionActionTypeID,
				MonitoringSessionActionTypeName,
				MonitoringSessionActionStatusTypeID,
				MonitoringSessionActionStatusTypeName,
				ActionDate,
				Comments,
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
